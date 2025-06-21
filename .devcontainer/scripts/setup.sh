#!/bin/bash

# =============================================================================
# DevContainer 初期化セットアップスクリプト
# 開発環境の完全な初期化を行う
# =============================================================================

set -e

# カラー出力定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# ログ出力関数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_section() {
    echo -e "${CYAN}[SECTION]${NC} $1"
}

# =============================================================================
# メイン処理開始
# =============================================================================

log_section "=== DevContainer 初期セットアップ開始 ==="

# 1. Go環境確認
log_section "1. Go環境の確認"
if command -v go >/dev/null 2>&1; then
    GO_VERSION=$(go version)
    log_success "Go環境確認: $GO_VERSION"
else
    log_warning "Go環境が見つかりません（DevContainer外で実行中の可能性）"
    log_info "このスクリプトはDevContainer内での実行を想定しています"
    exit 0
fi

# 2. 基本Goツールのインストール確認・実行
log_section "2. 基本Goツールのセットアップ"

install_go_tool() {
    local tool_name="$1"
    local install_cmd="$2"
    
    if command -v "$tool_name" >/dev/null 2>&1; then
        log_success "$tool_name は既にインストール済み"
    else
        log_info "$tool_name をインストール中..."
        if eval "$install_cmd"; then
            log_success "$tool_name インストール完了"
        else
            log_warning "$tool_name のインストールに失敗"
fi
    fi
}

# 必須ツールのインストール
install_go_tool "goimports" "go install golang.org/x/tools/cmd/goimports@latest"
install_go_tool "dlv" "go install github.com/go-delve/delve/cmd/dlv@latest"
install_go_tool "swag" "go install github.com/swaggo/swag/cmd/swag@latest"

# 3. Go依存関係の整理
log_section "3. Go依存関係の整理"
if [[ -f "go.mod" ]]; then
    log_info "go mod tidy を実行中..."
    if go mod tidy; then
        log_success "go mod tidy 完了"
    else
        log_warning "go mod tidy でエラーが発生"
    fi
    
    log_info "go mod download を実行中..."
    if go mod download; then
        log_success "go mod download 完了"
    else
        log_warning "go mod download でエラーが発生"
    fi
else
    log_info "go.mod が見つかりません - スキップ"
fi

# 4. Git Hooks セットアップ
log_section "4. Git Hooks セットアップ"
if [[ -f "scripts/setup-hooks.sh" ]]; then
    log_info "Git Hooks を設定中..."
    chmod +x scripts/setup-hooks.sh
    if ./scripts/setup-hooks.sh; then
        log_success "Git Hooks セットアップ完了"
    else
        log_warning "Git Hooks セットアップでエラーが発生"
    fi
else
    log_warning "scripts/setup-hooks.sh が見つかりません"
fi

# 5. 権限設定
log_section "5. ファイル権限の設定"

# scriptsディレクトリ内の全てのshファイルに実行権限付与
if [[ -d "scripts" ]]; then
    find scripts -name "*.sh" -type f -exec chmod +x {} \;
    log_success "scriptsディレクトリの権限設定完了"
fi

# Makefileの権限確認
if [[ -f "Makefile" ]]; then
    log_success "Makefile 確認済み"
fi

# 6. 開発環境の状態確認
log_section "6. 開発環境の状態確認"

# Dockerの確認
if command -v docker >/dev/null 2>&1; then
    log_success "Docker 利用可能"
else
    log_warning "Docker が見つかりません"
fi

# サービス接続確認（非ブロッキング）
log_info "サービス接続確認を実行中..."

# CockroachDBの確認（軽量）
if command -v cockroach >/dev/null 2>&1; then
    log_success "CockroachDB CLI 利用可能"
else
    log_warning "CockroachDB CLI が見つかりません"
fi

# Redisの確認（軽量）
if command -v redis-cli >/dev/null 2>&1; then
    log_success "Redis CLI 利用可能"
else
    log_warning "Redis CLI が見つかりません"
fi

# 7. Git設定の確認・同期
log_section "7. Git設定の確認・同期"

# Git設定の確認
log_info "Git設定を確認中..."

# Git version
if command -v git >/dev/null 2>&1; then
    GIT_VERSION=$(git --version)
    log_success "Git確認: $GIT_VERSION"
else
    log_error "Gitが見つかりません"
    exit 1
fi

# ホストのGit設定を確認・設定
setup_git_config() {
    log_info "Git設定の初期化を実行中..."
    
    # Git設定の確認
    GIT_USER_NAME=$(git config --global user.name 2>/dev/null || echo "")
    GIT_USER_EMAIL=$(git config --global user.email 2>/dev/null || echo "")
    
    if [[ -z "$GIT_USER_NAME" || -z "$GIT_USER_EMAIL" ]]; then
        log_warning "Git設定が不完全です"
        
        # ホストのGit設定をコピー（可能な場合）
        if [[ -f "/tmp/.gitconfig-host" ]]; then
            log_info "ホストのGit設定を適用中..."
            cp /tmp/.gitconfig-host ~/.gitconfig
            log_success "ホストのGit設定を適用しました"
        else
            log_warning "Git設定が見つかりません"
            log_info "手動でGit設定を行ってください:"
            echo "  git config --global user.name \"Your Name\""
            echo "  git config --global user.email \"your.email@example.com\""
        fi
    else
        log_success "Git設定確認済み:"
        echo "  User: $GIT_USER_NAME"
        echo "  Email: $GIT_USER_EMAIL"
    fi
    
    # Git認証情報の確認
    if git config --list | grep -q credential.helper; then
        log_success "Git credential helper 設定済み"
    else
        log_info "Git credential helper を設定中..."
        git config --global credential.helper store
        log_success "Git credential helper 設定完了"
    fi
    
    # SSH Agent の確認
    if [[ -n "$SSH_AUTH_SOCK" ]]; then
        log_success "SSH Agent 利用可能"
        if ssh-add -l >/dev/null 2>&1; then
            SSH_KEYS_COUNT=$(ssh-add -l | wc -l)
            log_success "SSH Keys: $SSH_KEYS_COUNT 個のキーが利用可能"
        else
            log_info "SSH Keys: キーが読み込まれていません"
        fi
    else
        log_warning "SSH Agent が見つかりません"
        log_info "SSH認証を使用する場合、ホストでSSH Agentを起動し、"
        log_info "VS CodeでSSH Agent Forwardingを有効にしてください"
    fi
    
    # Git設定の表示
    log_info "現在のGit設定:"
    echo "  Core Editor: $(git config --global core.editor || echo "未設定")"
    echo "  Default Branch: $(git config --global init.defaultBranch || echo "未設定")"
    echo "  Push Default: $(git config --global push.default || echo "未設定")"
    echo "  Pull Rebase: $(git config --global pull.rebase || echo "未設定")"
    
    # 基本的なGit設定の推奨値を設定
    git config --global init.defaultBranch main || true
    git config --global push.default simple || true
    git config --global pull.rebase false || true
    git config --global core.autocrlf input || true
    git config --global core.editor "code --wait" || true
    
    log_success "Git基本設定完了"
}

setup_git_config

# 8. 環境変数の設定確認
log_section "8. 環境変数の確認"

if [[ -f ".env.example" ]]; then
    if [[ ! -f ".env" ]]; then
        log_info ".env.example から .env をコピー中..."
        cp .env.example .env
        log_success ".env ファイル作成完了"
else
        log_success ".env ファイル 既存"
    fi
else
    log_info ".env.example が見つかりません - スキップ"
fi

# 8. 初期化完了メッセージ
log_section "=== DevContainer 初期セットアップ完了 ==="
echo ""
log_success "🎉 開発環境の準備が完了しました！"
echo ""
log_info "利用可能なコマンド:"
echo "  make help           - 利用可能なコマンド一覧"
echo "  make dev            - 開発サーバー起動"
echo "  make test           - テスト実行"
echo "  make lint           - コード品質チェック"
echo ""
log_info "Git Hooks設定済み - commit時に自動品質チェックが実行されます"
log_info "無効化する場合: git commit --no-verify"
echo ""
log_success "Happy Coding! 🚀"

exit 0 