-- Migration: Refresh Attribute Relationships with Standardized Types
-- Version: 1.0
-- Date: 2025-10-09
-- Dependencies: 20251009080000_standardize_attribute_types.sql

-- ===========================================
-- CLEAN UP EXISTING RELATIONSHIPS
-- ===========================================

DELETE FROM public.attribute_relationships;

-- ===========================================
-- IMPORT ATTRIBUTE RELATIONSHIPS WITH CORRECT TYPES
-- ===========================================

-- POE1 Game -> League Relationships
INSERT INTO public.attribute_relationships (parent_attribute_id, child_attribute_id)
SELECT
  parent.id as parent_attribute_id,
  child.id as child_attribute_id
FROM public.attributes parent
JOIN public.attributes child ON (
  parent.code = 'POE_1' AND parent.type = 'GAME' AND
  child.code IN (
    'STANDARD_STANDARD_POE1', 'HARDCORE_STANDARD_POE1',
    'STANDARD_MERCENARIES_POE1', 'HARDCORE_MERCENARIES_POE1'
  ) AND child.type = 'LEAGUE_POE1'
)
ON CONFLICT (parent_attribute_id, child_attribute_id) DO NOTHING;

-- POE2 Game -> League Relationships
INSERT INTO public.attribute_relationships (parent_attribute_id, child_attribute_id)
SELECT
  parent.id as parent_attribute_id,
  child.id as child_attribute_id
FROM public.attributes parent
JOIN public.attributes child ON (
  parent.code = 'POE_2' AND parent.type = 'GAME' AND
  child.code IN (
    'STANDARD_EA_POE2', 'HARDCORE_EA_POE2',
    'STANDARD_ROTA_POE2', 'HARDCORE_ROTA_POE2'
  ) AND child.type = 'LEAGUE_POE2'
)
ON CONFLICT (parent_attribute_id, child_attribute_id) DO NOTHING;

-- D4 Game -> Season Relationships
INSERT INTO public.attribute_relationships (parent_attribute_id, child_attribute_id)
SELECT
  parent.id as parent_attribute_id,
  child.id as child_attribute_id
FROM public.attributes parent
JOIN public.attributes child ON (
  parent.code = 'DIABLO_4' AND parent.type = 'GAME' AND
  child.code IN (
    'SOFTCORE_ETERNAL_D4', 'HARDCORE_ETERNAL_D4',
    'SOFTCORE_SEASON_10_D4', 'HARDCORE_SEASON_10_D4'
  ) AND child.type = 'SEASON_D4'
)
ON CONFLICT (parent_attribute_id, child_attribute_id) DO NOTHING;

-- POE1 Game -> Currency Relationships
INSERT INTO public.attribute_relationships (parent_attribute_id, child_attribute_id)
SELECT
  parent.id as parent_attribute_id,
  child.id as child_attribute_id
FROM public.attributes parent
JOIN public.attributes child ON (
  parent.code = 'POE_1' AND parent.type = 'GAME' AND
  child.type = 'CURRENCY_POE1'
)
ON CONFLICT (parent_attribute_id, child_attribute_id) DO NOTHING;

-- POE2 Game -> Currency Relationships
INSERT INTO public.attribute_relationships (parent_attribute_id, child_attribute_id)
SELECT
  parent.id as parent_attribute_id,
  child.id as child_attribute_id
FROM public.attributes parent
JOIN public.attributes child ON (
  parent.code = 'POE_2' AND parent.type = 'GAME' AND
  child.type = 'CURRENCY_POE2'
)
ON CONFLICT (parent_attribute_id, child_attribute_id) DO NOTHING;

-- D4 Game -> Currency Relationships
INSERT INTO public.attribute_relationships (parent_attribute_id, child_attribute_id)
SELECT
  parent.id as parent_attribute_id,
  child.id as child_attribute_id
FROM public.attributes parent
JOIN public.attributes child ON (
  parent.code = 'DIABLO_4' AND parent.type = 'GAME' AND
  child.type = 'CURRENCY_D4'
)
ON CONFLICT (parent_attribute_id, child_attribute_id) DO NOTHING;

-- ===========================================
-- STATISTICS UPDATE
-- ===========================================

ANALYZE public.attribute_relationships;