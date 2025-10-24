Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'

# 既に接続されているかチェック
$conn = Get-PnPConnection -ErrorAction SilentlyContinue
if (-not $conn) {
  . "$PSScriptRoot/connect.ps1"
}
. "$PSScriptRoot/config.ps1"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  EMP_1_EmploymentApprovals ビュー作成" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# ビュー名
$viewName = "承認履歴一覧"

# 既存のビューを削除（存在する場合）
$existingView = Get-PnPView -List $Approvals -Identity $viewName -ErrorAction SilentlyContinue
if ($existingView) {
  Remove-PnPView -List $Approvals -Identity $viewName -Force
  Write-Host "既存のビューを削除しました" -ForegroundColor Yellow
}

# フィールドの並び順
$viewFields = @(
  'ID'                      # リストID（先頭）
  'ParentRecord'            # 親レコード
  'StageNumber'             # ステージ番号
  'StageType'               # ステージ種別
  'ParallelGroupId'         # 並列グループID
  'IsRequired'              # 必須
  'Approver'                # 承認者
  'ApproverEmail'           # 承認者メール
  'Status'                  # 状態
  'DueDate'                 # 期限
  'ActionedAt'              # 処理日時
  'Note'                    # コメント
  'ActionedBy'              # 実行者
  'Order'                   # 順序
  'Modified'                # 更新日時
  'Editor'                  # 更新者
)

Write-Host "ビューを作成中..." -ForegroundColor Yellow

# ビューを作成
Add-PnPView -List $Approvals -Title $viewName -Fields $viewFields -SetAsDefault

Write-Host "✓ ビュー作成完了: $viewName" -ForegroundColor Green
Write-Host "  フィールド数: $($viewFields.Count)" -ForegroundColor Green

Write-Host "`n========================================`n" -ForegroundColor Cyan
