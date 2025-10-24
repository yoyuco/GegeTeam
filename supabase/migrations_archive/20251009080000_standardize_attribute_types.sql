-- Migration: Standardize Attribute Types - Consistent Naming Convention
-- Version: 1.0
-- Date: 2025-10-09
-- Dependencies: All previous currency migrations

-- ===========================================
-- STANDARDIZE ATTRIBUTE TYPES ACCORDING TO NEW RULE
-- Rule: [TYPE]_[GAME] where GAME always comes after underscore
-- ===========================================

-- Update attribute types to follow consistent naming convention
UPDATE public.attributes
SET type = 'CURRENCY_POE1'
WHERE type = 'POE1_CURRENCY';

UPDATE public.attributes
SET type = 'CURRENCY_POE2'
WHERE type = 'POE2_CURRENCY';

UPDATE public.attributes
SET type = 'SEASON_D4'
WHERE type = 'D4_SEASON';

-- League types are already correct: LEAGUE_POE1, LEAGUE_POE2
-- Game types are already correct: GAME
-- Business area types are already correct: BUSINESS_AREA
-- Role types are already correct: ROLE

-- ===========================================
-- UPDATE useGameContext MAPPINGS TO MATCH NEW TYPES
-- ===========================================

-- Note: After this migration, update useGameContext.js to use the new type prefixes:
-- POE1: currencyPrefix: 'CURRENCY_POE1', leaguePrefix: 'LEAGUE_POE1'
-- POE2: currencyPrefix: 'CURRENCY_POE2', leaguePrefix: 'LEAGUE_POE2'
-- D4: currencyPrefix: 'CURRENCY_D4', seasonPrefix: 'SEASON_D4'

-- ===========================================
-- CREATE INDEXES FOR NEW TYPE NAMES
-- ===========================================

CREATE INDEX IF NOT EXISTS idx_attributes_type_standardized ON public.attributes(type, code);
CREATE INDEX IF NOT EXISTS idx_currency_attributes_new ON public.attributes(type, code)
WHERE type IN ('CURRENCY_POE1', 'CURRENCY_POE2', 'CURRENCY_D4');
CREATE INDEX IF NOT EXISTS idx_league_season_attributes_new ON public.attributes(type, code)
WHERE type IN ('LEAGUE_POE1', 'LEAGUE_POE2', 'SEASON_D4');

-- ===========================================
-- UPDATE COMMENTS
-- ===========================================

COMMENT ON COLUMN public.attributes.type IS 'Type classification following convention [TYPE]_[GAME]: GAME, LEAGUE_POE1, LEAGUE_POE2, SEASON_D4, CURRENCY_POE1, CURRENCY_POE2, CURRENCY_D4, BUSINESS_AREA, ROLE';

-- ===========================================
-- STATISTICS UPDATE
-- ===========================================

ANALYZE public.attributes;