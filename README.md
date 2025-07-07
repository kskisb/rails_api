# Twitter Clone API
この API は [twitter_clone (フロントエンド)](https://github.com/kskisb/twitter_clone) と [rails_api (インフラ)](https://github.com/kskisb/iac/tree/main/cdk/rails_api) と連動しています。次の流れでセットアップできます。

## セットアップ

### docker
```
$ docker compose build --no-cache
$ docker compose up -d
```

### Rails コンテナ
```
$ docker exec -it rails_api-web-1 /bin/bash
```

### Migration (Railsコンテナ内で実行する場合)
```
$ bundle exec rails db:migrate
$ bundle exec rails db:seed
```

## デプロイ
AWS でデプロイする手順を簡単に記します。
1. AWS コンソールで ECR リポジトリを作成
2. プロジェクトルートで次のコマンドを実行
    ```
    $ aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com
    $ docker build -t ${ECR_REPOSITORY_NAME} . --platform linux/amd64
    $ docker tag ${ECR_REPOSITORY_NAME}:latest ${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${ECR_REPOSITORY_NAME}:latest
    $ docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${ECR_REPOSITORY_NAME}:latest
    ```
3. [このリポジトリ](https://github.com/kskisb/iac/tree/main/cdk/rails_api) を参照し、AWS のリソースを CDK により作成。
