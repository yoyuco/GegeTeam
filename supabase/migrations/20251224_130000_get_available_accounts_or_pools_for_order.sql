-- DROP FUNCTION first due to return type change
DROP FUNCTION IF EXISTS get_available_accounts_or_pools_for_order(UUID) CASCADE;

-- Get available game_accounts (for PURCHASE) or inventory_pools (for SALE) for an order
-- For SALE orders: shows ALL inventory_pools with intelligent match scoring
CREATE OR REPLACE FUNCTION get_available_accounts_or_pools_for_order(
    p_order_id UUID
)
RETURNS TABLE (
    type TEXT,
    id UUID,
    game_account_id UUID,
    account_name TEXT,
    currency_name TEXT,
    currency_code TEXT,
    available_quantity NUMERIC,
    reserved_quantity NUMERIC,
    total_quantity NUMERIC,
    average_cost NUMERIC,
    cost_currency TEXT,
    channel_name TEXT,
    game_code TEXT,
    server_code TEXT,
    is_suitable BOOLEAN,
    match_score INTEGER
) SECURITY DEFINER SET search_path = 'public'
AS $$
DECLARE
    v_order RECORD;
BEGIN
    -- Get order details
    SELECT
        co.id,
        co.order_type,
        co.game_code,
        co.server_attribute_code,
        co.currency_attribute_id,
        co.quantity,
        co.channel_id
    INTO v_order
    FROM currency_orders co
    WHERE co.id = p_order_id;

    IF NOT FOUND THEN
        RETURN;
    END IF;

    -- For PURCHASE orders: return available game_accounts for storage
    -- NOTE: game_accounts doesn't have channel_id, so channel_name is NULL
    IF v_order.order_type = 'PURCHASE' THEN
        RETURN QUERY
        SELECT
            'game_account'::TEXT as type,
            ga.id,
            ga.id as game_account_id,
            ga.account_name,
            attr.name as currency_name,
            attr.code as currency_code,
            0::NUMERIC as available_quantity,
            0::NUMERIC as reserved_quantity,
            0::NUMERIC as total_quantity,
            0::NUMERIC as average_cost,
            NULL::TEXT as cost_currency,
            NULL::TEXT as channel_name,  -- game_accounts has no channel
            ga.game_code,
            ga.server_attribute_code as server_code,
            true as is_suitable,
            100 as match_score
        FROM game_accounts ga
        CROSS JOIN LATERAL (
            SELECT attr.id, attr.name, attr.code
            FROM attributes attr
            WHERE attr.id = v_order.currency_attribute_id
        ) attr
        WHERE ga.game_code = v_order.game_code
          AND (ga.server_attribute_code = v_order.server_attribute_code OR
               (ga.server_attribute_code IS NULL AND v_order.server_attribute_code IS NULL) OR
               (ga.server_attribute_code IS NULL) OR
               (v_order.server_attribute_code IS NULL))
          AND ga.is_active = true
          AND LOWER(ga.purpose) IN ('inventory', 'storage')  -- Case-insensitive
        ORDER BY ga.account_name;

    -- For SALE orders: return ALL inventory_pools with intelligent match scoring
    -- Traders can decide which pool to use, results are sorted by relevance
    ELSIF v_order.order_type = 'SALE' THEN
        RETURN QUERY
        SELECT
            'inventory_pool'::TEXT as type,
            ip.id,
            ip.game_account_id,
            ga.account_name,
            attr.name as currency_name,
            attr.code as currency_code,
            GREATEST(0, ip.quantity - COALESCE(ip.reserved_quantity, 0)) as available_quantity,
            COALESCE(ip.reserved_quantity, 0) as reserved_quantity,
            ip.quantity as total_quantity,
            ip.average_cost,
            ip.cost_currency,
            ch.name as channel_name,
            ip.game_code,
            ip.server_attribute_code as server_code,
            CASE
                WHEN GREATEST(0, ip.quantity - COALESCE(ip.reserved_quantity, 0)) >= v_order.quantity THEN true
                ELSE false
            END as is_suitable,
            -- Match scoring algorithm for intelligent sorting:
            -- ONLY show pools matching game + server + currency
            -- 100: Perfect match (game + server + channel + currency + enough stock)
            -- 80: Good match (game + server + currency + enough stock, any channel)
            -- 50: Game + server + currency match but NOT enough stock (shows as warning)
            CASE
                WHEN ip.currency_attribute_id = v_order.currency_attribute_id
                     AND ip.game_code = v_order.game_code
                     AND (ip.server_attribute_code = v_order.server_attribute_code OR
                          (ip.server_attribute_code IS NULL AND v_order.server_attribute_code IS NULL))
                     AND (ip.channel_id = v_order.channel_id OR
                          (ip.channel_id IS NULL AND v_order.channel_id IS NULL))
                     AND GREATEST(0, ip.quantity - COALESCE(ip.reserved_quantity, 0)) >= v_order.quantity
                THEN 100
                WHEN ip.currency_attribute_id = v_order.currency_attribute_id
                     AND ip.game_code = v_order.game_code
                     AND (ip.server_attribute_code = v_order.server_attribute_code OR
                          (ip.server_attribute_code IS NULL AND v_order.server_attribute_code IS NULL))
                     AND GREATEST(0, ip.quantity - COALESCE(ip.reserved_quantity, 0)) >= v_order.quantity
                THEN 80
                WHEN ip.currency_attribute_id = v_order.currency_attribute_id
                     AND ip.game_code = v_order.game_code
                     AND (ip.server_attribute_code = v_order.server_attribute_code OR
                          (ip.server_attribute_code IS NULL AND v_order.server_attribute_code IS NULL))
                THEN 50
                ELSE 0
            END as match_score
        FROM inventory_pools ip
        JOIN game_accounts ga ON ip.game_account_id = ga.id
        JOIN attributes attr ON ip.currency_attribute_id = attr.id
        LEFT JOIN channels ch ON ip.channel_id = ch.id
        WHERE ga.is_active = true
          AND ip.quantity > 0
          AND ip.currency_attribute_id = v_order.currency_attribute_id
          AND ip.game_code = v_order.game_code
          AND (ip.server_attribute_code = v_order.server_attribute_code OR
               (ip.server_attribute_code IS NULL AND v_order.server_attribute_code IS NULL))
        ORDER BY
            match_score DESC,
            ip.game_code,
            ip.server_attribute_code NULLS LAST,
            ip.last_updated_at ASC;  -- FIFO within same match score

    END IF;

    RETURN;
END;
$$ LANGUAGE plpgsql;

-- Grant permissions
GRANT EXECUTE ON FUNCTION get_available_accounts_or_pools_for_order(UUID) TO authenticated;

-- Verify function creation
SELECT
    proname as function_name,
    'CREATED' as status
FROM pg_proc
WHERE proname = 'get_available_accounts_or_pools_for_order';
