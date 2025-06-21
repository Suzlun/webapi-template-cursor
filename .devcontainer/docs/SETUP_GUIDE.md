# DevContainer セットアップガイド

## 🚀 初回セットアップ

### 1. 前提条件の確認

必要なソフトウェアがインストールされていることを確認してください：

- **Docker Desktop**: 最新版を推奨
- **Visual Studio Code**: 最新版を推奨
- **Dev Containers 拡張機能**: `ms-vscode-remote.remote-containers`

### 2. DevContainer 起動

1. VS Code でプロジェクトを開く
2. コマンドパレット（`Ctrl+Shift+P` / `Cmd+Shift+P`）を開く
3. `Dev Containers: Reopen in Container` を選択
4. 初回は Docker イメージのビルドに 5-10 分程度かかります

### 3. セットアップ進行状況の確認

Docker ビルドの進行状況は VS Code の出力パネルで確認できます：

- `View` → `Output` → `Dev Containers` を選択

## ✅ 動作確認チェックリスト

DevContainer が正常に起動したら、以下を順番に確認してください：

### 1. 基本環境確認

```bash
# Go のバージョン確認
go version
# 期待値: go version go1.24.x linux/amd64

# 作業ディレクトリ確認
pwd
# 期待値: /workspace

# プロジェクト構造確認
ls -la
# 期待値: .devcontainer/, docs/, .cursor/ などが表示される
```

### 2. 開発ツール確認

```bash
# Make ヘルプ表示
make help
# 期待値: 利用可能なコマンド一覧が表示される

# Go tools 確認
which golangci-lint
which air
which swag
# 期待値: それぞれのツールのパスが表示される
```

### 3. データベース接続確認

```bash
# CockroachDB 接続テスト
cockroach sql --insecure --host=cockroachdb:26257 --execute="SELECT version();"
# 期待値: CockroachDB のバージョン情報が表示される

# データベース一覧確認
cockroach sql --insecure --host=cockroachdb:26257 --execute="SHOW DATABASES;"
# 期待値: webapi_dev, webapi_test, webapi_prod が表示される
```

### 4. Redis 接続確認

```bash
# Redis 接続テスト
redis-cli -h redis ping
# 期待値: PONG

# Redis 情報確認
redis-cli -h redis info server
# 期待値: Redis サーバー情報が表示される
```

### 5. サービス起動確認

```bash
# 全サービスの状態確認
docker-compose -f .devcontainer/docker-compose.yml ps
# 期待値: すべてのサービスが "Up" 状態で表示される
```

### 6. Go モジュール確認

```bash
# Go modules 初期化（初回のみ）
go mod init webapi-template  # setup.sh で自動実行済み

# 依存関係確認
go mod tidy
go list -m all
# 期待値: 依存関係一覧が表示される
```

## 🌐 Web サービス動作確認

ブラウザで以下の URL にアクセスして、各サービスが起動していることを確認：

| サービス          | URL                    | 確認内容                     |
| ----------------- | ---------------------- | ---------------------------- |
| CockroachDB Admin | http://localhost:8090  | DB 管理画面が表示される      |
| Jaeger UI         | http://localhost:16686 | トレーシング画面が表示される |
| pgAdmin           | http://localhost:5050  | ログイン画面が表示される     |
| Redis Commander   | http://localhost:8082  | Redis 管理画面が表示される   |

## 🔧 開発開始前のセットアップ

### 1. 環境変数設定

```bash
# .env ファイルを .env.example からコピー
cp .env.example .env

# 必要に応じて .env ファイルを編集
nano .env
```

### 2. データベース初期化

```bash
# データベース作成
make db-create

# マイグレーション実行（マイグレーションファイルがある場合）
make db-migrate
```

### 3. 開発サーバー起動テスト

```bash
# ホットリロード開発サーバー起動
make dev
# 期待値: Air によるホットリロードが開始される
```

## 🚨 よくある問題と解決方法

### 問題 1: Docker が起動しない

**症状**: `Cannot connect to the Docker daemon`

**解決方法**:

```bash
# Docker Desktop が起動していることを確認
docker --version

# Docker サービスの再起動
# macOS: Docker Desktop を再起動
# Linux: sudo systemctl restart docker
```

### 問題 2: CockroachDB に接続できない

**症状**: `connection refused` エラー

**解決方法**:

```bash
# CockroachDB コンテナの状態確認
docker-compose -f .devcontainer/docker-compose.yml ps cockroachdb

# CockroachDB ログ確認
docker-compose -f .devcontainer/docker-compose.yml logs cockroachdb

# CockroachDB コンテナ再起動
docker-compose -f .devcontainer/docker-compose.yml restart cockroachdb
```

### 問題 3: Redis に接続できない

**症状**: `Could not connect to Redis`

**解決方法**:

```bash
# Redis コンテナの状態確認
docker-compose -f .devcontainer/docker-compose.yml ps redis

# Redis コンテナ再起動
docker-compose -f .devcontainer/docker-compose.yml restart redis
```

### 問題 4: Go modules エラー

**症状**: `go: module webapi-template: reading module: module not found`

**解決方法**:

```bash
# Go modules 再初期化
rm -f go.mod go.sum
go mod init webapi-template

# 依存関係再インストール
make deps
```

### 問題 5: ポート競合エラー

**症状**: `port already in use`

**解決方法**:

```bash
# 使用中のポート確認
lsof -i :8080  # または該当ポート

# 全コンテナ停止
docker-compose -f .devcontainer/docker-compose.yml down

# コンテナ再起動
docker-compose -f .devcontainer/docker-compose.yml up -d
```

## 📋 次のステップ

DevContainer の動作確認が完了したら：

1. **README.md** を確認して、プロジェクトの概要を理解
2. **docs/requirements.md** で要件を確認
3. **make help** で利用可能なコマンドを確認
4. **make dev** で開発を開始

## 🆘 サポート

問題が解決しない場合：

1. GitHub Issues で問題を報告
2. `.devcontainer/` ディレクトリの設定ファイルを確認
3. Docker Desktop の設定を確認
4. VS Code の Dev Containers 拡張機能を最新版に更新

---

**Happy Coding! 🚀**
