

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


COMMENT ON SCHEMA "public" IS 'standard public schema';



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
        SELECT jsonb_agg(jsonb_build_object('id', p.id, 'display_name', p.display_name, 'status', p.status, 'email', u.email, 'assignments', COALESCE(asg.assignments, '[]'::jsonb)))
        FROM auth.users u
        JOIN public.profiles p ON u.id = p.id
        LEFT JOIN (
            SELECT
                ura.user_id,
                jsonb_agg(jsonb_build_object(
                    'assignment_id', ura.id, 'role_id', ura.role_id, 'role_code', r.code, 'role_name', r.name,
                    'game_attribute_id', ura.game_attribute_id, 'game_code', game_attr.code, 'game_name', game_attr.name, -- THÊM game_name
                    'business_area_attribute_id', ura.business_area_attribute_id, 'business_area_code', area_attr.code, 'business_area_name', area_attr.name -- THÊM business_area_name
                )) as assignments
            FROM public.user_role_assignments ura
            JOIN public.roles r ON ura.role_id = r.id
            LEFT JOIN public.attributes game_attr ON ura.game_attribute_id = game_attr.id
            LEFT JOIN public.attributes area_attr ON ura.business_area_attribute_id = area_attr.id
            GROUP BY ura.user_id
        ) asg ON u.id = asg.user_id
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
BEGIN
  -- Kiểm tra quyền hạn
  IF NOT has_permission('orders:cancel') THEN
    RAISE EXCEPTION 'User does not have permission to cancel orders';
  END IF;

  -- Lấy order_id từ line_id
  SELECT order_id INTO target_order_id FROM public.order_lines WHERE id = p_line_id;

  IF target_order_id IS NULL THEN
    RAISE EXCEPTION 'Order line not found';
  END IF;

  -- Cập nhật trạng thái và lưu lý do/bằng chứng
  UPDATE public.orders
  SET 
    status = 'cancelled',
    notes = p_reason
  WHERE id = target_order_id;

  -- MỚI: Lưu trữ URL bằng chứng vào order_lines
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
    v_order_line_id UUID; v_order_id UUID; v_service_type TEXT; completed_sessions_count INT;
    v_context jsonb;
BEGIN
    SELECT * INTO v_session FROM public.work_sessions WHERE id = p_session_id;
    IF NOT FOUND THEN RETURN; END IF;

    -- Lấy ngữ cảnh để kiểm tra quyền override
    SELECT jsonb_build_object('game_code', o.game_code, 'business_area_code', 'SERVICE')
    INTO v_context
    FROM public.order_lines ol JOIN public.orders o ON ol.order_id = o.id
    WHERE ol.id = v_session.order_line_id;

    -- SỬA LỖI: Thêm ngữ cảnh vào kiểm tra quyền override
    IF v_session.farmer_id <> (select auth.uid()) AND NOT has_permission('work_session:override', v_context) THEN 
        RAISE EXCEPTION 'Bạn không phải chủ phiên và không có quyền can thiệp.';
    END IF;
    
    -- Phần còn lại của hàm không thay đổi
    v_order_line_id := v_session.order_line_id;
    SELECT ol.order_id, (SELECT a.code FROM public.product_variant_attributes pva JOIN public.attributes a ON pva.attribute_id = a.id WHERE pva.variant_id = ol.variant_id AND a.type = 'SERVICE_TYPE' LIMIT 1) INTO v_order_id, v_service_type FROM public.order_lines ol WHERE ol.id = v_order_line_id;
    IF v_service_type = 'SELFPAY' AND v_session.unpaused_duration IS NOT NULL THEN UPDATE public.order_lines SET deadline_to = deadline_to - v_session.unpaused_duration, total_paused_duration = total_paused_duration - v_session.unpaused_duration, paused_at = NOW() WHERE id = v_order_line_id; END IF;
    DELETE FROM public.work_sessions WHERE id = p_session_id;
    SELECT count(*) INTO completed_sessions_count FROM public.work_sessions WHERE order_line_id = v_order_line_id AND ended_at IS NOT NULL;
    IF completed_sessions_count > 0 THEN 
        IF v_service_type = 'PILOT' THEN UPDATE public.orders SET status = 'pending_pilot' WHERE id = v_order_id;
        ELSIF v_service_type = 'SELFPAY' THEN UPDATE public.orders SET status = 'paused_selfplay' WHERE id = v_order_id; UPDATE public.order_lines SET paused_at = NOW() WHERE id = v_order_line_id AND paused_at IS NULL; END IF;
    ELSE UPDATE public.orders SET status = 'new' WHERE id = v_order_id; END IF;
END;
$$;


ALTER FUNCTION "public"."cancel_work_session_v1"("p_session_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."complete_order_line_v1"("p_line_id" "uuid", "p_completion_proof_urls" "text"[], "p_reason" "text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  target_order_id uuid;
BEGIN
  -- Kiểm tra quyền hạn
  IF NOT has_permission('orders:complete') THEN
    RAISE EXCEPTION 'User does not have permission to complete orders';
  END IF;

  -- Lấy order_id từ line_id
  SELECT order_id INTO target_order_id FROM public.order_lines WHERE id = p_line_id;

  IF target_order_id IS NULL THEN
    RAISE EXCEPTION 'Order line not found';
  END IF;
  
  -- Cập nhật trạng thái và lưu bằng chứng
  UPDATE public.orders
  SET 
    status = 'completed',
    notes = p_reason
  WHERE id = target_order_id;

  -- MỚI: Lưu trữ URL bằng chứng vào order_lines
  UPDATE public.order_lines
  SET
    action_proof_urls = p_completion_proof_urls
  WHERE id = p_line_id;

END;
$$;


ALTER FUNCTION "public"."complete_order_line_v1"("p_line_id" "uuid", "p_completion_proof_urls" "text"[], "p_reason" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."correct_reported_item_v1"("p_service_item_id" "uuid", "p_plan_qty" numeric, "p_done_qty" numeric, "p_params" "jsonb") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$ -- FIX
DECLARE
    v_order_line_id uuid; v_active_session_id uuid; v_current_start_state jsonb; v_item_state jsonb; v_new_start_state jsonb := '[]'::jsonb; i int;
    v_enriched_params jsonb; v_kind_code text; v_temp_code text; v_temp_label text;
BEGIN
    IF NOT has_permission('reports:resolve') THEN RAISE EXCEPTION 'Authorization failed.'; END IF;
    v_enriched_params := p_params;
    SELECT a.code INTO v_kind_code FROM public.order_service_items osi JOIN public.attributes a ON osi.service_kind_id = a.id WHERE osi.id = p_service_item_id;
    IF v_kind_code = 'MYTHIC' THEN
        v_temp_code := v_enriched_params->>'item_code';
        IF v_temp_code IS NOT NULL THEN SELECT name INTO v_temp_label FROM public.attributes WHERE code = v_temp_code AND type = 'MYTHIC_NAME'; v_enriched_params := v_enriched_params || jsonb_build_object('item_label', v_temp_label); END IF;
        v_temp_code := v_enriched_params->>'ga_code';
        IF v_temp_code IS NOT NULL THEN SELECT name INTO v_temp_label FROM public.attributes WHERE code = v_temp_code AND type = 'MYTHIC_GA_TYPE'; v_enriched_params := v_enriched_params || jsonb_build_object('ga_label', v_temp_label); END IF;
    ELSIF v_kind_code = 'BOSS' THEN
        v_temp_code := v_enriched_params->>'boss_code';
        IF v_temp_code IS NOT NULL THEN SELECT name INTO v_temp_label FROM public.attributes WHERE code = v_temp_code AND type = 'BOSS_NAME'; v_enriched_params := v_enriched_params || jsonb_build_object('boss_label', v_temp_label); END IF;
    ELSIF v_kind_code = 'THE_PIT' THEN
        v_temp_code := v_enriched_params->>'tier_code';
        IF v_temp_code IS NOT NULL THEN SELECT name INTO v_temp_label FROM public.attributes WHERE code = v_temp_code AND type = 'TIER_DIFFICULTY'; v_enriched_params := v_enriched_params || jsonb_build_object('tier_label', v_temp_label); END IF;
    END IF;
    UPDATE public.order_service_items SET plan_qty = p_plan_qty, done_qty = p_done_qty, params = v_enriched_params WHERE id = p_service_item_id RETURNING order_line_id INTO v_order_line_id;
    IF v_order_line_id IS NULL THEN RAISE EXCEPTION 'Service item not found.'; END IF;
    SELECT id, start_state INTO v_active_session_id, v_current_start_state FROM public.work_sessions WHERE order_line_id = v_order_line_id AND ended_at IS NULL LIMIT 1;
    IF v_active_session_id IS NOT NULL AND v_current_start_state IS NOT NULL THEN
        FOR i IN 0..jsonb_array_length(v_current_start_state) - 1 LOOP
            v_item_state := v_current_start_state -> i;
            IF (v_item_state->>'item_id')::uuid = p_service_item_id THEN v_item_state := v_item_state || jsonb_build_object('start_value', p_done_qty); END IF;
            v_new_start_state := v_new_start_state || v_item_state;
        END LOOP;
        UPDATE public.work_sessions SET start_state = v_new_start_state WHERE id = v_active_session_id;
    END IF;
END;
$$;


ALTER FUNCTION "public"."correct_reported_item_v1"("p_service_item_id" "uuid", "p_plan_qty" numeric, "p_done_qty" numeric, "p_params" "jsonb") OWNER TO "postgres";


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
    item jsonb;
BEGIN
    -- ĐÃ SỬA: Thêm ngữ cảnh vào kiểm tra quyền
    IF NOT has_permission('orders:create', jsonb_build_object('game_code', p_game_code, 'business_area_code', 'SERVICE')) THEN
        RAISE EXCEPTION 'Authorization failed.';
    END IF;

    SELECT id INTO v_party_id FROM public.parties WHERE name = p_customer_name AND type = 'customer';
    IF v_party_id IS NULL THEN
        INSERT INTO public.parties (name, type) VALUES (p_customer_name, 'customer') RETURNING id INTO v_party_id;
    END IF;

    SELECT id INTO v_channel_id FROM public.channels WHERE code = p_channel_code;
    IF v_channel_id IS NULL THEN
        INSERT INTO public.channels (code) VALUES (p_channel_code) RETURNING id INTO v_channel_id;
    END IF;

    IF p_customer_account_id IS NOT NULL THEN
        v_account_id := p_customer_account_id;
    ELSIF p_new_account_details IS NOT NULL AND jsonb_typeof(p_new_account_details) = 'object' THEN
        INSERT INTO public.customer_accounts (party_id, account_type, label, btag, login_id, login_pwd)
        VALUES (v_party_id, p_new_account_details->>'account_type', p_new_account_details->>'label', p_new_account_details->>'btag', p_new_account_details->>'login_id', p_new_account_details->>'login_pwd')
        RETURNING id INTO v_account_id;
    END IF;

    SELECT id INTO v_currency_id FROM public.currencies WHERE code = p_currency_code;
    SELECT id INTO v_product_id FROM public.products WHERE type = 'SERVICE' LIMIT 1;

    INSERT INTO public.product_variants (product_id, display_name, price)
    VALUES (v_product_id, 'Service-' || p_package_type || '-' || gen_random_uuid()::text, p_price)
    RETURNING id INTO v_variant_id;

    SELECT id INTO v_service_type_attr_id FROM public.attributes WHERE type = 'SERVICE_TYPE' AND code = (CASE WHEN p_service_type = 'selfplay' THEN 'SELFPAY' ELSE 'PILOT' END);
    IF v_service_type_attr_id IS NOT NULL THEN
        INSERT INTO public.product_variant_attributes (variant_id, attribute_id) VALUES (v_variant_id, v_service_type_attr_id);
    END IF;

    INSERT INTO public.orders (party_id, channel_id, currency_id, price_total, created_by, game_code, package_type, package_note, status)
    VALUES (v_party_id, v_channel_id, v_currency_id, p_price, (select auth.uid()), p_game_code, p_package_type, p_package_note, 'new')
    RETURNING id INTO v_new_order_id;

    INSERT INTO public.order_lines (order_id, variant_id, customer_account_id, qty, unit_price, deadline_to)
    VALUES (v_new_order_id, v_variant_id, v_account_id, 1, p_price, p_deadline)
    RETURNING id INTO v_new_line_id;

    IF p_service_items IS NOT NULL AND jsonb_typeof(p_service_items) = 'array' THEN
        FOR item IN SELECT * FROM jsonb_array_elements(p_service_items) LOOP
            INSERT INTO public.order_service_items (order_line_id, service_kind_id, params, plan_qty)
            VALUES (v_new_line_id, (item->>'service_kind_id')::uuid, (item->'params')::jsonb, (item->>'plan_qty')::numeric);
        END LOOP;
    END IF;

    RETURN QUERY SELECT v_new_order_id, v_new_line_id;
END;
$$;


ALTER FUNCTION "public"."create_service_order_v1"("p_channel_code" "text", "p_service_type" "text", "p_customer_name" "text", "p_deadline" timestamp with time zone, "p_price" numeric, "p_currency_code" "text", "p_package_type" "text", "p_package_note" "text", "p_customer_account_id" "uuid", "p_new_account_details" "jsonb", "p_game_code" "text", "p_service_items" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_service_report_v1"("p_order_service_item_id" "uuid", "p_description" "text", "p_proof_urls" "text"[]) RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
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
    SELECT order_line_id, id, (select auth.uid()), p_description, p_proof_urls, 'new' FROM public.order_service_items WHERE id = p_order_service_item_id RETURNING id, order_line_id INTO new_report_id, v_order_line_id;
    IF v_order_line_id IS NULL THEN RAISE EXCEPTION 'Invalid service item ID.'; END IF;
    PERFORM 1 FROM public.service_reports WHERE order_service_item_id = p_order_service_item_id AND status = 'new' AND id <> new_report_id;
    IF FOUND THEN DELETE FROM public.service_reports WHERE id = new_report_id; RAISE EXCEPTION 'This item already has an active report.'; END IF;
    RETURN new_report_id;
END;
$$;


ALTER FUNCTION "public"."create_service_report_v1"("p_order_service_item_id" "uuid", "p_description" "text", "p_proof_urls" "text"[]) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."current_user_id"() RETURNS "uuid"
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$ 
  SELECT (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')::uuid; 
$$;


ALTER FUNCTION "public"."current_user_id"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."finish_work_session_idem_v1"("p_session_id" "uuid", "p_outputs" "jsonb", "p_activity_rows" "jsonb", "p_overrun_reason" "text", "p_idem_key" "text") RETURNS "void"
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
    -- Bước 1: Log lại payload được gửi từ frontend để debug
    INSERT INTO public.debug_log (message)
    VALUES ('[finishSession DEBUG] p_activity_rows: ' || p_activity_rows::text);

    -- Bước 2: Xử lý logic nghiệp vụ (đã sửa lỗi)
    SELECT * INTO v_session FROM public.work_sessions WHERE id = p_session_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Phiên làm việc không tồn tại.'; END IF;
    IF v_session.ended_at IS NOT NULL THEN RETURN; END IF;
    
    SELECT jsonb_build_object('game_code', o.game_code, 'business_area_code', 'SERVICE')
    INTO v_context
    FROM public.order_lines ol JOIN public.orders o ON ol.order_id = o.id
    WHERE ol.id = v_session.order_line_id;

    IF v_session.farmer_id <> (select auth.uid()) AND NOT has_permission('work_session:override', v_context) THEN 
        RAISE EXCEPTION 'Bạn không phải chủ phiên và không có quyền can thiệp.';
    END IF;

    UPDATE public.work_sessions SET ended_at = NOW(), overrun_reason = p_overrun_reason WHERE id = p_session_id;
    
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
            -- SỬA LỖI QUAN TRỌNG: Thêm `order_service_item_id` và đọc `item_id` từ JSON
            INSERT INTO public.work_session_outputs(work_session_id, order_service_item_id, delta, params) 
            VALUES (p_session_id, (activity_item->>'item_id')::uuid, (activity_item->>'delta')::numeric, activity_item->'params');
        END LOOP;
    END IF;
    
    SELECT ol.id, o.id, (SELECT a.code FROM public.product_variant_attributes pva JOIN public.attributes a ON pva.attribute_id = a.id WHERE pva.variant_id = ol.variant_id AND a.type = 'SERVICE_TYPE' LIMIT 1), o.status
    INTO v_order_line_id, v_order_id, v_service_type, v_current_order_status
    FROM public.order_lines ol JOIN public.orders o ON ol.order_id = o.id WHERE ol.id = v_session.order_line_id;
    
    IF v_current_order_status <> 'pending_completion' THEN
        IF v_service_type = 'PILOT' THEN 
            UPDATE public.orders SET status = 'pending_pilot' WHERE id = v_order_id;
        ELSIF v_service_type = 'SELFPAY' THEN 
            UPDATE public.orders SET status = 'paused_selfplay' WHERE id = v_order_id; 
            UPDATE public.order_lines SET paused_at = NOW() WHERE id = v_order_line_id;
        END IF;
    END IF;
END;
$$;


ALTER FUNCTION "public"."finish_work_session_idem_v1"("p_session_id" "uuid", "p_outputs" "jsonb", "p_activity_rows" "jsonb", "p_overrun_reason" "text", "p_idem_key" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_boosting_order_detail_v1"("p_line_id" "uuid") RETURNS json
    LANGUAGE "sql"
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
  LEFT JOIN public.channels ch ON o.channel_id = ch.id
  LEFT JOIN public.customer_accounts acc ON ol.customer_account_id = acc.id
  LEFT JOIN public.product_variants pv ON ol.variant_id = pv.id
  WHERE ol.id = p_line_id;
$$;


ALTER FUNCTION "public"."get_boosting_order_detail_v1"("p_line_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_boosting_orders_v2"() RETURNS TABLE("id" "uuid", "order_id" "uuid", "created_at" timestamp with time zone, "updated_at" timestamp with time zone, "status" "text", "channel_code" "text", "customer_name" "text", "deadline" timestamp with time zone, "btag" "text", "login_id" "text", "login_pwd" "text", "service_type" "text", "package_type" "text", "package_note" "text", "assignees_text" "text", "service_items" "jsonb", "review_id" "uuid")
    LANGUAGE "sql"
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
    )
    SELECT
        ol.id,
        o.id,
        o.created_at,
        o.updated_at,
        o.status,
        ch.code,
        p.name,
        ol.deadline_to,
        ca.btag,
        ca.login_id,
        ca.login_pwd,
        (SELECT a.name FROM public.product_variant_attributes pva JOIN public.attributes a ON pva.attribute_id = a.id WHERE pva.variant_id = ol.variant_id AND a.type = 'SERVICE_TYPE' LIMIT 1),
        o.package_type,
        o.package_note,
        af.farmer_names,
        li.items,
        -- SỬA LỖI: Dùng subquery thay vì JOIN để tránh trùng lặp dòng
        (SELECT r.id FROM public.order_reviews r WHERE r.order_line_id = ol.id LIMIT 1) as review_id
    FROM public.order_lines ol
    JOIN public.orders o ON ol.order_id = o.id
    JOIN public.parties p ON o.party_id = p.id
    LEFT JOIN public.channels ch ON o.channel_id = ch.id
    LEFT JOIN public.customer_accounts ca ON ol.customer_account_id = ca.id
    LEFT JOIN line_items li ON ol.id = li.order_line_id
    LEFT JOIN active_farmers af ON ol.id = af.order_line_id
    -- Đã loại bỏ JOIN với order_reviews ở đây
    WHERE o.game_code = 'DIABLO_4' AND o.status <> 'draft'
    ORDER BY
        CASE o.status
            WHEN 'in_progress' THEN 1
            WHEN 'new' THEN 2
            WHEN 'pending_completion' THEN 3
            WHEN 'pending_pilot' THEN 4
            WHEN 'paused_selfplay' THEN 5
            WHEN 'completed' THEN 6
            WHEN 'cancelled' THEN 7
            ELSE 99
        END,
        af.farmer_names ASC NULLS LAST,
        ol.deadline_to ASC NULLS LAST;
$$;


ALTER FUNCTION "public"."get_boosting_orders_v2"() OWNER TO "postgres";


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
  WITH ranked_outputs AS (SELECT wso.order_service_item_id, wso.start_proof_url, wso.end_proof_url, (wso.start_value + wso.delta) as end_value, wso.delta, (wso.params->>'exp_percent')::numeric as exp_percent, ROW_NUMBER() OVER (PARTITION BY wso.order_service_item_id ORDER BY ws.ended_at DESC) as rn FROM public.work_session_outputs wso JOIN public.work_sessions ws ON wso.work_session_id = ws.id WHERE wso.order_service_item_id = ANY(p_item_ids) AND ws.ended_at IS NOT NULL)
  SELECT ro.order_service_item_id, ro.start_proof_url, ro.end_proof_url, ro.end_value, ro.delta, ro.exp_percent FROM ranked_outputs ro WHERE ro.rn = 1;
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


CREATE OR REPLACE FUNCTION "public"."get_session_history_v1"("p_line_id" "uuid") RETURNS "jsonb"
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
                -- THÊM CÁC TRƯỜNG ĐỂ PHÂN BIỆT
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


ALTER FUNCTION "public"."get_session_history_v1"("p_line_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_user_auth_context_v1"() RETURNS json
    LANGUAGE "sql" SECURITY DEFINER
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
      WHERE ura.user_id = auth.uid()
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
      WHERE ura.user_id = auth.uid()
    )
  );
$$;


ALTER FUNCTION "public"."get_user_auth_context_v1"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_new_user_with_trial_role"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  trial_role_id uuid;
BEGIN
  INSERT INTO public.profiles (id, display_name) VALUES (new.id, new.raw_user_meta_data->>'display_name');
  SELECT id INTO trial_role_id FROM public.roles WHERE code = 'trial';
  IF trial_role_id IS NOT NULL THEN
    INSERT INTO public.user_role_assignments (user_id, role_id) VALUES (new.id, trial_role_id);
  END IF;
  RETURN new;
END;
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
    v_uid uuid := (select auth.uid());
    v_context_game_code text := p_context->>'game_code';
    -- SỬA LỖI: Đọc đúng key 'business_area_code' thay vì 'business_area'
    v_context_business_area text := p_context->>'business_area_code';
BEGIN
  RETURN EXISTS (
    SELECT 1
    FROM public.user_role_assignments ura
    JOIN public.role_permissions rp ON ura.role_id = rp.role_id
    JOIN public.permissions p ON rp.permission_id = p.id
    LEFT JOIN public.attributes game_attr ON ura.game_attribute_id = game_attr.id
    LEFT JOIN public.attributes area_attr ON ura.business_area_attribute_id = area_attr.id
    WHERE ura.user_id = v_uid AND p.code = p_permission_code
      AND (ura.game_attribute_id IS NULL OR game_attr.code = v_context_game_code)
      AND (ura.business_area_attribute_id IS NULL OR area_attr.code = v_context_business_area)
  );
END;
$$;


ALTER FUNCTION "public"."has_permission"("p_permission_code" "text", "p_context" "jsonb") OWNER TO "postgres";


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
BEGIN
    -- Lấy ngữ cảnh từ đơn hàng để kiểm tra quyền
    SELECT jsonb_build_object('game_code', o.game_code, 'business_area_code', 'SERVICE')
    INTO v_context
    FROM public.order_lines ol JOIN public.orders o ON ol.order_id = o.id
    WHERE ol.id = p_order_line_id;

    -- SỬA LỖI: Thêm ngữ cảnh vào kiểm tra quyền
    IF NOT has_permission('work_session:start', v_context) THEN
        RAISE EXCEPTION 'Authorization failed.';
    END IF;

    SELECT o.id, o.status, ol.paused_at INTO v_order_id, v_current_status, v_paused_at FROM public.order_lines ol JOIN public.orders o ON ol.order_id = o.id WHERE ol.id = p_order_line_id;
    PERFORM 1 FROM public.work_sessions WHERE order_line_id = p_order_line_id AND ended_at IS NULL;
    IF FOUND THEN RAISE EXCEPTION 'Đơn hàng này đã có một phiên làm việc đang hoạt động.'; END IF;
    IF v_current_status = 'paused_selfplay' AND v_paused_at IS NOT NULL THEN
        v_paused_duration := NOW() - v_paused_at;
        UPDATE public.order_lines SET deadline_to = deadline_to + v_paused_duration, total_paused_duration = total_paused_duration + v_paused_duration, paused_at = NULL WHERE id = p_order_line_id;
    END IF;
    IF v_current_status IN ('new', 'pending_pilot', 'paused_selfplay') THEN UPDATE public.orders SET status = 'in_progress' WHERE id = v_order_id; END IF;
    INSERT INTO public.work_sessions (order_line_id, farmer_id, notes, start_state, unpaused_duration) VALUES (p_order_line_id, (select auth.uid()), p_initial_note, p_start_state, v_paused_duration) RETURNING id INTO new_session_id;
    RETURN new_session_id;
END;
$$;


ALTER FUNCTION "public"."start_work_session_v1"("p_order_line_id" "uuid", "p_start_state" "jsonb", "p_initial_note" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."submit_order_review_v1"("p_line_id" "uuid", "p_rating" numeric, "p_comment" "text", "p_proof_urls" "text"[]) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
  -- SỬA LẠI: Kiểm tra quyền 'orders:add_review'
  IF NOT has_permission('orders:add_review') THEN
    RAISE EXCEPTION 'User does not have permission to submit a review';
  END IF;

  INSERT INTO public.order_reviews (order_line_id, rating, comment, proof_urls, created_by)
  VALUES (p_line_id, p_rating, p_comment, p_proof_urls, auth.uid());
END;
$$;


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
DECLARE v_order_line_id UUID; v_order_id UUID; v_current_order_status TEXT; total_items INT; completed_items INT;
BEGIN
    IF TG_OP = 'UPDATE' AND NEW.done_qty <> OLD.done_qty THEN
        v_order_line_id := NEW.order_line_id;
        SELECT ol.order_id, o.status INTO v_order_id, v_current_order_status FROM public.order_lines ol JOIN public.orders o ON ol.order_id = o.id WHERE ol.id = v_order_line_id;
        IF v_current_order_status IN ('completed', 'cancelled', 'pending_completion') THEN RETURN NEW; END IF;
        SELECT count(*) INTO total_items FROM public.order_service_items WHERE order_line_id = v_order_line_id;
        SELECT count(*) INTO completed_items FROM public.order_service_items WHERE order_line_id = v_order_line_id AND done_qty >= COALESCE(plan_qty, 0);
        IF total_items > 0 AND total_items = completed_items THEN
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
BEGIN
  -- Dùng chung quyền 'orders:edit_details'
  IF NOT has_permission('orders:edit_details') THEN
    RAISE EXCEPTION 'User does not have permission to edit orders';
  END IF;

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
BEGIN
  -- 1. Kiểm tra quyền hạn
  IF NOT has_permission('orders:edit_details') THEN
    RAISE EXCEPTION 'User does not have permission to edit orders';
  END IF;

  -- 2. Lấy các ID liên quan từ order_line
  SELECT order_id, customer_account_id INTO v_order_id, v_customer_account_id
  FROM public.order_lines
  WHERE id = p_line_id;

  IF v_order_id IS NULL THEN
    RAISE EXCEPTION 'Order line not found';
  END IF;

  -- 3. Cập nhật các bảng liên quan
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
    -- Tìm product_id của 'Boosting Service'
    SELECT prod.id INTO v_product_id FROM public.products prod WHERE prod.name = 'Boosting Service' LIMIT 1;
    
    IF v_product_id IS NOT NULL THEN
      -- Tạo tên variant dựa trên service_type
      v_variant_name := 'Service-' || lower(p_service_type);

      -- Tìm hoặc tạo mới variant tương ứng
      WITH new_variant AS (
        INSERT INTO public.product_variants (product_id, display_name)
        VALUES (v_product_id, v_variant_name)
        ON CONFLICT (product_id, display_name) DO UPDATE SET display_name = EXCLUDED.display_name
        RETURNING id
      )
      SELECT id INTO v_variant_id FROM new_variant;

      -- Cập nhật variant_id trên order_lines
      UPDATE public.order_lines
      SET variant_id = v_variant_id
      WHERE id = p_line_id;
    END IF;
  END IF;

END;
$$;


ALTER FUNCTION "public"."update_order_details_v1"("p_line_id" "uuid", "p_service_type" "text", "p_deadline" timestamp with time zone, "p_package_note" "text", "p_btag" "text", "p_login_id" "text", "p_login_pwd" "text") OWNER TO "postgres";

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
    "action_proof_urls" "text"[]
);


ALTER TABLE "public"."order_lines" OWNER TO "postgres";


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
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
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
    "id" "uuid" NOT NULL,
    "display_name" "text",
    "status" "text" DEFAULT 'ok'::"text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);

ALTER TABLE ONLY "public"."profiles" FORCE ROW LEVEL SECURITY;


ALTER TABLE "public"."profiles" OWNER TO "postgres";


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
    "params" "jsonb"
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
    "unpaused_duration" interval
);


ALTER TABLE "public"."work_sessions" OWNER TO "postgres";


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
    ADD CONSTRAINT "profiles_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



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



CREATE POLICY "Users can update their own profile" ON "public"."profiles" FOR UPDATE TO "authenticated" USING (("auth"."uid"() = "id")) WITH CHECK (("auth"."uid"() = "id"));



ALTER TABLE "public"."attribute_relationships" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."attributes" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."audit_logs" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "audit_no_delete" ON "public"."audit_logs" FOR DELETE USING (false);



CREATE POLICY "audit_no_update" ON "public"."audit_logs" FOR UPDATE WITH CHECK (false);



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


ALTER TABLE "public"."role_permissions" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."roles" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."service_reports" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_role_assignments" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."work_session_outputs" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."work_sessions" ENABLE ROW LEVEL SECURITY;




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";






REVOKE USAGE ON SCHEMA "public" FROM PUBLIC;
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT ALL ON SCHEMA "public" TO "service_role";


































































































































































GRANT ALL ON FUNCTION "public"."get_user_auth_context_v1"() TO "authenticated";



























GRANT SELECT ON TABLE "public"."attribute_relationships" TO "anon";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."attribute_relationships" TO "authenticated";



GRANT SELECT ON TABLE "public"."attributes" TO "anon";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."attributes" TO "authenticated";



GRANT SELECT ON TABLE "public"."audit_logs" TO "anon";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."audit_logs" TO "authenticated";



GRANT SELECT ON TABLE "public"."channels" TO "anon";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."channels" TO "authenticated";



GRANT SELECT ON TABLE "public"."currencies" TO "anon";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."currencies" TO "authenticated";



GRANT SELECT ON TABLE "public"."customer_accounts" TO "anon";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."customer_accounts" TO "authenticated";



GRANT SELECT ON TABLE "public"."debug_log" TO "anon";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."debug_log" TO "authenticated";



GRANT SELECT ON TABLE "public"."level_exp" TO "anon";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."level_exp" TO "authenticated";



GRANT SELECT ON TABLE "public"."order_lines" TO "anon";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."order_lines" TO "authenticated";



GRANT SELECT ON TABLE "public"."order_reviews" TO "anon";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."order_reviews" TO "authenticated";



GRANT SELECT ON TABLE "public"."order_service_items" TO "anon";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."order_service_items" TO "authenticated";



GRANT SELECT ON TABLE "public"."orders" TO "anon";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."orders" TO "authenticated";



GRANT SELECT ON TABLE "public"."parties" TO "anon";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."parties" TO "authenticated";



GRANT SELECT ON TABLE "public"."permissions" TO "anon";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."permissions" TO "authenticated";



GRANT SELECT ON TABLE "public"."product_variant_attributes" TO "anon";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."product_variant_attributes" TO "authenticated";



GRANT SELECT ON TABLE "public"."product_variants" TO "anon";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."product_variants" TO "authenticated";



GRANT SELECT ON TABLE "public"."products" TO "anon";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."products" TO "authenticated";



GRANT SELECT ON TABLE "public"."profiles" TO "anon";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."profiles" TO "authenticated";



GRANT SELECT ON TABLE "public"."role_permissions" TO "anon";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."role_permissions" TO "authenticated";



GRANT SELECT ON TABLE "public"."roles" TO "anon";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."roles" TO "authenticated";



GRANT SELECT ON TABLE "public"."service_reports" TO "anon";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."service_reports" TO "authenticated";



GRANT SELECT ON TABLE "public"."user_role_assignments" TO "anon";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."user_role_assignments" TO "authenticated";



GRANT SELECT ON TABLE "public"."work_session_outputs" TO "anon";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."work_session_outputs" TO "authenticated";



GRANT SELECT ON TABLE "public"."work_sessions" TO "anon";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."work_sessions" TO "authenticated";









ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT SELECT ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT SELECT,INSERT,DELETE,UPDATE ON TABLES TO "authenticated";





















