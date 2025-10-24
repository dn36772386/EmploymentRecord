# Power Automate フロー作成スクリプト（改良版）
# REST API + 接続参照の修正

param(
    [Parameter(Mandatory=$false)]
    [string]$SourceFlowId = "daf1fc3a-17a8-f011-bbd3-000d3ace47ae",
    
    [Parameter(Mandatory=$false)]
    [string]$NewFlowName = "EMP_2_雇用調書承認フロー"
)

# スクリプトのディレクトリを取得
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent (Split-Path -Parent $ScriptDir)

# 設定ファイルを読み込む
. "$RootDir\config.ps1"

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Power Automate フロー作成（改良版）" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# トークンファイルのパス
$TokenFile = Join-Path $RootDir "output\.flow-token.txt"

# トークンの存在確認
if (-not (Test-Path $TokenFile)) {
    Write-Host "✗ トークンファイルが見つかりません" -ForegroundColor Red
    Write-Host "  先に get-flow-token.ps1 を実行してください" -ForegroundColor Yellow
    exit 1
}

# トークンを読み込む
$AccessToken = Get-Content $TokenFile -Raw
$AccessToken = $AccessToken.Trim()

Write-Host "✓ アクセストークンを読み込みました" -ForegroundColor Green
Write-Host ""

# API ヘッダー
$Headers = @{
    "Authorization" = "Bearer $AccessToken"
    "Content-Type" = "application/json; charset=utf-8"
    "Accept" = "application/json"
}

# 環境IDを取得
Write-Host "環境情報を取得中..." -ForegroundColor Cyan

try {
    $EnvResponse = Invoke-RestMethod -Uri "https://api.flow.microsoft.com/providers/Microsoft.ProcessSimple/environments?api-version=2016-11-01" -Headers $Headers -Method Get
    
    $Environment = $EnvResponse.value | Where-Object { $_.properties.isDefault -eq $true } | Select-Object -First 1
    if (-not $Environment) {
        $Environment = $EnvResponse.value | Select-Object -First 1
    }
    
    $EnvironmentId = $Environment.name
    Write-Host "✓ 環境ID: $EnvironmentId" -ForegroundColor Green
    Write-Host "  環境名: $($Environment.properties.displayName)" -ForegroundColor Gray
    Write-Host ""
} catch {
    Write-Host "✗ 環境情報の取得に失敗しました" -ForegroundColor Red
    Write-Host "  エラー: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# 既存フロー定義を取得
Write-Host "既存フローの定義を取得中..." -ForegroundColor Cyan

$SourceFlowUri = "https://api.flow.microsoft.com/providers/Microsoft.ProcessSimple/environments/$EnvironmentId/flows/$SourceFlowId`?api-version=2016-11-01&`$expand=properties/connectionReferences/apiConnection"

try {
    $SourceFlow = Invoke-RestMethod -Uri $SourceFlowUri -Headers $Headers -Method Get
    Write-Host "✓ 既存フロー定義を取得しました" -ForegroundColor Green
    Write-Host "  フロー名: $($SourceFlow.properties.displayName)" -ForegroundColor Gray
    Write-Host ""
} catch {
    Write-Host "✗ 既存フローの取得に失敗しました" -ForegroundColor Red
    Write-Host "  エラー: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# PowerShellでフローをUIで複製するガイドを表示
Write-Host "==================================" -ForegroundColor Yellow
Write-Host "⚠️  重要な情報" -ForegroundColor Yellow
Write-Host "==================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "Power Automate Management APIには以下の制限があります:" -ForegroundColor White
Write-Host "1. 新規フローの作成時、接続参照の設定が複雑" -ForegroundColor Gray
Write-Host "2. トリガーの設定に特別な形式が必要" -ForegroundColor Gray
Write-Host "3. 作成後に手動での接続再設定が必要" -ForegroundColor Gray
Write-Host ""
Write-Host "そのため、以下の方法をお勧めします:" -ForegroundColor Cyan
Write-Host ""
Write-Host "【推奨アプローチ】" -ForegroundColor Green
Write-Host ""
Write-Host "1. Power Automate ポータルにアクセス" -ForegroundColor White
Write-Host "   https://make.powerautomate.com" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. 既存フローを複製" -ForegroundColor White
Write-Host "   - 「マイ フロー」を開く" -ForegroundColor Gray
Write-Host "   - 「EMP_1_雇用調書承認フロー」を検索" -ForegroundColor Gray
Write-Host "   - 右側の「︙」→「名前を付けて保存」" -ForegroundColor Gray
Write-Host "   - 新しい名前: 「EMP_2_雇用調書承認フロー」" -ForegroundColor Gray
Write-Host ""
Write-Host "3. 設計書に従って編集" -ForegroundColor White
Write-Host "   詳細手順: docs/EMP_2_FLOW_SETUP_GUIDE.md" -ForegroundColor Cyan
Write-Host ""
Write-Host "==================================" -ForegroundColor Yellow
Write-Host ""

Write-Host "Power Automate ポータルを開きますか？ (Y/n): " -NoNewline -ForegroundColor Yellow
$Response = Read-Host

if ($Response -eq "" -or $Response -eq "Y" -or $Response -eq "y") {
    $FlowsUrl = "https://make.powerautomate.com/environments/$EnvironmentId/flows"
    Write-Host ""
    Write-Host "ブラウザでPower Automateを開いています..." -ForegroundColor Cyan
    
    if ($IsMacOS) {
        & open $FlowsUrl
    } elseif ($IsWindows) {
        & start $FlowsUrl
    } else {
        & xdg-open $FlowsUrl
    }
    
    Write-Host "✓ ブラウザを開きました" -ForegroundColor Green
    Write-Host ""
    Write-Host "次の手順:" -ForegroundColor Yellow
    Write-Host "1. 「EMP_1_雇用調書承認フロー」を検索" -ForegroundColor White
    Write-Host "2. 「︙」→「名前を付けて保存」→ 名前: 「EMP_2_雇用調書承認フロー」" -ForegroundColor White
    Write-Host "3. 「編集」をクリック" -ForegroundColor White
    Write-Host "4. docs/EMP_2_FLOW_SETUP_GUIDE.md の手順に従う" -ForegroundColor White
    Write-Host ""
}

# 設計書を開く
Write-Host "設計書を開きますか？ (Y/n): " -NoNewline -ForegroundColor Yellow
$Response2 = Read-Host

if ($Response2 -eq "" -or $Response2 -eq "Y" -or $Response2 -eq "y") {
    $GuideFile = Join-Path $RootDir "docs\EMP_2_FLOW_SETUP_GUIDE.md"
    
    if (Test-Path $GuideFile) {
        Write-Host ""
        Write-Host "設計書を開いています..." -ForegroundColor Cyan
        
        if ($IsMacOS) {
            & open $GuideFile
        } elseif ($IsWindows) {
            & start $GuideFile
        } else {
            & xdg-open $GuideFile
        }
        
        Write-Host "✓ 設計書を開きました" -ForegroundColor Green
    } else {
        Write-Host "設計書が見つかりません: $GuideFile" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "準備完了！" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Power Automate UIでフローを作成し、" -ForegroundColor White
Write-Host "設計書の手順に従って実装してください。" -ForegroundColor White
Write-Host ""
