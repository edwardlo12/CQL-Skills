# Medical Code Validation Reference

## ICD-10-CM Code Validation

### Code Structure

**Format:** Letter + 2-7 digits (e.g., E11.9, S14.109A)

**Structure:**
- Category: 3 characters (e.g., E11)
- Subcategory: 4 characters (e.g., E11.9)
- Full code: up to 7 characters (e.g., S14.109A)

### Common ICD-10-CM Codes for NHI

**Diabetes:**
- E10.*: Type 1 diabetes mellitus
- E11.*: Type 2 diabetes mellitus
- E13.*: Other specified diabetes mellitus

**Cardiovascular:**
- I10: Essential (primary) hypertension
- I21.*: Acute myocardial infarction
- I50.*: Heart failure

**Coagulation disorders:**
- D68.*: Other coagulation defects
- D68.0: Von Willebrand disease
- D69.*: Purpura and other hemorrhagic conditions

**Pregnancy:**
- Z33.1: Pregnant state, incidental
- O00-O9A: Pregnancy, childbirth and the puerperium

**Spinal cord:**
- S14.*: Injury of nerves and spinal cord at neck level
- G95.*: Other diseases of spinal cord
- M43.3: Recurrent atlantoaxial subluxation with myelopathy

### Validation Checks

**Code existence:**
- Verify code exists in ICD-10-CM
- Check version applicability (2023, 2024, 2025)
- ⚠️ Flag deprecated codes

**Code appropriateness:**
- Code matches disease description
- Specificity appropriate (3-digit vs 7-digit)
- ⚠️ Too broad: Using E11 when E11.9 more appropriate
- ⚠️ Too specific: Using E11.65 when E11.* intended

**Filter operator correctness:**
- 3-character codes → use `descendent-of`
- Full codes (6-7 char) → use `=`
- Example: D68 → `descendent-of`, D68.0 → `=`

### Common Mistakes

❌ **Wrong specificity:**
```json
// Rules say "糖尿病" (broad)
// ValueSet only includes E11.9 (unspecified)
// Should include all E11.* or E10-E13.*
```

❌ **Missing subcategories:**
```json
// Rules say "脊髓損傷或病變"
// Only includes S14.* (injury)
// Missing G95.* (disease) and M43.3 (subluxation)
```

## LOINC Code Validation

### Code Structure

**Format:** Numeric code (e.g., 777-3, 2093-3)

**Components:**
- Component: What is measured (e.g., Platelets)
- Property: Kind of quantity (e.g., #/volume, Mass/volume)
- Time: Point in time vs 24-hour
- System: Blood, Serum, Urine
- Scale: Quantitative, Ordinal, Nominal

### Common LOINC Codes for NHI

**Hematology:**
- 777-3: Platelets [#/volume] in Blood
- 718-7: Hemoglobin [Mass/volume] in Blood
- 6690-2: White blood cells [#/volume] in Blood

**Chemistry:**
- 2093-3: Cholesterol [Mass/volume] in Serum or Plasma
- 2089-1: LDL Cholesterol [Mass/volume] in Serum or Plasma
- 2085-9: HDL Cholesterol [Mass/volume] in Serum or Plasma

**Diabetes monitoring:**
- 4548-4: Hemoglobin A1c/Hemoglobin.total in Blood
- 2345-7: Glucose [Mass/volume] in Serum or Plasma

**Renal function:**
- 2160-0: Creatinine [Mass/volume] in Serum or Plasma
- 33914-3: GFR/1.73 sq M.predicted [Volume Rate/Area] in Serum or Plasma by Creatinine-based formula (MDRD)

### Validation Checks

**Code correctness:**
- LOINC code matches lab test name
- Units compatible with test
- ⚠️ Wrong code: Using 718-7 (Hemoglobin) for platelets

**Unit validation:**
- `/uL` for cell counts (platelets, WBC)
- `mg/dL` for cholesterol, glucose
- `%` for HbA1c
- `mL/min/1.73m2` for GFR
- ⚠️ Wrong unit: Using `g/dL` for platelets

**Common test name → LOINC mappings:**

| Test name | LOINC | Typical unit |
|-----------|-------|--------------|
| 血小板 (Platelets) | 777-3 | /uL or 10*3/uL |
| 膽固醇 (Total cholesterol) | 2093-3 | mg/dL |
| LDL | 2089-1 | mg/dL |
| HDL | 2085-9 | mg/dL |
| 糖化血色素 (HbA1c) | 4548-4 | % |
| 血糖 (Glucose) | 2345-7 | mg/dL |
| 肌酸酐 (Creatinine) | 2160-0 | mg/dL |
| eGFR | 33914-3 | mL/min/1.73m2 |
| 血紅素 (Hemoglobin) | 718-7 | g/dL |

### Common Mistakes

❌ **Wrong LOINC code:**
```cql
// Rules say "血小板數量"
code "血小板": '718-7' from "LOINC"  // ❌ This is Hemoglobin
// Should be:
code "血小板": '777-3' from "LOINC"  // ✅ Correct
```

❌ **Unit mismatch:**
```cql
// LOINC 777-3 expects /uL or 10*3/uL
where C3F.QuantityValue(O) < 50000 'g/dL'  // ❌ Wrong unit
// Should be:
where C3F.QuantityValue(O) < 50000 '/uL'  // ✅ Correct
```

## SNOMED CT Code Validation

### Code Structure

**Format:** Numeric code (6-18 digits, typically 6-7 for specialties)

### Common Specialty Codes

**Medical specialties (example codes - verify for Taiwan):**
- 394537008: Pediatric specialty
- 394579002: Cardiology
- 394810000: Rheumatology
- 394801008: Neurology
- 394882004: Pain medicine
- 394609007: General surgery

**Important:** Taiwan NHI may use specific specialty codes. Always flag specialty codes for manual verification.

### Validation Checks

**Code existence:**
- Code exists in SNOMED CT
- Code represents correct concept
- ⚠️ **Always flag for manual verification** - Taiwan may use different codes

**Code appropriateness:**
- Code matches specialty description
- Example: "兒科" should map to Pediatric specialty code
- ⚠️ Multiple possible codes may exist - clarification needed

### Common Mistakes

⚠️ **Using wrong code system:**
```cql
// Using SNOMED CT for specialty when Taiwan NHI has specific system
code "兒科": '394537008' from "SCT"  // ⚠️ Verify this is correct for Taiwan
```

⚠️ **Using international code when local code exists:**
```cql
// Taiwan may have specific specialty coding system
// Always flag for verification with NHI standards
```

## Code Validation Workflow

### Step 1: Identify Code Type

Determine if code is:
- ICD-10-CM (diagnosis)
- ICD-10-PCS (procedure)
- LOINC (lab)
- SNOMED CT (clinical concepts)
- Local Taiwan codes

### Step 2: Verify Code Correctness

**For ICD-10-CM:**
1. Check code format valid (letter + digits)
2. Verify code exists in ICD-10-CM
3. Confirm code matches disease description
4. Check specificity appropriate

**For LOINC:**
1. Check code format valid (digits with hyphen)
2. Verify code exists in LOINC
3. Confirm code matches lab test name
4. Validate unit compatibility
5. Check component/property/system match

**For SNOMED CT:**
1. Check code format valid (numeric)
2. Verify code exists in SNOMED CT
3. **Always flag specialty codes for manual verification**
4. Confirm appropriateness for Taiwan NHI context

### Step 3: Check Code Coverage

When rules mention diseases/tests:
- Extract all mentioned conditions
- Verify each has corresponding code/ValueSet
- Check codes cover all mentioned variants
- ❌ Flag missing codes
- ⚠️ Flag potentially extra codes

### Step 4: Validate Filter Operators

For ValueSet compose.include:
- 3-char ICD codes → `descendent-of`
- Full ICD codes → `=`
- Multiple unrelated codes → `in`
- ⚠️ Flag potentially wrong operator

## Code Completeness Examples

### Example 1: Comprehensive Coverage ✅

**Rules:** "脊髓損傷或病變"

**Complete ValueSet:**
```json
{
  "compose": {
    "include": [
      {
        "system": "http://hl7.org/fhir/sid/icd-10-cm",
        "filter": [{
          "property": "concept",
          "op": "descendent-of",
          "value": "S14"
        }]
      },
      {
        "system": "http://hl7.org/fhir/sid/icd-10-cm",
        "filter": [{
          "property": "concept",
          "op": "descendent-of",
          "value": "G95"
        }]
      },
      {
        "system": "http://hl7.org/fhir/sid/icd-10-cm",
        "concept": [{
          "code": "M43.3"
        }]
      }
    ]
  }
}
```
✅ Covers injury (S14.*), disease (G95.*), and subluxation (M43.3)

### Example 2: Incomplete Coverage ❌

**Rules:** "凝血異常，疑有 Von Willebrand disease"

**Incomplete ValueSet:**
```json
{
  "compose": {
    "include": [{
      "system": "http://hl7.org/fhir/sid/icd-10-cm",
      "concept": [{
        "code": "D68.0"
      }]
    }]
  }
}
```
❌ Only includes D68.0, missing broader coagulation disorders (D68.*, D69.*)

**Should be:**
```json
{
  "compose": {
    "include": [{
      "system": "http://hl7.org/fhir/sid/icd-10-cm",
      "filter": [{
        "property": "concept",
        "op": "descendent-of",
        "value": "D68"
      }]
    }]
  }
}
```
✅ Covers all coagulation defects including VWD

## Quick Reference: Code Lookup

**ICD-10-CM lookup:** https://www.icd10data.com/
**LOINC lookup:** https://loinc.org/
**SNOMED CT lookup:** https://browser.ihtsdotools.org/

**When validating:**
1. Look up code in appropriate system
2. Verify display name matches
3. Check code currency (not deprecated)
4. Confirm appropriateness for Taiwan NHI
