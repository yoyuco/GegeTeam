-- Fix shift assignment functions - remove references to created_by and updated_by columns
-- These columns don't exist in the shift_assignments table

-- Fix create_shift_assignment_direct function
DROP FUNCTION IF EXISTS create_shift_assignment_direct(UUID, UUID, UUID, UUID, TEXT, BOOLEAN);

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

    -- Create assignment (without created_by column)
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
$$ LANGUAGE plpgsql;

-- Fix update_shift_assignment_direct function
DROP FUNCTION IF EXISTS update_shift_assignment_direct(UUID, UUID, UUID, UUID, UUID, TEXT, BOOLEAN);

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

    -- Perform update with provided values (without updated_by column)
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
$$ LANGUAGE plpgsql;

-- Fix delete_shift_assignment_direct function
DROP FUNCTION IF EXISTS delete_shift_assignment_direct(UUID, UUID);

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
$$ LANGUAGE plpgsql;

-- Grant permissions
GRANT EXECUTE ON FUNCTION create_shift_assignment_direct(UUID, UUID, UUID, UUID, TEXT, BOOLEAN) TO authenticated;
GRANT EXECUTE ON FUNCTION update_shift_assignment_direct(UUID, UUID, UUID, UUID, UUID, TEXT, BOOLEAN) TO authenticated;
GRANT EXECUTE ON FUNCTION delete_shift_assignment_direct(UUID, UUID) TO authenticated;

-- Test the update function
SELECT 'Testing update function...' as test;
SELECT update_shift_assignment_direct(
    '83bd99bb-a238-45ec-b10c-f4320c3e259e'::UUID, -- p_user_id (profile ID)
    '0349d797-a905-4b9f-8f37-e2c6e362929e'::UUID, -- p_assignment_id
    NULL::UUID, -- p_employee_profile_id (no change)
    NULL::UUID, -- p_shift_id (no change)
    NULL::UUID, -- p_channels_id (no change)
    NULL::TEXT, -- p_currency_code (no change)
    false::BOOLEAN -- p_is_active (change to false)
);