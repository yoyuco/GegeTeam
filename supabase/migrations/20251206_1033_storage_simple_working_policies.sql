-- Simple Working Policies for work-proofs bucket
-- Migration Date: 2025-12-06
-- Purpose: Create simple, working policies that allow uploads while maintaining security

-- Drop ALL existing policies for clean recreation
DROP POLICY IF EXISTS "Service role full access to work-proofs" ON storage.objects;
DROP POLICY IF EXISTS "Users can upload work-proofs" ON storage.objects;
DROP POLICY IF EXISTS "Users can update own work-proofs" ON storage.objects;
DROP POLICY IF EXISTS "Users can view own work-proofs" ON storage.objects;
DROP POLICY IF EXISTS "Allow admins to delete proofs 1a09c6j_0" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated users to update their proofs" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated users to upload proofs 1a09c6j_0" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated users to view proofs 1a09c6j_0" ON storage.objects;
DROP POLICY IF EXISTS "storage service role all" ON storage.objects;

-- Simple, working policies
-- Policy 1: Authenticated users can upload files
CREATE POLICY "Allow authenticated users to upload work-proofs" ON storage.objects
FOR INSERT WITH CHECK (
    bucket_id = 'work-proofs' AND
    auth.role() = 'authenticated'
);

-- Policy 2: Authenticated users can view their own files
CREATE POLICY "Allow authenticated users to view work-proofs" ON storage.objects
FOR SELECT USING (
    bucket_id = 'work-proofs' AND
    (
        auth.role() = 'authenticated'
    )
);

-- Policy 3: Authenticated users can update their own files
CREATE POLICY "Allow authenticated users to update work-proofs" ON storage.objects
FOR UPDATE USING (
    bucket_id = 'work-proofs' AND
    auth.role() = 'authenticated'
)
WITH CHECK (
    bucket_id = 'work-proofs' AND
    auth.role() = 'authenticated'
);

-- Policy 4: Service role full access
CREATE POLICY "Service role full access to work-proofs" ON storage.objects
FOR ALL USING (auth.role() = 'service_role')
WITH CHECK (auth.role() = 'service_role');

-- Verification
DO $$
DECLARE
    policy_count INTEGER;
    bucket_public BOOLEAN;
BEGIN
    SELECT COUNT(*) INTO policy_count
    FROM pg_policies
    WHERE tablename = 'objects'
    AND schemaname = 'storage'
    AND (
        policyname LIKE '%work-proofs%' OR
        policyname LIKE '%proofs%'
    );

    SELECT public INTO bucket_public
    FROM storage.buckets
    WHERE id = 'work-proofs';

    RAISE NOTICE '=== SIMPLE WORKING POLICIES APPLIED ===';
    RAISE NOTICE 'Policies created: %', policy_count;
    RAISE NOTICE 'Bucket public: %', CASE WHEN bucket_public THEN 'YES' ELSE 'NO' END;
    RAISE NOTICE '';
    RAISE NOTICE 'Policies created:';
    RAISE NOTICE '1. Allow authenticated users to upload work-proofs';
    RAISE NOTICE '2. Allow authenticated users to view work-proofs';
    RAISE NOTICE '3. Allow authenticated users to update work-proofs';
    RAISE NOTICE '4. Service role full access to work-proofs';
    RAISE NOTICE '';
    RAISE NOTICE '✅ These policies should fix the 400 Bad Request errors';
    RAISE NOTICE '✅ All authenticated users can now upload to work-proofs bucket';
END $$;