# ================================================================
# 雇用記録に承認関連フィールドを追加
# ================================================================
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  雇用記録に承認フィールドを追加" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$listName = 'EMP_1_EmploymentRecords'

try {
  # 第1段承認ステータス
  Write-Host "第1段承認ステータスフィールドを追加中..." -ForegroundColor Yellow
  try {
    Add-PnPField -List $listName -DisplayName "第1段承認ステータス" -InternalName "Stage1ApprovalStatus" -Type Choice -Choices @("未申請", "申請中", "承認", "却下", "差戻し") -AddToDefaultView
    Write-Host "✓ 第1段承認ステータス追加完了" -ForegroundColor Green
  }
  catch {
    Write-Host "⚠ 第1段承認ステータス: $($_.Exception.Message)" -ForegroundColor Yellow
  }

  # 第1段承認コメント
  Write-Host "第1段承認コメントフィールドを追加中..." -ForegroundColor Yellow
  try {
    Add-PnPField -List $listName -DisplayName "第1段承認コメント" -InternalName "Stage1ApprovalComment" -Type Note -AddToDefaultView
    Write-Host "✓ 第1段承認コメント追加完了" -ForegroundColor Green
  }
  catch {
    Write-Host "⚠ 第1段承認コメント: $($_.Exception.Message)" -ForegroundColor Yellow
  }

  # 第1段承認日時
  Write-Host "第1段承認日時フィールドを追加中..." -ForegroundColor Yellow
  try {
    Add-PnPField -List $listName -DisplayName "第1段承認日時" -InternalName "Stage1ApprovalDate" -Type DateTime -AddToDefaultView
    Write-Host "✓ 第1段承認日時追加完了" -ForegroundColor Green
  }
  catch {
    Write-Host "⚠ 第1段承認日時: $($_.Exception.Message)" -ForegroundColor Yellow
  }

  # 第2段承認ステータス
  Write-Host "第2段承認ステータスフィールドを追加中..." -ForegroundColor Yellow
  try {
    Add-PnPField -List $listName -DisplayName "第2段承認ステータス" -InternalName "Stage2ApprovalStatus" -Type Choice -Choices @("未申請", "申請中", "承認", "却下", "差戻し") -AddToDefaultView
    Write-Host "✓ 第2段承認ステータス追加完了" -ForegroundColor Green
  }
  catch {
    Write-Host "⚠ 第2段承認ステータス: $($_.Exception.Message)" -ForegroundColor Yellow
  }

  # 第2段承認コメント
  Write-Host "第2段承認コメントフィールドを追加中..." -ForegroundColor Yellow
  try {
    Add-PnPField -List $listName -DisplayName "第2段承認コメント" -InternalName "Stage2ApprovalComment" -Type Note -AddToDefaultView
    Write-Host "✓ 第2段承認コメント追加完了" -ForegroundColor Green
  }
  catch {
    Write-Host "⚠ 第2段承認コメント: $($_.Exception.Message)" -ForegroundColor Yellow
  }

  # 第2段承認日時
  Write-Host "第2段承認日時フィールドを追加中..." -ForegroundColor Yellow
  try {
    Add-PnPField -List $listName -DisplayName "第2段承認日時" -InternalName "Stage2ApprovalDate" -Type DateTime -AddToDefaultView
    Write-Host "✓ 第2段承認日時追加完了" -ForegroundColor Green
  }
  catch {
    Write-Host "⚠ 第2段承認日時: $($_.Exception.Message)" -ForegroundColor Yellow
  }

  # 申請日時
  Write-Host "申請日時フィールドを追加中..." -ForegroundColor Yellow
  try {
    Add-PnPField -List $listName -DisplayName "申請日時" -InternalName "SubmittedDate" -Type DateTime -AddToDefaultView
    Write-Host "✓ 申請日時追加完了" -ForegroundColor Green
  }
  catch {
    Write-Host "⚠ 申請日時: $($_.Exception.Message)" -ForegroundColor Yellow
  }

  Write-Host "`n✅ 承認フィールドの追加が完了しました" -ForegroundColor Green
  
  # フィールド一覧を表示
  Write-Host "`n追加されたフィールド:" -ForegroundColor Cyan
  Get-PnPField -List $listName | Where-Object { 
    $_.InternalName -like 'Stage*Approval*' -or $_.InternalName -eq 'SubmittedDate'
  } | Select-Object Title, InternalName, TypeAsString | Format-Table
}
catch {
  Write-Host "`n❌ エラーが発生しました: $($_.Exception.Message)" -ForegroundColor Red
  throw
}
