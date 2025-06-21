# =============================================================================
# 開発環境用 Dockerfile (Go 1.24 + 開発ツール)
# =============================================================================

# 軽量化されたDevContainer - 素早い起動を優先
FROM golang:1.24-bullseye AS base

# 基本的なシステムパッケージのインストール
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    unzip \
    vim \
    nano \
    htop \
    jq \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Go環境設定
ENV GO111MODULE=on \
    GOPROXY=https://proxy.golang.org,direct \
    GOSUMDB=sum.golang.org \
    CGO_ENABLED=0 \
    GOPATH=/go \
    GOROOT=/usr/local/go

# 作業ディレクトリ設定
WORKDIR /workspace

# 開発環境用のターゲット
FROM base AS development

# 非rootユーザー作成
RUN groupadd --gid 1000 vscode \
    && useradd --uid 1000 --gid vscode --shell /bin/bash --create-home vscode

# 基本的なGoツールのみインストール（軽量化）
RUN go install golang.org/x/tools/gopls@latest && \
    go install golang.org/x/tools/cmd/goimports@latest && \
    go install github.com/go-delve/delve/cmd/dlv@latest && \
    go install github.com/swaggo/swag/cmd/swag@latest

# CockroachDB CLIのインストール
RUN curl https://binaries.cockroachdb.com/cockroach-v25.2.0.linux-amd64.tgz | tar -xz && \
    cp -i cockroach-v25.2.0.linux-amd64/cockroach /usr/local/bin/ && \
    rm -rf cockroach-v25.2.0.linux-amd64

# 開発用ディレクトリの準備
RUN mkdir -p /workspace && \
    chown -R vscode:vscode /workspace && \
    chown -R vscode:vscode /go

# ユーザー切り替え
USER vscode

# デフォルトコマンド
CMD ["bash"]

# -----------------------------------------
# Production Stage（将来用）
# -----------------------------------------
FROM alpine:3.19 AS production

# 最小限のランタイム環境
RUN apk --no-cache add ca-certificates tzdata

WORKDIR /app

# アプリケーションバイナリ（将来的にコピー）
# COPY --from=builder /app/main .

# 非rootユーザー
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

USER appuser

EXPOSE 8080

# 将来的にはアプリケーションバイナリを実行
# CMD ["./main"] 