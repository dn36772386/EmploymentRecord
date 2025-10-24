# Power Automate フロー作成スクリプト
# EMP_2_雇用調書承認フロー（並行2段階承認）

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
Write-Host "Power Automate フロー作成" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "新しいフロー名: $NewFlowName" -ForegroundColor Yellow
Write-Host "ベースフロー: $SourceFlowId" -ForegroundColor Yellow
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
    "Content-Type" = "application/json"
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
    Write-Host ""
} catch {
    Write-Host "✗ 環境情報の取得に失敗しました" -ForegroundColor Red
    Write-Host "  エラー: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# 既存フロー定義を取得
Write-Host "既存フローの定義を取得中..." -ForegroundColor Cyan

$SourceFlowUri = "https://api.flow.microsoft.com/providers/Microsoft.ProcessSimple/environments/$EnvironmentId/flows/$SourceFlowId`?api-version=2016-11-01"

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

# 新しいフロー定義を作成
Write-Host "新しいフロー定義を作成中..." -ForegroundColor Cyan

$NewFlowId = [System.Guid]::NewGuid().ToString()

# 基本構造をコピー
$NewFlowDefinition = @{
    properties = @{
        displayName = $NewFlowName
        state = "Started"
        definition = @{
            '$schema' = "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#"
            contentVersion = "1.0.0.0"
            parameters = $SourceFlow.properties.definition.parameters
            triggers = $SourceFlow.properties.definition.triggers
            actions = @{}
        }
        connectionReferences = $SourceFlow.properties.connectionReferences
    }
}

# アクションを構築（並行2段階承認）
Write-Host "並行2段階承認アクションを構築中..." -ForegroundColor Cyan

# 1. 項目の取得
$NewFlowDefinition.properties.definition.actions["Get_item"] = @{
    type = "ApiConnection"
    inputs = @{
        host = @{
            connection = @{
                name = "@parameters('`$connections')['sharepointonline']['connectionId']"
            }
        }
        method = "get"
        path = "/datasets/@{encodeURIComponent('https://tf1980.sharepoint.com/sites/abeam')}/tables/@{encodeURIComponent('9898ad51-5d08-4c68-97c8-e8123b70bc44')}/items/@{triggerBody()?['entity']?['ID']}"
    }
    runAfter = @{}
}

# 2. 第1承認者への承認依頼
$NewFlowDefinition.properties.definition.actions["Approval_Stage1"] = @{
    type = "ApiConnection"
    inputs = @{
        host = @{
            connection = @{
                name = "@parameters('`$connections')['approvals']['connectionId']"
            }
        }
        method = "post"
        path = "/approvals"
        body = @{
            approvalType = "Approve/Reject"
            title = "【第1承認依頼】雇用調書 - @{outputs('Get_item')?['body/FullName']}"
            assignedTo = "@{outputs('Get_item')?['body/Stage1ApproversClaims']}"
            details = "申請者: @{outputs('Get_item')?['body/FullName']}\n職員番号: @{outputs('Get_item')?['body/EmployeeID']}\n採用理由: @{outputs('Get_item')?['body/EmploymentReason']}\n部署: @{outputs('Get_item')?['body/Department']}"
            itemLink = "@{outputs('Get_item')?['body/{Link}']}"
            itemLinkDescription = "アイテムを表示"
        }
    }
    runAfter = @{
        Get_item = @("Succeeded")
    }
}

# 3. 第2承認者への承認依頼（並行実行）
$NewFlowDefinition.properties.definition.actions["Approval_Stage2"] = @{
    type = "ApiConnection"
    inputs = @{
        host = @{
            connection = @{
                name = "@parameters('`$connections')['approvals']['connectionId']"
            }
        }
        method = "post"
        path = "/approvals"
        body = @{
            approvalType = "Approve/Reject"
            title = "【第2承認依頼】雇用調書 - @{outputs('Get_item')?['body/FullName']}"
            assignedTo = "@{outputs('Get_item')?['body/Stage2ApproversClaims']}"
            details = "申請者: @{outputs('Get_item')?['body/FullName']}\n職員番号: @{outputs('Get_item')?['body/EmployeeID']}\n採用理由: @{outputs('Get_item')?['body/EmploymentReason']}\n部署: @{outputs('Get_item')?['body/Department']}"
            itemLink = "@{outputs('Get_item')?['body/{Link}']}"
            itemLinkDescription = "アイテムを表示"
        }
    }
    runAfter = @{
        Get_item = @("Succeeded")
    }
}

# 4. 第1承認者結果チェック
$NewFlowDefinition.properties.definition.actions["Condition_Stage1"] = @{
    type = "If"
    expression = @{
        equals = @(
            "@outputs('Approval_Stage1')?['body/outcome']",
            "Approve"
        )
    }
    actions = @{
        # 承認時: ステータス更新
        Update_Stage1_Approved = @{
            type = "ApiConnection"
            inputs = @{
                host = @{
                    connection = @{
                        name = "@parameters('`$connections')['sharepointonline']['connectionId']"
                    }
                }
                method = "patch"
                path = "/datasets/@{encodeURIComponent('https://tf1980.sharepoint.com/sites/abeam')}/tables/@{encodeURIComponent('9898ad51-5d08-4c68-97c8-e8123b70bc44')}/items/@{outputs('Get_item')?['body/ID']}"
                body = @{
                    Stage1ApprovalStatus = "承認"
                    Stage1ApprovalComment = "@{outputs('Approval_Stage1')?['body/responses'][0]['comments']}"
                    Stage1ApprovalDate = "@{utcNow()}"
                }
            }
            runAfter = @{}
        }
        # 権限継承解除
        Break_Permissions = @{
            type = "ApiConnection"
            inputs = @{
                host = @{
                    connection = @{
                        name = "@parameters('`$connections')['sharepointonline']['connectionId']"
                    }
                }
                method = "post"
                path = "/datasets/@{encodeURIComponent('https://tf1980.sharepoint.com/sites/abeam')}/_api/web/lists/getbytitle('EMP_1_EmploymentRecords')/items(@{outputs('Get_item')?['body/ID']})/breakroleinheritance(copyRoleAssignments=false)"
                headers = @{
                    Accept = "application/json;odata=verbose"
                    "Content-Type" = "application/json;odata=verbose"
                }
            }
            runAfter = @{
                Update_Stage1_Approved = @("Succeeded")
            }
        }
        # 閲覧権限付与
        Grant_Read_Permission = @{
            type = "ApiConnection"
            inputs = @{
                host = @{
                    connection = @{
                        name = "@parameters('`$connections')['sharepointonline']['connectionId']"
                    }
                }
                method = "post"
                path = "/datasets/@{encodeURIComponent('https://tf1980.sharepoint.com/sites/abeam')}/_api/web/lists/getbytitle('EMP_1_EmploymentRecords')/items(@{outputs('Get_item')?['body/ID']})/roleassignments/addroleassignment(principalid=@{outputs('Get_item')?['body/AuthorId']},roledefid=1073741826)"
                headers = @{
                    Accept = "application/json;odata=verbose"
                    "Content-Type" = "application/json;odata=verbose"
                }
            }
            runAfter = @{
                Break_Permissions = @("Succeeded")
            }
        }
    }
    else = @{
        actions = @{
            # 差戻し時: ステータス更新
            Update_Stage1_Rejected = @{
                type = "ApiConnection"
                inputs = @{
                    host = @{
                        connection = @{
                            name = "@parameters('`$connections')['sharepointonline']['connectionId']"
                        }
                    }
                    method = "patch"
                    path = "/datasets/@{encodeURIComponent('https://tf1980.sharepoint.com/sites/abeam')}/tables/@{encodeURIComponent('9898ad51-5d08-4c68-97c8-e8123b70bc44')}/items/@{outputs('Get_item')?['body/ID']}"
                    body = @{
                        Stage1ApprovalStatus = "差戻し"
                        Stage1ApprovalComment = "@{outputs('Approval_Stage1')?['body/responses'][0]['comments']}"
                        Stage1ApprovalDate = "@{utcNow()}"
                        OverallApproval = "差戻し"
                    }
                }
                runAfter = @{}
            }
            # 差戻しメール送信
            Send_Rejection_Email_Stage1 = @{
                type = "ApiConnection"
                inputs = @{
                    host = @{
                        connection = @{
                            name = "@parameters('`$connections')['office365']['connectionId']"
                        }
                    }
                    method = "post"
                    path = "/v2/Mail"
                    body = @{
                        To = "@{outputs('Get_item')?['body/AuthorEmail']}"
                        Subject = "【差戻し】雇用調書 - @{outputs('Get_item')?['body/FullName']}"
                        Body = "<p>雇用調書が差戻されました。</p><p><strong>申請者:</strong> @{outputs('Get_item')?['body/FullName']}</p><p><strong>差戻理由:</strong><br>@{outputs('Approval_Stage1')?['body/responses'][0]['comments']}</p><p><a href=`"@{outputs('Get_item')?['body/{Link}']}`">アイテムを確認</a></p>"
                    }
                }
                runAfter = @{
                    Update_Stage1_Rejected = @("Succeeded")
                }
            }
        }
    }
    runAfter = @{
        Approval_Stage1 = @("Succeeded")
    }
}

# 5. 第2承認者結果チェック（第1承認者と同様の構造）
$NewFlowDefinition.properties.definition.actions["Condition_Stage2"] = @{
    type = "If"
    expression = @{
        equals = @(
            "@outputs('Approval_Stage2')?['body/outcome']",
            "Approve"
        )
    }
    actions = @{
        Update_Stage2_Approved = @{
            type = "ApiConnection"
            inputs = @{
                host = @{
                    connection = @{
                        name = "@parameters('`$connections')['sharepointonline']['connectionId']"
                    }
                }
                method = "patch"
                path = "/datasets/@{encodeURIComponent('https://tf1980.sharepoint.com/sites/abeam')}/tables/@{encodeURIComponent('9898ad51-5d08-4c68-97c8-e8123b70bc44')}/items/@{outputs('Get_item')?['body/ID']}"
                body = @{
                    Stage2ApprovalStatus = "承認"
                    Stage2ApprovalComment = "@{outputs('Approval_Stage2')?['body/responses'][0]['comments']}"
                    Stage2ApprovalDate = "@{utcNow()}"
                }
            }
            runAfter = @{}
        }
        Break_Permissions_Stage2 = @{
            type = "ApiConnection"
            inputs = @{
                host = @{
                    connection = @{
                        name = "@parameters('`$connections')['sharepointonline']['connectionId']"
                    }
                }
                method = "post"
                path = "/datasets/@{encodeURIComponent('https://tf1980.sharepoint.com/sites/abeam')}/_api/web/lists/getbytitle('EMP_1_EmploymentRecords')/items(@{outputs('Get_item')?['body/ID']})/breakroleinheritance(copyRoleAssignments=false)"
                headers = @{
                    Accept = "application/json;odata=verbose"
                    "Content-Type" = "application/json;odata=verbose"
                }
            }
            runAfter = @{
                Update_Stage2_Approved = @("Succeeded")
            }
        }
        Grant_Read_Permission_Stage2 = @{
            type = "ApiConnection"
            inputs = @{
                host = @{
                    connection = @{
                        name = "@parameters('`$connections')['sharepointonline']['connectionId']"
                    }
                }
                method = "post"
                path = "/datasets/@{encodeURIComponent('https://tf1980.sharepoint.com/sites/abeam')}/_api/web/lists/getbytitle('EMP_1_EmploymentRecords')/items(@{outputs('Get_item')?['body/ID']})/roleassignments/addroleassignment(principalid=@{outputs('Get_item')?['body/AuthorId']},roledefid=1073741826)"
                headers = @{
                    Accept = "application/json;odata=verbose"
                    "Content-Type" = "application/json;odata=verbose"
                }
            }
            runAfter = @{
                Break_Permissions_Stage2 = @("Succeeded")
            }
        }
    }
    else = @{
        actions = @{
            Update_Stage2_Rejected = @{
                type = "ApiConnection"
                inputs = @{
                    host = @{
                        connection = @{
                            name = "@parameters('`$connections')['sharepointonline']['connectionId']"
                        }
                    }
                    method = "patch"
                    path = "/datasets/@{encodeURIComponent('https://tf1980.sharepoint.com/sites/abeam')}/tables/@{encodeURIComponent('9898ad51-5d08-4c68-97c8-e8123b70bc44')}/items/@{outputs('Get_item')?['body/ID']}"
                    body = @{
                        Stage2ApprovalStatus = "差戻し"
                        Stage2ApprovalComment = "@{outputs('Approval_Stage2')?['body/responses'][0]['comments']}"
                        Stage2ApprovalDate = "@{utcNow()}"
                        OverallApproval = "差戻し"
                    }
                }
                runAfter = @{}
            }
            Send_Rejection_Email_Stage2 = @{
                type = "ApiConnection"
                inputs = @{
                    host = @{
                        connection = @{
                            name = "@parameters('`$connections')['office365']['connectionId']"
                        }
                    }
                    method = "post"
                    path = "/v2/Mail"
                    body = @{
                        To = "@{outputs('Get_item')?['body/AuthorEmail']}"
                        Subject = "【差戻し】雇用調書 - @{outputs('Get_item')?['body/FullName']}"
                        Body = "<p>雇用調書が差戻されました。</p><p><strong>申請者:</strong> @{outputs('Get_item')?['body/FullName']}</p><p><strong>差戻理由:</strong><br>@{outputs('Approval_Stage2')?['body/responses'][0]['comments']}</p><p><a href=`"@{outputs('Get_item')?['body/{Link}']}`">アイテムを確認</a></p>"
                    }
                }
                runAfter = @{
                    Update_Stage2_Rejected = @("Succeeded")
                }
            }
        }
    }
    runAfter = @{
        Approval_Stage2 = @("Succeeded")
    }
}

# 6. 最終承認判定
$NewFlowDefinition.properties.definition.actions["Final_Approval_Check"] = @{
    type = "If"
    expression = @{
        and = @(
            @{
                equals = @(
                    "@outputs('Approval_Stage1')?['body/outcome']",
                    "Approve"
                )
            },
            @{
                equals = @(
                    "@outputs('Approval_Stage2')?['body/outcome']",
                    "Approve"
                )
            }
        )
    }
    actions = @{
        Update_Final_Approved = @{
            type = "ApiConnection"
            inputs = @{
                host = @{
                    connection = @{
                        name = "@parameters('`$connections')['sharepointonline']['connectionId']"
                    }
                }
                method = "patch"
                path = "/datasets/@{encodeURIComponent('https://tf1980.sharepoint.com/sites/abeam')}/tables/@{encodeURIComponent('9898ad51-5d08-4c68-97c8-e8123b70bc44')}/items/@{outputs('Get_item')?['body/ID']}"
                body = @{
                    OverallApproval = "承認完了"
                    ApprovalCompletedDate = "@{utcNow()}"
                }
            }
            runAfter = @{}
        }
        Send_Completion_Email = @{
            type = "ApiConnection"
            inputs = @{
                host = @{
                    connection = @{
                        name = "@parameters('`$connections')['office365']['connectionId']"
                    }
                }
                method = "post"
                path = "/v2/Mail"
                body = @{
                    To = "@{outputs('Get_item')?['body/AuthorEmail']};@{outputs('Get_item')?['body/Stage1ApproversEmail']};@{outputs('Get_item')?['body/Stage2ApproversEmail']}"
                    Subject = "【承認完了】雇用調書 - @{outputs('Get_item')?['body/FullName']}"
                    Body = "<p>雇用調書の承認が完了しました。</p><p><strong>申請者:</strong> @{outputs('Get_item')?['body/FullName']}</p><p><strong>第1承認者:</strong> @{outputs('Get_item')?['body/Stage1ApproversEmail']} - 承認</p><p><strong>第2承認者:</strong> @{outputs('Get_item')?['body/Stage2ApproversEmail']} - 承認</p><p><strong>承認完了日時:</strong> @{utcNow()}</p><p><a href=`"@{outputs('Get_item')?['body/{Link}']}`">アイテムを確認</a></p>"
                }
            }
            runAfter = @{
                Update_Final_Approved = @("Succeeded")
            }
        }
    }
    else = @{
        actions = @{
            Update_Final_Rejected = @{
                type = "ApiConnection"
                inputs = @{
                    host = @{
                        connection = @{
                            name = "@parameters('`$connections')['sharepointonline']['connectionId']"
                        }
                    }
                    method = "patch"
                    path = "/datasets/@{encodeURIComponent('https://tf1980.sharepoint.com/sites/abeam')}/tables/@{encodeURIComponent('9898ad51-5d08-4c68-97c8-e8123b70bc44')}/items/@{outputs('Get_item')?['body/ID']}"
                    body = @{
                        OverallApproval = "差戻し"
                    }
                }
                runAfter = @{}
            }
        }
    }
    runAfter = @{
        Condition_Stage1 = @("Succeeded")
        Condition_Stage2 = @("Succeeded")
    }
}

Write-Host "✓ フロー定義を作成しました" -ForegroundColor Green
Write-Host ""

# フロー定義をJSONファイルに保存
$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$JsonFile = Join-Path $RootDir "output\designs\Flow_${NewFlowName}_definition_${Timestamp}.json"
$NewFlowDefinition | ConvertTo-Json -Depth 100 | Out-File -FilePath $JsonFile -Encoding UTF8
Write-Host "✓ フロー定義を保存: $JsonFile" -ForegroundColor Green
Write-Host ""

# フローを作成
Write-Host "フローを作成中..." -ForegroundColor Cyan

$CreateFlowUri = "https://api.flow.microsoft.com/providers/Microsoft.ProcessSimple/environments/$EnvironmentId/flows/$NewFlowId`?api-version=2016-11-01"

$Body = $NewFlowDefinition | ConvertTo-Json -Depth 100 -Compress

try {
    Write-Host "デバッグ: リクエストURI" -ForegroundColor Gray
    Write-Host "  $CreateFlowUri" -ForegroundColor Gray
    Write-Host ""
    
    $Response = Invoke-RestMethod -Uri $CreateFlowUri -Headers $Headers -Method Put -Body $Body -Verbose -ErrorAction Stop
    
    Write-Host "✓ フローの作成に成功しました！" -ForegroundColor Green
    Write-Host ""
    Write-Host "フロー情報:" -ForegroundColor Yellow
    Write-Host "  ID: $NewFlowId" -ForegroundColor White
    Write-Host "  名前: $($Response.properties.displayName)" -ForegroundColor White
    Write-Host "  状態: $($Response.properties.state)" -ForegroundColor White
    Write-Host ""
    Write-Host "フローURL:" -ForegroundColor Yellow
    Write-Host "  https://make.powerautomate.com/environments/$EnvironmentId/flows/$NewFlowId/details" -ForegroundColor Cyan
    Write-Host ""
    
    # 結果をファイルに保存
    $ResultFile = Join-Path $RootDir "output\designs\Flow_${NewFlowName}_created_${Timestamp}.json"
    $Response | ConvertTo-Json -Depth 100 | Out-File -FilePath $ResultFile -Encoding UTF8
    Write-Host "✓ 作成結果を保存: $ResultFile" -ForegroundColor Green
    Write-Host ""
    Write-Host "==================================" -ForegroundColor Cyan
    Write-Host "フロー作成完了！" -ForegroundColor Green
    Write-Host "==================================" -ForegroundColor Cyan
    
} catch {
    Write-Host "✗ フローの作成に失敗しました" -ForegroundColor Red
    Write-Host "  エラー: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "  ステータスコード: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
    
    # エラーレスポンスの詳細を取得
    try {
        $ErrorStream = $_.Exception.Response.Content.ReadAsStringAsync().Result
        Write-Host "  APIレスポンス: $ErrorStream" -ForegroundColor Red
    } catch {
        Write-Host "  レスポンス詳細の取得に失敗" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "トラブルシューティング:" -ForegroundColor Yellow
    Write-Host "  1. API version (2016-11-01) が正しいか確認" -ForegroundColor Yellow
    Write-Host "  2. EnvironmentId: $EnvironmentId" -ForegroundColor Yellow
    Write-Host "  3. FlowId: $NewFlowId" -ForegroundColor Yellow
    Write-Host "  4. フロー定義ファイルを確認: $JsonFile" -ForegroundColor Yellow
    Write-Host "  5. Flows.Manage.All 権限があるか確認" -ForegroundColor Yellow
    
    exit 1
}
