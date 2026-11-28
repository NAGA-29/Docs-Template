# <test-name>

## 実施条件
- 実施日時: YYYY-MM-DD HH:MM〜HH:MM (JST)
- 対象環境 / URL:
- 対象コミット (git rev-parse HEAD):
- サーバースペック: vCPU / RAM / ディスク
- k6 実行元: マシン・所在（同一DC / 社内NW / 自宅）・概算RTT
- 主要設定: HeartbeatDBSyncInterval= / NotificationQueueSize= / heartbeat TTL= / Nginx rate limit=
- 試験前DB状態: logs=  件 / terminal_metrics=  件 / Redis keys=

## 実行コマンド
（そのまま貼る）

## 結果
- k6 サマリ: <file>.json
- サーバーメトリクス: metrics/<test-name>.csv
- pprof: pprof/<test-name>/

## 判定
- 閾値: pass / fail（違反項目と実測値）
- 送信件数 vs DB保存件数: N / M（欠損率 x.x%）
- ドロップ件数（queue full）: N 件
- キュー最大滞留: event_db_queue= / chan len=
- 負荷停止後のドレイン時間: N 秒

## 所見・次アクション
