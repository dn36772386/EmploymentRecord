Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/connect.ps1"
. "$PSScriptRoot/config.ps1"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  EMP_1_EmploymentRecords フィールド確認" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$fields = Get-PnPField -List $SrcList | Where-Object { -not $_.FromBaseType } | Sort-Object Title

Write-Host "カスタムフィールド数: $($fields.Count)" -ForegroundColor Yellow
Write-Host ""

foreach ($f in $fields) {
  # 遅延読み込みを解消
  Get-PnPProperty -ClientObject $f -Property Title,InternalName,TypeAsString,Required,Choices -ErrorAction SilentlyContinue | Out-Null
  
  $required = if ($f.Required) { "[必須]" } else { "" }
  $hasChoices = $f.PSObject.Properties.Name -contains 'Choices' -and $f.Choices
  $choices = if ($hasChoices) { "選択肢: $($f.Choices -join ', ')" } else { "" }
  Write-Host "・$($f.Title) ($($f.InternalName)) - $($f.TypeAsString) $required" -ForegroundColor Green
  if ($choices) {
    Write-Host "  $choices" -ForegroundColor Gray
  }
}

Write-Host "`n========================================`n" -ForegroundColor Cyan
