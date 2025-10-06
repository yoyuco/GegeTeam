-- Add pilot cycle fields to get_boosting_order_detail_v1 function
-- This ensures the drawer gets correct pilot cycle data from database

CREATE OR REPLACE FUNCTION "public"."get_boosting_order_detail_v1"("p_line_id" "uuid") RETURNS json
    LANGUAGE "sql" STABLE
    SET "search_path" TO 'public'
    AS $$
  SELECT json_build_object(
    'id', ol.id,
    'line_id', ol.id,
    'order_id', o.id,
    'created_at', o.created_at,
    'updated_at', o.updated_at,
    'status', o.status,
    'channel_code', ch.code,
    'customer_name', p.name,
    'deadline', ol.deadline_to,
    'btag', acc.btag,
    'login_id', acc.login_id,
    'login_pwd', acc.login_pwd,
    'service_type', pv.display_name,
    'package_type', o.package_type,
    'package_note', o.package_note,
    'action_proof_urls', ol.action_proof_urls,
    'machine_info', ol.machine_info,
    'paused_at', ol.paused_at,
    'pilot_warning_level', ol.pilot_warning_level,
    'pilot_is_blocked', ol.pilot_is_blocked,
    'pilot_cycle_start_at', ol.pilot_cycle_start_at,
    'pilot_online_hours', CASE
        WHEN ol.paused_at IS NOT NULL THEN
            EXTRACT(EPOCH FROM (ol.paused_at - COALESCE(ol.pilot_cycle_start_at, o.created_at))) / 3600
        ELSE
            EXTRACT(EPOCH FROM (NOW() - COALESCE(ol.pilot_cycle_start_at, o.created_at))) / 3600
    END,
    'service_items', (
      SELECT json_agg(
        json_build_object(
          'id', si.id,
          'kind_code', k.code,
          'kind_name', k.name,
          'params', si.params,
          'plan_qty', si.plan_qty,
          'done_qty', si.done_qty,
          'active_report_id', (SELECT sr.id FROM service_reports sr WHERE sr.order_service_item_id = si.id AND sr.status = 'new' LIMIT 1)
        )
      )
      FROM public.order_service_items si
      JOIN public.attributes k ON si.service_kind_id = k.id
      WHERE si.order_line_id = ol.id
    ),
    'active_session', (
      SELECT json_build_object(
        'session_id', ws.id,
        'farmer_id', ws.farmer_id,
        'farmer_name', pr.display_name,
        'start_state', ws.start_state
      )
      FROM public.work_sessions ws
      JOIN public.profiles pr ON ws.farmer_id = pr.id
      WHERE ws.order_line_id = ol.id AND ws.ended_at IS NULL
      LIMIT 1
    )
  )
  FROM public.order_lines ol
  JOIN public.orders o ON ol.order_id = o.id
  JOIN public.parties p ON o.party_id = p.id
  LEFT JOIN public.product_variants pv ON ol.variant_id = pv.id
  LEFT JOIN public.channels ch ON o.channel_id = ch.id
  LEFT JOIN public.customer_accounts acc ON ol.customer_account_id = acc.id
  WHERE ol.id = p_line_id;
$$;

-- Update the function owner
ALTER FUNCTION "public"."get_boosting_order_detail_v1"("p_line_id" "uuid") OWNER TO "postgres";

-- Grant permissions
GRANT ALL ON FUNCTION "public"."get_boosting_order_detail_v1"("p_line_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_boosting_order_detail_v1"("p_line_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_boosting_order_detail_v1"("p_line_id" "uuid") TO "service_role";