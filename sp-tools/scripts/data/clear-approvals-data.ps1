Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'

# 既に接続されているかチェック
$conn = Get-PnPConnection -ErrorAction SilentlyContinue
if (-not $conn) {
  . "$PSScriptRoot/connect.ps1"
}
. "$PSScriptRoot/config.ps1"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  承認履歴データクリア" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# 承認履歴リストの確認
$list = Get-PnPList -Identity $Approvals -ErrorAction SilentlyContinue
if (-not $list) {
  Write-Host "✗ エラー: 承認履歴リスト ($Approvals) が見つかりません" -ForegroundColor Red
  exit 1
}

# 全アイテムを取得
Write-Host "承認履歴アイテムを取得中..." -ForegroundColor Gray
$items = Get-PnPListItem -List $Approvals -Fields "ID" -PageSize 1000

if ($items.Count -eq 0) {
  Write-Host "✓ 承認履歴は既に空です" -ForegroundColor Green
  exit 0
}

Write-Host "削除対象: $($items.Count) 件" -ForegroundColor Yellow

# 削除確認
Write-Host "`n⚠️  警告: すべての承認履歴データを削除します" -ForegroundColor Red
$confirm = Read-Host "続行しますか? (yes/no)"

if ($confirm -ne "yes") {
  Write-Host "キャンセルしました" -ForegroundColor Yellow
  exit 0
}

# アイテムを削除（逆順で削除）
Write-Host "`n削除中..." -ForegroundColor Yellow
$count = 0
$success = 0
$failed = 0

# IDの降順でソートして削除（関連レコードの問題を回避）
$sortedItems = $items | Sort-Object -Property Id -Descending

foreach ($item in $sortedItems) {
  $count++
  try {
    Remove-PnPListItem -List $Approvals -Identity $item.Id -Force
    Write-Host "  [$count/$($items.Count)] ✓ ID: $($item.Id) 削除完了" -ForegroundColor Green
    $success++
  }
  catch {
    Write-Host "  [$count/$($items.Count)] ✗ ID: $($item.Id) エラー: $($_.Exception.Message)" -ForegroundColor Red
    $failed++
  }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  削除完了" -ForegroundColor Cyan
Write-Host "  成功: $success 件" -ForegroundColor Green
Write-Host "  失敗: $failed 件" -ForegroundColor $(if($failed -gt 0){'Red'}else{'Green'})
Write-Host "========================================`n" -ForegroundColor Cyan

# 確認
$remainingItems = Get-PnPListItem -List $Approvals -Fields "ID"
if ($remainingItems.Count -eq 0) {
  Write-Host "✅ 承認履歴データのクリアが完了しました" -ForegroundColor Green
} else {
  Write-Host "⚠️  警告: $($remainingItems.Count) 件のアイテムが残っています" -ForegroundColor Yellow
}
