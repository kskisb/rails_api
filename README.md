# Twitter Clone API セットアップ
この API は [このリポジトリ](https://github.com/kskisb/twitter_clone) と連動しています。次の流れでセットアップできます。

## docker
```
$ docker compose build --no-cache
$ docker compose up -d
```

## Railsコンテナ
```
$ docker exec -it rails_api-web-1 /bin/bash
```

## Migration(Railsコンテナ内で実行する場合)
```
$ bundle exec rails db:migrate
$ bundle exec rails db:seed
```