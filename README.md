# EventManagement

イベント・予定管理アプリ（学習用プロジェクト）。
イベントをCRUDで管理し、日付とステータス（予定／対応中／完了）で状況を把握できるWebアプリ。カレンダー表示にも対応する。

詳しい要件は [docs/requirements.md](docs/requirements.md) を参照。

## 技術構成

| 項目 | 使用技術 |
|---|---|
| フロントエンド | Vue 3（TypeScript）+ Vite |
| バックエンド | Ruby on Rails（APIモード） |
| データベース | MySQL（Docker） |

バージョンの詳細は [docs/tech-stack.md](docs/tech-stack.md) を参照。

## セットアップ・起動方法（ローカル開発）

```
docker compose up
```

- フロントエンド: http://localhost:5173
- バックエンドAPI: http://localhost:3000
- MySQL: localhost:3306（root / password）

## ディレクトリ構成

```
.
├── backend/           Rails APIバックエンド
├── frontend/          Vueフロントエンド
├── docker-compose.yml MySQL等の起動設定（ローカル開発用）
├── infra/             AWSインフラ構成（Terraform）
└── docs/              要件定義・画面設計・DB設計・インフラ設計などのドキュメント
```

## ドキュメント

| ドキュメント | 内容 |
|---|---|
| [docs/requirements.md](docs/requirements.md) | 要件定義書（全体概要・非機能要件など） |
| [docs/functional-requirements.md](docs/functional-requirements.md) | 機能要件・対象外機能・受け入れ基準 |
| [docs/screen-design.md](docs/screen-design.md) | 画面設計（一覧画面・カレンダー画面のレイアウト） |
| [docs/database-design.md](docs/database-design.md) | データベース設計（テーブル定義） |
| [docs/tech-stack.md](docs/tech-stack.md) | 技術スタックと採用バージョン、AWSインフラ構成の概要 |
| [docs/infra-design.md](docs/infra-design.md) | AWSネットワーク構成・Terraform管理範囲・デプロイ手順 |

## 開発ルール

このリポジトリでの開発ルール（Issue駆動・ブランチ運用・PR必須化）は [CLAUDE.md](CLAUDE.md) を参照。

## 現在の実装状況

- [x] バックエンド・フロントエンドの初期セットアップ
- [x] イベントCRUD API（一覧・詳細・作成・更新・削除、ステータス絞り込み・日付順ソート対応）
- [x] 一覧画面での表示・作成・編集・削除・ステータス変更・絞り込み・並び替え（フロントエンド）
- [x] カレンダー画面（月表示、イベント色分け、日付/イベントクリックでの作成・編集）
- [x] Terraformによるインフラ構築（VPC・EC2・RDS・ECR）
- [x] EC2上でのdocker-compose起動・ECRからのイメージPull
- [x] EC2のパブリックIPからのCRUD動作確認（動作確認後、課金防止のためterraform destroy済み。再構築時はinfra/README.mdの手順を参照）

## 今後の課題

- [x] カレンダー画面に前月・次月・今日への移動ボタンを追加する - [#13](https://github.com/K-Katsumata9/EventManagement/issues/13)
- [x] 全体のUI/UX改善（Indigoテーマ・角丸・余白の調整、Googleカレンダー風のサイドバーレイアウト） - [#13](https://github.com/K-Katsumata9/EventManagement/issues/13)
