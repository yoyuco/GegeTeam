-- Production Migration: Employee Assignment System Improvements
-- Adds fallback mechanism and cleans up unused game_code column
-- Date: 2025-12-09

-- ================================================================
-- PART 1: Employee Fallback Functions
-- ================================================================

-- Function to find fallback employee for game code when direct assignment fails
CREATE OR REPLACE FUNCTION get_employee_fallback_for_game_code(
    p_game_code TEXT,
    p_current_time TIME DEFAULT NULL,
    p_exclude_account_id UUID DEFAULT NULL
)
RETURNS TABLE(
    success BOOLEAN,
    employee_profile_id UUID,
    employee_name TEXT,
    fallback_reason TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO public
AS $$
DECLARE
    v_current_local_time TIME := COALESCE(p_current_time, NOW()::TIME);
    v_current_shift_id UUID;
BEGIN
    -- Get current shift ID
    SELECT id INTO v_current_shift_id
    FROM work_shifts
    WHERE is_active = true
      AND (
        (start_time <= end_time AND start_time <= v_current_local_time AND end_time >= v_current_local_time)
        OR (start_time > end_time AND (v_current_local_time >= start_time OR v_current_local_time <= end_time))
      )
    LIMIT 1;

    IF v_current_shift_id IS NULL THEN
        RETURN QUERY
        SELECT false, NULL::UUID, 'No active shift found', NULL::TEXT;
        RETURN;
    END IF;

    -- Find any employee working with this game code
    RETURN QUERY
    SELECT
        true as success,
        se.employee_profile_id,
        p.display_name as employee_name,
        format('Fallback: Found %s working with %s game (shift: %s)',
               p.display_name, p_game_code,
               (SELECT name FROM work_shifts WHERE id = v_current_shift_id)) as fallback_reason
    FROM shift_assignments se
    JOIN work_shifts sa ON se.shift_id = sa.id
    JOIN profiles p ON se.employee_profile_id = p.id
    JOIN game_accounts ga ON se.game_account_id = ga.id
    WHERE ga.game_code = p_game_code
      AND se.is_active = true
      AND sa.is_active = true
      AND sa.id = v_current_shift_id
      AND (p_exclude_account_id IS NULL OR se.game_account_id != p_exclude_account_id)
      AND p.status = 'active'
    ORDER BY
        -- Prioritize employees with fewer active assignments
        (
            SELECT COUNT(*)
            FROM currency_orders co
            WHERE co.assigned_to = se.employee_profile_id
              AND co.status = 'assigned'
        ) ASC,
        -- Then by account name for consistency
        ga.account_name ASC
    LIMIT 1;

    -- If no employees found for this game code
    IF NOT FOUND THEN
        RETURN QUERY
        SELECT false, NULL::UUID,
               format('No employees found working with %s game in current shift', p_game_code) as employee_name,
               NULL::TEXT;
    END IF;

    RETURN;
END;
$$;

-- ================================================================
-- PART 2: Enhanced Assignment Function with Fallback
-- ================================================================

-- Enhanced assign_sell_order_with_inventory_v2 with 2-level fallback
CREATE OR REPLACE FUNCTION assign_sell_order_with_inventory_v2(
  p_order_id UUID DEFAULT NULL,
  p_user_id UUID DEFAULT NULL,
  p_rotation_type TEXT DEFAULT 'currency_first'
)
RETURNS TABLE(
  success BOOLEAN,
  message TEXT,
  assigned_employee_id UUID,
  assigned_employee_name TEXT,
  game_account_id UUID,
  game_account_name TEXT,
  channel_id UUID,
  channel_name TEXT,
  cost_amount NUMERIC,
  cost_currency TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO public
AS $$
BEGIN
    -- Get current user (from parameter or auth)
    DECLARE
        v_current_user_id UUID := COALESCE(p_user_id, auth.uid());
        v_order RECORD;
        v_inventory_pool RECORD;
        v_employee RECORD;
        v_fallback_employee RECORD;
        v_cost_amount DECIMAL;
        v_cost_currency TEXT;
        v_bot_profile_id UUID DEFAULT '3c6f63c0-6cc5-4e04-9ccc-c5b92a8868dc';
        v_assignment_method TEXT;
        v_fallback_reason TEXT;
    BEGIN
        -- Get order details
        SELECT * INTO v_order
        FROM public.currency_orders
        WHERE id = p_order_id AND status = 'pending';

        IF NOT FOUND THEN
            RETURN QUERY
            SELECT
                false as success,
                'Order not found or not in pending status' as message,
                NULL::UUID, NULL::TEXT, NULL::UUID, NULL::TEXT,
                NULL::UUID, NULL::TEXT, NULL::NUMERIC, NULL::TEXT;
            RETURN;
        END IF;

        -- Step 1: Find best inventory pool using selected rotation type
        IF p_rotation_type = 'account_first' THEN
            SELECT * INTO v_inventory_pool FROM public.get_inventory_pool_with_account_first_rotation(
                v_order.game_code,
                v_order.server_attribute_code,
                v_order.currency_attribute_id,
                v_order.quantity
            );
        ELSE
            -- Fall back to original currency-first rotation
            SELECT * INTO v_inventory_pool FROM public.get_inventory_pool_with_currency_rotation(
                v_order.game_code,
                v_order.server_attribute_code,
                v_order.currency_attribute_id,
                v_order.quantity
            );
        END IF;

        IF v_inventory_pool IS NULL OR NOT v_inventory_pool.success THEN
            RETURN QUERY
            SELECT
                false as success,
                CASE
                    WHEN v_inventory_pool.message IS NOT NULL THEN v_inventory_pool.message
                    ELSE format('No suitable inventory pool found with %s rotation', p_rotation_type)
                END as message,
                NULL::UUID, NULL::TEXT, NULL::UUID, NULL::TEXT,
                NULL::UUID, NULL::TEXT, NULL::NUMERIC, NULL::TEXT;
            RETURN;
        END IF;

        -- Calculate cost amount
        v_cost_amount := v_order.quantity * COALESCE(v_inventory_pool.average_cost, 0);
        v_cost_currency := COALESCE(v_inventory_pool.cost_currency, 'VND');

        -- Step 2: Find employee with 2-level fallback mechanism

        -- LEVEL 1: Try exact account assignment first
        SELECT * INTO v_employee
        FROM public.get_employee_for_account_in_shift(v_inventory_pool.game_account_id)
        LIMIT 1;

        IF v_employee.success THEN
            v_assignment_method := 'Direct assignment';
            v_fallback_reason := 'Exact account match';
        ELSE
            -- LEVEL 2: Fallback to any employee with same game code
            -- Initialize fallback_employee to avoid unassigned record error
            v_fallback_employee := ROW(false, NULL::UUID, '', ''::TEXT);

            SELECT * INTO v_fallback_employee
            FROM public.get_employee_fallback_for_game_code(
                v_order.game_code,
                NOW()::TIME,
                v_inventory_pool.game_account_id  -- Exclude the original account
            )
            LIMIT 1;

            IF v_fallback_employee.success THEN
                v_employee.employee_profile_id := v_fallback_employee.employee_profile_id;
                v_employee.employee_name := v_fallback_employee.employee_name;
                v_employee.success := true;
                v_assignment_method := 'Game code fallback';
                v_fallback_reason := v_fallback_employee.fallback_reason;
            ELSE
                -- No employee found at all
                RETURN QUERY
                SELECT
                    false as success,
                    format('No employee available for account %s and no fallback for game %s: %s',
                           v_inventory_pool.account_name,
                           v_order.game_code,
                           COALESCE(v_fallback_employee.employee_name, 'No fallback available')) as message,
                    NULL::UUID, NULL::TEXT,
                    v_inventory_pool.game_account_id, v_inventory_pool.account_name,
                    v_inventory_pool.channel_id, v_inventory_pool.channel_name,
                    v_cost_amount, v_cost_currency;
                RETURN;
            END IF;
        END IF;

        -- Step 3: Update database
        UPDATE public.currency_orders
        SET assigned_to = v_employee.employee_profile_id,
            game_account_id = v_inventory_pool.game_account_id,
            inventory_pool_id = v_inventory_pool.inventory_pool_id,
            assigned_at = NOW(),
            status = 'assigned',
            submitted_by = CASE WHEN submitted_by IS NULL THEN v_bot_profile_id ELSE submitted_by END,
            updated_at = NOW(),
            updated_by = v_current_user_id,
            cost_amount = v_cost_amount,
            cost_currency_code = v_cost_currency
        WHERE id = p_order_id;

        UPDATE public.inventory_pools
        SET quantity = quantity - v_order.quantity,
            reserved_quantity = reserved_quantity + v_order.quantity,
            last_updated_at = NOW(),
            last_updated_by = v_current_user_id
        WHERE id = v_inventory_pool.inventory_pool_id;

        -- Return success with assignment method info
        RETURN QUERY
        SELECT
            true as success,
            format('%s assignment: %s -> %s (Account: %s) | %s | %s',
                   CASE WHEN p_rotation_type = 'account_first' THEN 'Account-first' ELSE 'Currency-first' END,
                   v_employee.employee_name, v_inventory_pool.channel_name,
                   v_inventory_pool.account_name,
                   v_assignment_method,
                   COALESCE(v_fallback_reason, 'Direct assignment')) as message,
            v_employee.employee_profile_id as assigned_employee_id,
            v_employee.employee_name as assigned_employee_name,
            v_inventory_pool.game_account_id as game_account_id,
            v_inventory_pool.account_name as game_account_name,
            v_inventory_pool.channel_id as channel_id,
            v_inventory_pool.channel_name as channel_name,
            v_cost_amount as cost_amount,
            v_cost_currency as cost_currency;

        RETURN;
    END;
END;
$$;

-- ================================================================
-- PART 3: Cleanup - Remove unused game_code column and trigger
-- ================================================================

-- Drop the trigger that updates game_code
DROP TRIGGER IF EXISTS tr_update_shift_assignment_game_code ON shift_assignments;

-- Drop the function that updates game_code
DROP FUNCTION IF EXISTS update_shift_assignment_game_code();

-- Drop unused round robin function (uses removed game_code column)
DROP FUNCTION IF EXISTS get_employee_for_game_in_shift_round_robin();

-- Drop test function (not used in production)
DROP FUNCTION IF EXISTS test_employee_assignment();

-- Remove the unused game_code column from shift_assignments
-- Note: This column is redundant since we can get game_code from game_accounts
ALTER TABLE shift_assignments
DROP COLUMN IF EXISTS game_code;

-- ================================================================
-- PART 4: Grant Permissions
-- ================================================================

-- Grant execute permissions to authenticated and service_role users
GRANT EXECUTE ON FUNCTION get_employee_fallback_for_game_code TO authenticated;
GRANT EXECUTE ON FUNCTION get_employee_fallback_for_game_code TO service_role;

GRANT EXECUTE ON FUNCTION assign_sell_order_with_inventory_v2 TO authenticated;
GRANT EXECUTE ON FUNCTION assign_sell_order_with_inventory_v2 TO service_role;

-- ================================================================
-- PART 5: Add Comments for Documentation
-- ================================================================

COMMENT ON FUNCTION get_employee_fallback_for_game_code IS
'Finds fallback employee for a game code when direct account assignment fails.
Parameters:
- p_game_code: Game code to search for
- p_current_time: Time to check (defaults to NOW())
- p_exclude_account_id: Account to exclude from search
Returns: Employee info with fallback reason';

COMMENT ON FUNCTION assign_sell_order_with_inventory_v2 IS
'Enhanced assignment function with 2-level fallback mechanism.
Level 1: Direct account assignment
Level 2: Game code fallback
This reduces failed orders when no direct assignment is available.';

-- ================================================================
-- VERIFICATION QUERIES (for manual testing after deployment)
-- ================================================================

/*
-- Test fallback function
SELECT * FROM get_employee_fallback_for_game_code('POE_2', NOW()::TIME, NULL);

-- Test full assignment with fallback
SELECT * FROM assign_sell_order_with_inventory_v2('order-uuid-here');

-- Verify game_code column removed
SELECT column_name
FROM information_schema.columns
WHERE table_name = 'shift_assignments'
  AND column_name = 'game_code';

-- Verify trigger removed
SELECT tgname
FROM pg_trigger
WHERE tgrelid::regclass = 'public.shift_assignments'::regclass
  AND tgname = 'tr_update_shift_assignment_game_code';

-- Verify function removed
SELECT proname
FROM pg_proc
WHERE proname = 'update_shift_assignment_game_code';

-- Verify round robin function removed
SELECT proname
FROM pg_proc
WHERE proname = 'get_employee_for_game_in_shift_round_robin';

-- Verify test function removed
SELECT proname
FROM pg_proc
WHERE proname = 'test_employee_assignment';
*/