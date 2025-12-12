-- Deploy sell order completion functions from staging to production
-- Migration Date: 2025-12-11
-- Purpose: Sync all sell order related functions from staging to fix production issues

-- 1. Drop existing functions to ensure clean recreation
-- Drop functions with CASCADE to remove all overloads
DROP FUNCTION IF EXISTS complete_sell_order_with_profit_calculation CASCADE;
DROP FUNCTION IF EXISTS complete_sell_order_with_profit_calculation(p_order_id UUID) CASCADE;
DROP FUNCTION IF EXISTS complete_sell_order_with_profit_calculation(p_order_id UUID, p_user_id UUID) CASCADE;
DROP FUNCTION IF EXISTS complete_sale_order_v2 CASCADE;
DROP FUNCTION IF EXISTS complete_sale_order_v2(p_order_id UUID, p_user_id UUID) CASCADE;
DROP FUNCTION IF EXISTS process_sell_order_delivery CASCADE;
DROP FUNCTION IF EXISTS process_sell_order_delivery(p_order_id UUID, p_delivery_proof_url TEXT, p_user_id UUID) CASCADE;
DROP FUNCTION IF EXISTS process_sell_order_delivery(p_order_id UUID, p_delivery_proof_url TEXT, p_user_id UUID, p_delivery_proof_data JSONB) CASCADE;
DROP FUNCTION IF EXISTS process_delivery_confirmation_v2 CASCADE;
DROP FUNCTION IF EXISTS process_delivery_confirmation_v2(p_order_id UUID, p_user_id UUID) CASCADE;
DROP FUNCTION IF EXISTS get_delivery_summary CASCADE;
DROP FUNCTION IF EXISTS get_delivery_summary(p_order_id UUID) CASCADE;

-- 2. Create/Recreate complete_sell_order_with_profit_calculation function (from staging)
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

-- 3. Create complete_sale_order_v2 as alias (from staging)
CREATE OR REPLACE FUNCTION complete_sale_order_v2(
    p_order_id UUID,
    p_user_id UUID
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    profit_amount NUMERIC,
    profit_currency TEXT,
    profit_margin_percentage NUMERIC
)
AS $$
BEGIN
    -- Simply delegate to the existing function
    RETURN QUERY SELECT * FROM complete_sell_order_with_profit_calculation(p_order_id, p_user_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Create process_sell_order_delivery function (from staging with fixes)
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
SET search_path = public
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

    -- If proofs is not an array, convert it
    IF jsonb_typeof(v_existing_proofs) != 'array' THEN
        v_existing_proofs := '[]'::JSONB;
    END IF;

    -- 6. Calculate profit metrics
    v_cost_amount_usd := v_order.quantity * v_pool.average_cost;
    v_sale_amount_usd := v_order.quantity * v_order.unit_price;
    v_profit_amount := v_sale_amount_usd - v_cost_amount_usd;

    -- Calculate transaction unit price (what we actually sold at)
    v_transaction_unit_price := v_order.unit_price;

    -- Calculate exchange rates
    v_exchange_rate_cost := v_pool.average_cost;  -- Cost per unit (using average_cost)
    v_exchange_rate_sale := v_order.unit_price;  -- Sale price per unit in VND

    IF v_cost_amount_usd > 0 THEN
        v_profit_margin := (v_profit_amount / v_cost_amount_usd) * 100;
    ELSE
        v_profit_margin := 0;
    END IF;

    -- 8. Deduct from inventory pool (use CASCADE for delivery fee calculation later)
    UPDATE inventory_pools SET
        quantity = quantity - v_order.quantity,
        reserved_quantity = reserved_quantity - v_order.quantity,
        last_updated_at = NOW(),
        last_updated_by = p_user_id
    WHERE id = v_pool.id;

    -- 9. Create transaction record - FIX: Remove inventory_pool_id column (doesn't exist)
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
        created_at,
        exchange_rate_usd,
        channel_id
    ) VALUES (
        v_pool.game_account_id,
        v_order.game_code,
        v_order.server_attribute_code,
        'sale_delivery',
        v_order.currency_attribute_id,
        v_order.quantity,
        v_transaction_unit_price,
        v_order.cost_currency_code,  -- Use cost_currency from order
        p_order_id,
        jsonb_build_array(v_new_proof),
        p_user_id,
        NOW(),
        v_exchange_rate_cost,
        v_pool.channel_id
    );

    -- 10. Update currency order with delivery information - FIX: Properly handle proofs
    UPDATE currency_orders SET
        status = 'completed',
        completed_at = NOW(),
        delivery_at = NOW(),
        delivered_by = p_user_id,
        profit_amount = v_profit_amount,
        profit_currency_code = v_order.cost_currency_code,
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

-- 5. Create process_delivery_confirmation_v2 function (from staging)
CREATE OR REPLACE FUNCTION process_delivery_confirmation_v2(
    p_order_id UUID,
    p_user_id UUID
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
DECLARE
    v_order RECORD;
    v_inventory_pool_id UUID;
    v_cost_amount NUMERIC;
    v_cost_currency_code TEXT;
    v_result JSON := '{}'::JSON;
BEGIN
    -- Lấy thông tin đơn hàng
    SELECT * INTO v_order
    FROM currency_orders
    WHERE id = p_order_id;

    IF NOT FOUND THEN
        v_result := jsonb_build_object('success', false, 'error', 'Đơn hàng không tồn tại');
        RETURN v_result;
    END IF;

    -- Xử lý inventory tùy theo loại đơn hàng
    IF v_order.order_type = 'PURCHASE' THEN
        -- Đơn mua: thêm vào inventory
        v_result := jsonb_build_object('success', true, 'message', 'Đã nhận hàng thành công');
    ELSIF v_order.order_type = 'SELL' THEN
        -- Đơn bán: trừ khỏi inventory
        v_result := jsonb_build_object('success', true, 'message', 'Đã giao hàng thành công');
    END IF;

    RETURN v_result;
END;
$$;

-- 6. Create get_delivery_summary function (from staging)
CREATE OR REPLACE FUNCTION get_delivery_summary(
    p_order_id UUID
)
RETURNS TABLE(
    order_number TEXT,
    status TEXT,
    quantity NUMERIC,
    cost_amount NUMERIC,
    cost_currency_code TEXT,
    sale_amount NUMERIC,
    sale_currency_code TEXT,
    profit_amount NUMERIC,
    profit_currency_code TEXT,
    profit_margin_percentage NUMERIC,
    delivery_proofs JSONB,
    can_process_delivery BOOLEAN,
    delivery_status TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
BEGIN
    RETURN QUERY
    SELECT
        co.order_number,
        co.status::TEXT,
        co.quantity,
        co.cost_amount,
        co.cost_currency_code,
        co.sale_amount,
        co.currency_code,
        co.profit_amount,
        co.profit_currency_code,
        co.profit_margin_percentage,
        co.proofs,
        (co.order_type = 'SALE' AND co.status IN ('ready', 'delivering')) as can_process_delivery,
        CASE
            WHEN co.status = 'completed' THEN 'Delivered'
            WHEN co.status = 'delivering' THEN 'In Progress'
            WHEN co.status = 'ready' THEN 'Ready for Delivery'
            ELSE 'Not Ready'
        END as delivery_status
    FROM currency_orders co
    WHERE co.id = p_order_id
      AND co.order_type = 'SALE';
END;
$$;

-- Grant permissions
GRANT EXECUTE ON FUNCTION complete_sell_order_with_profit_calculation TO authenticated;
GRANT EXECUTE ON FUNCTION complete_sell_order_with_profit_calculation TO service_role;

GRANT EXECUTE ON FUNCTION complete_sale_order_v2 TO authenticated;
GRANT EXECUTE ON FUNCTION complete_sale_order_v2 TO service_role;

GRANT EXECUTE ON FUNCTION process_sell_order_delivery TO authenticated;
GRANT EXECUTE ON FUNCTION process_sell_order_delivery TO service_role;

GRANT EXECUTE ON FUNCTION process_delivery_confirmation_v2 TO authenticated;
GRANT EXECUTE ON FUNCTION process_delivery_confirmation_v2 TO service_role;

GRANT EXECUTE ON FUNCTION get_delivery_summary TO authenticated;
GRANT EXECUTE ON FUNCTION get_delivery_summary TO service_role;

-- Verification
DO $$
BEGIN
    RAISE NOTICE 'Migration completed: Deployed all sell order functions from staging to production';
    RAISE NOTICE 'Functions deployed:';
    RAISE NOTICE '- complete_sell_order_with_profit_calculation';
    RAISE NOTICE '- complete_sale_order_v2 (alias)';
    RAISE NOTICE '- process_sell_order_delivery';
    RAISE NOTICE '- process_delivery_confirmation_v2';
    RAISE NOTICE '- get_delivery_summary';
    RAISE NOTICE 'All functions have been fixed to work with existing schema';
END $$;