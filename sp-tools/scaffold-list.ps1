Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/connect.ps1"
. "$PSScriptRoot/config.ps1"

if(-not (Get-PnPList -Identity $DstList -ErrorAction SilentlyContinue)){
  New-PnPList -Title $DstList -Template GenericList -Url ("Lists/{0}" -f $DstList) -OnQuickLaunch | Out-Null
}

$schema = Get-Content "$PSScriptRoot/${SrcList}_schema.json" | ConvertFrom-Json
foreach($c in $schema){
  if(Get-PnPField -List $DstList -Identity $c.InternalName -ErrorAction SilentlyContinue){ continue }
  switch ($c.Type) {
    "Text"     { Add-PnPField -List $DstList -DisplayName $c.DisplayName -InternalName $c.InternalName -Type Text }
    "Note"     { Add-PnPField -List $DstList -DisplayName $c.DisplayName -InternalName $c.InternalName -Type Note }
    "Number"   { Add-PnPField -List $DstList -DisplayName $c.DisplayName -InternalName $c.InternalName -Type Number }
    "Currency" { Add-PnPField -List $DstList -DisplayName $c.DisplayName -InternalName $c.InternalName -Type Currency }
    "DateTime" { Add-PnPField -List $DstList -DisplayName $c.DisplayName -InternalName $c.InternalName -Type DateTime }
    "Choice"   {
      $choices = if([string]::IsNullOrEmpty($c.Choices)) { @() } else { $c.Choices -split '\|'}
      Add-PnPField -List $DstList -DisplayName $c.DisplayName -InternalName $c.InternalName -Type Choice -Choices $choices
    }
    "User"     { Add-PnPField -List $DstList -DisplayName $c.DisplayName -InternalName $c.InternalName -Type User }
    default    { Write-Host "Skip type: $($c.Type) [$($c.DisplayName)]" -ForegroundColor Yellow }
  }
  if($c.Required){ Set-PnPField -List $DstList -Identity $c.InternalName -Values @{ Required = $true } }
}

Write-Host "Scaffolded -> $DstList"
