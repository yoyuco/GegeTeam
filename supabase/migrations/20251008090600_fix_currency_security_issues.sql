-- Migration: Fix Currency System Security Issues
-- Version: 1.0
-- Date: 2025-10-08
-- Description: Fix RLS and function security issues identified by Supabase linter

-- ===========================================
-- ENABLE RLS ON TRADING FEE CHAINS
-- ===========================================

-- Enable RLS on trading_fee_chains table
ALTER TABLE public.trading_fee_chains ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for trading_fee_chains
-- Everyone can read active fee chains
CREATE POLICY "Allow authenticated users to read active fee chains"
    ON public.trading_fee_chains FOR SELECT
    USING (is_active = true);

-- Only admins can manage fee chains
CREATE POLICY "Allow admins to manage fee chains"
    ON public.trading_fee_chains FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.user_role_assignments ura
            JOIN public.roles r ON ura.role_id = r.id
            WHERE ura.user_id = auth.uid()
            AND r.code = 'admin'
        )
    );

-- ===========================================
-- ENABLE RLS ON EXCHANGE RATES
-- ===========================================

-- Enable RLS on exchange_rates table
ALTER TABLE public.exchange_rates ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for exchange_rates
-- Everyone can read exchange rates
CREATE POLICY "Allow authenticated users to read exchange rates"
    ON public.exchange_rates FOR SELECT
    USING (true);

-- Only admins can update exchange rates
CREATE POLICY "Allow admins to update exchange rates"
    ON public.exchange_rates FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.user_role_assignments ura
            JOIN public.roles r ON ura.role_id = r.id
            WHERE ura.user_id = auth.uid()
            AND r.code IN ('admin', 'manager')
        )
    );

-- ===========================================
-- FIX FUNCTIONS SEARCH PATH SECURITY
-- ===========================================

-- Drop and recreate functions with proper search_path settings

-- Fix get_channel_fee_chain function
DROP FUNCTION IF EXISTS public.get_channel_fee_chain(p_channel_id UUID);

CREATE OR REPLACE FUNCTION public.get_channel_fee_chain(p_channel_id UUID)
RETURNS TABLE(
    fee_chain_id UUID,
    fee_chain_name TEXT,
    fee_chain_description TEXT,
    chain_steps JSONB
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    RETURN QUERY
    SELECT
        tfc.id as fee_chain_id,
        tfc.name as fee_chain_name,
        tfc.description as fee_chain_description,
        tfc.chain_steps
    FROM public.channels c
    LEFT JOIN public.trading_fee_chains tfc ON c.trading_fee_chain_id = tfc.id AND tfc.is_active = true
    WHERE c.id = p_channel_id;
END;
$$;

-- Fix update_currency_inventory function
-- First drop the trigger that depends on it
DROP TRIGGER IF EXISTS trigger_update_currency_inventory ON public.currency_transactions;

CREATE OR REPLACE FUNCTION public.update_currency_inventory()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_inventory_record RECORD;
    v_new_quantity NUMERIC;
    v_new_reserved NUMERIC;
    v_total_value NUMERIC;
    v_total_quantity NUMERIC;
    v_new_avg_price_vnd NUMERIC;
    v_new_avg_price_usd NUMERIC;
BEGIN
    -- Check if inventory record exists
    SELECT * INTO v_inventory_record
    FROM public.currency_inventory
    WHERE game_account_id = NEW.game_account_id
      AND currency_attribute_id = NEW.currency_attribute_id
    FOR UPDATE;

    IF v_inventory_record IS NULL THEN
        -- Create new inventory record
        INSERT INTO public.currency_inventory (
            game_account_id,
            currency_attribute_id,
            quantity,
            reserved_quantity,
            avg_buy_price_vnd,
            avg_buy_price_usd,
            last_updated_at
        ) VALUES (
            NEW.game_account_id,
            NEW.currency_attribute_id,
            CASE
                WHEN NEW.transaction_type IN ('purchase', 'exchange_in', 'farm_in', 'transfer', 'manual_adjustment')
                THEN GREATEST(NEW.quantity, 0)
                ELSE 0
            END,
            0,
            CASE
                WHEN NEW.transaction_type IN ('purchase', 'exchange_in', 'farm_in')
                THEN NEW.unit_price_vnd
                ELSE 0
            END,
            CASE
                WHEN NEW.transaction_type IN ('purchase', 'exchange_in', 'farm_in')
                THEN NEW.unit_price_usd
                ELSE 0
            END,
            NOW()
        );

        RETURN NEW;
    END IF;

    -- Calculate new quantities based on transaction type
    CASE NEW.transaction_type
        WHEN 'purchase', 'exchange_in', 'farm_in', 'transfer', 'manual_adjustment' THEN
            -- Adding to inventory
            v_new_quantity := v_inventory_record.quantity + NEW.quantity;
            v_new_reserved := v_inventory_record.reserved_quantity;

            -- Update average price for purchase types
            IF NEW.transaction_type IN ('purchase', 'exchange_in', 'farm_in') AND NEW.quantity > 0 THEN
                v_total_value := (v_inventory_record.quantity * v_inventory_record.avg_buy_price_vnd) + (NEW.quantity * NEW.unit_price_vnd);
                v_total_quantity := v_inventory_record.quantity + NEW.quantity;
                v_new_avg_price_vnd := v_total_value / v_total_quantity;

                v_total_value := (v_inventory_record.quantity * v_inventory_record.avg_buy_price_usd) + (NEW.quantity * NEW.unit_price_usd);
                v_new_avg_price_usd := v_total_value / v_total_quantity;
            ELSE
                v_new_avg_price_vnd := v_inventory_record.avg_buy_price_vnd;
                v_new_avg_price_usd := v_inventory_record.avg_buy_price_usd;
            END IF;

        WHEN 'sale_delivery', 'exchange_out', 'farm_payout' THEN
            -- Removing from inventory
            v_new_quantity := v_inventory_record.quantity - NEW.quantity;
            v_new_reserved := v_inventory_record.reserved_quantity;
            v_new_avg_price_vnd := v_inventory_record.avg_buy_price_vnd;
            v_new_avg_price_usd := v_inventory_record.avg_buy_price_usd;

            -- Check if enough quantity
            IF v_new_quantity < 0 THEN
                RAISE EXCEPTION 'Insufficient inventory. Current: %, Attempted to remove: %',
                    v_inventory_record.quantity, NEW.quantity;
            END IF;

        ELSE
            -- For other transaction types, don't change quantity
            v_new_quantity := v_inventory_record.quantity;
            v_new_reserved := v_inventory_record.reserved_quantity;
            v_new_avg_price_vnd := v_inventory_record.avg_buy_price_vnd;
            v_new_avg_price_usd := v_inventory_record.avg_buy_price_usd;
    END CASE;

    -- Update inventory record
    UPDATE public.currency_inventory
    SET
        quantity = v_new_quantity,
        reserved_quantity = v_new_reserved,
        avg_buy_price_vnd = v_new_avg_price_vnd,
        avg_buy_price_usd = v_new_avg_price_usd,
        last_updated_at = NOW()
    WHERE id = v_inventory_record.id;

    RETURN NEW;
END;
$$;

-- Fix auto_create_inventory_records function
DROP TRIGGER IF EXISTS trigger_auto_create_inventory_records ON public.game_accounts;

CREATE OR REPLACE FUNCTION public.auto_create_inventory_records()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_currency_record RECORD;
BEGIN
    -- For INVENTORY type accounts, create empty inventory records for all currencies
    IF NEW.purpose = 'INVENTORY' THEN
        -- Create inventory records for all currencies of this game
        FOR v_currency_record IN
            SELECT id
            FROM public.attributes
            WHERE type = NEW.game_code || '_CURRENCY'
        LOOP
            INSERT INTO public.currency_inventory (
                game_account_id,
                currency_attribute_id,
                quantity,
                reserved_quantity,
                avg_buy_price_vnd,
                avg_buy_price_usd,
                last_updated_at
            ) VALUES (
                NEW.id,
                v_currency_record.id,
                0,
                0,
                0,
                0,
                NOW()
            )
            ON CONFLICT (game_account_id, currency_attribute_id)
            DO NOTHING;
        END LOOP;
    END IF;

    RETURN NEW;
END;
$$;

-- Fix protect_account_with_currency function
DROP TRIGGER IF EXISTS trigger_protect_account_with_currency ON public.game_accounts;

CREATE OR REPLACE FUNCTION public.protect_account_with_currency()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_currency_count INTEGER;
BEGIN
    -- Check if account has any currency
    SELECT COUNT(*) INTO v_currency_count
    FROM public.currency_inventory
    WHERE game_account_id = OLD.id
      AND quantity > 0;

    IF v_currency_count > 0 THEN
        RAISE EXCEPTION 'Cannot delete game account with existing currency. Found % currency types with quantity > 0', v_currency_count;
    END IF;

    RETURN OLD;
END;
$$;

-- Fix update_updated_at_column function
-- Note: This function is used by multiple triggers, so we won't drop it here
-- We'll create it with proper security if it doesn't exist

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;

-- Fix calculate_chain_costs function
DROP FUNCTION IF EXISTS public.calculate_chain_costs(
    p_chain_id UUID,
    p_from_amount NUMERIC,
    p_from_currency TEXT,
    p_to_currency TEXT,
    p_exchange_rates JSONB
);

CREATE OR REPLACE FUNCTION public.calculate_chain_costs(
    p_chain_id UUID,
    p_from_amount NUMERIC,
    p_from_currency TEXT,
    p_to_currency TEXT,
    p_exchange_rates JSONB DEFAULT '{}'
)
RETURNS TABLE(
    step_number INTEGER,
    from_amount NUMERIC,
    to_amount NUMERIC,
    from_currency TEXT,
    to_currency TEXT,
    fee_type TEXT,
    fee_amount NUMERIC,
    fee_currency TEXT,
    description TEXT,
    cumulative_amount NUMERIC
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_chain JSONB;
    v_step JSONB;
    v_current_amount NUMERIC := p_from_amount;
    v_current_currency TEXT := p_from_currency;
    v_exchange_rate NUMERIC;
BEGIN
    -- Get chain steps
    SELECT chain_steps INTO v_chain
    FROM public.trading_fee_chains
    WHERE id = p_chain_id AND is_active = true;

    IF v_chain IS NULL THEN
        RAISE EXCEPTION 'Trading chain not found or inactive';
    END IF;

    -- Process each step in chain
    FOR v_step IN SELECT * FROM jsonb_array_elements(v_chain) as step
    LOOP
        -- Calculate exchange rate if needed
        IF v_step->>'from_currency' <> v_step->>'to_currency' THEN
            v_exchange_rate := (p_exchange_rates ->> (v_step->>'from_currency' || '_' || v_step->>'to_currency'))::NUMERIC;
            IF v_exchange_rate IS NULL THEN
                -- Try to get from database
                SELECT rate INTO v_exchange_rate
                FROM public.exchange_rates
                WHERE source_currency = v_step->>'from_currency'
                  AND target_currency = v_step->>'to_currency';

                IF v_exchange_rate IS NULL THEN
                    RAISE EXCEPTION 'Missing exchange rate for % to %', v_step->>'from_currency', v_step->>'to_currency';
                END IF;
            END IF;
        ELSE
            v_exchange_rate := 1;
        END IF;

        -- Calculate amount after exchange rate
        DECLARE
            v_exchanged_amount NUMERIC;
            v_fee_amount NUMERIC;
        BEGIN
            v_exchanged_amount := v_current_amount * v_exchange_rate;

            -- Calculate fee
            IF (v_step->>'fee_currency') = (v_step->>'to_currency') THEN
                -- Fee calculated on target currency
                v_fee_amount := (v_exchanged_amount * (v_step->>'fee_percent')::NUMERIC / 100) + (v_step->>'fee_fixed')::NUMERIC;
            ELSE
                -- Fee calculated on source currency, need conversion
                v_fee_amount := ((v_current_amount * (v_step->>'fee_percent')::NUMERIC / 100) + (v_step->>'fee_fixed')::NUMERIC) * v_exchange_rate;
            END IF;

            -- Return results for this step
            RETURN QUERY
            SELECT
                (v_step->>'step')::INTEGER as step_number,
                v_current_amount as from_amount,
                (v_exchanged_amount - v_fee_amount) as to_amount,
                v_step->>'from_currency' as from_currency,
                v_step->>'to_currency' as to_currency,
                v_step->>'fee_type' as fee_type,
                v_fee_amount as fee_amount,
                v_step->>'fee_currency' as fee_currency,
                v_step->>'description' as description,
                (v_exchanged_amount - v_fee_amount) as cumulative_amount;

            -- Update for next step
            v_current_amount := v_exchanged_amount - v_fee_amount;
            v_current_currency := v_step->>'to_currency';
        END;
    END LOOP;
END;
$$;

-- Fix calculate_simple_profit_loss function
DROP FUNCTION IF EXISTS public.calculate_simple_profit_loss(
    p_purchase_amount NUMERIC,
    p_purchase_currency TEXT,
    p_sale_amount NUMERIC,
    p_sale_currency TEXT,
    p_chain_id UUID,
    p_exchange_rates JSONB
);

CREATE OR REPLACE FUNCTION public.calculate_simple_profit_loss(
    p_purchase_amount NUMERIC,
    p_purchase_currency TEXT,
    p_sale_amount NUMERIC,
    p_sale_currency TEXT,
    p_chain_id UUID,
    p_exchange_rates JSONB DEFAULT '{}'
)
RETURNS TABLE(
    purchase_amount NUMERIC,
    purchase_currency TEXT,
    sale_amount NUMERIC,
    sale_currency TEXT,
    total_fees NUMERIC,
    net_profit NUMERIC,
    profit_margin_percent NUMERIC
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_total_fees NUMERIC := 0;
    v_final_amount NUMERIC;
    v_exchange_rate NUMERIC;
BEGIN
    -- Calculate total fees for sale chain
    SELECT COALESCE(SUM(fee_amount), 0) INTO v_total_fees
    FROM public.calculate_chain_costs(p_chain_id, p_sale_amount, p_sale_currency, p_purchase_currency, p_exchange_rates);

    -- Get final amount
    SELECT cumulative_amount INTO v_final_amount
    FROM public.calculate_chain_costs(p_chain_id, p_sale_amount, p_sale_currency, p_purchase_currency, p_exchange_rates)
    ORDER BY step_number DESC
    LIMIT 1;

    -- Convert purchase amount to same currency for comparison
    IF p_purchase_currency <> p_sale_currency THEN
        v_exchange_rate := (p_exchange_rates ->> (p_purchase_currency || '_' || p_sale_currency))::NUMERIC;
        IF v_exchange_rate IS NULL THEN
            SELECT rate INTO v_exchange_rate
            FROM public.exchange_rates
            WHERE source_currency = p_purchase_currency
              AND target_currency = p_sale_currency;
        END IF;

        IF v_exchange_rate IS NOT NULL THEN
            v_final_amount := v_final_amount - (p_purchase_amount * v_exchange_rate);
        ELSE
            v_final_amount := NULL; -- Cannot calculate without exchange rate
        END IF;
    ELSE
        v_final_amount := v_final_amount - p_purchase_amount;
    END IF;

    RETURN QUERY
    SELECT
        p_purchase_amount as purchase_amount,
        p_purchase_currency as purchase_currency,
        p_sale_amount as sale_amount,
        p_sale_currency as sale_currency,
        v_total_fees as total_fees,
        COALESCE(v_final_amount, 0) as net_profit,
        CASE
            WHEN p_purchase_amount > 0 AND v_final_amount IS NOT NULL
            THEN ((v_final_amount) / p_purchase_amount * 100)
            ELSE NULL
        END as profit_margin_percent;
END;
$$;

-- Fix calculate_order_profit function
DROP FUNCTION IF EXISTS public.calculate_order_profit(p_order_line_id UUID);

CREATE OR REPLACE FUNCTION public.calculate_order_profit(p_order_line_id UUID)
RETURNS TABLE(
    order_line_id UUID,
    purchase_amount NUMERIC,
    sale_amount NUMERIC,
    channel_name TEXT,
    fee_chain_name TEXT,
    total_fees NUMERIC,
    net_profit NUMERIC,
    profit_margin_percent NUMERIC,
    calculation_details JSONB
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_order_line RECORD;
    v_fee_chain_id UUID;
    v_exchange_rates JSONB;
BEGIN
    -- Get order line details with channel information
    SELECT
        ol.*,
        c.code as channel_code,
        c.trading_fee_chain_id
    INTO v_order_line
    FROM public.order_lines ol
    JOIN public.channels c ON ol.channel_id = c.id
    WHERE ol.id = p_order_line_id;

    IF v_order_line IS NULL THEN
        RAISE EXCEPTION 'Order line not found';
    END IF;

    -- Get current exchange rates
    SELECT jsonb_object_agg(
        source_currency || '_' || target_currency,
        rate
    ) INTO v_exchange_rates
    FROM public.exchange_rates;

    -- Calculate profit using the channel's fee chain
    IF v_order_line.trading_fee_chain_id IS NOT NULL THEN
        RETURN QUERY
        SELECT
            v_order_line.id as order_line_id,
            COALESCE(v_order_line.buy_price_total, 0) as purchase_amount,
            COALESCE(v_order_line.sell_price_total, 0) as sale_amount,
            v_order_line.channel_code as channel_name,
            tfc.name as fee_chain_name,
            profit.total_fees,
            profit.net_profit,
            profit.profit_margin_percent,
            jsonb_build_object(
                'channel_id', v_order_line.channel_id,
                'fee_chain_id', v_order_line.trading_fee_chain_id,
                'exchange_rates_used', v_exchange_rates,
                'calculation_steps', profit.calculation_steps
            ) as calculation_details
        FROM public.trading_fee_chains tfc
        CROSS JOIN LATERAL public.calculate_simple_profit_loss(
            COALESCE(v_order_line.buy_price_total, 0),
            'VND',
            COALESCE(v_order_line.sell_price_total, 0),
            CASE
                WHEN v_order_line.sell_price_currency_code = 'USD' THEN 'USD'
                ELSE 'VND'
            END,
            v_order_line.trading_fee_chain_id,
            v_exchange_rates
        ) profit
        WHERE tfc.id = v_order_line.trading_fee_chain_id;
    ELSE
        -- No fee chain associated - calculate simple profit
        RETURN QUERY
        SELECT
            v_order_line.id as order_line_id,
            COALESCE(v_order_line.buy_price_total, 0) as purchase_amount,
            COALESCE(v_order_line.sell_price_total, 0) as sale_amount,
            v_order_line.channel_code as channel_name,
            'No Fees Applied' as fee_chain_name,
            0 as total_fees,
            CASE
                WHEN v_order_line.sell_price_currency_code = 'USD' THEN
                    (v_order_line.sell_price_total * (v_exchange_rates ->> 'USD_VND')::NUMERIC) - v_order_line.buy_price_total
                ELSE
                    v_order_line.sell_price_total - v_order_line.buy_price_total
            END as net_profit,
            CASE
                WHEN v_order_line.buy_price_total > 0 THEN
                    CASE
                        WHEN v_order_line.sell_price_currency_code = 'USD' THEN
                            ((v_order_line.sell_price_total * (v_exchange_rates ->> 'USD_VND')::NUMERIC) - v_order_line.buy_price_total) / v_order_line.buy_price_total * 100
                        ELSE
                            (v_order_line.sell_price_total - v_order_line.buy_price_total) / v_order_line.buy_price_total * 100
                    END
                ELSE NULL
            END as profit_margin_percent,
            jsonb_build_object(
                'channel_id', v_order_line.channel_id,
                'fee_chain_id', NULL,
                'note', 'No fee chain associated with this channel'
            ) as calculation_details;
    END IF;
END;
$$;

-- ===========================================
-- RECREATE TRIGGERS (they will use the updated functions)
-- ===========================================

-- Recreate triggers with fixed functions
CREATE TRIGGER trigger_update_currency_inventory
    AFTER INSERT ON public.currency_transactions
    FOR EACH ROW
    EXECUTE FUNCTION public.update_currency_inventory();

CREATE TRIGGER trigger_auto_create_inventory_records
    AFTER INSERT ON public.game_accounts
    FOR EACH ROW
    EXECUTE FUNCTION public.auto_create_inventory_records();

CREATE TRIGGER trigger_protect_account_with_currency
    BEFORE DELETE ON public.game_accounts
    FOR EACH ROW
    EXECUTE FUNCTION public.protect_account_with_currency();

-- Note: update_updated_at_column triggers may already exist from previous migrations
-- They will use the updated function automatically since we used CREATE OR REPLACE

-- ===========================================
-- GRANT PERMISSIONS
-- ===========================================

-- Grant necessary permissions
GRANT SELECT ON public.trading_fee_chains TO authenticated;
GRANT SELECT ON public.exchange_rates TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_channel_fee_chain TO authenticated;
GRANT EXECUTE ON FUNCTION public.calculate_chain_costs TO authenticated;
GRANT EXECUTE ON FUNCTION public.calculate_simple_profit_loss TO authenticated;
GRANT EXECUTE ON FUNCTION public.calculate_order_profit TO authenticated;

-- ===========================================
-- COMMENTS
-- ===========================================

COMMENT ON FUNCTION public.get_channel_fee_chain IS 'Lấy chuỗi phí liên kết với một kênh bán hàng (fixed security)';
COMMENT ON FUNCTION public.calculate_order_profit IS 'Tính lợi nhuận cho một đơn hàng dựa trên chuỗi phí của kênh (fixed security)';
COMMENT ON FUNCTION public.calculate_chain_costs IS 'Tính toán chi phí qua từng bước trong chuỗi phí (fixed security)';
COMMENT ON FUNCTION public.calculate_simple_profit_loss IS 'Tính toán lợi nhuận đơn giản cho một giao dịch (fixed security)';