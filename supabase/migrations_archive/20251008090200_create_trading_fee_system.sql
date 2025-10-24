-- Migration: Create Trading Fee Chains System
-- Version: 1.0
-- Date: 2025-10-08
-- Dependencies: 20251008090000_create_currency_enums.sql

-- ===========================================
-- TRADING FEE CHAINS SYSTEM
-- ===========================================

-- Trading Fee Chains Definitions
CREATE TABLE public.trading_fee_chains (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    name text NOT NULL UNIQUE,
    description text,
    chain_steps JSONB NOT NULL,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- Exchange Rates Table
CREATE TABLE public.exchange_rates (
    source_currency text NOT NULL,
    target_currency text NOT NULL,
    rate numeric NOT NULL CHECK (rate > 0),
    last_updated_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (source_currency, target_currency)
);

-- ===========================================
-- CORE FUNCTIONS FOR FEE CALCULATION
-- ===========================================

-- Function to calculate costs through a fee chain
CREATE OR REPLACE FUNCTION public.calculate_chain_costs(
    p_chain_id UUID,
    p_from_amount NUMERIC,
    p_from_currency TEXT,
    p_to_currency TEXT,
    p_exchange_rates JSONB DEFAULT '{}'
) RETURNS TABLE(
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
) AS $$
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
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to calculate simple profit/loss
CREATE OR REPLACE FUNCTION public.calculate_simple_profit_loss(
    p_purchase_amount NUMERIC,
    p_purchase_currency TEXT,
    p_sale_amount NUMERIC,
    p_sale_currency TEXT,
    p_chain_id UUID,
    p_exchange_rates JSONB DEFAULT '{}'
) RETURNS TABLE(
    purchase_amount NUMERIC,
    purchase_currency TEXT,
    sale_amount NUMERIC,
    sale_currency TEXT,
    total_fees NUMERIC,
    net_profit NUMERIC,
    profit_margin_percent NUMERIC
) AS $$
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
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ===========================================
-- INDEXES
-- ===========================================

CREATE INDEX idx_trading_fee_chains_active ON public.trading_fee_chains(is_active);
CREATE INDEX idx_exchange_rates_updated ON public.exchange_rates(last_updated_at);

-- ===========================================
-- SAMPLE DATA
-- ===========================================

-- Insert sample trading fee chains
INSERT INTO public.trading_fee_chains (name, description, chain_steps) VALUES
(
    'Facebook to G2G to Payoneer',
    'Mua từ Facebook, bán qua G2G, rút về Payoneer',
    '[
        {
            "step": 1,
            "from_currency": "VND",
            "to_currency": "USD",
            "fee_type": "SALE_FEE",
            "fee_percent": 5.0,
            "fee_fixed": 0,
            "fee_currency": "USD",
            "description": "G2G platform fee 5%"
        },
        {
            "step": 2,
            "from_currency": "USD",
            "to_currency": "USD",
            "fee_type": "WITHDRAWAL_FEE",
            "fee_percent": 1.0,
            "fee_fixed": 0,
            "fee_currency": "USD",
            "description": "G2G to Payoneer fee 1%"
        },
        {
            "step": 3,
            "from_currency": "USD",
            "to_currency": "VND",
            "fee_type": "CONVERSION_FEE",
            "fee_percent": 0,
            "fee_fixed": 0,
            "fee_currency": "USD",
            "description": "Payoneer to VND (thường miễn phí)"
        }
    ]'
),
(
    'Zalo to G2G to Payoneer',
    'Mua từ Zalo, bán qua G2G, rút về Payoneer',
    '[
        {
            "step": 1,
            "from_currency": "VND",
            "to_currency": "USD",
            "fee_type": "SALE_FEE",
            "fee_percent": 5.0,
            "fee_fixed": 0,
            "fee_currency": "USD",
            "description": "G2G platform fee 5%"
        },
        {
            "step": 2,
            "from_currency": "USD",
            "to_currency": "USD",
            "fee_type": "WITHDRAWAL_FEE",
            "fee_percent": 1.0,
            "fee_fixed": 0,
            "fee_currency": "USD",
            "description": "G2G to Payoneer fee 1%"
        },
        {
            "step": 3,
            "from_currency": "USD",
            "to_currency": "VND",
            "fee_type": "CONVERSION_FEE",
            "fee_percent": 0,
            "fee_fixed": 0,
            "fee_currency": "USD",
            "description": "Payoneer to VND"
        }
    ]'
),
(
    'Direct Customer to Bank',
    'Bán trực tiếp cho khách, nhận về ngân hàng Việt Nam',
    '[
        {
            "step": 1,
            "from_currency": "VND",
            "to_currency": "VND",
            "fee_type": "CONVERSION_FEE",
            "fee_percent": 0,
            "fee_fixed": 0,
            "fee_currency": "VND",
            "description": "Không phí, nhận thẳng VND"
        }
    ]'
),
(
    'PayPal to Bank',
    'Nhận qua PayPal, chuyển về bank Việt Nam',
    '[
        {
            "step": 1,
            "from_currency": "USD",
            "to_currency": "USD",
            "fee_type": "WITHDRAWAL_FEE",
            "fee_percent": 2.9,
            "fee_fixed": 0.30,
            "fee_currency": "USD",
            "description": "PayPal fee 2.9% + $0.30"
        },
        {
            "step": 2,
            "from_currency": "USD",
            "to_currency": "VND",
            "fee_type": "CONVERSION_FEE",
            "fee_percent": 2.5,
            "fee_fixed": 0,
            "fee_currency": "USD",
            "description": "PayPal to VND conversion fee 2.5%"
        }
    ]'
);

-- Insert sample exchange rates
INSERT INTO public.exchange_rates (source_currency, target_currency, rate) VALUES
('USD', 'VND', 25700),
('VND', 'USD', 0.00003891),
('EUR', 'USD', 1.08),
('USD', 'EUR', 0.93);

-- ===========================================
-- COMMENTS
-- ===========================================

COMMENT ON TABLE public.trading_fee_chains IS 'Định nghĩa chuỗi phí theo quy trình thực tế (VD: Facebook -> G2G -> Payoneer -> VND)';
COMMENT ON COLUMN public.trading_fee_chains.chain_steps IS 'JSON array chứa các bước tính phí, mỗi bước bao gồm thông tin chuyển đổi currency và phí';
COMMENT ON TABLE public.exchange_rates IS 'Lưu trữ tỷ giá thị trường được cập nhật tự động hoặc thủ công';
COMMENT ON COLUMN public.exchange_rates.rate IS 'Tỷ giá chuyển đổi: 1 source_currency = rate target_currency';

COMMENT ON FUNCTION public.calculate_chain_costs IS 'Tính toán chi phí qua từng bước trong chuỗi phí, trả về chi tiết cho mỗi bước';
COMMENT ON FUNCTION public.calculate_simple_profit_loss IS 'Tính toán lợi nhuận đơn giản cho một giao dịch mua-bán';