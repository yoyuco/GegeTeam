-- Fix RLS policies for order-related tables
-- Tables: orders, order_lines, order_service_items, work_sessions, order_reviews

-- ============================================
-- 1. orders table
-- ============================================
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "authenticated_read_orders" ON orders;
CREATE POLICY "authenticated_read_orders"
ON orders FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "authenticated_update_orders" ON orders;
CREATE POLICY "authenticated_update_orders"
ON orders FOR UPDATE TO authenticated USING (true);

GRANT SELECT, UPDATE ON orders TO authenticated;

-- ============================================
-- 2. order_lines table
-- ============================================
ALTER TABLE order_lines ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "authenticated_read_order_lines" ON order_lines;
CREATE POLICY "authenticated_read_order_lines"
ON order_lines FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "authenticated_update_order_lines" ON order_lines;
CREATE POLICY "authenticated_update_order_lines"
ON order_lines FOR UPDATE TO authenticated USING (true);

GRANT SELECT, UPDATE ON order_lines TO authenticated;

-- ============================================
-- 3. order_service_items table
-- ============================================
ALTER TABLE order_service_items ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "authenticated_read_order_service_items" ON order_service_items;
CREATE POLICY "authenticated_read_order_service_items"
ON order_service_items FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "authenticated_update_order_service_items" ON order_service_items;
CREATE POLICY "authenticated_update_order_service_items"
ON order_service_items FOR UPDATE TO authenticated USING (true);

GRANT SELECT, UPDATE ON order_service_items TO authenticated;

-- ============================================
-- 4. work_sessions table
-- ============================================
ALTER TABLE work_sessions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "authenticated_read_work_sessions" ON work_sessions;
CREATE POLICY "authenticated_read_work_sessions"
ON work_sessions FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "authenticated_insert_work_sessions" ON work_sessions;
CREATE POLICY "authenticated_insert_work_sessions"
ON work_sessions FOR INSERT TO authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "authenticated_update_work_sessions" ON work_sessions;
CREATE POLICY "authenticated_update_work_sessions"
ON work_sessions FOR UPDATE TO authenticated USING (true);

DROP POLICY IF EXISTS "authenticated_delete_work_sessions" ON work_sessions;
CREATE POLICY "authenticated_delete_work_sessions"
ON work_sessions FOR DELETE TO authenticated USING (true);

GRANT SELECT, INSERT, UPDATE, DELETE ON work_sessions TO authenticated;

-- ============================================
-- 5. order_reviews table
-- ============================================
ALTER TABLE order_reviews ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "authenticated_read_order_reviews" ON order_reviews;
CREATE POLICY "authenticated_read_order_reviews"
ON order_reviews FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "authenticated_insert_order_reviews" ON order_reviews;
CREATE POLICY "authenticated_insert_order_reviews"
ON order_reviews FOR INSERT TO authenticated WITH CHECK (true);

GRANT SELECT, INSERT ON order_reviews TO authenticated;

-- ============================================
-- 6. Additional tables that might be needed
-- ============================================

-- parties table (for customer info)
ALTER TABLE parties ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "authenticated_read_parties" ON parties;
CREATE POLICY "authenticated_read_parties"
ON parties FOR SELECT TO authenticated USING (true);
GRANT SELECT ON parties TO authenticated;

-- product_variants table (for service types)
ALTER TABLE product_variants ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "authenticated_read_product_variants" ON product_variants;
CREATE POLICY "authenticated_read_product_variants"
ON product_variants FOR SELECT TO authenticated USING (true);
GRANT SELECT ON product_variants TO authenticated;

-- order_line_assignees table (for assignees) - skip if not exists
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'order_line_assignees') THEN
    ALTER TABLE order_line_assignees ENABLE ROW LEVEL SECURITY;
    DROP POLICY IF EXISTS "authenticated_read_order_line_assignees" ON order_line_assignees;
    CREATE POLICY "authenticated_read_order_line_assignees"
    ON order_line_assignees FOR SELECT TO authenticated USING (true);
    GRANT SELECT ON order_line_assignees TO authenticated;
  END IF;
END $$;
