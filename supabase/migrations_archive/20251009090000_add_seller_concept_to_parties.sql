-- Migration: Add Seller Concept to Parties Table
-- Version: 1.0
-- Date: 2025-10-09
-- Dependencies: 20251004011427_remote_schema.sql

-- ===========================================
-- ADD SELLER CONCEPT TO PARTIES TABLE
-- ===========================================

-- Add new columns to parties table
ALTER TABLE public.parties
ADD COLUMN IF NOT EXISTS contact_info JSONB DEFAULT '{}',
ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW(),
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- Update existing parties to have appropriate types first
UPDATE public.parties
SET type = 'CUSTOMER'
WHERE type IS NULL OR type NOT IN ('CUSTOMER', 'SELLER', 'PARTNER', 'SUPPLIER');

-- Add constraint for party types after data is cleaned
ALTER TABLE public.parties
ADD CONSTRAINT check_party_type
CHECK (type IN ('CUSTOMER', 'SELLER', 'PARTNER', 'SUPPLIER'));

-- Insert sample sellers
INSERT INTO public.parties (type, name, contact_info) VALUES
('SELLER', 'Wholesaler A', '{"contact": "Discord: wholesaler_a", "reliability": "high"}'),
('SELLER', 'Player B', '{"contact": "Game: PlayerB#1234", "reliability": "medium"}'),
('SELLER', 'Farm Team Alpha', '{"contact": "Telegram: @farmteam", "reliability": "high"}'),
('SELLER', 'Market Supplier', '{"contact": "WhatsApp: +84901234567", "reliability": "high"}')
ON CONFLICT (id) DO NOTHING;

-- Insert sample customers
INSERT INTO public.parties (type, name, contact_info) VALUES
('CUSTOMER', 'John Doe', '{"contact": "Discord: john_doe", "notes": "Regular customer"}'),
('CUSTOMER', 'Gamer123', '{"contact": "Game: Gamer123#5678", "notes": "Prefers POE1"}'),
('CUSTOMER', 'Mike Smith', '{"contact": "Telegram: @mike_smith", "notes": "Bulk buyer"}')
ON CONFLICT (id) DO NOTHING;

-- ===========================================
-- CREATE INDEXES FOR PERFORMANCE
-- ===========================================

CREATE INDEX IF NOT EXISTS idx_parties_type ON public.parties(type);
CREATE INDEX IF NOT EXISTS idx_parties_is_active ON public.parties(is_active);
CREATE INDEX IF NOT EXISTS idx_parties_name ON public.parties(name);

-- ===========================================
-- CREATE UPDATED AT TRIGGER
-- ===========================================

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_parties_updated_at
    BEFORE UPDATE ON public.parties
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

-- ===========================================
-- COMMENTS
-- ===========================================

COMMENT ON TABLE public.parties IS 'Parties involved in transactions (customers, sellers, partners, suppliers)';
COMMENT ON COLUMN public.parties.type IS 'Type of party: CUSTOMER, SELLER, PARTNER, or SUPPLIER';
COMMENT ON COLUMN public.parties.name IS 'Display name of the party';
COMMENT ON COLUMN public.parties.contact_info IS 'JSONB containing contact information, notes, and metadata';
COMMENT ON COLUMN public.parties.is_active IS 'Whether this party is still active for transactions';
COMMENT ON COLUMN public.parties.created_at IS 'When this party was first added';
COMMENT ON COLUMN public.parties.updated_at IS 'When this party was last updated';

-- ===========================================
-- STATISTICS UPDATE
-- ===========================================

ANALYZE public.parties;