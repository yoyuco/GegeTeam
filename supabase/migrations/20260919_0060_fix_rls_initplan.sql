-- Sửa 17 policy RLS bị Supabase advisor gắn cờ `auth_rls_initplan`.
--
-- Đã áp dụng trực tiếp lên production susuoambmzdmcygovkea ngày 2026-09-19.
--
-- VẤN ĐỀ: khi gọi trần, auth.uid() / auth.role() / auth.jwt() / current_setting()
-- bị Postgres tính lại CHO TỪNG DÒNG của bảng. Bọc trong một scalar subquery
-- `(select ...)` khiến nó thành InitPlan, tính đúng một lần cho cả truy vấn.
--
-- KHÔNG đổi logic phân quyền. Các hàm này đều STABLE nên `(select f())` cho
-- đúng kết quả như `f()`. Chỉ đổi số lần tính.
--
-- Dùng ALTER POLICY nên tên policy, cmd và danh sách role giữ nguyên.
--
-- KẾT QUẢ: sau khi áp dụng, lint `auth_rls_initplan` biến mất hoàn toàn khỏi
-- Supabase performance advisor (17 -> 0).
--
-- Lưu ý: 8 policy khác đã được bọc sẵn từ trước nên không có mặt ở đây.

ALTER POLICY "business_processes_all_service_role" ON public.business_processes
  USING (((select auth.role()) = 'service_role'::text));

ALTER POLICY "business_processes_select_authenticated" ON public.business_processes
  USING (((select auth.role()) = 'authenticated'::text));

ALTER POLICY "Enable insert for admin and moderator roles" ON public.channels
  WITH CHECK (((created_by = (select auth.uid())) AND (EXISTS ( SELECT 1
     FROM (user_role_assignments ura
       JOIN roles r ON ((ura.role_id = r.id)))
    WHERE ((ura.user_id = get_current_profile_id()) AND ((r.code)::text = ANY (ARRAY['admin'::text, 'mod'::text])))))));

ALTER POLICY "Authenticated users can read logs" ON public.exchange_rate_api_log
  USING (((select auth.role()) = 'authenticated'::text));

ALTER POLICY "Service role can insert logs" ON public.exchange_rate_api_log
  WITH CHECK ((((select auth.jwt()) ->> 'role'::text) = 'service_role'::text));

ALTER POLICY "Enable insert for service role" ON public.exchange_rate_trigger
  WITH CHECK ((((select auth.jwt()) ->> 'role'::text) = 'service_role'::text));

ALTER POLICY "Enable read for authenticated users" ON public.exchange_rate_trigger
  USING (((select auth.role()) = 'authenticated'::text));

ALTER POLICY "Enable update for service role" ON public.exchange_rate_trigger
  USING ((((select auth.jwt()) ->> 'role'::text) = 'service_role'::text));

ALTER POLICY "fees_all_service_role" ON public.fees
  USING (((select auth.role()) = 'service_role'::text));

ALTER POLICY "fees_select_authenticated" ON public.fees
  USING (((select auth.role()) = 'authenticated'::text));

ALTER POLICY "Service role can manage inventory pools" ON public.inventory_pools
  USING (((select auth.role()) = 'service_role'::text));

ALTER POLICY "Users can view inventory pools" ON public.inventory_pools
  USING (((select auth.role()) = 'authenticated'::text));

ALTER POLICY "Allow users with permission to view reviews" ON public.order_reviews
  USING (((EXISTS ( SELECT 1
     FROM (user_role_assignments ura
       JOIN roles r ON ((ura.role_id = r.id)))
    WHERE ((ura.user_id = get_current_profile_id()) AND ((r.code)::text = ANY (ARRAY['admin'::text]))))) OR (created_by = (select auth.uid()))));

ALTER POLICY "Allow service_role to delete parties" ON public.parties
  USING (((select current_setting('app.settings.current_user_email'::text, true)) = 'service_role'::text));

ALTER POLICY "Users can view their own status logs" ON public.profile_status_logs
  USING (((profile_id = ( SELECT profiles.id
     FROM profiles
    WHERE (profiles.auth_id = (select auth.uid())))) OR (EXISTS ( SELECT 1
     FROM (user_role_assignments ura
       JOIN roles r ON ((ura.role_id = r.id)))
    WHERE ((ura.user_id = get_current_profile_id()) AND ((r.code)::text = ANY (ARRAY['admin'::text])))))));

ALTER POLICY "Secure role-based profile update policy" ON public.profiles
  USING (((auth_id = (select auth.uid())) OR (EXISTS ( SELECT 1
     FROM ((auth.users u
       JOIN user_role_assignments ura ON ((u.id = ( SELECT profiles_1.id
             FROM profiles profiles_1
            WHERE (profiles_1.auth_id = (select auth.uid()))
           LIMIT 1))))
       JOIN roles r ON ((ura.role_id = r.id)))
    WHERE ((u.id = (select auth.uid())) AND ((r.code)::text = ANY (ARRAY['admin'::text, 'administrator'::text])))))));

ALTER POLICY "Allow users to read their own assignments" ON public.user_role_assignments
  USING ((user_id = (select auth.uid())));
