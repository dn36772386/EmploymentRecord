Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'

# 既に接続されているかチェック
$conn = Get-PnPConnection -ErrorAction SilentlyContinue
if (-not $conn) {
  . "$PSScriptRoot/connect.ps1"
}
. "$PSScriptRoot/config.ps1"

<#
.SYNOPSIS
雇用記録に対して承認レコードを自動生成するスクリプト

.DESCRIPTION
新しい雇用記録が作成されたときに、その記録に対する承認フロー（3段階）を
自動的に作成します。Power Automateから呼び出すことを想定しています。

.PARAMETER EmploymentRecordId
雇用記録のID

.EXAMPLE
./create-approval-records-for-employment.ps1 -EmploymentRecordId 123
#>

param(
    [Parameter(Mandatory=$false)]
    [int]$EmploymentRecordId
)

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  承認レコード自動生成" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# 固定ユーザー設定
$applicantEmail = "user1@abctestdomain.com"        # 申請者
$stage1ApproverEmail = "manager1@abctestdomain.com"  # 第1段承認者（部門）
$stage2ApproverEmail = "dnakajima@abctestdomain.com" # 第2段承認者（管理部門）

# パラメータが指定されていない場合は、承認レコードが未設定の雇用記録を処理
if ($EmploymentRecordId -eq 0) {
    Write-Host "承認レコードが未設定の雇用記録を検索中..." -ForegroundColor Gray
    
    # すべての雇用記録を取得
    $employmentRecords = Get-PnPListItem -List 'EMP_1_EmploymentRecords' -Fields "ID","EmployeeID","FullName"
    
    # 既に承認レコードがある雇用記録IDを取得
    $existingApprovals = Get-PnPListItem -List 'EMP_1_EmploymentApprovals' -Fields "ParentRecord"
    $existingRecordIds = $existingApprovals | ForEach-Object { 
        if ($_.FieldValues.ParentRecord) {
            $_.FieldValues.ParentRecord.LookupId
        }
    } | Select-Object -Unique
    
    # 承認レコードがない雇用記録を抽出
    $recordsToProcess = $employmentRecords | Where-Object { 
        $existingRecordIds -notcontains $_.Id 
    }
    
    if ($recordsToProcess.Count -eq 0) {
        Write-Host "✓ すべての雇用記録に承認レコードが設定されています" -ForegroundColor Green
        exit 0
    }
    
    Write-Host "✓ 処理対象: $($recordsToProcess.Count) 件の雇用記録" -ForegroundColor Yellow
} else {
    # 指定されたIDの雇用記録を取得
    Write-Host "雇用記録ID: $EmploymentRecordId を処理中..." -ForegroundColor Gray
    $record = Get-PnPListItem -List 'EMP_1_EmploymentRecords' -Id $EmploymentRecordId
    if (-not $record) {
        Write-Host "✗ エラー: 雇用記録ID $EmploymentRecordId が見つかりません" -ForegroundColor Red
        exit 1
    }
    $recordsToProcess = @($record)
}

# 承認レコードを生成
$totalCreated = 0
$totalFailed = 0

foreach ($record in $recordsToProcess) {
    $recordId = $record.Id
    $employeeId = $record.FieldValues.EmployeeID
    $fullName = $record.FieldValues.FullName
    
    Write-Host "`n[$employeeId] $fullName の承認レコードを作成中..." -ForegroundColor Cyan
    
    $approvalRecords = @()
    
    # Stage 0: 申請者（下書き状態）
    $approvalRecords += @{
        Title = "申請 - $fullName"
        StageNumber = 0
        StageType = "部門"
        ApproverEmail = $applicantEmail
        Status = "下書き"
        IsRequired = $true
        DueDate = (Get-Date).AddDays(30)
        Order = 1
    }
    
    # Stage 1: 第1段承認者（部門長）
    $approvalRecords += @{
        Title = "第1段承認 - $fullName"
        StageNumber = 1
        StageType = "部門"
        ApproverEmail = $stage1ApproverEmail
        Status = "待機中"
        IsRequired = $true
        DueDate = (Get-Date).AddDays(7)
        Order = 2
    }
    
    # Stage 2: 第2段承認者（管理部門）
    $approvalRecords += @{
        Title = "第2段承認 - $fullName"
        StageNumber = 2
        StageType = "管理部門"
        ApproverEmail = $stage2ApproverEmail
        Status = "待機中"
        IsRequired = $true
        DueDate = (Get-Date).AddDays(3)
        Order = 3
    }
    
    # 承認レコードを作成
    $createdCount = 0
    foreach ($approval in $approvalRecords) {
        try {
            # アイテム作成
            $values = @{
                "Title" = $approval.Title
                "StageNumber" = $approval.StageNumber
                "StageType" = $approval.StageType
                "ApproverEmail" = $approval.ApproverEmail
                "Approver" = $approval.ApproverEmail
                "Status" = $approval.Status
                "IsRequired" = $approval.IsRequired
                "DueDate" = $approval.DueDate
                "Order" = $approval.Order
            }
            
            $item = Add-PnPListItem -List 'EMP_1_EmploymentApprovals' -Values $values
            
            # ParentRecordをSet-PnPListItemで設定（XMLを使用）
            $ctx = Get-PnPContext
            $list = $ctx.Web.Lists.GetByTitle('EMP_1_EmploymentApprovals')
            $listItem = $list.GetItemById($item.Id)
            
            # LookupFieldValueオブジェクトを作成
            $lookupValue = New-Object Microsoft.SharePoint.Client.FieldLookupValue
            $lookupValue.LookupId = $recordId
            $listItem["ParentRecord"] = $lookupValue
            
            $listItem.Update()
            $ctx.ExecuteQuery()
            
            Write-Host "  ✓ Stage $($approval.StageNumber) - $($approval.Status)" -ForegroundColor Green
            $createdCount++
        }
        catch {
            Write-Host "  ✗ Stage $($approval.StageNumber) - エラー: $($_.Exception.Message)" -ForegroundColor Red
            $totalFailed++
        }
    }
    
    if ($createdCount -eq $approvalRecords.Count) {
        Write-Host "  ✓ 完了: $createdCount 件の承認レコードを作成" -ForegroundColor Green
        $totalCreated += $createdCount
    } else {
        Write-Host "  ⚠️  一部失敗: $createdCount/$($approvalRecords.Count) 件作成" -ForegroundColor Yellow
        $totalCreated += $createdCount
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  処理完了" -ForegroundColor Cyan
Write-Host "  作成: $totalCreated 件" -ForegroundColor Green
Write-Host "  失敗: $totalFailed 件" -ForegroundColor $(if($totalFailed -gt 0){'Red'}else{'Green'})
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "✅ 承認レコード自動生成完了！" -ForegroundColor Green
