# Common NHI Rule Implementation Patterns

## Frequency Limit Patterns

### Pattern 1: Annual Limit (一年限 X 次)

**Rules text:** "一年限申報三次"

**CQL implementation:**
```cql
define "過去一年執行次數":
  Count(
    C3F.ObservationLookBack(
      [Observation: "相關檢驗 valueset"],
      1 year
    )
  )

define "頻率符合":
  "過去一年執行次數" < 3

define "MeetsInclusionCriteria":
  "適應症" and "頻率符合"
```

### Pattern 2: Multi-Year Limit (每 X 年限一次)

**Rules text:** "每四年限一次"

**CQL implementation:**
```cql
define "過去四年執行次數":
  Count(
    C3F.ObservationLookBack(
      [Observation: "相關檢驗 valueset"],
      4 years
    )
  )

define "頻率符合":
  "過去四年執行次數" < 1
```

### Pattern 3: Lifetime Limit (終身限一次)

**Rules text:** "終身限申報一次"

**CQL implementation:**
```cql
define "過去所有執行記錄":
  [Observation: "相關檢驗 valueset"]

define "頻率符合":
  Count("過去所有執行記錄") < 1
```

### Pattern 4: Treatment Interval (間隔 X 週/月)

**Rules text:** "每次治療應間隔四週"

**CQL implementation:**
```cql
define "最近一次執行":
  Last(
    [Observation: "相關檢驗 valueset"] O
      sort by (issued as FHIR.instant).value
  )

define "間隔足夠":
  "最近一次執行" is null
    or (Today() - 4 weeks) >= ("最近一次執行".issued as FHIR.instant).value
```

## Age Restriction Patterns

### Pattern 1: Minimum Age (X 歲以上)

**Rules text:** "限六歲以上"

```cql
define "年齡符合":
  AgeInYears() >= 6
```

### Pattern 2: Maximum Age (未滿 X 歲)

**Rules text:** "限未滿十三歲"

```cql
define "年齡符合":
  AgeInYears() < 13
```

### Pattern 3: Age Range (X-Y 歲)

**Rules text:** "限六歲以上未滿十三歲"

```cql
define "年齡符合":
  AgeInYears() >= 6 and AgeInYears() < 13
```

**Alternative phrasing:** "6-13歲" → same implementation

## Specialty Restriction Patterns

### Pattern 1: Physician Specialty

**Rules text:** "限兒科專科醫師執行"

```cql
codesystem "SCT": 'http://snomed.info/sct'
code "兒科專科醫師": '24251000087109' from "SCT" display 'Pediatric specialty'

define "執行醫師":
  [Practitioner] P
    where exists (
      P.qualification Q
        where Q.code ~ "兒科專科醫師"
    )

define "專科符合":
  exists "執行醫師"
```

**Note:** SNOMED CT codes for specialties may need verification for Taiwan NHI

### Pattern 2: Department/Service Type

**Rules text:** "限復健科申報"

```cql
codesystem "ActCode": 'http://terminology.hl7.org/CodeSystem/v3-ActCode'
code "復健科": 'REHAB' from "ActCode"

define "科別符合":
  exists (
    [Encounter] E
      where E.serviceType ~ "復健科"
  )
```

## Indication Patterns

### Pattern 1: Single Indication

**Rules text:** "適應症：糖尿病"

```cql
valueset "糖尿病 valueset": 'https://example.org/fhir/ValueSet/diabetes'

define "糖尿病":
  exists ( C3F.Confirmed([Condition: "糖尿病 valueset"]) )

define "適應症":
  "糖尿病"
```

### Pattern 2: Multiple Indications (OR logic)

**Rules text:** "適應症：糖尿病或高血壓"

```cql
valueset "糖尿病 valueset": 'https://example.org/fhir/ValueSet/diabetes'
valueset "高血壓 valueset": 'https://example.org/fhir/ValueSet/hypertension'

define "糖尿病":
  exists ( C3F.Confirmed([Condition: "糖尿病 valueset"]) )

define "高血壓":
  exists ( C3F.Confirmed([Condition: "高血壓 valueset"]) )

define "適應症":
  "糖尿病" or "高血壓"
```

### Pattern 3: Multiple Indications (AND logic)

**Rules text:** "適應症：糖尿病合併腎病變"

```cql
valueset "糖尿病 valueset": 'https://example.org/fhir/ValueSet/diabetes'
valueset "腎病變 valueset": 'https://example.org/fhir/ValueSet/nephropathy'

define "糖尿病":
  exists ( C3F.Confirmed([Condition: "糖尿病 valueset"]) )

define "腎病變":
  exists ( C3F.Confirmed([Condition: "腎病變 valueset"]) )

define "適應症":
  "糖尿病" and "腎病變"
```

### Pattern 4: Suspected/Provisional Diagnosis

**Rules text:** "疑有 Von Willebrand disease 者"

```cql
valueset "VWD valueset": 'https://example.org/fhir/ValueSet/vwd'

define "疑似VWD":
  exists (
    [Condition: "VWD valueset"] C
      where C.verificationStatus ~ "provisional"
        or C.verificationStatus ~ "confirmed"
  )

define "適應症":
  "疑似VWD"
```

## Contraindication Patterns

### Pattern 1: Simple Contraindication

**Rules text:** "禁忌症：懷孕婦女"

```cql
valueset "懷孕 valueset": 'https://example.org/fhir/ValueSet/pregnancy'

define "懷孕":
  exists ( C3F.Confirmed([Condition: "懷孕 valueset"]) )

define "MeetsInclusionCriteria":
  "適應症" and not "懷孕"
```

### Pattern 2: Multiple Contraindications

**Rules text:** "禁忌症：懷孕、哺乳期婦女"

```cql
valueset "懷孕 valueset": 'https://example.org/fhir/ValueSet/pregnancy'
valueset "哺乳 valueset": 'https://example.org/fhir/ValueSet/lactation'

define "懷孕":
  exists ( C3F.Confirmed([Condition: "懷孕 valueset"]) )

define "哺乳中":
  exists ( C3F.Confirmed([Condition: "哺乳 valueset"]) )

define "無禁忌症":
  not "懷孕" and not "哺乳中"

define "MeetsInclusionCriteria":
  "適應症" and "無禁忌症"
```

## Lab Value Patterns

### Pattern 1: Threshold Check (< threshold)

**Rules text:** "血小板數量 < 50,000 /uL"

```cql
codesystem "LOINC": 'http://loinc.org'
code "血小板數量": '777-3' from "LOINC" display 'Platelets [#/volume] in Blood'

define "血小板過低":
  exists (
    [Observation: "血小板數量"] O
      where C3F.QuantityValue(O) < 50000 '/uL'
        and O.status in {'final', 'corrected', 'amended'}
  )

define "MeetsInclusionCriteria":
  "適應症" and "血小板過低"
```

### Pattern 2: Threshold Check (> threshold)

**Rules text:** "LDL > 100 mg/dL"

```cql
codesystem "LOINC": 'http://loinc.org'
code "LDL": '2089-1' from "LOINC" display 'LDL Cholesterol'

define "LDL過高":
  exists (
    [Observation: "LDL"] O
      where C3F.QuantityValue(O) > 100 'mg/dL'
        and O.status in {'final', 'corrected', 'amended'}
  )
```

### Pattern 3: Range Check

**Rules text:** "HbA1c 7.0-9.0 %"

```cql
codesystem "LOINC": 'http://loinc.org'
code "HbA1c": '4548-4' from "LOINC" display 'Hemoglobin A1c'

define "HbA1c範圍適當":
  exists (
    [Observation: "HbA1c"] O
      where C3F.QuantityValue(O) >= 7.0 '%'
        and C3F.QuantityValue(O) <= 9.0 '%'
        and O.status in {'final', 'corrected', 'amended'}
  )
```

## Mutual Exclusivity Patterns

### Pattern 1: Cannot Co-claim

**Rules text:** "不得同時申報 08112C"

```cql
valueset "衝突項目 valueset": 'https://example.org/fhir/ValueSet/conflicting-procedure'

define "無同時申報":
  not exists (
    [Procedure: "衝突項目 valueset"] P
      where P.performed during Interval[Today() - 30 days, Today()]
  )

define "MeetsInclusionCriteria":
  "適應症" and "無同時申報"
```

### Pattern 2: Choose One of Multiple

**Rules text:** "與 08112C, 08113D 擇一給付"

```cql
valueset "互斥項目 valueset": 'https://example.org/fhir/ValueSet/mutually-exclusive'

define "無申報互斥項目":
  not exists (
    [Procedure: "互斥項目 valueset"] P
      where P.performed during Interval[Today() - 90 days, Today()]
  )
```

## Complete Example: Complex Rule

**Rules text:**
```
規則編號：08111B
給付點數：800點
適應症：凝血異常，疑有 Von Willebrand disease
禁忌症：懷孕婦女
年齡限制：6歲以上未滿13歲
專科限制：兒科專科醫師執行
執行頻率：一年限申報三次
檢驗條件：血小板數量 < 50,000 /uL
```

**Complete CQL implementation:**
```cql
library "08111B" version '0.0.1'

using FHIR version '4.0.1'

include "FHIRHelpers" version '4.0.1' called FHIRHelpers
include "CDSConnectCommonsForFHIRv401" version '2.0.0' called C3F

context Patient

// CodeSystems
codesystem "ICD-10-CM": 'http://hl7.org/fhir/sid/icd-10-cm'
codesystem "LOINC": 'http://loinc.org'
codesystem "SCT": 'http://snomed.info/sct'

// ValueSets
valueset "凝血異常 valueset": 'https://example.org/fhir/ValueSet/coagulation-disorder'
valueset "懷孕 valueset": 'https://example.org/fhir/ValueSet/pregnancy'

// Codes
code "血小板數量": '777-3' from "LOINC" display 'Platelets'
code "兒科專科醫師": '24251000087109' from "SCT" display 'Pediatric specialty'

// Indications
define "凝血異常":
  exists ( C3F.Confirmed([Condition: "凝血異常 valueset"]) )

define "適應症":
  "凝血異常"

// Contraindications
define "懷孕":
  exists ( C3F.Confirmed([Condition: "懷孕 valueset"]) )

// Age restriction
define "年齡符合":
  AgeInYears() >= 6 and AgeInYears() < 13

// Specialty restriction
define "專科符合":
  exists (
    [Practitioner] P
      where exists (
        P.qualification Q where Q.code ~ "兒科專科醫師"
      )
  )

// Frequency limit
define "過去一年執行次數":
  Count(
    C3F.ObservationLookBack(
      [Observation: code in "血小板數量"],
      1 year
    )
  )

define "頻率符合":
  "過去一年執行次數" < 3

// Lab value
define "血小板過低":
  exists (
    [Observation: "血小板數量"] O
      where C3F.QuantityValue(O) < 50000 '/uL'
        and O.status in {'final', 'corrected', 'amended'}
  )

// Main inclusion criteria
define "MeetsInclusionCriteria":
  "適應症"
    and not "懷孕"
    and "年齡符合"
    and "專科符合"
    and "頻率符合"
    and "血小板過低"

define "InPopulation":
  "MeetsInclusionCriteria"

define "Recommendation":
  if "InPopulation"
    then '建議給付 800 點'
    else null

define "Rationale":
  null

define "Links":
  null

define "Suggestions":
  null

define "Errors":
  null
```

## Pattern Recognition Guidelines

When analyzing CQL against rules:

1. **Identify the pattern type** - Is it frequency, age, specialty, indication, etc.?
2. **Match to standard pattern** - Does implementation follow the common pattern?
3. **Verify parameters** - Are values (ages, counts, thresholds) correct?
4. **Check logic operators** - Are AND/OR/NOT used correctly?
5. **Validate completeness** - Are all rule elements implemented?

**Common deviations to flag:**
- Wrong time period in frequency checks
- Wrong comparison operator (< vs <=)
- Missing contraindication negation
- Incorrect specialty codes
- Wrong LOINC codes for labs
