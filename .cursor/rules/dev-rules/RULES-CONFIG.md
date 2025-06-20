# Cursor Rules 設定ガイド

## 概要

このドキュメントは、各ルールファイルの設定とその読み込みタイミングを説明します。

## MDC ファイル形式

Cursor のルールファイルは MDC（Markdown with Context）形式で記述します。各ファイルの先頭には以下のメタデータを含めます：

```markdown
---
description: "ルールの説明（AIが選択判断に使用）"
globs: "**/*.go,**/*.ts" # ファイルパターン（カンマ区切り）
alwaysApply: true/false # 常時適用するかどうか
---
```

## ルール適用パターン

### 1. alwaysApply: true（常時適用）

**説明**: プロジェクト全体で常に適用されるルール
**読み込みタイミング**: 常時
**メモリ使用量**: 高
**適用ルール**:

- `golang-coding-rules.mdc`: Go 言語の基本コーディング規約
- `architecture-rules.mdc`: Clean Architecture とレイヤー設計

### 2. alwaysApply: false + globs 設定（ファイルパターン適用）

**説明**: 特定のファイルパターンで作業する際に適用されるルール
**読み込みタイミング**: 対象ファイルを開いた時、または関連するファイルで作業中
**メモリ使用量**: 中
**適用ルール**:

#### API 関連

- `api-design-rules.mdc`
- **対象ファイル**: `**/handler/**/*.go,**/api/**/*.go,**/*_handler.go,**/*handler*.go`

#### データベース関連

- `database-rules.mdc`
- **対象ファイル**: `**/infrastructure/database/**/*.go,**/repository/**/*.go,**/*_repository*.go,**/migration/**/*.go,**/cache/**/*.go`

#### テスト関連

- `testing-rules.mdc`
- `tdd-rules.mdc`
- **対象ファイル**: `**/*_test.go,**/tests/**/*.go,**/test/**/*.go`

#### OpenAPI 関連

- `openapi-rules.mdc`
- **対象ファイル**: `**/api/**/*.yaml,**/api/**/*.yml,**/swagger/**/*.go,**/docs/**/*.yaml,**/openapi/**/*,**/*swagger*.go`

### 3. alwaysApply: false + description 設定（AI 判断による適用）

**説明**: AI が説明文を参考に必要性を判断して適用するルール
**読み込みタイミング**: AI が関連性を判断した時のみ
**メモリ使用量**: 低

### 4. alwaysApply: false + globs 空（手動参照のみ）

**説明**: 明示的に参照された時のみ読み込まれるルール
**読み込みタイミング**: @記法で明示的にルールを参照した時のみ
**メモリ使用量**: 最低
**適用ルール**:

- `README-rules-summary.mdc`: 全ルールの概要とガイドライン

## パフォーマンス最適化

### メモリ使用量の最小化

1. **alwaysApply: true**: 必須ルールのみに限定
2. **globs**: ファイルパターンを正確に指定
3. **description**: 参考資料は必要時のみ読み込み

### ファイルパターンマッチング効率化

```
# 効率的なパターン（推奨）
**/handler/**/*.go
**/*_test.go

# 非効率的なパターン（避ける）
**/*
**/.*
```

## ファイルパターン説明

### Go 言語関連

```
**/*.go                    # すべてのGoファイル
**/internal/**/*.go        # internal配下のGoファイル
**/pkg/**/*.go            # pkg配下のGoファイル
**/cmd/**/*.go            # cmd配下のGoファイル
```

### API 関連

```
**/handler/**/*.go        # ハンドラーディレクトリ
**/api/**/*.go           # APIディレクトリ
**/*_handler.go          # _handlerサフィックス
**/*handler*.go          # handlerを含むファイル
```

### データベース関連

```
**/repository/**/*.go     # リポジトリディレクトリ
**/*_repository*.go       # _repositoryを含むファイル
**/migration/**/*.go      # マイグレーションディレクトリ
**/cache/**/*.go         # キャッシュディレクトリ
```

### テスト関連

```
**/*_test.go             # テストファイル
**/tests/**/*.go         # testsディレクトリ
**/test/**/*.go          # testディレクトリ
```

### OpenAPI 関連

```
**/api/**/*.yaml         # API仕様ディレクトリのYAML
**/api/**/*.yml          # API仕様ディレクトリのYML
**/swagger/**/*.go       # Swaggerディレクトリ
**/docs/**/*.yaml        # docsディレクトリのYAML
**/openapi/**/*          # openAPIディレクトリ
**/*swagger*.go          # swaggerを含むファイル
```

## トラブルシューティング

### ルールが適用されない場合

1. ファイルパターンを確認
2. alwaysApply 設定が適切に設定されているか確認
3. description 設定を確認

### パフォーマンスが悪い場合

1. `alwaysApply: true` ルールを減らす
2. ファイルパターンをより具体的に指定
3. 不要なルールを手動参照形式に変更

### 設定変更時の注意点

1. Cursor を再起動してルール設定を反映
2. ファイルパターンの変更後は動作確認を実施
3. チーム内でルール設定を共有

## 使用例

### 新しい API ハンドラーを作成する場合

1. `**/handler/**/*.go` に該当するファイルを作成
2. 自動的に `api-design-rules.mdc` が読み込まれる
3. RESTful API 設計規則が適用される

### テストファイルを作成する場合

1. `**/*_test.go` パターンのファイルを作成
2. `testing-rules.mdc` と `tdd-rules.mdc` が読み込まれる
3. テスト設計と TDD 規則が適用される

### データベースリポジトリを実装する場合

1. `**/repository/**/*.go` または `**/*_repository*.go` ファイルを作成
2. `database-rules.mdc` が読み込まれる
3. GORM、PostgreSQL、Redis 関連の規則が適用される

## 重要な技術カバレッジ

### ✅ **新規追加（v2.0）**

#### **分散トレーシング（OpenTelemetry）**

- **実装場所**: `golang-coding-rules.mdc`
- **カバー内容**:
  - OpenTelemetry セットアップ（Jaeger/OTLP 対応）
  - ミドルウェア実装（HTTP トレーシング）
  - サービス層・リポジトリ層でのスパン管理
  - エラートレーシングと構造化属性
  - ベストプラクティス（適切なスパン分割）

#### **Kubernetes 対応**

- **実装場所**: `database-rules.mdc`
- **カバー内容**:
  - Docker マルチステージビルド最適化
  - Kubernetes マニフェスト（Deployment/Service/Ingress）
  - ヘルスチェック実装（Liveness/Readiness/Startup）
  - Graceful Shutdown
  - HPA/PDB 設定
  - 構造化ログ（JSON 出力）
  - PostgreSQL クラスタ対応

### **アンチパターン対策強化**

#### **新たに対策されたパターン**

- **Observability Anti-patterns**: 過度なスパン分割、トレース情報の不足
- **Container Anti-patterns**: 非効率な Docker ビルド、セキュリティリスク
- **Kubernetes Anti-patterns**: 不適切な Resource 設定、ヘルスチェック不備

### **プロダクション対応レベル**

本ルールセットにより以下のプロダクション要件をカバー：

✅ **高可用性**: Kubernetes HPA/PDB、PostgreSQL クラスタ対応  
✅ **可観測性**: OpenTelemetry、構造化ログ、メトリクス統合  
✅ **セキュリティ**: 非 root コンテナ、readOnlyRootFilesystem、Secret 管理  
✅ **スケーラビリティ**: 水平スケーリング、リソース最適化  
✅ **運用性**: Graceful Shutdown、ヘルスチェック、設定外部化
