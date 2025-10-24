# フォルダ構造整理完了

## 実施内容

sp-toolsディレクトリのファイルを論理的なフォルダ構造に整理しました（2025/10/18）。

## 新しいフォルダ構造

```
sp-tools/
├── README.md                    # メインドキュメント（更新済み）
├── config.ps1                   # 設定ファイル
├── connect.ps1                  # SharePoint接続
├── reorganize-files.ps1         # このフォルダ整理を実行したスクリプト
│
├── scripts/                     # 実行スクリプト
│   ├── setup/                   # リスト作成・初期設定（9ファイル）
│   ├── data/                    # データ投入・更新・削除（14ファイル）
│   ├── views/                   # ビュー作成・更新（5ファイル）
│   ├── export/                  # スキーマ・書式エクスポート（4ファイル）
│   ├── verify/                  # 検証・確認（4ファイル）
│   ├── apply-actions.ps1        # その他ユーティリティ
│   └── create-approval-records-for-employment.ps1
│
├── json-formats/                # JSON列書式ファイル（5ファイル）
│   ├── employment-approval-buttons.json
│   ├── employment-approval-column-format.json
│   ├── approvals-json-settings.json
│   ├── approvals-title-format.json
│   └── submit-button-format.json
│
├── docs/                        # ドキュメント（2ファイル）
│   ├── EMPLOYMENT_APPROVAL_SETUP.md
│   └── POWER_AUTOMATE_SETUP.md
│
└── output/                      # 出力ファイル
    ├── designs/                 # リスト設計書（19ファイル）
    └── schemas/                 # スキーマ・書式JSON/CSV（4ファイル）
```

## 移動したファイル数

- 合計: **69ファイル** を整理
- スキップ: **0ファイル**

## 注意事項

### スクリプト実行時のパス

多くのスクリプトは相対パスで `config.ps1` と `connect.ps1` を読み込んでいるため、**sp-toolsディレクトリから実行**する必要があります：

```bash
# ✅ 正しい実行方法
cd /Users/nakajima/Documents/EmploymentRecord/EmploymentRecord/sp-tools
pwsh -File ./scripts/setup/run-all.ps1

# ❌ サブディレクトリからの実行は非推奨
cd sp-tools/scripts/setup
pwsh -File ./run-all.ps1  # config.ps1が見つからない可能性
```

### パス参照の互換性

ほとんどのスクリプトは `$PSScriptRoot` を使用しているため、自動的に正しいパスを解決します。以下のスクリプトはパス調整済み：

- `scripts/export/export-all-lists.ps1` → 出力先を `output/designs/` に変更済み
- `scripts/export/export-schema.ps1` → 出力先を `output/schemas/` に変更済み
- `scripts/export/export-format.ps1` → 出力先を `output/schemas/` に変更済み

### エクスポート機能の強化（2025/10/18 18:22）

`scripts/export/export-all-lists.ps1` にビュー詳細設定の出力機能を追加：

**追加された出力項目**:
- ビュータイプ、既定ビュー、個人用、非表示フラグ
- 行数制限、ページング、スコープ
- 表示列一覧（フィールド名のリスト）
- ViewQuery (CAML XML)
- 集計設定 (Aggregations XML)
- グループ化設定 (GroupBy XML)
- 並び順設定 (OrderBy XML)
- JSON書式（CustomFormatter、RowFormatter）
- ヘッダー/フッターJSON（環境により利用可能）

### 今後の運用

- 新規スクリプトは適切なサブフォルダに配置
- 出力ファイルは自動的に `output/` 配下に保存
- JSON書式ファイルは `json-formats/` に集約
- ドキュメントは `docs/` に配置

## 元に戻す方法

このフォルダ整理を元に戻したい場合は、以下を実行：

```bash
# 各フォルダから親ディレクトリにファイルを戻す
mv scripts/*/*.ps1 .
mv scripts/*.ps1 .
mv json-formats/*.json .
mv docs/*.md .
```

ただし、**新しい構造のまま使用することを強く推奨**します。
