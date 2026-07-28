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

## 執行步驟

### Step 1：收集任務資訊

取得：
- **任務編號**（禪道編號，例如 5728）
- **任務標題**
- **目前分支名稱**
- **禪道衝刺版號**（Scrum sprint version，例如 `1_25_0`）；若由 `cp-backend-workflow` 呼叫，優先使用其傳入的 `task_dir`

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

若 `task-doc/{衝刺版號}/task-{編號}/project-doc/task-{編號}-backend-dev-doc.md` 存在，讀取作為補充說明。
若由 `cp-backend-workflow` 傳入 `task_dir`，優先讀取 `{task_dir}/project-doc/task-{編號}-backend-dev-doc.md`，並將 MR 描述寫入 `{task_dir}/end-version-report/mr-description/`。

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
