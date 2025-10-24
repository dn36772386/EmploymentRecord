Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'

# 既に接続されているかチェック
$conn = Get-PnPConnection -ErrorAction SilentlyContinue
if (-not $conn) {
  . "$PSScriptRoot/connect.ps1"
}
. "$PSScriptRoot/config.ps1"

# リストが存在しない場合は作成
if(-not (Get-PnPList -Identity $SrcList -ErrorAction SilentlyContinue)){
  New-PnPList -Title $SrcList -Template GenericList -Url ("Lists/{0}" -f $SrcList) -OnQuickLaunch | Out-Null
  Write-Host "✓ リスト作成: $SrcList" -ForegroundColor Green
}

$List = $SrcList

# ヘルパー関数
function Add-FieldIfNotExists {
  param(
    [string]$DisplayName,
    [string]$InternalName,
    [string]$Type,
    [string[]]$Choices = @(),
    [bool]$Required = $false,
    [bool]$AllowMultiple = $false
  )
  
  if(-not (Get-PnPField -List $List -Identity $InternalName -ErrorAction SilentlyContinue)){
    $params = @{
      List = $List
      DisplayName = $DisplayName
      InternalName = $InternalName
      Type = $Type
    }
    
    if ($Choices.Count -gt 0) {
      $params['Choices'] = $Choices
    }
    
    Add-PnPField @params | Out-Null
    
    if ($Required) {
      Set-PnPField -List $List -Identity $InternalName -Values @{Required=$true}
    }
    
    if ($AllowMultiple) {
      Set-PnPField -List $List -Identity $InternalName -Values @{AllowMultipleValues=$true}
    }
  }
}

Write-Host "フィールドを追加中..." -ForegroundColor Yellow

# 管理情報
Add-FieldIfNotExists -DisplayName '採用理由' -InternalName 'EmploymentReason' -Type 'Choice' -Choices @('新規','更新(変更あり)') -Required $true
Add-FieldIfNotExists -DisplayName '職員番号' -InternalName 'EmployeeID' -Type 'Number' -Required $true

# 所属情報
Add-FieldIfNotExists -DisplayName '所属' -InternalName 'Department' -Type 'Choice' -Choices @('人事課','研究支援課','財務課','情報基盤課') -Required $true
Add-FieldIfNotExists -DisplayName '担当グループ' -InternalName 'GroupName' -Type 'Text'
Add-FieldIfNotExists -DisplayName '雇用責任者' -InternalName 'EmploymentOwner' -Type 'User'
Add-FieldIfNotExists -DisplayName '事務担当者' -InternalName 'AdministrativeClerk' -Type 'User'

# 個人情報
Add-FieldIfNotExists -DisplayName '氏名' -InternalName 'FullName' -Type 'Text' -Required $true
Add-FieldIfNotExists -DisplayName 'フリガナ' -InternalName 'Furigana' -Type 'Text'
Add-FieldIfNotExists -DisplayName '性別' -InternalName 'Gender' -Type 'Choice' -Choices @('男','女')
Add-FieldIfNotExists -DisplayName '生年月日' -InternalName 'BirthDate' -Type 'DateTime'
Add-FieldIfNotExists -DisplayName '住所' -InternalName 'Address' -Type 'Text'
Add-FieldIfNotExists -DisplayName '郵便番号' -InternalName 'PostalCode' -Type 'Text'
Add-FieldIfNotExists -DisplayName '本人連絡先' -InternalName 'ContactNumber' -Type 'Text'
Add-FieldIfNotExists -DisplayName '国籍' -InternalName 'Nationality' -Type 'Text'
Add-FieldIfNotExists -DisplayName '在留資格' -InternalName 'ResidenceStatus' -Type 'Text'
Add-FieldIfNotExists -DisplayName '在留期限' -InternalName 'ResidenceLimit' -Type 'DateTime'
Add-FieldIfNotExists -DisplayName '資格外活動許可' -InternalName 'WorkPermit' -Type 'Choice' -Choices @('有','無')

# 雇用情報
Add-FieldIfNotExists -DisplayName '区分' -InternalName 'EmploymentType' -Type 'Choice' -Choices @('フルタイム','パートタイム') -Required $true
Add-FieldIfNotExists -DisplayName '職種' -InternalName 'JobTitle' -Type 'Text'
Add-FieldIfNotExists -DisplayName '契約期間開始' -InternalName 'StartDate' -Type 'DateTime' -Required $true
Add-FieldIfNotExists -DisplayName '契約期間終了' -InternalName 'EndDate' -Type 'DateTime' -Required $true
Add-FieldIfNotExists -DisplayName '更新上限有無' -InternalName 'RenewalFlag' -Type 'Choice' -Choices @('有','無')
Add-FieldIfNotExists -DisplayName '更新上限日' -InternalName 'RenewalLimit' -Type 'DateTime'

# 勤務情報
Add-FieldIfNotExists -DisplayName '勤務場所' -InternalName 'WorkLocation' -Type 'Text' -Required $true
Add-FieldIfNotExists -DisplayName '業務内容' -InternalName 'WorkDescription' -Type 'Note'
Add-FieldIfNotExists -DisplayName '業務内容の変更範囲' -InternalName 'WorkChangeScope' -Type 'Choice' -Choices @('変更なし','業務拡大','業務縮小')
Add-FieldIfNotExists -DisplayName '勤務日数（週）' -InternalName 'WorkDays' -Type 'Number'
Add-FieldIfNotExists -DisplayName '勤務曜日' -InternalName 'WorkWeekdaysChoice' -Type 'MultiChoice' -Choices @('月','火','水','木','金','土','日') -AllowMultiple $true
Add-FieldIfNotExists -DisplayName '休日' -InternalName 'HolidaysChoice' -Type 'MultiChoice' -Choices @('月','火','水','木','金','土','日') -AllowMultiple $true
Add-FieldIfNotExists -DisplayName '勤務開始時刻' -InternalName 'StartTime' -Type 'DateTime'
Add-FieldIfNotExists -DisplayName '勤務終了時刻' -InternalName 'EndTime' -Type 'DateTime'
Add-FieldIfNotExists -DisplayName '休憩時間' -InternalName 'BreakTime' -Type 'Text'
Add-FieldIfNotExists -DisplayName '1日勤務時間' -InternalName 'DailyWorkHours' -Type 'Number'

# 賃金情報
Add-FieldIfNotExists -DisplayName '賃金形態' -InternalName 'PayType' -Type 'Choice' -Choices @('月給','時給','日給') -Required $true
Add-FieldIfNotExists -DisplayName '賃金単価' -InternalName 'PayRate' -Type 'Number' -Required $true

# 財源情報
Add-FieldIfNotExists -DisplayName '雇用財源' -InternalName 'FundingType' -Type 'Choice' -Choices @('人事課人件費','外部資金','その他') -Required $true
Add-FieldIfNotExists -DisplayName '執行見込み総額' -InternalName 'ExpenseEstimate' -Type 'Currency'
Add-FieldIfNotExists -DisplayName '人件費番号' -InternalName 'HRExpenseCode' -Type 'Text'

# Lookup フィールド: ProjectMaster への参照
$pm = Get-PnPList -Identity $ProjectMaster -ErrorAction SilentlyContinue
if ($pm) {
  $pmId = $pm.Id.ToString('B')
  
  if(-not (Get-PnPField -List $List -Identity 'ProjectCodeLookup' -ErrorAction SilentlyContinue)){
    Add-PnPFieldFromXml -List $List -FieldXml @"
<Field Type='Lookup' DisplayName='プロジェクトコード'
  StaticName='ProjectCodeLookup' Name='ProjectCodeLookup'
  List='$pmId' ShowField='ProjectCode' Required='TRUE' />
"@ | Out-Null
  }
  
  if(-not (Get-PnPField -List $List -Identity 'ProjectName' -ErrorAction SilentlyContinue)){
    Add-PnPFieldFromXml -List $List -FieldXml @"
<Field Type='Lookup' DisplayName='プロジェクト名'
  StaticName='ProjectName' Name='ProjectName'
  List='$pmId' ShowField='ProjectName' />
"@ | Out-Null
  }
} else {
  Write-Warning "ProjectMaster リストが見つかりません。Lookup フィールドはスキップされました。"
}

# 承認設定（User フィールド、複数選択可能）
if(-not (Get-PnPField -List $List -Identity 'Stage1Approvers' -ErrorAction SilentlyContinue)){
  Add-PnPField -List $List -DisplayName '第1段承認者（部門）' -InternalName 'Stage1Approvers' -Type User | Out-Null
  Set-PnPField -List $List -Identity 'Stage1Approvers' -Values @{AllowMultipleValues=$true}
}

if(-not (Get-PnPField -List $List -Identity 'Stage2Approvers' -ErrorAction SilentlyContinue)){
  Add-PnPField -List $List -DisplayName '第2段承認者（管理部門）' -InternalName 'Stage2Approvers' -Type User | Out-Null
  Set-PnPField -List $List -Identity 'Stage2Approvers' -Values @{AllowMultipleValues=$true}
}

# 承認集約・備考・管理補助
Add-FieldIfNotExists -DisplayName '全体承認状態' -InternalName 'OverallApproval' -Type 'Text'
Add-FieldIfNotExists -DisplayName '備考' -InternalName 'Remarks' -Type 'Note'
Add-FieldIfNotExists -DisplayName '申請ボタン' -InternalName 'SubmitBtn' -Type 'Text'

Write-Host "✓ すべてのフィールド追加完了: $List" -ForegroundColor Green
