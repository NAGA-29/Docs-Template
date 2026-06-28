# ログ設計ガイドライン

OpenTelemetry (OTel) ログデータモデル・Semantic Conventions を主軸とし、不足する語彙を Elastic Common Schema (ECS) で補う。
出力形式は JSON Lines。アプリはフラットな JSON を stdout に出力し、バックエンドへの適合（Elasticsearch へのネスト展開、S3/DuckDB へのそのままの積載、Loki へのラベル変換等）は Collector 層（OTel Collector / Fluent Bit）の責務とする。

## 変更履歴

| バージョン | 日付          | 変更内容                                                                                                                                                                                | 作成者   |
| ---------- | ------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| v0.1       | 2026年6月23日 | 初版作成                                                                                                                                                                                | @NAGA-29 |
| v0.2       | 2026年6月25日 | エラー系を OTel 準拠の `exception.*` に変更（旧 `error.*`）／`trace_id` の根拠説明を OTel non-OTLP 形式に訂正／メッセージコードと運用手順書連携（§7）を追加／補足運用ルール（§8）を追加 | @NAGA-29 |
| v0.3       | 2026年6月26日 | ログの種別と適用範囲（§2）を新設。認証/監査/バッチのフィールド群、種別ディスクリミネータ event.category を追加。以降の章を繰り下げ                                                      | @NAGA-29 |
| v0.4       | 2026年6月28日 | フラット原則の理由をバックエンド非依存の構造的根拠に改訂。冒頭前提を「Collector 層がバックエンド適合を担う」に変更。§1 原則 #1 の理由を更新                                             | @NAGA-29 |

---

## 1. 基本原則

| #   | ルール                                                                                            | 理由                                                                                                                                                                                                                                                      |
| --- | ------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | **物理フラット出力**。JSON オブジェクトのネストは原則禁止                                         | フラット→ネスト変換は Collector で容易だが、ネスト→フラットは構造解析が必要でコストがかかる。アプリをフラット固定にすることで、どのバックエンド（ES・DuckDB・BigQuery・Loki 等）へも Collector 側で適合でき、アプリを変えずにバックエンドを切り替えられる |
| 2   | 階層は `domain.attribute` の**ドット名前空間**で表現。意味的な深さに上限は設けない                | ECS/OTel に準拠（`http.request.method` など3階層は普通）                                                                                                                                                                                                  |
| 3   | 実ネスト（実オブジェクト）を許すのは**構造が固定された既知グループのみ**、かつ**実ネスト2層まで** | `exception` のスタックトレースなど少数の例外に蓋をする                                                                                                                                                                                                    |
| 4   | 配列オブジェクト `[{...}, {...}]` は原則禁止                                                      | 検索・集計を著しく悪化させる                                                                                                                                                                                                                              |
| 5   | 記法は**ドット記法に統一**（snake_case との混在禁止）                                             | 表記ゆれを排除                                                                                                                                                                                                                                            |
| 6   | timestamp は **RFC3339 / UTC 固定**                                                               | タイムゾーン起因の事故を防ぐ                                                                                                                                                                                                                              |
| 7   | 1イベント = 1行（JSON Lines）                                                                     | 行単位で集計・分割しやすい                                                                                                                                                                                                                                |
| 8   | アプリは **stdout のみに出力**。ローテーション・収集・transform は Collector 側                   | 12-Factor。出力形式とストレージ形式を分離                                                                                                                                                                                                                 |

> 「フラット原則」が主、「実ネスト2層まで」はその例外側の上限。普段はフラット、どうしても必要な既知グループだけ2層で許容する建て付け。

---

## 2. ログの種別と適用範囲

ログには複数の種別があり、役割・出力元・保持期間・機密度が異なる。**すべて共通スキーマ（§3）の上に乗せ**、種別は `event.category`（必要なら `event.dataset` も併用）で区別する。フィールドの名前空間・型は種別をまたいで共通にする。

### 2.1 適用範囲の線引き

- **本規約の主対象 = アプリケーションが出力するログ**（操作・アクセス・エラー・認証・監査・バッチ）。
- **ミドルウェア/インフラのログ（nginx・apache のアクセスログ、AWS CloudTrail、VPC フローログ等）はフォーマットをアプリ側で制御できない**。これらは「収集・正規化の対象」とし、Collector（Fluent Bit / OTel Collector）側で共通スキーマのキー名へマッピングする。マッピング表は Collector 設定として管理する。
  - 例（nginx → 共通スキーマ）：`remote_addr` → `client.address` ／ `request_method` → `http.request.method` ／ `status` → `http.response.status_code` ／ `body_bytes_sent` → `http.response.body.size` ／ `http_user_agent` → `user_agent.original` ／ `request_time` → `duration_ms`（秒→ミリ秒換算）

### 2.2 種別一覧

| 種別                   | 役割                                              | 主な出力元             | `event.category`            | 主な追加フィールド                                                        | 代表レベル  | 保持・取扱い                   |
| ---------------------- | ------------------------------------------------- | ---------------------- | --------------------------- | ------------------------------------------------------------------------- | ----------- | ------------------------------ |
| アクセスログ（エッジ） | 全 HTTP トラフィックの素の記録                    | nginx / apache / LB    | `web`                       | `http.*`, `url.path`, `client.address`, `user_agent.original`             | INFO        | 短〜中                         |
| アクセスログ（アプリ） | 業務文脈付きのリクエスト記録                      | アプリのミドルウェア層 | `web`                       | 上記 + `trace_id`, `user.id`, `http.route`, `duration_ms`                 | INFO        | 中                             |
| 操作ログ（アプリログ） | ビジネスイベントの記録                            | アプリ                 | ドメインに応じて            | `event.name`, ドメイン固有値                                              | INFO        | 中                             |
| エラーログ             | 例外・処理失敗                                    | アプリ / FW            | （`event.outcome=failure`） | `exception.*`, `message.code`                                             | ERROR       | 中                             |
| 認証 / ログインログ    | 認証イベント（成功/失敗/ログアウト/トークン発行） | 認証層                 | `authentication`            | `auth.method`, `auth.event`, `event.outcome`, `user.id`, `client.address` | INFO / WARN | **長期・改ざん防止・閲覧制限** |
| 監査ログ（Audit）      | 誰が・いつ・何を変更したか                        | アプリ                 | `audit`                     | `actor.id`, `action`, `target.type`, `target.id`, 変更前後                | INFO        | **長期・WORM・閲覧制限**       |
| バッチログ             | バッチ実行の開始/終了/進行/件数                   | バッチ                 | `process`                   | `batch.job_id`, `batch.stats.*`, `duration_ms`                            | INFO        | 中                             |

### 2.3 設計上の要点

- **アクセスログはエッジとアプリで役割分担**：エッジは全量トラフィックの素の記録（`trace_id` を持たないこともある）、アプリは業務文脈（`trace_id` / `user.id` / `http.route`）付き。両者を突き合わせられるよう、可能ならエッジでも `trace_id` を透過させる（リクエストヘッダ経由）。
- **ヘルスチェックのアクセスログは出力しない**（§9）。
- **認証ログ・監査ログはセキュリティ要件が別格**：
  - 一度書いたら変更・削除できない保管（WORM / IAM で write-once）。
  - 閲覧者を必要メンバーに限定。
  - 保持期間を長め（業務・コンプラ要件準拠）に設定し、**通常のアプリログとは別ストリーム / 別バケットに分離**するのが安全。
- **認証ログはブルートフォース等の監視対象**。失敗イベントは必ず `event.outcome=failure` を立て、集計・閾値検知をしやすくする。
- **監査ログの変更前後（before/after）は PII を含みやすい**。マスキング方針（§7）の対象。構造が可変なため、`change.before` / `change.after` を実ネスト許容の既知グループとして扱うか、JSON 文字列で持つかを要審議。

---

## 3. 予約フィールド（全サービス共通・意味と型を固定）

これらは**全ログに必須**。意味・型を変えての再利用を禁止する。

| フィールド        | 型                    | 内容                                                                                                         | 例                         |
| ----------------- | --------------------- | ------------------------------------------------------------------------------------------------------------ | -------------------------- |
| `timestamp`       | string (RFC3339, UTC) | **イベントの発生時刻（オリジンクロック＝処理が起きたサービス自身の時計）。収集時刻・取り込み時刻ではない。** | `2026-06-26T04:21:09.123Z` |
| `level`           | string                | ログレベル文字列                                                                                             | `INFO`                     |
| `severity_number` | int                   | OTel 数値スケール（§6参照）。ロガーが出せない場合は Collector 側で `level` から補完してよい                  | `9`                        |
| `message`         | string                | 人間可読の本文（変数を埋め込まず固定文言に寄せる）                                                           | `request completed`        |
| `message.code`    | string                | 運用手順書と紐づく一意なメッセージコード。**WARN 以上に付与**（INFO は不要）。詳細は §8                      | `PAYMENT-003`              |
| `service.name`    | string                | サービス名                                                                                                   | `motionginko-api`          |
| `service.version` | string                | デプロイ識別（リリース相関に必須）                                                                           | `1.4.2`                    |
| `env`             | string                | 環境                                                                                                         | `prod` / `stg` / `dev`     |
| `event.category`  | string                | **ログ種別ディスクリミネータ**（§2）。`web` / `authentication` / `audit` / `process` 等                      | `web`                      |
| `schema.version`  | string                | このログ規約のバージョン                                                                                     | `0.4`                      |

> **`timestamp` の意味について**：`@` 接頭辞（ECS の `@timestamp`）はクオート必須で事故のもとになるため採用しない。素の `timestamp` を使うが、意味は **「イベント発生時刻（オリジンクロック）」に固定** する。
> 収集時刻・取り込み時刻が必要になった場合は `timestamp` に混ぜず、以下の予約キーを使う（普段は出力不要）。
>
> | フィールド | 型 | 内容 |
> |-----------|-----|------|
> | `observed.timestamp` | string (RFC3339, UTC) | 収集システム（Collector）が観測した時刻。OTel の ObservedTimestamp 相当 |
> | `event.ingested` | string (RFC3339, UTC) | 解析基盤に取り込まれた時刻。ECS 相当 |

---

## 4. 標準ドメインフィールド辞書（許可リスト）

ID・コード類は原則 **string (keyword)**。常に整数のもの（HTTP status 等）のみ int。

### 4.1 トレース相関（OTel non-OTLP 形式でルート直下）

JSON ログでは OTel の non-OTLP ログ形式に従い `trace_id` / `span_id`（アンダースコア）をルート直下に置く。ECS の `trace.id` / `span.id` とは別表記なので混在させない。

| フィールド    | 型     | 内容                 |
| ------------- | ------ | -------------------- |
| `trace_id`    | string | 分散トレース ID      |
| `span_id`     | string | スパン ID            |
| `trace_flags` | string | サンプリングフラグ等 |

### 4.2 HTTP

| フィールド                  | 型     | 内容                         |
| --------------------------- | ------ | ---------------------------- |
| `http.request.method`       | string | `GET` 等                     |
| `http.route`                | string | ルートパターン `/users/{id}` |
| `http.response.status_code` | int    | `200`                        |
| `http.request.body.size`    | int    | バイト数                     |
| `http.response.body.size`   | int    | バイト数                     |
| `url.path`                  | string | 実パス                       |
| `url.query`                 | string | クエリ文字列（PII注意）      |

### 4.3 クライアント / ネットワーク

| フィールド                 | 型     | 内容                       |
| -------------------------- | ------ | -------------------------- |
| `client.address`           | string | クライアント IP（PII注意） |
| `user_agent.original`      | string | UA 文字列                  |
| `network.protocol.version` | string | `1.1` / `2`                |

### 4.4 ユーザー（PII。マスキング方針の対象）

| フィールド  | 型     | 内容            |
| ----------- | ------ | --------------- |
| `user.id`   | string | 内部ユーザー ID |
| `user.role` | string | ロール          |

### 4.5 DB

| フィールド         | 型     | 内容                                                |
| ------------------ | ------ | --------------------------------------------------- |
| `db.system`        | string | `postgresql` / `sqlite`                             |
| `db.operation`     | string | `SELECT` 等                                         |
| `db.statement`     | string | クエリ本文（PII・機密注意。本番は出力可否を要検討） |
| `db.rows_affected` | int    | 影響行数                                            |

### 4.6 例外（OTel `exception.*` 準拠。**実ネスト2層を許容する例外**）

| フィールド              | 型     | 内容                         |
| ----------------------- | ------ | ---------------------------- |
| `exception.type`        | string | 例外クラス / 型名            |
| `exception.message`     | string | エラーメッセージ             |
| `exception.stack_trace` | string | スタックトレース（複数行可） |

エラーの分類・結果を集計したい場合は ECS の event 語彙を拡張として併用する（任意）:

| フィールド      | 型     | 内容                  |
| --------------- | ------ | --------------------- |
| `event.outcome` | string | `success` / `failure` |

### 4.7 認証 / ログイン（`event.category=authentication`）

| フィールド    | 型     | 内容                                                |
| ------------- | ------ | --------------------------------------------------- |
| `auth.method` | string | `password` / `oauth` / `sso` 等                     |
| `auth.event`  | string | `login` / `logout` / `token_issue` / `login_failed` |

※ 主体・送信元・結果は既出の `user.id` / `client.address` / `event.outcome` を流用する。

### 4.8 監査（`event.category=audit`）

| フィールド      | 型              | 内容                                                |
| --------------- | --------------- | --------------------------------------------------- |
| `actor.id`      | string          | 操作主体のユーザー / サービス ID                    |
| `action`        | string          | 操作種別 `create` / `update` / `delete` 等          |
| `target.type`   | string          | 対象リソース種別                                    |
| `target.id`     | string          | 対象リソース ID                                     |
| `change.before` | string / object | 変更前（可変構造。文字列化 or 実ネスト2層を要審議） |
| `change.after`  | string / object | 変更後（同上）                                      |

### 4.9 バッチ（`event.category=process`）

バッチ統計はネストオブジェクトにせず**フラットなドットキー**で持つ（FA ガイドの `batch.stats: {...}` ネストとはここで分岐。物理フラット原則を優先）。

| フィールド            | 型     | 内容         |
| --------------------- | ------ | ------------ |
| `batch.job_id`        | string | ジョブ識別子 |
| `batch.stats.total`   | int    | 総件数       |
| `batch.stats.success` | int    | 成功件数     |
| `batch.stats.failed`  | int    | 失敗件数     |
| `batch.stats.skipped` | int    | スキップ件数 |

### 4.10 ログ発生元

| フィールド      | 型     | 内容         |
| --------------- | ------ | ------------ |
| `log.logger`    | string | ロガー名     |
| `code.function` | string | 関数名       |
| `code.filepath` | string | ファイルパス |
| `code.lineno`   | int    | 行番号       |

### 4.11 イベント / 性能

| フィールド      | 型     | 内容                                                                  |
| --------------- | ------ | --------------------------------------------------------------------- |
| `event.name`    | string | イベント識別名                                                        |
| `event.dataset` | string | データセット識別（`nginx.access` / `app.audit` 等。種別の細分に使用） |
| `duration_ms`   | number | 処理時間（ミリ秒）                                                    |

> ここに無いフィールドを追加する場合は §7 のプロセスに従う。`xxx.id` は string、`xxx.size` / `xxx.count` は int、時間は `*_ms` で number、を既定とする。

---

## 5. カーディナリティ方針

- `user.id` / `trace_id` のような高カーディナリティ値は**属性として出すのは可**だが、メトリクスのラベルやインデックスのファセットには使わない。
- 値の取りうる範囲が無限大になりうるフィールドは、集計軸（GROUP BY 想定）にしない。

---

## 6. ログレベル運用基準（severity_number は OTel 準拠）

| level   | severity_number | 使う場面                                                 |
| ------- | --------------- | -------------------------------------------------------- |
| `DEBUG` | 5               | 開発時の詳細。本番では原則出さない                       |
| `INFO`  | 9               | 正常系の節目（リクエスト完了、ジョブ開始/終了）          |
| `WARN`  | 13              | 異常ではないが注視すべき事象（リトライ、フォールバック） |
| `ERROR` | 17              | 処理失敗。ユーザー影響あり。要対応                       |
| `FATAL` | 21              | プロセス継続不能                                         |

「何を INFO / WARN / ERROR にするか」の判断基準を文書化しておくこと（これが無いと結局カオス化する）。

---

## 7. ガバナンス（フォーマット以外で今決めること）

- **中央フィールド辞書**（本ドキュメント §3–4）をリポジトリで管理。新規フィールド追加は PR レビュー必須。
- **移行表**：既存ログがある場合はスプレッドシートで旧→新フィールド対応を作る（ECS Mapper 的アプローチ）。インフラ/ミドルウェアログの Collector マッピング表（§2.1）もここで一元管理。
- **PII / 機密マスキング方針**：`client.address` `url.query` `db.statement` `user.*` `change.before` `change.after` 等、マスク・出力禁止対象をスキーマ側で明示。
- **schema.version をログに埋める**：将来フォーマットを変えたとき新旧を区別できる。

---

## 8. メッセージコードと運用手順書連携

自然言語のエラーメッセージは表現が揺らぎ、発生箇所で意味も変わるため、運用者が参照する**運用手順書（障害対応マニュアル）と紐づく一意なメッセージコード**を付与する。

- 付与対象は**運用者の対応が必要なレベル（WARN 以上）**。INFO には不要。
- コードは命名規則を設けて一意にする（例 `AUTH-LOGIN-001` / `PAYMENT-003`）。
- 各コードに対し「発生原因」「運用者が取るべきアクション」を別ドキュメント（運用一覧 / 運用手順書）で定義する。
- **ユーザー向けメッセージとログメッセージは必ず分離**する（目的・対象者が異なる。スタックトレースや内部エラー文はユーザーに出さない）。両者を突き合わせられるよう、`trace_id` をユーザー向け表示にも出す。

| 管理項目         | 必須 | 内容                                     |
| ---------------- | ---- | ---------------------------------------- |
| メッセージコード | ✅    | 一意な ID（命名規則あり）                |
| メッセージ       | ✅    | 何が起きたかを一行で                     |
| ログレベル       | ✅    | WARN / ERROR / FATAL                     |
| 通知フラグ       |      | レベルと別に通知有無を制御したい場合のみ |
| 発生原因         | ✅    | 主な原因・発生条件                       |
| アクション       | ✅    | 運用者が取るべき対応・調査               |

> **通知設計**：原則ログレベル（WARN/ERROR 以上を一律通知）で完結させる。通知フラグの導入は「INFO でも通知したい」「コード修正なしに通知 ON/OFF を切り替えたい」等の例外時のみ。「ERROR だが通知したくない」ケースは、フラグではなく INFO に下げて解決する。

---

## 9. 補足運用ルール

- **ヘルスチェックのアクセスログは出力しない**（LB 等からの大量アクセスで調査ノイズ・コストになるため、分岐で除外）。
- **起動ログは他フォーマットと一致しなくてよい**。サービス名・バージョン・git hash・ビルド時刻・環境・主要設定値（機密は除く）を INFO で出す。視認性優先のバナー可。
- **ローカル環境に限り非構造化ログ・絵文字を許容**（デプロイ環境では出さない＝ノイズ）。
- **保持期間ポリシーを明示**：環境別に保持日数を定める（例 prod 30日 / dev 7日）。認証・監査ログは長期・別系統（§2.3）。巨大ペイロード（Base64 バイナリ等）は出力しない。
- **アクセスログはリクエスト/レスポンス両方で出す**のを基本とする（調査性を優先。ログ量は増える）。

---

## 10. 実装メモ（Go / Laravel）

### Go（`slog`）

- キー文字列にドットをそのまま入れる：`slog.String("http.request.method", r.Method)`
- **`slog.Group` は使わない**（物理ネストになるため）。フラット運用を徹底。
- 共通ミドルウェアで `timestamp` / `service.*` / `env` / `event.category` / `trace_id` / `span_id` を自動注入。

### Laravel（Monolog）

- JSON formatter を使用。context 配列のキーにドット文字列を入れる：`Log::info('...', ['http.response.status_code' => 200])`
- 共通 processor で予約フィールドを自動付与。
- 認証・監査ログは専用チャンネル（別ハンドラ / 別出力先）に分離。

---

## 11. 出力例

通常（アプリのアクセスログ）:

```json
{"timestamp":"2026-06-26T04:21:09.123Z","level":"INFO","severity_number":9,"message":"request completed","service.name":"motionginko-api","service.version":"1.4.2","env":"prod","event.category":"web","schema.version":"0.4","trace_id":"a1b2c3","span_id":"d4e5f6","http.request.method":"GET","http.route":"/motions/{id}","http.response.status_code":200,"duration_ms":42.7,"user.id":"u_123"}
```

エラー（`exception.*` のみ実ネスト2層を許容。WARN 以上は `message.code` を付与）:

```json
{"timestamp":"2026-06-26T04:22:00.001Z","level":"ERROR","severity_number":17,"message":"failed to load motion","message.code":"MOTION-404","service.name":"motionginko-api","service.version":"1.4.2","env":"prod","event.category":"web","schema.version":"0.4","trace_id":"a1b2c3","http.route":"/motions/{id}","http.response.status_code":500,"event.outcome":"failure","exception":{"type":"NotFoundError","message":"motion not found","stack_trace":"..."}}
```

認証ログ（ログイン失敗）:

```json
{"timestamp":"2026-06-26T04:23:11.500Z","level":"WARN","severity_number":13,"message":"login failed","message.code":"AUTH-LOGIN-001","service.name":"auth-service","service.version":"2.0.1","env":"prod","event.category":"authentication","schema.version":"0.4","trace_id":"b2c3d4","auth.method":"password","auth.event":"login_failed","event.outcome":"failure","user.id":"u_123","client.address":"203.0.113.5"}
```

監査ログ（更新操作）:

```json
{"timestamp":"2026-06-26T04:24:00.000Z","level":"INFO","severity_number":9,"message":"resource updated","service.name":"motionginko-api","service.version":"1.4.2","env":"prod","event.category":"audit","schema.version":"0.4","trace_id":"c3d4e5","actor.id":"u_123","action":"update","target.type":"motion","target.id":"m_456"}
```

## 12. 参考リンク

- [OpenTelemetry Semantic Conventions](https://opentelemetry.io/docs/reference/specification/logs/semantic_conventions/)
- [Elastic Common Schema](https://www.elastic.co/guide/en/ecs/current/index.html)
- [ログ設計ガイドライン](https://future-architect.github.io/arch-guidelines/documents/forLog/log_guidelines.html#%E3%83%AC%E3%82%A4%E3%82%A2%E3%82%A6%E3%83%88)
