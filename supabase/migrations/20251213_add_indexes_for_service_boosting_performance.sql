-- Add Performance Indexes for Service Boosting Page
-- Migration Date: 2025-12-13
-- Purpose: Improve query performance for Service Boosting page
-- NOTE: This version adds indexes only. Column changes moved to phase 2.

-- Enable pg_trgm extension for efficient LIKE queries
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- 1. Indexes for JOIN operations
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_order_lines_order_id ON order_lines(order_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_orders_party_id ON orders(party_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_order_lines_variant_id ON order_lines(variant_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_orders_channel_id ON orders(channel_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_order_lines_customer_account_id ON order_lines(customer_account_id);

-- 2. Indexes for filtering
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_orders_game_code_status ON orders(game_code, status)
WHERE status <> 'draft';

-- 3. Full-text search indexes for customer name filtering
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_parties_name_gin ON parties USING gin(to_tsvector('simple', name));

-- 4. Index for work sessions (used in active_farmers CTE)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_work_sessions_order_line_id ON work_sessions(order_line_id, ended_at)
WHERE ended_at IS NULL;

-- 6. Trigram indexes for partial matching (ILIKE '%text%' queries)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_parties_name_trgm ON parties USING gin(name gin_trgm_ops);

-- 7. Indexes for order_service_items (used in line_items CTE)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_order_service_items_order_line_id ON order_service_items(order_line_id);

-- 8. Indexes for service_reports (referenced in line_items CTE)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_service_reports_status ON service_reports(status)
WHERE status = 'new';

-- 9. Index for order_reviews
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_order_reviews_order_line_id ON order_reviews(order_line_id);

-- 10. Additional useful indexes
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_orders_created_at ON orders(created_at DESC);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_orders_updated_at ON orders(updated_at DESC);

-- 11. Individual indexes for sorting (optimized for ORDER BY in get_boosting_orders_v3)
-- These indexes help with the sorting in get_boosting_orders_v3
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_order_lines_status ON order_lines(status);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_order_lines_delivered_at_null ON order_lines(delivered_at) WHERE delivered_at IS NOT NULL;
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_order_lines_delivered_at_sort ON order_lines(delivered_at DESC);

-- NOTE: Phase 2 (column additions) moved to separate migration
-- Phase 2 will add status_order column and trigger when needed

-- Verification
DO $$
BEGIN
    RAISE NOTICE '==========================================';
    RAISE NOTICE 'PERFORMANCE INDEXES ADDED FOR SERVICE BOOSTING';
    RAISE NOTICE '==========================================';
    RAISE NOTICE 'Indexes added:';
    RAISE NOTICE '- JOIN indexes: order_lines, orders, parties tables';
    RAISE NOTICE '- Filter indexes: game_code, status, customer_name';
    RAISE NOTICE '- Sorting indexes: status, delivered_at optimizations';
    RAISE NOTICE '- Text search: Full-text and trigram indexes';
    RAISE NOTICE '- Additional performance indexes for timestamps';
    RAISE NOTICE '==========================================';
END $$;