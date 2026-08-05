---
name: cp-backend-dev-doc
description: >
  CP 後端開發文件產生器：當使用者描述一個 CP 任務需要做後端開發文件、說「幫我寫開發文件」、「分析這個任務」、「起草後端設計」時，務必使用這個 skill。
  會自動探索 java-service codebase，根據任務描述起草包含業務邏輯流程、API 設計、資料庫變更的後端開發文件，同時產出 HTML（可直接貼進禪道卡）與 Markdown（方便開發者閱讀）兩份本地檔案。
  凡是提到「後端開發文件」、「API 設計」、「資料庫變更」、「業務梳理」、「開發文件」時，都應主動觸發此 skill。
---

# CP 後端開發文件產生器

## 概述

根據使用者描述的任務需求，探索 java-service codebase，起草後端開發文件並儲存到本地。

**產出物（同一份內容，兩種格式）：**
- `task-doc/{衝刺版號}/task-{編號}/project-doc/task-{編號}-backend-dev-doc.html`（HTML 格式，方便直接貼進禪道卡）
- `task-doc/{衝刺版號}/task-{編號}/project-doc/task-{編號}-backend-dev-doc.md`（Markdown 格式，方便開發者閱讀）

**文件內容：**
1. 業務邏輯流程說明
2. API 設計（新增 / 修改的 endpoint）
3. 資料庫變更（新欄位、新表、Redis）
4. 注意事項 / 風險點

---

## 執行步驟

### Step 1：確認任務資訊

從使用者訊息中取得：
- **任務編號**（CP-XXXX 或 禪道 task 編號）
- **任務標題與需求描述**
- **初步判斷影響哪些服務**（若有提到）
- **禪道衝刺版號**（Scrum sprint version，例如 `1_25_0`）；若由 `cp-backend-workflow` 呼叫，優先使用其傳入的 `task_dir`

若任務編號不明，詢問使用者。若已有 `task_dir`，所有產出一律寫入 `task_dir/project-doc/`，不要自行組舊路徑。

若已有 `task_dir`，先讀取以下文件作為設計輸入；文件不存在時不要自行捏造內容，改以 `{待確認}` 標示或回報需先補齊：

- `{task_dir}/project-doc/business-brief.md`：大任務的業務流程與角色影響。
- `{task_dir}/project-doc/requirement-risk-test-brief.md`：PM / 後端 / 前端 / QA 會議確認過的改動、風險與測試說明。
- `{task_dir}/project-doc/release-assessment.md`：預發 / 正式上線評估，尤其 DB / Redis 共用資源影響。

### Step 2：探索 Codebase

Codebase 根目錄：`/Users/jixiangwang/Documents/pte-work/gitlab/cp-v2/cp-backend/java-service`

先讀取 AGENTS.md 了解整體架構：
```
/Users/jixiangwang/Documents/pte-work/gitlab/cp-v2/cp-backend/java-service/AGENTS.md
```

根據任務描述判斷影響的服務，進入對應目錄：
- 業務邏輯 → `bll/{服務名}/`
- 資料存取 → `base/{服務名}/`
- 對外 API → `open-one-key/{服務名}/`

在目標服務中搜尋相關的：
- Controller（`controller/`）：現有 API 入口
- Service（`service/impl/`）：業務邏輯
- Mapper（`mapper/`）：資料庫查詢
- Domain（`domain/vo/`、`domain/dto/`）：請求 / 回應模型
- 相關 Entity 或 Table 結構

**探索策略：**
- 先找最可能的入口點，不要一次掃描整個目錄
- 根據功能關鍵字搜尋（grep），縮小範圍後再讀完整檔案
- 若涉及跨服務呼叫，追蹤 `cloud/`（Feign Client）

### Step 3：分析影響範圍

根據 codebase 探索結果，整理：
- 需要新增的 API endpoint
- 需要修改的現有 API
- 需要新增的資料庫欄位 / 新表
- 需要新增 / 修改的 Redis key
- 跨服務呼叫影響
- 對測試說明與預發 / 正式上線評估的技術補充

若有不確定的設計決策，向使用者提問，每次 1~2 個問題。

### Step 4：建立任務資料夾

```bash
mkdir -p /Users/jixiangwang/Documents/pte-work/gitlab/cp-v2/cp-backend/task-doc/{衝刺版號}/task-{編號}/project-doc
```

若由 `cp-backend-workflow` 傳入 `task_dir`，改建立：

```bash
mkdir -p {task_dir}/project-doc
```

### Step 5：起草開發文件

閱讀 `references/backend-dev-doc-template.html`，根據分析結果填入模板，產出完整 HTML 文件；再把同一份內容輸出成對應的 Markdown 文件。

**HTML 格式規範（要能直接貼進禪道富文本）：**
- 禪道會吃掉 `<style>` 和 class，**所有樣式一律用 inline 屬性**（`<table border="1" cellpadding="6" cellspacing="0" width="100%">`）
- code / JSON / SQL 用 `<pre>` 包起來，避免被自動排版打亂
- 段落用 `<p>`、清單用 `<ul>/<ol>`、標題用 `<h1>~<h3>`，不要用 Markdown 語法

**內容填寫原則：**
- 業務流程要說清楚，讓隊友看得懂，用直白人話，少術語
- API 設計要包含完整 Request / Response JSON 範例
- 資料庫變更要附上可執行的 SQL
- 不確定的地方標示 `{待確認}` 並說明原因
- 符合 CP 架構規範：BigDecimal 金額、userId 來自 Token、Redis key 用封裝方法

### Step 6：儲存文件

將兩份文件儲存到：
```
/Users/jixiangwang/Documents/pte-work/gitlab/cp-v2/cp-backend/task-doc/{衝刺版號}/task-{編號}/project-doc/task-{編號}-backend-dev-doc.html
/Users/jixiangwang/Documents/pte-work/gitlab/cp-v2/cp-backend/task-doc/{衝刺版號}/task-{編號}/project-doc/task-{編號}-backend-dev-doc.md
```

儲存完成後，告知使用者：
- 兩份文件路徑（HTML 貼禪道、Markdown 供閱讀）
- 文件包含哪些主要內容
- 哪些地方標示了 `{待確認}`，需要使用者補充

---

## 重要原則

- **先探索再起草**：一定要先讀相關 code，不要只靠任務描述憑空設計
- **架構邊界**：Open 不直接呼叫 Base、BLL 不直接用 Mapper、跨服務走 Feign
- **安全規範**：userId 來自 Token 解析，金額用 BigDecimal，Redis key 用封裝
- **不確定就標示**：比起亂填，用 `{待確認}` 標示更有用

---

## 參考資料

- `references/backend-dev-doc-template.html` — 開發文件 HTML 模板（inline 樣式，可直接貼進禪道）
- `/Users/jixiangwang/Documents/pte-work/gitlab/cp-v2/cp-backend/java-service/AGENTS.md` — 系統架構總覽
