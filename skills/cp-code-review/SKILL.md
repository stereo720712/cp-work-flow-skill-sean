---
name: cp-code-review
description: >
  CP Code Review：當使用者說「幫我 review code」、「review 一下」、「我要提測了幫我看看」、「review 這個 MR」時，務必使用這個 skill。
  支援兩種情境：(1) 提測前自我 review 自己的 code diff；(2) review 別人提交的 GitLab MR。
  凡是提到「code review」、「review MR」、「review 我的 code」、「看一下改動」、「提測前確認」時，都應主動觸發此 skill。
---

# CP Code Review

## 概述

支援兩種 review 情境：

- **情境 A：自我 review**（提測前確認自己的 code）
- **情境 B：MR review**（review 別人的 merge request）

---

## Workflow 模式契約

若由 `cp-backend-workflow` 呼叫，且提供 `task_dir`：

1. 先讀取 `{task_dir}/project-doc/affected-repos.md`，以此作為 self-review 的 repo 範圍。
2. 只 review 狀態不是 `not_required`、`blocked` 的 repo；`needs_confirm` 必須先詢問使用者或由 codebase 探索確認後才 review。
3. 每個 repo 依各自的 `路徑`、`source branch`、`target branch` 分別取得 diff，不把多個 repo 混在同一段 review。
4. review 完成後，按 repo 回報 blocking / non-blocking / OK，並標示哪些 repo 跳過或仍需確認。

若沒有 `{task_dir}/project-doc/affected-repos.md`：

1. 先提醒使用者 workflow inventory 缺失，建議補齊 `affected-repos.md` 後再續跑正式 workflow。
2. 若使用者只是要 review 目前 repo，可依使用者指定 repo、目前所在 git repo、branch 名稱與 diff 範圍推測單一 repo 後 review。
3. 這種 fallback review 不更新 `workflow-state.md` 或 `affected-repos.md`，回報時必須說明「未找到 affected-repos.md，本次只 review 推測出的 repo，未更新 workflow 狀態」。
4. 若可能涉及多 repo 或推測不唯一，先詢問使用者要 review 哪些 repo，或要求先補齊 `affected-repos.md`。

## 情境 A：自我 Review（提測前）

### 使用時機
使用者說「幫我 review 我的 code」、「我要提測了看一下」，且沒有提供 MR 連結或編號。

### 執行步驟

#### Step 1：確認 repo 路徑與目標分支

若是 workflow 模式，優先使用 `{task_dir}/project-doc/affected-repos.md` 中狀態可 review 的 repo 清單；沒有該檔案時，先提醒補齊 inventory，只有在使用者接受 fallback review 時才用目前 repo / 使用者指定路徑 / git diff 推測。

```bash
cd {repo 路徑} && git rev-parse --show-toplevel
git branch --show-current
git log --oneline origin/master..HEAD
```

若使用者沒有指定路徑，詢問目前在哪個 service repo 下工作。

預設對比基準為 `origin/master`，若 repo 預設主分支不同（如 `main`、`develop`），依實際情況調整。

#### Step 2：取得 diff

```bash
git diff origin/master...HEAD
```

若 diff 太大，先用以下指令了解改動範圍：

```bash
git diff origin/master...HEAD --stat
```

再針對重點檔案逐一讀取。

多 repo 任務要逐 repo 執行上述 diff，不要把不同 repo 的 diff 合併成一次 review。

#### Step 3：執行 Review

依照以下面向逐一審查，重點放在高風險問題：

**必查面向（高風險）：**
- 潛在 bug / 邏輯錯誤：null handling、邊界條件、狀態流轉、漏判分支
- 併發 / 一致性風險：race condition、重複扣款、重複入帳、rollback 失效
- 安全性：userId 是否來自 Token、金額是否用 BigDecimal、敏感資料是否洩漏
- Regression 風險：舊流程是否被改壞、既有 API 相容性

**一般面向：**
- 架構邊界：Open 不直接呼叫 Base、BLL 不直接用 Mapper
- 錯誤處理：是否有吞錯的 catch、log 是否足夠
- DB / Redis：是否有 N+1、Redis key 是否用封裝方法
- 可維護性：命名、職責切分

**跳過：**
- 純格式、縮排問題（linter 會處理）
- 前人留下的既有問題（非本次改動）
- 過度挑剔的 nitpick

#### Step 4：輸出 Review 結果

```
## Code Review 結果

**分支**：{分支名}
**改動範圍**：{幾個檔案，主要在哪些服務}

---

🔴 **必須修改（blocking）**

1. {問題描述}
   - 位置：{檔案}:{行號}
   - 問題：{說明為什麼危險、可能造成什麼風險}
   - 建議：{修改方式}

---

🟡 **建議修改（non-blocking）**

1. {問題描述}
   - 位置：{檔案}:{行號}
   - 建議：{修改方式}

---

🟢 **看起來 OK**

- {說明哪些地方設計正確、沒有問題}
```

若沒有任何問題：直接說明 code 看起來 OK，可以提測。

---

## 情境 B：MR Review

### 使用時機
使用者提供 GitLab MR 連結（`https://gitlab.zanatest.com/.../-/merge_requests/{id}`）或 MR 編號。

### 執行步驟

#### Step 1：取得 MR 資訊

從使用者訊息中取得 MR id 或 URL。

若使用者在某個 service repo 目錄下，直接使用 glab：

```bash
# 查看 MR 基本資訊
glab mr view {MR_ID}

# 取得 diff
glab mr diff {MR_ID}
```

若需要切換到正確的 repo，詢問使用者 MR 屬於哪個 service。

#### Step 2：了解 MR 背景

讀取 MR 標題、描述，了解：
- 這個 MR 要解決什麼問題
- 影響哪些服務 / 功能

若有任務編號（CP-XXXX），可讀取對應的開發文件：
```
task-doc/{衝刺版號}/task-{編號}/project-doc/task-{編號}-backend-dev-doc.md
```

#### Step 3：執行 Review

與情境 A 相同的 review 面向，但額外注意：
- MR 描述與實際改動是否一致
- 是否有多餘的改動（與任務無關的修改）
- 是否有遺漏的改動（任務描述提到但 code 沒有做的）

#### Step 4：輸出 Review 結果

格式與情境 A 相同，標題改為：

```
## MR Review 結果

**MR**：{MR 標題}（#{MR_ID}）
**作者**：{作者}
**改動範圍**：{幾個檔案，主要在哪些服務}
```

---

## 共通原則

- **以資深後端工程師角度 review**：重點是線上風險、業務一致性，不是格式
- **blocking 問題一定要說清楚**：是什麼、為什麼危險、怎麼修
- **non-blocking 要說明為何只是建議**
- **不確定的地方標示「需確認」**，不要腦補不存在的前提
- **若 diff 資訊不足**，主動讀取相關 code 補充背景再 review
- **workflow 範圍優先**：有 `affected-repos.md` 時以它為準；沒有時先要求補 inventory。若只做當前 repo fallback review，必須明確說明未更新 workflow 狀態

---

## 系統架構參考

- `/Users/jixiangwang/Documents/pte-work/gitlab/cp-v2/cp-backend/java-service/AGENTS.md`
- `/Users/jixiangwang/Documents/pte-work/gitlab/cp-v2/cp-backend/java-service/backend-agent-skill/agent-rules/code-review.md`
