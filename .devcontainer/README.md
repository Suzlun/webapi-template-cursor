# DevContainer 設定

webapi-template-cursor プロジェクトの DevContainer 設定一式です。

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

| サービス          | ポート | URL                        | 用途                                       |
| ----------------- | ------ | -------------------------- | ------------------------------------------ |
| API Server        | 8080   | http://localhost:8080      | メインアプリケーション                     |
| Swagger UI        | 8081   | http://localhost:8081      | API ドキュメント                           |
| CockroachDB Admin | 8090   | http://localhost:8090      | DB 管理                                    |
| CockroachDB SQL   | 26257  | `cockroach sql --insecure` | DB 接続                                    |
| Redis             | 6379   | `redis-cli -h redis`       | キャッシュ                                 |
| Jaeger UI         | 16686  | http://localhost:16686     | 分散トレーシング                           |
| pgAdmin           | 5050   | http://localhost:5050      | DB 管理ツール (admin@example.com/admin123) |
| Redis Commander   | 8082   | http://localhost:8082      | Redis 管理                                 |

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

## Git 設定の共有 🔧

### 自動設定機能

DevContainer 起動時に、ホストマシンの Git 設定が自動的にコンテナ内に同期されます：

1. **ホストの Git 設定コピー**: `~/.gitconfig` の内容をコンテナ内に適用
2. **SSH Agent 転送**: ホストの SSH 鍵をコンテナ内で使用可能
3. **Git 認証情報共有**: VS Code が自動的にホストの認証情報を共有

### Git 設定の確認

```bash
# Git設定の確認
make git-status

# 出力例:
🔍 Git設定を確認中...
Git Version: git version 2.34.1
User Name: Your Name
User Email: your.email@example.com
Core Editor: code --wait
Default Branch: main
Credential Helper: store
SSH Agent: 利用可能
SSH Keys: 2 個のキーが利用可能
```

### Git 設定のトラブルシューティング

#### 🚨 問題 1: Git 設定が見つからない

```bash
# 症状
User Name: 未設定
User Email: 未設定

# 解決方法1: 手動設定
make git-setup

# 解決方法2: 直接設定
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

#### 🚨 問題 2: SSH Agent が利用できない

```bash
# 症状
SSH Agent: 利用不可

# 解決方法（ホストマシンで実行）:
# 1. SSH Agentを起動
eval "$(ssh-agent -s)"

# 2. SSH鍵を追加
ssh-add ~/.ssh/id_rsa  # または該当する鍵

# 3. VS Codeを再起動
```

#### 🚨 問題 3: Git 認証に失敗する

```bash
# HTTPSの場合
git config --global credential.helper store

# SSHの場合
ssh -T git@github.com  # GitHub接続テスト
```

### Git 設定コマンド

```bash
# Git設定確認
make git-status

# Git設定を対話的に設定
make git-setup

# Git設定をリセット
make git-reset
```

## 使用方法

### 初回セットアップ

1. **VS Code 拡張機能のインストール**

   - Dev Containers 拡張機能をインストール

2. **プロジェクトを開く**

   ```bash
   # リポジトリクローン
   git clone https://github.com/your-org/webapi-template-cursor.git
   cd webapi-template-cursor

   # VS Codeで開く
   code .
   ```

3. **DevContainer で開く**

   - VS Code で「Reopen in Container」を選択
   - 初回は 5-10 分程度の構築時間が必要

4. **Git 設定確認**
   ```bash
   make git-status
   ```

### 日常の開発

```bash
# 開発サーバー起動
make dev

# テスト実行
make test

# Git設定確認
make git-status

# コミット
git add .
git commit -m "feat: new feature"
git push
```

## 自動化された機能

### セットアップスクリプト

DevContainer 起動時に以下が自動実行されます：

1. ✅ Go 環境・ツールのセットアップ
2. ✅ Git 設定の同期・確認
3. ✅ プロジェクト依存関係の解決
4. ✅ Git Hooks の設定
5. ✅ ファイル権限の設定
6. ✅ 開発環境の健全性確認

### Git Hooks の自動設定

以下の Git Hooks が自動設定されます：

- **pre-commit**: コードフォーマット・リント実行
- **pre-push**: テスト実行

```bash
# Git Hooks を手動で再設定
./scripts/setup-hooks.sh
```

## 高度な使用方法

### 追加ツールのインストール

```bash
# 開発ツール一括インストール（時間がかかります）
make install-tools
```

含まれるツール：

- golangci-lint (リンター)
- air (ホットリロード)
- migrate (DB マイグレーション)
- mockery (モック生成)

### データベース操作

```bash
# データベース接続確認
make db-status

# CockroachDB CLIに接続
cockroach sql --insecure --host=cockroachdb
```

### API ドキュメント生成

```bash
# Swagger ドキュメントを生成
make swagger

# Swagger UI: http://localhost:8081
```

## トラブルシューティング

### よくある問題

#### 1. コンテナ起動が遅い

- **原因**: 初回構築・大きなイメージ
- **解決**: 軽量化された Dockerfile を使用済み

#### 2. ポート競合

- **原因**: ホストで同じポートを使用中
- **解決**: `devcontainer.json`でポート変更

#### 3. Git 設定が同期されない

- **原因**: ホストに`.gitconfig`が存在しない
- **解決**: `make git-setup`で手動設定

#### 4. メモリ不足

- **原因**: Docker のメモリ制限
- **解決**: Docker Desktop でメモリ増加

### ログの確認

```bash
# DevContainer構築ログ
# VS Code: View → Output → Dev Containers

# アプリケーションログ
make dev  # 開発サーバーのログを表示
```

## セキュリティ考慮事項

### 含まれるもの

- ✅ Git 設定の安全な共有
- ✅ SSH Agent 転送
- ✅ 認証情報の自動管理

### 含まれないもの

- ❌ Secret ファイルの共有（`.env`等は手動設定）
- ❌ プライベート鍵のコピー（転送のみ）

## サポート

### 問題の報告

1. `make git-status` の出力を確認
2. DevContainer 構築ログを確認
3. Issue テンプレートで報告

### 設定変更

- `devcontainer.json`: VS Code・ポート設定
- `docker-compose.yml`: サービス設定
- `Dockerfile`: 開発環境パッケージ
- `scripts/setup.sh`: 初期化ロジック

---

**Note**: この DevContainer 設定は、WebAPI 開発のベストプラクティスに基づいて構築されています。追加の要件がある場合は、設定ファイルを適切に修正してください。
