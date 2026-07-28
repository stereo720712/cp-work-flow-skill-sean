---
name: cp-backend-workflow
description: >
  CP 後端任務總控流程：當使用者要求完整處理 CP／禪道後端任務、從任務分析一路做到 commit、review、MR 描述或 GitLab MR 提交時使用。負責判斷目前階段、協調既有子 skill、管理多 repo 進度與必要確認，不取代各子 skill 的專業流程。
---

# CP 後端任務總控

協調 CP 後端任務從需求到 MR 的階段流程。實作階段可由 `cp-task-dev` 協助以 TDD 開發與保存進度；總控只負責判斷狀態、呼叫子 skill、保存文件與回報進度。

## 子 skill 對照

依階段使用既有 skill，不要複製其細節：

| 階段 | 使用 skill | 主要產出 |
|---|---|---|
| 任務模板 | `cp-task-template` | `task-{編號}/`、禪道主／子任務 HTML |
| Repo inventory | 總控維護 | `project-doc/affected-repos.md` |
| 後端設計 | `cp-backend-dev-doc` | backend dev doc HTML／Markdown |
| TDD 實作 | `cp-task-dev` | 需求分析、TDD 測試計畫、開發進度與交接紀錄 |
| commit | `commit` | 繁中 Conventional Commit |
| 自測 | `cp-self-test-report` | 後端自測報告（可選） |
| review | `cp-code-review` | 提測前 review 意見 |
| MR 描述 | `cp-mr-description` | 每個 repo 一份 MR Markdown |
| MR 提交 | `cp-mr-submit` | GitLab MR、Assignee、merge options、MR URL |
| 衝突 | `cp-merge-conflict` | 衝突分析與合併建議 |

## 啟動時收集

取得或確認：

- 禪道／CP 任務編號與任務 URL 或內容。
- 禪道衝刺版號（Scrum sprint version），例如 `1_25_0`；任務資料夾放在 `task-doc/{衝刺版號}/task-{編號}/`。
- 受影響 repo、目前分支與目標分支（預設 `master`）。
- 是否要產出自測報告。
- 實作方式：由 `cp-task-dev` 協助 TDD，或由使用者人工 coding。
- 是否要執行 commit、push、產生 MR 描述、提交 GitLab MR。

若已有 `task-doc/{衝刺版號}/task-{編號}/`，先讀取既有文件與 handoff，不覆蓋既有資料。資訊不足時一次只詢問最必要的問題。

## Workflow State 與續跑

每個任務資料夾固定維護：

- `handoff/workflow-state.md`：目前流程狀態、repo 進度、文件產物、外部操作結果。
- `handoff/requirement-changes.md`：需求變更紀錄與返工判斷。
- `project-doc/affected-repos.md`：本任務受影響 repo 清單，後續 review / commit / push / MR 都以它為準。

啟動時先執行：

1. 若 `workflow-state.md` 存在，先讀取它作為目前流程狀態。
2. 若 `requirement-changes.md` 存在，讀取最新需求版本與未處理變更。
3. 再用實際工作區狀態驗證 repo：`git status`、目前 branch、是否有未提交變更、是否已 push、是否已有 MR。
4. 若狀態檔與 git 現況不一致，以 git 現況為準，並更新 `workflow-state.md`。
5. 已標記 `done` 或 `skipped` 的階段不得重複執行，除非使用者明確要求重跑。
6. 若存在 `needs_update`，優先處理需要更新的階段，不要繼續往後做 MR 或結案。

狀態值只使用：

- `pending`：尚未處理
- `in_progress`：正在處理
- `done`：已完成
- `skipped`：使用者明確跳過
- `blocked`：有阻塞，需使用者或外部狀態處理
- `needs_update`：需求變更後，已完成產物需要更新

每完成一個階段後，更新 `workflow-state.md`：

- repo 狀態：coding、review、commit、push、MR 描述、MR URL。
- 文件狀態：任務描述、後端開發文件、自測報告、MR 描述。
- 外部操作結果：commit hash、push 狀態、MR URL。
- 使用者決策：是否跳過自測、是否 commit、是否 push、是否建立 MR。
- 最近進度：用時間條列記錄完成了什麼。

若流程被中斷，下次從第一個 `needs_update`、`blocked` 或 `pending` 階段繼續。

## 需求變更處理

當使用者補充、修改、推翻或擴大需求時，不得直接覆蓋既有文件或狀態。

處理流程：

1. 在 `handoff/requirement-changes.md` 新增一筆需求變更紀錄，版本號依序遞增：`R1`、`R2`、`R3`。
2. 比對變更內容與已完成階段，判斷受影響範圍。
3. 將受影響的 `done` 階段改為 `needs_update`。
4. 未受影響的階段保持 `done`，不得重做。
5. 更新 `workflow-state.md` 的目前需求版本與受影響 repo / 文件狀態。
6. 回報使用者：哪些產物需要更新、哪些可以沿用、是否需要人工 coding。
7. 等使用者確認後，再更新對應文件或進入 coding / review / MR 階段。

影響判斷規則：

- API input / output 變更：後端開發文件、coding、review、自測報告、MR 描述標記 `needs_update`。
- DB schema / Redis 變更：後端開發文件、coding、review、自測報告、MR 描述標記 `needs_update`。
- 業務規則變更：後端開發文件、coding、review、自測報告、MR 描述標記 `needs_update`。
- 只改禪道文字描述：任務模板或 MR 描述標記 `needs_update`。
- 只補測試說明：自測報告標記 `needs_update`。
- MR 已建立後才變更需求：不自動重開 MR，只標記 MR 需要更新並等待使用者確認。
- 需求新增或移除服務 / repo：`affected-repos.md` 標記 `needs_update`，並重新判斷 review、commit、push、MR 範圍。

## Repo Inventory

總控必須維護 `project-doc/affected-repos.md` 作為任務 repo 名冊。後續 review、commit、push、MR 描述與 MR 提交都以這份清單為準，不要每個子 skill 重新猜 repo 範圍。

建立或更新時機：

1. `cp-task-template` 建立任務資料夾後：根據任務描述初始化可能受影響 repo。
2. `cp-backend-dev-doc` 完成後：根據 codebase 探索結果校正 repo 清單。
3. 需求變更後：重新評估新增、移除或不再需要處理的 repo。
4. 使用者明確補充「還有另一個服務 / 前端 repo 要改」時：追加或更新清單。

格式固定：

```markdown
# task-{編號} affected repos

| repo | 類型 | 路徑 | source branch | target branch | 狀態 | 備註 |
|---|---|---|---|---|---|---|
|  | backend / backend-base / backend-open / frontend / other |  |  | master | needs_confirm |  |
```

Repo 狀態只使用：

- `needs_confirm`：可能受影響，需使用者或 codebase 探索確認。
- `pending`：已確認需要處理，但尚未 coding。
- `coding_done`：coding 已完成，尚未 review / commit。
- `reviewed`：已 review。
- `committed`：已 commit。
- `pushed`：已 push，可產 MR。
- `mr_ready`：MR 描述已產生。
- `mr_created`：MR 已建立。
- `not_required`：已確認相關但不需要處理。
- `blocked`：該 repo 有阻塞。
- `needs_update`：需求變更後需要重新處理。

規則：

- 不確定是否受影響的 repo，不要刪掉，標記 `needs_confirm`。
- 明確不需要改但與任務相關的 repo，保留並標記 `not_required`，避免後續重複詢問。
- 多 repo 任務的每個 repo 必須各自有一列，不得合併。
- `workflow-state.md` 的 Repo 狀態要與 `affected-repos.md` 同步；若兩者不一致，以 `affected-repos.md` 作為任務範圍，以 git 現況作為實際進度。
- 後續 review / commit / push / MR 只處理狀態不是 `not_required` 的 repo；`needs_confirm` 必須先確認，不可直接提交或建立 MR。

## 階段判斷

依序檢查工作區與文件狀態：

1. 沒有任務資料夾：使用 `cp-task-template` 建立標準骨架與任務文件。
2. 沒有 `project-doc/affected-repos.md` 或其狀態為 `needs_update`：建立或更新 repo inventory。
3. 沒有後端開發文件且需求需要設計：使用 `cp-backend-dev-doc`；完成後校正 `affected-repos.md`。
4. 仍未 coding：若使用者希望 Agent 協助實作，使用 `cp-task-dev` 先完成需求分析與 TDD 計畫，再進入實作；若由使用者人工 coding，仍要求以同一組文件記錄測試與進度，不假設程式已修改。
5. 有未提交程式變更：先確認 `cp-task-dev` 的 `dev-progress.md` 與測試紀錄已更新，再依 `affected-repos.md` 範圍執行 `cp-code-review`（使用者要求時），再用 `commit`；保留不相關變更，不自動加入。
6. 分支未 push：依 `affected-repos.md` 範圍在使用者明確要求時執行 push；網路受限時申請授權，不重複執行已成功的 push。
7. 自測報告：只有使用者要求或任務明確要求時使用 `cp-self-test-report`；使用者說「不用自測／不寫自測報告」時跳過，並在後續 MR 描述標記為不產出。
8. 要開 MR：依 `affected-repos.md` 範圍先使用 `cp-mr-description` 產生每個 repo 的 Markdown，再由使用者確認內容後使用 `cp-mr-submit` 實際建立 MR。
9. 發生 merge conflict：停止後續提交，使用 `cp-merge-conflict` 分析，等待使用者確認合併方案。

## 多 repo 任務規則

- 每個 repo 都是獨立 Git root，分別檢查 branch、status、commit、push 與 MR。
- 不把不同 repo 的變更混在同一次 commit 或 MR。
- 任務文件一律放在：`task-doc/{衝刺版號}/task-{編號}/...`。這裡的衝刺版號是禪道 Scrum sprint version，不是程式發版版本。
- MR 文件放在：`task-doc/{衝刺版號}/task-{編號}/end-version-report/mr-description/mr-description-{服務名}.md`。
- MR 建立設定依 `cp-mr-submit`：Assignee 預設 `austin`、Reviewer 不設定、Delete source branch 關閉、Squash commits 開啟。
- 已存在 MR 時不得重複建立；只回報現有 MR，除非使用者要求更新。

## 呼叫子 skill 時的路徑契約

總控呼叫任何會讀寫任務文件的子 skill 時，必須明確提供：

- `task_id`：任務編號，例如 `task-5987`。
- `sprint_version`：禪道衝刺版號，例如 `1_25_0`。
- `task_dir`：完整任務資料夾，例如 `task-doc/1_25_0/task-5987`。

子 skill 收到 `task_dir` 時，必須優先使用該路徑讀寫文件，不得自行退回舊路徑 `task-doc/task-{編號}`。

## 外部操作確認

以下動作會改變外部狀態，只有使用者明確要求時執行：

- `git commit`
- `git push`
- 建立 GitLab MR
- 設定 Assignee、Approval Rule 或 merge options

若使用者只要求分析、產文件或產生指令，不要自行 commit、push 或建立 MR。

## 進度回報

每個階段完成後回報：

- 已完成的 repo 與階段。
- 尚未完成或被阻擋的 repo 與原因。
- 產出的文件路徑、commit hash、branch 或 MR URL。
- 不要把「已產生 MR 描述」誤報成「已建立 MR」。

MR 完成後依 `cp-mr-submit` 的固定格式輸出：

```markdown
## task-{編號}
### {服務名稱}
{MR URL}
```
