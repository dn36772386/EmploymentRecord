Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'

# 既に接続されているかチェック
$conn = Get-PnPConnection -ErrorAction SilentlyContinue
if (-not $conn) {
  . "$PSScriptRoot/connect.ps1"
}
. "$PSScriptRoot/config.ps1"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  サンプルプロジェクトデータ登録" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# サンプルデータ定義（20件）
$projects = @(
  @{
    ProjectCode = "PRJ001"
    ProjectName = "AI研究開発プロジェクト"
    PurposeBudgetCode = "11111"
    PurposeBudgetName = "研究開発費"
    PurposeExecCode = "22222"
    PurposeExecName = "先端技術研究"
    DeptCode = "44444"
    DeptName = "事務部門B"
    FundingCode = "33333"
    FundingName = "補助金"
    ValidUntil = (Get-Date).AddYears(2)
    BudgetProcFlag = "未"
    Notes = "次世代AI技術の研究開発"
  },
  @{
    ProjectCode = "PRJ002"
    ProjectName = "データサイエンス人材育成"
    PurposeBudgetCode = "11112"
    PurposeBudgetName = "教育研修費"
    PurposeExecCode = "22223"
    PurposeExecName = "人材育成"
    DeptCode = "44445"
    DeptName = "教育推進部"
    FundingCode = "33334"
    FundingName = "運営費交付金"
    ValidUntil = (Get-Date).AddYears(1)
    BudgetProcFlag = "済"
    Notes = "データサイエンティスト養成プログラム"
  },
  @{
    ProjectCode = "PRJ003"
    ProjectName = "医療DX推進プロジェクト"
    PurposeBudgetCode = "11113"
    PurposeBudgetName = "医療システム開発"
    PurposeExecCode = "22224"
    PurposeExecName = "DX推進"
    DeptCode = "44446"
    DeptName = "医療情報部"
    FundingCode = "33335"
    FundingName = "補助金"
    ValidUntil = (Get-Date).AddMonths(18)
    BudgetProcFlag = "未"
    Notes = "電子カルテシステム統合プロジェクト"
  },
  @{
    ProjectCode = "PRJ004"
    ProjectName = "スマートシティ実証実験"
    PurposeBudgetCode = "11114"
    PurposeBudgetName = "都市開発費"
    PurposeExecCode = "22225"
    PurposeExecName = "実証実験"
    DeptCode = "44447"
    DeptName = "都市研究所"
    FundingCode = "33336"
    FundingName = "委託費"
    ValidUntil = (Get-Date).AddYears(3)
    BudgetProcFlag = "済"
    Notes = "IoTセンサーを活用した都市管理"
  },
  @{
    ProjectCode = "PRJ005"
    ProjectName = "環境保全研究プログラム"
    PurposeBudgetCode = "11115"
    PurposeBudgetName = "環境研究費"
    PurposeExecCode = "22226"
    PurposeExecName = "環境保全"
    DeptCode = "44448"
    DeptName = "環境科学部"
    FundingCode = "33337"
    FundingName = "科研費"
    ValidUntil = (Get-Date).AddYears(5)
    BudgetProcFlag = "未"
    Notes = "持続可能な社会実現のための基礎研究"
  },
  @{
    ProjectCode = "PRJ006"
    ProjectName = "グローバル人材交流事業"
    PurposeBudgetCode = "11116"
    PurposeBudgetName = "国際交流費"
    PurposeExecCode = "22227"
    PurposeExecName = "国際連携"
    DeptCode = "44449"
    DeptName = "国際交流課"
    FundingCode = "33338"
    FundingName = "寄付金"
    ValidUntil = $null
    BudgetProcFlag = "済"
    Notes = "海外大学との共同研究推進"
  },
  @{
    ProjectCode = "PRJ007"
    ProjectName = "地域連携イノベーション"
    PurposeBudgetCode = "11117"
    PurposeBudgetName = "地域貢献費"
    PurposeExecCode = "22228"
    PurposeExecName = "地域連携"
    DeptCode = "44450"
    DeptName = "地域連携室"
    FundingCode = "33339"
    FundingName = "自己収入"
    ValidUntil = (Get-Date).AddMonths(24)
    BudgetProcFlag = "未"
    Notes = "地元企業との産学連携プロジェクト"
  },
  @{
    ProjectCode = "PRJ008"
    ProjectName = "次世代エネルギー研究"
    PurposeBudgetCode = "11118"
    PurposeBudgetName = "エネルギー研究費"
    PurposeExecCode = "22229"
    PurposeExecName = "新エネルギー開発"
    DeptCode = "44451"
    DeptName = "工学部"
    FundingCode = "33340"
    FundingName = "補助金"
    ValidUntil = (Get-Date).AddYears(4)
    BudgetProcFlag = "済"
    Notes = "再生可能エネルギーの効率化研究"
  },
  @{
    ProjectCode = "PRJ009"
    ProjectName = "教育ICT基盤整備"
    PurposeBudgetCode = "11119"
    PurposeBudgetName = "情報基盤整備費"
    PurposeExecCode = "22230"
    PurposeExecName = "ICT整備"
    DeptCode = "44452"
    DeptName = "情報基盤センター"
    FundingCode = "33341"
    FundingName = "運営費交付金"
    ValidUntil = (Get-Date).AddYears(1).AddMonths(6)
    BudgetProcFlag = "未"
    Notes = "オンライン教育システムの構築"
  },
  @{
    ProjectCode = "PRJ010"
    ProjectName = "ビッグデータ解析基盤構築"
    PurposeBudgetCode = "11120"
    PurposeBudgetName = "情報システム開発費"
    PurposeExecCode = "22231"
    PurposeExecName = "データ解析基盤"
    DeptCode = "44453"
    DeptName = "データ科学研究所"
    FundingCode = "33342"
    FundingName = "委託費"
    ValidUntil = (Get-Date).AddYears(2).AddMonths(6)
    BudgetProcFlag = "済"
    Notes = "大規模データ解析用クラウド基盤"
  },
  @{
    ProjectCode = "PRJ011"
    ProjectName = "文化財デジタルアーカイブ"
    PurposeBudgetCode = "11121"
    PurposeBudgetName = "文化事業費"
    PurposeExecCode = "22232"
    PurposeExecName = "デジタル保存"
    DeptCode = "44454"
    DeptName = "文化研究所"
    FundingCode = "33343"
    FundingName = "補助金"
    ValidUntil = $null
    BudgetProcFlag = "未"
    Notes = "歴史的文書のデジタル化プロジェクト"
  },
  @{
    ProjectCode = "PRJ012"
    ProjectName = "健康増進プログラム開発"
    PurposeBudgetCode = "11122"
    PurposeBudgetName = "保健事業費"
    PurposeExecCode = "22233"
    PurposeExecName = "健康増進"
    DeptCode = "44455"
    DeptName = "保健管理センター"
    FundingCode = "33344"
    FundingName = "自己収入"
    ValidUntil = (Get-Date).AddMonths(15)
    BudgetProcFlag = "済"
    Notes = "学生・教職員向け健康管理システム"
  },
  @{
    ProjectCode = "PRJ013"
    ProjectName = "ロボティクス応用研究"
    PurposeBudgetCode = "11123"
    PurposeBudgetName = "先端技術研究費"
    PurposeExecCode = "22234"
    PurposeExecName = "ロボット工学"
    DeptCode = "44456"
    DeptName = "機械工学科"
    FundingCode = "33345"
    FundingName = "科研費"
    ValidUntil = (Get-Date).AddYears(3).AddMonths(3)
    BudgetProcFlag = "未"
    Notes = "介護支援ロボットの開発"
  },
  @{
    ProjectCode = "PRJ014"
    ProjectName = "留学生支援システム構築"
    PurposeBudgetCode = "11124"
    PurposeBudgetName = "留学生支援費"
    PurposeExecCode = "22235"
    PurposeExecName = "留学生サポート"
    DeptCode = "44457"
    DeptName = "学生支援課"
    FundingCode = "33346"
    FundingName = "寄付金"
    ValidUntil = (Get-Date).AddYears(2)
    BudgetProcFlag = "済"
    Notes = "多言語対応の学生支援ポータル"
  },
  @{
    ProjectCode = "PRJ015"
    ProjectName = "防災教育プログラム"
    PurposeBudgetCode = "11125"
    PurposeBudgetName = "防災事業費"
    PurposeExecCode = "22236"
    PurposeExecName = "防災教育"
    DeptCode = "44458"
    DeptName = "安全管理室"
    FundingCode = "33347"
    FundingName = "補助金"
    ValidUntil = $null
    BudgetProcFlag = "未"
    Notes = "地域と連携した防災訓練プログラム"
  },
  @{
    ProjectCode = "PRJ016"
    ProjectName = "バイオテクノロジー研究"
    PurposeBudgetCode = "11126"
    PurposeBudgetName = "生命科学研究費"
    PurposeExecCode = "22237"
    PurposeExecName = "バイオ技術"
    DeptCode = "44459"
    DeptName = "生命科学部"
    FundingCode = "33348"
    FundingName = "科研費"
    ValidUntil = (Get-Date).AddYears(5).AddMonths(6)
    BudgetProcFlag = "済"
    Notes = "遺伝子編集技術の医療応用研究"
  },
  @{
    ProjectCode = "PRJ017"
    ProjectName = "オープンキャンパス運営"
    PurposeBudgetCode = "11127"
    PurposeBudgetName = "広報事業費"
    PurposeExecCode = "22238"
    PurposeExecName = "入試広報"
    DeptCode = "44460"
    DeptName = "入試課"
    FundingCode = "33349"
    FundingName = "運営費交付金"
    ValidUntil = (Get-Date).AddMonths(9)
    BudgetProcFlag = "未"
    Notes = "バーチャルオープンキャンパスの実施"
  },
  @{
    ProjectCode = "PRJ018"
    ProjectName = "量子コンピュータ研究"
    PurposeBudgetCode = "11128"
    PurposeBudgetName = "最先端技術研究費"
    PurposeExecCode = "22239"
    PurposeExecName = "量子技術"
    DeptCode = "44461"
    DeptName = "物理学科"
    FundingCode = "33350"
    FundingName = "委託費"
    ValidUntil = (Get-Date).AddYears(6)
    BudgetProcFlag = "済"
    Notes = "量子アルゴリズムの開発と応用"
  },
  @{
    ProjectCode = "PRJ019"
    ProjectName = "キャリア支援強化プログラム"
    PurposeBudgetCode = "11129"
    PurposeBudgetName = "就職支援費"
    PurposeExecCode = "22240"
    PurposeExecName = "キャリア教育"
    DeptCode = "44462"
    DeptName = "キャリアセンター"
    FundingCode = "33351"
    FundingName = "自己収入"
    ValidUntil = (Get-Date).AddYears(1).AddMonths(3)
    BudgetProcFlag = "未"
    Notes = "企業連携による実践型キャリア教育"
  },
  @{
    ProjectCode = "PRJ020"
    ProjectName = "図書館デジタル化推進"
    PurposeBudgetCode = "11130"
    PurposeBudgetName = "図書館運営費"
    PurposeExecCode = "22241"
    PurposeExecName = "デジタルライブラリ"
    DeptCode = "44463"
    DeptName = "図書館"
    FundingCode = "33352"
    FundingName = "運営費交付金"
    ValidUntil = (Get-Date).AddYears(2).AddMonths(9)
    BudgetProcFlag = "済"
    Notes = "電子書籍・論文データベース拡充"
  }
)

Write-Host "登録開始..." -ForegroundColor Yellow
$count = 0
$success = 0
$failed = 0

foreach ($proj in $projects) {
  $count++
  try {
    # ValidUntilがnullの場合は除外
    $values = @{
      "ProjectCode" = $proj.ProjectCode
      "ProjectName" = $proj.ProjectName
      "PurposeBudgetCode" = $proj.PurposeBudgetCode
      "PurposeBudgetName" = $proj.PurposeBudgetName
      "PurposeExecCode" = $proj.PurposeExecCode
      "PurposeExecName" = $proj.PurposeExecName
      "DeptCode" = $proj.DeptCode
      "DeptName" = $proj.DeptName
      "FundingCode" = $proj.FundingCode
      "FundingName" = $proj.FundingName
      "BudgetProcFlag" = $proj.BudgetProcFlag
      "Notes" = $proj.Notes
    }
    
    if ($proj.ValidUntil) {
      $values["ValidUntil"] = $proj.ValidUntil
    }
    
    $item = Add-PnPListItem -List $ProjectMaster -Values $values
    Write-Host "  [$count/20] ✓ $($proj.ProjectCode) - $($proj.ProjectName)" -ForegroundColor Green
    $success++
  }
  catch {
    Write-Host "  [$count/20] ✗ $($proj.ProjectCode) - エラー: $($_.Exception.Message)" -ForegroundColor Red
    $failed++
  }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  登録完了" -ForegroundColor Cyan
Write-Host "  成功: $success 件" -ForegroundColor Green
Write-Host "  失敗: $failed 件" -ForegroundColor $(if($failed -gt 0){'Red'}else{'Green'})
Write-Host "========================================`n" -ForegroundColor Cyan

# 登録結果を確認
Write-Host "登録されたプロジェクト一覧:" -ForegroundColor Yellow
$items = Get-PnPListItem -List $ProjectMaster -Fields "ProjectCode","ProjectName","BudgetProcFlag" | 
  Sort-Object -Property @{Expression={$_.FieldValues.ProjectCode}} |
  Select-Object -First 20

foreach ($item in $items) {
  $code = $item.FieldValues.ProjectCode
  $name = $item.FieldValues.ProjectName
  $flag = $item.FieldValues.BudgetProcFlag
  Write-Host "  - $code : $name [$flag]" -ForegroundColor Gray
}

Write-Host "`n✅ サンプルデータ登録完了！" -ForegroundColor Green
