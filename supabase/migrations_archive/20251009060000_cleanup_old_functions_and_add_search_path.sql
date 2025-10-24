-- Migration: Cleanup old functions and add search_path to new ones
-- Version: 1.0
-- Date: 2025-10-09
-- Dependencies: All previous currency migrations

-- ===========================================
-- DROP OLD FUNCTIONS
-- ===========================================

-- Drop old calculate_order_profit function (no longer needed)
DROP FUNCTION IF EXISTS public.calculate_order_profit(p_order_line_id UUID);

-- Drop any other old functions that might conflict
DROP FUNCTION IF EXISTS public.calculate_chain_costs(JSONB);

-- Drop existing functions before recreating to avoid return type conflicts
DROP FUNCTION IF EXISTS public.get_currency_inventory_summary_v1(TEXT, UUID);
DROP FUNCTION IF EXISTS public.record_currency_purchase_v1(UUID, UUID, NUMERIC, NUMERIC, NUMERIC, NUMERIC, UUID, TEXT[], TEXT);
DROP FUNCTION IF EXISTS public.calculate_profit_for_order_v1(UUID);

-- ===========================================
-- UPDATE NEW RPC FUNCTIONS WITH SEARCH_PATH
-- ===========================================

-- Recreate functions with proper search_path and improved error handling

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
SET search_path = public
AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_can_manage BOOLEAN := FALSE;
BEGIN
    -- Set search_path to public
    SET LOCAL search_path TO public;

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

-- Grant execute permission
GRANT EXECUTE ON FUNCTION public.get_currency_inventory_summary_v1(TEXT, UUID) TO authenticated;
COMMENT ON FUNCTION public.get_currency_inventory_summary_v1 IS 'Get currency inventory summary with permission checks (v1)';

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
    message TEXT,
    transaction_id UUID
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_game_account RECORD;
    v_can_purchase BOOLEAN := FALSE;
    v_transaction_id UUID;
BEGIN
    -- Set search_path to public
    SET LOCAL search_path TO public;

    -- Check permissions
    SELECT EXISTS(
        SELECT 1 FROM user_role_assignments ura
        JOIN attributes ba ON ura.business_area_attribute_id = ba.id
        WHERE ura.user_id = v_user_id
        AND ba.code = 'CURRENCY'
        AND ura.game_attribute_id IS NOT NULL
        AND EXISTS (
            SELECT 1 FROM game_accounts ga
            WHERE ga.id = p_game_account_id
            AND ga.game_code = (SELECT code FROM attributes WHERE id = ura.game_attribute_id)
        )
    ) INTO v_can_purchase;

    IF NOT v_can_purchase THEN
        RETURN QUERY SELECT FALSE, 'Permission denied: Cannot record currency purchase', NULL::UUID;
        RETURN;
    END IF;

    -- Get game account details
    SELECT * INTO v_game_account
    FROM game_accounts
    WHERE id = p_game_account_id;

    IF v_game_account IS NULL THEN
        RETURN QUERY SELECT FALSE, 'Invalid game account', NULL::UUID;
        RETURN;
    END IF;

    -- Validate quantity
    IF p_quantity <= 0 THEN
        RETURN QUERY SELECT FALSE, 'Quantity must be positive', NULL::UUID;
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
        v_game_account.game_code,
        v_game_account.league_attribute_id,
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

    -- Update inventory (handled by trigger)

    RETURN QUERY SELECT TRUE, 'Purchase recorded successfully', v_transaction_id;
END;
$$;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION public.record_currency_purchase_v1 TO authenticated;
COMMENT ON FUNCTION public.record_currency_purchase_v1 IS 'Record currency purchase with inventory updates (v1)';

-- 3. Calculate Profit for Order (Enhanced version)
CREATE OR REPLACE FUNCTION public.calculate_profit_for_order_v1(
    p_order_line_id UUID
)
RETURNS TABLE(
    order_line_id UUID,
    purchase_amount NUMERIC,
    sale_amount NUMERIC,
    channel_name TEXT,
    fee_chain_name TEXT,
    total_fees NUMERIC,
    net_profit NUMERIC,
    profit_margin_percent NUMERIC
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_can_view BOOLEAN := FALSE;
BEGIN
    -- Set search_path to public
    SET LOCAL search_path TO public;

    -- Check permissions
    SELECT EXISTS(
        SELECT 1 FROM user_role_assignments ura
        JOIN attributes ba ON ura.business_area_attribute_id = ba.id
        WHERE ura.user_id = v_user_id
        AND ba.code = 'CURRENCY'
    ) INTO v_can_view;

    IF NOT v_can_view THEN
        RAISE EXCEPTION 'Permission denied: Cannot view order profit';
    END IF;

    -- Calculate profit using trading fee chain
    RETURN QUERY
    WITH order_data AS (
        SELECT
            ol.id as order_line_id,
            ol.quantity,
            ol.unit_price_vnd,
            ol.channel_id,
            ch.name as channel_name,
            tfc.name as fee_chain_name
        FROM order_lines ol
        JOIN channels ch ON ol.channel_id = ch.id
        LEFT JOIN trading_fee_chains tfc ON ch.trading_fee_chain_id = tfc.id
        WHERE ol.id = p_order_line_id
    ),
    fees AS (
        SELECT
            SUM(CASE
                WHEN ft.type = 'PERCENTAGE' THEN od.quantity * od.unit_price_vnd * (ft.value / 100)
                WHEN ft.type = 'FIXED_VND' THEN ft.value
                WHEN ft.type = 'FIXED_USD' THEN ft.value * COALESCE((SELECT rate FROM exchange_rates WHERE source_currency = 'USD' AND target_currency = 'VND'), 25700)
                ELSE 0
            END) as total_fees
        FROM order_data od
        LEFT JOIN trading_fee_chains tfc ON od.fee_chain_name = tfc.name
        LEFT JOIN trading_fees tf ON tfc.id = tf.fee_chain_id
        WHERE tf.is_active = true
    ),
    transactions AS (
        SELECT
            SUM(CASE
                WHEN ct.transaction_type IN ('purchase', 'farm_in') THEN ct.quantity * ct.unit_price_vnd
                ELSE 0
            END) as purchase_amount,
            SUM(CASE
                WHEN ct.transaction_type IN ('sale_delivery', 'exchange_in') THEN ABS(ct.quantity * ct.unit_price_vnd)
                ELSE 0
            END) as sale_amount
        FROM currency_transactions ct
        WHERE ct.order_line_id = p_order_line_id
    )
    SELECT
        od.order_line_id,
        COALESCE(t.purchase_amount, 0) as purchase_amount,
        COALESCE(t.sale_amount, od.quantity * od.unit_price_vnd) as sale_amount,
        od.channel_name,
        od.fee_chain_name,
        COALESCE(f.total_fees, 0) as total_fees,
        (COALESCE(t.sale_amount, od.quantity * od.unit_price_vnd) - COALESCE(t.purchase_amount, 0) - COALESCE(f.total_fees, 0)) as net_profit,
        CASE
            WHEN COALESCE(t.purchase_amount, 0) > 0
            THEN ((COALESCE(t.sale_amount, od.quantity * od.unit_price_vnd) - COALESCE(t.purchase_amount, 0) - COALESCE(f.total_fees, 0)) / COALESCE(t.purchase_amount, 0)) * 100
            ELSE 0
        END as profit_margin_percent
    FROM order_data od
    LEFT JOIN fees f ON true
    LEFT JOIN transactions t ON true;
END;
$$;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION public.calculate_profit_for_order_v1 TO authenticated;
COMMENT ON FUNCTION public.calculate_profit_for_order_v1 IS 'Calculate profit for order with fee chain integration (v1)';

-- ===========================================
-- SYSTEM LOGGING
-- ===========================================

-- Create system_logs table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.system_logs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    action TEXT NOT NULL,
    status TEXT NOT NULL,
    details JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by UUID REFERENCES public.profiles(id)
);

-- Create indexes for system_logs
CREATE INDEX IF NOT EXISTS idx_system_logs_action ON public.system_logs(action);
CREATE INDEX IF NOT EXISTS idx_system_logs_created_at ON public.system_logs(created_at);
CREATE INDEX IF NOT EXISTS idx_system_logs_status ON public.system_logs(status);

-- ===========================================
-- COMMENTS
-- ===========================================

COMMENT ON TABLE public.system_logs IS 'System operation logs for debugging and auditing';
COMMENT ON COLUMN public.system_logs.action IS 'Type of action performed';
COMMENT ON COLUMN public.system_logs.status IS 'Status of the action (success, error, etc.)';
COMMENT ON COLUMN public.system_logs.details IS 'Additional details in JSON format';

-- Log this migration
INSERT INTO public.system_logs (action, status, details)
VALUES (
    'cleanup_old_functions_and_add_search_path',
    'success',
    json_build_object(
        'dropped_functions', ARRAY['calculate_order_profit', 'calculate_chain_costs'],
        'updated_functions', ARRAY['get_currency_inventory_summary_v1', 'record_currency_purchase_v1', 'calculate_profit_for_order_v1'],
        'created_table', 'system_logs'
    )
);