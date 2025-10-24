-- Update get_boosting_orders_v3 to prioritize recently completed orders before deadline sorting
CREATE OR REPLACE FUNCTION public.get_boosting_orders_v3(p_limit integer DEFAULT 50, p_offset integer DEFAULT 0, p_channels text[] DEFAULT NULL::text[], p_statuses text[] DEFAULT NULL::text[], p_service_types text[] DEFAULT NULL::text[], p_package_types text[] DEFAULT NULL::text[], p_customer_name text DEFAULT NULL::text, p_assignee text DEFAULT NULL::text, p_delivery_status text DEFAULT NULL::text, p_review_status text DEFAULT NULL::text)
 RETURNS TABLE(id uuid, order_id uuid, created_at timestamp with time zone, updated_at timestamp with time zone, status text, channel_code text, customer_name text, deadline timestamp with time zone, btag text, login_id text, login_pwd text, service_type text, package_type text, package_note text, assignees_text text, service_items jsonb, review_id uuid, machine_info text, paused_at timestamp with time zone, delivered_at timestamp with time zone, action_proof_urls text[], total_count bigint)
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
      -- Filter by review status (using subquery for review_id)
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
    -- Same sorting logic as before
    bq.status_order,
    bq.assignees_text ASC NULLS LAST,
    bq.delivered_at ASC NULLS FIRST,
    bq.review_id ASC NULLS FIRST,
    -- For completed orders, prioritize recently completed ones first
    CASE WHEN bq.status = 'completed' THEN bq.updated_at ELSE NULL END DESC NULLS LAST,
    bq.deadline ASC NULLS LAST
  LIMIT p_limit
  OFFSET p_offset;
$function$;
