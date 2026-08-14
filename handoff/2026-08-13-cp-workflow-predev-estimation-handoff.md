# CP workflow pre-dev brief and estimation handoff - 2026-08-13

## 本次處理目標

本次 session 主要調整 `cp-backend-workflow` 的開發前流程，讓 CP 後端任務在正式 coding 前能更清楚地完成：

1. 流程圖呈現。
2. 任務估時。
3. 開發前主管提報文件。
4. Claude / Codex skill 基本驗證。

## 已完成 commit

本輪已完成兩個 commit：

```text
ddce509 docs(cp-backend-workflow): 補充流程圖與任務估時
dc8bf45 feat(cp-backend-workflow): 調整開發前提報流程
```

目前工作區在開始撰寫本 handoff 前是乾淨的；本 handoff 檔案尚未 commit。

## 已完成改動

### 1. 補上 CP 後端總控流程圖

已在以下文件加入 Mermaid 流程圖：

- `skills/cp-backend-workflow/SKILL.md`
- `cp-backend-work-flow.md`

流程圖涵蓋：

- 建任務資料夾與模板。
- Repo inventory。
- 需求釐清與 simple / complex 分級。
- 任務估時。
- 會議前置文件。
- 後端開發文件。
- TDD 實作。
- review / 自測。
- commit / push。
- MR 描述與提交。
- QA 測試矩陣。
- 需求變更回流。
- merge conflict 處理。

### 2. 新增任務估時階段

在 `cp-backend-workflow` 中新增「任務估時」階段，產物固定為：

```text
project-doc/task-estimation.html
```

目前估時表暫定給 CP 後端流程使用，未來再抽象成更通用的估時模型，並依不同系統、環境與交付流程定義不同估時項目。

目前固定 HTML 表格欄位：

- 估時項目
- 工作內容
- 預估工時
- 備註

目前固定估時項目：

- 需求整理
- Coding
- 自測與修改
- 文件整理
- 前端對接文件
- Code Review / MR 準備
- 部署收尾
- 合計

`Code Review / MR 準備` 是本輪討論後補上的項目，原因是 CP 後端流程中 self-review、處理 review 問題與 MR 前置整理是 commit / MR 前的必要成本，不適合混在 coding 或文件整理裡。

### 3. 重新定位開發前主管提報文件

原本曾討論 `requirement-risk-test-brief.html` 與 `business-brief.html` 的區分。後來根據使用者提供的實際 Confluence 內容判斷，公司後端開發前更需要一份給主管看的主文件，而不是過度拆成「風險測試說明」與「業務說明」兩份同級文件。

最終流程定義改為：

simple 任務至少維護：

```text
project-doc/task-estimation.html
project-doc/pre-dev-brief.html
```

complex 任務額外維護：

```text
project-doc/business-brief.html
```

涉及 DB、Redis、MQ、排程、回調、正式資料修復、預發正式差異或需要明確上線 / 回滾計畫時，額外維護：

```text
project-doc/release-assessment.html
```

`requirement-risk-test-brief.html` 已從流程定義中移除，改由 `pre-dev-brief.html` 承擔開發前主管提報主文件。

### 4. `pre-dev-brief.html` 內容定義

`pre-dev-brief.html` 是 simple / complex 都要有的開發前主管提報主文件，內容固定包含：

- 需求背景：為什麼要做，現況痛點是什麼。
- 目標方案：這次要怎麼解，預期流程會變成什麼。
- 影響範圍：影響哪些服務、API、DB、Redis、MQ、排程、回調、前端頁面或外部系統；不確定項標 `待確認`。
- 業務流程：用條列或流程圖說明主要流程、狀態流轉與前後端互動。
- 風險與注意事項：整理金流、訂單狀態、權限、幣種、回調、排程、資料一致性、相容性與前後端顯示落差等風險。
- 測試與驗收重點：列出後端自測、前後端聯調、QA 必測路徑、異常路徑與回歸範圍。
- 開發估時：引用 `task-estimation.html` 的估時摘要。
- 待主管 / PM / QA 確認事項：列出需要會上確認的決策。
- 不做範圍：明確列出本次不處理的功能、資料修復、相容場景或前端改動。

### 5. `business-brief.html` 定位

`business-brief.html` 只在 complex 任務產生，作為 `pre-dev-brief.html` 的詳細業務流程附件。

內容聚焦：

- 現況流程與痛點。
- 目標流程與角色分工。
- 主要狀態流轉、資料流與前後端互動。
- 邊界案例與例外處理。
- 會議決策紀錄。

使用者提供的 Confluence 範例「高風險入幣補入帳」比較像 complex 任務的 `pre-dev-brief.html` + `business-brief.html` 混合版。若要提報主管，應優先整理成 `pre-dev-brief.html`，細節流程可拆到 `business-brief.html`，API request / response、SQL、enum、index 等過細內容應放到後端開發文件。

### 6. `release-assessment.html` 定位

`release-assessment.html` 不再是 complex 任務必產文件，而是有上線風險時才產。

內容聚焦：

- 預發 / 正式環境差異。
- DB / Redis / MQ / 排程 / 回調 / 初始化資料影響。
- 上線步驟、驗證方式與回滾方式。
- 是否需要停機、灰度、補資料或通知 QA / PM / 運維。
- 上線後觀察指標與已知殘留風險。

### 7. 新增 skill 驗證腳本

新增：

```text
scripts/validate-skills.sh
```

用途：

- 檢查每個 skill 目錄是否有 `SKILL.md`。
- 檢查 frontmatter 是否有 `name` / `description`。
- 檢查資料夾名稱是否與 frontmatter `name` 一致。
- 執行 `scripts/install-claude.sh --dry-run`，確認 Claude 安裝流程相容。
- 執行 Codex `quick_validate.py`；預設只顯示 warning。
- 若需要把 Codex 格式檢查也視為失敗條件，可使用 `--strict-codex`。

使用方式：

```bash
scripts/validate-skills.sh
scripts/validate-skills.sh --strict-codex
```

已同步更新 `README.md` 的「安裝與同步」段落。

## 驗證結果

已執行：

```bash
scripts/validate-skills.sh
```

結果通過 Claude 基本相容性檢查與 install dry-run。

目前已知 warning：

```text
cp-merge-conflict failed Codex quick_validate.py: Description cannot contain angle brackets (< or >)
```

這是既有 skill 對 Codex 嚴格格式的 warning，不影響本輪新增的 Claude 基本相容性檢查。若後續要讓 `scripts/validate-skills.sh --strict-codex` 也通過，需要修正 `skills/cp-merge-conflict/SKILL.md` description 中的 `<` / `>`。

## 當前 git 狀態

截至本 handoff 撰寫前：

- 已 commit：`ddce509`、`dc8bf45`
- 工作區原本乾淨。
- 新增本 handoff 後，尚需再 commit handoff 檔案。

建議下一個 commit message：

```text
docs(handoff): 補充開發前提報流程交接紀錄
```

## 後續建議

1. 若要讓 Codex strict 驗證也通過，修正 `cp-merge-conflict` 的 description angle brackets。
2. 下一步可針對 `pre-dev-brief.html` 補一份 HTML 模板，避免每次從零生成主管提報文件。
3. 若要進一步抽象通用流程，可把「估時模型」、「開發前提報」、「業務流程附件」、「上線評估」拆成通用 core + CP adapter。
4. 若要立即讓 runtime 使用最新 skill，執行：

```bash
scripts/install-codex.sh
scripts/install-claude.sh
```
