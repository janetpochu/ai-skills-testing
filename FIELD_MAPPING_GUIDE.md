# Complete Guide: Fast EAPI-PAPI Field Mapping with GPT

## Overview
This guide helps you quickly generate field mappings between your fixed EAPI response and multiple PAPI sources using ChatGPT or any GPT-based AI.

---

## 📋 What You'll Get

A complete mapping table with:
- Every EAPI field mapped to its PAPI source(s)
- Transformation logic documentation
- Missing field identification
- Complex mapping highlights

---

## 🚀 Quick Start (3 Steps)

### Step 1: Prepare Your Files
Gather these files:
- ✅ EAPI response specification (JSON/YAML)
- ✅ PAPI specification(s) - all systems that EAPI calls

### Step 2: Use One of Three Prompts

#### Option A: Detailed Prompt (Most Comprehensive)
📄 Use: `GPT_FIELD_MAPPING_PROMPT.md`
- Best for: Complex integrations with multiple PAPIs
- Includes: Detailed instructions, validation rules, output formats
- Time: ~2-5 minutes for GPT to process

#### Option B: Short Prompt (Balanced)
📄 Use: `GPT_FIELD_MAPPING_PROMPT_SHORT.md`
- Best for: Standard integrations
- Includes: Essential instructions with examples
- Time: ~1-3 minutes for GPT to process

#### Option C: Ultra-Short Prompt (Quick)
📄 Use: `GPT_FIELD_MAPPING_ULTRA_SHORT.txt`
- Best for: Simple integrations or quick iterations
- Includes: Minimal instructions, inline examples
- Time: ~30-60 seconds for GPT to process

### Step 3: Review & Export
- Copy the markdown table to your documentation
- Export CSV to Excel/Google Sheets for team collaboration
- Use the analysis to identify gaps and complex scenarios

---

## 📝 Output Format

You'll receive a table like this:

| EAPI Response Field | Field Info | EAPI Logic | PAPI System | PAPI Fields |
|---------------------|------------|------------|-------------|-------------|
| data.customerName | string | CONCAT(firstName, " ", lastName) | Customer Service | data.customer.firstName, data.customer.lastName |
| data.customerId | string | | Customer Service | data.customer.id |
| data.totalSpent | number | SUM(orders[].total) | Order Management | data.orders[].orderTotal |
| data.isActive | boolean | | Customer Service | data.customer.activeStatus |
| data.recommendations[] | array<object> | [NOT AVAILABLE] | N/A | N/A |

---

## 🎯 Understanding the Columns

### 1. EAPI Response Field
**Format:** Dot notation for nested structures
- Simple field: `data.customerName`
- Nested object: `data.address.street`
- Array field: `data.orders[]`
- Array item property: `data.orders[].orderId`

### 2. Field Info
**Format:** Data type with optional format details
- Primitives: `string`, `number`, `boolean`
- Objects: `object`
- Arrays: `array`, `array<string>`, `array<object>`
- With format: `string (ISO8601)`, `number (currency)`

### 3. EAPI Logic
**When to use:** Only when transformation is needed

**Leave EMPTY for:**
- Direct field mapping (same name, same type)
- Simple field renaming

**Common transformations:**
```
CONCAT(field1, " ", field2)          - String concatenation
UPPERCASE(field)                      - Convert to uppercase
LOWERCASE(field)                      - Convert to lowercase
FORMAT_DATE(field, "YYYY-MM-DD")     - Date formatting
SUM(array[].field)                   - Sum array values
DEFAULT(field, "value")              - Default value if null
IF(condition, trueValue, falseValue) - Conditional
MAP(array, transformation)           - Array transformation
FILTER(array, condition)             - Array filtering
ROUND(number, 2)                     - Number rounding
```

**Special markers:**
```
[HARDCODED: "value"]   - Static value not from PAPI
[CALCULATED]           - Requires business logic
[GENERATED]            - Generated at runtime (timestamp, UUID)
```

### 4. PAPI System
**Format:** Descriptive name of the PAPI service

Examples:
- Customer Service
- Calculation Engine
- Order Management
- Payment Gateway
- Loyalty Service
- Marketing Engine

**Special values:**
- `N/A` - For hardcoded/generated fields
- `[CALCULATED]` - For derived fields using business logic

### 5. PAPI Fields
**Format:** Dot notation matching PAPI response structure

**Simple mapping:**
```
data.customer.id
response.user.email
```

**Multiple fields (same PAPI):**
```
data.customer.firstName, data.customer.lastName
```

**Multiple PAPIs:**
```
CustomerService:data.name, OrderService:data.customerName
```

**Special values:**
```
N/A                    - For hardcoded/generated fields
[SEE LOGIC]            - Complex calculation explained in EAPI Logic
```

---

## 🔧 Common Transformation Patterns

### Pattern 1: Name Concatenation
```
EAPI Field: data.fullName
EAPI Logic: CONCAT(firstName, " ", lastName)
PAPI Fields: data.customer.firstName, data.customer.lastName
```

### Pattern 2: Array Aggregation
```
EAPI Field: data.totalAmount
EAPI Logic: SUM(orders[].amount)
PAPI Fields: data.orders[].orderAmount
```

### Pattern 3: Conditional Logic
```
EAPI Field: data.membershipLevel
EAPI Logic: IF(points > 1000, "Gold", IF(points > 500, "Silver", "Bronze"))
PAPI Fields: data.loyalty.points
```

### Pattern 4: Multiple PAPI Sources
```
EAPI Field: data.userScore
EAPI Logic: (purchases * 10) + (reviews * 5)
PAPI System: Order Service; Review Service
PAPI Fields: OrderService:data.totalPurchases, ReviewService:data.reviewCount
```

### Pattern 5: Default Value
```
EAPI Field: data.language
EAPI Logic: DEFAULT(preferredLang, "en")
PAPI Fields: data.customer.preferredLanguage
```

### Pattern 6: Date Formatting
```
EAPI Field: data.registeredDate
EAPI Logic: FORMAT_DATE(created, "YYYY-MM-DD")
PAPI Fields: data.customer.createdAt
```

### Pattern 7: Array Filtering
```
EAPI Field: data.activePromotions[]
EAPI Logic: FILTER(promotions, status="active")
PAPI Fields: data.marketing.promotions[]
```

---

## 🎓 Example Prompts in Action

### Example 1: Simple Use Case

**Your Input to GPT:**
```
[Paste Ultra-Short Prompt]

EAPI Spec:
{
  "data": {
    "userId": "string",
    "userName": "string"
  }
}

PAPI Spec:
{
  "user": {
    "id": "string",
    "first_name": "string",
    "last_name": "string"
  }
}
```

**GPT Output:**
| EAPI Field | Type | Logic | PAPI System | PAPI Source |
|------------|------|-------|-------------|-------------|
| data.userId | string | | User Service | user.id |
| data.userName | string | CONCAT(first_name, " ", last_name) | User Service | user.first_name, user.last_name |

### Example 2: Complex Use Case

**Your Input to GPT:**
```
[Paste Detailed Prompt]

EAPI Spec:
{
  "data": {
    "customer": {
      "id": "string",
      "name": "string",
      "totalSpent": "number"
    },
    "orders": [
      {
        "orderId": "string",
        "amount": "number",
        "status": "string"
      }
    ]
  }
}

PAPI Specs:

1. Customer API:
{
  "customer": {
    "customerId": "string",
    "firstName": "string",
    "lastName": "string"
  }
}

2. Order API:
{
  "orders": [
    {
      "id": "string",
      "total": "number",
      "orderStatus": "string"
    }
  ]
}
```

**GPT Output:**
| EAPI Field | Type | Logic | PAPI System | PAPI Source |
|------------|------|-------|-------------|-------------|
| data.customer.id | string | | Customer API | customer.customerId |
| data.customer.name | string | CONCAT(firstName, " ", lastName) | Customer API | customer.firstName, customer.lastName |
| data.customer.totalSpent | number | SUM(orders[].total) | Order API | orders[].total |
| data.orders[] | array<object> | | Order API | orders[] |
| data.orders[].orderId | string | | Order API | orders[].id |
| data.orders[].amount | number | | Order API | orders[].total |
| data.orders[].status | string | | Order API | orders[].orderStatus |

---

## 📊 Working with the Output

### In Markdown (for Documentation)
Copy the markdown table directly into:
- Confluence pages
- GitHub READMEs
- Technical specifications
- API documentation

### In CSV (for Collaboration)
Import into:
- Excel for team review
- Google Sheets for collaborative editing
- JIRA for ticket creation
- Project management tools

### In Code Comments
Use as reference when implementing:
```javascript
// EAPI Field: data.customerName
// PAPI Source: customer.firstName, customer.lastName
// Logic: CONCAT(firstName, " ", lastName)
const customerName = `${papi.customer.firstName} ${papi.customer.lastName}`;
```

---

## ✅ Validation Checklist

After receiving GPT output, verify:

- [ ] **Completeness**: Every EAPI field is listed
- [ ] **Accuracy**: Field types match between EAPI and PAPI
- [ ] **Logic**: Transformations are clear and implementable
- [ ] **Missing Fields**: Identified and marked appropriately
- [ ] **Arrays**: Array fields and their children are mapped
- [ ] **Nested Objects**: All nested levels are captured
- [ ] **Special Cases**: Hardcoded, calculated, and generated fields noted

---

## 🚨 Common Issues & Solutions

### Issue 1: GPT Misses Nested Fields
**Solution:** Explicitly ask GPT to "traverse all nested levels and list every field"

### Issue 2: Ambiguous Mappings
**Solution:** Ask GPT to "flag ambiguous mappings and provide alternatives"

### Issue 3: Missing Transformation Logic
**Solution:** Ask GPT to "explain all transformations in pseudo-code format"

### Issue 4: Incomplete PAPI Sources
**Solution:** Provide all PAPI specs at once, or tell GPT "if field is missing in provided PAPIs, mark as [NOT AVAILABLE]"

---

## 💡 Pro Tips

1. **Iterative Approach**: Start with ultra-short prompt for quick overview, then use detailed prompt for complex sections

2. **Batch Processing**: Group related fields and ask GPT to focus on specific sections (e.g., "map only data.customer.* fields")

3. **Version Control**: Save each mapping iteration with version numbers (v1, v2, etc.)

4. **Reuse Patterns**: Build a library of common transformation patterns from your mappings

5. **Validate with Code**: Generate sample code from the mapping to verify logic is correct

6. **Team Review**: Share CSV with developers for technical validation

7. **Update PAPI Changes**: When PAPI specs change, provide only the changed sections to GPT with instruction "update existing mapping"

---

## 📚 Files Included

1. **GPT_FIELD_MAPPING_PROMPT.md** - Comprehensive detailed prompt
2. **GPT_FIELD_MAPPING_PROMPT_SHORT.md** - Balanced concise prompt
3. **GPT_FIELD_MAPPING_ULTRA_SHORT.txt** - Minimal quick prompt
4. **field_mapping_template.csv** - Example output with 25+ mapping patterns
5. **FIELD_MAPPING_GUIDE.md** - This guide (you are here)

---

## 🎯 Next Steps

1. Choose your prompt based on complexity
2. Gather your EAPI and PAPI specs
3. Copy prompt to ChatGPT/GPT-4
4. Paste your specs
5. Review and validate output
6. Export to your preferred format
7. Share with your development team

---

## 📞 Need Help?

If GPT's output isn't matching your needs:
- Try a different prompt version
- Break down complex specs into smaller chunks
- Provide example mappings to guide GPT
- Add specific instructions for your unique requirements

**Remember:** The more specific your PAPI and EAPI specs, the better the mapping quality!
