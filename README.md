# webapi-template-cursor

Clean Architecture ベースの Go WebAPI テンプレートです。

## 🚀 クイックスタート（DevContainer）

### 前提条件

- Docker Desktop
- Visual Studio Code
- Dev Containers 拡張機能

### 1. リポジトリをクローン

```bash
git clone <repository-url>
cd webapi-template-cursor
```

### 2. DevContainer で開く

1. VS Code でプロジェクトを開く
2. `Ctrl+Shift+P` (Windows/Linux) または `Cmd+Shift+P` (Mac)
3. `Dev Containers: Reopen in Container` を選択
4. 初回は Docker イメージのビルドに数分かかります

### 3. 開発環境の確認

コンテナが立ち上がったら、ターミナルで以下を実行：

```bash
make help           # 利用可能なコマンドを確認
make setup-hooks    # Git Hooksを設定（必須）
```

> **⚠️ 重要**: 初回セットアップ時は `make setup-hooks` を実行してください。これにより、コミット前に自動的にコード品質チェックが実行されます。

## 🛠️ 技術スタック

### バックエンド

- **言語**: Go 1.24+
- **Web フレームワーク**: Gin
- **ORM**: GORM
- **データベース**: CockroachDB v25.2 (PostgreSQL 互換)
- **キャッシュ**: Redis 7+
- **ID 戦略**: ULID (Universally Unique Lexicographically Sortable Identifier)

### 開発・運用

- **API 仕様**: OpenAPI 3.0+ / Swagger
- **テスト**: testify, sqlmock
- **開発手法**: TDD (Test-Driven Development)
- **監視**: OpenTelemetry, Jaeger
- **ログ**: slog (構造化ログ)

### インフラ

- **コンテナ**: Docker
- **オーケストレーション**: Kubernetes (API サーバーのみ)
- **外部サービス**: CockroachDB Cloud, Redis (マネージドサービス)

## 📋 利用可能なコマンド

```bash
# 開発
make dev                 # 開発サーバーを起動（ホットリロード）
make run                 # アプリケーションを直接実行
make build               # アプリケーションをビルド

# テスト
make test                # テストを実行
make test-coverage       # カバレッジ付きでテストを実行

# 品質チェック
make lint                # golangci-lintを実行
make fmt                 # コードフォーマット
make setup-hooks         # Git Hooksを設定（初回必須）

# データベース
make db-create           # データベースを作成
make db-migrate          # マイグレーションを実行
make db-migrate-down     # マイグレーションをロールバック
make db-reset            # データベースをリセット

# API ドキュメント
make swagger             # Swagger ドキュメントを生成

# Docker
make docker-build        # Docker イメージをビルド
make docker-run          # Docker コンテナを実行

# その他
make clean               # 生成ファイルを削除
make deps                # 依存関係をインストール
make tools               # 開発ツールをインストール
```

## 🌐 アクセス可能なサービス

DevContainer 起動後、以下のサービスにアクセスできます：

| サービス          | URL                    | 説明                   |
| ----------------- | ---------------------- | ---------------------- |
| API Server        | http://localhost:8080  | メインの API           |
| Swagger UI        | http://localhost:8081  | API ドキュメント       |
| CockroachDB Admin | http://localhost:8090  | データベース管理       |
| Jaeger UI         | http://localhost:16686 | 分散トレーシング       |
| pgAdmin           | http://localhost:5050  | データベース管理ツール |
| Redis Commander   | http://localhost:8082  | Redis 管理ツール       |

### 管理ツールのログイン情報

**pgAdmin**

- Email: `admin@webapi-template.local`
- Password: `admin123`

**Redis Commander**

- Username: `admin`
- Password: `admin123`

## 📁 プロジェクト構造

```
.
├── cmd/
│   └── server/              # アプリケーションエントリーポイント
├── internal/                # プライベートコード
│   ├── domain/
│   │   ├── entity/          # ドメインエンティティ
│   │   └── repository/      # リポジトリインターフェース
│   ├── usecase/             # ビジネスロジック（サービス層）
│   ├── handler/             # HTTPハンドラー
│   └── infrastructure/      # 外部依存実装
│       ├── database/        # データベース接続・実装
│       ├── cache/           # キャッシュ実装
│       └── config/          # 設定管理
├── pkg/                     # 再利用可能なコード
│   ├── logger/              # ログ
│   ├── validator/           # バリデーション
│   ├── ulid/                # ULID ユーティリティ
│   └── middleware/          # ミドルウェア
├── docs/                    # ドキュメント
├── migrations/              # データベースマイグレーション
├── tests/                   # テスト
│   ├── integration/         # 統合テスト
│   ├── e2e/                 # E2Eテスト
│   └── mocks/               # モック
├── scripts/                 # スクリプト
└── configs/                 # 設定ファイル
```

## 🔧 開発ワークフロー

### 1. 新機能の開発

```bash
# 1. フィーチャーブランチ作成
git checkout -b feature/user-management

# 2. TDDで開発（テストファースト）
# テストを書いてから実装

# 3. 開発サーバー起動（ホットリロード）
make dev

# 4. コード品質チェック
make lint
make test

# 5. API ドキュメント更新
make swagger
```

### 2. データベース操作

```bash
# データベース接続
cockroach sql --insecure --host=cockroachdb:26257

# データベース作成
make db-create

# マイグレーション実行
make db-migrate

# データベースリセット（開発時）
make db-reset
```

### 3. Redis 操作

```bash
# Redis接続
redis-cli -h redis

# Redis データ確認
redis-cli -h redis keys "*"
```

## 🏗️ Clean Architecture

本プロジェクトは Clean Architecture を採用しています：

```
┌─────────────────────────────────────┐
│           Handler Layer             │  ← HTTPリクエスト処理
├─────────────────────────────────────┤
│           Service Layer             │  ← ビジネスロジック
├─────────────────────────────────────┤
│          Repository Layer           │  ← データアクセス抽象化
├─────────────────────────────────────┤
│           Entity Layer              │  ← ドメインモデル
└─────────────────────────────────────┘
```

### 依存関係ルール

- 外側のレイヤーは内側のレイヤーに依存できる
- 内側のレイヤーは外側のレイヤーに依存してはいけない
- インターフェースを使用して依存関係を逆転させる

## 🆔 ULID 戦略

本プロジェクトでは UUID の代わりに ULID を使用しています：

### ULID の利点

- **時系列順序性**: 自然な時系列ソート
- **効率的ページング**: カーソルベースページング最適化
- **分散システム対応**: 衝突のない分散 ID 生成

### 使用例

```go
// エンティティ定義
type User struct {
    ID        string         `gorm:"type:varchar(26);primaryKey" json:"id"`
    Name      string         `gorm:"not null" json:"name"`
    Email     string         `gorm:"uniqueIndex;not null" json:"email"`
    CreatedAt time.Time      `json:"created_at"`
    UpdatedAt time.Time      `json:"updated_at"`
}

// ULID自動生成
func (u *User) BeforeCreate(tx *gorm.DB) error {
    if u.ID == "" {
        u.ID = ulid.Make().String()
    }
    return nil
}
```

## 🔍 可観測性

### 分散トレーシング（Jaeger）

すべての HTTP リクエストとデータベースクエリが自動的にトレースされます。

```bash
# Jaeger UI でトレースを確認
open http://localhost:16686
```

### 構造化ログ（slog）

```go
// ログ出力例
slog.Info("User created successfully",
    "user_id", user.ID,
    "email", user.Email,
    "request_id", getRequestID(ctx),
)
```

## 📚 ドキュメント

- [要件定義](./docs/requirements.md)
- [API 設計規則](./.cursor/rules/dev-rules/api-design-rules.mdc)
- [データベース設計規則](./.cursor/rules/dev-rules/database-rules.mdc)
- [アーキテクチャ規則](./.cursor/rules/dev-rules/architecture-rules.mdc)
- [テスト規則](./.cursor/rules/dev-rules/testing-rules.mdc)

## 🚨 トラブルシューティング

### DevContainer が起動しない

```bash
# Docker Desktop が起動していることを確認
docker --version

# Dev Containers 拡張機能が有効か確認
# VS Code の Extensions で "Dev Containers" を検索
```

### データベース接続エラー

```bash
# CockroachDB コンテナの状態確認
docker-compose ps

# CockroachDB ログ確認
docker-compose logs cockroachdb

# データベース再作成
make db-reset
```

### Redis 接続エラー

```bash
# Redis コンテナの状態確認
docker-compose ps redis

# Redis ログ確認
docker-compose logs redis

# Redis 接続テスト
redis-cli -h redis ping
```

### Go modules エラー

```bash
# モジュールキャッシュクリア
go clean -modcache

# 依存関係再インストール
make deps
```

## 🤝 コントリビューション

1. フィーチャーブランチを作成
2. TDD でテストファーストで実装
3. `make lint` でコード品質チェック
4. `make test` でテスト実行
5. プルリクエスト作成

## �� ライセンス

MIT License
