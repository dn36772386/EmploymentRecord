Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'

# 既に接続されているかチェック
$conn = Get-PnPConnection -ErrorAction SilentlyContinue
if (-not $conn) {
  . "$PSScriptRoot/connect.ps1"
}
. "$PSScriptRoot/config.ps1"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  雇用記録サンプルデータ登録" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# プロジェクトマスタから参照データを取得
Write-Host "プロジェクトマスタを確認中..." -ForegroundColor Gray
$projects = Get-PnPListItem -List $ProjectMaster -Fields "ID","ProjectCode","ProjectName" | Select-Object -First 10
if ($projects.Count -eq 0) {
  Write-Host "✗ エラー: プロジェクトマスタにデータがありません" -ForegroundColor Red
  Write-Host "  先に ./insert-sample-projects.ps1 を実行してください" -ForegroundColor Yellow
  exit 1
}
Write-Host "✓ プロジェクト取得完了: $($projects.Count) 件" -ForegroundColor Green

# サンプルデータ定義（10件）
# 氏名、住所、電話番号などは明確にサンプルデータとわかるように設定
$records = @(
  @{
    EmploymentReason = "新規"
    EmployeeID = 1001001
    Department = "人事課"
    GroupName = "第1グループ"
    FullName = "サンプル 太郎"
    Furigana = "サンプル タロウ"
    Gender = "男"
    BirthDate = (Get-Date "1990-04-15")
    Address = "東京都千代田区サンプル町1-2-3 サンプルビル101"
    PostalCode = "100-0001"
    ContactNumber = "03-0000-0001"
    Nationality = "日本国"
    EmploymentType = "フルタイム"
    JobTitle = "事務員A"
    StartDate = (Get-Date "2024-04-01")
    EndDate = (Get-Date "2025-03-31")
    RenewalFlag = "有"
    RenewalLimit = (Get-Date "2027-03-31")
    WorkLocation = "サンプルキャンパス 人事課"
    WorkDescription = "人事関連事務全般"
    WorkChangeScope = "変更なし"
    WorkDays = 5
    WorkWeekdaysChoice = @("月","火","水","木","金")
    HolidaysChoice = @("土","日")
    StartTime = (Get-Date "2024-01-01 09:00")
    EndTime = (Get-Date "2024-01-01 17:15")
    BreakTime = "12:00〜12:45"
    DailyWorkHours = 7.5
    PayType = "月給"
    PayRate = 250000
    FundingType = "人事課人件費"
    ProjectRef = $projects[0].Id
    ExpenseEstimate = 3000000
    HRExpenseCode = "SR000001"
    Remarks = "標準的な事務職員の雇用（サンプルデータ）"
  },
  @{
    EmploymentReason = "更新(変更あり)"
    EmployeeID = 1001002
    Department = "研究支援課"
    GroupName = "研究支援第2グループ"
    FullName = "サンプル 花子"
    Furigana = "サンプル ハナコ"
    Gender = "女"
    BirthDate = (Get-Date "1988-07-22")
    Address = "大阪府大阪市サンプル区サンプル1-1-1"
    PostalCode = "530-0001"
    ContactNumber = "06-0000-0002"
    Nationality = "日本国"
    EmploymentType = "フルタイム"
    JobTitle = "研究員A"
    StartDate = (Get-Date "2024-04-01")
    EndDate = (Get-Date "2025-03-31")
    RenewalFlag = "有"
    RenewalLimit = (Get-Date "2026-03-31")
    WorkLocation = "サンプルキャンパス 研究支援課"
    WorkDescription = "研究プロジェクト支援業務、データ収集・分析"
    WorkChangeScope = "業務拡大"
    WorkDays = 5
    WorkWeekdaysChoice = @("月","火","水","木","金")
    HolidaysChoice = @("土","日")
    StartTime = (Get-Date "2024-01-01 09:00")
    EndTime = (Get-Date "2024-01-01 17:15")
    BreakTime = "12:00〜12:45"
    DailyWorkHours = 7.5
    PayType = "月給"
    PayRate = 280000
    FundingType = "外部資金"
    ProjectRef = $projects[1].Id
    ExpenseEstimate = 3360000
    HRExpenseCode = "SR000002"
    Remarks = "AI研究プロジェクト支援担当（サンプルデータ）"
  },
  @{
    EmploymentReason = "新規"
    EmployeeID = 1001003
    Department = "財務課"
    GroupName = "経理グループ"
    FullName = "テスト 一郎"
    Furigana = "テスト イチロウ"
    Gender = "男"
    BirthDate = (Get-Date "1992-11-05")
    Address = "神奈川県横浜市サンプル区テスト町2-3-4"
    PostalCode = "220-0001"
    ContactNumber = "045-0000-0003"
    Nationality = "日本国"
    EmploymentType = "パートタイム"
    JobTitle = "経理事務員"
    StartDate = (Get-Date "2024-05-01")
    EndDate = (Get-Date "2025-03-31")
    RenewalFlag = "無"
    WorkLocation = "サンプルキャンパス 財務課"
    WorkDescription = "経理伝票処理、予算管理補助"
    WorkChangeScope = "変更なし"
    WorkDays = 3
    WorkWeekdaysChoice = @("月","水","金")
    HolidaysChoice = @("火","木","土","日")
    StartTime = (Get-Date "2024-01-01 10:00")
    EndTime = (Get-Date "2024-01-01 16:00")
    BreakTime = "12:00〜13:00"
    DailyWorkHours = 5
    PayType = "時給"
    PayRate = 1500
    FundingType = "人事課人件費"
    ProjectRef = $projects[2].Id
    ExpenseEstimate = 990000
    HRExpenseCode = "SR000003"
    Remarks = "週3日勤務、経理経験者（サンプルデータ）"
  },
  @{
    EmploymentReason = "新規"
    EmployeeID = 1001004
    Department = "情報基盤課"
    GroupName = "システム運用グループ"
    FullName = "ダミー 美咲"
    Furigana = "ダミー ミサキ"
    Gender = "女"
    BirthDate = (Get-Date "1995-03-18")
    Address = "千葉県千葉市サンプル区ダミー3-4-5"
    PostalCode = "260-0001"
    ContactNumber = "043-0000-0004"
    Nationality = "日本国"
    EmploymentType = "フルタイム"
    JobTitle = "システムエンジニア"
    StartDate = (Get-Date "2024-06-01")
    EndDate = (Get-Date "2025-05-31")
    RenewalFlag = "有"
    RenewalLimit = (Get-Date "2028-05-31")
    WorkLocation = "サンプルキャンパス 情報基盤センター"
    WorkDescription = "学内システムの運用・保守、ヘルプデスク対応"
    WorkChangeScope = "変更なし"
    WorkDays = 5
    WorkWeekdaysChoice = @("月","火","水","木","金")
    HolidaysChoice = @("土","日")
    StartTime = (Get-Date "2024-01-01 09:30")
    EndTime = (Get-Date "2024-01-01 18:00")
    BreakTime = "12:00〜13:00"
    DailyWorkHours = 7.5
    PayType = "月給"
    PayRate = 320000
    FundingType = "外部資金"
    ProjectRef = $projects[3].Id
    ExpenseEstimate = 3840000
    HRExpenseCode = "SR000004"
    Remarks = "教育ICT基盤整備プロジェクト担当（サンプルデータ）"
  },
  @{
    EmploymentReason = "更新(変更あり)"
    EmployeeID = 1001005
    Department = "研究支援課"
    GroupName = "研究企画グループ"
    FullName = "サンプル リサ"
    Furigana = "サンプル リサ"
    Gender = "女"
    BirthDate = (Get-Date "1993-08-30")
    Address = "埼玉県さいたま市サンプル区テスト4-5-6"
    PostalCode = "330-0001"
    ContactNumber = "048-0000-0005"
    Nationality = "アメリカ合衆国"
    ResidenceStatus = "特定活動"
    ResidenceLimit = (Get-Date "2026-12-31")
    WorkPermit = "有"
    EmploymentType = "フルタイム"
    JobTitle = "研究員B"
    StartDate = (Get-Date "2024-04-01")
    EndDate = (Get-Date "2025-03-31")
    RenewalFlag = "有"
    RenewalLimit = (Get-Date "2026-12-31")
    WorkLocation = "サンプルキャンパス 研究支援課"
    WorkDescription = "国際共同研究の調整、翻訳業務"
    WorkChangeScope = "業務拡大"
    WorkDays = 5
    WorkWeekdaysChoice = @("月","火","水","木","金")
    HolidaysChoice = @("土","日")
    StartTime = (Get-Date "2024-01-01 09:00")
    EndTime = (Get-Date "2024-01-01 17:15")
    BreakTime = "12:00〜12:45"
    DailyWorkHours = 7.5
    PayType = "月給"
    PayRate = 300000
    FundingType = "外部資金"
    ProjectRef = $projects[4].Id
    ExpenseEstimate = 3600000
    HRExpenseCode = "SR000005"
    Remarks = "グローバル人材交流事業担当、在留資格管理必要（サンプルデータ）"
  },
  @{
    EmploymentReason = "新規"
    EmployeeID = 1001006
    Department = "人事課"
    GroupName = "給与グループ"
    FullName = "テスト 健太"
    Furigana = "テスト ケンタ"
    Gender = "男"
    BirthDate = (Get-Date "1991-06-12")
    Address = "愛知県名古屋市サンプル区ダミー5-6-7"
    PostalCode = "460-0001"
    ContactNumber = "052-0000-0006"
    Nationality = "日本国"
    EmploymentType = "パートタイム"
    JobTitle = "給与計算補助"
    StartDate = (Get-Date "2024-07-01")
    EndDate = (Get-Date "2024-12-31")
    RenewalFlag = "有"
    RenewalLimit = (Get-Date "2025-12-31")
    WorkLocation = "サンプルキャンパス 人事課"
    WorkDescription = "給与計算データ入力、勤怠管理"
    WorkChangeScope = "変更なし"
    WorkDays = 4
    WorkWeekdaysChoice = @("月","火","木","金")
    HolidaysChoice = @("水","土","日")
    StartTime = (Get-Date "2024-01-01 09:00")
    EndTime = (Get-Date "2024-01-01 15:00")
    BreakTime = "12:00〜13:00"
    DailyWorkHours = 5
    PayType = "時給"
    PayRate = 1400
    FundingType = "人事課人件費"
    ProjectRef = $projects[5].Id
    ExpenseEstimate = 672000
    HRExpenseCode = "SR000006"
    Remarks = "週4日勤務、給与計算経験者（サンプルデータ）"
  },
  @{
    EmploymentReason = "新規"
    EmployeeID = 1001007
    Department = "研究支援課"
    GroupName = "データ科学グループ"
    FullName = "ダミー 直子"
    Furigana = "ダミー ナオコ"
    Gender = "女"
    BirthDate = (Get-Date "1994-09-25")
    Address = "福岡県福岡市サンプル区テスト6-7-8"
    PostalCode = "810-0001"
    ContactNumber = "092-0000-0007"
    Nationality = "日本国"
    EmploymentType = "フルタイム"
    JobTitle = "データアナリスト"
    StartDate = (Get-Date "2024-08-01")
    EndDate = (Get-Date "2026-07-31")
    RenewalFlag = "無"
    WorkLocation = "サンプルキャンパス データ科学研究所"
    WorkDescription = "ビッグデータ解析、統計分析、レポート作成"
    WorkChangeScope = "変更なし"
    WorkDays = 5
    WorkWeekdaysChoice = @("月","火","水","木","金")
    HolidaysChoice = @("土","日")
    StartTime = (Get-Date "2024-01-01 10:00")
    EndTime = (Get-Date "2024-01-01 18:30")
    BreakTime = "12:30〜13:30"
    DailyWorkHours = 7.5
    PayType = "月給"
    PayRate = 350000
    FundingType = "外部資金"
    ProjectRef = $projects[6].Id
    ExpenseEstimate = 8400000
    HRExpenseCode = "SR000007"
    Remarks = "ビッグデータ解析基盤構築プロジェクト、2年契約（サンプルデータ）"
  },
  @{
    EmploymentReason = "更新(変更あり)"
    EmployeeID = 1001008
    Department = "財務課"
    GroupName = "調達グループ"
    FullName = "サンプル 優子"
    Furigana = "サンプル ユウコ"
    Gender = "女"
    BirthDate = (Get-Date "1989-12-08")
    Address = "北海道札幌市サンプル区ダミー7-8-9"
    PostalCode = "060-0001"
    ContactNumber = "011-0000-0008"
    Nationality = "日本国"
    EmploymentType = "フルタイム"
    JobTitle = "調達事務員"
    StartDate = (Get-Date "2024-04-01")
    EndDate = (Get-Date "2025-03-31")
    RenewalFlag = "有"
    RenewalLimit = (Get-Date "2027-03-31")
    WorkLocation = "サンプルキャンパス 財務課"
    WorkDescription = "物品調達、契約書管理、入札業務補助"
    WorkChangeScope = "業務縮小"
    WorkDays = 5
    WorkWeekdaysChoice = @("月","火","水","木","金")
    HolidaysChoice = @("土","日")
    StartTime = (Get-Date "2024-01-01 09:00")
    EndTime = (Get-Date "2024-01-01 17:15")
    BreakTime = "12:00〜12:45"
    DailyWorkHours = 7.5
    PayType = "月給"
    PayRate = 260000
    FundingType = "人事課人件費"
    ProjectRef = $projects[7].Id
    ExpenseEstimate = 3120000
    HRExpenseCode = "SR000008"
    Remarks = "契約事務経験10年、業務範囲見直し予定（サンプルデータ）"
  },
  @{
    EmploymentReason = "新規"
    EmployeeID = 1001009
    Department = "情報基盤課"
    GroupName = "ネットワーク運用グループ"
    FullName = "テスト 大輔"
    Furigana = "テスト ダイスケ"
    Gender = "男"
    BirthDate = (Get-Date "1996-02-14")
    Address = "宮城県仙台市サンプル区テスト8-9-10"
    PostalCode = "980-0001"
    ContactNumber = "022-0000-0009"
    Nationality = "日本国"
    EmploymentType = "パートタイム"
    JobTitle = "ネットワーク技術者"
    StartDate = (Get-Date "2024-09-01")
    EndDate = (Get-Date "2025-08-31")
    RenewalFlag = "有"
    RenewalLimit = (Get-Date "2026-08-31")
    WorkLocation = "サンプルキャンパス 情報基盤センター"
    WorkDescription = "ネットワーク機器設定、障害対応"
    WorkChangeScope = "変更なし"
    WorkDays = 3
    WorkWeekdaysChoice = @("火","水","木")
    HolidaysChoice = @("月","金","土","日")
    StartTime = (Get-Date "2024-01-01 13:00")
    EndTime = (Get-Date "2024-01-01 19:00")
    BreakTime = "なし"
    DailyWorkHours = 6
    PayType = "時給"
    PayRate = 2000
    FundingType = "外部資金"
    ProjectRef = $projects[8].Id
    ExpenseEstimate = 1872000
    HRExpenseCode = "SR000009"
    Remarks = "夜間シフト対応可能、ネットワーク専門技術者（サンプルデータ）"
  },
  @{
    EmploymentReason = "新規"
    EmployeeID = 1001010
    Department = "研究支援課"
    GroupName = "産学連携グループ"
    FullName = "ダミー 誠"
    Furigana = "ダミー マコト"
    Gender = "男"
    BirthDate = (Get-Date "1987-05-20")
    Address = "広島県広島市サンプル区ダミー9-10-11"
    PostalCode = "730-0001"
    ContactNumber = "082-0000-0010"
    Nationality = "日本国"
    EmploymentType = "フルタイム"
    JobTitle = "産学連携コーディネーター"
    StartDate = (Get-Date "2024-10-01")
    EndDate = (Get-Date "2027-09-30")
    RenewalFlag = "無"
    WorkLocation = "サンプルキャンパス 産学連携室"
    WorkDescription = "企業連携窓口、共同研究支援、知財管理"
    WorkChangeScope = "変更なし"
    WorkDays = 5
    WorkWeekdaysChoice = @("月","火","水","木","金")
    HolidaysChoice = @("土","日")
    StartTime = (Get-Date "2024-01-01 09:00")
    EndTime = (Get-Date "2024-01-01 17:15")
    BreakTime = "12:00〜12:45"
    DailyWorkHours = 7.5
    PayType = "月給"
    PayRate = 380000
    FundingType = "外部資金"
    ProjectRef = $projects[9].Id
    ExpenseEstimate = 13680000
    HRExpenseCode = "SR000010"
    Remarks = "地域連携イノベーション担当、3年契約（サンプルデータ）"
  }
)

Write-Host "登録開始..." -ForegroundColor Yellow
$count = 0
$success = 0
$failed = 0

foreach ($rec in $records) {
  $count++
  try {
    # 基本値を設定（必須フィールド）
    $values = @{
      "EmploymentReason" = $rec.EmploymentReason
      "EmployeeID" = $rec.EmployeeID
      "Department" = $rec.Department
      "FullName" = $rec.FullName
      "EmploymentType" = $rec.EmploymentType
      "StartDate" = $rec.StartDate
      "EndDate" = $rec.EndDate
      "WorkLocation" = $rec.WorkLocation
      "PayType" = $rec.PayType
      "PayRate" = $rec.PayRate
      "FundingType" = $rec.FundingType
    }
    
    # Lookupフィールドは後で更新スクリプトで設定
    # "ProjectCodeLookupId" = $rec.ProjectRef
    
    # オプション項目を追加（存在し、かつnullでない場合のみ）
    if ($rec.ContainsKey('GroupName') -and $rec.GroupName) { $values["GroupName"] = $rec.GroupName }
    if ($rec.ContainsKey('Furigana') -and $rec.Furigana) { $values["Furigana"] = $rec.Furigana }
    if ($rec.ContainsKey('Gender') -and $rec.Gender) { $values["Gender"] = $rec.Gender }
    if ($rec.ContainsKey('BirthDate') -and $rec.BirthDate) { $values["BirthDate"] = $rec.BirthDate }
    if ($rec.ContainsKey('Address') -and $rec.Address) { $values["Address"] = $rec.Address }
    if ($rec.ContainsKey('PostalCode') -and $rec.PostalCode) { $values["PostalCode"] = $rec.PostalCode }
    if ($rec.ContainsKey('ContactNumber') -and $rec.ContactNumber) { $values["ContactNumber"] = $rec.ContactNumber }
    if ($rec.ContainsKey('Nationality') -and $rec.Nationality) { $values["Nationality"] = $rec.Nationality }
    if ($rec.ContainsKey('ResidenceStatus') -and $rec.ResidenceStatus) { $values["ResidenceStatus"] = $rec.ResidenceStatus }
    if ($rec.ContainsKey('ResidenceLimit') -and $rec.ResidenceLimit) { $values["ResidenceLimit"] = $rec.ResidenceLimit }
    if ($rec.ContainsKey('WorkPermit') -and $rec.WorkPermit) { $values["WorkPermit"] = $rec.WorkPermit }
    if ($rec.ContainsKey('JobTitle') -and $rec.JobTitle) { $values["JobTitle"] = $rec.JobTitle }
    if ($rec.ContainsKey('RenewalFlag') -and $rec.RenewalFlag) { $values["RenewalFlag"] = $rec.RenewalFlag }
    if ($rec.ContainsKey('RenewalLimit') -and $rec.RenewalLimit) { $values["RenewalLimit"] = $rec.RenewalLimit }
    if ($rec.ContainsKey('WorkDescription') -and $rec.WorkDescription) { $values["WorkDescription"] = $rec.WorkDescription }
    if ($rec.ContainsKey('WorkChangeScope') -and $rec.WorkChangeScope) { $values["WorkChangeScope"] = $rec.WorkChangeScope }
    if ($rec.ContainsKey('WorkDays') -and $rec.WorkDays) { $values["WorkDays"] = $rec.WorkDays }
    if ($rec.ContainsKey('WorkWeekdaysChoice') -and $rec.WorkWeekdaysChoice) { $values["WorkWeekdaysChoice"] = $rec.WorkWeekdaysChoice }
    if ($rec.ContainsKey('HolidaysChoice') -and $rec.HolidaysChoice) { $values["HolidaysChoice"] = $rec.HolidaysChoice }
    if ($rec.ContainsKey('StartTime') -and $rec.StartTime) { $values["StartTime"] = $rec.StartTime }
    if ($rec.ContainsKey('EndTime') -and $rec.EndTime) { $values["EndTime"] = $rec.EndTime }
    if ($rec.ContainsKey('BreakTime') -and $rec.BreakTime) { $values["BreakTime"] = $rec.BreakTime }
    if ($rec.ContainsKey('DailyWorkHours') -and $rec.DailyWorkHours) { $values["DailyWorkHours"] = $rec.DailyWorkHours }
    if ($rec.ContainsKey('ExpenseEstimate') -and $rec.ExpenseEstimate) { $values["ExpenseEstimate"] = $rec.ExpenseEstimate }
    if ($rec.ContainsKey('HRExpenseCode') -and $rec.HRExpenseCode) { $values["HRExpenseCode"] = $rec.HRExpenseCode }
    if ($rec.ContainsKey('Remarks') -and $rec.Remarks) { $values["Remarks"] = $rec.Remarks }
    
    $item = Add-PnPListItem -List $SrcList -Values $values
    Write-Host "  [$count/10] ✓ $($rec.EmployeeID) - $($rec.FullName) ($($rec.Department))" -ForegroundColor Green
    $success++
  }
  catch {
    Write-Host "  [$count/10] ✗ $($rec.EmployeeID) - エラー: $($_.Exception.Message)" -ForegroundColor Red
    $failed++
  }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  登録完了" -ForegroundColor Cyan
Write-Host "  成功: $success 件" -ForegroundColor Green
Write-Host "  失敗: $failed 件" -ForegroundColor $(if($failed -gt 0){'Red'}else{'Green'})
Write-Host "========================================`n" -ForegroundColor Cyan

# 登録結果を確認
Write-Host "登録された雇用記録一覧:" -ForegroundColor Yellow
$items = Get-PnPListItem -List $SrcList -Fields "EmployeeID","FullName","Department","EmploymentType" | 
  Sort-Object -Property @{Expression={$_.FieldValues.EmployeeID}}

foreach ($item in $items) {
  $empId = $item.FieldValues.EmployeeID
  $name = $item.FieldValues.FullName
  $dept = $item.FieldValues.Department
  $type = $item.FieldValues.EmploymentType
  Write-Host "  - $empId : $name [$dept / $type]" -ForegroundColor Gray
}

Write-Host "`n✅ サンプルデータ登録完了！" -ForegroundColor Green
