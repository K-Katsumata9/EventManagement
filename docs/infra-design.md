# インフラ構成

[← 要件定義書に戻る](requirements.md)

第一版のインフラゴールは、EC2のパブリックIPからアクセスしてCRUD処理が正常に行えることとする。
技術選定の概要は [技術スタック 6. 本番相当環境（インフラ構成）](tech-stack.md#6-本番相当環境インフラ構成) を参照。本ドキュメントではネットワーク構成・管理範囲の詳細を記載する。

## 1. ネットワーク構成

| リソース | 種別 | 配置 | 補足 |
|---|---|---|---|
| VPC | ネットワーク | - | 本アプリ専用のVPCを新規作成する |
| Public Subnet | サブネット | AZ×1 | EC2を配置する。第一版は単一AZ・単一サブネット構成とする |
| Private Subnet | サブネット | AZ×1 | RDSを配置する。第一版は単一AZ構成とする（Multi-AZは対象外） |
| Internet Gateway | ゲートウェイ | VPCにアタッチ | Public Subnetからのインターネット疎通に使用する |
| EC2用セキュリティグループ | SG | EC2にアタッチ | SSH（管理者IPのみ）・HTTP（アプリ用ポート、0.0.0.0/0）を許可する |
| RDS用セキュリティグループ | SG | RDSにアタッチ | EC2用セキュリティグループからのMySQLポート（3306）のみ許可する |

## 2. コンピュート・データベース

| リソース | 補足 |
|---|---|
| EC2インスタンス | Public Subnetに配置。パブリックIP（Elastic IP）を付与する。起動時のuser_dataでECRログイン・イメージpull・docker-compose起動を自動実行する |
| RDS for MySQL | Private Subnetに配置。パブリックアクセス不可。EC2からのみ接続を許可する |
| ECRリポジトリ | frontend用・backend用の2リポジトリ。EC2のIAMロールにECR Pull権限を付与する |

## 3. IAM
- EC2にはECRからのイメージPullに必要な権限（`AmazonEC2ContainerRegistryReadOnly`相当）を持つIAMロールをアタッチする
- Terraform実行用のIAMユーザー／ロールは別途管理し、本リポジトリには認証情報を含めない

## 4. Terraform管理範囲
- VPC・サブネット・ルートテーブル・Internet Gateway
- セキュリティグループ（EC2用・RDS用）
- EC2インスタンス（IAMロール・user_data含む）
- RDS for MySQL（パラメータグループ・サブネットグループ含む）
- ECRリポジトリ（frontend用・backend用）

Terraformのコードは `infra/` ディレクトリ配下で管理する（TaskManagementの `infra/` 構成を参考にする）。
tfstateの管理方法（ローカル／S3バックエンド等）は実装着手時に確定する。

## 5. デプロイフロー
1. ローカルでfrontend／backendのDockerイメージをビルドする
2. ECRへログインし、各リポジトリにイメージをpushする
3. EC2上でイメージをpullし、docker-composeで起動する（初回はuser_data、以降はSSHでの再実行を想定）
4. EC2のパブリックIP（またはElastic IP）にブラウザでアクセスし、イベントのCRUD操作が正常に行えることを確認する

## 6. スコープ外（第一版では対応しない）
- HTTPS化（ACM証明書・ALB等）
- CI/CDによるデプロイ自動化
- Multi-AZ構成・オートスケーリング
- WAF等の高度なセキュリティ対策
