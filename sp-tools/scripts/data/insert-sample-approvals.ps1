Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'

# 既に接続されているかチェック
$conn = Get-PnPConnection -ErrorAction SilentlyContinue
if (-not $conn) {
  . "$PSScriptRoot/connect.ps1"
}
. "$PSScriptRoot/config.ps1"

# リスト名を文字列として確実に設定
$SrcList = 'EMP_1_EmploymentRecords'
$Approvals = 'EMP_1_EmploymentApprovals'

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  承認履歴サンプルデータ登録" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# 雇用記録を取得
Write-Host "雇用記録を確認中..." -ForegroundColor Gray
$employmentRecords = Get-PnPListItem -List $SrcList -Fields "ID","EmployeeID","FullName" | Sort-Object -Property @{Expression={$_.FieldValues.EmployeeID}}

if ($employmentRecords.Count -eq 0) {
  Write-Host "✗ エラー: 雇用記録にデータがありません" -ForegroundColor Red
  Write-Host "  先に ./insert-sample-employment-records-v2.ps1 を実行してください" -ForegroundColor Yellow
  exit 1
}
Write-Host "✓ 雇用記録取得完了: $($employmentRecords.Count) 件" -ForegroundColor Green

# 固定ユーザー設定
Write-Host "承認者を設定中..." -ForegroundColor Gray
$applicantEmail = "user1@abctestdomain.com"        # 申請者
$stage1ApproverEmail = "manager1@abctestdomain.com"  # 第1段承認者（部門）
$stage2ApproverEmail = "dnakajima@abctestdomain.com" # 第2段承認者（管理部門）
Write-Host "  申請者: $applicantEmail" -ForegroundColor Gray
Write-Host "  第1段承認者（部門）: $stage1ApproverEmail" -ForegroundColor Gray
Write-Host "  第2段承認者（管理部門）: $stage2ApproverEmail" -ForegroundColor Gray
Write-Host "✓ 承認者設定完了" -ForegroundColor Green

# 承認状態のリスト（ランダム選択用）
$statusList = @('下書き', '申請中', '承認', '却下', '差戻し')

# 承認履歴サンプルデータを生成
Write-Host "`n承認履歴データを生成中..." -ForegroundColor Yellow
$approvals = @()
$recordIndex = 0

foreach ($record in $employmentRecords) {
  $recordIndex++
  $recordId = $record.Id
  $employeeId = $record.FieldValues.EmployeeID
  $fullName = $record.FieldValues.FullName
  
  # 各雇用記録に対して3段階の承認フローを作成
  # 1. 申請者（本人）
  # 2. 第1段承認者（部門長）
  # 3. 第2段承認者（管理部門）
  
  # ランダムに承認状態を決定（進捗度を変える）
  $progress = Get-Random -Minimum 0 -Maximum 4
  # 0: 下書きのみ
  # 1: 申請中（申請済み、第1段待ち）
  # 2: 第1段承認済み、第2段待ち
  # 3: 全承認完了 or 却下/差戻し
  
  # Stage 0: 申請者（下書き/申請）
  $status0 = if ($progress -eq 0) { '下書き' } else { '申請中' }
  $actionedAt0 = if ($progress -ge 1) { (Get-Date).AddDays(-(Get-Random -Minimum 10 -Maximum 30)) } else { $null }
  
  $approvals += @{
    ParentRecordId = $recordId
    StageNumber = 0
    StageType = '部門'
    ParallelGroupId = ''
    IsRequired = $true
    ApproverEmail = $applicantEmail
    Status = $status0
    DueDate = (Get-Date).AddDays(7)
    ActionedAt = $actionedAt0
    Note = if ($progress -ge 1) { "申請を提出しました" } else { "" }
    ActionedByEmail = if ($progress -ge 1) { $applicantEmail } else { $null }
    Order = 1
    EmployeeInfo = "$employeeId - $fullName"
  }
  
  # Stage 1: 第1段承認者（部門長）
  if ($progress -ge 1) {
    $status1 = switch ($progress) {
      1 { '申請中' }
      2 { '承認' }
      3 { 
        $rand = Get-Random -Minimum 0 -Maximum 10
        if ($rand -lt 7) { '承認' } elseif ($rand -lt 9) { '却下' } else { '差戻し' }
      }
    }
    $actionedAt1 = if ($progress -ge 2) { (Get-Date).AddDays(-(Get-Random -Minimum 5 -Maximum 15)) } else { $null }
    $noteText1 = switch ($status1) {
      '申請中' { "" }
      '承認' { "部門として承認します" }
      '却下' { "記載内容に不備があります。差し戻しします" }
      '差戻し' { "プロジェクトコードを確認してください" }
    }
    
    $approvals += @{
      ParentRecordId = $recordId
      StageNumber = 1
      StageType = '部門'
      ParallelGroupId = ''
      IsRequired = $true
      ApproverEmail = $stage1ApproverEmail
      Status = $status1
      DueDate = (Get-Date).AddDays(5)
      ActionedAt = $actionedAt1
      Note = $noteText1
      ActionedByEmail = if ($progress -ge 2) { $stage1ApproverEmail } else { $null }
      Order = 2
      EmployeeInfo = "$employeeId - $fullName"
    }
  }
  
  # Stage 2: 第2段承認者（管理部門）- 第1段が承認された場合のみ
  if ($progress -ge 2 -and $approvals[-1].Status -eq '承認') {
    $status2 = if ($progress -eq 2) { '申請中' } else {
      $rand = Get-Random -Minimum 0 -Maximum 10
      if ($rand -lt 8) { '承認' } else { '却下' }
    }
    $actionedAt2 = if ($progress -ge 3) { (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 7)) } else { $null }
    $noteText2 = switch ($status2) {
      '申請中' { "" }
      '承認' { "最終承認します。手続きを進めてください" }
      '却下' { "予算調整が必要です。再検討をお願いします" }
    }
    
    $approvals += @{
      ParentRecordId = $recordId
      StageNumber = 2
      StageType = '管理部門'
      ParallelGroupId = ''
      IsRequired = $true
      ApproverEmail = $stage2ApproverEmail
      Status = $status2
      DueDate = (Get-Date).AddDays(3)
      ActionedAt = $actionedAt2
      Note = $noteText2
      ActionedByEmail = if ($progress -ge 3) { $stage2ApproverEmail } else { $null }
      Order = 3
      EmployeeInfo = "$employeeId - $fullName"
    }
  }
}

Write-Host "✓ 承認履歴データ生成完了: $($approvals.Count) 件" -ForegroundColor Green

# 承認履歴を登録
Write-Host "`n承認履歴を登録中..." -ForegroundColor Yellow
$count = 0
$success = 0
$failed = 0

foreach ($approval in $approvals) {
  $count++
  try {
    # 基本情報でアイテムを作成（Lookupフィールド除外）
    $values = @{
      "Title" = "承認 - Stage $($approval.StageNumber) - $($approval.EmployeeInfo)"
      "StageNumber" = $approval.StageNumber
      "StageType" = $approval.StageType
      "IsRequired" = $approval.IsRequired
      "ApproverEmail" = $approval.ApproverEmail
      "Status" = $approval.Status
      "DueDate" = $approval.DueDate
      "Order" = $approval.Order
    }
    
    # Approverフィールドはメールアドレスで設定
    if ($approval.ApproverEmail) {
      $values["Approver"] = $approval.ApproverEmail
    }
    
    # オプション項目
    if ($approval.ParallelGroupId) { $values["ParallelGroupId"] = $approval.ParallelGroupId }
    if ($approval.ActionedAt) { $values["ActionedAt"] = $approval.ActionedAt }
    if ($approval.Note) { $values["Note"] = $approval.Note }
    if ($approval.ActionedByEmail) { $values["ActionedBy"] = $approval.ActionedByEmail }
    
    # アイテム作成
    $item = Add-PnPListItem -List 'EMP_1_EmploymentApprovals' -Values $values
    
    # Set-PnPListItemでLookupフィールドを更新（Lookup値形式: "ID;#Value"）
    if ($approval.ParentRecordId) {
      $lookupValue = "$($approval.ParentRecordId);#$($approval.ParentRecordId)"
      Set-PnPListItem -List 'EMP_1_EmploymentApprovals' -Identity $item.Id -Values @{
        "ParentRecord" = $lookupValue
      } | Out-Null
    }
    
    $statusColor = switch ($approval.Status) {
      '下書き' { 'Gray' }
      '申請中' { 'Yellow' }
      '承認' { 'Green' }
      '却下' { 'Red' }
      '差戻し' { 'Magenta' }
      default { 'White' }
    }
    Write-Host "  [$count/$($approvals.Count)] ✓ Stage $($approval.StageNumber) - $($approval.EmployeeInfo) - $($approval.Status)" -ForegroundColor $statusColor
    $success++
  }
  catch {
    Write-Host "  [$count/$($approvals.Count)] ✗ エラー: $($_.Exception.Message)" -ForegroundColor Red
    $failed++
  }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  登録完了" -ForegroundColor Cyan
Write-Host "  成功: $success 件" -ForegroundColor Green
Write-Host "  失敗: $failed 件" -ForegroundColor $(if($failed -gt 0){'Red'}else{'Green'})
Write-Host "========================================`n" -ForegroundColor Cyan

# 登録結果を確認
Write-Host "登録された承認履歴一覧:" -ForegroundColor Yellow
$allApprovals = Get-PnPListItem -List 'EMP_1_EmploymentApprovals' -Fields "StageNumber","StageType","Status","ApproverEmail","Order" | Sort-Object -Property @{Expression={$_.FieldValues.Order}}

Write-Host "  合計: $($allApprovals.Count) 件登録" -ForegroundColor Cyan
foreach ($app in $allApprovals | Select-Object -First 10) {
  $stageNum = $app.FieldValues.StageNumber
  $stageType = $app.FieldValues.StageType
  $status = $app.FieldValues.Status
  $approverEmail = $app.FieldValues.ApproverEmail
  $statusIcon = switch ($status) {
    '下書き' { '📝' }
    '申請中' { '⏳' }
    '承認' { '✅' }
    '却下' { '❌' }
    '差戻し' { '↩️' }
    default { '❓' }
  }
  Write-Host "  Stage $stageNum [$stageType]: $statusIcon $status ($approverEmail)" -ForegroundColor Gray
}
if ($allApprovals.Count -gt 10) {
  Write-Host "  ... 他 $($allApprovals.Count - 10) 件" -ForegroundColor Gray
}

Write-Host "`n✅ 承認履歴サンプルデータ登録完了！" -ForegroundColor Green
Write-Host "   - 各雇用記録に対してランダムな承認状態を設定しました" -ForegroundColor Gray
Write-Host "   - 下書き、申請中、承認、却下、差戻しの各状態が含まれます" -ForegroundColor Gray
Write-Host "   - 申請者: user1@abctestdomain.com" -ForegroundColor Gray
Write-Host "   - 第1段承認者（部門）: manager1@abctestdomain.com" -ForegroundColor Gray
Write-Host "   - 第2段承認者（管理部門）: dnakajima@abctestdomain.com" -ForegroundColor Gray
