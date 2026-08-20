# CP 任務模板與前置文件 HTML 流程交接紀錄 - 2026-08-20

## 本次處理目標

修正 2026-08-13 流程改版後，任務模板與下游 skills 仍使用舊版 Markdown 空殼文件的問題，讓 repo source、流程文件與實際 runtime skill 一致。

## 已完成 commit

本次流程與模板修正已提交：

```text
be9a4d2 docs: 統一任務前置文件與流程規則
```

本交接紀錄會另行提交。

## 最終文件規則

開發前文件改為以下四份 HTML，均由 `cp-backend-workflow` 在對應階段產出，任務資料夾建立時不初始化空殼檔：

```text
project-doc/task-estimation.html
project-doc/pre-dev-brief.html
project-doc/business-brief.html
project-doc/release-assessment.html
```

- simple 任務：`task-estimation.html`、`pre-dev-brief.html`。
- complex 任務：額外產出 `business-brief.html`。
- 涉及 DB / Redis / MQ / 排程 / 回調、正式資料修復、預發正式差異或需要明確上線／回滾計畫時：產出 `release-assessment.html`。
- `requirement-risk-test-brief` 已從流程移除，職責由 `pre-dev-brief.html` 承擔。

## 已完成改動

### 模板與流程文件

- `skills/cp-task-template/SKILL.md`：移除建立階段的舊 Markdown 空殼初始化規則，改為由 workflow 階段產出 HTML。
- `skills/cp-task-template/references/task-folder-template/README.md`：更新文件清單、分級規則與產出責任。
- `skills/cp-task-template/references/task-folder-template/handoff/workflow-state.md`：文件狀態表改為四份 HTML。
- `skills/cp-task-template/references/task-folder-template/handoff/requirement-changes.md`：需求變更影響清單改用新的 HTML 文件。
- 移除模板中的 `business-brief.md`、`release-assessment.md`、`requirement-risk-test-brief.md` 空殼檔。
- 移除 repo 根目錄重複的 `cp-task-folder-template/`，保留 `skills/cp-task-template/references/task-folder-template/` 作為唯一來源。

### 下游 skills

- `skills/cp-backend-dev-doc/SKILL.md`：輸入文件改讀 `pre-dev-brief.html`、`business-brief.html`、`release-assessment.html`。
- `skills/cp-task-dev/SKILL.md`：同步新的前置文件路徑與職責描述。
- `skills/cp-self-test-report/SKILL.md`：同步讀取 `pre-dev-brief.html`、`release-assessment.html`。

### 流程與說明文件

- `skills/cp-backend-workflow/SKILL.md`：清除舊流程語意，明確定義四份 HTML 的產出、更新與 QA 輸入規則。
- `cp-backend-work-flow.md`：同步上線評估與 QA 前置文件名稱。
- `README.md`：更新目錄、資料夾結構、流程圖、分級規則、跨 session 讀取清單與 skill 對照表。

## Runtime 同步狀態

以下五個 source skill 已與 `~/.claude/skills/` 實體 copy 以 `diff -qr` 驗證一致：

```text
cp-task-template
cp-backend-workflow
cp-backend-dev-doc
cp-task-dev
cp-self-test-report
```

注意：這些是實體 copy，不是 symlink；後續修改 source 後仍需重新同步 runtime。

## 驗證結果

已執行並通過：

```text
git diff --check
diff -qr source-skill ~/.claude/skills/source-skill
```

本次只有 Markdown、流程定義與模板異動，沒有可執行程式或單元測試需要執行。

另外掃描 active 文件後，未發現舊版 `.md` 路徑或舊流程語意殘留；README 與模板保留「`requirement-risk-test-brief` 已移除」的說明，作為遷移提示。

## 尚未處理／後續注意事項

1. `task-6060` 等既有任務資料夾不會被本次模板修正自動遷移；若要補文件，應依當時需求重新產出對應 HTML，不要直接建立舊版空殼 `.md`。
2. `1_25_0` 尚未上線；本次不涉及實作程式、版本發布或任何服務部署。
3. 後續若新增或調整前置文件規則，應同步檢查 source、`~/.claude/skills/` 及 README／流程定義，避免再次分岔。
