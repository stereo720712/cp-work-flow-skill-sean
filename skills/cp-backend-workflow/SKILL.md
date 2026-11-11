---
name: cp-backend-workflow
description: >
  CP 後端任務總控流程：當使用者要求完整處理 CP／禪道後端任務、任務估時、從任務分析一路做到 commit、review、MR 描述、GitLab MR 提交或交付測試部門的測試場景用例時使用。負責判斷目前階段、協調既有子 skill、管理多 repo 進度與必要確認，不取代各子 skill 的專業流程。
---

# CP 後端任務總控

協調 CP 後端任務從需求、估時到 MR 與測試交付的階段流程。實作階段可由 `cp-task-dev` 協助以 TDD 開發與保存進度；總控只負責判斷狀態、呼叫子 skill、保存文件與回報進度。

## 流程圖

```mermaid
flowchart TD
    A[使用者提供 CP / 禪道任務] --> B{已有 task_dir 與 workflow-state?}
    B -- 否 --> C[cp-task-template 建立任務資料夾與禪道模板]
    B -- 是 --> D[讀取 workflow-state / requirement-changes / affected-repos]
    C --> E[建立或更新 affected-repos.md]
    D --> E
    E --> F{需求是否已釐清並完成分級?}
    F -- 否 --> G[grill-me 釐清需求並判斷 simple / complex]
    F -- 是 --> FD1
    G --> FD1[drawio-diagram 產業務流程圖（已存在且未 needs_update 則跳過）]
    FD1 --> TE[產 task-estimation.html 任務估時]
    TE --> H[維護會議前置文件 pre-dev-brief 等]
    H --> FD3{有狀態流轉?}
    FD3 -- 是 --> FD3A[drawio-diagram 產狀態流轉圖]
    FD3 -- 否 --> I{需要後端設計?}
    FD3A --> I
    I -- 是 --> J[cp-backend-dev-doc 產後端開發文件並校正 repo]
    I -- 否 --> K{需要 Agent coding?}
    J --> CX{complex?}
    CX -- 是 --> FD2[drawio-diagram 產資料流 + 架構圖]
    CX -- 否 --> K
    FD2 --> K
    K -- 是 --> L[cp-task-dev 需求分析 / TDD / 實作 / dev-progress]
    K -- 否 --> M[使用者人工 coding 後補齊測試與進度紀錄]
    L --> N{是否需要 review?}
    M --> N
    N -- 是 --> O[cp-code-review]
    O --> P{有 blocking 問題?}
    P -- 是 --> L
    P -- 否 --> Q{需要自測報告?}
    N -- 否 --> Q
    Q -- 是 --> R[cp-self-test-report]
    Q -- 否 --> S{使用者要求 commit?}
    R --> S
    S -- 是 --> T[分 repo commit]
    S -- 否 --> U[等待使用者下一步]
    T --> V{使用者要求 push?}
    V -- 是 --> W[分 repo push]
    V -- 否 --> U
    W --> X{使用者要開 MR?}
    X -- 是 --> Y[cp-mr-description 產每 repo MR 描述]
    X -- 否 --> U
    Y --> Z{使用者確認建立 MR?}
    Z -- 是 --> AA[cp-mr-submit 建立 GitLab MR]
    Z -- 否 --> U
    AA --> AB{需要交付測試部門?}
    AB -- 是 --> AC[產 end-version-report/test-scenarios/test-scenarios.html]
    AB -- 否 --> AD[流程完成]
    AC --> FD4[drawio-diagram 產測試路徑圖]
    FD4 --> AD

    E -. 需求變更 .-> AE[記錄 requirement-changes.md 並標記 needs_update]
    FD1 -. 需求變更 .-> AE
    TE -. 需求變更 .-> AE
    H -. 需求變更 .-> AE
    FD3A -. 需求變更 .-> AE
    J -. 需求變更 .-> AE
    FD2 -. 需求變更 .-> AE
    L -. 需求變更 .-> AE
    Y -. 需求變更 .-> AE
    AC -. 需求變更 .-> AE
    AE --> D

    T -. merge / rebase / pull conflict .-> AF[cp-merge-conflict 分析衝突]
    W -. merge / rebase / pull conflict .-> AF
    AF --> U
```

## 子 skill 對照

依階段使用既有 skill，不要複製其細節。每個階段先使用主 skill；輔助 skill 只在觸發條件符合時引用，用來補需求釐清、品質閘門、驗證或外部交付。

| 階段 | 主 skill | 可引用的輔助 skill | 觸發條件 | 主要產出 / 動作 |
|---|---|---|---|---|
| 任務模板 | `cp-task-template` | `cp-backend-workflow` | 沒有任務資料夾、禪道任務描述需要建立或更新 | `task-{編號}/`、禪道主／子任務 HTML |
| Repo inventory | `cp-backend-workflow` | `cp-backend-dev-doc` 探索結果 | 沒有 `affected-repos.md`、需求變更、後端設計發現新 repo | `project-doc/affected-repos.md` |
| 任務分級 / 需求釐清 | `cp-backend-workflow` | `grill-me`、`drawio-diagram`、`karpathy-guidelines` | 需求未釐清、任務需分 simple / complex、存在假設或高風險業務行為 | 任務規模判斷、確認結論、待確認問題、業務流程圖 |
| 任務估時 | `cp-backend-workflow` | `grill-me` 結論、`affected-repos.md`、`karpathy-guidelines` | 任務分級與主要範圍完成後；需求變更影響範圍、風險或驗收時 | `project-doc/task-estimation.html` |
| 會議前置文件 | `cp-backend-workflow` | `grill-me` 結論、`drawio-diagram`、`karpathy-guidelines` | 估時完成後；開發前需要提報主管或會議前需要明確風險與測試範圍 | `pre-dev-brief.html`、`business-brief.html`、`release-assessment.html`、狀態流轉圖 |
| 後端設計 | `cp-backend-dev-doc` | `karpathy-guidelines`、`drawio-diagram`、`cp-backend-workflow` 校正 repo | 需求需要 API / DB / Redis / 業務流程設計，或既有設計需更新 | backend dev doc HTML／Markdown、校正 `affected-repos.md`；complex 另產資料流與架構圖 |
| TDD 實作 | `cp-task-dev` | `karpathy-guidelines`、必要時 `grill-me` | 使用者要 Agent coding、需要 TDD、需求仍有實作前歧義 | 需求分析、TDD 測試計畫、開發進度與交接紀錄 |
| Review | `cp-code-review` | `karpathy-guidelines`、`cp-task-dev` 測試紀錄 | 使用者要求 review、提測前、MR review、commit 前需要風險確認 | blocking / non-blocking / OK review 結果 |
| 自測 | `cp-self-test-report` | `cp-task-dev` 測試紀錄、`cp-code-review` 結果 | 使用者要求自測報告、任務明確需要後端自測交付 | 後端自測報告（可選） |
| Commit | `commit`（全域 skill） | `cp-backend-workflow`、`cp-code-review` | 使用者明確要求 commit，且 repo 範圍與測試 / review 狀態已確認 | 繁中 Conventional Commit；未安裝時依「Commit 規則」節 |
| Push | `cp-backend-workflow` | 無專用 skill | 使用者明確要求 push，且每個 repo 已 commit | 每個 repo 各自 push |
| MR 描述 | `cp-mr-description` | `affected-repos.md`、`cp-task-dev`、`cp-self-test-report`、`cp-code-review` | 使用者要開 MR 或產 MR 描述，且 repo 範圍已確認 | 每個 repo 一份 MR Markdown |
| MR 提交 | `cp-mr-submit` | Chrome / GitLab 登入狀態、`cp-mr-description` | 使用者確認 MR 描述並要求建立 MR | GitLab MR、Assignee、merge options、MR URL |
| 測試場景用例 | `cp-backend-workflow` | `cp-task-dev`、`cp-self-test-report`、`cp-code-review`、`drawio-diagram` | MR 建立後要交付測試部門；或使用者要求提早產出草稿 | `end-version-report/test-scenarios/test-scenarios.html`、測試路徑圖 |
| 衝突 | `cp-merge-conflict` | `cp-backend-workflow` 暫停後續階段 | merge / rebase / pull 出現 conflict | 衝突分析與合併建議，使用者確認後才寫入 |
| 流程圖 | `drawio-diagram` | `grill-me` 結論、`cp-backend-dev-doc`、`test-scenarios.html` | 需求釐清後產業務流程圖；有狀態流轉時產狀態流轉圖；complex 後端設計後產資料流與架構圖；測試場景完成後產測試路徑圖；或使用者要求畫圖 / 要貼 Confluence | `project-doc/diagrams/*.drawio`（有 draw.io desktop 時另產 `.png`） |

輔助 skill 調用規則：

- `karpathy-guidelines` 是品質閘門，不是獨立階段；需求釐清、後端設計、TDD、review 都要套用它的假設 / 簡潔 / 精準改動 / 驗證標準。
- `grill-me` 只負責逐題釐清決策，不直接改文件；結論由總控寫入業務、風險、測試或上線文件。
- `cp-task-dev` 的測試紀錄是 review、自測報告、MR 描述與測試場景用例的主要輸入之一。
- `cp-code-review` 的結果可回饋到 `cp-task-dev` 修正，也可作為 commit / MR 前的風險依據。
- `cp-backend-dev-doc` 完成後必須回饋 `affected-repos.md`，避免後續 review / commit / MR 範圍過期。
- `drawio-diagram` 只畫圖，不決定需求；圖的內容以 `pre-dev-brief.html` 與後端開發文件為準，圖與文字不一致時以文字為準。開發文件內已有 mermaid 時，mermaid 是來源、drawio 是產物，要改流程先改 mermaid 再重產。

## 啟動時收集

取得或確認：

- 禪道／CP 任務編號與任務 URL 或內容。
- 禪道衝刺版號（Scrum sprint version），例如 `1_25_0`。
- 任務文件根目錄 `task_root` 與完整任務目錄 `task_dir`。若使用者未提供，先詢問要放哪裡；可建議預設 `{repo}/task-doc/{衝刺版號}/`，但不得未確認就建立。
- 受影響 repo、目前分支與目標分支（預設 `master`）；source branch 依「分支命名」節的 `feature/{衝刺版號}_task-{任務編號}` 格式確認。
- 任務規模：`simple` / `complex`；若不明，先依影響範圍判斷。
- 任務估時是否要貼禪道、是否要拆前端 / 後端 / QA / PM 溝通成本。
- 是否需要跨 PM / 後端 / 前端 / QA 會議討論。
- 是否涉及預發 / 正式共用 DB、Redis、MQ、排程、回調或資料初始化。
- 是否涉及 Web 前後端業務互動流程：頁面入口、角色權限、前端操作、後端 API、DB / Redis 變化、前端回顯 / 錯誤提示。
- 是否要產出自測報告。
- 實作方式：由 `cp-task-dev` 協助 TDD，或由使用者人工 coding。
- 是否要執行 commit、push、產生 MR 描述、提交 GitLab MR、交付測試場景用例。

若已有 `task_dir`，先讀取既有文件與 handoff，不覆蓋既有資料。資訊不足時一次只詢問最必要的問題。

## Workflow State 與續跑

每個任務資料夾固定維護：

- `handoff/workflow-state.md`：目前流程狀態、repo 進度、文件產物、外部操作結果。
- `handoff/requirement-changes.md`：需求變更紀錄與返工判斷。
- `project-doc/affected-repos.md`：本任務受影響 repo 清單，後續 review / commit / push / MR 都以它為準。
- `project-doc/task-estimation.html`：任務估時 HTML 表格。
- `project-doc/pre-dev-brief.html`：開發前主管提報文件，說明需求背景、方案、影響範圍、風險、測試、估時與待決策事項。
- `project-doc/business-brief.html`：complex 任務的詳細業務流程補充附件。
- `project-doc/release-assessment.html`：有上線風險時才產生的預發 / 正式上線評估，特別記錄 DB / Redis 影響。
- `project-doc/diagrams/`：本任務的 draw.io 流程圖與 PNG，由 `drawio-diagram` 產生。
- `end-version-report/test-scenarios/test-scenarios.html`：交付測試部門的測試場景用例。

啟動時先執行：

1. 若 `workflow-state.md` 存在，先讀取它作為目前流程狀態。
2. 若 `requirement-changes.md` 存在，讀取最新需求版本與未處理變更。
3. 再用實際工作區狀態驗證 repo：`git status`、目前 branch、是否有未提交變更、是否已 push、是否已有 MR。
4. 若狀態檔與 git 現況不一致，以 git 現況為準，並更新 `workflow-state.md`。
5. 已標記 `done` 或 `skipped` 的階段不得重複執行，除非使用者明確要求重跑。
6. 若存在 `needs_update`，優先處理需要更新的階段，不要繼續往後做 MR 或結案。

階段 / 文件狀態值只使用：

- `pending`：尚未處理
- `in_progress`：正在處理
- `done`：已完成
- `skipped`：使用者明確跳過
- `blocked`：有阻塞，需使用者或外部狀態處理
- `needs_update`：需求變更後，已完成產物需要更新

Repo 狀態另有一套（見「Repo Inventory」）。兩者同步規則：任一必要 repo 為 `blocked` 時，該 repo 正在進行的階段標 `blocked`；任一必要 repo 為 `needs_update` 時，該 repo 已完成的 coding / review / commit / MR 相關階段標 `needs_update`。

每完成一個階段後，更新 `workflow-state.md`：

- repo 狀態：coding、review、commit、push、MR 描述、MR URL。
- 文件狀態：任務描述、任務估時、後端開發文件、自測報告、MR 描述、測試場景用例。
- 外部操作結果：commit hash、push 狀態、MR URL。
- 使用者決策：是否跳過自測、是否 commit、是否 push、是否建立 MR、是否交付測試場景。
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

- API input / output 變更：後端開發文件、coding、review、自測報告、MR 描述、測試場景用例標記 `needs_update`。
- DB schema / Redis 變更：後端開發文件、coding、review、自測報告、MR 描述、測試場景用例標記 `needs_update`。
- 業務規則變更：後端開發文件、coding、review、自測報告、MR 描述、測試場景用例標記 `needs_update`；`diagrams/` 的 `business-flow` 一併標記。
- API / DB / Redis 變更影響資料流或分層：`diagrams/` 的 `data-flow`、`architecture` 標記 `needs_update`。
- 狀態機、狀態流轉或觸發事件變更：`diagrams/` 的 `state-machine` 標記 `needs_update`。
- 測試範圍、必測路徑或異常路徑變更：`test-scenarios.html` 與 `diagrams/` 的 `test-path` 一起標記 `needs_update`。
- 開發文件內的 mermaid 與對應 drawio 一律同時標記 `needs_update`，且先改 mermaid 再重產 drawio。
- 影響 repo 範圍、實作策略、驗收條件、風險或交付時間：任務估時標記 `needs_update`。
- 前後端業務互動流程變更，例如頁面入口、操作步驟、前端 request / response 處理、錯誤提示、角色權限：`pre-dev-brief.html`、自測報告、MR 描述、測試場景用例標記 `needs_update`；若影響 API 或前後端實作，再標記後端開發文件與 coding。
- 只改禪道文字描述：任務模板或 MR 描述標記 `needs_update`。
- 只補測試說明：自測報告標記 `needs_update`。
- 會議後調整業務流程、風險或測試範圍：`pre-dev-brief.html` 標記 `needs_update`；complex 任務同步更新 `business-brief.html`，若涉及上線策略則更新 `release-assessment.html`；若影響實作，再標記後端開發文件與 coding。
- 上線策略、DB / Redis / 預發正式共用資源評估變更：`release-assessment.html`、自測報告、MR 描述標記 `needs_update`；若影響程式或資料腳本，再標記 coding。
- MR 建立後又變更需求、測試失敗或 code diff 變動：測試場景用例標記 `needs_update`，待 MR / 文件重新定案後再重產。
- MR 已建立後才變更需求：不自動重開 MR，只標記 MR 需要更新並等待使用者確認。
- 需求新增或移除服務 / repo：`affected-repos.md` 標記 `needs_update`，並重新判斷 review、commit、push、MR 範圍；`diagrams/` 的 `architecture` 一併標記。

## Karpathy Guidelines 品質閘門

`karpathy-guidelines` 不是獨立階段，而是整個 workflow 的品質閘門。總控在呼叫子 skill 前後套用以下檢查：

1. **Think Before Coding**：在 `grill-me`、後端開發文件與 `cp-task-dev` 前，明確列出已確認結論、仍是假設的內容、需要使用者決策的問題；關鍵業務行為、金流 / 訂單 / 權限 / DB 影響不明時，不直接進入 coding。
2. **Simplicity First**：任務分級為 `simple` 時，後端開發文件與 TDD 計畫只保留支撐驗收的最小設計；不得新增泛用框架、未要求的配置化或跨場景抽象。
3. **Surgical Changes**：`affected-repos.md` 是改動邊界；coding、review、commit、MR 只處理狀態不是 `not_required` 的 repo。發現無關重構、格式化或既有死 code，只記錄風險，不順手修改。
4. **Goal-Driven Execution**：每個進入 coding 的 repo 都必須在 `cp-task-dev` 產出可驗證目標與測試命令；沒有實際執行的測試，不得被記錄為通過。

若 runtime 未安裝 `karpathy-guidelines`，總控仍依本節執行同等規則，不阻塞流程。

## 任務分級與 grill-me 導入

在 `cp-task-template` 建立任務資料夾、且 `affected-repos.md` 初步完成後，先做任務分級，再決定文件深度。

### 分級規則

符合任一條件時，預設判定為 `complex`：

- 跨 2 個以上 repo，或同時影響前端 / 後端 / QA / PM 流程。
- 需要驗證完整 Web 前後端業務互動流程，包含頁面操作、API、DB / Redis 與前端回顯 / 錯誤提示。
- 涉及 DB schema、Redis、MQ、排程、回調、通知、資料初始化或資料修復。
- 涉及資金、訂單、商戶、交易員、權限、風控或狀態機。
- 需要評估預發 / 正式共用 DB、Redis，或預發作為正式備援的上線影響。
- 需求有多角色、多狀態、多流程分支，或 PM / QA 需要拿文件開會對齊。

不符合上述條件、且是單 repo 小改 / 小 API / 文案 / 查詢欄位時，可判定為 `simple`。

### grill-me 使用時機

- 所有任務在產後端開發文件前，都要先使用 `grill-me` 做需求釐清。
- `simple` 任務：使用輕量 grill，只確認改動範圍、驗收條件、主要風險、測試重點與不做事項；通常 1~3 題即可。
- `complex` 任務：使用完整 grill，逐題確認業務流程、角色影響、DB / Redis / MQ / 排程 / 回調 / 通知、權限 / 風控、測試範圍、上線與回滾。
- 使用者明確說「用 grill-me 分析 / grill 一下需求」：直接啟動，不再重複確認。
- 使用者明確說不用追問：可跳過，但要在 `workflow-state.md` 記錄 `grill_me: skipped` 與原因；此時仍需在 `pre-dev-brief.html` 中標示未經 grill 確認的假設。

本 workflow repo 自帶 `skills/grill-me/`。若 runtime 尚未安裝該 skill，使用本 repo 的 `skills/grill-me/SKILL.md` 規則執行同等流程，不依賴外部 `grilling` skill。

`grill-me` 只負責逐題釐清決策，不直接改文件；確認結論後，總控依序產出業務流程圖 → `task-estimation.html` → `pre-dev-brief.html`；若為 `complex`，再產出或更新 `business-brief.html`，有上線風險時產出或更新 `release-assessment.html`。測試場景用例是 MR 建立後的交付產物，不在此階段生成。

### 分級後產物

`simple` 任務至少維護：

- `project-doc/task-estimation.html`
- `project-doc/pre-dev-brief.html`
- `project-doc/diagrams/{task_id}-business-flow.drawio`

`complex` 任務額外維護：

- `project-doc/business-brief.html`
- `project-doc/diagrams/{task_id}-data-flow.drawio`
- `project-doc/diagrams/{task_id}-architecture.drawio`

涉及訂單、工單、審核或任何狀態機時，額外維護：

- `project-doc/diagrams/{task_id}-state-machine.drawio`

涉及 DB、Redis、MQ、排程、回調、正式資料修復、預發正式差異或需要明確上線 / 回滾計畫時，額外維護：

- `project-doc/release-assessment.html`

所有任務在 MR 建立後，若需要交付測試部門，才產生：

- `end-version-report/test-scenarios/test-scenarios.html`
- `project-doc/diagrams/{task_id}-test-path.drawio`

## 任務估時

任務估時在任務分級、需求釐清與業務流程圖之後產生，早於 `pre-dev-brief.html`（它要引用估時摘要）、後端開發文件與 TDD 實作。估時先用簡單 HTML 表格即可，供禪道貼上、PM 排期與後續需求變更比對。

備註：目前這份估時表是暫時給 CP 後端流程使用；之後再抽象成更通用的估時模型，並依不同系統、環境與交付流程定義不同的估時項目。

產出位置固定：

```text
project-doc/task-estimation.html
```

HTML 表格固定欄位：

```html
<table>
  <thead>
    <tr>
      <th>估時項目</th>
      <th>工作內容</th>
      <th>預估工時</th>
      <th>備註</th>
    </tr>
  </thead>
  <tbody>
    <tr><td>需求整理</td><td></td><td></td><td></td></tr>
    <tr><td>Coding</td><td></td><td></td><td></td></tr>
    <tr><td>自測與修改</td><td></td><td></td><td></td></tr>
    <tr><td>文件整理</td><td></td><td></td><td></td></tr>
    <tr><td>前端對接文件</td><td></td><td></td><td></td></tr>
    <tr><td>Code Review / MR 準備</td><td></td><td></td><td></td></tr>
    <tr><td>部署收尾</td><td></td><td></td><td></td></tr>
    <tr><td>合計</td><td></td><td></td><td></td></tr>
  </tbody>
</table>
```

估時規則：

- `Coding` 包含後端實作與必要單元 / 整合測試補強，不包含自測後返修。
- `自測與修改` 包含本地測試、功能自測、排程 / 回調 / DB 狀態確認與自測後修正。
- `文件整理` 包含後端開發文件、自測報告、MR 描述、測試場景用例或禪道需要貼上的後端說明。
- `前端對接文件` 包含 API input / output、錯誤碼、欄位說明、頁面互動注意事項。
- `Code Review / MR 準備` 是總控預設補上的估時項，包含 self-review、處理 review 問題、整理 MR 前置資訊。
- `部署收尾` 包含 push、MR 建立後追蹤、上線注意事項、DB / Redis / 排程 / 回調確認與 QA 交接。
- 需求未確認時，在備註欄標明假設與待確認事項，不要把估時寫成單一確定承諾。
- 需求變更後，只更新受影響的列與合計，保留前一版估時摘要或備註，方便比較增減。

## 會議前置文件

會議前置文件直接產 HTML；HTML 內容要能直接貼入禪道富文本。

`pre-dev-brief.html` 是 simple / complex 都要有的開發前主管提報主文件，內容先固定包含：

- 需求背景：為什麼要做，現況痛點是什麼。
- 目標方案：這次要怎麼解，預期流程會變成什麼。
- 影響範圍：影響哪些服務、API、DB、Redis、MQ、排程、回調、前端頁面或外部系統；不確定項標 `待確認`。
- 業務流程：用條列或流程圖說明主要流程、狀態流轉與前後端互動；附上 `diagrams/` 下對應的 `.drawio` 檔名，有 PNG 時一併引用。
- 風險與注意事項：整理金流、訂單狀態、權限、幣種、回調、排程、資料一致性、相容性與前後端顯示落差等風險。
- 測試與驗收重點：列出後端自測、前後端聯調、QA 必測路徑、異常路徑與回歸範圍。
- 開發估時：引用 `task-estimation.html` 的估時摘要。
- 待主管 / PM / QA 確認事項：列出需要會上確認的決策。
- 不做範圍：明確列出本次不處理的功能、資料修復、相容場景或前端改動。

`business-brief.html` 只在 complex 任務產生，作為 `pre-dev-brief.html` 的詳細業務流程附件：

- 現況流程與痛點。
- 目標流程與角色分工。
- 主要狀態流轉、資料流與前後端互動；有狀態機時附上 `diagrams/{task_id}-state-machine.drawio`，節點是狀態、邊是觸發事件。
- 邊界案例與例外處理。
- 會議決策紀錄。

`release-assessment.html` 只在 complex 或涉及上線風險時產生，內容聚焦上線影響：

- 預發 / 正式環境差異。
- DB / Redis / MQ / 排程 / 回調 / 初始化資料影響。
- 上線步驟、驗證方式與回滾方式。
- 是否需要停機、灰度、補資料或通知 QA / PM / 運維。
- 上線後觀察指標與已知殘留風險。

## 測試場景用例

給測試部門看的測試用例 HTML：**以這次改動的 API 為主軸，推出每支 API 可能的業務場景**，讓測試人員拿到就能照著測。它不是開發的自測紀錄，也不是把 TDD 測試案例原樣轉貼。

### 產出時機

- 正式版：MR 建立後產生，此時 code diff 已定案。前置條件：
  - `affected-repos.md` 中需要處理的 repo 狀態為 `mr_created`。
  - 不存在必要 repo 的 `needs_update`、`blocked`、`needs_confirm`。
- 草稿版：使用者要求提早給測試部門時，可在 coding 完成（repo 為 `coding_done` 以後）就產生，`status` 標 `draft`；MR 建立後或 diff 變動後重產為正式版。
- 前置條件不成立時，不產正式版；先回報缺少哪個前置階段。

產出位置固定：

```text
end-version-report/test-scenarios/test-scenarios.html
```

HTML 格式以 `references/test-scenarios-template.html` 為準，內容要能直接貼入禪道富文本（inline style、表格，不依賴外部 CSS / JS）。

### 步驟一：盤點改動的 API

依 `affected-repos.md` 範圍，對每個 repo 讀 `git diff {target_branch}...{source_branch}`，列出所有「入口」：

- **直接改動**：Controller / FeignClient 的 mapping、request / response DTO、參數校驗有改。
- **間接影響**：Service / Mapper / 工具類有改時，往上追呼叫它的 API，一併列入並標「間接」；追不到入口的改動記在「待確認」。
- **非 HTTP 入口**：MQ consumer、排程、回調、通知也算入口，同樣列出。

每個入口記錄：服務、Method + Path（或 topic / job 名稱）、改動類型（新增 / 修改 / 行為變更）、改了什麼（白話）、影響的前端頁面與角色。頁面與角色從前端子任務描述、`pre-dev-brief.html` 或 controller 的權限註解取得；找不到就標 `{待確認}`。

### 步驟二：每支 API 推業務場景

依下列維度逐一檢查，**只列這支 API 真的適用的維度**，不湊數：

| 維度 | 要推什麼場景 |
|---|---|
| 主流程 | 每個業務分支（code 中的 if / switch / 策略分派）至少一個正常場景 |
| 參數校驗 | 必填缺少、格式錯誤、長度、金額精度、枚舉值不合法 |
| 角色權限 | 不同角色呼叫、未登入、越權操作別人的資料 |
| 狀態前置 | 訂單 / 商戶 / 帳號處於不同狀態時呼叫（含不允許的狀態） |
| 邊界值 | 0、負數、上限、跨日 / 時區、幣種、空列表、分頁邊界 |
| 冪等與併發 | 重複提交、回調重送、同一筆資料同時操作 |
| 外部依賴 | 三方 / 下游服務失敗或逾時、MQ 重試 |
| 相容舊資料 | 新欄位在歷史資料為 null、舊版前端呼叫 |
| 副作用 | DB 欄位、Redis key、MQ 訊息、通知、日誌是否正確產生或未產生 |
| 前端回顯 | 成功提示、錯誤訊息、列表刷新、導出結果 |

多支 API 組成一條業務流程時（例如建單 → 付款 → 回調 → 查詢），另外列「端到端業務場景」，串起整條流程測。

### 寫法規則

- 每個場景一列：編號（`A1-S01`，A = API 序號）、類型、業務場景、前置條件、操作步驟、預期結果、優先級、來源、開發已測。
- **預期結果要具體**：回應 code / 訊息、畫面變化、DB / Redis 狀態；不寫「正常」「成功」。錯誤碼與訊息必須來自 code，不要自己編。
- **來源欄必填**：`需求`、`diff`、`TDD`、`自測`、`推導`。`推導` 表示是從 code 分支推出、業務預期未經確認的場景，預期結果寫 code 的實際行為並加註「請 PM / QA 確認業務預期」。
- **不知道的不編**：API 欄位、測試帳號、URL 不確定時標 `{待補充}`。
- **開發已測**：TDD 測試計畫或自測報告已實測過的，填結果與環境（例如「通過 / test 環境 / 11-10」），測試部門可決定是否重測；沒實際執行的不得填通過。
- 優先級：P0 主流程與資金 / 訂單 / 權限相關；P1 異常與邊界；P2 相容與回顯細節。
- 無法由 Agent 實測的頁面互動，標為需測試部門補測與截圖。
- 最後列「回歸範圍」（共用同一 Service / 表 / Redis key 的既有功能）與「不測項目」（含原因與風險接受人）。

場景寫完後，用 `drawio-diagram` 產 `diagrams/{task_id}-test-path.drawio`：lane 分「正常路徑」與「異常路徑」，依 P0 / P1 場景與端到端業務場景畫成流程，異常分支用紅色節點。圖的內容必須與 `test-scenarios.html` 一致；場景改了要一併重產。

## Repo Inventory

總控必須維護 `project-doc/affected-repos.md` 作為任務 repo 名冊。後續 review、commit、push、MR 描述、MR 提交與測試場景用例都以這份清單為準，不要每個子 skill 重新猜 repo 範圍。

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
|  | backend / backend-base / backend-open / frontend / other |  | feature/{衝刺版號}_task-{任務編號} | master | needs_confirm |  |
```

source branch 一律填「分支命名」節的格式；尚未開分支時照樣先填預期名稱，並在備註標 `未建立`。

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

## 分支命名

開發者常同時跑多個任務，分支名稱必須一眼看出「哪個衝刺、哪個任務」。

格式固定：

```text
feature/{衝刺版號}_task-{任務編號}
```

範例：

```text
feature/1_25_0_task-5987
```

- `{衝刺版號}` 是禪道 Scrum sprint version，例如 `1_25_0`，不是程式發版版本。
- `{任務編號}` 是禪道任務編號，與 `task_dir` 的 `task-{編號}` 一致。
- 修 bug 類任務可用 `fix/` 取代 `feature/`，其餘格式不變。
- 多 repo 任務的每個 repo 都用**同一個分支名稱**，方便對照與開 MR。

進入 coding 前必須檢查：

1. 讀 `affected-repos.md`，取得每個要處理 repo 的 source branch。
2. 對每個 repo 執行 `git branch --show-current`，比對是否符合上述格式。
3. **不符合或還在 `master` / `develop` 上時，提醒使用者**：目前在哪個分支、依任務資訊建議的分支名稱是什麼、有哪些 repo 需要開分支。
4. 缺少衝刺版號時先問使用者，不要自己編一個版號。

**建立或切換分支屬於外部操作，必須使用者明確要求才執行**；總控預設只提醒與提供建議指令，不自行 `git checkout -b`。

分支名稱確認後寫回 `affected-repos.md` 的 source branch 欄，後續 commit、push、MR 都以它為準。

## 階段判斷

依序檢查工作區與文件狀態（順序與流程圖一致）：

1. 沒有任務資料夾：使用 `cp-task-template` 建立標準骨架與任務文件。
2. 沒有 `project-doc/affected-repos.md` 或其狀態為 `needs_update`：建立或更新 repo inventory。
3. 尚未任務分級或需求未釐清：判斷 `simple` / `complex`，使用 `grill-me` 釐清；完成後用 `drawio-diagram` 產 `business-flow` 業務流程圖（已存在且非 `needs_update` 則跳過）。
4. 沒有 `project-doc/task-estimation.html` 或其狀態為 `needs_update`：依任務分級、repo 範圍、風險與待確認事項產生或更新估時 HTML 表格。
5. 會議前置文件缺失或 `needs_update`：所有任務產 `pre-dev-brief.html`（引用估時摘要），complex 另產 `business-brief.html`，有上線風險時產 `release-assessment.html`；任務涉及狀態機時另產 `state-machine` 圖，附在 `business-brief.html`。
6. 沒有後端開發文件且需求需要設計：使用 `cp-backend-dev-doc`；完成後校正 `affected-repos.md`；complex 任務再用 `drawio-diagram` 產 `data-flow` 與 `architecture`。
7. 進入 coding 前：依「分支命名」節檢查每個要處理 repo 的目前分支；不符 `feature/{衝刺版號}_task-{任務編號}` 或仍在 `master` 上時，先提醒使用者並給建議分支名稱，等使用者確認或自行開分支後再往下。
8. 仍未 coding：若使用者希望 Agent 協助實作，使用 `cp-task-dev` 先完成需求分析與 TDD 計畫，再進入實作；若由使用者人工 coding，仍要求以同一組文件記錄測試與進度，不假設程式已修改。
9. coding 完成、尚未 commit：先確認 `cp-task-dev` 的 `dev-progress.md` 與測試紀錄已更新；使用者要求時依 `affected-repos.md` 範圍執行 `cp-code-review`，有 blocking 問題回到第 8 步。
10. 自測報告：只有使用者要求或任務明確要求時使用 `cp-self-test-report`；使用者說「不用自測／不寫自測報告」時跳過，並在後續 MR 描述標記為不產出。
11. Commit：使用者明確要求時依「Commit 規則」分 repo commit；保留不相關變更，不自動加入。
12. 分支未 push：依 `affected-repos.md` 範圍在使用者明確要求時執行 push；網路受限時申請授權，不重複執行已成功的 push。
13. 要開 MR：依 `affected-repos.md` 範圍先使用 `cp-mr-description` 產生每個 repo 的 Markdown，再由使用者確認內容後使用 `cp-mr-submit` 實際建立 MR。
14. MR 建立完成後：若需要交付測試部門，依「測試場景用例」節產生 `end-version-report/test-scenarios/test-scenarios.html`，再用 `drawio-diagram` 產 `test-path` 測試路徑圖。
15. 發生 merge conflict：停止後續提交，使用 `cp-merge-conflict` 分析，等待使用者確認合併方案。

## 多 repo 任務規則

- 每個 repo 都是獨立 Git root，分別檢查 branch、status、commit、push 與 MR。
- 每個 repo 用同一個 `feature/{衝刺版號}_task-{任務編號}` 分支名稱，不要各 repo 取不同名字。
- 不把不同 repo 的變更混在同一次 commit 或 MR。
- 任務文件一律放在已確認的 `task_dir` 之下；預設格式可以是 `{task_root}/task-{編號}/...`，但 `task_root` 必須先確認。這裡的衝刺版號是禪道 Scrum sprint version，不是程式發版版本。
- MR 文件放在：`{task_dir}/end-version-report/mr-description/mr-description-{服務名}.md`。
- MR 建立設定（Assignee、Reviewer、merge options）一律依 `cp-mr-submit`，總控不另外規定。
- 已存在 MR 時不得重複建立；只回報現有 MR，除非使用者要求更新。

## 呼叫子 skill 時的路徑契約

總控呼叫任何會讀寫任務文件的子 skill 時，必須明確提供：

- `task_id`：任務編號，例如 `task-5987`。
- `sprint_version`：禪道衝刺版號，例如 `1_25_0`。
- `task_root`：已確認的任務文件根目錄，例如 `task-doc/1_25_0` 或其他使用者指定路徑。
- `task_dir`：完整任務資料夾，例如 `{task_root}/task-5987`。

呼叫 `drawio-diagram` 時另外傳：

- `output_dir`：`{task_dir}/project-doc/diagrams/`
- `prefix`：`task-{編號}`

子 skill 收到 `task_dir` 時，必須優先使用該路徑讀寫文件，不得自行退回舊路徑 `task-doc/task-{編號}` 或任何寫死的絕對路徑。若缺少 `task_dir`，先向使用者確認 `task_root`，再組出 `task_dir`。

## Commit 規則

優先使用全域 `commit` skill。若 runtime 未安裝，總控依以下同等規則執行，不阻塞流程：

- 每個 repo 各自 commit，不跨 repo 混合。
- 只 `git add` 本任務相關檔案；工作區中不相關的變更保留不動，並在回報中列出。
- 訊息用繁體中文 Conventional Commit：`{type}({scope}): {摘要}`，type 取 `feat` / `fix` / `refactor` / `test` / `docs` / `chore`；body 寫改動原因與任務編號 `task-{編號}`。
- commit 前確認測試狀態：沒實際跑過的測試不在訊息中寫成已通過。
- 完成後把 commit hash 寫回 `workflow-state.md`，`affected-repos.md` 狀態改為 `committed`。

## 外部操作確認

以下動作會改變外部狀態，只有使用者明確要求時執行：

- `git commit`
- `git push`
- 建立或切換分支
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
