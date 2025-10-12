# SharePoint Online リスト管理ツール

SharePoint Online のリストからスキーマやカスタム書式を吸い出し、新しいリストへ展開するための PowerShell スクリプト一式です。

## 前提条件

- PowerShell 7.x (pwsh)
- PnP.PowerShell モジュール
  ```powershell
  Install-Module PnP.PowerShell -Scope CurrentUser
  ```

## ファイル構成

| ファイル | 説明 |
|---------|------|
| `config.ps1` | 設定値（サイトURL、テナントID、クライアントID、リスト名等）を定義 |
| `connect.ps1` | SharePoint Online への接続処理 |
| `export-schema.ps1` | リストのフィールドスキーマを CSV/JSON にエクスポート |
| `export-format.ps1` | カスタム書式（CustomFormatter）を CSV/JSON にエクスポート |
| `scaffold-list.ps1` | エクスポートしたスキーマから新しいリストを作成 |
| `add-lookup-project.ps1` | Lookup フィールド（ProjectMaster → ProjectCode）を追加 |
| `apply-actions.ps1` | 承認ボタンのカラムフォーマッタを適用 |

## 設定

### 方法1: config.ps1 を直接編集

`config.ps1` を開いて以下の値を設定してください：

```powershell
$SiteUrl  = 'https://your-tenant.sharepoint.com/sites/your-site'
$TenantId = 'your-tenant-guid'
$ClientId = 'your-app-client-guid'
$SrcList  = 'EmploymentRecords'
$DstList  = 'EmploymentRecords_v2'
```

### 方法2: 環境変数で設定

```bash
# zsh/bash
export SP_SITE_URL="https://your-tenant.sharepoint.com/sites/your-site"
export SP_TENANT_ID="your-tenant-guid"
export SP_CLIENT_ID="your-app-client-guid"
export SP_SRC_LIST="EmploymentRecords"
export SP_DST_LIST="EmploymentRecords_v2"
```

```powershell
# PowerShell
$env:SP_SITE_URL = "https://your-tenant.sharepoint.com/sites/your-site"
$env:SP_TENANT_ID = "your-tenant-guid"
$env:SP_CLIENT_ID = "your-app-client-guid"
```

## 使い方

### 1. 接続確認

```bash
cd /path/to/sp-tools
pwsh -NoLogo -NoProfile -File ./connect.ps1
```

初回実行時はブラウザが開き、Azure AD 認証が求められます。

### 2. スキーマ・書式のエクスポート

```bash
# スキーマをエクスポート（EmploymentRecords_schema.csv/json）
pwsh -File ./export-schema.ps1

# カスタム書式をエクスポート（EmploymentRecords_format.csv/json）
pwsh -File ./export-format.ps1
```

### 3. 新しいリストの作成（オプション）

```bash
# スキーマから新リストを作成
pwsh -File ./scaffold-list.ps1

# Lookup フィールドを追加
pwsh -File ./add-lookup-project.ps1
```

### 4. 承認ボタンの適用

```bash
# Action 列に承認ボタンのフォーマッタを適用
pwsh -File ./apply-actions.ps1
```

## 認証について

- **Interactive 認証**: ブラウザが開き、対話的にサインインします（既定）
- **Device Login**: コードをコピーして https://microsoft.com/devicelogin で認証します

Interactive 認証が失敗した場合は自動的に Device Login にフォールバックします。

## 現在の設定値（既定）

- **SiteUrl**: `https://tf1980.sharepoint.com/sites/abeam`
- **TenantId**: `06fc33a9-9a64-4306-9557-34d54b0a0aaf`
- **ClientId**: `46c6f234-4c52-4872-abb9-036254518457`
- **SrcList**: `EmploymentRecords`（元リスト）
- **DstList**: `EmploymentRecords_v2`（展開先リスト）
- **ProjectMaster**: `ProjectMaster`（参照元マスター）

## トラブルシューティング

### 認証エラー

```
AADSTS7000218: The request body must contain the following parameter: 'client_assertion' or 'client_secret'
```

→ Azure AD のアプリ登録で以下を確認：
1. 「認証」→「パブリック クライアント フローを許可する」を有効化
2. 「API のアクセス許可」→ SharePoint の delegated 権限を付与
3. テナント管理者の同意を実施

### モジュールが見つからない

```bash
pwsh -Command "Install-Module PnP.PowerShell -Scope CurrentUser -Force"
```

### 列が見つからない

`config.ps1` の列内部名（`$ApprovalStatus`, `$Approver`, `$ActionColumn` 等）が実際のリストと一致しているか確認してください。

## Power Automate との連携

承認ワークフローは Power Automate で以下のトリガー式を使用：

**申請時（承認待ち）**:
```
@equals(triggerOutputs()?['body/ApprovalStatus'],'承認待ち')
```

**結果時（承認/却下）**:
```
@or(equals(triggerOutputs()?['body/ApprovalStatus'],'承認'),equals(triggerOutputs()?['body/ApprovalStatus'],'却下'))
```

## ライセンス

MIT

## 作成者

Employment Record プロジェクトチーム
