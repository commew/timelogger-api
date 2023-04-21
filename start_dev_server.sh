bundle check || bundle install &&
rm -f tmp/pids/server.pid &&
rails s -p 3000 -b '0.0.0.0'

## 以下、 credentials に設定した値の動作確認のためのコード
## 滅多に使用しないと思われるので、コメントアウトを編集して実行する形式を採用
## ローカル環境にて各環境の credentials を参照して起動
## 現状では、各環境の DB に正しくつながっているかのテストができる
## 注意点として、参照系のアクセスはしてよいが、更新系のアクセスはしないように
## RAILS_ENV を指定して起動するため、開発が進むとこのテストは役に立たなくなる可能性あり

# # このファイルの1~3行目をコメントアウトし、以下の行をコメントアウト
# bundle check || bundle install &&
# rm -f tmp/pids/server.pid
# # 環境を指定、使わない方はコメントアウトする
# ENV_STRING="staging"
# ENV_STRING="production"
# # 環境とマスターキーを指定して rails server を起動
# RAILS_ENV="${ENV_STRING}" RAILS_MASTER_KEY=$(cat config/credentials/"${ENV_STRING}".key) rails s -p 3000 -b '0.0.0.0'
# rails s -p 3000 -b '0.0.0.0'
# # 変更したら docker compose down && docker compose up -d を実行する
