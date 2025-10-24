#!/usr/bin/env pwsh
#Requires -Modules PnP.PowerShell
<#
.SYNOPSIS
  プロジェクトマスタとLookupフィールドの完全セットアップ

.DESCRIPTION
  1回の接続で以下の作業を全て実行:
  1. プロジェクトのTitleを「コード - 名称」形式に更新
  2. LookupフィールドをTitle参照に再作成
  3. 雇用記録のLookup値を再設定
  4. ビューを整理
#>

param(
  [string]$SiteUrl = "https://tf1980.sharepoint.com/sites/abeam"
)

$ErrorActionPreference = "Stop"

# 接続（1回のみ）
. "$PSScriptRoot/connect.ps1"
. "$PSScriptRoot/config.ps1"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  プロジェクト参照の完全セットアップ" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

try {
  # ステップ1: プロジェクトのTitleを更新（既に完了している場合はスキップ）
  Write-Host "[1/4] プロジェクトのTitle確認・更新中..." -ForegroundColor Yellow
  $projects = @(Get-PnPListItem -List $ProjectMaster)
  $needsUpdate = $false
  
  foreach ($project in $projects) {
    $code = $project.FieldValues.ProjectCode
    $name = $project.FieldValues.ProjectName
    $currentTitle = $project.FieldValues.Title
    $expectedTitle = "$code - $name"
    
    if ($currentTitle -ne $expectedTitle) {
      $needsUpdate = $true
      break
    }
  }
  
  if ($needsUpdate) {
    $updated = 0
    foreach ($project in $projects) {
      $code = $project.FieldValues.ProjectCode
      $name = $project.FieldValues.ProjectName
      $newTitle = "$code - $name"
      
      Set-PnPListItem -List $ProjectMaster -Identity $project.Id -Values @{
        "Title" = $newTitle
      } -UpdateType SystemUpdate | Out-Null
      $updated++
    }
    Write-Host "  ✓ Title更新完了: $updated 件" -ForegroundColor Green
  } else {
    Write-Host "  ✓ Title更新済み（スキップ）" -ForegroundColor Gray
  }
  
  # ステップ2: Lookupフィールドを再作成
  Write-Host "`n[2/4] Lookupフィールド再作成中..." -ForegroundColor Yellow
  
  # 既存フィールド削除
  $existingLookup = Get-PnPField -List $SrcList -Identity "ProjectCodeLookup" -ErrorAction SilentlyContinue
  if ($existingLookup) {
    Remove-PnPField -List $SrcList -Identity "ProjectCodeLookup" -Force
    Write-Host "  ✓ 既存フィールド削除" -ForegroundColor Gray
  }
  
  # 新規作成（Title参照）
  $projectList = Get-PnPList -Identity $ProjectMaster
  $fieldXml = @"
<Field 
  Type='LookupMulti' 
  DisplayName='プロジェクト' 
  Required='FALSE' 
  EnforceUniqueValues='FALSE' 
  List='$($projectList.Id)' 
  ShowField='Title' 
  Mult='TRUE'
  UnlimitedLengthInDocumentLibrary='FALSE' 
  RelationshipDeleteBehavior='None' 
  ID='{$(New-Guid)}' 
  StaticName='ProjectCodeLookup' 
  Name='ProjectCodeLookup' />
"@
  
  Add-PnPFieldFromXml -List $SrcList -FieldXml $fieldXml
  Write-Host "  ✓ 新しいLookupフィールド作成完了" -ForegroundColor Green
  
  # ステップ3: Lookup値を設定
  Write-Host "`n[3/4] プロジェクト参照を設定中..." -ForegroundColor Yellow
  $employments = @(Get-PnPListItem -List $SrcList)
  $projects = @(Get-PnPListItem -List $ProjectMaster)
  
  $updated = 0
  for ($i = 0; $i -lt $employments.Count; $i++) {
    $emp = $employments[$i]
    $empId = $emp.FieldValues.EmployeeID
    $name = $emp.FieldValues.FullName
    
    # 職員番号から割当プロジェクト数を決定（1-3件）
    $projectCount = (($empId % 3) + 1)
    
    # 職員番号からベースインデックスを計算
    $baseIndex = [int]($empId % $projects.Count)
    
    # 複数プロジェクトを割り当て
    $projectIds = @()
    $projectTitles = @()
    
    for ($j = 0; $j -lt $projectCount; $j++) {
      $index = ($baseIndex + $j) % $projects.Count
      $projectIds += $projects[$index].Id
      $projectTitles += $projects[$index].FieldValues.Title
    }
    
    Set-PnPListItem -List $SrcList -Identity $emp.Id -Values @{
      "ProjectCodeLookup" = $projectIds
    } -UpdateType SystemUpdate | Out-Null
    
    $projectTitlesStr = $projectTitles -join ", "
    Write-Host "  ✓ $empId - $name" -ForegroundColor Green
    Write-Host "    → $projectTitlesStr" -ForegroundColor Gray
    $updated++
  }
  Write-Host "  ✓ Lookup設定完了: $updated 件" -ForegroundColor Green
  
  # ステップ4: ビューを更新
  Write-Host "`n[4/4] ビュー更新中..." -ForegroundColor Yellow
  
  # 既存ビュー削除
  $existingView = Get-PnPView -List $SrcList -Identity "すべてのアイテム" -ErrorAction SilentlyContinue
  if ($existingView) {
    Remove-PnPView -List $SrcList -Identity "すべてのアイテム" -Force
  }
  
  # 新規ビュー作成
  $viewFields = @(
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
  
  Add-PnPView -List $SrcList -Title "すべてのアイテム" -Fields $viewFields -SetAsDefault
  Write-Host "  ✓ ビュー更新完了" -ForegroundColor Green
  
  Write-Host ""
  Write-Host "========================================" -ForegroundColor Green
  Write-Host "  ✅ セットアップ完了" -ForegroundColor Green
  Write-Host "========================================" -ForegroundColor Green
  Write-Host ""
  Write-Host "結果概要:" -ForegroundColor Yellow
  Write-Host "  - プロジェクト表示: [コード - 名称] 形式" -ForegroundColor Gray
  Write-Host "  - Lookupフィールド: 複数選択対応" -ForegroundColor Gray
  Write-Host "  - 雇用記録: $($employments.Count) 件にプロジェクト割当完了" -ForegroundColor Gray
  Write-Host "  - ビュー: フィールド順序を整理" -ForegroundColor Gray
  
} catch {
  Write-Host ""
  Write-Host "❌ エラー: $_" -ForegroundColor Red
  Write-Host $_.ScriptStackTrace -ForegroundColor DarkGray
  exit 1
}
