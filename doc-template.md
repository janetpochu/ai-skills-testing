# API Documentation Template
<!-- One file per endpoint. Replace all {{placeholders}}. -->

---

# {{Endpoint Name}} — API Documentation

> **Brief Description**
> {{1–3 sentences describing what this endpoint does, who calls it, and the business purpose.}}

---

## Application Architecture Summary

{{1–2 sentences summarising the overall application architecture relevant to this endpoint.}}

| Layer | Component | Responsibility | Example |
|---|---|---|---|
| API / Controller | `{{ControllerClassName}}` | Receives HTTP request, validates input, delegates to service | `POST /api/v1/{{path}}` |
| Service | `{{ServiceClassName}}` | Business logic, orchestration, error handling | `{{ServiceClassName}}.process()` |
| Repository / DAO | `{{RepositoryClassName}}` | Database access (if applicable) | `{{EntityName}}Repository.save()` |
| Downstream Client | `{{ClientClassName}}` | Calls external/SAPI service | `{{ClientClassName}}.call()` |
| DTO / Model | `{{RequestDto}}`, `{{ResponseDto}}` | Data transfer objects | `{{RequestDto}}.getField()` |
| Exception Handler | `{{ExceptionHandlerClass}}` | Maps exceptions to HTTP error responses | `{{ExceptionName}}` → `400` |

> Add or remove rows as needed. If a layer is not present, remove its row.

---

## Flow Diagram

```
Client
  │
  ▼
[{{ControllerClassName}}]  ── validates request headers & body
  │
  ▼
[{{ServiceClassName}}]     ── applies business logic
  │                           ── calls downstream if needed
  ├──► [{{SAPIClientClassName}}]  POST {{sapiPath}}
  │         └── returns {{sapiResponse}}
  │
  ▼
[{{ServiceClassName}}]     ── maps SAPI response → PAPI response
  │
  ▼
[{{ControllerClassName}}]  ── returns HTTP {{successStatus}} + response body
  │
  ▼
Client receives response
```

> Expand with branching paths (validation failure, error from downstream) if relevant.

---

## PAPI Request Info

**Path:** `{{/api/v1/example}}`
**Method:** `{{POST | GET | PUT | PATCH | DELETE}}`

### Request Headers

| Header | Description | Example | Required |
|---|---|---|---|
| `Authorization` | Bearer token for authentication | `Bearer eyJhbGci...` | Yes |
| `Content-Type` | Request body format | `application/json` | Yes |
| `{{HeaderName}}` | {{Description}} | `{{ExampleValue}}` | {{Yes/No}} |

> Remove rows that do not apply. Add all `@RequestHeader` parameters found in the controller.

### Request Body Structure

| Field | Type | Description | Example | Required |
|---|---|---|---|---|
| `{{fieldName}}` | `{{string}}` | {{What this field means and how it is used}} | `{{realistic-example}}` | {{Yes/No}} |
| `{{nested.fieldName}}` | `{{string}}` | {{Description of nested field}} | `{{realistic-example}}` | {{Yes/No}} |
| `{{items[].fieldName}}` | `{{string}}` | {{Description of array item field}} | `{{realistic-example}}` | {{Yes/No}} |

> **Expand every field — no collapsing nested objects into a single row.**
> Use dot-notation for nested fields, bracket-notation for array item fields.

#### Sample Request

```json
{
  "{{fieldName}}": "{{realistic-example}}",
  "{{nested}}": {
    "{{fieldName}}": "{{realistic-example}}"
  },
  "{{items}}": [
    {
      "{{fieldName}}": "{{realistic-example}}"
    }
  ]
}
```

### Request Validation Rules

| Field | Rule | Error Message |
|---|---|---|
| `{{fieldName}}` | {{e.g. Must not be blank}} | `{{e.g. fieldName is required}}` |
| `{{fieldName}}` | {{e.g. Max 50 characters}} | `{{e.g. fieldName exceeds maximum length}}` |
| `{{fieldName}}` | {{e.g. Must match pattern `^[A-Z]{3}$`}} | `{{e.g. Invalid format}}` |

> Map every `@NotNull`, `@NotBlank`, `@Size`, `@Pattern`, `@Min`, `@Max`, `@Email`, custom validator found on the DTO.

---

## PAPI Response

### Response Headers

| Header | Description | Example |
|---|---|---|
| `Content-Type` | Response body format | `application/json` |
| `{{HeaderName}}` | {{Description}} | `{{ExampleValue}}` |

<!-- ═══════════════════════════════════════════════════════════
     JWT SECTION — Include ONLY if a JWT / token is returned
     ═══════════════════════════════════════════════════════════ -->

#### JWT — `{{HeaderName or field name where JWT is returned}}`

| Field (Claim) | Type | Source | Description |
|---|---|---|---|
| `sub` | `string` | `{{e.g. user.getUserId()}}` | Subject — unique user identifier |
| `{{claimName}}` | `{{string}}` | `{{code source}}` | {{What this claim represents}} |
| `iat` | `long (epoch)` | Generated at runtime | Issued-at timestamp |
| `exp` | `long (epoch)` | `iat + {{N}} seconds` | Expiry timestamp |

<!-- ═══════════════════════════════════════════════════════════ -->

### Response Body Structure and Example

| Field | Type | Description | Example |
|---|---|---|---|
| `{{fieldName}}` | `{{string}}` | {{What this field contains}} | `{{realistic-example}}` |
| `{{nested.fieldName}}` | `{{string}}` | {{Description}} | `{{realistic-example}}` |
| `{{items[].fieldName}}` | `{{string}}` | {{Description of array item field}} | `{{realistic-example}}` |

> **Document every field returned in the response DTO, including nested objects and arrays.**

#### Sample Response — Success (`{{HTTP Status, e.g. 200 OK}}`)

```json
{
  "{{fieldName}}": "{{realistic-example}}",
  "{{nested}}": {
    "{{fieldName}}": "{{realistic-example}}"
  }
}
```

---

## PAPI Error Handling

| HTTP Status | Exception / Condition | Error Code | Description | Sample Response |
|---|---|---|---|---|
| `400` | `{{e.g. MethodArgumentNotValidException}}` | `{{VALIDATION_ERROR}}` | Request body fails validation | `{"code":"VALIDATION_ERROR","message":"fieldName is required"}` |
| `401` | `{{e.g. UnauthorizedException}}` | `{{UNAUTHORIZED}}` | Missing or invalid token | `{"code":"UNAUTHORIZED","message":"Token expired"}` |
| `404` | `{{e.g. ResourceNotFoundException}}` | `{{NOT_FOUND}}` | Resource does not exist | `{"code":"NOT_FOUND","message":"Record not found"}` |
| `500` | `{{e.g. RuntimeException}}` | `{{INTERNAL_ERROR}}` | Unexpected server error | `{"code":"INTERNAL_ERROR","message":"An unexpected error occurred"}` |

> Add every exception class found in `@ExceptionHandler` or `@ControllerAdvice`.
> If an error response body has a fixed structure, document it once above as a note.

---

## Data Mapping — PAPI Response ↔ SAPI Response

| PAPI Response Field | Type | SAPI Source Field | SAPI Service | Transformation / Note |
|---|---|---|---|---|
| `{{papiField}}` | `{{string}}` | `{{sapiResponseField}}` | `{{SAPIServiceName}}` | {{e.g. Direct mapping / uppercase / formatted}} |
| `{{papiField}}` | `{{string}}` | `{{hardcoded / computed}}` | — | {{e.g. Always "SUCCESS" / concatenation of X + Y}} |

> Every field in the PAPI response must have a row here.
> If the value is not from SAPI (e.g. computed, defaulted, from DB), note the source clearly.

---

## SAPI Request — {{SAPIServiceName}}

> Repeat this section for each downstream service call, in call order.

**Target Service:** `{{SAPIServiceName}}`
**Path:** `{{/sapi/v1/example}}`
**Method:** `{{POST}}`

### SAPI Request Headers

| Header | Value / Source | Description |
|---|---|---|
| `Authorization` | `{{e.g. Forwarded from PAPI request / generated}}` | Auth token for SAPI |
| `Content-Type` | `application/json` | Request body format |
| `{{HeaderName}}` | `{{value or source}}` | {{Description}} |

### SAPI Request Body

| Field | Type | Source | Description | Example |
|---|---|---|---|---|
| `{{sapiField}}` | `{{string}}` | `{{PAPI field: requestBody.fieldName}}` | {{What this field means to SAPI}} | `{{realistic-example}}` |
| `{{sapiField}}` | `{{string}}` | `{{Hardcoded: "CHANNEL_A"}}` | {{Description}} | `CHANNEL_A` |
| `{{sapiField}}` | `{{string}}` | `{{Computed: SHA256(userId + timestamp)}}` | {{Description}} | `3d4f...` |

> The **Source** column must always state where the value comes from:
> - `PAPI field: <fieldPath>` — copied from incoming request
> - `Hardcoded: <value>` — constant in code
> - `Computed: <formula>` — derived/calculated
> - `Config: <property key>` — from application config

#### Sample SAPI Request

```json
{
  "{{sapiField}}": "{{realistic-example}}"
}
```

### SAPI Response

**Expected HTTP Status:** `{{200 OK}}`

| Field | Type | Description | Example |
|---|---|---|---|
| `{{sapiResponseField}}` | `{{string}}` | {{What SAPI returns in this field}} | `{{realistic-example}}` |

#### Sample SAPI Response

```json
{
  "{{sapiResponseField}}": "{{realistic-example}}"
}
```

### SAPI Error Handling

| HTTP Status | Condition | How PAPI Handles It |
|---|---|---|
| `4xx` | {{e.g. Invalid request to SAPI}} | {{e.g. Wrap in PAPIException, return 400 to client}} |
| `5xx` | {{e.g. SAPI timeout / error}} | {{e.g. Retry once, then return 503 to client}} |

---

<!-- Add additional "## SAPI Request — <ServiceName>" sections for each downstream call -->
