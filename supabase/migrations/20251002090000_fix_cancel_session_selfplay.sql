-- Fix cancel_work_session_v1 để set paused_at cho Selfplay
-- Vấn đề: Khi cancel session, paused_at không được set → mất deadline

CREATE OR REPLACE FUNCTION public.cancel_work_session_v1(p_session_id uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
    v_session public.work_sessions%ROWTYPE;
    v_order_line_id UUID;
    v_order_id UUID;
    v_service_type TEXT;
    completed_sessions_count INT;
    v_context jsonb;
BEGIN
    SELECT * INTO v_session FROM public.work_sessions WHERE id = p_session_id;
    IF NOT FOUND THEN RETURN; END IF;

    -- Lấy ngữ cảnh để kiểm tra quyền override
    SELECT jsonb_build_object('game_code', o.game_code, 'business_area_code', 'SERVICE')
    INTO v_context
    FROM public.order_lines ol JOIN public.orders o ON ol.order_id = o.id
    WHERE ol.id = v_session.order_line_id;

    IF v_session.farmer_id <> public.get_current_profile_id() AND NOT has_permission('work_session:override', v_context) THEN
        RAISE EXCEPTION 'Bạn không phải chủ phiên và không có quyền can thiệp.';
    END IF;

    v_order_line_id := v_session.order_line_id;

    -- ✅ FIX: Lấy service_type từ product_variants.display_name thay vì attributes
    SELECT
        ol.order_id,
        pv.display_name
    INTO
        v_order_id,
        v_service_type
    FROM public.order_lines ol
    LEFT JOIN public.product_variants pv ON ol.variant_id = pv.id
    WHERE ol.id = v_order_line_id;

    -- ✅ FIX: Dùng tên đúng 'Service-Selfplay' và luôn set paused_at khi cancel
    IF v_service_type = 'Service-Selfplay' THEN
        -- Hoàn lại deadline nếu đã cộng khi start
        IF v_session.unpaused_duration IS NOT NULL THEN
            UPDATE public.order_lines
            SET
                deadline_to = deadline_to - v_session.unpaused_duration,
                total_paused_duration = total_paused_duration - v_session.unpaused_duration
            WHERE id = v_order_line_id;
        END IF;

        -- Luôn set paused_at khi cancel session (để bảo toàn deadline)
        UPDATE public.order_lines
        SET paused_at = NOW()
        WHERE id = v_order_line_id;
    END IF;

    DELETE FROM public.work_sessions WHERE id = p_session_id;

    SELECT count(*) INTO completed_sessions_count
    FROM public.work_sessions
    WHERE order_line_id = v_order_line_id AND ended_at IS NOT NULL;

    IF completed_sessions_count > 0 THEN
        IF v_service_type = 'Service-Pilot' THEN
            UPDATE public.orders SET status = 'pending_pilot' WHERE id = v_order_id;
        ELSIF v_service_type = 'Service-Selfplay' THEN
            UPDATE public.orders SET status = 'paused_selfplay' WHERE id = v_order_id;
        END IF;
    ELSE
        UPDATE public.orders SET status = 'new' WHERE id = v_order_id;
    END IF;
END;
$function$;
