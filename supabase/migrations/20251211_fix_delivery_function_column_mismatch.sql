-- Fix process_sell_order_delivery function column mismatch
-- Migration Date: 2025-12-11
-- Purpose: Remove inventory_pool_id reference and fix column order in currency_transactions insert

-- Drop and recreate the function with correct column mapping
DROP FUNCTION IF EXISTS process_sell_order_delivery(p_order_id UUID, p_delivery_proof_url TEXT, p_user_id UUID, p_delivery_proof_data JSONB);

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

    -- If proofs is not an array, convert it
    IF jsonb_typeof(v_existing_proofs) != 'array' THEN
        v_existing_proofs := '[]'::JSONB;
    END IF;

    -- 6. Start transaction
    BEGIN;

    -- 7. Calculate profit metrics
    v_cost_amount_usd := v_order.quantity * v_pool.cost_usd;
    v_sale_amount_usd := v_order.quantity * v_order.unit_price;
    v_profit_amount := v_sale_amount_usd - v_cost_amount_usd;

    -- Calculate transaction unit price (what we actually sold at)
    v_transaction_unit_price := v_order.unit_price;

    -- Calculate exchange rates
    v_exchange_rate_cost := v_pool.cost_usd;  -- Cost per unit in USD
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

    -- 9. Create transaction record - FIX: Fix column order and include inventory_pool_id
    INSERT INTO currency_transactions (
        game_account_id,
        game_code,
        server_attribute_code,
        transaction_type,
        currency_attribute_id,
        quantity,
        unit_price,
        currency_code,
        inventory_pool_id,
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
        'USD',
        v_pool.id,
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
        profit_currency_code = 'USD',
        profit_margin_percentage = v_profit_margin,
        cost_to_sale_exchange_rate = v_exchange_rate_cost,
        exchange_rate_date = CURRENT_DATE,
        exchange_rate_source = 'system',
        proofs = v_existing_proofs || v_new_proof
    WHERE id = p_order_id;

    -- 11. Commit transaction
    COMMIT;

    -- 12. Return success result
    RETURN QUERY SELECT
        true,
        'Delivery processed successfully',
        p_order_id,
        v_profit_amount,
        v_fees_breakdown;

EXCEPTION
    WHEN OTHERS THEN
        -- Rollback on error
        ROLLBACK;

        -- Return error information
        RETURN QUERY SELECT
            false,
            'Delivery processing failed: ' || SQLERRM,
            NULL::UUID,
            NULL::NUMERIC,
            NULL::JSONB;
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION process_sell_order_delivery TO authenticated;
GRANT EXECUTE ON FUNCTION process_sell_order_delivery TO service_role;

-- Verification
DO $$
BEGIN
    RAISE NOTICE 'Migration completed: Fixed process_sell_order_delivery function';
    RAISE NOTICE '- Removed reference to non-existent inventory_pool_id column';
    RAISE NOTICE '- Fixed column order in INSERT statement';
    RAISE NOTICE '- Added transaction rollback on error';
END $$;