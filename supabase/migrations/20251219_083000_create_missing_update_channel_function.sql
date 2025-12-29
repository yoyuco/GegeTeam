-- Create missing update_channel_direct function
-- This function is called by ChannelsManagement.vue component

CREATE OR REPLACE FUNCTION update_channel_direct(
    p_channel_id UUID,
    p_code TEXT,
    p_name TEXT,
    p_description TEXT,
    p_website_url TEXT,
    p_direction TEXT,
    p_is_active BOOLEAN DEFAULT true,
    p_updated_by UUID DEFAULT NULL -- profiles.id from frontend (who is updating) - following memory.md pattern
)
RETURNS JSON SECURITY DEFINER SET search_path = 'public'
AS $$
DECLARE
    v_channel channels%ROWTYPE;
    v_name_exists BOOLEAN;
BEGIN
    -- Validate channel exists
    SELECT * INTO v_channel
    FROM channels
    WHERE id = p_channel_id;

    IF v_channel.id IS NULL THEN
        RETURN json_build_object('success', false, 'message', 'Channel not found');
    END IF;

    -- Check if name already exists for another channel
    SELECT EXISTS(SELECT 1 FROM channels WHERE name = p_name AND id != p_channel_id AND is_active = true) INTO v_name_exists;

    IF v_name_exists THEN
        RETURN json_build_object('success', false, 'message', 'Channel name already exists');
    END IF;

    -- Validate direction
    IF p_direction NOT IN ('BUY', 'SELL', 'BOTH') THEN
        RETURN json_build_object('success', false, 'message', 'Invalid direction. Must be: BUY, SELL, or BOTH');
    END IF;

    -- Update channel
    UPDATE channels
    SET
        code = p_code,
        name = p_name,
        description = p_description,
        website_url = p_website_url,
        direction = p_direction,
        is_active = p_is_active,
        updated_at = now()
    WHERE id = p_channel_id;

    RETURN json_build_object(
        'success', true,
        'message', 'Channel updated successfully',
        'channel_id', p_channel_id
    );
END;
$$ LANGUAGE plpgsql;

-- Grant permissions
GRANT EXECUTE ON FUNCTION update_channel_direct(UUID, TEXT, TEXT, TEXT, TEXT, TEXT, BOOLEAN, UUID) TO authenticated;

-- Verify function creation
SELECT
    proname as function_name,
    pg_get_function_arguments(oid) as parameters,
    'CREATED' as status
FROM pg_proc
WHERE proname = 'update_channel_direct';