# DevContainer 設定

WebAPI Template プロジェクトの DevContainer 設定一式です。

## 📁 ディレクトリ構造

```
.devcontainer/
├── devcontainer.json          # DevContainer メイン設定
├── docker-compose.yml         # サービス構成定義
├── Dockerfile                 # 開発環境イメージ
├── config/                    # 設定ファイル群
│   ├── database/              # データベース関連設定
│   │   ├── init-db.sql       # CockroachDB 初期化
│   │   └── pgadmin-servers.json # pgAdmin サーバー設定
│   ├── cache/                 # キャッシュ関連設定
│   │   └── redis.conf        # Redis 設定
│   └── shell/                 # シェル関連設定
│       └── zsh_history       # Zsh コマンド履歴
├── scripts/                   # 実行スクリプト群
│   ├── setup.sh              # 初期化スクリプト
│   └── health-check.sh       # ヘルスチェック
├── docs/                      # ドキュメント
│   └── SETUP_GUIDE.md        # セットアップガイド
└── README.md                  # このファイル
```

## 🚀 クイックスタート

```bash
# 1. VS Code でプロジェクトを開く
# 2. Ctrl+Shift+P → "Dev Containers: Reopen in Container"
# 3. 自動的に環境構築が開始されます
```

## 📋 設定ファイル詳細

### Core Configuration

- **`devcontainer.json`**: DevContainer のメイン設定

  - VS Code 拡張機能
  - ポートフォワーディング
  - マウント設定
  - ユーザー設定

- **`docker-compose.yml`**: サービス構成

  - Go アプリケーション環境
  - CockroachDB v25.2
  - Redis 7+
  - Jaeger (分散トレーシング)
  - pgAdmin & Redis Commander

- **`Dockerfile`**: 開発環境イメージ
  - Go 1.24+ 基盤
  - 開発ツール統合
  - セキュリティ設定

### Configuration Files

#### Database (`config/database/`)

- **`init-db.sql`**: CockroachDB 初期化 SQL
- **`pgadmin-servers.json`**: pgAdmin 自動接続設定

#### Cache (`config/cache/`)

- **`redis.conf`**: Redis 開発環境設定

#### Shell (`config/shell/`)

- **`zsh_history`**: よく使うコマンドのプリセット

### Scripts (`scripts/`)

- **`setup.sh`**: 全自動環境セットアップ
- **`health-check.sh`**: 環境ヘルスチェック

### Documentation (`docs/`)

- **`SETUP_GUIDE.md`**: 詳細セットアップガイド

## 🔧 カスタマイズ

### ポート設定変更

`docker-compose.yml` の `ports` セクションで変更:

```yaml
ports:
  - "8080:8080" # API Server
  - "8090:8080" # CockroachDB Admin
```

### VS Code 拡張機能追加

`devcontainer.json` の `extensions` セクションに追加:

```json
"extensions": [
  "your.extension.id"
]
```

### 環境変数設定

`docker-compose.yml` の `environment` セクションで設定:

```yaml
environment:
  - YOUR_VAR=your_value
```

## 🌐 アクセス可能サービス

| サービス          | ポート | URL                        | 用途                   |
| ----------------- | ------ | -------------------------- | ---------------------- |
| API Server        | 8080   | http://localhost:8080      | メインアプリケーション |
| Swagger UI        | 8081   | http://localhost:8081      | API ドキュメント       |
| CockroachDB Admin | 8090   | http://localhost:8090      | DB 管理                |
| CockroachDB SQL   | 26257  | `cockroach sql --insecure` | DB 接続                |
| Redis             | 6379   | `redis-cli -h redis`       | キャッシュ             |
| Jaeger UI         | 16686  | http://localhost:16686     | 分散トレーシング       |
| pgAdmin           | 5050   | http://localhost:5050      | DB 管理ツール (admin@example.com/admin123) |
| Redis Commander   | 8082   | http://localhost:8082      | Redis 管理             |

## 🛠️ トラブルシューティング

### ヘルスチェック実行

```bash
.devcontainer/scripts/health-check.sh
```

### サービス再起動

```bash
docker-compose -f .devcontainer/docker-compose.yml restart
```

### ログ確認

```bash
docker-compose -f .devcontainer/docker-compose.yml logs [service_name]
```

## 📚 関連ドキュメント

- [詳細セットアップガイド](./docs/SETUP_GUIDE.md)
- [プロジェクト README](../README.md)
- [要件定義](../docs/requirements.md)
