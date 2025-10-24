-- Add PURCHASE channels to the database (COMPATIBLE VERSION)
-- These channels represent where we buy currencies from
-- Modified to work with existing channels table structure (uses direction instead of channel_type)

-- First, let's check what channels already exist
SELECT code, name, direction, is_active FROM public.channels;

-- Add PURCHASE channels using existing table structure
INSERT INTO public.channels (
    id,
    code,
    name,
    description,
    direction,
    is_active,
    created_at,
    updated_at,
    -- Set default fee structure for purchase channels
    purchase_fee_rate,
    purchase_fee_fixed,
    purchase_fee_currency,
    sale_fee_rate,
    sale_fee_fixed,
    sale_fee_currency
) VALUES
('pur001', 'Discord_Farmers', 'Discord Farmers', 'Discord communities and farmer groups where we purchase currencies', 'BUY', true, NOW(), NOW(), 2.0, 0, 'VND', 0, 0, 'VND'),
('pur002', 'Facebook_Groups', 'Facebook Groups', 'Facebook groups and communities for currency purchases', 'BUY', true, NOW(), NOW(), 3.0, 0, 'VND', 0, 0, 'VND'),
('pur003', 'Direct_Farmers', 'Direct Farmers', 'Direct contracts with individual farmers', 'BUY', true, NOW(), NOW(), 1.5, 0, 'VND', 0, 0, 'VND'),
('pur004', 'Trading_Communities', 'Trading Communities', 'Various trading communities and forums', 'BUY', true, NOW(), NOW(), 2.5, 0, 'VND', 0, 0, 'VND'),
('pur005', 'In_Game_Trade', 'In-Game Trade', 'Direct in-game trading channels', 'BUY', true, NOW(), NOW(), 1.0, 0, 'VND', 0, 0, 'VND')
ON CONFLICT (id) DO NOTHING;

-- Add SELL channels for existing channels (update direction if needed)
UPDATE public.channels
SET direction = 'SELL',
    updated_at = NOW()
WHERE code IN ('Discord', 'Facebook', 'G2G', 'Eldorado', 'PlayerAuctions')
AND direction = 'BOTH';

-- Verify the channels were added and updated
SELECT
    code,
    name,
    direction,
    is_active,
    purchase_fee_rate,
    sale_fee_rate
FROM public.channels
ORDER BY direction, code;

-- Count channels by direction
SELECT
    direction,
    COUNT(*) as channel_count,
    COUNT(*) FILTER (WHERE is_active = true) as active_count,
    AVG(purchase_fee_rate) FILTER (WHERE direction = 'BUY') as avg_purchase_fee,
    AVG(sale_fee_rate) FILTER (WHERE direction = 'SELL') as avg_sale_fee
FROM public.channels
GROUP BY direction
ORDER BY direction;

-- Show current channel portfolio
SELECT
    'Channel Portfolio' as info,
    COUNT(*) FILTER (WHERE direction = 'BUY') as purchase_channels,
    COUNT(*) FILTER (WHERE direction = 'SELL') as sale_channels,
    COUNT(*) FILTER (WHERE direction = 'BOTH') as bidirectional_channels,
    COUNT(*) FILTER (WHERE is_active = true) as total_active_channels
FROM public.channels;