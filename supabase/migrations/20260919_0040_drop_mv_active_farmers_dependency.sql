-- Bỏ phụ thuộc của get_boosting_orders_v4 vào materialized view mv_active_farmers.
--
-- Đã áp dụng trực tiếp lên production susuoambmzdmcygovkea ngày 2026-09-19.
--
-- VẤN ĐỀ: mv_active_farmers phải được làm mới thủ công bằng refresh_active_farmers(),
-- và frontend gọi hàm đó 356 lần/ngày sau mỗi thao tác phiên làm việc. Cơ chế này
-- vừa tốn một vòng gọi mạng, vừa sinh lỗi hiển thị: nếu quên gọi hoặc gọi sai thứ
-- tự thì bảng hiện tên farmer cũ.
--
-- CÁCH SỬA: thay bằng CTE active_farmers tổng hợp thẳng từ work_sessions.
-- Chỉ quét khoảng 20 phiên đang mở nhờ index từng phần đã có sẵn:
--   idx_work_sessions_order_ended ON work_sessions (order_line_id, ended_at)
--     WHERE (ended_at IS NULL)
-- Không dùng LATERAL ở nhánh filtered vì farmer_names cần cho cả bộ lọc p_assignee
-- lẫn ORDER BY, LATERAL sẽ phải chạy 8.000+ lần. CTE gom một lần rồi LEFT JOIN
-- có chi phí đúng bằng cách join vào MV trước đây.
--
-- ĐO ĐƯỢC (trung bình 5 lần, production, so với bản còn dùng MV):
--   trang 1            45.2ms -> 41.8ms
--   trang sau          56.5ms -> 52.7ms
--   lọc theo assignee   5.2ms ->  5.0ms
-- Tức là ngang bằng về tốc độ, nhưng dữ liệu luôn tươi và bỏ được 356 lượt
-- refresh mỗi ngày.
--
-- KIỂM CHỨNG: sau khi REFRESH MV cho công bằng rồi đối chiếu toàn bộ 25 cột trên
-- 8.237 dòng thật, EXCEPT ALL hai chiều đều bằng 0. Khớp tuyệt đối.
--
-- Chữ ký và 25 cột trả về vẫn giữ nguyên -> frontend không phải đổi cách gọi.

CREATE OR REPLACE FUNCTION public.get_boosting_orders_v4(
  p_limit integer DEFAULT 50,
  p_offset integer DEFAULT 0,
  p_channels uuid[] DEFAULT NULL::uuid[],
  p_statuses text[] DEFAULT NULL::text[],
  p_service_types text[] DEFAULT NULL::text[],
  p_package_types text[] DEFAULT NULL::text[],
  p_customer_name text DEFAULT NULL::text,
  p_assignee text DEFAULT NULL::text,
  p_delivery_status text DEFAULT NULL::text,
  p_review_status text DEFAULT NULL::text)
RETURNS TABLE(
  id uuid, order_id uuid, created_at timestamp with time zone, updated_at timestamp with time zone,
  status text, channel_code text, customer_name text, deadline timestamp with time zone,
  btag text, login_id text, login_pwd text, service_type text, package_type text, package_note text,
  assignees_text text, service_items jsonb, review_id uuid, machine_info text,
  paused_at timestamp with time zone, delivered_at timestamp with time zone, action_proof_urls text[],
  pilot_warning_level integer, pilot_is_blocked boolean, pilot_cycle_start_at timestamp with time zone,
  total_count bigint)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
BEGIN
  RETURN QUERY
  WITH active_farmers AS (
    -- Thay cho mv_active_farmers. Quét ~20 dòng qua idx_work_sessions_order_ended.
    SELECT ws.order_line_id,
           string_agg(DISTINCT pr.display_name, ', ' ORDER BY pr.display_name) AS farmer_names
    FROM work_sessions ws
    JOIN profiles pr ON ws.farmer_id = pr.id
    WHERE ws.ended_at IS NULL
    GROUP BY ws.order_line_id
  ),
  filtered AS (
    -- Chỉ lấy các cột cần cho lọc và sắp xếp. Không đụng jsonb ở bước này.
    SELECT ol.id AS ol_id, o.status AS f_status, o.delivered_at AS f_delivered_at,
           af.farmer_names AS f_assignees, o.updated_at AS f_updated_at, ol.deadline_to AS f_deadline
    FROM order_lines ol
    JOIN orders o ON ol.order_id = o.id
    JOIN parties p ON o.party_id = p.id
    LEFT JOIN product_variants pv ON ol.variant_id = pv.id
    LEFT JOIN active_farmers af ON ol.id = af.order_line_id
    WHERE o.game_code = 'DIABLO_4' AND o.status <> 'draft'
      AND (p_channels IS NULL OR o.channel_id = ANY(p_channels))
      AND (p_statuses IS NULL OR o.status = ANY(p_statuses))
      AND (p_service_types IS NULL OR pv.display_name = ANY(p_service_types))
      AND (p_package_types IS NULL OR o.package_type = ANY(p_package_types))
      AND (p_customer_name IS NULL OR LOWER(p.name) LIKE LOWER('%' || TRIM(p_customer_name) || '%'))
      AND (p_assignee IS NULL OR (af.farmer_names IS NOT NULL AND LOWER(af.farmer_names) LIKE LOWER('%' || TRIM(p_assignee) || '%')))
      AND CASE WHEN p_delivery_status = 'delivered' THEN o.delivered_at IS NOT NULL
               WHEN p_delivery_status = 'not_delivered' THEN o.delivered_at IS NULL ELSE TRUE END
      AND CASE WHEN p_review_status = 'reviewed' THEN EXISTS (SELECT 1 FROM order_reviews r WHERE r.order_line_id = ol.id)
               WHEN p_review_status = 'not_reviewed' THEN NOT EXISTS (SELECT 1 FROM order_reviews r WHERE r.order_line_id = ol.id)
               ELSE TRUE END
  ),
  counted AS (SELECT count(*) AS n FROM filtered),
  page AS (
    SELECT f.ol_id FROM filtered f
    ORDER BY CASE f.f_status WHEN 'new' THEN 1 WHEN 'in_progress' THEN 2 WHEN 'pending_pilot' THEN 3 WHEN 'paused_selfplay' THEN 4 WHEN 'customer_playing' THEN 5 WHEN 'pending_completion' THEN 6 WHEN 'completed' THEN 7 WHEN 'cancelled' THEN 8 ELSE 99 END,
             f.f_delivered_at ASC NULLS FIRST, f.f_assignees ASC NULLS LAST,
             f.f_updated_at DESC NULLS LAST, f.f_deadline ASC NULLS LAST, f.ol_id
    LIMIT p_limit OFFSET p_offset
  )
  SELECT ol.id, ol.order_id, o.created_at, o.updated_at, o.status, ch.code, p.name, ol.deadline_to,
         ca.btag, ca.login_id, ca.login_pwd, pv.display_name, o.package_type, o.package_note,
         af.farmer_names, COALESCE(li.items, '[]'::jsonb),
         (SELECT r.id FROM order_reviews r WHERE r.order_line_id = ol.id LIMIT 1),
         ol.machine_info, ol.paused_at, o.delivered_at, ol.action_proof_urls,
         COALESCE(ol.pilot_warning_level, 0), COALESCE(ol.pilot_is_blocked, FALSE),
         COALESCE(ol.pilot_cycle_start_at, o.created_at), (SELECT n FROM counted)
  FROM page pgx
  JOIN order_lines ol ON ol.id = pgx.ol_id
  JOIN orders o ON ol.order_id = o.id
  JOIN parties p ON o.party_id = p.id
  LEFT JOIN product_variants pv ON ol.variant_id = pv.id
  LEFT JOIN channels ch ON o.channel_id = ch.id
  LEFT JOIN customer_accounts ca ON ol.customer_account_id = ca.id
  LEFT JOIN active_farmers af ON ol.id = af.order_line_id
  -- LATERAL: chỉ chạy cho p_limit dòng của trang, không phải toàn bộ order_service_items
  LEFT JOIN LATERAL (
    SELECT jsonb_agg(jsonb_build_object(
             'id', osi.id, 'kind_code', a_kind.code, 'kind_name', a_kind.name,
             'params', osi.params, 'plan_qty', osi.plan_qty, 'done_qty', osi.done_qty,
             'active_report_id', (SELECT sr.id FROM service_reports sr WHERE sr.order_service_item_id = osi.id AND sr.status = 'new' LIMIT 1)
           ) ORDER BY a_kind.name, osi.id) AS items
    FROM order_service_items osi
    JOIN attributes a_kind ON osi.service_kind_id = a_kind.id
    WHERE osi.order_line_id = ol.id
  ) li ON TRUE
  ORDER BY CASE o.status WHEN 'new' THEN 1 WHEN 'in_progress' THEN 2 WHEN 'pending_pilot' THEN 3 WHEN 'paused_selfplay' THEN 4 WHEN 'customer_playing' THEN 5 WHEN 'pending_completion' THEN 6 WHEN 'completed' THEN 7 WHEN 'cancelled' THEN 8 ELSE 99 END,
           o.delivered_at ASC NULLS FIRST, af.farmer_names ASC NULLS LAST,
           o.updated_at DESC NULLS LAST, ol.deadline_to ASC NULLS LAST, ol.id;
END;
$function$;
