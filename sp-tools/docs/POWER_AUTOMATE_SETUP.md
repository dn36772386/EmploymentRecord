# Power Automate フロー設定ガイド

このドキュメントでは、雇用調書承認システムのPower Automateフローの設定方法を説明します。

## 必要なフロー

### 1. 申請提出フロー（Submit Application）

**トリガー**: SharePoint - 選択したアイテムの場合
- **サイトアドレス**: `https://tf1980.sharepoint.com/sites/abeam`
- **リスト名**: `EMP_1_EmploymentRecords`

**アクション**:

1. **変数を初期化する** - `申請者ID`
   - 名前: `申請者ID`
   - 種類: 整数
   - 値: `triggerBody()?['entity']?['ID']`

2. **変数を初期化する** - `申請者名`
   - 名前: `申請者名`
   - 種類: 文字列
   - 値: `triggerBody()?['entity']?['FullName']`

3. **SharePoint - アイテムの更新**
   - サイトアドレス: `https://tf1980.sharepoint.com/sites/abeam`
   - リスト名: `EMP_1_EmploymentRecords`
   - ID: `@{variables('申請者ID')}`
   - フィールド:
     - `OverallApproval`: `申請中`

4. **SharePoint - アイテムの作成**（承認履歴 - 申請記録）
   - サイトアドレス: `https://tf1980.sharepoint.com/sites/abeam`
   - リスト名: `EMP_1_EmploymentApprovals`
   - フィールド:
     - `Title`: `申請 - @{variables('申請者名')}`
     - `ParentRecordId`: `@{variables('申請者ID')}`
     - `StageNumber`: `0`
     - `StageType`: `部門`
     - `Status`: `申請中`
     - `IsRequired`: `Yes`
     - `ActionedAt`: `@{utcNow()}`
     - `Order`: `1`

5. **SharePoint - 複数のアイテムの取得**（第1段承認者を取得）
   - サイトアドレス: `https://tf1980.sharepoint.com/sites/abeam`
   - リスト名: `EMP_1_EmploymentRecords`
   - フィルタークエリ: `ID eq @{variables('申請者ID')}`

6. **Apply to each**（第1段承認者に対して承認依頼を作成）
   - 以前の手順から出力を選択: `body('複数のアイテムの取得')?['value']`
   
   内部アクション:
   
   a. **SharePoint - アイテムの作成**（承認履歴 - 第1段承認待ち）
   - リスト名: `EMP_1_EmploymentApprovals`
   - フィールド:
     - `Title`: `第1段承認 - @{variables('申請者名')}`
     - `ParentRecordId`: `@{variables('申請者ID')}`
     - `StageNumber`: `1`
     - `StageType`: `部門`
     - `Status`: `申請中`
     - `IsRequired`: `Yes`
     - `ApproverId`: `@{items('Apply_to_each')?['Stage1Approvers']?['Claims']}`
     - `ApproverEmail`: `@{items('Apply_to_each')?['Stage1Approvers']?['Email']}`
     - `DueDate`: `@{addDays(utcNow(), 7)}`
     - `Order`: `2`
   
   b. **Office 365 Outlook - メールの送信 (V2)**
   - 宛先: `@{items('Apply_to_each')?['Stage1Approvers']?['Email']}`
   - 件名: `【承認依頼】雇用調書の承認をお願いします - @{variables('申請者名')}`
   - 本文:
   ```html
   <p>以下の雇用調書の承認依頼がありました。</p>
   <p><strong>申請者:</strong> @{variables('申請者名')}<br>
   <strong>職員番号:</strong> @{items('Apply_to_each')?['EmployeeID']}<br>
   <strong>所属:</strong> @{items('Apply_to_each')?['Department']}</p>
   <p>承認または却下は以下のリンクから実行してください:<br>
   <a href="https://tf1980.sharepoint.com/sites/abeam/Lists/EMP_1_EmploymentRecords/DispForm.aspx?ID=@{variables('申請者ID')}">雇用調書を開く</a></p>
   ```

7. **条件分岐** - すべての承認者にメール送信完了
   - はいの場合: メッセージを返す
   - いいえの場合: エラーログ

---

### 2. 承認フロー（Approve Application）

**トリガー**: SharePoint - 選択したアイテムの場合
- **サイトアドレス**: `https://tf1980.sharepoint.com/sites/abeam`
- **リスト名**: `EMP_1_EmploymentRecords`

**アクション**:

1. **変数を初期化する** - `記録ID`
   - 名前: `記録ID`
   - 種類: 整数
   - 値: `@{triggerBody()?['entity']?['ID']}`

2. **変数を初期化する** - `承認者メール`
   - 名前: `承認者メール`
   - 種類: 文字列
   - 値: `@{triggerOutputs()?['headers']?['x-ms-user-email']}`

3. **SharePoint - 複数のアイテムの取得**（承認待ちレコードを取得）
   - リスト名: `EMP_1_EmploymentApprovals`
   - フィルタークエリ: `ParentRecordId eq @{variables('記録ID')} and Status eq '申請中' and ApproverEmail eq '@{variables('承認者メール')}'`
   - 並べ替え順序: `Order asc`
   - 上位カウント: `1`

4. **条件分岐** - 承認待ちレコードが存在するか
   - 条件: `@{length(body('複数のアイテムの取得')?['value'])} greater than 0`
   
   **はいの場合**:
   
   a. **SharePoint - アイテムの更新**（承認履歴を更新）
   - リスト名: `EMP_1_EmploymentApprovals`
   - ID: `@{body('複数のアイテムの取得')?['value']?[0]?['ID']}`
   - フィールド:
     - `Status`: `承認`
     - `ActionedAt`: `@{utcNow()}`
     - `ActionedById`: `@{triggerOutputs()?['headers']?['x-ms-user-id']}`
     - `Note`: `承認しました`
   
   b. **SharePoint - 複数のアイテムの取得**（次の段階を確認）
   - リスト名: `EMP_1_EmploymentApprovals`
   - フィルタークエリ: `ParentRecordId eq @{variables('記録ID')}`
   - 並べ替え順序: `Order desc`
   - 上位カウント: `1`
   
   c. **条件分岐** - 最終承認かどうか
   - 条件: `@{body('複数のアイテムの取得_2')?['value']?[0]?['StageNumber']} equals 2`
   
   **はいの場合**（最終承認）:
   - **SharePoint - アイテムの更新**
     - リスト名: `EMP_1_EmploymentRecords`
     - ID: `@{variables('記録ID')}`
     - フィールド:
       - `OverallApproval`: `承認`
   
   - **Office 365 Outlook - メールの送信 (V2)**（申請者へ通知）
   - 件名: `【承認完了】雇用調書が承認されました`
   
   **いいえの場合**（次段階へ）:
   - 第2段承認者への通知処理
   
   **いいえの場合**（承認待ちレコードなし）:
   - エラーメッセージ

---

### 3. 却下フロー（Reject Application）

**トリガー**: SharePoint - 選択したアイテムの場合
- **サイトアドレス**: `https://tf1980.sharepoint.com/sites/abeam`
- **リスト名**: `EMP_1_EmploymentRecords`

**アクション**:

1. **変数を初期化する** - `記録ID`、`承認者メール`（承認フローと同様）

2. **SharePoint - 複数のアイテムの取得**（承認待ちレコードを取得）

3. **条件分岐** - 承認待ちレコードが存在するか
   
   **はいの場合**:
   
   a. **SharePoint - アイテムの更新**（承認履歴を更新）
   - フィールド:
     - `Status`: `却下`
     - `ActionedAt`: `@{utcNow()}`
     - `ActionedById`: `@{triggerOutputs()?['headers']?['x-ms-user-id']}`
     - `Note`: `却下しました`
   
   b. **SharePoint - アイテムの更新**（雇用記録を更新）
   - リスト名: `EMP_1_EmploymentRecords`
   - ID: `@{variables('記録ID')}`
   - フィールド:
       - `OverallApproval`: `却下`
   
   c. **Office 365 Outlook - メールの送信 (V2)**（申請者へ通知）
   - 件名: `【却下】雇用調書が却下されました`

---

### 4. 差戻しフロー（Return Application）

**トリガー**: SharePoint - 選択したアイテムの場合
- **サイトアドレス**: `https://tf1980.sharepoint.com/sites/abeam`
- **リスト名**: `EMP_1_EmploymentRecords`

**アクション**: 却下フローと同様ですが、`Status`を`差戻し`に設定

---

## JSON列書式の設定

### 申請ボタン列（SubmitBtn）の設定

1. `EMP_1_EmploymentRecords`リストを開く
2. `SubmitBtn`列の設定を開く
3. 「列の書式設定」→「詳細モード」
4. `submit-button-format.json`の内容をコピー
5. `YOUR_FLOW_ID_HERE`を実際のフローIDに置き換え
   - フローIDの取得方法:
     - Power Automateで対象フローを開く
     - URLから`environments/`と`/flows/`の間の文字列がフローID

### 承認履歴列の設定

1. `EMP_1_EmploymentApprovals`リストを開く
2. `Title`列の設定を開く
3. 「列の書式設定」→「詳細モード」
4. `approvals-title-format.json`の内容を貼り付け
5. 保存

---

## トラブルシューティング

### フローが実行されない
- SharePointリストの権限を確認
- フローの実行履歴でエラーを確認
- トリガー条件が正しいか確認

### 承認者にメールが届かない
- Office 365 Outlookの接続を確認
- メールアドレスが正しいか確認
- メールボックスの容量を確認

### 承認状態が更新されない
- フロー内のリスト名、列名が正確か確認
- 変数の初期化が正しいか確認
