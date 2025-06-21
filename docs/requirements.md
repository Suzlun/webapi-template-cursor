# WebAPI サーバーテンプレート 要件定義

## 概要

Golang で WebAPIServer のテンプレートを作成します。
RESTful API を提供し、データベースアクセス、キャッシュ機能、認証機能を含む汎用的なテンプレートを目指します。

## 技術スタック

### バックエンド

- **言語**: Go 1.24+
- **Web フレームワーク**: gin
- **ORM**: GORM
- **データベース**: CockroachDB v25.2
  - PostgreSQL wire protocol v3.0 互換
  - PostgreSQL 17 相当の機能をサポート
  - ULID (Universally Unique Lexicographically Sortable Identifier) 使用
- **キャッシュ**: Redis 7+
- **API ドキュメント**: OpenAPI 3.0+ / Swagger
- **バリデーション**: go-playground/validator
- **テストライブラリ**: testify, sqlmock

### 監視・運用

- **分散トレーシング**: OpenTelemetry
- **トレース収集**: Jaeger / OTLP
- **メトリクス**: Prometheus
- **ログ**: slog (構造化ログ)
- **ヘルスチェック**: Kubernetes Probes

### インフラ・デプロイ

- **コンテナ化**: Docker
- **オーケストレーション**: Kubernetes (API サーバーのみ)
- **パッケージ管理**: Helm
- **CI/CD**: GitHub Actions
- **環境管理**: ConfigMap / Secret
- **外部サービス**: CockroachDB v25.2, Redis (Kubernetes 外部で管理)

### アーキテクチャ

- Clean Architecture をベースとした設計
- レイヤード アーキテクチャ
  - Handler Layer (API エンドポイント)
  - Service Layer (ビジネスロジック)
  - Repository Layer (データアクセス)
  - Entity Layer (ドメインモデル)

## 機能要件

### 基本機能

1. **API 機能**

   - RESTful API
   - JSON 形式のレスポンス
   - エラーハンドリング
   - ミドルウェア（ログ、CORS、認証等）

2. **データベース機能**

   - CockroachDB v25.2 接続
   - マイグレーション機能
   - 分散トランザクション管理
   - PostgreSQL 互換クライアント使用可能

3. **キャッシュ機能**

   - Redis 接続
   - セッション管理
   - データキャッシュ

4. **認証・認可**

   - JWT 認証
   - ユーザー管理
   - 権限管理

5. **ログ機能**

   - 構造化ログ
   - ログレベル管理
   - アクセスログ

6. **開発手法**

   - TDD (Test-Driven Development)
   - OpenAPI 仕様駆動開発
   - API ドキュメント自動生成

7. **API ドキュメント**
   - OpenAPI 3.0+ 準拠
   - Swagger UI 統合
   - API スキーマ検証

## 非機能要件

### 性能

- レスポンス時間: 100ms 以下（通常の CRUD 操作）
- 同時接続数: 1000 接続

### セキュリティ

- HTTPS 対応
- SQL インジェクション対策
- XSS 対策
- CSRF 対策

### 運用

- ヘルスチェック機能
- メトリクス収集
- Graceful shutdown

## ディレクトリ構造

```
.
├── cmd/
│   └── server/
│       └── main.go
├── internal/
│   ├── domain/
│   │   ├── entity/
│   │   └── repository/
│   ├── usecase/
│   ├── handler/
│   └── infrastructure/
│       ├── database/
│       ├── cache/
│       └── config/
├── pkg/
├── docs/
├── migrations/
├── docker/
├── scripts/
└── tests/
```

## コーディング規則

別途 `./.cursor/rules/dev-rules/` に詳細を定義
