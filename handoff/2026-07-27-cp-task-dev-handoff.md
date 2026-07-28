# CP task-dev session handoff - 2026-07-27

## 本次處理目標

為 CP 後端工作流補上 `cp-task-dev`，讓後端實作階段可以使用 TDD，並留下需求分析、測試計畫與跨 Agent／Session 可接手的開發紀錄。

## 已完成改動

### 1. 新增 cp-task-dev skill

新增：

- `skills/cp-task-dev/SKILL.md`
- `skills/cp-task-dev/references/requirement-analysis-template.md`
- `skills/cp-task-dev/references/tdd-test-plan-template.md`
- `skills/cp-task-dev/references/dev-progress-template.md`

Skill 職責：

- 開發前釐清需求、驗收條件、例外行為與不在範圍內的項目。
- 建立 TDD 測試計畫，涵蓋 Red / Green / Refactor。
- 記錄每次實作、測試結果、變更檔案、阻塞與下一步。
- 支援 Agent 協助 coding，也支援使用者人工 coding。
- 不取代 `cp-backend-workflow`。
- 不自行執行 commit、push 或建立 MR。

### 2. 更新總控流程

更新 `skills/cp-backend-workflow/SKILL.md`：

- 新增 `cp-task-dev` 的 TDD 實作階段。
- 將原本的人工 coding 階段改為：
  - 使用 `cp-task-dev` 協助 TDD 實作；或
  - 使用者人工 coding，但仍需維護同一組測試與進度文件。
- 有未提交程式變更時，先確認 `dev-progress.md` 與測試紀錄已更新。
- 啟動時收集實作方式：`cp-task-dev` 協助或人工 coding。

### 3. 更新 README 與 task-template

更新：

- `README.md`
- `skills/cp-task-template/SKILL.md`

README 現在將流程描述為：

```text
cp-task-template
  -> cp-backend-dev-doc
  -> cp-task-dev（TDD 實作與紀錄）
  -> review / commit / self-test / MR
```

### 4. 同步任務資料夾模板

兩份模板都新增以下文件：

- `project-doc/requirement-analysis.md`
- `test-file-script/tdd-test-plan.md`
- `handoff/dev-progress.md`

同步位置：

- `cp-task-folder-template/`
- `skills/cp-task-template/references/task-folder-template/`

兩份 README 也都補上 `cp-task-dev` 文件用途說明。

## 固定文件契約

`cp-task-dev` 使用的任務文件路徑：

```text
task-doc/{衝刺版號}/task-{編號}/
├── project-doc/requirement-analysis.md
├── test-file-script/tdd-test-plan.md
└── handoff/dev-progress.md
```

若文件已存在，後續 session 必須先讀取並追加，不得覆蓋既有紀錄。

## 驗證結果

已完成：

- `cp-task-dev` 通過 `skill-creator` 的 `quick_validate.py`。
- 兩份 task folder template 的三個新增文件已使用 `cmp` 確認內容一致。
- README、總控與 template skill 已確認包含 `cp-task-dev`、TDD 與開發紀錄描述。
- 已確認沒有殘留「只能人工 coding」的舊流程描述。

驗證輸出：

```text
Skill is valid!
TEMPLATE_FILES_SYNC_OK
```

## 目前限制與注意事項

- 目前工作目錄不是 Git repository，無法執行 `git status` 或產生 diff／commit。
- `cp-task-dev` 已存在於本 source repo，但若要讓實際 runtime 立即觸發，仍需同步到對應的 Codex／Claude skills 安裝目錄。
- 本次沒有導入 SDD、open-spec 或 spec-kit；目前以 TDD 為 CP 專案實作階段的工作流。
- `cp-task-dev` 目前只驗證自身 skill 格式；若後續修改其他 skill，應重新執行相關 skill validator。

## 下一步建議

1. 將本 repo 的 `skills/cp-task-dev` 同步到實際 runtime skill 目錄，確認 skill discovery 可觸發。
2. 用一個實際 CP 任務跑一次完整流程，確認 `requirement-analysis.md`、`tdd-test-plan.md` 與 `dev-progress.md` 的內容是否足夠。
3. 若實際使用後發現狀態需要更細分，再評估是否將 `workflow-state.md` 的 coding 狀態拆成 `test_plan_ready`、`dev_in_progress` 等狀態。
4. 之後若要抽離通用能力，再另行評估 `project-workflow`；不要先把通用規則持續塞進 CP 特化 skill。

## Session 接手順序

下一個 session 建議依序讀取：

1. 本文件。
2. `README.md`。
3. `skills/cp-task-dev/SKILL.md`。
4. `skills/cp-backend-workflow/SKILL.md`。
5. `cp-task-folder-template/` 與 `skills/cp-task-template/references/task-folder-template/` 的三份新增模板。

## 本次追加：CP 工作流使用說明同步（2026-07-27）

已將完整 CP 工作流與使用方式補入專案根目錄 `README.md`，內容包含：

- 從 `/cp-backend-workflow CP-{編號}` 啟動完整流程。
- `cp-task-template`、repo inventory、`cp-backend-dev-doc`、`cp-task-dev`、review、自測、commit、push、MR 描述、MR 提交與衝突處理的順序。
- 任務文件固定路徑：`task-doc/{禪道衝刺版號}/task-{任務編號}/`。
- `workflow-state.md`、`requirement-changes.md`、`affected-repos.md` 與 `dev-progress.md` 的跨 session 續跑方式。
- 需求變更以 `R1`、`R2`、`R3` 追加，受影響階段標記為 `needs_update`。
- commit、push、建立或修改 MR 必須由使用者明確要求。
- 直接使用 `cp-task-dev` 的 prompt 範例與固定輸出文件。

本次只更新使用文件與交接紀錄，沒有修改 skill 執行規則或任務模板；`cp-task-dev` 的 validator 維持通過。
