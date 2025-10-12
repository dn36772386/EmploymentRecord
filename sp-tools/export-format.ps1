Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/connect.ps1"
. "$PSScriptRoot/config.ps1"

$rows = foreach($f in Get-PnPField -List $SrcList | Where-Object {$_.CustomFormatter}){
  [PSCustomObject]@{
    InternalName   = $f.InternalName
    DisplayName    = $f.Title
    CustomFormatter= $f.CustomFormatter
  }
}
$rows | Export-Csv "$PSScriptRoot/${SrcList}_format.csv" -NoTypeInformation -Encoding UTF8
$rows | ConvertTo-Json -Depth 12 | Out-File "$PSScriptRoot/${SrcList}_format.json" -Encoding UTF8
Write-Host "Exported format -> ${SrcList}_format.(csv|json)"