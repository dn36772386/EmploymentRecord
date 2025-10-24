# リスト設計書 (EMP_1_EmploymentRecords)

生成日時: 2025/10/18 18:19:21
サイト: https://tf1980.sharepoint.com/sites/abeam
リスト: EMP_1_EmploymentRecords

## 基本情報
- Title: EMP_1_EmploymentRecords
- Id: 9898ad51-5d08-4c68-97c8-e8123b70bc44
- URL: /sites/abeam/Lists/EMP_1_EmploymentRecords/view1.aspx
- 説明: 
- テンプレート: 100
- アイテム数: 22
- Hidden: False
- ContentTypesEnabled: False
- 添付ファイル: True
- フォルダー作成可: False
- バージョン管理: Major=True Minor=False ForceCheckout=False
- 版数上限: MajorLimit=50 MajorWithMinorLimit=0
- 読取権限(ReadSecurity): 1 / 書込権限(WriteSecurity): 1
- 固有権限(HasUniqueRoleAssignments): True

## フィールド一覧

### 採用理由 (EmploymentReason)
- 型: Choice
- 必須: False / Hidden: False / ReadOnly: False
- 選択肢: 新規 | 更新(変更あり)


### 職員番号 (EmployeeID)
- 型: Number
- 必須: False / Hidden: False / ReadOnly: False


### 所属 (Department)
- 型: Choice
- 必須: False / Hidden: False / ReadOnly: False
- 選択肢: 人事課 | 研究支援課 | 財務課 | 情報基盤課


### 担当グループ (GroupName)
- 型: Text
- 必須: False / Hidden: False / ReadOnly: False


### 雇用責任者 (EmploymentOwner)
- 型: User
- 必須: False / Hidden: False / ReadOnly: False
- Lookup: List={52e51bb0-a252-480a-8758-fbec9c73707d}, Field=, Multi=False


### 事務担当者 (AdministrativeClerk)
- 型: User
- 必須: False / Hidden: False / ReadOnly: False
- Lookup: List={52e51bb0-a252-480a-8758-fbec9c73707d}, Field=, Multi=False


### 氏名 (FullName)
- 型: Text
- 必須: False / Hidden: False / ReadOnly: False


### フリガナ (Furigana)
- 型: Text
- 必須: False / Hidden: False / ReadOnly: False


### 性別 (Gender)
- 型: Choice
- 必須: False / Hidden: False / ReadOnly: False
- 選択肢: 男 | 女


### 生年月日 (BirthDate)
- 型: DateTime
- 必須: False / Hidden: False / ReadOnly: False


### 住所 (Address)
- 型: Text
- 必須: False / Hidden: False / ReadOnly: False


### 郵便番号 (PostalCode)
- 型: Text
- 必須: False / Hidden: False / ReadOnly: False


### 本人連絡先 (ContactNumber)
- 型: Text
- 必須: False / Hidden: False / ReadOnly: False


### 国籍 (Nationality)
- 型: Text
- 必須: False / Hidden: False / ReadOnly: False


### 在留資格 (ResidenceStatus)
- 型: Text
- 必須: False / Hidden: False / ReadOnly: False


### 在留期限 (ResidenceLimit)
- 型: DateTime
- 必須: False / Hidden: False / ReadOnly: False


### 資格外活動許可 (WorkPermit)
- 型: Choice
- 必須: False / Hidden: False / ReadOnly: False
- 選択肢: 有 | 無


### 区分 (EmploymentType)
- 型: Choice
- 必須: False / Hidden: False / ReadOnly: False
- 選択肢: フルタイム | パートタイム


### 職種 (JobTitle)
- 型: Text
- 必須: False / Hidden: False / ReadOnly: False


### 契約期間開始 (StartDate)
- 型: DateTime
- 必須: False / Hidden: False / ReadOnly: False


### 契約期間終了 (EndDate)
- 型: DateTime
- 必須: False / Hidden: False / ReadOnly: False


### 更新上限有無 (RenewalFlag)
- 型: Choice
- 必須: False / Hidden: False / ReadOnly: False
- 選択肢: 有 | 無


### 更新上限日 (RenewalLimit)
- 型: DateTime
- 必須: False / Hidden: False / ReadOnly: False


### 勤務場所 (WorkLocation)
- 型: Text
- 必須: False / Hidden: False / ReadOnly: False


### 業務内容 (WorkDescription)
- 型: Note
- 必須: False / Hidden: False / ReadOnly: False


### 業務内容の変更範囲 (WorkChangeScope)
- 型: Choice
- 必須: False / Hidden: False / ReadOnly: False
- 選択肢: 変更なし | 業務拡大 | 業務縮小


### 勤務日数（週） (WorkDays)
- 型: Number
- 必須: False / Hidden: False / ReadOnly: False


### 勤務曜日 (WorkWeekdaysChoice)
- 型: MultiChoice
- 必須: False / Hidden: False / ReadOnly: False
- 選択肢: 月 | 火 | 水 | 木 | 金 | 土 | 日


### 休日 (HolidaysChoice)
- 型: MultiChoice
- 必須: False / Hidden: False / ReadOnly: False
- 選択肢: 月 | 火 | 水 | 木 | 金 | 土 | 日


### 勤務開始時刻 (StartTime)
- 型: DateTime
- 必須: False / Hidden: False / ReadOnly: False


### 勤務終了時刻 (EndTime)
- 型: DateTime
- 必須: False / Hidden: False / ReadOnly: False


### 休憩時間 (BreakTime)
- 型: Text
- 必須: False / Hidden: False / ReadOnly: False


### 1日勤務時間 (DailyWorkHours)
- 型: Number
- 必須: False / Hidden: False / ReadOnly: False


### 賃金形態 (PayType)
- 型: Choice
- 必須: False / Hidden: False / ReadOnly: False
- 選択肢: 月給 | 時給 | 日給


### 賃金単価 (PayRate)
- 型: Number
- 必須: False / Hidden: False / ReadOnly: False


### 執行見込み総額 (ExpenseEstimate)
- 型: Currency
- 必須: False / Hidden: False / ReadOnly: False


### 人件費番号 (HRExpenseCode)
- 型: Text
- 必須: False / Hidden: False / ReadOnly: False


### 第1段承認者（部門） (Stage1Approvers)
- 型: UserMulti
- 必須: False / Hidden: False / ReadOnly: False
- Lookup: List={52e51bb0-a252-480a-8758-fbec9c73707d}, Field=, Multi=True


### 第2段承認者（管理部門） (Stage2Approvers)
- 型: UserMulti
- 必須: False / Hidden: False / ReadOnly: False
- Lookup: List={52e51bb0-a252-480a-8758-fbec9c73707d}, Field=, Multi=True


### 全体承認状態 (OverallApproval)
- 型: Text
- 必須: False / Hidden: False / ReadOnly: False


### 備考 (Remarks)
- 型: Note
- 必須: False / Hidden: False / ReadOnly: False


### 申請ボタン (SubmitBtn)
- 型: Text
- 必須: False / Hidden: False / ReadOnly: False


### プロジェクト (ProjectCodeLookup)
- 型: LookupMulti
- 必須: False / Hidden: False / ReadOnly: False
- Lookup: List=869efb95-b706-4bb4-9f0f-41daa970fc35, Field=Title, Multi=True


### 第1段承認ステータス (Stage1ApprovalStatus)
- 型: Choice
- 必須: False / Hidden: False / ReadOnly: False
- 選択肢: 未申請 | 申請中 | 承認 | 却下 | 差戻し


### 第1段承認コメント (Stage1ApprovalComment)
- 型: Note
- 必須: False / Hidden: False / ReadOnly: False


### 第1段承認日時 (Stage1ApprovalDate)
- 型: DateTime
- 必須: False / Hidden: False / ReadOnly: False


### 第2段承認ステータス (Stage2ApprovalStatus)
- 型: Choice
- 必須: False / Hidden: False / ReadOnly: False
- 選択肢: 未申請 | 申請中 | 承認 | 却下 | 差戻し


### 第2段承認コメント (Stage2ApprovalComment)
- 型: Note
- 必須: False / Hidden: False / ReadOnly: False


### 第2段承認日時 (Stage2ApprovalDate)
- 型: DateTime
- 必須: False / Hidden: False / ReadOnly: False


### 申請日時 (SubmittedDate)
- 型: DateTime
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
- 表示列: ID, EmployeeID, FullName, Department, ProjectCodeLookup, EmploymentType, StartDate, EndDate, WorkLocation, PayType, PayRate, Modified, Created, Stage1ApprovalStatus, Stage1ApprovalComment, Stage1ApprovalDate, Stage2ApprovalStatus, Stage2ApprovalComment, Stage2ApprovalDate, SubmittedDate


### 雇用調書詳細 (Default=True)
- RowLimit: 30
- 表示列: ID, SubmitBtn, OverallApproval, EmploymentReason, EmployeeID, Department, GroupName, FullName, Furigana, Gender, BirthDate, Address, PostalCode, ContactNumber, Nationality, EmploymentType, JobTitle, StartDate, EndDate, RenewalFlag, RenewalLimit, WorkLocation, WorkDescription, WorkDays, DailyWorkHours, PayType, PayRate, ProjectCodeLookup, ExpenseEstimate, HRExpenseCode, Remarks, Modified, Created, SubmittedDate, Stage1ApprovalComment, Stage1ApprovalStatus, Stage1Approvers, Stage1ApprovalDate, Stage2ApprovalComment, Stage2ApprovalStatus, Stage2Approvers, Stage2ApprovalDate, Author


---
(本書は export-all-lists.ps1 により自動生成されました)
