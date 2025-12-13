-- Production Fix for Multiple Proofs and Exchange Order Issues
-- Migration Date: 2025-12-14
-- This migration combines all fixes for production deployment

-- =====================================================
-- 1. Fix process_sell_order_delivery for multiple proofs
-- =====================================================

CREATE OR REPLACE FUNCTION "public"."process_sell_order_delivery"("p_order_id" "uuid", "p_delivery_proof_urls" "jsonb", "p_user_id" "uuid") RETURNS TABLE("success" boolean, "message" "text", "order_id" "uuid", "profit_amount" numeric, "fees_breakdown" "jsonb")
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
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
    v_new_proofs JSONB;
    v_transaction_unit_price NUMERIC;
    v_existing_proofs JSONB;
    v_url TEXT;
    v_new_proof JSONB;
    v_index INTEGER;
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

    -- 3. Validate proofs parameter
    IF p_delivery_proof_urls IS NULL THEN
        RETURN QUERY SELECT false, 'Delivery proofs are required', NULL::UUID, NULL::NUMERIC, NULL::JSONB;
        RETURN;
    END IF;

    -- Convert single URL to array if needed (backward compatibility)
    IF jsonb_typeof(p_delivery_proof_urls) = 'string' THEN
        p_delivery_proof_urls := jsonb_build_array(p_delivery_proof_urls);
    ELSIF jsonb_typeof(p_delivery_proof_urls) != 'array' THEN
        RETURN QUERY SELECT false, 'Delivery proofs must be a string or array', NULL::UUID, NULL::NUMERIC, NULL::JSONB;
        RETURN;
    END IF;

    -- Validate array is not empty
    IF jsonb_array_length(p_delivery_proof_urls) = 0 THEN
        RETURN QUERY SELECT false, 'At least one delivery proof is required', NULL::UUID, NULL::NUMERIC, NULL::JSONB;
        RETURN;
    END IF;

    -- 4. Handle existing proofs - Keep existing logic
    v_existing_proofs := COALESCE(v_order.proofs, '[]'::JSONB);

    -- If proofs is an object, convert to array
    IF jsonb_typeof(v_existing_proofs) = 'object' THEN
        v_existing_proofs := jsonb_build_array(v_existing_proofs);
    ELSIF jsonb_typeof(v_existing_proofs) != 'array' THEN
        v_existing_proofs := '[]'::JSONB;
    END IF;

    -- 5. Build delivery proof objects for each URL
    v_new_proofs := '[]'::JSONB;

    -- Remove existing delivery proofs to avoid duplicates
    v_existing_proofs := (
        SELECT jsonb_agg(proof)
        FROM jsonb_array_elements(v_existing_proofs) AS proof
        WHERE proof->>'type' != 'delivery'
    );

    -- Process each delivery proof URL
    FOR v_index IN 0..jsonb_array_length(p_delivery_proof_urls) - 1 LOOP
        v_url := jsonb_extract_path_text(p_delivery_proof_urls, v_index::TEXT);

        v_new_proof := jsonb_build_object(
            'type', 'delivery',
            'url', v_url,
            'uploaded_at', NOW(),
            'uploaded_by', p_user_id
        );

        v_new_proofs := v_new_proofs || jsonb_build_array(v_new_proof);
    END LOOP;

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

    -- 7. Calculate profit
    v_profit_amount := v_sale_amount_usd - v_cost_amount_usd;
    v_profit_margin := CASE WHEN v_cost_amount_usd > 0 THEN (v_profit_amount / v_cost_amount_usd) * 100 ELSE 0 END;

    -- 8. Calculate transaction unit price
    v_transaction_unit_price := v_cost_amount_usd / v_order.quantity;

    -- 9. Update inventory pool
    UPDATE inventory_pools SET
        quantity = quantity - v_order.quantity,
        reserved_quantity = reserved_quantity - v_order.quantity,
        last_updated_at = NOW(),
        last_updated_by = p_user_id
    WHERE id = v_order.inventory_pool_id;

    -- 10. Create currency transaction record
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
        'sale_delivery',
        v_order.currency_attribute_id,
        v_order.quantity,
        p_order_id,
        v_transaction_unit_price,
        'USD',
        v_exchange_rate_cost,
        v_pool.channel_id,
        v_new_proofs,
        p_user_id,
        NOW(),
        v_order.server_attribute_code
    );

    -- 11. Update currency order
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
        proofs = v_existing_proofs || v_new_proofs
    WHERE id = p_order_id;

    -- 12. Return success result
    RETURN QUERY SELECT
        true,
        format('Delivery processed successfully with %s proof(s)', jsonb_array_length(v_new_proofs)),
        p_order_id,
        v_profit_amount,
        v_fees_breakdown;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT
            false,
            'Delivery processing failed: ' || SQLERRM,
            NULL::UUID,
            NULL::NUMERIC,
            NULL::JSONB;
END;
$$;

-- =====================================================
-- 2. Fix confirm_purchase_order_receiving_v2 for multiple proofs
-- =====================================================

CREATE OR REPLACE FUNCTION "public"."confirm_purchase_order_receiving_v2"("p_order_id" "uuid", "p_completed_by" "uuid", "p_proofs" "jsonb" DEFAULT NULL) RETURNS TABLE("success" boolean, "message" "text", "details" "jsonb")
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
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

    -- Create transaction record
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
        v_final_proofs,
        'Purchase receiving confirmation - Order: ' || COALESCE(v_order.order_number, p_order_id::TEXT),
        v_user_id
    ) RETURNING id INTO v_transaction_id;

    -- Update order status with proofs
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
            'proofs_added', COALESCE(jsonb_array_length(p_proofs), 0)
        );

EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'Error in confirm_purchase_order_receiving_v2: %', SQLERRM;
        RETURN QUERY SELECT FALSE, 'Error confirming purchase order receiving: ' || SQLERRM, NULL::JSONB;
END;
$$;

-- =====================================================
-- 3. Fix update_currency_order_proofs for multiple proofs
-- =====================================================

CREATE OR REPLACE FUNCTION "public"."update_currency_order_proofs"("p_order_id" "uuid", "p_proofs" "jsonb") RETURNS TABLE("success" boolean, "message" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    v_order_exists BOOLEAN;
    v_current_user_id UUID;
    v_bot_profile_id UUID DEFAULT '3c6f63c0-6cc5-4e04-9ccc-c5b92a8868dc';  -- Bot (auto) profile ID
    v_existing_proofs JSONB;
    v_final_proofs JSONB;
    v_new_proof JSONB;
    v_index INTEGER;
BEGIN
    -- Get current user profile ID for updated_by
    BEGIN
        SELECT id INTO v_current_user_id FROM get_current_profile_id();
    EXCEPTION WHEN OTHERS THEN
        -- Fixed: Add public.profiles prefix
        SELECT id INTO v_current_user_id FROM public.profiles ORDER BY created_at ASC LIMIT 1;
    END;

    -- Check if order exists
    SELECT EXISTS(SELECT 1 FROM public.currency_orders WHERE id = p_order_id)
    INTO v_order_exists;

    IF NOT v_order_exists THEN
        RETURN QUERY SELECT FALSE, 'Order not found';
        RETURN;
    END IF;

    -- Handle existing proofs - Append instead of replace
    v_existing_proofs := COALESCE(
        (SELECT proofs FROM public.currency_orders WHERE id = p_order_id),
        '[]'::jsonb
    );

    -- Ensure proofs is an array
    IF jsonb_typeof(v_existing_proofs) != 'array' THEN
        v_existing_proofs := '[]'::jsonb;
    END IF;

    -- Convert p_proofs to array if single object
    IF jsonb_typeof(p_proofs) != 'array' THEN
        p_proofs := jsonb_build_array(p_proofs);
    END IF;

    -- Process new proofs and ensure required fields
    v_final_proofs := '[]'::jsonb;

    FOR v_index IN 0..jsonb_array_length(p_proofs) - 1 LOOP
        v_new_proof := jsonb_extract_path(p_proofs, v_index::TEXT);

        -- Ensure required fields exist
        IF v_new_proof ? 'url' AND v_new_proof ? 'type' THEN
            -- Set uploaded_at and uploaded_by if not present
            IF NOT (v_new_proof ? 'uploaded_at') THEN
                v_new_proof := jsonb_set(v_new_proof, '{uploaded_at}', to_jsonb(NOW()));
            END IF;

            IF NOT (v_new_proof ? 'uploaded_by') THEN
                v_new_proof := jsonb_set(v_new_proof, '{uploaded_by}', to_jsonb(v_bot_profile_id));
            END IF;

            v_final_proofs := v_final_proofs || jsonb_build_array(v_new_proof);
        END IF;
    END LOOP;

    -- Append new proofs to existing proofs
    v_final_proofs := v_existing_proofs || v_final_proofs;

    -- Update order with appended proofs
    UPDATE public.currency_orders
    SET proofs = v_final_proofs,
        status = 'pending',
        submitted_at = NOW(),
        submitted_by = v_bot_profile_id,
        updated_at = NOW(),
        updated_by = v_current_user_id
    WHERE id = p_order_id;

    RETURN QUERY SELECT TRUE,
        format('Successfully added %s proof(s) to order', jsonb_array_length(v_final_proofs) - jsonb_array_length(v_existing_proofs));

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, 'Error updating order proofs: ' || SQLERRM;
END;
$$;

-- =====================================================
-- 4. Fix create_exchange_currency_order duplicate key error
-- =====================================================

CREATE OR REPLACE FUNCTION "public"."create_exchange_currency_order"("p_user_id" "uuid", "p_game_account_id" "uuid", "p_source_currency_id" "uuid", "p_source_quantity" "numeric", "p_target_currency_id" "uuid", "p_target_quantity" "numeric", "p_server_attribute_code" "text" DEFAULT NULL::"text") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    v_order_id UUID;
    v_order_number TEXT;
    v_channel_id UUID;
    v_game_account RECORD;
    v_source_cost_amount NUMERIC;
    v_source_cost_currency_code TEXT;
    v_source_currency_code TEXT;
    v_target_currency_code TEXT;
    v_available_quantity NUMERIC;
    v_current_user_id UUID;
    v_party_exists BOOLEAN;
    v_total_exchange_value NUMERIC;
    v_source_unit_cost NUMERIC;
    v_target_unit_cost NUMERIC;
    v_user_display_name TEXT;
BEGIN
    -- Get current user ID from profiles
    SELECT id, display_name INTO v_current_user_id, v_user_display_name
    FROM profiles
    WHERE id = p_user_id;

    IF v_current_user_id IS NULL THEN
        RAISE EXCEPTION 'Invalid user profile';
    END IF;

    -- Auto-create party record if not exists with UNIQUE name
    -- Use user display name + timestamp to ensure uniqueness
    SELECT EXISTS(SELECT 1 FROM parties WHERE id = p_user_id) INTO v_party_exists;

    IF NOT v_party_exists THEN
        INSERT INTO parties (id, type, name, created_at, updated_at)
        VALUES (
            p_user_id,
            'customer',
            COALESCE(v_user_display_name, 'Exchange User') || ' - ' || TO_CHAR(NOW(), 'YYYY-MM-DD HH24:MI:SS'),
            NOW(),
            NOW()
        );
    END IF;

    -- Get game account details (for game_code only, server can be NULL for global accounts)
    SELECT game_code
    INTO v_game_account
    FROM game_accounts
    WHERE id = p_game_account_id AND is_active = true;

    IF v_game_account IS NULL THEN
        RAISE EXCEPTION 'Game account not found or inactive';
    END IF;

    -- Get source currency cost info from inventory_pools
    -- Logic: use server from GameServerSelector, game from account, specific account_id, currency_id, sufficient_quantity
    SELECT average_cost, cost_currency, quantity, channel_id
    INTO v_source_unit_cost, v_source_cost_currency_code, v_available_quantity, v_channel_id
    FROM inventory_pools
    WHERE game_code = v_game_account.game_code
      AND (
        -- Handle both NULL and specific server codes
        (p_server_attribute_code IS NULL AND server_attribute_code IS NULL)
        OR
        (p_server_attribute_code IS NOT NULL AND server_attribute_code = p_server_attribute_code)
      )
      AND game_account_id = p_game_account_id
      AND currency_attribute_id = p_source_currency_id
      AND quantity >= p_source_quantity
    ORDER BY last_updated_at ASC  -- FIFO: oldest pool first
    LIMIT 1;

    IF v_source_unit_cost IS NULL THEN
        RAISE EXCEPTION 'Không tìm thấy inventory pool phù hợp hoặc không đủ tồn kho. Game: %, Server: %, Account: %, Currency: %, Quantity: %',
            v_game_account.game_code, p_server_attribute_code, p_game_account_id, p_source_currency_id, p_source_quantity;
    END IF;

    -- Calculate total exchange value (both cost and sale should be equal)
    v_total_exchange_value := p_source_quantity * v_source_unit_cost;

    -- Calculate target unit cost (ensuring equal total value)
    v_target_unit_cost := v_total_exchange_value / p_target_quantity;

    -- Get currency codes
    SELECT code INTO v_source_currency_code
    FROM attributes
    WHERE id = p_source_currency_id AND type = 'GAME_CURRENCY';

    SELECT code INTO v_target_currency_code
    FROM attributes
    WHERE id = p_target_currency_id AND type = 'GAME_CURRENCY';

    -- Generate order number - Match purchase/sale timestamp format
    v_order_number := 'EO' || TO_CHAR(NOW(), 'YYYYMMDDHH24MISSMS');

    -- Create the order with CORRECT equal cost/sale values
    INSERT INTO currency_orders (
        order_type,
        status,
        order_number,
        game_code,
        game_account_id,
        server_attribute_code,
        channel_id,
        currency_attribute_id,
        quantity,
        cost_amount,
        cost_currency_code,
        foreign_currency_id,
        foreign_currency_code,
        foreign_amount,
        sale_amount,
        sale_currency_code,
        exchange_type,
        exchange_details,
        party_id,
        created_by
    ) VALUES (
        'EXCHANGE',
        'draft',
        v_order_number,
        v_game_account.game_code,
        p_game_account_id,
        p_server_attribute_code,  -- Use server from GameServerSelector
        v_channel_id,
        p_source_currency_id,
        p_source_quantity,
        v_total_exchange_value,  -- ✅ CORRECT: Total value
        v_source_cost_currency_code,
        p_target_currency_id,
        v_target_currency_code,
        p_target_quantity,
        v_total_exchange_value,  -- ✅ CORRECT: EQUAL TO COST AMOUNT
        v_source_cost_currency_code,
        'currency',
        json_build_object(
            'source_currency', json_build_object(
                'id', p_source_currency_id,
                'code', v_source_currency_code,
                'quantity', p_source_quantity,
                'unit_cost', v_source_unit_cost,
                'total_value', v_total_exchange_value,
                'cost_currency_code', v_source_cost_currency_code
            ),
            'target_currency', json_build_object(
                'id', p_target_currency_id,
                'code', v_target_currency_code,
                'quantity', p_target_quantity,
                'unit_cost', v_target_unit_cost,
                'total_value', v_total_exchange_value,
                'value_currency_code', v_source_cost_currency_code
            ),
            'exchange_rate', json_build_object(
                'source_to_target', (p_target_quantity::NUMERIC / p_source_quantity::NUMERIC),
                'source_unit_cost', v_source_unit_cost,
                'target_unit_cost', v_target_unit_cost,
                'calculated_at', NOW()
            )
        ),
        v_current_user_id,
        v_current_user_id
    ) RETURNING id INTO v_order_id;

    -- Return success result
    RETURN json_build_object(
        'order_id', v_order_id,
        'order_number', v_order_number,
        'status', 'draft',
        'message', 'Exchange order created successfully',
        'party_id', v_current_user_id,
        'exchange_values', json_build_object(
            'total_exchange_value', v_total_exchange_value,
            'source_unit_cost', v_source_unit_cost,
            'target_unit_cost', v_target_unit_cost,
            'cost_currency', v_source_cost_currency_code
        )
    );
END;
$$;

-- =====================================================
-- Verification Section
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Production Migration Applied Successfully';
    RAISE NOTICE '========================================';
    RAISE NOTICE '1. process_sell_order_delivery - Updated to handle multiple proofs (JSONB array)';
    RAISE NOTICE '2. confirm_purchase_order_receiving_v2 - Updated to append proofs instead of replace';
    RAISE NOTICE '3. update_currency_order_proofs - Updated to handle multiple proofs';
    RAISE NOTICE '4. create_exchange_currency_order - Fixed duplicate key error with unique party names';
    RAISE NOTICE '========================================';
END;
$$;