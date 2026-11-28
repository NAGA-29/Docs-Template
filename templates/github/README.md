# GitHub テンプレート

リポジトリの `.github/` に置いて使う、Issue / PR / リリース関連のテンプレート集。
このフォルダは `.github/` と同じ構成になっているので、そのままコピーして使える。

## 構成

```text
github/
├── ISSUE_TEMPLATE/
│   ├── bug_report.md        不具合報告 (ラベル: bug)
│   ├── feature_request.md   機能要望・改善提案 (ラベル: enhancement)
│   ├── question.md          質問 (ラベル: question)
│   └── config.yml           空 Issue の禁止、外部リンクの設定
├── PULL_REQUEST_TEMPLATE.md PR の説明テンプレート
├── RELEASE_TEMPLATE.md      手動でリリースノートを書く場合のひな形
├── release-drafter.yml      リリースノート自動生成と PR の自動ラベル付けの設定
├── workflows/
│   └── release-drafter.yml  release-drafter を実行する GitHub Actions
├── labels.sh                必要なラベルの一括作成スクリプト
└── README.md                (このファイル。コピー不要)
```

## 使い方

### 1. コピーする

使いたいリポジトリのルートで実行する。

```bash
cp -r /path/to/Docs-Template/templates/github/. .github/
rm .github/README.md .github/labels.sh   # 不要なら削除
```

`labels.sh` と `README.md` は `.github/` に置かなくてもよい。
`RELEASE_TEMPLATE.md` は release-drafter を使う場合は不要なので削除してよい。

### 2. ラベルを作成する

Issue テンプレートの `labels:` は、ラベルが存在しないと付与されない(エラーにもならない)。
最初に一度だけ実行する。

```bash
gh auth login                         # 未ログインの場合
./templates/github/labels.sh OWNER/REPO         # リポジトリを指定
./templates/github/labels.sh                    # カレントのリポジトリ
```

何度実行しても安全。既存ラベルの色と説明は上書きされる。

### 3. プロジェクトに合わせて調整する

| 対象 | 調整する内容 |
| --- | --- |
| `ISSUE_TEMPLATE/config.yml` | `contact_links` のコメントを外して URL を設定する |
| `release-drafter.yml` の `autolabeler` | `docker` など、プロジェクト固有のラベルとパスを追加する |
| `release-drafter.yml` の `categories` | ラベルを追加したら `labels.sh` にも追加する |
| `workflows/release-drafter.yml` | `main` 以外をリリースブランチにする場合は `branches` を変更する |

## release-drafter の動き

1. PR を作ると、ブランチ名と変更ファイルから自動でラベルが付く。
2. `main` にマージされると、ラベルごとに分類したリリースノートの下書きが作られる。
3. バージョンは `major` / `minor` / `patch` ラベルで決まる(指定なしは patch)。
4. GitHub の Releases 画面で下書きを確認して公開する。

### ブランチ名とラベルの対応

PR を作ったとき、**PR 元のブランチ名の先頭部分**を見て、対応するラベルが自動で付く。
ブランチ名は `種類/内容` の形(`/` か `-` で区切る)にしておくと、ラベルが付く。

例: `feat/login-page` というブランチから PR を作ると、`feature` ラベルが付く。

| ブランチ名 | ラベル | 意味・使いどころ |
| --- | --- | --- |
| `feat/xxx`, `feature/xxx` | feature | 新機能の追加 |
| `fix/xxx`, `bugfix/xxx` | bug | 不具合の修正 |
| `enhancement/xxx`, `improve/xxx` | enhancement | 既存機能の改善 |
| `refactor/xxx`, `refactoring/xxx` | refactor | 動作を変えない内部の整理 |
| `docs/xxx`, `doc/xxx`, `documentation/xxx` | documentation | ドキュメントの追加・修正 |
| `chore/xxx` | chore | 設定変更や依存更新などの雑務 |
| `test/xxx` | test | テストの追加・修正 |

- 表の `xxx` は任意の文字列に読み替える(例: `fix/null-pointer`、`docs/update-readme`)。
- 付いたラベルは、`main` へのマージ後に作られるリリースノートで、対応するカテゴリに分類される。
  例: `bug` → 「🐛 Bug Fixes」、`feature` → 「🚀 Features」。
- 上の表に当てはまらないブランチ名(例: `my-branch`)では、ブランチ名からのラベルは付かない。
  その場合は PR にラベルを手動で付けると、リリースノートに反映される。

### 変更ファイルとラベルの対応

ブランチ名とは別に、変更したファイルからもラベルが付く。

| 変更したファイル | ラベル |
| --- | --- |
| `*.md` | documentation |
| `.github/` 配下 | github |

例: ブランチ名が `fix/typo` でも、`README.md` だけを変更していれば、`bug` と `documentation` の両方が付く。

## 注意

- `workflows/release-drafter.yml` の Action はコミット SHA で固定している(サプライチェーン対策)。
  更新は Dependabot で自動化するのがおすすめ。

  ```yaml
  # .github/dependabot.yml
  version: 2
  updates:
    - package-ecosystem: github-actions
      directory: /
      schedule:
        interval: weekly
  ```

- PR テンプレートは `.github/PULL_REQUEST_TEMPLATE.md` に置いたときだけ有効になる。
