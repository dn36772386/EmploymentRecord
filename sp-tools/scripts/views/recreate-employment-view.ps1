#!/usr/bin/env pwsh
#Requires -Modules PnP.PowerShell
<#
.SYNOPSIS
  雇用記録リストのビューを再作成（フィールド順序を整理）

.DESCRIPTION
  ProjectCodeLookupとProjectNameLookupを適切な位置に配置したビューを作成
#>

Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'

# 既に接続されているかチェック
$conn = Get-PnPConnection -ErrorAction SilentlyContinue
if (-not $conn) {
  . "$PSScriptRoot/connect.ps1"
}
. "$PSScriptRoot/config.ps1"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  雇用記録ビュー再作成" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# 既存のビューを削除
Write-Host "既存ビューを削除中..." -ForegroundColor Gray
$existingView = Get-PnPView -List $SrcList -Identity "すべてのアイテム" -ErrorAction SilentlyContinue
if ($existingView) {
  Remove-PnPView -List $SrcList -Identity "すべてのアイテム" -Force
  Write-Host "✓ 既存ビュー削除完了" -ForegroundColor Green
}

# 新しいビューを作成（フィールド順序を指定）
Write-Host "新しいビューを作成中..." -ForegroundColor Gray

$viewFields = @(
  "ID"
  "EmployeeID"
  "FullName"
  "Department"
  "ProjectCodeLookup"
  "ProjectNameLookup"
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

Add-PnPView -List $SrcList -Title "すべてのアイテム" -Fields $viewFields -SetAsDefault

Write-Host "✓ ビュー作成完了" -ForegroundColor Green

# 作成されたビューを確認
Write-Host "`nビュー情報:" -ForegroundColor Yellow
$view = Get-PnPView -List $SrcList -Identity "すべてのアイテム"
Write-Host "  タイトル: $($view.Title)"
Write-Host "  既定: $($view.DefaultView)"
Write-Host "  フィールド数: $($view.ViewFields.Count)"
Write-Host ""
Write-Host "表示フィールド順序:" -ForegroundColor Yellow
$view.ViewFields | ForEach-Object { $i=1 } { Write-Host "  $i. $_" -ForegroundColor Gray; $i++ }

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "  ✅ ビュー再作成完了" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Green
