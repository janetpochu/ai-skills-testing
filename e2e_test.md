---
name: api-testcase-gen
description: >
  Use this skill whenever the user wants to generate frontend test cases or sample responses from an API
  specification document. Triggers include: "generate test cases from spec", "create sample responses for
  frontend", "generate F/E test data", "create happy path and negative cases from API doc", "mock responses
  for testing", "boundary test cases from spec", or any request to turn an API documentation (.md or described
  spec) into structured JSON test scenarios. Always use this skill when an API doc exists and the user wants
  test data, sample payloads, or mock responses — even if they just say "generate test cases" or "make some
  samples for the frontend".
---

# API Test Case Generator Skill

Reads a structured API documentation file (produced by the `springboot-api-doc` skill or equivalent) and
generates a comprehensive set of named JSON test case files for frontend testing. Cases are derived
systematically from the spec — not invented — so every case has a traceable reason.

Output: one `<EndpointName>-test-cases.json` file containing all happy path, boundary, and negative cases,
plus a `<EndpointName>-test-index.md` summary table explaining each case.

---

## Step 1 — Read the API Documentation

The user will provide the spec in one of these ways:

| Input | Action |
|---|---|
| Uploaded `.md` file | `view /mnt/user-data/uploads/<filename>` |
| Pasted content | Read from conversation context |
| Previously generated doc | Read from `/mnt/user-data/outputs/<EndpointName>-api-doc.md` |

Read the **entire** document before proceeding. Do not generate cases from partial reading.

---

## Step 2 — Parse the Spec Into a Test Inventory

Silently extract the following from each section of the doc. This is internal working data — do not output it.

### 2A — Endpoint Metadata
- [ ] HTTP method
- [ ] Path
- [ ] Brief description (used as test file header comment)

### 2B — Request Field Inventory
For every row in the **Request Body Structure** table extract:
```
field_name | type | required (Yes/No) | example_value
```
Flag each field with applicable boundary sources:
- Has explicit validation rule → `HAS_VALIDATION`
- Required = Yes → `REQUIRED`
- Required = No → `OPTIONAL`
- Type is enum (fixed set of values listed) → `ENUM`
- Type is date/datetime → `DATE`
- Type is boolean → `BOOLEAN`
- Type is integer/number → `NUMERIC`
- Type is string with no other flag → `STRING`

### 2C — Validation Rule Inventory
For every row in **Request Validation Rules** table extract:
```
field_name | rule_type | constraint_value | error_message
```

Rule types to recognise:
| Annotation / Rule | Rule Type | Constraint Values to Extract |
|---|---|---|
| `@NotNull` / `@NotBlank` / `@NotEmpty` | REQUIRED | — |
| `@Size(min=X, max=Y)` | SIZE | min, max |
| `@Min(X)` / `@Max(Y)` | RANGE | min, max |
| `@Length(min=X, max=Y)` | SIZE | min, max |
| `@Pattern(regexp=...)` | PATTERN | regexp, valid example, invalid example |
| `@Email` | EMAIL | — |
| `@Positive` / `@PositiveOrZero` | RANGE | min=1 or min=0 |
| `@Negative` / `@NegativeOrZero` | RANGE | max=-1 or max=0 |
| `@DecimalMin` / `@DecimalMax` | RANGE | min, max |
| `@Future` / `@Past` | DATE_CONSTRAINT | future or past |
| Custom validator noted in doc | CUSTOM | note the rule description |

### 2D — Enum Value Inventory
For any field whose Description or Type column lists fixed accepted values (e.g. `"USD", "EUR", "SGD"`),
extract the full list. Each value becomes one happy case.

### 2E — Response Body Field Inventory
For every row in **Response Body Structure** table extract:
```
field_name | type | example_value
```
This is used to construct realistic response payloads.

### 2F — Error Handling Inventory
For every row in **PAPI Error Handling** table extract:
```
http_status | condition | error_code | sample_response_body
```
Each row becomes one negative test case.

### 2G — SAPI Failure Inventory
For each **SAPI Request** section, note:
- SAPI service name
- SAPI error rows (4xx, 5xx) and how PAPI handles them
Each SAPI error row becomes one negative test case.

### 2H — Optional Field Inventory
All fields where Required = `No`. Each becomes one happy case where the field is omitted.

---

## Step 3 — Derive Test Cases Systematically

Apply the derivation rules below. Every case must have a generated `case_id`, `category`, `description`,
and `reason` (why this case exists, traceable to the spec).

### 3A — Happy Path Cases

**HAPPY_001 — Baseline**
Always generate exactly one baseline case: all required fields present, all optional fields included,
all values taken from the `Example` column of the Request Body table.

**HAPPY_00N — Optional Field Omitted (one per optional field)**
For each field where Required = `No`:
- Generate one case identical to baseline but with that field removed
- Description: `"Optional field '{fieldName}' omitted — endpoint should still succeed"`
- Reason: `"Field marked Required=No in spec"`

**HAPPY_00N — Enum Values (one per enum value per enum field)**
For each enum field, generate one case per valid value (using baseline for all other fields):
- Description: `"{fieldName} = '{value}' (valid enum)"`
- Reason: `"Each enum value must be accepted per spec"`

**HAPPY_00N — Boundary Minimum (one per bounded field)**
For each field with a SIZE or RANGE rule:
- Set the field to its minimum allowed value
- For SIZE min: string of exactly `min` characters (use realistic character, not `"a"` repeated — use
  the field's context, e.g. a name field uses `"Jo"`, an ID field uses the shortest valid ID pattern)
- For RANGE min: the exact minimum number
- Description: `"{fieldName} at minimum boundary ({min})"`
- Reason: `"@Size/@Min constraint — min boundary is {min}"`

**HAPPY_00N — Boundary Maximum (one per bounded field)**
- Set the field to its maximum allowed value
- For SIZE max: string of exactly `max` characters (fill with contextually appropriate characters)
- For RANGE max: the exact maximum number
- Description: `"{fieldName} at maximum boundary ({max})"`
- Reason: `"@Size/@Max constraint — max boundary is {max}"`

**HAPPY_00N — Boolean Variations**
For each boolean field: generate one case with `true` and one with `false`.

### 3B — Negative / Edge Cases

**NEG_001 to NEG_00N — Missing Required Fields (one per required field)**
For each field where Required = `Yes`:
- Generate one case identical to baseline but with that field removed entirely
- Expected response: HTTP 400
- Description: `"Required field '{fieldName}' missing"`
- Reason: `"Field marked Required=Yes — omission must return 400"`

**NEG_00N — Below Minimum Boundary (one per bounded field)**
For SIZE: string of `min - 1` characters (or empty string if min=1)
For RANGE: `min - 1` value
Expected: HTTP 400 + validation error message from spec

**NEG_00N — Above Maximum Boundary (one per bounded field)**
For SIZE: string of `max + 1` characters
For RANGE: `max + 1` value
Expected: HTTP 400 + validation error message from spec

**NEG_00N — Invalid Format (one per PATTERN / EMAIL / DATE field)**
- PATTERN: provide a string that clearly violates the regexp
- EMAIL: provide `"notanemail"` or `"missing@"` 
- DATE: provide `"not-a-date"`, wrong separator (`"20240101"`), invalid month (`"2024-13-01"`)
Expected: HTTP 400

**NEG_00N — Wrong Type**
For numeric fields: send a string value e.g. `"abc"`
For date fields: send an integer
Expected: HTTP 400

**NEG_00N — Invalid Enum Value**
For each enum field: send one value not in the accepted list (e.g. `"INVALID"`)
Expected: HTTP 400

**NEG_00N — Null on Required Field**
For each Required=Yes field that is not a primitive: send explicitly `null`
Expected: HTTP 400

**NEG_00N — Error Handling Table Cases**
For each row in the Error Handling table:
- Create one case that triggers that exact condition
- Use the sample response body from the table as the expected response
- Description: taken from the Condition column
- Expected: HTTP status from the table

**NEG_00N — SAPI Downstream Failures**
For each SAPI error row:
- Create one case representing that downstream failure scenario
- Note in `setup_note`: what the mock/stub needs to return to trigger this case
- Expected: the PAPI response as described in the error handling section

---

## Step 4 — Self-Review Cross-Check (MANDATORY)

Before generating any JSON, verify:

```
SELF-REVIEW CHECKLIST
=====================
[ ] HAPPY_001 baseline exists
[ ] One optional-omit case exists for every Required=No field
[ ] Two boundary cases (min + max) exist for every bounded field
[ ] One case per enum value exists for every enum field
[ ] One missing-field negative case exists for every Required=Yes field
[ ] Below-min and above-max negative cases exist for every bounded field
[ ] One invalid-format case exists for every PATTERN/EMAIL/DATE field
[ ] Every error row in Error Handling table has a corresponding NEG case
[ ] Every SAPI error row has a corresponding NEG case
[ ] Every case has: case_id, category, description, reason, request, expected_response
[ ] No example value is a type placeholder ("string", "integer", "boolean") — all are realistic
[ ] Boundary string values are contextually appropriate, not just repeated "a" characters
```

Fix any gap before outputting.

---

## Step 5 — Generate JSON Output

Produce two files:

### File 1: `<EndpointName>-test-cases.json`

Follow the schema in `references/test-case-schema.json` exactly.

Top-level structure:
```json
{
  "endpoint": {
    "method": "POST",
    "path": "/api/v1/example",
    "description": "Brief description from spec"
  },
  "generated_at": "<ISO date>",
  "summary": {
    "total": 0,
    "happy": 0,
    "negative": 0
  },
  "test_cases": [ ... ]
}
```

Each test case object:
```json
{
  "case_id": "HAPPY_001",
  "category": "happy",
  "sub_category": "baseline | optional_omit | boundary_min | boundary_max | enum | boolean",
  "description": "Human-readable description of what this case tests",
  "reason": "Traceable reason from spec (which rule/field/section drives this case)",
  "request": {
    "headers": { },
    "body": { }
  },
  "expected_response": {
    "http_status": 200,
    "headers": { },
    "body": { }
  },
  "setup_note": "Optional: what mock/stub needs to be configured for this case to work"
}
```

**Rules for request body values:**
- Use the example from the spec for baseline
- For boundary cases: use the exact boundary value, keep all other fields as baseline
- For negative cases: change only the field under test, keep all other fields valid (baseline)
- Never change more than one thing at a time in a negative case — isolate the failure

**Rules for expected_response body:**
- Happy cases: use the Response Body example from the spec, with field values that make sense
  for the specific request scenario (adjust where the response logically differs)
- Negative cases: use the error response structure from the Error Handling table
- SAPI failure cases: use the PAPI error response that the spec says SAPI errors map to

### File 2: `<EndpointName>-test-index.md`

A summary table the F/E team can use as a quick reference:

```markdown
# Test Case Index — <EndpointName>

| Case ID | Category | Description | Expected HTTP | Reason |
|---|---|---|---|---|
| HAPPY_001 | Happy / Baseline | All fields valid | 200 | Baseline positive case |
| HAPPY_002 | Happy / Optional Omit | Field 'remarks' omitted | 200 | Required=No in spec |
| NEG_001 | Negative / Missing Field | 'customerId' missing | 400 | Required=Yes in spec |
...

**Total: N cases (X happy, Y negative)**
```

Save both files to `/mnt/user-data/outputs/` and present them.

---

## Step 6 — Final Output Statement

End your response with:

```
✅ Test cases generated.

Endpoint: METHOD /path
Total cases: N
  Happy path:  X
    - Baseline: 1
    - Optional omit: N
    - Boundary (min/max): N
    - Enum variations: N
    - Boolean variations: N
  Negative: Y
    - Missing required fields: N
    - Boundary violations: N
    - Invalid format: N
    - Invalid enum: N
    - Error handling table: N
    - SAPI failure scenarios: N

Files:
  📄 <EndpointName>-test-cases.json
  📄 <EndpointName>-test-index.md

⚠ Inferred / uncertain: <list any values that could not be derived from spec, or "None">
```

---

## Reference Files

📄 `references/test-case-schema.json` — Full JSON schema for the output file (read before generating)
