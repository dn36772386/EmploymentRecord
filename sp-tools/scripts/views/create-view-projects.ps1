Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'

# 既に接続されているかチェック
$conn = Get-PnPConnection -ErrorAction SilentlyContinue
if (-not $conn) {
  . "$PSScriptRoot/connect.ps1"
}
. "$PSScriptRoot/config.ps1"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  EMP_1_Projects ビュー作成" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# ビュー名
$viewName = "プロジェクト一覧"

# 既存のビューを削除（存在する場合）
$existingView = Get-PnPView -List $ProjectMaster -Identity $viewName -ErrorAction SilentlyContinue
if ($existingView) {
  Remove-PnPView -List $ProjectMaster -Identity $viewName -Force
  Write-Host "既存のビューを削除しました" -ForegroundColor Yellow
}

# フィールドの並び順
$viewFields = @(
  'ID'                      # リストID（先頭）
  'ProjectCode'             # プロジェクトコード
  'ProjectName'             # プロジェクト名
  'PurposeBudgetCode'       # 目的(予算)コード
  'PurposeBudgetName'       # 目的(予算)名称
  'PurposeExecCode'         # 目的(執行)コード
  'PurposeExecName'         # 目的(執行)名称
  'DeptCode'                # 部門コード
  'DeptName'                # 部門名称
  'FundingCode'             # 財源コード
  'FundingName'             # 財源名称
  'ValidUntil'              # 有効期限
  'BudgetProcFlag'          # 予算財会処理
  'Notes'                   # 備考
  'Modified'                # 更新日時
  'Editor'                  # 更新者
)

Write-Host "ビューを作成中..." -ForegroundColor Yellow

# ビューを作成
Add-PnPView -List $ProjectMaster -Title $viewName -Fields $viewFields -SetAsDefault

Write-Host "✓ ビュー作成完了: $viewName" -ForegroundColor Green
Write-Host "  フィールド数: $($viewFields.Count)" -ForegroundColor Green

Write-Host "`n========================================`n" -ForegroundColor Cyan
