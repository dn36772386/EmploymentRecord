# 雇用記録承認ワークフロー - Power Automate 設定ガイド

## 概要

雇用記録 (`EMP_1_EmploymentRecords`) の承認ワークフローを実装するためのPower Automateフロー設定ガイドです。

## 承認フィールド構成

### 雇用記録リストのフィールド

| フィールド名 | 内部名 | 型 | 説明 |
|------------|--------|-----|------|
| 全体承認状態 | OverallApproval | Text | 未申請/第1段承認待ち/第2段承認待ち/承認完了/差戻し |
| 申請日時 | SubmittedDate | DateTime | 申請された日時 |
| 第1段承認者（部門） | Stage1Approvers | UserMulti | 部門の承認者 |
| 第1段承認ステータス | Stage1ApprovalStatus | Choice | 未申請/申請中/承認/却下/差戻し |
| 第1段承認コメント | Stage1ApprovalComment | Note | 承認者のコメント |
| 第1段承認日時 | Stage1ApprovalDate | DateTime | 承認/却下された日時 |
| 第2段承認者（管理部門） | Stage2Approvers | UserMulti | 管理部門の承認者 |
| 第2段承認ステータス | Stage2ApprovalStatus | Choice | 未申請/申請中/承認/却下/差戻し |
| 第2段承認コメント | Stage2ApprovalComment | Note | 承認者のコメント |
| 第2段承認日時 | Stage2ApprovalDate | DateTime | 承認/却下された日時 |

## フロー1: 雇用記録申請フロー

### トリガー
- **種類**: PowerApps (V2)
- **説明**: 申請ボタンから起動

### アクション

#### 1. SharePointアイテムの更新
- **サイトアドレス**: `https://tf1980.sharepoint.com/sites/abeam`
- **リスト名**: `EMP_1_EmploymentRecords`
- **ID**: トリガーからのアイテムID
- **更新フィールド**:
  - `OverallApproval`: "第1段承認待ち"
  - `SubmittedDate`: `utcNow()`
  - `Stage1ApprovalStatus`: "申請中"
  - `Stage2ApprovalStatus`: "未申請"

#### 2. 承認メール送信
- **To**: `Stage1Approvers`（第1段承認者）
- **Subject**: `【承認依頼】雇用調書の承認をお願いします - [@{items('body/EmployeeID')} @{items('body/FullName')}]`
- **Body**:
```html
<p>雇用調書の承認依頼が届いています。</p>

<h3>申請情報</h3>
<ul>
  <li><strong>社員ID:</strong> @{items('body/EmployeeID')}</li>
  <li><strong>氏名:</strong> @{items('body/FullName')}</li>
  <li><strong>申請日時:</strong> @{items('body/SubmittedDate')}</li>
</ul>

<p><a href="https://tf1980.sharepoint.com/sites/abeam/Lists/EMP_1_EmploymentRecords/DispForm.aspx?ID=@{items('body/ID')}">承認画面を開く</a></p>
```

---

## フロー2: 第1段承認フロー

### トリガー
- **種類**: PowerApps (V2)
- **説明**: 第1段承認ボタンから起動

### アクション

#### 1. 承認コメント取得
- **種類**: PowerApps入力
- **変数名**: `ApprovalComment`
- **説明**: "承認コメントを入力してください"

#### 2. SharePointアイテムの更新
- **更新フィールド**:
  - `Stage1ApprovalStatus`: "承認"
  - `Stage1ApprovalComment`: `@{triggerBody()['text']}`（コメント）
  - `Stage1ApprovalDate`: `utcNow()`
  - `OverallApproval`: "第2段承認待ち"
  - `Stage2ApprovalStatus`: "申請中"

#### 3. 第2段承認者へメール送信
- **To**: `Stage2Approvers`（第2段承認者）
- **Subject**: `【承認依頼】雇用調書の第2段承認をお願いします - [@{items('body/EmployeeID')} @{items('body/FullName')}]`
- **Body**:
```html
<p>第1段承認が完了しました。第2段承認をお願いします。</p>

<h3>申請情報</h3>
<ul>
  <li><strong>社員ID:</strong> @{items('body/EmployeeID')}</li>
  <li><strong>氏名:</strong> @{items('body/FullName')}</li>
  <li><strong>申請日時:</strong> @{items('body/SubmittedDate')}</li>
  <li><strong>第1段承認日時:</strong> @{items('body/Stage1ApprovalDate')}</li>
</ul>

<h3>第1段承認者コメント</h3>
<p>@{items('body/Stage1ApprovalComment')}</p>

<p><a href="https://tf1980.sharepoint.com/sites/abeam/Lists/EMP_1_EmploymentRecords/DispForm.aspx?ID=@{items('body/ID')}">承認画面を開く</a></p>
```

#### 4. 申請者へ通知メール送信
- **To**: `CreatedBy`（作成者）
- **Subject**: `【通知】雇用調書の第1段承認が完了しました - [@{items('body/EmployeeID')} @{items('body/FullName')}]`
- **Body**:
```html
<p>あなたが申請した雇用調書の第1段承認が完了しました。</p>

<h3>承認情報</h3>
<ul>
  <li><strong>承認者:</strong> 第1段承認者（部門）</li>
  <li><strong>承認日時:</strong> @{items('body/Stage1ApprovalDate')}</li>
  <li><strong>コメント:</strong> @{items('body/Stage1ApprovalComment')}</li>
</ul>

<p>現在、第2段承認待ちです。</p>
```

---

## フロー3: 第1段却下/差戻しフロー

### トリガー
- **種類**: PowerApps (V2)
- **説明**: 第1段却下ボタンから起動

### アクション

#### 1. 却下理由取得
- **種類**: PowerApps入力
- **変数名**: `RejectionReason`
- **説明**: "却下理由を入力してください（必須）"

#### 2. 却下種別の選択
- **種類**: PowerApps入力（Choice）
- **変数名**: `RejectionType`
- **選択肢**: "却下", "差戻し"

#### 3. SharePointアイテムの更新
- **更新フィールド**:
  - `Stage1ApprovalStatus`: `@{triggerBody()['text_1']}`（却下or差戻し）
  - `Stage1ApprovalComment`: `@{triggerBody()['text']}`（却下理由）
  - `Stage1ApprovalDate`: `utcNow()`
  - `OverallApproval`: "差戻し"

#### 4. 申請者へメール送信
- **To**: `CreatedBy`（作成者）
- **Subject**: `【@{triggerBody()['text_1']}】雇用調書が@{triggerBody()['text_1']}されました - [@{items('body/EmployeeID')} @{items('body/FullName')}]`
- **Body**:
```html
<p style="color: red;"><strong>あなたが申請した雇用調書が@{triggerBody()['text_1']}されました。</strong></p>

<h3>@{triggerBody()['text_1']}情報</h3>
<ul>
  <li><strong>@{triggerBody()['text_1']}者:</strong> 第1段承認者（部門）</li>
  <li><strong>@{triggerBody()['text_1']}日時:</strong> @{items('body/Stage1ApprovalDate')}</li>
</ul>

<h3>@{triggerBody()['text_1']}理由</h3>
<p>@{items('body/Stage1ApprovalComment')}</p>

<p><a href="https://tf1980.sharepoint.com/sites/abeam/Lists/EMP_1_EmploymentRecords/DispForm.aspx?ID=@{items('body/ID')}">内容を確認する</a></p>

<p>@{if(equals(triggerBody()['text_1'], '差戻し'), '修正後、再度申請してください。', '')}</p>
```

---

## フロー4: 第2段承認フロー

### トリガー
- **種類**: PowerApps (V2)
- **説明**: 第2段承認ボタンから起動

### アクション

#### 1. 承認コメント取得
- **種類**: PowerApps入力
- **変数名**: `ApprovalComment`
- **説明**: "承認コメントを入力してください"

#### 2. SharePointアイテムの更新
- **更新フィールド**:
  - `Stage2ApprovalStatus`: "承認"
  - `Stage2ApprovalComment`: `@{triggerBody()['text']}`（コメント）
  - `Stage2ApprovalDate`: `utcNow()`
  - `OverallApproval`: "承認完了"

#### 3. 申請者へ完了メール送信
- **To**: `CreatedBy`（作成者）
- **Subject**: `【承認完了】雇用調書の承認が完了しました - [@{items('body/EmployeeID')} @{items('body/FullName')}]`
- **Body**:
```html
<p style="color: green;"><strong>おめでとうございます！あなたが申請した雇用調書の承認が完了しました。</strong></p>

<h3>申請情報</h3>
<ul>
  <li><strong>社員ID:</strong> @{items('body/EmployeeID')}</li>
  <li><strong>氏名:</strong> @{items('body/FullName')}</li>
  <li><strong>申請日時:</strong> @{items('body/SubmittedDate')}</li>
</ul>

<h3>第1段承認情報</h3>
<ul>
  <li><strong>承認日時:</strong> @{items('body/Stage1ApprovalDate')}</li>
  <li><strong>コメント:</strong> @{items('body/Stage1ApprovalComment')}</li>
</ul>

<h3>第2段承認情報</h3>
<ul>
  <li><strong>承認日時:</strong> @{items('body/Stage2ApprovalDate')}</li>
  <li><strong>コメント:</strong> @{items('body/Stage2ApprovalComment')}</li>
</ul>

<p><a href="https://tf1980.sharepoint.com/sites/abeam/Lists/EMP_1_EmploymentRecords/DispForm.aspx?ID=@{items('body/ID')}">承認済み雇用調書を確認する</a></p>
```

#### 4. 第1段承認者へ完了通知
- **To**: `Stage1Approvers`
- **Subject**: `【承認完了】雇用調書の最終承認が完了しました - [@{items('body/EmployeeID')} @{items('body/FullName')}]`
- **Body**:
```html
<p>あなたが第1段承認した雇用調書の最終承認が完了しました。</p>

<h3>申請情報</h3>
<ul>
  <li><strong>社員ID:</strong> @{items('body/EmployeeID')}</li>
  <li><strong>氏名:</strong> @{items('body/FullName')}</li>
  <li><strong>第2段承認日時:</strong> @{items('body/Stage2ApprovalDate')}</li>
</ul>
```

---

## フロー5: 第2段却下/差戻しフロー

### トリガー
- **種類**: PowerApps (V2)
- **説明**: 第2段却下ボタンから起動

### アクション

#### 1. 却下理由取得
- **種類**: PowerApps入力
- **変数名**: `RejectionReason`
- **説明**: "却下理由を入力してください（必須）"

#### 2. 却下種別の選択
- **種類**: PowerApps入力（Choice）
- **変数名**: `RejectionType`
- **選択肢**: "却下", "差戻し"

#### 3. SharePointアイテムの更新
- **更新フィールド**:
  - `Stage2ApprovalStatus`: `@{triggerBody()['text_1']}`（却下or差戻し）
  - `Stage2ApprovalComment`: `@{triggerBody()['text']}`（却下理由）
  - `Stage2ApprovalDate`: `utcNow()`
  - `OverallApproval`: "差戻し"
  - `Stage1ApprovalStatus`: "未申請"（差戻しの場合は第1段階に戻す）

#### 4. 申請者へメール送信
- **To**: `CreatedBy`（作成者）
- **Subject**: `【@{triggerBody()['text_1']}】雇用調書が第2段階で@{triggerBody()['text_1']}されました - [@{items('body/EmployeeID')} @{items('body/FullName')}]`
- **Body**:
```html
<p style="color: red;"><strong>あなたが申請した雇用調書が第2段階で@{triggerBody()['text_1']}されました。</strong></p>

<h3>@{triggerBody()['text_1']}情報</h3>
<ul>
  <li><strong>@{triggerBody()['text_1']}者:</strong> 第2段承認者（管理部門）</li>
  <li><strong>@{triggerBody()['text_1']}日時:</strong> @{items('body/Stage2ApprovalDate')}</li>
</ul>

<h3>@{triggerBody()['text_1']}理由</h3>
<p>@{items('body/Stage2ApprovalComment')}</p>

<p><a href="https://tf1980.sharepoint.com/sites/abeam/Lists/EMP_1_EmploymentRecords/DispForm.aspx?ID=@{items('body/ID')}">内容を確認する</a></p>

<p>@{if(equals(triggerBody()['text_1'], '差戻し'), '修正後、再度申請してください。', '')}</p>
```

#### 5. 第1段承認者へ通知
- **To**: `Stage1Approvers`
- **Subject**: `【通知】雇用調書が第2段階で@{triggerBody()['text_1']}されました - [@{items('body/EmployeeID')} @{items('body/FullName')}]`
- **Body**:
```html
<p>あなたが第1段承認した雇用調書が第2段階で@{triggerBody()['text_1']}されました。</p>

<h3>@{triggerBody()['text_1']}情報</h3>
<ul>
  <li><strong>@{triggerBody()['text_1']}者:</strong> 第2段承認者（管理部門）</li>
  <li><strong>@{triggerBody()['text_1']}日時:</strong> @{items('body/Stage2ApprovalDate')}</li>
  <li><strong>理由:</strong> @{items('body/Stage2ApprovalComment')}</li>
</ul>
```

---

## JSON列書式の適用方法

### 1. OverallApproval（全体承認状態）列に詳細表示を適用

1. SharePointで`EMP_1_EmploymentRecords`リストを開く
2. `OverallApproval`列のヘッダーをクリック → **列の設定** → **この列の書式設定**
3. **詳細設定モード**を選択
4. `employment-approval-column-format.json`の内容を貼り付け
5. **保存**

### 2. Title列に承認ボタンを追加

1. `Title`列のヘッダーをクリック → **列の設定** → **この列の書式設定**
2. **詳細設定モード**を選択
3. `employment-approval-buttons.json`の内容を貼り付け
4. 各フローIDを実際のFlow IDに置き換え:
   - `YOUR_SUBMIT_FLOW_ID` → 申請フローのID
   - `YOUR_STAGE1_APPROVE_FLOW_ID` → 第1段承認フローのID
   - `YOUR_STAGE1_REJECT_FLOW_ID` → 第1段却下フローのID
   - `YOUR_STAGE2_APPROVE_FLOW_ID` → 第2段承認フローのID
   - `YOUR_STAGE2_REJECT_FLOW_ID` → 第2段却下フローのID
5. **保存**

---

## トラブルシューティング

### フローが起動しない

- SharePointリストのアクセス権限を確認
- Flow IDが正しく設定されているか確認
- フローの実行履歴でエラーを確認

### メールが届かない

- メールアドレスが正しく設定されているか確認
- `Stage1Approvers`、`Stage2Approvers`フィールドにユーザーが設定されているか確認
- Outlookの迷惑メールフォルダを確認

### 承認ステータスが更新されない

- フローのSharePoint更新アクションでフィールド名が正しいか確認
- リストアイテムのアクセス権限を確認

---

## 運用のベストプラクティス

1. **承認者の事前設定**: 雇用記録作成時に`Stage1Approvers`と`Stage2Approvers`を設定
2. **期限管理**: 承認期限を設定し、期限超過時に通知フローを作成
3. **承認履歴の保存**: 承認/却下のアクションは自動的にフィールドに記録される
4. **定期的な確認**: 承認待ちのアイテムを定期的にレビュー
5. **テスト環境での検証**: 本番環境に適用する前に、テスト環境で十分にテスト

---

## 参考情報

- [Power Automate - SharePointコネクタ](https://docs.microsoft.com/ja-jp/connectors/sharepointonline/)
- [JSON列書式設定リファレンス](https://docs.microsoft.com/ja-jp/sharepoint/dev/declarative-customization/column-formatting)
- [Power Automate - PowerAppsトリガー](https://docs.microsoft.com/ja-jp/power-automate/powerapps-trigger)
