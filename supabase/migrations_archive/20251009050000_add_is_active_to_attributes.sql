-- Migration: Add is_active column to attributes table
-- Version: 1.0
-- Date: 2025-10-09
-- Dependencies: All previous migrations

-- ===========================================
-- ADD IS_ACTIVE COLUMN TO ATTRIBUTES
-- ===========================================

-- Add is_active column to attributes table
ALTER TABLE public.attributes
ADD COLUMN IF NOT EXISTS is_active boolean NOT NULL DEFAULT true;

-- Add index for performance
CREATE INDEX IF NOT EXISTS idx_attributes_is_active ON public.attributes(is_active);

-- Add comment
COMMENT ON COLUMN public.attributes.is_active IS 'Whether this attribute is active and available for use';

-- Set all existing attributes as active
UPDATE public.attributes SET is_active = true WHERE is_active IS NULL;

-- ===========================================
-- ADD SORT_ORDER COLUMN TO ATTRIBUTES
-- ===========================================

-- Add sort_order column for ordering attributes
ALTER TABLE public.attributes
ADD COLUMN IF NOT EXISTS sort_order integer NOT NULL DEFAULT 0;

-- Add index for sorting
CREATE INDEX IF NOT EXISTS idx_attributes_sort_order ON public.attributes(sort_order);

-- Add comment
COMMENT ON COLUMN public.attributes.sort_order IS 'Display order for attributes (lower numbers appear first)';

-- Set default sort order based on type and name
UPDATE public.attributes SET sort_order =
CASE
    WHEN type = 'POE1_LEAGUE' THEN 100
    WHEN type = 'POE2_LEAGUE' THEN 200
    WHEN type = 'D4_SEASON' THEN 300
    WHEN type = 'POE1_CURRENCY' THEN 1000
    WHEN type = 'POE2_CURRENCY' THEN 2000
    WHEN type = 'D4_CURRENCY' THEN 3000
    WHEN type = 'BUSINESS_AREA' THEN 5000
    ELSE 9999
END
WHERE sort_order = 0;

-- ===========================================
-- ADD DESCRIPTION COLUMN TO ATTRIBUTES
-- ===========================================

-- Add description column
ALTER TABLE public.attributes
ADD COLUMN IF NOT EXISTS description text;

-- Add comment
COMMENT ON COLUMN public.attributes.description IS 'Optional description for the attribute';

-- ===========================================
-- ADD IS_ACTIVE COLUMN TO ROLES
-- ===========================================

-- Add is_active column to roles table if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'roles' AND column_name = 'is_active'
    ) THEN
        ALTER TABLE public.roles ADD COLUMN is_active boolean NOT NULL DEFAULT true;
        CREATE INDEX idx_roles_is_active ON public.roles(is_active);
        COMMENT ON COLUMN public.roles.is_active IS 'Whether this role is active and available for use';
    END IF;
END $$;

-- Add description column to roles table if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'roles' AND column_name = 'description'
    ) THEN
        ALTER TABLE public.roles ADD COLUMN description text;
        COMMENT ON COLUMN public.roles.description IS 'Optional description for the role';
    END IF;
END $$;

-- Add sort_order column to roles table if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'roles' AND column_name = 'sort_order'
    ) THEN
        ALTER TABLE public.roles ADD COLUMN sort_order integer NOT NULL DEFAULT 0;
        CREATE INDEX idx_roles_sort_order ON public.roles(sort_order);
        COMMENT ON COLUMN public.roles.sort_order IS 'Display order for roles (lower numbers appear first)';
    END IF;
END $$;

-- ===========================================
-- ADD IS_ACTIVE COLUMN TO TRADING_FEE_CHAINS
-- ===========================================

-- Add is_active column to trading_fee_chains table if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'trading_fee_chains' AND column_name = 'is_active'
    ) THEN
        ALTER TABLE public.trading_fee_chains ADD COLUMN is_active boolean NOT NULL DEFAULT true;
        CREATE INDEX idx_trading_fee_chains_is_active ON public.trading_fee_chains(is_active);
        COMMENT ON COLUMN public.trading_fee_chains.is_active IS 'Whether this trading fee chain is active and available for use';
    END IF;
END $$;

-- ===========================================
-- UPDATE EXISTING DATA
-- ===========================================

-- Set all existing roles and fee chains as active
UPDATE public.roles SET is_active = true WHERE is_active IS NULL;
UPDATE public.trading_fee_chains SET is_active = true WHERE is_active IS NULL;

-- ===========================================
-- COMMENTS
-- ===========================================

-- This migration adds standard management columns (is_active, sort_order, description)
-- to the attributes table and other related tables for better control over
-- which items are displayed and in what order