# CP workflow skill session handoff - 2026-07-24

## 本次處理目標

針對目前 `work-flow-skill-sean` 專案中的 CP 後端工作流 skills，強化跨 session 可續跑能力、需求變更處理、路徑一致性與多 repo 任務範圍管理。

## 已完成改動

### 1. Workflow state / resume 機制

新增任務狀態檔概念：

- `handoff/workflow-state.md`
- `handoff/requirement-changes.md`

目的：

- 讓 `/cp-backend-workflow` 下次接續同一個 CP 任務時，可以先讀取狀態檔，不必重新猜目前做到哪一步。
- 每完成一個階段後記錄 repo 狀態、文件狀態、commit / push / MR URL、使用者決策。
- 被中斷後從第一個 `needs_update`、`blocked` 或 `pending` 階段繼續。

相關檔案：

- `skills/cp-backend-workflow/SKILL.md`
- `skills/cp-task-template/SKILL.md`
- `skills/cp-task-template/references/task-folder-template/handoff/workflow-state.md`
- `skills/cp-task-template/references/task-folder-template/handoff/requirement-changes.md`
- `cp-task-folder-template/handoff/workflow-state.md`
- `cp-task-folder-template/handoff/requirement-changes.md`

狀態值統一為：

- `pending`
- `in_progress`
- `done`
- `skipped`
- `blocked`
- `needs_update`

### 2. 需求變更處理

新增 `requirement-changes.md`，用 `R0 / R1 / R2...` 記錄需求版本。

規則：

- 初始需求記為 `R0 - 初始需求`。
- 使用者補充、修改、推翻或擴大需求時，不覆蓋舊狀態。
- 每次變更追加一筆紀錄。
- 受影響的已完成階段從 `done` 改成 `needs_update`。
- 未受影響階段保持 `done`，避免無意義重做。

影響判斷已寫入 `cp-backend-workflow/SKILL.md`，包含：

- API input / output 變更
- DB schema / Redis 變更
- 業務規則變更
- 只改禪道文字
- 只補測試說明
- MR 已建立後才變更需求
- 新增或移除服務 / repo

### 3. task-doc 路徑規則統一

使用者補充：「版本」其實是禪道 Scrum sprint version，不是程式版本。

因此已統一語意與路徑：

```text
task-doc/{衝刺版號}/task-{編號}/...
```

並在 skill 內統一稱為：

- 禪道衝刺版號
- Scrum sprint version
- `sprint_version`

`workflow-state.md` 也從原本 `version_dir` 改成：

- `sprint_version`
- `sprint_dir`

已清掉舊的：

```text
task-doc/task-{編號}
task-doc/{版本}
version_dir
```

唯一保留的 `task-doc/task-{編號}` 出現在禁止規則中：

```text
不得自行退回舊路徑 task-doc/task-{編號}
```

### 4. 子 skill 路徑契約

在 `cp-backend-workflow/SKILL.md` 新增「呼叫子 skill 時的路徑契約」。

總控呼叫任何會讀寫任務文件的子 skill 時，必須明確提供：

- `task_id`
- `sprint_version`
- `task_dir`

子 skill 收到 `task_dir` 時，必須優先使用該路徑，不得自行猜舊路徑。

已同步相關子 skill：

- `cp-backend-dev-doc`
- `cp-self-test-report`
- `cp-mr-description`
- `cp-code-review`
- `cp-mr-submit`

### 5. Repo inventory / affected repos

新增固定 repo inventory：

```text
project-doc/affected-repos.md
```

流程位置：

1. `cp-task-template` 建立任務資料夾後，先初始化 `affected-repos.md`
2. `cp-backend-dev-doc` 完成後，根據 codebase 探索結果校正 repo 清單
3. 需求變更後，重新評估新增、移除或不再需要處理的 repo
4. 後續 review / commit / push / MR 都以 `affected-repos.md` 為準

新增模板檔案：

- `skills/cp-task-template/references/task-folder-template/project-doc/affected-repos.md`
- `cp-task-folder-template/project-doc/affected-repos.md`

`workflow-state.md` 新增：

```text
affected_repos: project-doc/affected-repos.md
```

Repo 狀態值：

- `needs_confirm`
- `pending`
- `coding_done`
- `reviewed`
- `committed`
- `pushed`
- `mr_ready`
- `mr_created`
- `not_required`
- `blocked`
- `needs_update`

## 已修改的主要檔案

- `skills/cp-backend-workflow/SKILL.md`
- `skills/cp-task-template/SKILL.md`
- `skills/cp-backend-dev-doc/SKILL.md`
- `skills/cp-self-test-report/SKILL.md`
- `skills/cp-mr-description/SKILL.md`
- `skills/cp-code-review/SKILL.md`
- `skills/cp-mr-submit/SKILL.md`
- `skills/cp-task-template/references/backend-dev-doc-template.md`
- `skills/cp-mr-description/references/mr-description-template.md`
- `skills/cp-task-template/references/task-folder-template/README.md`
- `cp-task-folder-template/README.md`
- `skills/cp-task-template/references/task-folder-template/handoff/workflow-state.md`
- `skills/cp-task-template/references/task-folder-template/handoff/requirement-changes.md`
- `skills/cp-task-template/references/task-folder-template/project-doc/affected-repos.md`
- `cp-task-folder-template/handoff/workflow-state.md`
- `cp-task-folder-template/handoff/requirement-changes.md`
- `cp-task-folder-template/project-doc/affected-repos.md`

## 驗證結果

已安裝 `PyYAML 6.0.3` 到目前使用者的 Python site-packages。

原因：

- Homebrew Python 是 externally-managed environment，直接 system-wide pip install 被擋。
- 最後使用：

```bash
python3 -m pip install --user --break-system-packages PyYAML
```

已跑過 `skill-creator/scripts/quick_validate.py`。

全部通過的 skill：

- `cp-backend-workflow`
- `cp-task-template`
- `cp-backend-dev-doc`
- `cp-self-test-report`
- `cp-mr-description`
- `cp-code-review`
- `cp-mr-submit`

後續新增 repo inventory 後，重新驗證：

- `cp-backend-workflow`
- `cp-task-template`

結果皆為：

```text
Skill is valid!
```

## 目前專案狀態注意事項

此目錄目前不是 git repository。

執行：

```bash
git status --short
```

結果：

```text
fatal: not a git repository (or any of the parent directories): .git
```

因此本次沒有 commit，也沒有 git diff summary。

## 設計判斷

目前這套 skill 仍是 CP 專案特化版，不是通用專案 workflow。

原因：

- CP codebase 路徑寫死
- 禪道 task-doc / sprint version 綁定
- Java service 結構綁定 `bll / base / open-one-key`
- CP review 規則包含 BigDecimal、userId from token、Open/BLL/Base 架構邊界
- GitLab MR 提交規則綁定 Assignee / Squash / Delete source branch 等 CP 團隊慣例

若未來要支援全新專案，建議抽出通用層：

```text
project-workflow
  - workflow-state.md
  - requirement-changes.md
  - affected-repos.md
  - resume rules
  - repo inventory
  - generic review / commit / push / MR stages

cp-backend-workflow
  - CP 專案路徑
  - 禪道規則
  - CP Java 架構規則
  - CP MR / 自測 / review 特化
```

下一步若要繼續改善，建議先不要再把通用能力塞進 `cp-backend-workflow`，而是考慮建立 `project-workflow` skill，再讓 CP skill 採用它的狀態管理規則。

## 建議下一步

1. 決定是否要抽通用 `project-workflow` skill。
2. 若繼續強化 CP skill，下一個高價值項目是把 `affected-repos.md` 的狀態同步規則補到 `cp-code-review`、`cp-mr-description`、`cp-mr-submit`，讓它們明確讀 repo inventory，而不是只由總控口頭要求。
3. 若這份 source 要同步到實際 Codex/Claude skills 安裝目錄，需要再把本 repo 的 `skills/` 複製到對應 runtime skill 目錄。
