


SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE EXTENSION IF NOT EXISTS "pgsodium";








ALTER SCHEMA "public" OWNER TO "postgres";


COMMENT ON SCHEMA "public" IS 'Cleaned up duplicate functions on 2025-10-03';



CREATE SCHEMA IF NOT EXISTS "reporting";


ALTER SCHEMA "reporting" OWNER TO "postgres";


CREATE EXTENSION IF NOT EXISTS "btree_gin" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pg_trgm" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE TYPE "public"."account_type_enum" AS ENUM (
    'btag',
    'login'
);


ALTER TYPE "public"."account_type_enum" OWNER TO "postgres";


CREATE TYPE "public"."app_role" AS ENUM (
    'admin',
    'mod',
    'manager',
    'trader_manager',
    'farmer_manager',
    'leader',
    'trader_leader',
    'farmer_leader',
    'trader1',
    'trader2',
    'farmer',
    'trial',
    'accountant'
);


ALTER TYPE "public"."app_role" OWNER TO "postgres";


CREATE TYPE "public"."order_side_enum" AS ENUM (
    'BUY',
    'SELL'
);


ALTER TYPE "public"."order_side_enum" OWNER TO "postgres";


CREATE TYPE "public"."product_type_enum" AS ENUM (
    'SERVICE',
    'ITEM',
    'CURRENCY'
);


ALTER TYPE "public"."product_type_enum" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."add_vault_secret"("p_name" "text", "p_secret" "text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
    INSERT INTO vault.secrets (name, secret)
    VALUES (p_name, p_secret);
END;
$$;


ALTER FUNCTION "public"."add_vault_secret"("p_name" "text", "p_secret" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."admin_get_all_users"() RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
    IF NOT has_permission('admin:manage_roles') THEN RAISE EXCEPTION 'Authorization failed.'; END IF;
    RETURN (
        SELECT jsonb_agg(jsonb_build_object(
            'id', p.id, -- Đây là profile_id
            'display_name', p.display_name, 
            'status', p.status, 
            'email', u.email, 
            'assignments', COALESCE(asg.assignments, '[]'::jsonb)
        ))
        FROM auth.users u
        JOIN public.profiles p ON u.id = p.auth_id
        LEFT JOIN (
            SELECT
                ura.user_id,
                jsonb_agg(jsonb_build_object(
                    'assignment_id', ura.id, 
                    'role_id', ura.role_id, 
                    'role_code', r.code, 
                    'role_name', r.name,
                    'game_attribute_id', ura.game_attribute_id, 
                    'game_code', game_attr.code, 
                    'game_name', game_attr.name,
                    'business_area_attribute_id', ura.business_area_attribute_id, 
                    'business_area_code', area_attr.code, 
                    'business_area_name', area_attr.name
                )) as assignments
            FROM public.user_role_assignments ura
            JOIN public.roles r ON ura.role_id = r.id
            LEFT JOIN public.attributes game_attr ON ura.game_attribute_id = game_attr.id
            LEFT JOIN public.attributes area_attr ON ura.business_area_attribute_id = area_attr.id
            GROUP BY ura.user_id
        ) asg ON p.id = asg.user_id -- <<< SỬA LỖI Ở ĐÂY (từ u.id thành p.id)
    );
END;
$$;


ALTER FUNCTION "public"."admin_get_all_users"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."admin_get_roles_and_permissions"() RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
  -- Chỉ người có quyền mới được thực thi
  IF NOT has_permission('admin:manage_roles') THEN
    RAISE EXCEPTION 'Authorization failed.';
  END IF;

  RETURN jsonb_build_object(
    'roles', (SELECT jsonb_agg(r) FROM (SELECT id, name, code FROM roles ORDER BY name) r),
    -- SỬA ĐỔI: Thêm cột `description_vi` vào câu SELECT
    'permissions', (SELECT jsonb_agg(p) FROM (SELECT id, code, description, "group", description_vi FROM permissions ORDER BY "group", code) p),
    'assignments', (SELECT jsonb_agg(rp) FROM (SELECT role_id, permission_id FROM role_permissions) rp)
  );
END;
$$;


ALTER FUNCTION "public"."admin_get_roles_and_permissions"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."admin_rebase_item_progress_v1"("p_service_item_id" "uuid", "p_authoritative_done_qty" numeric, "p_new_params" "jsonb", "p_reason" "text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    last_session_id uuid;
BEGIN
    -- 1. Kiểm tra quyền hạn
    IF NOT has_permission('reports:resolve') THEN
        RAISE EXCEPTION 'Authorization failed.';
    END IF;

    -- 2. Đánh dấu tất cả các output cũ của item này là lỗi thời (obsolete)
    UPDATE public.work_session_outputs
    SET is_obsolete = TRUE
    WHERE order_service_item_id = p_service_item_id;

    -- 3. Tìm session ID cuối cùng để gắn bản ghi "chuẩn hóa" vào cho có ngữ cảnh
    SELECT work_session_id INTO last_session_id
    FROM public.work_session_outputs
    WHERE order_service_item_id = p_service_item_id
    ORDER BY id DESC
    LIMIT 1;

    -- 4. Tạo một bản ghi output "chuẩn" duy nhất, ghi đè lên tất cả lịch sử cũ
    INSERT INTO public.work_session_outputs(work_session_id, order_service_item_id, start_value, delta, params)
    VALUES (
        last_session_id,
        p_service_item_id,
        0,
        p_authoritative_done_qty,
        jsonb_build_object(
            'correction_reason', p_reason,
            'corrected_by', auth.uid(),
            'corrected_at', now()
        )
    );

    -- 5. Cập nhật lại hạng mục dịch vụ với done_qty và params chuẩn
    UPDATE public.order_service_items
    SET 
        done_qty = p_authoritative_done_qty,
        params = p_new_params
    WHERE id = p_service_item_id;

END;
$$;


ALTER FUNCTION "public"."admin_rebase_item_progress_v1"("p_service_item_id" "uuid", "p_authoritative_done_qty" numeric, "p_new_params" "jsonb", "p_reason" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."admin_update_permissions_for_role"("p_role_id" "uuid", "p_permission_ids" "uuid"[]) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  v_permission_id uuid;
BEGIN
  -- Chỉ người có quyền mới được thực thi
  IF NOT has_permission('admin:manage_roles') THEN
    RAISE EXCEPTION 'Authorization failed.';
  END IF;
  
  -- Xóa tất cả các quyền cũ của role này
  DELETE FROM public.role_permissions WHERE role_id = p_role_id;
  
  -- Thêm lại các quyền mới từ danh sách được cung cấp
  IF array_length(p_permission_ids, 1) > 0 THEN
    FOREACH v_permission_id IN ARRAY p_permission_ids
    LOOP
      INSERT INTO public.role_permissions (role_id, permission_id)
      VALUES (p_role_id, v_permission_id);
    END LOOP;
  END IF;
END;
$$;


ALTER FUNCTION "public"."admin_update_permissions_for_role"("p_role_id" "uuid", "p_permission_ids" "uuid"[]) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."admin_update_user_assignments"("p_user_id" "uuid", "p_assignments" "jsonb") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
    IF NOT has_permission('admin:manage_roles') THEN
        RAISE EXCEPTION 'Authorization failed.';
    END IF;

    -- Xóa tất cả các gán quyền cũ của người dùng này
    DELETE FROM public.user_role_assignments WHERE user_id = p_user_id;

    -- Thêm các gán quyền mới từ payload
    IF jsonb_array_length(p_assignments) > 0 THEN
        INSERT INTO public.user_role_assignments (user_id, role_id, game_attribute_id, business_area_attribute_id)
        SELECT
            p_user_id,
            (a->>'role_id')::uuid,
            (a->>'game_attribute_id')::uuid,
            (a->>'business_area_attribute_id')::uuid
        FROM jsonb_array_elements(p_assignments) a;
    END IF;
END;
$$;


ALTER FUNCTION "public"."admin_update_user_assignments"("p_user_id" "uuid", "p_assignments" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."admin_update_user_status"("p_user_id" "uuid", "p_new_status" "text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
    -- Chỉ người có quyền mới được thực hiện
    IF NOT has_permission('admin:manage_roles') THEN
        RAISE EXCEPTION 'Authorization failed.';
    END IF;

    -- Cập nhật trạng thái trong bảng profiles
    UPDATE public.profiles
    SET status = p_new_status
    WHERE id = p_user_id;
END;
$$;


ALTER FUNCTION "public"."admin_update_user_status"("p_user_id" "uuid", "p_new_status" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."audit_ctx_v1"() RETURNS "jsonb"
    LANGUAGE "sql" STABLE
    SET "search_path" TO 'public'
    AS $$
select jsonb_strip_nulls(jsonb_build_object(
  'role', current_setting('role', true),
  'sub',  nullif(current_setting('request.jwt.claim.sub',  true), ''),
  'email',nullif(current_setting('request.jwt.claim.email',true), ''),
  'aud',  nullif(current_setting('request.jwt.claim.aud',  true), '')
));
$$;


ALTER FUNCTION "public"."audit_ctx_v1"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."audit_diff_v1"("old_row" "jsonb", "new_row" "jsonb") RETURNS "jsonb"
    LANGUAGE "plpgsql" STABLE
    SET "search_path" TO 'public'
    AS $$
DECLARE result jsonb := '{}'::jsonb; rec record;
BEGIN
    IF old_row IS NULL THEN -- INSERT
        FOR rec IN SELECT key, value FROM jsonb_each(new_row) LOOP result := result || jsonb_build_object(rec.key, jsonb_build_object('new', rec.value)); END LOOP;
        RETURN result;
    END IF;
    IF new_row IS NULL THEN -- DELETE
        FOR rec IN SELECT key, value FROM jsonb_each(old_row) LOOP result := result || jsonb_build_object(rec.key, jsonb_build_object('old', rec.value)); END LOOP;
        RETURN result;
    END IF;
    -- UPDATE
    FOR rec IN SELECT key, value FROM jsonb_each(new_row) LOOP
        IF old_row->rec.key IS NULL OR old_row->rec.key <> rec.value THEN
            result := result || jsonb_build_object(rec.key, jsonb_build_object('old', old_row->rec.key, 'new', rec.value));
        END IF;
    END LOOP;
    RETURN result;
END;
$$;


ALTER FUNCTION "public"."audit_diff_v1"("old_row" "jsonb", "new_row" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."cancel_order_line_v1"("p_line_id" "uuid", "p_cancellation_proof_urls" "text"[], "p_reason" "text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  target_order_id uuid;
  v_context jsonb;
  v_current_status text;
BEGIN
  -- Bước 1: Lấy order_id, status và ngữ cảnh từ order_line_id
  SELECT
    ol.order_id,
    o.status,
    jsonb_build_object('game_code', o.game_code, 'business_area_code', 'SERVICE')
  INTO
    target_order_id,
    v_current_status,
    v_context
  FROM public.order_lines ol
  JOIN public.orders o ON ol.order_id = o.id
  WHERE ol.id = p_line_id;

  IF target_order_id IS NULL THEN
    RAISE EXCEPTION 'Order line not found';
  END IF;

  -- Bước 2: Kiểm tra quyền hạn VỚI NGỮ CẢNH ĐẦY ĐỦ
  IF NOT has_permission('orders:cancel', v_context) THEN
    RAISE EXCEPTION 'User does not have permission to cancel orders';
  END IF;

  -- Bước 3: Dừng deadline nếu đang in_progress
  IF v_current_status = 'in_progress' THEN
    UPDATE public.order_lines
    SET paused_at = NOW()
    WHERE id = p_line_id;
  END IF;

  -- Bước 4: Cập nhật trạng thái và lưu bằng chứng
  UPDATE public.orders
  SET
    status = 'cancelled',
    notes = p_reason
  WHERE id = target_order_id;

  UPDATE public.order_lines
  SET
    action_proof_urls = p_cancellation_proof_urls
  WHERE id = p_line_id;

END;
$$;


ALTER FUNCTION "public"."cancel_order_line_v1"("p_line_id" "uuid", "p_cancellation_proof_urls" "text"[], "p_reason" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."cancel_work_session_v1"("p_session_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
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

    -- Lấy ngữ cảnh để kiểm tra quyền override
    SELECT jsonb_build_object('game_code', o.game_code, 'business_area_code', 'SERVICE')
    INTO v_context
    FROM public.order_lines ol JOIN public.orders o ON ol.order_id = o.id
    WHERE ol.id = v_session.order_line_id;

    IF v_session.farmer_id <> public.get_current_profile_id() AND NOT has_permission('work_session:override', v_context) THEN
        RAISE EXCEPTION 'Bạn không phải chủ phiên và không có quyền can thiệp.';
    END IF;

    v_order_line_id := v_session.order_line_id;

    -- ✅ FIX: Lấy service_type từ product_variants.display_name thay vì attributes
    SELECT
        ol.order_id,
        pv.display_name
    INTO
        v_order_id,
        v_service_type
    FROM public.order_lines ol
    LEFT JOIN public.product_variants pv ON ol.variant_id = pv.id
    WHERE ol.id = v_order_line_id;

    -- ✅ FIX: Dùng tên đúng 'Service-Selfplay' và luôn set paused_at khi cancel
    IF v_service_type = 'Service-Selfplay' THEN
        -- Hoàn lại deadline nếu đã cộng khi start
        IF v_session.unpaused_duration IS NOT NULL THEN
            UPDATE public.order_lines
            SET
                deadline_to = deadline_to - v_session.unpaused_duration,
                total_paused_duration = total_paused_duration - v_session.unpaused_duration
            WHERE id = v_order_line_id;
        END IF;

        -- Luôn set paused_at khi cancel session (để bảo toàn deadline)
        UPDATE public.order_lines
        SET paused_at = NOW()
        WHERE id = v_order_line_id;
    END IF;

    DELETE FROM public.work_sessions WHERE id = p_session_id;

    SELECT count(*) INTO completed_sessions_count
    FROM public.work_sessions
    WHERE order_line_id = v_order_line_id AND ended_at IS NOT NULL;

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
$$;


ALTER FUNCTION "public"."cancel_work_session_v1"("p_session_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."complete_order_line_v1"("p_line_id" "uuid", "p_completion_proof_urls" "text"[], "p_reason" "text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  target_order_id uuid;
  v_context jsonb;
  v_current_status text;
BEGIN
  -- Bước 1: Lấy order_id, status và ngữ cảnh từ p_line_id
  SELECT
    ol.order_id,
    o.status,
    jsonb_build_object('game_code', o.game_code, 'business_area_code', 'SERVICE')
  INTO
    target_order_id,
    v_current_status,
    v_context
  FROM public.order_lines ol
  JOIN public.orders o ON ol.order_id = o.id
  WHERE ol.id = p_line_id;

  IF target_order_id IS NULL THEN
    RAISE EXCEPTION 'Order line not found';
  END IF;

  -- Bước 2: Kiểm tra quyền hạn VỚI NGỮ CẢNH ĐẦY ĐỦ
  IF NOT has_permission('orders:complete', v_context) THEN
    RAISE EXCEPTION 'User does not have permission to complete orders';
  END IF;

  -- Bước 3: Dừng deadline nếu đang in_progress
  IF v_current_status = 'in_progress' THEN
    UPDATE public.order_lines
    SET paused_at = NOW()
    WHERE id = p_line_id;
  END IF;

  -- Bước 4: Cập nhật trạng thái và lưu bằng chứng
  UPDATE public.orders
  SET
    status = 'completed',
    notes = p_reason
  WHERE id = target_order_id;

  UPDATE public.order_lines
  SET
    action_proof_urls = p_completion_proof_urls
  WHERE id = p_line_id;

END;
$$;


ALTER FUNCTION "public"."complete_order_line_v1"("p_line_id" "uuid", "p_completion_proof_urls" "text"[], "p_reason" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_service_order_v1"("p_channel_code" "text", "p_service_type" "text", "p_customer_name" "text", "p_deadline" timestamp with time zone, "p_price" numeric, "p_currency_code" "text", "p_package_type" "text", "p_package_note" "text", "p_customer_account_id" "uuid", "p_new_account_details" "jsonb", "p_game_code" "text", "p_service_items" "jsonb") RETURNS TABLE("order_id" "uuid", "line_id" "uuid")
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    v_party_id uuid;
    v_channel_id uuid;
    v_currency_id uuid;
    v_product_id uuid;
    v_variant_id uuid;
    v_new_order_id uuid;
    v_new_line_id uuid;
    v_account_id uuid;
    v_service_type_attr_id uuid;
    v_variant_name text;
    item RECORD; -- <<< SỬA LỖI: Khai báo biến item ở đây
BEGIN
    -- 1. Kiểm tra quyền hạn
    IF NOT has_permission('orders:create', jsonb_build_object('game_code', p_game_code, 'business_area_code', 'SERVICE')) THEN
        RAISE EXCEPTION 'Authorization failed.';
    END IF;

    -- 2. Tìm hoặc tạo Party (khách hàng)
    SELECT id INTO v_party_id FROM public.parties WHERE name = p_customer_name AND type = 'customer';
    IF v_party_id IS NULL THEN
        INSERT INTO public.parties (name, type) VALUES (p_customer_name, 'customer') RETURNING id INTO v_party_id;
    END IF;

    -- 3. Tìm hoặc tạo Channel (kênh bán)
    SELECT id INTO v_channel_id FROM public.channels WHERE code = p_channel_code;
    IF v_channel_id IS NULL THEN
        INSERT INTO public.channels (code) VALUES (p_channel_code) RETURNING id INTO v_channel_id;
    END IF;
    
    -- 4. Tìm hoặc tạo Currency
    SELECT id INTO v_currency_id FROM public.currencies WHERE code = p_currency_code;
    IF v_currency_id IS NULL THEN
        INSERT INTO public.currencies (code, name) VALUES (p_currency_code, p_currency_code) RETURNING id INTO v_currency_id;
    END IF;

    -- 5. Xử lý tài khoản khách hàng
    IF p_customer_account_id IS NOT NULL THEN
        v_account_id := p_customer_account_id;
    ELSIF p_new_account_details IS NOT NULL AND jsonb_typeof(p_new_account_details) = 'object' THEN
        INSERT INTO public.customer_accounts (party_id, account_type, label, btag, login_id, login_pwd)
        VALUES (v_party_id, p_new_account_details->>'account_type', p_new_account_details->>'label', p_new_account_details->>'btag', p_new_account_details->>'login_id', p_new_account_details->>'login_pwd')
        RETURNING id INTO v_account_id;
    END IF;

    -- 6. Tìm hoặc Tạo (Upsert) Product Variant chuẩn
    IF LOWER(p_service_type) = 'selfplay' THEN
        v_variant_name := 'Service - Selfplay';
    ELSE
        v_variant_name := 'Service - Pilot';
    END IF;

    SELECT id INTO v_product_id FROM public.products WHERE type = 'SERVICE' LIMIT 1;
    IF v_product_id IS NULL THEN
        RAISE EXCEPTION 'Product with type SERVICE not found.';
    END IF;

    INSERT INTO public.product_variants (product_id, display_name, price)
    VALUES (v_product_id, v_variant_name, 0)
    ON CONFLICT (product_id, display_name) DO UPDATE SET display_name = EXCLUDED.display_name
    RETURNING id INTO v_variant_id;

    SELECT id INTO v_service_type_attr_id FROM public.attributes WHERE type = 'SERVICE_TYPE' AND code = (CASE WHEN LOWER(p_service_type) = 'selfplay' THEN 'SELFPLAY' ELSE 'PILOT' END);
    IF v_service_type_attr_id IS NOT NULL THEN
        INSERT INTO public.product_variant_attributes (variant_id, attribute_id) 
        VALUES (v_variant_id, v_service_type_attr_id)
        ON CONFLICT DO NOTHING;
    END IF;

    -- 7. Tạo Order và Order Line
    INSERT INTO public.orders (party_id, channel_id, currency_id, price_total, created_by, game_code, package_type, package_note, status)
    VALUES (v_party_id, v_channel_id, v_currency_id, p_price, public.get_current_profile_id(), p_game_code, p_package_type, p_package_note, 'new')
    RETURNING id INTO v_new_order_id;

    INSERT INTO public.order_lines (order_id, variant_id, customer_account_id, qty, unit_price, deadline_to)
    VALUES (v_new_order_id, v_variant_id, v_account_id, 1, p_price, p_deadline)
    RETURNING id INTO v_new_line_id;

    -- 8. Chèn các hạng mục dịch vụ (Service Items)
    IF p_service_items IS NOT NULL AND jsonb_typeof(p_service_items) = 'array' THEN
        FOR item IN SELECT * FROM jsonb_array_elements(p_service_items) LOOP
            INSERT INTO public.order_service_items (order_line_id, service_kind_id, params, plan_qty)
            VALUES (v_new_line_id, (item.value->>'service_kind_id')::uuid, (item.value->'params')::jsonb, (item.value->>'plan_qty')::numeric);
        END LOOP;
    END IF;

    -- 9. Trả về ID
    RETURN QUERY SELECT v_new_order_id, v_new_line_id;
END;
$$;


ALTER FUNCTION "public"."create_service_order_v1"("p_channel_code" "text", "p_service_type" "text", "p_customer_name" "text", "p_deadline" timestamp with time zone, "p_price" numeric, "p_currency_code" "text", "p_package_type" "text", "p_package_note" "text", "p_customer_account_id" "uuid", "p_new_account_details" "jsonb", "p_game_code" "text", "p_service_items" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_service_report_v1"("p_order_service_item_id" "uuid", "p_description" "text", "p_proof_urls" "text"[]) RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$DECLARE
    v_order_line_id uuid;
    new_report_id uuid;
    v_context jsonb;
BEGIN
    -- Lấy ngữ cảnh để kiểm tra quyền
    SELECT jsonb_build_object('game_code', o.game_code, 'business_area_code', 'SERVICE')
    INTO v_context
    FROM public.order_service_items osi
    JOIN public.order_lines ol ON osi.order_line_id = ol.id
    JOIN public.orders o ON ol.order_id = o.id
    WHERE osi.id = p_order_service_item_id;

    -- SỬA LỖI: Thêm kiểm tra quyền tường minh ở đầu hàm
    IF NOT has_permission('reports:create', v_context) THEN
        RAISE EXCEPTION 'Authorization failed.';
    END IF;

    INSERT INTO public.service_reports (order_line_id, order_service_item_id, reported_by, description, current_proof_urls, status)
    SELECT order_line_id, id, (select get_current_profile_id()), p_description, p_proof_urls, 'new' FROM public.order_service_items WHERE id = p_order_service_item_id RETURNING id, order_line_id INTO new_report_id, v_order_line_id;
    IF v_order_line_id IS NULL THEN RAISE EXCEPTION 'Invalid service item ID.'; END IF;
    PERFORM 1 FROM public.service_reports WHERE order_service_item_id = p_order_service_item_id AND status = 'new' AND id <> new_report_id;
    IF FOUND THEN DELETE FROM public.service_reports WHERE id = new_report_id; RAISE EXCEPTION 'This item already has an active report.'; END IF;
    RETURN new_report_id;
END;$$;


ALTER FUNCTION "public"."create_service_report_v1"("p_order_service_item_id" "uuid", "p_description" "text", "p_proof_urls" "text"[]) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."current_user_id"() RETURNS "uuid"
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$ 
  SELECT (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')::uuid; 
$$;


ALTER FUNCTION "public"."current_user_id"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."finish_work_session_idem_v1"("p_session_id" "uuid", "p_outputs" "jsonb", "p_activity_rows" "jsonb", "p_overrun_reason" "text", "p_idem_key" "text", "p_overrun_type" "text", "p_overrun_proof_urls" "text"[]) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    v_session public.work_sessions%ROWTYPE;
    v_order_line_id UUID;
    v_order_id UUID;
    v_service_type TEXT;
    output_item JSONB;
    activity_item JSONB;
    v_delta NUMERIC;
    v_current_order_status TEXT;
    v_context jsonb;
BEGIN
    -- Phần logic đến đây giữ nguyên
    SELECT * INTO v_session FROM public.work_sessions WHERE id = p_session_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Phiên làm việc không tồn tại.'; END IF;
    IF v_session.ended_at IS NOT NULL THEN RETURN; END IF;
    
    SELECT jsonb_build_object('game_code', o.game_code, 'business_area_code', 'SERVICE')
    INTO v_context
    FROM public.order_lines ol JOIN public.orders o ON ol.order_id = o.id
    WHERE ol.id = v_session.order_line_id;

    IF v_session.farmer_id <> public.get_current_profile_id() AND NOT has_permission('work_session:override', v_context) THEN 
        RAISE EXCEPTION 'Bạn không phải chủ phiên và không có quyền can thiệp.';
    END IF;

    UPDATE public.work_sessions 
    SET 
        ended_at = NOW(), 
        overrun_reason = p_overrun_reason,
        overrun_type = p_overrun_type,
        overrun_proof_urls = p_overrun_proof_urls
    WHERE id = p_session_id;
    
    IF jsonb_array_length(p_outputs) > 0 THEN
        FOR output_item IN SELECT * FROM jsonb_array_elements(p_outputs) LOOP
            v_delta := (output_item->>'current_value')::numeric - (output_item->>'start_value')::numeric;
            INSERT INTO public.work_session_outputs(work_session_id, order_service_item_id, start_value, delta, start_proof_url, end_proof_url, params) 
            VALUES (p_session_id, (output_item->>'item_id')::uuid, (output_item->>'start_value')::numeric, v_delta, output_item->>'start_proof_url', output_item->>'end_proof_url', output_item->'params');
            UPDATE public.order_service_items SET done_qty = done_qty + v_delta WHERE id = (output_item->>'item_id')::uuid;
        END LOOP;
    END IF;
    
    IF jsonb_array_length(p_activity_rows) > 0 THEN
        FOR activity_item IN SELECT * FROM jsonb_array_elements(p_activity_rows) LOOP
            INSERT INTO public.work_session_outputs(work_session_id, order_service_item_id, delta, params) 
            VALUES (p_session_id, (activity_item->>'item_id')::uuid, (activity_item->>'delta')::numeric, activity_item->'params');
        END LOOP;
    END IF;
    
    -- <<< SỬA LỖI LOGIC NẰM Ở ĐÂY >>>
    -- Lấy thông tin trạng thái và loại dịch vụ một cách đáng tin cậy hơn
    SELECT 
        ol.id, 
        o.id, 
        pv.display_name, -- Lấy trực tiếp từ product_variants
        o.status
    INTO 
        v_order_line_id, 
        v_order_id, 
        v_service_type, 
        v_current_order_status
    FROM public.order_lines ol
    JOIN public.orders o ON ol.order_id = o.id
    LEFT JOIN public.product_variants pv ON ol.variant_id = pv.id
    WHERE ol.id = v_session.order_line_id;
    
    -- So sánh với tên variant đã được chuẩn hóa
    IF v_current_order_status <> 'pending_completion' THEN
        IF v_service_type = 'Service-Pilot' THEN 
            UPDATE public.orders SET status = 'pending_pilot' WHERE id = v_order_id;
        ELSIF v_service_type = 'Service-Selfplay' THEN 
            UPDATE public.orders SET status = 'paused_selfplay' WHERE id = v_order_id; 
            UPDATE public.order_lines SET paused_at = NOW() WHERE id = v_order_line_id;
        END IF;
    END IF;
END;
$$;


ALTER FUNCTION "public"."finish_work_session_idem_v1"("p_session_id" "uuid", "p_outputs" "jsonb", "p_activity_rows" "jsonb", "p_overrun_reason" "text", "p_idem_key" "text", "p_overrun_type" "text", "p_overrun_proof_urls" "text"[]) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_boosting_filter_options"() RETURNS TABLE("channels" "text"[], "service_types" "text"[], "package_types" "text"[], "statuses" "text"[])
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  WITH base_data AS (
    SELECT DISTINCT
      ch.code as channel_code,
      pv.display_name as service_type,
      o.package_type,
      o.status
    FROM public.order_lines ol
    JOIN public.orders o ON ol.order_id = o.id
    LEFT JOIN public.channels ch ON o.channel_id = ch.id
    LEFT JOIN public.product_variants pv ON ol.variant_id = pv.id
    WHERE o.game_code = 'DIABLO_4'
      AND o.status <> 'draft'
  )
  SELECT
    ARRAY_AGG(DISTINCT bd.channel_code ORDER BY bd.channel_code) FILTER (WHERE bd.channel_code IS NOT NULL) as channels,
    ARRAY_AGG(DISTINCT bd.service_type ORDER BY bd.service_type) FILTER (WHERE bd.service_type IS NOT NULL) as service_types,
    ARRAY_AGG(DISTINCT bd.package_type ORDER BY bd.package_type) FILTER (WHERE bd.package_type IS NOT NULL) as package_types,
    ARRAY_AGG(DISTINCT bd.status ORDER BY bd.status) FILTER (WHERE bd.status IS NOT NULL) as statuses
  FROM base_data bd;
$$;


ALTER FUNCTION "public"."get_boosting_filter_options"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."get_boosting_filter_options"() IS 'Returns all distinct filter option values for the Service Boosting page. Used to populate filter dropdowns with all possible values from the database, not just from currently loaded records.';



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


ALTER FUNCTION "public"."get_boosting_order_detail_v1"("p_line_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_boosting_orders_v2"() RETURNS TABLE("id" "uuid", "order_id" "uuid", "created_at" timestamp with time zone, "updated_at" timestamp with time zone, "status" "text", "channel_code" "text", "customer_name" "text", "deadline" timestamp with time zone, "btag" "text", "login_id" "text", "login_pwd" "text", "service_type" "text", "package_type" "text", "package_note" "text", "assignees_text" "text", "service_items" "jsonb", "review_id" "uuid", "machine_info" "text", "paused_at" timestamp with time zone, "delivered_at" timestamp with time zone, "action_proof_urls" "text"[])
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
    WITH active_farmers AS (
      -- ... (CTE này không thay đổi)
      SELECT
        ws.order_line_id,
        STRING_AGG(p.display_name, ', ') as farmer_names
      FROM public.work_sessions ws
      JOIN public.profiles p ON ws.farmer_id = p.id
      WHERE ws.ended_at IS NULL
      GROUP BY ws.order_line_id
    ),
    line_items AS (
      -- ... (CTE này không thay đổi)
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
    )
    SELECT
        ol.id,
        o.id,
        o.created_at,
        o.updated_at,
        o.status,
        ch.code,
        p.name,
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
        ol.action_proof_urls
    FROM public.order_lines ol
    JOIN public.orders o ON ol.order_id = o.id
    JOIN public.parties p ON o.party_id = p.id
    LEFT JOIN public.product_variants pv ON ol.variant_id = pv.id
    LEFT JOIN public.channels ch ON o.channel_id = ch.id
    LEFT JOIN public.customer_accounts ca ON ol.customer_account_id = ca.id
    LEFT JOIN line_items li ON ol.id = li.order_line_id
    LEFT JOIN active_farmers af ON ol.id = af.order_line_id
    WHERE o.game_code = 'DIABLO_4' AND o.status <> 'draft'
    -- <<< LOGIC SẮP XẾP ĐÃ ĐƯỢC CẬP NHẬT THEO YÊU CẦU >>>
    ORDER BY
        -- Ưu tiên 1: Trạng thái Đơn hàng
        CASE o.status
            WHEN 'new' THEN 1
            WHEN 'in_progress' THEN 2
            WHEN 'pending_pilot' THEN 3
            WHEN 'paused_selfplay' THEN 4
            WHEN 'pending_completion' THEN 5
            WHEN 'completed' THEN 6
            WHEN 'cancelled' THEN 7
            ELSE 99
        END,
        -- Ưu tiên 2: Người thực hiện
        af.farmer_names ASC NULLS LAST,
        -- Ưu tiên 3: Trạng thái Giao hàng (chưa trả lên trước)
        o.delivered_at ASC NULLS FIRST,
        -- Ưu tiên 4: Trạng thái Review (chưa review lên trước)
        (SELECT r.id FROM public.order_reviews r WHERE r.order_line_id = ol.id LIMIT 1) ASC NULLS FIRST,
        -- Ưu tiên 5: Deadline (sớm hơn lên trước)
        ol.deadline_to ASC NULLS LAST;
$$;


ALTER FUNCTION "public"."get_boosting_orders_v2"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_boosting_orders_v3"("p_limit" integer DEFAULT 50, "p_offset" integer DEFAULT 0, "p_channels" "text"[] DEFAULT NULL::"text"[], "p_statuses" "text"[] DEFAULT NULL::"text"[], "p_service_types" "text"[] DEFAULT NULL::"text"[], "p_package_types" "text"[] DEFAULT NULL::"text"[], "p_customer_name" "text" DEFAULT NULL::"text", "p_assignee" "text" DEFAULT NULL::"text", "p_delivery_status" "text" DEFAULT NULL::"text", "p_review_status" "text" DEFAULT NULL::"text") RETURNS TABLE("id" "uuid", "order_id" "uuid", "created_at" timestamp with time zone, "updated_at" timestamp with time zone, "status" "text", "channel_code" "text", "customer_name" "text", "deadline" timestamp with time zone, "btag" "text", "login_id" "text", "login_pwd" "text", "service_type" "text", "package_type" "text", "package_note" "text", "assignees_text" "text", "service_items" "jsonb", "review_id" "uuid", "machine_info" "text", "paused_at" timestamp with time zone, "delivered_at" timestamp with time zone, "action_proof_urls" "text"[], "total_count" bigint)
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
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
    -- Same sorting logic as v2
    bq.status_order,
    bq.assignees_text ASC NULLS LAST,
    bq.delivered_at ASC NULLS FIRST,
    bq.review_id ASC NULLS FIRST,
    bq.deadline ASC NULLS LAST
  LIMIT p_limit
  OFFSET p_offset;
$$;


ALTER FUNCTION "public"."get_boosting_orders_v3"("p_limit" integer, "p_offset" integer, "p_channels" "text"[], "p_statuses" "text"[], "p_service_types" "text"[], "p_package_types" "text"[], "p_customer_name" "text", "p_assignee" "text", "p_delivery_status" "text", "p_review_status" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_current_profile_id"() RETURNS "uuid"
    LANGUAGE "sql" STABLE
    SET "search_path" TO 'public'
    AS $$
  SELECT id
  FROM public.profiles
  WHERE auth_id = auth.uid();
$$;


ALTER FUNCTION "public"."get_current_profile_id"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_customers_by_channel_v1"("p_channel_code" "text") RETURNS TABLE("name" "text")
    LANGUAGE "sql" STABLE
    SET "search_path" TO 'public'
    AS $$
  SELECT DISTINCT p.name
  FROM public.parties p
  JOIN public.orders o ON o.party_id = p.id
  JOIN public.channels c ON o.channel_id = c.id
  WHERE c.code = p_channel_code AND p.type = 'customer'
  ORDER BY p.name;
$$;


ALTER FUNCTION "public"."get_customers_by_channel_v1"("p_channel_code" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_last_item_proof_v1"("p_item_ids" "uuid"[]) RETURNS TABLE("item_id" "uuid", "last_start_proof_url" "text", "last_end_proof_url" "text", "last_end" numeric, "last_delta" numeric, "last_exp_percent" numeric)
    LANGUAGE "sql" STABLE
    SET "search_path" TO 'public'
    AS $$
  WITH ranked_outputs AS (
    SELECT 
      wso.order_service_item_id, 
      wso.start_proof_url, 
      wso.end_proof_url, 
      (wso.start_value + wso.delta) as end_value, 
      wso.delta, (wso.params->>'exp_percent')::numeric as exp_percent, 
      ROW_NUMBER() OVER (PARTITION BY wso.order_service_item_id ORDER BY ws.ended_at DESC, wso.id DESC) as rn 
    FROM public.work_session_outputs wso 
    LEFT JOIN public.work_sessions ws ON wso.work_session_id = ws.id 
    WHERE 
      wso.order_service_item_id = ANY(p_item_ids) 
      AND (wso.params->>'label') IS NULL
      AND wso.is_obsolete = FALSE
  )
  SELECT 
    ro.order_service_item_id, 
    ro.start_proof_url, 
    ro.end_proof_url, 
    ro.end_value, 
    ro.delta, 
    ro.exp_percent 
  FROM ranked_outputs ro 
  WHERE ro.rn = 1;
$$;


ALTER FUNCTION "public"."get_last_item_proof_v1"("p_item_ids" "uuid"[]) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_my_assignments"() RETURNS "jsonb"
    LANGUAGE "sql" STABLE
    SET "search_path" TO 'public'
    AS $$
  SELECT jsonb_agg(
    jsonb_build_object(
      'role', r.code, 'permissions', p.codes,
      'game_code', game_attr.code, 'game_name', game_attr.name, -- THÊM game_name
      'business_area_code', area_attr.code, 'business_area_name', area_attr.name -- THÊM business_area_name VÀ ĐỔI TÊN business_area
    )
  )
  FROM public.user_role_assignments ura
  JOIN public.roles r ON ura.role_id = r.id
  LEFT JOIN (SELECT rp.role_id, jsonb_agg(p.code) as codes FROM public.role_permissions rp JOIN public.permissions p ON rp.permission_id = p.id GROUP BY rp.role_id) p ON ura.role_id = p.role_id
  LEFT JOIN public.attributes game_attr ON ura.game_attribute_id = game_attr.id
  LEFT JOIN public.attributes area_attr ON ura.business_area_attribute_id = area_attr.id
  WHERE ura.user_id = (select auth.uid());
$$;


ALTER FUNCTION "public"."get_my_assignments"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_reviews_for_order_line_v1"("p_line_id" "uuid") RETURNS "jsonb"
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  -- Kiểm tra quyền hạn trước khi trả về dữ liệu
  SELECT CASE
    WHEN has_permission('orders:view_reviews') THEN (
      SELECT jsonb_agg(
        jsonb_build_object(
          'id', r.id,
          'rating', r.rating,
          'comment', r.comment,
          'proof_urls', r.proof_urls,
          'created_at', r.created_at,
          'reviewer_name', p.display_name
        ) ORDER BY r.created_at DESC
      )
      FROM public.order_reviews r
      JOIN public.profiles p ON r.created_by = p.id
      WHERE r.order_line_id = p_line_id
    )
    ELSE
      '[]'::jsonb -- Trả về mảng rỗng nếu không có quyền
    END;
$$;


ALTER FUNCTION "public"."get_reviews_for_order_line_v1"("p_line_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_service_reports_v1"("p_status" "text" DEFAULT 'new'::"text") RETURNS TABLE("report_id" "uuid", "reported_at" timestamp with time zone, "report_status" "text", "report_description" "text", "report_proof_urls" "text"[], "reporter_name" "text", "order_line_id" "uuid", "customer_name" "text", "channel_code" "text", "service_type" "text", "deadline" timestamp with time zone, "package_note" "text", "btag" "text", "login_id" "text", "login_pwd" "text", "reported_item" "jsonb")
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  SELECT sr.id, sr.created_at, sr.status, sr.description, sr.current_proof_urls, reporter.display_name, ol.id, p.name, ch.code, (SELECT a.name FROM public.product_variant_attributes pva JOIN public.attributes a ON pva.attribute_id = a.id WHERE pva.variant_id = ol.variant_id AND a.type = 'SERVICE_TYPE' LIMIT 1), ol.deadline_to, o.package_note, ca.btag, ca.login_id, ca.login_pwd, jsonb_build_object('id', osi.id, 'kind_code', a.code, 'params', osi.params, 'plan_qty', osi.plan_qty, 'done_qty', osi.done_qty)
  FROM public.service_reports sr JOIN public.profiles reporter ON sr.reported_by = reporter.id JOIN public.order_lines ol ON sr.order_line_id = ol.id JOIN public.orders o ON ol.order_id = o.id JOIN public.parties p ON o.party_id = p.id LEFT JOIN public.channels ch ON o.channel_id = ch.id LEFT JOIN public.customer_accounts ca ON ol.customer_account_id = ca.id JOIN public.order_service_items osi ON sr.order_service_item_id = osi.id JOIN public.attributes a ON osi.service_kind_id = a.id
  WHERE has_permission('reports:view') AND sr.status = p_status ORDER BY sr.created_at ASC;
$$;


ALTER FUNCTION "public"."get_service_reports_v1"("p_status" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_session_history_v2"("p_line_id" "uuid") RETURNS "jsonb"
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  SELECT CASE
    WHEN has_permission('orders:view_all') THEN (
      SELECT jsonb_agg(
        jsonb_build_object(
          'session_id', ws.id,
          'started_at', ws.started_at,
          'ended_at', ws.ended_at,
          'farmer_name', p.display_name,
          
          -- <<< LOGIC CẢNH BÁO ĐÃ ĐƯỢC SỬA LẠI HOÀN CHỈNH >>>
          'has_zero_progress_item', (
            EXISTS (
              SELECT 1
              FROM public.work_session_outputs wso
              JOIN public.order_service_items osi ON wso.order_service_item_id = osi.id
              JOIN public.attributes a ON osi.service_kind_id = a.id
              WHERE wso.work_session_id = ws.id
                AND a.code <> 'MYTHIC' -- Bỏ qua kind Mythic
                AND (
                  -- Trường hợp 1: Các kind khác leveling có delta = 0
                  (a.code <> 'LEVELING' AND wso.delta = 0)
                  OR
                  -- Trường hợp 2: Kind Leveling có delta = 0 VÀ %EXP không đổi
                  (
                    a.code = 'LEVELING' AND wso.delta = 0 AND
                    COALESCE((wso.params->>'exp_percent')::numeric, -1) = 
                    COALESCE(
                        (
                          SELECT (elem->>'start_exp')::numeric
                          FROM jsonb_array_elements(ws.start_state) AS elem
                          WHERE elem->>'item_id' = wso.order_service_item_id::text
                          LIMIT 1
                        ), 
                        -1
                    )
                  )
                )
            )
          ),
          
          'outputs', (
            SELECT jsonb_agg(
              jsonb_build_object(
                'id', osi.id,
                'kind_code', a.code,
                'params', osi.params,
                'plan_qty', osi.plan_qty,
                'done_qty', osi.done_qty,
                'session_start_value', wso.start_value,
                'session_end_value', wso.start_value + wso.delta,
                'session_delta', wso.delta,
                'start_proof_url', wso.start_proof_url,
                'end_proof_url', wso.end_proof_url,
                'is_activity', (wso.params->>'label' IS NOT NULL),
                'activity_label', wso.params->>'label'
              )
            )
            FROM public.work_session_outputs wso
            JOIN public.order_service_items osi ON wso.order_service_item_id = osi.id
            JOIN public.attributes a ON osi.service_kind_id = a.id
            WHERE wso.work_session_id = ws.id
          )
        ) ORDER BY ws.started_at DESC
      )
      FROM public.work_sessions ws
      JOIN public.profiles p ON ws.farmer_id = p.id
      WHERE ws.order_line_id = p_line_id AND ws.ended_at IS NOT NULL
    )
    ELSE
      '[]'::jsonb
    END;
$$;


ALTER FUNCTION "public"."get_session_history_v2"("p_line_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_user_auth_context_v1"() RETURNS json
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  SELECT json_build_object(
    'roles', (
      SELECT json_agg(
        json_build_object(
          'role_code', r.code,
          'role_name', r.name,
          'game_code', g.code,
          'game_name', g.name,
          'business_area_code', ba.code,
          'business_area_name', ba.name
        )
      )
      FROM public.user_role_assignments ura
      JOIN public.roles r ON ura.role_id = r.id
      LEFT JOIN public.attributes g ON ura.game_attribute_id = g.id AND g.type = 'GAME'
      LEFT JOIN public.attributes ba ON ura.business_area_attribute_id = ba.id AND ba.type = 'BUSINESS_AREA'
      -- <<< SỬA LỖI Ở ĐÂY >>>
      WHERE ura.user_id = public.get_current_profile_id()
    ),
    'permissions', (
      SELECT json_agg(
        json_build_object(
          'permission_code', p.code,
          'game_code', g.code,
          'business_area_code', ba.code
        )
      )
      FROM public.user_role_assignments ura
      JOIN public.roles r ON ura.role_id = r.id
      JOIN public.role_permissions rp ON r.id = rp.role_id
      JOIN public.permissions p ON rp.permission_id = p.id
      LEFT JOIN public.attributes g ON ura.game_attribute_id = g.id AND g.type = 'GAME'
      LEFT JOIN public.attributes ba ON ura.business_area_attribute_id = ba.id AND ba.type = 'BUSINESS_AREA'
      -- <<< SỬA LỖI Ở ĐÂY >>>
      WHERE ura.user_id = public.get_current_profile_id()
    )
  );
$$;


ALTER FUNCTION "public"."get_user_auth_context_v1"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_new_user_with_trial_role"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  trial_role_id uuid;
  v_display     text;
  v_profile_id  uuid;
begin
  -- display_name: ưu tiên meta, fallback phần trước @ của email
  v_display := coalesce(
    new.raw_user_meta_data ->> 'display_name',
    split_part(new.email, '@', 1)
  );

  -- tạo profile; để default tự xử lý id/created_at/updated_at/status
  insert into public.profiles (auth_id, display_name)
  values (new.id, v_display)
  returning id into v_profile_id;

  -- lấy id role 'Trial' theo code
  select id into trial_role_id
  from public.roles
  where code = 'trial'
  limit 1;

  -- gán role nếu có
  if trial_role_id is not null then
    insert into public.user_role_assignments (user_id, role_id)
    select v_profile_id, trial_role_id
    where not exists (
      select 1 from public.user_role_assignments
      where user_id = v_profile_id and role_id = trial_role_id
    );
  else
    raise warning 'role "trial" not found; skip assignment for user %', new.id;
  end if;

  return new;
end
$$;


ALTER FUNCTION "public"."handle_new_user_with_trial_role"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_orders_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_orders_updated_at"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."has_permission"("p_permission_code" "text", "p_context" "jsonb" DEFAULT '{}'::"jsonb") RETURNS boolean
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    -- SỬA LỖI: Lấy profile_id của người dùng đang đăng nhập thay vì auth.uid()
    v_profile_id uuid := public.get_current_profile_id();
    v_context_game_code text := p_context->>'game_code';
    v_context_business_area text := p_context->>'business_area_code';
BEGIN
    -- Nếu không tìm thấy profile cho người dùng, họ không có quyền gì cả
    IF v_profile_id IS NULL THEN
        RETURN FALSE;
    END IF;

    -- Thực hiện kiểm tra quyền bằng cách so sánh với profile_id
    RETURN EXISTS (
        SELECT 1
        FROM public.user_role_assignments ura
        JOIN public.role_permissions rp ON ura.role_id = rp.role_id
        JOIN public.permissions p ON rp.permission_id = p.id
        LEFT JOIN public.attributes game_attr ON ura.game_attribute_id = game_attr.id
        LEFT JOIN public.attributes area_attr ON ura.business_area_attribute_id = area_attr.id
        -- SỬA LỖI: Điều kiện WHERE bây giờ so sánh đúng profile_id
        WHERE ura.user_id = v_profile_id AND p.code = p_permission_code
          AND (ura.game_attribute_id IS NULL OR game_attr.code = v_context_game_code)
          AND (ura.business_area_attribute_id IS NULL OR area_attr.code = v_context_business_area)
    );
END;
$$;


ALTER FUNCTION "public"."has_permission"("p_permission_code" "text", "p_context" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."mark_order_as_delivered_v1"("p_order_id" "uuid", "p_is_delivered" boolean) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  v_context jsonb; -- <<< BIẾN MỚI ĐỂ LƯU NGỮ CẢNH
BEGIN
  -- 1. Lấy ngữ cảnh của đơn hàng đang được cập nhật
  SELECT 
    jsonb_build_object('game_code', o.game_code, 'business_area_code', 'SERVICE')
  INTO 
    v_context
  FROM public.orders o
  WHERE o.id = p_order_id;

  -- 2. Kiểm tra quyền hạn VỚI NGỮ CẢNH ĐẦY ĐỦ
  IF NOT has_permission('orders:edit_details', v_context) THEN
    RAISE EXCEPTION 'Authorization failed. You do not have permission to edit this order.';
  END IF;

  -- 3. Cập nhật trạng thái (logic cũ giữ nguyên)
  UPDATE public.orders
  SET delivered_at = CASE 
                      WHEN p_is_delivered THEN NOW() 
                      ELSE NULL 
                    END
  WHERE id = p_order_id;
END;
$$;


ALTER FUNCTION "public"."mark_order_as_delivered_v1"("p_order_id" "uuid", "p_is_delivered" boolean) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."resolve_service_report_v1"("p_report_id" "uuid", "p_resolver_notes" "text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
    IF NOT has_permission('reports:resolve') THEN RAISE EXCEPTION 'Authorization failed.'; END IF;
    UPDATE public.service_reports SET status = 'resolved', resolved_at = now(), resolved_by = (select auth.uid()), resolver_notes = p_resolver_notes WHERE id = p_report_id;
END;
$$;


ALTER FUNCTION "public"."resolve_service_report_v1"("p_report_id" "uuid", "p_resolver_notes" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."start_work_session_v1"("p_order_line_id" "uuid", "p_start_state" "jsonb", "p_initial_note" "text" DEFAULT NULL::"text") RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    v_order_id UUID;
    v_current_status TEXT;
    v_paused_at TIMESTAMPTZ;
    v_paused_duration INTERVAL;
    new_session_id UUID;
    v_context jsonb;
    v_order_created_at TIMESTAMPTZ; -- <<< THÊM BIẾN MỚI
    v_service_type TEXT; -- <<< THÊM BIẾN MỚI
BEGIN
    -- Lấy ngữ cảnh và các thông tin cần thiết
    SELECT 
        o.id, o.status, ol.paused_at, o.created_at, pv.display_name,
        jsonb_build_object('game_code', o.game_code, 'business_area_code', 'SERVICE')
    INTO 
        v_order_id, v_current_status, v_paused_at, v_order_created_at, v_service_type,
        v_context
    FROM public.order_lines ol 
    JOIN public.orders o ON ol.order_id = o.id 
    LEFT JOIN public.product_variants pv ON ol.variant_id = pv.id
    WHERE ol.id = p_order_line_id;

    -- Kiểm tra quyền với ngữ cảnh
    IF NOT has_permission('work_session:start', v_context) THEN
        RAISE EXCEPTION 'Authorization failed.';
    END IF;

    -- Kiểm tra session đang hoạt động
    PERFORM 1 FROM public.work_sessions WHERE order_line_id = p_order_line_id AND ended_at IS NULL;
    IF FOUND THEN RAISE EXCEPTION 'Đơn hàng này đã có một phiên làm việc đang hoạt động.'; END IF;
    
    -- <<< SỬA ĐỔI LOGIC QUAN TRỌNG NẰM Ở ĐÂY >>>
    -- Xử lý logic tạm dừng cho cả trạng thái 'new' và 'paused_selfplay' của đơn Selfplay
    IF v_service_type = 'Service-Selfplay' THEN
        IF v_current_status = 'paused_selfplay' AND v_paused_at IS NOT NULL THEN
            v_paused_duration := NOW() - v_paused_at;
        ELSIF v_current_status = 'new' THEN
            v_paused_duration := NOW() - v_order_created_at;
        END IF;
    END IF;

    -- Nếu có thời gian tạm dừng cần cộng lại, thì cập nhật deadline
    IF v_paused_duration IS NOT NULL THEN
        UPDATE public.order_lines 
        SET 
            deadline_to = deadline_to + v_paused_duration, 
            total_paused_duration = total_paused_duration + v_paused_duration, 
            paused_at = NULL 
        WHERE id = p_order_line_id;
    END IF;
    
    -- Cập nhật status trên bảng orders
    IF v_current_status IN ('new', 'pending_pilot', 'paused_selfplay') THEN 
        UPDATE public.orders SET status = 'in_progress' WHERE id = v_order_id; 
    END IF;
    
    -- Tạo một bản ghi work_session mới
    INSERT INTO public.work_sessions (order_line_id, farmer_id, notes, start_state, unpaused_duration) 
    VALUES (p_order_line_id, public.get_current_profile_id(), p_initial_note, p_start_state, v_paused_duration) 
    RETURNING id INTO new_session_id;

    RETURN new_session_id;
END;
$$;


ALTER FUNCTION "public"."start_work_session_v1"("p_order_line_id" "uuid", "p_start_state" "jsonb", "p_initial_note" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."submit_order_review_v1"("p_line_id" "uuid", "p_rating" numeric, "p_comment" "text", "p_proof_urls" "text"[]) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$BEGIN
  -- SỬA LẠI: Kiểm tra quyền 'orders:add_review'
  IF NOT has_permission('orders:add_review') THEN
    RAISE EXCEPTION 'User does not have permission to submit a review';
  END IF;

  INSERT INTO public.order_reviews (order_line_id, rating, comment, proof_urls, created_by)
  VALUES (p_line_id, p_rating, p_comment, p_proof_urls, get_current_profile_id());
END;$$;


ALTER FUNCTION "public"."submit_order_review_v1"("p_line_id" "uuid", "p_rating" numeric, "p_comment" "text", "p_proof_urls" "text"[]) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."tr_audit_row_v1"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE v_actor_id uuid; v_old_row_json jsonb; v_new_row_json jsonb; v_diff jsonb; v_entity_id uuid;
BEGIN
    BEGIN v_actor_id := (current_setting('request.jwt.claims', true)::jsonb ->> 'sub')::uuid; EXCEPTION WHEN OTHERS THEN v_actor_id := NULL; END;
    IF (TG_OP = 'UPDATE') THEN v_old_row_json := to_jsonb(OLD); v_new_row_json := to_jsonb(NEW);
    ELSIF (TG_OP = 'DELETE') THEN v_old_row_json := to_jsonb(OLD); v_new_row_json := NULL;
    ELSIF (TG_OP = 'INSERT') THEN v_old_row_json := NULL; v_new_row_json := to_jsonb(NEW);
    END IF;
    v_diff := audit_diff_v1(v_old_row_json, v_new_row_json);
    BEGIN
        IF v_new_row_json ? 'id' THEN v_entity_id := (v_new_row_json ->> 'id')::uuid;
        ELSIF v_old_row_json ? 'id' THEN v_entity_id := (v_old_row_json ->> 'id')::uuid;
        ELSE v_entity_id := NULL;
        END IF;
    EXCEPTION WHEN OTHERS THEN v_entity_id := NULL;
    END;
    INSERT INTO public.audit_logs (actor, entity, entity_id, action, op, diff, row_old, row_new)
    VALUES (v_actor_id, TG_TABLE_SCHEMA || '.' || TG_TABLE_NAME, v_entity_id, LOWER(TG_OP), TG_OP, v_diff, v_old_row_json, v_new_row_json);
    RETURN COALESCE(NEW, OLD);
END;
$$;


ALTER FUNCTION "public"."tr_audit_row_v1"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."tr_audit_row_v1"() IS '[v1.1] Trigger audit chuẩn hóa, ghi lại các thay đổi INSERT, UPDATE, DELETE vào bảng audit_logs. Đã sửa lỗi ép kiểu UUID cho entity_id.';



CREATE OR REPLACE FUNCTION "public"."tr_check_all_items_completed_v1"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
DECLARE v_order_line_id UUID; v_order_id UUID; v_current_order_status TEXT; v_service_type TEXT; total_items INT; completed_items INT;
BEGIN
    IF TG_OP = 'UPDATE' AND NEW.done_qty <> OLD.done_qty THEN
        v_order_line_id := NEW.order_line_id;
        SELECT ol.order_id, o.status, pv.display_name
        INTO v_order_id, v_current_order_status, v_service_type
        FROM public.order_lines ol
        JOIN public.orders o ON ol.order_id = o.id
        LEFT JOIN public.product_variants pv ON ol.variant_id = pv.id
        WHERE ol.id = v_order_line_id;

        IF v_current_order_status IN ('completed', 'cancelled', 'pending_completion') THEN RETURN NEW; END IF;
        SELECT count(*) INTO total_items FROM public.order_service_items WHERE order_line_id = v_order_line_id;
        SELECT count(*) INTO completed_items FROM public.order_service_items WHERE order_line_id = v_order_line_id AND done_qty >= COALESCE(plan_qty, 0);
        IF total_items > 0 AND total_items = completed_items THEN
            -- Chỉ dừng deadline cho Selfplay khi pending_completion
            IF v_current_order_status = 'in_progress' AND v_service_type = 'Service-Selfplay' THEN
                UPDATE public.order_lines SET paused_at = NOW() WHERE id = v_order_line_id;
            END IF;
            UPDATE public.orders SET status = 'pending_completion' WHERE id = v_order_id;
        END IF;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."tr_check_all_items_completed_v1"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."try_uuid"("p" "text") RETURNS "uuid"
    LANGUAGE "plpgsql" IMMUTABLE
    SET "search_path" TO 'pg_catalog', 'public'
    AS $$
begin
  return p::uuid;
exception when others then
  return null;
end $$;


ALTER FUNCTION "public"."try_uuid"("p" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_action_proofs_v1"("p_line_id" "uuid", "p_new_urls" "text"[]) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  v_context jsonb; -- <<< BIẾN MỚI ĐỂ LƯU NGỮ CẢNH
BEGIN
  -- 1. Lấy ngữ cảnh từ đơn hàng để kiểm tra quyền
  SELECT 
    jsonb_build_object('game_code', o.game_code, 'business_area_code', 'SERVICE')
  INTO 
    v_context
  FROM public.order_lines ol
  JOIN public.orders o ON ol.order_id = o.id
  WHERE ol.id = p_line_id;

  -- 2. Kiểm tra quyền hạn VỚI NGỮ CẢNH ĐẦY ĐỦ
  IF NOT has_permission('orders:edit_details', v_context) THEN
    RAISE EXCEPTION 'Authorization failed. You do not have permission to edit this order.';
  END IF;

  -- 3. Cập nhật bảng (logic cũ giữ nguyên)
  UPDATE public.order_lines
  SET action_proof_urls = p_new_urls
  WHERE id = p_line_id;

END;
$$;


ALTER FUNCTION "public"."update_action_proofs_v1"("p_line_id" "uuid", "p_new_urls" "text"[]) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_order_details_v1"("p_line_id" "uuid", "p_service_type" "text", "p_deadline" timestamp with time zone, "p_package_note" "text", "p_btag" "text", "p_login_id" "text", "p_login_pwd" "text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  v_order_id uuid;
  v_customer_account_id uuid;
  v_product_id uuid;
  v_variant_id uuid;
  v_variant_name text;
  v_context jsonb; -- <<< BIẾN MỚI ĐỂ LƯU NGỮ CẢNH
BEGIN
  -- 1. Lấy các ID liên quan và ngữ cảnh từ order_line
  SELECT 
    ol.order_id, 
    ol.customer_account_id,
    jsonb_build_object('game_code', o.game_code, 'business_area_code', 'SERVICE')
  INTO 
    v_order_id, 
    v_customer_account_id,
    v_context
  FROM public.order_lines ol
  JOIN public.orders o ON ol.order_id = o.id
  WHERE ol.id = p_line_id;

  IF v_order_id IS NULL THEN
    RAISE EXCEPTION 'Order line not found';
  END IF;

  -- 2. Kiểm tra quyền hạn VỚI NGỮ CẢNH ĐẦY ĐỦ
  IF NOT has_permission('orders:edit_details', v_context) THEN
    RAISE EXCEPTION 'Authorization failed. You do not have permission to edit this order.';
  END IF;

  -- 3. Cập nhật các bảng liên quan (logic còn lại giữ nguyên)
  -- 3.1 Cập nhật deadline trên order_lines
  UPDATE public.order_lines
  SET deadline_to = p_deadline
  WHERE id = p_line_id;

  -- 3.2 Cập nhật package_note trên orders
  UPDATE public.orders
  SET package_note = p_package_note
  WHERE id = v_order_id;

  -- 3.3 Cập nhật thông tin tài khoản khách hàng (nếu có)
  IF v_customer_account_id IS NOT NULL THEN
    UPDATE public.customer_accounts
    SET 
      btag = p_btag,
      login_id = p_login_id,
      login_pwd = p_login_pwd
    WHERE id = v_customer_account_id;
  END IF;

  -- 3.4 Cập nhật Service Type (thông qua product_variant)
  IF p_service_type IS NOT NULL THEN
    SELECT prod.id INTO v_product_id FROM public.products prod WHERE prod.name = 'Boosting Service' LIMIT 1;
    
    IF v_product_id IS NOT NULL THEN
      v_variant_name := 'Service-' || lower(p_service_type);

      WITH new_variant AS (
        INSERT INTO public.product_variants (product_id, display_name)
        VALUES (v_product_id, v_variant_name)
        ON CONFLICT (product_id, display_name) DO UPDATE SET display_name = EXCLUDED.display_name
        RETURNING id
      )
      SELECT id INTO v_variant_id FROM new_variant;

      UPDATE public.order_lines
      SET variant_id = v_variant_id
      WHERE id = p_line_id;
    END IF;
  END IF;

END;
$$;


ALTER FUNCTION "public"."update_order_details_v1"("p_line_id" "uuid", "p_service_type" "text", "p_deadline" timestamp with time zone, "p_package_note" "text", "p_btag" "text", "p_login_id" "text", "p_login_pwd" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_order_line_machine_info_v1"("p_line_id" "uuid", "p_machine_info" "text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
    IF auth.uid() IS NULL THEN
        RAISE EXCEPTION 'Authentication required.';
    END IF;
    UPDATE public.order_lines
    SET machine_info = p_machine_info
    WHERE id = p_line_id;
END;
$$;


ALTER FUNCTION "public"."update_order_line_machine_info_v1"("p_line_id" "uuid", "p_machine_info" "text") OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."attribute_relationships" (
    "parent_attribute_id" "uuid" NOT NULL,
    "child_attribute_id" "uuid" NOT NULL
);


ALTER TABLE "public"."attribute_relationships" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."attributes" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "code" "text" NOT NULL,
    "name" "text" NOT NULL,
    "type" "text" NOT NULL
);


ALTER TABLE "public"."attributes" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."audit_logs" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "at" timestamp with time zone DEFAULT "now"(),
    "actor" "uuid",
    "entity" "text",
    "entity_id" "uuid",
    "action" "text",
    "diff" "jsonb",
    "table_name" "text",
    "op" "text",
    "pk" "jsonb",
    "row_old" "jsonb",
    "row_new" "jsonb",
    "ctx" "jsonb"
);


ALTER TABLE "public"."audit_logs" OWNER TO "postgres";


COMMENT ON TABLE "public"."audit_logs" IS 'all logs';



CREATE TABLE IF NOT EXISTS "public"."channels" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "code" "text" NOT NULL
);


ALTER TABLE "public"."channels" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."currencies" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "code" "text" NOT NULL,
    "name" "text"
);


ALTER TABLE "public"."currencies" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."customer_accounts" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "party_id" "uuid" NOT NULL,
    "account_type" "text",
    "label" "text" NOT NULL,
    "btag" "text",
    "login_id" "text",
    "login_pwd" "text"
);


ALTER TABLE "public"."customer_accounts" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."debug_log" (
    "id" integer NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "message" "text"
);


ALTER TABLE "public"."debug_log" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."debug_log_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."debug_log_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."debug_log_id_seq" OWNED BY "public"."debug_log"."id";



CREATE TABLE IF NOT EXISTS "public"."level_exp" (
    "level" integer NOT NULL,
    "cumulative_exp" bigint NOT NULL
);

ALTER TABLE ONLY "public"."level_exp" FORCE ROW LEVEL SECURITY;


ALTER TABLE "public"."level_exp" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."order_lines" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "order_id" "uuid" NOT NULL,
    "variant_id" "uuid" NOT NULL,
    "customer_account_id" "uuid",
    "qty" numeric DEFAULT 1 NOT NULL,
    "unit_price" numeric DEFAULT 0 NOT NULL,
    "deadline_to" timestamp with time zone,
    "notes" "text",
    "paused_at" timestamp with time zone,
    "total_paused_duration" interval DEFAULT '00:00:00'::interval,
    "action_proof_urls" "text"[],
    "machine_info" "text"
);


ALTER TABLE "public"."order_lines" OWNER TO "postgres";


COMMENT ON COLUMN "public"."order_lines"."machine_info" IS 'Thông tin máy tính đang thực hiện đơn hàng Pilot (ví dụ: Máy 35).';



CREATE TABLE IF NOT EXISTS "public"."order_reviews" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "order_line_id" "uuid" NOT NULL,
    "rating" numeric NOT NULL,
    "comment" "text",
    "proof_urls" "text"[],
    "created_by" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "order_reviews_rating_check" CHECK ((("rating" >= (0)::numeric) AND ("rating" <= (5)::numeric)))
);


ALTER TABLE "public"."order_reviews" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."order_service_items" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "order_line_id" "uuid" NOT NULL,
    "params" "jsonb",
    "plan_qty" numeric DEFAULT 0,
    "service_kind_id" "uuid" NOT NULL,
    "done_qty" numeric DEFAULT 0 NOT NULL
);


ALTER TABLE "public"."order_service_items" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."orders" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "side" "public"."order_side_enum" DEFAULT 'SELL'::"public"."order_side_enum" NOT NULL,
    "status" "text" DEFAULT 'new'::"text" NOT NULL,
    "party_id" "uuid" NOT NULL,
    "channel_id" "uuid",
    "currency_id" "uuid",
    "created_by" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "price_total" numeric DEFAULT 0 NOT NULL,
    "notes" "text",
    "game_code" "text",
    "package_type" "text",
    "package_note" "text",
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "delivered_at" timestamp with time zone
);


ALTER TABLE "public"."orders" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."parties" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "type" "text" NOT NULL,
    "name" "text" NOT NULL
);


ALTER TABLE "public"."parties" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."permissions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "code" "text" NOT NULL,
    "description" "text",
    "group" "text" DEFAULT 'General'::"text" NOT NULL,
    "description_vi" "text"
);


ALTER TABLE "public"."permissions" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."product_variant_attributes" (
    "variant_id" "uuid" NOT NULL,
    "attribute_id" "uuid" NOT NULL
);


ALTER TABLE "public"."product_variant_attributes" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."product_variants" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "product_id" "uuid" NOT NULL,
    "display_name" "text" NOT NULL,
    "price" numeric DEFAULT 0 NOT NULL,
    "is_active" boolean DEFAULT true NOT NULL
);


ALTER TABLE "public"."product_variants" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."products" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "type" "public"."product_type_enum" NOT NULL
);


ALTER TABLE "public"."products" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."profiles" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "display_name" "text",
    "status" "text" DEFAULT 'active'::"text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "auth_id" "uuid" NOT NULL
);

ALTER TABLE ONLY "public"."profiles" FORCE ROW LEVEL SECURITY;


ALTER TABLE "public"."profiles" OWNER TO "postgres";


COMMENT ON COLUMN "public"."profiles"."auth_id" IS 'Foreign key to auth.users.id';



CREATE TABLE IF NOT EXISTS "public"."role_permissions" (
    "role_id" "uuid" NOT NULL,
    "permission_id" "uuid" NOT NULL
);


ALTER TABLE "public"."role_permissions" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."roles" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "code" "public"."app_role" NOT NULL,
    "name" "text" NOT NULL
);


ALTER TABLE "public"."roles" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."service_reports" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "order_line_id" "uuid" NOT NULL,
    "order_service_item_id" "uuid" NOT NULL,
    "reported_by" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "description" "text" NOT NULL,
    "current_proof_urls" "text"[],
    "disputed_start_value" numeric,
    "disputed_proof_url" "text",
    "status" "text" DEFAULT 'new'::"text" NOT NULL,
    "resolved_at" timestamp with time zone,
    "resolved_by" "uuid",
    "resolver_notes" "text"
);


ALTER TABLE "public"."service_reports" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_role_assignments" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "role_id" "uuid" NOT NULL,
    "game_attribute_id" "uuid",
    "business_area_attribute_id" "uuid"
);


ALTER TABLE "public"."user_role_assignments" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."work_session_outputs" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "work_session_id" "uuid" NOT NULL,
    "order_service_item_id" "uuid" NOT NULL,
    "delta" numeric DEFAULT 0 NOT NULL,
    "proof_url" "text",
    "start_value" numeric DEFAULT 0 NOT NULL,
    "start_proof_url" "text",
    "end_proof_url" "text",
    "params" "jsonb",
    "is_obsolete" boolean DEFAULT false NOT NULL
);


ALTER TABLE "public"."work_session_outputs" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."work_sessions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "order_line_id" "uuid" NOT NULL,
    "farmer_id" "uuid" NOT NULL,
    "started_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "ended_at" timestamp with time zone,
    "notes" "text",
    "overrun_reason" "text",
    "start_state" "jsonb",
    "unpaused_duration" interval,
    "overrun_type" "text",
    "overrun_proof_urls" "text"[]
);


ALTER TABLE "public"."work_sessions" OWNER TO "postgres";


COMMENT ON COLUMN "public"."work_sessions"."overrun_type" IS 'Loại lý do vượt chỉ tiêu (OBJECTIVE | KPI_FAIL)';



COMMENT ON COLUMN "public"."work_sessions"."overrun_proof_urls" IS 'Danh sách URL bằng chứng khi vượt chỉ tiêu.';



ALTER TABLE ONLY "public"."debug_log" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."debug_log_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."attribute_relationships"
    ADD CONSTRAINT "attribute_relationships_pkey" PRIMARY KEY ("parent_attribute_id", "child_attribute_id");



ALTER TABLE ONLY "public"."attributes"
    ADD CONSTRAINT "attributes_code_key" UNIQUE ("code");



ALTER TABLE ONLY "public"."attributes"
    ADD CONSTRAINT "attributes_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."audit_logs"
    ADD CONSTRAINT "audit_logs_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."channels"
    ADD CONSTRAINT "channels_code_key" UNIQUE ("code");



ALTER TABLE ONLY "public"."channels"
    ADD CONSTRAINT "channels_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."currencies"
    ADD CONSTRAINT "currencies_code_key" UNIQUE ("code");



ALTER TABLE ONLY "public"."currencies"
    ADD CONSTRAINT "currencies_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."customer_accounts"
    ADD CONSTRAINT "customer_accounts_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."debug_log"
    ADD CONSTRAINT "debug_log_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."level_exp"
    ADD CONSTRAINT "level_exp_pkey" PRIMARY KEY ("level");



ALTER TABLE ONLY "public"."order_lines"
    ADD CONSTRAINT "order_lines_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."order_reviews"
    ADD CONSTRAINT "order_reviews_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."order_service_items"
    ADD CONSTRAINT "order_service_items_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."orders"
    ADD CONSTRAINT "orders_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."parties"
    ADD CONSTRAINT "parties_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."parties"
    ADD CONSTRAINT "parties_type_name_key" UNIQUE ("type", "name");



ALTER TABLE ONLY "public"."permissions"
    ADD CONSTRAINT "permissions_code_key" UNIQUE ("code");



ALTER TABLE ONLY "public"."permissions"
    ADD CONSTRAINT "permissions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."product_variant_attributes"
    ADD CONSTRAINT "product_variant_attributes_pkey" PRIMARY KEY ("variant_id", "attribute_id");



ALTER TABLE ONLY "public"."product_variants"
    ADD CONSTRAINT "product_variants_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."product_variants"
    ADD CONSTRAINT "product_variants_product_id_display_name_key" UNIQUE ("product_id", "display_name");



ALTER TABLE ONLY "public"."products"
    ADD CONSTRAINT "products_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_auth_id_key" UNIQUE ("auth_id");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."role_permissions"
    ADD CONSTRAINT "role_permissions_pkey" PRIMARY KEY ("role_id", "permission_id");



ALTER TABLE ONLY "public"."roles"
    ADD CONSTRAINT "roles_code_key" UNIQUE ("code");



ALTER TABLE ONLY "public"."roles"
    ADD CONSTRAINT "roles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."service_reports"
    ADD CONSTRAINT "service_reports_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_role_assignments"
    ADD CONSTRAINT "user_role_assignments_pkey1" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_role_assignments"
    ADD CONSTRAINT "user_role_assignments_user_id_role_id_game_attribute_id_bus_key" UNIQUE ("user_id", "role_id", "game_attribute_id", "business_area_attribute_id");



ALTER TABLE ONLY "public"."work_session_outputs"
    ADD CONSTRAINT "work_session_outputs_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."work_sessions"
    ADD CONSTRAINT "work_sessions_pkey" PRIMARY KEY ("id");



CREATE INDEX "idx_user_role_assignments_user_id" ON "public"."user_role_assignments" USING "btree" ("user_id");



CREATE INDEX "ix_attribute_relationships_child" ON "public"."attribute_relationships" USING "btree" ("child_attribute_id");



CREATE INDEX "ix_attribute_relationships_parent" ON "public"."attribute_relationships" USING "btree" ("parent_attribute_id");



CREATE INDEX "ix_customer_accounts_party_id" ON "public"."customer_accounts" USING "btree" ("party_id");



CREATE INDEX "ix_order_lines_customer_account_id" ON "public"."order_lines" USING "btree" ("customer_account_id");



CREATE INDEX "ix_order_lines_order_id" ON "public"."order_lines" USING "btree" ("order_id");



CREATE INDEX "ix_order_lines_variant_id" ON "public"."order_lines" USING "btree" ("variant_id");



CREATE INDEX "ix_order_service_items_order_line_id" ON "public"."order_service_items" USING "btree" ("order_line_id");



CREATE INDEX "ix_order_service_items_service_kind_id" ON "public"."order_service_items" USING "btree" ("service_kind_id");



CREATE INDEX "ix_orders_channel_id" ON "public"."orders" USING "btree" ("channel_id");



CREATE INDEX "ix_orders_created_by" ON "public"."orders" USING "btree" ("created_by");



CREATE INDEX "ix_orders_currency_id" ON "public"."orders" USING "btree" ("currency_id");



CREATE INDEX "ix_orders_party_id" ON "public"."orders" USING "btree" ("party_id");



CREATE INDEX "ix_product_variant_attributes_attribute_id" ON "public"."product_variant_attributes" USING "btree" ("attribute_id");



CREATE INDEX "ix_product_variant_attributes_variant_id" ON "public"."product_variant_attributes" USING "btree" ("variant_id");



CREATE INDEX "ix_product_variants_product_id" ON "public"."product_variants" USING "btree" ("product_id");



CREATE INDEX "ix_work_session_outputs_osid_id" ON "public"."work_session_outputs" USING "btree" ("order_service_item_id");



CREATE INDEX "ix_work_session_outputs_work_session_id" ON "public"."work_session_outputs" USING "btree" ("work_session_id");



CREATE INDEX "ix_work_sessions_farmer_id" ON "public"."work_sessions" USING "btree" ("farmer_id");



CREATE INDEX "ix_work_sessions_order_line_id" ON "public"."work_sessions" USING "btree" ("order_line_id");



CREATE OR REPLACE TRIGGER "on_orders_update" BEFORE UPDATE ON "public"."orders" FOR EACH ROW EXECUTE FUNCTION "public"."handle_orders_updated_at"();



CREATE OR REPLACE TRIGGER "tr_after_update_order_service_items" AFTER UPDATE ON "public"."order_service_items" FOR EACH ROW EXECUTE FUNCTION "public"."tr_check_all_items_completed_v1"();



ALTER TABLE ONLY "public"."attribute_relationships"
    ADD CONSTRAINT "attribute_relationships_child_attribute_id_fkey" FOREIGN KEY ("child_attribute_id") REFERENCES "public"."attributes"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."attribute_relationships"
    ADD CONSTRAINT "attribute_relationships_parent_attribute_id_fkey" FOREIGN KEY ("parent_attribute_id") REFERENCES "public"."attributes"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."customer_accounts"
    ADD CONSTRAINT "customer_accounts_party_id_fkey" FOREIGN KEY ("party_id") REFERENCES "public"."parties"("id");



ALTER TABLE ONLY "public"."order_service_items"
    ADD CONSTRAINT "fk_service_kind" FOREIGN KEY ("service_kind_id") REFERENCES "public"."attributes"("id");



ALTER TABLE ONLY "public"."order_lines"
    ADD CONSTRAINT "order_lines_customer_account_id_fkey" FOREIGN KEY ("customer_account_id") REFERENCES "public"."customer_accounts"("id");



ALTER TABLE ONLY "public"."order_lines"
    ADD CONSTRAINT "order_lines_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "public"."orders"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."order_lines"
    ADD CONSTRAINT "order_lines_variant_id_fkey" FOREIGN KEY ("variant_id") REFERENCES "public"."product_variants"("id");



ALTER TABLE ONLY "public"."order_reviews"
    ADD CONSTRAINT "order_reviews_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id");



ALTER TABLE ONLY "public"."order_reviews"
    ADD CONSTRAINT "order_reviews_order_line_id_fkey" FOREIGN KEY ("order_line_id") REFERENCES "public"."order_lines"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."order_service_items"
    ADD CONSTRAINT "order_service_items_order_line_id_fkey" FOREIGN KEY ("order_line_id") REFERENCES "public"."order_lines"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."orders"
    ADD CONSTRAINT "orders_channel_id_fkey" FOREIGN KEY ("channel_id") REFERENCES "public"."channels"("id");



ALTER TABLE ONLY "public"."orders"
    ADD CONSTRAINT "orders_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id");



ALTER TABLE ONLY "public"."orders"
    ADD CONSTRAINT "orders_currency_id_fkey" FOREIGN KEY ("currency_id") REFERENCES "public"."currencies"("id");



ALTER TABLE ONLY "public"."orders"
    ADD CONSTRAINT "orders_party_id_fkey" FOREIGN KEY ("party_id") REFERENCES "public"."parties"("id");



ALTER TABLE ONLY "public"."product_variant_attributes"
    ADD CONSTRAINT "product_variant_attributes_attribute_id_fkey" FOREIGN KEY ("attribute_id") REFERENCES "public"."attributes"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."product_variant_attributes"
    ADD CONSTRAINT "product_variant_attributes_variant_id_fkey" FOREIGN KEY ("variant_id") REFERENCES "public"."product_variants"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."product_variants"
    ADD CONSTRAINT "product_variants_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_auth_id_fkey" FOREIGN KEY ("auth_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."role_permissions"
    ADD CONSTRAINT "role_permissions_permission_id_fkey" FOREIGN KEY ("permission_id") REFERENCES "public"."permissions"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."role_permissions"
    ADD CONSTRAINT "role_permissions_role_id_fkey" FOREIGN KEY ("role_id") REFERENCES "public"."roles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."service_reports"
    ADD CONSTRAINT "service_reports_order_line_id_fkey" FOREIGN KEY ("order_line_id") REFERENCES "public"."order_lines"("id");



ALTER TABLE ONLY "public"."service_reports"
    ADD CONSTRAINT "service_reports_order_service_item_id_fkey" FOREIGN KEY ("order_service_item_id") REFERENCES "public"."order_service_items"("id");



ALTER TABLE ONLY "public"."service_reports"
    ADD CONSTRAINT "service_reports_reported_by_fkey" FOREIGN KEY ("reported_by") REFERENCES "public"."profiles"("id");



ALTER TABLE ONLY "public"."service_reports"
    ADD CONSTRAINT "service_reports_resolved_by_fkey" FOREIGN KEY ("resolved_by") REFERENCES "public"."profiles"("id");



ALTER TABLE ONLY "public"."user_role_assignments"
    ADD CONSTRAINT "user_role_assignments_business_area_attribute_id_fkey" FOREIGN KEY ("business_area_attribute_id") REFERENCES "public"."attributes"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."user_role_assignments"
    ADD CONSTRAINT "user_role_assignments_game_attribute_id_fkey" FOREIGN KEY ("game_attribute_id") REFERENCES "public"."attributes"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."user_role_assignments"
    ADD CONSTRAINT "user_role_assignments_role_id_fkey1" FOREIGN KEY ("role_id") REFERENCES "public"."roles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_role_assignments"
    ADD CONSTRAINT "user_role_assignments_user_id_fkey1" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."work_session_outputs"
    ADD CONSTRAINT "work_session_outputs_order_service_item_id_fkey" FOREIGN KEY ("order_service_item_id") REFERENCES "public"."order_service_items"("id");



ALTER TABLE ONLY "public"."work_session_outputs"
    ADD CONSTRAINT "work_session_outputs_work_session_id_fkey" FOREIGN KEY ("work_session_id") REFERENCES "public"."work_sessions"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."work_sessions"
    ADD CONSTRAINT "work_sessions_farmer_id_fkey" FOREIGN KEY ("farmer_id") REFERENCES "public"."profiles"("id");



ALTER TABLE ONLY "public"."work_sessions"
    ADD CONSTRAINT "work_sessions_order_line_id_fkey" FOREIGN KEY ("order_line_id") REFERENCES "public"."order_lines"("id");



CREATE POLICY "Allow admin to delete" ON "public"."role_permissions" FOR DELETE TO "authenticated" USING ("public"."has_permission"('admin:manage_roles'::"text"));



CREATE POLICY "Allow admin to insert" ON "public"."role_permissions" FOR INSERT TO "authenticated" WITH CHECK ("public"."has_permission"('admin:manage_roles'::"text"));



CREATE POLICY "Allow admin to manage debug logs" ON "public"."debug_log" TO "authenticated" USING ("public"."has_permission"('admin:manage_roles'::"text")) WITH CHECK ("public"."has_permission"('admin:manage_roles'::"text"));



CREATE POLICY "Allow admin to manage permissions" ON "public"."permissions" TO "authenticated" USING ("public"."has_permission"('admin:manage_roles'::"text")) WITH CHECK ("public"."has_permission"('admin:manage_roles'::"text"));



CREATE POLICY "Allow admin to update" ON "public"."role_permissions" FOR UPDATE TO "authenticated" USING ("public"."has_permission"('admin:manage_roles'::"text"));



CREATE POLICY "Allow admins to delete assignments" ON "public"."user_role_assignments" FOR DELETE TO "authenticated" USING ("public"."has_permission"('admin:manage_roles'::"text"));



CREATE POLICY "Allow admins to insert assignments" ON "public"."user_role_assignments" FOR INSERT TO "authenticated" WITH CHECK ("public"."has_permission"('admin:manage_roles'::"text"));



CREATE POLICY "Allow admins to update assignments" ON "public"."user_role_assignments" FOR UPDATE TO "authenticated" USING ("public"."has_permission"('admin:manage_roles'::"text"));



CREATE POLICY "Allow authenticated read access" ON "public"."attribute_relationships" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Allow authenticated read access" ON "public"."attributes" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Allow authenticated read access" ON "public"."channels" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Allow authenticated read access" ON "public"."currencies" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Allow authenticated read access" ON "public"."customer_accounts" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Allow authenticated read access" ON "public"."order_lines" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Allow authenticated read access" ON "public"."order_service_items" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Allow authenticated read access" ON "public"."orders" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Allow authenticated read access" ON "public"."parties" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Allow authenticated read access" ON "public"."product_variant_attributes" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Allow authenticated read access" ON "public"."product_variants" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Allow authenticated read access" ON "public"."products" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Allow authenticated read access" ON "public"."roles" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Allow authenticated read access" ON "public"."work_session_outputs" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Allow authenticated read access" ON "public"."work_sessions" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Allow authenticated users to create reports" ON "public"."service_reports" FOR INSERT TO "authenticated" WITH CHECK (true);



CREATE POLICY "Allow authenticated users to read permissions" ON "public"."permissions" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Allow authenticated users to read profiles" ON "public"."profiles" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Allow authenticated users to read role permissions" ON "public"."role_permissions" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Allow managers to resolve reports" ON "public"."service_reports" FOR UPDATE TO "authenticated" USING ("public"."has_permission"('reports:resolve'::"text")) WITH CHECK ("public"."has_permission"('reports:resolve'::"text"));



CREATE POLICY "Allow privileged users to read audit logs" ON "public"."audit_logs" FOR SELECT TO "authenticated" USING ("public"."has_permission"('system:view_audit_logs'::"text"));



CREATE POLICY "Allow read access to all authenticated users" ON "public"."level_exp" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Allow users to read relevant reports" ON "public"."service_reports" FOR SELECT TO "authenticated" USING ((("reported_by" = ( SELECT "auth"."uid"() AS "uid")) OR "public"."has_permission"('reports:view'::"text")));



CREATE POLICY "Allow users to read their own, and admins all" ON "public"."user_role_assignments" FOR SELECT TO "authenticated" USING ((("user_id" = "auth"."uid"()) OR "public"."has_permission"('admin:manage_roles'::"text")));



CREATE POLICY "Allow users with permission to add reviews" ON "public"."order_reviews" FOR INSERT WITH CHECK ((("created_by" = "auth"."uid"()) AND "public"."has_permission"('orders:add_review'::"text")));



CREATE POLICY "Allow users with permission to view reviews" ON "public"."order_reviews" FOR SELECT USING ("public"."has_permission"('orders:view_reviews'::"text"));



CREATE POLICY "Block all deletes" ON "public"."service_reports" FOR DELETE TO "authenticated" USING (false);



CREATE POLICY "Block deletes" ON "public"."attribute_relationships" FOR DELETE TO "authenticated" USING (false);



CREATE POLICY "Block deletes" ON "public"."attributes" FOR DELETE TO "authenticated" USING (false);



CREATE POLICY "Block deletes" ON "public"."channels" FOR DELETE TO "authenticated" USING (false);



CREATE POLICY "Block deletes" ON "public"."currencies" FOR DELETE TO "authenticated" USING (false);



CREATE POLICY "Block deletes" ON "public"."customer_accounts" FOR DELETE TO "authenticated" USING (false);



CREATE POLICY "Block deletes" ON "public"."order_lines" FOR DELETE TO "authenticated" USING (false);



CREATE POLICY "Block deletes" ON "public"."order_service_items" FOR DELETE TO "authenticated" USING (false);



CREATE POLICY "Block deletes" ON "public"."orders" FOR DELETE TO "authenticated" USING (false);



CREATE POLICY "Block deletes" ON "public"."parties" FOR DELETE TO "authenticated" USING (false);



CREATE POLICY "Block deletes" ON "public"."product_variant_attributes" FOR DELETE TO "authenticated" USING (false);



CREATE POLICY "Block deletes" ON "public"."product_variants" FOR DELETE TO "authenticated" USING (false);



CREATE POLICY "Block deletes" ON "public"."products" FOR DELETE TO "authenticated" USING (false);



CREATE POLICY "Block deletes" ON "public"."roles" FOR DELETE TO "authenticated" USING (false);



CREATE POLICY "Block deletes" ON "public"."work_session_outputs" FOR DELETE TO "authenticated" USING (false);



CREATE POLICY "Block deletes" ON "public"."work_sessions" FOR DELETE TO "authenticated" USING (false);



CREATE POLICY "Block inserts" ON "public"."attribute_relationships" FOR INSERT TO "authenticated" WITH CHECK (false);



CREATE POLICY "Block inserts" ON "public"."attributes" FOR INSERT TO "authenticated" WITH CHECK (false);



CREATE POLICY "Block inserts" ON "public"."channels" FOR INSERT TO "authenticated" WITH CHECK (false);



CREATE POLICY "Block inserts" ON "public"."currencies" FOR INSERT TO "authenticated" WITH CHECK (false);



CREATE POLICY "Block inserts" ON "public"."customer_accounts" FOR INSERT TO "authenticated" WITH CHECK (false);



CREATE POLICY "Block inserts" ON "public"."order_lines" FOR INSERT TO "authenticated" WITH CHECK (false);



CREATE POLICY "Block inserts" ON "public"."order_service_items" FOR INSERT TO "authenticated" WITH CHECK (false);



CREATE POLICY "Block inserts" ON "public"."orders" FOR INSERT TO "authenticated" WITH CHECK (false);



CREATE POLICY "Block inserts" ON "public"."parties" FOR INSERT TO "authenticated" WITH CHECK (false);



CREATE POLICY "Block inserts" ON "public"."product_variant_attributes" FOR INSERT TO "authenticated" WITH CHECK (false);



CREATE POLICY "Block inserts" ON "public"."product_variants" FOR INSERT TO "authenticated" WITH CHECK (false);



CREATE POLICY "Block inserts" ON "public"."products" FOR INSERT TO "authenticated" WITH CHECK (false);



CREATE POLICY "Block inserts" ON "public"."roles" FOR INSERT TO "authenticated" WITH CHECK (false);



CREATE POLICY "Block inserts" ON "public"."work_session_outputs" FOR INSERT TO "authenticated" WITH CHECK (false);



CREATE POLICY "Block inserts" ON "public"."work_sessions" FOR INSERT TO "authenticated" WITH CHECK (false);



CREATE POLICY "Block updates" ON "public"."attribute_relationships" FOR UPDATE TO "authenticated" USING (false) WITH CHECK (false);



CREATE POLICY "Block updates" ON "public"."attributes" FOR UPDATE TO "authenticated" USING (false) WITH CHECK (false);



CREATE POLICY "Block updates" ON "public"."channels" FOR UPDATE TO "authenticated" USING (false) WITH CHECK (false);



CREATE POLICY "Block updates" ON "public"."currencies" FOR UPDATE TO "authenticated" USING (false) WITH CHECK (false);



CREATE POLICY "Block updates" ON "public"."customer_accounts" FOR UPDATE TO "authenticated" USING (false) WITH CHECK (false);



CREATE POLICY "Block updates" ON "public"."order_lines" FOR UPDATE TO "authenticated" USING (false) WITH CHECK (false);



CREATE POLICY "Block updates" ON "public"."order_service_items" FOR UPDATE TO "authenticated" USING (false) WITH CHECK (false);



CREATE POLICY "Block updates" ON "public"."orders" FOR UPDATE TO "authenticated" USING (false) WITH CHECK (false);



CREATE POLICY "Block updates" ON "public"."parties" FOR UPDATE TO "authenticated" USING (false) WITH CHECK (false);



CREATE POLICY "Block updates" ON "public"."product_variant_attributes" FOR UPDATE TO "authenticated" USING (false) WITH CHECK (false);



CREATE POLICY "Block updates" ON "public"."product_variants" FOR UPDATE TO "authenticated" USING (false) WITH CHECK (false);



CREATE POLICY "Block updates" ON "public"."products" FOR UPDATE TO "authenticated" USING (false) WITH CHECK (false);



CREATE POLICY "Block updates" ON "public"."roles" FOR UPDATE TO "authenticated" USING (false) WITH CHECK (false);



CREATE POLICY "Block updates" ON "public"."work_session_outputs" FOR UPDATE TO "authenticated" USING (false) WITH CHECK (false);



CREATE POLICY "Block updates" ON "public"."work_sessions" FOR UPDATE TO "authenticated" USING (false) WITH CHECK (false);



CREATE POLICY "Users can update their own profile" ON "public"."profiles" FOR UPDATE USING (("auth"."uid"() = "auth_id")) WITH CHECK (("auth"."uid"() = "auth_id"));



ALTER TABLE "public"."attribute_relationships" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."attributes" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."audit_logs" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "audit_no_delete" ON "public"."audit_logs" FOR DELETE USING (false);



CREATE POLICY "audit_no_update" ON "public"."audit_logs" FOR UPDATE WITH CHECK (false);



CREATE POLICY "authenticated_delete_work_sessions" ON "public"."work_sessions" FOR DELETE TO "authenticated" USING (true);



CREATE POLICY "authenticated_insert_order_reviews" ON "public"."order_reviews" FOR INSERT TO "authenticated" WITH CHECK (true);



CREATE POLICY "authenticated_insert_work_sessions" ON "public"."work_sessions" FOR INSERT TO "authenticated" WITH CHECK (true);



CREATE POLICY "authenticated_read_attribute_relationships" ON "public"."attribute_relationships" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "authenticated_read_attributes" ON "public"."attributes" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "authenticated_read_order_lines" ON "public"."order_lines" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "authenticated_read_order_reviews" ON "public"."order_reviews" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "authenticated_read_order_service_items" ON "public"."order_service_items" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "authenticated_read_orders" ON "public"."orders" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "authenticated_read_parties" ON "public"."parties" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "authenticated_read_product_variants" ON "public"."product_variants" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "authenticated_read_profiles" ON "public"."profiles" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "authenticated_read_work_sessions" ON "public"."work_sessions" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "authenticated_update_order_lines" ON "public"."order_lines" FOR UPDATE TO "authenticated" USING (true);



CREATE POLICY "authenticated_update_order_service_items" ON "public"."order_service_items" FOR UPDATE TO "authenticated" USING (true);



CREATE POLICY "authenticated_update_orders" ON "public"."orders" FOR UPDATE TO "authenticated" USING (true);



CREATE POLICY "authenticated_update_work_sessions" ON "public"."work_sessions" FOR UPDATE TO "authenticated" USING (true);



ALTER TABLE "public"."channels" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."currencies" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."customer_accounts" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."debug_log" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."level_exp" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."order_lines" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."order_reviews" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."order_service_items" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."orders" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."parties" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."permissions" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."product_variant_attributes" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."product_variants" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."products" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."profiles" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "realtime_order_lines_read" ON "public"."order_lines" FOR SELECT TO "supabase_realtime_admin" USING (true);



CREATE POLICY "realtime_order_reviews_read" ON "public"."order_reviews" FOR SELECT TO "supabase_realtime_admin" USING (true);



CREATE POLICY "realtime_order_service_items_read" ON "public"."order_service_items" FOR SELECT TO "supabase_realtime_admin" USING (true);



CREATE POLICY "realtime_orders_read" ON "public"."orders" FOR SELECT TO "supabase_realtime_admin" USING (true);



CREATE POLICY "realtime_profiles_read" ON "public"."profiles" FOR SELECT TO "supabase_realtime_admin" USING (true);



CREATE POLICY "realtime_work_sessions_read" ON "public"."work_sessions" FOR SELECT TO "supabase_realtime_admin" USING (true);



ALTER TABLE "public"."role_permissions" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."roles" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."service_reports" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_role_assignments" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."work_session_outputs" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."work_sessions" ENABLE ROW LEVEL SECURITY;




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";






ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."order_lines";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."order_service_items";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."orders";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."profiles";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."work_sessions";



REVOKE USAGE ON SCHEMA "public" FROM PUBLIC;
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT ALL ON SCHEMA "public" TO "service_role";




































































































































































































































































































































































































































































































































GRANT ALL ON FUNCTION "public"."add_vault_secret"("p_name" "text", "p_secret" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."add_vault_secret"("p_name" "text", "p_secret" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."add_vault_secret"("p_name" "text", "p_secret" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."admin_get_all_users"() TO "anon";
GRANT ALL ON FUNCTION "public"."admin_get_all_users"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."admin_get_all_users"() TO "service_role";



GRANT ALL ON FUNCTION "public"."admin_get_roles_and_permissions"() TO "anon";
GRANT ALL ON FUNCTION "public"."admin_get_roles_and_permissions"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."admin_get_roles_and_permissions"() TO "service_role";



GRANT ALL ON FUNCTION "public"."admin_rebase_item_progress_v1"("p_service_item_id" "uuid", "p_authoritative_done_qty" numeric, "p_new_params" "jsonb", "p_reason" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."admin_rebase_item_progress_v1"("p_service_item_id" "uuid", "p_authoritative_done_qty" numeric, "p_new_params" "jsonb", "p_reason" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."admin_rebase_item_progress_v1"("p_service_item_id" "uuid", "p_authoritative_done_qty" numeric, "p_new_params" "jsonb", "p_reason" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."admin_update_permissions_for_role"("p_role_id" "uuid", "p_permission_ids" "uuid"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."admin_update_permissions_for_role"("p_role_id" "uuid", "p_permission_ids" "uuid"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."admin_update_permissions_for_role"("p_role_id" "uuid", "p_permission_ids" "uuid"[]) TO "service_role";



GRANT ALL ON FUNCTION "public"."admin_update_user_assignments"("p_user_id" "uuid", "p_assignments" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."admin_update_user_assignments"("p_user_id" "uuid", "p_assignments" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."admin_update_user_assignments"("p_user_id" "uuid", "p_assignments" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."admin_update_user_status"("p_user_id" "uuid", "p_new_status" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."admin_update_user_status"("p_user_id" "uuid", "p_new_status" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."admin_update_user_status"("p_user_id" "uuid", "p_new_status" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."audit_ctx_v1"() TO "anon";
GRANT ALL ON FUNCTION "public"."audit_ctx_v1"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."audit_ctx_v1"() TO "service_role";



GRANT ALL ON FUNCTION "public"."audit_diff_v1"("old_row" "jsonb", "new_row" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."audit_diff_v1"("old_row" "jsonb", "new_row" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."audit_diff_v1"("old_row" "jsonb", "new_row" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."cancel_order_line_v1"("p_line_id" "uuid", "p_cancellation_proof_urls" "text"[], "p_reason" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."cancel_order_line_v1"("p_line_id" "uuid", "p_cancellation_proof_urls" "text"[], "p_reason" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."cancel_order_line_v1"("p_line_id" "uuid", "p_cancellation_proof_urls" "text"[], "p_reason" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."cancel_work_session_v1"("p_session_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."cancel_work_session_v1"("p_session_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."cancel_work_session_v1"("p_session_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."complete_order_line_v1"("p_line_id" "uuid", "p_completion_proof_urls" "text"[], "p_reason" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."complete_order_line_v1"("p_line_id" "uuid", "p_completion_proof_urls" "text"[], "p_reason" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."complete_order_line_v1"("p_line_id" "uuid", "p_completion_proof_urls" "text"[], "p_reason" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."create_service_order_v1"("p_channel_code" "text", "p_service_type" "text", "p_customer_name" "text", "p_deadline" timestamp with time zone, "p_price" numeric, "p_currency_code" "text", "p_package_type" "text", "p_package_note" "text", "p_customer_account_id" "uuid", "p_new_account_details" "jsonb", "p_game_code" "text", "p_service_items" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."create_service_order_v1"("p_channel_code" "text", "p_service_type" "text", "p_customer_name" "text", "p_deadline" timestamp with time zone, "p_price" numeric, "p_currency_code" "text", "p_package_type" "text", "p_package_note" "text", "p_customer_account_id" "uuid", "p_new_account_details" "jsonb", "p_game_code" "text", "p_service_items" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_service_order_v1"("p_channel_code" "text", "p_service_type" "text", "p_customer_name" "text", "p_deadline" timestamp with time zone, "p_price" numeric, "p_currency_code" "text", "p_package_type" "text", "p_package_note" "text", "p_customer_account_id" "uuid", "p_new_account_details" "jsonb", "p_game_code" "text", "p_service_items" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."create_service_report_v1"("p_order_service_item_id" "uuid", "p_description" "text", "p_proof_urls" "text"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."create_service_report_v1"("p_order_service_item_id" "uuid", "p_description" "text", "p_proof_urls" "text"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_service_report_v1"("p_order_service_item_id" "uuid", "p_description" "text", "p_proof_urls" "text"[]) TO "service_role";



GRANT ALL ON FUNCTION "public"."current_user_id"() TO "anon";
GRANT ALL ON FUNCTION "public"."current_user_id"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."current_user_id"() TO "service_role";



GRANT ALL ON FUNCTION "public"."finish_work_session_idem_v1"("p_session_id" "uuid", "p_outputs" "jsonb", "p_activity_rows" "jsonb", "p_overrun_reason" "text", "p_idem_key" "text", "p_overrun_type" "text", "p_overrun_proof_urls" "text"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."finish_work_session_idem_v1"("p_session_id" "uuid", "p_outputs" "jsonb", "p_activity_rows" "jsonb", "p_overrun_reason" "text", "p_idem_key" "text", "p_overrun_type" "text", "p_overrun_proof_urls" "text"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."finish_work_session_idem_v1"("p_session_id" "uuid", "p_outputs" "jsonb", "p_activity_rows" "jsonb", "p_overrun_reason" "text", "p_idem_key" "text", "p_overrun_type" "text", "p_overrun_proof_urls" "text"[]) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_boosting_filter_options"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_boosting_filter_options"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_boosting_filter_options"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_boosting_order_detail_v1"("p_line_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_boosting_order_detail_v1"("p_line_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_boosting_order_detail_v1"("p_line_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_boosting_orders_v2"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_boosting_orders_v2"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_boosting_orders_v2"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_boosting_orders_v3"("p_limit" integer, "p_offset" integer, "p_channels" "text"[], "p_statuses" "text"[], "p_service_types" "text"[], "p_package_types" "text"[], "p_customer_name" "text", "p_assignee" "text", "p_delivery_status" "text", "p_review_status" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_boosting_orders_v3"("p_limit" integer, "p_offset" integer, "p_channels" "text"[], "p_statuses" "text"[], "p_service_types" "text"[], "p_package_types" "text"[], "p_customer_name" "text", "p_assignee" "text", "p_delivery_status" "text", "p_review_status" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_boosting_orders_v3"("p_limit" integer, "p_offset" integer, "p_channels" "text"[], "p_statuses" "text"[], "p_service_types" "text"[], "p_package_types" "text"[], "p_customer_name" "text", "p_assignee" "text", "p_delivery_status" "text", "p_review_status" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_current_profile_id"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_current_profile_id"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_current_profile_id"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_customers_by_channel_v1"("p_channel_code" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_customers_by_channel_v1"("p_channel_code" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_customers_by_channel_v1"("p_channel_code" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_last_item_proof_v1"("p_item_ids" "uuid"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."get_last_item_proof_v1"("p_item_ids" "uuid"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_last_item_proof_v1"("p_item_ids" "uuid"[]) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_my_assignments"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_my_assignments"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_my_assignments"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_reviews_for_order_line_v1"("p_line_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_reviews_for_order_line_v1"("p_line_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_reviews_for_order_line_v1"("p_line_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_service_reports_v1"("p_status" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_service_reports_v1"("p_status" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_service_reports_v1"("p_status" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_session_history_v2"("p_line_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_session_history_v2"("p_line_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_session_history_v2"("p_line_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_user_auth_context_v1"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_user_auth_context_v1"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_user_auth_context_v1"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_new_user_with_trial_role"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user_with_trial_role"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user_with_trial_role"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_orders_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_orders_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_orders_updated_at"() TO "service_role";



GRANT ALL ON FUNCTION "public"."has_permission"("p_permission_code" "text", "p_context" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."has_permission"("p_permission_code" "text", "p_context" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."has_permission"("p_permission_code" "text", "p_context" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."mark_order_as_delivered_v1"("p_order_id" "uuid", "p_is_delivered" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."mark_order_as_delivered_v1"("p_order_id" "uuid", "p_is_delivered" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."mark_order_as_delivered_v1"("p_order_id" "uuid", "p_is_delivered" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."resolve_service_report_v1"("p_report_id" "uuid", "p_resolver_notes" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."resolve_service_report_v1"("p_report_id" "uuid", "p_resolver_notes" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."resolve_service_report_v1"("p_report_id" "uuid", "p_resolver_notes" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."start_work_session_v1"("p_order_line_id" "uuid", "p_start_state" "jsonb", "p_initial_note" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."start_work_session_v1"("p_order_line_id" "uuid", "p_start_state" "jsonb", "p_initial_note" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."start_work_session_v1"("p_order_line_id" "uuid", "p_start_state" "jsonb", "p_initial_note" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."submit_order_review_v1"("p_line_id" "uuid", "p_rating" numeric, "p_comment" "text", "p_proof_urls" "text"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."submit_order_review_v1"("p_line_id" "uuid", "p_rating" numeric, "p_comment" "text", "p_proof_urls" "text"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."submit_order_review_v1"("p_line_id" "uuid", "p_rating" numeric, "p_comment" "text", "p_proof_urls" "text"[]) TO "service_role";



GRANT ALL ON FUNCTION "public"."tr_audit_row_v1"() TO "anon";
GRANT ALL ON FUNCTION "public"."tr_audit_row_v1"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tr_audit_row_v1"() TO "service_role";



GRANT ALL ON FUNCTION "public"."tr_check_all_items_completed_v1"() TO "anon";
GRANT ALL ON FUNCTION "public"."tr_check_all_items_completed_v1"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tr_check_all_items_completed_v1"() TO "service_role";



GRANT ALL ON FUNCTION "public"."try_uuid"("p" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."try_uuid"("p" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."try_uuid"("p" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."update_action_proofs_v1"("p_line_id" "uuid", "p_new_urls" "text"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."update_action_proofs_v1"("p_line_id" "uuid", "p_new_urls" "text"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_action_proofs_v1"("p_line_id" "uuid", "p_new_urls" "text"[]) TO "service_role";



GRANT ALL ON FUNCTION "public"."update_order_details_v1"("p_line_id" "uuid", "p_service_type" "text", "p_deadline" timestamp with time zone, "p_package_note" "text", "p_btag" "text", "p_login_id" "text", "p_login_pwd" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."update_order_details_v1"("p_line_id" "uuid", "p_service_type" "text", "p_deadline" timestamp with time zone, "p_package_note" "text", "p_btag" "text", "p_login_id" "text", "p_login_pwd" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_order_details_v1"("p_line_id" "uuid", "p_service_type" "text", "p_deadline" timestamp with time zone, "p_package_note" "text", "p_btag" "text", "p_login_id" "text", "p_login_pwd" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."update_order_line_machine_info_v1"("p_line_id" "uuid", "p_machine_info" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."update_order_line_machine_info_v1"("p_line_id" "uuid", "p_machine_info" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_order_line_machine_info_v1"("p_line_id" "uuid", "p_machine_info" "text") TO "service_role";



























GRANT ALL ON TABLE "public"."attribute_relationships" TO "anon";
GRANT ALL ON TABLE "public"."attribute_relationships" TO "authenticated";
GRANT ALL ON TABLE "public"."attribute_relationships" TO "service_role";



GRANT ALL ON TABLE "public"."attributes" TO "anon";
GRANT ALL ON TABLE "public"."attributes" TO "authenticated";
GRANT ALL ON TABLE "public"."attributes" TO "service_role";



GRANT ALL ON TABLE "public"."audit_logs" TO "anon";
GRANT ALL ON TABLE "public"."audit_logs" TO "authenticated";
GRANT ALL ON TABLE "public"."audit_logs" TO "service_role";



GRANT ALL ON TABLE "public"."channels" TO "anon";
GRANT ALL ON TABLE "public"."channels" TO "authenticated";
GRANT ALL ON TABLE "public"."channels" TO "service_role";



GRANT ALL ON TABLE "public"."currencies" TO "anon";
GRANT ALL ON TABLE "public"."currencies" TO "authenticated";
GRANT ALL ON TABLE "public"."currencies" TO "service_role";



GRANT ALL ON TABLE "public"."customer_accounts" TO "anon";
GRANT ALL ON TABLE "public"."customer_accounts" TO "authenticated";
GRANT ALL ON TABLE "public"."customer_accounts" TO "service_role";



GRANT ALL ON TABLE "public"."debug_log" TO "anon";
GRANT ALL ON TABLE "public"."debug_log" TO "authenticated";
GRANT ALL ON TABLE "public"."debug_log" TO "service_role";



GRANT ALL ON SEQUENCE "public"."debug_log_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."debug_log_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."debug_log_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."level_exp" TO "anon";
GRANT ALL ON TABLE "public"."level_exp" TO "authenticated";
GRANT ALL ON TABLE "public"."level_exp" TO "service_role";



GRANT ALL ON TABLE "public"."order_lines" TO "anon";
GRANT ALL ON TABLE "public"."order_lines" TO "authenticated";
GRANT ALL ON TABLE "public"."order_lines" TO "service_role";



GRANT ALL ON TABLE "public"."order_reviews" TO "anon";
GRANT ALL ON TABLE "public"."order_reviews" TO "authenticated";
GRANT ALL ON TABLE "public"."order_reviews" TO "service_role";



GRANT ALL ON TABLE "public"."order_service_items" TO "anon";
GRANT ALL ON TABLE "public"."order_service_items" TO "authenticated";
GRANT ALL ON TABLE "public"."order_service_items" TO "service_role";



GRANT ALL ON TABLE "public"."orders" TO "anon";
GRANT ALL ON TABLE "public"."orders" TO "authenticated";
GRANT ALL ON TABLE "public"."orders" TO "service_role";



GRANT ALL ON TABLE "public"."parties" TO "anon";
GRANT ALL ON TABLE "public"."parties" TO "authenticated";
GRANT ALL ON TABLE "public"."parties" TO "service_role";



GRANT ALL ON TABLE "public"."permissions" TO "anon";
GRANT ALL ON TABLE "public"."permissions" TO "authenticated";
GRANT ALL ON TABLE "public"."permissions" TO "service_role";



GRANT ALL ON TABLE "public"."product_variant_attributes" TO "anon";
GRANT ALL ON TABLE "public"."product_variant_attributes" TO "authenticated";
GRANT ALL ON TABLE "public"."product_variant_attributes" TO "service_role";



GRANT ALL ON TABLE "public"."product_variants" TO "anon";
GRANT ALL ON TABLE "public"."product_variants" TO "authenticated";
GRANT ALL ON TABLE "public"."product_variants" TO "service_role";



GRANT ALL ON TABLE "public"."products" TO "anon";
GRANT ALL ON TABLE "public"."products" TO "authenticated";
GRANT ALL ON TABLE "public"."products" TO "service_role";



GRANT ALL ON TABLE "public"."profiles" TO "anon";
GRANT ALL ON TABLE "public"."profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."profiles" TO "service_role";



GRANT ALL ON TABLE "public"."role_permissions" TO "anon";
GRANT ALL ON TABLE "public"."role_permissions" TO "authenticated";
GRANT ALL ON TABLE "public"."role_permissions" TO "service_role";



GRANT ALL ON TABLE "public"."roles" TO "anon";
GRANT ALL ON TABLE "public"."roles" TO "authenticated";
GRANT ALL ON TABLE "public"."roles" TO "service_role";



GRANT ALL ON TABLE "public"."service_reports" TO "anon";
GRANT ALL ON TABLE "public"."service_reports" TO "authenticated";
GRANT ALL ON TABLE "public"."service_reports" TO "service_role";



GRANT ALL ON TABLE "public"."user_role_assignments" TO "anon";
GRANT ALL ON TABLE "public"."user_role_assignments" TO "authenticated";
GRANT ALL ON TABLE "public"."user_role_assignments" TO "service_role";



GRANT ALL ON TABLE "public"."work_session_outputs" TO "anon";
GRANT ALL ON TABLE "public"."work_session_outputs" TO "authenticated";
GRANT ALL ON TABLE "public"."work_session_outputs" TO "service_role";



GRANT ALL ON TABLE "public"."work_sessions" TO "anon";
GRANT ALL ON TABLE "public"."work_sessions" TO "authenticated";
GRANT ALL ON TABLE "public"."work_sessions" TO "service_role";









ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";































RESET ALL;
CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION handle_new_user_with_trial_role();


  create policy "Allow admins to delete proofs 1a09c6j_0"
  on "storage"."objects"
  as permissive
  for delete
  to authenticated
using (((bucket_id = 'work-proofs'::text) AND has_permission('admin:manage_roles'::text)));



  create policy "Allow authenticated users to update their proofs 1a09c6j_0"
  on "storage"."objects"
  as permissive
  for update
  to authenticated
using (((bucket_id = 'work-proofs'::text) AND (owner = auth.uid())))
with check (((bucket_id = 'work-proofs'::text) AND (owner = auth.uid())));



  create policy "Allow authenticated users to upload proofs 1a09c6j_0"
  on "storage"."objects"
  as permissive
  for insert
  to authenticated
with check ((bucket_id = 'work-proofs'::text));



  create policy "Allow authenticated users to view proofs 1a09c6j_0"
  on "storage"."objects"
  as permissive
  for select
  to authenticated
using ((bucket_id = 'work-proofs'::text));



  create policy "storage service role all"
  on "storage"."objects"
  as permissive
  for all
  to public
using ((auth.role() = 'service_role'::text))
with check ((auth.role() = 'service_role'::text));



