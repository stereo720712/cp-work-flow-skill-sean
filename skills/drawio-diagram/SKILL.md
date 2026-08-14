---
name: drawio-diagram
description: >
  draw.io 流程圖產生器：當使用者說「畫流程圖」、「產 drawio」、「畫個業務流程」、「畫資料流」、「畫架構圖」，
  或需要把流程圖貼進 Confluence、禪道、投影片時，務必使用這個 skill。
  產出未壓縮 .drawio XML，並在本機有 draw.io desktop 時自動轉出內嵌原始檔的 PNG。
  支援業務流程（泳道）、資料流程、架構圖、狀態流轉、測試路徑五種圖。
  凡是提到「流程圖」、「drawio」、「架構圖」、「資料流」、「泳道圖」、「畫圖貼 Confluence」時，都應主動觸發此 skill。
---

# draw.io 流程圖產生器

產出未壓縮的 `.drawio` XML，可直接用 draw.io 開啟編輯、貼進 Confluence，或匯出 PNG。

本 skill **只畫圖，不決定需求**。流程內容以呼叫端給的來源為準；來源與圖不一致時，以來源文字為準。

---

## Step 1：確認輸入與 PNG 能力

### 1.1 收集輸入

| 輸入 | 說明 | 缺少時 |
|---|---|---|
| `output_dir` | 圖要放哪個資料夾 | **問使用者**，不要寫死絕對路徑、不要自行退回舊路徑 |
| `prefix` | 檔名前綴 | 由 `cp-backend-workflow` 呼叫時是 `task-{編號}`；單獨呼叫時用使用者給的名稱，沒有就用 kind 當檔名 |
| kind | 圖的種類（見 Step 2） | 依使用者描述判斷，不確定就問 |
| 流程來源 | mermaid、條列步驟、開發文件或口述 | 直接問使用者要畫什麼 |

由 `cp-backend-workflow` 呼叫時，`output_dir` 固定為 `{task_dir}/project-doc/diagrams/`。

### 1.2 偵測 draw.io CLI，並先告知使用者

**在開始畫圖前就先偵測，把結果告訴使用者**，不要等到最後匯出失敗才講：

```bash
DRAWIO_BIN="$(command -v drawio || true)"
[ -n "$DRAWIO_BIN" ] || DRAWIO_BIN="/Applications/draw.io.app/Contents/MacOS/draw.io"
[ -x "$DRAWIO_BIN" ] && echo "found: $DRAWIO_BIN" || echo "not found"
```

- **偵測到**：告知「本機有 draw.io desktop，會同時產出 `.drawio` 與 PNG」，照 Step 5 匯出。
- **沒偵測到**：告知「本機沒有 draw.io desktop，只會產出 `.drawio`」，並附上自行轉檔的方式：

  > 要 PNG 的話，開 https://app.diagrams.net → File → Open From → Device 選這個 `.drawio` →
  > File → Export as → PNG，勾選 **Include a copy of my diagram**（這樣 PNG 之後還能拖回 draw.io 編輯）。
  > 或安裝 draw.io desktop（https://github.com/jgraph/drawio-desktop/releases）後重跑。

  **不要因為沒有 CLI 就中止流程**，`.drawio` 照樣要產出。

---

## Step 2：選圖種類與 lane

| kind | 用途 | lane 語意 | 典型 lane |
|---|---|---|---|
| `business-flow` | 給 PM / 主管看的業務流程 | 角色 | 用戶 / 前端 / 後端 / DB / 外部系統 |
| `data-flow` | 資料怎麼流過各層 | 技術層 | 前端 / API 層 / Service / Mapper·DB / Redis·MQ |
| `state-machine` | 訂單、工單狀態流轉 | 不分 lane（單欄） | — |
| `test-path` | QA 測試路徑 | 路徑類型 | 正常路徑 / 異常路徑 |
| `architecture` | 服務 / 元件關係 | 不用 lane，改分層方塊 | — |

檔名：`{output_dir}/{prefix}-{kind}.drawio`

lane 由呼叫端指定；沒指定就用上表典型值，並在回報時說明用了哪些 lane，讓使用者能改。

---

## Step 3：從 mermaid 轉入

若來源已經是 mermaid（例如後端開發文件裡的 `flowchart`），**照它的節點與邊生成，不要自己重新設計流程**。

節點形狀對照：

| mermaid | drawio 語意 |
|---|---|
| `A[文字]` | 一般動作 |
| `A{文字}` | 判斷 |
| `A((文字))`、`A([文字])` | 起訖點 |
| `A[(文字)]` | DB 讀寫 |
| `-->|標籤|` | 邊上的 value |

**單向來源規則**：mermaid 是作者版本，`.drawio` 是產物。之後要改流程，改 mermaid 再重產，不要反向手改 drawio 再回填 mermaid。

---

## Step 4：產生 XML

讀 `references/diagram-template.drawio` 當結構範例（page 1 泳道流程、page 2 架構圖）。

輸出必須是**未壓縮** XML：人看得懂、git diff 看得出改了什麼。不要輸出壓縮版。

### 泳道座標公式

**先給每個流程步驟一個全域列號 `row`**（第 1 步 row=0、第 2 步 row=1），再決定它在哪個 lane。跨 lane 就是同時換 row 換欄，自然畫出對角流向。同一 row 可以放不同 lane 的兩個節點（例如是／否兩個分支），不會重疊。

| 元素 | parent | 座標 |
|---|---|---|
| pool | `1` | x=40, y=40, width=`260*laneCount`, height=`60 + 100*rowCount` |
| lane i | `pool` | x=`260*i`, y=0, width=260, height=**與 pool 相同** |
| 節點（row 列，lane i） | `lane{i}` | x=30, y=`60 + 100*row`, width=200, height=60 |
| 菱形判斷節點 | `lane{i}` | 同上但 height=80、y 再減 10 |
| 邊 | `pool` | `edgeStyle=orthogonalEdgeStyle;rounded=0;html=1;`，**不指定 exitX/entryX**，讓 draw.io 自己繞線 |

節點座標是**相對於 lane** 的，不是絕對座標。lane 高度務必與 pool 一致，否則欄位會長短不齊。

### 節點樣式

| 語意 | style |
|---|---|
| 起訖點 | `ellipse;whiteSpace=wrap;html=1;fillColor=#d5e8d4;strokeColor=#82b366;` |
| 一般動作 | `rounded=1;whiteSpace=wrap;html=1;fillColor=#dae8fc;strokeColor=#6c8ebf;` |
| 判斷 | `rhombus;whiteSpace=wrap;html=1;fillColor=#fff2cc;strokeColor=#d6b656;` |
| DB 讀寫 | `shape=cylinder3;whiteSpace=wrap;html=1;boundedLbl=1;backgroundOutline=1;size=15;fillColor=#e1d5e7;strokeColor=#9673a6;` |
| 外部系統 / MQ / 回調 | `shape=hexagon;whiteSpace=wrap;html=1;fillColor=#ffe6cc;strokeColor=#d79b00;` |
| 異常 / 失敗分支 | `rounded=1;whiteSpace=wrap;html=1;fillColor=#f8cecc;strokeColor=#b85450;` |
| 尚未定案 | 上述任一再加 `dashed=1;`，文字標 `{待確認}` |

`{待確認}` 沿用 workflow 慣例，圖上一眼看得出哪裡還沒確認。不確定的地方標出來，比亂填有用。

### 架構圖座標

不用 swimlane，全部 `parent="1"` 絕對座標：

| 元素 | 座標 |
|---|---|
| 第 L 層背景框 | x=40, y=`40 + 160*L`, width=920, height=120 |
| 層內第 i 個元件 | x=`60 + 220*i`, y=`層y + 50`, width=180, height=60 |

層背景框樣式必須加 `align=left;spacingLeft=10;`，否則層名會跑到框的右邊置中：

```text
rounded=0;whiteSpace=wrap;html=1;fillColor=#f5f5f5;strokeColor=#666666;verticalAlign=top;align=left;spacingLeft=10;fontStyle=1;
```

XML 中**背景框先寫、元件後寫**（draw.io 依文件順序決定 z-order，後寫的蓋在上層）。

跨服務呼叫加 `dashed=1`，在 edge 的 value 標協定（Feign / MQ / HTTP）。

### 連線不要穿過方塊

架構圖的元件是絕對座標，自動繞線會直接穿過中間的方塊。規則：

- **相鄰層垂直連線**：加 `exitX=0.5;exitY=1;entryX=0.5;entryY=0;`（底部出、頂部進）
- **同層水平連線**：加 `exitX=1;exitY=0.5;entryX=0;entryY=0.5;`（右出、左進）
- **跨 2 層以上**：上面兩招不夠，要加 waypoint 從空白區繞過去

```xml
<mxCell id="a9" value="MQ" style="edgeStyle=orthogonalEdgeStyle;rounded=0;html=1;exitX=1;exitY=0.5;entryX=0.5;entryY=0;dashed=1;" edge="1" parent="1" source="c21" target="c42">
  <mxGeometry relative="1" as="geometry">
    <Array as="points">
      <mxPoint x="590" y="440" />
    </Array>
  </mxGeometry>
</mxCell>
```

waypoint 的 x 通常取目標元件的中心 x，y 取來源元件的中心 y，讓線先水平走到目標正上方再垂直落下。

泳道圖不需要這些：lane 是容器，draw.io 的繞線在容器間已經夠乾淨。

---

## Step 5：匯出 PNG

Step 1.2 偵測到 CLI 才做：

```bash
"$DRAWIO_BIN" -x -f png -e -s 2 -b 10 -o "{output_dir}/{prefix}-{kind}.png" "{output_dir}/{prefix}-{kind}.drawio"
```

| flag | 作用 |
|---|---|
| `-e` | 把 diagram XML 內嵌進 PNG。**貼進 Confluence 的是普通 PNG，但拖回 draw.io 仍可編輯** |
| `-s 2` | 2 倍解析度，Confluence 上不糊 |
| `-b 10` | 留白邊 |
| `-p N` | 多頁檔案選第 N 頁（從 0 起算）。本 skill 產的是單頁檔，通常用不到 |

匯出失敗不算流程失敗：回報失敗原因，保留 `.drawio`，並給 Step 1.2 的網站轉檔說明。

---

## Step 6：回報

告訴使用者：

- 產出的檔案路徑（`.drawio`，以及有產的話 `.png`）
- 用了哪些 lane / 分層，方便使用者要求調整
- 標了 `{待確認}` 的節點清單，這些是需要補確認的地方
- 怎麼用：
  - **Confluence 有裝 draw.io app**：頁面插入 draw.io 巨集 → Extras → Edit Diagram → 貼上 `.drawio` 內容
  - **Confluence 沒裝**：直接貼 PNG（之後要改，把 PNG 拖回 draw.io 就能編輯）
- 沒產 PNG 時，附上 Step 1.2 的自行轉檔說明

---

## 重要原則

- **只畫圖，不決定需求**：流程內容以來源為準，不要自己補業務規則。缺的地方標 `{待確認}`
- **不寫死路徑**：`output_dir` 一定由呼叫端給或問使用者
- **未壓縮 XML**：人看得懂、進得了 git diff
- **佈局差不多就好**：固定座標公式產的圖節點文字太長時會擠；這是刻意的簡單佈局，使用者在 draw.io 按 Arrange → Layout → Vertical Flow 就能自動整一次。不要為了美觀寫自動佈局演算法
- **沒 CLI 不阻塞**：`.drawio` 永遠要產出

---

## 參考資料

- `references/diagram-template.drawio` — 結構範例，page 1 泳道流程、page 2 架構圖
- draw.io desktop releases — https://github.com/jgraph/drawio-desktop/releases
- 線上版 — https://app.diagrams.net
