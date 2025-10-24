-- Add PURCHASE channels to the database
-- These channels represent where we buy currencies from

-- First, let's check what channels already exist
SELECT code, name, channel_type, is_active FROM public.channels;

-- Add PURCHASE channels
INSERT INTO public.channels (id, code, name, description, channel_type, is_active, created_at, updated_at) VALUES
('pur001', 'Discord_Farmers', 'Discord Farmers', 'Discord communities and farmer groups where we purchase currencies', 'PURCHASE', true, NOW(), NOW()),
('pur002', 'Facebook_Groups', 'Facebook Groups', 'Facebook groups and communities for currency purchases', 'PURCHASE', true, NOW(), NOW()),
('pur003', 'Direct_Farmers', 'Direct Farmers', 'Direct contracts with individual farmers', 'PURCHASE', true, NOW(), NOW()),
('pur004', 'Trading_Communities', 'Trading Communities', 'Various trading communities and forums', 'PURCHASE', true, NOW(), NOW()),
('pur005', 'In_Game_Trade', 'In-Game Trade', 'Direct in-game trading channels', 'PURCHASE', true, NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- Verify the channels were added
SELECT code, name, channel_type, is_active FROM public.channels ORDER BY channel_type, code;

-- Count channels by type
SELECT
    channel_type,
    COUNT(*) as channel_count,
    COUNT(*) FILTER (WHERE is_active = true) as active_count
FROM public.channels
GROUP BY channel_type;