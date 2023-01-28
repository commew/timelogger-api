# How to Start

## 初回構築
```
## 環境起動
docker compose up -d
## 初回起動時は bundle install が走るので、依存のインストールが終わった頃に DB を初期化する
docker compose exec api rails db:create
```

## 初回以降の開発開始と終了
```
# API サーバー起動
docker compose up -d

# API サーバーに入って操作
docker compose exec api bash

# 終了
docker compose down
```

## トラブルシュート

- DB 関連でうまくいかない場合は環境を終了した状態で `rm -rf docker/data` を実行して DB のデータを全削除する。
- Rails 関連でうまくいかない場合は `rm -rf vendor` を実行して依存のインストールをやり直す。

## エイリアス
`. ./alias.sh` コンテナ外から rails などのコマンドを呼ぶ際のエイリアス集を読み込む。  
お好みの応じて。
