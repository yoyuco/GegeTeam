-- Viết lại get_boosting_orders_v4 để hết lỗi timeout 8s (Postgres 57014 -> HTTP 500).
--
-- Đã áp dụng trực tiếp lên production susuoambmzdmcygovkea ngày 2026-09-19.
--
-- VẤN ĐỀ CŨ: hàm dựng CTE line_items (jsonb_agg) cho TOÀN BỘ order_service_items
-- và dùng COUNT(*) OVER() nên phải giữ cả 8000+ dòng trong bộ nhớ, rồi mới LIMIT 50.
-- Hệ quả: mỗi lần gọi đều tràn temp file ra đĩa (temp read=1108 written=687).
-- p50 ~266ms nhưng p99 đụng trần 8s -> 4,3% request trả 500 khi có tải dồn.
--
-- CÁCH SỬA: lọc + phân trang trên tập cột nhẹ trước, chỉ dựng jsonb cho đúng
-- p_limit dòng của trang bằng LEFT JOIN LATERAL. total_count tính riêng bằng
-- một CTE count thay cho window function.
--
-- ĐO ĐƯỢC (trung bình 5 lần, production):
--   trang 1 (offset 0)       182.3ms -> 40.4ms   (4,5x)
--   trang sau (offset 4000)  239.9ms -> 51.6ms   (4,7x)
--   lọc theo status           88.0ms ->  5.3ms  (16,5x)
--   tràn temp file            có     -> không
--
-- TƯƠNG THÍCH: giữ nguyên 10 tham số (kèm DEFAULT) và nguyên 25 cột trả về,
-- nên FRONTEND KHÔNG CẦN SỬA. Dùng CREATE OR REPLACE nên giữ nguyên owner và
-- các quyền EXECUTE đã cấp (anon, authenticated, service_role).
--
-- ĐÃ KIỂM CHỨNG trước khi thay, đối chiếu với hàm cũ trên 8.122 dòng thật:
--   - 24/25 cột khớp tuyệt đối (EXCEPT ALL hai chiều = 0)
--   - service_items khớp tuyệt đối về nội dung và số phần tử
--   - 10 tổ hợp bộ lọc (status / delivery / review / customer_name / assignee /
--     package_type / offset sâu / offset vượt biên) đều cho cùng số dòng
--
-- THAY ĐỔI HÀNH VI DUY NHẤT: thêm tiêu chí sắp xếp phụ để thứ tự ổn định.
--   - jsonb_agg(... ORDER BY a_kind.name, osi.id)  -- thêm osi.id
--   - ORDER BY ..., ol.id                          -- thêm ol.id
-- Trước đây khi trùng khoá sắp xếp, thứ tự phụ thuộc vị trí vật lý của dòng nên
-- có thể đổi bất cứ lúc nào planner đổi kế hoạch (và đã đổi sau khi chạy ANALYZE).
-- Ảnh hưởng: thứ tự phần tử trong service_items của ~325/8122 dòng (4%) khác so
-- với trước. Nội dung không đổi. Đổi lại, phân trang hết bị trùng/sót dòng ở
-- ranh giới trang khi có bản ghi trùng khoá sắp xếp.

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
  WITH filtered AS (
    -- Chỉ lấy các cột cần cho lọc và sắp xếp. Không đụng jsonb ở bước này.
    SELECT ol.id AS ol_id, o.status AS f_status, o.delivered_at AS f_delivered_at,
           mv.farmer_names AS f_assignees, o.updated_at AS f_updated_at, ol.deadline_to AS f_deadline
    FROM order_lines ol
    JOIN orders o ON ol.order_id = o.id
    JOIN parties p ON o.party_id = p.id
    LEFT JOIN product_variants pv ON ol.variant_id = pv.id
    LEFT JOIN mv_active_farmers mv ON ol.id = mv.order_line_id
    WHERE o.game_code = 'DIABLO_4' AND o.status <> 'draft'
      AND (p_channels IS NULL OR o.channel_id = ANY(p_channels))
      AND (p_statuses IS NULL OR o.status = ANY(p_statuses))
      AND (p_service_types IS NULL OR pv.display_name = ANY(p_service_types))
      AND (p_package_types IS NULL OR o.package_type = ANY(p_package_types))
      AND (p_customer_name IS NULL OR LOWER(p.name) LIKE LOWER('%' || TRIM(p_customer_name) || '%'))
      AND (p_assignee IS NULL OR (mv.farmer_names IS NOT NULL AND LOWER(mv.farmer_names) LIKE LOWER('%' || TRIM(p_assignee) || '%')))
      AND CASE WHEN p_delivery_status = 'delivered' THEN o.delivered_at IS NOT NULL
               WHEN p_delivery_status = 'not_delivered' THEN o.delivered_at IS NULL ELSE TRUE END
      -- EXISTS thay cho subquery lấy id: tương đương về logic, rẻ hơn nhiều
      AND CASE WHEN p_review_status = 'reviewed' THEN EXISTS (SELECT 1 FROM order_reviews r WHERE r.order_line_id = ol.id)
               WHEN p_review_status = 'not_reviewed' THEN NOT EXISTS (SELECT 1 FROM order_reviews r WHERE r.order_line_id = ol.id)
               ELSE TRUE END
  ),
  -- Thay cho COUNT(*) OVER() vốn buộc phải giữ cả 8000+ dòng kèm jsonb trong bộ nhớ
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
         mv.farmer_names, COALESCE(li.items, '[]'::jsonb),
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
  LEFT JOIN mv_active_farmers mv ON ol.id = mv.order_line_id
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
           o.delivered_at ASC NULLS FIRST, mv.farmer_names ASC NULLS LAST,
           o.updated_at DESC NULLS LAST, ol.deadline_to ASC NULLS LAST, ol.id;
END;
$function$;
