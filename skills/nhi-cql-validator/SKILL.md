---
name: nhi-cql-validator
description: "Validate Taiwan NHI CQL Library (.cql) and FHIR ValueSet (.json) files for compliance with NHI regulations and FHIR standards. Includes syntax checking, format validation, and business logic validation (comparing against original NHI payment rules). Optional auto-fix functionality. Use when user asks to: (1) Validate/check CQL files, (2) Verify ValueSet compliance, (3) Check NHI CQL compliance, (4) Review payment rules implementation, (5) Fix/auto-correct CQL issues, (6) Compare against NHI regulations, or (7) Check logic correctness"
---

# NHI CQL Validator

Validate existing Taiwan NHI CQL Library and FHIR ValueSet files for compliance with NHI regulations and FHIR standards.

## Validation Modes

### Mode 1: Syntax & Format Validation Only
When NHI payment rules text is NOT provided, perform basic validation:
- CQL syntax and structure
- Required NHI define statements
- CodeSystem URL approval
- ValueSet JSON structure
- Cross-validation between CQL and ValueSet

### Mode 2: Full Validation with Business Logic ⭐ Recommended
When NHI payment rules text IS provided, perform comprehensive validation:
- All Mode 1 checks
- **Business logic coverage analysis** - Compare CQL implementation against original rules
- **Rule condition matching** - Verify all conditions are implemented
- **Medical knowledge validation** - Check code correctness (ICD-10-CM, LOINC, SNOMED CT)

## Quick Start

**Syntax validation only:**
```
請驗證這個 CQL 檔案：
[file content or path]
```

**Full validation (recommended):**
```
請驗證這個 CQL 是否符合健保規則：

**CQL 檔案**：[content]

**健保給付規則**：
規則編號：08111B
給付點數：800點
適應症：凝血異常，Von Willebrand disease
禁忌症：懷孕婦女
執行頻率：一年限三次
年齡限制：6-13歲
專科限制：兒科專科醫師
檢驗條件：血小板 < 50,000 /uL
```

**Auto-fix (when explicitly requested):**
```
請驗證並自動修正這個 CQL：
[CQL content]

**健保規則**：[rules text]
```

## Validation Workflow

### Step 1: Syntax & Format Checks

**CQL syntax validation:**
- Library declaration format: `library "[規則編號]" version '0.0.1'`
- Required headers exist (FHIR 4.0.1, FHIRHelpers, C3F)
- Context declaration: `context Patient`
- Indentation: 2 spaces (not tabs)
- String quotes: single quotes `'...'`

**NHI compliance checks:**
- Required define statements exist (see references/nhi-requirements.md)
- CodeSystem URLs in approved list (8 allowed systems)
- Correct C3F function usage

**ValueSet JSON validation:**
- Required FHIR fields present (resourceType, id, url, compose, etc.)
- ID format warning (OID preferred but not required)
- Filter operator appropriateness
- Purpose field format

### Step 2: Business Logic Validation (if rules provided)

**Extract and compare from NHI rules:**

1. **Basic info matching:**
   - Rule number matches library name
   - Payment points appear in Recommendation
   - Effective date (if any)

2. **Indication verification:**
   - All mentioned diagnoses/conditions have corresponding ValueSets
   - ICD-10-CM codes completely covered
   - Logic (OR/AND) correctly implemented
   - Check for missing or extra indications

3. **Contraindication verification:**
   - All contraindications implemented as exclusion conditions
   - Use `not exists` or exclude from MeetsInclusionCriteria

4. **Frequency limit verification:**
   - "一年限 X 次" → `Count(ObservationLookBack(..., 1 year)) < X`
   - Multi-year restrictions
   - Treatment interval requirements

5. **Age restriction verification:**
   - Age limits implemented with `AgeInYears()`
   - Age ranges correct

6. **Specialty restriction verification:**
   - Practitioner.qualification checks
   - Encounter.serviceType checks
   - SNOMED CT specialty codes correct

7. **Lab value verification:**
   - Lab conditions correctly implemented
   - LOINC codes correct
   - Units correct

8. **Other requirements:**
   - Administrative requirements in Recommendation
   - Payment specifications noted
   - Mutual exclusivity implemented

For detailed rule elements and patterns, see:
- **references/rule-extraction.md** - Rule element extraction guide
- **references/common-patterns.md** - Common NHI rule implementation patterns
- **references/medical-codes.md** - Medical code validation reference

### Step 3: Generate Coverage Report

Produce a **Rule Coverage Analysis** showing:
- Coverage statistics (% implemented vs missing)
- ✅ Correctly implemented conditions
- ❌ Missing conditions with suggested fixes
- ⚠️ Uncertain implementations requiring confirmation
- Priority-ranked improvement suggestions

See references/report-template.md for complete report structure.

### Step 4: Auto-Fix (only when explicitly requested)

**Trigger keywords:** 自動修正, 修正, fix, 幫我修正

**Auto-fixable issues:**

*CQL fixes:*
- Indentation (tabs → 2 spaces)
- String quotes (double → single)
- Redundant C3F function definitions
- Missing required define statements (add with null default)
- Missing logic based on rules (with user confirmation)

*ValueSet JSON fixes:*
- URL protocol corrections
- Missing required fields
- JSON formatting
- Missing ICD-10-CM codes based on rules

**Safety mechanisms:**
1. Only fix format and clear syntax issues directly
2. Clearly mark business logic additions
3. Note "Please backup original files" in report
4. Show all changes clearly
5. Mark uncertain fixes as "需人工確認"

For complete auto-fix specification, see references/auto-fix-guide.md.

## Output Report Structure

Generate validation reports following this structure:

```markdown
# CQL/ValueSet 驗證報告

## 檔案摘要
[File counts, validation mode, overall status]

## 第一部分：語法和格式驗證
[Errors, warnings, cross-validation results]

## 第二部分：健保規則覆蓋度分析 📋
[Only if rules provided: coverage stats, condition matching, missing items]

## 第三部分：醫學知識驗證 🏥
[Code correctness: ICD-10-CM, LOINC, SNOMED CT]

## 第四部分：改進建議
[Priority-ranked recommendations: 🔴 high, 🟡 medium, 🟢 low]

## 統計資訊
[Issue counts, auto-fix availability, pass rates]

## 後續建議動作
[Immediate actions and post-fix steps]
```

See references/report-template.md for complete template with examples.

## Cross-Validation Logic

**CQL ↔ ValueSet URL matching:**
- CQL uses `https://` in valueset declarations
- ValueSet JSON uses `http://` in url field
- This difference is **correct** - do not flag as error

**Dependency checks:**
- FHIRHelpers.cql present in same directory
- CDSConnectCommonsForFHIRv401.cql present in same directory

**Version consistency:**
- All referenced version numbers consistent

## Common Issue Detection

Automatically detect:
- Redundant helper function definitions (should use C3F directly)
- Unused valueset declarations
- Unused CodeSystem declarations
- Missing payment points in Recommendation
- Always-true or always-false conditions
- Contradictory conditions
- Unreasonable time ranges

## Relationship with nhi-cql-generator

This skill is the companion validation tool to `nhi-cql-generator`:
- **Generator**: Creates new CQL and ValueSet from scratch
- **Validator**: Checks existing CQL and ValueSet (from any source)
- Both operate independently

**Suggested workflow:**
```
Scenario 1: Using generator
規則文字 → Generator → CQL/ValueSet → Validator (with rules) → ✅ Pass

Scenario 2: Manually created or other source
Existing CQL + 規則文字 → Validator → Issues found → Auto-fix → Re-validate → ✅ Pass

Scenario 3: CQL without rules
Existing CQL → Validator (syntax only) → Basic validation ✅
Note: "For deeper validation, provide original NHI payment rules"
```

## Batch Validation

Support multiple files:
```
請驗證這個目錄下的所有 CQL 和 ValueSet：
[directory path or multiple files]

**健保規則** (如有): [rules text]
```

## Reference Files

For detailed information, read as needed:

- **references/nhi-requirements.md** - NHI compliance requirements (required defines, approved CodeSystems)
- **references/rule-extraction.md** - How to extract and match rule elements
- **references/common-patterns.md** - Common NHI rule implementation patterns
- **references/medical-codes.md** - Medical code validation (ICD-10-CM, LOINC, SNOMED CT)
- **references/report-template.md** - Complete validation report template with examples
- **references/auto-fix-guide.md** - Auto-fix specifications and safety mechanisms

## Example Assets

Reference examples in assets/:
- **assets/example-valid.cql** - Fully compliant CQL example
- **assets/example-valueset.json** - Properly formatted ValueSet example
- **assets/example-rules.txt** - Sample NHI payment rules text

## Important Notes

**Business logic validation limitations:**

Can check:
- ✅ Explicit conditions implemented (age, frequency, specialty)
- ✅ Mentioned diseases/labs have corresponding ValueSets/codes
- ✅ Logic structure reasonableness

Cannot check (requires human judgment):
- ❌ Complete medical semantic correctness of ValueSets
- ❌ Complex clinical judgment logic
- ❌ Implicit business rules (not stated in text)

**When in doubt, mark as ⚠️ "需確認" rather than assuming correctness.**

## Output Formatting Guidelines

- Use clear section headers with emoji markers (📋 🏥 etc.)
- Color-code priorities: 🔴 high, 🟡 medium, 🟢 low
- Use checkmarks: ✅ correct, ❌ missing, ⚠️ uncertain
- Include code snippets for suggested fixes
- Show specific line numbers for issues
- Provide actionable recommendations
