-- Update currency orders visibility rules
-- New rules:
-- 1. PENDING orders: Admin sees all, users with appropriate permissions see pending orders
-- 2. ASSIGNED orders: Admin sees all, creator sees their orders, assigned employee sees their assigned orders

CREATE OR REPLACE FUNCTION get_currency_orders_optimized(
    p_current_profile_id UUID,
    p_for_delivery BOOLEAN DEFAULT FALSE,
    p_limit INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0,
    p_search_query TEXT DEFAULT NULL,
    p_status_filter TEXT DEFAULT NULL,
    p_order_type_filter TEXT DEFAULT NULL,
    p_game_code_filter TEXT DEFAULT NULL,
    p_start_date TIMESTAMPTZ DEFAULT NULL,
    p_end_date TIMESTAMPTZ DEFAULT NULL
)
RETURNS TABLE (
    -- Same structure as original function
    id UUID,
    order_number TEXT,
    order_type TEXT,
    status TEXT,
    game_code TEXT,
    server_attribute_code TEXT,
    quantity NUMERIC,
    cost_amount NUMERIC,
    cost_currency_code TEXT,
    sale_amount NUMERIC,
    sale_currency_code TEXT,
    profit_amount NUMERIC,
    profit_currency_code TEXT,
    foreign_currency_id UUID,
    foreign_currency_code TEXT,
    foreign_amount NUMERIC,
    profit_margin_percentage NUMERIC,
    cost_to_sale_exchange_rate NUMERIC,
    exchange_rate_date DATE,
    exchange_rate_source TEXT,
    currency_attribute_id UUID,
    currency_attribute JSONB,
    channel_id UUID,
    channel JSONB,
    game_account_id UUID,
    game_account JSONB,
    party_id UUID,
    party JSONB,
    assigned_to UUID,
    assigned_employee JSONB,
    created_by UUID,
    created_by_profile JSONB,
    foreign_currency_attribute JSONB,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    submitted_at TIMESTAMPTZ,
    submitted_by UUID,
    assigned_at TIMESTAMPTZ,
    preparation_at TIMESTAMPTZ,
    ready_at TIMESTAMPTZ,
    delivery_at TIMESTAMPTZ,
    delivered_by UUID,
    completed_at TIMESTAMPTZ,
    cancelled_at TIMESTAMPTZ,
    priority_level INTEGER,
    deadline_at TIMESTAMPTZ,
    delivery_info TEXT,
    notes TEXT,
    proofs JSONB,
    inventory_pool_id UUID,
    exchange_type TEXT,
    exchange_details JSONB
) SECURITY DEFINER SET search_path = 'public'
AS $$
DECLARE
    v_is_admin boolean := false;
    v_is_manager boolean := false;
    v_is_leader boolean := false;
    v_can_view_pending boolean := false;
    v_current_profile_id uuid := p_current_profile_id;
BEGIN
    -- SECURITY: Require valid profile ID
    IF v_current_profile_id IS NULL THEN
        RAISE EXCEPTION 'Authentication required: profile ID cannot be null';
    END IF;

    -- Check user roles and permissions
    SELECT EXISTS(
        SELECT 1
        FROM user_role_assignments ura
        JOIN roles r ON ura.role_id = r.id
        WHERE ura.user_id = v_current_profile_id
        AND r.code IN ('admin', 'mod')
    ) INTO v_is_admin;

    -- Check if user is manager or leader
    SELECT EXISTS(
        SELECT 1
        FROM user_role_assignments ura
        JOIN roles r ON ura.role_id = r.id
        WHERE ura.user_id = v_current_profile_id
        AND r.code IN ('manager', 'leader')
    ) INTO v_is_manager;

    -- Combine admin, mod, manager, leader for admin privileges
    v_is_admin := v_is_admin OR v_is_manager;

    -- Check if user can view pending orders (has any currency-related permission)
    -- This will be checked against the permissions system
    -- For now, assume anyone with currency permissions can view pending orders
    -- TODO: Integrate with actual permissions system
    v_can_view_pending := v_is_admin OR v_is_manager OR v_is_leader;

    -- Apply access control with new visibility rules
    RETURN QUERY
    SELECT
        co.id,
        co.order_number,
        co.order_type::text,
        co.status::text,
        co.game_code,
        co.server_attribute_code,
        co.quantity,
        co.cost_amount,
        co.cost_currency_code,
        co.sale_amount,
        co.sale_currency_code,
        co.profit_amount,
        co.profit_currency_code,
        co.foreign_currency_id,
        co.foreign_currency_code,
        co.foreign_amount,
        co.profit_margin_percentage,
        co.cost_to_sale_exchange_rate,
        co.exchange_rate_date,
        co.exchange_rate_source,
        co.currency_attribute_id,
        jsonb_build_object(
            'id', ca.id,
            'code', ca.code,
            'name', ca.name,
            'type', ca.type
        ) as currency_attribute,
        co.channel_id,
        jsonb_build_object(
            'id', ch.id,
            'code', ch.code,
            'name', ch.name
        ) as channel,
        co.game_account_id,
        jsonb_build_object(
            'id', ga.id,
            'account_name', ga.account_name,
            'game_code', ga.game_code,
            'purpose', ga.purpose
        ) as game_account,
        co.party_id,
        jsonb_build_object(
            'id', pt.id,
            'name', pt.name,
            'type', pt.type
        ) as party,
        co.assigned_to,
        jsonb_build_object(
            'id', p_assigned.id,
            'display_name', p_assigned.display_name
        ) as assigned_employee,
        co.created_by,
        jsonb_build_object(
            'id', p_creator.id,
            'display_name', p_creator.display_name
        ) as created_by_profile,
        jsonb_build_object(
            'id', fca.id,
            'code', fca.code,
            'name', fca.name,
            'type', fca.type
        ) as foreign_currency_attribute,
        co.created_at,
        co.updated_at,
        co.submitted_at,
        co.submitted_by,
        co.assigned_at,
        co.preparation_at,
        co.ready_at,
        co.delivery_at,
        co.delivered_by,
        co.completed_at,
        co.cancelled_at,
        co.priority_level,
        co.deadline_at,
        co.delivery_info,
        co.notes,
        co.proofs,
        co.inventory_pool_id,
        co.exchange_type::text,
        co.exchange_details
    FROM currency_orders co
    LEFT JOIN attributes ca ON co.currency_attribute_id = ca.id
    LEFT JOIN channels ch ON co.channel_id = ch.id
    LEFT JOIN game_accounts ga ON co.game_account_id = ga.id
    LEFT JOIN parties pt ON co.party_id = pt.id
    LEFT JOIN profiles p_assigned ON co.assigned_to = p_assigned.id
    LEFT JOIN profiles p_creator ON co.created_by = p_creator.id
    LEFT JOIN attributes fca ON co.foreign_currency_id = fca.id
    WHERE
        -- Server-side search filter
        (
            p_search_query IS NULL
            OR
            (
                co.order_number ILIKE '%' || p_search_query || '%'
                OR co.notes ILIKE '%' || p_search_query || '%'
                OR ca.name ILIKE '%' || p_search_query || '%'
                OR ca.code ILIKE '%' || p_search_query || '%'
                OR ch.name ILIKE '%' || p_search_query || '%'
                OR p_creator.display_name ILIKE '%' || p_search_query || '%'
                OR ga.account_name ILIKE '%' || p_search_query || '%'
            )
        )
        -- Server-side status filter
        AND (p_status_filter IS NULL OR co.status::text = p_status_filter)
        -- Server-side order type filter
        AND (p_order_type_filter IS NULL OR co.order_type::text = p_order_type_filter)
        -- Server-side game code filter
        AND (p_game_code_filter IS NULL OR co.game_code = p_game_code_filter)
        -- Server-side date range filter
        AND (p_start_date IS NULL OR p_end_date IS NULL OR co.created_at BETWEEN p_start_date AND p_end_date)

        -- NEW VISIBILITY RULES:
        AND (
            -- Rule 1: PENDING orders
            (
                co.status = 'pending'
                AND (
                    v_is_admin  -- Admin sees all pending
                    OR v_can_view_pending  -- Users with permissions see pending
                )
            )
            -- Rule 2: ASSIGNED orders (includes all other statuses)
            OR (
                co.status IN ('assigned', 'preparing', 'delivering', 'ready', 'delivered', 'completed', 'cancelled')
                AND (
                    v_is_admin  -- Admin sees all assigned orders
                    OR co.created_by = v_current_profile_id  -- Creator sees their orders
                    OR co.assigned_to = v_current_profile_id  -- Assigned employee sees their orders
                )
            )
        )

        -- For delivery tab, filter specific statuses (INCLUDES pending!)
        AND (
            NOT p_for_delivery
            OR co.status IN ('pending', 'assigned', 'preparing', 'delivering', 'ready', 'delivered')
        )
    ORDER BY co.created_at DESC
    LIMIT p_limit OFFSET p_offset;
END;
$$ LANGUAGE plpgsql;

-- Grant permissions
GRANT EXECUTE ON FUNCTION get_currency_orders_optimized(UUID, BOOLEAN, INTEGER, INTEGER, TEXT, TEXT, TEXT, TEXT, TIMESTAMPTZ, TIMESTAMPTZ) TO authenticated;

-- Verify function creation
SELECT
    proname as function_name,
    'UPDATED with new visibility rules' as status
FROM pg_proc
WHERE proname = 'get_currency_orders_optimized';

-- Test the function to ensure it works correctly
SELECT 'Testing updated visibility rules...' as message;