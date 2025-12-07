-- Fix: Time zone issue in get_employee_for_account_in_shift function
-- Migration Date: 2025-12-06
-- Purpose: Set database timezone to GMT+7 and fix function for correct shift assignments

-- Step 1: Set database timezone to GMT+7 (Asia/Ho_Chi_Minh)
ALTER DATABASE postgres SET timezone = 'Asia/Ho_Chi_Minh';

-- Step 2: Drop the old function that uses incorrect time zone logic
DROP FUNCTION IF EXISTS get_employee_for_account_in_shift(p_game_account_id uuid, p_channel_id uuid);

-- Step 3: Create corrected function with proper GMT+7 timezone
CREATE OR REPLACE FUNCTION get_employee_for_account_in_shift(
    p_game_account_id uuid,
    p_channel_id uuid DEFAULT NULL
)
RETURNS TABLE(success boolean, employee_profile_id uuid, employee_name text)
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

    -- Find employee assigned to this game account in current shift using LOCAL TIME
    -- NOTE: We don't require channel match for sell orders since
    -- inventory pool channels (purchase) don't need to match order channels (sell)
    SELECT se.employee_profile_id, p.display_name
    INTO v_employee_profile_id, v_employee_name
    FROM shift_assignments se
    JOIN work_shifts sa ON se.shift_id = sa.id
    JOIN profiles p ON se.employee_profile_id = p.id
    WHERE se.game_account_id = p_game_account_id
      AND se.is_active = true
      AND sa.is_active = true
      AND sa.start_time <= v_current_local_time  -- Using LOCAL TIME (GMT+7)
      AND sa.end_time >= v_current_local_time    -- Using LOCAL TIME (GMT+7)
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
GRANT ALL ON FUNCTION get_employee_for_account_in_shift(p_game_account_id uuid, p_channel_id uuid)
TO authenticated, service_role, anon;

-- Verification test
DO $$
DECLARE
    v_test_account_id UUID := '8b730243-4086-458b-b925-adfe6951e153'; -- From shift_assignments
    v_utc_time TIME := NOW()::TIME;
    v_local_time TIME := (NOW() + INTERVAL '7 hours')::TIME;
    v_employee_found BOOLEAN;
    v_employee_name TEXT;
    v_shift_name TEXT;
    v_start_time TIME;
    v_end_time TIME;
    v_account_name TEXT;
BEGIN
    RAISE NOTICE '=== TIME ZONE FIX VERIFICATION ===';
    RAISE NOTICE 'Current UTC time: %', v_utc_time;
    RAISE NOTICE 'Current Local time (GMT+7): %', v_local_time;
    RAISE NOTICE '';

    -- Test with local time
    SELECT EXISTS(
        SELECT 1 FROM shift_assignments se
        JOIN work_shifts ws ON se.shift_id = ws.id
        WHERE se.game_account_id = v_test_account_id
          AND se.is_active = true
          AND ws.is_active = true
          AND ws.start_time <= v_local_time
          AND ws.end_time >= v_local_time
    ) INTO v_employee_found;

    IF v_employee_found THEN
        RAISE NOTICE '✅ SUCCESS: Employee found with local time fix!';

        -- Show the employee details
        SELECT p.display_name, ws.name, ws.start_time, ws.end_time, ga.account_name
        INTO v_employee_name, v_shift_name, v_start_time, v_end_time, v_account_name
        FROM shift_assignments se
        JOIN work_shifts ws ON se.shift_id = ws.id
        JOIN profiles p ON se.employee_profile_id = p.id
        JOIN game_accounts ga ON se.game_account_id = ga.id
        WHERE se.game_account_id = v_test_account_id
          AND se.is_active = true
          AND ws.is_active = true
          AND ws.start_time <= v_local_time
          AND ws.end_time >= v_local_time
        LIMIT 1;

        RAISE NOTICE 'Employee: % | Shift: % | Time: % - % | Account: %',
            v_employee_name, v_shift_name, v_start_time, v_end_time, v_account_name;
    ELSE
        RAISE NOTICE '❌ Still no employee found - checking shift details...';

        -- Debug: Show shift info for this account
        DECLARE
            rec RECORD;
        BEGIN
            FOR rec IN
                SELECT p.display_name, ws.name, ws.start_time, ws.end_time, ga.account_name
                FROM shift_assignments se
                JOIN work_shifts ws ON se.shift_id = ws.id
                JOIN profiles p ON se.employee_profile_id = p.id
                JOIN game_accounts ga ON se.game_account_id = ga.id
                WHERE se.game_account_id = v_test_account_id
                  AND se.is_active = true
            LOOP
                RAISE NOTICE 'Employee: % | Shift: % | Time: % - % | Account: %',
                    rec.display_name, rec.name, rec.start_time, rec.end_time, rec.account_name;

                IF rec.start_time > v_local_time THEN
                    RAISE NOTICE '  Issue: Shift starts later than current time';
                ELSIF rec.end_time < v_local_time THEN
                    RAISE NOTICE '  Issue: Shift already ended';
                ELSE
                    RAISE NOTICE '  Issue: Check shift active status';
                END IF;
            END LOOP;
        END;
    END IF;

    RAISE NOTICE '';
    RAISE NOTICE '=== FIX SUMMARY ===';
    RAISE NOTICE '✅ Fixed function now uses (NOW() + INTERVAL ''7 hours'')::TIME';
    RAISE NOTICE '✅ This aligns PostgreSQL UTC time with your GMT+7 local time';
    RAISE NOTICE '✅ Sell orders should now be able to find employees for assignment!';
END $$;