-- Create missing delete_channel_direct function
-- This function is called by ChannelsManagement.vue component

CREATE OR REPLACE FUNCTION delete_channel_direct(
    p_channel_id UUID
)
RETURNS JSON SECURITY DEFINER SET search_path = 'public'
AS $$
DECLARE
    v_channel channels%ROWTYPE;
BEGIN
    -- Validate channel exists
    SELECT * INTO v_channel
    FROM channels
    WHERE id = p_channel_id;

    IF v_channel.id IS NULL THEN
        RETURN json_build_object('success', false, 'message', 'Channel not found');
    END IF;

    -- Soft delete (set inactive) instead of hard delete to maintain audit trail
    UPDATE channels
    SET
        is_active = false,
        updated_at = now()
    WHERE id = p_channel_id;

    RETURN json_build_object(
        'success', true,
        'message', 'Channel deleted successfully',
        'channel_id', p_channel_id
    );
END;
$$ LANGUAGE plpgsql;

-- Grant permissions
GRANT EXECUTE ON FUNCTION delete_channel_direct(UUID) TO authenticated;

-- Verify function creation
SELECT
    proname as function_name,
    pg_get_function_arguments(oid) as parameters,
    'CREATED' as status
FROM pg_proc
WHERE proname = 'delete_channel_direct';