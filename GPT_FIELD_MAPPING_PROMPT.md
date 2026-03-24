# GPT Prompt for EAPI-PAPI Field Mapping

## Copy and paste this entire prompt to GPT/ChatGPT:

---

You are an API integration specialist. I need you to create a detailed field mapping table between EAPI (Experience API) response and PAPI (Process API) responses.

## Input Files I Will Provide:
1. **EAPI Response Spec** - Fixed response structure (JSON/YAML)
2. **PAPI Spec(s)** - One or more PAPI endpoint specifications

## Your Task:
Create a comprehensive mapping table with these exact columns:

| EAPI Response Field | Field Info | EAPI Logic | PAPI System | PAPI Fields |
|---------------------|------------|------------|-------------|-------------|

### Column Definitions:

**EAPI Response Field**: 
- Use dot notation for nested fields
- Example: `data.customerName`, `data.orders[].orderId`, `data.address.street`

**Field Info**: 
- Data type: `string`, `number`, `boolean`, `object`, `array`, `array<object>`, `array<string>`, etc.
- Include format if relevant: `string (ISO8601)`, `number (currency)`, `string (email)`

**EAPI Logic**: 
- Leave EMPTY if direct field mapping (no transformation)
- If transformation needed, specify the logic:
  - `CONCAT(field1, " ", field2)` - Concatenation
  - `UPPERCASE(field)` - Case conversion
  - `FORMAT_DATE(field, "YYYY-MM-DD")` - Date formatting
  - `SUM(field1, field2)` - Calculation
  - `field1 || "default"` - Default value handling
  - `IF(condition, value1, value2)` - Conditional logic
  - `MAP(array, transformation)` - Array transformation
  - Custom logic description in plain English

**PAPI System**: 
- Name of the PAPI service/system
- Example: `Calculation Engine`, `Customer Service`, `Order Management`, `Payment Gateway`
- Include endpoint if multiple endpoints from same system

**PAPI Fields**: 
- Use dot notation matching PAPI response structure
- Example: `data.proposition.customerName`, `response.customer.fullName`
- If multiple fields needed, list with commas: `firstName, lastName`
- If from different PAPI calls, prefix with system: `CustomerService:data.name, OrderService:data.customerInfo.name`

## Instructions:

### Step 1: Analyze EAPI Response Structure
- Traverse the entire EAPI response JSON structure
- List EVERY field at all nesting levels
- Note arrays and their item structures

### Step 2: Match with PAPI Sources
For each EAPI field:
1. Search ALL provided PAPI specs for matching or related fields
2. Check for exact name matches first
3. Then check for semantic matches (e.g., `userName` vs `user_name` vs `name`)
4. Identify if multiple PAPI fields are needed

### Step 3: Determine Transformation Logic
- If field names and types match exactly → Leave EAPI Logic empty
- If names differ but semantics match → Note the mapping
- If aggregation needed → Document the calculation
- If data type conversion needed → Specify the conversion
- If conditional logic needed → Describe the condition

### Step 4: Handle Special Cases
- **Missing in PAPI**: Mark as `[NOT AVAILABLE IN PAPI]` in PAPI System column
- **Hardcoded values**: Mark as `[HARDCODED]` with value in EAPI Logic
- **Derived fields**: Mark as `[CALCULATED]` and specify formula in EAPI Logic
- **Multiple PAPI calls**: List all sources separated by semicolons

### Step 5: Validate Completeness
- Ensure EVERY EAPI field has a row
- Ensure no EAPI field is listed twice
- Flag any ambiguous mappings with `[REVIEW NEEDED]`

## Output Format:

Provide the mapping in two formats:

### Format 1: Markdown Table
```markdown
| EAPI Response Field | Field Info | EAPI Logic | PAPI System | PAPI Fields |
|---------------------|------------|------------|-------------|-------------|
| data.customerName | string | CONCAT(firstName, " ", lastName) | Customer Service | data.customer.firstName, data.customer.lastName |
| data.customerId | string | | Customer Service | data.customer.id |
| data.orders[].orderId | array<string> | | Order Management | data.orders[].id |
```

### Format 2: CSV (for easy import to Excel)
```csv
"EAPI Response Field","Field Info","EAPI Logic","PAPI System","PAPI Fields"
"data.customerName","string","CONCAT(firstName, "" "", lastName)","Customer Service","data.customer.firstName, data.customer.lastName"
"data.customerId","string","","Customer Service","data.customer.id"
"data.orders[].orderId","array<string>","","Order Management","data.orders[].id"
```

## Additional Analysis:

After the mapping table, provide:

### 1. Summary Statistics
- Total EAPI fields: X
- Direct mappings (no logic): X
- Transformed mappings: X
- Missing in PAPI: X
- Multiple PAPI sources needed: X

### 2. Complex Mappings Summary
List any fields requiring:
- Multiple PAPI calls
- Complex transformations
- Conditional logic
- Array transformations

### 3. Missing Fields Report
List EAPI fields that have NO matching PAPI source with recommendations:
- Could it be hardcoded?
- Should it come from a different PAPI not in spec?
- Is it a calculated/derived field?

### 4. PAPI Call Sequence
Based on the mappings, suggest the optimal sequence of PAPI calls:
```
Layer 0 (Independent):
- Customer Service: GET /customer
- Product Service: GET /products

Layer 1 (Depends on Layer 0):
- Order Management: GET /orders (needs customerId from Layer 0)
```

## Example Usage:

**User provides:**
```
EAPI Response:
{
  "data": {
    "customerName": "string",
    "totalAmount": "number",
    "orders": [{"orderId": "string"}]
  }
}

PAPI Specs:
1. Customer API: {"customer": {"firstName": "string", "lastName": "string"}}
2. Order API: {"orders": [{"id": "string", "amount": "number"}]}
```

**You generate:**
| EAPI Response Field | Field Info | EAPI Logic | PAPI System | PAPI Fields |
|---------------------|------------|------------|-------------|-------------|
| data.customerName | string | CONCAT(firstName, " ", lastName) | Customer API | customer.firstName, customer.lastName |
| data.totalAmount | number | SUM(orders[].amount) | Order API | orders[].amount |
| data.orders[].orderId | array<string> | | Order API | orders[].id |

---

## Now I'm ready! Please provide:
1. Your EAPI response specification (JSON/YAML)
2. Your PAPI specification(s) (JSON/YAML or endpoint descriptions)

I will generate the complete field mapping table for you.
