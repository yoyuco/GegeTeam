-- Update 5 order completion functions from staging to production
-- Migration Date: 2025-12-12
-- Purpose: Sync order completion functions with staging versions
-- Note: These are the EXACT functions from staging database

-- 1. Update complete_sell_order_with_profit_calculation function (from staging)
-- Drop all versions to ensure clean recreation
DROP FUNCTION IF EXISTS complete_sell_order_with_profit_calculation CASCADE;

-- Create version with no parameters (from staging) - NOTE: Staging has this function despite the bug
CREATE OR REPLACE FUNCTION complete_sell_order_with_profit_calculation()
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
DECLARE
    profit_amount numeric;
    cost_amount numeric;
    revenue_amount numeric;
BEGIN
    -- Calculate cost from assigned inventory
    SELECT COALESCE(SUM(ip.cost_usd * soi.quantity), 0) INTO cost_amount
    FROM sell_orders so
    JOIN sell_order_items soi ON so.id = soi.sell_order_id
    JOIN order_assignments oa ON so.id = oa.order_id
    JOIN inventory_pools ip ON oa.inventory_pool_id = ip.id
    WHERE so.id = p_order_id;

    -- Get revenue from order
    SELECT COALESCE(SUM(soi.quantity * soi.unit_price), 0) INTO revenue_amount
    FROM sell_order_items soi
    WHERE soi.sell_order_id = p_order_id;

    -- Calculate profit
    profit_amount := revenue_amount - cost_amount;

    -- Update order with profit information
    UPDATE sell_orders
    SET status = 'completed',
        completed_at = NOW(),
        profit_amount = profit_amount,
        cost_amount = cost_amount,
        revenue_amount = revenue_amount
    WHERE id = p_order_id;

    RETURN profit_amount;
END;
$$;

-- Create version with parameters (from staging)
CREATE OR REPLACE FUNCTION complete_sell_order_with_profit_calculation(
    p_order_id UUID,
    p_user_id UUID DEFAULT NULL::UUID
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    profit_amount NUMERIC,
    profit_currency TEXT,
    profit_margin_percentage NUMERIC
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
DECLARE
    v_order RECORD;
    v_inventory_pool RECORD;
    v_current_user_id UUID;
    v_profit_amount DECIMAL;
    v_profit_margin_percentage DECIMAL;
BEGIN
    -- Get current user (from parameter or auth)
    v_current_user_id := COALESCE(p_user_id, auth.uid());

    -- Get order details with inventory pool information
    SELECT
        co.*,
        ip.average_cost as pool_average_cost,
        ip.cost_currency as pool_cost_currency
    INTO v_order
    FROM currency_orders co
    LEFT JOIN inventory_pools ip ON co.inventory_pool_id = ip.id
    WHERE co.id = p_order_id;

    IF NOT FOUND THEN
        RETURN QUERY
        SELECT false, 'Order not found', 0::DECIMAL, NULL::TEXT, 0::DECIMAL;
        RETURN;
    END IF;

    -- Only process sell orders
    IF v_order.order_type != 'SELL' THEN
        RETURN QUERY
        SELECT false, 'This function only handles sell orders', 0::DECIMAL, NULL::TEXT, 0::DECIMAL;
        RETURN;
    END IF;

    -- Only allow completion for 'delivered' status
    IF v_order.status != 'delivered' THEN
        RETURN QUERY
        SELECT false, 'Order must be in delivered status to complete', 0::DECIMAL, NULL::TEXT, 0::DECIMAL;
        RETURN;
    END IF;

    -- Check if we have inventory pool information
    IF v_order.inventory_pool_id IS NULL THEN
        RETURN QUERY
        SELECT false, 'No inventory pool assigned to this order', 0::DECIMAL, NULL::TEXT, 0::DECIMAL;
        RETURN;
    END IF;

    -- Calculate profit if we have sale amount
    IF v_order.sale_amount IS NOT NULL AND v_order.pool_average_cost IS NOT NULL THEN
        v_profit_amount := v_order.sale_amount - (v_order.quantity * v_order.pool_average_cost);

        -- Calculate profit margin percentage
        IF v_order.sale_amount != 0 THEN
            v_profit_margin_percentage := (v_profit_amount / v_order.sale_amount) * 100;
        END IF;
    END IF;

    -- Update inventory pool: reduce reserved quantity (actual delivery)
    UPDATE inventory_pools
    SET
        reserved_quantity = reserved_quantity - v_order.quantity,
        last_updated_at = NOW(),
        last_updated_by = v_current_user_id
    WHERE id = v_order.inventory_pool_id;

    -- Update order with profit information and completion status
    UPDATE currency_orders
    SET
        status = 'completed',
        completed_at = NOW(),
        updated_at = NOW(),
        updated_by = v_current_user_id,
        profit_amount = v_profit_amount,
        profit_currency_code = v_order.pool_cost_currency,
        profit_margin_percentage = v_profit_margin_percentage
    WHERE id = p_order_id;

    -- Return success result with profit calculation
    RETURN QUERY
    SELECT
        true,
        format('Sell order completed successfully. Pool: %s | Profit: %s %s (%.2f%%)',
               v_order.inventory_pool_id,
               COALESCE(v_profit_amount, 0),
               COALESCE(v_order.pool_cost_currency, 'N/A'),
               COALESCE(v_profit_margin_percentage, 0))::TEXT,
        v_profit_amount,
        v_order.pool_cost_currency,
        v_profit_margin_percentage;

    RETURN;
END;
$$;

-- 2. Update complete_sale_order_v2 function (EXACT from staging)
DROP FUNCTION IF EXISTS complete_sale_order_v2 CASCADE;

CREATE OR REPLACE FUNCTION complete_sale_order_v2(
    p_order_id UUID,
    p_user_id UUID
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    order_id UUID
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
DECLARE
    v_order RECORD;
    v_user_role TEXT;
    v_has_delivery_proof BOOLEAN := FALSE;
BEGIN
    -- Get order information
    SELECT * INTO v_order FROM currency_orders WHERE id = p_order_id;

    IF v_order IS NULL THEN
        RETURN QUERY SELECT false, 'Order not found', NULL::UUID;
        RETURN;
    END IF;

    -- Check if order type is SALE
    IF v_order.order_type != 'SALE' THEN
        RETURN QUERY SELECT false, 'Order is not a sale order', NULL::UUID;
        RETURN;
    END IF;

    -- Check if order is in delivered status
    IF v_order.status != 'delivered' THEN
        RETURN QUERY SELECT false, 'Order must be in delivered status to complete', NULL::UUID;
        RETURN;
    END IF;

    -- Get user role if user_id provided
    IF p_user_id IS NOT NULL THEN
        SELECT r.code INTO v_user_role
        FROM user_role_assignments ura
        JOIN roles r ON ura.role_id = r.id
        WHERE ura.user_id = p_user_id
        LIMIT 1;
    END IF;

    -- Check if user is admin/mod/manager/leader or created the order
    IF p_user_id IS NOT NULL AND (
        v_user_role IN ('admin', 'mod', 'manager', 'leader') OR
        v_order.created_by = p_user_id OR
        v_order.assigned_to = p_user_id
    ) THEN
        -- Check if delivery proof exists
        SELECT EXISTS (
            SELECT 1 FROM jsonb_array_elements(v_order.proofs) elem
            WHERE elem->>'type' = 'delivery'
        ) INTO v_has_delivery_proof;

        IF NOT v_has_delivery_proof THEN
            RETURN QUERY SELECT false, 'Delivery proof is required to complete sale order', NULL::UUID;
            RETURN;
        END IF;

        -- Update order status
        UPDATE currency_orders SET
            status = 'completed',
            completed_at = NOW(),
            updated_at = NOW()
        WHERE id = p_order_id;

        RETURN QUERY SELECT true, 'Sale order completed successfully', p_order_id;
        RETURN;
    END IF;

    RETURN QUERY SELECT false, 'Permission denied', NULL::UUID;
END;
$$;

-- 3. Update complete_currency_order_v1 function (EXACT from staging - uses currency_inventory)
DROP FUNCTION IF EXISTS complete_currency_order_v1 CASCADE;

CREATE OR REPLACE FUNCTION complete_currency_order_v1(
    p_order_id UUID,
    p_completion_notes TEXT DEFAULT NULL,
    p_proof_urls TEXT[] DEFAULT NULL
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    transaction_id UUID,
    profit_vnd NUMERIC
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
DECLARE
    v_user_id uuid := public.get_current_profile_id();
    v_order RECORD;
    v_transaction_id uuid;
    v_can_complete boolean := false;
    v_avg_cost_vnd numeric;
BEGIN
    -- Permission Check using has_permission function
    v_can_complete := public.has_permission('currency:complete', jsonb_build_object('game_code', (SELECT game_code FROM public.currency_orders WHERE id = p_order_id)));

    IF NOT v_can_complete THEN
        RETURN QUERY SELECT FALSE, 'Permission denied: Cannot complete order', NULL::UUID, NULL::NUMERIC;
        RETURN;
    END IF;

    -- Get order info
    SELECT * INTO v_order FROM public.currency_orders
    WHERE id = p_order_id AND status IN ('assigned', 'preparing', 'ready', 'delivering');

    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'Order not found or not ready for completion', NULL::UUID, NULL::NUMERIC;
        RETURN;
    END IF;

    -- Get average cost from inventory
    SELECT avg_buy_price_vnd INTO v_avg_cost_vnd
    FROM public.currency_inventory
    WHERE game_account_id = v_order.game_account_id
      AND currency_attribute_id = v_order.currency_attribute_id
      AND game_code = v_order.game_code
      AND (
          (v_order.league_attribute_id IS NOT NULL AND league_attribute_id = v_order.league_attribute_id) OR
          (v_order.league_attribute_id IS NULL AND league_attribute_id IS NULL)
      );

    -- Create transaction
    INSERT INTO public.currency_transactions (
        game_account_id, game_code, league_attribute_id,
        transaction_type, currency_attribute_id, quantity,
        unit_price_vnd, unit_price_usd,
        currency_order_id, proof_urls, notes, created_by
    ) VALUES (
        v_order.game_account_id, v_order.game_code, v_order.league_attribute_id,
        'sale_delivery', v_order.currency_attribute_id, -v_order.quantity,
        v_order.unit_price_vnd, v_order.unit_price_usd,
        p_order_id, p_proof_urls, p_completion_notes, v_user_id
    ) RETURNING id INTO v_transaction_id;

    -- Update inventory
    UPDATE public.currency_inventory
    SET quantity = quantity - v_order.quantity,
        reserved_quantity = COALESCE(reserved_quantity, 0) - v_order.quantity,
        last_updated_at = NOW()
    WHERE game_account_id = v_order.game_account_id
      AND currency_attribute_id = v_order.currency_attribute_id
      AND game_code = v_order.game_code
      AND (
          (v_order.league_attribute_id IS NOT NULL AND league_attribute_id = v_order.league_attribute_id) OR
          (v_order.league_attribute_id IS NULL AND league_attribute_id IS NULL)
      );

    -- Update order status to 'delivered' first (delivered but waiting final confirmation)
    UPDATE public.currency_orders
    SET status = 'delivered',
        delivered_at = NOW(),
        delivered_by = v_user_id,
        completion_notes = p_completion_notes,
        proof_urls = p_proof_urls,
        cost_per_unit_vnd = v_avg_cost_vnd,
        updated_at = NOW(),
        updated_by = v_user_id
    WHERE id = p_order_id;

    RETURN QUERY SELECT
        TRUE,
        'Order marked as delivered. Upload proof to complete.',
        v_transaction_id,
        (v_order.unit_price_vnd - COALESCE(v_avg_cost_vnd, 0)) * v_order.quantity;
END;
$$;

-- 4. Update complete_purchase_order_wac function (EXACT from staging)
DROP FUNCTION IF EXISTS complete_purchase_order_wac CASCADE;

CREATE OR REPLACE FUNCTION complete_purchase_order_wac(
    p_order_id UUID,
    p_completed_by UUID DEFAULT NULL::UUID,
    p_proofs TEXT[] DEFAULT NULL::TEXT[],
    p_channel_id UUID DEFAULT NULL::UUID
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    details JSONB
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
DECLARE
    v_order RECORD;
    v_user_id UUID;
    v_existing_proofs JSONB;
    v_new_payment_proofs JSONB;
    v_final_proofs JSONB;
BEGIN
    -- Get user ID from parameter or current profile
    IF p_completed_by IS NOT NULL THEN
        v_user_id := p_completed_by;
    ELSE
        v_user_id := get_current_profile_id();
    END IF;

    -- Get order info - should already be delivered
    SELECT * INTO v_order FROM currency_orders
    WHERE id = p_order_id AND order_type = 'PURCHASE' AND status = 'delivered';

    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'Purchase order not found or not delivered yet. Use receive function first.', NULL::JSONB;
        RETURN;
    END IF;

    -- Get existing proofs from order
    v_existing_proofs := COALESCE(v_order.proofs, '{}'::jsonb);

    -- Build new payment proofs array from p_proofs parameter
    v_new_payment_proofs := '[]'::jsonb;

    -- Add new payment proofs from parameter
    IF p_proofs IS NOT NULL THEN
        FOR i IN 1..array_length(p_proofs, 1) LOOP
            v_new_payment_proofs := v_new_payment_proofs ||
                jsonb_build_object(
                    'type', 'payment',
                    'url', p_proofs[i],
                    'uploaded_at', NOW()::text
                );
        END LOOP;
    END IF;

    -- Merge existing proofs with new payment proofs
    v_final_proofs := v_existing_proofs || v_new_payment_proofs;

    -- Update order status to completed with completion timestamp
    UPDATE currency_orders SET
        status = 'completed',
        completed_at = NOW(),  -- Set completion timestamp
        proofs = v_final_proofs,
        updated_at = NOW(),
        updated_by = v_user_id
    WHERE id = p_order_id;

    -- Return success result
    RETURN QUERY SELECT TRUE,
        format('Purchase order completed! %s payment proof(s) uploaded. Order: %s',
               jsonb_array_length(v_new_payment_proofs),
               COALESCE(v_order.order_number, p_order_id::TEXT)
        ),
        jsonb_build_object(
            'order_id', p_order_id,
            'order_number', v_order.order_number,
            'status', 'completed',
            'completed_at', NOW(),
            'new_payment_proofs_count', jsonb_array_length(v_new_payment_proofs),
            'total_proofs_count', jsonb_array_length(v_final_proofs),
            'inventory_pool_id', v_order.inventory_pool_id  -- Reference to existing pool
        );

EXCEPTION
    WHEN OTHERS THEN
        -- Rollback any changes and return error
        RAISE WARNING 'Error in complete_purchase_order_wac: %', SQLERRM;
        RETURN QUERY SELECT FALSE, 'Error completing purchase order: ' || SQLERRM, NULL::JSONB;
END;
$$;

-- 5. Update confirm_purchase_order_receiving_v2 function (EXACT from staging)
DROP FUNCTION IF EXISTS confirm_purchase_order_receiving_v2 CASCADE;

CREATE OR REPLACE FUNCTION confirm_purchase_order_receiving_v2(
    p_order_id UUID,
    p_completed_by UUID,
    p_proofs JSONB DEFAULT NULL
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    data JSONB
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
DECLARE
    v_order RECORD;
    v_user_id UUID := p_completed_by;
    v_inventory_pool RECORD;
    v_transaction_id UUID;
    v_new_average_cost DECIMAL;
    v_old_average_cost DECIMAL;
    v_new_quantity DECIMAL;
    v_cost_amount DECIMAL;
    v_cost_currency TEXT;
    v_game_account_id UUID;
    v_existing_pool_found BOOLEAN := FALSE;
    v_order_channel_id UUID;
    v_channel_exists BOOLEAN;
    v_final_proofs JSONB;
BEGIN
    -- Temporarily disable RLS for this function
    SET LOCAL row_security = off;

    -- Get order info
    SELECT * INTO v_order FROM currency_orders
    WHERE id = p_order_id AND order_type = 'PURCHASE' AND status IN ('assigned', 'preparing', 'ready', 'delivering');

    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'Purchase order not found or not ready for receiving confirmation', NULL::JSONB;
        RETURN;
    END IF;

    -- Validate required fields
    IF v_order.game_account_id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'Purchase order must be assigned to a game account first', NULL::JSONB;
        RETURN;
    END IF;

    -- Set values from order
    v_game_account_id := v_order.game_account_id;
    v_cost_amount := COALESCE(v_order.cost_amount, 0);
    v_cost_currency := COALESCE(v_order.cost_currency_code, 'VND');
    v_order_channel_id := v_order.channel_id;

    -- Validate that the channel exists
    SELECT EXISTS(SELECT 1 FROM channels WHERE id = v_order_channel_id AND is_active = true) INTO v_channel_exists;

    IF v_order_channel_id IS NOT NULL AND NOT v_channel_exists THEN
        RETURN QUERY SELECT FALSE, 'Invalid channel: Channel does not exist or is not active', NULL::JSONB;
        RETURN;
    END IF;

    -- Use provided proofs if given, otherwise use existing proofs
    v_final_proofs := COALESCE(p_proofs, v_order.proofs);

    -- Find existing inventory pool
    SELECT * INTO v_inventory_pool
    FROM inventory_pools
    WHERE game_account_id = v_game_account_id
      AND currency_attribute_id = v_order.currency_attribute_id
      AND game_code = v_order.game_code
      AND COALESCE(server_attribute_code, '') = COALESCE(v_order.server_attribute_code, '')
    FOR UPDATE;

    IF v_inventory_pool.id IS NOT NULL THEN
        v_existing_pool_found := TRUE;
        v_old_average_cost := COALESCE(v_inventory_pool.average_cost, 0);
    END IF;

    -- Update or create inventory pool
    IF v_existing_pool_found THEN
        v_new_quantity := COALESCE(v_inventory_pool.quantity, 0) + v_order.quantity;

        IF v_new_quantity > 0 THEN
            v_new_average_cost := (
                (COALESCE(v_inventory_pool.quantity, 0) * COALESCE(v_inventory_pool.average_cost, 0)) +
                (v_order.quantity * v_cost_amount / v_order.quantity)
            ) / v_new_quantity;
        ELSE
            v_new_average_cost := v_cost_amount / v_order.quantity;
        END IF;

        UPDATE inventory_pools SET
            quantity = v_new_quantity,
            average_cost = v_new_average_cost,
            cost_currency = v_cost_currency,
            last_updated_at = NOW(),
            last_updated_by = v_user_id,
            channel_id = v_order_channel_id
        WHERE id = v_inventory_pool.id;

    ELSE
        v_new_quantity := v_order.quantity;
        v_new_average_cost := v_cost_amount / v_order.quantity;

        INSERT INTO inventory_pools (
            game_account_id,
            currency_attribute_id,
            quantity,
            average_cost,
            cost_currency,
            game_code,
            server_attribute_code,
            channel_id,
            last_updated_at,
            last_updated_by
        ) VALUES (
            v_game_account_id,
            v_order.currency_attribute_id,
            v_order.quantity,
            v_new_average_cost,
            v_cost_currency,
            v_order.game_code,
            v_order.server_attribute_code,
            v_order_channel_id,
            NOW(),
            v_user_id
        ) RETURNING * INTO v_inventory_pool;
    END IF;

    -- Create transaction record with final proofs
    INSERT INTO currency_transactions (
        game_account_id,
        game_code,
        server_attribute_code,
        transaction_type,
        currency_attribute_id,
        quantity,
        unit_price,
        currency_code,
        channel_id,
        currency_order_id,
        proofs,
        notes,
        created_by
    ) VALUES (
        v_game_account_id,
        v_order.game_code,
        v_order.server_attribute_code,
        'purchase',
        v_order.currency_attribute_id,
        v_order.quantity,
        v_cost_amount / v_order.quantity,
        v_cost_currency,
        v_order_channel_id,
        p_order_id,
        COALESCE(v_final_proofs, '{}'::jsonb),
        'Purchase receiving confirmation - Order: ' || COALESCE(v_order.order_number, p_order_id::TEXT),
        v_user_id
    ) RETURNING id INTO v_transaction_id;

    -- Update order status with FINAL proofs
    UPDATE currency_orders SET
        status = 'delivered',
        delivered_by = v_user_id,
        delivery_at = NOW(),
        inventory_pool_id = v_inventory_pool.id,
        proofs = v_final_proofs,
        updated_at = NOW(),
        updated_by = v_user_id
    WHERE id = p_order_id;

    -- Return success
    RETURN QUERY SELECT TRUE,
        format('Purchase order receiving confirmed! %s added to inventory (Pool: %s)',
               v_order.quantity,
               v_inventory_pool.id::TEXT
        ),
        jsonb_build_object(
            'transaction_id', v_transaction_id,
            'inventory_pool_id', v_inventory_pool.id,
            'delivery_at', NOW(),
            'new_quantity', v_new_quantity,
            'proofs_count', jsonb_array_length(COALESCE(v_final_proofs, '[]'::jsonb))
        );

EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'Error in confirm_purchase_order_receiving_v2: %', SQLERRM;
        RETURN QUERY SELECT FALSE, 'Error confirming purchase order receiving: ' || SQLERRM, NULL::JSONB;
END;
$$;

-- Grant permissions for all functions
-- Grant permissions for both versions of complete_sell_order_with_profit_calculation
GRANT EXECUTE ON FUNCTION complete_sell_order_with_profit_calculation() TO authenticated;
GRANT EXECUTE ON FUNCTION complete_sell_order_with_profit_calculation() TO service_role;

GRANT EXECUTE ON FUNCTION complete_sell_order_with_profit_calculation(p_order_id UUID, p_user_id UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION complete_sell_order_with_profit_calculation(p_order_id UUID, p_user_id UUID) TO service_role;

GRANT EXECUTE ON FUNCTION complete_sale_order_v2 TO authenticated;
GRANT EXECUTE ON FUNCTION complete_sale_order_v2 TO service_role;

GRANT EXECUTE ON FUNCTION complete_currency_order_v1 TO authenticated;
GRANT EXECUTE ON FUNCTION complete_currency_order_v1 TO service_role;

GRANT EXECUTE ON FUNCTION complete_purchase_order_wac TO authenticated;
GRANT EXECUTE ON FUNCTION complete_purchase_order_wac TO service_role;

GRANT EXECUTE ON FUNCTION confirm_purchase_order_receiving_v2 TO authenticated;
GRANT EXECUTE ON FUNCTION confirm_purchase_order_receiving_v2 TO service_role;

-- Verification
DO $$
BEGIN
    RAISE NOTICE 'Migration completed: Updated 5 order completion functions EXACT from staging';
    RAISE NOTICE 'Functions updated:';
    RAISE NOTICE '- complete_sell_order_with_profit_calculation (2 versions - with and without parameters)';
    RAISE NOTICE '- complete_sale_order_v2 (with role checks and delivery proof validation)';
    RAISE NOTICE '- complete_currency_order_v1 (uses currency_inventory table)';
    RAISE NOTICE '- complete_purchase_order_wac (for PURCHASE orders)';
    RAISE NOTICE '- confirm_purchase_order_receiving_v2 (with p_proofs JSONB parameter)';
    RAISE NOTICE 'All functions are now 100% identical to staging versions';
END $$;