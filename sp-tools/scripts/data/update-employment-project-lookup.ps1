Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'

# 既に接続されているかチェック
$conn = Get-PnPConnection -ErrorAction SilentlyContinue
if (-not $conn) {
  . "$PSScriptRoot/connect.ps1"
}
. "$PSScriptRoot/config.ps1"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  雇用記録プロジェクト参照更新" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# プロジェクトマスタ取得
Write-Host "プロジェクトマスタを取得中..." -ForegroundColor Gray
$projects = @(Get-PnPListItem -List $ProjectMaster)
Write-Host "✓ プロジェクト取得: $($projects.Count) 件" -ForegroundColor Green

# 雇用記録取得
Write-Host "雇用記録を取得中..." -ForegroundColor Gray
$employments = @(Get-PnPListItem -List $SrcList)
Write-Host "✓ 雇用記録取得: $($employments.Count) 件" -ForegroundColor Green

Write-Host "`nプロジェクト参照を更新中..." -ForegroundColor Yellow
Write-Host "(各職員に1-3件のプロジェクトをランダム割当)" -ForegroundColor Gray

$updated = 0
for ($i = 0; $i -lt $employments.Count; $i++) {
  $emp = $employments[$i]
  $empId = $emp.FieldValues.EmployeeID
  $name = $emp.FieldValues.FullName
  
  # 職員番号から割当プロジェクト数を決定（1-3件）
  $projectCount = (($empId % 3) + 1)
  
  # 職員番号からベースインデックスを計算
  $baseIndex = [int]($empId % $projects.Count)
  
  # 複数プロジェクトを割り当て（重複しないように）
  $projectIds = @()
  $projectCodes = @()
  
  for ($j = 0; $j -lt $projectCount; $j++) {
    $index = ($baseIndex + $j) % $projects.Count
    $projectIds += $projects[$index].Id
    $projectCodes += $projects[$index].FieldValues.ProjectCode
  }
  
  try {
    # 複数選択Lookupフィールドの設定（配列で渡す）
    Set-PnPListItem -List $SrcList -Identity $emp.Id -Values @{
      "ProjectCodeLookup" = $projectIds
    } -UpdateType SystemUpdate | Out-Null
    
    $projectCodesStr = $projectCodes -join ", "
    Write-Host "  ✓ $empId - $name → $projectCodesStr" -ForegroundColor Green
    $updated++
  }
  catch {
    Write-Host "  ✗ $empId - $name : $($_.Exception.Message)" -ForegroundColor Red
  }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  ✅ 更新完了: $updated 件" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Cyan
