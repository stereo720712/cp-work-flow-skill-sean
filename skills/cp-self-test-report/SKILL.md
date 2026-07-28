---
name: cp-self-test-report
description: >
  CP 後端自測報告產生器：當使用者說「幫我生成自測報告」、「寫自測報告」、「生成測試報告」、「我要提測了」時，務必使用這個 skill。
  根據任務描述與 codebase 分析，產出可直接貼入禪道後端子任務、同時也儲存為本地 HTML 的完整後端功能自測報告。
  凡是提到「自測報告」、「test report」、「提測」、「後端測試」時，都應主動觸發此 skill。
---

# CP 後端自測報告產生器

## 概述

根據任務需求與實際 code，產出一份完整的後端功能自測報告，格式為 HTML。

**產出物：**
- `task-doc/{衝刺版號}/task-{編號}/test-file-script/task-{編號}-self-test-report.html` — 本地儲存
- 同內容也可直接貼入禪道後端子任務的「任務描述」欄位

**報告結構（依主管指定的禪道官方模板 `references/self-test-report-template.html`）：**
- 每個受影響的後端模組各一個 `<h2>` 區塊，多個模組用 `<hr />` 分隔
- 每個模組內固定四段 `<h3>`：
  1. **功能場景**：表格欄位 測試流程 | API|操作(Input) | 執行結果(Output) | 敘述/驗證點（正向 + 異常各至少一筆）
  2. **資料庫數值核對 (Data Integrity)**：表格欄位 核對目標 | SQL | 執行結果 | 敘述
  3. **單元測試 (Unit Test Reports)**：列出測試組件，留截圖 placeholder
  4. **其他測試結果 (Other Test Results)**：非 API 類驗證（排程 / 導出 / 回調等），留測試情境與截圖

---

## 執行步驟

### Step 1：確認任務資訊

取得：
- **任務編號**
- **任務描述**（或已有的開發文件）
- **禪道衝刺版號**（Scrum sprint version，例如 `1_25_0`）；若由 `cp-backend-workflow` 呼叫，優先使用其傳入的 `task_dir`

若 `task-doc/{衝刺版號}/task-{編號}/project-doc/task-{編號}-backend-dev-doc.md` 存在，優先讀取作為設計依據。若由 `cp-backend-workflow` 呼叫，優先使用其傳入的 `task_dir`。

### Step 2：探索 Codebase

Codebase 根目錄：`/Users/jixiangwang/Documents/pte-work/gitlab/cp-v2/cp-backend/java-service`

針對受影響的服務，找到：
- Controller 的 endpoint 路徑與方法名
- Service 的主要業務邏輯與分支條件
- 驗證規則（`@Valid`、手動 if 判斷、錯誤碼）
- 異常情境（什麼情況會拋錯、拋什麼錯誤碼）
- 資料庫 / Redis 的實際寫入欄位

從 code 推導出真實的 Input / Output 範例，而不是憑空想像。

**搜尋重點：**
- 錯誤碼：搜尋 `throw` 或 `ResultCode` / `BizException` 確認實際錯誤碼
- API 路徑：從 `@RequestMapping` / `@PostMapping` 確認完整路徑
- Response 結構：從 DTO 類別確認回傳欄位

### Step 3：設計測試案例

針對每個 API / 功能點，設計：

**正向流程（必有）：**
- 標準成功路徑
- 若有多種合法輸入組合，各設計一筆

**異常流程（必有）：**
- 必填欄位缺失
- 格式錯誤 / 非法值
- 業務邏輯不通過（例如餘額不足、狀態錯誤）
- 權限不足（若有）

### Step 4：建立任務資料夾（若不存在）

```bash
mkdir -p /Users/jixiangwang/Documents/pte-work/gitlab/cp-v2/cp-backend/task-doc/{衝刺版號}/task-{編號}/test-file-script
```

若由 `cp-backend-workflow` 傳入 `task_dir`，改建立：

```bash
mkdir -p {task_dir}/test-file-script
```

### Step 5：產出 HTML 報告

閱讀 `references/self-test-report-template.html`（主管指定的禪道官方模板）作為格式基礎，依實際測試案例填入完整內容，保持四段結構不變。

**格式要求（要能直接貼進禪道富文本）：**
- 每個模組一個 `<h2>` 標題，模組間用 `<hr />` 分隔
- 每個模組固定四段 `<h3>`：功能場景 / 資料庫數值核對 / 單元測試 / 其他測試結果
- 表格用 inline `style="width:1106.66px;"`，欄位順序照模板不要改
- API 路徑要完整（含 context-path）
- JSON / SQL 範例用 `<pre>` 包裹，排版清楚
- 驗證點要具體可執行，不要只寫「功能正常」
- 截圖類（單元測試、其他測試）保留 placeholder 提示，由使用者補圖

### Step 6：儲存並回報

儲存到：
```
/Users/jixiangwang/Documents/pte-work/gitlab/cp-v2/cp-backend/task-doc/{衝刺版號}/task-{編號}/test-file-script/task-{編號}-self-test-report.html
```

回報：
- 檔案路徑
- 涵蓋了哪些服務、幾個測試場景
- 哪些地方需要使用者補充真實測試數據（例如需要先建資料的前置條件）

---

## 重要原則

- **從 code 推導，不要憑空填寫**：API 路徑、錯誤碼、Response 欄位都要從 codebase 確認
- **正向 + 異常都要有**：只有 happy path 的報告是不完整的
- **驗證點要可執行**：測試人員看到驗證點，要能直接對照結果判斷是否通過
- **JSON 要格式化**：Input / Output 的 JSON 要縮排排版，方便閱讀

---

## 參考資料

- `references/self-test-report-template.html` — 報告 HTML 格式模板
- `task-doc/{衝刺版號}/task-{編號}/project-doc/task-{編號}-backend-dev-doc.md` — 同任務的開發文件（若已存在）
- `/Users/jixiangwang/Documents/pte-work/gitlab/cp-v2/cp-backend/java-service/AGENTS.md` — 系統架構
