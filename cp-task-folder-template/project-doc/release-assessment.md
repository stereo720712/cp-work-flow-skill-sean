# task-{編號} release assessment

## 基本資訊

- task_id:
- task_title:
- sprint_version:
- requirement_version: R0
- status: draft / done / needs_update

## 環境與上線順序

- 測試環境：
- 預發環境：
- 正式環境：
- 上線順序：先上預發，再上正式
- 預發是否作為正式備援：yes / no / unknown
- 預發與正式是否共用 DB：yes / no / unknown
- 預發與正式是否共用 Redis：yes / no / unknown

## DB 影響評估

| 項目 | 是否涉及 | 內容 | 相容性 | 回滾方式 |
|---|---|---|---|---|
| DDL |  |  |  |  |
| DML / 初始化資料 |  |  |  |  |
| 查詢條件 / 索引 |  |  |  |  |
| 資料修復 |  |  |  |  |

## Redis 影響評估

| 項目 | 是否涉及 | key / prefix | 影響 | 清理 / 回滾方式 |
|---|---|---|---|---|
| 新增 key |  |  |  |  |
| 修改 key |  |  |  |  |
| 快取資料相容性 |  |  |  |  |
| TTL / 清理策略 |  |  |  |  |

## 預發驗證重點

-

## 正式上線檢查

- [ ] SQL 已確認向前相容。
- [ ] Redis key 與資料相容性已確認。
- [ ] 預發先上不會污染正式資料。
- [ ] 回滾方式已確認。
- [ ] QA / PM / 後端確認可上線。

## 風險與應對

| 風險 | 監控方式 | 發生時處理 |
|---|---|---|
|  |  |  |
