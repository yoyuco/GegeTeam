-- Migration: Import Attribute Relationships from CSV
-- Version: 1.0
-- Date: 2025-10-09
-- Dependencies: 20251009073000_add_attributes_from_csv.sql

-- ===========================================
-- CLEAN UP EXISTING RELATIONSHIPS
-- ===========================================

DELETE FROM public.attribute_relationships;

-- ===========================================
-- IMPORT ATTRIBUTE RELATIONSHIPS FROM CSV
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
    'ETERNAL_SOFTCORE_D4', 'ETERNAL_HARDCORE_D4',
    'SEASON_10_SOFTCORE_D4', 'SEASON_10_HARDCORE_D4'
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
-- CREATE INDEXES FOR PERFORMANCE
-- ===========================================

CREATE INDEX IF NOT EXISTS idx_attribute_relationships_parent ON public.attribute_relationships(parent_attribute_id);
CREATE INDEX IF NOT EXISTS idx_attribute_relationships_child ON public.attribute_relationships(child_attribute_id);
CREATE INDEX IF NOT EXISTS idx_attribute_relationships_parent_child ON public.attribute_relationships(parent_attribute_id, child_attribute_id);

-- ===========================================
-- COMMENTS
-- ===========================================

COMMENT ON TABLE public.attribute_relationships IS 'Hierarchical relationships between attributes (games, leagues, currencies)';
COMMENT ON COLUMN public.attribute_relationships.parent_attribute_id IS 'Parent attribute (e.g., Game)';
COMMENT ON COLUMN public.attribute_relationships.child_attribute_id IS 'Child attribute (e.g., League or Currency)';

-- ===========================================
-- STATISTICS UPDATE
-- ===========================================

ANALYZE public.attribute_relationships;