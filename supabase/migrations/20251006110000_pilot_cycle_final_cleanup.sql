-- Final migration for pilot cycle system
-- This combines all necessary pilot cycle changes into one clean migration

-- 1. Add pilot warning columns to order_lines (if not exists)
-- Note: These columns may already exist in production from staging
-- Check and add pilot_warning_level if not exists
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'order_lines'
        AND column_name = 'pilot_warning_level'
    ) THEN
        ALTER TABLE order_lines
        ADD COLUMN pilot_warning_level INTEGER DEFAULT 0
        CHECK (pilot_warning_level IN (0, 1, 2));

        COMMENT ON COLUMN order_lines.pilot_warning_level IS 'Mức cảnh báo chu kỳ online pilot: 0=none, 1=warning (5 ngày), 2=blocked (6 ngày). Chỉ áp dụng cho pilot orders đang hoạt động';
    END IF;
END $$;

-- Check and add pilot_is_blocked if not exists
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'order_lines'
        AND column_name = 'pilot_is_blocked'
    ) THEN
        ALTER TABLE order_lines
        ADD COLUMN pilot_is_blocked BOOLEAN DEFAULT FALSE;

        COMMENT ON COLUMN order_lines.pilot_is_blocked IS 'Khóa gán đơn hàng mới khi = TRUE (>= 6 ngày online). Chỉ áp dụng cho pilot orders đang hoạt động';
    END IF;
END $$;

-- Check and add pilot_cycle_start_at if not exists
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'order_lines'
        AND column_name = 'pilot_cycle_start_at'
    ) THEN
        ALTER TABLE order_lines
        ADD COLUMN pilot_cycle_start_at TIMESTAMP WITH TIME ZONE;

        COMMENT ON COLUMN order_lines.pilot_cycle_start_at IS 'Thời gian bắt đầu chu kỳ online hiện tại. Reset khi đủ điều kiện nghỉ.';

        -- Initialize pilot_cycle_start_at for existing pilot orders
        -- For completed orders: use NULL (no cycle needed)
        -- For active orders: use a more recent start point to avoid immediate warnings
        UPDATE order_lines
        SET pilot_cycle_start_at = o_cases.pilot_cycle_start_at
        FROM (
            SELECT
                ol.id,
                CASE
                    -- Completed/cancelled orders: no cycle needed
                    WHEN o.status IN ('completed', 'cancelled', 'delivered', 'pending_completion') THEN NULL
                    -- For active pilot orders, start from a reasonable recent time
                    -- to avoid immediate warnings for existing orders
                    WHEN pv.display_name = 'Service - Pilot' THEN
                        CASE
                            -- If recently created (last 3 days), use created_at
                            WHEN o.created_at >= NOW() - INTERVAL '3 days' THEN o.created_at
                            -- If older, start from 3 days ago to give grace period
                            ELSE NOW() - INTERVAL '3 days'
                        END
                    -- Non-pilot orders: use created_at
                    ELSE o.created_at
                END as pilot_cycle_start_at
            FROM order_lines ol
            JOIN orders o ON ol.order_id = o.id
            JOIN product_variants pv ON ol.variant_id = pv.id
            WHERE ol.pilot_cycle_start_at IS NULL
        ) AS o_cases
        WHERE order_lines.id = o_cases.id;
    END IF;
END $$;

-- 2. Create pilot cycle management functions (consolidated)
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
    FROM orders o
    JOIN order_lines ol ON o.id = ol.order_id
    JOIN product_variants pv ON ol.variant_id = pv.id
    WHERE ol.id = p_order_line_id;

    -- Only process pilot orders
    IF v_service_type != 'Service - Pilot' THEN
        RETURN;
    END IF;

    -- Skip completed orders
    IF v_order_status IN ('completed', 'cancelled', 'delivered', 'pending_completion') THEN
        RETURN;
    END IF;

    -- Calculate online hours từ thời gian bắt đầu chu kỳ hiện tại
    IF v_current_paused_at IS NOT NULL THEN
        -- Currently resting
        v_hours_online := EXTRACT(EPOCH FROM (v_current_paused_at - v_cycle_start_at)) / 3600;
    ELSE
        -- Currently online
        v_hours_online := EXTRACT(EPOCH FROM (NOW() - v_cycle_start_at)) / 3600;
    END IF;

    -- Update warning level
    UPDATE order_lines
    SET
        pilot_warning_level = CASE
            WHEN v_hours_online >= 6 * 24 THEN 2  -- >= 6 days
            WHEN v_hours_online >= 5 * 24 THEN 1  -- >= 5 days
            ELSE 0
        END,
        pilot_is_blocked = (v_hours_online >= 6 * 24)
    WHERE id = p_order_line_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

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
    FROM orders o
    JOIN order_lines ol ON o.id = ol.order_id
    JOIN product_variants pv ON ol.variant_id = pv.id
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
        RETURN; -- Not resting, no reset needed
    END IF;

    -- Calculate online and rest hours từ thời gian bắt đầu chu kỳ hiện tại
    v_hours_online := EXTRACT(EPOCH FROM (v_current_paused_at - v_cycle_start_at)) / 3600;
    v_hours_rest := EXTRACT(EPOCH FROM (NOW() - v_current_paused_at)) / 3600;

    -- Determine required rest hours
    v_required_rest_hours := CASE
        WHEN v_hours_online <= 4 * 24 THEN 6  -- <= 4 days: 6 hours
        ELSE 12  -- > 4 days: 12 hours
    END;

    -- Reset if enough rest
    IF v_hours_rest >= v_required_rest_hours THEN
        UPDATE order_lines
        SET
            pilot_warning_level = 0,
            pilot_is_blocked = FALSE,
            pilot_cycle_start_at = NOW()  -- Reset thời gian bắt đầu chu kỳ mới!
        WHERE id = p_order_line_id;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Update get_boosting_orders_v3 to include pilot warning fields
DROP FUNCTION IF EXISTS public.get_boosting_orders_v3(
  p_limit integer,
  p_offset integer,
  p_channels text[],
  p_statuses text[],
  p_service_types text[],
  p_package_types text[],
  p_customer_name text,
  p_assignee text,
  p_delivery_status text,
  p_review_status text
);

CREATE FUNCTION public.get_boosting_orders_v3(
  p_limit integer DEFAULT 50,
  p_offset integer DEFAULT 0,
  p_channels text[] DEFAULT NULL::text[],
  p_statuses text[] DEFAULT NULL::text[],
  p_service_types text[] DEFAULT NULL::text[],
  p_package_types text[] DEFAULT NULL::text[],
  p_customer_name text DEFAULT NULL::text,
  p_assignee text DEFAULT NULL::text,
  p_delivery_status text DEFAULT NULL::text,
  p_review_status text DEFAULT NULL::text
)
RETURNS TABLE(
  id uuid,
  order_id uuid,
  created_at timestamp with time zone,
  updated_at timestamp with time zone,
  status text,
  channel_code text,
  customer_name text,
  deadline timestamp with time zone,
  btag text,
  login_id text,
  login_pwd text,
  service_type text,
  package_type text,
  package_note text,
  assignees_text text,
  service_items jsonb,
  review_id uuid,
  machine_info text,
  paused_at timestamp with time zone,
  delivered_at timestamp with time zone,
  action_proof_urls text[],
  pilot_warning_level integer,
  pilot_is_blocked boolean,
  pilot_cycle_start_at timestamp with time zone,
  total_count bigint
)
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path TO 'public'
AS $$
  WITH active_farmers AS (
    SELECT
      ws.order_line_id,
      STRING_AGG(p.display_name, ', ') as farmer_names
    FROM public.work_sessions ws
    JOIN public.profiles p ON ws.farmer_id = p.id
    WHERE ws.ended_at IS NULL
    GROUP BY ws.order_line_id
  ),
  line_items AS (
    SELECT
      osi.order_line_id,
      jsonb_agg(
        jsonb_build_object(
          'id', osi.id,
          'kind_code', a_kind.code,
          'kind_name', a_kind.name,
          'params', osi.params,
          'plan_qty', osi.plan_qty,
          'done_qty', osi.done_qty,
          'active_report_id', (SELECT sr.id FROM service_reports sr WHERE sr.order_service_item_id = osi.id AND sr.status = 'new' LIMIT 1)
        ) ORDER BY a_kind.name
      ) AS items
    FROM public.order_service_items osi
    JOIN public.attributes a_kind ON osi.service_kind_id = a_kind.id
    GROUP BY osi.order_line_id
  ),
  base_query AS (
    SELECT
      ol.id,
      o.id as order_id,
      o.created_at,
      o.updated_at,
      o.status,
      ch.code as channel_code,
      p.name as customer_name,
      ol.deadline_to as deadline,
      ca.btag,
      ca.login_id,
      ca.login_pwd,
      pv.display_name as service_type,
      o.package_type,
      o.package_note,
      af.farmer_names as assignees_text,
      li.items as service_items,
      (SELECT r.id FROM public.order_reviews r WHERE r.order_line_id = ol.id LIMIT 1) as review_id,
      ol.machine_info,
      ol.paused_at,
      o.delivered_at,
      ol.action_proof_urls,
      -- Add pilot warning fields
      COALESCE(ol.pilot_warning_level, 0) as pilot_warning_level,
      COALESCE(ol.pilot_is_blocked, FALSE) as pilot_is_blocked,
      COALESCE(ol.pilot_cycle_start_at, o.created_at) as pilot_cycle_start_at,
      -- Add sorting columns for ORDER BY (using old rule with customer_playing before pending_completion)
      CASE o.status
        WHEN 'new' THEN 1
        WHEN 'in_progress' THEN 2
        WHEN 'pending_pilot' THEN 3
        WHEN 'paused_selfplay' THEN 4
        WHEN 'customer_playing' THEN 5
        WHEN 'pending_completion' THEN 6
        WHEN 'completed' THEN 7
        WHEN 'cancelled' THEN 8
        ELSE 99
      END as status_order
    FROM public.order_lines ol
    JOIN public.orders o ON ol.order_id = o.id
    JOIN public.parties p ON o.party_id = p.id
    LEFT JOIN public.product_variants pv ON ol.variant_id = pv.id
    LEFT JOIN public.channels ch ON o.channel_id = ch.id
    LEFT JOIN public.customer_accounts ca ON ol.customer_account_id = ca.id
    LEFT JOIN line_items li ON ol.id = li.order_line_id
    LEFT JOIN active_farmers af ON ol.id = af.order_line_id
    WHERE o.game_code = 'DIABLO_4' AND o.status <> 'draft'
      -- Filter by channels
      AND (p_channels IS NULL OR ch.code = ANY(p_channels))
      -- Filter by statuses
      AND (p_statuses IS NULL OR o.status = ANY(p_statuses))
      -- Filter by service types (using display_name from product_variants)
      AND (p_service_types IS NULL OR pv.display_name = ANY(p_service_types))
      -- Filter by package types
      AND (p_package_types IS NULL OR o.package_type = ANY(p_package_types))
      -- Filter by customer name (case-insensitive partial match)
      AND (p_customer_name IS NULL OR LOWER(p.name) LIKE LOWER('%' || p_customer_name || '%'))
      -- Filter by assignee (case-insensitive partial match)
      AND (p_assignee IS NULL OR LOWER(af.farmer_names) LIKE LOWER('%' || p_assignee || '%'))
  ),
  filtered_query AS (
    SELECT * FROM base_query
    -- Additional filtering for delivery status if specified
    WHERE
      CASE
        WHEN p_delivery_status = 'delivered' THEN delivered_at IS NOT NULL
        WHEN p_delivery_status = 'not_delivered' THEN delivered_at IS NULL
        ELSE TRUE
      END
      -- Additional filtering for review status if specified
      AND CASE
        WHEN p_review_status = 'reviewed' THEN review_id IS NOT NULL
        WHEN p_review_status = 'not_reviewed' THEN review_id IS NULL
        ELSE TRUE
      END
  ),
  counted_query AS (
    SELECT *, COUNT(*) OVER() as total_count FROM filtered_query
  )
  SELECT
    id,
    order_id,
    created_at,
    updated_at,
    status,
    channel_code,
    customer_name,
    deadline,
    btag,
    login_id,
    login_pwd,
    service_type,
    package_type,
    package_note,
    assignees_text,
    service_items,
    review_id,
    machine_info,
    paused_at,
    delivered_at,
    action_proof_urls,
    pilot_warning_level,
    pilot_is_blocked,
    pilot_cycle_start_at,
    total_count
  FROM counted_query
  ORDER BY
    -- Same sorting logic as before
    status_order,
    assignees_text ASC NULLS LAST,
    delivered_at ASC NULLS FIRST,
    review_id ASC NULLS FIRST,
    -- Add pilot cycle sorting (non-blocked first, lower warning first)
    pilot_is_blocked ASC NULLS LAST,
    pilot_warning_level ASC NULLS LAST,
    -- For completed orders, prioritize recently completed ones first
    CASE WHEN status = 'completed' THEN updated_at ELSE NULL END DESC NULLS LAST,
    deadline ASC NULLS LAST
  LIMIT p_limit OFFSET p_offset;
$$;

-- 4. Create triggers for automatic pilot cycle management
CREATE OR REPLACE FUNCTION tr_auto_update_pilot_cycle_on_session_end()
RETURNS TRIGGER AS $$
BEGIN
    -- Only update for pilot orders
    IF EXISTS (
        SELECT 1 FROM orders o
        JOIN order_lines ol ON o.id = ol.order_id
        JOIN product_variants pv ON ol.variant_id = pv.id
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
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION tr_auto_update_pilot_cycle_on_pause_change()
RETURNS TRIGGER AS $$
BEGIN
    -- Only update for pilot orders
    IF EXISTS (
        SELECT 1 FROM orders o
        JOIN product_variants pv ON o.id = NEW.order_id
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
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION tr_auto_initialize_pilot_cycle_on_first_session()
RETURNS TRIGGER AS $$
BEGIN
    -- Only update for pilot orders when pilot_cycle_start_at is NULL
    IF EXISTS (
        SELECT 1 FROM orders o
        JOIN order_lines ol ON o.id = ol.order_id
        JOIN product_variants pv ON ol.variant_id = pv.id
        WHERE ol.id = NEW.order_line_id
        AND pv.display_name = 'Service - Pilot'
        AND ol.pilot_cycle_start_at IS NULL
        AND o.status NOT IN ('completed', 'cancelled', 'delivered', 'pending_completion')
    ) THEN
        -- Initialize pilot cycle start time
        UPDATE order_lines
        SET pilot_cycle_start_at = NEW.started_at
        WHERE id = NEW.order_line_id;

        -- Update pilot cycle warning
        PERFORM public.update_pilot_cycle_warning(NEW.order_line_id);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to initialize pilot cycle for new pilot orders
CREATE OR REPLACE FUNCTION tr_auto_initialize_pilot_cycle_on_order_create()
RETURNS TRIGGER AS $$
BEGIN
    -- Only initialize for new pilot orders
    IF EXISTS (
        SELECT 1 FROM product_variants pv
        WHERE pv.id = NEW.variant_id
        AND pv.display_name = 'Service - Pilot'
    ) THEN
        -- Initialize pilot cycle start time to current time
        NEW.pilot_cycle_start_at := NOW();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create the triggers
DROP TRIGGER IF EXISTS tr_pilot_cycle_work_session_end ON public.work_sessions;
CREATE TRIGGER tr_pilot_cycle_work_session_end
    AFTER UPDATE ON public.work_sessions
    FOR EACH ROW
    WHEN (OLD.ended_at IS NULL AND NEW.ended_at IS NOT NULL)
    EXECUTE FUNCTION tr_auto_update_pilot_cycle_on_session_end();

DROP TRIGGER IF EXISTS tr_pilot_cycle_pause_change ON public.order_lines;
CREATE TRIGGER tr_pilot_cycle_pause_change
    AFTER UPDATE ON public.order_lines
    FOR EACH ROW
    WHEN (OLD.paused_at IS DISTINCT FROM NEW.paused_at)
    EXECUTE FUNCTION tr_auto_update_pilot_cycle_on_pause_change();

DROP TRIGGER IF EXISTS tr_pilot_cycle_first_session ON public.work_sessions;
CREATE TRIGGER tr_pilot_cycle_first_session
    AFTER INSERT ON public.work_sessions
    FOR EACH ROW
    WHEN (NEW.ended_at IS NULL)  -- Only for new sessions
    EXECUTE FUNCTION tr_auto_initialize_pilot_cycle_on_first_session();

DROP TRIGGER IF EXISTS tr_pilot_cycle_order_create ON public.order_lines;
CREATE TRIGGER tr_pilot_cycle_order_create
    BEFORE INSERT ON public.order_lines
    FOR EACH ROW
    EXECUTE FUNCTION tr_auto_initialize_pilot_cycle_on_order_create();

-- 5. Grant permissions
GRANT ALL ON FUNCTION public.get_boosting_orders_v3(
  p_limit integer,
  p_offset integer,
  p_channels text[],
  p_statuses text[],
  p_service_types text[],
  p_package_types text[],
  p_customer_name text,
  p_assignee text,
  p_delivery_status text,
  p_review_status text
) TO anon;
GRANT ALL ON FUNCTION public.get_boosting_orders_v3(
  p_limit integer,
  p_offset integer,
  p_channels text[],
  p_statuses text[],
  p_service_types text[],
  p_package_types text[],
  p_customer_name text,
  p_assignee text,
  p_delivery_status text,
  p_review_status text
) TO authenticated;
GRANT ALL ON FUNCTION public.get_boosting_orders_v3(
  p_limit integer,
  p_offset integer,
  p_channels text[],
  p_statuses text[],
  p_service_types text[],
  p_package_types text[],
  p_customer_name text,
  p_assignee text,
  p_delivery_status text,
  p_review_status text
) TO service_role;