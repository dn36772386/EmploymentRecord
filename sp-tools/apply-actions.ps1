Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/connect.ps1"
. "$PSScriptRoot/config.ps1"

$json = @"
{
  "$schema":"https://developer.microsoft.com/json-schemas/sp/v2/column-formatting.schema.json",
  "elmType":"div","style":{"display":"flex","gap":"6px"},
  "children":[
    {"elmType":"button","txtContent":"申請",
     "style":{"padding":"4px 10px","display":"=if([$${ApprovalStatus}]=='下書き' && @me==[$Author.email],'inline-flex','none')"},
     "customRowAction":{"action":"setValue","actionInput":{"$${ApprovalStatus}":"承認待ち"}}},
    {"elmType":"button","txtContent":"承認",
     "style":{"padding":"4px 10px","display":"=if([$${ApprovalStatus}]=='承認待ち' && @me==[$${Approver}.email],'inline-flex','none')"},
     "customRowAction":{"action":"setValue","actionInput":{"$${ApprovalStatus}":"承認"}}},
    {"elmType":"button","txtContent":"却下",
     "style":{"padding":"4px 10px","display":"=if([$${ApprovalStatus}]=='承認待ち' && @me==[$${Approver}.email],'inline-flex','none')"},
     "customRowAction":{"action":"setValue","actionInput":{"$${ApprovalStatus}":"却下"}}}
  ]
}
"@

$json = $json.Replace("$${ApprovalStatus}", $ApprovalStatus).Replace("$${Approver}", $Approver)

Set-PnPField -List $SrcList -Identity $ActionColumn -Values @{ CustomFormatter = $json }
Write-Host "Applied column formatter to $SrcList.$ActionColumn"
