-- Fix finish_work_session_idem_v1 to include proper pilot cycle logic
-- This updates the function to match the staging version with pilot cycle integration

CREATE OR REPLACE FUNCTION "public"."finish_work_session_idem_v1"(
    "p_session_id" "uuid",
    "p_outputs" "jsonb",
    "p_activity_rows" "jsonb",
    "p_overrun_reason" "text",
    "p_idem_key" "text",
    "p_overrun_type" "text",
    "p_overrun_proof_urls" "text"[]
) RETURNS "void"
LANGUAGE "plpgsql" SECURITY DEFINER
SET "search_path" TO 'public'
AS $$
DECLARE
    v_session public.work_sessions%ROWTYPE;
    v_order_line_id UUID;
    v_order_id UUID;
    v_service_type TEXT;
    output_item JSONB;
    activity_item JSONB;
    v_delta NUMERIC;
    v_current_order_status TEXT;
    v_context jsonb;
    v_pilot_service_type TEXT; -- For pilot cycle logic
BEGIN
    -- Phần logic gốc từ schema - giữ nguyên
    SELECT * INTO v_session FROM public.work_sessions WHERE id = p_session_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Phiên làm việc không tồn tại.'; END IF;
    IF v_session.ended_at IS NOT NULL THEN RETURN; END IF;

    v_order_line_id := v_session.order_line_id;

    -- Lấy ngữ cảnh để kiểm tra quyền override
    SELECT jsonb_build_object('game_code', o.game_code, 'business_area_code', 'SERVICE')
    INTO v_context
    FROM public.order_lines ol JOIN public.orders o ON ol.order_id = o.id
    WHERE ol.id = v_order_line_id;

    IF v_session.farmer_id <> public.get_current_profile_id() AND NOT has_permission('work_session:override', v_context) THEN
        RAISE EXCEPTION 'Bạn không phải chủ phiên và không có quyền can thiệp.';
    END IF;

    -- Lấy thông tin trạng thái và loại dịch vụ
    SELECT
        ol.id,
        o.id,
        (SELECT a.name FROM product_variant_attributes pva
         JOIN attributes a ON pva.attribute_id = a.id
         WHERE pva.variant_id = ol.variant_id AND a.type = 'SERVICE_TYPE' LIMIT 1) as service_type,
        o.status
    INTO
        v_order_line_id,
        v_order_id,
        v_service_type,
        v_current_order_status
    FROM public.order_lines ol
    JOIN public.orders o ON ol.order_id = o.id
    WHERE ol.id = v_order_line_id;

    -- Lưu lại service_type cho pilot cycle logic
    v_pilot_service_type := v_service_type;

    -- So sánh với tên variant đã được chuẩn hóa
    IF v_current_order_status <> 'pending_completion' THEN
        IF v_service_type IN ('Service - Pilot', 'Pilot') THEN
            UPDATE public.orders SET status = 'pending_pilot' WHERE id = v_order_id;
        ELSIF v_service_type IN ('Service - Selfplay', 'Selfplay') THEN
            UPDATE public.orders SET status = 'paused_selfplay' WHERE id = v_order_id;
        END IF;
    END IF;

    -- Xử lý outputs - giữ nguyên logic gốc để đảm bảo data được lưu
    IF p_outputs IS NOT NULL THEN
        FOR output_item IN SELECT * FROM jsonb_array_elements(p_outputs)
        LOOP
            -- Tính delta như logic gốc: current_value - start_value
            v_delta := (output_item->>'current_value')::numeric - (output_item->>'start_value')::numeric;

            -- Chỉ insert nếu delta khác 0
            IF v_delta <> 0 THEN
                INSERT INTO public.work_session_outputs (work_session_id, order_service_item_id, start_value, delta, start_proof_url, end_proof_url, params)
                VALUES (
                    p_session_id,
                    (output_item->>'item_id')::uuid,
                    (output_item->>'start_value')::numeric,
                    v_delta,
                    output_item->>'start_proof_url',
                    output_item->>'end_proof_url',
                    output_item->'params'
                );

                -- Update done_qty trong order_service_items như logic gốc
                UPDATE public.order_service_items
                SET done_qty = done_qty + v_delta
                WHERE id = (output_item->>'item_id')::uuid;
            END IF;
        END LOOP;
    END IF;

    IF p_activity_rows IS NOT NULL THEN
        FOR activity_item IN SELECT * FROM jsonb_array_elements(p_activity_rows)
        LOOP
            -- Logic gốc: activity cũng được insert vào work_session_outputs
            INSERT INTO public.work_session_outputs(work_session_id, order_service_item_id, delta, params)
            VALUES (p_session_id, (activity_item->>'item_id')::uuid, (activity_item->>'delta')::numeric, activity_item->'params');
        END LOOP;
    END IF;

    -- Kết thúc phiên - giữ nguyên logic
    UPDATE public.work_sessions
    SET
        ended_at = now(),
        overrun_reason = p_overrun_reason,
        overrun_type = p_overrun_type,
        overrun_proof_urls = p_overrun_proof_urls
    WHERE id = p_session_id;

    -- *** THÊM LOGIC PILOT CYCLE CHO FINISH SESSION ***
    IF v_pilot_service_type IN ('Service - Pilot', 'Pilot') AND
       v_current_order_status NOT IN ('completed', 'cancelled', 'delivered', 'pending_completion') THEN

        -- Bắt đầu nghỉ nếu không phải customer_playing
        UPDATE order_lines
        SET
            paused_at = CASE
                WHEN v_current_order_status = 'customer_playing' THEN paused_at  -- Khách chơi -> vẫn online
                ELSE now()                                             -- Thật sự nghỉ
            END
        WHERE id = v_order_line_id;

        -- Cập nhật pilot cycle warning
        PERFORM public.update_pilot_cycle_warning(v_order_line_id);

        -- Kiểm tra điều kiện reset
        PERFORM public.check_and_reset_pilot_cycle(v_order_line_id);
    END IF;
END;
$$;

-- Grant permissions
GRANT ALL ON FUNCTION "public"."finish_work_session_idem_v1"(
    "p_session_id" "uuid",
    "p_outputs" "jsonb",
    "p_activity_rows" "jsonb",
    "p_overrun_reason" "text",
    "p_idem_key" "text",
    "p_overrun_type" "text",
    "p_overrun_proof_urls" "text"[]
) TO anon;
GRANT ALL ON FUNCTION "public"."finish_work_session_idem_v1"(
    "p_session_id" "uuid",
    "p_outputs" "jsonb",
    "p_activity_rows" "jsonb",
    "p_overrun_reason" "text",
    "p_idem_key" "text",
    "p_overrun_type" "text",
    "p_overrun_proof_urls" "text"[]
) TO authenticated;
GRANT ALL ON FUNCTION "public"."finish_work_session_idem_v1"(
    "p_session_id" "uuid",
    "p_outputs" "jsonb",
    "p_activity_rows" "jsonb",
    "p_overrun_reason" "text",
    "p_idem_key" "text",
    "p_overrun_type" "text",
    "p_overrun_proof_urls" "text"[]
) TO service_role;

-- Ensure the function owner has proper permissions to bypass RLS
ALTER FUNCTION "public"."finish_work_session_idem_v1" OWNER TO postgres;