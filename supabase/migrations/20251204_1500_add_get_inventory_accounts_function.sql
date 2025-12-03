-- Add RPC function to get inventory accounts for currency transfer
-- This function properly handles both server-specific and global accounts
-- Fixes security issue with search_path and improves account loading logic

-- RPC function to get inventory accounts for currency transfer
-- Returns both server-specific accounts (server_attribute_code = server_code)
-- and global accounts (server_attribute_code IS NULL) for the given game
CREATE OR REPLACE FUNCTION get_inventory_accounts(
    p_game_code TEXT,
    p_server_attribute_code TEXT DEFAULT NULL
)
RETURNS TABLE (
    id UUID,
    account_name TEXT,
    purpose TEXT,
    server_attribute_code TEXT,
    is_active BOOLEAN
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    RETURN QUERY
    SELECT
        ga.id,
        ga.account_name,
        ga.purpose,
        ga.server_attribute_code,
        ga.is_active
    FROM game_accounts ga
    WHERE
        ga.game_code = p_game_code
        AND ga.purpose = 'INVENTORY'
        AND ga.is_active = true
        AND (
            -- Include server-specific accounts for this server
            ga.server_attribute_code = p_server_attribute_code
            OR
            -- Include global accounts (NULL server_attribute_code)
            ga.server_attribute_code IS NULL
        )
    ORDER BY
        -- Server-specific accounts first, then global accounts
        CASE
            WHEN ga.server_attribute_code IS NULL THEN 2
            ELSE 1
        END,
        ga.account_name;
END;
$$;

-- Grant permissions
GRANT EXECUTE ON FUNCTION get_inventory_accounts TO authenticated;

-- Add comment for documentation
COMMENT ON FUNCTION get_inventory_accounts IS 'Get inventory accounts for a specific game and server, including both server-specific and global accounts. Server-specific accounts are returned first, followed by global accounts.';