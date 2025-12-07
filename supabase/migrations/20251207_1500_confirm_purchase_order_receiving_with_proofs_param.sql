-- Add proofs parameter to confirm_purchase_order_receiving_v2 function
-- Migration Date: 2025-12-07
-- Purpose: Function should receive proofs from frontend instead of reading from database

-- Drop and recreate the function with proofs parameter
DROP FUNCTION IF EXISTS confirm_purchase_order_receiving_v2(p_order_id UUID, p_completed_by UUID);

CREATE OR REPLACE FUNCTION confirm_purchase_order_receiving_v2(
    p_order_id UUID,
    p_completed_by UUID,
    p_proofs JSONB DEFAULT NULL
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    data JSONB
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO public
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

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION confirm_purchase_order_receiving_v2 TO authenticated;

-- Verification
DO $$
BEGIN
    RAISE NOTICE 'Migration completed: confirm_purchase_order_receiving_v2 now accepts proofs parameter';
    RAISE NOTICE 'Function signature: confirm_purchase_order_receiving_v2(p_order_id, p_completed_by, p_proofs)';
    RAISE NOTICE 'Frontend should pass proofs directly to avoid timing issues';
END $$;