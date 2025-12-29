-- Fix return type mismatch in get_all_shift_assignments_direct function
-- Error: "Returned type time without time zone does not match expected type text in column 7"

-- Drop and recreate function with correct return types
DROP FUNCTION IF EXISTS get_all_shift_assignments_direct();

CREATE OR REPLACE FUNCTION get_all_shift_assignments_direct()
RETURNS TABLE (
    id UUID,
    employee_profile_id UUID,
    employee_name TEXT,
    shift_id UUID,
    shift_name TEXT,
    shift_start_time TIME,
    shift_end_time TIME,  -- Fixed: was TEXT, should be TIME
    channels_id UUID,
    channel_name TEXT,
    currency_code TEXT,
    currency_name TEXT,
    is_active BOOLEAN,
    assigned_at TIMESTAMPTZ
) SECURITY DEFINER SET search_path = 'public'
AS $$
BEGIN
  RETURN QUERY
  SELECT
    sa.id,
    sa.employee_profile_id,
    COALESCE(p.display_name, 'Unknown') as employee_name,
    sa.shift_id,
    COALESCE(ws.name, 'Unknown') as shift_name,
    ws.start_time as shift_start_time,
    ws.end_time as shift_end_time,  -- Fixed: return as TIME, not TEXT
    sa.channels_id,
    COALESCE(c.name, 'Unknown') as channel_name,
    sa.currency_code,
    COALESCE(curr.name, sa.currency_code) as currency_name,
    sa.is_active,
    sa.assigned_at
  FROM shift_assignments sa
  LEFT JOIN profiles p ON sa.employee_profile_id = p.id
  LEFT JOIN work_shifts ws ON sa.shift_id = ws.id
  LEFT JOIN channels c ON sa.channels_id = c.id
  LEFT JOIN currencies curr ON sa.currency_code = curr.code
  ORDER BY sa.assigned_at DESC;
END;
$$ LANGUAGE plpgsql;

-- Grant permissions
GRANT EXECUTE ON FUNCTION get_all_shift_assignments_direct() TO authenticated;

-- Verify the function was created correctly
SELECT
    proname as function_name,
    pg_get_function_arguments(oid) as parameters,
    'FIXED' as status
FROM pg_proc
WHERE proname = 'get_all_shift_assignments_direct';