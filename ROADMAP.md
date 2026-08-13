# CP Workflow Skill Roadmap

## 目標

將目前 CP 後端工作流 skill 從專案特化流程，逐步整理成可抽象、可複用、可分層的軟體開發流程系統。

短期仍以 CP 後端任務可穩定落地為優先；中長期再抽出通用 workflow core，並派生前端、App、嵌入式等不同 domain workflow。

## 當前定位

目前本 repo 是：

```text
cp-backend-workflow-skill
```

它包含：

- CP 後端任務總控流程。
- 禪道任務模板。
- 後端開發文件。
- TDD 實作紀錄。
- Code review。
- 自測報告。
- MR 描述與提交。
- 合併衝突處理。
- Karpathy 品質閘門。

目前仍有 CP 專屬內容，例如禪道、Java service、GitLab MR 規則、CP 架構規範與自測報告格式。

## 核心設計方向

### 1. 先穩定 CP workflow

短期目標是讓 CP 後端任務可以穩定使用：

- 每個任務先確認 `task_root` / `task_dir`，不寫死路徑。
- 所有子 skill 以 `task_dir` 作為文件讀寫契約。
- `affected-repos.md` 作為 repo 範圍單一來源。
- `workflow-state.md` 支援中斷後續跑。
- `requirement-changes.md` 支援需求變更版本。
- `cp-task-dev` 維護 TDD 與 dev-progress。
- review、self-test、MR 描述、QA 測試矩陣都能讀取前面階段產物。

### 2. 抽出 workflow core concepts

下一階段整理一份 `workflow-core-concepts.md`，定義哪些概念屬於通用 workflow core：

- `task_root`
- `task_dir`
- workflow state
- requirement changes
- impact inventory
- requirement analysis
- verification plan
- dev progress
- review result
- test report
- release handoff
- external action confirmation

通用 core 不應知道 CP、禪道、Java、GitLab 或任何特定技術棧。

### 3. 將 CP 內容下沉成 adapter

CP backend adapter 負責：

- 禪道主任務 / 子任務 HTML 模板。
- CP Java service codebase 探索方式。
- CP repo 類型與 `affected-repos.md` 欄位。
- CP 架構規範。
- 後端自測報告格式。
- GitLab MR 描述與提交規則。

## 演進階段

### Phase 1：CP workflow 穩定化

目標：

- 用真實 CP 任務跑完整流程。
- 修正 `task_root` / `task_dir` 提問與傳遞是否順。
- 確認主 skill / 輔助 skill 對照是否足以指導總控。
- 確認 Karpathy 品質閘門不會過度打斷簡單任務。

交付：

- 可穩定使用的 `cp-backend-workflow`。
- 最新 `cp-backend-work-flow.md`。
- 一份實戰後的 session handoff。

### Phase 2：抽象 workflow core

目標：

- 新增 `workflow-core-concepts.md`。
- 將通用狀態機、任務資料夾、需求變更、impact inventory、驗證計畫抽成中立語言。
- 標註哪些 CP skill 段落可上移到 core，哪些必須留在 CP adapter。

可能產物：

```text
docs/workflow-core-concepts.md
docs/adapter-boundary.md
docs/workflow-state-model.md
```

### Phase 3：拆分專案層次

目標：

將目前單一 CP repo 的經驗拆成：

```text
software-workflow-core/
backend-workflow-cp/
frontend-workflow/
app-workflow/
embedded-workflow/
```

建議分工：

- `software-workflow-core`：狀態、目錄、需求變更、impact inventory、驗證、交接。
- `backend-workflow-cp`：CP 後端專案 adapter。
- `frontend-workflow`：前端 UI / API / E2E / release 流程。
- `app-workflow`：iOS / Android / App Store / 版本回歸流程。
- `embedded-workflow`：firmware / hardware interface / flashing / integration test 流程。

### Phase 4：跨 domain workflow 驗證

目標：

- 用同一套 core concepts 套到不同 domain。
- 驗證哪些概念是真的通用，哪些只是 backend 假象。
- 讓每個 domain adapter 只處理自己的模板、工具、驗證方式與發布規則。

驗證 domain：

- CP backend。
- Frontend web app。
- Mobile app。
- Embedded / firmware。

## 近期待辦

- [ ] 用一個真實 CP 任務完整跑一次目前 workflow。
- [ ] 新增 `workflow-core-concepts.md`。
- [ ] 新增 adapter 邊界文件，區分 core / CP backend adapter。
- [ ] 檢查所有 skill 是否仍有寫死路徑或專案假設。
- [ ] 為 `task_root` / `task_dir` 設計一致的提問與 fallback 規則。
- [ ] 評估是否需要把 `affected-repos.md` 泛化成 `impact-inventory.md`。
- [ ] 評估是否需要把 `cp-task-dev` 泛化成 `tdd-dev` core skill。
- [ ] 實戰後調整 Karpathy 品質閘門的觸發強度。

## 不做事項

- 不急著拆 repo；先讓 CP workflow 跑順。
- 不把 CP 專屬模板塞進 core。
- 不把所有 domain 都抽象成同一份大而全 skill。
- 不為了通用化犧牲目前 CP 後端任務的可用性。

## 判斷標準

這條 roadmap 成功的標準：

- CP 後端任務仍能順暢完成。
- 新任務不再依賴寫死路徑。
- 子 skill 可以透過清楚契約協作。
- 通用 core 文件能清楚說明「什麼可復用、什麼不能復用」。
- 新 domain workflow 可以引用 core concepts，而不是複製整套 CP 流程。
