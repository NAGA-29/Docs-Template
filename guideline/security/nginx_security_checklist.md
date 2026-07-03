# Nginxで簡単に導入できるセキュリティ対策

JWT認証を前提としても、Nginx側で入口対策を追加するとバックエンドの負荷軽減や不要なアクセスの遮断に役立つ。

------------------------------------------------------------------------

## 1. IP単位のレートリミット

``` nginx
limit_req_zone $binary_remote_addr zone=ip_limit:10m rate=60r/m;

location /api/ {
    limit_req zone=ip_limit burst=30 nodelay;
    proxy_pass http://backend;
}
```

- 同一IPからの大量アクセスを抑制する。
- 端末ID単位のレートリミットと併用するとより効果的。

------------------------------------------------------------------------

## 2. 端末ID単位のレートリミット

``` nginx
limit_req_zone $http_x_device_id zone=device_limit:10m rate=10r/m;

location /api/terminal/logs {
    limit_req zone=device_limit burst=20 nodelay;
    proxy_pass http://backend;
}
```

### ポイント

- `X-Device-Id` をキーにレートリミットを行う。
- 端末ID一覧を保持する必要はない。
- Nginxが共有メモリ(`zone`)上で自動管理する。

JWTで認証されているIoT端末には相性が良い。

------------------------------------------------------------------------

## 3. リクエストボディサイズ制限

``` nginx
client_max_body_size 1m;
```

巨大POSTによる帯域・メモリ消費を抑える。

------------------------------------------------------------------------

## 4. タイムアウト設定

``` nginx
client_body_timeout 10s;
client_header_timeout 10s;
keepalive_timeout 15s;
send_timeout 10s;
```

遅い接続によるリソース占有を防止する。

------------------------------------------------------------------------

## 5. HTTPメソッド制限

``` nginx
location /api/terminal/logs {

    limit_except POST {
        deny all;
    }

    proxy_pass http://backend;
}
```

POST専用APIならGETなどを拒否できる。

------------------------------------------------------------------------

## 6. 必須ヘッダーの存在チェック

``` nginx
if ($http_authorization = "") {
    return 401;
}

if ($http_x_device_id = "") {
    return 400;
}
```

JWTや端末IDが無いリクエストをバックエンドへ送らない。
ただし、`if`ディレクティブはNginxの挙動が複雑になるため、必要最小限に留める。

------------------------------------------------------------------------

## 7. バックエンドへ渡すヘッダー整理

``` nginx
proxy_set_header Host $host;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Proto $scheme;

proxy_set_header X-Internal-User "";
proxy_set_header X-Admin "";
```

クライアントが付与した不要・危険なヘッダーを除去する。
アプリ側で`X-Internal-User` や `X-Admin` などのヘッダーを使っている場合は、Nginxで空にしておく。

------------------------------------------------------------------------

## 8. 隠しファイルへのアクセス拒否

``` nginx
location ~ /\.(?!well-known) {
    deny all;
}
```

`.env` や `.git` などへのアクセスを防ぐ。

------------------------------------------------------------------------

## 9. セキュリティヘッダー

``` nginx
add_header X-Content-Type-Options nosniff always;
add_header X-Frame-Options DENY always;
add_header Referrer-Policy no-referrer always;
```

ブラウザ向けの基本的な保護を追加する。

------------------------------------------------------------------------

## 10. Health Checkは別扱い

``` nginx
location /health {
    access_log off;
    return 200 "ok";
}
```

死活監視までレートリミットしないようにする。
アクセスログも出さないことで、死活監視のアクセスが大量に残ることを防ぐ。

------------------------------------------------------------------------

# User-Agentについて

User-AgentはHTTPクライアントが送信する自己紹介文字列。

例

- Chrome
- Safari
- Firefox
- curl
- OkHttp(Android)
- Python requests

## 注意

> User-Agentは簡単に偽装できる。

``` bash
curl -A "Mozilla/5.0" https://example.com
```

そのため、

- User-Agentが空なら拒否する
- 雑なBotを多少減らす

程度には有効だが、

**Chromeだけ許可する**などのセキュリティ対策としては意味が薄い。

------------------------------------------------------------------------

# 優先順位

1. レートリミット
2. リクエストサイズ制限
3. タイムアウト
4. HTTPメソッド制限
5. JWT・端末ID必須チェック
6. 隠しファイル拒否

認証・認可はバックエンド、Nginxは入口で不要なアクセスを落とす役割と考えるのが基本。
