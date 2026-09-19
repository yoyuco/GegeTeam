-- Chặn `anon` gọi 61 hàm SECURITY DEFINER vừa ghi dữ liệu vừa không kiểm tra quyền.
--
-- Đã áp dụng trực tiếp lên production susuoambmzdmcygovkea ngày 2026-09-19.
--
-- VẤN ĐỀ: cả 206 hàm SECURITY DEFINER trong schema public đều gọi được bởi role
-- `anon`, tức là bởi bất kỳ ai có khoá publishable — mà khoá đó nằm trong mã
-- JavaScript của frontend nên là công khai. Không cần đăng nhập.
-- Trong số đó 61 hàm (không phải trigger, có ghi dữ liệu, KHÔNG có một dòng
-- kiểm tra quyền nào) tạo thành lỗ hổng leo thang đặc quyền thực sự. Ví dụ:
--
--   add_vault_secret(name, secret)  -> INSERT INTO vault.secrets, không kiểm tra gì
--   delete_channel_direct(id)       -> DELETE FROM channels
--                                      (chú thích trong hàm tự ghi "bypasses RLS")
--   assign_role_to_user(...)        -> gán vai trò, không kiểm tra người gọi
--
-- LƯU Ý QUAN TRỌNG: chỉ `REVOKE ... FROM anon` là KHÔNG ĐỦ. Postgres mặc định
-- cấp EXECUTE cho PUBLIC khi tạo hàm, và `anon` là thành viên của PUBLIC, nên
-- quyền vẫn còn qua đường đó. Phải thu hồi cả hai. ACL trước khi sửa:
--   =X/postgres | postgres=X/... | anon=X/... | authenticated=X/... | service_role=X/...
--    ^^^^^^^^^^ dòng này là PUBLIC
--
-- KHÔNG ảnh hưởng ai: postgres, authenticated và service_role đều có quyền
-- tường minh riêng nên giữ nguyên. Hai cron job (reset_eligible_pilot_cycles,
-- simple_exchange_rate_cron) chạy dưới role postgres -> vẫn chạy.
--
-- KIỂM CHỨNG: trong 24h trước khi sửa, chỉ 2/61 hàm từng được gọi qua API
-- (assign_role_to_user và remove_role_from_user, mỗi hàm 2 lần, đều là thao tác
-- admin từ tài khoản đã đăng nhập). 59 hàm còn lại không được gọi lần nào.
-- Sau khi áp dụng: số hàm `anon` gọi được giảm 206 -> 145, số hàm nguy hiểm
-- còn lại = 0, và 15 phút log tiếp theo không có lỗi nào.
--
-- CÒN TỒN: `authenticated` vẫn gọi được cả 206 hàm. Nghĩa là một tài khoản bất
-- kỳ đã đăng nhập (kể cả vai trò `trial`) vẫn gọi được add_vault_secret hay
-- delete_channel_direct. Sửa triệt để là thêm has_permission(...) vào trong
-- từng hàm, không nằm trong migration này.

DO $$
DECLARE
  r record;
  n int := 0;
BEGIN
  FOR r IN
    SELECT p.oid::regprocedure::text AS sig
    FROM pg_proc p
    JOIN pg_namespace ns ON ns.oid = p.pronamespace
    WHERE ns.nspname = 'public'
      AND p.prosecdef
      AND p.prokind IN ('f','p')
      AND p.prorettype <> 'trigger'::regtype
      AND p.prosrc !~* '(has_permission|auth\.uid|current_user_id|get_current_profile_id|auth\.role)'
      AND p.prosrc ~* '\m(insert|update|delete)\M'
  LOOP
    EXECUTE format('REVOKE EXECUTE ON FUNCTION %s FROM anon', r.sig);
    EXECUTE format('REVOKE EXECUTE ON FUNCTION %s FROM PUBLIC', r.sig);
    n := n + 1;
  END LOOP;
  RAISE NOTICE 'Da thu hoi EXECUTE tren % ham khoi anon va PUBLIC.', n;
END $$;
