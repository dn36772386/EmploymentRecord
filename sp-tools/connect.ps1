Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/config.ps1"

Import-Module PnP.PowerShell -ErrorAction Stop
Write-Host ("PS {0} / PnP {1}" -f $PSVersionTable.PSVersion, (Get-Module PnP.PowerShell -ListAvailable | Select-Object -First 1 -Expand Version))

# 既存の接続を確認
$existingConnection = $null
try {
  $existingConnection = Get-PnPConnection -ErrorAction SilentlyContinue
  if ($existingConnection -and $existingConnection.Url -eq $SiteUrl) {
    # 接続が有効か確認
    $testWeb = Get-PnPWeb -ErrorAction SilentlyContinue
    if ($testWeb) {
      Write-Host "✓ 既存の接続を再利用: $($testWeb.Title) <$($testWeb.Url)>" -ForegroundColor Green
      return
    }
  }
} catch {
  # 接続が無効または期限切れ
}

# 新規接続
Write-Host "接続先: $SiteUrl" -ForegroundColor Cyan
Write-Host "ClientId: $ClientId" -ForegroundColor Cyan
Write-Host "TenantId: $TenantId" -ForegroundColor Cyan

try {
  Write-Host "Interactive 認証を試行中..." -ForegroundColor Yellow
  Connect-PnPOnline -Url $SiteUrl -ClientId $ClientId -Tenant $TenantId -Interactive
  Write-Host "✓ Interactive 認証成功" -ForegroundColor Green
} catch {
  Write-Warning "Interactive 認証に失敗しました: $($_.Exception.Message)"
  Write-Host "Device Login 認証を試行中..." -ForegroundColor Yellow
  try {
    Connect-PnPOnline -Url $SiteUrl -ClientId $ClientId -Tenant $TenantId -DeviceLogin
    Write-Host "✓ Device Login 認証成功" -ForegroundColor Green
  } catch {
    throw "すべての認証方式が失敗しました。エラー: $($_.Exception.Message)"
  }
}

$cn = Get-PnPConnection
if (-not $cn) { throw "接続オブジェクトが取得できませんでした。" }

$web = Get-PnPWeb
Write-Host ("✓ 接続成功: {0} <{1}>" -f $web.Title, $web.Url) -ForegroundColor Green