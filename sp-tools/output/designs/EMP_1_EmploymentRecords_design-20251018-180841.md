# リスト設計書 (EMP_1_EmploymentRecords)

生成日時: 2025/10/18 18:08:41
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

### 権限サマリ
- ロール割当の数: 8

## フィールド一覧
### コンテンツ タイプの ID (ContentTypeId)
- 型(Type): ContentTypeId
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: True / Unique: False / Indexed: False

### タイトル (Title)
- 型(Type): Text
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: False / Unique: False / Indexed: False
- 最大長: 255

### 承認者のコメント (_ModerationComments)
- 型(Type): Note
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: True / Unique: False / Indexed: False
- 複数行: 行数=6 / RichText=False / AppendOnly=False

### ファイルの種類 (File_x0020_Type)
- 型(Type): Text
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: True / Unique: False / Indexed: False
- 最大長: 255

### 色 (_ColorHex)
- 型(Type): Text
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: True / Unique: False / Indexed: False
- 最大長: 255

### 色タグ (_ColorTag)
- 型(Type): Text
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: True / Unique: False / Indexed: False
- 最大長: 255

### 絵文字 (_Emoji)
- 型(Type): Text
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: True / Unique: False / Indexed: False
- 最大長: 255

### コンプライアンス資産 ID (ComplianceAssetId)
- 型(Type): Text
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: True / Unique: False / Indexed: False
- 最大長: 255

### 採用理由 (EmploymentReason)
- 型(Type): Choice
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: False / Unique: False / Indexed: False
- 選択肢: 新規 | 更新(変更あり)

### 職員番号 (EmployeeID)
- 型(Type): Number
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: False / Unique: False / Indexed: False

### 所属 (Department)
- 型(Type): Choice
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: False / Unique: False / Indexed: False
- 選択肢: 人事課 | 研究支援課 | 財務課 | 情報基盤課

### 担当グループ (GroupName)
- 型(Type): Text
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: False / Unique: False / Indexed: False
- 最大長: 255

### 雇用責任者 (EmploymentOwner)
- 型(Type): User
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: False / Unique: False / Indexed: False

### 事務担当者 (AdministrativeClerk)
- 型(Type): User
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: False / Unique: False / Indexed: False

### 氏名 (FullName)
- 型(Type): Text
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: False / Unique: False / Indexed: False
- 最大長: 255

### フリガナ (Furigana)
- 型(Type): Text
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: False / Unique: False / Indexed: False
- 最大長: 255

### 性別 (Gender)
- 型(Type): Choice
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: False / Unique: False / Indexed: False
- 選択肢: 男 | 女

### 生年月日 (BirthDate)
- 型(Type): DateTime
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: False / Unique: False / Indexed: False

### 住所 (Address)
- 型(Type): Text
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: False / Unique: False / Indexed: False
- 最大長: 255

### 郵便番号 (PostalCode)
- 型(Type): Text
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: False / Unique: False / Indexed: False
- 最大長: 255

### 本人連絡先 (ContactNumber)
- 型(Type): Text
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: False / Unique: False / Indexed: False
- 最大長: 255

### 国籍 (Nationality)
- 型(Type): Text
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: False / Unique: False / Indexed: False
- 最大長: 255

### 在留資格 (ResidenceStatus)
- 型(Type): Text
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: False / Unique: False / Indexed: False
- 最大長: 255

### 在留期限 (ResidenceLimit)
- 型(Type): DateTime
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: False / Unique: False / Indexed: False

### 資格外活動許可 (WorkPermit)
- 型(Type): Choice
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: False / Unique: False / Indexed: False
- 選択肢: 有 | 無

### 区分 (EmploymentType)
- 型(Type): Choice
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: False / Unique: False / Indexed: False
- 選択肢: フルタイム | パートタイム

### 職種 (JobTitle)
- 型(Type): Text
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: False / Unique: False / Indexed: False
- 最大長: 255

### 契約期間開始 (StartDate)
- 型(Type): DateTime
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: False / Unique: False / Indexed: False

### 契約期間終了 (EndDate)
- 型(Type): DateTime
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: False / Unique: False / Indexed: False

### 更新上限有無 (RenewalFlag)
- 型(Type): Choice
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: False / Unique: False / Indexed: False
- 選択肢: 有 | 無

### 更新上限日 (RenewalLimit)
- 型(Type): DateTime
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: False / Unique: False / Indexed: False

### 勤務場所 (WorkLocation)
- 型(Type): Text
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: False / Unique: False / Indexed: False
- 最大長: 255

### 業務内容 (WorkDescription)
- 型(Type): Note
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: False / Unique: False / Indexed: False
- 複数行: 行数=6 / RichText=False / AppendOnly=False

### 業務内容の変更範囲 (WorkChangeScope)
- 型(Type): Choice
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: False / Unique: False / Indexed: False
- 選択肢: 変更なし | 業務拡大 | 業務縮小

### 勤務日数（週） (WorkDays)
- 型(Type): Number
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: False / Unique: False / Indexed: False

### 勤務曜日 (WorkWeekdaysChoice)
- 型(Type): MultiChoice
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: False / Unique: False / Indexed: False
- 選択肢: 月 | 火 | 水 | 木 | 金 | 土 | 日

### 休日 (HolidaysChoice)
- 型(Type): MultiChoice
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: False / Unique: False / Indexed: False
- 選択肢: 月 | 火 | 水 | 木 | 金 | 土 | 日

### 勤務開始時刻 (StartTime)
- 型(Type): DateTime
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: False / Unique: False / Indexed: False

### 勤務終了時刻 (EndTime)
- 型(Type): DateTime
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: False / Unique: False / Indexed: False

### 休憩時間 (BreakTime)
- 型(Type): Text
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: False / Unique: False / Indexed: False
- 最大長: 255

### 1日勤務時間 (DailyWorkHours)
- 型(Type): Number
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: False / Unique: False / Indexed: False

### 賃金形態 (PayType)
- 型(Type): Choice
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: False / Unique: False / Indexed: False
- 選択肢: 月給 | 時給 | 日給

### 賃金単価 (PayRate)
- 型(Type): Number
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: False / Unique: False / Indexed: False

### 執行見込み総額 (ExpenseEstimate)
- 型(Type): Currency
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: False / Unique: False / Indexed: False

### 人件費番号 (HRExpenseCode)
- 型(Type): Text
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: False / Unique: False / Indexed: False
- 最大長: 255

### 第1段承認者（部門） (Stage1Approvers)
- 型(Type): UserMulti
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: False / Unique: False / Indexed: False

### 第2段承認者（管理部門） (Stage2Approvers)
- 型(Type): UserMulti
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: False / Unique: False / Indexed: False

### 全体承認状態 (OverallApproval)
- 型(Type): Text
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: False / Unique: False / Indexed: False
- 最大長: 255
- 列書式(JSON):
`$lang
{"$schema":"https://developer.microsoft.com/json-schemas/sp/v2/column-formatting.schema.json","elmType":"div","style":{"cursor":"default","min-height":"20px","min-width":"130px","display":"inline-flex","align-items":"center","text-overflow":"ellipsis","overflow":"hidden","white-space":"nowrap","box-sizing":"border-box","padding":"2px 8px 2px 8px","margin":"9px 0px 9px 0px","border-radius":"14px","border-width":"1px","border-style":"solid"},"attributes":{"class":{"operator":":","operands":[{"operator":"==","operands":["[$OverallApproval]","未申請"]},"sp-css-borderColor-neutralTertiaryAlt sp-css-backgroundColor-BgLightGray--hover",{"operator":":","operands":[{"operator":"||","operands":[{"operator":"==","operands":["[$OverallApproval]","第1段承認待ち"]},{"operator":"==","operands":["[$OverallApproval]","第2段承認待ち"]}]},"sp-css-backgroundColor-BgMauve sp-css-backgroundColor-BgViolet--hover sp-css-color-MauveFont",{"operator":":","operands":[{"operator":"==","operands":["[$OverallApproval]","差戻し"]},"sp-css-backgroundColor-errorBackground30 sp-css-backgroundColor-errorBackground30--hover sp-css-color-CoralFont","sp-css-backgroundColor-successBackground30 sp-css-backgroundColor-successBackground30--hover sp-css-color-MintGreenFont"]}]}]}},"children":[{"elmType":"span","style":{"flex":"auto"},"txtContent":"=if([$OverallApproval], [$OverallApproval] + ' (' + if([$Stage1ApprovalStatus], [$Stage1ApprovalStatus], '-') + ' / ' + if([$Stage2ApprovalStatus], [$Stage2ApprovalStatus], '-') + ')', '未設定')"}]}
```

### 備考 (Remarks)
- 型(Type): Note
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: False / Unique: False / Indexed: False
- 複数行: 行数=6 / RichText=False / AppendOnly=False

### 申請ボタン (SubmitBtn)
- 型(Type): Text
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: False / Unique: False / Indexed: False
- 最大長: 255
- 列書式(JSON):
`$lang
{"$schema":"https://developer.microsoft.com/json-schemas/sp/v2/column-formatting.schema.json","elmType":"div","children":[{"elmType":"button","attributes":{"title":"この行を申請します"},"txtContent":"申請","style":{"display":"=if([$OverallApproval] == '未申請' || [$OverallApproval] == '差戻し' || [$OverallApproval] == '', 'inline-block', 'none')","cursor":"pointer","padding":"3px 10px","border-radius":"4px","background-color":"#0078d4","color":"white","border":"1px solid #0078d4","font-size":"12px","line-height":"14px","height":"20px"},"customRowAction":{"action":"executeFlow","actionParams":"{\"id\":\"daf1fc3a-17a8-f011-bbd3-000d3ace47ae\"}"}}]}
```

### プロジェクト (ProjectCodeLookup)
- 型(Type): LookupMulti
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: False / Unique: False / Indexed: False
- Lookup: List=869efb95-b706-4bb4-9f0f-41daa970fc35, Field=Title, Multi=True

### 第1段承認ステータス (Stage1ApprovalStatus)
- 型(Type): Choice
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: False / Unique: False / Indexed: False
- 選択肢: 未申請 | 申請中 | 承認 | 却下 | 差戻し

### 第1段承認コメント (Stage1ApprovalComment)
- 型(Type): Note
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: False / Unique: False / Indexed: False
- 複数行: 行数=6 / RichText=False / AppendOnly=False

### 第1段承認日時 (Stage1ApprovalDate)
- 型(Type): DateTime
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: False / Unique: False / Indexed: False

### 第2段承認ステータス (Stage2ApprovalStatus)
- 型(Type): Choice
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: False / Unique: False / Indexed: False
- 選択肢: 未申請 | 申請中 | 承認 | 却下 | 差戻し

### 第2段承認コメント (Stage2ApprovalComment)
- 型(Type): Note
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: False / Unique: False / Indexed: False
- 複数行: 行数=6 / RichText=False / AppendOnly=False

### 第2段承認日時 (Stage2ApprovalDate)
- 型(Type): DateTime
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: False / Unique: False / Indexed: False

### 申請日時 (SubmittedDate)
- 型(Type): DateTime
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: False / Unique: False / Indexed: False

### ID (ID)
- 型(Type): Counter
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: True / Unique: False / Indexed: False

### コンテンツ タイプ (ContentType)
- 型(Type): Computed
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: False / Unique: False / Indexed: False

### 更新日時 (Modified)
- 型(Type): DateTime
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: True / Unique: False / Indexed: False

### 登録日時 (Created)
- 型(Type): DateTime
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: True / Unique: False / Indexed: False

### 登録者 (Author)
- 型(Type): User
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: True / Unique: False / Indexed: False

### 更新者 (Editor)
- 型(Type): User
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: True / Unique: False / Indexed: False

### コピー先の有無 (_HasCopyDestinations)
- 型(Type): Boolean
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: True / Unique: False / Indexed: False

### コピー元 (_CopySource)
- 型(Type): Text
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: True / Unique: False / Indexed: False
- 最大長: 255

### owshiddenversion (owshiddenversion)
- 型(Type): Integer
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: True / Unique: False / Indexed: False

### ワークフローのバージョン (WorkflowVersion)
- 型(Type): Integer
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: True / Unique: False / Indexed: False

### UI バージョン (_UIVersion)
- 型(Type): Integer
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: True / Unique: False / Indexed: False

### バージョン (_UIVersionString)
- 型(Type): Text
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: True / Unique: False / Indexed: False
- 最大長: 255

### 添付ファイル (Attachments)
- 型(Type): Attachments
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: False / Unique: False / Indexed: False

### 承認の状況 (_ModerationStatus)
- 型(Type): ModStat
- 必須: False / 既定値: 0
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: True / Unique: False / Indexed: False
- 選択肢: 0;#承認済み | 1;#却下 | 2;#承認待ち | 3;#下書き | 4;#期限付き

### 編集 (Edit)
- 型(Type): Computed
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: True / Unique: False / Indexed: False

### タイトル (LinkTitleNoMenu)
- 型(Type): Computed
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: True / Unique: False / Indexed: False

### タイトル (LinkTitle)
- 型(Type): Computed
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: True / Unique: False / Indexed: False

### タイトル (LinkTitle2)
- 型(Type): Computed
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: True / Unique: False / Indexed: False

### 選択 (SelectTitle)
- 型(Type): Computed
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: True / Unique: False / Indexed: False

### インスタンス ID (InstanceID)
- 型(Type): Integer
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: True / Unique: False / Indexed: False

### 順序 (Order)
- 型(Type): Number
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: False / Unique: False / Indexed: False

### GUID (GUID)
- 型(Type): Guid
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: True / Unique: False / Indexed: False

### ワークフロー インスタンス ID (WorkflowInstanceID)
- 型(Type): Guid
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: True / Unique: False / Indexed: False

### URL パス (FileRef)
- 型(Type): Lookup
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: True / Unique: False / Indexed: False

### パス (FileDirRef)
- 型(Type): Lookup
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: True / Unique: False / Indexed: False

### 更新日時 (Last_x0020_Modified)
- 型(Type): Lookup
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: True / Unique: False / Indexed: False

### 登録日時 (Created_x0020_Date)
- 型(Type): Lookup
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: True / Unique: False / Indexed: False

### アイテムの種類 (FSObjType)
- 型(Type): Lookup
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: True / Unique: False / Indexed: False

### 並べ替えの種類 (SortBehavior)
- 型(Type): Lookup
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: True / Unique: False / Indexed: False

### 有効な権限マスク (PermMask)
- 型(Type): Computed
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: True / Unique: False / Indexed: False

### プリンシパルの数 (PrincipalCount)
- 型(Type): Computed
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: True / Unique: False / Indexed: False

### 名前 (FileLeafRef)
- 型(Type): File
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: False / Unique: False / Indexed: False

### 固有 ID (UniqueId)
- 型(Type): Lookup
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: True / Unique: False / Indexed: False

### ドキュメントの親 ID (ParentUniqueId)
- 型(Type): Lookup
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: True / Unique: False / Indexed: False

### クライアント ID (SyncClientId)
- 型(Type): Lookup
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: True / Unique: False / Indexed: False

### ProgId (ProgId)
- 型(Type): Lookup
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: True / Unique: False / Indexed: False

### ScopeId (ScopeId)
- 型(Type): Lookup
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: True / Unique: False / Indexed: False

### HTML ファイルの種類 (HTML_x0020_File_x0020_Type)
- 型(Type): Computed
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: True / Unique: False / Indexed: False

### メニュー テーブルの編集の開始 (_EditMenuTableStart)
- 型(Type): Computed
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: True / Unique: False / Indexed: False

### メニュー テーブルの編集の開始 (_EditMenuTableStart2)
- 型(Type): Computed
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: True / Unique: False / Indexed: False

### メニュー テーブルの編集の終了 (_EditMenuTableEnd)
- 型(Type): Computed
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: True / Unique: False / Indexed: False

### 名前 (LinkFilenameNoMenu)
- 型(Type): Computed
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: True / Unique: False / Indexed: False

### 名前 (LinkFilename)
- 型(Type): Computed
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: True / Unique: False / Indexed: False

### 名前 (LinkFilename2)
- 型(Type): Computed
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: True / Unique: False / Indexed: False

### 種類 (DocIcon)
- 型(Type): Computed
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: True / Unique: False / Indexed: False

### サーバーの相対 URL (ServerUrl)
- 型(Type): Computed
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: True / Unique: False / Indexed: False

### エンコードされた絶対 URL (EncodedAbsUrl)
- 型(Type): Computed
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: True / Unique: False / Indexed: False

### ファイル名 (BaseName)
- 型(Type): Computed
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: True / Unique: False / Indexed: False

### プロパティ バッグ (MetaInfo)
- 型(Type): Lookup
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: False / Unique: False / Indexed: False

### レベル (_Level)
- 型(Type): Integer
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: True / Unique: False / Indexed: False

### 現在のバージョン (_IsCurrentVersion)
- 型(Type): Boolean
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: True / Unique: False / Indexed: False

### 子アイテムの数 (ItemChildCount)
- 型(Type): Lookup
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: True / Unique: False / Indexed: False

### 子フォルダーの数 (FolderChildCount)
- 型(Type): Lookup
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: True / Unique: False / Indexed: False

### 制限付き (Restricted)
- 型(Type): Lookup
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: True / Unique: False / Indexed: False

### 発信者 ID (OriginatorId)
- 型(Type): Lookup
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: True / Unique: False / Indexed: False

### NoExecute (NoExecute)
- 型(Type): Lookup
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: True / Unique: False / Indexed: False

### コンテンツのバージョン (ContentVersion)
- 型(Type): Lookup
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: True / Unique: False / Indexed: False

### ラベルの設定 (_ComplianceFlags)
- 型(Type): Lookup
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: True / Unique: False / Indexed: False

### 保持ラベル (_ComplianceTag)
- 型(Type): Lookup
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: True / Unique: False / Indexed: False

### 保持ラベルを適用済み (_ComplianceTagWrittenTime)
- 型(Type): Lookup
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: True / Unique: False / Indexed: False

### ラベルの適用者 (_ComplianceTagUserId)
- 型(Type): Lookup
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: True / Unique: False / Indexed: False

### レコードとして登録されているアイテム (_IsRecord)
- 型(Type): Computed
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: True / Unique: False / Indexed: False

### アクセス ポリシー (AccessPolicy)
- 型(Type): Lookup
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: True / Unique: False / Indexed: False

### VirusStatus (_VirusStatus)
- 型(Type): Lookup
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: True / Unique: False / Indexed: False

### VirusVendorID (_VirusVendorID)
- 型(Type): Lookup
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: True / Unique: False / Indexed: False

### VirusInfo (_VirusInfo)
- 型(Type): Lookup
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: True / Unique: False / Indexed: False

### RansomwareAnomalyMetaInfo (_RansomwareAnomalyMetaInfo)
- 型(Type): Lookup
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: True / Unique: False / Indexed: False

### 下書き所有者 ID (_DraftOwnerId)
- 型(Type): Lookup
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: True / Unique: False / Indexed: False

### メイン リンクの設定 (MainLinkSettings)
- 型(Type): Computed
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: True / Unique: False / Indexed: False

### アプリの作成者 (AppAuthor)
- 型(Type): Lookup
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: True / Unique: False / Indexed: False
- Lookup: List=AppPrincipals, Field=Title, Multi=False

### アプリの変更者 (AppEditor)
- 型(Type): Lookup
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: False / ReadOnly: True / Unique: False / Indexed: False
- Lookup: List=AppPrincipals, Field=Title, Multi=False

### 合計サイズ (SMTotalSize)
- 型(Type): Lookup
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: True / Unique: False / Indexed: False

### 最終更新日 (SMLastModifiedDate)
- 型(Type): Lookup
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: True / Unique: False / Indexed: False

### ファイル ストリームの合計サイズ (SMTotalFileStreamSize)
- 型(Type): Lookup
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: True / Unique: False / Indexed: False

### 合計ファイル数 (SMTotalFileCount)
- 型(Type): Lookup
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: True / Unique: False / Indexed: False

### コメントの設定 (_CommentFlags)
- 型(Type): Lookup
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: True / Unique: False / Indexed: False

### コメント数 (_CommentCount)
- 型(Type): Lookup
- 必須: False / 既定値: 
- 表示/新規/編集フォーム: N/A/N/A/N/A
- Hidden: True / ReadOnly: True / Unique: False / Indexed: False

## コンテンツタイプ
- アイテム (0x0100A61A715EF06C944DB63CC1F1B9A0165D) Hidden=False ReadOnly=False Sealed=False
- フォルダー (0x0120001790D3B53E7B4E4DADB7953AC75CE2E8) Hidden=False ReadOnly=False Sealed=True

## ビュー
### すべてのアイテム (Default=False)
