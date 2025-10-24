-- ===================================
-- CURRENCY ORDERS RPC FUNCTIONS
-- Part 3: Cancel & Query Functions
-- ===================================
-- Purpose: RPC functions for cancelling orders and querying orders
-- Version: 1.0
-- Date: 2025-01-13

-- ============================================
-- 6. CANCEL_CURRENCY_ORDER_V1
-- ============================================
-- Purpose: Cancel order at any stage (before completion)
-- Applicable to: Both SELL and PURCHASE orders
-- Note: For PURCHASE orders, cancellation requires inventory rollback

CREATE OR REPLACE FUNCTION cancel_currency_order_v1(
    p_order_id UUID,
    p_cancel_reason TEXT
) RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_profile_id uuid;
    v_order RECORD;
    v_can_cancel boolean := false;
    v_transaction_id uuid;
BEGIN
    -- Get current profile ID
    v_profile_id := get_current_profile_id();

    IF v_profile_id IS NULL THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'User profile not found'
        );
    END IF;

    -- Get order and validate
    SELECT * INTO v_order
    FROM currency_orders
    WHERE id = p_order_id;

    IF NOT FOUND THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'Order not found'
        );
    END IF;

    -- Cannot cancel if already completed or cancelled
    IF v_order.status IN ('completed', 'cancelled') THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'Cannot cancel order that is already ' || v_order.status
        );
    END IF;

    -- Check permission:
    -- - Owner can cancel their own orders
    -- - Admin/Manager can cancel any order
    IF v_order.created_by = v_profile_id THEN
        v_can_cancel := true;
    ELSIF EXISTS (
        SELECT 1 FROM user_role_assignments ura
        JOIN attributes ba ON ura.business_area_attribute_id = ba.id
        WHERE ura.user_id = v_profile_id
        AND ba.code IN ('CURRENCY', 'DIABLO_4')
        AND ura.role_name IN ('admin', 'manager')
    ) THEN
        v_can_cancel := true;
    END IF;

    IF NOT v_can_cancel THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'Permission denied: You can only cancel your own orders, or must have admin/manager role'
        );
    END IF;

    -- Validate cancel reason is provided
    IF p_cancel_reason IS NULL OR p_cancel_reason = '' THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'Cancel reason is required'
        );
    END IF;

    -- Special handling for PURCHASE orders that are already completed
    -- (Rare case: user wants to rollback a purchase)
    IF v_order.order_type = 'PURCHASE' AND v_order.status = 'completed' AND v_order.assigned_account_id IS NOT NULL THEN
        -- Create reversal transaction
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
            notes,
            created_by,
            created_at
        ) VALUES (
            'manual_adjustment',  -- Use manual adjustment for reversal
            v_order.assigned_account_id,
            v_order.currency_attribute_id,
            -v_order.quantity,  -- Negative to reverse
            v_order.unit_price_vnd,
            v_order.unit_price_usd,
            v_order.game_code,
            v_order.league_attribute_id,
            p_order_id,
            'REVERSAL: ' || p_cancel_reason,
            v_profile_id,
            now()
        )
        RETURNING id INTO v_transaction_id;

        -- Update inventory (rollback)
        UPDATE currency_inventory
        SET
            quantity = quantity - v_order.quantity,
            last_updated_at = now()
        WHERE game_account_id = v_order.assigned_account_id
        AND currency_attribute_id = v_order.currency_attribute_id
        AND league_attribute_id = v_order.league_attribute_id
        AND game_code = v_order.game_code;
    END IF;

    -- Update order status to cancelled
    UPDATE currency_orders
    SET
        status = 'cancelled',
        cancelled_at = now(),
        cancelled_by = v_profile_id,
        cancel_reason = p_cancel_reason,
        notes = COALESCE(notes || E'\n\n', '') || '[CANCELLED] ' || p_cancel_reason,
        updated_at = now(),
        updated_by = v_profile_id
    WHERE id = p_order_id;

    -- Return success
    RETURN jsonb_build_object(
        'success', true,
        'order_id', p_order_id,
        'new_status', 'cancelled',
        'previous_status', v_order.status,
        'reversal_transaction_id', v_transaction_id
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
-- 7. GET_CURRENCY_SELL_ORDERS_V1
-- ============================================
-- Purpose: Query SELL orders with filters

CREATE OR REPLACE FUNCTION get_currency_sell_orders_v1(
    p_status TEXT DEFAULT NULL,
    p_game_code TEXT DEFAULT NULL,
    p_customer_name TEXT DEFAULT NULL,
    p_date_from TIMESTAMPTZ DEFAULT NULL,
    p_date_to TIMESTAMPTZ DEFAULT NULL,
    p_limit INT DEFAULT 50,
    p_offset INT DEFAULT 0
) RETURNS TABLE(
    order_id uuid,
    order_number text,
    order_type text,
    status text,
    currency_name text,
    currency_code text,
    quantity numeric,
    unit_price_vnd numeric,
    unit_price_usd numeric,
    total_price_vnd numeric,
    customer_name text,
    customer_game_tag text,
    delivery_info text,
    channel_name text,
    exchange_type text,
    assigned_account_name text,
    created_at timestamptz,
    created_by_name text,
    assigned_at timestamptz,
    started_at timestamptz,
    completed_at timestamptz,
    proof_urls text[],
    notes text
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_profile_id uuid;
BEGIN
    -- Get current profile ID
    v_profile_id := get_current_profile_id();

    -- Check permission
    IF NOT EXISTS (
        SELECT 1 FROM user_role_assignments ura
        JOIN attributes ba ON ura.business_area_attribute_id = ba.id
        WHERE ura.user_id = v_profile_id
        AND ba.code IN ('CURRENCY', 'DIABLO_4')
    ) THEN
        RAISE EXCEPTION 'Permission denied: User does not have currency role';
    END IF;

    -- Return filtered results
    RETURN QUERY
    SELECT
        co.id,
        co.order_number,
        co.order_type::text,
        co.status::text,
        curr_attr.name as currency_name,
        curr_attr.code as currency_code,
        co.quantity,
        co.unit_price_vnd,
        co.unit_price_usd,
        co.total_price_vnd,
        co.customer_name,
        co.customer_game_tag,
        co.delivery_info,
        ch.name as channel_name,
        co.exchange_type::text,
        ga.name as assigned_account_name,
        co.created_at,
        p.display_name as created_by_name,
        co.assigned_at,
        co.started_at,
        co.completed_at,
        co.proof_urls,
        co.notes
    FROM currency_orders co
    LEFT JOIN attributes curr_attr ON co.currency_attribute_id = curr_attr.id
    LEFT JOIN channels ch ON co.channel_id = ch.id
    LEFT JOIN game_accounts ga ON co.assigned_account_id = ga.id
    LEFT JOIN profiles p ON co.created_by = p.id
    WHERE co.order_type = 'SELL'
    AND (p_status IS NULL OR co.status::text = p_status)
    AND (p_game_code IS NULL OR co.game_code = p_game_code)
    AND (p_customer_name IS NULL OR co.customer_name ILIKE '%' || p_customer_name || '%')
    AND (p_date_from IS NULL OR co.created_at >= p_date_from)
    AND (p_date_to IS NULL OR co.created_at <= p_date_to)
    ORDER BY
        CASE co.status
            WHEN 'pending' THEN 1
            WHEN 'assigned' THEN 2
            WHEN 'in_progress' THEN 3
            WHEN 'completed' THEN 4
            WHEN 'cancelled' THEN 5
        END,
        co.created_at DESC
    LIMIT p_limit
    OFFSET p_offset;
END;
$$;

-- ============================================
-- 8. GET_CURRENCY_PURCHASE_ORDERS_V1
-- ============================================
-- Purpose: Query PURCHASE orders with filters

CREATE OR REPLACE FUNCTION get_currency_purchase_orders_v1(
    p_status TEXT DEFAULT NULL,
    p_game_code TEXT DEFAULT NULL,
    p_supplier_name TEXT DEFAULT NULL,
    p_date_from TIMESTAMPTZ DEFAULT NULL,
    p_date_to TIMESTAMPTZ DEFAULT NULL,
    p_limit INT DEFAULT 50,
    p_offset INT DEFAULT 0
) RETURNS TABLE(
    order_id uuid,
    order_number text,
    order_type text,
    status text,
    currency_name text,
    currency_code text,
    quantity numeric,
    unit_price_vnd numeric,
    unit_price_usd numeric,
    total_price_vnd numeric,
    supplier_name text,
    supplier_contact text,
    assigned_account_name text,
    created_at timestamptz,
    created_by_name text,
    completed_at timestamptz,
    proof_urls text[],
    notes text
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_profile_id uuid;
BEGIN
    -- Get current profile ID
    v_profile_id := get_current_profile_id();

    -- Check permission
    IF NOT EXISTS (
        SELECT 1 FROM user_role_assignments ura
        JOIN attributes ba ON ura.business_area_attribute_id = ba.id
        WHERE ura.user_id = v_profile_id
        AND ba.code IN ('CURRENCY', 'DIABLO_4')
    ) THEN
        RAISE EXCEPTION 'Permission denied: User does not have currency role';
    END IF;

    -- Return filtered results
    RETURN QUERY
    SELECT
        co.id,
        co.order_number,
        co.order_type::text,
        co.status::text,
        curr_attr.name as currency_name,
        curr_attr.code as currency_code,
        co.quantity,
        co.unit_price_vnd,
        co.unit_price_usd,
        co.total_price_vnd,
        co.customer_name as supplier_name,  -- Stored in customer_name field
        co.delivery_info as supplier_contact,  -- Stored in delivery_info field
        ga.name as assigned_account_name,
        co.created_at,
        p.display_name as created_by_name,
        co.completed_at,
        co.proof_urls,
        co.notes
    FROM currency_orders co
    LEFT JOIN attributes curr_attr ON co.currency_attribute_id = curr_attr.id
    LEFT JOIN game_accounts ga ON co.assigned_account_id = ga.id
    LEFT JOIN profiles p ON co.created_by = p.id
    WHERE co.order_type = 'PURCHASE'
    AND (p_status IS NULL OR co.status::text = p_status)
    AND (p_game_code IS NULL OR co.game_code = p_game_code)
    AND (p_supplier_name IS NULL OR co.customer_name ILIKE '%' || p_supplier_name || '%')
    AND (p_date_from IS NULL OR co.created_at >= p_date_from)
    AND (p_date_to IS NULL OR co.created_at <= p_date_to)
    ORDER BY co.created_at DESC
    LIMIT p_limit
    OFFSET p_offset;
END;
$$;

-- Grant permissions
GRANT EXECUTE ON FUNCTION cancel_currency_order_v1 TO authenticated;
GRANT EXECUTE ON FUNCTION get_currency_sell_orders_v1 TO authenticated;
GRANT EXECUTE ON FUNCTION get_currency_purchase_orders_v1 TO authenticated;

-- Add comments
COMMENT ON FUNCTION cancel_currency_order_v1 IS 'Cancel order at any stage (before completion). For PURCHASE orders, automatically rollbacks inventory. Requires cancel reason.';
COMMENT ON FUNCTION get_currency_sell_orders_v1 IS 'Query SELL orders with filters. Returns orders sorted by status priority and creation date.';
COMMENT ON FUNCTION get_currency_purchase_orders_v1 IS 'Query PURCHASE orders with filters. Note: supplier info is stored in customer_name and delivery_info fields.';
