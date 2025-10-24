Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'

# 既に接続されているかチェック
$conn = Get-PnPConnection -ErrorAction SilentlyContinue
if (-not $conn) {
  . "$PSScriptRoot/connect.ps1"
}
. "$PSScriptRoot/config.ps1"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  EMP_1_EmploymentRecords ビュー確認" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$views = Get-PnPView -List $SrcList

Write-Host "利用可能なビュー:" -ForegroundColor Yellow
foreach ($view in $views) {
  $defaultMark = if ($view.DefaultView) { " [既定]" } else { "" }
  Write-Host "  ・$($view.Title)$defaultMark" -ForegroundColor Green
}

Write-Host "`n詳細: 雇用記録一覧 ビュー" -ForegroundColor Yellow
$detailView = Get-PnPView -List $SrcList -Identity "雇用記録一覧" -Includes ViewFields
Write-Host "  フィールド数: $($detailView.ViewFields.Count)" -ForegroundColor Cyan
Write-Host "  フィールド一覧:" -ForegroundColor Cyan

$counter = 1
foreach ($field in $detailView.ViewFields) {
  Write-Host "    $counter. $field" -ForegroundColor Gray
  $counter++
}

Write-Host "`n========================================`n" -ForegroundColor Cyan
