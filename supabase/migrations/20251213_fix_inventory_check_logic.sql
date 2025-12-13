-- Fix Inventory Check Logic
-- Migration Date: 2025-12-13
-- Purpose: Fix inventory pool selection logic to only check quantity, not reserved_quantity
-- Because quantity already represents available stock after assignment

-- 1. Fix get_inventory_pool_with_currency_rotation
DROP FUNCTION IF EXISTS get_inventory_pool_with_currency_rotation(p_game_code TEXT, p_server_attribute_code TEXT, p_currency_attribute_id UUID, p_required_quantity NUMERIC) CASCADE;

CREATE OR REPLACE FUNCTION get_inventory_pool_with_currency_rotation(
    p_game_code TEXT,
    p_server_attribute_code TEXT,
    p_currency_attribute_id UUID,
    p_required_quantity NUMERIC
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    inventory_pool_id UUID,
    game_account_id UUID,
    channel_id UUID,
    channel_name TEXT,
    account_name TEXT,
    average_cost NUMERIC,
    cost_currency TEXT,
    available_quantity NUMERIC,
    match_reason TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
BEGIN
    RETURN QUERY
    SELECT
        true as success,
        'Found suitable inventory pool' as message,
        ip.id as inventory_pool_id,
        ip.game_account_id,
        ip.channel_id,
        c.name as channel_name,
        ga.account_name,
        ip.average_cost,
        ip.cost_currency,
        ip.quantity as available_quantity,  -- FIX: Only check actual quantity
        'Currency-first rotation match' as match_reason
    FROM inventory_pools ip
    JOIN game_accounts ga ON ip.game_account_id = ga.id
    JOIN channels c ON ip.channel_id = c.id
    WHERE ip.game_code = p_game_code
      AND COALESCE(ip.server_attribute_code, '') = COALESCE(p_server_attribute_code, '')
      AND ip.currency_attribute_id = p_currency_attribute_id
      AND ip.quantity >= p_required_quantity  -- FIX: Only check quantity, not reserved_quantity
      AND ip.average_cost > 0
    ORDER BY ip.average_cost ASC
    LIMIT 1;

    -- If no pool found, return empty result
    IF NOT FOUND THEN
        RETURN QUERY
        SELECT false, 'No suitable inventory pool found', NULL::UUID, NULL::UUID, NULL::UUID,
               NULL::TEXT, NULL::TEXT, NULL::NUMERIC, NULL::TEXT, 0::NUMERIC, 'No match';
    END IF;
END;
$$;

-- 2. Fix get_inventory_pool_with_account_first_rotation
DROP FUNCTION IF EXISTS get_inventory_pool_with_account_first_rotation(p_game_code TEXT, p_server_attribute_code TEXT, p_currency_attribute_id UUID, p_required_quantity NUMERIC) CASCADE;

CREATE OR REPLACE FUNCTION get_inventory_pool_with_account_first_rotation(
    p_game_code TEXT,
    p_server_attribute_code TEXT,
    p_currency_attribute_id UUID,
    p_required_quantity NUMERIC
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    inventory_pool_id UUID,
    game_account_id UUID,
    channel_id UUID,
    channel_name TEXT,
    account_name TEXT,
    average_cost NUMERIC,
    cost_currency TEXT,
    available_quantity NUMERIC,
    match_reason TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
BEGIN
    -- Try to find pool with existing assignments first (account-first rotation)
    RETURN QUERY
    SELECT
        true as success,
        'Found inventory pool with existing assignments' as message,
        ip.id as inventory_pool_id,
        ip.game_account_id,
        ip.channel_id,
        c.name as channel_name,
        ga.account_name,
        ip.average_cost,
        ip.cost_currency,
        ip.quantity as available_quantity,  -- FIX: Only check actual quantity
        'Account-first rotation: Existing assignments' as match_reason
    FROM inventory_pools ip
    JOIN game_accounts ga ON ip.game_account_id = ga.id
    JOIN channels c ON ip.channel_id = c.id
    LEFT JOIN currency_orders co ON co.inventory_pool_id = ip.id AND co.status = 'assigned'
    WHERE ip.game_code = p_game_code
      AND COALESCE(ip.server_attribute_code, '') = COALESCE(p_server_attribute_code, '')
      AND ip.currency_attribute_id = p_currency_attribute_id
      AND ip.quantity >= p_required_quantity  -- FIX: Only check quantity, not reserved_quantity
      AND ip.average_cost > 0
    GROUP BY ip.id, ip.game_account_id, ip.channel_id, c.name, ga.account_name,
             ip.average_cost, ip.cost_currency, ip.quantity
    HAVING COUNT(co.id) > 0  -- Has existing assignments
    ORDER BY COUNT(co.id) DESC, ip.average_cost ASC
    LIMIT 1;

    -- If no pool with assignments found, try regular pool search
    IF NOT FOUND THEN
        RETURN QUERY
        SELECT
            true as success,
            'Found suitable inventory pool (no existing assignments)' as message,
            ip.id as inventory_pool_id,
            ip.game_account_id,
            ip.channel_id,
            c.name as channel_name,
            ga.account_name,
            ip.average_cost,
            ip.cost_currency,
            ip.quantity as available_quantity,  -- FIX: Only check actual quantity
            'Account-first rotation: New pool' as match_reason
        FROM inventory_pools ip
        JOIN game_accounts ga ON ip.game_account_id = ga.id
        JOIN channels c ON ip.channel_id = c.id
        WHERE ip.game_code = p_game_code
          AND COALESCE(ip.server_attribute_code, '') = COALESCE(p_server_attribute_code, '')
          AND ip.currency_attribute_id = p_currency_attribute_id
          AND ip.quantity >= p_required_quantity  -- FIX: Only check quantity, not reserved_quantity
          AND ip.average_cost > 0
        ORDER BY ip.average_cost ASC
        LIMIT 1;
    END IF;

    -- If still no pool found, return empty result
    IF NOT FOUND THEN
        RETURN QUERY
        SELECT false, 'No suitable inventory pool found', NULL::UUID, NULL::UUID, NULL::UUID,
               NULL::TEXT, NULL::TEXT, NULL::NUMERIC, NULL::TEXT, 0::NUMERIC, 'No match';
    END IF;
END;
$$;

-- 3. Revert assign_sell_order_with_inventory_v2 to original logic
DROP FUNCTION IF EXISTS assign_sell_order_with_inventory_v2(p_order_id UUID, p_user_id UUID, p_rotation_type TEXT) CASCADE;

CREATE OR REPLACE FUNCTION assign_sell_order_with_inventory_v2(
    p_order_id UUID DEFAULT NULL::UUID,
    p_user_id UUID DEFAULT NULL::UUID,
    p_rotation_type TEXT DEFAULT 'currency_first'::TEXT
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
SET search_path = 'public'
AS $$
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
    FROM currency_orders
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
        SELECT * INTO v_inventory_pool FROM get_inventory_pool_with_account_first_rotation(
            v_order.game_code,
            v_order.server_attribute_code,
            v_order.currency_attribute_id,
            v_order.quantity
        );
    ELSE
        -- Fall back to original currency-first rotation
        SELECT * INTO v_inventory_pool FROM get_inventory_pool_with_currency_rotation(
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

    -- Step 2: Find employee with fallback mechanism

    -- LEVEL 1: Try exact account assignment first
    SELECT * INTO v_employee
    FROM get_employee_for_account_in_shift(v_inventory_pool.game_account_id)
    LIMIT 1;

    IF v_employee.success THEN
        v_assignment_method := 'Direct assignment';
        v_fallback_reason := 'Exact account match';
    ELSE
        -- LEVEL 2: Fallback to any employee with same game code
        v_fallback_employee := ROW(false, NULL::UUID, '', ''::TEXT);

        SELECT * INTO v_fallback_employee
        FROM get_employee_fallback_for_game_code(
            v_order.game_code,
            NOW()::TIME,
            v_inventory_pool.game_account_id
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
                       COALESCE(v_inventory_pool.account_name, 'Unknown'),
                       v_order.game_code,
                       COALESCE(v_fallback_employee.employee_name, 'No fallback available')) as message,
                NULL::UUID, NULL::TEXT,
                v_inventory_pool.game_account_id, COALESCE(v_inventory_pool.account_name, 'Unknown'),
                v_inventory_pool.channel_id, v_inventory_pool.channel_name,
                v_cost_amount, v_cost_currency;
            RETURN;
        END IF;
    END IF;

    -- Step 3: Update database
    UPDATE currency_orders
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

    -- CORRECT: Reduce quantity AND increase reserved_quantity on assignment
    -- This reserves the stock for this specific customer
    UPDATE inventory_pools
    SET quantity = quantity - v_order.quantity,
        reserved_quantity = reserved_quantity + v_order.quantity,
        last_updated_at = NOW(),
        last_updated_by = v_current_user_id
    WHERE id = v_inventory_pool.inventory_pool_id;

    -- Return success with assignment method info
    RETURN QUERY
    SELECT
        true as success,
        format('%s assignment: %s -> %s (Account: %s)',
               CASE WHEN p_rotation_type = 'account_first' THEN 'Account-first' ELSE 'Currency-first' END,
               COALESCE(v_employee.employee_name, 'Unknown'), v_inventory_pool.channel_name,
               COALESCE(v_inventory_pool.account_name, 'Unknown')) as message,
        v_employee.employee_profile_id as assigned_employee_id,
        COALESCE(v_employee.employee_name, 'Unknown') as assigned_employee_name,
        v_inventory_pool.game_account_id as game_account_id,
        COALESCE(v_inventory_pool.account_name, 'Unknown') as game_account_name,
        v_inventory_pool.channel_id as channel_id,
        v_inventory_pool.channel_name as channel_name,
        v_cost_amount as cost_amount,
        v_cost_currency as cost_currency;

    RETURN;
END;
$$;

-- 4. Fix process_sell_order_delivery to only reduce reserved_quantity
DROP FUNCTION IF EXISTS process_sell_order_delivery(p_order_id UUID, p_delivery_proof_url TEXT, p_user_id UUID);

CREATE OR REPLACE FUNCTION process_sell_order_delivery(
    p_order_id UUID,
    p_delivery_proof_url TEXT,
    p_user_id UUID,
    p_delivery_proof_data JSONB DEFAULT NULL
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    order_id UUID,
    profit_amount NUMERIC,
    fees_breakdown JSONB
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO public
AS $$
DECLARE
    v_order RECORD;
    v_pool RECORD;
    v_cost_amount_usd NUMERIC;
    v_sale_amount_usd NUMERIC;
    v_profit_amount NUMERIC;
    v_profit_margin NUMERIC;
    v_exchange_rate_cost NUMERIC;
    v_exchange_rate_sale NUMERIC;
    v_process_id UUID;
    v_total_fees_usd NUMERIC := 0;
    v_fees_breakdown JSONB := '[]'::JSONB;
    v_fee_record RECORD;
    v_new_proof JSONB;
    v_transaction_unit_price NUMERIC;
    v_existing_proofs JSONB;
    v_delivery_filename TEXT;
BEGIN
    -- 1. Validate and get order information
    SELECT * INTO v_order FROM currency_orders
    WHERE id = p_order_id
      AND order_type = 'SALE'
      AND status IN ('assigned', 'delivering', 'ready', 'preparing');

    IF v_order IS NULL THEN
        RETURN QUERY SELECT false, 'Order not found, not a sale order, or not ready for delivery', NULL::UUID, NULL::NUMERIC, NULL::JSONB;
        RETURN;
    END IF;

    -- 2. Get inventory pool and validate quantity
    SELECT * INTO v_pool FROM inventory_pools WHERE id = v_order.inventory_pool_id;

    IF v_pool IS NULL THEN
        RETURN QUERY SELECT false, 'Inventory pool not found', NULL::UUID, NULL::NUMERIC, NULL::JSONB;
        RETURN;
    END IF;

    IF v_pool.reserved_quantity < v_order.quantity THEN
        RETURN QUERY SELECT
            false,
            format('Insufficient reserved quantity: required=%s, available=%s', v_order.quantity, v_pool.reserved_quantity),
            NULL::UUID,
            NULL::NUMERIC,
            NULL::JSONB
        ;
        RETURN;
    END IF;

    -- 3. Extract filename from provided data or derive from URL
    IF p_delivery_proof_data IS NOT NULL AND jsonb_typeof(p_delivery_proof_data) = 'object' THEN
        v_delivery_filename := p_delivery_proof_data->>'filename';
    END IF;

    IF v_delivery_filename IS NULL OR v_delivery_filename = '' THEN
        -- Try to extract filename from URL
        v_delivery_filename := substring(p_delivery_proof_url FROM '[^/]*$');
        -- If URL ends with timestamp pattern, try to find original filename in delivery proofs
        IF v_delivery_filename ~ '^\d{13}-\w{6}-' THEN
            -- Look for existing delivery proofs with proper filename
            SELECT COALESCE(proofs->>'filename', v_delivery_filename) INTO v_delivery_filename
            FROM currency_orders
            WHERE id = p_order_id
              AND jsonb_typeof(proofs) = 'array'
              AND EXISTS (
                  SELECT 1 FROM jsonb_array_elements(proofs) elem
                  WHERE elem->>'type' = 'delivery'
                    AND elem->>'filename' IS NOT NULL
                    AND elem->>'filename' != ''
              )
            LIMIT 1;
        END IF;
    END IF;

    -- 4. Prepare delivery proof with consistent type and filename
    v_new_proof := jsonb_build_object(
        'type', 'delivery',
        'url', p_delivery_proof_url,
        'filename', COALESCE(v_delivery_filename, 'delivery_proof'),
        'uploaded_at', NOW(),
        'uploaded_by', p_user_id
    );

    -- 5. Handle existing proofs - FIX: Handle both array and object formats
    v_existing_proofs := COALESCE(v_order.proofs, '[]'::JSONB);

    -- If proofs is an object, convert to array
    IF jsonb_typeof(v_existing_proofs) = 'object' THEN
        v_existing_proofs := jsonb_build_array(v_existing_proofs);
    ELSIF jsonb_typeof(v_existing_proofs) != 'array' THEN
        v_existing_proofs := '[]'::JSONB;
    END IF;

    -- 6. Get current exchange rates
    BEGIN
        -- Convert cost to USD if needed
        IF v_order.cost_currency_code = 'USD' THEN
            v_cost_amount_usd := v_order.cost_amount;
            v_exchange_rate_cost := 1;
        ELSIF v_order.cost_currency_code = 'CNY' THEN
            v_exchange_rate_cost := get_exchange_rate_for_delivery('CNY', 'USD', CURRENT_DATE);
            v_cost_amount_usd := v_order.cost_amount * v_exchange_rate_cost;
        ELSIF v_order.cost_currency_code = 'VND' THEN
            v_exchange_rate_cost := get_exchange_rate_for_delivery('VND', 'USD', CURRENT_DATE);
            v_cost_amount_usd := v_order.cost_amount * v_exchange_rate_cost;
        ELSE
            v_exchange_rate_cost := get_exchange_rate_for_delivery(v_order.cost_currency_code, 'USD', CURRENT_DATE);
            v_cost_amount_usd := v_order.cost_amount * v_exchange_rate_cost;
        END IF;

        -- Convert sale to USD if needed
        IF v_order.sale_currency_code = 'USD' THEN
            v_sale_amount_usd := v_order.sale_amount;
            v_exchange_rate_sale := 1;
        ELSE
            v_exchange_rate_sale := get_exchange_rate_for_delivery(v_order.sale_currency_code, 'USD', CURRENT_DATE);
            v_sale_amount_usd := v_order.sale_amount * v_exchange_rate_sale;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        RETURN QUERY SELECT false, 'Exchange rate not available: ' || SQLERRM, NULL::UUID, NULL::NUMERIC, NULL::JSONB;
        RETURN;
    END;

    -- 7. Calculate profit using CASCADE method (simplified for this fix)
    v_transaction_unit_price := v_cost_amount_usd / v_order.quantity;
    v_profit_amount := v_sale_amount_usd - v_cost_amount_usd;

    IF v_cost_amount_usd > 0 THEN
        v_profit_margin := (v_profit_amount / v_cost_amount_usd) * 100;
    ELSE
        v_profit_margin := 0;
    END IF;

    -- 8. Update inventory pool - only reduce reserved_quantity on delivery
    -- quantity was already reduced when order was assigned
    UPDATE inventory_pools SET
        reserved_quantity = reserved_quantity - v_order.quantity,
        last_updated_at = NOW(),
        last_updated_by = p_user_id
    WHERE id = v_pool.id;

    -- 9. Create transaction record
    INSERT INTO currency_transactions (
        game_account_id,
        game_code,
        server_attribute_code,
        transaction_type,
        currency_attribute_id,
        quantity,
        unit_price,
        currency_code,
        currency_order_id,
        proofs,
        created_by,
        created_at
    ) VALUES (
        v_pool.game_account_id,
        v_order.game_code,
        v_order.server_attribute_code,
        'sale_delivery',
        v_order.currency_attribute_id,
        v_order.quantity,
        v_transaction_unit_price,
        'USD',
        p_order_id,
        jsonb_build_array(v_new_proof),
        p_user_id,
        NOW()
    );

    -- 10. Update currency order with delivery information - FIX: Properly handle proofs
    UPDATE currency_orders SET
        status = 'completed',
        completed_at = NOW(),
        delivery_at = NOW(),
        delivered_by = p_user_id,
        profit_amount = v_profit_amount,
        profit_currency_code = 'USD',
        profit_margin_percentage = v_profit_margin,
        cost_to_sale_exchange_rate = v_exchange_rate_cost,
        exchange_rate_date = CURRENT_DATE,
        exchange_rate_source = 'system',
        proofs = v_existing_proofs || v_new_proof
    WHERE id = p_order_id;

    -- 11. Return success result
    RETURN QUERY SELECT
        true,
        'Delivery processed successfully',
        p_order_id,
        v_profit_amount,
        v_fees_breakdown;

EXCEPTION
    WHEN OTHERS THEN
        -- Return error information
        RETURN QUERY SELECT
            false,
            'Delivery processing failed: ' || SQLERRM,
            NULL::UUID,
            NULL::NUMERIC,
            NULL::JSONB;
END;
$$;

-- Grant permissions for all functions
GRANT EXECUTE ON FUNCTION get_inventory_pool_with_currency_rotation TO authenticated;
GRANT EXECUTE ON FUNCTION get_inventory_pool_with_currency_rotation TO service_role;

GRANT EXECUTE ON FUNCTION get_inventory_pool_with_account_first_rotation TO authenticated;
GRANT EXECUTE ON FUNCTION get_inventory_pool_with_account_first_rotation TO service_role;

GRANT EXECUTE ON FUNCTION assign_sell_order_with_inventory_v2 TO authenticated;
GRANT EXECUTE ON FUNCTION assign_sell_order_with_inventory_v2 TO service_role;

GRANT EXECUTE ON FUNCTION process_sell_order_delivery TO authenticated;

-- Verification
DO $$
BEGIN
    RAISE NOTICE '==========================================';
    RAISE NOTICE 'INVENTORY CHECK LOGIC FIX COMPLETED';
    RAISE NOTICE '==========================================';
    RAISE NOTICE 'Fixed: Inventory pools now only check quantity (not reserved_quantity)';
    RAISE NOTICE 'Fixed: Assignment reduces quantity and increases reserved_quantity';
    RAISE NOTICE 'Fixed: Delivery only reduces reserved_quantity';
    RAISE NOTICE 'This ensures reserved stock is not double-counted';
    RAISE NOTICE '';
    RAISE NOTICE 'Important: When cancelling orders, you must:';
    RAISE NOTICE '1. Use cancel_sell_order() function for sell orders';
    RAISE NOTICE '2. This will restore: quantity += order_quantity';
    RAISE NOTICE '3. This will update: reserved_quantity -= order_quantity';
    RAISE NOTICE '==========================================';
END $$;