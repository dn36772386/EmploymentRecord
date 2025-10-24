Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'

# 既に接続されているかチェック
$conn = Get-PnPConnection -ErrorAction SilentlyContinue
if (-not $conn) {
  . "$PSScriptRoot/connect.ps1"
}
. "$PSScriptRoot/config.ps1"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  雇用記録データクリア&再登録" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# 既存データ削除
Write-Host "[1/2] 既存データ削除中..." -ForegroundColor Yellow
$items = @(Get-PnPListItem -List $SrcList -PageSize 5000)
if ($items.Count -gt 0) {
  foreach ($item in $items) {
    Remove-PnPListItem -List $SrcList -Identity $item.Id -Force
  }
  Write-Host "✓ 削除完了: $($items.Count) 件" -ForegroundColor Green
} else {
  Write-Host "✓ 既存データなし" -ForegroundColor Gray
}

# 新規登録
Write-Host "`n[2/2] 新規データ登録" -ForegroundColor Yellow
Start-Sleep -Seconds 1
. "$PSScriptRoot/insert-sample-employment-records.ps1"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  ✅ 完了！" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Cyan
