# 前端子任務描述 HTML 模板

貼入禪道前端子任務的「任務描述」欄位。

將 `{佔位符}` 替換為實際內容。每個受影響的前端 repo 各一行。

---

```html
<table border="1" cellpadding="6" cellspacing="0">
  <thead>
    <tr>
      <th>改動內容</th>
      <th>改動範圍</th>
      <th>自測</th>
      <th>說明</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>{前端 repo 名稱，例如 otc365-cashier}</td>
      <td>
        1. {改動項目 1，例如：新增 XXX 功能}<br>
        2. {改動項目 2}<br>
        3. {改動項目 3}
      </td>
      <td>
        1) {自測驗證點 1，例如：點擊 XXX 按鈕，應正確觸發 YYY}<br>
        2) {自測驗證點 2}<br>
        3) {自測驗證點 3}
      </td>
      <td></td>
    </tr>
    <tr>
      <td>{前端 repo 名稱，例如 otc365-advertise}</td>
      <td>
        1. {改動項目 1}<br>
        2. {改動項目 2}
      </td>
      <td>
        1) {自測驗證點 1}<br>
        2) {自測驗證點 2}
      </td>
      <td></td>
    </tr>
  </tbody>
</table>
```

---

## 使用說明

- **改動內容**：填入受影響的前端 repo 名稱（如 `otc365-cashier`、`otc365-advertise`、`otc365-management` 等）
- **改動範圍**：條列這個 repo 做了哪些改動，要具體（新增 component、修改 API 串接、補 i18n 文案等）
- **自測**：條列前端自己要驗證的點，以使用者操作角度描述（點擊XXX、應正確顯示YYY）
- **說明**：選填，補充備注或特殊情況
- 若只影響一個 repo，刪除多餘的 `<tr>` 即可
