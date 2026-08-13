---
name: cp-mr-description
description: >
  CP MR 描述產生器：當使用者說「幫我寫 MR」、「產出 MR 描述」、「我要開 MR」、「結案了幫我寫 merge request」時，務必使用這個 skill。
  根據任務資訊與 code 改動，產出完整的 GitLab MR 描述 Markdown，讓使用者直接複製貼上。
  凡是提到「MR」、「merge request」、「結案」、「開 PR」時，都應主動觸發此 skill。
---

# CP MR 描述產生器

## 概述

根據任務資訊與 code 改動，產出可直接複製貼上到 GitLab 的 MR 描述 Markdown。

---

## Workflow 模式契約

若由 `cp-backend-workflow` 呼叫，且提供 `task_dir`：

1. 先讀取 `{task_dir}/project-doc/affected-repos.md`，以此作為 MR 描述產生範圍。
2. 正式 MR 描述只處理狀態為 `pushed` 或 `mr_ready` 的 repo。
3. 每個 repo 一份 Markdown，寫入 `{task_dir}/end-version-report/mr-description/mr-description-{repo}.md`，不要把多 repo 合併成同一份 MR 描述。
4. 每個 repo 依自己的 `路徑`、`source branch`、`target branch` 取得 branch、commit log 與 diff。
5. 狀態為 `needs_confirm`、`pending`、`coding_done`、`needs_update`、`blocked`、`not_required` 的 repo 不產生正式 MR 描述，先回報原因與下一步。
6. 若使用者明確要求提前產生草稿，只能針對單一 repo 產 draft，檔案與回報都要標明草稿；不得將 repo 狀態更新為 `mr_ready`。
7. 完成後回報已產生的檔案、跳過的 repo，以及仍需確認、需返工或被阻塞的 repo。

若沒有 `{task_dir}/project-doc/affected-repos.md`：

1. 視為 workflow blocked：不產生正式 MR 描述，先要求補齊 `{task_dir}/project-doc/affected-repos.md`。
2. 若使用者明確要求臨時草稿，可只依目前 repo / 使用者指定 repo 產單 repo draft，並在回報中說明「未找到 affected-repos.md，本次為草稿，未更新 workflow 狀態，不可視為 mr_ready」。
3. 若可能涉及多 repo 或推測不唯一，不產草稿，先要求補齊 `affected-repos.md`。

## 執行步驟

### Step 1：收集任務資訊

取得：
- **任務編號**（禪道編號，例如 5728）
- **任務標題**
- **目前分支名稱**
- **禪道衝刺版號**（Scrum sprint version，例如 `1_25_0`）；若由 `cp-backend-workflow` 呼叫，優先使用其傳入的 `task_dir`
- **repo 範圍**：workflow 模式必須先讀 `{task_dir}/project-doc/affected-repos.md`；沒有時要求補齊 inventory，不產正式 MR 描述。只有使用者明確要求 draft 時，才可依單一明確 repo 產草稿

```bash
git branch --show-current
git log --oneline origin/master..HEAD
```

### Step 2：分析改動範圍

```bash
git diff origin/master...HEAD --stat
```

了解：
- 改動了哪些服務 / 檔案
- 主要改動類型（新增功能、修 bug、重構）

若 `{task_dir}/project-doc/task-{編號}-backend-dev-doc.md` 存在，讀取作為補充說明。
若由 `cp-backend-workflow` 傳入 `task_dir`，優先讀取 `{task_dir}/project-doc/task-{編號}-backend-dev-doc.md`，並將 MR 描述寫入 `{task_dir}/end-version-report/mr-description/`。

多 repo 任務要對狀態為 `pushed` 或 `mr_ready` 的 repo 分別執行 diff 與描述產生，輸出檔名使用 `mr-description-{repo}.md`。若需求變更、測試失敗、review blocking 或 code 又修改，既有 MR 描述視為 stale，下一次進入 MR 階段時必須重新產生。

### Step 3：產出 MR 描述 Markdown

閱讀 `references/mr-description-template.md`，根據任務資訊填入，產出完整 Markdown。

### Step 4：呈現結果

直接輸出 Markdown 內容，讓使用者複製貼上：

```
以下是 MR 描述，可直接複製貼上到 GitLab：

---
{MR 描述 Markdown}
---
```

---

## 參考資料

- `references/mr-description-template.md` — MR 描述 Markdown 模板
