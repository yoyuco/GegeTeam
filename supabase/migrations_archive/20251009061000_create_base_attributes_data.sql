-- Migration: Create Base Attributes Data for Currency System
-- Version: 1.0
-- Date: 2025-10-09
-- Dependencies: 20251008090000_create_currency_enums.sql

-- ===========================================
-- INSERT BASE ATTRIBUTES DATA
-- ===========================================

-- Game Attributes
INSERT INTO public.attributes (code, name, type, sort_order, is_active) VALUES
('POE1', 'Path of Exile 1', 'GAME', 1, true),
('POE2', 'Path of Exile 2', 'GAME', 2, true),
('D4', 'Diablo 4', 'GAME', 3, true)
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    type = EXCLUDED.type,
    sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active;

-- POE1 League Attributes
INSERT INTO public.attributes (code, name, type, sort_order, is_active) VALUES
('STANDARD_STANDARD_POE1', 'Standard', 'LEAGUE_POE1', 1, true),
('HARDCORE_STANDARD_POE1', 'Hardcore', 'LEAGUE_POE1', 2, true),
('SSF_STANDARD_POE1', 'SSF Standard', 'LEAGUE_POE1', 3, true),
('SSF_HARDCORE_POE1', 'SSF Hardcore', 'LEAGUE_POE1', 4, true)
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    type = EXCLUDED.type,
    sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active;

-- POE2 EA League Attributes
INSERT INTO public.attributes (code, name, type, sort_order, is_active) VALUES
('STANDARD_EA_POE2', 'Standard EA', 'LEAGUE_POE2', 1, true),
('HARDCORE_EA_POE2', 'Hardcore EA', 'LEAGUE_POE2', 2, true)
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    type = EXCLUDED.type,
    sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active;

-- D4 Season 10 Attributes
INSERT INTO public.attributes (code, name, type, sort_order, is_active) VALUES
('SEASON_10_SOFTCORE_D4', 'Season 10 Softcore', 'LEAGUE_D4', 1, true),
('SEASON_10_HARDCORE_D4', 'Season 10 Hardcore', 'LEAGUE_D4', 2, true)
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    type = EXCLUDED.type,
    sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active;

-- Business Area Attributes
INSERT INTO public.attributes (code, name, type, sort_order, is_active) VALUES
('SERVICE', 'Service', 'BUSINESS_AREA', 1, true),
('CURRENCY', 'Currency', 'BUSINESS_AREA', 2, true)
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    type = EXCLUDED.type,
    sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active;

-- POE1 Currency Attributes
INSERT INTO public.attributes (code, name, type, sort_order, is_active) VALUES
('DIVINE_ORB_POE1', 'Divine Orb', 'CURRENCY_POE1', 1, true),
('CHAOS_ORB_POE1', 'Chaos Orb', 'CURRENCY_POE1', 2, true),
('EXALTED_ORB_POE1', 'Exalted Orb', 'CURRENCY_POE1', 3, true)
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    type = EXCLUDED.type,
    sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active;

-- POE2 Currency Attributes
INSERT INTO public.attributes (code, name, type, sort_order, is_active) VALUES
('DIVINE_ORB_POE2', 'Divine Orb', 'CURRENCY_POE2', 1, true),
('CHAOS_ORB_POE2', 'Chaos Orb', 'CURRENCY_POE2', 2, true),
('EXALTED_ORB_POE2', 'Exalted Orb', 'CURRENCY_POE2', 3, true)
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    type = EXCLUDED.type,
    sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active;

-- D4 Currency Attributes
INSERT INTO public.attributes (code, name, type, sort_order, is_active) VALUES
('GOLD_D4', 'Gold', 'CURRENCY_D4', 1, true)
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    type = EXCLUDED.type,
    sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active;

-- Role Attributes
INSERT INTO public.attributes (code, name, type, sort_order, is_active) VALUES
('admin', 'Administrator', 'ROLE', 1, true),
('manager', 'Manager', 'ROLE', 2, true),
('moderator', 'Moderator', 'ROLE', 3, true),
('staff', 'Staff', 'ROLE', 4, true)
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    type = EXCLUDED.type,
    sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active;

-- ===========================================
-- CREATE INDEXES FOR PERFORMANCE
-- ===========================================

CREATE INDEX IF NOT EXISTS idx_attributes_type ON public.attributes(type);
CREATE INDEX IF NOT EXISTS idx_attributes_code ON public.attributes(code);
CREATE INDEX IF NOT EXISTS idx_attributes_active ON public.attributes(is_active);

-- ===========================================
-- COMMENTS
-- ===========================================

COMMENT ON TABLE public.attributes IS 'Base attributes for currency system including games, leagues, currencies, and roles';
COMMENT ON COLUMN public.attributes.sort_order IS 'Order for displaying attributes in UI';
COMMENT ON COLUMN public.attributes.is_active IS 'Whether this attribute is currently active and selectable';