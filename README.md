# CQL Skills ⚕️📚

## About

**本存放庫收錄 CQL Skills（技能）。目前包含：**

- `nhi-cql-generator`：將健保給付規則轉換成可執行的 CQL 與 ValueSet（支援 FHIR R4 / 4.0.1）。
- `nhi-cql-validator`：驗證既有的台灣健保 CQL 與 ValueSet 是否符合健保規範與 FHIR 標準（包含語法檢查、業務邏輯覆蓋度分析，以及可選的自動修正功能）。


## Skills (目錄結構)

- `skills/`：技能資料夾，每個技能皆為獨立資料夾，內含 `SKILL.md`（說明與指令）、資源與範例。


## 快速開始 🔧

建議使用 Agent Skills CLI（透過 npx）直接安裝本 skill：

- 從 GitHub 安裝（範例）：

```bash
npx skills add github:<owner>/<repo>#main --skill skills/nhi-cql-generator
npx skills add github:<owner>/<repo>#main --skill skills/nhi-cql-validator
```

- 或從本機路徑安裝：

```bash
npx skills add ./skills/nhi-cql-generator
npx skills add ./skills/nhi-cql-validator
```

安裝後，可用 `npx skills list` 確認已安裝的 Skills，並依照你的 agent 平台（例如 Claude）載入與測試。


## 貢獻 ✨

歡迎提出 Issue 與 Pull Request。建議的貢獻流程如下：

1. Fork 本 repository。
2. 建立 feature branch：`git checkout -b feature/your-feature`。
3. 提交清楚的 commits，並發起 Pull Request，說明變更與測試方式。
4. 若新增或修改第三方資產，請同時更新 `THIRD_PARTY_NOTICES.md` 並附上來源與授權說明。

## Disclaimer ⚠️

本專案與其中的技能與範例僅供參考與教育用途。請在本地或生產環境使用前充分測試與驗證授權相容性與技術正確性。