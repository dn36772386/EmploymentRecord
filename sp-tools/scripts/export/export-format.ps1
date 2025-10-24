Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/../../connect.ps1"
. "$PSScriptRoot/../../config.ps1"

$rows = foreach($f in Get-PnPField -List $SrcList | Where-Object {$_.CustomFormatter}){
  [PSCustomObject]@{
    InternalName   = $f.InternalName
    DisplayName    = $f.Title
    CustomFormatter= $f.CustomFormatter
  }
}
$outputDir = Join-Path $PSScriptRoot "../../output/schemas"
if (-not (Test-Path $outputDir)) { New-Item -ItemType Directory -Path $outputDir -Force | Out-Null }
$rows | Export-Csv "$outputDir/${SrcList}_format.csv" -NoTypeInformation -Encoding UTF8
$rows | ConvertTo-Json -Depth 12 | Out-File "$outputDir/${SrcList}_format.json" -Encoding UTF8
Write-Host "Exported format -> ${SrcList}_format.(csv|json)"