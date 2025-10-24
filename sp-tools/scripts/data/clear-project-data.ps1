Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'

# 既に接続されているかチェック
$conn = Get-PnPConnection -ErrorAction SilentlyContinue
if (-not $conn) {
  . "$PSScriptRoot/connect.ps1"
}
. "$PSScriptRoot/config.ps1"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  プロジェクトデータ削除" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "⚠️  警告: $ProjectMaster のすべてのアイテムを削除します" -ForegroundColor Yellow
Write-Host "   リスト構造とビューは保持されます。" -ForegroundColor Yellow
Write-Host ""

# リストの存在確認
try {
  $list = Get-PnPList -Identity $ProjectMaster -ErrorAction Stop
  $items = Get-PnPListItem -List $ProjectMaster -PageSize 5000
  $itemCount = $items.Count
  
  if ($itemCount -eq 0) {
    Write-Host "✓ リストは空です（削除するデータがありません）" -ForegroundColor Green
    Write-Host "`n========================================`n" -ForegroundColor Cyan
    return
  }
  
  Write-Host "削除対象:" -ForegroundColor Red
  Write-Host "  リスト名: $ProjectMaster" -ForegroundColor Gray
  Write-Host "  アイテム数: $itemCount 件" -ForegroundColor Gray
  Write-Host ""
  
  # 確認プロンプト
  $confirm = Read-Host "本当に削除しますか? (yes/no)"
  
  if ($confirm -eq "yes") {
    Write-Host "`n削除中..." -ForegroundColor Yellow
    
    $deleted = 0
    foreach ($item in $items) {
      try {
        Remove-PnPListItem -List $ProjectMaster -Identity $item.Id -Force
        $deleted++
        if ($deleted % 5 -eq 0) {
          Write-Host "  進行中... ($deleted / $itemCount)" -ForegroundColor Gray
        }
      }
      catch {
        Write-Host "  ✗ ID $($item.Id) の削除に失敗: $($_.Exception.Message)" -ForegroundColor Red
      }
    }
    
    Write-Host "`n✓ データを削除しました: $deleted / $itemCount 件" -ForegroundColor Green
    Write-Host ""
    Write-Host "次のコマンドで新しいデータを登録できます:" -ForegroundColor Cyan
    Write-Host "  pwsh -File ./insert-sample-projects.ps1" -ForegroundColor Gray
  }
  else {
    Write-Host "`n削除をキャンセルしました" -ForegroundColor Yellow
  }
}
catch {
  Write-Host "✗ エラー: リストが見つかりません ($ProjectMaster)" -ForegroundColor Red
  Write-Host "  $($_.Exception.Message)" -ForegroundColor Gray
}

Write-Host "`n========================================`n" -ForegroundColor Cyan
