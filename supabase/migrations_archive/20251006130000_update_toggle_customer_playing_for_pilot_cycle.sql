-- Update toggle_customer_playing function to integrate with existing pilot cycle system
-- This migration assumes pilot cycle columns and functions already exist in production

-- Update toggle_customer_playing to integrate with pilot cycle logic
CREATE OR REPLACE FUNCTION public.toggle_customer_playing(
    p_order_id uuid,
    p_enable_customer_playing boolean,
    p_current_user_id uuid
)
RETURNS TABLE(
    success boolean,
    message text,
    new_status text,
    new_deadline timestamp with time zone
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
    v_order_record RECORD;
    v_current_status text;
    v_current_deadline timestamp with time zone;
    v_new_deadline timestamp with time zone;
    v_now timestamp with time zone := now();
    v_service_type text;
    v_order_line_id uuid;
BEGIN
    -- Get current order info with correct schema
    SELECT
        o.status,
        ol.deadline_to as deadline,
        COALESCE(
            (SELECT a.name FROM product_variant_attributes pva
             JOIN attributes a ON pva.attribute_id = a.id
             WHERE pva.variant_id = ol.variant_id AND a.type = 'SERVICE_TYPE' LIMIT 1),
            'Unknown'
        ) as service_type,
        ol.paused_at,
        ol.id
    INTO v_order_record
    FROM orders o
    JOIN order_lines ol ON o.id = ol.order_id
    WHERE o.id = p_order_id
    LIMIT 1;

    IF NOT FOUND THEN
        RETURN QUERY SELECT false, 'Đơn hàng không tồn tại'::text, NULL::text, NULL::timestamp with time zone;
        RETURN;
    END IF;

    v_current_status := v_order_record.status;
    v_current_deadline := v_order_record.deadline;
    v_order_line_id := v_order_record.id;
    v_service_type := v_order_record.service_type;

    -- Chỉ áp dụng cho pilot orders (exclude Selfplay)
    IF v_service_type = 'Selfplay' THEN
        RETURN QUERY SELECT false, 'Chỉ áp dụng cho đơn hàng pilot'::text, NULL::text, NULL::timestamp with time zone;
        RETURN;
    END IF;

    -- Chỉ cho phép toggle khi đang trong các trạng thái phù hợp
    IF v_current_status NOT IN ('in_progress', 'pending_pilot', 'customer_playing') THEN
        RETURN QUERY SELECT false, 'Chỉ áp dụng cho đơn hàng đang thực hiện'::text, NULL::text, NULL::timestamp with time zone;
        RETURN;
    END IF;

    IF p_enable_customer_playing THEN
        -- Bắt đầu khách chơi
        -- Update paused_at để đánh dấu thời điểm bắt đầu khách chơi
        UPDATE order_lines
        SET paused_at = v_now
        WHERE order_id = p_order_id;

        -- Update order status
        UPDATE orders
        SET
            status = 'customer_playing',
            updated_at = v_now
        WHERE id = p_order_id;

        -- Cập nhật pilot cycle warning (chỉ cho pilot đang hoạt động)
        PERFORM public.update_pilot_cycle_warning(v_order_line_id);

        RETURN QUERY SELECT
            true,
            'Đã chuyển sang trạng thái Khách chơi'::text,
            'customer_playing'::text,
            v_current_deadline;
        RETURN;

    ELSE
        -- Tắt chế độ khách chơi - tiếp tục pilot
        -- Tính toán thời gian đã khách chơi để cộng vào deadline
        IF v_order_record.paused_at IS NOT NULL AND v_current_deadline IS NOT NULL THEN
            -- Thời gian khách chơi = now - paused_at
            v_new_deadline := v_current_deadline + (v_now - v_order_record.paused_at);
        ELSE
            v_new_deadline := v_current_deadline;
        END IF;

        -- CẬP NHẬT paused_at TÙY THEO WORK SESSION (logic cho pilot cycle)
        UPDATE order_lines
        SET
            paused_at = CASE
                WHEN EXISTS (
                    SELECT 1 FROM work_sessions
                    WHERE order_line_id = v_order_line_id
                    AND ended_at IS NULL
                ) THEN NULL  -- Có work session -> vẫn online
                ELSE v_now   -- Không work session -> bắt đầu nghỉ
            END
        WHERE order_id = p_order_id;

        -- Update order status và deadline
        UPDATE orders
        SET
            status = 'pending_pilot',
            updated_at = v_now
        WHERE id = p_order_id;

        -- Update deadline trong order_lines
        UPDATE order_lines
        SET deadline_to = v_new_deadline
        WHERE order_id = p_order_id;

        -- Cập nhật pilot cycle warning (chỉ cho pilot đang hoạt động)
        PERFORM public.update_pilot_cycle_warning(v_order_line_id);

        -- Kiểm tra điều kiện reset (chỉ cho pilot đang hoạt động)
        PERFORM public.check_and_reset_pilot_cycle(v_order_line_id);

        RETURN QUERY SELECT
            true,
            'Đã tiếp tục thực hiện đơn hàng'::text,
            'pending_pilot'::text,
            v_new_deadline;
        RETURN;
    END IF;
END;
$$;

-- Grant permissions
GRANT ALL ON FUNCTION public.toggle_customer_playing(uuid, boolean, uuid) TO anon;
GRANT ALL ON FUNCTION public.toggle_customer_playing(uuid, boolean, uuid) TO authenticated;
GRANT ALL ON FUNCTION public.toggle_customer_playing(uuid, boolean, uuid) TO service_role;