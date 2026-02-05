# Rule Element Extraction and Matching

## Table of Contents

1. Basic Information Extraction
2. Indication Verification
3. Contraindication Verification
4. Frequency Limit Verification
5. Age Restriction Verification
6. Specialty Restriction Verification
7. Lab Value Verification
8. Other Requirements

## 1. Basic Information Extraction

### Rule Number Matching

**Extract from rules text:**
- Look for "規則編號:", "代碼:", "Code:" patterns
- Extract alphanumeric code (e.g., "08111B")

**Verify in CQL:**
- Check library name matches: `library "08111B" version '0.0.1'`
- ❌ Flag mismatch as error

### Payment Points

**Extract from rules text:**
- Look for "給付點數:", "點數:", "points:" patterns
- Extract numeric value (e.g., "800點", "800 points")

**Verify in CQL:**
- Check `Recommendation` define contains point value
- Example: `define "Recommendation": '建議給付 800 點'`
- ❌ Flag missing point value as error

### Effective Date

**Extract from rules text:**
- Look for "生效日期:", "effective date:" patterns
- Optional - may not be present

**Verify in CQL:**
- Check if date mentioned in Rationale or Recommendation
- ⚠️ Flag as warning if missing (low priority)

## 2. Indication Verification

### Extract Indications from Rules

**Common patterns in rules text:**
- "適應症:", "Indications:"
- Numbered lists: "1. 糖尿病 2. 高血壓"
- Inline: "患有糖尿病或高血壓者"
- Detailed: "診斷為 ICD-10-CM E11 (Type 2 diabetes)"

**Extract disease/condition names:**
- Identify all medical conditions mentioned
- Note logical connectors (AND/OR)
- Extract specific ICD codes if mentioned

### Verify in CQL

**Check for ValueSet declarations:**
```cql
valueset "糖尿病 valueset": 'https://...'
valueset "高血壓 valueset": 'https://...'
```

**Check for condition logic:**
```cql
define "糖尿病":
  exists ( C3F.Confirmed([Condition: "糖尿病 valueset"]) )

define "高血壓":
  exists ( C3F.Confirmed([Condition: "高血壓 valueset"]) )

define "適應症":
  "糖尿病" or "高血壓"  // OR logic
  // OR
  "糖尿病" and "高血壓"  // AND logic
```

**Validation checks:**
- ✅ Each mentioned disease has ValueSet
- ✅ Logic connector (OR/AND) matches rules
- ❌ Missing ValueSet for mentioned disease
- ⚠️ Extra ValueSet not in rules (may be intentional)

### Verify ValueSet Contents

If rules mention specific ICD codes:
- Read corresponding ValueSet JSON
- Check compose.include contains those codes
- ❌ Flag missing codes

**Example:**
Rules say: "糖尿病 (E11.*, E10.*)"
ValueSet should include:
```json
{
  "compose": {
    "include": [{
      "system": "http://hl7.org/fhir/sid/icd-10-cm",
      "filter": [{
        "property": "concept",
        "op": "descendent-of",
        "value": "E11"
      }]
    }, {
      "system": "http://hl7.org/fhir/sid/icd-10-cm",
      "filter": [{
        "property": "concept",
        "op": "descendent-of",
        "value": "E10"
      }]
    }]
  }
}
```

## 3. Contraindication Verification

### Extract Contraindications from Rules

**Common patterns:**
- "禁忌症:", "Contraindications:"
- "禁用於:", "不得用於:"
- "不適用於懷孕婦女"
- Listed conditions that exclude eligibility

### Verify in CQL

**Check contraindications are EXCLUDED:**

Method 1: Separate define with negation
```cql
define "懷孕":
  exists ( C3F.Confirmed([Condition: "懷孕 valueset"]) )

define "MeetsInclusionCriteria":
  "適應症" and not "懷孕"
```

Method 2: Direct exclusion in logic
```cql
define "MeetsInclusionCriteria":
  "適應症"
    and not exists ( C3F.Confirmed([Condition: "懷孕 valueset"]) )
```

**Validation checks:**
- ✅ Each contraindication has exclusion logic
- ❌ Contraindication mentioned but not excluded
- ⚠️ Contraindication included instead of excluded (logic error)

**Common mistake:**
```cql
// WRONG - includes contraindication
define "MeetsInclusionCriteria":
  "適應症" and "懷孕"  // ❌ Should be "and not 懷孕"
```

## 4. Frequency Limit Verification

### Extract Frequency Limits from Rules

**Common patterns:**

| Rules text | Meaning | Expected implementation |
|------------|---------|------------------------|
| 一年限申報 X 次 | Max X times per year | `Count(...) < X` within 1 year |
| 每四年限一次 | Once per 4 years | `Count(...) < 1` within 4 years |
| 終身限一次 | Once in lifetime | `Count(...) < 1` all time |
| 每次治療間隔 X 週 | X weeks between treatments | Date difference check |
| 每月限 X 次 | Max X times per month | `Count(...) < X` within 1 month |

### Verify in CQL

**Standard pattern using ObservationLookBack:**
```cql
define "先前執行次數":
  Count(
    C3F.ObservationLookBack(
      [Observation: "相關檢驗 valueset"],
      1 year
    )
  )

define "頻率符合":
  "先前執行次數" < 3  // 一年限三次
```

**Alternative pattern using Procedure:**
```cql
define "過去一年執行記錄":
  [Procedure: "相關處置 valueset"] P
    where P.performed during Interval[Today() - 1 year, Today()]

define "頻率符合":
  Count("過去一年執行記錄") < 3
```

**Validation checks:**
- ✅ Time period matches rules (1 year, 4 years, etc.)
- ✅ Count limit matches rules (< 3, < 1, etc.)
- ❌ Missing frequency check when rules specify it
- ⚠️ Wrong time period (e.g., 6 months instead of 1 year)
- ⚠️ Wrong operator (e.g., <= instead of <)

## 5. Age Restriction Verification

### Extract Age Restrictions from Rules

**Common patterns:**

| Rules text | CQL implementation |
|------------|-------------------|
| X 歲以上 | `AgeInYears() >= X` |
| 未滿 X 歲 | `AgeInYears() < X` |
| X 歲以下 | `AgeInYears() <= X` |
| X 至 Y 歲 | `AgeInYears() >= X and AgeInYears() <= Y` |
| 6 歲以上未滿 13 歲 | `AgeInYears() >= 6 and AgeInYears() < 13` |

### Verify in CQL

**Standard pattern:**
```cql
define "年齡符合":
  AgeInYears() >= 6 and AgeInYears() < 13
```

**Validation checks:**
- ✅ Age bounds match rules exactly
- ✅ Operators correct (>, >=, <, <=)
- ❌ Missing age check when rules specify it
- ⚠️ Age bounds off by one (e.g., <= 13 instead of < 13)

## 6. Specialty Restriction Verification

### Extract Specialty Restrictions from Rules

**Common patterns:**
- "限...專科醫師執行": Practitioner qualification restriction
- "限...科別申報": Encounter service type restriction

**Examples:**
- "限兒科專科醫師執行"
- "限心臟內科醫師執行"
- "限復健科申報"

### Verify in CQL

**Practitioner qualification check:**
```cql
codesystem "SCT": 'http://snomed.info/sct'
code "兒科專科醫師": '24251000087109' from "SCT"

define "執行者符合資格":
  exists (
    [Practitioner] P
      where exists (
        P.qualification Q
          where Q.code ~ "兒科專科醫師"
      )
  )
```

**Encounter service type check:**
```cql
define "科別符合":
  exists (
    [Encounter] E
      where E.serviceType ~ "復健科 code"
  )
```

**Validation checks:**
- ✅ Specialty mentioned has corresponding check
- ✅ SNOMED CT code appropriate for specialty
- ❌ Missing specialty check when rules require it
- ⚠️ **SNOMED CT code correctness unclear** - mark for manual verification

**Important:** Taiwan NHI may use specific specialty codes - flag for verification

## 7. Lab Value Verification

### Extract Lab Conditions from Rules

**Common patterns:**
- "血小板數量 < 50,000 /uL"
- "LDL > 100 mg/dL"
- "HbA1c ≥ 7.0 %"
- "eGFR < 60 mL/min/1.73m2"

**Extract components:**
- Lab test name
- Comparison operator (<, >, <=, >=, =)
- Threshold value
- Unit

### Verify in CQL

**Standard pattern:**
```cql
codesystem "LOINC": 'http://loinc.org'
code "血小板數量": '777-3' from "LOINC" display 'Platelets [#/volume] in Blood'

define "血小板過低":
  exists (
    [Observation: "血小板數量"] O
      where C3F.QuantityValue(O) < 50000 '/uL'
        and O.status in {'final', 'corrected', 'amended'}
  )
```

**Validation checks:**
- ✅ LOINC code matches lab test name
- ✅ Comparison operator matches rules
- ✅ Threshold value matches rules
- ✅ Unit matches rules
- ❌ Missing lab check when rules specify it
- ⚠️ Wrong LOINC code for test
- ⚠️ Wrong unit conversion

**Common LOINC codes to verify:**
- 777-3: Platelets
- 2093-3: Cholesterol [Mass/volume] in Serum or Plasma
- 4548-4: Hemoglobin A1c
- 33914-3: GFR/1.73 sq M.predicted

## 8. Other Requirements

### Administrative Requirements

**Common patterns:**
- "應事先申請"
- "需檢附報告"
- "需經審查核准"

**Verify in CQL:**
- Should appear in Recommendation or Rationale
- Not enforced programmatically
- ⚠️ Flag if missing from documentation

**Example:**
```cql
define "Recommendation":
  if "InPopulation"
    then '建議給付 800 點。注意：需事先申請核准。'
    else null
```

### Payment Specifications

**Common patterns:**
- "材料費另計"
- "不含藥費"
- "特殊材料加收"

**Verify in CQL:**
- Should appear in Recommendation
- ⚠️ Flag if rules mention but CQL doesn't document

### Mutual Exclusivity

**Common patterns:**
- "不得同時申報 [其他項目]"
- "擇一給付"

**Verify in CQL:**
- Should check for absence of conflicting procedures/observations
- ❌ Flag if exclusivity rule not implemented

**Example:**
```cql
define "無同時申報項目":
  not exists ( [Procedure: "衝突項目 valueset"] )

define "MeetsInclusionCriteria":
  "適應症" and "無同時申報項目"
```

## Summary Checklist

When rules text is provided, extract and verify:

- [ ] Rule number matches library name
- [ ] Payment points in Recommendation
- [ ] All indications have ValueSets
- [ ] All contraindications excluded
- [ ] Frequency limits implemented
- [ ] Age restrictions enforced
- [ ] Specialty restrictions checked
- [ ] Lab value conditions present
- [ ] Administrative requirements documented
- [ ] Payment specs documented
- [ ] Mutual exclusivity enforced
