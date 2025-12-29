-- Create missing create_channel_direct function
-- This function is called by ChannelsManagement.vue component

CREATE OR REPLACE FUNCTION create_channel_direct(
    p_code TEXT,
    p_name TEXT,
    p_description TEXT,
    p_website_url TEXT,
    p_direction TEXT,
    p_is_active BOOLEAN DEFAULT true,
    p_created_by UUID DEFAULT NULL -- profiles.id from frontend (who is creating) - following memory.md pattern
)
RETURNS JSON SECURITY DEFINER SET search_path = 'public'
AS $$
DECLARE
    v_channel_id UUID;
    v_name_exists BOOLEAN;
    v_code_exists BOOLEAN;
BEGIN
    -- Validate input fields
    IF p_code IS NULL OR p_code = '' THEN
        RETURN json_build_object('success', false, 'message', 'Channel code is required');
    END IF;

    IF p_name IS NULL OR p_name = '' THEN
        RETURN json_build_object('success', false, 'message', 'Channel name is required');
    END IF;

    -- Validate direction
    IF p_direction NOT IN ('BUY', 'SELL', 'BOTH') THEN
        RETURN json_build_object('success', false, 'message', 'Invalid direction. Must be: BUY, SELL, or BOTH');
    END IF;

    -- Check if channel code already exists
    SELECT EXISTS(SELECT 1 FROM channels WHERE code = p_code AND is_active = true) INTO v_code_exists;

    IF v_code_exists THEN
        RETURN json_build_object('success', false, 'message', 'Channel code already exists');
    END IF;

    -- Check if channel name already exists
    SELECT EXISTS(SELECT 1 FROM channels WHERE name = p_name AND is_active = true) INTO v_name_exists;

    IF v_name_exists THEN
        RETURN json_build_object('success', false, 'message', 'Channel name already exists');
    END IF;

    -- Create new channel
    INSERT INTO channels (
        code, name, description, website_url, direction, is_active,
        created_at, updated_at
    ) VALUES (
        p_code, p_name, p_description, p_website_url, p_direction, p_is_active,
        now(), now()
    ) RETURNING id INTO v_channel_id;

    RETURN json_build_object(
        'success', true,
        'message', 'Channel created successfully',
        'channel_id', v_channel_id
    );
END;
$$ LANGUAGE plpgsql;

-- Grant permissions
GRANT EXECUTE ON FUNCTION create_channel_direct(TEXT, TEXT, TEXT, TEXT, TEXT, BOOLEAN, UUID) TO authenticated;

-- Verify function creation
SELECT
    proname as function_name,
    pg_get_function_arguments(oid) as parameters,
    'CREATED' as status
FROM pg_proc
WHERE proname = 'create_channel_direct';