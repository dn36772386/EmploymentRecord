<#
  export-all-lists.ps1
  - 1回の認証で複数のリストの設計書を出力します
  - 使い方: pwsh -File ./export-all-lists.ps1
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# 認証（1回だけ）
. "$PSScriptRoot/../../connect.ps1"

# 各リストのエクスポート
$lists = @(
    'EMP_1_EmploymentRecords',
    'EMP_1_Projects',
    'EMP_1_EmploymentApprovals'
)

foreach ($listName in $lists) {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "エクスポート中: $listName" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    
    try {
        # config.ps1の$SrcListを一時的に上書き
        $global:SrcList = $listName
        
        # エクスポート処理を実行
        $list = Get-PnPList -Identity $listName -ErrorAction Stop
        
        # 事前に主要プロパティを引き出す
        Get-PnPProperty -ClientObject $list -Property `
          Title,Id,DefaultViewUrl,Description,Hidden,ItemCount,BaseTemplate,ContentTypesEnabled, `
          EnableAttachments,EnableFolderCreation,EnableVersioning,EnableMinorVersions,ForceCheckout, `
          MajorVersionLimit,MajorWithMinorVersionsLimit,ReadSecurity,WriteSecurity,ValidationFormula,ValidationMessage, `
          HasUniqueRoleAssignments,ListExperienceOptions,CommandBarEnabledOnView `
          -ErrorAction SilentlyContinue | Out-Null
        
        # リストレベルのJSON書式を取得（存在する場合）
        $listFormatterJSON = $null
        try {
            # ListExperience の JSON書式設定を取得
            $listFormatterJSON = $list.CustomActionElements
        } catch { }
        
        # 出力先
        $ts = (Get-Date).ToString('yyyyMMdd-HHmmss')
        $baseName = "$($listName)_design-$ts"
        $outputDir = Join-Path $PSScriptRoot "../../output/designs"
        if (-not (Test-Path $outputDir)) {
            New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
        }
        $mdPath = Join-Path $outputDir "$baseName.md"
        
        # ヘッダ
        $header = @()
        $header += "# リスト設計書 ($($list.Title))"
        $header += ''
        $header += "生成日時: $(Get-Date -Format 'yyyy/MM/dd HH:mm:ss')"
        $header += "サイト: $((Get-PnPConnection).Url)"
        $header += "リスト: $listName"
        $header += ''
        $header += "## 基本情報"
        $header += ("- Title: {0}" -f $list.Title)
        $header += ("- Id: {0}" -f $list.Id)
        $header += ("- URL: {0}" -f $list.DefaultViewUrl)
        $header += ("- 説明: {0}" -f ($list.Description ?? ''))
        $header += ("- テンプレート: {0}" -f $list.BaseTemplate)
        $header += ("- アイテム数: {0}" -f $list.ItemCount)
        $header += ("- Hidden: {0}" -f $list.Hidden)
        $header += ("- ContentTypesEnabled: {0}" -f $list.ContentTypesEnabled)
        $header += ("- 添付ファイル: {0}" -f $list.EnableAttachments)
        $header += ("- フォルダー作成可: {0}" -f $list.EnableFolderCreation)
        $header += ("- バージョン管理: Major={0} Minor={1} ForceCheckout={2}" -f $list.EnableVersioning,$list.EnableMinorVersions,$list.ForceCheckout)
        $header += ("- 版数上限: MajorLimit={0} MajorWithMinorLimit={1}" -f $list.MajorVersionLimit,$list.MajorWithMinorVersionsLimit)
        $header += ("- 読取権限(ReadSecurity): {0} / 書込権限(WriteSecurity): {1}" -f $list.ReadSecurity,$list.WriteSecurity)
        $header += ("- 固有権限(HasUniqueRoleAssignments): {0}" -f $list.HasUniqueRoleAssignments)
        
        # リストエクスペリエンス設定
        if ($list.PSObject.Properties.Name -contains 'ListExperienceOptions') {
            $expText = switch($list.ListExperienceOptions) {
                0 { "Auto" }
                1 { "NewExperience" }
                2 { "ClassicExperience" }
                default { $list.ListExperienceOptions }
            }
            $header += ("- ListExperience: {0}" -f $expText)
        }
        
        $header += ''
        
        Set-Content -Path $mdPath -Value ($header -join "`n") -Encoding UTF8
        
        # フィールド
        Add-Content -Path $mdPath -Value "## フィールド一覧`n" -Encoding UTF8
        
        $fields = Get-PnPField -List $listName
        foreach($f in $fields | Where-Object { -not $_.FromBaseType }) {
            Get-PnPProperty -ClientObject $f -Property `
                Title,InternalName,TypeAsString,Required,Hidden,ReadOnlyField,DefaultValue `
                -ErrorAction SilentlyContinue | Out-Null
            Get-PnPProperty -ClientObject $f -Property `
                Choices,LookupList,LookupField,AllowMultipleValues,CustomFormatter `
                -ErrorAction SilentlyContinue | Out-Null
            
            $line = "### $($f.Title) ($($f.InternalName))`n"
            $line += "- 型: $($f.TypeAsString)`n"
            $line += "- 必須: $($f.Required) / Hidden: $($f.Hidden) / ReadOnly: $($f.ReadOnlyField)`n"
            if ($f.DefaultValue) { $line += "- 既定値: $($f.DefaultValue)`n" }
            
            # プロパティの存在確認
            if (($f.PSObject.Properties.Name -contains 'Choices') -and $f.Choices) {
                $line += "- 選択肢: $(($f.Choices -as [string[]]) -join ' | ')`n"
            }
            if (($f.PSObject.Properties.Name -contains 'LookupList') -and $f.LookupList) {
                $multi = if($f.PSObject.Properties.Name -contains 'AllowMultipleValues'){ $f.AllowMultipleValues } else { $false }
                $line += "- Lookup: List=$($f.LookupList), Field=$($f.LookupField), Multi=$multi`n"
            }
            
            # 列のJSON書式
            if (($f.PSObject.Properties.Name -contains 'CustomFormatter') -and $f.CustomFormatter) {
                $line += "`n**列書式 (JSON):**`n"
                $line += "``````json`n"
                $line += $f.CustomFormatter
                $line += "`n``````n"
            }
            
            $line += "`n"
            Add-Content -Path $mdPath -Value $line -Encoding UTF8
        }
        
        # カスタムアクション（コマンドバーのカスタマイズ）
        try {
            $customActions = Get-PnPCustomAction -List $listName -ErrorAction SilentlyContinue
            if ($customActions) {
                Add-Content -Path $mdPath -Value "## カスタムアクション (コマンドバー)`n" -Encoding UTF8
                foreach ($ca in $customActions) {
                    Get-PnPProperty -ClientObject $ca -Property Title,Name,Location,Sequence,CommandUIExtension,ClientSideComponentId,ClientSideComponentProperties -ErrorAction SilentlyContinue | Out-Null
                    
                    $caLine = "### $($ca.Title) ($($ca.Name))`n"
                    $caLine += "- Location: $($ca.Location)`n"
                    $caLine += "- Sequence: $($ca.Sequence)`n"
                    
                    if ($ca.CommandUIExtension) {
                        $caLine += "`n**CommandUIExtension (XML):**`n"
                        $caLine += "``````xml`n"
                        $caLine += $ca.CommandUIExtension
                        $caLine += "`n``````n"
                    }
                    
                    if ($ca.ClientSideComponentId -and $ca.ClientSideComponentId -ne [Guid]::Empty) {
                        $caLine += "`n**SPFx拡張機能:**`n"
                        $caLine += "- ComponentId: $($ca.ClientSideComponentId)`n"
                        if ($ca.ClientSideComponentProperties) {
                            $caLine += "- Properties (JSON):`n"
                            $caLine += "``````json`n"
                            $caLine += $ca.ClientSideComponentProperties
                            $caLine += "`n``````n"
                        }
                    }
                    
                    $caLine += "`n"
                    Add-Content -Path $mdPath -Value $caLine -Encoding UTF8
                }
            }
        } catch { }
        
        # ビュー
        Add-Content -Path $mdPath -Value "## ビュー`n" -Encoding UTF8
        
        $views = Get-PnPView -List $listName
        foreach($v in $views) {
            # 詳細プロパティを取得
            Get-PnPProperty -ClientObject $v -Property `
                Title,DefaultView,ViewFields,RowLimit,Paged,Scope,ViewQuery, `
                ViewType,PersonalView,Hidden,MobileView,MobileDefaultView, `
                Aggregations,AggregationsStatus,GroupBy,OrderBy, `
                CustomFormatter,RowFormatter `
                -ErrorAction SilentlyContinue | Out-Null
            
            $line = "### $($v.Title)`n"
            $line += "- 既定ビュー: $($v.DefaultView)`n"
            $line += "- ビュータイプ: $($v.ViewType)`n"
            $line += "- 個人用: $($v.PersonalView) / 非表示: $($v.Hidden)`n"
            $line += "- 行数制限: $($v.RowLimit) / ページング: $($v.Paged)`n"
            
            # スコープ
            $scopeText = switch($v.Scope) {
                0 { "既定（フォルダーなし）" }
                1 { "再帰的（すべて）" }
                2 { "フォルダー内のみ" }
                default { $v.Scope }
            }
            $line += "- スコープ: $scopeText`n"
            
            # モバイル
            if ($v.PSObject.Properties.Name -contains 'MobileView') {
                $line += "- モバイル: View=$($v.MobileView) / Default=$($v.MobileDefaultView)`n"
            }
            
            # 表示列
            if ($v.ViewFields -and $v.ViewFields.Count -gt 0) {
                $line += "`n**表示列** ($($v.ViewFields.Count)個):`n"
                $line += "``````n"
                $line += (($v.ViewFields -as [string[]]) -join "`n")
                $line += "`n``````n"
            }
            
            # クエリ (CAML)
            if ($v.ViewQuery) {
                $line += "`n**ViewQuery (CAML):**`n"
                $line += "``````xml`n"
                $line += $v.ViewQuery
                $line += "`n``````n"
            }
            
            # 集計
            if (($v.PSObject.Properties.Name -contains 'Aggregations') -and $v.Aggregations) {
                $line += "`n**集計:**`n"
                $line += "``````xml`n"
                $line += $v.Aggregations
                $line += "`n``````n"
                if ($v.PSObject.Properties.Name -contains 'AggregationsStatus') {
                    $line += "- 集計ステータス: $($v.AggregationsStatus)`n"
                }
            }
            
            # グループ化
            if (($v.PSObject.Properties.Name -contains 'GroupBy') -and $v.GroupBy) {
                $line += "`n**グループ化:**`n"
                $line += "``````xml`n"
                $line += $v.GroupBy
                $line += "`n``````n"
            }
            
            # 並び順
            if (($v.PSObject.Properties.Name -contains 'OrderBy') -and $v.OrderBy) {
                $line += "`n**並び順:**`n"
                $line += "``````xml`n"
                $line += $v.OrderBy
                $line += "`n``````n"
            }
            
            # JSON書式
            if ($v.PSObject.Properties.Name -contains 'CustomFormatter' -and $v.CustomFormatter) {
                $line += "`n**カスタム書式 (JSON):**`n"
                $line += "``````json`n"
                $line += $v.CustomFormatter
                $line += "`n``````n"
            }
            
            if ($v.PSObject.Properties.Name -contains 'RowFormatter' -and $v.RowFormatter) {
                $line += "`n**行書式 (JSON):**`n"
                $line += "``````json`n"
                $line += $v.RowFormatter
                $line += "`n``````n"
            }
            
            # ヘッダー/フッターJSON (環境により利用可能)
            try {
                $hdrJson = $v.HeaderJSON
                if ($hdrJson) {
                    $line += "`n**ヘッダー書式 (JSON):**`n"
                    $line += "``````json`n"
                    $line += $hdrJson
                    $line += "`n``````n"
                }
            } catch { }
            
            try {
                $ftrJson = $v.FooterJSON
                if ($ftrJson) {
                    $line += "`n**フッター書式 (JSON):**`n"
                    $line += "``````json`n"
                    $line += $ftrJson
                    $line += "`n``````n"
                }
            } catch { }
            
            $line += "`n---`n"
            Add-Content -Path $mdPath -Value $line -Encoding UTF8
        }
        
        Add-Content -Path $mdPath -Value "---`n(本書は export-all-lists.ps1 により自動生成されました)" -Encoding UTF8
        
        # TXTにもコピー
        $txtPath = $mdPath -replace '\.md$', '.txt'
        Copy-Item -Path $mdPath -Destination $txtPath -Force
        
        Write-Host "✓ 出力: $mdPath" -ForegroundColor Green
        Write-Host "✓ 出力: $txtPath" -ForegroundColor Green
        
    } catch {
        Write-Warning "エクスポート失敗 ($listName): $($_.Exception.Message)"
    }
}

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "すべてのエクスポートが完了しました" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
