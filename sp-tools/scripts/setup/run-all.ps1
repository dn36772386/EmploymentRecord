#!/usr/bin/env pwsh
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  リスト作成スクリプト実行" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

try {
    Write-Host "[1/4] 接続中..." -ForegroundColor Yellow
    . "$PSScriptRoot/connect.ps1"
    
    Write-Host "`n[2/4] EMP_1_Projects を作成中..." -ForegroundColor Yellow
    . "$PSScriptRoot/create-projects.ps1"
    Write-Host "✓ EMP_1_Projects 完了" -ForegroundColor Green
    
    Write-Host "`n[3/4] EMP_1_EmploymentRecords を更新中..." -ForegroundColor Yellow
    . "$PSScriptRoot/update-employment-records.ps1"
    Write-Host "✓ EMP_1_EmploymentRecords 完了" -ForegroundColor Green
    
    Write-Host "`n[4/4] EMP_1_EmploymentApprovals を作成中..." -ForegroundColor Yellow
    . "$PSScriptRoot/create-approvals-list.ps1"
    Write-Host "✓ EMP_1_EmploymentApprovals 完了" -ForegroundColor Green
    
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "  すべて完了！" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
    
} catch {
    Write-Host "`n✗ エラーが発生しました:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
    exit 1
}
