# 技術スタック

[← 要件定義書に戻る](requirements.md)

## 1. 基本構成

| 項目 | 使用技術 | 補足（一般的な説明） |
|---|---|---|
| フロントエンド | Vue 3（TypeScript） | 画面（ブラウザ上の見た目・操作部分）を作るための技術。型を用いて実装ミスを防ぎやすいTypeScriptを採用 |
| バックエンド | Ruby on Rails（APIモード） | データの登録・更新・削除などの処理を行うサーバー側の仕組み。画面描画は行わずJSON APIのみを提供する |
| データベース | MySQL | イベント情報を保存しておく仕組み |

## 2. フロントエンド周辺技術

| 項目 | 使用技術 | 補足 |
|---|---|---|
| 言語 | TypeScript | JavaScriptに型を付けた言語。実装ミスの早期発見や、コードの読みやすさ向上のために採用 |
| ビルドツール | Vite | Vueの SPA構成を、高速に開発・ビルドするためのツール |
| 状態管理 | Pinia | Vue公式の状態管理ライブラリ。イベント一覧やフィルタ状態などをコンポーネント間で共有する |
| ルーティング | Vue Router | 一覧画面・カレンダー画面間のページ遷移を管理する |
| カレンダー表示 | 自作コンポーネント（またはFullCalendar等の検討） | 月表示カレンダーの実装。第一版はシンプルな自作コンポーネントで開始し、必要に応じてライブラリ導入を検討する |
| HTTPクライアント | axios | バックエンドAPIとの通信に使用する |

## 3. バックエンド周辺技術

| 項目 | 使用技術 | 補足 |
|---|---|---|
| API構成 | Rails API mode（`rails new --api`） | ビューを持たずJSONを返すAPI専用構成 |
| ORM | Active Record | RubyのオブジェクトとDBのテーブルを対応付け、SQLを直接書かずにデータ操作を行う仕組み |
| CORS | rack-cors | フロントエンド（別オリジン）からのAPIアクセスを許可するための設定 |

## 4. 構成イメージ

```
[ブラウザ]
   ↓ HTTP（API通信 / JSON）
[Vue 3（TypeScript / Vite / Pinia / Vue Router）] ── フロントエンド
   ↓
[Rails（APIモード）] ── バックエンド
   ↓ Active Record
[MySQL]
```

## 5. 開発環境
- ローカル開発ではDocker Composeでフロントエンド・バックエンド・MySQLを起動できる構成とする（TaskManagementのdocker-compose構成を参考にする）
- バージョンの詳細は今後の実装着手時に確定し、本ドキュメントを更新する

## 6. 本番相当環境（インフラ構成）

第一版のゴールは、EC2のIPアドレスから接続してCRUD処理が正常に行えることとする。

| 項目 | 使用技術 | 補足 |
|---|---|---|
| コンテナオーケストレーション | Docker Compose on EC2 | frontend・backendの2コンテナをEC2上のdocker-composeで起動する |
| コンテナレジストリ | Amazon ECR | frontend用・backend用の2リポジトリを用意する |
| コンピュート | Amazon EC2（Public Subnet） | 起動時のuser_dataでECRからイメージをPullし、docker-composeで起動する |
| データベース | Amazon RDS for MySQL（Private Subnet） | EC2のセキュリティグループからのみ接続を許可する |
| IaC | Terraform | VPC・サブネット・セキュリティグループ・EC2・RDS・ECRなど、インフラ一式をコードで管理する |

### 6.1 構成イメージ

```
[インターネット]
   ↓
[EC2（Public Subnet）]
   ├─ frontendコンテナ（Nginx配信）
   └─ backendコンテナ（Rails API）
        ↓（SG経由でのみ許可）
   [RDS for MySQL（Private Subnet）]

   ↑ 起動時
[Amazon ECR]（frontend / backendイメージ）
```

### 6.2 デプロイフロー（第一版はCI/CDなし・手動）
1. ローカルでfrontend／backendのDockerイメージをビルドする
2. `docker push`でECR（frontend用・backend用）にそれぞれpushする
3. EC2のuser_data（またはSSHでの再実行）でECRからイメージをpullし、docker-composeで起動する
4. EC2のパブリックIPにアクセスし、CRUD操作が正常に行えることを確認する

CI/CD（GitHub Actionsでのビルド・push・デプロイ自動化）は第一版のスコープ外とし、必要になった段階で別途検討する。
