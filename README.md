# Docs Template Index

このリポジトリには、要件定義から設計・仕様・運用・組織まで、開発プロジェクトで用いる各種ドキュメントのテンプレートが格納されています。テンプレートを使用する際は、必ずプロジェクト実態に合わせてカスタマイズしてください。

VS Code の拡張機能でこれらのMarkdownを統一体裁のPDFへ出力できるよう設定済みです（手順は [PDF化ガイド](guideline/pdf-export.md) を参照）。

---

## テンプレート一覧

### 要件定義・設計

| ファイル | 用途 |
|----------|------|
| [`design/Requirements_Definition_Document_TEMPLATE.md`](design/Requirements_Definition_Document_TEMPLATE.md) | 要件定義書テンプレート |
| [`design/Basic_Design_Document_TEMPLATE.md`](design/Basic_Design_Document_TEMPLATE.md) | 基本設計書テンプレート |
| [`design/Detailed_Design_Document_TEMPLATE.md`](design/Detailed_Design_Document_TEMPLATE.md) | 詳細設計書テンプレート |
| [`design/design_documents_guide.md`](design/design_documents_guide.md) | 要件定義・基本設計・詳細設計・仕様書の使い分けガイド |

### 内部仕様書

| ファイル | 用途 |
|----------|------|
| [`spec/TEMPLATE_INTERNAL_SPECIFICATION_BACKEND.md`](spec/TEMPLATE_INTERNAL_SPECIFICATION_BACKEND.md) | バックエンド（サーバー側）内部仕様書 |
| [`spec/TEMPLATE_INTERNAL_SPECIFICATION_FRONTEND.md`](spec/TEMPLATE_INTERNAL_SPECIFICATION_FRONTEND.md) | フロントエンド内部仕様書（UI/UX・状態管理など） |
| [`spec/TEMPLATE_INTERNAL_SPECIFICATION_ANDROID_APP.md`](spec/TEMPLATE_INTERNAL_SPECIFICATION_ANDROID_APP.md) | Android アプリ内部仕様書 |

### 運用・アーキテクチャ・組織

| ファイル | 用途 |
|----------|------|
| [`operation/TEMPLATE_OPERATION.md`](operation/TEMPLATE_OPERATION.md) | 運用手順テンプレート（日常運用・監視・インシデント対応） |
| [`TEMPLATE_ROOT_README.md`](TEMPLATE_ROOT_README.md) | プロジェクトルート用 README テンプレート（ルート直下） |
| [`architecture/Architecture.md`](architecture/Architecture.md) | アーキテクチャドキュメント（技術スタック・構成原則） |
| [`architecture/adr_guideline.md`](architecture/adr_guideline.md) | ADR（アーキテクチャ決定記録）作成ガイドライン |
| [`guideline/logging-convention.md`](guideline/logging-convention.md) | ログ設計ガイドライン（OpenTelemetry / ECS） |
| [`observability/tools.md`](observability/tools.md) | 監視基盤ツールリスト（OpenTelemetry + Grafana） |
| [`organization/Team_Topologies.md`](organization/Team_Topologies.md) | チームトポロジー（組織設計）テンプレート |

---

## ディレクトリ構成

```text
.
├── README.md                                     # 本ファイル（インデックス）
├── TEMPLATE_ROOT_README.md                       # プロジェクトルート用README（分類が曖昧なためルート直下）
├── design/                                       # 要件定義・設計書テンプレート
│   ├── Requirements_Definition_Document_TEMPLATE.md
│   ├── Basic_Design_Document_TEMPLATE.md
│   ├── Detailed_Design_Document_TEMPLATE.md
│   └── design_documents_guide.md                 # 各設計文書の使い分けガイド
├── spec/                                         # 内部仕様書テンプレート・各種仕様の格納先
│   ├── TEMPLATE_INTERNAL_SPECIFICATION_BACKEND.md
│   ├── TEMPLATE_INTERNAL_SPECIFICATION_FRONTEND.md
│   └── TEMPLATE_INTERNAL_SPECIFICATION_ANDROID_APP.md
├── operation/                                    # 運用ドキュメント
│   └── TEMPLATE_OPERATION.md                      # 運用手順
├── architecture/                                 # アーキテクチャ関連
│   ├── Architecture.md
│   ├── adr_guideline.md
│   └── adr/                                       # 個別ADRの格納先
├── guideline/                                     # 各種ガイドライン
│   ├── logging-convention.md
│   └── pdf-export.md                              # VS Code拡張機能でのPDF化手順
├── observability/tools.md                         # 監視ツールリスト
├── organization/Team_Topologies.md                # 組織設計
├── css/                                           # PDF出力用スタイル
│   ├── cover-style.css
│   └── page-style.css
├── images/                                        # ドキュメント貼付画像の保存先
├── output/                                        # PDF出力先
├── sow/                                           # SOW（作業範囲記述書）格納先
└── .vscode/                                       # PDF出力・Lint等の設定
    ├── extensions.json
    └── settings.json
```

---

## PDF化（VS Code 拡張機能）

各Markdownは VS Code 拡張機能 **Markdown PDF**（`yzane.markdown-pdf`）で、表紙・スタイル・Mermaid図込みのPDFへ出力できます。設定は [`.vscode/`](.vscode/) に同梱済みです。

- 手順・設定の詳細 → **[VS Code 拡張機能によるPDF化ガイド](guideline/pdf-export.md)**
- ざっくり手順:
  1. 本リポジトリを VS Code でフォルダとして開き、推奨拡張機能をインストールする。
  2. 対象の `.md` を開き、コマンドパレットで `Markdown PDF: Export (pdf)` を実行する。
  3. `output/` にPDFが生成される。

---

## 運用フロー

1. **要件変更・新規機能の検討**
   - 要件定義書／各設計書テンプレートをコピーし、機能仕様・UI・運用手順などを更新します。

2. **設計判断の確定**
   - アーキテクチャに影響する判断がある場合は `architecture/adr/` 配下で ADR を作成（テンプレートは [`architecture/adr_guideline.md`](architecture/adr_guideline.md) を参照）。
   - ドラフト段階でステークホルダーと合意形成し、確定後にステータスを `Accepted` に更新します。

3. **全体アーキテクチャの更新**
   - ADRで採択した内容を [`architecture/Architecture.md`](architecture/Architecture.md) に反映し、現行構成との差分を明記します。
   - 反映時には変更日・担当者を明記し、必要に応じて関連セクションの図や表を更新します。

4. **運用ドキュメントの整備**
   - 日常運用や監視体制に変更がある場合は [`operation/TEMPLATE_OPERATION.md`](operation/TEMPLATE_OPERATION.md) をベースにした運用ドキュメントを更新し、関連Runbookへのリンクを整備します。

---

## ドキュメント初回チェックリスト

- [ ] テンプレートの書式をプロジェクト仕様に合わせて更新したか
- [ ] `architecture/Architecture.md` の最新化とバージョン記載を行ったか
- [ ] 必要なADRを作成／更新したか（`architecture/adr/ADR-XXX-title.md`）
- [ ] 運用手順ドキュメント（`operation/TEMPLATE_OPERATION.md` を基に作成）を用意したか
- [ ] 関連テンプレート（監視、組織など）を用意したか
- [ ] PDF出力が正しく行えるか（[PDF化ガイド](guideline/pdf-export.md) 参照）を確認したか
- [ ] 更新内容をチームに共有し、コードと同様にレビューを受けたか

---

## ファイル整理ポリシー

- 体裁が大きく変わった場合や過去版を参照する必要がある場合は、旧版を別ディレクトリ（例: `archive/`）に保管してください。
- ドキュメントはGitでバージョン管理されるため、著者と変更履歴を明記しておくとレビューがスムーズになります。
- 大型ドキュメントはテンプレート末尾の指示に従い分割し、目次や索引を更新してください。
