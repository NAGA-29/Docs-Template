# Docs Template

開発プロジェクトで使うドキュメントの **テンプレート** と **ガイドライン** をまとめたリポジトリです。

| 区分 | 置き場所 | 使い方 |
|------|----------|--------|
| テンプレート | [`templates/`](templates/) | プロジェクトへ **コピーして埋める** ひな形。工程順に番号を振っています。 |
| ガイドライン | [`guidelines/`](guidelines/) | **読んで従う / 確認に使う** 規約・チェックリスト・解説。テーマ別に分けています。 |

テンプレートは必ずプロジェクトの実態に合わせてカスタマイズしてください。
Markdown は VS Code 拡張機能で統一体裁の PDF に出力できます（→ [PDF化ガイド](guidelines/documentation/pdf_export.md)）。

---

## どの場面で何を使うか

| 場面 | 使うもの |
|------|----------|
| どの文書を書けばよいか迷った | [設計文書の使い分けガイド](guidelines/documentation/document_types_guide.md) |
| 新規プロジェクトを立ち上げる | [プロジェクト README](templates/00_project/project_readme.md) / [GitHub テンプレート](templates/github/README.md) |
| 顧客・関係者と要望を整理する | [要求定義書](templates/01_requirements/requirement_analysis.md) + [要件確認チェックリスト](guidelines/requirements/requirements_checklist.md) |
| 要件を確定させる・見積もる | [要件定義書](templates/01_requirements/requirements_definition.md) + [要件確認チェックリスト](guidelines/requirements/requirements_checklist.md) |
| 設計する | [基本設計書](templates/02_design/basic_design.md) → [詳細設計書](templates/02_design/detailed_design.md) |
| 実装済み機能の仕様を残す | [内部仕様書（Backend / Frontend / Android）](templates/03_spec/) |
| 技術選定・アーキテクチャを決める | [ADR](templates/04_architecture/adr.md)（[書き方](guidelines/documentation/adr_guideline.md)）→ [アーキテクチャ文書](templates/04_architecture/architecture.md) に反映 |
| 既存システムに機能追加・改修する | [変更管理テンプレート一式](templates/05_change/README.md) |
| ログ・監視を設計する | [ログ設計ガイドライン](guidelines/observability/logging_convention.md) / [監視基盤ツールリスト](guidelines/observability/monitoring_tools.md) |
| 負荷試験をする | [負荷試験計画](templates/06_test/stress_test_plan.md) → [試験記録](templates/06_test/test_record.md) |
| 本番公開する | [公開前チェックリスト](guidelines/security/public_release_checklist.md) / [Nginx セキュリティ対策](guidelines/security/nginx_security.md) |
| 運用を始める | [運用手順書](templates/07_operation/operation.md) |

---

## テンプレート一覧（`templates/`）

| 工程 | ファイル | 内容 |
|------|----------|------|
| 00 プロジェクト | [`project_readme.md`](templates/00_project/project_readme.md) | プロジェクトルート用 README |
| | [`team_topologies.md`](templates/00_project/team_topologies.md) | チームトポロジー（組織設計）※未作成 |
| 01 要求・要件 | [`requirement_analysis.md`](templates/01_requirements/requirement_analysis.md) | 要求定義書（なぜ作るか・誰の課題か・成功の定義） |
| | [`requirements_definition.md`](templates/01_requirements/requirements_definition.md) | 要件定義書（機能要件・非機能要件） |
| 02 設計 | [`basic_design.md`](templates/02_design/basic_design.md) | 基本設計書（何を作るか・外からどう見えるか） |
| | [`detailed_design.md`](templates/02_design/detailed_design.md) | 詳細設計書（どう実装するか） |
| 03 仕様 | [`internal_spec_backend.md`](templates/03_spec/internal_spec_backend.md) | バックエンド内部仕様書 |
| | [`internal_spec_frontend.md`](templates/03_spec/internal_spec_frontend.md) | フロントエンド内部仕様書 |
| | [`internal_spec_android.md`](templates/03_spec/internal_spec_android.md) | Android アプリ内部仕様書 |
| 04 アーキテクチャ | [`architecture.md`](templates/04_architecture/architecture.md) | アーキテクチャ文書（現時点の全体像・設計原則） |
| | [`adr.md`](templates/04_architecture/adr.md) | ADR（アーキテクチャ決定記録）1件分 |
| 05 変更管理 | [`README.md`](templates/05_change/README.md) | 規模別の使い分け |
| | [`01_change_request.md`](templates/05_change/01_change_request.md) | 変更要求書 |
| | [`02_change_requirements.md`](templates/05_change/02_change_requirements.md) | 変更要件定義書 |
| | [`03_impact_analysis.md`](templates/05_change/03_impact_analysis.md) | 影響調査書 |
| | [`04_change_specification.md`](templates/05_change/04_change_specification.md) | 変更仕様書（小〜中規模を1ファイルで） |
| 06 テスト | [`stress_test_plan.md`](templates/06_test/stress_test_plan.md) | 負荷試験 計画／実施 |
| | [`test_record.md`](templates/06_test/test_record.md) | 試験記録（1回分） |
| 07 運用 | [`operation.md`](templates/07_operation/operation.md) | 運用手順書（日常運用・監視・インシデント対応） |
| GitHub | [`github/`](templates/github/README.md) | `.github/` 用 Issue / PR / リリーステンプレート、ラベル作成スクリプト |

## ガイドライン一覧（`guidelines/`）

| テーマ | ファイル | 内容 |
|--------|----------|------|
| ドキュメント運用 | [`document_types_guide.md`](guidelines/documentation/document_types_guide.md) | 要件定義・設計・仕様書・差分資料・ADR の役割と更新ルール |
| | [`adr_guideline.md`](guidelines/documentation/adr_guideline.md) | ADR の位置付けと運用 |
| | [`pdf_export.md`](guidelines/documentation/pdf_export.md) | VS Code 拡張機能による PDF 化手順 |
| 要件 | [`requirements_checklist.md`](guidelines/requirements/requirements_checklist.md) | 要件確認チェックリスト（共通機能・非機能・見積対象・ヒアリング観点） |
| 可観測性 | [`logging_convention.md`](guidelines/observability/logging_convention.md) | ログ設計ガイドライン（OpenTelemetry / ECS） |
| | [`monitoring_tools.md`](guidelines/observability/monitoring_tools.md) | 監視基盤ツールリスト（OpenTelemetry + Grafana） |
| セキュリティ | [`public_release_checklist.md`](guidelines/security/public_release_checklist.md) | Web サービス公開前チェックリスト |
| | [`nginx_security.md`](guidelines/security/nginx_security.md) | Nginx で導入できるセキュリティ対策 |

---

## ディレクトリ構成

```text
.
├── README.md                  # 本ファイル（索引）
├── templates/                 # コピーして使うテンプレート（工程順）
│   ├── 00_project/
│   ├── 01_requirements/
│   ├── 02_design/
│   ├── 03_spec/
│   ├── 04_architecture/
│   ├── 05_change/
│   ├── 06_test/
│   ├── 07_operation/
│   └── github/                # .github/ と同じ構成
├── guidelines/                # 読んで従うガイドライン（テーマ別）
│   ├── documentation/
│   ├── requirements/
│   ├── observability/
│   └── security/
├── css/                       # PDF 出力用スタイル
├── images/                    # 文書に貼り付けた画像の保存先（自動）
├── output/                    # PDF 出力先（Git 管理外）
└── .vscode/                   # PDF 出力・Lint 等の設定
```

---

## ドキュメント運用の流れ

1. **要求・要件を固める** — 要求定義書 → 要件定義書。抜け漏れは要件確認チェックリストで確認する。
2. **設計する** — 基本設計書 → 詳細設計書。実装後は内部仕様書を「現在の正」として最新化する。
3. **設計判断を記録する** — アーキテクチャに影響する判断は ADR を作成し、合意後に `Accepted` へ更新。採択内容を アーキテクチャ文書 に反映する。
4. **変更する** — 既存システムの改修は `templates/05_change/` を規模に応じて使い、完了後に大本の設計書・仕様書へ反映する。
5. **公開・運用する** — 公開前チェックリストを通し、運用手順書と Runbook を整備する。

詳しい考え方は [設計文書の使い分けガイド](guidelines/documentation/document_types_guide.md) を参照してください。

## このリポジトリへの追加ルール

- **コピーして埋めるもの** は `templates/` の該当工程へ、**読んで従うもの** は `guidelines/` の該当テーマへ置く。
- ファイル名は英小文字の `snake_case.md`。テンプレートには `_template` などの接尾辞を付けない（コピー後そのまま使える名前にする）。
- 追加・移動したら本 README の一覧と「どの場面で何を使うか」を更新する。
