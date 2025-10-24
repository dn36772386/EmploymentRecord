Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'

# 既に接続されているかチェック
$conn = Get-PnPConnection -ErrorAction SilentlyContinue
if (-not $conn) {
  . "$PSScriptRoot/connect.ps1"
}
. "$PSScriptRoot/config.ps1"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  全リストのビュー確認" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# EMP_1_EmploymentRecords
Write-Host "【1】EMP_1_EmploymentRecords" -ForegroundColor Yellow
$view1 = Get-PnPView -List $SrcList -Identity "雇用記録一覧" -Includes ViewFields
Write-Host "  ビュー名: $($view1.Title)" -ForegroundColor Green
Write-Host "  既定ビュー: $($view1.DefaultView)" -ForegroundColor Green
Write-Host "  フィールド数: $($view1.ViewFields.Count)" -ForegroundColor Green
Write-Host "  先頭5フィールド: $($view1.ViewFields[0..4] -join ', ')" -ForegroundColor Gray

# EMP_1_Projects
Write-Host "`n【2】EMP_1_Projects" -ForegroundColor Yellow
$view2 = Get-PnPView -List $ProjectMaster -Identity "プロジェクト一覧" -Includes ViewFields
Write-Host "  ビュー名: $($view2.Title)" -ForegroundColor Green
Write-Host "  既定ビュー: $($view2.DefaultView)" -ForegroundColor Green
Write-Host "  フィールド数: $($view2.ViewFields.Count)" -ForegroundColor Green
Write-Host "  全フィールド:" -ForegroundColor Gray
foreach ($field in $view2.ViewFields) {
  Write-Host "    - $field" -ForegroundColor Gray
}

# EMP_1_EmploymentApprovals
Write-Host "`n【3】EMP_1_EmploymentApprovals" -ForegroundColor Yellow
$view3 = Get-PnPView -List $Approvals -Identity "承認履歴一覧" -Includes ViewFields
Write-Host "  ビュー名: $($view3.Title)" -ForegroundColor Green
Write-Host "  既定ビュー: $($view3.DefaultView)" -ForegroundColor Green
Write-Host "  フィールド数: $($view3.ViewFields.Count)" -ForegroundColor Green
Write-Host "  全フィールド:" -ForegroundColor Gray
foreach ($field in $view3.ViewFields) {
  Write-Host "    - $field" -ForegroundColor Gray
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  ✅ すべてのビューが正常に作成されています" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Cyan
