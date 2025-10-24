<#
  config.ps1
  - SharePoint Online 接続に必要な設定値を定義します。
  - 環境変数があればそれを優先して使用します。
  - reade.txt の設定値を反映済みです。
#>

# SharePoint サイト URL
$SiteUrl  = if ($env:SP_SITE_URL)  { $env:SP_SITE_URL }  else { throw "SP_SITE_URL environment variable is required" }

# Azure AD テナント ID（GUID）- カスタムアプリ使用時のみ
$TenantId = if ($env:SP_TENANT_ID) { $env:SP_TENANT_ID } else { throw "SP_TENANT_ID environment variable is required" }

# アプリ（アプリ登録）のクライアント ID（GUID）- カスタムアプリ使用時のみ
$ClientId = if ($env:SP_CLIENT_ID) { $env:SP_CLIENT_ID } else { throw "SP_CLIENT_ID environment variable is required" }

# 対象リスト名（元/先）
$SrcList  = if ($env:SP_SRC_LIST)  { $env:SP_SRC_LIST }  else { 'EMP_1_EmploymentRecords' }
$DstList  = if ($env:SP_DST_LIST)  { $env:SP_DST_LIST }  else { 'EmploymentRecords_v2' }

# 参照元マスター
$ProjectMaster = if ($env:SP_PROJECT_MASTER) { $env:SP_PROJECT_MASTER } else { 'EMP_1_Projects' }

# 承認リスト
$Approvals = if ($env:SP_APPROVALS) { $env:SP_APPROVALS } else { 'EMP_1_EmploymentApprovals' }

# 列内部名（承認系）
$ApprovalStatus = if ($env:SP_APPROVAL_STATUS) { $env:SP_APPROVAL_STATUS } else { 'ApprovalStatus' }
$Approver       = if ($env:SP_APPROVER)        { $env:SP_APPROVER }        else { 'Approver' }
$ActionColumn   = if ($env:SP_ACTION_COLUMN)   { $env:SP_ACTION_COLUMN }   else { 'Action' }

# 注: ここでは $fields 等の実行時データには触れません。
#     スキーマ整形や書式出力のロジックは export-*.ps1 側で行います。
