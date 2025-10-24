<#
  get-flow-token.ps1
  - Power Automate Management API用の認証トークンを取得します
  - 使い方: pwsh -File ./scripts/export/get-flow-token.ps1
#>

# config.ps1から設定を読み込み
. "$PSScriptRoot\..\..\config.ps1"

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Power Automate API 認証" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# MSAL.PS モジュールの確認とインストール
if (-not (Get-Module -ListAvailable -Name MSAL.PS)) {
    Write-Host "MSAL.PSモジュールをインストール中..." -ForegroundColor Yellow
    try {
        Install-Module -Name MSAL.PS -Scope CurrentUser -Force -AllowClobber
        Write-Host "✓ MSAL.PSモジュールのインストール完了" -ForegroundColor Green
    } catch {
        Write-Host "✗ MSAL.PSのインストールに失敗: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "手動でインストールしてください: Install-Module -Name MSAL.PS -Scope CurrentUser" -ForegroundColor Yellow
        exit 1
    }
}

Import-Module MSAL.PS

try {
    Write-Host "認証情報:" -ForegroundColor Cyan
    Write-Host "  TenantId: $TenantId" -ForegroundColor Gray
    Write-Host "  ClientId: $ClientId" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "インタラクティブ認証を開始します..." -ForegroundColor Yellow
    Write-Host "ブラウザが開きます。Microsoftアカウントでサインインしてください。" -ForegroundColor Yellow
    Write-Host ""
    
    # インタラクティブ認証でトークン取得
    $authResult = Get-MsalToken `
        -ClientId $ClientId `
        -TenantId $TenantId `
        -Scopes "https://service.flow.microsoft.com/.default" `
        -Interactive `
        -ErrorAction Stop
    
    if ($authResult.AccessToken) {
        Write-Host "✓ 認証成功！" -ForegroundColor Green
        Write-Host ""
        
        # トークン情報を表示
        $tokenPreview = $authResult.AccessToken.Substring(0, [Math]::Min(50, $authResult.AccessToken.Length))
        Write-Host "アクセストークン（プレビュー）:" -ForegroundColor Yellow
        Write-Host "  $tokenPreview..." -ForegroundColor Gray
        Write-Host ""
        
        Write-Host "トークン情報:" -ForegroundColor Yellow
        Write-Host "  ユーザー: $($authResult.Account.Username)" -ForegroundColor Gray
        Write-Host "  有効期限: $($authResult.ExpiresOn.LocalDateTime)" -ForegroundColor Gray
        Write-Host ""
        
        # トークンをファイルに保存
        $outputDir = "$PSScriptRoot\..\..\output"
        if (-not (Test-Path $outputDir)) {
            New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
        }
        
        $tokenFile = "$outputDir\.flow-token.txt"
        $authResult.AccessToken | Out-File -FilePath $tokenFile -Encoding UTF8 -NoNewline
        
        Write-Host "✓ トークンを保存しました: $tokenFile" -ForegroundColor Green
        Write-Host ""
        Write-Host "注意事項:" -ForegroundColor Yellow
        Write-Host "  - このトークンは機密情報です" -ForegroundColor Yellow
        Write-Host "  - 使用後は削除することを推奨します" -ForegroundColor Yellow
        Write-Host "  - 有効期限は約1時間です" -ForegroundColor Yellow
        Write-Host ""
        
        # .gitignoreに追加
        $gitignorePath = "$PSScriptRoot\..\..\output\.gitignore"
        if (-not (Test-Path $gitignorePath)) {
            ".flow-token.txt" | Out-File -FilePath $gitignorePath -Encoding UTF8
            Write-Host "✓ .gitignoreを作成しました" -ForegroundColor Green
        }
        
        Write-Host "==================================" -ForegroundColor Green
        Write-Host "認証完了！" -ForegroundColor Green
        Write-Host "==================================" -ForegroundColor Green
        
        return $authResult.AccessToken
        
    } else {
        Write-Host "✗ 認証に失敗しました（トークンが取得できませんでした）" -ForegroundColor Red
        return $null
    }
    
} catch {
    Write-Host ""
    Write-Host "✗ エラーが発生しました:" -ForegroundColor Red
    Write-Host "  $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    
    if ($_.Exception.Message -match "AADSTS65001") {
        Write-Host "原因: API権限の管理者同意が必要です" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "対処方法:" -ForegroundColor Yellow
        Write-Host "  1. Microsoft Entra管理センターにアクセス" -ForegroundColor White
        Write-Host "     https://entra.microsoft.com" -ForegroundColor Gray
        Write-Host "  2. アプリ → アプリの登録 → PnP PowerShell App" -ForegroundColor White
        Write-Host "  3. APIのアクセス許可 → アクセス許可の追加" -ForegroundColor White
        Write-Host "  4. 所属する組織で使用している API → Flow Service" -ForegroundColor White
        Write-Host "  5. Flows.Read.All を選択" -ForegroundColor White
        Write-Host "  6. 管理者の同意を与えます" -ForegroundColor White
    }
    
    Write-Host ""
    Write-Host "スタックトレース:" -ForegroundColor Gray
    Write-Host $_.ScriptStackTrace -ForegroundColor Gray
    
    return $null
}
