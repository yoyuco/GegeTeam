-- Query để kiểm tra các index đã thêm cho Service Boosting performance
-- Chạy trên production để verify

-- Kiểm tra tất cả các index đã tạo
SELECT
    schemaname,
    tablename,
    indexname,
    indexdef
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

-- Kiểm tra pg_trgm extension đã được enable chưa
SELECT extname, extversion
FROM pg_extension
WHERE extname = 'pg_trgm';

-- Thống kê số lượng index đã tạo theo bảng
SELECT
    tablename,
    COUNT(*) as index_count,
    STRING_AGG(indexname, ', ' ORDER BY indexname) as indexes_created
FROM pg_indexes
WHERE indexname LIKE 'idx_%'
AND tablename IN ('orders', 'order_lines', 'parties', 'work_sessions', 'order_service_items', 'service_reports', 'order_reviews')
GROUP BY tablename
ORDER BY tablename;

-- Tổng hợp
SELECT
    'Service Boosting Indexes' as description,
    COUNT(*) as total_indexes,
    STRING_AGG(DISTINCT tablename, ', ' ORDER BY tablename) as tables_affected
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