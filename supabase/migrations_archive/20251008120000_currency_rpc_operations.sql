-- Additional Currency RPC Functions for Operations

-- 6. Exchange Currency (Between different types)
CREATE OR REPLACE FUNCTION public.exchange_currency_v1(
    p_from_account_id UUID,
    p_from_currency_id UUID,
    p_to_currency_id UUID,
    p_from_quantity NUMERIC,
    p_to_quantity NUMERIC,
    p_exchange_rate NUMERIC,
    p_notes TEXT DEFAULT NULL
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    from_transaction_id UUID,
    to_transaction_id UUID
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_from_account RECORD;
    v_to_account RECORD;
    v_from_available NUMERIC := 0;
    v_can_exchange BOOLEAN := FALSE;
    v_from_trans_id UUID;
    v_to_trans_id UUID;
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
                WHERE ga.id = p_from_account_id
                AND ga.game_code = (SELECT code FROM attributes WHERE id = ura.game_attribute_id)
            )
        )
    ) INTO v_can_exchange;

    IF NOT v_can_exchange THEN
        RETURN QUERY SELECT FALSE, 'Permission denied: Cannot exchange currency', NULL::UUID, NULL::UUID;
        RETURN;
    END IF;

    -- Get account details
    SELECT * INTO v_from_account
    FROM game_accounts WHERE id = p_from_account_id;

    IF v_from_account IS NULL THEN
        RETURN QUERY SELECT FALSE, 'Invalid source account', NULL::UUID, NULL::UUID;
        RETURN;
    END IF;

    -- Check inventory availability
    SELECT COALESCE(SUM(quantity - reserved_quantity), 0)
    INTO v_from_available
    FROM currency_inventory
    WHERE game_account_id = p_from_account_id
    AND currency_attribute_id = p_from_currency_id;

    IF v_from_available < p_from_quantity THEN
        RETURN QUERY SELECT FALSE,
            format('Insufficient inventory: Available %s, Requested %s', v_from_available, p_from_quantity),
            NULL::UUID, NULL::UUID;
        RETURN;
    END IF;

    -- Create exchange out transaction
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
        notes,
        created_by
    ) VALUES (
        p_from_account_id,
        v_from_account.game_code,
        v_from_account.league_attribute_id,
        'exchange_out',
        p_from_currency_id,
        -p_from_quantity,
        0, -- No price for exchange
        0,
        p_exchange_rate,
        format('Exchange %s %s to %s %s (Rate: %s)',
            p_from_quantity,
            (SELECT name FROM attributes WHERE id = p_from_currency_id),
            p_to_quantity,
            (SELECT name FROM attributes WHERE id = p_to_currency_id),
            p_exchange_rate
        ) || COALESCE(format('. Notes: %s', p_notes), ''),
        v_user_id
    ) RETURNING id INTO v_from_trans_id;

    -- Create exchange in transaction
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
        notes,
        created_by
    ) VALUES (
        p_from_account_id,
        v_from_account.game_code,
        v_from_account.league_attribute_id,
        'exchange_in',
        p_to_currency_id,
        p_to_quantity,
        0, -- No price for exchange
        0,
        p_exchange_rate,
        format('Exchange %s %s to %s %s (Rate: %s)',
            p_from_quantity,
            (SELECT name FROM attributes WHERE id = p_from_currency_id),
            p_to_quantity,
            (SELECT name FROM attributes WHERE id = p_to_currency_id),
            p_exchange_rate
        ) || COALESCE(format('. Notes: %s', p_notes), ''),
        v_user_id
    ) RETURNING id INTO v_to_trans_id;

    -- Update inventory (decrease from currency)
    UPDATE currency_inventory
    SET
        quantity = quantity - p_from_quantity,
        last_updated_at = NOW()
    WHERE game_account_id = p_from_account_id
    AND currency_attribute_id = p_from_currency_id;

    -- Update inventory (increase to currency)
    INSERT INTO currency_inventory (
        game_account_id,
        currency_attribute_id,
        quantity,
        avg_buy_price_vnd,
        avg_buy_price_usd
    ) VALUES (
        p_from_account_id,
        p_to_currency_id,
        p_to_quantity,
        0, -- No cost for exchange
        0
    )
    ON CONFLICT (game_account_id, currency_attribute_id)
    DO UPDATE SET
        quantity = currency_inventory.quantity + p_to_quantity,
        last_updated_at = NOW();

    RETURN QUERY SELECT TRUE, 'Currency exchanged successfully', v_from_trans_id, v_to_trans_id;
END;
$$;

-- 7. Payout Farmer
CREATE OR REPLACE FUNCTION public.payout_farmer_v1(
    p_farmer_profile_id UUID,
    p_game_account_id UUID,
    p_currency_attribute_id UUID,
    p_quantity NUMERIC,
    p_payout_rate_vnd NUMERIC,
    p_payout_rate_usd NUMERIC DEFAULT 0,
    p_exchange_rate_vnd_per_usd NUMERIC DEFAULT 25700,
    p_notes TEXT DEFAULT NULL
)
RETURNS TABLE(
    success BOOLEAN,
    transaction_id UUID,
    message TEXT,
    payout_amount_vnd NUMERIC,
    payout_amount_usd NUMERIC
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_game_account RECORD;
    v_farmer_name TEXT;
    v_available_quantity NUMERIC := 0;
    v_can_payout BOOLEAN := FALSE;
    v_transaction_id UUID;
    v_payout_vnd NUMERIC;
    v_payout_usd NUMERIC;
BEGIN
    -- Check permissions (manager or admin can payout)
    SELECT EXISTS(
        SELECT 1 FROM user_role_assignments ura
        JOIN roles r ON ura.role_id = r.id
        JOIN attributes ba ON ura.business_area_attribute_id = ba.id
        WHERE ura.user_id = v_user_id
        AND ba.code = 'CURRENCY'
        AND r.code IN ('admin', 'manager', 'farmer_manager', 'farmer_leader')
    ) INTO v_can_payout;

    IF NOT v_can_payout THEN
        RETURN QUERY SELECT FALSE, NULL::UUID, 'Permission denied: Cannot payout to farmer', 0, 0;
        RETURN;
    END IF;

    -- Get details
    SELECT ga.*
    INTO v_game_account
    FROM game_accounts ga
    WHERE ga.id = p_game_account_id;

    SELECT p.display_name
    INTO v_farmer_name
    FROM profiles p
    WHERE p.id = p_farmer_profile_id;

    IF v_game_account IS NULL THEN
        RETURN QUERY SELECT FALSE, NULL::UUID, 'Invalid game account or farmer', 0, 0;
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
            0, 0;
        RETURN;
    END IF;

    -- Calculate payout amounts
    v_payout_vnd := p_quantity * p_payout_rate_vnd;
    v_payout_usd := p_quantity * p_payout_rate_usd;

    -- Create payout transaction
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
        farmer_profile_id,
        notes,
        created_by
    ) VALUES (
        p_game_account_id,
        v_game_account.game_code,
        v_game_account.league_attribute_id,
        'farm_payout',
        p_currency_attribute_id,
        -p_quantity,
        p_payout_rate_vnd,
        p_payout_rate_usd,
        p_exchange_rate_vnd_per_usd,
        p_farmer_profile_id,
        format('Farmer payout to %s: %s units @ %s VND/unit = %s VND',
            COALESCE(v_farmer_name, 'Unknown'),
            p_quantity,
            p_payout_rate_vnd,
            v_payout_vnd
        ) || COALESCE(format('. Notes: %s', p_notes), ''),
        v_user_id
    ) RETURNING id INTO v_transaction_id;

    -- Update inventory
    UPDATE currency_inventory
    SET
        quantity = quantity - p_quantity,
        last_updated_at = NOW()
    WHERE game_account_id = p_game_account_id
    AND currency_attribute_id = p_currency_attribute_id;

    RETURN QUERY SELECT TRUE, v_transaction_id, 'Farmer payout processed successfully', v_payout_vnd, v_payout_usd;
END;
$$;

-- 8. Archive League Currency (End of season)
CREATE OR REPLACE FUNCTION public.archive_league_currency_v1(
    p_from_league_id UUID,
    p_to_league_id UUID,
    p_archive_type TEXT DEFAULT 'standard' -- 'standard', 'softcore', 'hardcore'
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    transactions_created BIGINT,
    total_value_vnd NUMERIC
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_from_league RECORD;
    v_to_league RECORD;
    v_can_archive BOOLEAN := FALSE;
    v_transaction_count BIGINT := 0;
    v_total_value NUMERIC := 0;
BEGIN
    -- Check permissions (admin or manager only)
    SELECT EXISTS(
        SELECT 1 FROM user_role_assignments ura
        JOIN roles r ON ura.role_id = r.id
        JOIN attributes ba ON ura.business_area_attribute_id = ba.id
        WHERE ura.user_id = v_user_id
        AND ba.code = 'CURRENCY'
        AND r.code IN ('admin', 'manager')
    ) INTO v_can_archive;

    IF NOT v_can_archive THEN
        RETURN QUERY SELECT FALSE, 'Permission denied: Cannot archive league currency', 0, 0;
        RETURN;
    END IF;

    -- Get league details
    SELECT fl.*
    INTO v_from_league
    FROM attributes fl
    WHERE fl.id = p_from_league_id;

    IF v_from_league IS NULL THEN
        RETURN QUERY SELECT FALSE, 'Invalid source or target league', 0, 0;
        RETURN;
    END IF;

    -- Archive all inventory in the league
    INSERT INTO currency_transactions (
        game_account_id,
        game_code,
        league_attribute_id,
        transaction_type,
        currency_attribute_id,
        quantity,
        unit_price_vnd,
        unit_price_usd,
        notes,
        created_by
    )
    SELECT
        inv.game_account_id,
        ga.game_code,
        p_from_league_id,
        'league_archive',
        inv.currency_attribute_id,
        -inv.quantity, -- Move all currency out
        inv.avg_buy_price_vnd,
        inv.avg_buy_price_usd,
        format('League archive: %s → %s. Moved %s %s',
            v_from_league.name,
            (SELECT name FROM attributes WHERE id = p_to_league_id),
            inv.quantity,
            (SELECT name FROM attributes WHERE id = inv.currency_attribute_id)
        ),
        v_user_id
    FROM currency_inventory inv
    JOIN game_accounts ga ON inv.game_account_id = ga.id
    WHERE ga.league_attribute_id = p_from_league_id
    AND inv.quantity > 0
    RETURNING id INTO v_transaction_count;

    -- Calculate total value
    SELECT COALESCE(SUM(quantity * avg_buy_price_vnd), 0)
    INTO v_total_value
    FROM currency_inventory inv
    JOIN game_accounts ga ON inv.game_account_id = ga.id
    WHERE ga.league_attribute_id = p_from_league_id
    AND inv.quantity > 0;

    -- Clear inventory
    DELETE FROM currency_inventory
    WHERE game_account_id IN (
        SELECT id FROM game_accounts WHERE league_attribute_id = p_from_league_id
    );

    RETURN QUERY SELECT TRUE,
        format('League %s archived successfully. %s transactions processed, total value: %s VND',
            v_from_league.name,
            v_transaction_count,
            v_total_value
        ),
        v_transaction_count,
        v_total_value;
END;
$$;

-- 9. Get Transaction History with Filters
CREATE OR REPLACE FUNCTION public.get_currency_transaction_history_v1(
    p_game_code TEXT DEFAULT NULL,
    p_league_id UUID DEFAULT NULL,
    p_transaction_type TEXT DEFAULT NULL,
    p_currency_id UUID DEFAULT NULL,
    p_account_id UUID DEFAULT NULL,
    p_start_date TIMESTAMPTZ DEFAULT NULL,
    p_end_date TIMESTAMPTZ DEFAULT NULL,
    p_limit BIGINT DEFAULT 100,
    p_offset BIGINT DEFAULT 0
)
RETURNS TABLE(
    id UUID,
    created_at TIMESTAMPTZ,
    transaction_type TEXT,
    currency_name TEXT,
    currency_code TEXT,
    quantity NUMERIC,
    unit_price_vnd NUMERIC,
    unit_price_usd NUMERIC,
    total_value_vnd NUMERIC,
    account_name TEXT,
    league_name TEXT,
    creator_name TEXT,
    notes TEXT,
    proof_urls TEXT[]
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
        RAISE EXCEPTION 'Permission denied: Cannot view transaction history';
    END IF;

    RETURN QUERY
    SELECT
        ct.id,
        ct.created_at,
        ct.transaction_type,
        curr.name as currency_name,
        curr.code as currency_code,
        ct.quantity,
        ct.unit_price_vnd,
        ct.unit_price_usd,
        ABS(ct.quantity * ct.unit_price_vnd) as total_value_vnd,
        ga.account_name,
        l.name as league_name,
        p.display_name as creator_name,
        ct.notes,
        ct.proof_urls
    FROM currency_transactions ct
    JOIN attributes curr ON ct.currency_attribute_id = curr.id
    JOIN game_accounts ga ON ct.game_account_id = ga.id
    JOIN attributes l ON ga.league_attribute_id = l.id
    JOIN profiles p ON ct.created_by = p.id
    WHERE
        -- Permission filter
        EXISTS (
            SELECT 1 FROM user_role_assignments ura
            WHERE ura.user_id = v_user_id
            AND ura.business_area_attribute_id = (SELECT id FROM attributes WHERE code = 'CURRENCY')
            AND (
                ura.game_attribute_id IS NULL
                OR ura.game_attribute_id = (SELECT id FROM attributes WHERE code = ga.game_code AND type = 'GAME')
            )
        )
        -- Optional filters
        AND (p_game_code IS NULL OR ga.game_code = p_game_code)
        AND (p_league_id IS NULL OR ga.league_attribute_id = p_league_id)
        AND (p_transaction_type IS NULL OR ct.transaction_type = p_transaction_type)
        AND (p_currency_id IS NULL OR ct.currency_attribute_id = p_currency_id)
        AND (p_account_id IS NULL OR ct.game_account_id = p_account_id)
        AND (p_start_date IS NULL OR ct.created_at >= p_start_date)
        AND (p_end_date IS NULL OR ct.created_at <= p_end_date)
    ORDER BY ct.created_at DESC
    LIMIT p_limit
    OFFSET p_offset;
END;
$$;

-- Grant execute permissions to authenticated users
GRANT EXECUTE ON FUNCTION public.exchange_currency_v1 TO authenticated;
GRANT EXECUTE ON FUNCTION public.payout_farmer_v1 TO authenticated;
GRANT EXECUTE ON FUNCTION public.archive_league_currency_v1 TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_currency_transaction_history_v1 TO authenticated;