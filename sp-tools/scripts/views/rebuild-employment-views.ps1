#!/usr/bin/env pwsh
#Requires -Modules PnP.PowerShell
<#
.SYNOPSIS
  雇用記録リストのビューを完全に再構築

.DESCRIPTION
  すべてのビューを削除し、正しいフィールド順序で新しいビューを作成
#>

Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'

# 接続
. "$PSScriptRoot/connect.ps1"
. "$PSScriptRoot/config.ps1"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  雇用記録ビュー完全再構築" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

try {
  # 既存のすべてのビューを削除
  Write-Host "既存ビューを削除中..." -ForegroundColor Yellow
  $views = Get-PnPView -List $SrcList
  foreach ($view in $views) {
    if ($view.Title -ne "すべてのドキュメント") {
      Write-Host "  削除: $($view.Title)" -ForegroundColor Gray
      Remove-PnPView -List $SrcList -Identity $view.Title -Force
    }
  }
  Write-Host "✓ 既存ビュー削除完了" -ForegroundColor Green
  
  # メインビュー作成（基本情報 + プロジェクト + 勤務・給与）
  Write-Host "`nメインビューを作成中..." -ForegroundColor Yellow
  
  $mainViewFields = @(
    "ID"
    "EmployeeID"
    "FullName"
    "Department"
    "ProjectCodeLookup"
    "EmploymentType"
    "StartDate"
    "EndDate"
    "WorkLocation"
    "PayType"
    "PayRate"
    "FundingType"
    "Modified"
    "Created"
  )
  
  Add-PnPView -List $SrcList -Title "すべてのアイテム" -Fields $mainViewFields -SetAsDefault
  Write-Host "✓ メインビュー作成完了" -ForegroundColor Green
  
  # 雇用記録一覧ビュー作成（より詳細な情報を含む）
  Write-Host "雇用調書詳細ビューを作成中..." -ForegroundColor Yellow
  
  $detailViewFields = @(
    "ID"
    "EmploymentReason"
    "EmployeeID"
    "Department"
    "GroupName"
    "FullName"
    "Furigana"
    "Gender"
    "BirthDate"
    "Address"
    "PostalCode"
    "ContactNumber"
    "Nationality"
    "EmploymentType"
    "JobTitle"
    "ProjectCodeLookup"
    "StartDate"
    "EndDate"
    "RenewalFlag"
    "RenewalLimit"
    "WorkLocation"
    "WorkDescription"
    "WorkDays"
    "DailyWorkHours"
    "PayType"
    "PayRate"
    "FundingType"
    "ExpenseEstimate"
    "HRExpenseCode"
    "Remarks"
    "Modified"
    "Created"
  )
  
  Add-PnPView -List $SrcList -Title "雇用調書詳細" -Fields $detailViewFields
  Write-Host "✓ 雇用調書詳細ビュー作成完了" -ForegroundColor Green
  
  # 作成されたビューを確認
  Write-Host "`n作成されたビュー:" -ForegroundColor Yellow
  $views = Get-PnPView -List $SrcList
  foreach ($view in $views) {
    Write-Host "  - $($view.Title) (既定: $($view.DefaultView), フィールド数: $($view.ViewFields.Count))" -ForegroundColor Green
  }
  
  Write-Host ""
  Write-Host "========================================" -ForegroundColor Green
  Write-Host "  ✅ ビュー再構築完了" -ForegroundColor Green
  Write-Host "========================================" -ForegroundColor Green
  
} catch {
  Write-Host ""
  Write-Host "❌ エラー: $_" -ForegroundColor Red
  Write-Host $_.ScriptStackTrace -ForegroundColor DarkGray
  exit 1
}
