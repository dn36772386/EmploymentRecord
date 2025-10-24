# SharePoint Online リスト管理ツール

SharePoint Online のリストからスキーマやカスタム書式を吸い出し、新しいリストへ展開するための PowerShell スクリプト一式です。

## 前提条件

- PowerShell 7.x (pwsh)
- PnP.PowerShell モジュール
  ```powershell
  Install-Module PnP.PowerShell -Scope CurrentUser
  ```

## 設定

[`config.ps1`](config.ps1) を編集：

```powershell
$SiteUrl      = 'https://tf1980.sharepoint.com/sites/abeam'
$TenantId     = '06fc33a9-9a64-4306-9557-34d54b0a0aaf'
$ClientId     = '46c6f234-4c52-4872-abb9-036254518457'
```

## リスト構成

### EMP_1_Projects（14フィールド）

プロジェクトマスタ。Title は「PRJ001 - プロジェクト名」形式。

| 表示名 | InternalName | 型 | 備考 |
|--------|-------------|-----|------|
| プロジェクトコード | ProjectCode | Text | 一意、インデックス付き |
| プロジェクト名 | ProjectName | Text | |
| 目的（予算）コード | PurposeBudgetCode | Text | |
| 目的（予算）名称 | PurposeBudgetName | Text | |
| 目的（執行）コード | PurposeExecCode | Text | |
| 目的（執行）名称 | PurposeExecName | Text | |
| 部門コード | DeptCode | Text | |
| 部門名称 | DeptName | Text | |
| 財源コード | FundingCode | Text | |
| 財源名称 | FundingName | Text | |
| 有効期限 | ValidUntil | DateTime | 「無」の場合は空欄 |
| 予算財会処理 | BudgetProcFlag | Choice | 済, 未 |
| 備考 | Notes | Note | |

### EMP_1_EmploymentRecords（47フィールド）

雇用調書。以下の分類で構成：

#### 申請基本情報（7フィールド）

| 表示名 | InternalName | 型 | 備考 |
|--------|-------------|-----|------|
| 採用理由 | EmploymentReason | Choice | 新規, 更新(変更あり) |
| 職員番号 | EmployeeID | Number | 例：1001001 |
| 氏名 | FullName | Text | 例：サンプル 太郎 |
| フリガナ | Furigana | Text | 全角カナ |
| 生年月日 | BirthDate | DateTime | |
| 所属 | Department | Choice | 人事課, 研究支援課, 財務課, 情報基盤課 |
| 担当グループ | GroupName | Text | 例：第1G |

#### 管理体制（2フィールド）

| 表示名 | InternalName | 型 | 備考 |
|--------|-------------|-----|------|
| 雇用責任者 | EmploymentOwner | User | 所属長 |
| 事務担当者 | AdministrativeClerk | User | 実務担当 |

#### 個人情報（8フィールド）

| 表示名 | InternalName | 型 | 備考 |
|--------|-------------|-----|------|
| 性別 | Gender | Choice | 男, 女 |
| 住所 | Address | Text | |
| 郵便番号 | PostalCode | Text | 例：100-0001 |
| 本人連絡先 | ContactNumber | Text | 電話・メール |
| 国籍 | Nationality | Text | 例：日本国 |
| 在留資格 | ResidenceStatus | Text | 外国籍の場合 |
| 在留期限 | ResidenceLimit | DateTime | 外国籍の場合 |
| 資格外活動許可 | WorkPermit | Choice | 有, 無 |

#### 雇用情報（6フィールド）

| 表示名 | InternalName | 型 | 備考 |
|--------|-------------|-----|------|
| 区分 | EmploymentType | Choice | フルタイム, パートタイム |
| 職種 | JobTitle | Text | 例：研究員A |
| 契約期間開始 | StartDate | DateTime | |
| 契約期間終了 | EndDate | DateTime | |
| 更新上限有無 | RenewalFlag | Choice | 有, 無 |
| 更新上限日 | RenewalLimit | DateTime | |

#### 勤務情報（10フィールド）

| 表示名 | InternalName | 型 | 備考 |
|--------|-------------|-----|------|
| 勤務場所 | WorkLocation | Text | 例：サンプルキャンパス 人事課 |
| 業務内容 | WorkDescription | Note | 複数行テキスト |
| 業務内容の変更範囲 | WorkChangeScope | Choice | 変更なし, 業務拡大, 業務縮小 |
| 勤務日数（週） | WorkDays | Number | 例：5 |
| 勤務曜日 | WorkWeekdaysChoice | MultiChoice | 月, 火, 水, 木, 金, 土, 日 |
| 休日 | HolidaysChoice | MultiChoice | 月, 火, 水, 木, 金, 土, 日 |
| 勤務開始時刻 | StartTime | DateTime | 例：9:00 |
| 勤務終了時刻 | EndTime | DateTime | 例：17:15 |
| 休憩時間 | BreakTime | Text | 例：12:00〜12:45 |
| 1日勤務時間 | DailyWorkHours | Number | 例：7.5（時間） |

#### 賃金情報（2フィールド）

| 表示名 | InternalName | 型 | 備考 |
|--------|-------------|-----|------|
| 賃金形態 | PayType | Choice | 月給, 時給, 日給 |
| 賃金単価 | PayRate | Number | 例：1700 |

#### 財源情報（4フィールド）

| 表示名 | InternalName | 型 | 備考 |
|--------|-------------|-----|------|
| 雇用財源 | FundingType | Choice | 人事課人件費, 外部資金, その他 |
| プロジェクト | ProjectCodeLookup | LookupMulti | → EMP_1_Projects.Title（複数選択） |
| 執行見込み総額 | ExpenseEstimate | Currency | |
| 人件費番号 | HRExpenseCode | Text | 例：SR000000 |

#### 承認設定（2フィールド）

| 表示名 | InternalName | 型 | 備考 |
|--------|-------------|-----|------|
| 第1段承認者（部門） | Stage1Approvers | UserMulti | 複数可 |
| 第2段承認者（管理部門） | Stage2Approvers | UserMulti | 複数可 |

#### 承認ステータス（7フィールド）

| 表示名 | InternalName | 型 | 備考 |
|--------|-------------|-----|------|
| 全体承認状態 | OverallApproval | Text | 未申請/第1段承認待ち/第2段承認待ち/承認完了/差戻し |
| 申請日時 | SubmittedDate | DateTime | 申請された日時 |
| 第1段承認ステータス | Stage1ApprovalStatus | Choice | 未申請/申請中/承認/却下/差戻し |
| 第1段承認コメント | Stage1ApprovalComment | Note | 承認者のコメント |
| 第1段承認日時 | Stage1ApprovalDate | DateTime | 承認/却下された日時 |
| 第2段承認ステータス | Stage2ApprovalStatus | Choice | 未申請/申請中/承認/却下/差戻し |
| 第2段承認コメント | Stage2ApprovalComment | Note | 承認者のコメント |
| 第2段承認日時 | Stage2ApprovalDate | DateTime | 承認/却下された日時 |

#### 管理補助（1フィールド）

| 表示名 | InternalName | 型 | 備考 |
|--------|-------------|-----|------|
| 備考 | Remarks | Note | 特記事項 |

## ビュー

### EmploymentRecords（雇用調書）

- **すべてのアイテム**（既定、14フィールド）- 一覧表示
- **雇用調書詳細**（32フィールド）- 詳細表示

### Projects（プロジェクトマスタ）

- **プロジェクト一覧**（EMP_1_Projects、16フィールド）

## ディレクトリ構造

```
sp-tools/
├── README.md                    # このファイル
├── config.ps1                   # 設定ファイル
├── connect.ps1                  # SharePoint接続
├── reorganize-files.ps1         # ファイル整理スクリプト
│
├── scripts/                     # 実行スクリプト
│   ├── setup/                   # リスト作成・初期設定
│   ├── data/                    # データ投入・更新・削除
│   ├── views/                   # ビュー作成・更新
│   ├── export/                  # スキーマ・書式エクスポート
│   └── verify/                  # 検証・確認
│
├── json-formats/                # JSON列書式ファイル
├── docs/                        # ドキュメント
└── output/                      # 出力ファイル
    ├── designs/                 # リスト設計書
    └── schemas/                 # スキーマ・書式JSON/CSV
```

## スクリプト一覧

### セットアップ (scripts/setup/)

| ファイル | 説明 |
|---------|------|
| `run-all.ps1` | 3リスト一括作成 |
| `create-projects.ps1` | プロジェクトマスタ作成 |
| `scaffold-list.ps1` | 雇用調書リスト作成（全フィールド） |
| `create-approvals-list.ps1` | 承認履歴リスト作成 |
| `add-approval-fields-to-employment.ps1` | 承認フィールド追加 |
| `setup-project-lookup-complete.ps1` | **全データ一括投入（推奨）** |

### データ管理 (scripts/data/)

| ファイル | 説明 |
|---------|------|
| `insert-sample-projects.ps1` | プロジェクトマスタのみ投入 |
| `insert-sample-employment-records-v2.ps1` | 雇用記録のみ投入 |
| `refresh-project-data.ps1` | プロジェクトデータ再投入 |
| `refresh-employment-data.ps1` | 雇用記録データ再投入 |
| `update-approval-status.ps1` | 承認ステータス更新 |

### ビュー管理 (scripts/views/)

| ファイル | 説明 |
|---------|------|
| `rebuild-employment-views.ps1` | 雇用調書ビュー再作成 |
| `create-view-projects.ps1` | プロジェクト一覧ビュー作成 |

### エクスポート (scripts/export/)

| ファイル | 説明 |
|---------|------|
| `export-all-lists.ps1` | **全リスト設計書を一括出力（1回の認証）** |
| `export-list-design.ps1` | 単一リスト設計書出力 |
| `export-schema.ps1` | スキーマCSV/JSON出力 |
| `export-format.ps1` | 列書式JSON出力 |

### 確認・検証 (scripts/verify/)

| ファイル | 説明 |
|---------|------|
| `check-lists.ps1` | 全リスト確認 |
| `verify-fields.ps1` | フィールド一覧 |
| `verify-all-views.ps1` | ビュー情報確認 |

### JSON書式ファイル (json-formats/)

| ファイル | 説明 | 適用先 |
|---------|------|--------|
| `employment-approval-column-format.json` | 承認ステータス詳細表示 | EMP_1_EmploymentRecords.OverallApproval |
| `employment-approval-buttons.json` | 承認アクションボタン | EMP_1_EmploymentRecords.Title（または任意の列） |
| `approvals-json-settings.json` | 承認リスト設定 | - |

### ドキュメント (docs/)

| ファイル | 説明 |
|---------|------|
| `EMPLOYMENT_APPROVAL_SETUP.md` | 承認ワークフロー設定ガイド |
| `POWER_AUTOMATE_SETUP.md` | Power Automate連携ガイド |

## サンプルデータ投入

### 全データ一括投入（推奨）

```bash
pwsh -File ./scripts/setup/setup-project-lookup-complete.ps1
```

このスクリプトは以下を順次実行します：
1. プロジェクトマスタへのサンプルデータ投入（10件）
2. 雇用記録へのサンプルデータ投入（10件）

### 承認機能の設定

```bash
# 承認フィールドを雇用記録に追加
pwsh -File ./scripts/setup/add-approval-fields-to-employment.ps1

# ランダムな承認ステータスを設定
pwsh -File ./scripts/data/update-approval-status.ps1
```

### 個別投入

```bash
# プロジェクトマスタのみ
pwsh -File ./scripts/data/insert-sample-projects.ps1

# 雇用記録のみ（プロジェクトマスタが必要）
pwsh -File ./scripts/data/insert-sample-employment-records-v2.ps1
```

## リスト設計書の出力

### 全リスト一括出力（推奨）

```bash
pwsh -File ./scripts/export/export-all-lists.ps1
```

**1回の認証**で全リスト（EMP_1_EmploymentRecords, EMP_1_Projects, EMP_1_EmploymentApprovals）の設計書を出力します。

出力先: `output/designs/`

**出力内容**:
- **リスト基本情報**（バージョン管理、権限設定、ListExperienceなど）
- **全フィールド詳細**:
  - 型、必須、選択肢、Lookup情報
  - 既定値、Hidden、ReadOnly
  - **列レベルのJSON書式（CustomFormatter）** ✨
- **カスタムアクション（コマンドバー）**:
  - CommandUIExtension (XML)
  - SPFx拡張機能 (ClientSideComponent)
- **ビュー詳細設定**:
  - ビュータイプ、既定ビュー、個人用、非表示
  - 行数制限、ページング、スコープ
  - 表示列一覧
  - ViewQuery (CAML)
  - 集計、グループ化、並び順 (XML)
  - **JSON書式（CustomFormatter、RowFormatter、Header/Footer）** ✨

### 個別リスト出力

```bash
# config.ps1 の $SrcList を編集してから実行
pwsh -File ./scripts/export/export-list-design.ps1
```

## JSON列書式設定

### 承認ステータス詳細表示（OverallApproval列）

`EMP_1_EmploymentRecords`リストの`OverallApproval`列に以下の設定を適用：

1. リストで列設定を開く
2. 「列の書式設定」→「詳細モード」
3. `json-formats/employment-approval-column-format.json`の内容をコピー

**表示される情報**：
- 全体承認状態（未申請/第1段承認待ち/第2段承認待ち/承認完了/差戻し）
- 申請日時
- 第1段承認ステータス、コメント、日時
- 第2段承認ステータス、コメント、日時

### 承認アクションボタン（Title列またはカスタム列）

`EMP_1_EmploymentRecords`リストの`Title`列（または任意の列）に`json-formats/employment-approval-buttons.json`を適用：

1. リストで列設定を開く
2. 「列の書式設定」→「詳細モード」
3. `json-formats/employment-approval-buttons.json`の内容をコピー
4. 各`YOUR_*_FLOW_ID`を実際のPower AutomateフローIDに置き換え
   - `YOUR_SUBMIT_FLOW_ID` → 申請フローのID
   - `YOUR_STAGE1_APPROVE_FLOW_ID` → 第1段承認フローのID
   - `YOUR_STAGE1_REJECT_FLOW_ID` → 第1段却下フローのID
   - `YOUR_STAGE2_APPROVE_FLOW_ID` → 第2段承認フローのID
   - `YOUR_STAGE2_REJECT_FLOW_ID` → 第2段却下フローのID

**表示されるボタン**：
- 未申請/差戻し状態：「申請」ボタン
- 第1段申請中：「第1段承認」「第1段却下」ボタン
- 第2段申請中：「第2段承認」「第2段却下」ボタン

## Power Automate 連携

詳細は [`docs/POWER_AUTOMATE_SETUP.md`](docs/POWER_AUTOMATE_SETUP.md) を参照してください。

### 必要なフロー

1. **申請提出フロー** - 申請ボタン押下時
2. **承認フロー** - 承認ボタン押下時
3. **却下フロー** - 却下ボタン押下時
4. **差戻しフロー** - 差戻しボタン押下時（オプション）

### フローIDの設定

Power Automateでフローを作成後、以下の手順でIDを取得：

1. Power Automateで対象フローを開く
2. ブラウザのURLから以下の形式を探す：
   ```
   https://make.powerautomate.com/environments/{環境ID}/flows/{フローID}/...
   ```
3. `{フローID}`部分をコピー
## Power Automate 連携

詳細な設定方法は [`docs/EMPLOYMENT_APPROVAL_SETUP.md`](docs/EMPLOYMENT_APPROVAL_SETUP.md) を参照してください。

### 必要なフロー

1. **雇用記録申請フロー** - 申請ボタンから起動、第1段承認者へメール送信
2. **第1段承認フロー** - 承認コメント入力、第2段承認者へメール送信
3. **第1段却下/差戻しフロー** - 却下理由入力、申請者へメール送信
4. **第2段承認フロー** - 承認コメント入力、申請者へ完了メール送信
5. **第2段却下/差戻しフロー** - 却下理由入力、申請者へメール送信

### JSON書式へのFlow ID設定

1. Power Automateでフローを作成
2. フローのURLから`environments/{環境ID}/flows/{フローID}`の`{フローID}`部分をコピー
3. `json-formats/employment-approval-buttons.json`内の該当部分を置き換え
4. JSON書式をSharePointリストに適用

### トリガー条件例

**第1段承認待ち時**:
```javascript
@equals(triggerOutputs()?['body/Stage1ApprovalStatus'],'申請中')
```

**第2段承認待ち時**:
```javascript
@equals(triggerOutputs()?['body/Stage2ApprovalStatus'],'申請中')
```

**承認完了時**:
```javascript
@equals(triggerOutputs()?['body/OverallApproval'],'承認完了')
```

## トラブルシューティング

### ログインエラーが繰り返される

統合スクリプトを使用：

```bash
# ✅ 1回のログイン
pwsh -File ./scripts/setup/setup-project-lookup-complete.ps1
```

### ビューが壊れている

```bash
pwsh -File ./scripts/views/rebuild-employment-views.ps1
```

### データをリセット

```bash
# プロジェクトデータのみ削除して再投入
pwsh -File ./scripts/data/refresh-project-data.ps1

# 雇用記録データのみ削除して再投入
pwsh -File ./scripts/data/refresh-employment-data.ps1
```

### JSON書式が反映されない

1. ブラウザのキャッシュをクリア
2. SharePointリストをリフレッシュ
3. JSON構文エラーがないか確認（JSON Linterを使用）

## ライセンス

MIT

## 作成者

Employment Record プロジェクトチーム
