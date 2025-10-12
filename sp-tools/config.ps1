<#
  config.ps1
  - SharePoint Online 接続に必要な設定値を定義します。
  - 環境変数があればそれを優先して使用します。
  - reade.txt の設定値を反映済みです。
#>

# SharePoint サイト URL
$SiteUrl  = if ($env:SP_SITE_URL)  { $env:SP_SITE_URL }  else { 'https://tf1980.sharepoint.com/sites/abeam' }

# Azure AD テナント ID（GUID）- カスタムアプリ使用時のみ
$TenantId = if ($env:SP_TENANT_ID) { $env:SP_TENANT_ID } else { '06fc33a9-9a64-4306-9557-34d54b0a0aaf' }

# アプリ（アプリ登録）のクライアント ID（GUID）- カスタムアプリ使用時のみ
$ClientId = if ($env:SP_CLIENT_ID) { $env:SP_CLIENT_ID } else { '46c6f234-4c52-4872-abb9-036254518457' }

# 対象リスト名（元/先）
$SrcList  = if ($env:SP_SRC_LIST)  { $env:SP_SRC_LIST }  else { 'EmploymentRecords' }
$DstList  = if ($env:SP_DST_LIST)  { $env:SP_DST_LIST }  else { 'EmploymentRecords_v2' }

# 参照元マスター
$ProjectMaster = if ($env:SP_PROJECT_MASTER) { $env:SP_PROJECT_MASTER } else { 'ProjectMaster' }

# 列内部名（承認系）
$ApprovalStatus = if ($env:SP_APPROVAL_STATUS) { $env:SP_APPROVAL_STATUS } else { 'ApprovalStatus' }
$Approver       = if ($env:SP_APPROVER)        { $env:SP_APPROVER }        else { 'Approver' }
$ActionColumn   = if ($env:SP_ACTION_COLUMN)   { $env:SP_ACTION_COLUMN }   else { 'Action' }

# 注: ここでは $fields 等の実行時データには触れません。
#     スキーマ整形や書式出力のロジックは export-*.ps1 側で行います。