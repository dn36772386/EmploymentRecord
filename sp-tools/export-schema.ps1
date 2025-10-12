. "$PSScriptRoot/connect.ps1"
. "$PSScriptRoot/config.ps1"

# 必要プロパティを明示ロード（Choices 等は非 Choice でも含めて良い。参照時は防御）
$fields = Get-PnPField -List $SrcList -Includes Title,InternalName,TypeAsString,Required,Choices,LookupList,LookupField,AllowMultipleValues,DisplayFormat,FromBaseType

$shape = foreach($f in $fields | Where-Object { -not $_.FromBaseType }) {
  # 安全に Choices 等を取り出す
  $hasChoices  = $f.PSObject.Properties.Name -contains 'Choices' -and $f.Choices
  $choicesStr  = if($hasChoices -and ($f.TypeAsString -in @('Choice','MultiChoice'))) { ($f.Choices -as [string[]]) -join '|' } else { '' }

  $isLookup      = $f.TypeAsString -in @('Lookup','LookupMulti')
  $lookupListId  = if($isLookup -and $f.LookupList)  { $f.LookupList }  else { '' }
  $lookupField   = if($isLookup -and $f.LookupField) { $f.LookupField } else { '' }

  $allowMulti = if($f.PSObject.Properties.Name -contains 'AllowMultipleValues' -and $f.AllowMultipleValues) { $true } else { $false }
  $displayFmt = if($f.PSObject.Properties.Name -contains 'DisplayFormat') { $f.DisplayFormat } else { $null }

  [PSCustomObject]@{
    DisplayName   = $f.Title
    InternalName  = $f.InternalName
    Type          = $f.TypeAsString
    Required      = [bool]$f.Required
    AllowMultiple = [bool]$allowMulti
    Choices       = $choicesStr
    LookupListId  = $lookupListId
    LookupField   = $lookupField
    DisplayFormat = $displayFmt
  }
}

# 出力
$csv  = Join-Path $PSScriptRoot "${SrcList}_schema.csv"
$json = Join-Path $PSScriptRoot "${SrcList}_schema.json"
$shape | Export-Csv $csv -NoTypeInformation -Encoding UTF8
$shape | ConvertTo-Json -Depth 6 | Out-File $json -Encoding UTF8
Write-Host "Exported schema -> $csv / $json"
