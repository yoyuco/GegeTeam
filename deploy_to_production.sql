-- =============================================================================
-- DEPLOY TO PRODUCTION - SUPABASE DATABASE FUNCTIONS
-- =============================================================================
-- Production Project ID: susuoambmzdmcygovkea
-- Date: 2025-10-02
-- Purpose: Deploy critical database functions from staging to production
--
-- INSTRUCTIONS:
-- 1. Open Supabase Dashboard for production project
-- 2. Navigate to SQL Editor
-- 3. Copy and paste this entire file
-- 4. Execute the SQL
-- 5. Verify functions are created successfully
-- =============================================================================

-- -----------------------------------------------------------------------------
-- FUNCTION 1: get_customers_by_channel_v1
-- Purpose: Get distinct customer names by channel code
-- Used by: Sales page for customer filtering
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.get_customers_by_channel_v1(p_channel_code text)
 RETURNS TABLE(name text)
 LANGUAGE sql
 STABLE
 SET search_path TO 'public'
AS $function$
  SELECT DISTINCT p.name
  FROM public.parties p
  JOIN public.orders o ON o.party_id = p.id
  JOIN public.channels c ON o.channel_id = c.id
  WHERE c.code = p_channel_code AND p.type = 'customer'
  ORDER BY p.name;
$function$;

-- -----------------------------------------------------------------------------
-- FUNCTION 2: create_service_order_v1
-- Purpose: Create a new service order with customer account
-- Used by: Order creation workflow
-- Parameters:
--   - p_channel_code: Channel identifier (e.g., 'FACEBOOK', 'WEBSITE')
--   - p_customer_name: Customer name
--   - p_package_type: Package type
--   - p_package_note: Package notes
--   - p_deadline: Deadline timestamp
--   - p_service_type: Service type (e.g., 'Service-Pilot', 'Service-Selfplay')
--   - p_btag: Battle tag
--   - p_login_id: Login ID
--   - p_login_pwd: Login password
--   - p_machine_info: Machine information
--   - p_service_items: Service items as JSONB array
--   - p_action_proof_urls: Proof URLs array
-- Returns: UUID of created order_line
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.create_service_order_v1(
  p_channel_code text,
  p_customer_name text,
  p_package_type text,
  p_package_note text,
  p_deadline timestamp with time zone,
  p_service_type text,
  p_btag text,
  p_login_id text,
  p_login_pwd text,
  p_machine_info text,
  p_service_items jsonb,
  p_action_proof_urls text[]
)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_channel_id UUID;
  v_party_id UUID;
  v_order_id UUID;
  v_variant_id UUID;
  v_line_id UUID;
  v_account_id UUID;
  v_item JSONB;
  v_kind_id UUID;
  v_service_item_id UUID;
  v_context jsonb;
BEGIN
  -- Validate permissions
  SELECT jsonb_build_object('game_code', 'DIABLO_4', 'business_area_code', 'SERVICE')
  INTO v_context;

  IF NOT has_permission('order:create', v_context) THEN
    RAISE EXCEPTION 'Bạn không có quyền tạo đơn hàng.';
  END IF;

  -- Get channel ID
  SELECT id INTO v_channel_id FROM public.channels WHERE code = p_channel_code;
  IF v_channel_id IS NULL THEN RAISE EXCEPTION 'Channel % không tồn tại', p_channel_code; END IF;

  -- Get or create party (customer)
  SELECT id INTO v_party_id FROM public.parties WHERE name = p_customer_name AND type = 'customer';
  IF v_party_id IS NULL THEN
    INSERT INTO public.parties (name, type) VALUES (p_customer_name, 'customer') RETURNING id INTO v_party_id;
  END IF;

  -- Get variant ID based on service type
  SELECT id INTO v_variant_id FROM public.product_variants WHERE display_name = p_service_type;
  IF v_variant_id IS NULL THEN RAISE EXCEPTION 'Service type % không tồn tại', p_service_type; END IF;

  -- Create order
  INSERT INTO public.orders (
    game_code,
    channel_id,
    party_id,
    status,
    package_type,
    package_note
  ) VALUES (
    'DIABLO_4',
    v_channel_id,
    v_party_id,
    'new',
    p_package_type,
    p_package_note
  ) RETURNING id INTO v_order_id;

  -- Create customer account
  INSERT INTO public.customer_accounts (btag, login_id, login_pwd)
  VALUES (p_btag, p_login_id, p_login_pwd)
  RETURNING id INTO v_account_id;

  -- Create order line
  INSERT INTO public.order_lines (
    order_id,
    variant_id,
    customer_account_id,
    deadline_to,
    machine_info,
    action_proof_urls
  ) VALUES (
    v_order_id,
    v_variant_id,
    v_account_id,
    p_deadline,
    p_machine_info,
    p_action_proof_urls
  ) RETURNING id INTO v_line_id;

  -- Create service items
  FOR v_item IN SELECT * FROM jsonb_array_elements(p_service_items)
  LOOP
    -- Get service kind ID
    SELECT id INTO v_kind_id
    FROM public.attributes
    WHERE code = (v_item->>'kind_code')::text
      AND category = 'service_kind';

    IF v_kind_id IS NULL THEN
      RAISE EXCEPTION 'Service kind % không tồn tại', (v_item->>'kind_code')::text;
    END IF;

    -- Insert service item
    INSERT INTO public.order_service_items (
      order_line_id,
      service_kind_id,
      params,
      plan_qty
    ) VALUES (
      v_line_id,
      v_kind_id,
      (v_item->'params')::jsonb,
      (v_item->>'plan_qty')::integer
    );
  END LOOP;

  RETURN v_line_id;
END;
$function$;

-- -----------------------------------------------------------------------------
-- FUNCTION 3: cancel_work_session_v1
-- Purpose: Cancel a work session and restore deadline for Selfplay services
-- Used by: Session management workflow
-- Fix: Properly sets paused_at when canceling Selfplay sessions
-- Parameters:
--   - p_session_id: UUID of the work session to cancel
-- Returns: void
-- -----------------------------------------------------------------------------
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

    -- Get context for permission check
    SELECT jsonb_build_object('game_code', o.game_code, 'business_area_code', 'SERVICE')
    INTO v_context
    FROM public.order_lines ol JOIN public.orders o ON ol.order_id = o.id
    WHERE ol.id = v_session.order_line_id;

    IF v_session.farmer_id <> public.get_current_profile_id() AND NOT has_permission('work_session:override', v_context) THEN
        RAISE EXCEPTION 'Bạn không phải chủ phiên và không có quyền can thiệp.';
    END IF;

    v_order_line_id := v_session.order_line_id;

    -- Get service_type from product_variants.display_name
    SELECT
        ol.order_id,
        pv.display_name
    INTO
        v_order_id,
        v_service_type
    FROM public.order_lines ol
    LEFT JOIN public.product_variants pv ON ol.variant_id = pv.id
    WHERE ol.id = v_order_line_id;

    -- Handle Selfplay deadline restoration
    IF v_service_type = 'Service-Selfplay' THEN
        -- Restore deadline if it was extended when session started
        IF v_session.unpaused_duration IS NOT NULL THEN
            UPDATE public.order_lines
            SET
                deadline_to = deadline_to - v_session.unpaused_duration,
                total_paused_duration = total_paused_duration - v_session.unpaused_duration
            WHERE id = v_order_line_id;
        END IF;

        -- Always set paused_at when canceling session (to preserve deadline)
        UPDATE public.order_lines
        SET paused_at = NOW()
        WHERE id = v_order_line_id;
    END IF;

    -- Delete the session
    DELETE FROM public.work_sessions WHERE id = p_session_id;

    -- Count completed sessions
    SELECT count(*) INTO completed_sessions_count
    FROM public.work_sessions
    WHERE order_line_id = v_order_line_id AND ended_at IS NOT NULL;

    -- Update order status based on service type and completion state
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

-- -----------------------------------------------------------------------------
-- FUNCTION 4: get_boosting_orders_v3
-- Purpose: Get boosting orders with server-side pagination and filtering
-- Used by: ServiceBoosting page with realtime updates
-- New in v3: Adds pagination, filtering, and total_count
-- Parameters:
--   - p_limit: Number of records to return (default 50)
--   - p_offset: Offset for pagination (default 0)
--   - p_channels: Array of channel codes to filter (optional)
--   - p_statuses: Array of order statuses to filter (optional)
--   - p_service_types: Array of service types to filter (optional)
--   - p_package_types: Array of package types to filter (optional)
--   - p_customer_name: Customer name search (optional, case-insensitive)
--   - p_assignee: Assignee name search (optional, case-insensitive)
--   - p_delivery_status: Delivery status filter (optional: 'delivered', 'not_delivered')
--   - p_review_status: Review status filter (optional: 'reviewed', 'not_reviewed')
-- Returns: Table with order data including total_count for pagination
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.get_boosting_orders_v3(
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
   total_count bigint
 )
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
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
      -- Add sorting columns for ORDER BY
      CASE o.status
        WHEN 'new' THEN 1
        WHEN 'in_progress' THEN 2
        WHEN 'pending_pilot' THEN 3
        WHEN 'paused_selfplay' THEN 4
        WHEN 'pending_completion' THEN 5
        WHEN 'completed' THEN 6
        WHEN 'cancelled' THEN 7
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
      -- Filter by service types
      AND (p_service_types IS NULL OR pv.display_name = ANY(p_service_types))
      -- Filter by package types
      AND (p_package_types IS NULL OR o.package_type = ANY(p_package_types))
      -- Filter by customer name (case-insensitive LIKE)
      AND (p_customer_name IS NULL OR LOWER(p.name) LIKE '%' || LOWER(p_customer_name) || '%')
      -- Filter by assignee (case-insensitive LIKE)
      AND (p_assignee IS NULL OR LOWER(af.farmer_names) LIKE '%' || LOWER(p_assignee) || '%')
      -- Filter by delivery status
      AND (
        p_delivery_status IS NULL OR
        (p_delivery_status = 'delivered' AND o.delivered_at IS NOT NULL) OR
        (p_delivery_status = 'not_delivered' AND o.delivered_at IS NULL)
      )
      -- Filter by review status
      AND (
        p_review_status IS NULL OR
        (p_review_status = 'reviewed' AND EXISTS (SELECT 1 FROM public.order_reviews r WHERE r.order_line_id = ol.id)) OR
        (p_review_status = 'not_reviewed' AND NOT EXISTS (SELECT 1 FROM public.order_reviews r WHERE r.order_line_id = ol.id))
      )
  ),
  total AS (
    SELECT COUNT(*) as cnt FROM base_query
  )
  SELECT
    bq.id,
    bq.order_id,
    bq.created_at,
    bq.updated_at,
    bq.status,
    bq.channel_code,
    bq.customer_name,
    bq.deadline,
    bq.btag,
    bq.login_id,
    bq.login_pwd,
    bq.service_type,
    bq.package_type,
    bq.package_note,
    bq.assignees_text,
    bq.service_items,
    bq.review_id,
    bq.machine_info,
    bq.paused_at,
    bq.delivered_at,
    bq.action_proof_urls,
    t.cnt as total_count
  FROM base_query bq
  CROSS JOIN total t
  ORDER BY
    bq.status_order,
    bq.assignees_text ASC NULLS LAST,
    bq.delivered_at ASC NULLS FIRST,
    bq.review_id ASC NULLS FIRST,
    bq.deadline ASC NULLS LAST
  LIMIT p_limit
  OFFSET p_offset;
$function$;

-- =============================================================================
-- DEPLOYMENT COMPLETE
-- =============================================================================
-- Next steps:
-- 1. Verify all 4 functions are created: SELECT * FROM pg_proc WHERE proname LIKE '%_v%';
-- 2. Test each function with sample data
-- 3. Update frontend to use these functions
-- 4. Monitor performance and error logs
-- =============================================================================
