# EMP_2 並行2段階承認フロー作成手順
**Power Automate 実装ガイド**

作成日: 2025/10/18

---

## 📋 前提条件

- ✅ SharePointリスト `EMP_1_EmploymentRecords` が存在
- ✅ 既存フロー `EMP_1_雇用調書承認フロー`（FlowID: daf1fc3a-17a8-f011-bbd3-000d3ace47ae）が存在
- ✅ 必要な列が全て存在（Stage1Approvers, Stage2Approversなど）

---

## 🚀 作成手順

### ステップ1: 既存フローの複製

#### 1-1. Power Automateを開く
```
https://make.powerautomate.com
```

#### 1-2. 既存フローを検索
1. 左メニュー「**マイ フロー**」をクリック
2. 検索ボックスに「**EMP_1_雇用調書承認フロー**」と入力

#### 1-3. フローを複製
1. フロー名の右側「**︙**」（縦3点メニュー）をクリック
2. 「**名前を付けて保存**」を選択
3. 新しい名前: `EMP_2_雇用調書承認フロー`
4. 「**保存**」をクリック

#### 1-4. 新しいフローを編集
1. 保存されたフロー「**EMP_2_雇用調書承認フロー**」を開く
2. 「**編集**」ボタンをクリック

---

### ステップ2: トリガーと項目取得

既存の以下のアクションは**変更不要**：
- ✅ **トリガー**: `manual`（SharePoint - 選択したアイテムに対して）
- ✅ **項目の取得**: SharePointリストからアイテムを取得

---

### ステップ3: 第1承認者への承認依頼（既存を修正）

#### 3-1. 既存の承認アクションを探す
- 通常「**承認を開始して結果を待機**」という名前のアクション

#### 3-2. アクション名を変更
- **新しい名前**: `第1承認者への承認依頼`

#### 3-3. 各項目を修正

| 項目 | 設定値 |
|------|--------|
| **承認の種類** | 承認/拒否 - 最初に応答 |
| **タイトル** | `【第1承認依頼】雇用調書 - @{outputs('項目の取得')?['body/FullName']}` |
| **割り当て先** | `@{outputs('項目の取得')?['body/Stage1ApproversClaims']}` |
| **アイテムリンク** | `@{outputs('項目の取得')?['body/{Link}']}` |

**詳細セクション**:
```
申請者: @{outputs('項目の取得')?['body/FullName']}
職員番号: @{outputs('項目の取得')?['body/EmployeeID']}
採用理由: @{outputs('項目の取得')?['body/EmploymentReason']}
部署: @{outputs('項目の取得')?['body/Department']}
```

---

### ステップ4: 第2承認者への承認依頼（新規追加・並行実行）

#### 4-1. アクションを追加
1. 「**項目の取得**」アクションの下に「**+ 新しいステップ**」をクリック
2. 「**承認**」で検索
3. 「**承認 - 承認を開始して結果を待機**」を選択

#### 4-2. アクション名を設定
- **名前**: `第2承認者への承認依頼`

#### 4-3. 各項目を設定

| 項目 | 設定値 |
|------|--------|
| **承認の種類** | 承認/拒否 - 最初に応答 |
| **タイトル** | `【第2承認依頼】雇用調書 - @{outputs('項目の取得')?['body/FullName']}` |
| **割り当て先** | `@{outputs('項目の取得')?['body/Stage2ApproversClaims']}` |
| **アイテムリンク** | `@{outputs('項目の取得')?['body/{Link}']}` |
| **詳細** | （第1承認者と同じ内容） |

#### 4-4. 並行実行の設定 ⚠️重要
1. 「**第2承認者への承認依頼**」アクションの右上「**︙**」をクリック
2. 「**実行条件の構成**」を選択
3. 「**次の後に実行**」を `項目の取得` に設定
4. これにより、第1・第2承認が**同時に実行**されます

---

### ステップ5: 第1承認者の結果チェック

#### 5-1. 条件アクションを追加
1. 「**第1承認者への承認依頼**」の下に「**+ 新しいステップ**」
2. 「**条件**」で検索
3. 「**コントロール - 条件**」を選択

#### 5-2. 条件式を設定
```
@outputs('第1承認者への承認依頼')?['body/outcome']
が次の値に等しい
Approve
```

---

#### 5-3. 「はいの場合」の処理

**A. リストアイテムを更新（承認ステータス）**

1. 「**はいの場合**」ブランチに「**アクションの追加**」
2. 「**SharePoint - 項目の更新**」を選択
3. 設定:

| 項目 | 設定値 |
|------|--------|
| **サイトのアドレス** | `https://tf1980.sharepoint.com/sites/abeam` |
| **リスト名** | `EMP_1_EmploymentRecords` |
| **ID** | `@{outputs('項目の取得')?['body/ID']}` |
| **Stage1ApprovalStatus** | `承認` |
| **Stage1ApprovalComment** | `@{outputs('第1承認者への承認依頼')?['body/responses'][0]['comments']}` |
| **Stage1ApprovalDate** | `@{utcNow()}` |

**B. 申請者権限を「閲覧のみ」に変更**

**B-1. SharePoint HTTPリクエスト（権限継承解除）**

1. 「**アクションの追加**」→「**SharePoint - HTTP要求の送信**」
2. 設定:

| 項目 | 設定値 |
|------|--------|
| **サイトのアドレス** | `https://tf1980.sharepoint.com/sites/abeam` |
| **メソッド** | `POST` |
| **URI** | `_api/web/lists/getbytitle('EMP_1_EmploymentRecords')/items(@{outputs('項目の取得')?['body/ID']})/breakroleinheritance(copyRoleAssignments=false)` |
| **ヘッダー** | `{"Accept":"application/json;odata=verbose","Content-Type":"application/json;odata=verbose"}` |

**B-2. SharePoint HTTPリクエスト（閲覧権限付与）**

1. 「**アクションの追加**」→「**SharePoint - HTTP要求の送信**」
2. 設定:

| 項目 | 設定値 |
|------|--------|
| **サイトのアドレス** | `https://tf1980.sharepoint.com/sites/abeam` |
| **メソッド** | `POST` |
| **URI** | `_api/web/lists/getbytitle('EMP_1_EmploymentRecords')/items(@{outputs('項目の取得')?['body/ID']})/roleassignments/addroleassignment(principalid=@{outputs('項目の取得')?['body/AuthorId']},roledefid=1073741826)` |
| **ヘッダー** | `{"Accept":"application/json;odata=verbose","Content-Type":"application/json;odata=verbose"}` |

> **💡 RoleDefId参考値**
> - 1073741829: フルコントロール
> - 1073741827: 編集
> - **1073741826: 投稿（閲覧）** ← 使用
> - 1073741924: 制限付き閲覧

---

#### 5-4. 「いいえの場合」の処理（差戻し）

**A. リストアイテムを更新**

1. 「**いいえの場合**」ブランチに「**SharePoint - 項目の更新**」を追加
2. 設定:

| 項目 | 設定値 |
|------|--------|
| **Stage1ApprovalStatus** | `差戻し` |
| **Stage1ApprovalComment** | `@{outputs('第1承認者への承認依頼')?['body/responses'][0]['comments']}` |
| **Stage1ApprovalDate** | `@{utcNow()}` |
| **OverallApproval** | `差戻し` |

**B. 申請者へメール送信**

1. 「**Office 365 Outlook - メールの送信 (V2)**」を追加
2. 設定:

| 項目 | 設定値 |
|------|--------|
| **宛先** | `@{outputs('項目の取得')?['body/AuthorEmail']}` |
| **件名** | `【差戻し】雇用調書 - @{outputs('項目の取得')?['body/FullName']}` |
| **本文** | ↓ 下記HTML |

```html
<p>雇用調書が差戻されました。</p>
<p><strong>申請者:</strong> @{outputs('項目の取得')?['body/FullName']}</p>
<p><strong>差戻理由:</strong><br>@{outputs('第1承認者への承認依頼')?['body/responses'][0]['comments']}</p>
<p><a href="@{outputs('項目の取得')?['body/{Link}']}">アイテムを確認</a></p>
```

---

### ステップ6: 第2承認者の結果チェック

**ステップ5と同じ処理を第2承認者用に作成します。**

#### 6-1. 条件アクションを追加
1. 「**第2承認者への承認依頼**」の下に「**条件**」を追加
2. 条件式:
   ```
   @outputs('第2承認者への承認依頼')?['body/outcome']
   が次の値に等しい
   Approve
   ```

#### 6-2. 「はいの場合」
- リストアイテムを更新（`Stage2ApprovalStatus = 承認`、`Stage2ApprovalComment`、`Stage2ApprovalDate`）
- 申請者権限を閲覧のみに変更（HTTPリクエスト×2）

#### 6-3. 「いいえの場合」
- リストアイテムを更新（`Stage2ApprovalStatus = 差戻し`、`OverallApproval = 差戻し`）
- 申請者へメール送信

---

### ステップ7: 最終承認結果の判定

#### 7-1. 条件アクションを追加
1. 第1・第2承認者の条件分岐の**後**に「**条件**」を追加
2. **詳細モード**に切り替え
3. 以下の式を入力:

```javascript
@and(
  equals(outputs('第1承認者への承認依頼')?['body/outcome'], 'Approve'),
  equals(outputs('第2承認者への承認依頼')?['body/outcome'], 'Approve')
)
```

---

#### 7-2. 「はいの場合」（両方承認完了）

**A. リストアイテムを更新**

| 項目 | 設定値 |
|------|--------|
| **OverallApproval** | `承認完了` |
| **ApprovalCompletedDate** | `@{utcNow()}` |

> ⚠️ **注意**: `ApprovalCompletedDate`列が存在しない場合は、事前にSharePointリストに追加してください。

**B. 全員へ完了通知メール**

1. 「**Office 365 Outlook - メールの送信 (V2)**」を追加
2. 設定:

| 項目 | 設定値 |
|------|--------|
| **宛先** | `@{outputs('項目の取得')?['body/AuthorEmail']};@{outputs('項目の取得')?['body/Stage1ApproversEmail']};@{outputs('項目の取得')?['body/Stage2ApproversEmail']}` |
| **件名** | `【承認完了】雇用調書 - @{outputs('項目の取得')?['body/FullName']}` |
| **本文** | ↓ 下記HTML |

```html
<p>雇用調書の承認が完了しました。</p>
<p><strong>申請者:</strong> @{outputs('項目の取得')?['body/FullName']}</p>
<p><strong>第1承認者:</strong> @{outputs('項目の取得')?['body/Stage1ApproversEmail']}} - 承認</p>
<p><strong>第2承認者:</strong> @{outputs('項目の取得')?['body/Stage2ApproversEmail']}} - 承認</p>
<p><strong>承認完了日時:</strong> @{utcNow()}</p>
<p><a href="@{outputs('項目の取得')?['body/{Link}']}">アイテムを確認</a></p>
```

---

#### 7-3. 「いいえの場合」（いずれかが差戻し）

**A. リストアイテムを更新**

| 項目 | 設定値 |
|------|--------|
| **OverallApproval** | `差戻し` |

**B. 申請者へ差戻し通知**

- ステップ5-4と同様のメール送信処理

---

### ステップ8: フローを保存してテスト

#### 8-1. 保存
1. 画面上部の「**保存**」ボタンをクリック
2. エラーがないか確認
3. エラーがある場合は、該当アクションを修正

#### 8-2. テスト実行
1. SharePointリスト `EMP_1_EmploymentRecords` を開く
2. 1件データを選択
3. `Stage1Approvers`と`Stage2Approvers`に承認者を設定（まだ設定していない場合）
4. 申請ボタンをクリック
5. Power Automateの「**実行履歴**」を確認

#### 8-3. 動作確認チェックリスト

- [ ] 承認者2人に同時にメールが届く
- [ ] 第1承認者が承認した時点で申請者が編集できなくなる
- [ ] 第2承認者が承認した時点で申請者が編集できなくなる
- [ ] 2人とも承認で「承認完了」になる
- [ ] 1人でも差戻しで「差戻し」になる
- [ ] 承認完了時に全員へメール送信される
- [ ] 差戻し時に申請者へメール送信される

---

## 🔧 トラブルシューティング

### エラー: ユーザーフィールドが取得できない

**症状**: `Stage1ApproversClaims`が空になる

**解決策**:
1. 「**項目の取得**」アクションを開く
2. 「**詳細オプションを表示する**」を展開
3. 「**フィールドの展開**」に以下を追加:
   ```
   Stage1Approvers,Stage2Approvers,Author
   ```

---

### エラー: HTTP要求が失敗する（403 Forbidden）

**症状**: 権限変更のHTTPリクエストで403エラー

**原因**: フロー実行者に権限がない

**解決策**:
1. フロー実行者にサイト管理者権限を付与
2. または、フローの接続設定で管理者アカウントを使用:
   - アクションの「**︙**」→「**接続の変更**」
   - 管理者アカウントで再接続

---

### エラー: メール送信先が空

**症状**: メール送信時に宛先が空でエラー

**原因**: ユーザーフィールドのプロパティ参照が不正

**解決策**:
`Stage1ApproversEmail`が機能しない場合、以下を使用:
```
@{outputs('項目の取得')?['body/Stage1Approvers'][0]['Email']}
```

または、複数承認者の場合:
```
@{join(outputs('項目の取得')?['body/Stage1Approvers']?['Email'], ';')}
```

---

### エラー: 並行実行されない

**症状**: 第1承認が完了してから第2承認が開始される

**原因**: 実行条件が正しく設定されていない

**解決策**:
1. 「**第2承認者への承認依頼**」の「**︙**」→「**実行条件の構成**」
2. 「**次の後に実行**」を `第1承認者への承認依頼` から `項目の取得` に変更
3. 保存して再テスト

---

## ✅ 完了チェックリスト

- [ ] 既存フローを複製して「EMP_2_雇用調書承認フロー」を作成
- [ ] 第1承認者への承認依頼を設定
- [ ] 第2承認者への承認依頼を設定（並行実行）
- [ ] 第1承認者の結果チェック条件を設定
- [ ] 第2承認者の結果チェック条件を設定
- [ ] 申請者権限変更のHTTPリクエストを設定（両承認者分）
- [ ] 最終承認結果判定の条件を設定
- [ ] 承認完了時のメール通知を設定
- [ ] 差戻し時のメール通知を設定
- [ ] フローを保存
- [ ] テスト実行で動作確認

---

## 📚 関連ドキュメント

- [EMP_2並行承認設計書](./EMP_2_PARALLEL_APPROVAL_DESIGN.md)
- [雇用調書承認セットアップガイド](./EMPLOYMENT_APPROVAL_SETUP.md)

---

**作成者**: GitHub Copilot  
**作成日**: 2025/10/18  
**ステータス**: ✅ 完成
