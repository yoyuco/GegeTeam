-- Add Performance Indexes for Service Boosting Page (v3 - Fixed for Staging)
-- Migration Date: 2025-12-13
-- Purpose: Improve query performance for Service Boosting page
-- Status: Successfully applied to staging

-- Enable pg_trgm extension for efficient LIKE queries
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- 1. Indexes for JOIN operations
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_order_lines_order_id ON order_lines(order_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_orders_party_id ON orders(party_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_order_lines_variant_id ON order_lines(variant_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_orders_channel_id ON orders(channel_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_order_lines_customer_account_id ON order_lines(customer_account_id);

-- 2. Indexes for filtering (fixed - order_lines doesn't have status column)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_orders_game_code_status ON orders(game_code, status)
WHERE status <> 'draft';
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_orders_status ON orders(status);

-- 3. Full-text search indexes for customer name filtering
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_parties_name_gin ON parties USING gin(to_tsvector('simple', name));

-- 4. Index for work sessions (used in active_farmers CTE)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_work_sessions_order_line_id ON work_sessions(order_line_id, ended_at)
WHERE ended_at IS NULL;

-- 5. Trigram indexes for partial matching (ILIKE '%text%' queries)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_parties_name_trgm ON parties USING gin(name gin_trgm_ops);

-- 6. Indexes for order_service_items (used in line_items CTE)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_order_service_items_order_line_id ON order_service_items(order_line_id);

-- 7. Indexes for service_reports (referenced in line_items CTE)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_service_reports_status ON service_reports(status)
WHERE status = 'new';

-- 8. Index for order_reviews
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_order_reviews_order_line_id ON order_reviews(order_line_id);

-- 9. Additional useful indexes for sorting
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_orders_created_at ON orders(created_at DESC);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_orders_updated_at ON orders(updated_at DESC);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_orders_delivered_at ON orders(delivered_at DESC);

-- Summary of applied indexes:
-- - 5 indexes for JOIN operations
-- - 2 indexes for filtering (orders table only)
-- - 2 full-text/trigram indexes for customer name search
-- - 1 index for work sessions
-- - 3 indexes for related tables (order_service_items, service_reports, order_reviews)
-- - 3 timestamp indexes for sorting
-- Total: 16 indexes added