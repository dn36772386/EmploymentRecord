# リスト設計書 (EMP_1_Projects)

生成日時: 2025/10/18 18:19:22
サイト: https://tf1980.sharepoint.com/sites/abeam
リスト: EMP_1_Projects

## 基本情報
- Title: EMP_1_Projects
- Id: 869efb95-b706-4bb4-9f0f-41daa970fc35
- URL: /sites/abeam/Lists/EMP_1_Projects/view.aspx
- 説明: 
- テンプレート: 100
- アイテム数: 20
- Hidden: False
- ContentTypesEnabled: False
- 添付ファイル: True
- フォルダー作成可: False
- バージョン管理: Major=True Minor=False ForceCheckout=False
- 版数上限: MajorLimit=50 MajorWithMinorLimit=0
- 読取権限(ReadSecurity): 1 / 書込権限(WriteSecurity): 1
- 固有権限(HasUniqueRoleAssignments): False

## フィールド一覧

### プロジェクトコード (ProjectCode)
- 型: Text
- 必須: True / Hidden: False / ReadOnly: False


### プロジェクト名 (ProjectName)
- 型: Text
- 必須: True / Hidden: False / ReadOnly: False


### 目的(予算)コード (PurposeBudgetCode)
- 型: Text
- 必須: False / Hidden: False / ReadOnly: False


### 目的(予算)名称 (PurposeBudgetName)
- 型: Text
- 必須: False / Hidden: False / ReadOnly: False


### 目的(執行)コード (PurposeExecCode)
- 型: Text
- 必須: False / Hidden: False / ReadOnly: False


### 目的(執行)名称 (PurposeExecName)
- 型: Text
- 必須: False / Hidden: False / ReadOnly: False


### 部門コード (DeptCode)
- 型: Text
- 必須: False / Hidden: False / ReadOnly: False


### 部門名称 (DeptName)
- 型: Text
- 必須: False / Hidden: False / ReadOnly: False


### 財源コード (FundingCode)
- 型: Text
- 必須: False / Hidden: False / ReadOnly: False


### 財源名称 (FundingName)
- 型: Text
- 必須: False / Hidden: False / ReadOnly: False


### 有効期限 (ValidUntil)
- 型: DateTime
- 必須: False / Hidden: False / ReadOnly: False


### 予算財会処理 (BudgetProcFlag)
- 型: Choice
- 必須: False / Hidden: False / ReadOnly: False
- 選択肢: 済 | 未


### 備考 (Notes)
- 型: Note
- 必須: False / Hidden: False / ReadOnly: False


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


### プロジェクト一覧 (Default=True)
- RowLimit: 30
- 表示列: ID, ProjectCode, ProjectName, PurposeBudgetCode, PurposeBudgetName, PurposeExecCode, PurposeExecName, DeptCode, DeptName, FundingCode, FundingName, ValidUntil, BudgetProcFlag, Notes, Modified, Editor


---
(本書は export-all-lists.ps1 により自動生成されました)
