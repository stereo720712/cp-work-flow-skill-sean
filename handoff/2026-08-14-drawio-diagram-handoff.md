# drawio-diagram skill handoff - 2026-08-14

## 本次處理目標

為 CP 後端 workflow 補上流程圖產出能力。原本整條流程從需求釐清到 MR 只有文字與表格產物，唯一的圖是 `backend-dev-doc-template.md` 裡的一段 mermaid。實際需求是把圖貼到 **Confluence**，而 mermaid 在 Confluence 不一定渲染得出來，也不能在頁面上直接改。

## 已完成改動

### 1. 新增 `skills/drawio-diagram/`（通用 skill）

```text
skills/drawio-diagram/
├── SKILL.md                              211 行
└── references/diagram-template.drawio    183 行，雙頁範例
```

支援五種圖：`business-flow`、`state-machine`、`data-flow`、`architecture`、`test-path`。

產出未壓縮 `.drawio` XML，本機有 draw.io desktop 時另產 PNG。

### 2. 接進 workflow 的四個階段

| 階段 | 觸發條件 | 產出 | 歸屬文件 |
|---|---|---|---|
| 3 需求釐清後 | 所有任務 | `business-flow` | `pre-dev-brief.html` |
| 5 會議前置文件 | 涉及訂單／工單／審核等狀態機 | `state-machine` | `business-brief.html` |
| 6 後端設計後 | complex，由 mermaid 轉出 | `data-flow` + `architecture` | `backend-dev-doc.md` |
| 11 QA 測試矩陣後 | 需交付 QA 時 | `test-path` | `qa-test-matrix.md` |

產出位置固定：`{task_dir}/project-doc/diagrams/task-{編號}-{kind}.drawio`

### 3. 修改的既有檔案

- `skills/cp-backend-workflow/SKILL.md`：mermaid 圖加 FD1 / FD3 / FD3A / FD2 / FD4 節點與需求變更回流、子 skill 對照表加「流程圖」列、產物清單加 `diagrams/`、需求變更影響判斷加 5 條、階段判斷第 3 / 5 / 11 步、分級後產物、路徑契約加 `output_dir` / `prefix`
- `skills/cp-backend-dev-doc/SKILL.md`：Step 5 與 Step 6 之間插入 Step 5.5 產流程圖
- `cp-backend-work-flow.md`：同步以上全部

### 4. 新增分支命名規則

同一個開發者常同時跑多個任務，原本 workflow 完全沒有分支命名約定，`affected-repos.md` 的 source branch 欄是空的。本次訂為：

```text
feature/{衝刺版號}_task-{任務編號}
```

例如 `feature/1_25_0_task-5987`。衝刺版號是禪道 Scrum sprint version，不是程式發版版本；修 bug 類任務可用 `fix/` 取代 `feature/`。

- 多 repo 任務的每個 repo 用**同一個分支名稱**，方便對照與開 MR。
- 「階段判斷」新增第 6 步：進 coding 前逐 repo 比對目前分支，不符格式或還在 `master` 上就提醒使用者並給建議名稱（原第 6 步之後全部順延一號）。
- 缺衝刺版號時先問使用者，不自己編版號。
- **開分支、切分支歸類為外部操作**，比照 commit / push / MR，需使用者明確要求才執行；總控預設只提醒與提供指令，不自行 `git checkout -b`。
- 確認後寫回 `affected-repos.md` 的 source branch 欄，尚未開分支時照樣先填預期名稱並在備註標 `未建立`。

## 本次的關鍵決策與理由

### 為什麼是獨立 skill 而不是寫進總控

`cp-backend-workflow/SKILL.md` 已 469 行，是全 repo 最大的檔案，每次進 workflow 都整份載入。畫圖規格（座標公式 + 樣式表 + XML 範例）是純執行細節，塞進去等於只想 commit 也要吃這 100+ 行。總控的職責是調度，不是執行細節。

獨立 skill 另外讓使用者能隨手 `/drawio-diagram 畫這個流程`，不必跑整條 workflow。

### 為什麼命名不加 `cp-` 前綴

畫圖不綁 CP、不綁後端。與 `grill-me`、`karpathy-guidelines` 同屬通用 skill。ROADMAP Phase 2 抽 workflow core 時可直接搬，不用改名。

### PNG 策略：預設兩份都產

本機 `/Applications/draw.io.app` 已安裝，CLI 可用：

```bash
draw.io -x -f png -e -s 2 -b 10 -o flow.png flow.drawio
```

關鍵是 `-e` `--embed-diagram`：**把整份 diagram XML 內嵌進 PNG**。貼進 Confluence 的是普通 PNG（任何 Confluence 都吃），但把那張 PNG 拖回 draw.io 仍可繼續編輯。一個檔案同時是「能貼的圖」與「能改的原始檔」。

CLI 偵測順序（不寫死單一路徑）：

```bash
DRAWIO_BIN="$(command -v drawio || true)"
[ -n "$DRAWIO_BIN" ] || DRAWIO_BIN="/Applications/draw.io.app/Contents/MacOS/draw.io"
```

**偵測結果要在開始畫圖前就告知使用者**，不是等匯出失敗才講。偵測不到就只產 `.drawio`，附上 app.diagrams.net 的自行轉檔步驟，不中斷流程。

### mermaid 沒有被取代，是分工

| 用途 | 工具 |
|---|---|
| skill 自己的說明圖（讀者是 Claude 與看 repo 的人） | **mermaid，維持原樣不動** |
| 任務交付物、要貼 Confluence 給人看的圖 | **drawio** |
| 開發文件內的業務流程（重疊區） | **mermaid 當來源，drawio 當產物** |

重疊區訂**單向來源**規則：`backend-dev-doc.md` 裡的 mermaid 是唯一的「作者版本」，`.drawio` 由它轉出。要改流程只改 mermaid 再重產，不反向手改 drawio 再回填。兩個檔案，但只有一份要動腦的地方。

需求變更影響判斷已補上：開發文件內的 mermaid 與對應 drawio 一律同時標 `needs_update`。

## 實作中發現、已寫進 SKILL.md 的兩條規則

這兩條是實際畫出圖、看了渲染結果才發現的，不是設計時想到的：

1. **架構圖層背景框必須加 `align=left;spacingLeft=10;`**，否則層名會跑到框的右邊置中。
2. **架構圖的連線會直接穿過中間的方塊**（元件是絕對座標，自動繞線不避讓）。規則：相鄰層垂直連線加 `exitX=0.5;exitY=1;entryX=0.5;entryY=0;`；同層水平連線加 `exitX=1;exitY=0.5;entryX=0;entryY=0.5;`；跨 2 層以上要加 waypoint 從空白區繞過去。

泳道圖不需要這些 —— lane 是容器，draw.io 在容器間的繞線已經夠乾淨。

## 座標公式（生成的核心規則）

泳道圖：先給每個流程步驟一個**全域列號 row**，再決定它在哪個 lane。跨 lane 就是同時換 row 換欄，自然畫出對角流向。

| 元素 | parent | 座標 |
|---|---|---|
| pool | `1` | x=40, y=40, w=`260*laneCount`, h=`60 + 100*rowCount` |
| lane i | `pool` | x=`260*i`, y=0, w=260, h=**與 pool 相同** |
| 節點（row 列, lane i） | `lane{i}` | x=30, y=`60 + 100*row`, w=200, h=60（菱形 h=80、y 再 -10） |
| 邊 | `pool` | 只寫 `edgeStyle=orthogonalEdgeStyle`，不指定 exit/entry |

節點座標是**相對於 lane**，不是絕對座標。lane 高度務必與 pool 一致。

架構圖：層背景框 y=`40 + 160*L`、w=920、h=120；層內第 i 個元件 x=`60 + 220*i`、y=`層y + 50`、w=180、h=60。背景框先寫、元件後寫（z-order 依文件順序）。

## 驗證結果

| 項目 | 結果 |
|---|---|
| XML well-formed | 通過，2 pages |
| PNG 匯出（兩頁） | 通過，223KB / 144KB |
| `-e` 內嵌 XML | 通過，`zTXt` chunk `mxGraphModel` 1857 bytes |
| 視覺渲染 | 兩頁都人工看過，泳道分欄正確、節點在對的 lane、連線不穿方塊 |
| `scripts/validate-skills.sh` | 通過，未帶進新 warning |
| 兩份文件 mermaid 一致性 | `diff` 完全相同 |

驗證指令：

```bash
python3 -c "import xml.etree.ElementTree as ET; ET.parse('skills/drawio-diagram/references/diagram-template.drawio'); print('ok')"
/Applications/draw.io.app/Contents/MacOS/draw.io -x -f png -e -s 2 -b 10 -o /tmp/t.png skills/drawio-diagram/references/diagram-template.drawio
scripts/validate-skills.sh
diff <(sed -n '/```mermaid/,/```/p' skills/cp-backend-workflow/SKILL.md) <(sed -n '/```mermaid/,/```/p' cp-backend-work-flow.md)
```

## 尚未驗證

- **端到端跑 `/drawio-diagram`**：skill 尚未同步到 runtime，沒有實際以 skill 身分被觸發過一次。
- **Confluence 實貼**：不確定公司 Confluence 有沒有裝 draw.io app。有裝可 import `.drawio`，沒裝就貼 PNG。這步結果會決定要不要再調樣式或尺寸。

## 後續建議

1. 執行 `scripts/install-claude.sh`（需要 Codex 就再跑 `install-codex.sh`）讓 runtime 吃到新 skill。
2. 拿一個真實 CP 任務跑一次，確認 `output_dir` / `prefix` 的傳遞在實際呼叫中順不順。
3. 實貼一次 Confluence，回頭調樣式。
4. 節點文字過長時固定 100px 行距會擠 —— 這是刻意的簡單佈局（`SKILL.md` 有標 ponytail 註記），先看實際使用頻率再決定要不要處理。
5. 既有 warning 未處理：`cp-merge-conflict` 的 description 含角括號，`--strict-codex` 過不了。與本次無關。

## 本次同時 commit 的遺留檔案

`handoff/2026-08-13-cp-workflow-predev-estimation-handoff.md` 是上一個 session 留下、當時未 commit 的交接紀錄，本次一併納入。
