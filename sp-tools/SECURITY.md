# セキュリティ設定ガイド

## 重要: 環境変数の設定が必須です

このプロジェクトでは、機密情報を環境変数で管理しています。

### 初回セットアップ

1. `.env.example` をコピーして `.env` ファイルを作成：
   ```bash
   cp .env.example .env
   ```

2. `.env` ファイルを編集して、実際の値を設定：
   ```bash
   # SharePoint サイト URL
   SP_SITE_URL=https://tf1980.sharepoint.com/sites/abeam
   
   # Azure AD テナント ID
   SP_TENANT_ID=あなたのテナントID
   
   # アプリのクライアント ID
   SP_CLIENT_ID=あなたのクライアントID
   ```

3. PowerShellスクリプトを実行する前に、環境変数を読み込む：
   ```powershell
   # 方法1: .env ファイルから読み込み（推奨）
   Get-Content .env | ForEach-Object {
       if ($_ -match '^([^#][^=]+)=(.+)$') {
           [Environment]::SetEnvironmentVariable($matches[1], $matches[2], "Process")
       }
   }
   
   # 方法2: 個別に設定
   $env:SP_SITE_URL = "https://tf1980.sharepoint.com/sites/abeam"
   $env:SP_TENANT_ID = "あなたのテナントID"
   $env:SP_CLIENT_ID = "あなたのクライアントID"
   ```

### 注意事項

- `.env` ファイルは `.gitignore` で除外されており、Gitにコミットされません
- 絶対に `.env` ファイルや機密情報を含むファイルを公開リポジトリにプッシュしないでください
- チーム内で共有する場合は、安全な方法（1Password、Azure Key Vaultなど）を使用してください

### 既にGitHubにプッシュしてしまった場合

**重要**: 既に機密情報をGitHubにプッシュしてしまった場合：

1. **すぐにAzure ADでアプリの認証情報をローテーション（再生成）してください**
2. GitHubのリポジトリ履歴から機密情報を削除する必要があります
3. 詳細は [GitHub のドキュメント](https://docs.github.com/ja/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository) を参照してください
