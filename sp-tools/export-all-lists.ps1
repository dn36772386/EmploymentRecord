<#
  export-all-lists.ps1
  - 1回の認証で複数のリストの設計書を出力します
  - 使い方: pwsh -File ./export-all-lists.ps1
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# 認証（1回だけ）
. "$PSScriptRoot/connect.ps1"

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
          HasUniqueRoleAssignments -ErrorAction SilentlyContinue | Out-Null
        
        # 出力先
        $ts = (Get-Date).ToString('yyyyMMdd-HHmmss')
        $baseName = "$($listName)_design-$ts"
        $mdPath = Join-Path $PSScriptRoot "$baseName.md"
        
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
                Choices,LookupList,LookupField,AllowMultipleValues `
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
            $line += "`n"
            Add-Content -Path $mdPath -Value $line -Encoding UTF8
        }
        
        # ビュー
        Add-Content -Path $mdPath -Value "## ビュー`n" -Encoding UTF8
        
        $views = Get-PnPView -List $listName
        foreach($v in $views) {
            Get-PnPProperty -ClientObject $v -Property Title,DefaultView,ViewFields,RowLimit -ErrorAction SilentlyContinue | Out-Null
            
            $line = "### $($v.Title) (Default=$($v.DefaultView))`n"
            $line += "- RowLimit: $($v.RowLimit)`n"
            if ($v.ViewFields) {
                $line += "- 表示列: $(($v.ViewFields -as [string[]]) -join ', ')`n"
            }
            $line += "`n"
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
