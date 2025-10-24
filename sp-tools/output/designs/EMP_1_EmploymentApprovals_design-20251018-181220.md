# リスト設計書 (EMP_1_EmploymentApprovals)

生成日時: 2025/10/18 18:12:20
サイト: https://tf1980.sharepoint.com/sites/abeam
リスト: EMP_1_EmploymentApprovals

## 基本情報
- Title: EMP_1_EmploymentApprovals
- Id: 82f4f541-614b-4885-a13a-3f3a618109f9
- URL: /sites/abeam/Lists/EMP_1_EmploymentApprovals/view.aspx
- 説明: 
- テンプレート: 100
- アイテム数: 26
- Hidden: False
- ContentTypesEnabled: False
- 添付ファイル: True
- フォルダー作成可: False
- バージョン管理: Major=True Minor=False ForceCheckout=False
- 版数上限: MajorLimit=50 MajorWithMinorLimit=0
- 読取権限(ReadSecurity): 1 / 書込権限(WriteSecurity): 1
- 固有権限(HasUniqueRoleAssignments): False

## フィールド一覧

### 親レコード (ParentRecord)
- 型: Lookup
- 必須: True / Hidden: False / ReadOnly: False
- Lookup: List={e7e9aced-b339-48c1-adab-be261f506f85}, Field=Title, Multi=False


### ステージ番号 (StageNumber)
- 型: Number
- 必須: False / Hidden: False / ReadOnly: False


### ステージ種別 (StageType)
- 型: Choice
- 必須: False / Hidden: False / ReadOnly: False
- 選択肢: 部門 | 管理部門 | その他


### 並列グループID (ParallelGroupId)
- 型: Text
- 必須: False / Hidden: False / ReadOnly: False


### 必須 (IsRequired)
- 型: Boolean
- 必須: False / Hidden: False / ReadOnly: False


### 承認者 (Approver)
- 型: User
- 必須: False / Hidden: False / ReadOnly: False
- Lookup: List={52e51bb0-a252-480a-8758-fbec9c73707d}, Field=, Multi=False


### 承認者メール (ApproverEmail)
- 型: Text
- 必須: False / Hidden: False / ReadOnly: False


### 状態 (Status)
- 型: Choice
- 必須: False / Hidden: False / ReadOnly: False
- 選択肢: 下書き | 申請中 | 承認 | 却下 | 差戻し | 期限切れ


### 期限 (DueDate)
- 型: DateTime
- 必須: False / Hidden: False / ReadOnly: False


### 処理日時 (ActionedAt)
- 型: DateTime
- 必須: False / Hidden: False / ReadOnly: False


### コメント (Note)
- 型: Note
- 必須: False / Hidden: False / ReadOnly: False


### 実行者 (ActionedBy)
- 型: User
- 必須: False / Hidden: False / ReadOnly: False
- Lookup: List={52e51bb0-a252-480a-8758-fbec9c73707d}, Field=, Multi=False


### コメントの設定 (_CommentFlags)
- 型: Lookup
- 必須: False / Hidden: True / ReadOnly: True


### コメント数 (_CommentCount)
- 型: Lookup
- 必須: False / Hidden: True / ReadOnly: True


## ビュー

### すべてのアイテム (Default=False)
- RowLimit: 30
- 表示列: LinkTitle


### 承認履歴一覧 (Default=True)
- RowLimit: 30
- 表示列: ID, ParentRecord, StageNumber, StageType, ParallelGroupId, IsRequired, Approver, ApproverEmail, Status, DueDate, ActionedAt, Note, ActionedBy, Order, Modified, Editor


---
(本書は export-all-lists.ps1 により自動生成されました)
