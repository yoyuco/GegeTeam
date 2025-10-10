-- Migration: Enhance Channels Table for Currency Operations
-- Version: 1.0
-- Date: 2025-10-09
-- Dependencies: 20251004011427_remote_schema.sql, 20251008090500_link_channels_to_fee_chains.sql

-- ===========================================
-- ADD COLUMNS TO CHANNELS TABLE
-- ===========================================

-- Add additional columns to channels table
ALTER TABLE public.channels
ADD COLUMN IF NOT EXISTS name TEXT NOT NULL DEFAULT '',
ADD COLUMN IF NOT EXISTS description TEXT,
ADD COLUMN IF NOT EXISTS channel_type TEXT DEFAULT 'SALES',
ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW(),
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- Update name field for existing channels
UPDATE public.channels
SET name = CASE
    WHEN code = 'DIRECT' THEN 'Direct Bank Transfer'
    WHEN code = 'G2G' THEN 'G2G Marketplace'
    WHEN code = 'PAYPAL' THEN 'PayPal'
    WHEN code = 'FACEBOOK' THEN 'Facebook Groups'
    WHEN code = 'DISCORD' THEN 'Discord Communities'
    ELSE code
END,
channel_type = CASE
    WHEN code IN ('DIRECT', 'BANK') THEN 'DIRECT'
    WHEN code IN ('G2G', 'PAYPAL') THEN 'MARKETPLACE'
    WHEN code IN ('FACEBOOK', 'DISCORD') THEN 'SOCIAL'
    ELSE 'SALES'
END;

-- Insert sample channels if they don't exist
INSERT INTO public.channels (code, name, description, channel_type) VALUES
('DIRECT', 'Direct Bank Transfer', 'Direct customer to bank transactions', 'DIRECT'),
('G2G', 'G2G Marketplace', 'G2G gaming marketplace platform', 'MARKETPLACE'),
('PAYPAL', 'PayPal', 'PayPal payment processing', 'MARKETPLACE'),
('FACEBOOK', 'Facebook Groups', 'Facebook gaming groups and communities', 'SOCIAL'),
('DISCORD', 'Discord Communities', 'Discord trading communities', 'SOCIAL'),
('WHOLESALE', 'Wholesale Suppliers', 'Bulk wholesale suppliers', 'PURCHASE'),
('FARM_TEAM', 'Farm Teams', 'Internal farm teams', 'PURCHASE')
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    channel_type = EXCLUDED.channel_type;

-- Add constraint for channel types after data is cleaned
ALTER TABLE public.channels
ADD CONSTRAINT check_channel_type
CHECK (channel_type IN ('DIRECT', 'MARKETPLACE', 'SOCIAL', 'SALES', 'PURCHASE'));

-- ===========================================
-- CREATE INDEXES FOR PERFORMANCE
-- ===========================================

CREATE INDEX IF NOT EXISTS idx_channels_code ON public.channels(code);
CREATE INDEX IF NOT EXISTS idx_channels_name ON public.channels(name);
CREATE INDEX IF NOT EXISTS idx_channels_type ON public.channels(channel_type);
CREATE INDEX IF NOT EXISTS idx_channels_is_active ON public.channels(is_active);

-- ===========================================
-- CREATE UPDATED AT TRIGGER
-- ===========================================

CREATE TRIGGER update_channels_updated_at
    BEFORE UPDATE ON public.channels
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

-- ===========================================
-- COMMENTS
-- ===========================================

COMMENT ON TABLE public.channels IS 'Sales and purchase channels for currency transactions';
COMMENT ON COLUMN public.channels.code IS 'Unique channel identifier code';
COMMENT ON COLUMN public.channels.name IS 'Display name of the channel';
COMMENT ON COLUMN public.channels.description IS 'Description of what this channel is used for';
COMMENT ON COLUMN public.channels.channel_type IS 'Type of channel: DIRECT, MARKETPLACE, SOCIAL, SALES, or PURCHASE';
COMMENT ON COLUMN public.channels.is_active IS 'Whether this channel is still active for transactions';
COMMENT ON COLUMN public.channels.trading_fee_chain_id IS 'Associated fee chain for this channel (linked in previous migration)';

-- ===========================================
-- STATISTICS UPDATE
-- ===========================================

ANALYZE public.channels;