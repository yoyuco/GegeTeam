-- Fix RLS policies for production database
-- Tables: profiles, attributes

-- ============================================
-- 1. Enable RLS on profiles table
-- ============================================
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "Allow authenticated users to read profiles" ON profiles;
DROP POLICY IF EXISTS "Users can read all profiles" ON profiles;
DROP POLICY IF EXISTS "authenticated_read_profiles" ON profiles;

-- Create policy for authenticated users to read profiles
CREATE POLICY "authenticated_read_profiles"
ON profiles
FOR SELECT
TO authenticated
USING (true);

-- ============================================
-- 2. Enable RLS on attributes table
-- ============================================
ALTER TABLE attributes ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "Allow authenticated users to read attributes" ON attributes;
DROP POLICY IF EXISTS "Users can read all attributes" ON attributes;
DROP POLICY IF EXISTS "authenticated_read_attributes" ON attributes;

-- Create policy for authenticated users to read attributes
CREATE POLICY "authenticated_read_attributes"
ON attributes
FOR SELECT
TO authenticated
USING (true);

-- ============================================
-- 3. Enable RLS on attribute_relationships table
-- ============================================
ALTER TABLE attribute_relationships ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "Allow authenticated users to read attribute_relationships" ON attribute_relationships;
DROP POLICY IF EXISTS "Users can read all attribute_relationships" ON attribute_relationships;
DROP POLICY IF EXISTS "authenticated_read_attribute_relationships" ON attribute_relationships;

-- Create policy for authenticated users to read attribute_relationships
CREATE POLICY "authenticated_read_attribute_relationships"
ON attribute_relationships
FOR SELECT
TO authenticated
USING (true);

-- ============================================
-- 4. Grant necessary permissions
-- ============================================
GRANT SELECT ON profiles TO authenticated;
GRANT SELECT ON attributes TO authenticated;
GRANT SELECT ON attribute_relationships TO authenticated;
