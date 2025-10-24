#!/usr/bin/env pwsh
#Requires -Modules PnP.PowerShell
<#
.SYNOPSIS
  雇用記録のプロジェクト参照を更新

.DESCRIPTION
  1. ProjectNameLookupフィールドを削除
  2. ProjectCodeLookupをProjectDisplay参照に変更
  3. ビューのフィールド順序を修正
#>

param(
  [string]$SiteUrl = "https://tf1980.sharepoint.com/sites/abeam"
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  プロジェクト参照フィールド最終調整" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

try {
  # ProjectNameLookupフィールドを削除
  Write-Host "ProjectNameLookupフィールドを削除中..." -NoNewline
  $existingProjectName = Get-PnPField -List "EMP_1_EmploymentRecords" -Identity "ProjectNameLookup" -ErrorAction SilentlyContinue
  if ($existingProjectName) {
    Remove-PnPField -List "EMP_1_EmploymentRecords" -Identity "ProjectNameLookup" -Force
    Write-Host " ✓" -ForegroundColor Green
  } else {
    Write-Host " (存在しません)" -ForegroundColor Gray
  }
  
  # 既存のProjectCodeLookupフィールドを削除
  Write-Host "既存のProjectCodeLookupフィールドを削除中..." -NoNewline
  $existingLookup = Get-PnPField -List "EMP_1_EmploymentRecords" -Identity "ProjectCodeLookup" -ErrorAction SilentlyContinue
  if ($existingLookup) {
    Remove-PnPField -List "EMP_1_EmploymentRecords" -Identity "ProjectCodeLookup" -Force
    Write-Host " ✓" -ForegroundColor Green
  } else {
    Write-Host " (存在しません)" -ForegroundColor Gray
  }
  
  # プロジェクトマスタリストを確認
  Write-Host "プロジェクトマスタを確認中..." -NoNewline
  $projectList = Get-PnPList -Identity "EMP_1_Projects"
  if (-not $projectList) {
    throw "プロジェクトマスタリスト (EMP_1_Projects) が見つかりません"
  }
  Write-Host " ✓" -ForegroundColor Green
  
  # 新しいLookupフィールドを作成（ProjectDisplay参照）
  Write-Host "新しいLookupフィールドを作成中..." -NoNewline
  
  $fieldXml = @"
<Field 
  Type='LookupMulti' 
  DisplayName='プロジェクト' 
  Required='FALSE' 
  EnforceUniqueValues='FALSE' 
  List='$($projectList.Id)' 
  ShowField='ProjectDisplay' 
  Mult='TRUE'
  UnlimitedLengthInDocumentLibrary='FALSE' 
  RelationshipDeleteBehavior='None' 
  ID='{$(New-Guid)}' 
  StaticName='ProjectCodeLookup' 
  Name='ProjectCodeLookup' />
"@
  
  Add-PnPFieldFromXml -List "EMP_1_EmploymentRecords" -FieldXml $fieldXml
  Write-Host " ✓" -ForegroundColor Green
  
  Write-Host ""
  Write-Host "========================================" -ForegroundColor Green
  Write-Host "  ✅ フィールド更新完了" -ForegroundColor Green
  Write-Host "========================================" -ForegroundColor Green
  Write-Host ""
  Write-Host "注意: 既存データのLookup値はクリアされています。" -ForegroundColor Yellow
  Write-Host "      update-employment-project-lookup.ps1 を実行して再設定してください。" -ForegroundColor Yellow
  
} catch {
  Write-Host " ✗" -ForegroundColor Red
  Write-Host ""
  Write-Host "❌ エラー: $_" -ForegroundColor Red
  Write-Host $_.ScriptStackTrace -ForegroundColor DarkGray
  exit 1
}
