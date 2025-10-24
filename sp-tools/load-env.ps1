#!/usr/bin/env pwsh
<#
  load-env.ps1
  - .env ファイルから環境変数を読み込みます
  - 他のスクリプトの冒頭で `. "$PSScriptRoot/load-env.ps1"` として使用します
#>

$envFile = Join-Path $PSScriptRoot ".env"

if (Test-Path $envFile) {
    Write-Host "Loading environment variables from .env file..." -ForegroundColor Cyan
    
    Get-Content $envFile | ForEach-Object {
        $line = $_.Trim()
        # コメント行と空行をスキップ
        if ($line -and -not $line.StartsWith('#')) {
            if ($line -match '^([^=]+)=(.*)$') {
                $key = $matches[1].Trim()
                $value = $matches[2].Trim()
                
                # 既存の環境変数がなければ設定
                if (-not [Environment]::GetEnvironmentVariable($key, "Process")) {
                    [Environment]::SetEnvironmentVariable($key, $value, "Process")
                    Write-Host "  Set: $key" -ForegroundColor Green
                } else {
                    Write-Host "  Skip: $key (already set)" -ForegroundColor Yellow
                }
            }
        }
    }
    
    Write-Host "Environment variables loaded successfully." -ForegroundColor Green
} else {
    Write-Warning ".env file not found at: $envFile"
    Write-Warning "Please copy .env.example to .env and configure your settings."
    Write-Warning "See SECURITY.md for details."
}
