Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'

# 既に接続されているかチェック
$conn = Get-PnPConnection -ErrorAction SilentlyContinue
if (-not $conn) {
  . "$PSScriptRoot/connect.ps1"
}
. "$PSScriptRoot/config.ps1"

if(-not (Get-PnPList -Identity $Approvals -ErrorAction SilentlyContinue)){
  New-PnPList -Title $Approvals -Template GenericList -Url ("Lists/{0}" -f $Approvals) -OnQuickLaunch | Out-Null
}

# 親Lookup
$parent = Get-PnPList -Identity $SrcList
$parentId = $parent.Id.ToString('B')
if(-not (Get-PnPField -List $Approvals -Identity 'ParentRecord' -ErrorAction SilentlyContinue)){
  Add-PnPFieldFromXml -List $Approvals -FieldXml @"
<Field Type='Lookup' DisplayName='親レコード'
  StaticName='ParentRecord' Name='ParentRecord'
  List='$parentId' ShowField='Title' Required='FALSE' />
"@ | Out-Null
}

function A($d,$n,$t){ if(-not (Get-PnPField -List $Approvals -Identity $n -ErrorAction SilentlyContinue)){ Add-PnPField -List $Approvals -DisplayName $d -InternalName $n -Type $t | Out-Null } }

A 'ステージ番号'   'StageNumber'     'Number'
if(-not (Get-PnPField -List $Approvals -Identity 'StageType' -ErrorAction SilentlyContinue)){
  Add-PnPField -List $Approvals -DisplayName 'ステージ種別' -InternalName 'StageType' -Type Choice -Choices @('部門','管理部門','その他') | Out-Null
}
A '並列グループID' 'ParallelGroupId' 'Text'
A '必須'           'IsRequired'      'Boolean'
A '承認者'         'Approver'        'User'
A '承認者メール'   'ApproverEmail'   'Text'
if(-not (Get-PnPField -List $Approvals -Identity 'Status' -ErrorAction SilentlyContinue)){
  Add-PnPField -List $Approvals -DisplayName '状態' -InternalName 'Status' -Type Choice -Choices @('下書き','申請中','承認','却下','差戻し','期限切れ') | Out-Null
}
A '期限'           'DueDate'         'DateTime'
A '処理日時'       'ActionedAt'      'DateTime'
A 'コメント'       'Note'            'Note'
A '実行者'         'ActionedBy'      'User'
A '順序'           'Order'           'Number'

Write-Host "OK: $Approvals"