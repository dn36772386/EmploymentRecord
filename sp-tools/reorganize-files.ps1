<#
  reorganize-files.ps1
  - sp-tools ディレクトリのファイルを論理的なフォルダ構造に整理します
  - 使い方: pwsh -File ./reorganize-files.ps1
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$rootDir = $PSScriptRoot

Write-Host "ファイル整理を開始します..." -ForegroundColor Cyan
Write-Host "ルートディレクトリ: $rootDir" -ForegroundColor Cyan
Write-Host ""

# ファイル移動のマッピング
$moveMap = @{
    # コア設定（ルートに残す）
    'config.ps1' = $null
    'connect.ps1' = $null
    'README.md' = $null
    
    # セットアップスクリプト
    'run-all.ps1' = 'scripts/setup'
    'create-projects.ps1' = 'scripts/setup'
    'create-approvals-list.ps1' = 'scripts/setup'
    'scaffold-list.ps1' = 'scripts/setup'
    'add-approval-fields-to-employment.ps1' = 'scripts/setup'
    'add-lookup-project.ps1' = 'scripts/setup'
    'add-project-display-field.ps1' = 'scripts/setup'
    'create-project-lookup-field.ps1' = 'scripts/setup'
    'setup-project-lookup-complete.ps1' = 'scripts/setup'
    'recreate-projects-with-data.ps1' = 'scripts/setup'
    
    # データ管理
    'insert-sample-projects.ps1' = 'scripts/data'
    'insert-sample-employment-records.ps1' = 'scripts/data'
    'insert-sample-employment-records-v2.ps1' = 'scripts/data'
    'insert-sample-approvals.ps1' = 'scripts/data'
    'refresh-project-data.ps1' = 'scripts/data'
    'refresh-employment-data.ps1' = 'scripts/data'
    'clear-project-data.ps1' = 'scripts/data'
    'clear-approvals-data.ps1' = 'scripts/data'
    'delete-project-list.ps1' = 'scripts/data'
    'update-approval-status.ps1' = 'scripts/data'
    'update-employment-records.ps1' = 'scripts/data'
    'update-employment-project-lookup.ps1' = 'scripts/data'
    'update-project-lookup-final.ps1' = 'scripts/data'
    'update-project-lookup-multi.ps1' = 'scripts/data'
    
    # ビュー作成
    'create-view.ps1' = 'scripts/views'
    'create-view-projects.ps1' = 'scripts/views'
    'create-view-approvals.ps1' = 'scripts/views'
    'rebuild-employment-views.ps1' = 'scripts/views'
    'recreate-employment-view.ps1' = 'scripts/views'
    
    # エクスポート
    'export-schema.ps1' = 'scripts/export'
    'export-format.ps1' = 'scripts/export'
    'export-list-design.ps1' = 'scripts/export'
    'export-all-lists.ps1' = 'scripts/export'
    
    # 検証
    'check-lists.ps1' = 'scripts/verify'
    'verify-fields.ps1' = 'scripts/verify'
    'verify-view.ps1' = 'scripts/verify'
    'verify-all-views.ps1' = 'scripts/verify'
    
    # その他ユーティリティ
    'apply-actions.ps1' = 'scripts'
    'create-approval-records-for-employment.ps1' = 'scripts'
    
    # JSON書式ファイル
    'employment-approval-buttons.json' = 'json-formats'
    'employment-approval-column-format.json' = 'json-formats'
    'approvals-json-settings.json' = 'json-formats'
    'approvals-title-format.json' = 'json-formats'
    'submit-button-format.json' = 'json-formats'
    
    # ドキュメント
    'EMPLOYMENT_APPROVAL_SETUP.md' = 'docs'
    'POWER_AUTOMATE_SETUP.md' = 'docs'
}

# 出力ファイルのパターン（output/に移動）
$outputPatterns = @(
    'EMP_1_*_design-*.md',
    'EMP_1_*_design-*.txt',
    'EmploymentRecords_schema.*',
    'EmploymentRecords_format.*'
)

# ファイル移動実行
$movedCount = 0
$skippedCount = 0

foreach ($file in $moveMap.Keys) {
    $sourcePath = Join-Path $rootDir $file
    $destFolder = $moveMap[$file]
    
    if (-not (Test-Path $sourcePath)) {
        Write-Host "  ⚠ スキップ (存在しない): $file" -ForegroundColor Yellow
        $skippedCount++
        continue
    }
    
    if ($null -eq $destFolder) {
        Write-Host "  ○ ルートに維持: $file" -ForegroundColor Gray
        continue
    }
    
    $destPath = Join-Path $rootDir $destFolder
    if (-not (Test-Path $destPath)) {
        New-Item -ItemType Directory -Path $destPath -Force | Out-Null
    }
    
    $destFile = Join-Path $destPath $file
    if (Test-Path $destFile) {
        Write-Host "  ⚠ スキップ (既存): $file → $destFolder" -ForegroundColor Yellow
        $skippedCount++
        continue
    }
    
    Move-Item -Path $sourcePath -Destination $destFile -Force
    Write-Host "  ✓ 移動: $file → $destFolder" -ForegroundColor Green
    $movedCount++
}

# 出力ファイルの移動
Write-Host "`n出力ファイルを整理中..." -ForegroundColor Cyan
foreach ($pattern in $outputPatterns) {
    $files = Get-ChildItem -Path $rootDir -Filter $pattern -ErrorAction SilentlyContinue
    foreach ($file in $files) {
        $destFolder = if ($file.Name -match '_design-') { 
            'output/designs' 
        } else { 
            'output/schemas' 
        }
        $destPath = Join-Path $rootDir $destFolder
        $destFile = Join-Path $destPath $file.Name
        
        if (Test-Path $destFile) {
            Write-Host "  ⚠ スキップ (既存): $($file.Name)" -ForegroundColor Yellow
            $skippedCount++
            continue
        }
        
        Move-Item -Path $file.FullName -Destination $destFile -Force
        Write-Host "  ✓ 移動: $($file.Name) → $destFolder" -ForegroundColor Green
        $movedCount++
    }
}

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "整理完了" -ForegroundColor Green
Write-Host "  移動: $movedCount ファイル" -ForegroundColor Green
Write-Host "  スキップ: $skippedCount ファイル" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "新しいフォルダ構造:" -ForegroundColor Cyan
Write-Host "  📁 scripts/" -ForegroundColor White
Write-Host "    ├─ setup/      ... リスト作成・初期設定" -ForegroundColor Gray
Write-Host "    ├─ data/       ... データ投入・更新・削除" -ForegroundColor Gray
Write-Host "    ├─ views/      ... ビュー作成・更新" -ForegroundColor Gray
Write-Host "    ├─ export/     ... スキーマ・書式エクスポート" -ForegroundColor Gray
Write-Host "    └─ verify/     ... 検証・確認" -ForegroundColor Gray
Write-Host "  📁 json-formats/ ... JSON列書式ファイル" -ForegroundColor White
Write-Host "  📁 docs/         ... ドキュメント" -ForegroundColor White
Write-Host "  📁 output/       ... 出力ファイル" -ForegroundColor White
Write-Host "    ├─ designs/    ... リスト設計書" -ForegroundColor Gray
Write-Host "    └─ schemas/    ... スキーマ・書式JSON/CSV" -ForegroundColor Gray
