-- Fix duplicate key error in create_exchange_currency_order
-- Migration Date: 2025-12-14
-- Problem: Using hardcoded "Exchange Party" name causes duplicate key violation on parties_type_name_key

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

-- Verification
DO $$
BEGIN
    RAISE NOTICE 'create_exchange_currency_order updated to use unique party names';
END;
$$;