---
name: cp-task-dev
description: >
  CP 任務 TDD 開發流程：當使用者要開始實作 CP／禪道後端任務、需要釐清需求、設計測試案例、以 TDD 方式 coding，或需要留下可供跨 Agent／Session 接手的開發紀錄時使用。協助需求分析、測試先行、實作進度與測試結果紀錄；不取代 cp-backend-workflow，也不自行 commit、push 或建立 MR。
---

# CP 任務 TDD 開發流程

協助 `cp-backend-dev-doc` 完成後的實作階段，讓需求、測試與開發進度可被持續追蹤。實際程式修改可以由 Agent 協助完成，也可以由使用者人工完成；兩者都必須同步記錄到任務資料夾。

## 使用時機

- 已有 `task_dir`，且後端開發文件已完成或需求足以開始實作。
- 需求仍有模糊處時，先釐清範圍、驗收條件、例外行為與不做事項；必要時搭配 `grill-me`。
- 使用者要求 TDD、先寫測試、補測試案例，或需要交接開發進度時。

## 固定輸出

在 `task_dir` 下維護三份文件：

- `project-doc/requirement-analysis.md`：開發前的需求分析、驗收條件、範圍與風險。
- `test-file-script/tdd-test-plan.md`：測試案例、預期失敗結果、測試命令與完成狀態。
- `handoff/dev-progress.md`：每次實作／測試後的進度、變更檔案、結果、阻塞與下一步。

若任務資料夾中已有以下文件，必須先讀取並作為實作前輸入：

- `project-doc/business-brief.md`：大任務的業務流程與角色影響。
- `project-doc/requirement-risk-test-brief.md`：PM / 後端 / 前端 / QA 會議確認過的改動、風險與測試說明。
- `project-doc/release-assessment.md`：預發 / 正式上線評估，尤其 DB / Redis 共用資源影響。

使用 `references/` 下的同名模板建立文件；若文件已存在，保留既有內容，在原文件上追加版本與進度，不覆蓋歷史紀錄。

## 工作流程

1. **確認上下文**：讀取 `workflow-state.md`、`requirement-changes.md`、`affected-repos.md`、業務 / 風險 / 測試說明、上線評估與後端開發文件，確認 `task_id`、`sprint_version`、`task_dir` 及各 repo。
2. **需求分析**：將需求拆成可驗收條件，列出 API、DB、權限、錯誤處理、相容性與不在範圍內的項目。資訊不足時先詢問，不用猜測關鍵行為。
3. **建立 TDD 計畫**：依受影響 repo、業務場景、風險與測試說明安排測試，至少涵蓋主要成功流程、輸入／權限／資料異常、DB / Redis 影響與回歸風險。標記每個案例的 Red、Green、Refactor 狀態。
4. **Red**：先新增或調整測試，執行指定測試命令，確認測試因缺少行為而失敗；若無法執行，記錄原因與替代驗證方式。
5. **Green**：以最小實作使測試通過，避免順手擴大範圍；每個循環記錄變更檔案與測試結果。
6. **Refactor**：在測試通過後整理實作，重新執行受影響測試與必要的回歸測試。
7. **更新交接狀態**：更新 `dev-progress.md`，並同步 `workflow-state.md` 中的文件狀態、repo coding 狀態與最近進度。需求變更交由 `cp-backend-workflow` 追加 R 版本並判斷返工範圍。
8. **交給後續階段**：完成 coding 後，不自動 commit、push 或開 MR；依使用者要求交給 `cp-code-review`、`commit`、`cp-self-test-report` 等 skill。

## 邊界與規則

- 不把 TDD 計畫當成 SDD 規格；本 skill 只建立足夠支援實作與驗證的需求分析和測試紀錄。
- 不將未執行的測試標記為通過，不把預計修改誤記為已完成。
- 不覆蓋使用者未完成的 code 或既有交接紀錄；先讀取，再以追加方式更新。
- 外部狀態操作遵循總控規則：`git commit`、`git push`、建立或修改 MR 都需要使用者明確要求。

## 參考模板

- `references/requirement-analysis-template.md`
- `references/tdd-test-plan-template.md`
- `references/dev-progress-template.md`
