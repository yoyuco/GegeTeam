-- Công cụ dọn storage + siết loại file cho bucket work-proofs.
--
-- Đã áp dụng trực tiếp lên production susuoambmzdmcygovkea ngày 2026-09-19.
--
-- BỐI CẢNH: bucket work-proofs đạt 83 GB / 36.532 file, trong đó 35.811 file PNG
-- chiếm 82 GB (trung bình 2.405 kB mỗi file). 77 file WebP sẵn có trong cùng bucket
-- chỉ trung bình 185 kB — nhỏ hơn 13 lần. Kích thước trung bình còn đang phình:
-- 747 kB (03/2026) -> 4.266 kB (09/2026). Gói Pro bao gồm 100 GB.
--
-- 1. storage_cleanup_candidates()
--    Liệt kê file đủ điều kiện dọn. KHÔNG xoá gì, chỉ trả về danh sách.
--    Chỉ service_role gọi được.
--
--    Xoá THẬT phải qua Storage API, dùng scripts/cleanup-storage.mjs.
--    Xoá dòng trong storage.objects bằng SQL chỉ làm mất dấu vết mà KHÔNG xoá
--    file dưới S3 — dung lượng không giảm, file thành rác vĩnh viễn.
--
-- 2. Siết bucket work-proofs
--    allowed_mime_types: trước là NULL (nhận mọi loại file tới 50 MB). Bucket này
--    đang để public, và đã có một file .exe 4 MB được tải lên ngày 13/12/2025
--    (57c2e7d8-.../cancellation/1765624407746_4dqx3e623d.exe), cùng một .py và một
--    .filter. Public + nhận mọi mime type = tên miền Supabase của dự án vô tình
--    thành nơi phát tán file thực thi.
--    file_size_limit: 50 MB -> 10 MB. Sau khi frontend nén WebP thì ảnh chụp màn
--    hình chỉ còn khoảng 200 kB, 10 MB vẫn quá thoải mái.

CREATE OR REPLACE FUNCTION public.storage_cleanup_candidates(
  p_bucket text DEFAULT 'work-proofs',
  p_older_than interval DEFAULT '3 months',
  p_include_orphans boolean DEFAULT true)
RETURNS TABLE(duong_dan text, kich_thuoc bigint, ngay_tao timestamptz, ly_do text)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public','storage'
AS $function$
BEGIN
  RETURN QUERY
  WITH duoc_tham_chieu AS (
    SELECT unnest(action_proof_urls) AS u FROM order_lines WHERE action_proof_urls IS NOT NULL
    UNION ALL SELECT unnest(proof_urls) FROM order_reviews WHERE proof_urls IS NOT NULL
    UNION ALL SELECT unnest(current_proof_urls) FROM service_reports WHERE current_proof_urls IS NOT NULL
    UNION ALL SELECT disputed_proof_url FROM service_reports WHERE disputed_proof_url IS NOT NULL
    UNION ALL SELECT unnest(overrun_proof_urls) FROM work_sessions WHERE overrun_proof_urls IS NOT NULL
    UNION ALL SELECT proof_url FROM work_session_outputs WHERE proof_url IS NOT NULL
    UNION ALL SELECT start_proof_url FROM work_session_outputs WHERE start_proof_url IS NOT NULL
    UNION ALL SELECT end_proof_url FROM work_session_outputs WHERE end_proof_url IS NOT NULL
    UNION ALL SELECT (regexp_matches(proofs::text, '[^"]*' || p_bucket || '/[^"]+', 'g'))[1] FROM currency_orders WHERE proofs IS NOT NULL
    UNION ALL SELECT (regexp_matches(proofs::text, '[^"]*' || p_bucket || '/[^"]+', 'g'))[1] FROM currency_transactions WHERE proofs IS NOT NULL
  ),
  dd AS (
    SELECT DISTINCT regexp_replace(split_part(u, p_bucket || '/', 2), '\?.*$', '') AS p
    FROM duoc_tham_chieu WHERE u LIKE '%' || p_bucket || '/%'
  )
  SELECT o.name::text,
         (o.metadata->>'size')::bigint,
         o.created_at,
         CASE
           WHEN NOT EXISTS (SELECT 1 FROM dd WHERE dd.p = o.name) AND o.created_at < now() - p_older_than THEN 'cu_va_mo_coi'
           WHEN NOT EXISTS (SELECT 1 FROM dd WHERE dd.p = o.name) THEN 'mo_coi'
           ELSE 'cu_hon_moc'
         END::text
  FROM storage.objects o
  WHERE o.bucket_id = p_bucket
    AND (
      o.created_at < now() - p_older_than
      OR (p_include_orphans AND NOT EXISTS (SELECT 1 FROM dd WHERE dd.p = o.name))
    )
  ORDER BY o.created_at;
END;
$function$;

REVOKE EXECUTE ON FUNCTION public.storage_cleanup_candidates(text,interval,boolean) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.storage_cleanup_candidates(text,interval,boolean) FROM anon;
REVOKE EXECUTE ON FUNCTION public.storage_cleanup_candidates(text,interval,boolean) FROM authenticated;
GRANT  EXECUTE ON FUNCTION public.storage_cleanup_candidates(text,interval,boolean) TO service_role;

UPDATE storage.buckets
SET allowed_mime_types = ARRAY['image/webp','image/png','image/jpeg','image/gif','video/mp4'],
    file_size_limit    = 10485760
WHERE id = 'work-proofs';
