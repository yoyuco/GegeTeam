-- Migration: Add RPC Functions for Games and Roles
-- Version: 1.0
-- Date: 2025-10-09
-- Dependencies: 20251009070000_import_complete_attributes_from_csv.sql, 20251004011427_remote_schema.sql

-- ===========================================
-- GET GAMES FUNCTION
-- ===========================================

CREATE OR REPLACE FUNCTION public.get_games_v1()
RETURNS TABLE (
  id uuid,
  code text,
  name text,
  icon text,
  description text,
  sort_order integer,
  is_active boolean,
  currency_prefix text,
  league_prefix text
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    a.id,
    a.code,
    a.name,
    LOWER(REPLACE(a.code, '_', '-')) as icon, -- Generate icon from code
    a.name as description, -- Use name as description for now
    a.sort_order,
    a.is_active,
    CASE
      WHEN a.code = 'POE_1' THEN 'CURRENCY_POE1'
      WHEN a.code = 'POE_2' THEN 'CURRENCY_POE2'
      WHEN a.code = 'DIABLO_4' THEN 'CURRENCY_D4'
      ELSE 'CURRENCY_' || a.code
    END as currency_prefix,
    CASE
      WHEN a.code = 'POE_1' THEN 'LEAGUE_POE1'
      WHEN a.code = 'POE_2' THEN 'LEAGUE_POE2'
      WHEN a.code = 'DIABLO_4' THEN 'SEASON_D4'
      ELSE 'LEAGUE_' || a.code
    END as league_prefix
  FROM public.attributes a
  WHERE a.type = 'GAME'
    AND a.is_active = true
  ORDER BY a.sort_order, a.name;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ===========================================
-- GET GAME LEAGUES FUNCTION
-- ===========================================

CREATE OR REPLACE FUNCTION public.get_game_leagues_v1(p_game_code text)
RETURNS TABLE (
  id uuid,
  code text,
  name text,
  sort_order integer,
  is_active boolean
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    a.id,
    a.code,
    a.name,
    a.sort_order,
    a.is_active
  FROM public.attributes a
  JOIN public.attribute_relationships ar
    ON a.id = ar.child_attribute_id
  JOIN public.attributes game
    ON game.id = ar.parent_attribute_id
  WHERE game.code = p_game_code
    AND game.type = 'GAME'
    AND a.is_active = true
    AND (
      (p_game_code = 'POE_1' AND a.type = 'LEAGUE_POE1') OR
      (p_game_code = 'POE_2' AND a.type = 'LEAGUE_POE2') OR
      (p_game_code = 'DIABLO_4' AND a.type = 'SEASON_D4')
    )
  ORDER BY a.sort_order, a.name;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ===========================================
-- GET USER ROLES FUNCTION
-- ===========================================

CREATE OR REPLACE FUNCTION public.get_user_roles_v1(p_user_id uuid)
RETURNS TABLE (
  id uuid,
  code text,
  name text
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    r.id,
    r.code::text,
    r.name
  FROM public.roles r
  JOIN public.user_role_assignments ura ON r.id = ura.role_id
  WHERE ura.user_id = p_user_id
  ORDER BY r.code;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ===========================================
-- GET PRIMARY USER ROLE FUNCTION
-- ===========================================

CREATE OR REPLACE FUNCTION public.get_primary_user_role_v1(p_user_id uuid)
RETURNS TABLE (
  id uuid,
  code text,
  name text
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    r.id,
    r.code::text,
    r.name
  FROM public.roles r
  JOIN public.user_role_assignments ura ON r.id = ura.role_id
  WHERE ura.user_id = p_user_id
  ORDER BY r.code
  LIMIT 1;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ===========================================
-- GRANT PERMISSIONS
-- ===========================================

GRANT EXECUTE ON FUNCTION public.get_games_v1() TO anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.get_game_leagues_v1(text) TO anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.get_user_roles_v1(uuid) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.get_primary_user_role_v1(uuid) TO authenticated, service_role;

-- ===========================================
-- COMMENTS
-- ===========================================

COMMENT ON FUNCTION public.get_games_v1() IS 'Get all active games with currency and league prefixes';
COMMENT ON FUNCTION public.get_game_leagues_v1(text) IS 'Get active leagues for a specific game';
COMMENT ON FUNCTION public.get_user_roles_v1(uuid) IS 'Get all roles for a user';
COMMENT ON FUNCTION public.get_primary_user_role_v1(uuid) IS 'Get primary role for a user (lowest sort_order)';

-- ===========================================
-- STATISTICS UPDATE
-- ===========================================

ANALYZE public.attributes;
ANALYZE public.roles;
ANALYZE public.user_role_assignments;
ANALYZE public.attribute_relationships;