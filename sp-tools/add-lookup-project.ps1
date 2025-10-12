Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/connect.ps1"
. "$PSScriptRoot/config.ps1"

$pm = Get-PnPList -Identity $ProjectMaster
$listId = $pm.Id.ToString("B")

Add-PnPFieldFromXml -List $DstList -FieldXml @"
<Field Type='Lookup'
  DisplayName='財源_PJ'
  StaticName='ProjectCodeLookup'
  Name='ProjectCodeLookup'
  List='$listId'
  ShowField='ProjectCode'
  Required='FALSE' />
"@

Write-Host "Lookup added: $DstList.ProjectCodeLookup -> $ProjectMaster.ProjectCode"
