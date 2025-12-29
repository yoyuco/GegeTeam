-- Update confirm_purchase_order_receiving_v2 to ensure ALL columns are filled correctly
-- Fixes:
-- - Removed channel_id from currency_transactions insert (column doesn't exist)
-- - Added before_quantity and after_quantity tracking for pool changes
--
-- Note: assigned_at, assigned_to, preparation_at should be set by auto_assign_currency_order_on_view
-- when status changes to 'preparing'

CREATE OR REPLACE FUNCTION confirm_purchase_order_receiving_v2(
    p_order_id UUID,
    p_completed_by UUID,
    p_proofs JSONB DEFAULT NULL
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    details JSONB
) SECURITY DEFINER SET search_path = 'public'
AS $$
DECLARE
    v_order RECORD;
    v_user_id UUID := p_completed_by;
    v_inventory_pool RECORD;
    v_transaction_id UUID;
    v_new_average_cost DECIMAL;
    v_old_average_cost DECIMAL;
    v_new_quantity DECIMAL;
    v_old_quantity DECIMAL;
    v_cost_amount DECIMAL;
    v_cost_currency TEXT;
    v_game_account_id UUID;
    v_proof_urls TEXT[];
    v_existing_pool_found BOOLEAN := FALSE;
    v_order_channel_id UUID;
    v_channel_exists BOOLEAN := FALSE;
    v_existing_proofs JSONB;
    v_final_proofs JSONB;
    v_index INTEGER;
BEGIN
    -- Temporarily disable RLS for this function
    SET LOCAL row_security = off;

    -- Get order info with ALL timestamp fields
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

    -- Handle existing proofs - Append instead of replace
    v_existing_proofs := COALESCE(v_order.proofs, '[]'::JSONB);

    -- Ensure proofs is an array
    IF jsonb_typeof(v_existing_proofs) != 'array' THEN
        v_existing_proofs := '[]'::JSONB;
    END IF;

    -- Remove existing receiving proofs to avoid duplicates
    v_existing_proofs := (
        SELECT jsonb_agg(proof)
        FROM jsonb_array_elements(v_existing_proofs) AS proof
        WHERE proof->>'type' != 'receiving'
    );

    -- Process new proofs if provided
    IF p_proofs IS NOT NULL THEN
        -- Convert single proof to array if needed
        IF jsonb_typeof(p_proofs) != 'array' THEN
            p_proofs := jsonb_build_array(p_proofs);
        END IF;

        -- Build receiving proof objects
        v_final_proofs := '[]'::JSONB;

        FOR v_index IN 0..jsonb_array_length(p_proofs) - 1 LOOP
            v_final_proofs := v_final_proofs || jsonb_build_array(
                jsonb_set(
                    jsonb_set(
                        jsonb_extract_path(p_proofs, v_index::TEXT),
                        '{type}', '"receiving"'::jsonb
                    ),
                    '{uploaded_at}', to_jsonb(NOW())
                )
            );
        END LOOP;

        -- Combine existing proofs with new receiving proofs
        v_final_proofs := v_existing_proofs || v_final_proofs;
    ELSE
        v_final_proofs := v_existing_proofs;
    END IF;

    -- Find existing inventory pool
    SELECT * INTO v_inventory_pool
    FROM inventory_pools
    WHERE game_account_id = v_game_account_id
      AND currency_attribute_id = v_order.currency_attribute_id
      AND game_code = v_order.game_code
      AND COALESCE(server_attribute_code, '') = COALESCE(v_order.server_attribute_code, '')
      AND COALESCE(channel_id, '00000000-0000-0000-0000-000000000000') = COALESCE(v_order_channel_id, '00000000-0000-0000-0000-000000000000')
    FOR UPDATE;

    IF v_inventory_pool.id IS NOT NULL THEN
        v_existing_pool_found := TRUE;
        v_old_average_cost := COALESCE(v_inventory_pool.average_cost, 0);
        v_old_quantity := COALESCE(v_inventory_pool.quantity, 0);
    ELSE
        v_old_quantity := 0;
    END IF;

    -- Update or create inventory pool
    IF v_existing_pool_found THEN
        v_new_quantity := v_old_quantity + v_order.quantity;

        IF v_new_quantity > 0 THEN
            v_new_average_cost := (
                (v_old_quantity * v_old_average_cost) +
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

    -- Create transaction record with ALL columns filled
    -- FIXED: Removed channel_id (doesn't exist in currency_transactions)
    -- FIXED: Added before_quantity and after_quantity for pool tracking
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
        notes,
        created_by,
        before_quantity,
        after_quantity
    ) VALUES (
        v_game_account_id,
        v_order.game_code,
        v_order.server_attribute_code,
        'purchase',
        v_order.currency_attribute_id,
        v_order.quantity,
        v_cost_amount / v_order.quantity,
        v_cost_currency,
        p_order_id,
        v_final_proofs,
        'Purchase receiving confirmation - Order: ' || COALESCE(v_order.order_number, p_order_id::TEXT),
        v_user_id,
        v_old_quantity,
        v_new_quantity
    ) RETURNING id INTO v_transaction_id;

    -- Update order status with delivery timestamps
    UPDATE currency_orders SET
        status = 'delivered',
        ready_at = COALESCE(ready_at, NOW()),
        delivered_by = v_user_id,
        delivery_at = NOW(),
        inventory_pool_id = v_inventory_pool.id,
        proofs = v_final_proofs,
        updated_at = NOW(),
        updated_by = v_user_id
    WHERE id = p_order_id;

    -- Return success
    RETURN QUERY SELECT TRUE,
        format('Purchase order receiving confirmed! %s added to inventory (Pool: %s, Before: %s, After: %s)',
               v_order.quantity,
               v_inventory_pool.id::TEXT,
               v_old_quantity::TEXT,
               v_new_quantity::TEXT
        ),
        jsonb_build_object(
            'transaction_id', v_transaction_id,
            'inventory_pool_id', v_inventory_pool.id,
            'delivery_at', NOW(),
            'before_quantity', v_old_quantity,
            'after_quantity', v_new_quantity,
            'proofs_added', COALESCE(jsonb_array_length(p_proofs), 0)
        );

EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'Error in confirm_purchase_order_receiving_v2: %', SQLERRM;
        RETURN QUERY SELECT FALSE, 'Error confirming purchase order receiving: ' || SQLERRM, NULL::JSONB;
END;
$$ LANGUAGE plpgsql;

-- Grant permissions
GRANT EXECUTE ON FUNCTION confirm_purchase_order_receiving_v2(UUID, UUID, JSONB) TO authenticated;

-- Verify function update
SELECT
    proname as function_name,
    'FIXED' as status,
    'All columns filled: removed channel_id, added before_quantity/after_quantity' as notes
FROM pg_proc
WHERE proname = 'confirm_purchase_order_receiving_v2';
