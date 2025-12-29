-- Improve delete_channel_direct function to check for related records
-- Smart delete: hard delete if no references, soft delete if has references

CREATE OR REPLACE FUNCTION delete_channel_direct(
    p_channel_id UUID
)
RETURNS JSON SECURITY DEFINER SET search_path = 'public'
AS $$
DECLARE
    v_channel channels%ROWTYPE;
    v_related_count INTEGER;
    v_related_details TEXT;
BEGIN
    -- Validate channel exists
    SELECT * INTO v_channel
    FROM channels
    WHERE id = p_channel_id;

    IF v_channel.id IS NULL THEN
        RETURN json_build_object('success', false, 'message', 'Channel not found');
    END IF;

    -- Check for related records in all tables that reference channels
    WITH channel_refs AS (
        SELECT COUNT(*) as total_count,
            string_agg(table_name || ': ' || count, ', ') as details
        FROM (
            SELECT 'shift_assignments' as table_name, COUNT(*) as count FROM shift_assignments WHERE channels_id = p_channel_id
            UNION ALL
            SELECT 'business_processes (purchase)', COUNT(*) FROM business_processes WHERE purchase_channel_id = p_channel_id
            UNION ALL
            SELECT 'business_processes (sale)', COUNT(*) FROM business_processes WHERE sale_channel_id = p_channel_id
            UNION ALL
            SELECT 'inventory_pools', COUNT(*) FROM inventory_pools WHERE channel_id = p_channel_id
            UNION ALL
            SELECT 'orders', COUNT(*) FROM orders WHERE channel_id = p_channel_id
            UNION ALL
            SELECT 'parties', COUNT(*) FROM parties WHERE channel_id = p_channel_id
        ) ref_counts
        WHERE count > 0
    )
    SELECT total_count, details INTO v_related_count, v_related_details
    FROM channel_refs;

    -- If no related records, perform hard delete
    IF v_related_count = 0 OR v_related_count IS NULL THEN
        DELETE FROM channels WHERE id = p_channel_id;

        RETURN json_build_object(
            'success', true,
            'message', 'Đã xóa channel vĩnh viễn (không có dữ liệu liên quan)',
            'channel_id', p_channel_id,
            'delete_type', 'hard',
            'related_count', 0
        );
    ELSE
        -- Has related records, perform soft delete to avoid data integrity issues
        UPDATE channels
        SET
            is_active = false,
            updated_at = now()
        WHERE id = p_channel_id;

        RETURN json_build_object(
            'success', true,
            'message', 'Đã vô hiệu hóa channel (có ' || v_related_count || ' dữ liệu liên quan: ' || COALESCE(v_related_details, 'không rõ') || ')',
            'channel_id', p_channel_id,
            'delete_type', 'soft',
            'related_count', v_related_count,
            'related_details', v_related_details
        );
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Grant permissions
GRANT EXECUTE ON FUNCTION delete_channel_direct(UUID) TO authenticated;

-- Verify function creation
SELECT
    proname as function_name,
    pg_get_function_arguments(oid) as parameters,
    'IMPROVED' as status
FROM pg_proc
WHERE proname = 'delete_channel_direct';