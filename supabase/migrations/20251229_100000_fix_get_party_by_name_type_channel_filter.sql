-- Fix get_party_by_name_type to filter by channel_id
-- This ensures that when loading customer/supplier data by name,
-- it only returns results from the currently selected channel

-- Step 1: Drop old function version (2 parameters) first
-- Need to specify argument list to avoid ambiguity
DROP FUNCTION IF EXISTS public.get_party_by_name_type(text, text) CASCADE;

-- Step 2: Create new version with 3 parameters
CREATE OR REPLACE FUNCTION public.get_party_by_name_type(
    p_name text,
    p_type text,
    p_channel_id uuid DEFAULT NULL
)
RETURNS TABLE(
    party_id uuid,
    name text,
    type text,
    contact_info jsonb,
    notes text,
    channel_id uuid,
    game_code text
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
BEGIN
    -- If channel_id is provided, only search within that channel
    -- If channel_id is NULL, search all channels (backward compatibility)
    RETURN QUERY
    SELECT
        p.id as party_id,
        p.name,
        p.type,
        p.contact_info,
        p.notes,
        p.channel_id,
        p.game_code
    FROM parties p
    WHERE p.name = p_name
      AND p.type = p_type
      AND (p_channel_id IS NULL OR p.channel_id = p_channel_id)
    ORDER BY
        -- Prioritize exact channel match
        CASE WHEN p.channel_id = p_channel_id THEN 0 ELSE 1 END,
        -- Then prioritize recently updated
        p.updated_at DESC
    LIMIT 1;
END;
$$;

-- Grant permissions
GRANT EXECUTE ON FUNCTION public.get_party_by_name_type(text, text, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_party_by_name_type(text, text, uuid) TO service_role;

-- Add comment for documentation
COMMENT ON FUNCTION public.get_party_by_name_type IS 'Load party by name and type, optionally filtered by channel_id. If channel_id is provided, only returns parties from that channel. This prevents cross-channel data contamination when auto-filling forms.';
