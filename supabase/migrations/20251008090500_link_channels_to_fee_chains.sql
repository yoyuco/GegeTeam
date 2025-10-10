-- Migration: Link Channels to Trading Fee Chains
-- Version: 1.0
-- Date: 2025-10-08
-- Description: Add trading_fee_chain_id to channels table and set up default associations

-- ===========================================
-- UPDATE CHANNELS TABLE
-- ===========================================

-- Add trading_fee_chain_id column to channels table
ALTER TABLE public.channels
ADD COLUMN trading_fee_chain_id UUID REFERENCES public.trading_fee_chains(id) ON DELETE SET NULL;

-- Add comment
COMMENT ON COLUMN public.channels.trading_fee_chain_id IS 'Liên kết đến chuỗi phí mặc định áp dụng cho kênh bán hàng này. Khi NULL, sẽ không tính phí cho kênh này.';

-- ===========================================
-- CREATE INDEXES
-- ===========================================

CREATE INDEX idx_channels_trading_fee_chain ON public.channels(trading_fee_chain_id);
CREATE INDEX idx_channels_fee_chain_active ON public.channels(trading_fee_chain_id) WHERE trading_fee_chain_id IS NOT NULL;

-- ===========================================
-- UPDATE EXISTING CHANNELS WITH DEFAULT FEE CHAINS
-- ===========================================

-- Note: channels table has 'code' field, not 'name'
-- We'll update based on channel codes

-- Update G2G channels to use G2G fee chain
UPDATE public.channels
SET trading_fee_chain_id = (
    SELECT id FROM public.trading_fee_chains
    WHERE name = 'Facebook to G2G to Payoneer'
    LIMIT 1
)
WHERE
    trading_fee_chain_id IS NULL
    AND (
        LOWER(code) LIKE '%g2g%'
        OR LOWER(code) LIKE '%game2g%'
    );

-- Update Direct/Bank channels to use direct fee chain
UPDATE public.channels
SET trading_fee_chain_id = (
    SELECT id FROM public.trading_fee_chains
    WHERE name = 'Direct Customer to Bank'
    LIMIT 1
)
WHERE
    trading_fee_chain_id IS NULL
    AND (
        LOWER(code) LIKE '%direct%'
        OR LOWER(code) LIKE '%bank%'
        OR LOWER(code) LIKE '%transfer%'
        OR LOWER(code) LIKE '%chuyenkhoan%'
    );

-- Update PayPal channels to use PayPal fee chain
UPDATE public.channels
SET trading_fee_chain_id = (
    SELECT id FROM public.trading_fee_chains
    WHERE name = 'PayPal to Bank'
    LIMIT 1
)
WHERE
    trading_fee_chain_id IS NULL
    AND LOWER(code) LIKE '%paypal%';

-- Update Zalo channels to use G2G fee chain (similar flow)
UPDATE public.channels
SET trading_fee_chain_id = (
    SELECT id FROM public.trading_fee_chains
    WHERE name = 'Facebook to G2G to Payoneer'
    LIMIT 1
)
WHERE
    trading_fee_chain_id IS NULL
    AND LOWER(code) LIKE '%zalo%';

-- ===========================================
-- CREATE FUNCTION TO GET FEE CHAIN FOR CHANNEL
-- ===========================================

-- Function to get the fee chain for a channel (with fallback)
CREATE OR REPLACE FUNCTION public.get_channel_fee_chain(p_channel_id UUID)
RETURNS TABLE(
    fee_chain_id UUID,
    fee_chain_name TEXT,
    fee_chain_description TEXT,
    chain_steps JSONB
) AS $$
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
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ===========================================
-- UPDATE PROFIT CALCULATION FUNCTION
-- ===========================================

-- Update the profit calculation to work with channel-based fee chains
CREATE OR REPLACE FUNCTION public.calculate_order_profit(p_order_line_id UUID)
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
    profit_margin_percent NUMERIC,
    calculation_details JSONB
) AS $$
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
            'VND' as purchase_currency, -- Assuming purchase is in VND
            COALESCE(v_order_line.sell_price_total, 0) as sale_amount,
            CASE
                WHEN v_order_line.sell_price_currency_code = 'USD' THEN 'USD'
                ELSE 'VND'
            END as sale_currency,
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
            'VND' as purchase_currency,
            COALESCE(v_order_line.sell_price_total, 0) as sale_amount,
            CASE
                WHEN v_order_line.sell_price_currency_code = 'USD' THEN 'USD'
                ELSE 'VND'
            END as sale_currency,
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
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ===========================================
-- CREATE SAMPLE CHANNELS IF THEY DON'T EXIST
-- ===========================================

-- Note: channels table only has 'id' and 'code' fields
-- We'll add sample channels with fee chain associations
INSERT INTO public.channels (code, trading_fee_chain_id) VALUES
('G2G', (SELECT id FROM public.trading_fee_chains WHERE name = 'Facebook to G2G to Payoneer' LIMIT 1)),
('DIRECT_BANK', (SELECT id FROM public.trading_fee_chains WHERE name = 'Direct Customer to Bank' LIMIT 1)),
('PAYPAL', (SELECT id FROM public.trading_fee_chains WHERE name = 'PayPal to Bank' LIMIT 1)),
('ZALO', (SELECT id FROM public.trading_fee_chains WHERE name = 'Facebook to G2G to Payoneer' LIMIT 1)),
('FACEBOOK', (SELECT id FROM public.trading_fee_chains WHERE name = 'Facebook to G2G to Payoneer' LIMIT 1))
ON CONFLICT (code) DO UPDATE SET
trading_fee_chain_id = EXCLUDED.trading_fee_chain_id;

-- ===========================================
-- GRANT PERMISSIONS
-- ===========================================

GRANT SELECT ON public.channels TO authenticated;
GRANT SELECT ON public.trading_fee_chains TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_channel_fee_chain TO authenticated;
GRANT EXECUTE ON FUNCTION public.calculate_order_profit TO authenticated;

-- ===========================================
-- COMMENTS
-- ===========================================

COMMENT ON FUNCTION public.get_channel_fee_chain IS 'Lấy chuỗi phí liên kết với một kênh bán hàng';
COMMENT ON FUNCTION public.calculate_order_profit IS 'Tính lợi nhuận cho một đơn hàng dựa trên chuỗi phí của kênh';