# 後端開發文件模板

儲存為 `task-{編號}-backend-dev-doc.md`，放在 `task-doc/{衝刺版號}/task-{編號}/project-doc/` 資料夾。

---

```markdown
# CP-{任務編號} 後端開發文件

> 任務標題：{任務標題}
> 建立日期：{YYYY-MM-DD}

---

## 1. 業務邏輯流程說明

### 背景
{說明這個任務要解決什麼問題，或新增什麼功能}

### 流程說明
{描述主要業務流程，可用條列或 mermaid flowchart}

```mermaid
flowchart TD
    A[{起點}] --> B[{步驟}]
    B --> C{判斷條件}
    C -->|是| D[{結果 A}]
    C -->|否| E[{結果 B}]
```

### 影響服務
| 服務名稱 | 改動類型 | 說明 |
|---|---|---|
| {服務名} | 新增 / 修改 / 唯讀 | {簡述} |

---

## 2. API 設計

### 新增 API

#### {API 名稱}
- **Method**：POST / GET
- **Path**：`/cola/{domain}/{endpoint}`
- **Controller**：`{ControllerClass}#{methodName}`
- **說明**：{這個 API 做什麼}

**Request：**
```json
{
  "field1": "類型 | 說明",
  "field2": "類型 | 說明"
}
```

**Response：**
```json
{
  "code": 200,
  "msg": "成功",
  "success": true,
  "data": {
    "field1": "類型 | 說明"
  }
}
```

**驗證規則：**
- {欄位} — {規則，例如：不可為空、長度限制}

---

### 修改 API

#### {API 名稱}（修改）
- **Path**：`/cola/{domain}/{endpoint}`
- **修改原因**：{為什麼要改}
- **改動內容**：
  - Request 新增欄位：`{欄位名}` — {說明}
  - Response 移除欄位：`{欄位名}` — {說明}
  - 業務邏輯變更：{說明}

---

## 3. 資料庫變更

### 新增欄位

| 表名 | 欄位名 | 類型 | 預設值 | 說明 |
|---|---|---|---|---|
| {table_name} | {column_name} | VARCHAR(64) | NULL | {說明} |

**SQL：**
```sql
ALTER TABLE {table_name}
ADD COLUMN {column_name} VARCHAR(64) NULL COMMENT '{說明}';
```

### 新增表

```sql
CREATE TABLE {table_name} (
  id          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主鍵',
  {field}     VARCHAR(64)  NOT NULL COMMENT '{說明}',
  create_time DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '建立時間',
  update_time DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新時間',
  is_delete   TINYINT(1)   NOT NULL DEFAULT 0 COMMENT '軟刪除',
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='{表說明}';
```

### Redis 變更（若有）

| Key 格式 | TTL | 說明 |
|---|---|---|
| `{prefix}:{id}` | {秒數} | {說明} |

---

## 4. 注意事項 / 風險點

- {例如：此操作涉及金額計算，必須使用 BigDecimal}
- {例如：需要考慮併發情況，加分散式鎖}
- {例如：影響現有用戶資料，需確認資料遷移策略}
```
