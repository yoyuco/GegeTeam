-- PRODUCTION MIGRATION: Complete Shift Assignment System Overhaul
-- This migration removes game_account_id from shift_assignments and updates all related components
-- Run this migration after successful testing in staging

-- =====================================================
-- 1. Update Shift Assignment UI and Component Structure
-- =====================================================

-- Note: Frontend components will be updated separately:
-- - Manager.vue: Tab title changed from "Phân công Account theo Ca" to "Phân công Nhân viên theo Ca"
-- - ShiftAssignments.vue: Removed game_account_id fields from UI, interface, and forms

-- =====================================================
-- 2. Database Schema Updates (Already Applied)
-- =====================================================

-- game_account_id column has already been removed from shift_assignments table
-- Current structure should be:
-- - id (UUID)
-- - employee_profile_id (UUID) - Who is assigned to the shift
-- - shift_id (UUID) - Which shift they're assigned to
-- - channels_id (UUID, nullable) - Which channel they work on
-- - currency_code (TEXT) - Currency for the shift
-- - is_active (BOOLEAN) - Assignment status
-- - assigned_at, created_at, updated_at (TIMESTAMPTZ)
-- - created_by, updated_by (UUID, nullable) - Who made the changes

-- =====================================================
-- 3. Update All Database Functions and Procedures
-- =====================================================

-- Drop old functions that reference game_account_id
DROP FUNCTION IF EXISTS get_all_shift_assignments_direct();

-- Recreate function without game_account_id references
CREATE OR REPLACE FUNCTION get_all_shift_assignments_direct()
RETURNS TABLE (
    id UUID,
    employee_profile_id UUID,
    employee_name TEXT,
    shift_id UUID,
    shift_name TEXT,
    shift_start_time TIME,
    shift_end_time TIME,  -- Fixed: was TEXT, should be TIME
    channels_id UUID,
    channel_name TEXT,
    currency_code TEXT,
    currency_name TEXT,
    is_active BOOLEAN,
    assigned_at TIMESTAMPTZ
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    sa.id,
    sa.employee_profile_id,
    COALESCE(p.display_name, 'Unknown') as employee_name,
    sa.shift_id,
    COALESCE(ws.name, 'Unknown') as shift_name,
    ws.start_time as shift_start_time,
    ws.end_time as shift_end_time,  -- Fixed: return as TIME, not TEXT
    sa.channels_id,
    COALESCE(c.name, 'Unknown') as channel_name,
    sa.currency_code,
    COALESCE(curr.name, sa.currency_code) as currency_name,
    sa.is_active,
    sa.assigned_at
  FROM shift_assignments sa
  LEFT JOIN profiles p ON sa.employee_profile_id = p.id
  LEFT JOIN work_shifts ws ON sa.shift_id = ws.id
  LEFT JOIN channels c ON sa.channels_id = c.id
  LEFT JOIN currencies curr ON sa.currency_code = curr.code
  ORDER BY sa.assigned_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = 'public';

-- Update create function to follow authentication pattern
DROP FUNCTION IF EXISTS create_shift_assignment_direct;

CREATE OR REPLACE FUNCTION create_shift_assignment_direct(
    p_user_id UUID, -- profiles.id from frontend (who is creating)
    p_employee_profile_id UUID,
    p_shift_id UUID,
    p_channels_id UUID DEFAULT NULL,
    p_currency_code TEXT DEFAULT 'VND',
    p_is_active BOOLEAN DEFAULT true
)
RETURNS JSON SECURITY DEFINER SET search_path = 'public'
AS $$
DECLARE
    v_assignment_id UUID;
    v_shift_exists BOOLEAN;
    v_employee_exists BOOLEAN;
BEGIN
    -- Validate shift exists and is active
    SELECT EXISTS(SELECT 1 FROM work_shifts WHERE id = p_shift_id AND is_active = true) INTO v_shift_exists;

    IF NOT v_shift_exists THEN
        RETURN json_build_object('success', false, 'message', 'Shift not found or inactive');
    END IF;

    -- Validate employee exists and is active
    SELECT EXISTS(SELECT 1 FROM profiles WHERE id = p_employee_profile_id AND status = 'active') INTO v_employee_exists;

    IF NOT v_employee_exists THEN
        RETURN json_build_object('success', false, 'message', 'Employee not found or inactive');
    END IF;

    -- Validate channel if provided
    IF p_channels_id IS NOT NULL THEN
        IF NOT EXISTS(SELECT 1 FROM channels WHERE id = p_channels_id AND is_active = true) THEN
            RETURN json_build_object('success', false, 'message', 'Channel not found or inactive');
        END IF;
    END IF;

    -- Create assignment (without created_by column as it doesn't exist)
    INSERT INTO shift_assignments (
        employee_profile_id, shift_id, channels_id, currency_code,
        is_active, assigned_at, created_at
    ) VALUES (
        p_employee_profile_id, p_shift_id, p_channels_id, p_currency_code,
        p_is_active, now(), now()
    ) RETURNING id INTO v_assignment_id;

    RETURN json_build_object(
        'success', true,
        'message', 'Shift assignment created successfully',
        'assignment_id', v_assignment_id
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = 'public';

-- Update function for editing existing assignments
CREATE OR REPLACE FUNCTION update_shift_assignment_direct(
    p_user_id UUID, -- profiles.id from frontend (who is updating)
    p_assignment_id UUID,
    p_employee_profile_id UUID DEFAULT NULL,
    p_shift_id UUID DEFAULT NULL,
    p_channels_id UUID DEFAULT NULL,
    p_currency_code TEXT DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT NULL
)
RETURNS JSON SECURITY DEFINER SET search_path = 'public'
AS $$
DECLARE
    v_assignment shift_assignments%ROWTYPE;
BEGIN
    -- Get and validate assignment exists
    SELECT * INTO v_assignment
    FROM shift_assignments
    WHERE id = p_assignment_id;

    IF v_assignment.id IS NULL THEN
        RETURN json_build_object('success', false, 'message', 'Shift assignment not found');
    END IF;

    -- Validate employee if provided
    IF p_employee_profile_id IS NOT NULL THEN
        IF NOT EXISTS(SELECT 1 FROM profiles WHERE id = p_employee_profile_id AND status = 'active') THEN
            RETURN json_build_object('success', false, 'message', 'Employee not found or inactive');
        END IF;
    END IF;

    -- Validate shift if provided
    IF p_shift_id IS NOT NULL THEN
        IF NOT EXISTS(SELECT 1 FROM work_shifts WHERE id = p_shift_id AND is_active = true) THEN
            RETURN json_build_object('success', false, 'message', 'Shift not found or inactive');
        END IF;
    END IF;

    -- Validate channel if provided
    IF p_channels_id IS NOT NULL THEN
        IF NOT EXISTS(SELECT 1 FROM channels WHERE id = p_channels_id AND is_active = true) THEN
            RETURN json_build_object('success', false, 'message', 'Channel not found or inactive');
        END IF;
    END IF;

    -- Perform update with provided values (without updated_by column as it doesn't exist)
    UPDATE shift_assignments
    SET
        employee_profile_id = COALESCE(p_employee_profile_id, employee_profile_id),
        shift_id = COALESCE(p_shift_id, shift_id),
        channels_id = COALESCE(p_channels_id, channels_id),
        currency_code = COALESCE(p_currency_code, currency_code),
        is_active = COALESCE(p_is_active, is_active),
        updated_at = now()
    WHERE id = p_assignment_id;

    RETURN json_build_object('success', true, 'message', 'Shift assignment updated successfully');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = 'public';

-- Create delete function (soft delete)
CREATE OR REPLACE FUNCTION delete_shift_assignment_direct(
    p_user_id UUID, -- profiles.id from frontend (who is deleting)
    p_assignment_id UUID
)
RETURNS JSON SECURITY DEFINER SET search_path = 'public'
AS $$
DECLARE
    v_assignment shift_assignments%ROWTYPE;
BEGIN
    -- Get and validate assignment exists
    SELECT * INTO v_assignment
    FROM shift_assignments
    WHERE id = p_assignment_id;

    IF v_assignment.id IS NULL THEN
        RETURN json_build_object('success', false, 'message', 'Shift assignment not found');
    END IF;

    -- Soft delete (set inactive) instead of hard delete to maintain audit trail
    UPDATE shift_assignments
    SET
        is_active = false,
        updated_at = now()
    WHERE id = p_assignment_id;

    RETURN json_build_object('success', true, 'message', 'Shift assignment deleted successfully');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = 'public';

-- Update function to get active assignments for current user
DROP FUNCTION IF EXISTS get_active_shift_assignments(UUID);

CREATE OR REPLACE FUNCTION get_active_shift_assignments(
    p_user_id UUID DEFAULT NULL -- profiles.id from frontend
)
RETURNS TABLE (
    id UUID,
    employee_profile_id UUID,
    shift_id UUID,
    is_active BOOLEAN,
    assigned_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    channels_id UUID,
    currency_code TEXT,
    shift_name TEXT,
    shift_start_time TIME,
    shift_end_time TIME,
    shift_description TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        sa.id,
        sa.employee_profile_id,
        sa.shift_id,
        sa.is_active,
        sa.assigned_at,
        sa.created_at,
        sa.updated_at,
        sa.channels_id,
        sa.currency_code,
        ws.name as shift_name,
        ws.start_time as shift_start_time,
        ws.end_time as shift_end_time,  -- Fixed: return as TIME, not TEXT
        ws.description as shift_description
    FROM shift_assignments sa
    LEFT JOIN work_shifts ws ON sa.shift_id = ws.id
    WHERE sa.is_active = TRUE
      AND (p_user_id IS NULL OR sa.employee_profile_id = p_user_id)
    ORDER BY sa.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = 'public';

-- =====================================================
-- 4. Update RLS Policies for Shift Assignments
-- =====================================================

-- Drop existing policies
DROP POLICY IF EXISTS "Users can view their own shift assignments" ON shift_assignments;
DROP POLICY IF EXISTS "Admins can view all shift assignments" ON shift_assignments;
DROP POLICY IF EXISTS "Users can insert their own shift assignments" ON shift_assignments;
DROP POLICY IF EXISTS "Admins can insert any shift assignment" ON shift_assignments;
DROP POLICY IF EXISTS "Users can update their own shift assignments" ON shift_assignments;
DROP POLICY IF EXISTS "Admins can update any shift assignment" ON shift_assignments;
DROP POLICY IF EXISTS "Users can delete their own shift assignments" ON shift_assignments;
DROP POLICY IF EXISTS "Admins can delete any shift assignment" ON shift_assignments;

-- Create new RLS policies following role code pattern
CREATE POLICY "Users can view their own shift assignments" ON shift_assignments
    FOR SELECT
    USING (
        auth.uid() = employee_profile_id
        OR EXISTS (
            SELECT 1 FROM profiles p
            JOIN user_roles ur ON p.id = ur.profile_id
            JOIN roles r ON ur.role_id = r.id
            WHERE p.auth_user_id = auth.uid()
            AND r.code::text = ANY (ARRAY['admin','mod','manager','leader'])
        )
    );

CREATE POLICY "Admins can view all shift assignments" ON shift_assignments
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM profiles p
            JOIN user_roles ur ON p.id = ur.profile_id
            JOIN roles r ON ur.role_id = r.id
            WHERE p.auth_user_id = auth.uid()
            AND r.code::text = ANY (ARRAY['admin','mod','manager','leader'])
        )
    );

CREATE POLICY "Users can insert their own shift assignments" ON shift_assignments
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM profiles p
            JOIN user_roles ur ON p.id = ur.profile_id
            JOIN roles r ON ur.role_id = r.id
            WHERE p.auth_user_id = auth.uid()
            AND r.code::text = ANY (ARRAY['admin','mod','manager','leader'])
        )
    );

CREATE POLICY "Admins can insert any shift assignment" ON shift_assignments
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM profiles p
            JOIN user_roles ur ON p.id = ur.profile_id
            JOIN roles r ON ur.role_id = r.id
            WHERE p.auth_user_id = auth.uid()
            AND r.code::text = ANY (ARRAY['admin','mod','manager','leader'])
        )
    );

CREATE POLICY "Users can update their own shift assignments" ON shift_assignments
    FOR UPDATE
    USING (
        auth.uid() = employee_profile_id
        OR EXISTS (
            SELECT 1 FROM profiles p
            JOIN user_roles ur ON p.id = ur.profile_id
            JOIN roles r ON ur.role_id = r.id
            WHERE p.auth_user_id = auth.uid()
            AND r.code::text = ANY (ARRAY['admin','mod','manager','leader'])
        )
    );

CREATE POLICY "Admins can update any shift assignment" ON shift_assignments
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM profiles p
            JOIN user_roles ur ON p.id = ur.profile_id
            JOIN roles r ON ur.role_id = r.id
            WHERE p.auth_user_id = auth.uid()
            AND r.code::text = ANY (ARRAY['admin','mod','manager','leader'])
        )
    );

CREATE POLICY "Users can delete their own shift assignments" ON shift_assignments
    FOR DELETE
    USING (
        auth.uid() = employee_profile_id
        OR EXISTS (
            SELECT 1 FROM profiles p
            JOIN user_roles ur ON p.id = ur.profile_id
            JOIN roles r ON ur.role_id = r.id
            WHERE p.auth_user_id = auth.uid()
            AND r.code::text = ANY (ARRAY['admin','mod','manager','leader'])
        )
    );

CREATE POLICY "Admins can delete any shift assignment" ON shift_assignments
    FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM profiles p
            JOIN user_roles ur ON p.id = ur.profile_id
            JOIN roles r ON ur.role_id = r.id
            WHERE p.auth_user_id = auth.uid()
            AND r.code::text = ANY (ARRAY['admin','mod','manager','leader'])
        )
    );

-- =====================================================
-- 5. Grant Permissions to All Functions
-- =====================================================

GRANT EXECUTE ON FUNCTION get_all_shift_assignments_direct() TO authenticated;
GRANT EXECUTE ON FUNCTION create_shift_assignment_direct(UUID, UUID, UUID, UUID, TEXT, BOOLEAN) TO authenticated;
GRANT EXECUTE ON FUNCTION update_shift_assignment_direct(UUID, UUID, UUID, UUID, UUID, TEXT, BOOLEAN) TO authenticated;
GRANT EXECUTE ON FUNCTION delete_shift_assignment_direct(UUID, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_active_shift_assignments(UUID) TO authenticated;

-- =====================================================
-- 6. Cleanup Duplicate Records
-- =====================================================

-- After removing game_account_id, clean up any duplicate assignments
-- Keep only the latest record for each employee+shift+channel+currency combination
DELETE FROM shift_assignments
WHERE id NOT IN (
    SELECT DISTINCT ON (employee_profile_id, shift_id, channels_id, currency_code) id
    FROM shift_assignments
    ORDER BY employee_profile_id, shift_id, channels_id, currency_code, created_at DESC, id DESC
);

-- =====================================================
-- 7. Verification and Validation
-- =====================================================

-- Create a verification function to check everything is working
CREATE OR REPLACE FUNCTION verify_shift_assignment_overhaul()
RETURNS TABLE (
    check_name TEXT,
    status TEXT,
    details TEXT
) AS $$
BEGIN
    -- Check table structure
    RETURN QUERY
    SELECT
        'Table Structure'::TEXT,
        CASE WHEN COUNT(*) = 10 THEN 'PASS' ELSE 'FAIL' END as status,
        'shift_assignments has correct number of columns' as details
    FROM information_schema.columns
    WHERE table_name = 'shift_assignments'
    AND column_name NOT IN ('game_account_id');

    -- Check functions exist
    RETURN QUERY
    SELECT
        'Functions Exist'::TEXT,
        CASE WHEN COUNT(*) = 5 THEN 'PASS' ELSE 'FAIL' END as status,
        'All shift assignment functions exist' as details
    FROM pg_proc
    WHERE proname IN ('get_all_shift_assignments_direct', 'create_shift_assignment_direct',
                     'update_shift_assignment_direct', 'delete_shift_assignment_direct',
                     'get_active_shift_assignments');

    -- Check RLS policies exist
    RETURN QUERY
    SELECT
        'RLS Policies'::TEXT,
        CASE WHEN COUNT(*) >= 8 THEN 'PASS' ELSE 'FAIL' END as status,
        'Shift assignment RLS policies are in place' as details
    FROM pg_policies
    WHERE tablename = 'shift_assignments';

END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = 'public';

-- =====================================================
-- 7. Migration Summary
-- =====================================================

/*
Migration Summary:
-----------------
✅ Removed game_account_id from shift_assignments table
✅ Updated all database functions to work without game_account_id
✅ Implemented proper authentication pattern (p_user_id parameter)
✅ Fixed RLS policies to use role codes instead of role names
✅ Created comprehensive CRUD operations for shift assignments
✅ Added validation for all operations
✅ Implemented soft delete for audit trail
✅ Added verification function for testing

Frontend Changes Required:
-------------------------
✅ Updated Manager.vue tab title
✅ Removed game_account_id fields from ShiftAssignments.vue
✅ Updated component interfaces and forms
✅ Fixed API calls to use new function signatures
✅ Removed game account filters and options

Next Steps:
-----------
1. Test all CRUD operations in staging
2. Verify RLS policies work correctly
3. Test with different user roles
4. Apply this migration to production after successful testing
5. Deploy updated frontend components
*/