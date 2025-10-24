# EMP_2_雇用調書承認フロー - 並行2段階承認設計書

**作成日**: 2025/10/18
**目的**: EMP_1を拡張し、2人の承認者による並行承認フローを実装

## 承認フロー概要

```
申請ボタン押下
    ↓
[トリガー: 選択したアイテム]
    ↓
項目の取得
    ↓
┌─────────────────────┐
│  並行承認（2人）      │
│  ・承認者A          │
│  ・承認者B          │
└─────────────────────┘
    ↓
いずれか1人が承認
    ↓
申請者権限を「閲覧のみ」に変更
    ↓
2人目の承認待ち
    ↓
┌─────────────────────────┐
│ 両方承認？             │
├─────────────────────────┤
│ はい → 承認完了        │
│ いいえ → 差戻し        │
└─────────────────────────┘
```

## フロー構造

### 1. トリガー
- **種類**: SharePoint - 選択したアイテム
- **リスト**: EMP_1_EmploymentRecords
- **変更なし**（既存のまま）

### 2. アクション構成

#### 2.1 項目の取得
```
アクション: SharePoint - 項目の取得
サイトアドレス: https://tf1980.sharepoint.com/sites/abeam
リスト名: EMP_1_EmploymentRecords
ID: @triggerBody()?['entity']['ID']
```

#### 2.2 第1承認者への承認依頼
```
アクション: 承認 - 承認を開始して結果を待機
承認の種類: 承認/拒否 - 最初に応答
タイトル: 【第1承認依頼】雇用調書 - @{outputs('項目の取得')?['body/FullName']}
割り当て先: @{outputs('項目の取得')?['body/Stage1ApproversClaims']}
詳細:
  申請者: @{outputs('項目の取得')?['body/FullName']}
  職員番号: @{outputs('項目の取得')?['body/EmployeeID']}
  採用理由: @{outputs('項目の取得')?['body/EmploymentReason']}
  部署: @{outputs('項目の取得')?['body/Department']}
アイテムリンク: @{outputs('項目の取得')?['body/{Link}']}
```

#### 2.3 第2承認者への承認依頼（並行実行）
```
アクション: 承認 - 承認を開始して結果を待機
承認の種類: 承認/拒否 - 最初に応答
タイトル: 【第2承認依頼】雇用調書 - @{outputs('項目の取得')?['body/FullName']}
割り当て先: @{outputs('項目の取得')?['body/Stage2ApproversClaims']}
詳細: （第1承認者と同じ）
アイテムリンク: @{outputs('項目の取得')?['body/{Link}']}

実行条件設定: 「項目の取得」の後に並行実行
```

#### 2.4 条件：第1承認者の結果チェック
```
条件名: 第1承認者結果チェック
条件: @{outputs('第1承認者への承認依頼')?['body/outcome']} が次の値に等しい 'Approve'

【はいの場合】
  → リストアイテムの更新
     - Stage1ApprovalStatus = "承認"
     - Stage1ApprovalComment = @{outputs('第1承認者への承認依頼')?['body/responses'][0]['comments']}
     - Stage1ApprovalDate = @{utcNow()}
  
  → SharePoint HTTPリクエスト: 申請者権限を閲覧のみに変更
     URI: _api/web/lists/getbytitle('EMP_1_EmploymentRecords')/items(@{outputs('項目の取得')?['body/ID']})/breakroleinheritance(copyRoleAssignments=false)
     Method: POST
  
  → SharePoint HTTPリクエスト: 閲覧権限を付与
     URI: _api/web/lists/getbytitle('EMP_1_EmploymentRecords')/items(@{outputs('項目の取得')?['body/ID']})/roleassignments/addroleassignment(principalid=@{outputs('項目の取得')?['body/AuthorId']},roledefid=1073741826)
     Method: POST

【いいえの場合】
  → リストアイテムの更新
     - Stage1ApprovalStatus = "差戻し"
     - Stage1ApprovalComment = @{outputs('第1承認者への承認依頼')?['body/responses'][0]['comments']}
     - Stage1ApprovalDate = @{utcNow()}
     - OverallApproval = "差戻し"
  
  → メール送信（申請者へ差戻し通知）
```

#### 2.5 条件：第2承認者の結果チェック
```
条件名: 第2承認者結果チェック
条件: @{outputs('第2承認者への承認依頼')?['body/outcome']} が次の値に等しい 'Approve'

【はいの場合】
  → リストアイテムの更新
     - Stage2ApprovalStatus = "承認"
     - Stage2ApprovalComment = @{outputs('第2承認者への承認依頼')?['body/responses'][0]['comments']}
     - Stage2ApprovalDate = @{utcNow()}
  
  → 申請者権限を閲覧のみに変更（第1承認者と同じ処理）

【いいえの場合】
  → リストアイテムの更新
     - Stage2ApprovalStatus = "差戻し"
     - Stage2ApprovalComment = @{outputs('第2承認者への承認依頼')?['body/responses'][0]['comments']}
     - Stage2ApprovalDate = @{utcNow()}
     - OverallApproval = "差戻し"
  
  → メール送信（申請者へ差戻し通知）
```

#### 2.6 条件：両方の承認結果チェック
```
条件名: 両承認者の結果確認
条件: 
  AND(
    @{equals(outputs('第1承認者への承認依頼')?['body/outcome'], 'Approve')},
    @{equals(outputs('第2承認者への承認依頼')?['body/outcome'], 'Approve')}
  )

【はいの場合】（両方承認）
  → リストアイテムの更新
     - OverallApproval = "承認完了"
     - ApprovalCompletedDate = @{utcNow()}
  
  → メール送信（申請者・承認者全員へ完了通知）
     宛先: @{outputs('項目の取得')?['body/AuthorEmail']};@{outputs('項目の取得')?['body/Stage1ApproversEmail']};@{outputs('項目の取得')?['body/Stage2ApproversEmail']}
     件名: 【承認完了】雇用調書 - @{outputs('項目の取得')?['body/FullName']}
     本文: 
       雇用調書の承認が完了しました。
       
       申請者: @{outputs('項目の取得')?['body/FullName']}
       第1承認者: @{outputs('項目の取得')?['body/Stage1ApproversEmail']} - 承認
       第2承認者: @{outputs('項目の取得')?['body/Stage2ApproversEmail']} - 承認
       
       承認完了日時: @{utcNow()}

【いいえの場合】（いずれかが差戻し）
  → リストアイテムの更新
     - OverallApproval = "差戻し"
  
  → メール送信（申請者へ差戻し通知）
     件名: 【差戻し】雇用調書 - @{outputs('項目の取得')?['body/FullName']}
```

## 必要なSharePointリスト列

既存の`EMP_1_EmploymentRecords`には以下の列が既に存在します：

### 承認者関連（既存）
| 列名 | 種類 | 必須 | 説明 |
|------|------|------|------|
| Stage1Approvers | ユーザーまたはグループ | はい | 第1承認者 |
| Stage2Approvers | ユーザーまたはグループ | はい | 第2承認者 |

### 承認ステータス（既存）
| 列名 | 種類 | 選択肢 | 既定値 |
|------|------|--------|--------|
| Stage1ApprovalStatus | 選択 | 未承認/承認/差戻し | 未承認 |
| Stage2ApprovalStatus | 選択 | 未承認/承認/差戻し | 未承認 |
| OverallApproval | 選択 | 未申請/承認待ち/承認完了/差戻し | 未申請 |

### 承認コメント・日時（既存）
| 列名 | 種類 | 説明 |
|------|------|------|
| Stage1ApprovalComment | 複数行テキスト | 第1承認者のコメント |
| Stage2ApprovalComment | 複数行テキスト | 第2承認者のコメント |
| Stage1ApprovalDate | 日付と時刻 | 第1承認者承認日時 |
| Stage2ApprovalDate | 日付と時刻 | 第2承認者承認日時 |

### 追加が必要な列
| 列名 | 種類 | 説明 |
|------|------|------|
| ApprovalCompletedDate | 日付と時刻 | 承認完了日時（両方承認時に記録） |

## 権限制御の詳細

### 申請者権限の変更タイミング
- **いつ**: 承認者AまたはBのいずれか1人が承認した時点
- **変更内容**: 
  - アイテムの固有権限を有効化（`breakroleinheritance`）
  - 申請者に「閲覧」権限（RoleDefId: 1073741826）のみ付与
  - 編集権限を削除

### SharePoint HTTP要求の詳細

#### 1. 権限の継承を解除
```
URI: _api/web/lists/getbytitle('EMP_1_EmploymentRecords')/items(@{outputs('項目の取得')?['body/ID']})/breakroleinheritance(copyRoleAssignments=false)
Method: POST
Headers:
  Accept: application/json;odata=verbose
  Content-Type: application/json;odata=verbose
```

#### 2. 閲覧権限を付与
```
URI: _api/web/lists/getbytitle('EMP_1_EmploymentRecords')/items(@{outputs('項目の取得')?['body/ID']})/roleassignments/addroleassignment(principalid=@{outputs('項目の取得')?['body/AuthorId']},roledefid=1073741826)
Method: POST
Headers:
  Accept: application/json;odata=verbose
  Content-Type: application/json;odata=verbose
```

**RoleDefId参考値:**
- 1073741829: フルコントロール
- 1073741828: デザイン
- 1073741827: 編集
- 1073741826: 投稿（閲覧）
- 1073741924: 制限付き閲覧

## Power Automate UIでの実装手順

### ステップ1: 既存フローの複製
1. https://make.powerautomate.com を開く
2. 「EMP_1_雇用調書承認フロー」を検索
3. 右上「︙」→「名前を付けて保存」
4. 新しい名前：`EMP_2_雇用調書承認フロー`

### ステップ2: 並行承認の設定

#### トリガーと項目取得（変更なし）
既存の「manual」トリガーと「項目の取得」アクションはそのまま

#### 第1承認者への承認依頼
既存の承認アクションを複製して名前変更：
- アクション名：`第1承認者への承認依頼`
- 割り当て先：`@{outputs('項目の取得')?['body/Stage1ApproversClaims']}`
- タイトル：`【第1承認依頼】雇用調書 - @{outputs('項目の取得')?['body/FullName']}`

#### 第2承認者への承認依頼（並行実行）
1. 「第1承認者への承認依頼」を複製
2. アクション名：`第2承認者への承認依頼`
3. 割り当て先：`@{outputs('項目の取得')?['body/Stage2ApproversClaims']}`
4. タイトル：`【第2承認依頼】雇用調書 - @{outputs('項目の取得')?['body/FullName']}`
5. **重要**: アクション設定（︙）→「実行条件の構成」
   - 「項目の取得」の後に実行
   - 第1承認者と並行実行になるように設定

#### 第1承認者結果チェック
1. 「条件」アクションを追加
2. 条件式：
   ```
   @outputs('第1承認者への承認依頼')?['body/outcome']
   が次の値に等しい
   Approve
   ```
3. **はいの場合**:
   - SharePoint - 項目の更新（Stage1ApprovalStatus = "承認"）
   - SharePoint HTTPリクエスト（権限変更）×2
4. **いいえの場合**:
   - SharePoint - 項目の更新（Stage1ApprovalStatus = "差戻し"、OverallApproval = "差戻し"）
   - Office 365 Outlook - メールの送信

#### 第2承認者結果チェック
第1承認者と同様の条件分岐を作成（Stage2フィールドに変更）

#### 最終結果チェック
1. 「条件」アクションを追加
2. 詳細設定モードで式を入力：
   ```
   @and(
     equals(outputs('第1承認者への承認依頼')?['body/outcome'], 'Approve'),
     equals(outputs('第2承認者への承認依頼')?['body/outcome'], 'Approve')
   )
   ```
3. **はいの場合**: 承認完了処理
   - SharePoint - 項目の更新（OverallApproval = "承認完了"、ApprovalCompletedDate = @{utcNow()}）
   - Office 365 Outlook - メールの送信（申請者・両承認者へ完了通知）
4. **いいえの場合**: 差戻し処理
   - SharePoint - 項目の更新（OverallApproval = "差戻し"）
   - Office 365 Outlook - メールの送信（申請者へ差戻し通知）

### ステップ3: テスト実行
1. SharePointリストで1件データを選択
2. `Stage1Approvers`と`Stage2Approvers`に承認者を設定
3. 申請ボタンをクリック
4. 承認者2人にメールが届くことを確認
5. 1人が承認 → 申請者が編集できないことを確認
6. 2人とも承認 → 「承認完了」になることを確認

## 注意事項

1. **SharePoint列の追加**
   - `ApprovalCompletedDate`列を追加してください
   - 既存の`Stage1Approvers`, `Stage2Approvers`フィールドを使用

2. **権限設定**
   - SharePoint HTTPリクエストを実行するには、フロー実行者に適切な権限が必要
   - サイト管理者権限推奨

3. **並行実行の制御**
   - 2つの承認アクションは同時に実行されます
   - どちらかが先に完了しても、もう一方は継続します

4. **エラーハンドリング**
   - 権限変更エラー時のリトライロジック追加を推奨
   - メール送信失敗時の代替通知方法を検討

5. **ユーザーフィールドの参照**
   - Power Automateでユーザーフィールドを参照する場合：
     - メールアドレス: `Stage1ApproversEmail`, `Stage2ApproversEmail`
     - Claims形式: `Stage1ApproversClaims`, `Stage2ApproversClaims`
     - 表示名: `Stage1ApproversDisplayName`, `Stage2ApproversDisplayName`

## 拡張案

### 将来的な機能追加候補
- [ ] 3人以上の承認者対応
- [ ] 承認期限の設定
- [ ] 承認履歴の記録（別リスト）
- [ ] リマインダーメール自動送信
- [ ] モバイル通知対応
- [ ] 承認状況ダッシュボード

---
**作成者**: GitHub Copilot  
**レビュー**: 要確認  
**実装予定**: 2025/10/18
