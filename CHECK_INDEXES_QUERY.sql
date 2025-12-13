-- Query nhanh để kiểm tra indexes
-- Copy và chạy trực tiếp vào psql

SELECT
    '=== SERVICE BOOSTING INDEXES VERIFICATION ===' as info;

-- 1. Kiểm tra pg_trgm extension
SELECT
    'pg_trgm Extension' as item,
    CASE WHEN extname IS NOT NULL THEN '✅ Enabled' ELSE '❌ Not found' END as status
FROM pg_extension
WHERE extname = 'pg_trgm';

-- 2. Kiểm tra từng index
SELECT
    indexname as item,
    CASE WHEN indexname IS NOT NULL THEN '✅ Created' ELSE '❌ Missing' END as status,
    tablename
FROM pg_indexes
WHERE indexname IN (
    'idx_order_lines_order_id',
    'idx_orders_party_id',
    'idx_order_lines_variant_id',
    'idx_orders_channel_id',
    'idx_order_lines_customer_account_id',
    'idx_orders_game_code_status',
    'idx_orders_status',
    'idx_parties_name_gin',
    'idx_parties_name_trgm',
    'idx_work_sessions_order_line_id',
    'idx_order_service_items_order_line_id',
    'idx_service_reports_status',
    'idx_order_reviews_order_line_id',
    'idx_orders_created_at',
    'idx_orders_updated_at',
    'idx_orders_delivered_at',
    'idx_order_lines_status',
    'idx_order_lines_delivered_at_null',
    'idx_order_lines_delivered_at_sort'
)
ORDER BY tablename, indexname;

-- 3. Thống kê tổng quan
SELECT
    '=== SUMMARY ===' as info;

SELECT
    'Total indexes created' as item,
    COUNT(*)::text || '/18' as status
FROM pg_indexes
WHERE indexname IN (
    'idx_order_lines_order_id',
    'idx_orders_party_id',
    'idx_order_lines_variant_id',
    'idx_orders_channel_id',
    'idx_order_lines_customer_account_id',
    'idx_orders_game_code_status',
    'idx_orders_status',
    'idx_parties_name_gin',
    'idx_parties_name_trgm',
    'idx_work_sessions_order_line_id',
    'idx_order_service_items_order_line_id',
    'idx_service_reports_status',
    'idx_order_reviews_order_line_id',
    'idx_orders_created_at',
    'idx_orders_updated_at',
    'idx_orders_delivered_at',
    'idx_order_lines_status',
    'idx_order_lines_delivered_at_null',
    'idx_order_lines_delivered_at_sort'
);