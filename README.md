# How to Start

## 初回構築
```
## バックグラウンドで環境起動、API サーバーの出力を監視
docker compose up -d && docker compose logs -f api
```
初回起動時は bundle install が走る。  
ログに
```
api.timelogger  | * Listening on http://0.0.0.0:3000
api.timelogger  | Use Ctrl-C to stop
```
のように表示されたらインストールは終わっているので Ctrl+C でログ出力から抜ける。
```
## DB を初期化する
docker compose exec api rails db:create
```
上記コマンド実行後、動作確認としてブラウザにて [http://localhost:3000](http://localhost:3000) を開く。  
表示されていたら構築完了。

## 初回以降の開発開始と終了
```
# 環境の起動
docker compose up -d

# API コンテナに入って操作
docker compose exec api bash

# DB 接続
docker compose exec db mysql -u root -p
# ローカルのクライアントから DB 接続
mysql -u root -h 127.0.0.1 --port 3306 -p

# 環境の終了
docker compose down
```


## 開発中のあれこれ

### 各種コマンド実行

以下は基本、apiコンテナ内で行う。つまり、頭に`docker compose exec api`をつけて実行する。


#### rspecでの自動テストの実行

```
bundle exec rspec
```


### 機密情報の編集方法

1. config/credentials ディレクトリに鍵ファイルを置く (鍵は共有ドライブにある)
1. 以下のコマンドを実行すると vim が起動して編集が行える

```
## 本番環境
rails credentials:edit --environment production

## 検証環境
rails credentials:edit --environment staging
```


### Dockerコンテナ再起動が必要なタイミング

* `bundle install`後。


## トラブルシュート

- DB 関連でうまくいかない場合は環境を終了した状態で `rm -rf docker/data` を実行して DB のデータを全削除する。
- Rails 関連でうまくいかない場合は `rm -rf vendor` を実行して依存のインストールをやり直す。

