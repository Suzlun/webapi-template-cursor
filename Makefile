# =============================================================================
# webapi-template-cursor - Makefile
# =============================================================================

.PHONY: help dev build test clean install-tools setup-hooks

# デフォルトターゲット
.DEFAULT_GOAL := help

# ヘルプ
help: ## このヘルプを表示
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# 開発
dev: ## 開発サーバーを起動
	go run cmd/server/main.go

build: ## アプリケーションをビルド
	go build -o bin/server cmd/server/main.go

# テスト
test: ## テストを実行
	go test -v ./...

test-coverage: ## カバレッジ付きでテストを実行
	go test -v -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out -o coverage.html

# 依存関係
deps: ## 依存関係を整理
	go mod tidy
	go mod download

# 追加ツールのインストール（必要な時のみ）
install-tools: ## 開発ツールをインストール（時間がかかります）
	@echo "⏳ 開発ツールをインストール中..."
	go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
	go install github.com/cosmtrek/air@latest
	go install github.com/golang-migrate/migrate/v4/cmd/migrate@latest
	go install github.com/vektra/mockery/v2@latest
	@echo "✅ ツールのインストール完了"

# Git Hooks
setup-hooks: ## Git Hooksを設定（全チームメンバー必須）
	./scripts/setup-hooks.sh

# 品質チェック（golangci-lintがインストール済みの場合）
lint: ## golangci-lintを実行
	@if command -v golangci-lint >/dev/null 2>&1; then \
		golangci-lint run; \
	else \
		echo "⚠️  golangci-lintがインストールされていません。make install-tools を実行してください"; \
	fi

fmt: ## コードフォーマット
	go fmt ./...
	@if command -v goimports >/dev/null 2>&1; then \
		goimports -w .; \
	fi

# データベース
db-status: ## データベース接続確認
	cockroach sql --insecure --host=cockroachdb --execute="SELECT version();"

# Swagger（swagがインストール済みの場合）
swagger: ## Swagger ドキュメントを生成
	@if command -v swag >/dev/null 2>&1; then \
		swag init -g cmd/server/main.go -o docs; \
	else \
		echo "⚠️  swagがインストールされていません。すでにインストール済みです"; \
	fi

# Git設定
git-status: ## Git設定を確認
	@echo "🔍 Git設定を確認中..."
	@echo "Git Version: $(shell git --version)"
	@echo "User Name: $(shell git config --global user.name || echo '未設定')"
	@echo "User Email: $(shell git config --global user.email || echo '未設定')"
	@echo "Core Editor: $(shell git config --global core.editor || echo '未設定')"
	@echo "Default Branch: $(shell git config --global init.defaultBranch || echo '未設定')"
	@echo "Credential Helper: $(shell git config --global credential.helper || echo '未設定')"
	@if [ -n "$$SSH_AUTH_SOCK" ]; then \
		echo "SSH Agent: 利用可能"; \
		if ssh-add -l >/dev/null 2>&1; then \
			echo "SSH Keys: $(shell ssh-add -l | wc -l) 個のキーが利用可能"; \
		else \
			echo "SSH Keys: キーが読み込まれていません"; \
		fi; \
	else \
		echo "SSH Agent: 利用不可"; \
	fi

git-setup: ## Git設定を対話的に設定
	@echo "🛠️  Git設定を開始します..."
	@read -p "Git User Name: " name && git config --global user.name "$$name"
	@read -p "Git User Email: " email && git config --global user.email "$$email"
	@git config --global init.defaultBranch main
	@git config --global push.default simple
	@git config --global pull.rebase false
	@git config --global core.autocrlf input
	@git config --global core.editor "code --wait"
	@git config --global credential.helper store
	@echo "✅ Git設定完了"

git-reset: ## Git設定をリセット
	@echo "⚠️  Git設定をリセットします..."
	@read -p "本当にリセットしますか？ (y/N): " confirm && [ "$$confirm" = "y" ] || exit 1
	@rm -f ~/.gitconfig
	@echo "✅ Git設定をリセットしました"

# クリーンアップ
clean: ## 生成ファイルを削除
	rm -rf bin/ tmp/ coverage.out coverage.html 