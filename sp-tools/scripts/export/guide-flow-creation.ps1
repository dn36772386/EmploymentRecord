# Power Automate フロー作成スクリプト（代替方法）
# 既存フローをGUIでコピーし、定義をエクスポートする手順を提供

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Power Automate フロー作成ガイド" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "⚠️  注意: Power Automate Management API経由でのフロー作成には制限があります" -ForegroundColor Yellow
Write-Host ""
Write-Host "代わりに、以下の手順で実装することを推奨します:" -ForegroundColor Cyan
Write-Host ""

Write-Host "【推奨手順】" -ForegroundColor Green
Write-Host ""
Write-Host "1. Power Automate ポータルを開く" -ForegroundColor White
Write-Host "   https://make.powerautomate.com" -ForegroundColor Cyan
Write-Host ""

Write-Host "2. 既存フロー 'EMP_1_雇用調書承認フロー' を複製" -ForegroundColor White
Write-Host "   - マイフローで検索" -ForegroundColor Gray
Write-Host "   - フローの右側「︙」→「名前を付けて保存」" -ForegroundColor Gray
Write-Host "   - 新しい名前: 'EMP_2_雇用調書承認フロー'" -ForegroundColor Gray
Write-Host ""

Write-Host "3. 設計書に従って編集" -ForegroundColor White
Write-Host "   ドキュメント: docs/EMP_2_FLOW_SETUP_GUIDE.md" -ForegroundColor Cyan
Write-Host ""

Write-Host "【フロー定義ファイルが作成されています】" -ForegroundColor Green
Write-Host ""

# 最新の定義ファイルを探す
$OutputDir = Join-Path $PSScriptRoot "..\..\output\designs"
$LatestDefinition = Get-ChildItem -Path $OutputDir -Filter "Flow_EMP_2_*_definition_*.json" | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if ($LatestDefinition) {
    Write-Host "✓ フロー定義ファイル:" -ForegroundColor Green
    Write-Host "  $($LatestDefinition.FullName)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  このファイルには以下が含まれています:" -ForegroundColor White
    Write-Host "  - トリガー: SharePoint選択したアイテム" -ForegroundColor Gray
    Write-Host "  - 項目の取得" -ForegroundColor Gray
    Write-Host "  - 第1承認者への承認依頼（並行）" -ForegroundColor Gray
    Write-Host "  - 第2承認者への承認依頼（並行）" -ForegroundColor Gray
    Write-Host "  - 第1承認者結果チェック + 権限変更" -ForegroundColor Gray
    Write-Host "  - 第2承認者結果チェック + 権限変更" -ForegroundColor Gray
    Write-Host "  - 最終承認判定" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "【代替方法: PowerShell で定義を読み込んで手動インポート】" -ForegroundColor Yellow
Write-Host ""
Write-Host "Power Automate UIで以下の操作を実行してください:" -ForegroundColor White
Write-Host ""
Write-Host "1. 新しいフローを作成（空白から）" -ForegroundColor White
Write-Host "2. トリガーを追加: SharePoint - 選択したアイテムに対して" -ForegroundColor White
Write-Host "3. 上記の定義ファイルを参照しながら、アクションを追加" -ForegroundColor White
Write-Host ""

Write-Host "【または】完全な手順書を参照" -ForegroundColor Yellow
Write-Host ""
Write-Host "詳細な手順: docs/EMP_2_FLOW_SETUP_GUIDE.md" -ForegroundColor Cyan
Write-Host ""

Write-Host "このガイドには以下が含まれています:" -ForegroundColor White
Write-Host "  ✓ ステップバイステップの作成手順" -ForegroundColor Green
Write-Host "  ✓ 各アクションの詳細設定" -ForegroundColor Green
Write-Host "  ✓ 並行実行の設定方法" -ForegroundColor Green
Write-Host "  ✓ 権限変更のHTTPリクエスト設定" -ForegroundColor Green
Write-Host "  ✓ トラブルシューティング" -ForegroundColor Green
Write-Host "  ✓ 完了チェックリスト" -ForegroundColor Green
Write-Host ""

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "ガイド表示完了" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# ガイドドキュメントを開く
$GuideDoc = Join-Path $PSScriptRoot "..\..\docs\EMP_2_FLOW_SETUP_GUIDE.md"
if (Test-Path $GuideDoc) {
    Write-Host "ガイドドキュメントを開きますか？ (Y/n): " -NoNewline -ForegroundColor Yellow
    $Response = Read-Host
    if ($Response -eq "" -or $Response -eq "Y" -or $Response -eq "y") {
        if ($IsMacOS) {
            & open $GuideDoc
        } elseif ($IsWindows) {
            & start $GuideDoc
        } else {
            & xdg-open $GuideDoc
        }
        Write-Host "✓ ドキュメントを開きました" -ForegroundColor Green
    }
}
