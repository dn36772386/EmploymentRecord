# Power Automateフロー定義のエクスポート
# Usage: .\export-flow-definition.ps1 -FlowId <flow-id>

param(
    [Parameter(Mandatory=$false)]
    [string]$FlowId,
    
    [Parameter(Mandatory=$false)]
    [string]$ListName
)

# スクリプトのディレクトリを取得
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent (Split-Path -Parent $ScriptDir)

# 設定ファイルを読み込む
. "$RootDir\config.ps1"

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Power Automate フロー定義エクスポート" -ForegroundColor Cyan
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

# FlowIdが指定されていない場合、リストから検出
if (-not $FlowId) {
    if (-not $ListName) {
        $ListName = $SrcList  # config.ps1から
    }
    
    Write-Host "リスト '$ListName' からフローIDを検出します..." -ForegroundColor Cyan
    
    # SharePointに接続
    . "$RootDir\connect.ps1"
    
    # リストを取得
    $List = Get-PnPList -Identity $ListName -Includes Fields
    
    # カスタムフォーマッターからフローIDを抽出
    $FlowIds = @()
    foreach ($Field in $List.Fields) {
        # CustomFormatterプロパティを明示的に読み込む
        Get-PnPProperty -ClientObject $Field -Property CustomFormatter | Out-Null
        
        if ($Field.CustomFormatter) {
            try {
                $Formatter = $Field.CustomFormatter | ConvertFrom-Json
                if ($Formatter.elmType -eq "button" -and $Formatter.customRowAction.action -eq "executeFlow") {
                    $FlowIds += $Formatter.customRowAction.actionParams.id
                    Write-Host "  ✓ フィールド '$($Field.InternalName)' からフローID検出" -ForegroundColor Green
                }
            } catch {
                # JSONでない、またはフローアクションでない
            }
        }
    }
    
    if ($FlowIds.Count -eq 0) {
        Write-Host "✗ フローIDが見つかりませんでした" -ForegroundColor Red
        exit 1
    }
    
    if ($FlowIds.Count -gt 1) {
        Write-Host ""
        Write-Host "複数のフローが見つかりました:" -ForegroundColor Yellow
        for ($i = 0; $i -lt $FlowIds.Count; $i++) {
            Write-Host "  [$i] $($FlowIds[$i])" -ForegroundColor Yellow
        }
        $Selection = Read-Host "エクスポートするフローの番号を入力してください (0-$($FlowIds.Count - 1))"
        $FlowId = $FlowIds[[int]$Selection]
    } else {
        $FlowId = $FlowIds[0]
    }
    
    Write-Host "✓ フローID: $FlowId" -ForegroundColor Green
    Write-Host ""
}

# 環境IDを取得（Power Automate Management API呼び出し）
Write-Host "環境情報を取得中..." -ForegroundColor Cyan

$Headers = @{
    "Authorization" = "Bearer $AccessToken"
    "Content-Type" = "application/json"
}

# まず環境一覧を取得
try {
    $EnvResponse = Invoke-RestMethod -Uri "https://api.flow.microsoft.com/providers/Microsoft.ProcessSimple/environments?api-version=2016-11-01" -Headers $Headers -Method Get
    
    # デフォルト環境を探す（または最初の環境を使用）
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

# フロー定義を取得
Write-Host "フロー定義を取得中..." -ForegroundColor Cyan

$FlowUri = "https://api.flow.microsoft.com/providers/Microsoft.ProcessSimple/environments/$EnvironmentId/flows/$FlowId`?api-version=2016-11-01"

try {
    $FlowResponse = Invoke-RestMethod -Uri $FlowUri -Headers $Headers -Method Get
    
    Write-Host "✓ フロー定義を取得しました" -ForegroundColor Green
    Write-Host ""
    
    # フロー情報を表示
    Write-Host "フロー情報:" -ForegroundColor Cyan
    Write-Host "  名前: $($FlowResponse.properties.displayName)" -ForegroundColor White
    Write-Host "  状態: $($FlowResponse.properties.state)" -ForegroundColor White
    Write-Host "  作成日: $($FlowResponse.properties.createdTime)" -ForegroundColor White
    Write-Host "  更新日: $($FlowResponse.properties.lastModifiedTime)" -ForegroundColor White
    Write-Host ""
    
    # 出力ファイル名を生成
    $Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $FlowName = $FlowResponse.properties.displayName -replace '[\\/:*?"<>|]', '_'
    
    # JSON出力
    $JsonFile = Join-Path $RootDir "output\designs\Flow_${FlowName}_${Timestamp}.json"
    $FlowResponse | ConvertTo-Json -Depth 100 | Out-File -FilePath $JsonFile -Encoding UTF8
    Write-Host "✓ JSON定義を保存: $JsonFile" -ForegroundColor Green
    
    # Markdown出力
    $MdFile = Join-Path $RootDir "output\designs\Flow_${FlowName}_${Timestamp}.md"
    
    $MdContent = @"
# Power Automate フロー定義
**エクスポート日時**: $(Get-Date -Format "yyyy/MM/dd HH:mm:ss")

## 基本情報
- **フロー名**: $($FlowResponse.properties.displayName)
- **フローID**: $FlowId
- **環境**: $($Environment.properties.displayName)
- **環境ID**: $EnvironmentId
- **状態**: $($FlowResponse.properties.state)
- **作成日**: $($FlowResponse.properties.createdTime)
- **更新日**: $($FlowResponse.properties.lastModifiedTime)
- **作成者**: $($FlowResponse.properties.creator.userPrincipalName)

## トリガー
"@

    # トリガー情報を抽出
    $Definition = $FlowResponse.properties.definition
    if ($Definition.triggers) {
        foreach ($TriggerName in $Definition.triggers.PSObject.Properties.Name) {
            $Trigger = $Definition.triggers.$TriggerName
            $MdContent += @"

### $TriggerName
- **種類**: $($Trigger.type)
- **入力**:
``````json
$($Trigger.inputs | ConvertTo-Json -Depth 10)
``````

"@
        }
    }
    
    # アクション情報を抽出
    $MdContent += @"

## アクション
"@

    if ($Definition.actions) {
        foreach ($ActionName in $Definition.actions.PSObject.Properties.Name) {
            $Action = $Definition.actions.$ActionName
            $MdContent += @"

### $ActionName
- **種類**: $($Action.type)
"@
            if ($Action.runAfter) {
                $MdContent += "- **実行条件**: $($Action.runAfter.PSObject.Properties.Name -join ', ')`n"
            }
            
            $MdContent += @"
- **入力**:
``````json
$($Action.inputs | ConvertTo-Json -Depth 10)
``````

"@
        }
    }
    
    # 接続情報
    if ($FlowResponse.properties.connectionReferences) {
        $MdContent += @"

## 接続
"@
        foreach ($ConnName in $FlowResponse.properties.connectionReferences.PSObject.Properties.Name) {
            $Conn = $FlowResponse.properties.connectionReferences.$ConnName
            $MdContent += @"

### $ConnName
- **接続名**: $($Conn.connectionName)
- **接続ID**: $($Conn.id)

"@
        }
    }
    
    # Markdownファイルに保存
    $MdContent | Out-File -FilePath $MdFile -Encoding UTF8
    Write-Host "✓ Markdown定義を保存: $MdFile" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "==================================" -ForegroundColor Cyan
    Write-Host "エクスポート完了！" -ForegroundColor Green
    Write-Host "==================================" -ForegroundColor Cyan
    
} catch {
    Write-Host "✗ フロー定義の取得に失敗しました" -ForegroundColor Red
    Write-Host "  エラー: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $Reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $ResponseBody = $Reader.ReadToEnd()
        Write-Host "  レスポンス: $ResponseBody" -ForegroundColor Red
    }
    exit 1
}
