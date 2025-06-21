-- =============================================================================
-- CockroachDB 初期化スクリプト
-- =============================================================================

-- 開発用データベース作成
CREATE DATABASE IF NOT EXISTS webapi_dev;

-- 本番環境用データベース（将来用）
CREATE DATABASE IF NOT EXISTS webapi_prod;

-- テスト用データベース
CREATE DATABASE IF NOT EXISTS webapi_test;

-- データベース使用
USE webapi_dev;

-- CockroachDB v25.2 特有の設定
SET sql_safe_updates = false;

-- 時間帯設定
SET TIME ZONE 'Asia/Tokyo';

-- データベース情報表示
SELECT 
    'CockroachDB Database Initialized' AS status,
    version() AS version,
    current_database() AS current_db,
    current_user() AS current_user,
    current_timestamp AS initialized_at; 