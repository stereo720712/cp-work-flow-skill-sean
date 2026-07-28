---
name: cp-mr-submit
description: >
  CP GitLab MR 提交流程：當使用者要求提交、建立、開啟或送出 MR，且已有分支與 MR 描述時使用。透過 Chrome GitLab 頁面逐一建立多 repo MR，填入指定 Markdown、設定 Assignee、Merge options，並回報 MR 網址。
---

# CP GitLab MR 提交流程

用於在 `cp-mr-description` 產生描述後，實際於 GitLab 建立 Merge Request。這個 skill 會產生外部狀態變更；使用者明確要求提交 MR 時可執行，否則建立前先確認。

## 執行前確認

1. 取得任務編號、要提交的 repo、來源分支與目標分支（預設 `feature/task-{編號}` → `master`）。
2. 確認每個 repo 的分支已 push，並讀取對應文件：
   `task-doc/{衝刺版號}/task-{編號}/end-version-report/mr-description/mr-description-{服務名}.md`。
3. 若描述文件不存在，先使用 `cp-mr-description` 產生；不要自行捏造 MR 內容。
4. 先檢查 GitLab 是否已存在同一 source branch 的開啟 MR，避免重複建立。

## GitLab 操作

使用 Chrome 控制 GitLab，逐一操作每個 repo：

1. 開啟該 repo 的 New merge request 頁面，確認 `From` 是來源分支、`into` 是 `master`。
2. Title 使用 commit／描述對應的標題，例如 `chore: 移除 Seata 明確版本設定`。
3. 將對應 Markdown 完整填入 Description。
4. Assignee 設為 `austin`。
5. Reviewer 保持未設定。不要把 Assignee 或 Reviewer 當成 Approver；若使用者另行要求 Approval Rule，需另外檢查專案權限與規則入口。
6. Merge options：取消 `Delete source branch when merge request is accepted.`，勾選 `Squash commits when merge request is accepted.`。
7. 建立 MR 後，驗證頁面顯示正確 repo、source／target branch、Assignee 與描述內容；記錄 MR 編號與網址。

每次點擊、填寫或提交前，都依 Chrome skill 的 snapshot、唯一 locator、操作後驗證流程執行。若頁面找不到 Assignee、分支、欄位或權限不足，停止該 repo 並回報，不要用 Reviewer 替代。

## 多 repo 提交

多個 repo 必須分別建立 MR、分別驗證；不要把不同 repo 的描述合併成一個 MR。已建立的 MR 不要重複提交，除非使用者明確要求更新既有 MR。

## 網址輸出格式

完成後使用以下格式，不加列表符號，不加額外 GitLab URL 說明：

```markdown
## task-{編號}
### {服務名稱}
{MR URL}
```

多個 repo 依序追加 `### {服務名稱}` 與網址，例如：

```markdown
## task-5987
### otc-website-bll
https://gitlab.zanatest.com/up/v2/services/java-services/bll/otc-website-bll/-/merge_requests/354
### otc-wallet-bll
https://gitlab.zanatest.com/up/v2/services/java-services/bll/otc-wallet-bll/-/merge_requests/124
```

## 失敗與回報

- 已建立部分 repo 時，列出成功 MR URL 與失敗 repo 的具體原因。
- 不要因網路、登入、權限或 Approver 設定失敗而重複建立 MR。
- 若使用者要求的是「批准」而非建立 MR，不能代替其他帳號執行 Approve；只能在權限允許時設定 Approval Rule 或回報需人工處理。
