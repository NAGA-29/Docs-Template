# VS Code 拡張機能によるPDF化ガイド

本リポジトリのドキュメント（Markdown）は、VS Code の拡張機能 **Markdown PDF** を使ってPDF出力できるように設定済みです。表紙・ページスタイル・ヘッダー/フッター・Mermaid図の描画までまとめて設定されているため、拡張機能を入れて実行するだけで統一された体裁のPDFが得られます。

- 出力設定は [`.vscode/settings.json`](../.vscode/settings.json) に定義されています。
- 推奨拡張機能は [`.vscode/extensions.json`](../.vscode/extensions.json) に定義されています。
- PDF用スタイルは [`css/cover-style.css`](../css/cover-style.css) / [`css/page-style.css`](../css/page-style.css) に定義されています。

---

## 1. 前提

- [Visual Studio Code](https://code.visualstudio.com/) がインストールされていること。
- 本リポジトリを VS Code の**ワークスペース（フォルダ）として開いている**こと。
  - `.vscode/settings.json` はワークスペースを開いたときにのみ適用されます。単一ファイルだけを開くと設定が効きません。

---

## 2. 推奨拡張機能のインストール

本リポジトリを VS Code で開くと、右下に「推奨拡張機能をインストールしますか？」という通知が表示されます。これを承認すると以下がまとめて導入されます（[`.vscode/extensions.json`](../.vscode/extensions.json)）。

| 拡張機能ID | 名称 | 役割 |
|------------|------|------|
| `yzane.markdown-pdf` | Markdown PDF | **MarkdownをPDF/HTML/PNG等へ出力**（本ガイドの中心） |
| `yzhang.markdown-all-in-one` | Markdown All in One | 目次生成・整形などの編集支援 |
| `davidanson.vscode-markdownlint` | markdownlint | Markdownの文法チェック・自動修正 |
| `bierner.markdown-mermaid` | Markdown Preview Mermaid Support | プレビューでのMermaid図描画 |

手動で入れる場合は、拡張機能ビュー（`Ctrl/Cmd + Shift + X`）で上記IDを検索してインストールしてください。

---

## 3. PDFへの出力手順

1. PDF化したい Markdown ファイル（例: `Requirements_Definition_Document_TEMPLATE.md`）をエディタで開く。
2. コマンドパレットを開く（`Ctrl/Cmd + Shift + P`）。
3. **`Markdown PDF: Export (pdf)`** を実行する。
   - すべての形式を出力したい場合は `Markdown PDF: Export (all)` を実行します（PDF/HTML/PNG/JPEG）。
   - エディタ内で右クリック →「Markdown PDF: Export (pdf)」からでも実行できます。
4. 変換が完了すると、[`output/`](../output/) ディレクトリに `（ファイル名）.pdf` が生成されます。

> 初回実行時は Markdown PDF が内部で Chromium をダウンロードするため、数分かかることがあります。

---

## 4. 本リポジトリのPDF設定（`.vscode/settings.json`）

このリポジトリでは、体裁を統一するため以下の `markdown-pdf.*` 設定を行っています。主要な項目のみ抜粋します。

| 設定キー | 値 | 意味 |
|----------|----|------|
| `markdown-pdf.outputDirectory` | `output` | PDFの出力先を `output/` に固定 |
| `markdown-pdf.styles` | `../css/cover-style.css`, `../css/page-style.css` | 表紙・本文スタイルを適用 |
| `markdown-pdf.stylesRelativePathFile` | `true` | スタイルパスを対象ファイルからの相対で解決 |
| `markdown-pdf.includeDefaultStyles` | `false` | 既定スタイルを無効化し、上記CSSのみ適用 |
| `markdown-pdf.breaks` | `true` | 改行（単一の改行）をそのまま反映 |
| `markdown-pdf.margin.top` / `.bottom` | `0cm` / `2cm` | 上下余白（フッター用に下余白を確保） |
| `markdown-pdf.displayHeaderFooter` | `true` | ヘッダー/フッターを表示 |
| `markdown-pdf.footerTemplate` | （ページ番号 + `© SAMPLE`） | フッターに「現在ページ / 総ページ」と著作権表記を表示 |
| `markdown-pdf.mermaidServer` | `mermaid@10.0.3-alpha.1` のCDN | PDF内でMermaid図を描画するためのライブラリ |
| `markdown-pdf.markdown-it-include.enable` | `true` | 外部Markdownの取り込み（インクルード）を有効化 |

> フッターの `© SAMPLE` はサンプル表記です。実プロジェクトでは `markdown-pdf.footerTemplate` 内の文言を組織名などへ変更してください。

---

## 5. Mermaid図について

本リポジトリの各テンプレートは、フローチャートやシーケンス図に [Mermaid](https://mermaid.js.org/) 記法（` ```mermaid ` ブロック）を使用しています。

- **プレビュー表示**には `bierner.markdown-mermaid` が必要です。
- **PDF出力時**の描画は `markdown-pdf.mermaidServer` に指定したCDNを利用します。そのため、**PDF出力時はネットワーク接続が必要**です。オフライン環境では図が描画されないことがあります。

---

## 6. 画像の取り扱い

`.vscode/settings.json` の `markdown.copyFiles.destination` により、エディタへ画像を貼り付け（ペースト）すると、画像は自動的に [`images/`](../images/) 配下（`images/（ドキュメント名）/`）へ保存されます。PDF出力にもこの画像が取り込まれます。

---

## 7. うまくいかないときは

| 症状 | 対処 |
|------|------|
| スタイル（表紙・余白）が反映されない | フォルダ（ワークスペース）としてリポジトリを開いているか確認。単一ファイル起動では `.vscode/settings.json` が効きません。 |
| Mermaid図が空白になる | ネットワーク接続を確認（PDF出力時にCDNからmermaidを取得します）。 |
| PDFが `output/` に出ない | コマンドが `Markdown PDF: Export (pdf)` であること、拡張機能 `yzane.markdown-pdf` が有効であることを確認。 |
| 初回だけ実行が遅い/失敗する | Chromiumの初回ダウンロード中の可能性があります。しばらく待ってから再実行してください。 |

---

## 参考

- Markdown PDF (yzane.markdown-pdf): <https://marketplace.visualstudio.com/items?itemName=yzane.markdown-pdf>
- Mermaid: <https://mermaid.js.org/>
