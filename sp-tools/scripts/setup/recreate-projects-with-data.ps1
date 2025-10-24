Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'

# 既に接続されているかチェック
$conn = Get-PnPConnection -ErrorAction SilentlyContinue
if (-not $conn) {
  . "$PSScriptRoot/connect.ps1"
}
. "$PSScriptRoot/config.ps1"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  プロジェクトデータ再登録" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Step 1: 既存データの削除
Write-Host "[1/2] 既存データの削除" -ForegroundColor Yellow
try {
  $list = Get-PnPList -Identity $ProjectMaster -ErrorAction Stop
  $items = Get-PnPListItem -List $ProjectMaster -PageSize 5000
  $itemCount = $items.Count
  
  if ($itemCount -gt 0) {
    Write-Host "  既存アイテム: $itemCount 件" -ForegroundColor Gray
    Write-Host "  削除中..." -ForegroundColor Gray
    
    $deleted = 0
    foreach ($item in $items) {
      try {
        Remove-PnPListItem -List $ProjectMaster -Identity $item.Id -Force
        $deleted++
      }
      catch {
        Write-Host "  ✗ ID $($item.Id) の削除に失敗" -ForegroundColor Red
      }
    }
    Write-Host "  ✓ 削除完了: $deleted 件" -ForegroundColor Green
  }
  else {
    Write-Host "  既存データなし" -ForegroundColor Gray
  }
}
catch {
  Write-Host "  ✗ エラー: $($_.Exception.Message)" -ForegroundColor Red
  Write-Host "  リストが存在しない可能性があります" -ForegroundColor Yellow
  exit 1
}

# Step 2: サンプルデータの登録
Write-Host "`n[2/2] サンプルデータの登録" -ForegroundColor Yellow
Start-Sleep -Seconds 1
. "$PSScriptRoot/insert-sample-projects.ps1"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  ✅ データ再登録完了！" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Cyan
