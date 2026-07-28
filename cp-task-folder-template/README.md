# CP 任務資料夾模板（cp-task-folder-template）

每接一個 CP 後端任務，複製這份結構當 `task-doc/{衝刺版號}/task-{編號}/` 的骨架。
這裡的 `{衝刺版號}` 是禪道 Scrum sprint version，例如 `1_25_0`，
把開發過程產生的文件（需求、開發文件、測試、agent 交接、工具）分類歸位，
避免散落。每個子資料夾都有一份 `*-define.md` 說明用途。

## 資料夾用途

| 資料夾 | 放什麼 | 子資料夾 |
|---|---|---|
| `project-doc/` | 項目需求文件 / 材料、需求分析、affected repo inventory，主要供禪道報告貼上或 Confluence 用 | 可按屬性分 |
| `test-file-script/` | 測試相關文件、TDD 測試計畫 | 可按業務項目分 |
| `tool/` | 任務要用的工具程式 / script | — |
| `handoff/` | agent session 交接文件、workflow state、需求變更紀錄 | 每個 agent 可建自己的子資料夾 |
| `end-version-report/` | **已定案**的最終文件 | — |
| `other/` | 沒歸類、暫時不知道放哪的 | — |

## 文件生命週期

```
開發中：文件散在 project-doc / test-file-script / tool / handoff（隨時改）
   │
   ▼  定案
end-version-report/：定案後才移進來；一旦要再改，先移出去
```

- **進行中** 的文件放各功能資料夾，可隨意改。
- **定案** 後才收進 `end-version-report/`；要再修改就先移出，改完再放回——保持這裡永遠是「最終版」。
- 不確定歸類的先丟 `other/`，之後再歸位。

## 使用方式

```bash
cp -r work-flow-skill-sean/cp-task-folder-template \
      task-doc/{衝刺版號}/task-{編號}
```

各 `*-define.md` 是給人 / agent 看的用途說明，複製後可留著；實際文件直接放對應資料夾。

## Workflow state

任務資料夾建立後固定維護：

- `handoff/workflow-state.md`：目前流程狀態、repo 進度、文件產物、MR URL。
- `handoff/requirement-changes.md`：需求變更版本與返工判斷。
- `project-doc/affected-repos.md`：本任務受影響 repo 清單，後續 review / commit / push / MR 都以它為準。

下次由 `/cp-backend-workflow` 繼續任務時，先讀這兩份文件再判斷下一步。

`cp-task-dev` 開發階段固定使用：

- `project-doc/requirement-analysis.md`：開發前需求分析與驗收條件。
- `test-file-script/tdd-test-plan.md`：Red / Green / Refactor 測試案例與結果。
- `handoff/dev-progress.md`：開發進度、變更檔案、阻塞與接手資訊。
