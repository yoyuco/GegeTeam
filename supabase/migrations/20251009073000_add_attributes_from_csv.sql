-- Migration: Add Complete Attributes from CSV
-- Version: 1.0
-- Date: 2025-10-09
-- Dependencies: All previous currency migrations

-- ===========================================
-- INSERT ATTRIBUTES FROM CSV
-- ===========================================

-- Game Attributes
INSERT INTO public.attributes (code, name, type, sort_order, is_active) VALUES
('POE_1', 'Path of Exile 1', 'GAME', 1, true),
('POE_2', 'Path of Exile 2', 'GAME', 2, true),
('DIABLO_4', 'Diablo 4', 'GAME', 3, true)
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    type = EXCLUDED.type,
    sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active;

-- POE1 League Attributes
INSERT INTO public.attributes (code, name, type, sort_order, is_active) VALUES
('STANDARD_STANDARD_POE1', 'Standard', 'LEAGUE_POE1', 1, true),
('HARDCORE_STANDARD_POE1', 'Hardcore', 'LEAGUE_POE1', 2, true),
('STANDARD_MERCENARIES_POE1', 'Mercenaries Standard', 'LEAGUE_POE1', 3, true),
('HARDCORE_MERCENARIES_POE1', 'Mercenaries Hardcore', 'LEAGUE_POE1', 4, true)
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    type = EXCLUDED.type,
    sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active;

-- POE2 League Attributes
INSERT INTO public.attributes (code, name, type, sort_order, is_active) VALUES
('STANDARD_EA_POE2', 'Early Access Standard', 'LEAGUE_POE2', 1, true),
('HARDCORE_EA_POE2', 'Early Access Hardcore', 'LEAGUE_POE2', 2, true),
('STANDARD_ROTA_POE2', 'Rise of the Abyssal Standard', 'LEAGUE_POE2', 3, true),
('HARDCORE_ROTA_POE2', 'Rise of the Abyssal Hardcore', 'LEAGUE_POE2', 4, true)
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    type = EXCLUDED.type,
    sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active;

-- D4 Season Attributes
INSERT INTO public.attributes (code, name, type, sort_order, is_active) VALUES
('ETERNAL_SOFTCORE_D4', 'Eternal Softcore', 'D4_SEASON', 1, true),
('ETERNAL_HARDCORE_D4', 'Eternal Hardcore', 'D4_SEASON', 2, true),
('SEASON_10_SOFTCORE_D4', 'Season 10 Softcore', 'D4_SEASON', 3, true),
('SEASON_10_HARDCORE_D4', 'Season 10 Hardcore', 'D4_SEASON', 4, true)
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    type = EXCLUDED.type,
    sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active;

-- POE1 Currency Attributes (58 types)
INSERT INTO public.attributes (code, name, type, sort_order, is_active) VALUES
('DIVINE_ORB_POE1', 'Divine Orb', 'POE1_CURRENCY', 1, true),
('EXALTED_ORB_POE1', 'Exalted Orb', 'POE1_CURRENCY', 2, true),
('CHAOS_ORB_POE1', 'Chaos Orb', 'POE1_CURRENCY', 3, true),
('ORB_OF_FUSING_POE1', 'Orb of Fusing', 'POE1_CURRENCY', 4, true),
('MIRROR_OF_KALANDRA_POE1', 'Mirror of Kalandra', 'POE1_CURRENCY', 5, true),
('ANCIENT_ORB_POE1', 'Ancient Orb', 'POE1_CURRENCY', 6, true),
('ARMOURERS_SCRAP_POE1', 'Armourer''s Scrap', 'POE1_CURRENCY', 7, true),
('AWAKENED_SEXTANT_POE1', 'Awakened Sextant', 'POE1_CURRENCY', 8, true),
('AWAKENERS_ORB_POE1', 'Awakener''s Orb', 'POE1_CURRENCY', 9, true),
('BLACKSMITHS_WHETSTONE_POE1', 'Blacksmith''s Whetstone', 'POE1_CURRENCY', 10, true),
('BLESSED_ORB_POE1', 'Blessed Orb', 'POE1_CURRENCY', 11, true),
('CARTOGRAPHERS_CHISEL_POE1', 'Cartographer''s Chisel', 'POE1_CURRENCY', 12, true),
('CHROMATIC_ORB_POE1', 'Chromatic Orb', 'POE1_CURRENCY', 13, true),
('CRUSADERS_EXALTED_ORB_POE1', 'Crusader''s Exalted Orb', 'POE1_CURRENCY', 14, true),
('ELEVATED_SEXTANT_POE1', 'Elevated Sextant', 'POE1_CURRENCY', 15, true),
('GEMCUTTERS_PRISM_POE1', 'Gemcutter''s Prism', 'POE1_CURRENCY', 16, true),
('GLASSBLOWERS_BAUBLE_POE1', 'Glassblower''s Bauble', 'POE1_CURRENCY', 17, true),
('HINEKORAS_LOCK_POE1', 'Hinekora''s Lock', 'POE1_CURRENCY', 18, true),
('HUNTERS_EXALTED_ORB_POE1', 'Hunter''s Exalted Orb', 'POE1_CURRENCY', 19, true),
('JEWELLERS_ORB_POE1', 'Jeweller''s Orb', 'POE1_CURRENCY', 20, true),
('ORB_OF_ALCHEMY_POE1', 'Orb of Alchemy', 'POE1_CURRENCY', 21, true),
('ORB_OF_ALTERATION_POE1', 'Orb of Alteration', 'POE1_CURRENCY', 22, true),
('ORB_OF_ANNULMENT_POE1', 'Orb of Annulment', 'POE1_CURRENCY', 23, true),
('ORB_OF_AUGMENTATION_POE1', 'Orb of Augmentation', 'POE1_CURRENCY', 24, true),
('ORB_OF_CHANCE_POE1', 'Orb of Chance', 'POE1_CURRENCY', 25, true),
('ORB_OF_CONFLICT_POE1', 'Orb of Conflict', 'POE1_CURRENCY', 26, true),
('ORB_OF_DOMINANCE_POE1', 'Orb of Dominance', 'POE1_CURRENCY', 27, true),
('ORB_OF_REGRET_POE1', 'Orb of Regret', 'POE1_CURRENCY', 28, true),
('ORB_OF_SCOURING_POE1', 'Orb of Scouring', 'POE1_CURRENCY', 29, true),
('ORB_OF_TRANSMUTATION_POE1', 'Orb of Transmutation', 'POE1_CURRENCY', 30, true),
('ORB_OF_UNMAKING_POE1', 'Orb of Unmaking', 'POE1_CURRENCY', 31, true),
('ORB_OF_REMEMBRANCE_POE1', 'Orb of Remembrance', 'POE1_CURRENCY', 32, true),
('ORB_OF_UNRAVELLING_POE1', 'Orb of Unravelling', 'POE1_CURRENCY', 33, true),
('ORB_OF_INTENTION_POE1', 'Orb of Intention', 'POE1_CURRENCY', 34, true),
('PORTAL_SCROLL_POE1', 'Portal Scroll', 'POE1_CURRENCY', 35, true),
('REDEEMERS_EXALTED_ORB_POE1', 'Redeemer''s Exalted Orb', 'POE1_CURRENCY', 36, true),
('REGAL_ORB_POE1', 'Regal Orb', 'POE1_CURRENCY', 37, true),
('SCROLL_OF_WISDOM_POE1', 'Scroll of Wisdom', 'POE1_CURRENCY', 38, true),
('STACKED_DECK_POE1', 'Stacked Deck', 'POE1_CURRENCY', 39, true),
('TAILORING_ORB_POE1', 'Tailoring Orb', 'POE1_CURRENCY', 40, true),
('TEMPERING_ORB_POE1', 'Tempering Orb', 'POE1_CURRENCY', 41, true),
('VAAL_ORB_POE1', 'Vaal Orb', 'POE1_CURRENCY', 42, true),
('VEILED_CHAOS_ORB_POE1', 'Veiled Chaos Orb', 'POE1_CURRENCY', 43, true),
('WARLORDS_EXALTED_ORB_POE1', 'Warlord''s Exalted Orb', 'POE1_CURRENCY', 44, true),
('SHAPERS_EXALTED_ORB_POE1', 'Shaper''s Exalted Orb', 'POE1_CURRENCY', 45, true),
('ELDERS_EXALTED_ORB_POE1', 'Elder''s Exalted Orb', 'POE1_CURRENCY', 46, true),
('LESSER_ELDRITCH_ICHOR_POE1', 'Lesser Eldritch Ichor', 'POE1_CURRENCY', 47, true),
('GREATER_ELDRITCH_ICHOR_POE1', 'Greater Eldritch Ichor', 'POE1_CURRENCY', 48, true),
('GRAND_ELDRITCH_ICHOR_POE1', 'Grand Eldritch Ichor', 'POE1_CURRENCY', 49, true),
('EXCEPTIONAL_ELDRITCH_ICHOR_POE1', 'Exceptional Eldritch Ichor', 'POE1_CURRENCY', 50, true),
('LESSER_ELDRITCH_EMBER_POE1', 'Lesser Eldritch Ember', 'POE1_CURRENCY', 51, true),
('GREATER_ELDRITCH_EMBER_POE1', 'Greater Eldritch Ember', 'POE1_CURRENCY', 52, true),
('GRAND_ELDRITCH_EMBER_POE1', 'Grand Eldritch Ember', 'POE1_CURRENCY', 53, true),
('EXCEPTIONAL_ELDRITCH_EMBER_POE1', 'Exceptional Eldritch Ember', 'POE1_CURRENCY', 54, true),
('WILD_CRYSTALLISED_LIFEFORCE_POE1', 'Wild Crystallised Lifeforce', 'POE1_CURRENCY', 55, true),
('VIVID_CRYSTALLISED_LIFEFORCE_POE1', 'Vivid Crystallised Lifeforce', 'POE1_CURRENCY', 56, true),
('PRIMAL_CRYSTALLISED_LIFEFORCE_POE1', 'Primal Crystallised Lifeforce', 'POE1_CURRENCY', 57, true),
('SACRED_CRYSTALLISED_LIFEFORCE_POE1', 'Sacred Crystallised Lifeforce', 'POE1_CURRENCY', 58, true)
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    type = EXCLUDED.type,
    sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active;

-- POE2 Currency Attributes (50 types)
INSERT INTO public.attributes (code, name, type, sort_order, is_active) VALUES
('DIVINE_ORB_POE2', 'Divine Orb', 'POE2_CURRENCY', 1, true),
('EXALTED_ORB_POE2', 'Exalted Orb', 'POE2_CURRENCY', 2, true),
('CHAOS_ORB_POE2', 'Chaos Orb', 'POE2_CURRENCY', 3, true),
('MIRROR_OF_KALANDRA_POE2', 'Mirror of Kalandra', 'POE2_CURRENCY', 4, true),
('ANCIENT_ORB_POE2', 'Ancient Orb', 'POE2_CURRENCY', 5, true),
('ARCANISTS_ETCHE_POE2', 'Arcanist''s Etche', 'POE2_CURRENCY', 6, true),
('ARMOURERS_SCRAP_POE2', 'Armourer''s Scrap', 'POE2_CURRENCY', 7, true),
('ARTIFICERS_ORB_POE2', 'Artificer''s Orb', 'POE2_CURRENCY', 8, true),
('AWAKENED_SEXTANT_POE2', 'Awakened Sextant', 'POE2_CURRENCY', 9, true),
('AWAKENERS_ORB_POE2', 'Awakener''s Orb', 'POE2_CURRENCY', 10, true),
('BLACKSMITHS_WHETSTONE_POE2', 'Blacksmith''s Whetstone', 'POE2_CURRENCY', 11, true),
('BLESSED_ORB_POE2', 'Blessed Orb', 'POE2_CURRENCY', 12, true),
('CARTOGRAPHERS_CHISEL_POE2', 'Cartographer''s Chisel', 'POE2_CURRENCY', 13, true),
('CRUSADERS_EXALTED_ORB_POE2', 'Crusader''s Exalted Orb', 'POE2_CURRENCY', 14, true),
('ELEVATED_SEXTANT_POE2', 'Elevated Sextant', 'POE2_CURRENCY', 15, true),
('FRACTURING_ORB_POE2', 'Fracturing Orb', 'POE2_CURRENCY', 16, true),
('GEMCUTTERS_PRISM_POE2', 'Gemcutter''s Prism', 'POE2_CURRENCY', 17, true),
('GLASSBLOWERS_BAUBLE_POE2', 'Glassblower''s Bauble', 'POE2_CURRENCY', 18, true),
('HUNTERS_EXALTED_ORB_POE2', 'Hunter''s Exalted Orb', 'POE2_CURRENCY', 19, true),
('ORB_OF_ALCHEMY_POE2', 'Orb of Alchemy', 'POE2_CURRENCY', 20, true),
('ORB_OF_ANNULMENT_POE2', 'Orb of Annulment', 'POE2_CURRENCY', 21, true),
('ORB_OF_AUGMENTATION_POE2', 'Orb of Augmentation', 'POE2_CURRENCY', 22, true),
('ORB_OF_CHANCE_POE2', 'Orb of Chance', 'POE2_CURRENCY', 23, true),
('ORB_OF_CONFLICT_POE2', 'Orb of Conflict', 'POE2_CURRENCY', 24, true),
('ORB_OF_TRANSMUTATION_POE2', 'Orb of Transmutation', 'POE2_CURRENCY', 25, true),
('PORTAL_SCROLL_POE2', 'Portal Scroll', 'POE2_CURRENCY', 26, true),
('REDEEMERS_EXALTED_ORB_POE2', 'Redeemer''s Exalted Orb', 'POE2_CURRENCY', 27, true),
('REGAL_ORB_POE2', 'Regal Orb', 'POE2_CURRENCY', 28, true),
('SCROLL_OF_WISDOM_POE2', 'Scroll of Wisdom', 'POE2_CURRENCY', 29, true),
('STACKED_DECK_POE2', 'Stacked Deck', 'POE2_CURRENCY', 30, true),
('TAILORING_ORB_POE2', 'Tailoring Orb', 'POE2_CURRENCY', 31, true),
('TEMPERING_ORB_POE2', 'Tempering Orb', 'POE2_CURRENCY', 32, true),
('VAAL_ORB_POE2', 'Vaal Orb', 'POE2_CURRENCY', 33, true),
('VEILED_CHAOS_ORB_POE2', 'Veiled Chaos Orb', 'POE2_CURRENCY', 34, true),
('WARLORDS_EXALTED_ORB_POE2', 'Warlord''s Exalted Orb', 'POE2_CURRENCY', 35, true),
('LESSER_ELDRITCH_ICHOR_POE2', 'Lesser Eldritch Ichor', 'POE2_CURRENCY', 36, true),
('GREATER_ELDRITCH_ICHOR_POE2', 'Greater Eldritch Ichor', 'POE2_CURRENCY', 37, true),
('GRAND_ELDRITCH_ICHOR_POE2', 'Grand Eldritch Ichor', 'POE2_CURRENCY', 38, true),
('EXCEPTIONAL_ELDRITCH_ICHOR_POE2', 'Exceptional Eldritch Ichor', 'POE2_CURRENCY', 39, true),
('LESSER_ELDRITCH_EMBER_POE2', 'Lesser Eldritch Ember', 'POE2_CURRENCY', 40, true),
('GREATER_ELDRITCH_EMBER_POE2', 'Greater Eldritch Ember', 'POE2_CURRENCY', 41, true),
('GRAND_ELDRITCH_EMBER_POE2', 'Grand Eldritch Ember', 'POE2_CURRENCY', 42, true),
('EXCEPTIONAL_ELDRITCH_EMBER_POE2', 'Exceptional Eldritch Ember', 'POE2_CURRENCY', 43, true),
('WILD_CRYSTALLISED_LIFEFORCE_POE2', 'Wild Crystallised Lifeforce', 'POE2_CURRENCY', 44, true),
('VIVID_CRYSTALLISED_LIFEFORCE_POE2', 'Vivid Crystallised Lifeforce', 'POE2_CURRENCY', 45, true),
('PRIMAL_CRYSTALLISED_LIFEFORCE_POE2', 'Primal Crystallised Lifeforce', 'POE2_CURRENCY', 46, true),
('SACRED_CRYSTALLISED_LIFEFORCE_POE2', 'Sacred Crystallised Lifeforce', 'POE2_CURRENCY', 47, true),
('LESSER_JEWELLERS_ORB_POE2', 'Lesser Jeweller''s Orb', 'POE2_CURRENCY', 48, true),
('GREATER_JEWELLERS_ORB_POE2', 'Greater Jeweller''s Orb', 'POE2_CURRENCY', 49, true),
('PERFECT_JEWELLERS_ORB_POE2', 'Perfect Jeweller''s Orb', 'POE2_CURRENCY', 50, true)
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    type = EXCLUDED.type,
    sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active;

-- D4 Currency Attribute (1 type)
INSERT INTO public.attributes (code, name, type, sort_order, is_active) VALUES
('GOLD_D4', 'Gold', 'D4_CURRENCY', 1, true)
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    type = EXCLUDED.type,
    sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active;

-- ===========================================
-- UPDATE BUSINESS AREA ATTRIBUTES
-- ===========================================

-- Update existing business area attributes with better names
INSERT INTO public.attributes (code, name, type, sort_order, is_active) VALUES
('SERVICE', 'Service Operations', 'BUSINESS_AREA', 1, true),
('CURRENCY', 'Currency Operations', 'BUSINESS_AREA', 2, true)
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    type = EXCLUDED.type,
    sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active;

-- ===========================================
-- CREATE INDEXES FOR PERFORMANCE
-- ===========================================

CREATE INDEX IF NOT EXISTS idx_attributes_type_code ON public.attributes(type, code);
CREATE INDEX IF NOT EXISTS idx_attributes_is_active ON public.attributes(is_active);
CREATE INDEX IF NOT EXISTS idx_attributes_sort_order ON public.attributes(sort_order);

-- ===========================================
-- CREATE COMPOSITE INDEXES FOR RELATIONSHIPS
-- ===========================================

CREATE INDEX IF NOT EXISTS idx_attributes_game_league ON public.attributes(type, code)
WHERE type LIKE '%LEAGUE%';

CREATE INDEX IF NOT EXISTS idx_attributes_currency_game ON public.attributes(type, code)
WHERE type LIKE '%CURRENCY%';

-- ===========================================
-- COMMENTS
-- ===========================================

COMMENT ON TABLE public.attributes IS 'Master attributes table for games, leagues, currencies and business areas';
COMMENT ON COLUMN public.attributes.type IS 'Type classification: GAME, LEAGUE_POE1, LEAGUE_POE2, LEAGUE_D4, POE1_CURRENCY, POE2_CURRENCY, D4_CURRENCY, BUSINESS_AREA, ROLE';
COMMENT ON COLUMN public.attributes.sort_order IS 'Display order for UI elements';
COMMENT ON COLUMN public.attributes.is_active IS 'Whether this attribute is currently active and selectable';

-- ===========================================
-- STATISTICS UPDATE
-- ===========================================

ANALYZE public.attributes;