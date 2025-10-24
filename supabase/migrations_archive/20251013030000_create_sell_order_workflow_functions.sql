-- ===================================
-- CURRENCY ORDERS RPC FUNCTIONS
-- Part 2: SELL Order Workflow (Assign, Start, Complete)
-- ===================================
-- Purpose: RPC functions for SELL order multi-step workflow
-- Version: 1.0
-- Date: 2025-01-13

-- ============================================
-- 3. ASSIGN_CURRENCY_ORDER_V1
-- ============================================
-- Purpose: OPS assigns order to a game account
-- Status transition: pending → assigned

CREATE OR REPLACE FUNCTION assign_currency_order_v1(
    p_order_id UUID,
    p_game_account_id UUID,
    p_assignment_notes TEXT DEFAULT NULL
) RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_profile_id uuid;
    v_order RECORD;
    v_account_name text;
BEGIN
    -- Get current profile ID
    v_profile_id := get_current_profile_id();

    IF v_profile_id IS NULL THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'User profile not found'
        );
    END IF;

    -- Check permission (must have ops/trader2/admin role)
    IF NOT EXISTS (
        SELECT 1 FROM user_role_assignments ura
        JOIN attributes ba ON ura.business_area_attribute_id = ba.id
        WHERE ura.user_id = v_profile_id
        AND ba.code IN ('CURRENCY', 'DIABLO_4')
        AND ura.role_name IN ('admin', 'manager', 'trader2', 'ops')
    ) THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'Permission denied: User must have ops/trader2/admin role'
        );
    END IF;

    -- Get order and validate status
    SELECT * INTO v_order
    FROM currency_orders
    WHERE id = p_order_id
    AND order_type = 'SELL'
    AND status = 'pending';

    IF NOT FOUND THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'Order not found, not a SELL order, or not in pending status'
        );
    END IF;

    -- Validate game account exists and is active
    SELECT name INTO v_account_name
    FROM game_accounts
    WHERE id = p_game_account_id
    AND is_active = true;

    IF NOT FOUND THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'Game account not found or inactive'
        );
    END IF;

    -- Update order status to assigned
    UPDATE currency_orders
    SET
        status = 'assigned',
        assigned_account_id = p_game_account_id,
        assigned_at = now(),
        assigned_by = v_profile_id,
        notes = CASE
            WHEN p_assignment_notes IS NOT NULL THEN
                COALESCE(notes || E'\n\n', '') || '[ASSIGNED] ' || p_assignment_notes
            ELSE notes
        END,
        updated_at = now(),
        updated_by = v_profile_id
    WHERE id = p_order_id;

    -- Return success
    RETURN jsonb_build_object(
        'success', true,
        'order_id', p_order_id,
        'new_status', 'assigned',
        'assigned_account', v_account_name,
        'assigned_at', now()
    );

EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', SQLERRM
        );
END;
$$;

-- ============================================
-- 4. START_CURRENCY_ORDER_V1
-- ============================================
-- Purpose: OPS starts processing the order (begins delivery)
-- Status transition: assigned → in_progress

CREATE OR REPLACE FUNCTION start_currency_order_v1(
    p_order_id UUID,
    p_start_notes TEXT DEFAULT NULL
) RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_profile_id uuid;
    v_order RECORD;
BEGIN
    -- Get current profile ID
    v_profile_id := get_current_profile_id();

    IF v_profile_id IS NULL THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'User profile not found'
        );
    END IF;

    -- Check permission (must have ops/trader2/admin role)
    IF NOT EXISTS (
        SELECT 1 FROM user_role_assignments ura
        JOIN attributes ba ON ura.business_area_attribute_id = ba.id
        WHERE ura.user_id = v_profile_id
        AND ba.code IN ('CURRENCY', 'DIABLO_4')
        AND ura.role_name IN ('admin', 'manager', 'trader2', 'ops')
    ) THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'Permission denied: User must have ops/trader2/admin role'
        );
    END IF;

    -- Get order and validate status
    SELECT * INTO v_order
    FROM currency_orders
    WHERE id = p_order_id
    AND order_type = 'SELL'
    AND status = 'assigned';

    IF NOT FOUND THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'Order not found, not a SELL order, or not in assigned status'
        );
    END IF;

    -- Update order status to in_progress
    UPDATE currency_orders
    SET
        status = 'in_progress',
        started_at = now(),
        notes = CASE
            WHEN p_start_notes IS NOT NULL THEN
                COALESCE(notes || E'\n\n', '') || '[STARTED] ' || p_start_notes
            ELSE notes
        END,
        updated_at = now(),
        updated_by = v_profile_id
    WHERE id = p_order_id;

    -- Return success
    RETURN jsonb_build_object(
        'success', true,
        'order_id', p_order_id,
        'new_status', 'in_progress',
        'started_at', now()
    );

EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', SQLERRM
        );
END;
$$;

-- ============================================
-- 5. COMPLETE_CURRENCY_ORDER_V1
-- ============================================
-- Purpose: OPS marks order as completed after successful delivery
-- Status transition: in_progress → completed
-- Updates inventory (deducts quantity)

CREATE OR REPLACE FUNCTION complete_currency_order_v1(
    p_order_id UUID,
    p_completion_notes TEXT DEFAULT NULL,
    p_proof_urls TEXT[] DEFAULT NULL,
    p_actual_quantity NUMERIC DEFAULT NULL,      -- If different from planned
    p_actual_unit_price_vnd NUMERIC DEFAULT NULL -- If price changed
) RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_profile_id uuid;
    v_order RECORD;
    v_transaction_id uuid;
    v_final_quantity numeric;
    v_final_unit_price numeric;
    v_current_inventory_qty numeric;
    v_new_balance numeric;
BEGIN
    -- Get current profile ID
    v_profile_id := get_current_profile_id();

    IF v_profile_id IS NULL THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'User profile not found'
        );
    END IF;

    -- Check permission (must have ops/trader2/admin role)
    IF NOT EXISTS (
        SELECT 1 FROM user_role_assignments ura
        JOIN attributes ba ON ura.business_area_attribute_id = ba.id
        WHERE ura.user_id = v_profile_id
        AND ba.code IN ('CURRENCY', 'DIABLO_4')
        AND ura.role_name IN ('admin', 'manager', 'trader2', 'ops')
    ) THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'Permission denied: User must have ops/trader2/admin role'
        );
    END IF;

    -- Get order and validate status
    SELECT * INTO v_order
    FROM currency_orders
    WHERE id = p_order_id
    AND order_type = 'SELL'
    AND status = 'in_progress';

    IF NOT FOUND THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'Order not found, not a SELL order, or not in in_progress status'
        );
    END IF;

    -- Check that account is assigned
    IF v_order.assigned_account_id IS NULL THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'Order has no assigned game account'
        );
    END IF;

    -- Use actual values if provided, otherwise use original
    v_final_quantity := COALESCE(p_actual_quantity, v_order.quantity);
    v_final_unit_price := COALESCE(p_actual_unit_price_vnd, v_order.unit_price_vnd);

    -- Get current inventory
    SELECT COALESCE(quantity, 0)
    INTO v_current_inventory_qty
    FROM currency_inventory
    WHERE game_account_id = v_order.assigned_account_id
    AND currency_attribute_id = v_order.currency_attribute_id
    AND league_attribute_id = v_order.league_attribute_id
    AND game_code = v_order.game_code;

    -- Check if we have enough inventory (allow negative for pre-sale)
    -- This is a business rule check, but we allow it to go negative
    IF v_current_inventory_qty < v_final_quantity THEN
        -- Log warning but allow (business allows selling with negative inventory)
        RAISE NOTICE 'Warning: Selling with insufficient inventory. Current: %, Required: %',
            v_current_inventory_qty, v_final_quantity;
    END IF;

    -- Create currency transaction (deduct from inventory)
    INSERT INTO currency_transactions (
        transaction_type,
        game_account_id,
        currency_attribute_id,
        quantity,
        unit_price_vnd,
        unit_price_usd,
        game_code,
        league_attribute_id,
        order_id,
        proof_urls,
        notes,
        created_by,
        created_at
    ) VALUES (
        'sale_delivery',
        v_order.assigned_account_id,
        v_order.currency_attribute_id,
        -v_final_quantity,  -- Negative = deduct from inventory
        v_final_unit_price,
        COALESCE(p_actual_unit_price_vnd, v_order.unit_price_usd),
        v_order.game_code,
        v_order.league_attribute_id,
        p_order_id,
        p_proof_urls,
        COALESCE(p_completion_notes, 'Sale delivery to customer: ' || v_order.customer_name),
        v_profile_id,
        now()
    )
    RETURNING id INTO v_transaction_id;

    -- Update inventory (deduct quantity)
    UPDATE currency_inventory
    SET
        quantity = quantity - v_final_quantity,
        last_updated_at = now()
    WHERE game_account_id = v_order.assigned_account_id
    AND currency_attribute_id = v_order.currency_attribute_id
    AND league_attribute_id = v_order.league_attribute_id
    AND game_code = v_order.game_code
    RETURNING quantity INTO v_new_balance;

    -- If inventory doesn't exist, create it with negative balance
    IF NOT FOUND THEN
        INSERT INTO currency_inventory (
            game_account_id,
            currency_attribute_id,
            league_attribute_id,
            game_code,
            quantity,
            avg_buy_price_vnd,
            avg_buy_price_usd,
            last_updated_at
        ) VALUES (
            v_order.assigned_account_id,
            v_order.currency_attribute_id,
            v_order.league_attribute_id,
            v_order.game_code,
            -v_final_quantity,  -- Start with negative
            0,
            0,
            now()
        )
        RETURNING quantity INTO v_new_balance;
    END IF;

    -- Update order status to completed
    UPDATE currency_orders
    SET
        status = 'completed',
        completed_at = now(),
        completed_by = v_profile_id,
        proof_urls = COALESCE(p_proof_urls, proof_urls),
        quantity = v_final_quantity,
        unit_price_vnd = v_final_unit_price,
        notes = CASE
            WHEN p_completion_notes IS NOT NULL THEN
                COALESCE(notes || E'\n\n', '') || '[COMPLETED] ' || p_completion_notes
            ELSE notes
        END,
        updated_at = now(),
        updated_by = v_profile_id
    WHERE id = p_order_id;

    -- Return success
    RETURN jsonb_build_object(
        'success', true,
        'order_id', p_order_id,
        'new_status', 'completed',
        'transaction_id', v_transaction_id,
        'inventory_updated', true,
        'new_balance', v_new_balance
    );

EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', SQLERRM
        );
END;
$$;

-- Grant permissions
GRANT EXECUTE ON FUNCTION assign_currency_order_v1 TO authenticated;
GRANT EXECUTE ON FUNCTION start_currency_order_v1 TO authenticated;
GRANT EXECUTE ON FUNCTION complete_currency_order_v1 TO authenticated;

-- Add comments
COMMENT ON FUNCTION assign_currency_order_v1 IS 'OPS assigns SELL order to a game account. Status: pending → assigned';
COMMENT ON FUNCTION start_currency_order_v1 IS 'OPS starts processing SELL order (begins delivery). Status: assigned → in_progress';
COMMENT ON FUNCTION complete_currency_order_v1 IS 'OPS completes SELL order after delivery. Status: in_progress → completed. Deducts from inventory.';
