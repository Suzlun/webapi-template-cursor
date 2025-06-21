#!/bin/bash

# =============================================================================
# Git Hooks セットアップスクリプト
# 全開発者が統一的にpre-commitフックを使用するための設定
# =============================================================================

set -e

# カラー出力定義
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_info "=== Git Hooks セットアップ開始 ==="

# 1. Git Hooksディレクトリの設定
log_info "1. Git Hooksパスを設定中..."
git config core.hooksPath .githooks
log_success "Git Hooksパスを .githooks に設定"

# 2. フックファイルの実行権限確認
log_info "2. フックファイルの権限を確認中..."
if [[ -f ".githooks/pre-commit" ]]; then
    chmod +x .githooks/pre-commit
    log_success "pre-commit フックの実行権限を設定"
else
    log_warning "pre-commit フックが見つかりません"
fi

# 3. 必要なGoツールの確認・インストール提案
log_info "3. 必要なツールの確認中..."

check_and_suggest_install() {
    local tool_name="$1"
    local install_cmd="$2"
    
    if command -v "$tool_name" >/dev/null 2>&1; then
        log_success "$tool_name は既にインストール済み"
    else
        log_warning "$tool_name が見つかりません"
        echo "  インストールコマンド: $install_cmd"
    fi
}

check_and_suggest_install "goimports" "go install golang.org/x/tools/cmd/goimports@latest"
check_and_suggest_install "golangci-lint" "curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b \$(go env GOPATH)/bin v1.55.2"

log_success "=== Git Hooks セットアップ完了 ==="
echo ""
log_info "次回のgit commitから自動的に以下が実行されます："
echo "  - go mod tidy"
echo "  - gofmt -s -w"
echo "  - goimports -w"
echo "  - golangci-lint run"
echo "  - go test -short"
echo ""
log_info "フックを無効にしたい場合: git commit --no-verify" 