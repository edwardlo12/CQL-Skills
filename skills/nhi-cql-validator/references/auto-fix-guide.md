# Auto-Fix Guide

## Trigger Detection

Auto-fix should **ONLY** execute when user explicitly requests it.

**Trigger keywords:**
- "自動修正"
- "修正"
- "fix"
- "auto-fix"
- "幫我修正"
- "請修正"
- "自動修復"

**Do NOT auto-fix when:**
- User only asks to "validate" or "check"
- User asks "what's wrong" without requesting fixes
- Validation finds issues but no fix request made

## Auto-Fixable Issues

### Category 1: Format Issues (Safe to auto-fix)

#### 1.1 Indentation

**Issue:** Tabs instead of 2 spaces

**Detection:**
```
Line contains \t character
```

**Fix:**
```
Replace all \t with '  ' (2 spaces)
```

**Safety:** High - Pure formatting

#### 1.2 String Quotes

**Issue:** Double quotes instead of single quotes

**Detection:**
```
String literals use "..." instead of '...'
```

**Fix:**
```
Replace "..." with '...'
Preserve escaped quotes
```

**Safety:** High - Does not change semantics

#### 1.3 JSON Formatting

**Issue:** Inconsistent JSON indentation

**Detection:**
```
JSON not properly indented
```

**Fix:**
```
Reformat JSON with 2-space indentation
Preserve structure and values
```

**Safety:** High - Pure formatting

### Category 2: CQL Syntax Issues (Auto-fix with caution)

#### 2.1 Redundant Function Definitions

**Issue:** Redefining C3F functions

**Detection:**
```cql
define "Confirmed":
  [Condition] C where ...
```

**Fix:**
```
Remove entire function definition
Update references to use C3F.Confirmed()
```

**Safety:** Medium - Verify no custom logic

**Caution:**
```markdown
⚠️ **審查建議**: 請確認原 Confirmed 函式無特殊邏輯
- 原定義: [show original]
- 改為使用: C3F.Confirmed()
```

#### 2.2 Missing Required Defines

**Issue:** Missing MeetsInclusionCriteria, Recommendation, etc.

**Detection:**
```
Required define not found
```

**Fix:**
```cql
// Add with null placeholder
define "MeetsInclusionCriteria": null
define "Recommendation": null
define "Rationale": null
define "Links": null
define "Suggestions": null
define "Errors": null
```

**Safety:** Medium - Requires user to implement logic

**Note in report:**
```markdown
✅ **補充缺少的 define statements**: 已新增佔位符
- ⚠️ **需要實作**: 請為以下 define 補充實際邏輯
  - MeetsInclusionCriteria
  - Recommendation
```

#### 2.3 URL Protocol Corrections

**Issue:** ValueSet JSON uses https:// instead of http://

**Detection:**
```json
"url": "https://..."  // Should be http://
```

**Fix:**
```json
"url": "http://..."
```

**Safety:** High - Follows FHIR spec

### Category 3: Business Logic Additions (Requires user confirmation)

#### 3.1 Missing Contraindications

**When to auto-fix:**
- User provides rules text mentioning contraindication
- CQL has no corresponding exclusion
- User explicitly requests fix

**Generation process:**

1. Detect missing contraindication from rules
2. Generate valueset declaration
3. Generate exclusion logic
4. **Clearly mark as generated code**

**Example fix:**
```markdown
### 業務邏輯修正

#### 08111B.cql
✅ **補充禁忌症**: 新增「懷孕」條件檢查

**新增內容**:
```cql
// ⚠️ Auto-generated - Please review
valueset "懷孕 valueset": 'https://example.org/fhir/ValueSet/pregnancy'

define "懷孕":
  exists ( C3F.Confirmed([Condition: "懷孕 valueset"]) )

// Updated MeetsInclusionCriteria
define "MeetsInclusionCriteria":
  "適應症" and not "懷孕"  // ⚠️ Added contraindication
```

**需要**:
- 建立 pregnancy ValueSet (見下方「新增的 ValueSet」)
- 審查邏輯正確性
```
```

**Safety:** Low - Requires manual review

**Always include:**
- `⚠️ Auto-generated - Please review` comment
- Clear marking of additions
- Request for user review

#### 3.2 Missing Lab Value Checks

**When to auto-fix:**
- Rules specify lab threshold
- CQL lacks corresponding check
- User requests fix

**Generation:**
```cql
// ⚠️ Auto-generated - Please review
codesystem "LOINC": 'http://loinc.org'
code "血小板數量": '777-3' from "LOINC" display 'Platelets'

define "血小板過低":
  exists (
    [Observation: "血小板數量"] O
      where C3F.QuantityValue(O) < 50000 '/uL'
        and O.status in {'final', 'corrected', 'amended'}
  )
```

**Mark clearly:**
```markdown
⚠️ **自動生成的檢驗條件**
- LOINC code 777-3 自動選擇，請驗證正確性
- 閾值 50,000 /uL 來自規則文字
- 請審查邏輯是否符合臨床意圖
```

#### 3.3 Missing Frequency Checks

**Generation:**
```cql
// ⚠️ Auto-generated - Please review
define "過去一年執行次數":
  Count(
    C3F.ObservationLookBack(
      [Observation: "相關檢驗 valueset"],
      1 year
    )
  )

define "頻率符合":
  "過去一年執行次數" < 3
```

### Category 4: ValueSet Enhancements

#### 4.1 Missing ICD Codes

**When to auto-fix:**
- Rules mention specific diagnoses
- ValueSet lacks corresponding ICD codes
- User requests fix

**Process:**
1. Extract disease names from rules
2. Map to ICD-10-CM codes
3. Add to ValueSet compose.include
4. **Mark as suggested addition**

**Example:**
```json
// ⚠️ Auto-generated additions - Please review
{
  "compose": {
    "include": [{
      "system": "http://hl7.org/fhir/sid/icd-10-cm",
      "concept": [
        {"code": "Z33.1", "display": "Pregnant state, incidental"},
        {"code": "O09.0", "display": "Supervision of pregnancy with history of infertility"}
      ]
    }]
  }
}
```

**Note:**
```markdown
⚠️ **補充的 ICD-10-CM 代碼** (基於規則「懷孕婦女」)
- Z33.1: Pregnant state, incidental
- O09.*: Supervision of high risk pregnancy

請確認這些代碼涵蓋完整但不過於廣泛
```

## Auto-Fix Safety Mechanisms

### Mechanism 1: Classification by Safety Level

**Safe (auto-apply):**
- Indentation fixes
- Quote style fixes
- JSON formatting

**Medium (apply with note):**
- Removing redundant functions (after verification)
- URL protocol corrections
- Adding null placeholders

**Unsafe (apply with strong warnings):**
- Business logic additions
- ValueSet code additions
- Complex logic changes

### Mechanism 2: Clear Marking

All auto-generated or modified code must include:

```cql
// ⚠️ Auto-generated - Please review
[code]
```

Or in JSON:
```json
// ⚠️ Auto-added - Please review
```

### Mechanism 3: Backup Reminder

**Always include in report:**
```markdown
## ⚠️ 重要提醒

在應用修正前，請先備份原始檔案。

建議步驟：
1. 備份所有原始檔案
2. 審查下方修正內容
3. 應用修正
4. 重新執行驗證確認
```

### Mechanism 4: Show All Changes

For each file, show:
- Original code
- Modified code
- Explanation of change

**Format:**
```markdown
### 檔案：08111B.cql

**修正 1: 縮排問題**

原始內容（第 15 行）:
```cql
	define "適應症":  // ❌ Tab
```

修正後:
```cql
  define "適應症":  // ✅ 2 spaces
```
```

### Mechanism 5: Uncertainty Flags

For uncertain fixes, flag for manual review:

```markdown
## 需要人工確認的修正 ⚠️

### 08111B.cql

1. ⚠️ **適應症範圍**
   - 自動修正: 使用 D68.* (所有凝血疾病)
   - 規則文字: 只提到 "Von Willebrand disease"
   - **需確認**: 範圍是否過廣？
   - **選項**:
     - A: 保持 D68.* (涵蓋所有凝血疾病)
     - B: 縮小為 D68.0 (只有 VWD)
   - 建議: 諮詢規則制定單位
```

## Auto-Fix Workflow

### Step 1: Detect Fixable Issues

During validation, categorize issues:
- ✅ Safe auto-fix
- ⚠️ Medium auto-fix (needs review)
- ❌ Unsafe - manual only

### Step 2: Generate Fixes

For each fixable issue:
1. Generate fix code
2. Mark safety level
3. Prepare explanation
4. Prepare before/after comparison

### Step 3: Group Fixes

Organize fixes by:
- File
- Fix type (format, syntax, logic)
- Safety level

### Step 4: Generate Report

Structure:
```markdown
# 自動修正報告 🔧

## 修正摘要
- 修正的檔案數量: X
- 修正的問題數量: Y
- 無法自動修正的問題: Z

## 已修正的問題 ✅

### 語法和格式修正
[Safe fixes]

### 業務邏輯修正（基於健保規則）
[Logic additions - marked for review]

## 需要人工處理的問題 ⚠️
[Manual fixes required]

## 修正後的檔案
[Complete modified files]

## 新增的 ValueSet（如需要）
[New ValueSet files]

## 建議後續動作
[Next steps]
```

### Step 5: Present Fixes

**Do NOT automatically apply** - show what would be fixed

User must then:
1. Review fixes
2. Confirm application
3. Or request specific fixes only

## What NOT to Auto-Fix

**Never auto-fix:**
- Logical errors requiring domain knowledge
- Ambiguous rule interpretations
- Specialty codes (always require verification)
- Complex nested conditions
- Contradictory logic (flag for manual resolution)

**Example - Do not fix:**
```markdown
❌ **不自動修正**: 邏輯矛盾

發現問題:
```cql
define "條件A": AgeInYears() >= 65
define "條件B": AgeInYears() < 60
define "符合": "條件A" and "條件B"  // ❌ 永遠為 false
```

這需要人工判斷:
- 是否應為 "條件A" or "條件B"?
- 或者年齡範圍有誤?

請手動檢視規則文字並修正。
```

## Complete Auto-Fix Example

See detailed example in main skill description showing:
- Fix summary
- Categorized fixes
- Before/after code
- Safety warnings
- Review requirements
- Next steps

## Auto-Fix Testing

Before presenting fixes:
1. Verify syntax correctness of generated code
2. Check all placeholders filled
3. Ensure consistent indentation
4. Validate JSON structure if applicable
5. Confirm no breaking changes to safe fixes
