# ================================================================
# 雇用記録にランダムな承認ステータスを設定
# ================================================================
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  雇用記録に承認ステータスを設定" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# 固定の承認者メールアドレス
$stage1ApproverEmail = "manager1@abctestdomain.com"
$stage2ApproverEmail = "dnakajima@abctestdomain.com"

Write-Host "承認者設定:" -ForegroundColor Yellow
Write-Host "  第1段承認者（部門）: $stage1ApproverEmail" -ForegroundColor Cyan
Write-Host "  第2段承認者（管理部門）: $stage2ApproverEmail`n" -ForegroundColor Cyan

# 雇用記録を取得
Write-Host "雇用記録を取得中..." -ForegroundColor Yellow
$records = Get-PnPListItem -List 'EMP_1_EmploymentRecords' -Fields "ID","Title","EmployeeID","FullName"
Write-Host "✓ 雇用記録取得完了: $($records.Count) 件`n" -ForegroundColor Green

$count = 0
$success = 0
$failed = 0

foreach ($record in $records) {
  $count++
  $recordId = $record.Id
  $employeeId = $record.FieldValues.EmployeeID
  $fullName = $record.FieldValues.FullName
  
  try {
    # ランダムな承認進捗を決定（0-4）
    # 0: 未申請
    # 1: 第1段申請中
    # 2: 第1段承認済み、第2段申請中
    # 3: 第2段承認済み（完了）
    # 4: いずれかの段階で却下/差戻し
    $progress = Get-Random -Minimum 0 -Maximum 5
    
    $values = @{}
    
    # 全体承認状態を更新
    $overallStatus = switch ($progress) {
      0 { "未申請" }
      1 { "第1段承認待ち" }
      2 { "第2段承認待ち" }
      3 { "承認完了" }
      4 { "差戻し" }
    }
    $values["OverallApproval"] = $overallStatus
    
    # 承認進捗に応じてフィールドを設定
    if ($progress -ge 1) {
      # 申請日時を設定
      $submittedDate = (Get-Date).AddDays(-(Get-Random -Minimum 3 -Maximum 10))
      $values["SubmittedDate"] = $submittedDate
      
      # 第1段承認者を設定
      $values["Stage1Approvers"] = @($stage1ApproverEmail)
      
      if ($progress -eq 4) {
        # 却下または差戻し
        $isRejected = (Get-Random -Minimum 0 -Maximum 2) -eq 0
        $values["Stage1ApprovalStatus"] = if ($isRejected) { "却下" } else { "差戻し" }
        $values["Stage1ApprovalComment"] = if ($isRejected) {
          "予算上の制約により、この雇用調書は承認できません。再度検討してください。"
        } else {
          "記入内容に不備があります。以下を修正して再提出してください：`n- 職務内容の詳細が不足しています`n- 給与額の根拠を追加してください"
        }
        $values["Stage1ApprovalDate"] = $submittedDate.AddDays(1)
      }
      elseif ($progress -ge 2) {
        # 第1段承認済み
        $values["Stage1ApprovalStatus"] = "承認"
        $values["Stage1ApprovalComment"] = "部門として承認します。適切な人材配置と判断します。"
        $values["Stage1ApprovalDate"] = $submittedDate.AddDays(1)
        
        # 第2段承認者を設定
        $values["Stage2Approvers"] = @($stage2ApproverEmail)
        
        if ($progress -eq 2) {
          # 第2段申請中
          $values["Stage2ApprovalStatus"] = "申請中"
        }
        elseif ($progress -eq 3) {
          # 第2段承認済み
          $values["Stage2ApprovalStatus"] = "承認"
          $values["Stage2ApprovalComment"] = "管理部門として最終承認します。手続きを進めてください。"
          $values["Stage2ApprovalDate"] = $submittedDate.AddDays(2)
        }
      }
      else {
        # 第1段申請中
        $values["Stage1ApprovalStatus"] = "申請中"
      }
    }
    else {
      # 未申請
      $values["Stage1ApprovalStatus"] = "未申請"
      $values["Stage2ApprovalStatus"] = "未申請"
    }
    
    # レコードを更新
    Set-PnPListItem -List 'EMP_1_EmploymentRecords' -Identity $recordId -Values $values | Out-Null
    
    $statusColor = switch ($overallStatus) {
      '未申請' { 'Gray' }
      '第1段承認待ち' { 'Yellow' }
      '第2段承認待ち' { 'Yellow' }
      '承認完了' { 'Green' }
      '差戻し' { 'Red' }
      default { 'White' }
    }
    
    Write-Host "  [$count/$($records.Count)] ✓ $employeeId - $fullName : $overallStatus" -ForegroundColor $statusColor
    $success++
  }
  catch {
    Write-Host "  [$count/$($records.Count)] ✗ エラー: $($_.Exception.Message)" -ForegroundColor Red
    $failed++
  }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  更新完了" -ForegroundColor Cyan
Write-Host "  成功: $success 件" -ForegroundColor Green
Write-Host "  失敗: $failed 件" -ForegroundColor $(if($failed -gt 0){'Red'}else{'Green'})
Write-Host "========================================`n" -ForegroundColor Cyan

# 結果のサマリーを表示
Write-Host "承認ステータスのサマリー:" -ForegroundColor Cyan
$allRecords = Get-PnPListItem -List 'EMP_1_EmploymentRecords' -Fields "OverallApproval","Stage1ApprovalStatus","Stage2ApprovalStatus"

$summary = $allRecords | Group-Object { $_.FieldValues.OverallApproval } | Sort-Object Name
foreach ($group in $summary) {
  $statusIcon = switch ($group.Name) {
    '未申請' { '📝' }
    '第1段承認待ち' { '⏳' }
    '第2段承認待ち' { '⏳' }
    '承認完了' { '✅' }
    '差戻し' { '🔙' }
    default { '❓' }
  }
  Write-Host "  $statusIcon $($group.Name): $($group.Count) 件" -ForegroundColor Cyan
}

Write-Host "`n✅ 承認ステータスの設定が完了しました！" -ForegroundColor Green
Write-Host "  - 各雇用記録にランダムな承認進捗を設定しました" -ForegroundColor Gray
Write-Host "  - 承認者、コメント、日時も自動設定されています" -ForegroundColor Gray
Write-Host "  - SharePointのリストで確認してください`n" -ForegroundColor Gray
