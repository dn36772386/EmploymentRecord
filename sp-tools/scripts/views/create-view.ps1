Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'

# 既に接続されているかチェック
$conn = Get-PnPConnection -ErrorAction SilentlyContinue
if (-not $conn) {
  . "$PSScriptRoot/connect.ps1"
}
. "$PSScriptRoot/config.ps1"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  EMP_1_EmploymentRecords ビュー作成" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# ビュー名
$viewName = "雇用記録一覧"

# 既存のビューを削除（存在する場合）
$existingView = Get-PnPView -List $SrcList -Identity $viewName -ErrorAction SilentlyContinue
if ($existingView) {
  Remove-PnPView -List $SrcList -Identity $viewName -Force
  Write-Host "既存のビューを削除しました" -ForegroundColor Yellow
}

# フィールドの並び順（仕様書の順序）
$viewFields = @(
  'ID'                      # リストID（先頭）
  'EmploymentReason'        # 採用理由
  'EmployeeID'              # 職員番号
  'Department'              # 所属
  'GroupName'               # 担当グループ
  'EmploymentOwner'         # 雇用責任者
  'AdministrativeClerk'     # 事務担当者
  'FullName'                # 氏名
  'Furigana'                # フリガナ
  'Gender'                  # 性別
  'BirthDate'               # 生年月日
  'Address'                 # 住所
  'PostalCode'              # 郵便番号
  'ContactNumber'           # 本人連絡先
  'Nationality'             # 国籍
  'ResidenceStatus'         # 在留資格
  'ResidenceLimit'          # 在留期限
  'WorkPermit'              # 資格外活動許可
  'EmploymentType'          # 区分
  'JobTitle'                # 職種
  'StartDate'               # 契約期間開始
  'EndDate'                 # 契約期間終了
  'RenewalFlag'             # 更新上限有無
  'RenewalLimit'            # 更新上限日
  'WorkLocation'            # 勤務場所
  'WorkDescription'         # 業務内容
  'WorkChangeScope'         # 業務内容の変更範囲
  'WorkDays'                # 勤務日数（週）
  'WorkWeekdaysChoice'      # 勤務曜日
  'HolidaysChoice'          # 休日
  'StartTime'               # 勤務開始時刻
  'EndTime'                 # 勤務終了時刻
  'BreakTime'               # 休憩時間
  'DailyWorkHours'          # 1日勤務時間
  'PayType'                 # 賃金形態
  'PayRate'                 # 賃金単価
  'FundingType'             # 雇用財源
  'ProjectCodeLookup'       # プロジェクトコード
  'ProjectName'             # プロジェクト名
  'ExpenseEstimate'         # 執行見込み総額
  'HRExpenseCode'           # 人件費番号
  'Stage1Approvers'         # 第1段承認者（部門）
  'Stage2Approvers'         # 第2段承認者（管理部門）
  'OverallApproval'         # 全体承認状態
  'Remarks'                 # 備考
  'SubmitBtn'               # 申請ボタン
  'Modified'                # 更新日時
  'Editor'                  # 更新者
)

Write-Host "ビューを作成中..." -ForegroundColor Yellow

# ビューを作成
Add-PnPView -List $SrcList -Title $viewName -Fields $viewFields -SetAsDefault

Write-Host "✓ ビュー作成完了: $viewName" -ForegroundColor Green
Write-Host "  フィールド数: $($viewFields.Count)" -ForegroundColor Green

Write-Host "`n========================================`n" -ForegroundColor Cyan
