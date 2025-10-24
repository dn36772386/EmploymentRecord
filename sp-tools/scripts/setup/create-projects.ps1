Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'

# 既に接続されているかチェック
$conn = Get-PnPConnection -ErrorAction SilentlyContinue
if (-not $conn) {
  . "$PSScriptRoot/connect.ps1"
}
. "$PSScriptRoot/config.ps1"

if(-not (Get-PnPList -Identity $ProjectMaster -ErrorAction SilentlyContinue)){
  New-PnPList -Title $ProjectMaster -Template GenericList -Url ("Lists/{0}" -f $ProjectMaster) -OnQuickLaunch | Out-Null
}

function Ensure-Text($d,$n,$req=$false){
  if(-not (Get-PnPField -List $ProjectMaster -Identity $n -ErrorAction SilentlyContinue)){
    Add-PnPField -List $ProjectMaster -DisplayName $d -InternalName $n -Type Text | Out-Null
  }
  if($req){ Set-PnPField -List $ProjectMaster -Identity $n -Values @{Required=$true} }
}

Ensure-Text 'プロジェクトコード'   'ProjectCode'   $true
Ensure-Text 'プロジェクト名'       'ProjectName'   $true
Ensure-Text '目的(予算)コード'      'PurposeBudgetCode'
Ensure-Text '目的(予算)名称'        'PurposeBudgetName'
Ensure-Text '目的(執行)コード'      'PurposeExecCode'
Ensure-Text '目的(執行)名称'        'PurposeExecName'
Ensure-Text '部門コード'            'DeptCode'
Ensure-Text '部門名称'              'DeptName'
Ensure-Text '財源コード'            'FundingCode'
Ensure-Text '財源名称'              'FundingName'

if(-not (Get-PnPField -List $ProjectMaster -Identity 'ValidUntil' -ErrorAction SilentlyContinue)){
  Add-PnPField -List $ProjectMaster -DisplayName '有効期限' -InternalName 'ValidUntil' -Type DateTime | Out-Null
}
if(-not (Get-PnPField -List $ProjectMaster -Identity 'BudgetProcFlag' -ErrorAction SilentlyContinue)){
  Add-PnPField -List $ProjectMaster -DisplayName '予算財会処理' -InternalName 'BudgetProcFlag' -Type Choice -Choices @('済','未') | Out-Null
}
if(-not (Get-PnPField -List $ProjectMaster -Identity 'Notes' -ErrorAction SilentlyContinue)){
  Add-PnPField -List $ProjectMaster -DisplayName '備考' -InternalName 'Notes' -Type Note | Out-Null
}

# ProjectCode フィールドにインデックスと固有値制約を設定
Set-PnPField -List $ProjectMaster -Identity 'ProjectCode' -Values @{ Indexed=$true }
Set-PnPField -List $ProjectMaster -Identity 'ProjectCode' -Values @{ EnforceUniqueValues=$true }
Write-Host "OK: $ProjectMaster"
