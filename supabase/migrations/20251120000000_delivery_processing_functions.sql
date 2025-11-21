-- Migration: Delivery Processing Functions for Currency Orders
-- Created: 2025-11-20
-- Purpose: Implement delivery processing for sell orders with profit calculation

-- Main function to process sell order delivery
CREATE OR REPLACE FUNCTION process_sell_order_delivery(
    p_order_id UUID,
    p_delivery_proof_url TEXT,
    p_user_id UUID
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    updated_order_id UUID,
    profit_amount NUMERIC,
    fees_breakdown JSONB
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
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
    v_existing_proof JSONB;
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

    -- 3. Prepare delivery proof
    v_new_proof := jsonb_build_object(
        'type', 'delivery',
        'url', p_delivery_proof_url,
        'uploaded_at', NOW(),
        'uploaded_by', p_user_id
    );

    -- 4. Get current exchange rates
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

    -- 5. Calculate profit using CASCADE method in cost currency
    DECLARE
        v_sale_amount_cost_currency NUMERIC;
        v_current_amount NUMERIC;
        v_exchange_rate_sale_to_cost NUMERIC;
        v_profit_cost_currency NUMERIC;
    BEGIN
        -- Convert sale amount to cost currency for accurate calculation
        IF v_order.sale_currency_code = v_order.cost_currency_code THEN
            v_sale_amount_cost_currency := v_order.sale_amount;
            v_exchange_rate_sale_to_cost := 1;
        ELSE
            v_exchange_rate_sale_to_cost := get_exchange_rate_for_delivery(v_order.sale_currency_code, v_order.cost_currency_code, CURRENT_DATE);
            v_sale_amount_cost_currency := v_order.sale_amount * v_exchange_rate_sale_to_cost;
        END IF;

        -- Initialize cascade calculation
        v_current_amount := v_sale_amount_cost_currency;
        v_fees_breakdown := '[]'::JSONB;

        -- Find matching business process
        SELECT id INTO v_process_id
        FROM business_processes
        WHERE purchase_channel_id = v_pool.channel_id
          AND sale_channel_id = v_order.channel_id
          AND purchase_currency = v_order.cost_currency_code
          AND sale_currency = v_order.sale_currency_code
          AND is_active = true
        LIMIT 1;

        -- If no exact match, try broader search
        IF v_process_id IS NULL THEN
            SELECT id INTO v_process_id
            FROM business_processes
            WHERE purchase_currency = v_order.cost_currency_code
              AND sale_currency = v_order.sale_currency_code
              AND is_active = true
            LIMIT 1;
        END IF;

        -- Apply CASCADE fees if process found
        IF v_process_id IS NOT NULL THEN
            FOR v_fee_record IN
                SELECT f.*, 'Applied' as status FROM fees f
                JOIN process_fees_map fm ON f.id = fm.fee_id
                WHERE fm.process_id = v_process_id
                  AND f.is_active = true
                ORDER BY
                    CASE f.direction
                        WHEN 'SELL' THEN 1
                        WHEN 'WITHDRAW' THEN 2
                        WHEN 'BUY' THEN 3
                        ELSE 4
                    END
            LOOP
                DECLARE
                    v_fee_amount NUMERIC := 0;
                    v_fee_amount_cost_currency NUMERIC := 0;
                BEGIN
                    IF v_fee_record.fee_type = 'RATE' THEN
                        -- Percentage-based fee applied to current amount
                        IF v_fee_record.currency = v_order.cost_currency_code THEN
                            -- Fee in cost currency: apply directly
                            v_fee_amount_cost_currency := v_current_amount * v_fee_record.amount;
                        ELSIF v_fee_record.currency = v_order.sale_currency_code THEN
                            -- Fee in sale currency: convert to cost currency
                            v_fee_amount_cost_currency := (v_current_amount / v_exchange_rate_sale_to_cost) * v_fee_record.amount * v_exchange_rate_sale_to_cost;
                        ELSE
                            -- Fee in other currency: convert to cost currency
                            v_fee_amount_cost_currency := v_current_amount * v_fee_record.amount *
                                get_exchange_rate_for_delivery(v_fee_record.currency, v_order.cost_currency_code, CURRENT_DATE) /
                                CASE WHEN v_fee_record.currency = v_order.cost_currency_code THEN 1
                                     WHEN v_fee_record.currency = v_order.sale_currency_code THEN v_exchange_rate_sale_to_cost
                                     ELSE get_exchange_rate_for_delivery(v_fee_record.currency, v_order.cost_currency_code, CURRENT_DATE)
                                END;
                        END IF;
                    ELSIF v_fee_record.fee_type = 'FIXED' THEN
                        -- Fixed amount fee
                        IF v_fee_record.currency = v_order.cost_currency_code THEN
                            -- Fixed amount in cost currency
                            v_fee_amount_cost_currency := v_fee_record.amount;
                        ELSE
                            -- Convert fixed amount to cost currency
                            v_fee_amount_cost_currency := v_fee_record.amount *
                                get_exchange_rate_for_delivery(v_fee_record.currency, v_order.cost_currency_code, CURRENT_DATE);
                        END IF;
                    END IF;

                    -- Apply CASCADE: subtract fee from current amount
                    v_current_amount := v_current_amount - v_fee_amount_cost_currency;

                    -- Calculate USD equivalent for reporting
                    IF v_fee_record.currency = 'USD' THEN
                        v_fee_amount := v_fee_amount_cost_currency / v_exchange_rate_cost;
                    ELSIF v_fee_record.currency = v_order.cost_currency_code THEN
                        v_fee_amount := v_fee_amount_cost_currency * v_exchange_rate_cost;
                    ELSE
                        v_fee_amount := v_fee_amount_cost_currency *
                            get_exchange_rate_for_delivery(v_fee_record.currency, 'USD', CURRENT_DATE);
                    END IF;

                    -- Add to breakdown
                    v_fees_breakdown := v_fees_breakdown || jsonb_build_object(
                        'fee_code', v_fee_record.code,
                        'fee_name', v_fee_record.name,
                        'fee_type', v_fee_record.fee_type,
                        'original_amount', CASE
                            WHEN v_fee_record.currency = v_order.cost_currency_code THEN v_fee_amount_cost_currency
                            ELSE v_fee_record.amount
                        END,
                        'original_currency', v_fee_record.currency,
                        'usd_amount', v_fee_amount,
                        'cascade_applied_to', v_current_amount + v_fee_amount_cost_currency,
                        'cascade_remaining', v_current_amount
                    );
                END;
            END LOOP;
        END IF;

        -- Calculate final profit in cost currency
        v_profit_cost_currency := v_current_amount - v_order.cost_amount;

        -- Convert profit to USD for storage
        v_profit_amount := v_profit_cost_currency * v_exchange_rate_cost;

        -- Calculate profit margin percentage
        IF v_order.cost_amount > 0 THEN
            v_profit_margin := (v_profit_cost_currency / v_order.cost_amount) * 100;
        ELSE
            v_profit_margin := 0;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        -- Fallback to simple additive calculation if cascade fails
        v_total_fees_usd := 0;
        v_fees_breakdown := jsonb_build_object('error', 'Cascade calculation failed: ' || SQLERRM);
        v_profit_amount := v_sale_amount_usd - v_cost_amount_usd - v_total_fees_usd;
        v_profit_margin := CASE WHEN v_cost_amount_usd > 0 THEN (v_profit_amount / v_cost_amount_usd) * 100 ELSE 0 END;
    END;

    -- 6. Calculate transaction unit price (per currency unit)
    v_transaction_unit_price := v_cost_amount_usd / v_order.quantity;

    -- 7. Update inventory pool
    UPDATE inventory_pools SET
        quantity = quantity - v_order.quantity,
        reserved_quantity = reserved_quantity - v_order.quantity,
        last_updated_at = NOW(),
        last_updated_by = p_user_id
    WHERE id = v_order.inventory_pool_id;

    -- 8. Create currency transaction record
    INSERT INTO currency_transactions (
        game_account_id,
        game_code,
        transaction_type,
        currency_attribute_id,
        quantity,
        currency_order_id,
        unit_price,
        currency_code,
        exchange_rate_usd,
        channel_id,
        proofs,
        created_by,
        created_at,
        server_attribute_code
    ) VALUES (
        v_pool.game_account_id,
        v_order.game_code,
        'SALE_DELIVERY',
        v_order.currency_attribute_id,
        v_order.quantity,
        p_order_id,
        v_transaction_unit_price,
        'USD',
        v_exchange_rate_cost,
        v_pool.channel_id,
        jsonb_build_array(v_new_proof),
        p_user_id,
        NOW(),
        v_order.server_attribute_code
    );

    -- 9. Update currency order with delivery information
    UPDATE currency_orders SET
        status = 'completed',
        completed_at = NOW(),
        delivery_at = NOW(),
        delivered_by = p_user_id,
        profit_amount = v_profit_amount,
        profit_currency_code = 'USD',
        profit_margin_percentage = v_profit_margin,
        cost_to_sale_exchange_rate = CASE
            WHEN v_order.cost_currency_code = 'USD' THEN 1
            ELSE v_exchange_rate_cost
        END,
        exchange_rate_date = CURRENT_DATE,
        exchange_rate_source = 'system',
        proofs = COALESCE(v_order.proofs, '[]'::JSONB) || v_new_proof
    WHERE id = p_order_id;

    -- 10. Return success result
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

-- Helper function: Update delivery proof only
CREATE OR REPLACE FUNCTION update_delivery_proof(
    p_order_id UUID,
    p_proof_url TEXT,
    p_user_id UUID
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    updated_proofs JSONB
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
DECLARE
    v_order RECORD;
    v_new_proof JSONB;
    v_updated_proofs JSONB;
BEGIN
    -- Validate order
    SELECT * INTO v_order FROM currency_orders
    WHERE id = p_order_id AND order_type = 'SALE';

    IF v_order IS NULL THEN
        RETURN QUERY SELECT false, 'Order not found or not a sale order', NULL::JSONB;
        RETURN;
    END IF;

    -- Create new proof object
    v_new_proof := jsonb_build_object(
        'type', 'delivery_proof',
        'url', p_proof_url,
        'uploaded_at', NOW(),
        'uploaded_by', p_user_id
    );

    -- Update proofs
    v_updated_proofs := COALESCE(v_order.proofs, '[]'::JSONB) || v_new_proof;

    UPDATE currency_orders SET
        proofs = v_updated_proofs,
        updated_at = NOW(),
        updated_by = p_user_id
    WHERE id = p_order_id;

    RETURN QUERY SELECT true, 'Delivery proof updated successfully', v_updated_proofs;
END;
$$;

-- Helper function: Rollback delivery (for admin use)
CREATE OR REPLACE FUNCTION rollback_sell_order_delivery(
    p_order_id UUID,
    p_user_id UUID,
    p_reason TEXT DEFAULT 'Manual rollback'
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    rolled_back_order_id UUID
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
DECLARE
    v_order RECORD;
    v_pool RECORD;
    v_rollback_note JSONB;
BEGIN
    -- Get order information
    SELECT * INTO v_order FROM currency_orders
    WHERE id = p_order_id
      AND order_type = 'SALE'
      AND status = 'completed';

    IF v_order IS NULL THEN
        RETURN QUERY SELECT false, 'Order not found or not a completed sale order', NULL::UUID;
        RETURN;
    END IF;

    -- Get inventory pool
    SELECT * INTO v_pool FROM inventory_pools WHERE id = v_order.inventory_pool_id;

    IF v_pool IS NULL THEN
        RETURN QUERY SELECT false, 'Associated inventory pool not found', NULL::UUID;
        RETURN;
    END IF;

    -- Create rollback note
    v_rollback_note := jsonb_build_object(
        'type', 'delivery_rollback',
        'reason', p_reason,
        'rolled_back_at', NOW(),
        'rolled_back_by', p_user_id,
        'previous_status', 'completed'
    );

    -- Restore inventory quantities
    UPDATE inventory_pools SET
        quantity = quantity + v_order.quantity,
        reserved_quantity = reserved_quantity + v_order.quantity,
        last_updated_at = NOW(),
        last_updated_by = p_user_id
    WHERE id = v_order.inventory_pool_id;

    -- Delete delivery transaction records
    DELETE FROM currency_transactions
    WHERE currency_order_id = p_order_id
      AND transaction_type = 'SALE_DELIVERY';

    -- Reset order status and delivery information
    UPDATE currency_orders SET
        status = 'ready',
        completed_at = NULL,
        delivery_at = NULL,
        delivered_by = NULL,
        profit_amount = NULL,
        profit_currency_code = NULL,
        profit_margin_percentage = NULL,
        proofs = COALESCE(proofs, '[]'::JSONB) || v_rollback_note,
        updated_at = NOW(),
        updated_by = p_user_id
    WHERE id = p_order_id;

    RETURN QUERY SELECT true, 'Delivery rolled back successfully', p_order_id;
END;
$$;

-- Helper function: Get delivery summary for an order
CREATE OR REPLACE FUNCTION get_delivery_summary(
    p_order_id UUID
)
RETURNS TABLE (
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
        co.sale_currency_code,
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

-- Grant necessary permissions
GRANT EXECUTE ON FUNCTION process_sell_order_delivery TO authenticated;
GRANT EXECUTE ON FUNCTION update_delivery_proof TO authenticated;
GRANT EXECUTE ON FUNCTION get_delivery_summary TO authenticated;
-- Note: rollback function restricted to service_role only
GRANT EXECUTE ON FUNCTION rollback_sell_order_delivery TO service_role;