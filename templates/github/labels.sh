#!/usr/bin/env bash
# リポジトリに必要なラベルを一括で作成・更新する。
# 使い方: ./labels.sh [OWNER/REPO]   (省略時はカレントのリポジトリ)
# 前提:   gh CLI でログイン済みであること (gh auth login)
# 備考:   --force を付けているため、何度実行しても同じ結果になる(既存ラベルは更新)。
set -euo pipefail

REPO_ARGS=()
if [[ $# -ge 1 ]]; then
  REPO_ARGS=(--repo "$1")
fi

# 名前|色(#なし)|説明
LABELS=(
  # Issue テンプレート用
  "bug|d73a4a|不具合"
  "enhancement|a2eeef|機能要望・改善"
  "question|d876e3|質問"
  # release-drafter のカテゴリ用
  "feature|0e8a16|新機能"
  "style|c5def5|コードスタイルの変更"
  "refactor|fbca04|リファクタリング"
  "test|bfd4f2|テストの追加・修正"
  "performance|f9d0c4|パフォーマンス改善"
  "documentation|0075ca|ドキュメント"
  "dependencies|0366d6|依存関係の更新"
  "chore|ededed|雑務・メンテナンス"
  "removed|b60205|機能・コードの削除"
  "github|000000|.github 配下の変更"
  # release-drafter のバージョン判定用
  "major|b60205|メジャーバージョンを上げる"
  "minor|1d76db|マイナーバージョンを上げる"
  "patch|5319e7|パッチバージョンを上げる"
)

for entry in "${LABELS[@]}"; do
  IFS='|' read -r name color description <<< "$entry"
  gh label create "$name" --color "$color" --description "$description" --force ${REPO_ARGS[@]+"${REPO_ARGS[@]}"}
done

echo "完了: ${#LABELS[@]} 件のラベルを作成・更新しました"
