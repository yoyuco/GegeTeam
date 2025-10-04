-- Fix RLS policy for attribute_relationships table

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

-- Grant permission
GRANT SELECT ON attribute_relationships TO authenticated;
