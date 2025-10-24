-- Fix search_path for pilot cycle functions to ensure proper table resolution
-- This prevents issues with table not found errors

-- 1. tr_auto_update_pilot_cycle_on_pause_change trigger function
CREATE OR REPLACE FUNCTION public.tr_auto_update_pilot_cycle_on_pause_change()
RETURNS TRIGGER AS $$
BEGIN
    -- Only update for pilot orders
    IF EXISTS (
        SELECT 1 FROM public.orders o
        JOIN public.product_variants pv ON o.id = NEW.order_id
        WHERE pv.display_name = 'Service - Pilot'
        AND o.status NOT IN ('completed', 'cancelled', 'delivered', 'pending_completion')
    ) THEN
        -- Update pilot cycle warning
        PERFORM public.update_pilot_cycle_warning(NEW.id);

        -- Check and reset if conditions met
        PERFORM public.check_and_reset_pilot_cycle(NEW.id);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public';

-- 2. tr_auto_initialize_pilot_cycle_on_first_session trigger function
CREATE OR REPLACE FUNCTION public.tr_auto_initialize_pilot_cycle_on_first_session()
RETURNS TRIGGER AS $$
BEGIN
    -- Only update for pilot orders when pilot_cycle_start_at is NULL
    IF EXISTS (
        SELECT 1 FROM public.orders o
        JOIN public.order_lines ol ON o.id = ol.order_id
        JOIN public.product_variants pv ON ol.variant_id = pv.id
        WHERE ol.id = NEW.order_line_id
        AND pv.display_name = 'Service - Pilot'
        AND ol.pilot_cycle_start_at IS NULL
        AND o.status NOT IN ('completed', 'cancelled', 'delivered', 'pending_completion')
    ) THEN
        -- Initialize pilot cycle start time
        UPDATE public.order_lines
        SET pilot_cycle_start_at = NEW.started_at
        WHERE id = NEW.order_line_id;

        -- Update pilot cycle warning
        PERFORM public.update_pilot_cycle_warning(NEW.order_line_id);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public';

-- 3. check_and_reset_pilot_cycle function
CREATE OR REPLACE FUNCTION public.check_and_reset_pilot_cycle(p_order_line_id UUID)
RETURNS VOID AS $$
DECLARE
    v_service_type TEXT;
    v_order_status TEXT;
    v_hours_online NUMERIC;
    v_hours_rest NUMERIC;
    v_current_paused_at TIMESTAMP WITH TIME ZONE;
    v_cycle_start_at TIMESTAMP WITH TIME ZONE;
    v_required_rest_hours INTEGER;
BEGIN
    -- Get order information
    SELECT pv.display_name, o.status, ol.paused_at,
           COALESCE(ol.pilot_cycle_start_at, o.created_at) as cycle_start_at
    INTO v_service_type, v_order_status, v_current_paused_at, v_cycle_start_at
    FROM public.orders o
    JOIN public.order_lines ol ON o.id = ol.order_id
    JOIN public.product_variants pv ON ol.variant_id = pv.id
    WHERE ol.id = p_order_line_id;

    -- Only process pilot orders
    IF v_service_type != 'Service - Pilot' THEN
        RETURN;
    END IF;

    -- Skip completed orders
    IF v_order_status IN ('completed', 'cancelled', 'delivered', 'pending_completion') THEN
        RETURN;
    END IF;

    -- Check if currently resting
    IF v_current_paused_at IS NULL THEN
        RETURN;
    END IF;

    -- Calculate online and rest hours
    v_hours_online := EXTRACT(EPOCH FROM (v_current_paused_at - v_cycle_start_at)) / 3600;
    v_hours_rest := EXTRACT(EPOCH FROM (NOW() - v_current_paused_at)) / 3600;

    -- Determine required rest hours
    v_required_rest_hours := CASE
        WHEN v_hours_online <= 4 * 24 THEN 6  -- <= 4 days: 6 hours
        ELSE 12  -- > 4 days: 12 hours
    END;

    -- Reset if enough rest
    IF v_hours_rest >= v_required_rest_hours THEN
        -- Reset pilot cycle
        UPDATE public.order_lines
        SET
            pilot_cycle_start_at = v_current_paused_at,
            pilot_warning_level = 0,
            pilot_is_blocked = FALSE,
            paused_at = NULL
        WHERE id = p_order_line_id;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public';

-- 4. tr_auto_update_pilot_cycle_on_session_end trigger function
CREATE OR REPLACE FUNCTION public.tr_auto_update_pilot_cycle_on_session_end()
RETURNS TRIGGER AS $$
BEGIN
    -- Only update for pilot orders
    IF EXISTS (
        SELECT 1 FROM public.orders o
        JOIN public.order_lines ol ON o.id = ol.order_id
        JOIN public.product_variants pv ON ol.variant_id = pv.id
        WHERE ol.id = NEW.order_line_id
        AND pv.display_name = 'Service - Pilot'
        AND o.status NOT IN ('completed', 'cancelled', 'delivered', 'pending_completion')
    ) THEN
        -- Update pilot cycle warning
        PERFORM public.update_pilot_cycle_warning(NEW.order_line_id);

        -- Check and reset if conditions met
        PERFORM public.check_and_reset_pilot_cycle(NEW.order_line_id);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public';

-- 5. update_pilot_cycle_warning function
CREATE OR REPLACE FUNCTION public.update_pilot_cycle_warning(p_order_line_id UUID)
RETURNS VOID AS $$
DECLARE
    v_service_type TEXT;
    v_order_status TEXT;
    v_pilot_is_blocked BOOLEAN;
    v_pilot_warning_level INTEGER;
    v_hours_online NUMERIC;
    v_current_paused_at TIMESTAMP WITH TIME ZONE;
    v_cycle_start_at TIMESTAMP WITH TIME ZONE;
BEGIN
    -- Get order information
    SELECT pv.display_name, o.status, ol.pilot_is_blocked, ol.pilot_warning_level, ol.paused_at,
           COALESCE(ol.pilot_cycle_start_at, o.created_at) as cycle_start_at
    INTO v_service_type, v_order_status, v_pilot_is_blocked, v_pilot_warning_level, v_current_paused_at, v_cycle_start_at
    FROM public.orders o
    JOIN public.order_lines ol ON o.id = ol.order_id
    JOIN public.product_variants pv ON ol.variant_id = pv.id
    WHERE ol.id = p_order_line_id;

    -- Only process pilot orders
    IF v_service_type != 'Service - Pilot' THEN
        RETURN;
    END IF;

    -- Skip completed orders
    IF v_order_status IN ('completed', 'cancelled', 'delivered', 'pending_completion') THEN
        RETURN;
    END IF;

    -- Calculate online hours from current cycle start time
    IF v_current_paused_at IS NOT NULL THEN
        -- Currently resting
        v_hours_online := EXTRACT(EPOCH FROM (v_current_paused_at - v_cycle_start_at)) / 3600;
    ELSE
        -- Currently online
        v_hours_online := EXTRACT(EPOCH FROM (NOW() - v_cycle_start_at)) / 3600;
    END IF;

    -- Update warning level
    UPDATE public.order_lines
    SET
        pilot_warning_level = CASE
            WHEN v_hours_online >= 6 * 24 THEN 2  -- >= 6 days
            WHEN v_hours_online >= 5 * 24 THEN 1  -- >= 5 days
            ELSE 0
        END,
        pilot_is_blocked = (v_hours_online >= 6 * 24)
    WHERE id = p_order_line_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public';

-- 6. tr_auto_initialize_pilot_cycle_on_order_create trigger function
CREATE OR REPLACE FUNCTION public.tr_auto_initialize_pilot_cycle_on_order_create()
RETURNS TRIGGER AS $$
BEGIN
    -- Only initialize for new pilot orders
    IF EXISTS (
        SELECT 1 FROM public.product_variants pv
        WHERE pv.id = NEW.variant_id
        AND pv.display_name = 'Service - Pilot'
    ) THEN
        -- Initialize pilot cycle start time to current time
        NEW.pilot_cycle_start_at := NOW();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public';

-- Recreate triggers with proper search_path
DROP TRIGGER IF EXISTS tr_auto_update_pilot_cycle_on_pause_change ON public.order_lines;
CREATE TRIGGER tr_auto_update_pilot_cycle_on_pause_change
    AFTER UPDATE OF paused_at ON public.order_lines
    FOR EACH ROW
    WHEN (OLD.paused_at IS DISTINCT FROM NEW.paused_at)
    EXECUTE FUNCTION public.tr_auto_update_pilot_cycle_on_pause_change();

DROP TRIGGER IF EXISTS tr_auto_initialize_pilot_cycle_on_first_session ON public.work_sessions;
CREATE TRIGGER tr_auto_initialize_pilot_cycle_on_first_session
    AFTER INSERT ON public.work_sessions
    FOR EACH ROW
    EXECUTE FUNCTION public.tr_auto_initialize_pilot_cycle_on_first_session();

DROP TRIGGER IF EXISTS tr_auto_update_pilot_cycle_on_session_end ON public.work_sessions;
CREATE TRIGGER tr_auto_update_pilot_cycle_on_session_end
    AFTER UPDATE OF ended_at ON public.work_sessions
    FOR EACH ROW
    WHEN (OLD.ended_at IS NULL AND NEW.ended_at IS NOT NULL)
    EXECUTE FUNCTION public.tr_auto_update_pilot_cycle_on_session_end();

DROP TRIGGER IF EXISTS tr_auto_initialize_pilot_cycle_on_order_create ON public.order_lines;
CREATE TRIGGER tr_auto_initialize_pilot_cycle_on_order_create
    AFTER INSERT ON public.order_lines
    FOR EACH ROW
    EXECUTE FUNCTION public.tr_auto_initialize_pilot_cycle_on_order_create();