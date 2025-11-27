-- Create RPC function to get user role assignments with role names
CREATE OR REPLACE FUNCTION get_user_role_assignments_with_roles()
RETURNS TABLE (
  id UUID,
  user_id UUID,
  role_id UUID,
  role_name TEXT,
  game_name TEXT,
  business_area_name TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    ura.id,
    ura.user_id,
    ura.role_id,
    r.name as role_name,
    g.name as game_name,
    ba.name as business_area_name
  FROM public.user_role_assignments ura
  JOIN public.roles r ON ura.role_id = r.id
  LEFT JOIN public.attributes g ON ura.game_attribute_id = g.id
  LEFT JOIN public.attributes ba ON ura.business_area_attribute_id = ba.id
  ORDER BY ura.user_id, r.name;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;