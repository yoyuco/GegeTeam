-- Currency System RPC Functions
-- Multi-game Universal Currency Management

-- 1. Get Currency Inventory Summary (Dashboard)
CREATE OR REPLACE FUNCTION public.get_currency_inventory_summary_v1(
    p_game_code TEXT DEFAULT NULL,
    p_league_attribute_id UUID DEFAULT NULL
)
RETURNS TABLE(
    game_code TEXT,
    league_name TEXT,
    currency_id UUID,
    currency_name TEXT,
    currency_code TEXT,
    total_quantity NUMERIC,
    available_quantity NUMERIC,
    reserved_quantity NUMERIC,
    avg_buy_price_vnd NUMERIC,
    avg_buy_price_usd NUMERIC,
    total_value_vnd NUMERIC,
    total_value_usd NUMERIC,
    account_count BIGINT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_can_manage BOOLEAN := FALSE;
BEGIN
    -- Check if user can access currency system
    SELECT EXISTS(
        SELECT 1 FROM user_role_assignments ura
        JOIN attributes ba ON ura.business_area_attribute_id = ba.id
        WHERE ura.user_id = v_user_id
        AND ba.code = 'CURRENCY'
        AND (
            ura.game_attribute_id IS NULL
            OR EXISTS (
                SELECT 1 FROM attributes ga
                WHERE ga.id = ura.game_attribute_id
                AND ga.code = p_game_code
            )
        )
    ) INTO v_can_manage;

    IF NOT v_can_manage THEN
        RAISE EXCEPTION 'Permission denied: Cannot access currency inventory';
    END IF;

    RETURN QUERY
    SELECT
        ga.game_code,
        l.name as league_name,
        curr.id as currency_id,
        curr.name as currency_name,
        curr.code as currency_code,
        SUM(inv.quantity) as total_quantity,
        SUM(inv.quantity - inv.reserved_quantity) as available_quantity,
        SUM(inv.reserved_quantity) as reserved_quantity,
        AVG(inv.avg_buy_price_vnd) as avg_buy_price_vnd,
        AVG(inv.avg_buy_price_usd) as avg_buy_price_usd,
        SUM(inv.quantity * inv.avg_buy_price_vnd) as total_value_vnd,
        SUM(inv.quantity * inv.avg_buy_price_usd) as total_value_usd,
        COUNT(DISTINCT inv.game_account_id) as account_count
    FROM currency_inventory inv
    JOIN game_accounts ga ON inv.game_account_id = ga.id
    JOIN attributes curr ON inv.currency_attribute_id = curr.id
    JOIN attributes l ON ga.league_attribute_id = l.id
    WHERE ga.is_active = true
        AND curr.is_active = true
        AND (p_game_code IS NULL OR ga.game_code = p_game_code)
        AND (p_league_attribute_id IS NULL OR ga.league_attribute_id = p_league_attribute_id)
        -- Permission filter
        AND (
            EXISTS (
                SELECT 1 FROM user_role_assignments ura
                WHERE ura.user_id = v_user_id
                AND ura.business_area_attribute_id = (SELECT id FROM attributes WHERE code = 'CURRENCY')
                AND (
                    ura.game_attribute_id IS NULL
                    OR ura.game_attribute_id = (SELECT id FROM attributes WHERE code = ga.game_code AND type = 'GAME')
                )
            )
        )
    GROUP BY ga.game_code, l.name, curr.id, curr.name, curr.code
    ORDER BY ga.game_code, total_value_vnd DESC;
END;
$$;

-- 2. Record Currency Purchase
CREATE OR REPLACE FUNCTION public.record_currency_purchase_v1(
    p_game_account_id UUID,
    p_currency_attribute_id UUID,
    p_quantity NUMERIC,
    p_unit_price_vnd NUMERIC,
    p_unit_price_usd NUMERIC DEFAULT 0,
    p_exchange_rate_vnd_per_usd NUMERIC DEFAULT 25700,
    p_partner_id UUID DEFAULT NULL,
    p_proof_urls TEXT[] DEFAULT NULL,
    p_notes TEXT DEFAULT NULL
)
RETURNS TABLE(
    success BOOLEAN,
    transaction_id UUID,
    message TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_game_code TEXT;
    v_league_id UUID;
    v_transaction_id UUID;
    v_can_create BOOLEAN := FALSE;
BEGIN
    -- Check permissions
    SELECT EXISTS(
        SELECT 1 FROM user_role_assignments ura
        JOIN attributes ba ON ura.business_area_attribute_id = ba.id
        JOIN game_accounts ga ON ura.game_attribute_id = ga.id
        WHERE ura.user_id = v_user_id
        AND ba.code = 'CURRENCY'
        AND ga.id = p_game_account_id
    ) INTO v_can_create;

    IF NOT v_can_create THEN
        RETURN QUERY SELECT FALSE, NULL::UUID, 'Permission denied: Cannot create currency purchase';
        RETURN;
    END IF;

    -- Get game and league info
    SELECT game_code, league_attribute_id
    INTO v_game_code, v_league_id
    FROM game_accounts
    WHERE id = p_game_account_id;

    IF v_game_code IS NULL THEN
        RETURN QUERY SELECT FALSE, NULL::UUID, 'Invalid game account';
        RETURN;
    END IF;

    -- Create transaction
    INSERT INTO currency_transactions (
        game_account_id,
        game_code,
        league_attribute_id,
        transaction_type,
        currency_attribute_id,
        quantity,
        unit_price_vnd,
        unit_price_usd,
        exchange_rate_vnd_per_usd,
        partner_id,
        proof_urls,
        notes,
        created_by
    ) VALUES (
        p_game_account_id,
        v_game_code,
        v_league_id,
        'purchase',
        p_currency_attribute_id,
        p_quantity,
        p_unit_price_vnd,
        p_unit_price_usd,
        p_exchange_rate_vnd_per_usd,
        p_partner_id,
        p_proof_urls,
        p_notes,
        v_user_id
    ) RETURNING id INTO v_transaction_id;

    -- Update inventory (this should be handled by trigger)
    -- For now, manually update
    INSERT INTO currency_inventory (
        game_account_id,
        currency_attribute_id,
        quantity,
        avg_buy_price_vnd,
        avg_buy_price_usd
    ) VALUES (
        p_game_account_id,
        p_currency_attribute_id,
        p_quantity,
        p_unit_price_vnd,
        p_unit_price_usd
    )
    ON CONFLICT (game_account_id, currency_attribute_id)
    DO UPDATE SET
        quantity = currency_inventory.quantity + p_quantity,
        avg_buy_price_vnd = (
            (currency_inventory.quantity * currency_inventory.avg_buy_price_vnd) +
            (p_quantity * p_unit_price_vnd)
        ) / (currency_inventory.quantity + p_quantity),
        avg_buy_price_usd = (
            (currency_inventory.quantity * currency_inventory.avg_buy_price_usd) +
            (p_quantity * p_unit_price_usd)
        ) / (currency_inventory.quantity + p_quantity),
        last_updated_at = NOW();

    RETURN QUERY SELECT TRUE, v_transaction_id, 'Purchase recorded successfully';
END;
$$;

-- 3. Create Currency Sell Order
CREATE OR REPLACE FUNCTION public.create_currency_sell_order_v1(
    p_game_account_id UUID,
    p_currency_attribute_id UUID,
    p_quantity NUMERIC,
    p_unit_price_vnd NUMERIC,
    p_unit_price_usd NUMERIC,
    p_channel_id UUID,
    p_customer_name TEXT DEFAULT NULL,
    p_game_tag TEXT DEFAULT NULL,
    p_delivery_info TEXT DEFAULT NULL,
    p_order_line_id UUID DEFAULT NULL,
    p_notes TEXT DEFAULT NULL
)
RETURNS TABLE(
    success BOOLEAN,
    transaction_id UUID,
    message TEXT,
    inventory_available BOOLEAN
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_game_code TEXT;
    v_league_id UUID;
    v_transaction_id UUID;
    v_available_quantity NUMERIC := 0;
    v_can_create BOOLEAN := FALSE;
BEGIN
    -- Check permissions
    SELECT EXISTS(
        SELECT 1 FROM user_role_assignments ura
        JOIN attributes ba ON ura.business_area_attribute_id = ba.id
        WHERE ura.user_id = v_user_id
        AND ba.code = 'CURRENCY'
        AND (
            ura.game_attribute_id IS NULL
            OR EXISTS (
                SELECT 1 FROM game_accounts ga
                WHERE ga.id = p_game_account_id
                AND ga.game_code = (
                    SELECT code FROM attributes WHERE id = ura.game_attribute_id
                )
            )
        )
    ) INTO v_can_create;

    IF NOT v_can_create THEN
        RETURN QUERY SELECT FALSE, NULL::UUID, 'Permission denied: Cannot create sell order', FALSE;
        RETURN;
    END IF;

    -- Get game and league info
    SELECT game_code, league_attribute_id
    INTO v_game_code, v_league_id
    FROM game_accounts
    WHERE id = p_game_account_id;

    IF v_game_code IS NULL THEN
        RETURN QUERY SELECT FALSE, NULL::UUID, 'Invalid game account', FALSE;
        RETURN;
    END IF;

    -- Check inventory availability
    SELECT COALESCE(SUM(quantity - reserved_quantity), 0)
    INTO v_available_quantity
    FROM currency_inventory
    WHERE game_account_id = p_game_account_id
    AND currency_attribute_id = p_currency_attribute_id;

    IF v_available_quantity < p_quantity THEN
        RETURN QUERY SELECT FALSE, NULL::UUID,
            format('Insufficient inventory: Available %s, Requested %s', v_available_quantity, p_quantity),
            FALSE;
        RETURN;
    END IF;

    -- Create sell transaction
    INSERT INTO currency_transactions (
        game_account_id,
        game_code,
        league_attribute_id,
        transaction_type,
        currency_attribute_id,
        quantity,
        unit_price_vnd,
        unit_price_usd,
        channel_id,
        order_line_id,
        notes,
        created_by
    ) VALUES (
        p_game_account_id,
        v_game_code,
        v_league_id,
        'sale_delivery',
        p_currency_attribute_id,
        -p_quantity, -- Negative for outgoing
        p_unit_price_vnd,
        p_unit_price_usd,
        p_channel_id,
        p_order_line_id,
        format('Customer: %s, Game Tag: %s, Delivery: %s',
            COALESCE(p_customer_name, 'N/A'),
            COALESCE(p_game_tag, 'N/A'),
            COALESCE(p_delivery_info, 'N/A')
        ) || COALESCE(format('. Notes: %s', p_notes), ''),
        v_user_id
    ) RETURNING id INTO v_transaction_id;

    -- Reserve inventory (this should be handled by trigger)
    UPDATE currency_inventory
    SET reserved_quantity = reserved_quantity + p_quantity,
        last_updated_at = NOW()
    WHERE game_account_id = p_game_account_id
    AND currency_attribute_id = p_currency_attribute_id;

    RETURN QUERY SELECT TRUE, v_transaction_id, 'Sell order created successfully', TRUE;
END;
$$;

-- 4. Calculate Profit for Order
CREATE OR REPLACE FUNCTION public.calculate_profit_for_order_v1(
    p_order_line_id UUID
)
RETURNS TABLE(
    order_line_id UUID,
    purchase_amount NUMERIC,
    purchase_currency TEXT,
    sale_amount NUMERIC,
    sale_currency TEXT,
    channel_name TEXT,
    fee_chain_name TEXT,
    total_fees NUMERIC,
    net_profit NUMERIC,
    profit_margin_percent NUMERIC
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_can_view BOOLEAN := FALSE;
BEGIN
    -- Check permissions
    SELECT EXISTS(
        SELECT 1 FROM user_role_assignments ura
        JOIN attributes ba ON ura.business_area_attribute_id = ba.id
        WHERE ura.user_id = v_user_id
        AND ba.code = 'CURRENCY'
    ) INTO v_can_view;

    IF NOT v_can_view THEN
        RAISE EXCEPTION 'Permission denied: Cannot view profit calculations';
    END IF;

    RETURN QUERY
    WITH order_data AS (
        SELECT
            ol.id as order_line_id,
            ol.id,
            c.name as channel_name,
            tfc.name as fee_chain_name
        FROM order_lines ol
        JOIN channels c ON ol.channel_id = c.id
        LEFT JOIN trading_fee_chains tfc ON c.trading_fee_chain_id = tfc.id
        WHERE ol.id = p_order_line_id
    ),
    transactions AS (
        SELECT
            ct.*,
            curr.name as currency_name
        FROM currency_transactions ct
        JOIN attributes curr ON ct.currency_attribute_id = curr.id
        WHERE ct.order_line_id = p_order_line_id
        AND ct.transaction_type IN ('purchase', 'sale_delivery')
    ),
    purchases AS (
        SELECT
            currency_name,
            SUM(quantity * unit_price_vnd) as total_purchase_vnd,
            SUM(quantity * unit_price_usd) as total_purchase_usd
        FROM transactions
        WHERE transaction_type = 'purchase' AND quantity > 0
        GROUP BY currency_name
    ),
    sales AS (
        SELECT
            currency_name,
            SUM(ABS(quantity) * unit_price_vnd) as total_sale_vnd,
            SUM(ABS(quantity) * unit_price_usd) as total_sale_usd
        FROM transactions
        WHERE transaction_type = 'sale_delivery' AND quantity < 0
        GROUP BY currency_name
    )
    SELECT
        od.id as order_line_id,
        COALESCE(p.total_purchase_vnd, 0) as purchase_amount,
        'VND' as purchase_currency,
        COALESCE(s.total_sale_vnd, 0) as sale_amount,
        'VND' as sale_currency,
        od.channel_name,
        od.fee_chain_name,
        0 as total_fees, -- TODO: Calculate from fee chain
        COALESCE(s.total_sale_vnd, 0) - COALESCE(p.total_purchase_vnd, 0) as net_profit,
        CASE
            WHEN COALESCE(s.total_sale_vnd, 0) > 0
            THEN ROUND(((COALESCE(s.total_sale_vnd, 0) - COALESCE(p.total_purchase_vnd, 0)) / COALESCE(s.total_sale_vnd, 0)) * 100, 2)
            ELSE 0
        END as profit_margin_percent
    FROM order_data od
    LEFT JOIN purchases p ON true
    LEFT JOIN sales s ON true;
END;
$$;

-- 5. Fulfill Currency Order (Complete delivery)
CREATE OR REPLACE FUNCTION public.fulfill_currency_order_v1(
    p_transaction_id UUID,
    p_proof_urls TEXT[] DEFAULT NULL,
    p_completion_notes TEXT DEFAULT NULL
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_transaction RECORD;
    v_can_fulfill BOOLEAN := FALSE;
BEGIN
    -- Check permissions
    SELECT EXISTS(
        SELECT 1 FROM user_role_assignments ura
        JOIN attributes ba ON ura.business_area_attribute_id = ba.id
        WHERE ura.user_id = v_user_id
        AND ba.code = 'CURRENCY'
    ) INTO v_can_fulfill;

    IF NOT v_can_fulfill THEN
        RETURN QUERY SELECT FALSE, 'Permission denied: Cannot fulfill orders';
        RETURN;
    END IF;

    -- Get transaction details
    SELECT * INTO v_transaction
    FROM currency_transactions
    WHERE id = p_transaction_id
    AND transaction_type = 'sale_delivery';

    IF v_transaction IS NULL THEN
        RETURN QUERY SELECT FALSE, 'Transaction not found or not a sale delivery';
        RETURN;
    END IF;

    -- Update transaction with completion details
    UPDATE currency_transactions
    SET
        proof_urls = COALESCE(p_proof_urls, proof_urls),
        notes = COALESCE(p_completion_notes, notes) || ' [FULFILLED]',
        updated_at = NOW()
    WHERE id = p_transaction_id;

    -- Release inventory (this should be handled by trigger)
    UPDATE currency_inventory
    SET
        quantity = quantity - ABS(v_transaction.quantity),
        reserved_quantity = reserved_quantity - ABS(v_transaction.quantity),
        last_updated_at = NOW()
    WHERE game_account_id = v_transaction.game_account_id
    AND currency_attribute_id = v_transaction.currency_attribute_id;

    RETURN QUERY SELECT TRUE, 'Order fulfilled successfully';
END;
$$;

-- Grant execute permissions to authenticated users
GRANT EXECUTE ON FUNCTION public.get_currency_inventory_summary_v1 TO authenticated;
GRANT EXECUTE ON FUNCTION public.record_currency_purchase_v1 TO authenticated;
GRANT EXECUTE ON FUNCTION public.create_currency_sell_order_v1 TO authenticated;
GRANT EXECUTE ON FUNCTION public.calculate_profit_for_order_v1 TO authenticated;
GRANT EXECUTE ON FUNCTION public.fulfill_currency_order_v1 TO authenticated;