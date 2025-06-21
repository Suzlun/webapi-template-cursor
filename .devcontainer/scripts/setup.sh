#!/bin/bash
set -e

echo "🚀 WebAPI Template DevContainer セットアップ開始..."

# 基本情報表示
echo "📋 環境情報:"
echo "  - Go version: $(go version)"
echo "  - User: $(whoami)"
echo "  - Workspace: $(pwd)"

# Go モジュール初期化
if [ ! -f go.mod ]; then
    echo "📦 Go module 初期化中..."
    go mod init webapi-template
    echo "✅ Go module initialized"
fi

# 基本的な設定のみ
echo "⚙️  基本設定中..."

# Git設定（if not already configured）
if [ -z "$(git config --global user.name)" ]; then
    git config --global init.defaultBranch main
    echo "ℹ️  Git設定は必要に応じて手動で行ってください"
fi

# ディレクトリ構造作成
mkdir -p cmd/server
mkdir -p internal/{handler,usecase,domain,infrastructure}
mkdir -p pkg/{logger,middleware}
mkdir -p tests/{unit,integration,e2e}
mkdir -p docs/api

echo "📁 基本ディレクトリ構造を作成しました"

# サービス起動確認
echo "🔍 サービス起動確認中..."

# CockroachDB 待機（簡単な確認のみ）
echo "⏳ CockroachDB 起動待機中..."
for i in {1..30}; do
    if cockroach sql --insecure --host=cockroachdb --execute="SELECT 1;" > /dev/null 2>&1; then
        echo "✅ CockroachDB 接続確認"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "⚠️  CockroachDB 接続に時間がかかっています（後で確認してください）"
    fi
    sleep 2
done

# Redis 簡単な確認
if command -v redis-cli >/dev/null 2>&1; then
    if redis-cli -h redis ping > /dev/null 2>&1; then
        echo "✅ Redis 接続確認"
    else
        echo "⚠️  Redis 接続を確認してください"
    fi
fi

echo ""
echo "🎉 基本セットアップ完了！"
echo ""
echo "📚 次のステップ:"
echo "  1. go mod tidy でモジュールを整理"
echo "  2. 必要に応じて追加ツールをインストール:"
echo "     - make install-tools (golangci-lint等)"
echo "  3. サービスアクセス:"
echo "     - API Server: http://localhost:8080"
echo "     - CockroachDB Admin: http://localhost:8090"
echo "     - Jaeger UI: http://localhost:16686"
echo ""
echo "🚀 Happy Coding!" 