-- URGENT FIX: Create missing shift assignment functions with correct signatures
-- This fixes the 404 error for update_shift_assignment_direct function

-- First, drop any existing versions to avoid conflicts
DROP FUNCTION IF EXISTS get_all_shift_assignments_direct();
DROP FUNCTION IF EXISTS create_shift_assignment_direct(UUID, UUID, UUID, UUID, TEXT, BOOLEAN);
DROP FUNCTION IF EXISTS update_shift_assignment_direct(UUID, UUID, UUID, UUID, UUID, TEXT, BOOLEAN);
DROP FUNCTION IF EXISTS delete_shift_assignment_direct(UUID, UUID);
DROP FUNCTION IF EXISTS get_active_shift_assignments(UUID);

-- =====================================================
-- 1. Function to get all shift assignments (without game_account_id)
-- =====================================================
CREATE OR REPLACE FUNCTION get_all_shift_assignments_direct()
RETURNS TABLE (
    id UUID,
    employee_profile_id UUID,
    employee_name TEXT,
    shift_id UUID,
    shift_name TEXT,
    shift_start_time TIME,
    shift_end_time TEXT,
    channels_id UUID,
    channel_name TEXT,
    currency_code TEXT,
    currency_name TEXT,
    is_active BOOLEAN,
    assigned_at TIMESTAMPTZ
) SECURITY DEFINER SET search_path = 'public'
AS $$
BEGIN
  RETURN QUERY
  SELECT
    sa.id,
    sa.employee_profile_id,
    COALESCE(p.display_name, 'Unknown') as employee_name,
    sa.shift_id,
    COALESCE(ws.name, 'Unknown') as shift_name,
    ws.start_time as shift_start_time,
    ws.end_time as shift_end_time,
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
$$ LANGUAGE plpgsql;

-- =====================================================
-- 2. Function to create new shift assignment
-- =====================================================
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

    -- Create assignment
    INSERT INTO shift_assignments (
        employee_profile_id, shift_id, channels_id, currency_code,
        is_active, assigned_at, created_at, created_by
    ) VALUES (
        p_employee_profile_id, p_shift_id, p_channels_id, p_currency_code,
        p_is_active, now(), now(), p_user_id
    ) RETURNING id INTO v_assignment_id;

    RETURN json_build_object(
        'success', true,
        'message', 'Shift assignment created successfully',
        'assignment_id', v_assignment_id
    );
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 3. Function to update existing shift assignment
-- =====================================================
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

    -- Perform update with provided values
    UPDATE shift_assignments
    SET
        employee_profile_id = COALESCE(p_employee_profile_id, employee_profile_id),
        shift_id = COALESCE(p_shift_id, shift_id),
        channels_id = COALESCE(p_channels_id, channels_id),
        currency_code = COALESCE(p_currency_code, currency_code),
        is_active = COALESCE(p_is_active, is_active),
        updated_at = now(),
        updated_by = p_user_id
    WHERE id = p_assignment_id;

    RETURN json_build_object('success', true, 'message', 'Shift assignment updated successfully');
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 4. Function to delete shift assignment (soft delete)
-- =====================================================
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
        updated_at = now(),
        updated_by = p_user_id
    WHERE id = p_assignment_id;

    RETURN json_build_object('success', true, 'message', 'Shift assignment deleted successfully');
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 5. Function to get active assignments for current user
-- =====================================================
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
) SECURITY DEFINER SET search_path = 'public'
AS $$
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
        ws.end_time as shift_end_time,
        ws.description as shift_description
    FROM shift_assignments sa
    LEFT JOIN work_shifts ws ON sa.shift_id = ws.id
    WHERE sa.is_active = TRUE
      AND (p_user_id IS NULL OR sa.employee_profile_id = p_user_id)
    ORDER BY sa.created_at DESC;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 6. Grant Permissions
-- =====================================================
GRANT EXECUTE ON FUNCTION get_all_shift_assignments_direct() TO authenticated;
GRANT EXECUTE ON FUNCTION create_shift_assignment_direct(UUID, UUID, UUID, UUID, TEXT, BOOLEAN) TO authenticated;
GRANT EXECUTE ON FUNCTION update_shift_assignment_direct(UUID, UUID, UUID, UUID, UUID, TEXT, BOOLEAN) TO authenticated;
GRANT EXECUTE ON FUNCTION delete_shift_assignment_direct(UUID, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_active_shift_assignments(UUID) TO authenticated;

-- =====================================================
-- 7. Verification
-- =====================================================
SELECT
    proname as function_name,
    pg_get_function_arguments(oid) as parameters,
    'CREATED' as status
FROM pg_proc
WHERE proname IN ('get_all_shift_assignments_direct', 'create_shift_assignment_direct',
                 'update_shift_assignment_direct', 'delete_shift_assignment_direct',
                 'get_active_shift_assignments')
ORDER BY proname;