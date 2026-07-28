---
name: cp-task-template
description: >
  CP 禪道任務模板產生器：當使用者描述一個 CP 任務的需求內容，或說「幫我建任務模板」、「生成禪道需求」、「寫禪道任務」、「幫我寫任務描述」時，務必使用這個 skill。
  接收使用者描述的任務內容後，產出三份可直接貼入禪道的 HTML 模板：主任務描述、後端子任務描述（含自測報告框架）、前端子任務描述（改動表格）。
  凡是提到「禪道模板」、「任務描述」、「建任務」、「寫任務」、「禪道需求」、「CP ticket」、「創建任務資料夾」、「建立任務資料夾」、「建任務資料夾」、「開任務資料夾」，或給了禪道任務 URL（task-view-XXXX）時，都應主動觸發此 skill。
---

# CP 禪道任務模板產生器

## 前置需求

若要從禪道任務 URL 自動讀取內容，執行環境必須已安裝並啟用 **Chrome 瀏覽器 MCP 套件／擴充功能**，且可使用下列工具：`tabs_context_mcp`、`navigate`、`get_page_text`（或 `read_page`）。

啟動 URL 讀取流程前，先確認上述 Chrome 工具可用。若未安裝、未啟用或無法登入禪道，告知使用者 Chrome 前置條件未完成，並請其直接貼上任務內容後再繼續；不要假設可以透過 shell 自動安裝或讀取登入中的禪道頁面。

## 概述

根據使用者描述的任務需求，產出三份結構化 HTML，可直接貼入禪道對應任務的「任務描述」欄位。

**產出物：**
1. **任務資料夾**：以 `cp-task-folder-template` 建立 `task-{編號}/`（含 project-doc / test-file-script / tool / handoff / end-version-report / other 六分類 + README + workflow state + affected repos）
2. **主任務描述** HTML
3. **後端子任務描述** HTML（含業務邏輯說明 + 自測報告框架）
4. **前端子任務描述** HTML（改動表格）

---

## 執行步驟

### Step 1：取得任務資訊

**若使用者提供了禪道任務 URL**（形如 `zentao.*/task-view-{編號}.html`）：
先確認 Chrome 瀏覽器 MCP 套件／擴充功能已安裝並啟用，且目前工作階段可呼叫 Chrome 工具；確認後才用 Chrome 瀏覽器工具讀取該頁再往下走——
`tabs_context_mcp`（取得 tab）→ `navigate` 到該 URL → `get_page_text` / `read_page` 取內容。

若 Chrome 工具不可用或禪道尚未登入，請使用者貼上任務標題與內容，改依貼上的內容執行後續步驟。
URL 裡的 `task-view-{編號}` 即任務編號。從頁面取得任務標題、情境、影響範圍。

從使用者描述（或禪道頁）中識別以下資訊：

- **任務標題**：影響的系統（如【管理後台】【收銀台】）+ 功能描述
- **任務情境**：問題背景或功能說明（條列式）
- **後端影響範圍**：哪些服務需要改動、改了什麼
- **前端影響範圍**：哪些前端 repo 需要改動、改了什麼
- **任務編號**（若已知）：CP-XXXX

若有明顯缺少的資訊（例如完全不知道影響哪些服務），主動詢問，每次只問 1~2 個問題。

### Step 2：以模板建立任務資料夾

先確認**任務編號**（如 `task-49555`）；若不明，先問使用者。

接著確認**禪道衝刺版號**（Scrum sprint version，例如 `1_25_0`）與任務資料夾父目錄。預設父目錄為：

`/Users/jixiangwang/Documents/pte-work/gitlab/cp-v2/cp-backend/task-doc/{衝刺版號}/`

拿到目錄後以資料夾模板複製一份：

```bash
cp -r ~/.claude/skills/cp-task-template/references/task-folder-template \
      /Users/jixiangwang/Documents/pte-work/gitlab/cp-v2/cp-backend/task-doc/{衝刺版號}/task-{編號}
```

建立後資料夾內含六個分類子資料夾、README、`handoff/workflow-state.md`、`handoff/requirement-changes.md`、`project-doc/affected-repos.md`，以及供 `cp-task-dev` 使用的需求分析、TDD 測試計畫和開發進度模板。後續產出的三份 HTML 建議存到 `task-{編號}/project-doc/`。

建立任務資料夾後，初始化：

- `handoff/workflow-state.md`：填入 task id、任務標題、禪道衝刺版號、task dir、初始文件狀態。
- `handoff/requirement-changes.md`：保留 `R0 - 初始需求`，將初始任務內容摘要填入「現在」。
- `project-doc/affected-repos.md`：根據任務描述先填入可能受影響 repo；不確定的 repo 標記 `needs_confirm`，明確不需要處理但相關的 repo 標記 `not_required`。

若使用者後續補充或修改需求，不要覆蓋初始內容；交由 `cp-backend-workflow` 追加需求版本並標記需要更新的階段。

**一律用上面的 `cp -r` 複製整個 `references/task-folder-template`，禁止手工 `mkdir` 逐個建資料夾**——手建一定會漏掉標準骨架（只寫個 overview 就是這樣來的）。

若目標資料夾已存在，先告知使用者、不要覆蓋，問要不要沿用或改名。

### Step 3：產出主任務描述 HTML

閱讀 `references/main-task-template.md`，根據任務資訊填入模板，產出完整 HTML。

重點：
- 情境描述用條列式，清楚說明為什麼需要這個功能
- 業務梳理連結先留空（`業務梳理Confluence：` 後面不填）
- 影響服務列出所有相關後端服務與前端專案，branch 留空

### Step 4：產出後端子任務描述 HTML

閱讀 `references/backend-subtask-template.md`，根據任務資訊填入模板，產出完整 HTML。

重點：
- 業務邏輯說明要具體，說明問題背景與修改了什麼
- 每個受影響的後端服務建立一組測試表格
- 測試案例要涵蓋正向流程和主要異常流程
- API 路徑、Input/Output 盡量根據描述推斷，若不確定用 `{待補充}` 標示
- 驗證點要具體可執行

### Step 5：產出前端子任務描述 HTML

閱讀 `references/frontend-subtask-template.md`，根據任務資訊填入模板，產出完整 HTML。

重點：
- 每個受影響的前端 repo 各一行
- 改動範圍條列具體改動項目
- 自測以使用者操作角度描述驗證點

### Step 6：呈現結果

依序呈現三份內容，標示清楚各自貼到哪個任務：

```
📋 主任務描述（貼到主任務「任務描述」欄位）
---
[HTML 內容]
---

📋 後端子任務描述（貼到「後端」子任務「任務描述」欄位）
---
[HTML 內容]
---

📋 前端子任務描述（貼到「前端」子任務「任務描述」欄位）
---
[HTML 內容]
---
```

---

## 重要原則

- **三份都要產出**：不要只產出部分，使用者需要全部三份。
- **HTML 格式輸出**：必須是可直接貼入禪道的 HTML，不是 Markdown。
- **不確定的地方用 `{待補充}` 標示**：讓使用者知道哪裡需要自己補充，不要憑空捏造 API 細節。
- **業務邏輯要說人話**：描述要清楚，讓不熟悉這個功能的隊友也能看懂。
- **資料夾一律套模板**：建任務資料夾只能 `cp -r` 複製 `references/task-folder-template`，不要手工 `mkdir`，否則會漏標準骨架。

---

## 參考範本

- `references/main-task-template.md` — 主任務描述 HTML 格式與說明
- `references/backend-subtask-template.md` — 後端子任務 HTML 格式與說明
- `references/frontend-subtask-template.md` — 前端子任務 HTML 格式與說明
