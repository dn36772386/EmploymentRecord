#!/usr/bin/env pwsh
#Requires -Modules PnP.PowerShell
<#
.SYNOPSIS
  雇用記録リストのプロジェクト参照フィールドを複数選択対応に更新

.DESCRIPTION
  1. 既存のProjectCodeLookupフィールドを削除
  2. ProjectNameフィールドを削除（Lookupから取得するため不要）
  3. 複数選択可能なProjectCodeLookupフィールドを作成
  4. ProjectNameも参照できるように追加フィールドを作成
#>

param(
  [string]$SiteUrl = "https://tf1980.sharepoint.com/sites/abeam"
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  プロジェクト参照フィールド更新" -ForegroundColor Cyan
Write-Host "  (複数選択対応)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

try {
  # プロジェクトマスタリストを確認
  Write-Host "プロジェクトマスタを確認中..." -NoNewline
  $projectList = Get-PnPList -Identity "EMP_1_Projects"
  if (-not $projectList) {
    throw "プロジェクトマスタリスト (EMP_1_Projects) が見つかりません"
  }
  Write-Host " ✓" -ForegroundColor Green
  
  # 雇用記録リストを確認
  Write-Host "雇用記録リストを確認中..." -NoNewline
  $empList = Get-PnPList -Identity "EMP_1_EmploymentRecords"
  if (-not $empList) {
    throw "雇用記録リスト (EMP_1_EmploymentRecords) が見つかりません"
  }
  Write-Host " ✓" -ForegroundColor Green
  
  # 既存のProjectCodeLookupフィールドを削除
  Write-Host "既存のProjectCodeLookupフィールドを削除中..." -NoNewline
  $existingLookup = Get-PnPField -List "EMP_1_EmploymentRecords" -Identity "ProjectCodeLookup" -ErrorAction SilentlyContinue
  if ($existingLookup) {
    Remove-PnPField -List "EMP_1_EmploymentRecords" -Identity "ProjectCodeLookup" -Force
    Write-Host " ✓" -ForegroundColor Green
  } else {
    Write-Host " (存在しません)" -ForegroundColor Gray
  }
  
  # ProjectNameフィールドを削除
  Write-Host "ProjectNameフィールドを削除中..." -NoNewline
  $existingProjectName = Get-PnPField -List "EMP_1_EmploymentRecords" -Identity "ProjectName" -ErrorAction SilentlyContinue
  if ($existingProjectName) {
    Remove-PnPField -List "EMP_1_EmploymentRecords" -Identity "ProjectName" -Force
    Write-Host " ✓" -ForegroundColor Green
  } else {
    Write-Host " (存在しません)" -ForegroundColor Gray
  }
  
  # 複数選択可能なLookupフィールドを作成（ProjectCode参照）
  Write-Host "複数選択対応Lookupフィールドを作成中..." -NoNewline
  
  $fieldXml = @"
<Field 
  Type='LookupMulti' 
  DisplayName='プロジェクトコード' 
  Required='FALSE' 
  EnforceUniqueValues='FALSE' 
  List='$($projectList.Id)' 
  ShowField='ProjectCode' 
  Mult='TRUE'
  UnlimitedLengthInDocumentLibrary='FALSE' 
  RelationshipDeleteBehavior='None' 
  ID='{$(New-Guid)}' 
  StaticName='ProjectCodeLookup' 
  Name='ProjectCodeLookup' />
"@
  
  Add-PnPFieldFromXml -List "EMP_1_EmploymentRecords" -FieldXml $fieldXml
  Write-Host " ✓" -ForegroundColor Green
  
  # ProjectName参照フィールドを作成（読み取り専用）
  Write-Host "プロジェクト名称参照フィールドを作成中..." -NoNewline
  
  # まずProjectCodeLookupのIDを取得
  $lookupField = Get-PnPField -List "EMP_1_EmploymentRecords" -Identity "ProjectCodeLookup"
  
  $projectNameFieldXml = @"
<Field 
  Type='Lookup' 
  DisplayName='プロジェクト名称' 
  Required='FALSE' 
  List='$($projectList.Id)' 
  ShowField='ProjectName' 
  FieldRef='$($lookupField.Id)'
  ReadOnlyField='TRUE'
  UnlimitedLengthInDocumentLibrary='FALSE' 
  ID='{$(New-Guid)}' 
  StaticName='ProjectNameLookup' 
  Name='ProjectNameLookup' />
"@
  
  Add-PnPFieldFromXml -List "EMP_1_EmploymentRecords" -FieldXml $projectNameFieldXml
  Write-Host " ✓" -ForegroundColor Green
  
  Write-Host ""
  Write-Host "========================================" -ForegroundColor Green
  Write-Host "  ✅ フィールド更新完了" -ForegroundColor Green
  Write-Host "========================================" -ForegroundColor Green
  Write-Host ""
  Write-Host "作成されたフィールド:" -ForegroundColor Yellow
  Write-Host "  1. プロジェクトコード (ProjectCodeLookup) - 複数選択可能"
  Write-Host "  2. プロジェクト名称 (ProjectNameLookup) - 自動連動"
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
