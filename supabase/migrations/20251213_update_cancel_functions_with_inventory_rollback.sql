-- Update Cancel Functions with Proper Inventory Rollback Logic
-- Migration Date: 2025-12-13
-- Purpose: Fix cancel functions to properly handle inventory restoration
-- This ensures when orders are cancelled, inventory is returned correctly

-- First, let's check what cancel functions already exist
-- and update them with proper inventory rollback logic

-- 1. Update cancel_purchase_order function
CREATE OR REPLACE FUNCTION cancel_purchase_order(
    p_order_id UUID,
    p_user_id UUID DEFAULT NULL
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
DECLARE
    v_order RECORD;
    v_current_user_id UUID;
BEGIN
    -- Get current user (from parameter or auth)
    v_current_user_id := COALESCE(p_user_id, get_current_profile_id());

    -- Get order details
    SELECT * INTO v_order
    FROM currency_orders
    WHERE id = p_order_id;

    IF NOT FOUND THEN
        RETURN QUERY
        SELECT false, 'Order not found';
        RETURN;
    END IF;

    -- Only process purchase orders
    IF v_order.order_type != 'PURCHASE' THEN
        RETURN QUERY
        SELECT false, 'This function only handles purchase orders';
        RETURN;
    END IF;

    -- Only allow cancellation for certain statuses
    IF v_order.status IN ('completed', 'cancelled') THEN
        RETURN QUERY
        SELECT false, 'Order cannot be cancelled in current status: ' || v_order.status;
        RETURN;
    END IF;

    -- For purchase orders, we need to handle inventory if it was already processed
    IF v_order.inventory_pool_id IS NOT NULL AND v_order.status = 'delivered' THEN
        -- Rollback inventory pool - remove the quantity that was added
        UPDATE inventory_pools
        SET
            quantity = GREATEST(0, quantity - v_order.quantity),
            last_updated_at = NOW(),
            last_updated_by = v_current_user_id
        WHERE id = v_order.inventory_pool_id;

        RAISE LOG 'Rolled back inventory for cancelled purchase order %: pool_id=%s, quantity=%s',
            p_order_id, v_order.inventory_pool_id, v_order.quantity;
    END IF;

    -- Update order status to cancelled with timestamp
    UPDATE currency_orders
    SET
        status = 'cancelled',
        cancelled_at = NOW(),
        updated_at = NOW(),
        updated_by = v_current_user_id
    WHERE id = p_order_id;

    RETURN QUERY
    SELECT true, 'Purchase order cancelled successfully';
    RETURN;
END;
$$;

-- 2. Update cancel_sell_order_with_inventory_rollback function
CREATE OR REPLACE FUNCTION cancel_sell_order_with_inventory_rollback(
    p_order_id UUID,
    p_user_id UUID DEFAULT NULL
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
DECLARE
    v_order RECORD;
    v_current_user_id UUID;
    v_inventory_pool RECORD;
BEGIN
    -- Get current user (from parameter or auth)
    v_current_user_id := COALESCE(p_user_id, get_current_profile_id());

    -- Get order details
    SELECT * INTO v_order
    FROM currency_orders
    WHERE id = p_order_id;

    IF NOT FOUND THEN
        RETURN QUERY
        SELECT false, 'Order not found';
        RETURN;
    END IF;

    -- Only process sell orders
    IF v_order.order_type != 'SALE' THEN
        RETURN QUERY
        SELECT false, 'This function only handles sell orders';
        RETURN;
    END IF;

    -- Only allow cancellation for certain statuses
    IF v_order.status IN ('completed', 'cancelled') THEN
        RETURN QUERY
        SELECT false, 'Order cannot be cancelled in current status: ' || v_order.status;
        RETURN;
    END IF;

    -- Step 1: Lock and validate inventory pool with FOR UPDATE
    IF v_order.inventory_pool_id IS NOT NULL THEN
        -- Use the exact pool that was assigned
        SELECT * INTO v_inventory_pool
        FROM inventory_pools
        WHERE id = v_order.inventory_pool_id
        FOR UPDATE;
    ELSIF v_order.game_account_id IS NOT NULL THEN
        -- Fallback to old method if inventory_pool_id is not set
        SELECT * INTO v_inventory_pool
        FROM inventory_pools
        WHERE game_account_id = v_order.game_account_id
          AND currency_attribute_id = v_order.currency_attribute_id
          AND COALESCE(channel_id, '00000000-0000-0000-0000-000000000000'::UUID) = COALESCE(v_order.channel_id, '00000000-0000-0000-0000-000000000000'::UUID)
          AND game_code = v_order.game_code
        FOR UPDATE;
    END IF;

    -- Step 2: Validate that we have enough reserved quantity to rollback
    IF v_inventory_pool.id IS NOT NULL THEN
        IF COALESCE(v_inventory_pool.reserved_quantity, 0) < v_order.quantity THEN
            RETURN QUERY
            SELECT false, 'Insufficient reserved quantity to rollback. Reserved: ' ||
                   COALESCE(v_inventory_pool.reserved_quantity, 0) || ', Order: ' || v_order.quantity;
            RETURN;
        END IF;

        -- Step 3: Update inventory with row-level consistency
        -- When cancelling a sell order:
        -- - quantity += order_quantity (return to available stock)
        -- - reserved_quantity -= order_quantity (remove from reserved)
        UPDATE inventory_pools
        SET
            quantity = GREATEST(0, quantity + v_order.quantity),
            reserved_quantity = GREATEST(0, reserved_quantity - v_order.quantity),
            last_updated_at = NOW(),
            last_updated_by = v_current_user_id
        WHERE id = v_inventory_pool.id
        AND COALESCE(reserved_quantity, 0) >= v_order.quantity;

        -- Verify update was successful
        IF NOT FOUND THEN
            RETURN QUERY
            SELECT false, 'Inventory rollback failed - concurrent modification detected';
            RETURN;
        END IF;

        RAISE LOG 'Rolled back inventory for order %: pool_id=%s, quantity=%s',
            p_order_id, v_inventory_pool.id, v_order.quantity;

    ELSE
        RETURN QUERY
        SELECT false, 'No inventory pool found for rollback';
        RETURN;
    END IF;

    -- Step 4: Update order status to cancelled with timestamp
    UPDATE currency_orders
    SET
        status = 'cancelled',
        cancelled_at = NOW(),
        updated_at = NOW(),
        updated_by = v_current_user_id
    WHERE id = p_order_id;

    RETURN QUERY
    SELECT true, 'Sell order cancelled and inventory rolled back successfully using pool ID: ' || v_inventory_pool.id::TEXT;
    RETURN;
END;
$$;

-- 3. Update generic cancel_currency_order function
CREATE OR REPLACE FUNCTION cancel_currency_order(
    p_order_id UUID,
    p_user_id UUID DEFAULT NULL,
    p_reason TEXT DEFAULT NULL
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
DECLARE
    v_order_type TEXT;
BEGIN
    -- Get order type
    SELECT order_type INTO v_order_type
    FROM currency_orders
    WHERE id = p_order_id;

    IF v_order_type IS NULL THEN
        RETURN QUERY SELECT false, 'Order not found';
        RETURN;
    END IF;

    -- Route to appropriate cancel function
    IF v_order_type = 'SALE' THEN
        RETURN QUERY
        SELECT success, message
        FROM cancel_sell_order_with_inventory_rollback(p_order_id, p_user_id);
    ELSIF v_order_type = 'PURCHASE' THEN
        RETURN QUERY
        SELECT success, message
        FROM cancel_purchase_order(p_order_id, p_user_id);
    ELSE
        RETURN QUERY SELECT false, 'Unknown order type: ' || v_order_type;
    END IF;
END;
$$;

-- Grant permissions
GRANT EXECUTE ON FUNCTION cancel_purchase_order TO authenticated;
GRANT EXECUTE ON FUNCTION cancel_purchase_order TO service_role;

GRANT EXECUTE ON FUNCTION cancel_sell_order_with_inventory_rollback TO authenticated;
GRANT EXECUTE ON FUNCTION cancel_sell_order_with_inventory_rollback TO service_role;

GRANT EXECUTE ON FUNCTION cancel_currency_order TO authenticated;
GRANT EXECUTE ON FUNCTION cancel_currency_order TO service_role;

-- Verification
DO $$
BEGIN
    RAISE NOTICE '==========================================';
    RAISE NOTICE 'CANCEL ORDER FUNCTIONS UPDATED';
    RAISE NOTICE '==========================================';
    RAISE NOTICE 'Functions updated:';
    RAISE NOTICE '- cancel_purchase_order: Handles purchase order cancellation';
    RAISE NOTICE '- cancel_sell_order_with_inventory_rollback: Handles sell order cancellation with inventory restoration';
    RAISE NOTICE '- cancel_currency_order: Generic router function';
    RAISE NOTICE '';
    RAISE NOTICE 'Inventory restoration logic for sell orders:';
    RAISE NOTICE '- quantity += order_quantity (return to available stock)';
    RAISE NOTICE '- reserved_quantity -= order_quantity (remove from reserved)';
    RAISE NOTICE '==========================================';
END $$;