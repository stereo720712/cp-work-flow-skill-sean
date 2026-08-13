# CP workflow generalization session handoff - 2026-08-13

## 本次處理目標

本次 session 主要處理三件事：

1. 檢視並導入 `andrej-karpathy-skills` 的行為準則。
2. 將 Karpathy 原則融合進 CP 後端工作流，不只是新增孤立 skill。
3. 修正 CP workflow 中仍寫死的決策點，特別是任務文件根目錄 / `task_dir`，並開始為未來抽象成通用軟體開發流程做準備。

## 已完成改動

### 1. 新增 karpathy-guidelines skill source

新增：

- `skills/karpathy-guidelines/SKILL.md`

內容來自 `https://github.com/stereo720712/andrej-karpathy-skills` 的 `skills/karpathy-guidelines/SKILL.md`，保留 MIT metadata 與四個核心原則：

- Think Before Coding
- Simplicity First
- Surgical Changes
- Goal-Driven Execution

這個 skill 在本 repo 中定位為「品質閘門」，不是獨立業務階段。

### 2. Karpathy 原則融合進 CP workflow

已將 Karpathy 原則寫入以下 CP workflow 階段：

- `skills/cp-backend-workflow/SKILL.md`
  - 新增 Karpathy Guidelines 導入點。
  - 將其定義為整個 workflow 的品質閘門。
  - 套用到需求釐清、後端設計、TDD 實作、review。

- `skills/cp-task-dev/SKILL.md`
  - 新增「Karpathy 實作前檢查」。
  - 要求先寫清楚假設、歧義、最小實作範圍、不做事項與驗證標準。
  - Refactor 階段限制為只整理本次改動造成的重複或孤兒程式。

- `skills/cp-code-review/SKILL.md`
  - Review 增加 Karpathy 邊界檢查。
  - 檢查任務外功能、單次使用抽象、順手重構、格式化噪音，以及無法追溯到驗收條件 / TDD case 的改動。

同步更新 `cp-task-dev` 模板：

- `skills/cp-task-dev/references/requirement-analysis-template.md`
  - 新增 Karpathy 實作前檢查：已確認結論、仍是假設的內容、歧義與待決策、最小實作範圍。

- `skills/cp-task-dev/references/tdd-test-plan-template.md`
  - 新增可驗證目標表。
  - 測試案例增加目標 ID 對應。

- `skills/cp-task-dev/references/dev-progress-template.md`
  - 新增改動邊界。
  - 新增是否有範圍外改動。

### 3. 補上 root workflow 文件

新增並重寫：

- `cp-backend-work-flow.md`

這份文件從舊的線性流程：

```text
寫禪道需求 -> 開發文件 -> coding -> 測試 -> 自測報告 -> 提測 -> 結案
```

改成目前 CP workflow：

```text
cp-task-template
-> Repo inventory
-> simple / complex 分級
-> grill-me 需求釐清
-> 會議前置文件
-> cp-backend-dev-doc
-> cp-task-dev TDD
-> cp-code-review / cp-self-test-report
-> commit / push
-> cp-mr-description
-> cp-mr-submit
-> QA 測試矩陣
-> cp-merge-conflict
```

也補上：

- 任務文件結構。
- 續跑規則。
- 每一步使用哪些 skill。
- 每一步可引用哪些輔助 skill。
- 輔助 skill 調用規則。
- Karpathy 品質閘門。

此檔案已經 `git add`。

### 4. 每個流程步驟的主 skill / 輔助 skill 對照

在以下兩處加入「主 skill / 可引用的輔助 skill / 觸發條件 / 主要產物」表格：

- `skills/cp-backend-workflow/SKILL.md`
- `cp-backend-work-flow.md`

設計原則：

- 每個階段先使用主 skill。
- 輔助 skill 只在觸發條件符合時引用。
- `karpathy-guidelines` 是品質閘門，不是獨立階段。
- `grill-me` 只負責逐題釐清決策，不直接改文件。
- `cp-task-dev` 的測試紀錄會成為 review、自測報告、MR 描述與 QA 測試矩陣的輸入。
- `cp-code-review` 的結果可以回饋到 `cp-task-dev` 修正，也可以作為 commit / MR 前的風險依據。
- `cp-backend-dev-doc` 完成後必須回饋 `affected-repos.md`。

### 5. 移除任務文件根目錄硬編碼

使用者指出：「模板根目錄創建」這類以前寫死的部分，應該先提問。

本次已將 workflow 改成：

- 啟動時收集 / 確認 `task_root` 與 `task_dir`。
- 若使用者未提供，先詢問要放哪裡。
- 預設路徑只能作建議，不可未確認就建立。
- 子 skill 收到 `task_dir` 後，必須只用該路徑。
- 不得自行退回舊路徑 `task-doc/task-{編號}` 或寫死的絕對路徑。

已同步修改：

- `skills/cp-task-template/SKILL.md`
- `skills/cp-backend-workflow/SKILL.md`
- `skills/cp-backend-dev-doc/SKILL.md`
- `skills/cp-self-test-report/SKILL.md`
- `skills/cp-mr-description/SKILL.md`
- `skills/cp-mr-submit/SKILL.md`
- `skills/cp-code-review/SKILL.md`
- `skills/cp-task-template/references/backend-dev-doc-template.md`
- `skills/cp-task-template/references/task-folder-template/README.md`
- `skills/cp-mr-description/references/mr-description-template.md`
- `README.md`
- `cp-backend-work-flow.md`

目前仍保留的舊絕對路徑只作 fallback 建議，文字已明確要求必須先確認，不可直接使用。

## 重要設計決策

### 1. CP workflow 正在變成 workflow engine 雛形

目前 CP workflow 已經不只是「一串固定步驟」，而是有以下通用 workflow 概念：

- `task_root`
- `task_dir`
- `workflow-state.md`
- `requirement-changes.md`
- `affected-repos.md`
- `requirement-analysis.md`
- `tdd-test-plan.md`
- `dev-progress.md`
- review 結果
- self-test / verification report
- MR / release handoff
- external action confirmation

這些概念可以作為未來通用軟體開發流程的核心。

### 2. CP 專屬內容應下沉到 adapter

未來如果要抽成通用流程，不應讓 core workflow 知道：

- CP
- 禪道
- 禪道 HTML 模板
- Java service 目錄
- CP 分層規範
- GitLab MR 預設 assignee
- 主管自測報告模板

這些都應該留在 CP backend adapter / project-specific skills。

### 3. 通用 core 只定義流程語言

未來的通用 core 可以只定義：

- 任務資料夾生命週期
- 狀態值
- 需求變更版本
- 影響範圍 inventory
- 驗證計畫
- 開發進度
- review handoff
- release handoff
- 外部操作確認邊界

## 未來抽象方向

建議拆成以下層次：

```text
software-workflow-core/
  skills/
    workflow-orchestrator
    task-folder
    requirement-analysis
    impact-inventory
    tdd-dev
    code-review
    test-report
    release-handoff
    change-management

backend-workflow-cp/
  skills/
    cp-backend-workflow
    cp-task-template
    cp-backend-dev-doc
    cp-self-test-report
    cp-mr-description
    cp-mr-submit

frontend-workflow/
  skills/
    frontend-task-template
    frontend-dev-workflow
    frontend-ui-review
    frontend-e2e-test-report

app-workflow/
  skills/
    app-release-workflow
    app-platform-impact
    app-store-release-checklist
    mobile-regression-test

embedded-workflow/
  skills/
    firmware-task-workflow
    hardware-interface-impact
    integration-test-plan
    flashing-release-checklist
```

核心層不要知道具體技術棧；各專案用 adapter 提供：

- 任務模板
- codebase 探索方式
- impact inventory 欄位
- 測試報告格式
- review 規則
- release / MR / store / flashing 等外部交付方式

## 建議下一步

1. 補一份 `workflow-core-concepts.md`。
   - 列出哪些是通用 workflow core。
   - 哪些是 CP backend adapter。
   - 哪些是 Java backend 特化規則。

2. 將 `task_root` / `task_dir` 決策點推廣到所有新 workflow。
   - 不允許新 skill 寫死根目錄。
   - 所有讀寫型子 skill 都必須接收 `task_dir`。

3. 把 `cp-backend-workflow` 逐步拆出可重用段落。
   - 狀態機。
   - 需求變更。
   - inventory。
   - TDD / review / release handoff。

4. 用一個真實 CP 任務跑一次新流程。
   - 驗證 task_root 提問是否順。
   - 驗證輔助 skill 對照是否能讓總控正確引用。
   - 驗證 Karpathy 品質閘門是否太重或剛好。

## 本次 Git 狀態注意

使用者已明確要求「git add .」。執行前狀態中包含：

- 已 staged：`cp-backend-work-flow.md`
- 未 staged：本次 workflow / skill / README 修改
- untracked：`skills/karpathy-guidelines/`

## 2026-08-13 後續補充：測試報告與長線抽象方向

本 session 後續又補強了自測報告與 workflow 的測試視角，重點不是只產後端 API 自測，而是要覆蓋 Web 系統的實際業務驗證。

### 已補進 skill 的測試規則

已更新：

- `skills/cp-self-test-report/SKILL.md`
- `skills/cp-self-test-report/references/self-test-report-template.html`
- `skills/cp-backend-workflow/SKILL.md`

並已同步到 runtime 實際載入的：

- `/Users/jixiangwang/.codex/skills/cp-self-test-report/`
- `/Users/jixiangwang/.codex/skills/cp-backend-workflow/`

新增測試視角：

1. 後端特有驗證
   - API input / output。
   - 權限、角色、資料範圍。
   - 狀態流轉、錯誤碼、異常分支。
   - DB / Redis / MQ / cache 副作用。
   - 交易、併發、冪等、重複提交。
   - 排程、回調、導出、補償腳本。

2. 前端 / 頁面操作驗證
   - 頁面入口、菜單與按鈕權限。
   - 操作步驟、表單欄位、loading / success / error。
   - 錯誤提示、列表刷新、狀態顯示、導出結果。
   - Agent 無法實測時，必須列為「需開發者自行測試 / 補截圖」，不能省略。

3. 前後端業務互動流程
   - Web 任務不能只測後端 API。
   - 核心流程要從角色 / 權限、前端入口、操作步驟，一路串到 request、後端 API / service、DB / Redis 變化、response、前端回顯 / 錯誤提示。
   - 多角色、多狀態、多流程分支要分別列主要流程與異常流程。
   - QA 測試矩陣也要整理這條端到端互動流程，並標出 QA / 開發者需補測與補截圖項目。

這個方向很重要：`cp-self-test-report` 目前名稱仍是「後端自測報告」，但對 Web 系統任務來說，報告內容應至少提醒或記錄前端互動與業務端到端驗證，不應讓開發者誤以為 API pass 就等於業務流程 pass。

### 長線交接任務

長線任務仍然是把目前 CP workflow 抽象成幾本可復用規則，以及針對不同系統規劃各自 adapter / 開發流程。

建議拆成幾本規則：

1. `workflow-core-rules`
   - task_dir / workflow-state / requirement-changes / affected-repos。
   - 階段狀態、續跑、變更返工、外部操作確認。
   - 不包含 CP、禪道、Java、GitLab 特化內容。

2. `verification-rules`
   - 後端驗證。
   - 前端 / 頁面操作驗證。
   - 前後端業務互動驗證。
   - 非 API 驗證：排程、MQ、回調、導出、補償腳本。
   - 無法由 Agent 實測時，如何生成「開發者 / QA 需補測」清單。

3. `change-impact-rules`
   - API / DB / Redis / MQ / 權限 / 狀態機 / 前後端互動變更如何標記 `needs_update`。
   - 哪些文件與階段要返工。
   - 哪些產物可以沿用。

4. `system-adapter-rules`
   - 不同系統只提供 adapter，不改 core。
   - adapter 定義任務模板、codebase 探索方式、測試報告格式、review 規則、release / MR 交付方式。

不同系統的流程規劃可以先切：

- CP backend / Java service workflow。
- Frontend Web workflow。
- Full-stack Web workflow。
- App / mobile workflow。
- Job / data / integration workflow。
- Embedded / firmware workflow。

其中 Full-stack Web workflow 應該優先整理，因為這次補充的「後端注意事項、前端注意事項、前後端業務互動測試流程」正是 Web 系統最容易漏測的部分。

本 handoff 建立後，應執行：

```bash
git add .
```

這是使用者自己的專案，使用者已明確要求加入全部改動。

## 接手順序

下一個 session 建議依序讀取：

1. 本文件。
2. `README.md`。
3. `cp-backend-work-flow.md`。
4. `skills/cp-backend-workflow/SKILL.md`。
5. `skills/cp-task-template/SKILL.md`。
6. `skills/cp-task-dev/SKILL.md`。
7. `skills/karpathy-guidelines/SKILL.md`。
