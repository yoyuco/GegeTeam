-- ============================================================================
-- Add function to get all distinct filter options for Service Boosting page
-- ============================================================================
-- Date: 2025-10-03
-- Purpose: Return all possible filter values from the database, not just
--          from currently loaded records
-- ============================================================================

CREATE OR REPLACE FUNCTION "public"."get_boosting_filter_options"()
RETURNS TABLE(
  "channels" "text"[],
  "service_types" "text"[],
  "package_types" "text"[],
  "statuses" "text"[]
)
LANGUAGE "sql"
SECURITY DEFINER
SET search_path TO 'public'
AS $$
  WITH base_data AS (
    SELECT DISTINCT
      ch.code as channel_code,
      pv.display_name as service_type,
      o.package_type,
      o.status
    FROM public.order_lines ol
    JOIN public.orders o ON ol.order_id = o.id
    LEFT JOIN public.channels ch ON o.channel_id = ch.id
    LEFT JOIN public.product_variants pv ON ol.variant_id = pv.id
    WHERE o.game_code = 'DIABLO_4'
      AND o.status <> 'draft'
  )
  SELECT
    ARRAY_AGG(DISTINCT bd.channel_code ORDER BY bd.channel_code) FILTER (WHERE bd.channel_code IS NOT NULL) as channels,
    ARRAY_AGG(DISTINCT bd.service_type ORDER BY bd.service_type) FILTER (WHERE bd.service_type IS NOT NULL) as service_types,
    ARRAY_AGG(DISTINCT bd.package_type ORDER BY bd.package_type) FILTER (WHERE bd.package_type IS NOT NULL) as package_types,
    ARRAY_AGG(DISTINCT bd.status ORDER BY bd.status) FILTER (WHERE bd.status IS NOT NULL) as statuses
  FROM base_data bd;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION "public"."get_boosting_filter_options"() TO "authenticated";

-- Add comment for documentation
COMMENT ON FUNCTION "public"."get_boosting_filter_options"() IS
'Returns all distinct filter option values for the Service Boosting page. Used to populate filter dropdowns with all possible values from the database, not just from currently loaded records.';
