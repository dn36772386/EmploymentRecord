Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/connect.ps1"

Write-Host "`n=== EMP_1_ リスト一覧 ===" -ForegroundColor Cyan
$lists = Get-PnPList | Where-Object { $_.Title -like 'EMP_1_*' }
if ($lists) {
    foreach ($list in $lists) {
        Write-Host "✓ $($list.Title) - $($list.ItemCount) アイテム" -ForegroundColor Green
    }
} else {
    Write-Host "✗ EMP_1_ で始まるリストが見つかりません" -ForegroundColor Red
}

Write-Host "`n=== すべてのリスト ===" -ForegroundColor Cyan
Get-PnPList | Where-Object { -not $_.Hidden } | Select-Object Title, ItemCount | Format-Table -AutoSize
