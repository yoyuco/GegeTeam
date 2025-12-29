-- Function to auto-assign currency order when trader2 views it
-- Checks if user has trader2 role and matching game/business area permissions
CREATE OR REPLACE FUNCTION auto_assign_currency_order_on_view(
    p_order_id UUID,
    p_user_id UUID
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    assigned BOOLEAN,
    status_changed BOOLEAN
) SECURITY DEFINER SET search_path = 'public'
AS $$
DECLARE
    v_order RECORD;
    v_has_trader2_role BOOLEAN := false;
    v_has_start_permission BOOLEAN := false;
    v_game_matches BOOLEAN := false;
    v_business_area_matches BOOLEAN := false;
    v_order_number TEXT;
BEGIN
    -- Get order details
    SELECT
        co.id,
        co.order_number,
        co.status,
        co.game_code,
        co.assigned_to
    INTO v_order
    FROM currency_orders co
    WHERE co.id = p_order_id;

    -- Order not found
    IF NOT FOUND THEN
        RETURN QUERY SELECT false, 'Đơn hàng không tồn tại'::TEXT, false, false;
        RETURN;
    END IF;

    v_order_number := v_order.order_number;

    -- Only allow assignment for 'pending' or 'assigned' orders
    IF v_order.status NOT IN ('pending', 'assigned') THEN
        RETURN QUERY SELECT false, 'Đơn hàng đã được phân công hoặc không thể tiếp nhận'::TEXT, false, false;
        RETURN;
    END IF;

    -- Already assigned to someone else
    IF v_order.assigned_to IS NOT NULL AND v_order.assigned_to != p_user_id THEN
        RETURN QUERY SELECT false, 'Đơn hàng đã được phân công cho nhân viên khác'::TEXT, false, false;
        RETURN;
    END IF;

    -- Check if user has trader2 role with matching game/business area
    SELECT EXISTS(
        SELECT 1
        FROM user_role_assignments ura
        JOIN roles r ON ura.role_id = r.id
        WHERE ura.user_id = p_user_id
        AND r.code = 'trader2'
        -- Game match: either NULL (all games) or matches order's game code
        AND (
            ura.game_attribute_id IS NULL
            OR EXISTS (
                SELECT 1 FROM attributes ga
                WHERE ga.id = ura.game_attribute_id
                AND ga.code = v_order.game_code
            )
        )
        -- Business area: for now we'll be lenient (NULL matches all)
        AND (
            ura.business_area_attribute_id IS NULL
            OR ura.business_area_attribute_id IS NOT NULL  -- Any business area is OK for now
        )
    ) INTO v_has_trader2_role;

    IF NOT v_has_trader2_role THEN
        RETURN QUERY SELECT false, 'Bạn không có quyền tiếp nhận đơn hàng này (role trader2 required)'::TEXT, false, false;
        RETURN;
    END IF;

    -- Check if user has currency:start_orders permission
    SELECT EXISTS(
        SELECT 1
        FROM user_role_assignments ura
        JOIN role_permissions rp ON ura.role_id = rp.role_id
        JOIN permissions p ON rp.permission_id = p.id
        WHERE ura.user_id = p_user_id
        AND p.code = 'currency:start_orders'
    ) INTO v_has_start_permission;

    IF NOT v_has_start_permission THEN
        RETURN QUERY SELECT false, 'Bạn không có quyền bắt đầu xử lý đơn hàng'::TEXT, false, false;
        RETURN;
    END IF;

    -- Assign the order and change status to 'preparing'
    -- FIXED: Now includes updated_by to track who made the change
    UPDATE currency_orders
    SET
        assigned_to = p_user_id,
        status = 'preparing',
        assigned_at = COALESCE(assigned_at, NOW()),
        preparation_at = NOW(),
        updated_at = NOW(),
        updated_by = p_user_id
    WHERE id = p_order_id;

    -- Return success
    RETURN QUERY SELECT
        true,
        'Đã tiếp nhận đơn #' || v_order_number || '. Chuyển sang trạng thái Đang chuẩn bị.'::TEXT,
        true,
        true
    ;
    RETURN;
END;
$$ LANGUAGE plpgsql;

-- Grant permissions
GRANT EXECUTE ON FUNCTION auto_assign_currency_order_on_view(UUID, UUID) TO authenticated;

-- Verify function creation
SELECT
    proname as function_name,
    'CREATED/UPDATED' as status
FROM pg_proc
WHERE proname = 'auto_assign_currency_order_on_view';
