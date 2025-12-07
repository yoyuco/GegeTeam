-- Fix assign_sell_order_with_inventory_v2 to use single parameter function
-- Updated get_employee_for_account_in_shift only needs game_account_id

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
        v_cost_amount DECIMAL;
        v_cost_currency TEXT;
        v_bot_profile_id UUID DEFAULT '3c6f63c0-6cc5-4e04-9ccc-c5b92a8868dc';
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

        -- Step 2: Find employee - FIXED: Use single parameter function
        SELECT * INTO v_employee
        FROM public.get_employee_for_account_in_shift(v_inventory_pool.game_account_id)
        LIMIT 1;

        IF NOT v_employee.success THEN
            RETURN QUERY
            SELECT
                false as success,
                v_employee.employee_name as message, -- FIXED: Use employee_name instead of non-existent message field
                NULL::UUID, NULL::TEXT,
                v_inventory_pool.game_account_id, v_inventory_pool.account_name, -- FIXED: Correct order and types
                v_inventory_pool.channel_id, v_inventory_pool.channel_name,
                v_cost_amount, v_cost_currency;
            RETURN;
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

        -- Return success
        RETURN QUERY
        SELECT
            true as success,
            format('%s assignment: %s -> %s (Account: %s) | %s %s -> %s | Cost: %s %s',
                   CASE WHEN p_rotation_type = 'account_first' THEN 'Account-first' ELSE 'Currency-first' END,
                   v_employee.employee_name, v_inventory_pool.channel_name,
                   v_inventory_pool.account_name,
                   v_inventory_pool.cost_currency, v_inventory_pool.channel_name,
                   v_inventory_pool.account_name,
                   v_cost_amount, v_cost_currency) as message,
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

-- Grant permissions
GRANT EXECUTE ON FUNCTION assign_sell_order_with_inventory_v2 TO authenticated;
GRANT EXECUTE ON FUNCTION assign_sell_order_with_inventory_v2 TO service_role;

-- Test the fixed function
DO $$
DECLARE
    v_test_result RECORD;
BEGIN
    RAISE NOTICE 'Testing fixed assign_sell_order_with_inventory_v2 function...';

    SELECT * INTO v_test_result
    FROM assign_sell_order_with_inventory_v2(
        p_order_id := '987f1038-24e0-4c70-a2c3-c302c37d0735'::UUID,
        p_rotation_type := 'account_first'
    );

    IF v_test_result.success THEN
        RAISE NOTICE '✅ Function fixed! Assignment: %', v_test_result.message;
    ELSE
        RAISE NOTICE '❌ Function still has issues: %', v_test_result.message;
    END IF;
END $$;