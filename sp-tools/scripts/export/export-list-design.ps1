<#
  export-list-design.ps1
  - SharePoint Online のリスト設定を包括的に収集し、設計書 (Markdown/TEXT) を出力します。
  - 出力対象:
    * リスト基本情報 / バージョン設定 / 権限状態 / 検証式
    * フィールド(列)詳細 (型/必須/選択肢/Lookup/既定値/検証/インデックスなど)
    * コンテンツタイプ概要
    * ビュー (列/クエリ/行数/既定/JSON書式: Header/Row/Footer)
    * 列書式(JSON)
  - 依存: PnP.PowerShell
  - 使い方:
      pwsh -File ./export-list-design.ps1
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/connect.ps1"
. "$PSScriptRoot/config.ps1"

function Join-NotNull {
  param([Parameter(ValueFromPipeline)]$Values, [string]$Sep = ', ')
  $vals = @()
  foreach($v in $Values){ if($null -ne $v -and "$v" -ne ''){ $vals += "$v" } }
  if($vals.Count -eq 0){ return '' }
  return ($vals -join $Sep)
}

function Out-Line {
  param([string]$Path,[string]$Text)
  Add-Content -Path $Path -Value $Text -Encoding UTF8
}

function Fence {
  param([string]$lang = '', [string]$content)
  if([string]::IsNullOrWhiteSpace($content)){ return '' }
  $lb = "```$lang"; $rb = '```'
  return ("$lb`n$content`n$rb")
}

Write-Host "対象リスト: $SrcList" -ForegroundColor Cyan
$list = Get-PnPList -Identity $SrcList -ErrorAction Stop

# 事前に主要プロパティを引き出す
Get-PnPProperty -ClientObject $list -Property `
  Title,Id,DefaultViewUrl,Description,Hidden,ItemCount,BaseTemplate,ContentTypesEnabled, `
  EnableAttachments,EnableFolderCreation,EnableVersioning,EnableMinorVersions,ForceCheckout, `
  MajorVersionLimit,MajorWithMinorVersionsLimit,ReadSecurity,WriteSecurity,ValidationFormula,ValidationMessage, `
  HasUniqueRoleAssignments | Out-Null

# 出力先
$ts = (Get-Date).ToString('yyyyMMdd-HHmmss')
$baseName = "$($SrcList)_design-$ts"
$mdPath = Join-Path $PSScriptRoot "$baseName.md"
$txtPath = Join-Path $PSScriptRoot "$baseName.txt"

# ヘッダ
$header = @()
$header += "# リスト設計書 ($($list.Title))"
$header += ''
$header += "生成日時: $(Get-Date -Format 'yyyy/MM/dd HH:mm:ss')"
$header += "サイト: $SiteUrl"
$header += "リスト: $SrcList"
$header += ''
Set-Content -Path $mdPath -Value ($header -join "`n") -Encoding UTF8
Set-Content -Path $txtPath -Value ($header -join "`n") -Encoding UTF8

# 基本情報
Out-Line $mdPath "## 基本情報"
Out-Line $mdPath ("- Title: {0}" -f $list.Title)
Out-Line $mdPath ("- Id: {0}" -f $list.Id)
Out-Line $mdPath ("- URL: {0}" -f $list.DefaultViewUrl)
Out-Line $mdPath ("- 説明: {0}" -f ($list.Description ?? ''))
Out-Line $mdPath ("- テンプレート: {0}" -f $list.BaseTemplate)
Out-Line $mdPath ("- アイテム数: {0}" -f $list.ItemCount)
Out-Line $mdPath ("- Hidden: {0}" -f $list.Hidden)
Out-Line $mdPath ("- ContentTypesEnabled: {0}" -f $list.ContentTypesEnabled)
Out-Line $mdPath ("- 添付ファイル: {0}" -f $list.EnableAttachments)
Out-Line $mdPath ("- フォルダー作成可: {0}" -f $list.EnableFolderCreation)
Out-Line $mdPath ("- バージョン管理: Major={0} Minor={1} ForceCheckout={2}" -f $list.EnableVersioning,$list.EnableMinorVersions,$list.ForceCheckout)
Out-Line $mdPath ("- 版数上限: MajorLimit={0} MajorWithMinorLimit={1}" -f $list.MajorVersionLimit,$list.MajorWithMinorVersionsLimit)
Out-Line $mdPath ("- 読取権限(ReadSecurity): {0} / 書込権限(WriteSecurity): {1}" -f $list.ReadSecurity,$list.WriteSecurity)
Out-Line $mdPath ("- 固有権限(HasUniqueRoleAssignments): {0}" -f $list.HasUniqueRoleAssignments)
Out-Line $mdPath ''

if($list.ValidationFormula){
  Out-Line $mdPath "### リスト検証"
  Out-Line $mdPath ("- 検証式: {0}" -f $list.ValidationFormula)
  Out-Line $mdPath ("- メッセージ: {0}" -f $list.ValidationMessage)
  Out-Line $mdPath ''
}

# 権限概要 (件数のみ)
try {
  Get-PnPProperty -ClientObject $list -Property RoleAssignments | Out-Null
  $raCount = if($list.RoleAssignments){ $list.RoleAssignments.Count } else { 0 }
  Out-Line $mdPath "### 権限サマリ"
  Out-Line $mdPath ("- ロール割当の数: {0}" -f $raCount)
  Out-Line $mdPath ''
} catch { }

# フィールド
Out-Line $mdPath "## フィールド一覧"
$fields = Get-PnPField -List $SrcList
foreach($f in $fields){
  # 可能な限り多くのプロパティを取得 (存在しないものはスキップ)
  Get-PnPProperty -ClientObject $f -Property `
    Title,InternalName,StaticName,Description,TypeAsString,Required,FromBaseType,Hidden,ReadOnlyField, `
    EnforceUniqueValues,Indexed,DefaultValue,Group,SchemaXml, `
    Choices,LookupList,LookupField,AllowMultipleValues,DisplayFormat, `
    MaxLength,MinimumValue,MaximumValue,ShowInDisplayForm,ShowInNewForm,ShowInEditForm, `
    ValidationFormula,ValidationMessage,RichText,RichTextMode,NumberOfLines,AppendOnly `
    -ErrorAction SilentlyContinue | Out-Null

  $choicesStr = ''
  if(($f.PSObject.Properties.Name -contains 'Choices') -and $f.Choices){ $choicesStr = ($f.Choices -as [string[]]) -join ' | ' }
  $lookupInfo = ''
  if(($f.TypeAsString -in @('Lookup','LookupMulti')) -and ($f.LookupList)){
    $lookupInfo = "List=$($f.LookupList), Field=$($f.LookupField), Multi=$($f.AllowMultipleValues)"
  }

  Out-Line $mdPath ("### {0} ({1})" -f $f.Title,$f.InternalName)
  Out-Line $mdPath ("- 型(Type): {0}" -f $f.TypeAsString)
  if($f.Description){ Out-Line $mdPath ("- 説明: {0}" -f $f.Description) }
  Out-Line $mdPath ("- 必須: {0} / 既定値: {1}" -f ([bool]$f.Required), ($f.DefaultValue ?? ''))
  
  # プロパティが存在する場合のみ出力
  $showDisplay = if($f.PSObject.Properties.Name -contains 'ShowInDisplayForm'){ $f.ShowInDisplayForm } else { 'N/A' }
  $showNew = if($f.PSObject.Properties.Name -contains 'ShowInNewForm'){ $f.ShowInNewForm } else { 'N/A' }
  $showEdit = if($f.PSObject.Properties.Name -contains 'ShowInEditForm'){ $f.ShowInEditForm } else { 'N/A' }
  Out-Line $mdPath ("- 表示/新規/編集フォーム: {0}/{1}/{2}" -f $showDisplay,$showNew,$showEdit)
  
  Out-Line $mdPath ("- Hidden: {0} / ReadOnly: {1} / Unique: {2} / Indexed: {3}" -f $f.Hidden,$f.ReadOnlyField,$f.EnforceUniqueValues,$f.Indexed)
  if($choicesStr){ Out-Line $mdPath ("- 選択肢: {0}" -f $choicesStr) }
  if($lookupInfo){ Out-Line $mdPath ("- Lookup: {0}" -f $lookupInfo) }
  if($f.TypeAsString -eq 'Text' -and ($f.PSObject.Properties.Name -contains 'MaxLength') -and $f.MaxLength){ 
    Out-Line $mdPath ("- 最大長: {0}" -f $f.MaxLength) 
  }
  if($f.TypeAsString -eq 'Note'){
    $numLines = if($f.PSObject.Properties.Name -contains 'NumberOfLines'){ $f.NumberOfLines } else { 'N/A' }
    $richText = if($f.PSObject.Properties.Name -contains 'RichText'){ $f.RichText } else { 'N/A' }
    $appendOnly = if($f.PSObject.Properties.Name -contains 'AppendOnly'){ $f.AppendOnly } else { 'N/A' }
    Out-Line $mdPath ("- 複数行: 行数={0} / RichText={1} / AppendOnly={2}" -f $numLines,$richText,$appendOnly)
  }
  if($f.ValidationFormula){
    Out-Line $mdPath ("- 列検証式: {0}" -f $f.ValidationFormula)
    Out-Line $mdPath ("- 列検証メッセージ: {0}" -f $f.ValidationMessage)
  }
  # 列書式 (CustomFormatter)
  if($f.CustomFormatter){
    Out-Line $mdPath "- 列書式(JSON):"
    Out-Line $mdPath (Fence 'json' $f.CustomFormatter)
  }
  Out-Line $mdPath ''
}

# コンテンツタイプ
try {
  $cts = Get-PnPContentType -List $SrcList -ErrorAction Stop
  if($cts){
    Out-Line $mdPath "## コンテンツタイプ"
    foreach($ct in $cts){
      Get-PnPProperty -ClientObject $ct -Property Name,Id,Hidden,ReadOnly,Sealed -ErrorAction SilentlyContinue | Out-Null
      Out-Line $mdPath ("- {0} ({1}) Hidden={2} ReadOnly={3} Sealed={4}" -f $ct.Name,$ct.Id.StringValue,$ct.Hidden,$ct.ReadOnly,$ct.Sealed)
    }
    Out-Line $mdPath ''
  }
} catch { }

# ビュー
Out-Line $mdPath "## ビュー"
$views = Get-PnPView -List $SrcList
foreach($v in $views){
  Get-PnPProperty -ClientObject $v -Property Title,DefaultView,ViewQuery,ViewFields,RowLimit,Paged,ViewTypeKind,CustomFormatter -ErrorAction SilentlyContinue | Out-Null
  Out-Line $mdPath ("### {0} (Default={1})" -f $v.Title,$v.DefaultView)
  
  $rowLimit = if($v.PSObject.Properties.Name -contains 'RowLimit'){ $v.RowLimit } else { 'N/A' }
  $paged = if($v.PSObject.Properties.Name -contains 'Paged'){ $v.Paged } else { 'N/A' }
  $viewType = if($v.PSObject.Properties.Name -contains 'ViewTypeKind'){ $v.ViewTypeKind } else { 'N/A' }
  Out-Line $mdPath ("- RowLimit: {0} / Paged: {1} / Type: {2}" -f $rowLimit,$paged,$viewType)
  
  if($v.ViewFields){ Out-Line $mdPath ("- 表示列: {0}" -f (Join-NotNull $v.ViewFields)) }
  if($v.ViewQuery){ Out-Line $mdPath "- クエリ:"; Out-Line $mdPath (Fence 'xml' $v.ViewQuery) }
  # ビューの書式 (Row JSON)
  if($v.CustomFormatter){ Out-Line $mdPath "- 行書式(JSON):"; Out-Line $mdPath (Fence 'json' $v.CustomFormatter) }
  # ヘッダー/フッターはプロパティ名が環境で異なるため Try で取得
  try {
    $hdr = $v.HeaderJSON
    if($hdr){ Out-Line $mdPath "- ヘッダー(JSON):"; Out-Line $mdPath (Fence 'json' $hdr) }
  } catch {}
  try {
    $ftr = $v.FooterJSON
    if($ftr){ Out-Line $mdPath "- フッター(JSON):"; Out-Line $mdPath (Fence 'json' $ftr) }
  } catch {}
  Out-Line $mdPath ''
}

# 末尾
Out-Line $mdPath "---"
Out-Line $mdPath "(本書は export-list-design.ps1 により自動生成されました)"

# プレーンテキストにも同内容を出力
Copy-Item -Path $mdPath -Destination $txtPath -Force

Write-Host "出力: $mdPath" -ForegroundColor Green
Write-Host "出力: $txtPath" -ForegroundColor Green
