# Validation Report Template

## Complete Report Structure

```markdown
# CQL/ValueSet 驗證報告

## 檔案摘要
- 檢查的 CQL 檔案數量: [X]
- 檢查的 ValueSet 檔案數量: [Y]
- 驗證模式: [✅ 語法 + 格式 + 業務邏輯 / ⚠️ 僅語法 + 格式]
- 總體狀態: [✅ 通過 / ⚠️ 有警告 / ❌ 有錯誤]

---

## 第一部分：語法和格式驗證

### 錯誤 (Errors) ❌
> 必須修正才能正常運作的問題

#### [檔案名稱.cql]
1. ❌ **[問題類型]**: [詳細描述] [[可自動修正] / [需人工處理]]
   - 位置: 第 X 行
   - 當前值: [current]
   - 應為: [expected]

### 警告 (Warnings) ⚠️
> 不影響功能但違反最佳實踐

#### [檔案名稱.cql]
1. ⚠️ **[問題類型]**: [詳細描述] [[可自動修正] / [建議人工檢視]]
   - 位置: 第 X 行
   - 建議: [suggestion]

### 交叉驗證結果 🔗

#### CQL ↔ ValueSet 對應

| CQL Valueset 宣告 | 對應的 JSON 檔案 | 狀態 |
|------------------|----------------|------|
| [valueset name] | [filename.json] | [✅ 匹配 / ❌ 缺少 / ⚠️ URL 不符] |

#### 相依檔案檢查
- [✅ / ❌] FHIRHelpers.cql 存在
- [✅ / ❌] CDSConnectCommonsForFHIRv401.cql 存在

---

## 第二部分：健保規則覆蓋度分析 📋

> **注意**: 此部分僅在提供健保給付規則文字時顯示

### 規則資訊
- **規則編號**: [code]
- **給付點數**: [points]
- **規則來源**: [使用者提供 / GitHub / 其他]

### 覆蓋度統計

```
總條件數: [N]
├─ ✅ 已實作: [X] ([X/N]%)
├─ ❌ 遺漏: [Y] ([Y/N]%)
└─ ⚠️ 多餘/不確定: [Z] ([Z/N]%)
```

### 條件比對詳情

#### ✅ 已正確實作 ([X]項)

1. ✅ **[條件類型] - [條件名稱]**
   - 規則要求: [requirement from rules]
   - CQL 實作: [implementation in CQL]
   - ValueSet: [if applicable]
   - 狀態: [正確 / 需確認代碼正確性]

#### ❌ 遺漏的條件 ([Y]項)

1. ❌ **[條件類型] - [條件名稱]** [[可自動修正] / [需人工實作]]
   - 規則要求: [requirement from rules]
   - CQL 實作: **未實作**
   - 影響: [高/中/低]（[原因]）
   - **建議修正**:
     ```cql
     [suggested code]
     ```
   - **需要的 ValueSet** (如適用): [details]

#### ⚠️ 需要確認的實作

1. ⚠️ **[問題描述]**
   - CQL 實作: [current implementation]
   - 規則文字: [rules text]
   - 問題: [what's uncertain]
   - **需確認**: 
     - [question 1]
     - [question 2]
   - 建議: [suggestion]

### 規則覆蓋度評分

| 類別 | 得分 | 說明 |
|------|------|------|
| 適應症完整性 | [X]% | [comment] |
| 禁忌症完整性 | [X]% | [comment] |
| 檢驗條件完整性 | [X]% | [comment] |
| 頻率限制 | [X]% | [comment] |
| 年齡限制 | [X]% | [comment] |
| 專科限制 | [X]% | [comment] |
| 給付資訊 | [X]% | [comment] |
| **總體覆蓋度** | **[X]%** | [高/中/低]，[summary] |

---

## 第三部分：醫學知識驗證 🏥

### ICD-10-CM 代碼正確性
[✅ / ❌ / ⚠️] [code] - [description] ([status])

### LOINC 代碼驗證
[✅ / ❌ / ⚠️] [code] - [description] ([status])

### SNOMED CT 代碼驗證
[✅ / ❌ / ⚠️] [code] - [description] ([status])

---

## 第四部分：改進建議

### 🔴 高優先級（必須處理）
1. **[建議項目]** - [原因]
2. ...

### 🟡 中優先級（建議處理）
1. **[建議項目]** - [原因]
2. ...

### 🟢 低優先級（可選）
1. **[建議項目]** - [原因]
2. ...

---

## 統計資訊

### 問題統計
- 語法錯誤: [N]
- 語法警告: [N]
- 業務邏輯缺失: [N]
- 需確認項目: [N]
- 總問題數: [N]

### 可自動修正統計
- 可自動修正: [N] ([X]%)
- 需人工處理: [N] ([Y]%)

### 驗證通過率
- 語法驗證: [X]% ([通過/有警告/失敗])
- 業務邏輯驗證: [X]% ([高/中/低])
- **整體通過率: [X]%**

---

## 後續建議動作

### 立即執行
1. 💬 [如需自動修正，請回覆：「請自動修正...」]
2. 📝 [確認事項]
3. ...

### 修正後
1. 🔄 [後續步驟]
2. ...
```

## Section Guidelines

### Section 1: 語法和格式驗證

**Always include:**
- Errors and warnings organized by file
- Line numbers for all issues
- Auto-fix availability marker
- Cross-validation results
- Dependency checks

**Error format:**
```markdown
#### filename.cql
1. ❌ **缺少必要的 define statement**: 未找到 `MeetsInclusionCriteria` [可自動修正]
   - 位置: 檔案開頭
   - 建議: 新增以下定義
   ```cql
   define "MeetsInclusionCriteria": null
   ```
```

**Warning format:**
```markdown
1. ⚠️ **縮排不一致**: 第 15 行使用 tabs 而非 2 spaces [可自動修正]
   - 影響: 程式碼可讀性
   - 自動修正: 將 tabs 轉換為 2 spaces
```

### Section 2: 健保規則覆蓋度分析

**Only show when rules provided**

**Include:**
- Rule metadata
- Coverage statistics with visual tree
- Detailed condition matching
- Coverage scoring by category
- Overall coverage percentage

**Coverage tree format:**
```
總條件數: 8
├─ ✅ 已實作: 6 (75%)
├─ ❌ 遺漏: 2 (25%)
└─ ⚠️ 多餘/不確定: 0
```

**Correctly implemented condition format:**
```markdown
1. ✅ **適應症 - 凝血異常**
   - 規則要求: 凝血異常
   - CQL 實作: `exists ( C3F.Confirmed([Condition: "凝血異常 valueset"]) )`
   - ValueSet: 包含 ICD-10-CM D68.* 系列代碼
   - 狀態: 正確
```

**Missing condition format:**
```markdown
1. ❌ **禁忌症 - 懷孕婦女** [可自動修正]
   - 規則要求: 懷孕婦女禁用
   - CQL 實作: **未實作**
   - 影響: 高（安全性問題）
   - **建議修正**:
     ```cql
     valueset "懷孕 valueset": 'https://example.org/fhir/ValueSet/...'
     
     define "懷孕":
       exists ( C3F.Confirmed([Condition: "懷孕 valueset"]) )
     
     define "MeetsInclusionCriteria":
       "適應症" and not "懷孕"
     ```
   - **需要的 ValueSet**: 包含 Z33.1, O09.* 等代碼
```

**Uncertain implementation format:**
```markdown
1. ⚠️ **適應症範圍疑慮**
   - CQL 實作: ValueSet 使用 `descendent-of` D68 (所有凝血疾病)
   - 規則文字: 只提到「凝血異常」和「Von Willebrand disease」
   - 問題: ValueSet 包含所有 D68.* 代碼，可能超過規則意圖
   - **需確認**: 
     - 是否應該只包含 D68.0 (Von Willebrand disease)？
     - 或者規則文字簡化了，實際應涵蓋所有凝血疾病？
   - 建議: 與規則制定單位確認
```

### Section 3: 醫學知識驗證

**Include:**
- ICD-10-CM code checks
- LOINC code validation
- SNOMED CT code verification
- Flag uncertain codes for manual review

**Format:**
```markdown
### ICD-10-CM 代碼正確性
✅ D68.* - 凝血疾病（正確）
✅ D68.0 - Von Willebrand disease（正確）
⚠️ 需確認是否應包含所有 D68.* 子代碼

### LOINC 代碼驗證
❌ **缺少**: 777-3 (Platelets [#/volume] in Blood) - 血小板數量檢驗

### SNOMED CT 代碼驗證
⚠️ 24251000087109 - 需確認是否為台灣認可的兒科專科代碼
```

### Section 4: 改進建議

**Prioritize by:**
- 🔴 High: Safety issues, missing critical conditions
- 🟡 Medium: Correctness uncertainties, best practices
- 🟢 Low: Formatting, optional improvements

**Format:**
```markdown
### 🔴 高優先級（必須處理）
1. **補充禁忌症檢查**（懷孕婦女）- 安全性問題
2. **補充檢驗值條件**（血小板數量）- 給付條件缺失

### 🟡 中優先級（建議處理）
1. **確認適應症範圍** - 避免過度或不足給付
2. **驗證專科代碼**正確性

### 🟢 低優先級（可選）
1. 修正縮排問題
2. 移除冗餘函式
```

## Example Reports

### Example 1: Syntax-Only Validation

```markdown
# CQL/ValueSet 驗證報告

## 檔案摘要
- 檢查的 CQL 檔案數量: 1
- 檢查的 ValueSet 檔案數量: 2
- 驗證模式: ⚠️ 僅語法 + 格式
- 總體狀態: ⚠️ 有警告

---

## 第一部分：語法和格式驗證

### 錯誤 (Errors) ❌
無錯誤 ✅

### 警告 (Warnings) ⚠️

#### 08111B.cql
1. ⚠️ **縮排不一致**: 第 15, 23, 45 行使用 tabs 而非 2 spaces [可自動修正]
2. ⚠️ **冗餘的函式定義**: 第 50-60 行重複定義了 `Confirmed` 函式 [可自動修正]
   - 建議: 移除重複定義，直接使用 `C3F.Confirmed()`

### 交叉驗證結果 🔗

#### CQL ↔ ValueSet 對應

| CQL Valueset 宣告 | 對應的 JSON 檔案 | 狀態 |
|------------------|----------------|------|
| 凝血異常 valueset | coagulation-disorder.json | ✅ 匹配 |
| 懷孕 valueset | pregnancy.json | ✅ 匹配 |

#### 相依檔案檢查
- ✅ FHIRHelpers.cql 存在
- ✅ CDSConnectCommonsForFHIRv401.cql 存在

---

## 統計資訊

### 問題統計
- 語法錯誤: 0
- 語法警告: 2
- 總問題數: 2

### 可自動修正統計
- 可自動修正: 2 (100%)
- 需人工處理: 0

### 驗證通過率
- 語法驗證: 90% (有警告但無錯誤)
- **整體通過率: 90%**

---

## 後續建議動作

### 立即執行
1. 💬 如需自動修正，請回覆：「請自動修正這些格式問題」

**注意**: 未提供健保規則文字，僅執行基本語法驗證。如提供原始健保給付規則，可進行更深入的業務邏輯驗證。
```

### Example 2: Full Validation with Business Logic

See the complete example in the main user request description (too long to repeat here).

Key differences:
- Includes Section 2 (Rule Coverage Analysis)
- Includes Section 3 (Medical Code Validation)
- Shows missing conditions with suggested fixes
- Provides coverage scoring
- Prioritizes recommendations

## Report Customization

**Adjust tone based on results:**
- All passing ✅: Congratulatory tone
- Minor warnings ⚠️: Constructive tone
- Critical errors ❌: Urgent but helpful tone

**Adjust detail based on complexity:**
- Simple files: Brief report
- Complex rules: Comprehensive analysis
- Batch validation: Summary + per-file details

**Always include:**
- Clear status indicators (✅ ❌ ⚠️)
- Actionable recommendations
- Auto-fix availability
- Next steps guidance
