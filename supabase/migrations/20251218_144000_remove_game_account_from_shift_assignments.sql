-- Migration: Remove game_account_id from shift_assignments table
-- Description: Update shift_assignments to remove game_account_id and update all dependent functions
-- Created: 2025-12-18 14:40:00
-- Author: Claude Code

-- First, let's check if there's any data in shift_assignments that we need to preserve
SELECT 'Checking current shift_assignments data...' as log_message;

-- Remove game_account_id column from shift_assignments table
ALTER TABLE shift_assignments DROP COLUMN IF EXISTS game_account_id;

-- Add a comment to document the change
COMMENT ON COLUMN shift_assignments.employee_profile_id IS 'Employee profile ID - references profiles.id';

-- Update any functions that reference game_account_id in shift_assignments
-- Function 1: update_shift_assignment_status
CREATE OR REPLACE FUNCTION update_shift_assignment_status(p_shift_assignment_id UUID, p_status TEXT)
RETURNS BOOLEAN AS $$
DECLARE
    v_record_exists BOOLEAN;
BEGIN
    -- Check if the shift assignment exists
    SELECT EXISTS(SELECT 1 FROM shift_assignments WHERE id = p_shift_assignment_id) INTO v_record_exists;

    IF NOT v_record_exists THEN
        RAISE EXCEPTION 'Shift assignment with ID % does not exist', p_shift_assignment_id;
    END IF;

    -- Update the status (removed game_account_id reference)
    UPDATE shift_assignments
    SET
        is_active = CASE
            WHEN p_status = 'inactive' THEN FALSE
            WHEN p_status = 'active' THEN TRUE
            ELSE is_active
        END,
        updated_at = NOW()
    WHERE id = p_shift_assignment_id;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function 2: get_active_shift_assignments
CREATE OR REPLACE FUNCTION get_active_shift_assignments(p_employee_id UUID DEFAULT NULL)
RETURNS TABLE (
    assignment_id UUID,
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
        ws.end_time as shift_end_time,
        ws.description as shift_description
    FROM shift_assignments sa
    LEFT JOIN work_shifts ws ON sa.shift_id = ws.id
    WHERE sa.is_active = TRUE
      AND (p_employee_id IS NULL OR sa.employee_profile_id = p_employee_id)
    ORDER BY sa.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function 3: create_shift_assignment
CREATE OR REPLACE FUNCTION create_shift_assignment(
    p_employee_profile_id UUID,
    p_shift_id UUID,
    p_channels_id UUID DEFAULT NULL,
    p_currency_code TEXT DEFAULT ''
)
RETURNS UUID AS $$
DECLARE
    v_assignment_id UUID;
    v_is_active BOOLEAN := TRUE;
BEGIN
    -- Create the shift assignment (removed game_account_id parameter)
    INSERT INTO shift_assignments (
        employee_profile_id,
        shift_id,
        channels_id,
        currency_code,
        is_active
    ) VALUES (
        p_employee_profile_id,
        p_shift_id,
        p_channels_id,
        p_currency_code,
        v_is_active
    ) RETURNING id INTO v_assignment_id;

    RETURN v_assignment_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;