-- Fix shift time logic for get_employee_for_account_in_shift function
-- Problem: Current logic doesn't handle overnight shifts (wrap-around)
-- Solution: Use OR condition for proper time comparison

-- Drop and recreate function with correct logic
DROP FUNCTION IF EXISTS get_employee_for_account_in_shift;

CREATE OR REPLACE FUNCTION get_employee_for_account_in_shift(
  p_game_account_id UUID
)
RETURNS TABLE(
  success BOOLEAN,
  employee_profile_id UUID,
  employee_name TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO public
AS $$
DECLARE
    v_employee_profile_id UUID;
    v_employee_name TEXT;
    v_current_local_time TIME;
BEGIN
    -- Get current time in GMT+7 (database timezone already set to Asia/Ho_Chi_Minh)
    SELECT NOW()::TIME INTO v_current_local_time;

    -- Find employee assigned to this game account in current shift using PROPER TIME LOGIC
    -- Fix: Use OR condition to handle overnight shifts properly
    -- Example: Ca Đêm (20:00-08:00) should match any time >= 20:00 OR <= 08:00
    SELECT se.employee_profile_id, p.display_name
    INTO v_employee_profile_id, v_employee_name
    FROM shift_assignments se
    JOIN work_shifts sa ON se.shift_id = sa.id
    JOIN profiles p ON se.employee_profile_id = p.id
    WHERE se.game_account_id = p_game_account_id
      AND se.is_active = true
      AND sa.is_active = true
      AND (
        -- Normal time range (e.g., 08:00-17:00)
        (sa.start_time <= sa.end_time AND sa.start_time <= v_current_local_time AND sa.end_time >= v_current_local_time)
        OR
        -- Overnight/wrap-around range (e.g., 20:00-08:00)
        (sa.start_time > sa.end_time AND (v_current_local_time >= sa.start_time OR v_current_local_time <= sa.end_time))
      )
    LIMIT 1;

    -- Check if we found an employee
    IF v_employee_profile_id IS NOT NULL THEN
        RETURN QUERY
        SELECT true, v_employee_profile_id, v_employee_name;
    ELSE
        RETURN QUERY
        SELECT false, NULL::UUID, 'No employee assigned to this account in current shift';
    END IF;

    RETURN;
END;
$$;

-- Grant permissions
GRANT EXECUTE ON FUNCTION get_employee_for_account_in_shift TO authenticated;
GRANT EXECUTE ON FUNCTION get_employee_for_account_in_shift TO service_role;

-- Test the fixed function
DO $$
DECLARE
    v_test_result RECORD;
BEGIN
    RAISE NOTICE 'Testing fixed get_employee_for_account_in_shift function...';

    SELECT * INTO v_test_result FROM get_employee_for_account_in_shift('ebda6d22-0a53-4653-bdaa-3427369256e9');

    IF v_test_result.success THEN
        RAISE NOTICE '✅ Function fixed! Found employee: %', v_test_result.employee_name;
    ELSE
        RAISE NOTICE '❌ Function still has issues: %', v_test_result.employee_name;
    END IF;
END $$;