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
