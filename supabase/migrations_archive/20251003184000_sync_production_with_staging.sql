-- Sync Production database với Staging
-- Sửa GRANTS, RLS policies, và missing functions

-- ============================================
-- 1. FIX TABLE GRANTS - Change MAINTAIN to ALL
-- ============================================

-- Revoke fragmented grants
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM anon, authenticated, service_role;

-- Grant full permissions like staging
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon;
GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO service_role;

-- ============================================
-- 2. ADD MISSING REALTIME POLICIES
-- ============================================

-- order_lines
DROP POLICY IF EXISTS "realtime_order_lines_read" ON order_lines;
CREATE POLICY "realtime_order_lines_read"
ON order_lines FOR SELECT
TO supabase_realtime_admin
USING (true);

-- order_reviews
DROP POLICY IF EXISTS "realtime_order_reviews_read" ON order_reviews;
CREATE POLICY "realtime_order_reviews_read"
ON order_reviews FOR SELECT
TO supabase_realtime_admin
USING (true);

-- order_service_items
DROP POLICY IF EXISTS "realtime_order_service_items_read" ON order_service_items;
CREATE POLICY "realtime_order_service_items_read"
ON order_service_items FOR SELECT
TO supabase_realtime_admin
USING (true);

-- orders
DROP POLICY IF EXISTS "realtime_orders_read" ON orders;
CREATE POLICY "realtime_orders_read"
ON orders FOR SELECT
TO supabase_realtime_admin
USING (true);

-- profiles
DROP POLICY IF EXISTS "realtime_profiles_read" ON profiles;
CREATE POLICY "realtime_profiles_read"
ON profiles FOR SELECT
TO supabase_realtime_admin
USING (true);

-- work_sessions
DROP POLICY IF EXISTS "realtime_work_sessions_read" ON work_sessions;
CREATE POLICY "realtime_work_sessions_read"
ON work_sessions FOR SELECT
TO supabase_realtime_admin
USING (true);

-- ============================================
-- 3. ADD MISSING POLICY: Allow authenticated users to read profiles
-- ============================================
DROP POLICY IF EXISTS "Allow authenticated users to read profiles" ON profiles;
CREATE POLICY "Allow authenticated users to read profiles"
ON profiles FOR SELECT
TO authenticated
USING (true);
