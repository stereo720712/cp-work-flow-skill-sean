# 後端子任務描述 HTML 模板

貼入禪道後端子任務的「任務描述」欄位。

將 `{佔位符}` 替換為實際內容。測試表格每個服務獨立一組，視受影響服務數量複製。

---

```html
<h1>後端功能自測報告</h1>

<h2>CP-{任務編號} 後端業務邏輯說明</h2>

<h3>問題背景</h3>
<p>{描述這個任務要解決的問題或新增的功能背景}</p>

<h3>修改內容</h3>
<ol>
  <li><strong>{服務名稱}</strong> — {說明這個服務改了什麼}</li>
  <li><strong>{服務名稱}</strong> — {說明這個服務改了什麼}</li>
</ol>

<hr>

<h2>{服務名稱，例如 otc-order-bll}</h2>

<h3>1. {測試場景標題}</h3>
<table border="1" cellpadding="6" cellspacing="0">
  <thead>
    <tr>
      <th>測試流程</th>
      <th>API | 操作 (Input)</th>
      <th>執行結果 (Output)</th>
      <th>敘述 / 驗證點</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>正向流程：<br>{描述正常情境下的操作}</td>
      <td>
        POST {API 路徑}<br>
        <pre>{
  "param1": "value1",
  "param2": "value2"
}</pre>
      </td>
      <td>
        <pre>{
  "code": 200,
  "msg": "成功",
  "success": true,
  "data": {
    "{欄位}": "{預期值}"
  }
}</pre>
      </td>
      <td>
        1. 狀態碼為 200<br>
        2. {驗證點 2}<br>
        3. {驗證點 3}
      </td>
    </tr>
    <tr>
      <td>異常流程：<br>{描述異常情境，例如參數錯誤、越權等}</td>
      <td>
        POST {API 路徑}<br>
        <pre>{
  "param1": "{非法值}"
}</pre>
      </td>
      <td>
        <pre>{
  "code": 400,
  "msg": "{錯誤訊息}",
  "success": false
}</pre>
      </td>
      <td>
        1. 狀態碼為 {預期錯誤碼}<br>
        2. {驗證點 2}
      </td>
    </tr>
  </tbody>
</table>

<h3>2. 資料庫數值核對 (Data Integrity)</h3>
<p>{說明是否有資料庫寫入需要核對，若無則填「本功能不涉及資料庫數值異動，無需核對。」}</p>

<h3>3. 單元測試 (Unit Test Reports)</h3>
<p>{說明單元測試結果，若無則填「本任務無單元測試項目。」}</p>

<h3>4. 其他測試結果 (Other Test Results)</h3>
<p>{補充其他測試方式或注意事項}</p>
```

---

## 使用說明

- **多個服務**：若影響多個後端服務，從 `<h2>{服務名稱}` 開始複製整個區塊，依序排列
- **測試場景**：每個主要功能點建立一組表格，正向流程和異常流程各一行（或多行）
- **Input/Output**：盡量填入真實的 JSON 範例，讓測試人員可以直接對照
- **驗證點**：條列說明這個測試案例要確認什麼，越具體越好
