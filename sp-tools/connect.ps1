Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/config.ps1"

Import-Module PnP.PowerShell -ErrorAction Stop
Write-Host ("PS {0} / PnP {1}" -f $PSVersionTable.PSVersion, (Get-Module PnP.PowerShell -ListAvailable | Select-Object -First 1 -Expand Version))

try {
  Connect-PnPOnline -Url $SiteUrl -ClientId $ClientId -Tenant $TenantId -Interactive -ReturnConnection | Out-Null
} catch {
  Write-Warning "Interactive failed. Trying Device Login…"
  Connect-PnPOnline -Url $SiteUrl -ClientId $ClientId -Tenant $TenantId -DeviceLogin -ReturnConnection | Out-Null
}

$cn = Get-PnPConnection
if (-not $cn) { throw "Sign-in failed. Check app authentication settings." }

$web = Get-PnPWeb
Write-Host ("Connected: {0} <{1}>" -f $web.Title, $web.Url)