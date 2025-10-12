$shape = $fields | ForEach-Object {
  $type = $_.TypeAsString
  $hasChoicesProp = $_.PSObject.Properties.Name -contains 'Choices'
  $choices = if ($hasChoicesProp -and ($type -in @('Choice','MultiChoice'))) {
    @($_.Choices) -join '|'
  } else {
    ''
  }

  [PSCustomObject]@{
    DisplayName   = $_.Title
    InternalName  = $_.InternalName
    Type          = $type
    Choices       = $choices
    Required      = [bool]$_.Required
  }
}