#!/usr/bin/env pwsh
#Requires -Modules PnP.PowerShell
<#
.SYNOPSIS
  雇用記録リストにプロジェクトコード参照フィールドを追加

.DESCRIPTION
  EMP_1_EmploymentRecordsリストに、EMP_1_Projectsリストを参照する
  Lookupフィールド「ProjectCodeLookup」を作成します。
#>

param(
  [string]$SiteUrl = "https://tf1980.sharepoint.com/sites/abeam"
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  プロジェクト参照フィールド作成" -ForegroundColor Cyan
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
  
  # 既存フィールドを確認
  Write-Host "既存フィールドを確認中..." -NoNewline
  $existingField = Get-PnPField -List "EMP_1_EmploymentRecords" -Identity "ProjectCodeLookup" -ErrorAction SilentlyContinue
  
  if ($existingField) {
    Write-Host " ⚠️  既に存在します" -ForegroundColor Yellow
    Write-Host "`nフィールド情報:" -ForegroundColor Yellow
    Write-Host "  内部名: $($existingField.InternalName)"
    Write-Host "  表示名: $($existingField.Title)"
    Write-Host "  種類: $($existingField.TypeAsString)"
    return
  }
  Write-Host " ✓" -ForegroundColor Green
  
  # Lookupフィールドを作成
  Write-Host "Lookupフィールドを作成中..." -NoNewline
  
  $fieldXml = @"
<Field 
  Type='Lookup' 
  DisplayName='プロジェクトコード' 
  Required='FALSE' 
  EnforceUniqueValues='FALSE' 
  List='$($projectList.Id)' 
  ShowField='ProjectCode' 
  UnlimitedLengthInDocumentLibrary='FALSE' 
  RelationshipDeleteBehavior='None' 
  ID='{$(New-Guid)}' 
  StaticName='ProjectCodeLookup' 
  Name='ProjectCodeLookup' />
"@
  
  Add-PnPFieldFromXml -List "EMP_1_EmploymentRecords" -FieldXml $fieldXml
  
  Write-Host " ✓" -ForegroundColor Green
  
  # 作成されたフィールドを確認
  Write-Host "フィールド作成を確認中..." -NoNewline
  $newField = Get-PnPField -List "EMP_1_EmploymentRecords" -Identity "ProjectCodeLookup"
  Write-Host " ✓" -ForegroundColor Green
  
  Write-Host ""
  Write-Host "========================================" -ForegroundColor Green
  Write-Host "  ✅ フィールド作成完了" -ForegroundColor Green
  Write-Host "========================================" -ForegroundColor Green
  Write-Host ""
  Write-Host "作成されたフィールド:" -ForegroundColor Yellow
  Write-Host "  内部名: $($newField.InternalName)"
  Write-Host "  表示名: $($newField.Title)"
  Write-Host "  種類: $($newField.TypeAsString)"
  Write-Host "  参照先: EMP_1_Projects (ProjectCode)"
  
} catch {
  Write-Host " ✗" -ForegroundColor Red
  Write-Host ""
  Write-Host "❌ エラー: $_" -ForegroundColor Red
  Write-Host $_.ScriptStackTrace -ForegroundColor DarkGray
  exit 1
}
