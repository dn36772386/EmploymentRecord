#!/usr/bin/env pwsh
#Requires -Modules PnP.PowerShell
<#
.SYNOPSIS
  プロジェクトリストに表示用の計算列を追加

.DESCRIPTION
  ProjectCodeとProjectNameを連結した計算列を作成
  例: "PRJ001 - AI研究プロジェクト"
#>

param(
  [string]$SiteUrl = "https://tf1980.sharepoint.com/sites/abeam"
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  プロジェクト表示列追加" -ForegroundColor Cyan
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
  
  # 既存の計算列を削除（存在する場合）
  Write-Host "既存の計算列を確認中..." -NoNewline
  $existingField = Get-PnPField -List "EMP_1_Projects" -Identity "ProjectDisplay" -ErrorAction SilentlyContinue
  if ($existingField) {
    Remove-PnPField -List "EMP_1_Projects" -Identity "ProjectDisplay" -Force
    Write-Host " 既存列を削除" -ForegroundColor Yellow
  } else {
    Write-Host " ✓" -ForegroundColor Green
  }
  
  # 計算列を作成（ProjectCode と ProjectName を連結）
  Write-Host "計算列を作成中..." -NoNewline
  
  $fieldXml = @"
<Field 
  Type='Calculated' 
  DisplayName='プロジェクト表示' 
  ResultType='Text'
  ReadOnlyField='TRUE'
  ID='{$(New-Guid)}' 
  StaticName='ProjectDisplay' 
  Name='ProjectDisplay'>
  <Formula>=[ProjectCode]&amp;" - "&amp;[ProjectName]</Formula>
  <FieldRefs>
    <FieldRef Name='ProjectCode' />
    <FieldRef Name='ProjectName' />
  </FieldRefs>
</Field>
"@
  
  Add-PnPFieldFromXml -List "EMP_1_Projects" -FieldXml $fieldXml
  Write-Host " ✓" -ForegroundColor Green
  
  Write-Host ""
  Write-Host "========================================" -ForegroundColor Green
  Write-Host "  ✅ 計算列追加完了" -ForegroundColor Green
  Write-Host "========================================" -ForegroundColor Green
  Write-Host ""
  Write-Host "作成された列:" -ForegroundColor Yellow
  Write-Host "  プロジェクト表示 (ProjectDisplay)"
  Write-Host "  形式: [ProjectCode] - [ProjectName]"
  Write-Host ""
  
  # サンプルデータを表示
  Write-Host "サンプルデータ確認:" -ForegroundColor Yellow
  $items = Get-PnPListItem -List "EMP_1_Projects" -PageSize 5
  foreach ($item in $items) {
    $display = $item.FieldValues.ProjectDisplay
    Write-Host "  $display" -ForegroundColor Gray
  }
  
} catch {
  Write-Host " ✗" -ForegroundColor Red
  Write-Host ""
  Write-Host "❌ エラー: $_" -ForegroundColor Red
  Write-Host $_.ScriptStackTrace -ForegroundColor DarkGray
  exit 1
}
