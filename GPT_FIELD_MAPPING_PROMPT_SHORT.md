# Quick GPT Prompt (Short Version)

## Copy this to GPT/ChatGPT:

---

I need you to map EAPI response fields to PAPI sources. Create a table with these columns:

**Columns:**
1. **EAPI Response Field** - Use dot notation (e.g., `data.customerName`, `data.orders[].id`)
2. **Field Info** - Data type (string, number, boolean, object, array, array<object>)
3. **EAPI Logic** - Transformation logic if needed, empty if direct mapping. Examples: `CONCAT(a, b)`, `SUM(x, y)`, `UPPERCASE(field)`
4. **PAPI System** - Which PAPI service (e.g., "Calculation Engine", "Customer Service")
5. **PAPI Fields** - Source fields in dot notation (e.g., `data.proposition.customerName`)

**Special markers:**
- `[NOT AVAILABLE]` - Field missing in PAPI
- `[HARDCODED]` - Static value
- `[CALCULATED]` - Derived/computed field

**Your task:**
1. List EVERY field in EAPI response (traverse all nested levels)
2. Find matching fields in PAPI specs
3. Document transformation logic if names/types don't match exactly
4. Flag missing or ambiguous mappings

**Output as:**
- Markdown table
- CSV format
- Summary of complex mappings
- List of missing fields

**I will provide:**
- EAPI response spec (fixed structure)
- PAPI spec(s) (one or more systems)

Ready? Please analyze my specs.

---

## Then paste your EAPI and PAPI specs below this prompt
