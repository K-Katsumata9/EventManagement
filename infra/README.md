# インフラ・デプロイ手順

EventManagementをAWS（EC2 + RDS + ECR）にTerraformでデプロイする手順。
構成の詳細は [docs/infra-design.md](../docs/infra-design.md) を参照。

## 前提

- AWS CLI設定済み（`aws sts get-caller-identity`で確認）
- Terraform >= 1.7.0
- Docker（`--platform linux/amd64`でのビルドに対応していること）

## 1. tfvarsの準備

```
cd infra/terraform
cp terraform.tfvars.example terraform.tfvars
```

`terraform.tfvars`に以下を設定する（このファイルはgit管理外）:

- `db_password`: RDSのマスターパスワード（任意の強固な文字列）
- `rails_master_key`: `backend/config/master.key` の値

## 2. インフラ構築

```
terraform init
terraform plan -out=tfplan
terraform apply "tfplan"
```

`terraform output` でEC2のパブリックIP、ECRリポジトリURLなどを確認できる。

## 3. Dockerイメージのビルド・push

EC2はx86_64（Amazon Linux 2023）なので、Apple Silicon Mac等からビルドする場合は`--platform linux/amd64`を付ける。

```
ECR_REGISTRY=$(terraform output -raw ecr_backend_repository_url | cut -d/ -f1)
aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin "$ECR_REGISTRY"

# backend
cd ../../backend
docker build --platform linux/amd64 -t eventmanagement-backend:latest .
docker tag eventmanagement-backend:latest "$ECR_REGISTRY/eventmanagement-backend:latest"
docker push "$ECR_REGISTRY/eventmanagement-backend:latest"

# frontend（VITE_API_BASE_URLはDockerfile内でビルド時に空文字に設定済み。
# Nginxが/api/をbackendへリバースプロキシする）
cd ../frontend
docker build --platform linux/amd64 -t eventmanagement-frontend:latest .
docker tag eventmanagement-frontend:latest "$ECR_REGISTRY/eventmanagement-frontend:latest"
docker push "$ECR_REGISTRY/eventmanagement-frontend:latest"
```

## 4. EC2でのコンテナ起動

EC2起動時のuser_dataが自動でECRログイン・`docker-compose.prod.yml`起動を行う。
**ただし、EC2起動時点でイメージがECRにpushされていないと失敗する**ため、通常は次の順で行う。

1. `terraform apply`でインフラ作成（EC2も同時に起動するが、初回はイメージ未pushのためコンテナ起動は失敗する）
2. 上記手順3でイメージをpush
3. SSM Session Manager経由でEC2に接続し、手動で`docker compose up -d`を実行する

```
INSTANCE_ID=$(terraform output -raw ... ) # または `aws ec2 describe-instances` で確認

aws ssm send-command \
  --instance-ids "$INSTANCE_ID" \
  --region ap-northeast-1 \
  --document-name "AWS-RunShellScript" \
  --parameters 'commands=[
    "cd /opt/eventmanagement",
    "aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin '"$ECR_REGISTRY"'",
    "docker compose --env-file .env -f docker-compose.prod.yml up -d"
  ]'
```

コマンド結果は `aws ssm get-command-invocation --command-id <ID> --instance-id "$INSTANCE_ID"` で確認する。

SSM接続にはIAMロールに`AmazonSSMManagedInstanceCore`がアタッチされている必要がある（`iam.tf`で設定済み）。
**IAMロールへのポリシー追加は起動中のインスタンスには自動反映されないため、追加した場合はEC2を一度再起動（stop/start）してSSMエージェントを再認証させる。**

## 5. 動作確認

```
terraform output ec2_public_ip
```

ブラウザで `http://<EC2のパブリックIP>/` にアクセスし、イベントの一覧・カレンダー表示、CRUD操作が行えることを確認する。

## 6. 破棄（課金停止）

動作確認が終わったら、課金を止めるために破棄する。

```
terraform destroy
```

ECRリポジトリは`force_delete = true`を設定しているため、イメージが残っていても削除できる。

## 注意点・ハマりどころ

- **EC2のroot volumeサイズ**: AMIのスナップショットサイズ以上が必要。20GBでは`InvalidBlockDeviceMapping`エラーになるため30GBに設定している（`ec2.tf`）。
- **Railsのforce_ssl**: 本番環境はデフォルトで`config.force_ssl = true`になっており、HTTPで直接EC2にアクセスする本構成ではリダイレクトループになる。`RAILS_FORCE_SSL=false` / `RAILS_ASSUME_SSL=false`を環境変数で渡して無効化している（`docker-compose.prod.yml`）。
- **フロントのAPIベースURL**: `import.meta.env.VITE_API_BASE_URL || 'http://localhost:3000'`のように`||`でフォールバックすると、本番ビルド時に空文字（相対パス指定の意図）を渡しても`localhost:3000`にフォールバックしてしまう。`??`を使うこと（`frontend/src/api/client.ts`）。
- **再起動とuser_data**: EC2を再起動してもuser_data（cloud-initのscripts-user）は再実行されない（初回起動時のみ）。再起動後にコンテナが立ち上がっていない場合は、SSM経由で手動で`docker compose up -d`を実行する。
