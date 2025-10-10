--
-- PostgreSQL database dump
--

-- \restrict 5AGpsGDUgkjoMrugFnCbHDHgSlX4ZczI2fXddzgzqaSG7DuVlLtFKYmp0H01gIe

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
-- SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: auth; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA IF NOT EXISTS "auth";


ALTER SCHEMA "auth" OWNER TO "supabase_admin";

--
-- Name: extensions; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA IF NOT EXISTS "extensions";


ALTER SCHEMA "extensions" OWNER TO "postgres";

--
-- Name: graphql_public; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA IF NOT EXISTS "graphql_public";


ALTER SCHEMA "graphql_public" OWNER TO "supabase_admin";

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA IF NOT EXISTS "public";


ALTER SCHEMA "public" OWNER TO "postgres";

--
-- Name: SCHEMA "public"; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA "public" IS 'Cleaned up duplicate functions on 2025-10-03';


--
-- Name: realtime; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA IF NOT EXISTS "realtime";


ALTER SCHEMA "realtime" OWNER TO "supabase_admin";

--
-- Name: storage; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA IF NOT EXISTS "storage";


ALTER SCHEMA "storage" OWNER TO "supabase_admin";

--
-- Name: aal_level; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE "auth"."aal_level" AS ENUM (
    'aal1',
    'aal2',
    'aal3'
);


ALTER TYPE "auth"."aal_level" OWNER TO "supabase_auth_admin";

--
-- Name: code_challenge_method; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE "auth"."code_challenge_method" AS ENUM (
    's256',
    'plain'
);


ALTER TYPE "auth"."code_challenge_method" OWNER TO "supabase_auth_admin";

--
-- Name: factor_status; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE "auth"."factor_status" AS ENUM (
    'unverified',
    'verified'
);


ALTER TYPE "auth"."factor_status" OWNER TO "supabase_auth_admin";

--
-- Name: factor_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE "auth"."factor_type" AS ENUM (
    'totp',
    'webauthn',
    'phone'
);


ALTER TYPE "auth"."factor_type" OWNER TO "supabase_auth_admin";

--
-- Name: oauth_registration_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE "auth"."oauth_registration_type" AS ENUM (
    'dynamic',
    'manual'
);


ALTER TYPE "auth"."oauth_registration_type" OWNER TO "supabase_auth_admin";

--
-- Name: one_time_token_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE "auth"."one_time_token_type" AS ENUM (
    'confirmation_token',
    'reauthentication_token',
    'recovery_token',
    'email_change_token_new',
    'email_change_token_current',
    'phone_change_token'
);


ALTER TYPE "auth"."one_time_token_type" OWNER TO "supabase_auth_admin";

--
-- Name: account_type_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE "public"."account_type_enum" AS ENUM (
    'btag',
    'login'
);


ALTER TYPE "public"."account_type_enum" OWNER TO "postgres";

--
-- Name: app_role; Type: TYPE; Schema: public; Owner: postgres
--

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

--
-- Name: currency_transaction_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE "public"."currency_transaction_type" AS ENUM (
    'purchase',
    'sale_delivery',
    'exchange_out',
    'exchange_in',
    'transfer',
    'manual_adjustment',
    'farm_in',
    'farm_payout',
    'league_archive'
);


ALTER TYPE "public"."currency_transaction_type" OWNER TO "postgres";

--
-- Name: TYPE "currency_transaction_type"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TYPE "public"."currency_transaction_type" IS 'Các loại giao dịch currency trong hệ thống';


--
-- Name: game_account_purpose; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE "public"."game_account_purpose" AS ENUM (
    'FARM',
    'INVENTORY',
    'TRADE'
);


ALTER TYPE "public"."game_account_purpose" OWNER TO "postgres";

--
-- Name: TYPE "game_account_purpose"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TYPE "public"."game_account_purpose" IS 'Mục đích sử dụng của tài khoản game';


--
-- Name: game_code; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE "public"."game_code" AS ENUM (
    'POE_1',
    'POE_2',
    'DIABLO_4'
);


ALTER TYPE "public"."game_code" OWNER TO "postgres";

--
-- Name: TYPE "game_code"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TYPE "public"."game_code" IS 'Các game được hỗ trợ trong hệ thống';


--
-- Name: order_side_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE "public"."order_side_enum" AS ENUM (
    'BUY',
    'SELL'
);


ALTER TYPE "public"."order_side_enum" OWNER TO "postgres";

--
-- Name: product_type_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE "public"."product_type_enum" AS ENUM (
    'SERVICE',
    'ITEM',
    'CURRENCY'
);


ALTER TYPE "public"."product_type_enum" OWNER TO "postgres";

--
-- Name: trading_fee_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE "public"."trading_fee_type" AS ENUM (
    'PURCHASE_FEE',
    'SALE_FEE',
    'WITHDRAWAL_FEE',
    'CONVERSION_FEE',
    'TAX_FEE'
);


ALTER TYPE "public"."trading_fee_type" OWNER TO "postgres";

--
-- Name: TYPE "trading_fee_type"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TYPE "public"."trading_fee_type" IS 'Các loại phí trong chuỗi giao dịch';


--
-- Name: action; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE "realtime"."action" AS ENUM (
    'INSERT',
    'UPDATE',
    'DELETE',
    'TRUNCATE',
    'ERROR'
);


ALTER TYPE "realtime"."action" OWNER TO "supabase_admin";

--
-- Name: equality_op; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE "realtime"."equality_op" AS ENUM (
    'eq',
    'neq',
    'lt',
    'lte',
    'gt',
    'gte',
    'in'
);


ALTER TYPE "realtime"."equality_op" OWNER TO "supabase_admin";

--
-- Name: user_defined_filter; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE "realtime"."user_defined_filter" AS (
	"column_name" "text",
	"op" "realtime"."equality_op",
	"value" "text"
);


ALTER TYPE "realtime"."user_defined_filter" OWNER TO "supabase_admin";

--
-- Name: wal_column; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE "realtime"."wal_column" AS (
	"name" "text",
	"type_name" "text",
	"type_oid" "oid",
	"value" "jsonb",
	"is_pkey" boolean,
	"is_selectable" boolean
);


ALTER TYPE "realtime"."wal_column" OWNER TO "supabase_admin";

--
-- Name: wal_rls; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE "realtime"."wal_rls" AS (
	"wal" "jsonb",
	"is_rls_enabled" boolean,
	"subscription_ids" "uuid"[],
	"errors" "text"[]
);


ALTER TYPE "realtime"."wal_rls" OWNER TO "supabase_admin";

--
-- Name: buckettype; Type: TYPE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TYPE "storage"."buckettype" AS ENUM (
    'STANDARD',
    'ANALYTICS'
);


ALTER TYPE "storage"."buckettype" OWNER TO "supabase_storage_admin";

--
-- Name: email(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE OR REPLACE FUNCTION "auth"."email"() RETURNS "text"
    LANGUAGE "sql" STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.email', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'email')
  )::text
$$;


ALTER FUNCTION "auth"."email"() OWNER TO "supabase_auth_admin";

--
-- Name: FUNCTION "email"(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION "auth"."email"() IS 'Deprecated. Use auth.jwt() -> ''email'' instead.';


--
-- Name: jwt(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE OR REPLACE FUNCTION "auth"."jwt"() RETURNS "jsonb"
    LANGUAGE "sql" STABLE
    AS $$
  select 
    coalesce(
        nullif(current_setting('request.jwt.claim', true), ''),
        nullif(current_setting('request.jwt.claims', true), '')
    )::jsonb
$$;


ALTER FUNCTION "auth"."jwt"() OWNER TO "supabase_auth_admin";

--
-- Name: role(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE OR REPLACE FUNCTION "auth"."role"() RETURNS "text"
    LANGUAGE "sql" STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.role', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'role')
  )::text
$$;


ALTER FUNCTION "auth"."role"() OWNER TO "supabase_auth_admin";

--
-- Name: FUNCTION "role"(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION "auth"."role"() IS 'Deprecated. Use auth.jwt() -> ''role'' instead.';


--
-- Name: uid(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE OR REPLACE FUNCTION "auth"."uid"() RETURNS "uuid"
    LANGUAGE "sql" STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.sub', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
  )::uuid
$$;


ALTER FUNCTION "auth"."uid"() OWNER TO "supabase_auth_admin";

--
-- Name: FUNCTION "uid"(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION "auth"."uid"() IS 'Deprecated. Use auth.jwt() -> ''sub'' instead.';


--
-- Name: grant_pg_cron_access(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE OR REPLACE FUNCTION "extensions"."grant_pg_cron_access"() RETURNS "event_trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  IF EXISTS (
    SELECT
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_cron'
  )
  THEN
    grant usage on schema cron to postgres with grant option;

    alter default privileges in schema cron grant all on tables to postgres with grant option;
    alter default privileges in schema cron grant all on functions to postgres with grant option;
    alter default privileges in schema cron grant all on sequences to postgres with grant option;

    alter default privileges for user supabase_admin in schema cron grant all
        on sequences to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on tables to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on functions to postgres with grant option;

    grant all privileges on all tables in schema cron to postgres with grant option;
    revoke all on table cron.job from postgres;
    grant select on table cron.job to postgres with grant option;
  END IF;
END;
$$;


ALTER FUNCTION "extensions"."grant_pg_cron_access"() OWNER TO "supabase_admin";

--
-- Name: FUNCTION "grant_pg_cron_access"(); Type: COMMENT; Schema: extensions; Owner: supabase_admin
--

COMMENT ON FUNCTION "extensions"."grant_pg_cron_access"() IS 'Grants access to pg_cron';


--
-- Name: grant_pg_graphql_access(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE OR REPLACE FUNCTION "extensions"."grant_pg_graphql_access"() RETURNS "event_trigger"
    LANGUAGE "plpgsql"
    AS $_$
DECLARE
    func_is_graphql_resolve bool;
BEGIN
    func_is_graphql_resolve = (
        SELECT n.proname = 'resolve'
        FROM pg_event_trigger_ddl_commands() AS ev
        LEFT JOIN pg_catalog.pg_proc AS n
        ON ev.objid = n.oid
    );

    IF func_is_graphql_resolve
    THEN
        -- Update public wrapper to pass all arguments through to the pg_graphql resolve func
        DROP FUNCTION IF EXISTS graphql_public.graphql;
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language sql
        as $$
            select graphql.resolve(
                query := query,
                variables := coalesce(variables, '{}'),
                "operationName" := "operationName",
                extensions := extensions
            );
        $$;

        -- This hook executes when `graphql.resolve` is created. That is not necessarily the last
        -- function in the extension so we need to grant permissions on existing entities AND
        -- update default permissions to any others that are created after `graphql.resolve`
        grant usage on schema graphql to postgres, anon, authenticated, service_role;
        grant select on all tables in schema graphql to postgres, anon, authenticated, service_role;
        grant execute on all functions in schema graphql to postgres, anon, authenticated, service_role;
        grant all on all sequences in schema graphql to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on tables to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on functions to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on sequences to postgres, anon, authenticated, service_role;

        -- Allow postgres role to allow granting usage on graphql and graphql_public schemas to custom roles
        grant usage on schema graphql_public to postgres with grant option;
        grant usage on schema graphql to postgres with grant option;
    END IF;

END;
$_$;


ALTER FUNCTION "extensions"."grant_pg_graphql_access"() OWNER TO "supabase_admin";

--
-- Name: FUNCTION "grant_pg_graphql_access"(); Type: COMMENT; Schema: extensions; Owner: supabase_admin
--

COMMENT ON FUNCTION "extensions"."grant_pg_graphql_access"() IS 'Grants access to pg_graphql';


--
-- Name: grant_pg_net_access(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE OR REPLACE FUNCTION "extensions"."grant_pg_net_access"() RETURNS "event_trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_net'
  )
  THEN
    IF NOT EXISTS (
      SELECT 1
      FROM pg_roles
      WHERE rolname = 'supabase_functions_admin'
    )
    THEN
      CREATE USER supabase_functions_admin NOINHERIT CREATEROLE LOGIN NOREPLICATION;
    END IF;

    GRANT USAGE ON SCHEMA net TO supabase_functions_admin, postgres, anon, authenticated, service_role;

    IF EXISTS (
      SELECT FROM pg_extension
      WHERE extname = 'pg_net'
      -- all versions in use on existing projects as of 2025-02-20
      -- version 0.12.0 onwards don't need these applied
      AND extversion IN ('0.2', '0.6', '0.7', '0.7.1', '0.8', '0.10.0', '0.11.0')
    ) THEN
      ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;
      ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;

      ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;
      ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;

      REVOKE ALL ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;
      REVOKE ALL ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;

      GRANT EXECUTE ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
      GRANT EXECUTE ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
    END IF;
  END IF;
END;
$$;


ALTER FUNCTION "extensions"."grant_pg_net_access"() OWNER TO "supabase_admin";

--
-- Name: FUNCTION "grant_pg_net_access"(); Type: COMMENT; Schema: extensions; Owner: supabase_admin
--

COMMENT ON FUNCTION "extensions"."grant_pg_net_access"() IS 'Grants access to pg_net';


--
-- Name: pgrst_ddl_watch(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE OR REPLACE FUNCTION "extensions"."pgrst_ddl_watch"() RETURNS "event_trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  cmd record;
BEGIN
  FOR cmd IN SELECT * FROM pg_event_trigger_ddl_commands()
  LOOP
    IF cmd.command_tag IN (
      'CREATE SCHEMA', 'ALTER SCHEMA'
    , 'CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO', 'ALTER TABLE'
    , 'CREATE FOREIGN TABLE', 'ALTER FOREIGN TABLE'
    , 'CREATE VIEW', 'ALTER VIEW'
    , 'CREATE MATERIALIZED VIEW', 'ALTER MATERIALIZED VIEW'
    , 'CREATE FUNCTION', 'ALTER FUNCTION'
    , 'CREATE TRIGGER'
    , 'CREATE TYPE', 'ALTER TYPE'
    , 'CREATE RULE'
    , 'COMMENT'
    )
    -- don't notify in case of CREATE TEMP table or other objects created on pg_temp
    AND cmd.schema_name is distinct from 'pg_temp'
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


ALTER FUNCTION "extensions"."pgrst_ddl_watch"() OWNER TO "supabase_admin";

--
-- Name: pgrst_drop_watch(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE OR REPLACE FUNCTION "extensions"."pgrst_drop_watch"() RETURNS "event_trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  obj record;
BEGIN
  FOR obj IN SELECT * FROM pg_event_trigger_dropped_objects()
  LOOP
    IF obj.object_type IN (
      'schema'
    , 'table'
    , 'foreign table'
    , 'view'
    , 'materialized view'
    , 'function'
    , 'trigger'
    , 'type'
    , 'rule'
    )
    AND obj.is_temporary IS false -- no pg_temp objects
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


ALTER FUNCTION "extensions"."pgrst_drop_watch"() OWNER TO "supabase_admin";

--
-- Name: set_graphql_placeholder(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE OR REPLACE FUNCTION "extensions"."set_graphql_placeholder"() RETURNS "event_trigger"
    LANGUAGE "plpgsql"
    AS $_$
    DECLARE
    graphql_is_dropped bool;
    BEGIN
    graphql_is_dropped = (
        SELECT ev.schema_name = 'graphql_public'
        FROM pg_event_trigger_dropped_objects() AS ev
        WHERE ev.schema_name = 'graphql_public'
    );

    IF graphql_is_dropped
    THEN
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language plpgsql
        as $$
            DECLARE
                server_version float;
            BEGIN
                server_version = (SELECT (SPLIT_PART((select version()), ' ', 2))::float);

                IF server_version >= 14 THEN
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql extension is not enabled.'
                            )
                        )
                    );
                ELSE
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql is only available on projects running Postgres 14 onwards.'
                            )
                        )
                    );
                END IF;
            END;
        $$;
    END IF;

    END;
$_$;


ALTER FUNCTION "extensions"."set_graphql_placeholder"() OWNER TO "supabase_admin";

--
-- Name: FUNCTION "set_graphql_placeholder"(); Type: COMMENT; Schema: extensions; Owner: supabase_admin
--

COMMENT ON FUNCTION "extensions"."set_graphql_placeholder"() IS 'Reintroduces placeholder function for graphql_public.graphql';


--
-- Name: add_vault_secret("text", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

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

--
-- Name: admin_get_all_users(); Type: FUNCTION; Schema: public; Owner: postgres
--

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

--
-- Name: admin_get_roles_and_permissions(); Type: FUNCTION; Schema: public; Owner: postgres
--

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

--
-- Name: admin_rebase_item_progress_v1("uuid", numeric, "jsonb", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

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

--
-- Name: admin_update_permissions_for_role("uuid", "uuid"[]); Type: FUNCTION; Schema: public; Owner: postgres
--

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

--
-- Name: admin_update_user_assignments("uuid", "jsonb"); Type: FUNCTION; Schema: public; Owner: postgres
--

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

--
-- Name: admin_update_user_status("uuid", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

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

--
-- Name: archive_league_currency_v1("uuid", "uuid", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."archive_league_currency_v1"("p_from_league_id" "uuid", "p_to_league_id" "uuid", "p_archive_type" "text" DEFAULT 'standard'::"text") RETURNS TABLE("success" boolean, "message" "text", "transactions_created" bigint, "total_value_vnd" numeric)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_from_league RECORD;
    v_to_league RECORD;
    v_can_archive BOOLEAN := FALSE;
    v_transaction_count BIGINT := 0;
    v_total_value NUMERIC := 0;
BEGIN
    -- Check permissions (admin or manager only)
    SELECT EXISTS(
        SELECT 1 FROM user_role_assignments ura
        JOIN roles r ON ura.role_id = r.id
        JOIN attributes ba ON ura.business_area_attribute_id = ba.id
        WHERE ura.user_id = v_user_id
        AND ba.code = 'CURRENCY'
        AND r.code IN ('admin', 'manager')
    ) INTO v_can_archive;

    IF NOT v_can_archive THEN
        RETURN QUERY SELECT FALSE, 'Permission denied: Cannot archive league currency', 0, 0;
        RETURN;
    END IF;

    -- Get league details
    SELECT fl.*
    INTO v_from_league
    FROM attributes fl
    WHERE fl.id = p_from_league_id;

    IF v_from_league IS NULL THEN
        RETURN QUERY SELECT FALSE, 'Invalid source or target league', 0, 0;
        RETURN;
    END IF;

    -- Archive all inventory in the league
    INSERT INTO currency_transactions (
        game_account_id,
        game_code,
        league_attribute_id,
        transaction_type,
        currency_attribute_id,
        quantity,
        unit_price_vnd,
        unit_price_usd,
        notes,
        created_by
    )
    SELECT
        inv.game_account_id,
        ga.game_code,
        p_from_league_id,
        'league_archive',
        inv.currency_attribute_id,
        -inv.quantity, -- Move all currency out
        inv.avg_buy_price_vnd,
        inv.avg_buy_price_usd,
        format('League archive: %s → %s. Moved %s %s',
            v_from_league.name,
            (SELECT name FROM attributes WHERE id = p_to_league_id),
            inv.quantity,
            (SELECT name FROM attributes WHERE id = inv.currency_attribute_id)
        ),
        v_user_id
    FROM currency_inventory inv
    JOIN game_accounts ga ON inv.game_account_id = ga.id
    WHERE ga.league_attribute_id = p_from_league_id
    AND inv.quantity > 0
    RETURNING id INTO v_transaction_count;

    -- Calculate total value
    SELECT COALESCE(SUM(quantity * avg_buy_price_vnd), 0)
    INTO v_total_value
    FROM currency_inventory inv
    JOIN game_accounts ga ON inv.game_account_id = ga.id
    WHERE ga.league_attribute_id = p_from_league_id
    AND inv.quantity > 0;

    -- Clear inventory
    DELETE FROM currency_inventory
    WHERE game_account_id IN (
        SELECT id FROM game_accounts WHERE league_attribute_id = p_from_league_id
    );

    RETURN QUERY SELECT TRUE,
        format('League %s archived successfully. %s transactions processed, total value: %s VND',
            v_from_league.name,
            v_transaction_count,
            v_total_value
        ),
        v_transaction_count,
        v_total_value;
END;
$$;


ALTER FUNCTION "public"."archive_league_currency_v1"("p_from_league_id" "uuid", "p_to_league_id" "uuid", "p_archive_type" "text") OWNER TO "postgres";

--
-- Name: audit_ctx_v1(); Type: FUNCTION; Schema: public; Owner: postgres
--

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

--
-- Name: audit_diff_v1("jsonb", "jsonb"); Type: FUNCTION; Schema: public; Owner: postgres
--

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

--
-- Name: auto_create_inventory_records(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."auto_create_inventory_records"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    v_currency_record RECORD;
BEGIN
    -- For INVENTORY type accounts, create empty inventory records for all currencies
    IF NEW.purpose = 'INVENTORY' THEN
        -- Create inventory records for all currencies of this game
        FOR v_currency_record IN
            SELECT id
            FROM public.attributes
            WHERE type = NEW.game_code || '_CURRENCY'
        LOOP
            INSERT INTO public.currency_inventory (
                game_account_id,
                currency_attribute_id,
                quantity,
                reserved_quantity,
                avg_buy_price_vnd,
                avg_buy_price_usd,
                last_updated_at
            ) VALUES (
                NEW.id,
                v_currency_record.id,
                0,
                0,
                0,
                0,
                NOW()
            )
            ON CONFLICT (game_account_id, currency_attribute_id)
            DO NOTHING;
        END LOOP;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."auto_create_inventory_records"() OWNER TO "postgres";

--
-- Name: FUNCTION "auto_create_inventory_records"(); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION "public"."auto_create_inventory_records"() IS 'Tự động tạo record tồn kho cho tài khoản inventory mới';


--
-- Name: calculate_chain_costs("uuid", numeric, "text", "text", "jsonb"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."calculate_chain_costs"("p_chain_id" "uuid", "p_from_amount" numeric, "p_from_currency" "text", "p_to_currency" "text", "p_exchange_rates" "jsonb" DEFAULT '{}'::"jsonb") RETURNS TABLE("step_number" integer, "from_amount" numeric, "to_amount" numeric, "from_currency" "text", "to_currency" "text", "fee_type" "text", "fee_amount" numeric, "fee_currency" "text", "description" "text", "cumulative_amount" numeric)
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    v_chain JSONB;
    v_step JSONB;
    v_current_amount NUMERIC := p_from_amount;
    v_current_currency TEXT := p_from_currency;
    v_exchange_rate NUMERIC;
BEGIN
    -- Get chain steps
    SELECT chain_steps INTO v_chain
    FROM public.trading_fee_chains
    WHERE id = p_chain_id AND is_active = true;

    IF v_chain IS NULL THEN
        RAISE EXCEPTION 'Trading chain not found or inactive';
    END IF;

    -- Process each step in chain
    FOR v_step IN SELECT * FROM jsonb_array_elements(v_chain) as step
    LOOP
        -- Calculate exchange rate if needed
        IF v_step->>'from_currency' <> v_step->>'to_currency' THEN
            v_exchange_rate := (p_exchange_rates ->> (v_step->>'from_currency' || '_' || v_step->>'to_currency'))::NUMERIC;
            IF v_exchange_rate IS NULL THEN
                -- Try to get from database
                SELECT rate INTO v_exchange_rate
                FROM public.exchange_rates
                WHERE source_currency = v_step->>'from_currency'
                  AND target_currency = v_step->>'to_currency';

                IF v_exchange_rate IS NULL THEN
                    RAISE EXCEPTION 'Missing exchange rate for % to %', v_step->>'from_currency', v_step->>'to_currency';
                END IF;
            END IF;
        ELSE
            v_exchange_rate := 1;
        END IF;

        -- Calculate amount after exchange rate
        DECLARE
            v_exchanged_amount NUMERIC;
            v_fee_amount NUMERIC;
        BEGIN
            v_exchanged_amount := v_current_amount * v_exchange_rate;

            -- Calculate fee
            IF (v_step->>'fee_currency') = (v_step->>'to_currency') THEN
                -- Fee calculated on target currency
                v_fee_amount := (v_exchanged_amount * (v_step->>'fee_percent')::NUMERIC / 100) + (v_step->>'fee_fixed')::NUMERIC;
            ELSE
                -- Fee calculated on source currency, need conversion
                v_fee_amount := ((v_current_amount * (v_step->>'fee_percent')::NUMERIC / 100) + (v_step->>'fee_fixed')::NUMERIC) * v_exchange_rate;
            END IF;

            -- Return results for this step
            RETURN QUERY
            SELECT
                (v_step->>'step')::INTEGER as step_number,
                v_current_amount as from_amount,
                (v_exchanged_amount - v_fee_amount) as to_amount,
                v_step->>'from_currency' as from_currency,
                v_step->>'to_currency' as to_currency,
                v_step->>'fee_type' as fee_type,
                v_fee_amount as fee_amount,
                v_step->>'fee_currency' as fee_currency,
                v_step->>'description' as description,
                (v_exchanged_amount - v_fee_amount) as cumulative_amount;

            -- Update for next step
            v_current_amount := v_exchanged_amount - v_fee_amount;
            v_current_currency := v_step->>'to_currency';
        END;
    END LOOP;
END;
$$;


ALTER FUNCTION "public"."calculate_chain_costs"("p_chain_id" "uuid", "p_from_amount" numeric, "p_from_currency" "text", "p_to_currency" "text", "p_exchange_rates" "jsonb") OWNER TO "postgres";

--
-- Name: FUNCTION "calculate_chain_costs"("p_chain_id" "uuid", "p_from_amount" numeric, "p_from_currency" "text", "p_to_currency" "text", "p_exchange_rates" "jsonb"); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION "public"."calculate_chain_costs"("p_chain_id" "uuid", "p_from_amount" numeric, "p_from_currency" "text", "p_to_currency" "text", "p_exchange_rates" "jsonb") IS 'Tính toán chi phí qua từng bước trong chuỗi phí (fixed security)';


--
-- Name: calculate_profit_for_order_v1("uuid"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."calculate_profit_for_order_v1"("p_order_line_id" "uuid") RETURNS TABLE("order_line_id" "uuid", "purchase_amount" numeric, "sale_amount" numeric, "channel_name" "text", "fee_chain_name" "text", "total_fees" numeric, "net_profit" numeric, "profit_margin_percent" numeric)
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_can_view BOOLEAN := FALSE;
BEGIN
    -- Set search_path to public
    SET LOCAL search_path TO public;

    -- Check permissions
    SELECT EXISTS(
        SELECT 1 FROM user_role_assignments ura
        JOIN attributes ba ON ura.business_area_attribute_id = ba.id
        WHERE ura.user_id = v_user_id
        AND ba.code = 'CURRENCY'
    ) INTO v_can_view;

    IF NOT v_can_view THEN
        RAISE EXCEPTION 'Permission denied: Cannot view order profit';
    END IF;

    -- Calculate profit using trading fee chain
    RETURN QUERY
    WITH order_data AS (
        SELECT
            ol.id as order_line_id,
            ol.quantity,
            ol.unit_price_vnd,
            ol.channel_id,
            ch.name as channel_name,
            tfc.name as fee_chain_name
        FROM order_lines ol
        JOIN channels ch ON ol.channel_id = ch.id
        LEFT JOIN trading_fee_chains tfc ON ch.trading_fee_chain_id = tfc.id
        WHERE ol.id = p_order_line_id
    ),
    fees AS (
        SELECT
            SUM(CASE
                WHEN ft.type = 'PERCENTAGE' THEN od.quantity * od.unit_price_vnd * (ft.value / 100)
                WHEN ft.type = 'FIXED_VND' THEN ft.value
                WHEN ft.type = 'FIXED_USD' THEN ft.value * COALESCE((SELECT rate FROM exchange_rates WHERE source_currency = 'USD' AND target_currency = 'VND'), 25700)
                ELSE 0
            END) as total_fees
        FROM order_data od
        LEFT JOIN trading_fee_chains tfc ON od.fee_chain_name = tfc.name
        LEFT JOIN trading_fees tf ON tfc.id = tf.fee_chain_id
        WHERE tf.is_active = true
    ),
    transactions AS (
        SELECT
            SUM(CASE
                WHEN ct.transaction_type IN ('purchase', 'farm_in') THEN ct.quantity * ct.unit_price_vnd
                ELSE 0
            END) as purchase_amount,
            SUM(CASE
                WHEN ct.transaction_type IN ('sale_delivery', 'exchange_in') THEN ABS(ct.quantity * ct.unit_price_vnd)
                ELSE 0
            END) as sale_amount
        FROM currency_transactions ct
        WHERE ct.order_line_id = p_order_line_id
    )
    SELECT
        od.order_line_id,
        COALESCE(t.purchase_amount, 0) as purchase_amount,
        COALESCE(t.sale_amount, od.quantity * od.unit_price_vnd) as sale_amount,
        od.channel_name,
        od.fee_chain_name,
        COALESCE(f.total_fees, 0) as total_fees,
        (COALESCE(t.sale_amount, od.quantity * od.unit_price_vnd) - COALESCE(t.purchase_amount, 0) - COALESCE(f.total_fees, 0)) as net_profit,
        CASE
            WHEN COALESCE(t.purchase_amount, 0) > 0
            THEN ((COALESCE(t.sale_amount, od.quantity * od.unit_price_vnd) - COALESCE(t.purchase_amount, 0) - COALESCE(f.total_fees, 0)) / COALESCE(t.purchase_amount, 0)) * 100
            ELSE 0
        END as profit_margin_percent
    FROM order_data od
    LEFT JOIN fees f ON true
    LEFT JOIN transactions t ON true;
END;
$$;


ALTER FUNCTION "public"."calculate_profit_for_order_v1"("p_order_line_id" "uuid") OWNER TO "postgres";

--
-- Name: FUNCTION "calculate_profit_for_order_v1"("p_order_line_id" "uuid"); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION "public"."calculate_profit_for_order_v1"("p_order_line_id" "uuid") IS 'Calculate profit for order with fee chain integration (v1)';


--
-- Name: calculate_simple_profit_loss(numeric, "text", numeric, "text", "uuid", "jsonb"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."calculate_simple_profit_loss"("p_purchase_amount" numeric, "p_purchase_currency" "text", "p_sale_amount" numeric, "p_sale_currency" "text", "p_chain_id" "uuid", "p_exchange_rates" "jsonb" DEFAULT '{}'::"jsonb") RETURNS TABLE("purchase_amount" numeric, "purchase_currency" "text", "sale_amount" numeric, "sale_currency" "text", "total_fees" numeric, "net_profit" numeric, "profit_margin_percent" numeric)
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    v_total_fees NUMERIC := 0;
    v_final_amount NUMERIC;
    v_exchange_rate NUMERIC;
BEGIN
    -- Calculate total fees for sale chain
    SELECT COALESCE(SUM(fee_amount), 0) INTO v_total_fees
    FROM public.calculate_chain_costs(p_chain_id, p_sale_amount, p_sale_currency, p_purchase_currency, p_exchange_rates);

    -- Get final amount
    SELECT cumulative_amount INTO v_final_amount
    FROM public.calculate_chain_costs(p_chain_id, p_sale_amount, p_sale_currency, p_purchase_currency, p_exchange_rates)
    ORDER BY step_number DESC
    LIMIT 1;

    -- Convert purchase amount to same currency for comparison
    IF p_purchase_currency <> p_sale_currency THEN
        v_exchange_rate := (p_exchange_rates ->> (p_purchase_currency || '_' || p_sale_currency))::NUMERIC;
        IF v_exchange_rate IS NULL THEN
            SELECT rate INTO v_exchange_rate
            FROM public.exchange_rates
            WHERE source_currency = p_purchase_currency
              AND target_currency = p_sale_currency;
        END IF;

        IF v_exchange_rate IS NOT NULL THEN
            v_final_amount := v_final_amount - (p_purchase_amount * v_exchange_rate);
        ELSE
            v_final_amount := NULL; -- Cannot calculate without exchange rate
        END IF;
    ELSE
        v_final_amount := v_final_amount - p_purchase_amount;
    END IF;

    RETURN QUERY
    SELECT
        p_purchase_amount as purchase_amount,
        p_purchase_currency as purchase_currency,
        p_sale_amount as sale_amount,
        p_sale_currency as sale_currency,
        v_total_fees as total_fees,
        COALESCE(v_final_amount, 0) as net_profit,
        CASE
            WHEN p_purchase_amount > 0 AND v_final_amount IS NOT NULL
            THEN ((v_final_amount) / p_purchase_amount * 100)
            ELSE NULL
        END as profit_margin_percent;
END;
$$;


ALTER FUNCTION "public"."calculate_simple_profit_loss"("p_purchase_amount" numeric, "p_purchase_currency" "text", "p_sale_amount" numeric, "p_sale_currency" "text", "p_chain_id" "uuid", "p_exchange_rates" "jsonb") OWNER TO "postgres";

--
-- Name: FUNCTION "calculate_simple_profit_loss"("p_purchase_amount" numeric, "p_purchase_currency" "text", "p_sale_amount" numeric, "p_sale_currency" "text", "p_chain_id" "uuid", "p_exchange_rates" "jsonb"); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION "public"."calculate_simple_profit_loss"("p_purchase_amount" numeric, "p_purchase_currency" "text", "p_sale_amount" numeric, "p_sale_currency" "text", "p_chain_id" "uuid", "p_exchange_rates" "jsonb") IS 'Tính toán lợi nhuận đơn giản cho một giao dịch (fixed security)';


--
-- Name: can_assign_pilot_order("uuid"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."can_assign_pilot_order"("p_order_id" "uuid") RETURNS TABLE("can_assign" boolean, "reason" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    v_service_type TEXT;
    v_order_status TEXT;
    v_pilot_is_blocked BOOLEAN;
    v_pilot_warning_level INTEGER;
BEGIN
    -- Lấy thông tin order
    SELECT
        (SELECT a.name FROM product_variant_attributes pva
         JOIN attributes a ON pva.attribute_id = a.id
         WHERE pva.variant_id = ol.variant_id AND a.type = 'SERVICE_TYPE' LIMIT 1) as service_type,
        o.status,
        ol.pilot_is_blocked,
        ol.pilot_warning_level
    INTO v_service_type, v_order_status, v_pilot_is_blocked, v_pilot_warning_level
    FROM orders o
    JOIN order_lines ol ON o.id = ol.order_id
    WHERE o.id = p_order_id;

    -- Chỉ áp dụng cho pilot orders đang hoạt động
    IF v_service_type != 'pilot' OR
       v_order_status IN ('completed', 'cancelled', 'delivered', 'pending_completion') THEN
        RETURN QUERY SELECT true, 'Không áp dụng cho đơn hàng này'::TEXT;
        RETURN;
    END IF;

    -- Kiểm tra blocked status
    IF v_pilot_is_blocked THEN
        RETURN QUERY SELECT false, 'Pilot đã online liên tục quá 6 ngày, cần nghỉ để reset chu kỳ'::TEXT;
        RETURN;
    END IF;

    -- Kiểm tra warning level
    IF v_pilot_warning_level >= 1 THEN
        RETURN QUERY SELECT true, 'Cảnh báo: Pilot sắp đạt giới hạn online liên tục'::TEXT;
        RETURN;
    END IF;

    -- Có thể gán
    RETURN QUERY SELECT true, 'Có thể gán đơn hàng cho pilot'::TEXT;
    RETURN;
END;
$$;


ALTER FUNCTION "public"."can_assign_pilot_order"("p_order_id" "uuid") OWNER TO "postgres";

--
-- Name: cancel_order_line_v1("uuid", "text"[], "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

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

--
-- Name: cancel_work_session_v1("uuid"); Type: FUNCTION; Schema: public; Owner: postgres
--

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

    -- ✅ FIX: Lấy service_type từ attributes (đồng bộ với toggle_customer_playing)
    SELECT
        ol.order_id,
        (SELECT a.name FROM product_variant_attributes pva
         JOIN attributes a ON pva.attribute_id = a.id
         WHERE pva.variant_id = ol.variant_id AND a.type = 'SERVICE_TYPE' LIMIT 1) as service_type
    INTO
        v_order_id,
        v_service_type
    FROM public.order_lines ol
    WHERE ol.id = v_order_line_id;

    -- ✅ FIX: Dùng tên đúng - kiểm tra cả 2 khả năng
    IF v_service_type IN ('Service - Selfplay', 'Selfplay') THEN
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
        IF v_service_type IN ('Service - Pilot', 'Pilot') THEN
            UPDATE public.orders SET status = 'pending_pilot' WHERE id = v_order_id;
        ELSIF v_service_type IN ('Service - Selfplay', 'Selfplay') THEN
            UPDATE public.orders SET status = 'paused_selfplay' WHERE id = v_order_id;
        END IF;
    ELSE
        UPDATE public.orders SET status = 'new' WHERE id = v_order_id;
    END IF;
END;
$$;


ALTER FUNCTION "public"."cancel_work_session_v1"("p_session_id" "uuid") OWNER TO "postgres";

--
-- Name: check_and_reset_pilot_cycle("uuid"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."check_and_reset_pilot_cycle"("p_order_line_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    v_service_type TEXT;
    v_order_status TEXT;
    v_hours_online NUMERIC;
    v_hours_rest NUMERIC;
    v_current_paused_at TIMESTAMP WITH TIME ZONE;
    v_cycle_start_at TIMESTAMP WITH TIME ZONE;
    v_required_rest_hours INTEGER;
BEGIN
    -- Get order information
    SELECT pv.display_name, o.status, ol.paused_at,
           COALESCE(ol.pilot_cycle_start_at, o.created_at) as cycle_start_at
    INTO v_service_type, v_order_status, v_current_paused_at, v_cycle_start_at
    FROM public.orders o
    JOIN public.order_lines ol ON o.id = ol.order_id
    JOIN public.product_variants pv ON ol.variant_id = pv.id
    WHERE ol.id = p_order_line_id;

    -- Only process pilot orders
    IF v_service_type != 'Service - Pilot' THEN
        RETURN;
    END IF;

    -- Skip completed orders
    IF v_order_status IN ('completed', 'cancelled', 'delivered', 'pending_completion') THEN
        RETURN;
    END IF;

    -- Check if currently resting
    IF v_current_paused_at IS NULL THEN
        RETURN;
    END IF;

    -- Calculate online and rest hours
    v_hours_online := EXTRACT(EPOCH FROM (v_current_paused_at - v_cycle_start_at)) / 3600;
    v_hours_rest := EXTRACT(EPOCH FROM (NOW() - v_current_paused_at)) / 3600;

    -- Determine required rest hours
    v_required_rest_hours := CASE
        WHEN v_hours_online <= 4 * 24 THEN 6  -- <= 4 days: 6 hours
        ELSE 12  -- > 4 days: 12 hours
    END;

    -- Reset if enough rest
    IF v_hours_rest >= v_required_rest_hours THEN
        -- Reset pilot cycle
        UPDATE public.order_lines
        SET
            pilot_cycle_start_at = v_current_paused_at,
            pilot_warning_level = 0,
            pilot_is_blocked = FALSE,
            paused_at = NULL
        WHERE id = p_order_line_id;
    END IF;
END;
$$;


ALTER FUNCTION "public"."check_and_reset_pilot_cycle"("p_order_line_id" "uuid") OWNER TO "postgres";

--
-- Name: complete_order_line_v1("uuid", "text"[], "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

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

--
-- Name: create_currency_sell_order_v1("uuid", "uuid", numeric, numeric, numeric, "uuid", "text", "text", "text", "uuid", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."create_currency_sell_order_v1"("p_game_account_id" "uuid", "p_currency_attribute_id" "uuid", "p_quantity" numeric, "p_unit_price_vnd" numeric, "p_unit_price_usd" numeric, "p_channel_id" "uuid", "p_customer_name" "text" DEFAULT NULL::"text", "p_game_tag" "text" DEFAULT NULL::"text", "p_delivery_info" "text" DEFAULT NULL::"text", "p_order_line_id" "uuid" DEFAULT NULL::"uuid", "p_notes" "text" DEFAULT NULL::"text") RETURNS TABLE("success" boolean, "transaction_id" "uuid", "message" "text", "inventory_available" boolean)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_game_code TEXT;
    v_league_id UUID;
    v_transaction_id UUID;
    v_available_quantity NUMERIC := 0;
    v_can_create BOOLEAN := FALSE;
BEGIN
    -- Check permissions
    SELECT EXISTS(
        SELECT 1 FROM user_role_assignments ura
        JOIN attributes ba ON ura.business_area_attribute_id = ba.id
        WHERE ura.user_id = v_user_id
        AND ba.code = 'CURRENCY'
        AND (
            ura.game_attribute_id IS NULL
            OR EXISTS (
                SELECT 1 FROM game_accounts ga
                WHERE ga.id = p_game_account_id
                AND ga.game_code = (
                    SELECT code FROM attributes WHERE id = ura.game_attribute_id
                )
            )
        )
    ) INTO v_can_create;

    IF NOT v_can_create THEN
        RETURN QUERY SELECT FALSE, NULL::UUID, 'Permission denied: Cannot create sell order', FALSE;
        RETURN;
    END IF;

    -- Get game and league info
    SELECT game_code, league_attribute_id
    INTO v_game_code, v_league_id
    FROM game_accounts
    WHERE id = p_game_account_id;

    IF v_game_code IS NULL THEN
        RETURN QUERY SELECT FALSE, NULL::UUID, 'Invalid game account', FALSE;
        RETURN;
    END IF;

    -- Check inventory availability
    SELECT COALESCE(SUM(quantity - reserved_quantity), 0)
    INTO v_available_quantity
    FROM currency_inventory
    WHERE game_account_id = p_game_account_id
    AND currency_attribute_id = p_currency_attribute_id;

    IF v_available_quantity < p_quantity THEN
        RETURN QUERY SELECT FALSE, NULL::UUID,
            format('Insufficient inventory: Available %s, Requested %s', v_available_quantity, p_quantity),
            FALSE;
        RETURN;
    END IF;

    -- Create sell transaction
    INSERT INTO currency_transactions (
        game_account_id,
        game_code,
        league_attribute_id,
        transaction_type,
        currency_attribute_id,
        quantity,
        unit_price_vnd,
        unit_price_usd,
        channel_id,
        order_line_id,
        notes,
        created_by
    ) VALUES (
        p_game_account_id,
        v_game_code,
        v_league_id,
        'sale_delivery',
        p_currency_attribute_id,
        -p_quantity, -- Negative for outgoing
        p_unit_price_vnd,
        p_unit_price_usd,
        p_channel_id,
        p_order_line_id,
        format('Customer: %s, Game Tag: %s, Delivery: %s',
            COALESCE(p_customer_name, 'N/A'),
            COALESCE(p_game_tag, 'N/A'),
            COALESCE(p_delivery_info, 'N/A')
        ) || COALESCE(format('. Notes: %s', p_notes), ''),
        v_user_id
    ) RETURNING id INTO v_transaction_id;

    -- Reserve inventory (this should be handled by trigger)
    UPDATE currency_inventory
    SET reserved_quantity = reserved_quantity + p_quantity,
        last_updated_at = NOW()
    WHERE game_account_id = p_game_account_id
    AND currency_attribute_id = p_currency_attribute_id;

    RETURN QUERY SELECT TRUE, v_transaction_id, 'Sell order created successfully', TRUE;
END;
$$;


ALTER FUNCTION "public"."create_currency_sell_order_v1"("p_game_account_id" "uuid", "p_currency_attribute_id" "uuid", "p_quantity" numeric, "p_unit_price_vnd" numeric, "p_unit_price_usd" numeric, "p_channel_id" "uuid", "p_customer_name" "text", "p_game_tag" "text", "p_delivery_info" "text", "p_order_line_id" "uuid", "p_notes" "text") OWNER TO "postgres";

--
-- Name: create_service_order_v1("text", "text", "text", timestamp with time zone, numeric, "text", "text", "text", "uuid", "jsonb", "text", "jsonb"); Type: FUNCTION; Schema: public; Owner: postgres
--

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
    item RECORD;
BEGIN
    -- 1. Kiểm tra quyền hạn
    -- FIX #3: Changed 'order:create' to 'orders:create'
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
    -- FIX #1: Changed variant names to 'Service - Selfplay' and 'Service - Pilot' (with space)
    -- FIX #2: Use LOWER() for case-insensitive check
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

    -- FIX #2: Changed 'SELFPAY' to 'SELFPLAY'
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

    -- 8. Chèn các hạng mục dịch vụ (Service Items) - KEEP ORIGINAL LOGIC
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

--
-- Name: FUNCTION "create_service_order_v1"("p_channel_code" "text", "p_service_type" "text", "p_customer_name" "text", "p_deadline" timestamp with time zone, "p_price" numeric, "p_currency_code" "text", "p_package_type" "text", "p_package_note" "text", "p_customer_account_id" "uuid", "p_new_account_details" "jsonb", "p_game_code" "text", "p_service_items" "jsonb"); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION "public"."create_service_order_v1"("p_channel_code" "text", "p_service_type" "text", "p_customer_name" "text", "p_deadline" timestamp with time zone, "p_price" numeric, "p_currency_code" "text", "p_package_type" "text", "p_package_note" "text", "p_customer_account_id" "uuid", "p_new_account_details" "jsonb", "p_game_code" "text", "p_service_items" "jsonb") IS 'MINIMAL FIX: Only changed (1) variant names to "Service - Selfplay/Pilot", (2) SELFPAY→SELFPLAY, (3) order:create→orders:create';


--
-- Name: create_service_report_v1("uuid", "text", "text"[]); Type: FUNCTION; Schema: public; Owner: postgres
--

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

--
-- Name: current_user_id(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."current_user_id"() RETURNS "uuid"
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$ 
  SELECT (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')::uuid; 
$$;


ALTER FUNCTION "public"."current_user_id"() OWNER TO "postgres";

--
-- Name: exchange_currency_v1("uuid", "uuid", "uuid", numeric, numeric, numeric, "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."exchange_currency_v1"("p_from_account_id" "uuid", "p_from_currency_id" "uuid", "p_to_currency_id" "uuid", "p_from_quantity" numeric, "p_to_quantity" numeric, "p_exchange_rate" numeric, "p_notes" "text" DEFAULT NULL::"text") RETURNS TABLE("success" boolean, "message" "text", "from_transaction_id" "uuid", "to_transaction_id" "uuid")
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_from_account RECORD;
    v_to_account RECORD;
    v_from_available NUMERIC := 0;
    v_can_exchange BOOLEAN := FALSE;
    v_from_trans_id UUID;
    v_to_trans_id UUID;
BEGIN
    -- Check permissions
    SELECT EXISTS(
        SELECT 1 FROM user_role_assignments ura
        JOIN attributes ba ON ura.business_area_attribute_id = ba.id
        WHERE ura.user_id = v_user_id
        AND ba.code = 'CURRENCY'
        AND (
            ura.game_attribute_id IS NULL
            OR EXISTS (
                SELECT 1 FROM game_accounts ga
                WHERE ga.id = p_from_account_id
                AND ga.game_code = (SELECT code FROM attributes WHERE id = ura.game_attribute_id)
            )
        )
    ) INTO v_can_exchange;

    IF NOT v_can_exchange THEN
        RETURN QUERY SELECT FALSE, 'Permission denied: Cannot exchange currency', NULL::UUID, NULL::UUID;
        RETURN;
    END IF;

    -- Get account details
    SELECT * INTO v_from_account
    FROM game_accounts WHERE id = p_from_account_id;

    IF v_from_account IS NULL THEN
        RETURN QUERY SELECT FALSE, 'Invalid source account', NULL::UUID, NULL::UUID;
        RETURN;
    END IF;

    -- Check inventory availability
    SELECT COALESCE(SUM(quantity - reserved_quantity), 0)
    INTO v_from_available
    FROM currency_inventory
    WHERE game_account_id = p_from_account_id
    AND currency_attribute_id = p_from_currency_id;

    IF v_from_available < p_from_quantity THEN
        RETURN QUERY SELECT FALSE,
            format('Insufficient inventory: Available %s, Requested %s', v_from_available, p_from_quantity),
            NULL::UUID, NULL::UUID;
        RETURN;
    END IF;

    -- Create exchange out transaction
    INSERT INTO currency_transactions (
        game_account_id,
        game_code,
        league_attribute_id,
        transaction_type,
        currency_attribute_id,
        quantity,
        unit_price_vnd,
        unit_price_usd,
        exchange_rate_vnd_per_usd,
        notes,
        created_by
    ) VALUES (
        p_from_account_id,
        v_from_account.game_code,
        v_from_account.league_attribute_id,
        'exchange_out',
        p_from_currency_id,
        -p_from_quantity,
        0, -- No price for exchange
        0,
        p_exchange_rate,
        format('Exchange %s %s to %s %s (Rate: %s)',
            p_from_quantity,
            (SELECT name FROM attributes WHERE id = p_from_currency_id),
            p_to_quantity,
            (SELECT name FROM attributes WHERE id = p_to_currency_id),
            p_exchange_rate
        ) || COALESCE(format('. Notes: %s', p_notes), ''),
        v_user_id
    ) RETURNING id INTO v_from_trans_id;

    -- Create exchange in transaction
    INSERT INTO currency_transactions (
        game_account_id,
        game_code,
        league_attribute_id,
        transaction_type,
        currency_attribute_id,
        quantity,
        unit_price_vnd,
        unit_price_usd,
        exchange_rate_vnd_per_usd,
        notes,
        created_by
    ) VALUES (
        p_from_account_id,
        v_from_account.game_code,
        v_from_account.league_attribute_id,
        'exchange_in',
        p_to_currency_id,
        p_to_quantity,
        0, -- No price for exchange
        0,
        p_exchange_rate,
        format('Exchange %s %s to %s %s (Rate: %s)',
            p_from_quantity,
            (SELECT name FROM attributes WHERE id = p_from_currency_id),
            p_to_quantity,
            (SELECT name FROM attributes WHERE id = p_to_currency_id),
            p_exchange_rate
        ) || COALESCE(format('. Notes: %s', p_notes), ''),
        v_user_id
    ) RETURNING id INTO v_to_trans_id;

    -- Update inventory (decrease from currency)
    UPDATE currency_inventory
    SET
        quantity = quantity - p_from_quantity,
        last_updated_at = NOW()
    WHERE game_account_id = p_from_account_id
    AND currency_attribute_id = p_from_currency_id;

    -- Update inventory (increase to currency)
    INSERT INTO currency_inventory (
        game_account_id,
        currency_attribute_id,
        quantity,
        avg_buy_price_vnd,
        avg_buy_price_usd
    ) VALUES (
        p_from_account_id,
        p_to_currency_id,
        p_to_quantity,
        0, -- No cost for exchange
        0
    )
    ON CONFLICT (game_account_id, currency_attribute_id)
    DO UPDATE SET
        quantity = currency_inventory.quantity + p_to_quantity,
        last_updated_at = NOW();

    RETURN QUERY SELECT TRUE, 'Currency exchanged successfully', v_from_trans_id, v_to_trans_id;
END;
$$;


ALTER FUNCTION "public"."exchange_currency_v1"("p_from_account_id" "uuid", "p_from_currency_id" "uuid", "p_to_currency_id" "uuid", "p_from_quantity" numeric, "p_to_quantity" numeric, "p_exchange_rate" numeric, "p_notes" "text") OWNER TO "postgres";

--
-- Name: finish_work_session_idem_v1("uuid", "jsonb", "jsonb", "text", "text", "text", "text"[]); Type: FUNCTION; Schema: public; Owner: postgres
--

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
    -- 1. Lấy thông tin phiên và kiểm tra quyền (như cũ)
    SELECT * INTO v_session FROM public.work_sessions WHERE id = p_session_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Phiên làm việc không tồn tại.'; END IF;
    IF v_session.ended_at IS NOT NULL THEN RETURN; END IF;

    v_order_line_id := v_session.order_line_id;
    SELECT o.id INTO v_order_id FROM public.order_lines ol JOIN public.orders o ON ol.order_id = o.id WHERE ol.id = v_order_line_id;

    SELECT jsonb_build_object('game_code', o.game_code, 'business_area_code', 'SERVICE')
    INTO v_context
    FROM public.order_lines ol JOIN public.orders o ON ol.order_id = o.id
    WHERE ol.id = v_order_line_id;

    IF v_session.farmer_id <> public.get_current_profile_id() AND NOT has_permission('work_session:override', v_context) THEN
        RAISE EXCEPTION 'Bạn không phải chủ phiên và không có quyền can thiệp.';
    END IF;

    -- 2. Xử lý outputs và activities trước tiên
    IF p_outputs IS NOT NULL THEN
        FOR output_item IN SELECT * FROM jsonb_array_elements(p_outputs) LOOP
            v_delta := (output_item->>'current_value')::numeric - (output_item->>'start_value')::numeric;
            IF v_delta <> 0 THEN
                INSERT INTO public.work_session_outputs (work_session_id, order_service_item_id, start_value, delta, start_proof_url, end_proof_url, params)
                VALUES (p_session_id, (output_item->>'item_id')::uuid, (output_item->>'start_value')::numeric, v_delta, output_item->>'start_proof_url', output_item->>'end_proof_url', output_item->'params');
                
                UPDATE public.order_service_items SET done_qty = done_qty + v_delta WHERE id = (output_item->>'item_id')::uuid;
            END IF;
        END LOOP;
    END IF;

    IF p_activity_rows IS NOT NULL THEN
        FOR activity_item IN SELECT * FROM jsonb_array_elements(p_activity_rows) LOOP
            INSERT INTO public.work_session_outputs(work_session_id, order_service_item_id, delta, params)
            VALUES (p_session_id, (activity_item->>'item_id')::uuid, (activity_item->>'delta')::numeric, activity_item->'params');
        END LOOP;
    END IF;

    -- 3. Đánh dấu phiên làm việc đã kết thúc
    UPDATE public.work_sessions
    SET ended_at = now(), overrun_reason = p_overrun_reason, overrun_type = p_overrun_type, overrun_proof_urls = p_overrun_proof_urls
    WHERE id = p_session_id;

    -- 4. <<< LOGIC MỚI: Cập nhật trạng thái đơn hàng Ở CUỐI CÙNG >>>
    -- Đọc lại trạng thái mới nhất của đơn hàng (có thể đã bị trigger thay đổi)
    SELECT o.status, 
           (SELECT a.name FROM product_variant_attributes pva JOIN attributes a ON pva.attribute_id = a.id WHERE pva.variant_id = ol.variant_id AND a.type = 'SERVICE_TYPE' LIMIT 1)
    INTO v_current_order_status, v_service_type
    FROM public.order_lines ol JOIN public.orders o ON ol.order_id = o.id
    WHERE ol.id = v_order_line_id;

    -- Chỉ cập nhật nếu trạng thái vẫn còn là 'in_progress'
    IF v_current_order_status = 'in_progress' THEN
        IF v_service_type IN ('Service - Pilot', 'Pilot') THEN
            UPDATE public.orders SET status = 'pending_pilot' WHERE id = v_order_id;
        ELSIF v_service_type IN ('Service - Selfplay', 'Selfplay') THEN
            UPDATE public.orders SET status = 'paused_selfplay' WHERE id = v_order_id;
        END IF;
    END IF;

    -- 5. Xử lý logic Pilot Cycle (giữ nguyên)
    -- Đọc lại status một lần nữa để chắc chắn
    SELECT status INTO v_current_order_status FROM public.orders WHERE id = v_order_id;
    IF v_service_type IN ('Service - Pilot', 'Pilot') AND
       v_current_order_status NOT IN ('completed', 'cancelled', 'delivered', 'pending_completion') THEN
        
        UPDATE order_lines
        SET paused_at = CASE WHEN v_current_order_status = 'customer_playing' THEN paused_at ELSE now() END
        WHERE id = v_order_line_id;

        PERFORM public.update_pilot_cycle_warning(v_order_line_id);
        PERFORM public.check_and_reset_pilot_cycle(v_order_line_id);
    END IF;
END;
$$;


ALTER FUNCTION "public"."finish_work_session_idem_v1"("p_session_id" "uuid", "p_outputs" "jsonb", "p_activity_rows" "jsonb", "p_overrun_reason" "text", "p_idem_key" "text", "p_overrun_type" "text", "p_overrun_proof_urls" "text"[]) OWNER TO "postgres";

--
-- Name: fulfill_currency_order_v1("uuid", "text"[], "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."fulfill_currency_order_v1"("p_transaction_id" "uuid", "p_proof_urls" "text"[] DEFAULT NULL::"text"[], "p_completion_notes" "text" DEFAULT NULL::"text") RETURNS TABLE("success" boolean, "message" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_transaction RECORD;
    v_can_fulfill BOOLEAN := FALSE;
BEGIN
    -- Check permissions
    SELECT EXISTS(
        SELECT 1 FROM user_role_assignments ura
        JOIN attributes ba ON ura.business_area_attribute_id = ba.id
        WHERE ura.user_id = v_user_id
        AND ba.code = 'CURRENCY'
    ) INTO v_can_fulfill;

    IF NOT v_can_fulfill THEN
        RETURN QUERY SELECT FALSE, 'Permission denied: Cannot fulfill orders';
        RETURN;
    END IF;

    -- Get transaction details
    SELECT * INTO v_transaction
    FROM currency_transactions
    WHERE id = p_transaction_id
    AND transaction_type = 'sale_delivery';

    IF v_transaction IS NULL THEN
        RETURN QUERY SELECT FALSE, 'Transaction not found or not a sale delivery';
        RETURN;
    END IF;

    -- Update transaction with completion details
    UPDATE currency_transactions
    SET
        proof_urls = COALESCE(p_proof_urls, proof_urls),
        notes = COALESCE(p_completion_notes, notes) || ' [FULFILLED]',
        updated_at = NOW()
    WHERE id = p_transaction_id;

    -- Release inventory (this should be handled by trigger)
    UPDATE currency_inventory
    SET
        quantity = quantity - ABS(v_transaction.quantity),
        reserved_quantity = reserved_quantity - ABS(v_transaction.quantity),
        last_updated_at = NOW()
    WHERE game_account_id = v_transaction.game_account_id
    AND currency_attribute_id = v_transaction.currency_attribute_id;

    RETURN QUERY SELECT TRUE, 'Order fulfilled successfully';
END;
$$;


ALTER FUNCTION "public"."fulfill_currency_order_v1"("p_transaction_id" "uuid", "p_proof_urls" "text"[], "p_completion_notes" "text") OWNER TO "postgres";

--
-- Name: get_boosting_filter_options(); Type: FUNCTION; Schema: public; Owner: postgres
--

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

--
-- Name: FUNCTION "get_boosting_filter_options"(); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION "public"."get_boosting_filter_options"() IS 'Returns all distinct filter option values for the Service Boosting page. Used to populate filter dropdowns with all possible values from the database, not just from currently loaded records.';


--
-- Name: get_boosting_order_detail_v1("uuid"); Type: FUNCTION; Schema: public; Owner: postgres
--

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


ALTER FUNCTION "public"."get_boosting_order_detail_v1"("p_line_id" "uuid") OWNER TO "postgres";

--
-- Name: get_boosting_orders_v3(integer, integer, "text"[], "text"[], "text"[], "text"[], "text", "text", "text", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."get_boosting_orders_v3"("p_limit" integer DEFAULT 50, "p_offset" integer DEFAULT 0, "p_channels" "text"[] DEFAULT NULL::"text"[], "p_statuses" "text"[] DEFAULT NULL::"text"[], "p_service_types" "text"[] DEFAULT NULL::"text"[], "p_package_types" "text"[] DEFAULT NULL::"text"[], "p_customer_name" "text" DEFAULT NULL::"text", "p_assignee" "text" DEFAULT NULL::"text", "p_delivery_status" "text" DEFAULT NULL::"text", "p_review_status" "text" DEFAULT NULL::"text") RETURNS TABLE("id" "uuid", "order_id" "uuid", "created_at" timestamp with time zone, "updated_at" timestamp with time zone, "status" "text", "channel_code" "text", "customer_name" "text", "deadline" timestamp with time zone, "btag" "text", "login_id" "text", "login_pwd" "text", "service_type" "text", "package_type" "text", "package_note" "text", "assignees_text" "text", "service_items" "jsonb", "review_id" "uuid", "machine_info" "text", "paused_at" timestamp with time zone, "delivered_at" timestamp with time zone, "action_proof_urls" "text"[], "pilot_warning_level" integer, "pilot_is_blocked" boolean, "pilot_cycle_start_at" timestamp with time zone, "total_count" bigint)
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
      -- Add pilot warning fields
      COALESCE(ol.pilot_warning_level, 0) as pilot_warning_level,
      COALESCE(ol.pilot_is_blocked, FALSE) as pilot_is_blocked,
      COALESCE(ol.pilot_cycle_start_at, o.created_at) as pilot_cycle_start_at,
      -- Add sorting columns for ORDER BY (using old rule with customer_playing before pending_completion)
      CASE o.status
        WHEN 'new' THEN 1
        WHEN 'in_progress' THEN 2
        WHEN 'pending_pilot' THEN 3
        WHEN 'paused_selfplay' THEN 4
        WHEN 'customer_playing' THEN 5
        WHEN 'pending_completion' THEN 6
        WHEN 'completed' THEN 7
        WHEN 'cancelled' THEN 8
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
      -- Filter by service types (using display_name from product_variants)
      AND (p_service_types IS NULL OR pv.display_name = ANY(p_service_types))
      -- Filter by package types
      AND (p_package_types IS NULL OR o.package_type = ANY(p_package_types))
      -- Filter by customer name (case-insensitive partial match)
      AND (p_customer_name IS NULL OR LOWER(p.name) LIKE LOWER('%' || p_customer_name || '%'))
      -- Filter by assignee (case-insensitive partial match)
      AND (p_assignee IS NULL OR LOWER(af.farmer_names) LIKE LOWER('%' || p_assignee || '%'))
  ),
  filtered_query AS (
    SELECT * FROM base_query
    -- Additional filtering for delivery status if specified
    WHERE
      CASE
        WHEN p_delivery_status = 'delivered' THEN delivered_at IS NOT NULL
        WHEN p_delivery_status = 'not_delivered' THEN delivered_at IS NULL
        ELSE TRUE
      END
      -- Additional filtering for review status if specified
      AND CASE
        WHEN p_review_status = 'reviewed' THEN review_id IS NOT NULL
        WHEN p_review_status = 'not_reviewed' THEN review_id IS NULL
        ELSE TRUE
      END
  ),
  counted_query AS (
    SELECT *, COUNT(*) OVER() as total_count FROM filtered_query
  )
  SELECT
    id,
    order_id,
    created_at,
    updated_at,
    status,
    channel_code,
    customer_name,
    deadline,
    btag,
    login_id,
    login_pwd,
    service_type,
    package_type,
    package_note,
    assignees_text,
    service_items,
    review_id,
    machine_info,
    paused_at,
    delivered_at,
    action_proof_urls,
    pilot_warning_level,
    pilot_is_blocked,
    pilot_cycle_start_at,
    total_count
  FROM counted_query
  ORDER BY
    -- Same sorting logic as before
    status_order,
    assignees_text ASC NULLS LAST,
    delivered_at ASC NULLS FIRST,
    review_id ASC NULLS FIRST,
    -- Add pilot cycle sorting (non-blocked first, lower warning first)
    pilot_is_blocked ASC NULLS LAST,
    pilot_warning_level ASC NULLS LAST,
    -- For completed orders, prioritize recently completed ones first
    CASE WHEN status = 'completed' THEN updated_at ELSE NULL END DESC NULLS LAST,
    deadline ASC NULLS LAST
  LIMIT p_limit OFFSET p_offset;
$$;


ALTER FUNCTION "public"."get_boosting_orders_v3"("p_limit" integer, "p_offset" integer, "p_channels" "text"[], "p_statuses" "text"[], "p_service_types" "text"[], "p_package_types" "text"[], "p_customer_name" "text", "p_assignee" "text", "p_delivery_status" "text", "p_review_status" "text") OWNER TO "postgres";

--
-- Name: get_channel_fee_chain("uuid"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."get_channel_fee_chain"("p_channel_id" "uuid") RETURNS TABLE("fee_chain_id" "uuid", "fee_chain_name" "text", "fee_chain_description" "text", "chain_steps" "jsonb")
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        tfc.id as fee_chain_id,
        tfc.name as fee_chain_name,
        tfc.description as fee_chain_description,
        tfc.chain_steps
    FROM public.channels c
    LEFT JOIN public.trading_fee_chains tfc ON c.trading_fee_chain_id = tfc.id AND tfc.is_active = true
    WHERE c.id = p_channel_id;
END;
$$;


ALTER FUNCTION "public"."get_channel_fee_chain"("p_channel_id" "uuid") OWNER TO "postgres";

--
-- Name: FUNCTION "get_channel_fee_chain"("p_channel_id" "uuid"); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION "public"."get_channel_fee_chain"("p_channel_id" "uuid") IS 'Lấy chuỗi phí liên kết với một kênh bán hàng (fixed security)';


--
-- Name: get_currency_inventory_summary_v1("text", "uuid"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."get_currency_inventory_summary_v1"("p_game_code" "text" DEFAULT NULL::"text", "p_league_attribute_id" "uuid" DEFAULT NULL::"uuid") RETURNS TABLE("game_code" "text", "league_name" "text", "currency_id" "uuid", "currency_name" "text", "currency_code" "text", "total_quantity" numeric, "available_quantity" numeric, "reserved_quantity" numeric, "avg_buy_price_vnd" numeric, "avg_buy_price_usd" numeric, "total_value_vnd" numeric, "total_value_usd" numeric, "account_count" bigint)
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_can_manage BOOLEAN := FALSE;
BEGIN
    -- Set search_path to public
    SET LOCAL search_path TO public;

    -- Check if user can access currency system
    SELECT EXISTS(
        SELECT 1 FROM user_role_assignments ura
        JOIN attributes ba ON ura.business_area_attribute_id = ba.id
        WHERE ura.user_id = v_user_id
        AND ba.code = 'CURRENCY'
        AND (
            ura.game_attribute_id IS NULL
            OR EXISTS (
                SELECT 1 FROM attributes ga
                WHERE ga.id = ura.game_attribute_id
                AND ga.code = p_game_code
            )
        )
    ) INTO v_can_manage;

    IF NOT v_can_manage THEN
        RAISE EXCEPTION 'Permission denied: Cannot access currency inventory';
    END IF;

    RETURN QUERY
    SELECT
        ga.game_code,
        l.name as league_name,
        curr.id as currency_id,
        curr.name as currency_name,
        curr.code as currency_code,
        SUM(inv.quantity) as total_quantity,
        SUM(inv.quantity - inv.reserved_quantity) as available_quantity,
        SUM(inv.reserved_quantity) as reserved_quantity,
        AVG(inv.avg_buy_price_vnd) as avg_buy_price_vnd,
        AVG(inv.avg_buy_price_usd) as avg_buy_price_usd,
        SUM(inv.quantity * inv.avg_buy_price_vnd) as total_value_vnd,
        SUM(inv.quantity * inv.avg_buy_price_usd) as total_value_usd,
        COUNT(DISTINCT inv.game_account_id) as account_count
    FROM currency_inventory inv
    JOIN game_accounts ga ON inv.game_account_id = ga.id
    JOIN attributes curr ON inv.currency_attribute_id = curr.id
    JOIN attributes l ON ga.league_attribute_id = l.id
    WHERE ga.is_active = true
        AND curr.is_active = true
        AND (p_game_code IS NULL OR ga.game_code = p_game_code)
        AND (p_league_attribute_id IS NULL OR ga.league_attribute_id = p_league_attribute_id)
        -- Permission filter
        AND (
            EXISTS (
                SELECT 1 FROM user_role_assignments ura
                WHERE ura.user_id = v_user_id
                AND ura.business_area_attribute_id = (SELECT id FROM attributes WHERE code = 'CURRENCY')
                AND (
                    ura.game_attribute_id IS NULL
                    OR ura.game_attribute_id = (SELECT id FROM attributes WHERE code = ga.game_code AND type = 'GAME')
                )
            )
        )
    GROUP BY ga.game_code, l.name, curr.id, curr.name, curr.code
    ORDER BY ga.game_code, total_value_vnd DESC;
END;
$$;


ALTER FUNCTION "public"."get_currency_inventory_summary_v1"("p_game_code" "text", "p_league_attribute_id" "uuid") OWNER TO "postgres";

--
-- Name: FUNCTION "get_currency_inventory_summary_v1"("p_game_code" "text", "p_league_attribute_id" "uuid"); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION "public"."get_currency_inventory_summary_v1"("p_game_code" "text", "p_league_attribute_id" "uuid") IS 'Get currency inventory summary with permission checks (v1)';


--
-- Name: get_currency_transaction_history_v1("text", "uuid", "text", "uuid", "uuid", timestamp with time zone, timestamp with time zone, bigint, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."get_currency_transaction_history_v1"("p_game_code" "text" DEFAULT NULL::"text", "p_league_id" "uuid" DEFAULT NULL::"uuid", "p_transaction_type" "text" DEFAULT NULL::"text", "p_currency_id" "uuid" DEFAULT NULL::"uuid", "p_account_id" "uuid" DEFAULT NULL::"uuid", "p_start_date" timestamp with time zone DEFAULT NULL::timestamp with time zone, "p_end_date" timestamp with time zone DEFAULT NULL::timestamp with time zone, "p_limit" bigint DEFAULT 100, "p_offset" bigint DEFAULT 0) RETURNS TABLE("id" "uuid", "created_at" timestamp with time zone, "transaction_type" "text", "currency_name" "text", "currency_code" "text", "quantity" numeric, "unit_price_vnd" numeric, "unit_price_usd" numeric, "total_value_vnd" numeric, "account_name" "text", "league_name" "text", "creator_name" "text", "notes" "text", "proof_urls" "text"[])
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_can_view BOOLEAN := FALSE;
BEGIN
    -- Check permissions
    SELECT EXISTS(
        SELECT 1 FROM user_role_assignments ura
        JOIN attributes ba ON ura.business_area_attribute_id = ba.id
        WHERE ura.user_id = v_user_id
        AND ba.code = 'CURRENCY'
    ) INTO v_can_view;

    IF NOT v_can_view THEN
        RAISE EXCEPTION 'Permission denied: Cannot view transaction history';
    END IF;

    RETURN QUERY
    SELECT
        ct.id,
        ct.created_at,
        ct.transaction_type,
        curr.name as currency_name,
        curr.code as currency_code,
        ct.quantity,
        ct.unit_price_vnd,
        ct.unit_price_usd,
        ABS(ct.quantity * ct.unit_price_vnd) as total_value_vnd,
        ga.account_name,
        l.name as league_name,
        p.display_name as creator_name,
        ct.notes,
        ct.proof_urls
    FROM currency_transactions ct
    JOIN attributes curr ON ct.currency_attribute_id = curr.id
    JOIN game_accounts ga ON ct.game_account_id = ga.id
    JOIN attributes l ON ga.league_attribute_id = l.id
    JOIN profiles p ON ct.created_by = p.id
    WHERE
        -- Permission filter
        EXISTS (
            SELECT 1 FROM user_role_assignments ura
            WHERE ura.user_id = v_user_id
            AND ura.business_area_attribute_id = (SELECT id FROM attributes WHERE code = 'CURRENCY')
            AND (
                ura.game_attribute_id IS NULL
                OR ura.game_attribute_id = (SELECT id FROM attributes WHERE code = ga.game_code AND type = 'GAME')
            )
        )
        -- Optional filters
        AND (p_game_code IS NULL OR ga.game_code = p_game_code)
        AND (p_league_id IS NULL OR ga.league_attribute_id = p_league_id)
        AND (p_transaction_type IS NULL OR ct.transaction_type = p_transaction_type)
        AND (p_currency_id IS NULL OR ct.currency_attribute_id = p_currency_id)
        AND (p_account_id IS NULL OR ct.game_account_id = p_account_id)
        AND (p_start_date IS NULL OR ct.created_at >= p_start_date)
        AND (p_end_date IS NULL OR ct.created_at <= p_end_date)
    ORDER BY ct.created_at DESC
    LIMIT p_limit
    OFFSET p_offset;
END;
$$;


ALTER FUNCTION "public"."get_currency_transaction_history_v1"("p_game_code" "text", "p_league_id" "uuid", "p_transaction_type" "text", "p_currency_id" "uuid", "p_account_id" "uuid", "p_start_date" timestamp with time zone, "p_end_date" timestamp with time zone, "p_limit" bigint, "p_offset" bigint) OWNER TO "postgres";

--
-- Name: get_current_profile_id(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."get_current_profile_id"() RETURNS "uuid"
    LANGUAGE "sql" STABLE
    SET "search_path" TO 'public'
    AS $$
  SELECT id
  FROM public.profiles
  WHERE auth_id = auth.uid();
$$;


ALTER FUNCTION "public"."get_current_profile_id"() OWNER TO "postgres";

--
-- Name: get_customers_by_channel_v1("text"); Type: FUNCTION; Schema: public; Owner: postgres
--

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

--
-- Name: get_game_leagues_v1("text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."get_game_leagues_v1"("p_game_code" "text") RETURNS TABLE("id" "uuid", "code" "text", "name" "text", "sort_order" integer, "is_active" boolean)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  RETURN QUERY
  SELECT
    a.id,
    a.code,
    a.name,
    a.sort_order,
    a.is_active
  FROM public.attributes a
  JOIN public.attribute_relationships ar
    ON a.id = ar.child_attribute_id
  JOIN public.attributes game
    ON game.id = ar.parent_attribute_id
  WHERE game.code = p_game_code
    AND game.type = 'GAME'
    AND a.is_active = true
    AND (
      (p_game_code = 'POE_1' AND a.type = 'LEAGUE_POE1') OR
      (p_game_code = 'POE_2' AND a.type = 'LEAGUE_POE2') OR
      (p_game_code = 'DIABLO_4' AND a.type = 'SEASON_D4')
    )
  ORDER BY a.sort_order, a.name;
END;
$$;


ALTER FUNCTION "public"."get_game_leagues_v1"("p_game_code" "text") OWNER TO "postgres";

--
-- Name: FUNCTION "get_game_leagues_v1"("p_game_code" "text"); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION "public"."get_game_leagues_v1"("p_game_code" "text") IS 'Get active leagues for a specific game';


--
-- Name: get_games_v1(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."get_games_v1"() RETURNS TABLE("id" "uuid", "code" "text", "name" "text", "icon" "text", "description" "text", "sort_order" integer, "is_active" boolean, "currency_prefix" "text", "league_prefix" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  RETURN QUERY
  SELECT
    a.id,
    a.code,
    a.name,
    LOWER(REPLACE(a.code, '_', '-')) as icon, -- Generate icon from code
    a.name as description, -- Use name as description for now
    a.sort_order,
    a.is_active,
    CASE
      WHEN a.code = 'POE_1' THEN 'CURRENCY_POE1'
      WHEN a.code = 'POE_2' THEN 'CURRENCY_POE2'
      WHEN a.code = 'DIABLO_4' THEN 'CURRENCY_D4'
      ELSE 'CURRENCY_' || a.code
    END as currency_prefix,
    CASE
      WHEN a.code = 'POE_1' THEN 'LEAGUE_POE1'
      WHEN a.code = 'POE_2' THEN 'LEAGUE_POE2'
      WHEN a.code = 'DIABLO_4' THEN 'SEASON_D4'
      ELSE 'LEAGUE_' || a.code
    END as league_prefix
  FROM public.attributes a
  WHERE a.type = 'GAME'
    AND a.is_active = true
  ORDER BY a.sort_order, a.name;
END;
$$;


ALTER FUNCTION "public"."get_games_v1"() OWNER TO "postgres";

--
-- Name: FUNCTION "get_games_v1"(); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION "public"."get_games_v1"() IS 'Get all active games with currency and league prefixes';


--
-- Name: get_last_item_proof_v1("uuid"[]); Type: FUNCTION; Schema: public; Owner: postgres
--

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

--
-- Name: get_my_assignments(); Type: FUNCTION; Schema: public; Owner: postgres
--

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

--
-- Name: get_primary_user_role_v1("uuid"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."get_primary_user_role_v1"("p_user_id" "uuid") RETURNS TABLE("id" "uuid", "code" "text", "name" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  RETURN QUERY
  SELECT
    r.id,
    r.code::text,
    r.name
  FROM public.roles r
  JOIN public.user_role_assignments ura ON r.id = ura.role_id
  WHERE ura.user_id = p_user_id
  ORDER BY r.code
  LIMIT 1;
END;
$$;


ALTER FUNCTION "public"."get_primary_user_role_v1"("p_user_id" "uuid") OWNER TO "postgres";

--
-- Name: FUNCTION "get_primary_user_role_v1"("p_user_id" "uuid"); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION "public"."get_primary_user_role_v1"("p_user_id" "uuid") IS 'Get primary role for a user (lowest sort_order)';


--
-- Name: get_reviews_for_order_line_v1("uuid"); Type: FUNCTION; Schema: public; Owner: postgres
--

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

--
-- Name: get_service_reports_v1("text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."get_service_reports_v1"("p_status" "text" DEFAULT 'new'::"text") RETURNS TABLE("report_id" "uuid", "reported_at" timestamp with time zone, "report_status" "text", "report_description" "text", "report_proof_urls" "text"[], "reporter_name" "text", "order_line_id" "uuid", "customer_name" "text", "channel_code" "text", "service_type" "text", "deadline" timestamp with time zone, "package_note" "text", "btag" "text", "login_id" "text", "login_pwd" "text", "reported_item" "jsonb")
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  SELECT sr.id, sr.created_at, sr.status, sr.description, sr.current_proof_urls, reporter.display_name, ol.id, p.name, ch.code, (SELECT a.name FROM public.product_variant_attributes pva JOIN public.attributes a ON pva.attribute_id = a.id WHERE pva.variant_id = ol.variant_id AND a.type = 'SERVICE_TYPE' LIMIT 1), ol.deadline_to, o.package_note, ca.btag, ca.login_id, ca.login_pwd, jsonb_build_object('id', osi.id, 'kind_code', a.code, 'params', osi.params, 'plan_qty', osi.plan_qty, 'done_qty', osi.done_qty)
  FROM public.service_reports sr JOIN public.profiles reporter ON sr.reported_by = reporter.id JOIN public.order_lines ol ON sr.order_line_id = ol.id JOIN public.orders o ON ol.order_id = o.id JOIN public.parties p ON o.party_id = p.id LEFT JOIN public.channels ch ON o.channel_id = ch.id LEFT JOIN public.customer_accounts ca ON ol.customer_account_id = ca.id JOIN public.order_service_items osi ON sr.order_service_item_id = osi.id JOIN public.attributes a ON osi.service_kind_id = a.id
  WHERE has_permission('reports:view') AND sr.status = p_status ORDER BY sr.created_at ASC;
$$;


ALTER FUNCTION "public"."get_service_reports_v1"("p_status" "text") OWNER TO "postgres";

--
-- Name: get_session_history_v2("uuid"); Type: FUNCTION; Schema: public; Owner: postgres
--

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

--
-- Name: get_user_auth_context_v1(); Type: FUNCTION; Schema: public; Owner: postgres
--

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

--
-- Name: get_user_roles_v1("uuid"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."get_user_roles_v1"("p_user_id" "uuid") RETURNS TABLE("id" "uuid", "code" "text", "name" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  RETURN QUERY
  SELECT
    r.id,
    r.code::text,
    r.name
  FROM public.roles r
  JOIN public.user_role_assignments ura ON r.id = ura.role_id
  WHERE ura.user_id = p_user_id
  ORDER BY r.code;
END;
$$;


ALTER FUNCTION "public"."get_user_roles_v1"("p_user_id" "uuid") OWNER TO "postgres";

--
-- Name: FUNCTION "get_user_roles_v1"("p_user_id" "uuid"); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION "public"."get_user_roles_v1"("p_user_id" "uuid") IS 'Get all roles for a user';


--
-- Name: handle_new_user_with_trial_role(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."handle_new_user_with_trial_role"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  trial_role_id uuid;
  user_display_name text;
  new_profile_id uuid;
BEGIN
  -- 1. Chuẩn bị display_name
  user_display_name := COALESCE(
    NEW.raw_user_meta_data ->> 'display_name',
    SPLIT_PART(NEW.email, '@', 1)
  );

  -- 2. TẠO DÒNG MỚI TRONG PROFILES VỚI CẤU TRÚC MỚI
  --    - profiles.id sẽ được tự động tạo bởi `default gen_random_uuid()`
  --    - profiles.auth_id sẽ là ID từ auth.users (NEW.id)
  INSERT INTO public.profiles (auth_id, display_name)
  VALUES (NEW.id, user_display_name)
  RETURNING id INTO new_profile_id; -- Lấy id của profile vừa tạo

  -- 3. Lấy ID của vai trò 'trial'
  SELECT id INTO trial_role_id FROM public.roles WHERE code = 'trial';

  -- 4. Gán vai trò 'trial' nếu tìm thấy, sử dụng profile_id mới
  IF trial_role_id IS NOT NULL THEN
    INSERT INTO public.user_role_assignments (user_id, role_id)
    VALUES (new_profile_id, trial_role_id);
  ELSE
    RAISE WARNING 'Role with code ''trial'' not found. Skipping role assignment for user %', NEW.id;
  END IF;
  
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_new_user_with_trial_role"() OWNER TO "postgres";

--
-- Name: handle_orders_updated_at(); Type: FUNCTION; Schema: public; Owner: postgres
--

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

--
-- Name: has_permission("text", "jsonb"); Type: FUNCTION; Schema: public; Owner: postgres
--

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

--
-- Name: manual_reset_pilot_cycle("uuid", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."manual_reset_pilot_cycle"("p_pilot_cycle_id" "uuid", "p_reason" "text" DEFAULT NULL::"text") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
        BEGIN
            -- Since pilot_cycles table doesn't exist, return false
            RAISE NOTICE 'Pilot system not available - manual_reset_pilot_cycle is a stub function';
            RETURN FALSE;
        END;
        $$;


ALTER FUNCTION "public"."manual_reset_pilot_cycle"("p_pilot_cycle_id" "uuid", "p_reason" "text") OWNER TO "postgres";

--
-- Name: FUNCTION "manual_reset_pilot_cycle"("p_pilot_cycle_id" "uuid", "p_reason" "text"); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION "public"."manual_reset_pilot_cycle"("p_pilot_cycle_id" "uuid", "p_reason" "text") IS 'Stub function - pilot system not available (fixed search_path)';


--
-- Name: mark_order_as_delivered_v1("uuid", boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

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

--
-- Name: payout_farmer_v1("uuid", "uuid", "uuid", numeric, numeric, numeric, numeric, "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."payout_farmer_v1"("p_farmer_profile_id" "uuid", "p_game_account_id" "uuid", "p_currency_attribute_id" "uuid", "p_quantity" numeric, "p_payout_rate_vnd" numeric, "p_payout_rate_usd" numeric DEFAULT 0, "p_exchange_rate_vnd_per_usd" numeric DEFAULT 25700, "p_notes" "text" DEFAULT NULL::"text") RETURNS TABLE("success" boolean, "transaction_id" "uuid", "message" "text", "payout_amount_vnd" numeric, "payout_amount_usd" numeric)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_game_account RECORD;
    v_farmer_name TEXT;
    v_available_quantity NUMERIC := 0;
    v_can_payout BOOLEAN := FALSE;
    v_transaction_id UUID;
    v_payout_vnd NUMERIC;
    v_payout_usd NUMERIC;
BEGIN
    -- Check permissions (manager or admin can payout)
    SELECT EXISTS(
        SELECT 1 FROM user_role_assignments ura
        JOIN roles r ON ura.role_id = r.id
        JOIN attributes ba ON ura.business_area_attribute_id = ba.id
        WHERE ura.user_id = v_user_id
        AND ba.code = 'CURRENCY'
        AND r.code IN ('admin', 'manager', 'farmer_manager', 'farmer_leader')
    ) INTO v_can_payout;

    IF NOT v_can_payout THEN
        RETURN QUERY SELECT FALSE, NULL::UUID, 'Permission denied: Cannot payout to farmer', 0, 0;
        RETURN;
    END IF;

    -- Get details
    SELECT ga.*
    INTO v_game_account
    FROM game_accounts ga
    WHERE ga.id = p_game_account_id;

    SELECT p.display_name
    INTO v_farmer_name
    FROM profiles p
    WHERE p.id = p_farmer_profile_id;

    IF v_game_account IS NULL THEN
        RETURN QUERY SELECT FALSE, NULL::UUID, 'Invalid game account or farmer', 0, 0;
        RETURN;
    END IF;

    -- Check inventory availability
    SELECT COALESCE(SUM(quantity - reserved_quantity), 0)
    INTO v_available_quantity
    FROM currency_inventory
    WHERE game_account_id = p_game_account_id
    AND currency_attribute_id = p_currency_attribute_id;

    IF v_available_quantity < p_quantity THEN
        RETURN QUERY SELECT FALSE, NULL::UUID,
            format('Insufficient inventory: Available %s, Requested %s', v_available_quantity, p_quantity),
            0, 0;
        RETURN;
    END IF;

    -- Calculate payout amounts
    v_payout_vnd := p_quantity * p_payout_rate_vnd;
    v_payout_usd := p_quantity * p_payout_rate_usd;

    -- Create payout transaction
    INSERT INTO currency_transactions (
        game_account_id,
        game_code,
        league_attribute_id,
        transaction_type,
        currency_attribute_id,
        quantity,
        unit_price_vnd,
        unit_price_usd,
        exchange_rate_vnd_per_usd,
        farmer_profile_id,
        notes,
        created_by
    ) VALUES (
        p_game_account_id,
        v_game_account.game_code,
        v_game_account.league_attribute_id,
        'farm_payout',
        p_currency_attribute_id,
        -p_quantity,
        p_payout_rate_vnd,
        p_payout_rate_usd,
        p_exchange_rate_vnd_per_usd,
        p_farmer_profile_id,
        format('Farmer payout to %s: %s units @ %s VND/unit = %s VND',
            COALESCE(v_farmer_name, 'Unknown'),
            p_quantity,
            p_payout_rate_vnd,
            v_payout_vnd
        ) || COALESCE(format('. Notes: %s', p_notes), ''),
        v_user_id
    ) RETURNING id INTO v_transaction_id;

    -- Update inventory
    UPDATE currency_inventory
    SET
        quantity = quantity - p_quantity,
        last_updated_at = NOW()
    WHERE game_account_id = p_game_account_id
    AND currency_attribute_id = p_currency_attribute_id;

    RETURN QUERY SELECT TRUE, v_transaction_id, 'Farmer payout processed successfully', v_payout_vnd, v_payout_usd;
END;
$$;


ALTER FUNCTION "public"."payout_farmer_v1"("p_farmer_profile_id" "uuid", "p_game_account_id" "uuid", "p_currency_attribute_id" "uuid", "p_quantity" numeric, "p_payout_rate_vnd" numeric, "p_payout_rate_usd" numeric, "p_exchange_rate_vnd_per_usd" numeric, "p_notes" "text") OWNER TO "postgres";

--
-- Name: protect_account_with_currency(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."protect_account_with_currency"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    v_currency_count INTEGER;
BEGIN
    -- Check if account has any currency
    SELECT COUNT(*) INTO v_currency_count
    FROM public.currency_inventory
    WHERE game_account_id = OLD.id
      AND quantity > 0;

    IF v_currency_count > 0 THEN
        RAISE EXCEPTION 'Cannot delete game account with existing currency. Found % currency types with quantity > 0', v_currency_count;
    END IF;

    RETURN OLD;
END;
$$;


ALTER FUNCTION "public"."protect_account_with_currency"() OWNER TO "postgres";

--
-- Name: FUNCTION "protect_account_with_currency"(); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION "public"."protect_account_with_currency"() IS 'Ngăn xóa tài khoản game còn currency';


--
-- Name: record_currency_purchase_v1("uuid", "uuid", numeric, numeric, numeric, numeric, "uuid", "text"[], "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."record_currency_purchase_v1"("p_game_account_id" "uuid", "p_currency_attribute_id" "uuid", "p_quantity" numeric, "p_unit_price_vnd" numeric, "p_unit_price_usd" numeric DEFAULT 0, "p_exchange_rate_vnd_per_usd" numeric DEFAULT 25700, "p_partner_id" "uuid" DEFAULT NULL::"uuid", "p_proof_urls" "text"[] DEFAULT NULL::"text"[], "p_notes" "text" DEFAULT NULL::"text") RETURNS TABLE("success" boolean, "message" "text", "transaction_id" "uuid")
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_game_account RECORD;
    v_can_purchase BOOLEAN := FALSE;
    v_transaction_id UUID;
BEGIN
    -- Set search_path to public
    SET LOCAL search_path TO public;

    -- Check permissions
    SELECT EXISTS(
        SELECT 1 FROM user_role_assignments ura
        JOIN attributes ba ON ura.business_area_attribute_id = ba.id
        WHERE ura.user_id = v_user_id
        AND ba.code = 'CURRENCY'
        AND ura.game_attribute_id IS NOT NULL
        AND EXISTS (
            SELECT 1 FROM game_accounts ga
            WHERE ga.id = p_game_account_id
            AND ga.game_code = (SELECT code FROM attributes WHERE id = ura.game_attribute_id)
        )
    ) INTO v_can_purchase;

    IF NOT v_can_purchase THEN
        RETURN QUERY SELECT FALSE, 'Permission denied: Cannot record currency purchase', NULL::UUID;
        RETURN;
    END IF;

    -- Get game account details
    SELECT * INTO v_game_account
    FROM game_accounts
    WHERE id = p_game_account_id;

    IF v_game_account IS NULL THEN
        RETURN QUERY SELECT FALSE, 'Invalid game account', NULL::UUID;
        RETURN;
    END IF;

    -- Validate quantity
    IF p_quantity <= 0 THEN
        RETURN QUERY SELECT FALSE, 'Quantity must be positive', NULL::UUID;
        RETURN;
    END IF;

    -- Create transaction
    INSERT INTO currency_transactions (
        game_account_id,
        game_code,
        league_attribute_id,
        transaction_type,
        currency_attribute_id,
        quantity,
        unit_price_vnd,
        unit_price_usd,
        exchange_rate_vnd_per_usd,
        partner_id,
        proof_urls,
        notes,
        created_by
    ) VALUES (
        p_game_account_id,
        v_game_account.game_code,
        v_game_account.league_attribute_id,
        'purchase',
        p_currency_attribute_id,
        p_quantity,
        p_unit_price_vnd,
        p_unit_price_usd,
        p_exchange_rate_vnd_per_usd,
        p_partner_id,
        p_proof_urls,
        p_notes,
        v_user_id
    ) RETURNING id INTO v_transaction_id;

    -- Update inventory (handled by trigger)

    RETURN QUERY SELECT TRUE, 'Purchase recorded successfully', v_transaction_id;
END;
$$;


ALTER FUNCTION "public"."record_currency_purchase_v1"("p_game_account_id" "uuid", "p_currency_attribute_id" "uuid", "p_quantity" numeric, "p_unit_price_vnd" numeric, "p_unit_price_usd" numeric, "p_exchange_rate_vnd_per_usd" numeric, "p_partner_id" "uuid", "p_proof_urls" "text"[], "p_notes" "text") OWNER TO "postgres";

--
-- Name: FUNCTION "record_currency_purchase_v1"("p_game_account_id" "uuid", "p_currency_attribute_id" "uuid", "p_quantity" numeric, "p_unit_price_vnd" numeric, "p_unit_price_usd" numeric, "p_exchange_rate_vnd_per_usd" numeric, "p_partner_id" "uuid", "p_proof_urls" "text"[], "p_notes" "text"); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION "public"."record_currency_purchase_v1"("p_game_account_id" "uuid", "p_currency_attribute_id" "uuid", "p_quantity" numeric, "p_unit_price_vnd" numeric, "p_unit_price_usd" numeric, "p_exchange_rate_vnd_per_usd" numeric, "p_partner_id" "uuid", "p_proof_urls" "text"[], "p_notes" "text") IS 'Record currency purchase with inventory updates (v1)';


--
-- Name: reset_eligible_pilot_cycles(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."reset_eligible_pilot_cycles"() RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    line_record RECORD;
    hours_online NUMERIC;
    hours_rest NUMERIC;
    required_rest_hours INTEGER;
BEGIN
    -- Lặp qua tất cả các đơn hàng pilot đang trong trạng thái nghỉ
    FOR line_record IN
        SELECT 
            ol.id, 
            ol.paused_at,
            COALESCE(ol.pilot_cycle_start_at, o.created_at) as cycle_start_at
        FROM order_lines ol
        JOIN orders o ON ol.order_id = o.id
        JOIN product_variants pv ON ol.variant_id = pv.id
        WHERE 
            pv.display_name = 'Service - Pilot'
            AND ol.paused_at IS NOT NULL
            -- <<< THÊM ĐIỀU KIỆN LỌC MỚI Ở ĐÂY >>>
            AND o.status <> 'customer_playing' 
            AND o.status NOT IN ('completed', 'cancelled', 'delivered', 'pending_completion')
    LOOP
        -- Phần logic tính toán còn lại giữ nguyên
        hours_online := EXTRACT(EPOCH FROM (line_record.paused_at - line_record.cycle_start_at)) / 3600;
        hours_rest := EXTRACT(EPOCH FROM (NOW() - line_record.paused_at)) / 3600;

        required_rest_hours := CASE
            WHEN hours_online <= 4 * 24 THEN 6
            ELSE 12
        END;

        IF hours_rest >= required_rest_hours THEN
            UPDATE order_lines
            SET
                pilot_cycle_start_at = line_record.paused_at,
                pilot_warning_level = 0,
                pilot_is_blocked = FALSE,
                paused_at = NULL
            WHERE id = line_record.id;
        END IF;
    END LOOP;
END;
$$;


ALTER FUNCTION "public"."reset_eligible_pilot_cycles"() OWNER TO "postgres";

--
-- Name: reset_pilot_cycle_on_completion("uuid"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."reset_pilot_cycle_on_completion"("p_order_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
    -- Reset warning levels khi đơn hoàn thành/hủy
    UPDATE order_lines
    SET
        pilot_warning_level = 0,
        pilot_is_blocked = FALSE,
        updated_at = now()
    WHERE order_id = p_order_id;
END;
$$;


ALTER FUNCTION "public"."reset_pilot_cycle_on_completion"("p_order_id" "uuid") OWNER TO "postgres";

--
-- Name: resolve_service_report_v1("uuid", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

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

--
-- Name: start_work_session_v1("uuid", "jsonb", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

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
    v_order_created_at TIMESTAMPTZ;
    v_service_type TEXT;
BEGIN
    -- Lấy ngữ cảnh và các thông tin cần thiết
    SELECT o.id, o.status, ol.paused_at, o.created_at,
           (SELECT a.name FROM product_variant_attributes pva JOIN attributes a ON pva.attribute_id = a.id WHERE pva.variant_id = ol.variant_id AND a.type = 'SERVICE_TYPE' LIMIT 1) as service_type,
           jsonb_build_object('game_code', o.game_code, 'business_area_code', 'SERVICE')
    INTO v_order_id, v_current_status, v_paused_at, v_order_created_at, v_service_type, v_context
    FROM orders o
    JOIN order_lines ol ON o.id = ol.order_id
    WHERE ol.id = p_order_line_id;

    IF v_order_id IS NULL THEN RAISE EXCEPTION 'Order line not found'; END IF;

    -- <<< THÊM CÁC KIỂM TRA MỚI Ở ĐÂY >>>
    -- 1. Kiểm tra xem có phiên làm việc khác đang chạy không
    PERFORM 1 FROM public.work_sessions WHERE order_line_id = p_order_line_id AND ended_at IS NULL;
    IF FOUND THEN
        RAISE EXCEPTION 'Đơn hàng này đã có một phiên làm việc đang hoạt động.';
    END IF;
    
    -- 2. Kiểm tra xem khách hàng có đang chơi không
    IF v_current_status = 'customer_playing' THEN
        RAISE EXCEPTION 'Không thể bắt đầu phiên làm việc khi khách đang chơi.';
    END IF;

    -- Các logic còn lại của hàm
    IF NOT has_permission('work_session:start', v_context) THEN
        RAISE EXCEPTION 'Bạn không có quyền bắt đầu phiên làm việc cho dịch vụ này.';
    END IF;

    IF v_current_status IN ('completed', 'cancelled') THEN
        RAISE EXCEPTION 'Không thể bắt đầu phiên làm việc cho đơn hàng đã hoàn thành hoặc hủy.';
    END IF;

    IF v_current_status IN ('new', 'pending_pilot', 'paused_selfplay') THEN
        UPDATE public.orders SET status = 'in_progress' WHERE id = v_order_id;
    END IF;

    INSERT INTO public.work_sessions (order_line_id, farmer_id, notes, start_state, unpaused_duration)
    VALUES (p_order_line_id, public.get_current_profile_id(), p_initial_note, p_start_state, v_paused_duration)
    RETURNING id INTO new_session_id;

    IF v_service_type IN ('Service - Pilot', 'Pilot') AND
       v_current_status NOT IN ('completed', 'cancelled', 'delivered', 'pending_completion') THEN
        UPDATE order_lines SET paused_at = NULL WHERE id = p_order_line_id;
        PERFORM public.update_pilot_cycle_warning(p_order_line_id);
    END IF;

    RETURN new_session_id;
END;
$$;


ALTER FUNCTION "public"."start_work_session_v1"("p_order_line_id" "uuid", "p_start_state" "jsonb", "p_initial_note" "text") OWNER TO "postgres";

--
-- Name: submit_order_review_v1("uuid", numeric, "text", "text"[]); Type: FUNCTION; Schema: public; Owner: postgres
--

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

--
-- Name: toggle_customer_playing("uuid", boolean, "uuid"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."toggle_customer_playing"("p_order_id" "uuid", "p_enable_customer_playing" boolean, "p_current_user_id" "uuid") RETURNS TABLE("success" boolean, "message" "text", "new_status" "text", "new_deadline" timestamp with time zone)
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    -- <<< SỬA LỖI 1: Loại bỏ v_order_record, thay bằng các biến đơn giản >>>
    v_paused_at timestamptz;
    v_order_line_id uuid;
    v_current_status text;
    v_current_deadline timestamptz;
    v_new_deadline timestamptz;
    v_now timestamptz := now();
    v_service_type text;
BEGIN
    -- <<< SỬA LỖI 2: Cập nhật lại câu lệnh SELECT ... INTO ... >>>
    SELECT
        o.status,
        ol.deadline_to,
        COALESCE(
            (SELECT a.name FROM product_variant_attributes pva JOIN attributes a ON pva.attribute_id = a.id WHERE pva.variant_id = ol.variant_id AND a.type = 'SERVICE_TYPE' LIMIT 1),
            'Unknown'
        ),
        ol.paused_at,
        ol.id
    INTO 
        v_current_status, 
        v_current_deadline, 
        v_service_type, 
        v_paused_at, 
        v_order_line_id
    FROM orders o
    JOIN order_lines ol ON o.id = ol.order_id
    WHERE o.id = p_order_id
    LIMIT 1;

    IF NOT FOUND THEN
        RETURN QUERY SELECT false, 'Đơn hàng không tồn tại'::text, NULL::text, NULL::timestamp with time zone;
        RETURN;
    END IF;

    -- Sử dụng v_order_line_id đã lấy được để kiểm tra phiên làm việc
    IF p_enable_customer_playing THEN
        PERFORM 1 FROM public.work_sessions 
        WHERE order_line_id = v_order_line_id AND ended_at IS NULL;
        IF FOUND THEN
            RETURN QUERY SELECT false, 'Không thể bật chế độ khách chơi khi đang có phiên làm việc hoạt động.'::text, NULL::text, NULL::timestamptz;
            RETURN;
        END IF;
    END IF;

    -- Logic còn lại giữ nguyên
    IF v_service_type = 'Selfplay' THEN
        RETURN QUERY SELECT false, 'Chỉ áp dụng cho đơn hàng pilot'::text, NULL::text, NULL::timestamptz;
        RETURN;
    END IF;

    IF v_current_status NOT IN ('in_progress', 'pending_pilot', 'customer_playing') THEN
        RETURN QUERY SELECT false, 'Chỉ áp dụng cho đơn hàng đang thực hiện'::text, NULL::text, NULL::timestamptz;
        RETURN;
    END IF;

    IF p_enable_customer_playing THEN
        UPDATE order_lines SET paused_at = v_now WHERE id = v_order_line_id;
        UPDATE orders SET status = 'customer_playing', updated_at = v_now WHERE id = p_order_id;
        PERFORM public.update_pilot_cycle_warning(v_order_line_id);
        RETURN QUERY SELECT true, 'Đã chuyển sang trạng thái Khách chơi'::text, 'customer_playing'::text, v_current_deadline;
        RETURN;
    ELSE
        -- <<< SỬA LỖI 3: Thay thế v_order_record.paused_at bằng v_paused_at >>>
        IF v_paused_at IS NOT NULL AND v_current_deadline IS NOT NULL THEN
            v_new_deadline := v_current_deadline + (v_now - v_paused_at);
        ELSE
            v_new_deadline := v_current_deadline;
        END IF;
        
        UPDATE order_lines SET paused_at = CASE WHEN EXISTS (SELECT 1 FROM work_sessions WHERE order_line_id = v_order_line_id AND ended_at IS NULL) THEN NULL ELSE v_now END WHERE id = v_order_line_id;
        UPDATE orders SET status = 'pending_pilot', updated_at = v_now WHERE id = p_order_id;
        UPDATE order_lines SET deadline_to = v_new_deadline WHERE id = v_order_line_id;
        PERFORM public.update_pilot_cycle_warning(v_order_line_id);
        PERFORM public.check_and_reset_pilot_cycle(v_order_line_id);
        RETURN QUERY SELECT true, 'Đã tiếp tục thực hiện đơn hàng'::text, 'pending_pilot'::text, v_new_deadline;
        RETURN;
    END IF;
END;
$$;


ALTER FUNCTION "public"."toggle_customer_playing"("p_order_id" "uuid", "p_enable_customer_playing" boolean, "p_current_user_id" "uuid") OWNER TO "postgres";

--
-- Name: tr_audit_row_v1(); Type: FUNCTION; Schema: public; Owner: postgres
--

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

--
-- Name: FUNCTION "tr_audit_row_v1"(); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION "public"."tr_audit_row_v1"() IS '[v1.1] Trigger audit chuẩn hóa, ghi lại các thay đổi INSERT, UPDATE, DELETE vào bảng audit_logs. Đã sửa lỗi ép kiểu UUID cho entity_id.';


--
-- Name: tr_auto_initialize_pilot_cycle_on_first_session(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."tr_auto_initialize_pilot_cycle_on_first_session"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
    -- Only update for pilot orders when pilot_cycle_start_at is NULL
    IF EXISTS (
        SELECT 1 FROM public.orders o
        JOIN public.order_lines ol ON o.id = ol.order_id
        JOIN public.product_variants pv ON ol.variant_id = pv.id
        WHERE ol.id = NEW.order_line_id
        AND pv.display_name = 'Service - Pilot'
        AND ol.pilot_cycle_start_at IS NULL
        AND o.status NOT IN ('completed', 'cancelled', 'delivered', 'pending_completion')
    ) THEN
        -- Initialize pilot cycle start time
        UPDATE public.order_lines
        SET pilot_cycle_start_at = NEW.started_at
        WHERE id = NEW.order_line_id;

        -- Update pilot cycle warning
        PERFORM public.update_pilot_cycle_warning(NEW.order_line_id);
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."tr_auto_initialize_pilot_cycle_on_first_session"() OWNER TO "postgres";

--
-- Name: tr_auto_initialize_pilot_cycle_on_order_create(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."tr_auto_initialize_pilot_cycle_on_order_create"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
    -- Only initialize for new pilot orders
    IF EXISTS (
        SELECT 1 FROM public.product_variants pv
        WHERE pv.id = NEW.variant_id
        AND pv.display_name = 'Service - Pilot'
    ) THEN
        -- Initialize pilot cycle start time to current time
        NEW.pilot_cycle_start_at := NOW();
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."tr_auto_initialize_pilot_cycle_on_order_create"() OWNER TO "postgres";

--
-- Name: tr_auto_update_pilot_cycle_on_pause_change(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."tr_auto_update_pilot_cycle_on_pause_change"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
    -- Only update for pilot orders
    IF EXISTS (
        SELECT 1 FROM public.orders o
        JOIN public.product_variants pv ON o.id = NEW.order_id
        WHERE pv.display_name = 'Service - Pilot'
        AND o.status NOT IN ('completed', 'cancelled', 'delivered', 'pending_completion')
    ) THEN
        -- Update pilot cycle warning
        PERFORM public.update_pilot_cycle_warning(NEW.id);

        -- Check and reset if conditions met
        PERFORM public.check_and_reset_pilot_cycle(NEW.id);
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."tr_auto_update_pilot_cycle_on_pause_change"() OWNER TO "postgres";

--
-- Name: tr_auto_update_pilot_cycle_on_session_end(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."tr_auto_update_pilot_cycle_on_session_end"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
    -- Only update for pilot orders
    IF EXISTS (
        SELECT 1 FROM public.orders o
        JOIN public.order_lines ol ON o.id = ol.order_id
        JOIN public.product_variants pv ON ol.variant_id = pv.id
        WHERE ol.id = NEW.order_line_id
        AND pv.display_name = 'Service - Pilot'
        AND o.status NOT IN ('completed', 'cancelled', 'delivered', 'pending_completion')
    ) THEN
        -- Update pilot cycle warning
        PERFORM public.update_pilot_cycle_warning(NEW.order_line_id);

        -- Check and reset if conditions met
        PERFORM public.check_and_reset_pilot_cycle(NEW.order_line_id);
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."tr_auto_update_pilot_cycle_on_session_end"() OWNER TO "postgres";

--
-- Name: tr_auto_update_pilot_cycle_on_status_change(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."tr_auto_update_pilot_cycle_on_status_change"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
        BEGIN
            -- Since pilot_cycles table doesn't exist, just return NEW
            RAISE NOTICE 'Pilot system not available - tr_auto_update_pilot_cycle_on_status_change is a stub function';
            RETURN NEW;
        END;
        $$;


ALTER FUNCTION "public"."tr_auto_update_pilot_cycle_on_status_change"() OWNER TO "postgres";

--
-- Name: FUNCTION "tr_auto_update_pilot_cycle_on_status_change"(); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION "public"."tr_auto_update_pilot_cycle_on_status_change"() IS 'Stub function - pilot system not available (fixed search_path)';


--
-- Name: tr_check_all_items_completed_v1(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."tr_check_all_items_completed_v1"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
DECLARE v_order_line_id UUID; v_order_id UUID; v_current_order_status TEXT; v_service_type TEXT; total_items INT; completed_items INT;
BEGIN
    IF TG_OP = 'UPDATE' AND NEW.done_qty <> OLD.done_qty THEN
        v_order_line_id := NEW.order_line_id;
        SELECT ol.order_id, o.status,
               (SELECT a.name FROM product_variant_attributes pva
                JOIN attributes a ON pva.attribute_id = a.id
                WHERE pva.variant_id = ol.variant_id AND a.type = 'SERVICE_TYPE' LIMIT 1) as service_type
        INTO v_order_id, v_current_order_status, v_service_type
        FROM public.order_lines ol
        JOIN public.orders o ON ol.order_id = o.id
        WHERE ol.id = v_order_line_id;

        IF v_current_order_status IN ('completed', 'cancelled', 'pending_completion') THEN RETURN NEW; END IF;
        SELECT count(*) INTO total_items FROM public.order_service_items WHERE order_line_id = v_order_line_id;
        SELECT count(*) INTO completed_items FROM public.order_service_items WHERE order_line_id = v_order_line_id AND done_qty >= COALESCE(plan_qty, 0);
        IF total_items > 0 AND total_items = completed_items THEN
            -- Chỉ dừng deadline cho Selfplay khi pending_completion
            IF v_current_order_status = 'in_progress' AND v_service_type = 'Service - Selfplay' THEN
                UPDATE public.order_lines SET paused_at = NOW() WHERE id = v_order_line_id;
            END IF;
            UPDATE public.orders SET status = 'pending_completion' WHERE id = v_order_id;
        END IF;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."tr_check_all_items_completed_v1"() OWNER TO "postgres";

--
-- Name: try_uuid("text"); Type: FUNCTION; Schema: public; Owner: postgres
--

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

--
-- Name: update_action_proofs_v1("uuid", "text"[]); Type: FUNCTION; Schema: public; Owner: postgres
--

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

--
-- Name: update_currency_inventory(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."update_currency_inventory"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    v_inventory_record RECORD;
    v_new_quantity NUMERIC;
    v_new_reserved NUMERIC;
    v_total_value NUMERIC;
    v_total_quantity NUMERIC;
    v_new_avg_price_vnd NUMERIC;
    v_new_avg_price_usd NUMERIC;
BEGIN
    -- Check if inventory record exists
    SELECT * INTO v_inventory_record
    FROM public.currency_inventory
    WHERE game_account_id = NEW.game_account_id
      AND currency_attribute_id = NEW.currency_attribute_id
    FOR UPDATE;

    IF v_inventory_record IS NULL THEN
        -- Create new inventory record
        INSERT INTO public.currency_inventory (
            game_account_id,
            currency_attribute_id,
            quantity,
            reserved_quantity,
            avg_buy_price_vnd,
            avg_buy_price_usd,
            last_updated_at
        ) VALUES (
            NEW.game_account_id,
            NEW.currency_attribute_id,
            CASE
                WHEN NEW.transaction_type IN ('purchase', 'exchange_in', 'farm_in', 'transfer', 'manual_adjustment')
                THEN GREATEST(NEW.quantity, 0)
                ELSE 0
            END,
            0,
            CASE
                WHEN NEW.transaction_type IN ('purchase', 'exchange_in', 'farm_in')
                THEN NEW.unit_price_vnd
                ELSE 0
            END,
            CASE
                WHEN NEW.transaction_type IN ('purchase', 'exchange_in', 'farm_in')
                THEN NEW.unit_price_usd
                ELSE 0
            END,
            NOW()
        );

        RETURN NEW;
    END IF;

    -- Calculate new quantities based on transaction type
    CASE NEW.transaction_type
        WHEN 'purchase', 'exchange_in', 'farm_in', 'transfer', 'manual_adjustment' THEN
            -- Adding to inventory
            v_new_quantity := v_inventory_record.quantity + NEW.quantity;
            v_new_reserved := v_inventory_record.reserved_quantity;

            -- Update average price for purchase types
            IF NEW.transaction_type IN ('purchase', 'exchange_in', 'farm_in') AND NEW.quantity > 0 THEN
                v_total_value := (v_inventory_record.quantity * v_inventory_record.avg_buy_price_vnd) + (NEW.quantity * NEW.unit_price_vnd);
                v_total_quantity := v_inventory_record.quantity + NEW.quantity;
                v_new_avg_price_vnd := v_total_value / v_total_quantity;

                v_total_value := (v_inventory_record.quantity * v_inventory_record.avg_buy_price_usd) + (NEW.quantity * NEW.unit_price_usd);
                v_new_avg_price_usd := v_total_value / v_total_quantity;
            ELSE
                v_new_avg_price_vnd := v_inventory_record.avg_buy_price_vnd;
                v_new_avg_price_usd := v_inventory_record.avg_buy_price_usd;
            END IF;

        WHEN 'sale_delivery', 'exchange_out', 'farm_payout' THEN
            -- Removing from inventory
            v_new_quantity := v_inventory_record.quantity - NEW.quantity;
            v_new_reserved := v_inventory_record.reserved_quantity;
            v_new_avg_price_vnd := v_inventory_record.avg_buy_price_vnd;
            v_new_avg_price_usd := v_inventory_record.avg_buy_price_usd;

            -- Check if enough quantity
            IF v_new_quantity < 0 THEN
                RAISE EXCEPTION 'Insufficient inventory. Current: %, Attempted to remove: %',
                    v_inventory_record.quantity, NEW.quantity;
            END IF;

        ELSE
            -- For other transaction types, don't change quantity
            v_new_quantity := v_inventory_record.quantity;
            v_new_reserved := v_inventory_record.reserved_quantity;
            v_new_avg_price_vnd := v_inventory_record.avg_buy_price_vnd;
            v_new_avg_price_usd := v_inventory_record.avg_buy_price_usd;
    END CASE;

    -- Update inventory record
    UPDATE public.currency_inventory
    SET
        quantity = v_new_quantity,
        reserved_quantity = v_new_reserved,
        avg_buy_price_vnd = v_new_avg_price_vnd,
        avg_buy_price_usd = v_new_avg_price_usd,
        last_updated_at = NOW()
    WHERE id = v_inventory_record.id;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_currency_inventory"() OWNER TO "postgres";

--
-- Name: FUNCTION "update_currency_inventory"(); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION "public"."update_currency_inventory"() IS 'Cập nhật tồn kho tự động khi có giao dịch mới';


--
-- Name: update_order_details_v1("uuid", "text", timestamp with time zone, "text", "text", "text", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

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

--
-- Name: update_order_line_machine_info_v1("uuid", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

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

--
-- Name: update_pilot_cycle_warning("uuid"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."update_pilot_cycle_warning"("p_order_line_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    v_service_type TEXT;
    v_order_status TEXT;
    v_pilot_is_blocked BOOLEAN;
    v_pilot_warning_level INTEGER;
    v_hours_online NUMERIC;
    v_current_paused_at TIMESTAMP WITH TIME ZONE;
    v_cycle_start_at TIMESTAMP WITH TIME ZONE;
BEGIN
    -- Get order information
    SELECT pv.display_name, o.status, ol.pilot_is_blocked, ol.pilot_warning_level, ol.paused_at,
           COALESCE(ol.pilot_cycle_start_at, o.created_at) as cycle_start_at
    INTO v_service_type, v_order_status, v_pilot_is_blocked, v_pilot_warning_level, v_current_paused_at, v_cycle_start_at
    FROM public.orders o
    JOIN public.order_lines ol ON o.id = ol.order_id
    JOIN public.product_variants pv ON ol.variant_id = pv.id
    WHERE ol.id = p_order_line_id;

    -- Only process pilot orders
    IF v_service_type != 'Service - Pilot' THEN
        RETURN;
    END IF;

    -- Skip completed orders
    IF v_order_status IN ('completed', 'cancelled', 'delivered', 'pending_completion') THEN
        RETURN;
    END IF;

    -- Calculate online hours from current cycle start time
    IF v_current_paused_at IS NOT NULL THEN
        -- Currently resting
        v_hours_online := EXTRACT(EPOCH FROM (v_current_paused_at - v_cycle_start_at)) / 3600;
    ELSE
        -- Currently online
        v_hours_online := EXTRACT(EPOCH FROM (NOW() - v_cycle_start_at)) / 3600;
    END IF;

    -- Update warning level
    UPDATE public.order_lines
    SET
        pilot_warning_level = CASE
            WHEN v_hours_online >= 6 * 24 THEN 2  -- >= 6 days
            WHEN v_hours_online >= 5 * 24 THEN 1  -- >= 5 days
            ELSE 0
        END,
        pilot_is_blocked = (v_hours_online >= 6 * 24)
    WHERE id = p_order_line_id;
END;
$$;


ALTER FUNCTION "public"."update_pilot_cycle_warning"("p_order_line_id" "uuid") OWNER TO "postgres";

--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE OR REPLACE FUNCTION "public"."update_updated_at_column"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_updated_at_column"() OWNER TO "postgres";

--
-- Name: apply_rls("jsonb", integer); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE OR REPLACE FUNCTION "realtime"."apply_rls"("wal" "jsonb", "max_record_bytes" integer DEFAULT (1024 * 1024)) RETURNS SETOF "realtime"."wal_rls"
    LANGUAGE "plpgsql"
    AS $$
declare
-- Regclass of the table e.g. public.notes
entity_ regclass = (quote_ident(wal ->> 'schema') || '.' || quote_ident(wal ->> 'table'))::regclass;

-- I, U, D, T: insert, update ...
action realtime.action = (
    case wal ->> 'action'
        when 'I' then 'INSERT'
        when 'U' then 'UPDATE'
        when 'D' then 'DELETE'
        else 'ERROR'
    end
);

-- Is row level security enabled for the table
is_rls_enabled bool = relrowsecurity from pg_class where oid = entity_;

subscriptions realtime.subscription[] = array_agg(subs)
    from
        realtime.subscription subs
    where
        subs.entity = entity_;

-- Subscription vars
roles regrole[] = array_agg(distinct us.claims_role::text)
    from
        unnest(subscriptions) us;

working_role regrole;
claimed_role regrole;
claims jsonb;

subscription_id uuid;
subscription_has_access bool;
visible_to_subscription_ids uuid[] = '{}';

-- structured info for wal's columns
columns realtime.wal_column[];
-- previous identity values for update/delete
old_columns realtime.wal_column[];

error_record_exceeds_max_size boolean = octet_length(wal::text) > max_record_bytes;

-- Primary jsonb output for record
output jsonb;

begin
perform set_config('role', null, true);

columns =
    array_agg(
        (
            x->>'name',
            x->>'type',
            x->>'typeoid',
            realtime.cast(
                (x->'value') #>> '{}',
                coalesce(
                    (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                    (x->>'type')::regtype
                )
            ),
            (pks ->> 'name') is not null,
            true
        )::realtime.wal_column
    )
    from
        jsonb_array_elements(wal -> 'columns') x
        left join jsonb_array_elements(wal -> 'pk') pks
            on (x ->> 'name') = (pks ->> 'name');

old_columns =
    array_agg(
        (
            x->>'name',
            x->>'type',
            x->>'typeoid',
            realtime.cast(
                (x->'value') #>> '{}',
                coalesce(
                    (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                    (x->>'type')::regtype
                )
            ),
            (pks ->> 'name') is not null,
            true
        )::realtime.wal_column
    )
    from
        jsonb_array_elements(wal -> 'identity') x
        left join jsonb_array_elements(wal -> 'pk') pks
            on (x ->> 'name') = (pks ->> 'name');

for working_role in select * from unnest(roles) loop

    -- Update `is_selectable` for columns and old_columns
    columns =
        array_agg(
            (
                c.name,
                c.type_name,
                c.type_oid,
                c.value,
                c.is_pkey,
                pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
            )::realtime.wal_column
        )
        from
            unnest(columns) c;

    old_columns =
            array_agg(
                (
                    c.name,
                    c.type_name,
                    c.type_oid,
                    c.value,
                    c.is_pkey,
                    pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
                )::realtime.wal_column
            )
            from
                unnest(old_columns) c;

    if action <> 'DELETE' and count(1) = 0 from unnest(columns) c where c.is_pkey then
        return next (
            jsonb_build_object(
                'schema', wal ->> 'schema',
                'table', wal ->> 'table',
                'type', action
            ),
            is_rls_enabled,
            -- subscriptions is already filtered by entity
            (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
            array['Error 400: Bad Request, no primary key']
        )::realtime.wal_rls;

    -- The claims role does not have SELECT permission to the primary key of entity
    elsif action <> 'DELETE' and sum(c.is_selectable::int) <> count(1) from unnest(columns) c where c.is_pkey then
        return next (
            jsonb_build_object(
                'schema', wal ->> 'schema',
                'table', wal ->> 'table',
                'type', action
            ),
            is_rls_enabled,
            (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
            array['Error 401: Unauthorized']
        )::realtime.wal_rls;

    else
        output = jsonb_build_object(
            'schema', wal ->> 'schema',
            'table', wal ->> 'table',
            'type', action,
            'commit_timestamp', to_char(
                ((wal ->> 'timestamp')::timestamptz at time zone 'utc'),
                'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'
            ),
            'columns', (
                select
                    jsonb_agg(
                        jsonb_build_object(
                            'name', pa.attname,
                            'type', pt.typname
                        )
                        order by pa.attnum asc
                    )
                from
                    pg_attribute pa
                    join pg_type pt
                        on pa.atttypid = pt.oid
                where
                    attrelid = entity_
                    and attnum > 0
                    and pg_catalog.has_column_privilege(working_role, entity_, pa.attname, 'SELECT')
            )
        )
        -- Add "record" key for insert and update
        || case
            when action in ('INSERT', 'UPDATE') then
                jsonb_build_object(
                    'record',
                    (
                        select
                            jsonb_object_agg(
                                -- if unchanged toast, get column name and value from old record
                                coalesce((c).name, (oc).name),
                                case
                                    when (c).name is null then (oc).value
                                    else (c).value
                                end
                            )
                        from
                            unnest(columns) c
                            full outer join unnest(old_columns) oc
                                on (c).name = (oc).name
                        where
                            coalesce((c).is_selectable, (oc).is_selectable)
                            and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                    )
                )
            else '{}'::jsonb
        end
        -- Add "old_record" key for update and delete
        || case
            when action = 'UPDATE' then
                jsonb_build_object(
                        'old_record',
                        (
                            select jsonb_object_agg((c).name, (c).value)
                            from unnest(old_columns) c
                            where
                                (c).is_selectable
                                and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                        )
                    )
            when action = 'DELETE' then
                jsonb_build_object(
                    'old_record',
                    (
                        select jsonb_object_agg((c).name, (c).value)
                        from unnest(old_columns) c
                        where
                            (c).is_selectable
                            and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                            and ( not is_rls_enabled or (c).is_pkey ) -- if RLS enabled, we can't secure deletes so filter to pkey
                    )
                )
            else '{}'::jsonb
        end;

        -- Create the prepared statement
        if is_rls_enabled and action <> 'DELETE' then
            if (select 1 from pg_prepared_statements where name = 'walrus_rls_stmt' limit 1) > 0 then
                deallocate walrus_rls_stmt;
            end if;
            execute realtime.build_prepared_statement_sql('walrus_rls_stmt', entity_, columns);
        end if;

        visible_to_subscription_ids = '{}';

        for subscription_id, claims in (
                select
                    subs.subscription_id,
                    subs.claims
                from
                    unnest(subscriptions) subs
                where
                    subs.entity = entity_
                    and subs.claims_role = working_role
                    and (
                        realtime.is_visible_through_filters(columns, subs.filters)
                        or (
                          action = 'DELETE'
                          and realtime.is_visible_through_filters(old_columns, subs.filters)
                        )
                    )
        ) loop

            if not is_rls_enabled or action = 'DELETE' then
                visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
            else
                -- Check if RLS allows the role to see the record
                perform
                    -- Trim leading and trailing quotes from working_role because set_config
                    -- doesn't recognize the role as valid if they are included
                    set_config('role', trim(both '"' from working_role::text), true),
                    set_config('request.jwt.claims', claims::text, true);

                execute 'execute walrus_rls_stmt' into subscription_has_access;

                if subscription_has_access then
                    visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
                end if;
            end if;
        end loop;

        perform set_config('role', null, true);

        return next (
            output,
            is_rls_enabled,
            visible_to_subscription_ids,
            case
                when error_record_exceeds_max_size then array['Error 413: Payload Too Large']
                else '{}'
            end
        )::realtime.wal_rls;

    end if;
end loop;

perform set_config('role', null, true);
end;
$$;


ALTER FUNCTION "realtime"."apply_rls"("wal" "jsonb", "max_record_bytes" integer) OWNER TO "supabase_admin";

--
-- Name: broadcast_changes("text", "text", "text", "text", "text", "record", "record", "text"); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE OR REPLACE FUNCTION "realtime"."broadcast_changes"("topic_name" "text", "event_name" "text", "operation" "text", "table_name" "text", "table_schema" "text", "new" "record", "old" "record", "level" "text" DEFAULT 'ROW'::"text") RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    -- Declare a variable to hold the JSONB representation of the row
    row_data jsonb := '{}'::jsonb;
BEGIN
    IF level = 'STATEMENT' THEN
        RAISE EXCEPTION 'function can only be triggered for each row, not for each statement';
    END IF;
    -- Check the operation type and handle accordingly
    IF operation = 'INSERT' OR operation = 'UPDATE' OR operation = 'DELETE' THEN
        row_data := jsonb_build_object('old_record', OLD, 'record', NEW, 'operation', operation, 'table', table_name, 'schema', table_schema);
        PERFORM realtime.send (row_data, event_name, topic_name);
    ELSE
        RAISE EXCEPTION 'Unexpected operation type: %', operation;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to process the row: %', SQLERRM;
END;

$$;


ALTER FUNCTION "realtime"."broadcast_changes"("topic_name" "text", "event_name" "text", "operation" "text", "table_name" "text", "table_schema" "text", "new" "record", "old" "record", "level" "text") OWNER TO "supabase_admin";

--
-- Name: build_prepared_statement_sql("text", "regclass", "realtime"."wal_column"[]); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE OR REPLACE FUNCTION "realtime"."build_prepared_statement_sql"("prepared_statement_name" "text", "entity" "regclass", "columns" "realtime"."wal_column"[]) RETURNS "text"
    LANGUAGE "sql"
    AS $$
      /*
      Builds a sql string that, if executed, creates a prepared statement to
      tests retrive a row from *entity* by its primary key columns.
      Example
          select realtime.build_prepared_statement_sql('public.notes', '{"id"}'::text[], '{"bigint"}'::text[])
      */
          select
      'prepare ' || prepared_statement_name || ' as
          select
              exists(
                  select
                      1
                  from
                      ' || entity || '
                  where
                      ' || string_agg(quote_ident(pkc.name) || '=' || quote_nullable(pkc.value #>> '{}') , ' and ') || '
              )'
          from
              unnest(columns) pkc
          where
              pkc.is_pkey
          group by
              entity
      $$;


ALTER FUNCTION "realtime"."build_prepared_statement_sql"("prepared_statement_name" "text", "entity" "regclass", "columns" "realtime"."wal_column"[]) OWNER TO "supabase_admin";

--
-- Name: cast("text", "regtype"); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE OR REPLACE FUNCTION "realtime"."cast"("val" "text", "type_" "regtype") RETURNS "jsonb"
    LANGUAGE "plpgsql" IMMUTABLE
    AS $$
    declare
      res jsonb;
    begin
      execute format('select to_jsonb(%L::'|| type_::text || ')', val)  into res;
      return res;
    end
    $$;


ALTER FUNCTION "realtime"."cast"("val" "text", "type_" "regtype") OWNER TO "supabase_admin";

--
-- Name: check_equality_op("realtime"."equality_op", "regtype", "text", "text"); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE OR REPLACE FUNCTION "realtime"."check_equality_op"("op" "realtime"."equality_op", "type_" "regtype", "val_1" "text", "val_2" "text") RETURNS boolean
    LANGUAGE "plpgsql" IMMUTABLE
    AS $$
      /*
      Casts *val_1* and *val_2* as type *type_* and check the *op* condition for truthiness
      */
      declare
          op_symbol text = (
              case
                  when op = 'eq' then '='
                  when op = 'neq' then '!='
                  when op = 'lt' then '<'
                  when op = 'lte' then '<='
                  when op = 'gt' then '>'
                  when op = 'gte' then '>='
                  when op = 'in' then '= any'
                  else 'UNKNOWN OP'
              end
          );
          res boolean;
      begin
          execute format(
              'select %L::'|| type_::text || ' ' || op_symbol
              || ' ( %L::'
              || (
                  case
                      when op = 'in' then type_::text || '[]'
                      else type_::text end
              )
              || ')', val_1, val_2) into res;
          return res;
      end;
      $$;


ALTER FUNCTION "realtime"."check_equality_op"("op" "realtime"."equality_op", "type_" "regtype", "val_1" "text", "val_2" "text") OWNER TO "supabase_admin";

--
-- Name: is_visible_through_filters("realtime"."wal_column"[], "realtime"."user_defined_filter"[]); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE OR REPLACE FUNCTION "realtime"."is_visible_through_filters"("columns" "realtime"."wal_column"[], "filters" "realtime"."user_defined_filter"[]) RETURNS boolean
    LANGUAGE "sql" IMMUTABLE
    AS $_$
    /*
    Should the record be visible (true) or filtered out (false) after *filters* are applied
    */
        select
            -- Default to allowed when no filters present
            $2 is null -- no filters. this should not happen because subscriptions has a default
            or array_length($2, 1) is null -- array length of an empty array is null
            or bool_and(
                coalesce(
                    realtime.check_equality_op(
                        op:=f.op,
                        type_:=coalesce(
                            col.type_oid::regtype, -- null when wal2json version <= 2.4
                            col.type_name::regtype
                        ),
                        -- cast jsonb to text
                        val_1:=col.value #>> '{}',
                        val_2:=f.value
                    ),
                    false -- if null, filter does not match
                )
            )
        from
            unnest(filters) f
            join unnest(columns) col
                on f.column_name = col.name;
    $_$;


ALTER FUNCTION "realtime"."is_visible_through_filters"("columns" "realtime"."wal_column"[], "filters" "realtime"."user_defined_filter"[]) OWNER TO "supabase_admin";

--
-- Name: list_changes("name", "name", integer, integer); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE OR REPLACE FUNCTION "realtime"."list_changes"("publication" "name", "slot_name" "name", "max_changes" integer, "max_record_bytes" integer) RETURNS SETOF "realtime"."wal_rls"
    LANGUAGE "sql"
    SET "log_min_messages" TO 'fatal'
    AS $$
      with pub as (
        select
          concat_ws(
            ',',
            case when bool_or(pubinsert) then 'insert' else null end,
            case when bool_or(pubupdate) then 'update' else null end,
            case when bool_or(pubdelete) then 'delete' else null end
          ) as w2j_actions,
          coalesce(
            string_agg(
              realtime.quote_wal2json(format('%I.%I', schemaname, tablename)::regclass),
              ','
            ) filter (where ppt.tablename is not null and ppt.tablename not like '% %'),
            ''
          ) w2j_add_tables
        from
          pg_publication pp
          left join pg_publication_tables ppt
            on pp.pubname = ppt.pubname
        where
          pp.pubname = publication
        group by
          pp.pubname
        limit 1
      ),
      w2j as (
        select
          x.*, pub.w2j_add_tables
        from
          pub,
          pg_logical_slot_get_changes(
            slot_name, null, max_changes,
            'include-pk', 'true',
            'include-transaction', 'false',
            'include-timestamp', 'true',
            'include-type-oids', 'true',
            'format-version', '2',
            'actions', pub.w2j_actions,
            'add-tables', pub.w2j_add_tables
          ) x
      )
      select
        xyz.wal,
        xyz.is_rls_enabled,
        xyz.subscription_ids,
        xyz.errors
      from
        w2j,
        realtime.apply_rls(
          wal := w2j.data::jsonb,
          max_record_bytes := max_record_bytes
        ) xyz(wal, is_rls_enabled, subscription_ids, errors)
      where
        w2j.w2j_add_tables <> ''
        and xyz.subscription_ids[1] is not null
    $$;


ALTER FUNCTION "realtime"."list_changes"("publication" "name", "slot_name" "name", "max_changes" integer, "max_record_bytes" integer) OWNER TO "supabase_admin";

--
-- Name: quote_wal2json("regclass"); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE OR REPLACE FUNCTION "realtime"."quote_wal2json"("entity" "regclass") RETURNS "text"
    LANGUAGE "sql" IMMUTABLE STRICT
    AS $$
      select
        (
          select string_agg('' || ch,'')
          from unnest(string_to_array(nsp.nspname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
        )
        || '.'
        || (
          select string_agg('' || ch,'')
          from unnest(string_to_array(pc.relname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
          )
      from
        pg_class pc
        join pg_namespace nsp
          on pc.relnamespace = nsp.oid
      where
        pc.oid = entity
    $$;


ALTER FUNCTION "realtime"."quote_wal2json"("entity" "regclass") OWNER TO "supabase_admin";

--
-- Name: send("jsonb", "text", "text", boolean); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE OR REPLACE FUNCTION "realtime"."send"("payload" "jsonb", "event" "text", "topic" "text", "private" boolean DEFAULT true) RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  BEGIN
    -- Set the topic configuration
    EXECUTE format('SET LOCAL realtime.topic TO %L', topic);

    -- Attempt to insert the message
    INSERT INTO realtime.messages (payload, event, topic, private, extension)
    VALUES (payload, event, topic, private, 'broadcast');
  EXCEPTION
    WHEN OTHERS THEN
      -- Capture and notify the error
      RAISE WARNING 'ErrorSendingBroadcastMessage: %', SQLERRM;
  END;
END;
$$;


ALTER FUNCTION "realtime"."send"("payload" "jsonb", "event" "text", "topic" "text", "private" boolean) OWNER TO "supabase_admin";

--
-- Name: subscription_check_filters(); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE OR REPLACE FUNCTION "realtime"."subscription_check_filters"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
    /*
    Validates that the user defined filters for a subscription:
    - refer to valid columns that the claimed role may access
    - values are coercable to the correct column type
    */
    declare
        col_names text[] = coalesce(
                array_agg(c.column_name order by c.ordinal_position),
                '{}'::text[]
            )
            from
                information_schema.columns c
            where
                format('%I.%I', c.table_schema, c.table_name)::regclass = new.entity
                and pg_catalog.has_column_privilege(
                    (new.claims ->> 'role'),
                    format('%I.%I', c.table_schema, c.table_name)::regclass,
                    c.column_name,
                    'SELECT'
                );
        filter realtime.user_defined_filter;
        col_type regtype;

        in_val jsonb;
    begin
        for filter in select * from unnest(new.filters) loop
            -- Filtered column is valid
            if not filter.column_name = any(col_names) then
                raise exception 'invalid column for filter %', filter.column_name;
            end if;

            -- Type is sanitized and safe for string interpolation
            col_type = (
                select atttypid::regtype
                from pg_catalog.pg_attribute
                where attrelid = new.entity
                      and attname = filter.column_name
            );
            if col_type is null then
                raise exception 'failed to lookup type for column %', filter.column_name;
            end if;

            -- Set maximum number of entries for in filter
            if filter.op = 'in'::realtime.equality_op then
                in_val = realtime.cast(filter.value, (col_type::text || '[]')::regtype);
                if coalesce(jsonb_array_length(in_val), 0) > 100 then
                    raise exception 'too many values for `in` filter. Maximum 100';
                end if;
            else
                -- raises an exception if value is not coercable to type
                perform realtime.cast(filter.value, col_type);
            end if;

        end loop;

        -- Apply consistent order to filters so the unique constraint on
        -- (subscription_id, entity, filters) can't be tricked by a different filter order
        new.filters = coalesce(
            array_agg(f order by f.column_name, f.op, f.value),
            '{}'
        ) from unnest(new.filters) f;

        return new;
    end;
    $$;


ALTER FUNCTION "realtime"."subscription_check_filters"() OWNER TO "supabase_admin";

--
-- Name: to_regrole("text"); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE OR REPLACE FUNCTION "realtime"."to_regrole"("role_name" "text") RETURNS "regrole"
    LANGUAGE "sql" IMMUTABLE
    AS $$ select role_name::regrole $$;


ALTER FUNCTION "realtime"."to_regrole"("role_name" "text") OWNER TO "supabase_admin";

--
-- Name: topic(); Type: FUNCTION; Schema: realtime; Owner: supabase_realtime_admin
--

CREATE OR REPLACE FUNCTION "realtime"."topic"() RETURNS "text"
    LANGUAGE "sql" STABLE
    AS $$
select nullif(current_setting('realtime.topic', true), '')::text;
$$;


ALTER FUNCTION "realtime"."topic"() OWNER TO "supabase_realtime_admin";

--
-- Name: add_prefixes("text", "text"); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE OR REPLACE FUNCTION "storage"."add_prefixes"("_bucket_id" "text", "_name" "text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    prefixes text[];
BEGIN
    prefixes := "storage"."get_prefixes"("_name");

    IF array_length(prefixes, 1) > 0 THEN
        INSERT INTO storage.prefixes (name, bucket_id)
        SELECT UNNEST(prefixes) as name, "_bucket_id" ON CONFLICT DO NOTHING;
    END IF;
END;
$$;


ALTER FUNCTION "storage"."add_prefixes"("_bucket_id" "text", "_name" "text") OWNER TO "supabase_storage_admin";

--
-- Name: can_insert_object("text", "text", "uuid", "jsonb"); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE OR REPLACE FUNCTION "storage"."can_insert_object"("bucketid" "text", "name" "text", "owner" "uuid", "metadata" "jsonb") RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  INSERT INTO "storage"."objects" ("bucket_id", "name", "owner", "metadata") VALUES (bucketid, name, owner, metadata);
  -- hack to rollback the successful insert
  RAISE sqlstate 'PT200' using
  message = 'ROLLBACK',
  detail = 'rollback successful insert';
END
$$;


ALTER FUNCTION "storage"."can_insert_object"("bucketid" "text", "name" "text", "owner" "uuid", "metadata" "jsonb") OWNER TO "supabase_storage_admin";

--
-- Name: delete_leaf_prefixes("text"[], "text"[]); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE OR REPLACE FUNCTION "storage"."delete_leaf_prefixes"("bucket_ids" "text"[], "names" "text"[]) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_rows_deleted integer;
BEGIN
    LOOP
        WITH candidates AS (
            SELECT DISTINCT
                t.bucket_id,
                unnest(storage.get_prefixes(t.name)) AS name
            FROM unnest(bucket_ids, names) AS t(bucket_id, name)
        ),
        uniq AS (
             SELECT
                 bucket_id,
                 name,
                 storage.get_level(name) AS level
             FROM candidates
             WHERE name <> ''
             GROUP BY bucket_id, name
        ),
        leaf AS (
             SELECT
                 p.bucket_id,
                 p.name,
                 p.level
             FROM storage.prefixes AS p
                  JOIN uniq AS u
                       ON u.bucket_id = p.bucket_id
                           AND u.name = p.name
                           AND u.level = p.level
             WHERE NOT EXISTS (
                 SELECT 1
                 FROM storage.objects AS o
                 WHERE o.bucket_id = p.bucket_id
                   AND o.level = p.level + 1
                   AND o.name COLLATE "C" LIKE p.name || '/%'
             )
             AND NOT EXISTS (
                 SELECT 1
                 FROM storage.prefixes AS c
                 WHERE c.bucket_id = p.bucket_id
                   AND c.level = p.level + 1
                   AND c.name COLLATE "C" LIKE p.name || '/%'
             )
        )
        DELETE
        FROM storage.prefixes AS p
            USING leaf AS l
        WHERE p.bucket_id = l.bucket_id
          AND p.name = l.name
          AND p.level = l.level;

        GET DIAGNOSTICS v_rows_deleted = ROW_COUNT;
        EXIT WHEN v_rows_deleted = 0;
    END LOOP;
END;
$$;


ALTER FUNCTION "storage"."delete_leaf_prefixes"("bucket_ids" "text"[], "names" "text"[]) OWNER TO "supabase_storage_admin";

--
-- Name: delete_prefix("text", "text"); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE OR REPLACE FUNCTION "storage"."delete_prefix"("_bucket_id" "text", "_name" "text") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    -- Check if we can delete the prefix
    IF EXISTS(
        SELECT FROM "storage"."prefixes"
        WHERE "prefixes"."bucket_id" = "_bucket_id"
          AND level = "storage"."get_level"("_name") + 1
          AND "prefixes"."name" COLLATE "C" LIKE "_name" || '/%'
        LIMIT 1
    )
    OR EXISTS(
        SELECT FROM "storage"."objects"
        WHERE "objects"."bucket_id" = "_bucket_id"
          AND "storage"."get_level"("objects"."name") = "storage"."get_level"("_name") + 1
          AND "objects"."name" COLLATE "C" LIKE "_name" || '/%'
        LIMIT 1
    ) THEN
    -- There are sub-objects, skip deletion
    RETURN false;
    ELSE
        DELETE FROM "storage"."prefixes"
        WHERE "prefixes"."bucket_id" = "_bucket_id"
          AND level = "storage"."get_level"("_name")
          AND "prefixes"."name" = "_name";
        RETURN true;
    END IF;
END;
$$;


ALTER FUNCTION "storage"."delete_prefix"("_bucket_id" "text", "_name" "text") OWNER TO "supabase_storage_admin";

--
-- Name: delete_prefix_hierarchy_trigger(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE OR REPLACE FUNCTION "storage"."delete_prefix_hierarchy_trigger"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    prefix text;
BEGIN
    prefix := "storage"."get_prefix"(OLD."name");

    IF coalesce(prefix, '') != '' THEN
        PERFORM "storage"."delete_prefix"(OLD."bucket_id", prefix);
    END IF;

    RETURN OLD;
END;
$$;


ALTER FUNCTION "storage"."delete_prefix_hierarchy_trigger"() OWNER TO "supabase_storage_admin";

--
-- Name: enforce_bucket_name_length(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE OR REPLACE FUNCTION "storage"."enforce_bucket_name_length"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
begin
    if length(new.name) > 100 then
        raise exception 'bucket name "%" is too long (% characters). Max is 100.', new.name, length(new.name);
    end if;
    return new;
end;
$$;


ALTER FUNCTION "storage"."enforce_bucket_name_length"() OWNER TO "supabase_storage_admin";

--
-- Name: extension("text"); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE OR REPLACE FUNCTION "storage"."extension"("name" "text") RETURNS "text"
    LANGUAGE "plpgsql" IMMUTABLE
    AS $$
DECLARE
    _parts text[];
    _filename text;
BEGIN
    SELECT string_to_array(name, '/') INTO _parts;
    SELECT _parts[array_length(_parts,1)] INTO _filename;
    RETURN reverse(split_part(reverse(_filename), '.', 1));
END
$$;


ALTER FUNCTION "storage"."extension"("name" "text") OWNER TO "supabase_storage_admin";

--
-- Name: filename("text"); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE OR REPLACE FUNCTION "storage"."filename"("name" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
_parts text[];
BEGIN
	select string_to_array(name, '/') into _parts;
	return _parts[array_length(_parts,1)];
END
$$;


ALTER FUNCTION "storage"."filename"("name" "text") OWNER TO "supabase_storage_admin";

--
-- Name: foldername("text"); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE OR REPLACE FUNCTION "storage"."foldername"("name" "text") RETURNS "text"[]
    LANGUAGE "plpgsql" IMMUTABLE
    AS $$
DECLARE
    _parts text[];
BEGIN
    -- Split on "/" to get path segments
    SELECT string_to_array(name, '/') INTO _parts;
    -- Return everything except the last segment
    RETURN _parts[1 : array_length(_parts,1) - 1];
END
$$;


ALTER FUNCTION "storage"."foldername"("name" "text") OWNER TO "supabase_storage_admin";

--
-- Name: get_level("text"); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE OR REPLACE FUNCTION "storage"."get_level"("name" "text") RETURNS integer
    LANGUAGE "sql" IMMUTABLE STRICT
    AS $$
SELECT array_length(string_to_array("name", '/'), 1);
$$;


ALTER FUNCTION "storage"."get_level"("name" "text") OWNER TO "supabase_storage_admin";

--
-- Name: get_prefix("text"); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE OR REPLACE FUNCTION "storage"."get_prefix"("name" "text") RETURNS "text"
    LANGUAGE "sql" IMMUTABLE STRICT
    AS $_$
SELECT
    CASE WHEN strpos("name", '/') > 0 THEN
             regexp_replace("name", '[\/]{1}[^\/]+\/?$', '')
         ELSE
             ''
        END;
$_$;


ALTER FUNCTION "storage"."get_prefix"("name" "text") OWNER TO "supabase_storage_admin";

--
-- Name: get_prefixes("text"); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE OR REPLACE FUNCTION "storage"."get_prefixes"("name" "text") RETURNS "text"[]
    LANGUAGE "plpgsql" IMMUTABLE STRICT
    AS $$
DECLARE
    parts text[];
    prefixes text[];
    prefix text;
BEGIN
    -- Split the name into parts by '/'
    parts := string_to_array("name", '/');
    prefixes := '{}';

    -- Construct the prefixes, stopping one level below the last part
    FOR i IN 1..array_length(parts, 1) - 1 LOOP
            prefix := array_to_string(parts[1:i], '/');
            prefixes := array_append(prefixes, prefix);
    END LOOP;

    RETURN prefixes;
END;
$$;


ALTER FUNCTION "storage"."get_prefixes"("name" "text") OWNER TO "supabase_storage_admin";

--
-- Name: get_size_by_bucket(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE OR REPLACE FUNCTION "storage"."get_size_by_bucket"() RETURNS TABLE("size" bigint, "bucket_id" "text")
    LANGUAGE "plpgsql" STABLE
    AS $$
BEGIN
    return query
        select sum((metadata->>'size')::bigint) as size, obj.bucket_id
        from "storage".objects as obj
        group by obj.bucket_id;
END
$$;


ALTER FUNCTION "storage"."get_size_by_bucket"() OWNER TO "supabase_storage_admin";

--
-- Name: list_multipart_uploads_with_delimiter("text", "text", "text", integer, "text", "text"); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE OR REPLACE FUNCTION "storage"."list_multipart_uploads_with_delimiter"("bucket_id" "text", "prefix_param" "text", "delimiter_param" "text", "max_keys" integer DEFAULT 100, "next_key_token" "text" DEFAULT ''::"text", "next_upload_token" "text" DEFAULT ''::"text") RETURNS TABLE("key" "text", "id" "text", "created_at" timestamp with time zone)
    LANGUAGE "plpgsql"
    AS $_$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(key COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                        substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1)))
                    ELSE
                        key
                END AS key, id, created_at
            FROM
                storage.s3_multipart_uploads
            WHERE
                bucket_id = $5 AND
                key ILIKE $1 || ''%'' AND
                CASE
                    WHEN $4 != '''' AND $6 = '''' THEN
                        CASE
                            WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                                substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                key COLLATE "C" > $4
                            END
                    ELSE
                        true
                END AND
                CASE
                    WHEN $6 != '''' THEN
                        id COLLATE "C" > $6
                    ELSE
                        true
                    END
            ORDER BY
                key COLLATE "C" ASC, created_at ASC) as e order by key COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_key_token, bucket_id, next_upload_token;
END;
$_$;


ALTER FUNCTION "storage"."list_multipart_uploads_with_delimiter"("bucket_id" "text", "prefix_param" "text", "delimiter_param" "text", "max_keys" integer, "next_key_token" "text", "next_upload_token" "text") OWNER TO "supabase_storage_admin";

--
-- Name: list_objects_with_delimiter("text", "text", "text", integer, "text", "text"); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE OR REPLACE FUNCTION "storage"."list_objects_with_delimiter"("bucket_id" "text", "prefix_param" "text", "delimiter_param" "text", "max_keys" integer DEFAULT 100, "start_after" "text" DEFAULT ''::"text", "next_token" "text" DEFAULT ''::"text") RETURNS TABLE("name" "text", "id" "uuid", "metadata" "jsonb", "updated_at" timestamp with time zone)
    LANGUAGE "plpgsql"
    AS $_$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(name COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(name from length($1) + 1)) > 0 THEN
                        substring(name from 1 for length($1) + position($2 IN substring(name from length($1) + 1)))
                    ELSE
                        name
                END AS name, id, metadata, updated_at
            FROM
                storage.objects
            WHERE
                bucket_id = $5 AND
                name ILIKE $1 || ''%'' AND
                CASE
                    WHEN $6 != '''' THEN
                    name COLLATE "C" > $6
                ELSE true END
                AND CASE
                    WHEN $4 != '''' THEN
                        CASE
                            WHEN position($2 IN substring(name from length($1) + 1)) > 0 THEN
                                substring(name from 1 for length($1) + position($2 IN substring(name from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                name COLLATE "C" > $4
                            END
                    ELSE
                        true
                END
            ORDER BY
                name COLLATE "C" ASC) as e order by name COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_token, bucket_id, start_after;
END;
$_$;


ALTER FUNCTION "storage"."list_objects_with_delimiter"("bucket_id" "text", "prefix_param" "text", "delimiter_param" "text", "max_keys" integer, "start_after" "text", "next_token" "text") OWNER TO "supabase_storage_admin";

--
-- Name: lock_top_prefixes("text"[], "text"[]); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE OR REPLACE FUNCTION "storage"."lock_top_prefixes"("bucket_ids" "text"[], "names" "text"[]) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_bucket text;
    v_top text;
BEGIN
    FOR v_bucket, v_top IN
        SELECT DISTINCT t.bucket_id,
            split_part(t.name, '/', 1) AS top
        FROM unnest(bucket_ids, names) AS t(bucket_id, name)
        WHERE t.name <> ''
        ORDER BY 1, 2
        LOOP
            PERFORM pg_advisory_xact_lock(hashtextextended(v_bucket || '/' || v_top, 0));
        END LOOP;
END;
$$;


ALTER FUNCTION "storage"."lock_top_prefixes"("bucket_ids" "text"[], "names" "text"[]) OWNER TO "supabase_storage_admin";

--
-- Name: objects_delete_cleanup(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE OR REPLACE FUNCTION "storage"."objects_delete_cleanup"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_bucket_ids text[];
    v_names      text[];
BEGIN
    IF current_setting('storage.gc.prefixes', true) = '1' THEN
        RETURN NULL;
    END IF;

    PERFORM set_config('storage.gc.prefixes', '1', true);

    SELECT COALESCE(array_agg(d.bucket_id), '{}'),
           COALESCE(array_agg(d.name), '{}')
    INTO v_bucket_ids, v_names
    FROM deleted AS d
    WHERE d.name <> '';

    PERFORM storage.lock_top_prefixes(v_bucket_ids, v_names);
    PERFORM storage.delete_leaf_prefixes(v_bucket_ids, v_names);

    RETURN NULL;
END;
$$;


ALTER FUNCTION "storage"."objects_delete_cleanup"() OWNER TO "supabase_storage_admin";

--
-- Name: objects_insert_prefix_trigger(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE OR REPLACE FUNCTION "storage"."objects_insert_prefix_trigger"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    PERFORM "storage"."add_prefixes"(NEW."bucket_id", NEW."name");
    NEW.level := "storage"."get_level"(NEW."name");

    RETURN NEW;
END;
$$;


ALTER FUNCTION "storage"."objects_insert_prefix_trigger"() OWNER TO "supabase_storage_admin";

--
-- Name: objects_update_cleanup(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE OR REPLACE FUNCTION "storage"."objects_update_cleanup"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    -- NEW - OLD (destinations to create prefixes for)
    v_add_bucket_ids text[];
    v_add_names      text[];

    -- OLD - NEW (sources to prune)
    v_src_bucket_ids text[];
    v_src_names      text[];
BEGIN
    IF TG_OP <> 'UPDATE' THEN
        RETURN NULL;
    END IF;

    -- 1) Compute NEW−OLD (added paths) and OLD−NEW (moved-away paths)
    WITH added AS (
        SELECT n.bucket_id, n.name
        FROM new_rows n
        WHERE n.name <> '' AND position('/' in n.name) > 0
        EXCEPT
        SELECT o.bucket_id, o.name FROM old_rows o WHERE o.name <> ''
    ),
    moved AS (
         SELECT o.bucket_id, o.name
         FROM old_rows o
         WHERE o.name <> ''
         EXCEPT
         SELECT n.bucket_id, n.name FROM new_rows n WHERE n.name <> ''
    )
    SELECT
        -- arrays for ADDED (dest) in stable order
        COALESCE( (SELECT array_agg(a.bucket_id ORDER BY a.bucket_id, a.name) FROM added a), '{}' ),
        COALESCE( (SELECT array_agg(a.name      ORDER BY a.bucket_id, a.name) FROM added a), '{}' ),
        -- arrays for MOVED (src) in stable order
        COALESCE( (SELECT array_agg(m.bucket_id ORDER BY m.bucket_id, m.name) FROM moved m), '{}' ),
        COALESCE( (SELECT array_agg(m.name      ORDER BY m.bucket_id, m.name) FROM moved m), '{}' )
    INTO v_add_bucket_ids, v_add_names, v_src_bucket_ids, v_src_names;

    -- Nothing to do?
    IF (array_length(v_add_bucket_ids, 1) IS NULL) AND (array_length(v_src_bucket_ids, 1) IS NULL) THEN
        RETURN NULL;
    END IF;

    -- 2) Take per-(bucket, top) locks: ALL prefixes in consistent global order to prevent deadlocks
    DECLARE
        v_all_bucket_ids text[];
        v_all_names text[];
    BEGIN
        -- Combine source and destination arrays for consistent lock ordering
        v_all_bucket_ids := COALESCE(v_src_bucket_ids, '{}') || COALESCE(v_add_bucket_ids, '{}');
        v_all_names := COALESCE(v_src_names, '{}') || COALESCE(v_add_names, '{}');

        -- Single lock call ensures consistent global ordering across all transactions
        IF array_length(v_all_bucket_ids, 1) IS NOT NULL THEN
            PERFORM storage.lock_top_prefixes(v_all_bucket_ids, v_all_names);
        END IF;
    END;

    -- 3) Create destination prefixes (NEW−OLD) BEFORE pruning sources
    IF array_length(v_add_bucket_ids, 1) IS NOT NULL THEN
        WITH candidates AS (
            SELECT DISTINCT t.bucket_id, unnest(storage.get_prefixes(t.name)) AS name
            FROM unnest(v_add_bucket_ids, v_add_names) AS t(bucket_id, name)
            WHERE name <> ''
        )
        INSERT INTO storage.prefixes (bucket_id, name)
        SELECT c.bucket_id, c.name
        FROM candidates c
        ON CONFLICT DO NOTHING;
    END IF;

    -- 4) Prune source prefixes bottom-up for OLD−NEW
    IF array_length(v_src_bucket_ids, 1) IS NOT NULL THEN
        -- re-entrancy guard so DELETE on prefixes won't recurse
        IF current_setting('storage.gc.prefixes', true) <> '1' THEN
            PERFORM set_config('storage.gc.prefixes', '1', true);
        END IF;

        PERFORM storage.delete_leaf_prefixes(v_src_bucket_ids, v_src_names);
    END IF;

    RETURN NULL;
END;
$$;


ALTER FUNCTION "storage"."objects_update_cleanup"() OWNER TO "supabase_storage_admin";

--
-- Name: objects_update_level_trigger(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE OR REPLACE FUNCTION "storage"."objects_update_level_trigger"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    -- Ensure this is an update operation and the name has changed
    IF TG_OP = 'UPDATE' AND (NEW."name" <> OLD."name" OR NEW."bucket_id" <> OLD."bucket_id") THEN
        -- Set the new level
        NEW."level" := "storage"."get_level"(NEW."name");
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "storage"."objects_update_level_trigger"() OWNER TO "supabase_storage_admin";

--
-- Name: objects_update_prefix_trigger(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE OR REPLACE FUNCTION "storage"."objects_update_prefix_trigger"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    old_prefixes TEXT[];
BEGIN
    -- Ensure this is an update operation and the name has changed
    IF TG_OP = 'UPDATE' AND (NEW."name" <> OLD."name" OR NEW."bucket_id" <> OLD."bucket_id") THEN
        -- Retrieve old prefixes
        old_prefixes := "storage"."get_prefixes"(OLD."name");

        -- Remove old prefixes that are only used by this object
        WITH all_prefixes as (
            SELECT unnest(old_prefixes) as prefix
        ),
        can_delete_prefixes as (
             SELECT prefix
             FROM all_prefixes
             WHERE NOT EXISTS (
                 SELECT 1 FROM "storage"."objects"
                 WHERE "bucket_id" = OLD."bucket_id"
                   AND "name" <> OLD."name"
                   AND "name" LIKE (prefix || '%')
             )
         )
        DELETE FROM "storage"."prefixes" WHERE name IN (SELECT prefix FROM can_delete_prefixes);

        -- Add new prefixes
        PERFORM "storage"."add_prefixes"(NEW."bucket_id", NEW."name");
    END IF;
    -- Set the new level
    NEW."level" := "storage"."get_level"(NEW."name");

    RETURN NEW;
END;
$$;


ALTER FUNCTION "storage"."objects_update_prefix_trigger"() OWNER TO "supabase_storage_admin";

--
-- Name: operation(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE OR REPLACE FUNCTION "storage"."operation"() RETURNS "text"
    LANGUAGE "plpgsql" STABLE
    AS $$
BEGIN
    RETURN current_setting('storage.operation', true);
END;
$$;


ALTER FUNCTION "storage"."operation"() OWNER TO "supabase_storage_admin";

--
-- Name: prefixes_delete_cleanup(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE OR REPLACE FUNCTION "storage"."prefixes_delete_cleanup"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_bucket_ids text[];
    v_names      text[];
BEGIN
    IF current_setting('storage.gc.prefixes', true) = '1' THEN
        RETURN NULL;
    END IF;

    PERFORM set_config('storage.gc.prefixes', '1', true);

    SELECT COALESCE(array_agg(d.bucket_id), '{}'),
           COALESCE(array_agg(d.name), '{}')
    INTO v_bucket_ids, v_names
    FROM deleted AS d
    WHERE d.name <> '';

    PERFORM storage.lock_top_prefixes(v_bucket_ids, v_names);
    PERFORM storage.delete_leaf_prefixes(v_bucket_ids, v_names);

    RETURN NULL;
END;
$$;


ALTER FUNCTION "storage"."prefixes_delete_cleanup"() OWNER TO "supabase_storage_admin";

--
-- Name: prefixes_insert_trigger(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE OR REPLACE FUNCTION "storage"."prefixes_insert_trigger"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    PERFORM "storage"."add_prefixes"(NEW."bucket_id", NEW."name");
    RETURN NEW;
END;
$$;


ALTER FUNCTION "storage"."prefixes_insert_trigger"() OWNER TO "supabase_storage_admin";

--
-- Name: search("text", "text", integer, integer, integer, "text", "text", "text"); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE OR REPLACE FUNCTION "storage"."search"("prefix" "text", "bucketname" "text", "limits" integer DEFAULT 100, "levels" integer DEFAULT 1, "offsets" integer DEFAULT 0, "search" "text" DEFAULT ''::"text", "sortcolumn" "text" DEFAULT 'name'::"text", "sortorder" "text" DEFAULT 'asc'::"text") RETURNS TABLE("name" "text", "id" "uuid", "updated_at" timestamp with time zone, "created_at" timestamp with time zone, "last_accessed_at" timestamp with time zone, "metadata" "jsonb")
    LANGUAGE "plpgsql"
    AS $$
declare
    can_bypass_rls BOOLEAN;
begin
    SELECT rolbypassrls
    INTO can_bypass_rls
    FROM pg_roles
    WHERE rolname = coalesce(nullif(current_setting('role', true), 'none'), current_user);

    IF can_bypass_rls THEN
        RETURN QUERY SELECT * FROM storage.search_v1_optimised(prefix, bucketname, limits, levels, offsets, search, sortcolumn, sortorder);
    ELSE
        RETURN QUERY SELECT * FROM storage.search_legacy_v1(prefix, bucketname, limits, levels, offsets, search, sortcolumn, sortorder);
    END IF;
end;
$$;


ALTER FUNCTION "storage"."search"("prefix" "text", "bucketname" "text", "limits" integer, "levels" integer, "offsets" integer, "search" "text", "sortcolumn" "text", "sortorder" "text") OWNER TO "supabase_storage_admin";

--
-- Name: search_legacy_v1("text", "text", integer, integer, integer, "text", "text", "text"); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE OR REPLACE FUNCTION "storage"."search_legacy_v1"("prefix" "text", "bucketname" "text", "limits" integer DEFAULT 100, "levels" integer DEFAULT 1, "offsets" integer DEFAULT 0, "search" "text" DEFAULT ''::"text", "sortcolumn" "text" DEFAULT 'name'::"text", "sortorder" "text" DEFAULT 'asc'::"text") RETURNS TABLE("name" "text", "id" "uuid", "updated_at" timestamp with time zone, "created_at" timestamp with time zone, "last_accessed_at" timestamp with time zone, "metadata" "jsonb")
    LANGUAGE "plpgsql" STABLE
    AS $_$
declare
    v_order_by text;
    v_sort_order text;
begin
    case
        when sortcolumn = 'name' then
            v_order_by = 'name';
        when sortcolumn = 'updated_at' then
            v_order_by = 'updated_at';
        when sortcolumn = 'created_at' then
            v_order_by = 'created_at';
        when sortcolumn = 'last_accessed_at' then
            v_order_by = 'last_accessed_at';
        else
            v_order_by = 'name';
        end case;

    case
        when sortorder = 'asc' then
            v_sort_order = 'asc';
        when sortorder = 'desc' then
            v_sort_order = 'desc';
        else
            v_sort_order = 'asc';
        end case;

    v_order_by = v_order_by || ' ' || v_sort_order;

    return query execute
        'with folders as (
           select path_tokens[$1] as folder
           from storage.objects
             where objects.name ilike $2 || $3 || ''%''
               and bucket_id = $4
               and array_length(objects.path_tokens, 1) <> $1
           group by folder
           order by folder ' || v_sort_order || '
     )
     (select folder as "name",
            null as id,
            null as updated_at,
            null as created_at,
            null as last_accessed_at,
            null as metadata from folders)
     union all
     (select path_tokens[$1] as "name",
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata
     from storage.objects
     where objects.name ilike $2 || $3 || ''%''
       and bucket_id = $4
       and array_length(objects.path_tokens, 1) = $1
     order by ' || v_order_by || ')
     limit $5
     offset $6' using levels, prefix, search, bucketname, limits, offsets;
end;
$_$;


ALTER FUNCTION "storage"."search_legacy_v1"("prefix" "text", "bucketname" "text", "limits" integer, "levels" integer, "offsets" integer, "search" "text", "sortcolumn" "text", "sortorder" "text") OWNER TO "supabase_storage_admin";

--
-- Name: search_v1_optimised("text", "text", integer, integer, integer, "text", "text", "text"); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE OR REPLACE FUNCTION "storage"."search_v1_optimised"("prefix" "text", "bucketname" "text", "limits" integer DEFAULT 100, "levels" integer DEFAULT 1, "offsets" integer DEFAULT 0, "search" "text" DEFAULT ''::"text", "sortcolumn" "text" DEFAULT 'name'::"text", "sortorder" "text" DEFAULT 'asc'::"text") RETURNS TABLE("name" "text", "id" "uuid", "updated_at" timestamp with time zone, "created_at" timestamp with time zone, "last_accessed_at" timestamp with time zone, "metadata" "jsonb")
    LANGUAGE "plpgsql" STABLE
    AS $_$
declare
    v_order_by text;
    v_sort_order text;
begin
    case
        when sortcolumn = 'name' then
            v_order_by = 'name';
        when sortcolumn = 'updated_at' then
            v_order_by = 'updated_at';
        when sortcolumn = 'created_at' then
            v_order_by = 'created_at';
        when sortcolumn = 'last_accessed_at' then
            v_order_by = 'last_accessed_at';
        else
            v_order_by = 'name';
        end case;

    case
        when sortorder = 'asc' then
            v_sort_order = 'asc';
        when sortorder = 'desc' then
            v_sort_order = 'desc';
        else
            v_sort_order = 'asc';
        end case;

    v_order_by = v_order_by || ' ' || v_sort_order;

    return query execute
        'with folders as (
           select (string_to_array(name, ''/''))[level] as name
           from storage.prefixes
             where lower(prefixes.name) like lower($2 || $3) || ''%''
               and bucket_id = $4
               and level = $1
           order by name ' || v_sort_order || '
     )
     (select name,
            null as id,
            null as updated_at,
            null as created_at,
            null as last_accessed_at,
            null as metadata from folders)
     union all
     (select path_tokens[level] as "name",
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata
     from storage.objects
     where lower(objects.name) like lower($2 || $3) || ''%''
       and bucket_id = $4
       and level = $1
     order by ' || v_order_by || ')
     limit $5
     offset $6' using levels, prefix, search, bucketname, limits, offsets;
end;
$_$;


ALTER FUNCTION "storage"."search_v1_optimised"("prefix" "text", "bucketname" "text", "limits" integer, "levels" integer, "offsets" integer, "search" "text", "sortcolumn" "text", "sortorder" "text") OWNER TO "supabase_storage_admin";

--
-- Name: search_v2("text", "text", integer, integer, "text", "text", "text", "text"); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE OR REPLACE FUNCTION "storage"."search_v2"("prefix" "text", "bucket_name" "text", "limits" integer DEFAULT 100, "levels" integer DEFAULT 1, "start_after" "text" DEFAULT ''::"text", "sort_order" "text" DEFAULT 'asc'::"text", "sort_column" "text" DEFAULT 'name'::"text", "sort_column_after" "text" DEFAULT ''::"text") RETURNS TABLE("key" "text", "name" "text", "id" "uuid", "updated_at" timestamp with time zone, "created_at" timestamp with time zone, "last_accessed_at" timestamp with time zone, "metadata" "jsonb")
    LANGUAGE "plpgsql" STABLE
    AS $_$
DECLARE
    sort_col text;
    sort_ord text;
    cursor_op text;
    cursor_expr text;
    sort_expr text;
BEGIN
    -- Validate sort_order
    sort_ord := lower(sort_order);
    IF sort_ord NOT IN ('asc', 'desc') THEN
        sort_ord := 'asc';
    END IF;

    -- Determine cursor comparison operator
    IF sort_ord = 'asc' THEN
        cursor_op := '>';
    ELSE
        cursor_op := '<';
    END IF;
    
    sort_col := lower(sort_column);
    -- Validate sort column  
    IF sort_col IN ('updated_at', 'created_at') THEN
        cursor_expr := format(
            '($5 = '''' OR ROW(date_trunc(''milliseconds'', %I), name COLLATE "C") %s ROW(COALESCE(NULLIF($6, '''')::timestamptz, ''epoch''::timestamptz), $5))',
            sort_col, cursor_op
        );
        sort_expr := format(
            'COALESCE(date_trunc(''milliseconds'', %I), ''epoch''::timestamptz) %s, name COLLATE "C" %s',
            sort_col, sort_ord, sort_ord
        );
    ELSE
        cursor_expr := format('($5 = '''' OR name COLLATE "C" %s $5)', cursor_op);
        sort_expr := format('name COLLATE "C" %s', sort_ord);
    END IF;

    RETURN QUERY EXECUTE format(
        $sql$
        SELECT * FROM (
            (
                SELECT
                    split_part(name, '/', $4) AS key,
                    name,
                    NULL::uuid AS id,
                    updated_at,
                    created_at,
                    NULL::timestamptz AS last_accessed_at,
                    NULL::jsonb AS metadata
                FROM storage.prefixes
                WHERE name COLLATE "C" LIKE $1 || '%%'
                    AND bucket_id = $2
                    AND level = $4
                    AND %s
                ORDER BY %s
                LIMIT $3
            )
            UNION ALL
            (
                SELECT
                    split_part(name, '/', $4) AS key,
                    name,
                    id,
                    updated_at,
                    created_at,
                    last_accessed_at,
                    metadata
                FROM storage.objects
                WHERE name COLLATE "C" LIKE $1 || '%%'
                    AND bucket_id = $2
                    AND level = $4
                    AND %s
                ORDER BY %s
                LIMIT $3
            )
        ) obj
        ORDER BY %s
        LIMIT $3
        $sql$,
        cursor_expr,    -- prefixes WHERE
        sort_expr,      -- prefixes ORDER BY
        cursor_expr,    -- objects WHERE
        sort_expr,      -- objects ORDER BY
        sort_expr       -- final ORDER BY
    )
    USING prefix, bucket_name, limits, levels, start_after, sort_column_after;
END;
$_$;


ALTER FUNCTION "storage"."search_v2"("prefix" "text", "bucket_name" "text", "limits" integer, "levels" integer, "start_after" "text", "sort_order" "text", "sort_column" "text", "sort_column_after" "text") OWNER TO "supabase_storage_admin";

--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE OR REPLACE FUNCTION "storage"."update_updated_at_column"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW; 
END;
$$;


ALTER FUNCTION "storage"."update_updated_at_column"() OWNER TO "supabase_storage_admin";

SET default_tablespace = '';

SET default_table_access_method = "heap";

--
-- Name: audit_log_entries; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE IF NOT EXISTS "auth"."audit_log_entries" (
    "instance_id" "uuid",
    "id" "uuid" NOT NULL,
    "payload" json,
    "created_at" timestamp with time zone,
    "ip_address" character varying(64) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE "auth"."audit_log_entries" OWNER TO "supabase_auth_admin";

--
-- Name: TABLE "audit_log_entries"; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE "auth"."audit_log_entries" IS 'Auth: Audit trail for user actions.';


--
-- Name: flow_state; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE IF NOT EXISTS "auth"."flow_state" (
    "id" "uuid" NOT NULL,
    "user_id" "uuid",
    "auth_code" "text" NOT NULL,
    "code_challenge_method" "auth"."code_challenge_method" NOT NULL,
    "code_challenge" "text" NOT NULL,
    "provider_type" "text" NOT NULL,
    "provider_access_token" "text",
    "provider_refresh_token" "text",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "authentication_method" "text" NOT NULL,
    "auth_code_issued_at" timestamp with time zone
);


ALTER TABLE "auth"."flow_state" OWNER TO "supabase_auth_admin";

--
-- Name: TABLE "flow_state"; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE "auth"."flow_state" IS 'stores metadata for pkce logins';


--
-- Name: identities; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE IF NOT EXISTS "auth"."identities" (
    "provider_id" "text" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "identity_data" "jsonb" NOT NULL,
    "provider" "text" NOT NULL,
    "last_sign_in_at" timestamp with time zone,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "email" "text" GENERATED ALWAYS AS ("lower"(("identity_data" ->> 'email'::"text"))) STORED,
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL
);


ALTER TABLE "auth"."identities" OWNER TO "supabase_auth_admin";

--
-- Name: TABLE "identities"; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE "auth"."identities" IS 'Auth: Stores identities associated to a user.';


--
-- Name: COLUMN "identities"."email"; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN "auth"."identities"."email" IS 'Auth: Email is a generated column that references the optional email property in the identity_data';


--
-- Name: instances; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE IF NOT EXISTS "auth"."instances" (
    "id" "uuid" NOT NULL,
    "uuid" "uuid",
    "raw_base_config" "text",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone
);


ALTER TABLE "auth"."instances" OWNER TO "supabase_auth_admin";

--
-- Name: TABLE "instances"; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE "auth"."instances" IS 'Auth: Manages users across multiple sites.';


--
-- Name: mfa_amr_claims; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE IF NOT EXISTS "auth"."mfa_amr_claims" (
    "session_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone NOT NULL,
    "updated_at" timestamp with time zone NOT NULL,
    "authentication_method" "text" NOT NULL,
    "id" "uuid" NOT NULL
);


ALTER TABLE "auth"."mfa_amr_claims" OWNER TO "supabase_auth_admin";

--
-- Name: TABLE "mfa_amr_claims"; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE "auth"."mfa_amr_claims" IS 'auth: stores authenticator method reference claims for multi factor authentication';


--
-- Name: mfa_challenges; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE IF NOT EXISTS "auth"."mfa_challenges" (
    "id" "uuid" NOT NULL,
    "factor_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone NOT NULL,
    "verified_at" timestamp with time zone,
    "ip_address" "inet" NOT NULL,
    "otp_code" "text",
    "web_authn_session_data" "jsonb"
);


ALTER TABLE "auth"."mfa_challenges" OWNER TO "supabase_auth_admin";

--
-- Name: TABLE "mfa_challenges"; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE "auth"."mfa_challenges" IS 'auth: stores metadata about challenge requests made';


--
-- Name: mfa_factors; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE IF NOT EXISTS "auth"."mfa_factors" (
    "id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "friendly_name" "text",
    "factor_type" "auth"."factor_type" NOT NULL,
    "status" "auth"."factor_status" NOT NULL,
    "created_at" timestamp with time zone NOT NULL,
    "updated_at" timestamp with time zone NOT NULL,
    "secret" "text",
    "phone" "text",
    "last_challenged_at" timestamp with time zone,
    "web_authn_credential" "jsonb",
    "web_authn_aaguid" "uuid"
);


ALTER TABLE "auth"."mfa_factors" OWNER TO "supabase_auth_admin";

--
-- Name: TABLE "mfa_factors"; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE "auth"."mfa_factors" IS 'auth: stores metadata about factors';


--
-- Name: oauth_clients; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE IF NOT EXISTS "auth"."oauth_clients" (
    "id" "uuid" NOT NULL,
    "client_id" "text" NOT NULL,
    "client_secret_hash" "text" NOT NULL,
    "registration_type" "auth"."oauth_registration_type" NOT NULL,
    "redirect_uris" "text" NOT NULL,
    "grant_types" "text" NOT NULL,
    "client_name" "text",
    "client_uri" "text",
    "logo_uri" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "deleted_at" timestamp with time zone,
    CONSTRAINT "oauth_clients_client_name_length" CHECK (("char_length"("client_name") <= 1024)),
    CONSTRAINT "oauth_clients_client_uri_length" CHECK (("char_length"("client_uri") <= 2048)),
    CONSTRAINT "oauth_clients_logo_uri_length" CHECK (("char_length"("logo_uri") <= 2048))
);


ALTER TABLE "auth"."oauth_clients" OWNER TO "supabase_auth_admin";

--
-- Name: one_time_tokens; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE IF NOT EXISTS "auth"."one_time_tokens" (
    "id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "token_type" "auth"."one_time_token_type" NOT NULL,
    "token_hash" "text" NOT NULL,
    "relates_to" "text" NOT NULL,
    "created_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "one_time_tokens_token_hash_check" CHECK (("char_length"("token_hash") > 0))
);


ALTER TABLE "auth"."one_time_tokens" OWNER TO "supabase_auth_admin";

--
-- Name: refresh_tokens; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE IF NOT EXISTS "auth"."refresh_tokens" (
    "instance_id" "uuid",
    "id" bigint NOT NULL,
    "token" character varying(255),
    "user_id" character varying(255),
    "revoked" boolean,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "parent" character varying(255),
    "session_id" "uuid"
);


ALTER TABLE "auth"."refresh_tokens" OWNER TO "supabase_auth_admin";

--
-- Name: TABLE "refresh_tokens"; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE "auth"."refresh_tokens" IS 'Auth: Store of tokens used to refresh JWT tokens once they expire.';


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE; Schema: auth; Owner: supabase_auth_admin
--

CREATE SEQUENCE IF NOT EXISTS "auth"."refresh_tokens_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "auth"."refresh_tokens_id_seq" OWNER TO "supabase_auth_admin";

--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: auth; Owner: supabase_auth_admin
--

ALTER SEQUENCE "auth"."refresh_tokens_id_seq" OWNED BY "auth"."refresh_tokens"."id";


--
-- Name: saml_providers; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE IF NOT EXISTS "auth"."saml_providers" (
    "id" "uuid" NOT NULL,
    "sso_provider_id" "uuid" NOT NULL,
    "entity_id" "text" NOT NULL,
    "metadata_xml" "text" NOT NULL,
    "metadata_url" "text",
    "attribute_mapping" "jsonb",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "name_id_format" "text",
    CONSTRAINT "entity_id not empty" CHECK (("char_length"("entity_id") > 0)),
    CONSTRAINT "metadata_url not empty" CHECK ((("metadata_url" = NULL::"text") OR ("char_length"("metadata_url") > 0))),
    CONSTRAINT "metadata_xml not empty" CHECK (("char_length"("metadata_xml") > 0))
);


ALTER TABLE "auth"."saml_providers" OWNER TO "supabase_auth_admin";

--
-- Name: TABLE "saml_providers"; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE "auth"."saml_providers" IS 'Auth: Manages SAML Identity Provider connections.';


--
-- Name: saml_relay_states; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE IF NOT EXISTS "auth"."saml_relay_states" (
    "id" "uuid" NOT NULL,
    "sso_provider_id" "uuid" NOT NULL,
    "request_id" "text" NOT NULL,
    "for_email" "text",
    "redirect_to" "text",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "flow_state_id" "uuid",
    CONSTRAINT "request_id not empty" CHECK (("char_length"("request_id") > 0))
);


ALTER TABLE "auth"."saml_relay_states" OWNER TO "supabase_auth_admin";

--
-- Name: TABLE "saml_relay_states"; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE "auth"."saml_relay_states" IS 'Auth: Contains SAML Relay State information for each Service Provider initiated login.';


--
-- Name: schema_migrations; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE IF NOT EXISTS "auth"."schema_migrations" (
    "version" character varying(255) NOT NULL
);


ALTER TABLE "auth"."schema_migrations" OWNER TO "supabase_auth_admin";

--
-- Name: TABLE "schema_migrations"; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE "auth"."schema_migrations" IS 'Auth: Manages updates to the auth system.';


--
-- Name: sessions; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE IF NOT EXISTS "auth"."sessions" (
    "id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "factor_id" "uuid",
    "aal" "auth"."aal_level",
    "not_after" timestamp with time zone,
    "refreshed_at" timestamp without time zone,
    "user_agent" "text",
    "ip" "inet",
    "tag" "text"
);


ALTER TABLE "auth"."sessions" OWNER TO "supabase_auth_admin";

--
-- Name: TABLE "sessions"; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE "auth"."sessions" IS 'Auth: Stores session data associated to a user.';


--
-- Name: COLUMN "sessions"."not_after"; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN "auth"."sessions"."not_after" IS 'Auth: Not after is a nullable column that contains a timestamp after which the session should be regarded as expired.';


--
-- Name: sso_domains; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE IF NOT EXISTS "auth"."sso_domains" (
    "id" "uuid" NOT NULL,
    "sso_provider_id" "uuid" NOT NULL,
    "domain" "text" NOT NULL,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    CONSTRAINT "domain not empty" CHECK (("char_length"("domain") > 0))
);


ALTER TABLE "auth"."sso_domains" OWNER TO "supabase_auth_admin";

--
-- Name: TABLE "sso_domains"; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE "auth"."sso_domains" IS 'Auth: Manages SSO email address domain mapping to an SSO Identity Provider.';


--
-- Name: sso_providers; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE IF NOT EXISTS "auth"."sso_providers" (
    "id" "uuid" NOT NULL,
    "resource_id" "text",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "disabled" boolean,
    CONSTRAINT "resource_id not empty" CHECK ((("resource_id" = NULL::"text") OR ("char_length"("resource_id") > 0)))
);


ALTER TABLE "auth"."sso_providers" OWNER TO "supabase_auth_admin";

--
-- Name: TABLE "sso_providers"; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE "auth"."sso_providers" IS 'Auth: Manages SSO identity provider information; see saml_providers for SAML.';


--
-- Name: COLUMN "sso_providers"."resource_id"; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN "auth"."sso_providers"."resource_id" IS 'Auth: Uniquely identifies a SSO provider according to a user-chosen resource ID (case insensitive), useful in infrastructure as code.';


--
-- Name: users; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE IF NOT EXISTS "auth"."users" (
    "instance_id" "uuid",
    "id" "uuid" NOT NULL,
    "aud" character varying(255),
    "role" character varying(255),
    "email" character varying(255),
    "encrypted_password" character varying(255),
    "email_confirmed_at" timestamp with time zone,
    "invited_at" timestamp with time zone,
    "confirmation_token" character varying(255),
    "confirmation_sent_at" timestamp with time zone,
    "recovery_token" character varying(255),
    "recovery_sent_at" timestamp with time zone,
    "email_change_token_new" character varying(255),
    "email_change" character varying(255),
    "email_change_sent_at" timestamp with time zone,
    "last_sign_in_at" timestamp with time zone,
    "raw_app_meta_data" "jsonb",
    "raw_user_meta_data" "jsonb",
    "is_super_admin" boolean,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "phone" "text" DEFAULT NULL::character varying,
    "phone_confirmed_at" timestamp with time zone,
    "phone_change" "text" DEFAULT ''::character varying,
    "phone_change_token" character varying(255) DEFAULT ''::character varying,
    "phone_change_sent_at" timestamp with time zone,
    "confirmed_at" timestamp with time zone GENERATED ALWAYS AS (LEAST("email_confirmed_at", "phone_confirmed_at")) STORED,
    "email_change_token_current" character varying(255) DEFAULT ''::character varying,
    "email_change_confirm_status" smallint DEFAULT 0,
    "banned_until" timestamp with time zone,
    "reauthentication_token" character varying(255) DEFAULT ''::character varying,
    "reauthentication_sent_at" timestamp with time zone,
    "is_sso_user" boolean DEFAULT false NOT NULL,
    "deleted_at" timestamp with time zone,
    "is_anonymous" boolean DEFAULT false NOT NULL,
    CONSTRAINT "users_email_change_confirm_status_check" CHECK ((("email_change_confirm_status" >= 0) AND ("email_change_confirm_status" <= 2)))
);


ALTER TABLE "auth"."users" OWNER TO "supabase_auth_admin";

--
-- Name: TABLE "users"; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE "auth"."users" IS 'Auth: Stores user login data within a secure schema.';


--
-- Name: COLUMN "users"."is_sso_user"; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN "auth"."users"."is_sso_user" IS 'Auth: Set this column to true when the account comes from SSO. These accounts can have duplicate emails.';


--
-- Name: attribute_relationships; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."attribute_relationships" (
    "parent_attribute_id" "uuid" NOT NULL,
    "child_attribute_id" "uuid" NOT NULL
);


ALTER TABLE "public"."attribute_relationships" OWNER TO "postgres";

--
-- Name: TABLE "attribute_relationships"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."attribute_relationships" IS 'Hierarchical relationships between attributes (games, leagues, currencies)';


--
-- Name: COLUMN "attribute_relationships"."parent_attribute_id"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."attribute_relationships"."parent_attribute_id" IS 'Parent attribute (e.g., Game)';


--
-- Name: COLUMN "attribute_relationships"."child_attribute_id"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."attribute_relationships"."child_attribute_id" IS 'Child attribute (e.g., League or Currency)';


--
-- Name: attributes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."attributes" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "code" "text" NOT NULL,
    "name" "text" NOT NULL,
    "type" "text" NOT NULL,
    "is_active" boolean DEFAULT true NOT NULL,
    "sort_order" integer DEFAULT 0 NOT NULL,
    "description" "text"
);


ALTER TABLE "public"."attributes" OWNER TO "postgres";

--
-- Name: TABLE "attributes"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."attributes" IS 'Master attributes table for games, leagues, currencies and business areas';


--
-- Name: COLUMN "attributes"."type"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."attributes"."type" IS 'Type classification following convention [TYPE]_[GAME]: GAME, LEAGUE_POE1, LEAGUE_POE2, SEASON_D4, CURRENCY_POE1, CURRENCY_POE2, CURRENCY_D4, BUSINESS_AREA, ROLE';


--
-- Name: COLUMN "attributes"."is_active"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."attributes"."is_active" IS 'Whether this attribute is currently active and selectable';


--
-- Name: COLUMN "attributes"."sort_order"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."attributes"."sort_order" IS 'Display order for UI elements';


--
-- Name: COLUMN "attributes"."description"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."attributes"."description" IS 'Optional description for the attribute';


--
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: postgres
--

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

--
-- Name: TABLE "audit_logs"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."audit_logs" IS 'all logs';


--
-- Name: channels; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."channels" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "code" "text" NOT NULL,
    "trading_fee_chain_id" "uuid",
    "name" "text" DEFAULT ''::"text" NOT NULL,
    "description" "text",
    "channel_type" "text" DEFAULT 'SALES'::"text",
    "is_active" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "check_channel_type" CHECK (("channel_type" = ANY (ARRAY['DIRECT'::"text", 'MARKETPLACE'::"text", 'SOCIAL'::"text", 'SALES'::"text", 'PURCHASE'::"text"])))
);


ALTER TABLE "public"."channels" OWNER TO "postgres";

--
-- Name: TABLE "channels"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."channels" IS 'Sales and purchase channels for currency transactions';


--
-- Name: COLUMN "channels"."code"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."channels"."code" IS 'Unique channel identifier code';


--
-- Name: COLUMN "channels"."trading_fee_chain_id"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."channels"."trading_fee_chain_id" IS 'Associated fee chain for this channel (linked in previous migration)';


--
-- Name: COLUMN "channels"."name"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."channels"."name" IS 'Display name of the channel';


--
-- Name: COLUMN "channels"."description"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."channels"."description" IS 'Description of what this channel is used for';


--
-- Name: COLUMN "channels"."channel_type"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."channels"."channel_type" IS 'Type of channel: DIRECT, MARKETPLACE, SOCIAL, SALES, or PURCHASE';


--
-- Name: COLUMN "channels"."is_active"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."channels"."is_active" IS 'Whether this channel is still active for transactions';


--
-- Name: currencies; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."currencies" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "code" "text" NOT NULL,
    "name" "text"
);


ALTER TABLE "public"."currencies" OWNER TO "postgres";

--
-- Name: currency_inventory; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."currency_inventory" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "game_account_id" "uuid" NOT NULL,
    "currency_attribute_id" "uuid" NOT NULL,
    "quantity" numeric DEFAULT 0 NOT NULL,
    "reserved_quantity" numeric DEFAULT 0 NOT NULL,
    "avg_buy_price_vnd" numeric DEFAULT 0 NOT NULL,
    "avg_buy_price_usd" numeric DEFAULT 0 NOT NULL,
    "last_updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "currency_inventory_avg_buy_price_usd_check" CHECK (("avg_buy_price_usd" >= (0)::numeric)),
    CONSTRAINT "currency_inventory_avg_buy_price_vnd_check" CHECK (("avg_buy_price_vnd" >= (0)::numeric)),
    CONSTRAINT "currency_inventory_quantity_check" CHECK (("quantity" >= (0)::numeric)),
    CONSTRAINT "currency_inventory_reserved_quantity_check" CHECK (("reserved_quantity" >= (0)::numeric))
);


ALTER TABLE "public"."currency_inventory" OWNER TO "postgres";

--
-- Name: TABLE "currency_inventory"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."currency_inventory" IS 'Tồn kho hiện tại của các loại currency theo từng tài khoản game';


--
-- Name: COLUMN "currency_inventory"."quantity"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."currency_inventory"."quantity" IS 'Số lượng hiện có trong kho';


--
-- Name: COLUMN "currency_inventory"."reserved_quantity"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."currency_inventory"."reserved_quantity" IS 'Số lượng đã được reserve cho đơn hàng';


--
-- Name: COLUMN "currency_inventory"."avg_buy_price_vnd"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."currency_inventory"."avg_buy_price_vnd" IS 'Giá vốn trung bình theo VND';


--
-- Name: COLUMN "currency_inventory"."avg_buy_price_usd"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."currency_inventory"."avg_buy_price_usd" IS 'Giá vốn trung bình theo USD';


--
-- Name: currency_transactions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."currency_transactions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "game_account_id" "uuid" NOT NULL,
    "game_code" "public"."game_code" NOT NULL,
    "league_attribute_id" "uuid" NOT NULL,
    "transaction_type" "public"."currency_transaction_type" NOT NULL,
    "currency_attribute_id" "uuid" NOT NULL,
    "quantity" numeric NOT NULL,
    "unit_price_vnd" numeric NOT NULL,
    "unit_price_usd" numeric NOT NULL,
    "exchange_rate_vnd_per_usd" numeric,
    "order_line_id" "uuid",
    "partner_id" "uuid",
    "farmer_profile_id" "uuid",
    "proof_urls" "text"[],
    "notes" "text",
    "created_by" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "currency_transactions_exchange_rate_vnd_per_usd_check" CHECK (("exchange_rate_vnd_per_usd" > (0)::numeric)),
    CONSTRAINT "currency_transactions_unit_price_usd_check" CHECK (("unit_price_usd" >= (0)::numeric)),
    CONSTRAINT "currency_transactions_unit_price_vnd_check" CHECK (("unit_price_vnd" >= (0)::numeric))
);


ALTER TABLE "public"."currency_transactions" OWNER TO "postgres";

--
-- Name: TABLE "currency_transactions"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."currency_transactions" IS 'Sổ cái ghi lại mọi giao dịch làm thay đổi tồn kho currency';


--
-- Name: COLUMN "currency_transactions"."transaction_type"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."currency_transactions"."transaction_type" IS 'Loại giao dịch (purchase, sale_delivery, farm_in, etc.)';


--
-- Name: COLUMN "currency_transactions"."quantity"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."currency_transactions"."quantity" IS 'Số lượng giao dịch (dương cho vào, âm cho ra)';


--
-- Name: COLUMN "currency_transactions"."exchange_rate_vnd_per_usd"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."currency_transactions"."exchange_rate_vnd_per_usd" IS 'Tỷ giá VND/USD tại thời điểm giao dịch';


--
-- Name: COLUMN "currency_transactions"."proof_urls"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."currency_transactions"."proof_urls" IS 'URLs của bằng chứng giao dịch (screenshots, etc.)';


--
-- Name: customer_accounts; Type: TABLE; Schema: public; Owner: postgres
--

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

--
-- Name: debug_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."debug_log" (
    "id" integer NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "message" "text"
);


ALTER TABLE "public"."debug_log" OWNER TO "postgres";

--
-- Name: debug_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE IF NOT EXISTS "public"."debug_log_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."debug_log_id_seq" OWNER TO "postgres";

--
-- Name: debug_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "public"."debug_log_id_seq" OWNED BY "public"."debug_log"."id";


--
-- Name: exchange_rates; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."exchange_rates" (
    "source_currency" "text" NOT NULL,
    "target_currency" "text" NOT NULL,
    "rate" numeric NOT NULL,
    "last_updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "exchange_rates_rate_check" CHECK (("rate" > (0)::numeric))
);


ALTER TABLE "public"."exchange_rates" OWNER TO "postgres";

--
-- Name: TABLE "exchange_rates"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."exchange_rates" IS 'Lưu trữ tỷ giá thị trường được cập nhật tự động hoặc thủ công';


--
-- Name: COLUMN "exchange_rates"."rate"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."exchange_rates"."rate" IS 'Tỷ giá chuyển đổi: 1 source_currency = rate target_currency';


--
-- Name: game_accounts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."game_accounts" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "game_code" "public"."game_code" NOT NULL,
    "league_attribute_id" "uuid" NOT NULL,
    "account_name" "text" NOT NULL,
    "purpose" "public"."game_account_purpose" DEFAULT 'INVENTORY'::"public"."game_account_purpose" NOT NULL,
    "manager_profile_id" "uuid",
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."game_accounts" OWNER TO "postgres";

--
-- Name: TABLE "game_accounts"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."game_accounts" IS 'Quản lý tập trung các tài khoản game theo từng game, mùa giải và mục đích sử dụng';


--
-- Name: COLUMN "game_accounts"."game_code"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."game_accounts"."game_code" IS 'Mã game (POE1, POE2, D4)';


--
-- Name: COLUMN "game_accounts"."league_attribute_id"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."game_accounts"."league_attribute_id" IS 'League/season thuộc game';


--
-- Name: COLUMN "game_accounts"."account_name"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."game_accounts"."account_name" IS 'Tên tài khoản trong game';


--
-- Name: COLUMN "game_accounts"."purpose"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."game_accounts"."purpose" IS 'Mục đích: FARM (farm currency), INVENTORY (lưu trữ), TRADE (giao dịch)';


--
-- Name: COLUMN "game_accounts"."manager_profile_id"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."game_accounts"."manager_profile_id" IS 'Người quản lý tài khoản này';


--
-- Name: level_exp; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."level_exp" (
    "level" integer NOT NULL,
    "cumulative_exp" bigint NOT NULL
);

ALTER TABLE ONLY "public"."level_exp" FORCE ROW LEVEL SECURITY;


ALTER TABLE "public"."level_exp" OWNER TO "postgres";

--
-- Name: order_lines; Type: TABLE; Schema: public; Owner: postgres
--

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
    "machine_info" "text",
    "pilot_warning_level" integer DEFAULT 0,
    "pilot_is_blocked" boolean DEFAULT false,
    "pilot_cycle_start_at" timestamp with time zone,
    CONSTRAINT "order_lines_pilot_warning_level_check" CHECK (("pilot_warning_level" = ANY (ARRAY[0, 1, 2])))
);


ALTER TABLE "public"."order_lines" OWNER TO "postgres";

--
-- Name: COLUMN "order_lines"."machine_info"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."order_lines"."machine_info" IS 'Thông tin máy tính đang thực hiện đơn hàng Pilot (ví dụ: Máy 35).';


--
-- Name: COLUMN "order_lines"."pilot_warning_level"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."order_lines"."pilot_warning_level" IS 'Mức cảnh báo chu kỳ online pilot: 0=none, 1=warning (5 ngày), 2=blocked (6 ngày). Chỉ áp dụng cho pilot orders đang hoạt động';


--
-- Name: COLUMN "order_lines"."pilot_is_blocked"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."order_lines"."pilot_is_blocked" IS 'Khóa gán đơn hàng mới khi = TRUE (>= 6 ngày online). Chỉ áp dụng cho pilot orders đang hoạt động';


--
-- Name: COLUMN "order_lines"."pilot_cycle_start_at"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."order_lines"."pilot_cycle_start_at" IS 'Thời gian bắt đầu chu kỳ online hiện tại. Reset khi đủ điều kiện nghỉ. Đã fix từ created_at của orders.';


--
-- Name: order_reviews; Type: TABLE; Schema: public; Owner: postgres
--

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

--
-- Name: order_service_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."order_service_items" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "order_line_id" "uuid" NOT NULL,
    "params" "jsonb",
    "plan_qty" numeric DEFAULT 0,
    "service_kind_id" "uuid" NOT NULL,
    "done_qty" numeric DEFAULT 0 NOT NULL
);


ALTER TABLE "public"."order_service_items" OWNER TO "postgres";

--
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

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

--
-- Name: parties; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."parties" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "type" "text" NOT NULL,
    "name" "text" NOT NULL,
    "contact_info" "jsonb" DEFAULT '{}'::"jsonb",
    "is_active" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "check_party_type" CHECK (("type" = ANY (ARRAY['CUSTOMER'::"text", 'SELLER'::"text", 'PARTNER'::"text", 'SUPPLIER'::"text"])))
);


ALTER TABLE "public"."parties" OWNER TO "postgres";

--
-- Name: TABLE "parties"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."parties" IS 'Parties involved in transactions (customers, sellers, partners, suppliers)';


--
-- Name: COLUMN "parties"."type"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."parties"."type" IS 'Type of party: CUSTOMER, SELLER, PARTNER, or SUPPLIER';


--
-- Name: COLUMN "parties"."name"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."parties"."name" IS 'Display name of the party';


--
-- Name: COLUMN "parties"."contact_info"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."parties"."contact_info" IS 'JSONB containing contact information, notes, and metadata';


--
-- Name: COLUMN "parties"."is_active"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."parties"."is_active" IS 'Whether this party is still active for transactions';


--
-- Name: COLUMN "parties"."created_at"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."parties"."created_at" IS 'When this party was first added';


--
-- Name: COLUMN "parties"."updated_at"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."parties"."updated_at" IS 'When this party was last updated';


--
-- Name: permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."permissions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "code" "text" NOT NULL,
    "description" "text",
    "group" "text" DEFAULT 'General'::"text" NOT NULL,
    "description_vi" "text"
);


ALTER TABLE "public"."permissions" OWNER TO "postgres";

--
-- Name: product_variant_attributes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."product_variant_attributes" (
    "variant_id" "uuid" NOT NULL,
    "attribute_id" "uuid" NOT NULL
);


ALTER TABLE "public"."product_variant_attributes" OWNER TO "postgres";

--
-- Name: product_variants; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."product_variants" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "product_id" "uuid" NOT NULL,
    "display_name" "text" NOT NULL,
    "price" numeric DEFAULT 0 NOT NULL,
    "is_active" boolean DEFAULT true NOT NULL
);


ALTER TABLE "public"."product_variants" OWNER TO "postgres";

--
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."products" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "type" "public"."product_type_enum" NOT NULL
);


ALTER TABLE "public"."products" OWNER TO "postgres";

--
-- Name: profiles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."profiles" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "display_name" "text",
    "status" "text" DEFAULT 'active'::"text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "auth_id" "uuid" NOT NULL
);

ALTER TABLE ONLY "public"."profiles" FORCE ROW LEVEL SECURITY;


ALTER TABLE "public"."profiles" OWNER TO "postgres";

--
-- Name: COLUMN "profiles"."auth_id"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."profiles"."auth_id" IS 'Foreign key to auth.users.id';


--
-- Name: role_permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."role_permissions" (
    "role_id" "uuid" NOT NULL,
    "permission_id" "uuid" NOT NULL
);


ALTER TABLE "public"."role_permissions" OWNER TO "postgres";

--
-- Name: roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."roles" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "code" "public"."app_role" NOT NULL,
    "name" "text" NOT NULL,
    "is_active" boolean DEFAULT true NOT NULL,
    "description" "text",
    "sort_order" integer DEFAULT 0 NOT NULL
);


ALTER TABLE "public"."roles" OWNER TO "postgres";

--
-- Name: TABLE "roles"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."roles" IS 'User roles with app_role enum type';


--
-- Name: COLUMN "roles"."is_active"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."roles"."is_active" IS 'Whether this role is active and available for use';


--
-- Name: COLUMN "roles"."description"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."roles"."description" IS 'Optional description for the role';


--
-- Name: COLUMN "roles"."sort_order"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."roles"."sort_order" IS 'Display order for roles (lower numbers appear first)';


--
-- Name: service_reports; Type: TABLE; Schema: public; Owner: postgres
--

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

--
-- Name: TABLE "service_reports"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."service_reports" IS 'Báo cáo các service sai lệch';


--
-- Name: system_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."system_logs" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "action" "text" NOT NULL,
    "status" "text" NOT NULL,
    "details" "jsonb",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid"
);


ALTER TABLE "public"."system_logs" OWNER TO "postgres";

--
-- Name: TABLE "system_logs"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."system_logs" IS 'System operation logs for debugging and auditing';


--
-- Name: COLUMN "system_logs"."action"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."system_logs"."action" IS 'Type of action performed';


--
-- Name: COLUMN "system_logs"."status"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."system_logs"."status" IS 'Status of the action (success, error, etc.)';


--
-- Name: COLUMN "system_logs"."details"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."system_logs"."details" IS 'Additional details in JSON format';


--
-- Name: trading_fee_chains; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."trading_fee_chains" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "description" "text",
    "chain_steps" "jsonb" NOT NULL,
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."trading_fee_chains" OWNER TO "postgres";

--
-- Name: TABLE "trading_fee_chains"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."trading_fee_chains" IS 'Định nghĩa chuỗi phí theo quy trình thực tế (VD: Facebook -> G2G -> Payoneer -> VND)';


--
-- Name: COLUMN "trading_fee_chains"."chain_steps"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."trading_fee_chains"."chain_steps" IS 'JSON array chứa các bước tính phí, mỗi bước bao gồm thông tin chuyển đổi currency và phí';


--
-- Name: user_role_assignments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS "public"."user_role_assignments" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "role_id" "uuid" NOT NULL,
    "game_attribute_id" "uuid",
    "business_area_attribute_id" "uuid"
);


ALTER TABLE "public"."user_role_assignments" OWNER TO "postgres";

--
-- Name: TABLE "user_role_assignments"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."user_role_assignments" IS 'User to role assignments with optional game/business area restrictions';


--
-- Name: work_session_outputs; Type: TABLE; Schema: public; Owner: postgres
--

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

--
-- Name: work_sessions; Type: TABLE; Schema: public; Owner: postgres
--

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

--
-- Name: COLUMN "work_sessions"."overrun_type"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."work_sessions"."overrun_type" IS 'Loại lý do vượt chỉ tiêu (OBJECTIVE | KPI_FAIL)';


--
-- Name: COLUMN "work_sessions"."overrun_proof_urls"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."work_sessions"."overrun_proof_urls" IS 'Danh sách URL bằng chứng khi vượt chỉ tiêu.';


--
-- Name: messages; Type: TABLE; Schema: realtime; Owner: supabase_realtime_admin
--

CREATE TABLE IF NOT EXISTS "realtime"."messages" (
    "topic" "text" NOT NULL,
    "extension" "text" NOT NULL,
    "payload" "jsonb",
    "event" "text",
    "private" boolean DEFAULT false,
    "updated_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "inserted_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL
)
PARTITION BY RANGE ("inserted_at");


ALTER TABLE "realtime"."messages" OWNER TO "supabase_realtime_admin";

--
-- Name: messages_2025_10_07; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE IF NOT EXISTS "realtime"."messages_2025_10_07" (
    "topic" "text" NOT NULL,
    "extension" "text" NOT NULL,
    "payload" "jsonb",
    "event" "text",
    "private" boolean DEFAULT false,
    "updated_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "inserted_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL
);


ALTER TABLE "realtime"."messages_2025_10_07" OWNER TO "supabase_admin";

--
-- Name: messages_2025_10_08; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE IF NOT EXISTS "realtime"."messages_2025_10_08" (
    "topic" "text" NOT NULL,
    "extension" "text" NOT NULL,
    "payload" "jsonb",
    "event" "text",
    "private" boolean DEFAULT false,
    "updated_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "inserted_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL
);


ALTER TABLE "realtime"."messages_2025_10_08" OWNER TO "supabase_admin";

--
-- Name: messages_2025_10_09; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE IF NOT EXISTS "realtime"."messages_2025_10_09" (
    "topic" "text" NOT NULL,
    "extension" "text" NOT NULL,
    "payload" "jsonb",
    "event" "text",
    "private" boolean DEFAULT false,
    "updated_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "inserted_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL
);


ALTER TABLE "realtime"."messages_2025_10_09" OWNER TO "supabase_admin";

--
-- Name: messages_2025_10_10; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE IF NOT EXISTS "realtime"."messages_2025_10_10" (
    "topic" "text" NOT NULL,
    "extension" "text" NOT NULL,
    "payload" "jsonb",
    "event" "text",
    "private" boolean DEFAULT false,
    "updated_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "inserted_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL
);


ALTER TABLE "realtime"."messages_2025_10_10" OWNER TO "supabase_admin";

--
-- Name: messages_2025_10_11; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE IF NOT EXISTS "realtime"."messages_2025_10_11" (
    "topic" "text" NOT NULL,
    "extension" "text" NOT NULL,
    "payload" "jsonb",
    "event" "text",
    "private" boolean DEFAULT false,
    "updated_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "inserted_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL
);


ALTER TABLE "realtime"."messages_2025_10_11" OWNER TO "supabase_admin";

--
-- Name: messages_2025_10_12; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE IF NOT EXISTS "realtime"."messages_2025_10_12" (
    "topic" "text" NOT NULL,
    "extension" "text" NOT NULL,
    "payload" "jsonb",
    "event" "text",
    "private" boolean DEFAULT false,
    "updated_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "inserted_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL
);


ALTER TABLE "realtime"."messages_2025_10_12" OWNER TO "supabase_admin";

--
-- Name: messages_2025_10_13; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE IF NOT EXISTS "realtime"."messages_2025_10_13" (
    "topic" "text" NOT NULL,
    "extension" "text" NOT NULL,
    "payload" "jsonb",
    "event" "text",
    "private" boolean DEFAULT false,
    "updated_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "inserted_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL
);


ALTER TABLE "realtime"."messages_2025_10_13" OWNER TO "supabase_admin";

--
-- Name: schema_migrations; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE IF NOT EXISTS "realtime"."schema_migrations" (
    "version" bigint NOT NULL,
    "inserted_at" timestamp(0) without time zone
);


ALTER TABLE "realtime"."schema_migrations" OWNER TO "supabase_admin";

--
-- Name: subscription; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE IF NOT EXISTS "realtime"."subscription" (
    "id" bigint NOT NULL,
    "subscription_id" "uuid" NOT NULL,
    "entity" "regclass" NOT NULL,
    "filters" "realtime"."user_defined_filter"[] DEFAULT '{}'::"realtime"."user_defined_filter"[] NOT NULL,
    "claims" "jsonb" NOT NULL,
    "claims_role" "regrole" GENERATED ALWAYS AS ("realtime"."to_regrole"(("claims" ->> 'role'::"text"))) STORED NOT NULL,
    "created_at" timestamp without time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL
);


ALTER TABLE "realtime"."subscription" OWNER TO "supabase_admin";

--
-- Name: subscription_id_seq; Type: SEQUENCE; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE "realtime"."subscription" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "realtime"."subscription_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: buckets; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE IF NOT EXISTS "storage"."buckets" (
    "id" "text" NOT NULL,
    "name" "text" NOT NULL,
    "owner" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "public" boolean DEFAULT false,
    "avif_autodetection" boolean DEFAULT false,
    "file_size_limit" bigint,
    "allowed_mime_types" "text"[],
    "owner_id" "text",
    "type" "storage"."buckettype" DEFAULT 'STANDARD'::"storage"."buckettype" NOT NULL
);


ALTER TABLE "storage"."buckets" OWNER TO "supabase_storage_admin";

--
-- Name: COLUMN "buckets"."owner"; Type: COMMENT; Schema: storage; Owner: supabase_storage_admin
--

COMMENT ON COLUMN "storage"."buckets"."owner" IS 'Field is deprecated, use owner_id instead';


--
-- Name: buckets_analytics; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE IF NOT EXISTS "storage"."buckets_analytics" (
    "id" "text" NOT NULL,
    "type" "storage"."buckettype" DEFAULT 'ANALYTICS'::"storage"."buckettype" NOT NULL,
    "format" "text" DEFAULT 'ICEBERG'::"text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "storage"."buckets_analytics" OWNER TO "supabase_storage_admin";

--
-- Name: migrations; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE IF NOT EXISTS "storage"."migrations" (
    "id" integer NOT NULL,
    "name" character varying(100) NOT NULL,
    "hash" character varying(40) NOT NULL,
    "executed_at" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "storage"."migrations" OWNER TO "supabase_storage_admin";

--
-- Name: objects; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE IF NOT EXISTS "storage"."objects" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "bucket_id" "text",
    "name" "text",
    "owner" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "last_accessed_at" timestamp with time zone DEFAULT "now"(),
    "metadata" "jsonb",
    "path_tokens" "text"[] GENERATED ALWAYS AS ("string_to_array"("name", '/'::"text")) STORED,
    "version" "text",
    "owner_id" "text",
    "user_metadata" "jsonb",
    "level" integer
);


ALTER TABLE "storage"."objects" OWNER TO "supabase_storage_admin";

--
-- Name: COLUMN "objects"."owner"; Type: COMMENT; Schema: storage; Owner: supabase_storage_admin
--

COMMENT ON COLUMN "storage"."objects"."owner" IS 'Field is deprecated, use owner_id instead';


--
-- Name: prefixes; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE IF NOT EXISTS "storage"."prefixes" (
    "bucket_id" "text" NOT NULL,
    "name" "text" NOT NULL COLLATE "pg_catalog"."C",
    "level" integer GENERATED ALWAYS AS ("storage"."get_level"("name")) STORED NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "storage"."prefixes" OWNER TO "supabase_storage_admin";

--
-- Name: s3_multipart_uploads; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE IF NOT EXISTS "storage"."s3_multipart_uploads" (
    "id" "text" NOT NULL,
    "in_progress_size" bigint DEFAULT 0 NOT NULL,
    "upload_signature" "text" NOT NULL,
    "bucket_id" "text" NOT NULL,
    "key" "text" NOT NULL COLLATE "pg_catalog"."C",
    "version" "text" NOT NULL,
    "owner_id" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "user_metadata" "jsonb"
);


ALTER TABLE "storage"."s3_multipart_uploads" OWNER TO "supabase_storage_admin";

--
-- Name: s3_multipart_uploads_parts; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE IF NOT EXISTS "storage"."s3_multipart_uploads_parts" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "upload_id" "text" NOT NULL,
    "size" bigint DEFAULT 0 NOT NULL,
    "part_number" integer NOT NULL,
    "bucket_id" "text" NOT NULL,
    "key" "text" NOT NULL COLLATE "pg_catalog"."C",
    "etag" "text" NOT NULL,
    "owner_id" "text",
    "version" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "storage"."s3_multipart_uploads_parts" OWNER TO "supabase_storage_admin";

--
-- Name: messages_2025_10_07; Type: TABLE ATTACH; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY "realtime"."messages" ATTACH PARTITION "realtime"."messages_2025_10_07" FOR VALUES FROM ('2025-10-07 00:00:00') TO ('2025-10-08 00:00:00');


--
-- Name: messages_2025_10_08; Type: TABLE ATTACH; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY "realtime"."messages" ATTACH PARTITION "realtime"."messages_2025_10_08" FOR VALUES FROM ('2025-10-08 00:00:00') TO ('2025-10-09 00:00:00');


--
-- Name: messages_2025_10_09; Type: TABLE ATTACH; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY "realtime"."messages" ATTACH PARTITION "realtime"."messages_2025_10_09" FOR VALUES FROM ('2025-10-09 00:00:00') TO ('2025-10-10 00:00:00');


--
-- Name: messages_2025_10_10; Type: TABLE ATTACH; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY "realtime"."messages" ATTACH PARTITION "realtime"."messages_2025_10_10" FOR VALUES FROM ('2025-10-10 00:00:00') TO ('2025-10-11 00:00:00');


--
-- Name: messages_2025_10_11; Type: TABLE ATTACH; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY "realtime"."messages" ATTACH PARTITION "realtime"."messages_2025_10_11" FOR VALUES FROM ('2025-10-11 00:00:00') TO ('2025-10-12 00:00:00');


--
-- Name: messages_2025_10_12; Type: TABLE ATTACH; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY "realtime"."messages" ATTACH PARTITION "realtime"."messages_2025_10_12" FOR VALUES FROM ('2025-10-12 00:00:00') TO ('2025-10-13 00:00:00');


--
-- Name: messages_2025_10_13; Type: TABLE ATTACH; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY "realtime"."messages" ATTACH PARTITION "realtime"."messages_2025_10_13" FOR VALUES FROM ('2025-10-13 00:00:00') TO ('2025-10-14 00:00:00');


--
-- Name: refresh_tokens id; Type: DEFAULT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY "auth"."refresh_tokens" ALTER COLUMN "id" SET DEFAULT "nextval"('"auth"."refresh_tokens_id_seq"'::"regclass");


--
-- Name: debug_log id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."debug_log" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."debug_log_id_seq"'::"regclass");


--
-- Name: mfa_amr_claims amr_id_pk; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY "auth"."mfa_amr_claims"
    ADD CONSTRAINT "amr_id_pk" PRIMARY KEY ("id");


--
-- Name: audit_log_entries audit_log_entries_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY "auth"."audit_log_entries"
    ADD CONSTRAINT "audit_log_entries_pkey" PRIMARY KEY ("id");


--
-- Name: flow_state flow_state_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY "auth"."flow_state"
    ADD CONSTRAINT "flow_state_pkey" PRIMARY KEY ("id");


--
-- Name: identities identities_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY "auth"."identities"
    ADD CONSTRAINT "identities_pkey" PRIMARY KEY ("id");


--
-- Name: identities identities_provider_id_provider_unique; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY "auth"."identities"
    ADD CONSTRAINT "identities_provider_id_provider_unique" UNIQUE ("provider_id", "provider");


--
-- Name: instances instances_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY "auth"."instances"
    ADD CONSTRAINT "instances_pkey" PRIMARY KEY ("id");


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_authentication_method_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY "auth"."mfa_amr_claims"
    ADD CONSTRAINT "mfa_amr_claims_session_id_authentication_method_pkey" UNIQUE ("session_id", "authentication_method");


--
-- Name: mfa_challenges mfa_challenges_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY "auth"."mfa_challenges"
    ADD CONSTRAINT "mfa_challenges_pkey" PRIMARY KEY ("id");


--
-- Name: mfa_factors mfa_factors_last_challenged_at_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY "auth"."mfa_factors"
    ADD CONSTRAINT "mfa_factors_last_challenged_at_key" UNIQUE ("last_challenged_at");


--
-- Name: mfa_factors mfa_factors_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY "auth"."mfa_factors"
    ADD CONSTRAINT "mfa_factors_pkey" PRIMARY KEY ("id");


--
-- Name: oauth_clients oauth_clients_client_id_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY "auth"."oauth_clients"
    ADD CONSTRAINT "oauth_clients_client_id_key" UNIQUE ("client_id");


--
-- Name: oauth_clients oauth_clients_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY "auth"."oauth_clients"
    ADD CONSTRAINT "oauth_clients_pkey" PRIMARY KEY ("id");


--
-- Name: one_time_tokens one_time_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY "auth"."one_time_tokens"
    ADD CONSTRAINT "one_time_tokens_pkey" PRIMARY KEY ("id");


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY "auth"."refresh_tokens"
    ADD CONSTRAINT "refresh_tokens_pkey" PRIMARY KEY ("id");


--
-- Name: refresh_tokens refresh_tokens_token_unique; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY "auth"."refresh_tokens"
    ADD CONSTRAINT "refresh_tokens_token_unique" UNIQUE ("token");


--
-- Name: saml_providers saml_providers_entity_id_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY "auth"."saml_providers"
    ADD CONSTRAINT "saml_providers_entity_id_key" UNIQUE ("entity_id");


--
-- Name: saml_providers saml_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY "auth"."saml_providers"
    ADD CONSTRAINT "saml_providers_pkey" PRIMARY KEY ("id");


--
-- Name: saml_relay_states saml_relay_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY "auth"."saml_relay_states"
    ADD CONSTRAINT "saml_relay_states_pkey" PRIMARY KEY ("id");


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY "auth"."schema_migrations"
    ADD CONSTRAINT "schema_migrations_pkey" PRIMARY KEY ("version");


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY "auth"."sessions"
    ADD CONSTRAINT "sessions_pkey" PRIMARY KEY ("id");


--
-- Name: sso_domains sso_domains_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY "auth"."sso_domains"
    ADD CONSTRAINT "sso_domains_pkey" PRIMARY KEY ("id");


--
-- Name: sso_providers sso_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY "auth"."sso_providers"
    ADD CONSTRAINT "sso_providers_pkey" PRIMARY KEY ("id");


--
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY "auth"."users"
    ADD CONSTRAINT "users_phone_key" UNIQUE ("phone");


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY "auth"."users"
    ADD CONSTRAINT "users_pkey" PRIMARY KEY ("id");


--
-- Name: attribute_relationships attribute_relationships_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."attribute_relationships"
    ADD CONSTRAINT "attribute_relationships_pkey" PRIMARY KEY ("parent_attribute_id", "child_attribute_id");


--
-- Name: attributes attributes_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."attributes"
    ADD CONSTRAINT "attributes_code_key" UNIQUE ("code");


--
-- Name: attributes attributes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."attributes"
    ADD CONSTRAINT "attributes_pkey" PRIMARY KEY ("id");


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."audit_logs"
    ADD CONSTRAINT "audit_logs_pkey" PRIMARY KEY ("id");


--
-- Name: channels channels_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."channels"
    ADD CONSTRAINT "channels_code_key" UNIQUE ("code");


--
-- Name: channels channels_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."channels"
    ADD CONSTRAINT "channels_pkey" PRIMARY KEY ("id");


--
-- Name: currencies currencies_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."currencies"
    ADD CONSTRAINT "currencies_code_key" UNIQUE ("code");


--
-- Name: currencies currencies_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."currencies"
    ADD CONSTRAINT "currencies_pkey" PRIMARY KEY ("id");


--
-- Name: currency_inventory currency_inventory_game_account_id_currency_attribute_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."currency_inventory"
    ADD CONSTRAINT "currency_inventory_game_account_id_currency_attribute_id_key" UNIQUE ("game_account_id", "currency_attribute_id");


--
-- Name: currency_inventory currency_inventory_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."currency_inventory"
    ADD CONSTRAINT "currency_inventory_pkey" PRIMARY KEY ("id");


--
-- Name: currency_transactions currency_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."currency_transactions"
    ADD CONSTRAINT "currency_transactions_pkey" PRIMARY KEY ("id");


--
-- Name: customer_accounts customer_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."customer_accounts"
    ADD CONSTRAINT "customer_accounts_pkey" PRIMARY KEY ("id");


--
-- Name: debug_log debug_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."debug_log"
    ADD CONSTRAINT "debug_log_pkey" PRIMARY KEY ("id");


--
-- Name: exchange_rates exchange_rates_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."exchange_rates"
    ADD CONSTRAINT "exchange_rates_pkey" PRIMARY KEY ("source_currency", "target_currency");


--
-- Name: game_accounts game_accounts_game_code_league_attribute_id_account_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."game_accounts"
    ADD CONSTRAINT "game_accounts_game_code_league_attribute_id_account_name_key" UNIQUE ("game_code", "league_attribute_id", "account_name");


--
-- Name: game_accounts game_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."game_accounts"
    ADD CONSTRAINT "game_accounts_pkey" PRIMARY KEY ("id");


--
-- Name: level_exp level_exp_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."level_exp"
    ADD CONSTRAINT "level_exp_pkey" PRIMARY KEY ("level");


--
-- Name: order_lines order_lines_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."order_lines"
    ADD CONSTRAINT "order_lines_pkey" PRIMARY KEY ("id");


--
-- Name: order_reviews order_reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."order_reviews"
    ADD CONSTRAINT "order_reviews_pkey" PRIMARY KEY ("id");


--
-- Name: order_service_items order_service_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."order_service_items"
    ADD CONSTRAINT "order_service_items_pkey" PRIMARY KEY ("id");


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."orders"
    ADD CONSTRAINT "orders_pkey" PRIMARY KEY ("id");


--
-- Name: parties parties_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."parties"
    ADD CONSTRAINT "parties_pkey" PRIMARY KEY ("id");


--
-- Name: parties parties_type_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."parties"
    ADD CONSTRAINT "parties_type_name_key" UNIQUE ("type", "name");


--
-- Name: permissions permissions_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."permissions"
    ADD CONSTRAINT "permissions_code_key" UNIQUE ("code");


--
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."permissions"
    ADD CONSTRAINT "permissions_pkey" PRIMARY KEY ("id");


--
-- Name: product_variant_attributes product_variant_attributes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."product_variant_attributes"
    ADD CONSTRAINT "product_variant_attributes_pkey" PRIMARY KEY ("variant_id", "attribute_id");


--
-- Name: product_variants product_variants_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."product_variants"
    ADD CONSTRAINT "product_variants_pkey" PRIMARY KEY ("id");


--
-- Name: product_variants product_variants_product_id_display_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."product_variants"
    ADD CONSTRAINT "product_variants_product_id_display_name_key" UNIQUE ("product_id", "display_name");


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."products"
    ADD CONSTRAINT "products_pkey" PRIMARY KEY ("id");


--
-- Name: profiles profiles_auth_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_auth_id_key" UNIQUE ("auth_id");


--
-- Name: profiles profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_pkey" PRIMARY KEY ("id");


--
-- Name: role_permissions role_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."role_permissions"
    ADD CONSTRAINT "role_permissions_pkey" PRIMARY KEY ("role_id", "permission_id");


--
-- Name: roles roles_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."roles"
    ADD CONSTRAINT "roles_code_key" UNIQUE ("code");


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."roles"
    ADD CONSTRAINT "roles_pkey" PRIMARY KEY ("id");


--
-- Name: service_reports service_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."service_reports"
    ADD CONSTRAINT "service_reports_pkey" PRIMARY KEY ("id");


--
-- Name: system_logs system_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."system_logs"
    ADD CONSTRAINT "system_logs_pkey" PRIMARY KEY ("id");


--
-- Name: trading_fee_chains trading_fee_chains_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."trading_fee_chains"
    ADD CONSTRAINT "trading_fee_chains_name_key" UNIQUE ("name");


--
-- Name: trading_fee_chains trading_fee_chains_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."trading_fee_chains"
    ADD CONSTRAINT "trading_fee_chains_pkey" PRIMARY KEY ("id");


--
-- Name: user_role_assignments user_role_assignments_pkey1; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."user_role_assignments"
    ADD CONSTRAINT "user_role_assignments_pkey1" PRIMARY KEY ("id");


--
-- Name: user_role_assignments user_role_assignments_user_id_role_id_game_attribute_id_bus_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."user_role_assignments"
    ADD CONSTRAINT "user_role_assignments_user_id_role_id_game_attribute_id_bus_key" UNIQUE ("user_id", "role_id", "game_attribute_id", "business_area_attribute_id");


--
-- Name: work_session_outputs work_session_outputs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."work_session_outputs"
    ADD CONSTRAINT "work_session_outputs_pkey" PRIMARY KEY ("id");


--
-- Name: work_sessions work_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."work_sessions"
    ADD CONSTRAINT "work_sessions_pkey" PRIMARY KEY ("id");


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER TABLE ONLY "realtime"."messages"
    ADD CONSTRAINT "messages_pkey" PRIMARY KEY ("id", "inserted_at");


--
-- Name: messages_2025_10_07 messages_2025_10_07_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY "realtime"."messages_2025_10_07"
    ADD CONSTRAINT "messages_2025_10_07_pkey" PRIMARY KEY ("id", "inserted_at");


--
-- Name: messages_2025_10_08 messages_2025_10_08_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY "realtime"."messages_2025_10_08"
    ADD CONSTRAINT "messages_2025_10_08_pkey" PRIMARY KEY ("id", "inserted_at");


--
-- Name: messages_2025_10_09 messages_2025_10_09_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY "realtime"."messages_2025_10_09"
    ADD CONSTRAINT "messages_2025_10_09_pkey" PRIMARY KEY ("id", "inserted_at");


--
-- Name: messages_2025_10_10 messages_2025_10_10_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY "realtime"."messages_2025_10_10"
    ADD CONSTRAINT "messages_2025_10_10_pkey" PRIMARY KEY ("id", "inserted_at");


--
-- Name: messages_2025_10_11 messages_2025_10_11_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY "realtime"."messages_2025_10_11"
    ADD CONSTRAINT "messages_2025_10_11_pkey" PRIMARY KEY ("id", "inserted_at");


--
-- Name: messages_2025_10_12 messages_2025_10_12_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY "realtime"."messages_2025_10_12"
    ADD CONSTRAINT "messages_2025_10_12_pkey" PRIMARY KEY ("id", "inserted_at");


--
-- Name: messages_2025_10_13 messages_2025_10_13_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY "realtime"."messages_2025_10_13"
    ADD CONSTRAINT "messages_2025_10_13_pkey" PRIMARY KEY ("id", "inserted_at");


--
-- Name: subscription pk_subscription; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY "realtime"."subscription"
    ADD CONSTRAINT "pk_subscription" PRIMARY KEY ("id");


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY "realtime"."schema_migrations"
    ADD CONSTRAINT "schema_migrations_pkey" PRIMARY KEY ("version");


--
-- Name: buckets_analytics buckets_analytics_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY "storage"."buckets_analytics"
    ADD CONSTRAINT "buckets_analytics_pkey" PRIMARY KEY ("id");


--
-- Name: buckets buckets_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY "storage"."buckets"
    ADD CONSTRAINT "buckets_pkey" PRIMARY KEY ("id");


--
-- Name: migrations migrations_name_key; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY "storage"."migrations"
    ADD CONSTRAINT "migrations_name_key" UNIQUE ("name");


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY "storage"."migrations"
    ADD CONSTRAINT "migrations_pkey" PRIMARY KEY ("id");


--
-- Name: objects objects_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY "storage"."objects"
    ADD CONSTRAINT "objects_pkey" PRIMARY KEY ("id");


--
-- Name: prefixes prefixes_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY "storage"."prefixes"
    ADD CONSTRAINT "prefixes_pkey" PRIMARY KEY ("bucket_id", "level", "name");


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY "storage"."s3_multipart_uploads_parts"
    ADD CONSTRAINT "s3_multipart_uploads_parts_pkey" PRIMARY KEY ("id");


--
-- Name: s3_multipart_uploads s3_multipart_uploads_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY "storage"."s3_multipart_uploads"
    ADD CONSTRAINT "s3_multipart_uploads_pkey" PRIMARY KEY ("id");


--
-- Name: audit_logs_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX "audit_logs_instance_id_idx" ON "auth"."audit_log_entries" USING "btree" ("instance_id");


--
-- Name: confirmation_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX "confirmation_token_idx" ON "auth"."users" USING "btree" ("confirmation_token") WHERE (("confirmation_token")::"text" !~ '^[0-9 ]*$'::"text");


--
-- Name: email_change_token_current_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX "email_change_token_current_idx" ON "auth"."users" USING "btree" ("email_change_token_current") WHERE (("email_change_token_current")::"text" !~ '^[0-9 ]*$'::"text");


--
-- Name: email_change_token_new_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX "email_change_token_new_idx" ON "auth"."users" USING "btree" ("email_change_token_new") WHERE (("email_change_token_new")::"text" !~ '^[0-9 ]*$'::"text");


--
-- Name: factor_id_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX "factor_id_created_at_idx" ON "auth"."mfa_factors" USING "btree" ("user_id", "created_at");


--
-- Name: flow_state_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX "flow_state_created_at_idx" ON "auth"."flow_state" USING "btree" ("created_at" DESC);


--
-- Name: identities_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX "identities_email_idx" ON "auth"."identities" USING "btree" ("email" "text_pattern_ops");


--
-- Name: INDEX "identities_email_idx"; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON INDEX "auth"."identities_email_idx" IS 'Auth: Ensures indexed queries on the email column';


--
-- Name: identities_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX "identities_user_id_idx" ON "auth"."identities" USING "btree" ("user_id");


--
-- Name: idx_auth_code; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX "idx_auth_code" ON "auth"."flow_state" USING "btree" ("auth_code");


--
-- Name: idx_user_id_auth_method; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX "idx_user_id_auth_method" ON "auth"."flow_state" USING "btree" ("user_id", "authentication_method");


--
-- Name: mfa_challenge_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX "mfa_challenge_created_at_idx" ON "auth"."mfa_challenges" USING "btree" ("created_at" DESC);


--
-- Name: mfa_factors_user_friendly_name_unique; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX "mfa_factors_user_friendly_name_unique" ON "auth"."mfa_factors" USING "btree" ("friendly_name", "user_id") WHERE (TRIM(BOTH FROM "friendly_name") <> ''::"text");


--
-- Name: mfa_factors_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX "mfa_factors_user_id_idx" ON "auth"."mfa_factors" USING "btree" ("user_id");


--
-- Name: oauth_clients_client_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX "oauth_clients_client_id_idx" ON "auth"."oauth_clients" USING "btree" ("client_id");


--
-- Name: oauth_clients_deleted_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX "oauth_clients_deleted_at_idx" ON "auth"."oauth_clients" USING "btree" ("deleted_at");


--
-- Name: one_time_tokens_relates_to_hash_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX "one_time_tokens_relates_to_hash_idx" ON "auth"."one_time_tokens" USING "hash" ("relates_to");


--
-- Name: one_time_tokens_token_hash_hash_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX "one_time_tokens_token_hash_hash_idx" ON "auth"."one_time_tokens" USING "hash" ("token_hash");


--
-- Name: one_time_tokens_user_id_token_type_key; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX "one_time_tokens_user_id_token_type_key" ON "auth"."one_time_tokens" USING "btree" ("user_id", "token_type");


--
-- Name: reauthentication_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX "reauthentication_token_idx" ON "auth"."users" USING "btree" ("reauthentication_token") WHERE (("reauthentication_token")::"text" !~ '^[0-9 ]*$'::"text");


--
-- Name: recovery_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX "recovery_token_idx" ON "auth"."users" USING "btree" ("recovery_token") WHERE (("recovery_token")::"text" !~ '^[0-9 ]*$'::"text");


--
-- Name: refresh_tokens_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX "refresh_tokens_instance_id_idx" ON "auth"."refresh_tokens" USING "btree" ("instance_id");


--
-- Name: refresh_tokens_instance_id_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX "refresh_tokens_instance_id_user_id_idx" ON "auth"."refresh_tokens" USING "btree" ("instance_id", "user_id");


--
-- Name: refresh_tokens_parent_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX "refresh_tokens_parent_idx" ON "auth"."refresh_tokens" USING "btree" ("parent");


--
-- Name: refresh_tokens_session_id_revoked_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX "refresh_tokens_session_id_revoked_idx" ON "auth"."refresh_tokens" USING "btree" ("session_id", "revoked");


--
-- Name: refresh_tokens_updated_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX "refresh_tokens_updated_at_idx" ON "auth"."refresh_tokens" USING "btree" ("updated_at" DESC);


--
-- Name: saml_providers_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX "saml_providers_sso_provider_id_idx" ON "auth"."saml_providers" USING "btree" ("sso_provider_id");


--
-- Name: saml_relay_states_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX "saml_relay_states_created_at_idx" ON "auth"."saml_relay_states" USING "btree" ("created_at" DESC);


--
-- Name: saml_relay_states_for_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX "saml_relay_states_for_email_idx" ON "auth"."saml_relay_states" USING "btree" ("for_email");


--
-- Name: saml_relay_states_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX "saml_relay_states_sso_provider_id_idx" ON "auth"."saml_relay_states" USING "btree" ("sso_provider_id");


--
-- Name: sessions_not_after_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX "sessions_not_after_idx" ON "auth"."sessions" USING "btree" ("not_after" DESC);


--
-- Name: sessions_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX "sessions_user_id_idx" ON "auth"."sessions" USING "btree" ("user_id");


--
-- Name: sso_domains_domain_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX "sso_domains_domain_idx" ON "auth"."sso_domains" USING "btree" ("lower"("domain"));


--
-- Name: sso_domains_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX "sso_domains_sso_provider_id_idx" ON "auth"."sso_domains" USING "btree" ("sso_provider_id");


--
-- Name: sso_providers_resource_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX "sso_providers_resource_id_idx" ON "auth"."sso_providers" USING "btree" ("lower"("resource_id"));


--
-- Name: sso_providers_resource_id_pattern_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX "sso_providers_resource_id_pattern_idx" ON "auth"."sso_providers" USING "btree" ("resource_id" "text_pattern_ops");


--
-- Name: unique_phone_factor_per_user; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX "unique_phone_factor_per_user" ON "auth"."mfa_factors" USING "btree" ("user_id", "phone");


--
-- Name: user_id_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX "user_id_created_at_idx" ON "auth"."sessions" USING "btree" ("user_id", "created_at");


--
-- Name: users_email_partial_key; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX "users_email_partial_key" ON "auth"."users" USING "btree" ("email") WHERE ("is_sso_user" = false);


--
-- Name: INDEX "users_email_partial_key"; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON INDEX "auth"."users_email_partial_key" IS 'Auth: A partial unique index that applies only when is_sso_user is false';


--
-- Name: users_instance_id_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX "users_instance_id_email_idx" ON "auth"."users" USING "btree" ("instance_id", "lower"(("email")::"text"));


--
-- Name: users_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX "users_instance_id_idx" ON "auth"."users" USING "btree" ("instance_id");


--
-- Name: users_is_anonymous_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX "users_is_anonymous_idx" ON "auth"."users" USING "btree" ("is_anonymous");


--
-- Name: idx_attribute_relationships_child; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_attribute_relationships_child" ON "public"."attribute_relationships" USING "btree" ("child_attribute_id");


--
-- Name: idx_attribute_relationships_parent; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_attribute_relationships_parent" ON "public"."attribute_relationships" USING "btree" ("parent_attribute_id");


--
-- Name: idx_attribute_relationships_parent_child; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_attribute_relationships_parent_child" ON "public"."attribute_relationships" USING "btree" ("parent_attribute_id", "child_attribute_id");


--
-- Name: idx_attributes_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_attributes_active" ON "public"."attributes" USING "btree" ("is_active");


--
-- Name: idx_attributes_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_attributes_code" ON "public"."attributes" USING "btree" ("code");


--
-- Name: idx_attributes_currency_game; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_attributes_currency_game" ON "public"."attributes" USING "btree" ("type", "code") WHERE ("type" ~~ '%CURRENCY%'::"text");


--
-- Name: idx_attributes_game_league; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_attributes_game_league" ON "public"."attributes" USING "btree" ("type", "code") WHERE ("type" ~~ '%LEAGUE%'::"text");


--
-- Name: idx_attributes_is_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_attributes_is_active" ON "public"."attributes" USING "btree" ("is_active");


--
-- Name: idx_attributes_sort_order; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_attributes_sort_order" ON "public"."attributes" USING "btree" ("sort_order");


--
-- Name: idx_attributes_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_attributes_type" ON "public"."attributes" USING "btree" ("type");


--
-- Name: idx_attributes_type_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_attributes_type_code" ON "public"."attributes" USING "btree" ("type", "code");


--
-- Name: idx_attributes_type_standardized; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_attributes_type_standardized" ON "public"."attributes" USING "btree" ("type", "code");


--
-- Name: idx_channels_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_channels_code" ON "public"."channels" USING "btree" ("code");


--
-- Name: idx_channels_fee_chain_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_channels_fee_chain_active" ON "public"."channels" USING "btree" ("trading_fee_chain_id") WHERE ("trading_fee_chain_id" IS NOT NULL);


--
-- Name: idx_channels_is_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_channels_is_active" ON "public"."channels" USING "btree" ("is_active");


--
-- Name: idx_channels_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_channels_name" ON "public"."channels" USING "btree" ("name");


--
-- Name: idx_channels_trading_fee_chain; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_channels_trading_fee_chain" ON "public"."channels" USING "btree" ("trading_fee_chain_id");


--
-- Name: idx_channels_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_channels_type" ON "public"."channels" USING "btree" ("channel_type");


--
-- Name: idx_currency_attributes_new; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_currency_attributes_new" ON "public"."attributes" USING "btree" ("type", "code") WHERE ("type" = ANY (ARRAY['CURRENCY_POE1'::"text", 'CURRENCY_POE2'::"text", 'CURRENCY_D4'::"text"]));


--
-- Name: idx_currency_inventory_account; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_currency_inventory_account" ON "public"."currency_inventory" USING "btree" ("game_account_id");


--
-- Name: idx_currency_inventory_currency; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_currency_inventory_currency" ON "public"."currency_inventory" USING "btree" ("currency_attribute_id");


--
-- Name: idx_currency_inventory_quantity; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_currency_inventory_quantity" ON "public"."currency_inventory" USING "btree" ("quantity") WHERE ("quantity" > (0)::numeric);


--
-- Name: idx_currency_transactions_account; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_currency_transactions_account" ON "public"."currency_transactions" USING "btree" ("game_account_id");


--
-- Name: idx_currency_transactions_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_currency_transactions_created_at" ON "public"."currency_transactions" USING "btree" ("created_at");


--
-- Name: idx_currency_transactions_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_currency_transactions_created_by" ON "public"."currency_transactions" USING "btree" ("created_by");


--
-- Name: idx_currency_transactions_currency; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_currency_transactions_currency" ON "public"."currency_transactions" USING "btree" ("currency_attribute_id");


--
-- Name: idx_currency_transactions_game; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_currency_transactions_game" ON "public"."currency_transactions" USING "btree" ("game_code");


--
-- Name: idx_currency_transactions_league; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_currency_transactions_league" ON "public"."currency_transactions" USING "btree" ("league_attribute_id");


--
-- Name: idx_currency_transactions_order; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_currency_transactions_order" ON "public"."currency_transactions" USING "btree" ("order_line_id");


--
-- Name: idx_currency_transactions_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_currency_transactions_type" ON "public"."currency_transactions" USING "btree" ("transaction_type");


--
-- Name: idx_exchange_rates_updated; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_exchange_rates_updated" ON "public"."exchange_rates" USING "btree" ("last_updated_at");


--
-- Name: idx_game_accounts_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_game_accounts_active" ON "public"."game_accounts" USING "btree" ("is_active");


--
-- Name: idx_game_accounts_game_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_game_accounts_game_code" ON "public"."game_accounts" USING "btree" ("game_code");


--
-- Name: idx_game_accounts_league; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_game_accounts_league" ON "public"."game_accounts" USING "btree" ("league_attribute_id");


--
-- Name: idx_game_accounts_manager; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_game_accounts_manager" ON "public"."game_accounts" USING "btree" ("manager_profile_id");


--
-- Name: idx_game_accounts_purpose; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_game_accounts_purpose" ON "public"."game_accounts" USING "btree" ("purpose");


--
-- Name: idx_league_season_attributes_new; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_league_season_attributes_new" ON "public"."attributes" USING "btree" ("type", "code") WHERE ("type" = ANY (ARRAY['LEAGUE_POE1'::"text", 'LEAGUE_POE2'::"text", 'SEASON_D4'::"text"]));


--
-- Name: idx_parties_is_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_parties_is_active" ON "public"."parties" USING "btree" ("is_active");


--
-- Name: idx_parties_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_parties_name" ON "public"."parties" USING "btree" ("name");


--
-- Name: idx_parties_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_parties_type" ON "public"."parties" USING "btree" ("type");


--
-- Name: idx_roles_is_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_roles_is_active" ON "public"."roles" USING "btree" ("is_active");


--
-- Name: idx_roles_sort_order; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_roles_sort_order" ON "public"."roles" USING "btree" ("sort_order");


--
-- Name: idx_system_logs_action; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_system_logs_action" ON "public"."system_logs" USING "btree" ("action");


--
-- Name: idx_system_logs_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_system_logs_created_at" ON "public"."system_logs" USING "btree" ("created_at");


--
-- Name: idx_system_logs_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_system_logs_status" ON "public"."system_logs" USING "btree" ("status");


--
-- Name: idx_trading_fee_chains_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_trading_fee_chains_active" ON "public"."trading_fee_chains" USING "btree" ("is_active");


--
-- Name: idx_user_role_assignments_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "idx_user_role_assignments_user_id" ON "public"."user_role_assignments" USING "btree" ("user_id");


--
-- Name: ix_attribute_relationships_child; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_attribute_relationships_child" ON "public"."attribute_relationships" USING "btree" ("child_attribute_id");


--
-- Name: ix_attribute_relationships_parent; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_attribute_relationships_parent" ON "public"."attribute_relationships" USING "btree" ("parent_attribute_id");


--
-- Name: ix_customer_accounts_party_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_customer_accounts_party_id" ON "public"."customer_accounts" USING "btree" ("party_id");


--
-- Name: ix_order_lines_customer_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_order_lines_customer_account_id" ON "public"."order_lines" USING "btree" ("customer_account_id");


--
-- Name: ix_order_lines_order_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_order_lines_order_id" ON "public"."order_lines" USING "btree" ("order_id");


--
-- Name: ix_order_lines_variant_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_order_lines_variant_id" ON "public"."order_lines" USING "btree" ("variant_id");


--
-- Name: ix_order_service_items_order_line_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_order_service_items_order_line_id" ON "public"."order_service_items" USING "btree" ("order_line_id");


--
-- Name: ix_order_service_items_service_kind_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_order_service_items_service_kind_id" ON "public"."order_service_items" USING "btree" ("service_kind_id");


--
-- Name: ix_orders_channel_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_orders_channel_id" ON "public"."orders" USING "btree" ("channel_id");


--
-- Name: ix_orders_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_orders_created_by" ON "public"."orders" USING "btree" ("created_by");


--
-- Name: ix_orders_currency_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_orders_currency_id" ON "public"."orders" USING "btree" ("currency_id");


--
-- Name: ix_orders_party_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_orders_party_id" ON "public"."orders" USING "btree" ("party_id");


--
-- Name: ix_product_variant_attributes_attribute_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_product_variant_attributes_attribute_id" ON "public"."product_variant_attributes" USING "btree" ("attribute_id");


--
-- Name: ix_product_variant_attributes_variant_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_product_variant_attributes_variant_id" ON "public"."product_variant_attributes" USING "btree" ("variant_id");


--
-- Name: ix_product_variants_product_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_product_variants_product_id" ON "public"."product_variants" USING "btree" ("product_id");


--
-- Name: ix_work_session_outputs_osid_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_work_session_outputs_osid_id" ON "public"."work_session_outputs" USING "btree" ("order_service_item_id");


--
-- Name: ix_work_session_outputs_work_session_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_work_session_outputs_work_session_id" ON "public"."work_session_outputs" USING "btree" ("work_session_id");


--
-- Name: ix_work_sessions_farmer_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_work_sessions_farmer_id" ON "public"."work_sessions" USING "btree" ("farmer_id");


--
-- Name: ix_work_sessions_order_line_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_work_sessions_order_line_id" ON "public"."work_sessions" USING "btree" ("order_line_id");


--
-- Name: ix_realtime_subscription_entity; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX "ix_realtime_subscription_entity" ON "realtime"."subscription" USING "btree" ("entity");


--
-- Name: messages_inserted_at_topic_index; Type: INDEX; Schema: realtime; Owner: supabase_realtime_admin
--

CREATE INDEX "messages_inserted_at_topic_index" ON ONLY "realtime"."messages" USING "btree" ("inserted_at" DESC, "topic") WHERE (("extension" = 'broadcast'::"text") AND ("private" IS TRUE));


--
-- Name: messages_2025_10_07_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX "messages_2025_10_07_inserted_at_topic_idx" ON "realtime"."messages_2025_10_07" USING "btree" ("inserted_at" DESC, "topic") WHERE (("extension" = 'broadcast'::"text") AND ("private" IS TRUE));


--
-- Name: messages_2025_10_08_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX "messages_2025_10_08_inserted_at_topic_idx" ON "realtime"."messages_2025_10_08" USING "btree" ("inserted_at" DESC, "topic") WHERE (("extension" = 'broadcast'::"text") AND ("private" IS TRUE));


--
-- Name: messages_2025_10_09_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX "messages_2025_10_09_inserted_at_topic_idx" ON "realtime"."messages_2025_10_09" USING "btree" ("inserted_at" DESC, "topic") WHERE (("extension" = 'broadcast'::"text") AND ("private" IS TRUE));


--
-- Name: messages_2025_10_10_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX "messages_2025_10_10_inserted_at_topic_idx" ON "realtime"."messages_2025_10_10" USING "btree" ("inserted_at" DESC, "topic") WHERE (("extension" = 'broadcast'::"text") AND ("private" IS TRUE));


--
-- Name: messages_2025_10_11_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX "messages_2025_10_11_inserted_at_topic_idx" ON "realtime"."messages_2025_10_11" USING "btree" ("inserted_at" DESC, "topic") WHERE (("extension" = 'broadcast'::"text") AND ("private" IS TRUE));


--
-- Name: messages_2025_10_12_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX "messages_2025_10_12_inserted_at_topic_idx" ON "realtime"."messages_2025_10_12" USING "btree" ("inserted_at" DESC, "topic") WHERE (("extension" = 'broadcast'::"text") AND ("private" IS TRUE));


--
-- Name: messages_2025_10_13_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX "messages_2025_10_13_inserted_at_topic_idx" ON "realtime"."messages_2025_10_13" USING "btree" ("inserted_at" DESC, "topic") WHERE (("extension" = 'broadcast'::"text") AND ("private" IS TRUE));


--
-- Name: subscription_subscription_id_entity_filters_key; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE UNIQUE INDEX "subscription_subscription_id_entity_filters_key" ON "realtime"."subscription" USING "btree" ("subscription_id", "entity", "filters");


--
-- Name: bname; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX "bname" ON "storage"."buckets" USING "btree" ("name");


--
-- Name: bucketid_objname; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX "bucketid_objname" ON "storage"."objects" USING "btree" ("bucket_id", "name");


--
-- Name: idx_multipart_uploads_list; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX "idx_multipart_uploads_list" ON "storage"."s3_multipart_uploads" USING "btree" ("bucket_id", "key", "created_at");


--
-- Name: idx_name_bucket_level_unique; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX "idx_name_bucket_level_unique" ON "storage"."objects" USING "btree" ("name" COLLATE "C", "bucket_id", "level");


--
-- Name: idx_objects_bucket_id_name; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX "idx_objects_bucket_id_name" ON "storage"."objects" USING "btree" ("bucket_id", "name" COLLATE "C");


--
-- Name: idx_objects_lower_name; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX "idx_objects_lower_name" ON "storage"."objects" USING "btree" (("path_tokens"["level"]), "lower"("name") "text_pattern_ops", "bucket_id", "level");


--
-- Name: idx_prefixes_lower_name; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX "idx_prefixes_lower_name" ON "storage"."prefixes" USING "btree" ("bucket_id", "level", (("string_to_array"("name", '/'::"text"))["level"]), "lower"("name") "text_pattern_ops");


--
-- Name: name_prefix_search; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX "name_prefix_search" ON "storage"."objects" USING "btree" ("name" "text_pattern_ops");


--
-- Name: objects_bucket_id_level_idx; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX "objects_bucket_id_level_idx" ON "storage"."objects" USING "btree" ("bucket_id", "level", "name" COLLATE "C");


--
-- Name: messages_2025_10_07_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX "realtime"."messages_inserted_at_topic_index" ATTACH PARTITION "realtime"."messages_2025_10_07_inserted_at_topic_idx";


--
-- Name: messages_2025_10_07_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX "realtime"."messages_pkey" ATTACH PARTITION "realtime"."messages_2025_10_07_pkey";


--
-- Name: messages_2025_10_08_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX "realtime"."messages_inserted_at_topic_index" ATTACH PARTITION "realtime"."messages_2025_10_08_inserted_at_topic_idx";


--
-- Name: messages_2025_10_08_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX "realtime"."messages_pkey" ATTACH PARTITION "realtime"."messages_2025_10_08_pkey";


--
-- Name: messages_2025_10_09_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX "realtime"."messages_inserted_at_topic_index" ATTACH PARTITION "realtime"."messages_2025_10_09_inserted_at_topic_idx";


--
-- Name: messages_2025_10_09_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX "realtime"."messages_pkey" ATTACH PARTITION "realtime"."messages_2025_10_09_pkey";


--
-- Name: messages_2025_10_10_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX "realtime"."messages_inserted_at_topic_index" ATTACH PARTITION "realtime"."messages_2025_10_10_inserted_at_topic_idx";


--
-- Name: messages_2025_10_10_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX "realtime"."messages_pkey" ATTACH PARTITION "realtime"."messages_2025_10_10_pkey";


--
-- Name: messages_2025_10_11_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX "realtime"."messages_inserted_at_topic_index" ATTACH PARTITION "realtime"."messages_2025_10_11_inserted_at_topic_idx";


--
-- Name: messages_2025_10_11_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX "realtime"."messages_pkey" ATTACH PARTITION "realtime"."messages_2025_10_11_pkey";


--
-- Name: messages_2025_10_12_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX "realtime"."messages_inserted_at_topic_index" ATTACH PARTITION "realtime"."messages_2025_10_12_inserted_at_topic_idx";


--
-- Name: messages_2025_10_12_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX "realtime"."messages_pkey" ATTACH PARTITION "realtime"."messages_2025_10_12_pkey";


--
-- Name: messages_2025_10_13_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX "realtime"."messages_inserted_at_topic_index" ATTACH PARTITION "realtime"."messages_2025_10_13_inserted_at_topic_idx";


--
-- Name: messages_2025_10_13_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX "realtime"."messages_pkey" ATTACH PARTITION "realtime"."messages_2025_10_13_pkey";


--
-- Name: users on_auth_user_created; Type: TRIGGER; Schema: auth; Owner: supabase_auth_admin
--

CREATE OR REPLACE TRIGGER "on_auth_user_created" AFTER INSERT ON "auth"."users" FOR EACH ROW EXECUTE FUNCTION "public"."handle_new_user_with_trial_role"();


--
-- Name: orders on_orders_update; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "on_orders_update" BEFORE UPDATE ON "public"."orders" FOR EACH ROW EXECUTE FUNCTION "public"."handle_orders_updated_at"();


--
-- Name: order_service_items tr_after_update_order_service_items; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "tr_after_update_order_service_items" AFTER UPDATE ON "public"."order_service_items" FOR EACH ROW EXECUTE FUNCTION "public"."tr_check_all_items_completed_v1"();


--
-- Name: work_sessions tr_auto_initialize_pilot_cycle_on_first_session; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "tr_auto_initialize_pilot_cycle_on_first_session" AFTER INSERT ON "public"."work_sessions" FOR EACH ROW EXECUTE FUNCTION "public"."tr_auto_initialize_pilot_cycle_on_first_session"();


--
-- Name: order_lines tr_auto_initialize_pilot_cycle_on_order_create; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "tr_auto_initialize_pilot_cycle_on_order_create" AFTER INSERT ON "public"."order_lines" FOR EACH ROW EXECUTE FUNCTION "public"."tr_auto_initialize_pilot_cycle_on_order_create"();


--
-- Name: order_lines tr_auto_update_pilot_cycle_on_pause_change; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "tr_auto_update_pilot_cycle_on_pause_change" AFTER UPDATE OF "paused_at" ON "public"."order_lines" FOR EACH ROW WHEN (("old"."paused_at" IS DISTINCT FROM "new"."paused_at")) EXECUTE FUNCTION "public"."tr_auto_update_pilot_cycle_on_pause_change"();


--
-- Name: work_sessions tr_auto_update_pilot_cycle_on_session_end; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "tr_auto_update_pilot_cycle_on_session_end" AFTER UPDATE OF "ended_at" ON "public"."work_sessions" FOR EACH ROW WHEN ((("old"."ended_at" IS NULL) AND ("new"."ended_at" IS NOT NULL))) EXECUTE FUNCTION "public"."tr_auto_update_pilot_cycle_on_session_end"();


--
-- Name: work_sessions tr_pilot_cycle_first_session; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "tr_pilot_cycle_first_session" AFTER INSERT ON "public"."work_sessions" FOR EACH ROW WHEN (("new"."ended_at" IS NULL)) EXECUTE FUNCTION "public"."tr_auto_initialize_pilot_cycle_on_first_session"();


--
-- Name: order_lines tr_pilot_cycle_order_create; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "tr_pilot_cycle_order_create" BEFORE INSERT ON "public"."order_lines" FOR EACH ROW EXECUTE FUNCTION "public"."tr_auto_initialize_pilot_cycle_on_order_create"();


--
-- Name: order_lines tr_pilot_cycle_pause_change; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "tr_pilot_cycle_pause_change" AFTER UPDATE ON "public"."order_lines" FOR EACH ROW WHEN (("old"."paused_at" IS DISTINCT FROM "new"."paused_at")) EXECUTE FUNCTION "public"."tr_auto_update_pilot_cycle_on_pause_change"();


--
-- Name: work_sessions tr_pilot_cycle_work_session_end; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "tr_pilot_cycle_work_session_end" AFTER UPDATE ON "public"."work_sessions" FOR EACH ROW WHEN ((("old"."ended_at" IS NULL) AND ("new"."ended_at" IS NOT NULL))) EXECUTE FUNCTION "public"."tr_auto_update_pilot_cycle_on_session_end"();


--
-- Name: game_accounts trigger_auto_create_inventory_records; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "trigger_auto_create_inventory_records" AFTER INSERT ON "public"."game_accounts" FOR EACH ROW EXECUTE FUNCTION "public"."auto_create_inventory_records"();


--
-- Name: game_accounts trigger_protect_account_with_currency; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "trigger_protect_account_with_currency" BEFORE DELETE ON "public"."game_accounts" FOR EACH ROW EXECUTE FUNCTION "public"."protect_account_with_currency"();


--
-- Name: currency_transactions trigger_update_currency_inventory; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "trigger_update_currency_inventory" AFTER INSERT ON "public"."currency_transactions" FOR EACH ROW EXECUTE FUNCTION "public"."update_currency_inventory"();


--
-- Name: game_accounts trigger_update_game_accounts_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "trigger_update_game_accounts_updated_at" BEFORE UPDATE ON "public"."game_accounts" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();


--
-- Name: trading_fee_chains trigger_update_trading_fee_chains_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "trigger_update_trading_fee_chains_updated_at" BEFORE UPDATE ON "public"."trading_fee_chains" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();


--
-- Name: channels update_channels_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "update_channels_updated_at" BEFORE UPDATE ON "public"."channels" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();


--
-- Name: parties update_parties_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE OR REPLACE TRIGGER "update_parties_updated_at" BEFORE UPDATE ON "public"."parties" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();


--
-- Name: subscription tr_check_filters; Type: TRIGGER; Schema: realtime; Owner: supabase_admin
--

CREATE OR REPLACE TRIGGER "tr_check_filters" BEFORE INSERT OR UPDATE ON "realtime"."subscription" FOR EACH ROW EXECUTE FUNCTION "realtime"."subscription_check_filters"();


--
-- Name: buckets enforce_bucket_name_length_trigger; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE OR REPLACE TRIGGER "enforce_bucket_name_length_trigger" BEFORE INSERT OR UPDATE OF "name" ON "storage"."buckets" FOR EACH ROW EXECUTE FUNCTION "storage"."enforce_bucket_name_length"();


--
-- Name: objects objects_delete_delete_prefix; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE OR REPLACE TRIGGER "objects_delete_delete_prefix" AFTER DELETE ON "storage"."objects" FOR EACH ROW EXECUTE FUNCTION "storage"."delete_prefix_hierarchy_trigger"();


--
-- Name: objects objects_insert_create_prefix; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE OR REPLACE TRIGGER "objects_insert_create_prefix" BEFORE INSERT ON "storage"."objects" FOR EACH ROW EXECUTE FUNCTION "storage"."objects_insert_prefix_trigger"();


--
-- Name: objects objects_update_create_prefix; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE OR REPLACE TRIGGER "objects_update_create_prefix" BEFORE UPDATE ON "storage"."objects" FOR EACH ROW WHEN ((("new"."name" <> "old"."name") OR ("new"."bucket_id" <> "old"."bucket_id"))) EXECUTE FUNCTION "storage"."objects_update_prefix_trigger"();


--
-- Name: prefixes prefixes_create_hierarchy; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE OR REPLACE TRIGGER "prefixes_create_hierarchy" BEFORE INSERT ON "storage"."prefixes" FOR EACH ROW WHEN (("pg_trigger_depth"() < 1)) EXECUTE FUNCTION "storage"."prefixes_insert_trigger"();


--
-- Name: prefixes prefixes_delete_hierarchy; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE OR REPLACE TRIGGER "prefixes_delete_hierarchy" AFTER DELETE ON "storage"."prefixes" FOR EACH ROW EXECUTE FUNCTION "storage"."delete_prefix_hierarchy_trigger"();


--
-- Name: objects update_objects_updated_at; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE OR REPLACE TRIGGER "update_objects_updated_at" BEFORE UPDATE ON "storage"."objects" FOR EACH ROW EXECUTE FUNCTION "storage"."update_updated_at_column"();


--
-- Name: identities identities_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY "auth"."identities"
    ADD CONSTRAINT "identities_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY "auth"."mfa_amr_claims"
    ADD CONSTRAINT "mfa_amr_claims_session_id_fkey" FOREIGN KEY ("session_id") REFERENCES "auth"."sessions"("id") ON DELETE CASCADE;


--
-- Name: mfa_challenges mfa_challenges_auth_factor_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY "auth"."mfa_challenges"
    ADD CONSTRAINT "mfa_challenges_auth_factor_id_fkey" FOREIGN KEY ("factor_id") REFERENCES "auth"."mfa_factors"("id") ON DELETE CASCADE;


--
-- Name: mfa_factors mfa_factors_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY "auth"."mfa_factors"
    ADD CONSTRAINT "mfa_factors_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
-- Name: one_time_tokens one_time_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY "auth"."one_time_tokens"
    ADD CONSTRAINT "one_time_tokens_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
-- Name: refresh_tokens refresh_tokens_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY "auth"."refresh_tokens"
    ADD CONSTRAINT "refresh_tokens_session_id_fkey" FOREIGN KEY ("session_id") REFERENCES "auth"."sessions"("id") ON DELETE CASCADE;


--
-- Name: saml_providers saml_providers_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY "auth"."saml_providers"
    ADD CONSTRAINT "saml_providers_sso_provider_id_fkey" FOREIGN KEY ("sso_provider_id") REFERENCES "auth"."sso_providers"("id") ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_flow_state_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY "auth"."saml_relay_states"
    ADD CONSTRAINT "saml_relay_states_flow_state_id_fkey" FOREIGN KEY ("flow_state_id") REFERENCES "auth"."flow_state"("id") ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY "auth"."saml_relay_states"
    ADD CONSTRAINT "saml_relay_states_sso_provider_id_fkey" FOREIGN KEY ("sso_provider_id") REFERENCES "auth"."sso_providers"("id") ON DELETE CASCADE;


--
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY "auth"."sessions"
    ADD CONSTRAINT "sessions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
-- Name: sso_domains sso_domains_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY "auth"."sso_domains"
    ADD CONSTRAINT "sso_domains_sso_provider_id_fkey" FOREIGN KEY ("sso_provider_id") REFERENCES "auth"."sso_providers"("id") ON DELETE CASCADE;


--
-- Name: attribute_relationships attribute_relationships_child_attribute_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."attribute_relationships"
    ADD CONSTRAINT "attribute_relationships_child_attribute_id_fkey" FOREIGN KEY ("child_attribute_id") REFERENCES "public"."attributes"("id") ON DELETE CASCADE;


--
-- Name: attribute_relationships attribute_relationships_parent_attribute_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."attribute_relationships"
    ADD CONSTRAINT "attribute_relationships_parent_attribute_id_fkey" FOREIGN KEY ("parent_attribute_id") REFERENCES "public"."attributes"("id") ON DELETE CASCADE;


--
-- Name: channels channels_trading_fee_chain_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."channels"
    ADD CONSTRAINT "channels_trading_fee_chain_id_fkey" FOREIGN KEY ("trading_fee_chain_id") REFERENCES "public"."trading_fee_chains"("id") ON DELETE SET NULL;


--
-- Name: currency_inventory currency_inventory_currency_attribute_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."currency_inventory"
    ADD CONSTRAINT "currency_inventory_currency_attribute_id_fkey" FOREIGN KEY ("currency_attribute_id") REFERENCES "public"."attributes"("id") ON DELETE CASCADE;


--
-- Name: currency_inventory currency_inventory_game_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."currency_inventory"
    ADD CONSTRAINT "currency_inventory_game_account_id_fkey" FOREIGN KEY ("game_account_id") REFERENCES "public"."game_accounts"("id") ON DELETE CASCADE;


--
-- Name: currency_transactions currency_transactions_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."currency_transactions"
    ADD CONSTRAINT "currency_transactions_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id") ON DELETE RESTRICT;


--
-- Name: currency_transactions currency_transactions_currency_attribute_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."currency_transactions"
    ADD CONSTRAINT "currency_transactions_currency_attribute_id_fkey" FOREIGN KEY ("currency_attribute_id") REFERENCES "public"."attributes"("id") ON DELETE CASCADE;


--
-- Name: currency_transactions currency_transactions_farmer_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."currency_transactions"
    ADD CONSTRAINT "currency_transactions_farmer_profile_id_fkey" FOREIGN KEY ("farmer_profile_id") REFERENCES "public"."profiles"("id") ON DELETE SET NULL;


--
-- Name: currency_transactions currency_transactions_game_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."currency_transactions"
    ADD CONSTRAINT "currency_transactions_game_account_id_fkey" FOREIGN KEY ("game_account_id") REFERENCES "public"."game_accounts"("id") ON DELETE CASCADE;


--
-- Name: currency_transactions currency_transactions_league_attribute_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."currency_transactions"
    ADD CONSTRAINT "currency_transactions_league_attribute_id_fkey" FOREIGN KEY ("league_attribute_id") REFERENCES "public"."attributes"("id") ON DELETE CASCADE;


--
-- Name: currency_transactions currency_transactions_order_line_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."currency_transactions"
    ADD CONSTRAINT "currency_transactions_order_line_id_fkey" FOREIGN KEY ("order_line_id") REFERENCES "public"."order_lines"("id") ON DELETE SET NULL;


--
-- Name: currency_transactions currency_transactions_partner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."currency_transactions"
    ADD CONSTRAINT "currency_transactions_partner_id_fkey" FOREIGN KEY ("partner_id") REFERENCES "public"."parties"("id") ON DELETE SET NULL;


--
-- Name: customer_accounts customer_accounts_party_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."customer_accounts"
    ADD CONSTRAINT "customer_accounts_party_id_fkey" FOREIGN KEY ("party_id") REFERENCES "public"."parties"("id");


--
-- Name: order_service_items fk_service_kind; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."order_service_items"
    ADD CONSTRAINT "fk_service_kind" FOREIGN KEY ("service_kind_id") REFERENCES "public"."attributes"("id");


--
-- Name: game_accounts game_accounts_league_attribute_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."game_accounts"
    ADD CONSTRAINT "game_accounts_league_attribute_id_fkey" FOREIGN KEY ("league_attribute_id") REFERENCES "public"."attributes"("id") ON DELETE CASCADE;


--
-- Name: game_accounts game_accounts_manager_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."game_accounts"
    ADD CONSTRAINT "game_accounts_manager_profile_id_fkey" FOREIGN KEY ("manager_profile_id") REFERENCES "public"."profiles"("id") ON DELETE SET NULL;


--
-- Name: order_lines order_lines_customer_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."order_lines"
    ADD CONSTRAINT "order_lines_customer_account_id_fkey" FOREIGN KEY ("customer_account_id") REFERENCES "public"."customer_accounts"("id");


--
-- Name: order_lines order_lines_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."order_lines"
    ADD CONSTRAINT "order_lines_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "public"."orders"("id") ON DELETE CASCADE;


--
-- Name: order_lines order_lines_variant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."order_lines"
    ADD CONSTRAINT "order_lines_variant_id_fkey" FOREIGN KEY ("variant_id") REFERENCES "public"."product_variants"("id");


--
-- Name: order_reviews order_reviews_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."order_reviews"
    ADD CONSTRAINT "order_reviews_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id");


--
-- Name: order_reviews order_reviews_order_line_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."order_reviews"
    ADD CONSTRAINT "order_reviews_order_line_id_fkey" FOREIGN KEY ("order_line_id") REFERENCES "public"."order_lines"("id") ON DELETE CASCADE;


--
-- Name: order_service_items order_service_items_order_line_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."order_service_items"
    ADD CONSTRAINT "order_service_items_order_line_id_fkey" FOREIGN KEY ("order_line_id") REFERENCES "public"."order_lines"("id") ON DELETE CASCADE;


--
-- Name: orders orders_channel_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."orders"
    ADD CONSTRAINT "orders_channel_id_fkey" FOREIGN KEY ("channel_id") REFERENCES "public"."channels"("id");


--
-- Name: orders orders_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."orders"
    ADD CONSTRAINT "orders_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id");


--
-- Name: orders orders_currency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."orders"
    ADD CONSTRAINT "orders_currency_id_fkey" FOREIGN KEY ("currency_id") REFERENCES "public"."currencies"("id");


--
-- Name: orders orders_party_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."orders"
    ADD CONSTRAINT "orders_party_id_fkey" FOREIGN KEY ("party_id") REFERENCES "public"."parties"("id");


--
-- Name: product_variant_attributes product_variant_attributes_attribute_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."product_variant_attributes"
    ADD CONSTRAINT "product_variant_attributes_attribute_id_fkey" FOREIGN KEY ("attribute_id") REFERENCES "public"."attributes"("id") ON DELETE CASCADE;


--
-- Name: product_variant_attributes product_variant_attributes_variant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."product_variant_attributes"
    ADD CONSTRAINT "product_variant_attributes_variant_id_fkey" FOREIGN KEY ("variant_id") REFERENCES "public"."product_variants"("id") ON DELETE CASCADE;


--
-- Name: product_variants product_variants_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."product_variants"
    ADD CONSTRAINT "product_variants_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id");


--
-- Name: profiles profiles_auth_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_auth_id_fkey" FOREIGN KEY ("auth_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
-- Name: role_permissions role_permissions_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."role_permissions"
    ADD CONSTRAINT "role_permissions_permission_id_fkey" FOREIGN KEY ("permission_id") REFERENCES "public"."permissions"("id") ON DELETE CASCADE;


--
-- Name: role_permissions role_permissions_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."role_permissions"
    ADD CONSTRAINT "role_permissions_role_id_fkey" FOREIGN KEY ("role_id") REFERENCES "public"."roles"("id") ON DELETE CASCADE;


--
-- Name: service_reports service_reports_order_line_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."service_reports"
    ADD CONSTRAINT "service_reports_order_line_id_fkey" FOREIGN KEY ("order_line_id") REFERENCES "public"."order_lines"("id");


--
-- Name: service_reports service_reports_order_service_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."service_reports"
    ADD CONSTRAINT "service_reports_order_service_item_id_fkey" FOREIGN KEY ("order_service_item_id") REFERENCES "public"."order_service_items"("id");


--
-- Name: service_reports service_reports_reported_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."service_reports"
    ADD CONSTRAINT "service_reports_reported_by_fkey" FOREIGN KEY ("reported_by") REFERENCES "public"."profiles"("id");


--
-- Name: service_reports service_reports_resolved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."service_reports"
    ADD CONSTRAINT "service_reports_resolved_by_fkey" FOREIGN KEY ("resolved_by") REFERENCES "public"."profiles"("id");


--
-- Name: system_logs system_logs_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."system_logs"
    ADD CONSTRAINT "system_logs_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id");


--
-- Name: user_role_assignments user_role_assignments_business_area_attribute_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."user_role_assignments"
    ADD CONSTRAINT "user_role_assignments_business_area_attribute_id_fkey" FOREIGN KEY ("business_area_attribute_id") REFERENCES "public"."attributes"("id") ON DELETE SET NULL;


--
-- Name: user_role_assignments user_role_assignments_game_attribute_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."user_role_assignments"
    ADD CONSTRAINT "user_role_assignments_game_attribute_id_fkey" FOREIGN KEY ("game_attribute_id") REFERENCES "public"."attributes"("id") ON DELETE SET NULL;


--
-- Name: user_role_assignments user_role_assignments_role_id_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."user_role_assignments"
    ADD CONSTRAINT "user_role_assignments_role_id_fkey1" FOREIGN KEY ("role_id") REFERENCES "public"."roles"("id") ON DELETE CASCADE;


--
-- Name: user_role_assignments user_role_assignments_user_id_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."user_role_assignments"
    ADD CONSTRAINT "user_role_assignments_user_id_fkey1" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;


--
-- Name: work_session_outputs work_session_outputs_order_service_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."work_session_outputs"
    ADD CONSTRAINT "work_session_outputs_order_service_item_id_fkey" FOREIGN KEY ("order_service_item_id") REFERENCES "public"."order_service_items"("id");


--
-- Name: work_session_outputs work_session_outputs_work_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."work_session_outputs"
    ADD CONSTRAINT "work_session_outputs_work_session_id_fkey" FOREIGN KEY ("work_session_id") REFERENCES "public"."work_sessions"("id") ON DELETE CASCADE;


--
-- Name: work_sessions work_sessions_farmer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."work_sessions"
    ADD CONSTRAINT "work_sessions_farmer_id_fkey" FOREIGN KEY ("farmer_id") REFERENCES "public"."profiles"("id");


--
-- Name: work_sessions work_sessions_order_line_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."work_sessions"
    ADD CONSTRAINT "work_sessions_order_line_id_fkey" FOREIGN KEY ("order_line_id") REFERENCES "public"."order_lines"("id");


--
-- Name: objects objects_bucketId_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY "storage"."objects"
    ADD CONSTRAINT "objects_bucketId_fkey" FOREIGN KEY ("bucket_id") REFERENCES "storage"."buckets"("id");


--
-- Name: prefixes prefixes_bucketId_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY "storage"."prefixes"
    ADD CONSTRAINT "prefixes_bucketId_fkey" FOREIGN KEY ("bucket_id") REFERENCES "storage"."buckets"("id");


--
-- Name: s3_multipart_uploads s3_multipart_uploads_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY "storage"."s3_multipart_uploads"
    ADD CONSTRAINT "s3_multipart_uploads_bucket_id_fkey" FOREIGN KEY ("bucket_id") REFERENCES "storage"."buckets"("id");


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY "storage"."s3_multipart_uploads_parts"
    ADD CONSTRAINT "s3_multipart_uploads_parts_bucket_id_fkey" FOREIGN KEY ("bucket_id") REFERENCES "storage"."buckets"("id");


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_upload_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY "storage"."s3_multipart_uploads_parts"
    ADD CONSTRAINT "s3_multipart_uploads_parts_upload_id_fkey" FOREIGN KEY ("upload_id") REFERENCES "storage"."s3_multipart_uploads"("id") ON DELETE CASCADE;


--
-- Name: audit_log_entries; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE "auth"."audit_log_entries" ENABLE ROW LEVEL SECURITY;

--
-- Name: flow_state; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE "auth"."flow_state" ENABLE ROW LEVEL SECURITY;

--
-- Name: identities; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE "auth"."identities" ENABLE ROW LEVEL SECURITY;

--
-- Name: instances; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE "auth"."instances" ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_amr_claims; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE "auth"."mfa_amr_claims" ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_challenges; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE "auth"."mfa_challenges" ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_factors; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE "auth"."mfa_factors" ENABLE ROW LEVEL SECURITY;

--
-- Name: one_time_tokens; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE "auth"."one_time_tokens" ENABLE ROW LEVEL SECURITY;

--
-- Name: refresh_tokens; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE "auth"."refresh_tokens" ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_providers; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE "auth"."saml_providers" ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_relay_states; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE "auth"."saml_relay_states" ENABLE ROW LEVEL SECURITY;

--
-- Name: schema_migrations; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE "auth"."schema_migrations" ENABLE ROW LEVEL SECURITY;

--
-- Name: sessions; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE "auth"."sessions" ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_domains; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE "auth"."sso_domains" ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_providers; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE "auth"."sso_providers" ENABLE ROW LEVEL SECURITY;

--
-- Name: users; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE "auth"."users" ENABLE ROW LEVEL SECURITY;

--
-- Name: game_accounts Admins and managers can insert game accounts; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins and managers can insert game accounts" ON "public"."game_accounts" FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM ("public"."user_role_assignments" "ura"
     JOIN "public"."roles" "r" ON (("ura"."role_id" = "r"."id")))
  WHERE (("ura"."user_id" = "auth"."uid"()) AND ("r"."code" = ANY (ARRAY['admin'::"public"."app_role", 'manager'::"public"."app_role"]))))));


--
-- Name: role_permissions Allow admin to delete; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow admin to delete" ON "public"."role_permissions" FOR DELETE TO "authenticated" USING ("public"."has_permission"('admin:manage_roles'::"text"));


--
-- Name: role_permissions Allow admin to insert; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow admin to insert" ON "public"."role_permissions" FOR INSERT TO "authenticated" WITH CHECK ("public"."has_permission"('admin:manage_roles'::"text"));


--
-- Name: debug_log Allow admin to manage debug logs; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow admin to manage debug logs" ON "public"."debug_log" TO "authenticated" USING ("public"."has_permission"('admin:manage_roles'::"text")) WITH CHECK ("public"."has_permission"('admin:manage_roles'::"text"));


--
-- Name: permissions Allow admin to manage permissions; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow admin to manage permissions" ON "public"."permissions" TO "authenticated" USING ("public"."has_permission"('admin:manage_roles'::"text")) WITH CHECK ("public"."has_permission"('admin:manage_roles'::"text"));


--
-- Name: role_permissions Allow admin to update; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow admin to update" ON "public"."role_permissions" FOR UPDATE TO "authenticated" USING ("public"."has_permission"('admin:manage_roles'::"text"));


--
-- Name: user_role_assignments Allow admins to delete assignments; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow admins to delete assignments" ON "public"."user_role_assignments" FOR DELETE TO "authenticated" USING ("public"."has_permission"('admin:manage_roles'::"text"));


--
-- Name: user_role_assignments Allow admins to insert assignments; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow admins to insert assignments" ON "public"."user_role_assignments" FOR INSERT TO "authenticated" WITH CHECK ("public"."has_permission"('admin:manage_roles'::"text"));


--
-- Name: trading_fee_chains Allow admins to manage fee chains; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow admins to manage fee chains" ON "public"."trading_fee_chains" USING ((EXISTS ( SELECT 1
   FROM ("public"."user_role_assignments" "ura"
     JOIN "public"."roles" "r" ON (("ura"."role_id" = "r"."id")))
  WHERE (("ura"."user_id" = "auth"."uid"()) AND ("r"."code" = 'admin'::"public"."app_role")))));


--
-- Name: user_role_assignments Allow admins to update assignments; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow admins to update assignments" ON "public"."user_role_assignments" FOR UPDATE TO "authenticated" USING ("public"."has_permission"('admin:manage_roles'::"text"));


--
-- Name: exchange_rates Allow admins to update exchange rates; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow admins to update exchange rates" ON "public"."exchange_rates" USING ((EXISTS ( SELECT 1
   FROM ("public"."user_role_assignments" "ura"
     JOIN "public"."roles" "r" ON (("ura"."role_id" = "r"."id")))
  WHERE (("ura"."user_id" = "auth"."uid"()) AND ("r"."code" = ANY (ARRAY['admin'::"public"."app_role", 'manager'::"public"."app_role"]))))));


--
-- Name: attribute_relationships Allow authenticated read access; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow authenticated read access" ON "public"."attribute_relationships" FOR SELECT TO "authenticated" USING (true);


--
-- Name: attributes Allow authenticated read access; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow authenticated read access" ON "public"."attributes" FOR SELECT TO "authenticated" USING (true);


--
-- Name: channels Allow authenticated read access; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow authenticated read access" ON "public"."channels" FOR SELECT TO "authenticated" USING (true);


--
-- Name: currencies Allow authenticated read access; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow authenticated read access" ON "public"."currencies" FOR SELECT TO "authenticated" USING (true);


--
-- Name: customer_accounts Allow authenticated read access; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow authenticated read access" ON "public"."customer_accounts" FOR SELECT TO "authenticated" USING (true);


--
-- Name: order_lines Allow authenticated read access; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow authenticated read access" ON "public"."order_lines" FOR SELECT TO "authenticated" USING (true);


--
-- Name: order_service_items Allow authenticated read access; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow authenticated read access" ON "public"."order_service_items" FOR SELECT TO "authenticated" USING (true);


--
-- Name: orders Allow authenticated read access; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow authenticated read access" ON "public"."orders" FOR SELECT TO "authenticated" USING (true);


--
-- Name: parties Allow authenticated read access; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow authenticated read access" ON "public"."parties" FOR SELECT TO "authenticated" USING (true);


--
-- Name: product_variant_attributes Allow authenticated read access; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow authenticated read access" ON "public"."product_variant_attributes" FOR SELECT TO "authenticated" USING (true);


--
-- Name: product_variants Allow authenticated read access; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow authenticated read access" ON "public"."product_variants" FOR SELECT TO "authenticated" USING (true);


--
-- Name: products Allow authenticated read access; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow authenticated read access" ON "public"."products" FOR SELECT TO "authenticated" USING (true);


--
-- Name: roles Allow authenticated read access; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow authenticated read access" ON "public"."roles" FOR SELECT TO "authenticated" USING (true);


--
-- Name: work_session_outputs Allow authenticated read access; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow authenticated read access" ON "public"."work_session_outputs" FOR SELECT TO "authenticated" USING (true);


--
-- Name: work_sessions Allow authenticated read access; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow authenticated read access" ON "public"."work_sessions" FOR SELECT TO "authenticated" USING (true);


--
-- Name: service_reports Allow authenticated users to create reports; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow authenticated users to create reports" ON "public"."service_reports" FOR INSERT TO "authenticated" WITH CHECK (true);


--
-- Name: trading_fee_chains Allow authenticated users to read active fee chains; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow authenticated users to read active fee chains" ON "public"."trading_fee_chains" FOR SELECT USING (("is_active" = true));


--
-- Name: exchange_rates Allow authenticated users to read exchange rates; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow authenticated users to read exchange rates" ON "public"."exchange_rates" FOR SELECT USING (true);


--
-- Name: permissions Allow authenticated users to read permissions; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow authenticated users to read permissions" ON "public"."permissions" FOR SELECT TO "authenticated" USING (true);


--
-- Name: profiles Allow authenticated users to read profiles; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow authenticated users to read profiles" ON "public"."profiles" FOR SELECT TO "authenticated" USING (true);


--
-- Name: role_permissions Allow authenticated users to read role permissions; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow authenticated users to read role permissions" ON "public"."role_permissions" FOR SELECT TO "authenticated" USING (true);


--
-- Name: service_reports Allow managers to resolve reports; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow managers to resolve reports" ON "public"."service_reports" FOR UPDATE TO "authenticated" USING ("public"."has_permission"('reports:resolve'::"text")) WITH CHECK ("public"."has_permission"('reports:resolve'::"text"));


--
-- Name: audit_logs Allow privileged users to read audit logs; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow privileged users to read audit logs" ON "public"."audit_logs" FOR SELECT TO "authenticated" USING ("public"."has_permission"('system:view_audit_logs'::"text"));


--
-- Name: level_exp Allow read access to all authenticated users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow read access to all authenticated users" ON "public"."level_exp" FOR SELECT TO "authenticated" USING (true);


--
-- Name: service_reports Allow users to read relevant reports; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow users to read relevant reports" ON "public"."service_reports" FOR SELECT TO "authenticated" USING ((("reported_by" = ( SELECT "auth"."uid"() AS "uid")) OR "public"."has_permission"('reports:view'::"text")));


--
-- Name: user_role_assignments Allow users to read their own, and admins all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow users to read their own, and admins all" ON "public"."user_role_assignments" FOR SELECT TO "authenticated" USING ((("user_id" = "auth"."uid"()) OR "public"."has_permission"('admin:manage_roles'::"text")));


--
-- Name: order_reviews Allow users with permission to add reviews; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow users with permission to add reviews" ON "public"."order_reviews" FOR INSERT WITH CHECK ((("created_by" = "auth"."uid"()) AND "public"."has_permission"('orders:add_review'::"text")));


--
-- Name: order_reviews Allow users with permission to view reviews; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow users with permission to view reviews" ON "public"."order_reviews" FOR SELECT USING ("public"."has_permission"('orders:view_reviews'::"text"));


--
-- Name: service_reports Block all deletes; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Block all deletes" ON "public"."service_reports" FOR DELETE TO "authenticated" USING (false);


--
-- Name: attribute_relationships Block deletes; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Block deletes" ON "public"."attribute_relationships" FOR DELETE TO "authenticated" USING (false);


--
-- Name: attributes Block deletes; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Block deletes" ON "public"."attributes" FOR DELETE TO "authenticated" USING (false);


--
-- Name: channels Block deletes; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Block deletes" ON "public"."channels" FOR DELETE TO "authenticated" USING (false);


--
-- Name: currencies Block deletes; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Block deletes" ON "public"."currencies" FOR DELETE TO "authenticated" USING (false);


--
-- Name: customer_accounts Block deletes; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Block deletes" ON "public"."customer_accounts" FOR DELETE TO "authenticated" USING (false);


--
-- Name: order_lines Block deletes; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Block deletes" ON "public"."order_lines" FOR DELETE TO "authenticated" USING (false);


--
-- Name: order_service_items Block deletes; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Block deletes" ON "public"."order_service_items" FOR DELETE TO "authenticated" USING (false);


--
-- Name: orders Block deletes; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Block deletes" ON "public"."orders" FOR DELETE TO "authenticated" USING (false);


--
-- Name: parties Block deletes; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Block deletes" ON "public"."parties" FOR DELETE TO "authenticated" USING (false);


--
-- Name: product_variant_attributes Block deletes; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Block deletes" ON "public"."product_variant_attributes" FOR DELETE TO "authenticated" USING (false);


--
-- Name: product_variants Block deletes; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Block deletes" ON "public"."product_variants" FOR DELETE TO "authenticated" USING (false);


--
-- Name: products Block deletes; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Block deletes" ON "public"."products" FOR DELETE TO "authenticated" USING (false);


--
-- Name: roles Block deletes; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Block deletes" ON "public"."roles" FOR DELETE TO "authenticated" USING (false);


--
-- Name: work_session_outputs Block deletes; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Block deletes" ON "public"."work_session_outputs" FOR DELETE TO "authenticated" USING (false);


--
-- Name: work_sessions Block deletes; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Block deletes" ON "public"."work_sessions" FOR DELETE TO "authenticated" USING (false);


--
-- Name: attribute_relationships Block inserts; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Block inserts" ON "public"."attribute_relationships" FOR INSERT TO "authenticated" WITH CHECK (false);


--
-- Name: attributes Block inserts; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Block inserts" ON "public"."attributes" FOR INSERT TO "authenticated" WITH CHECK (false);


--
-- Name: channels Block inserts; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Block inserts" ON "public"."channels" FOR INSERT TO "authenticated" WITH CHECK (false);


--
-- Name: currencies Block inserts; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Block inserts" ON "public"."currencies" FOR INSERT TO "authenticated" WITH CHECK (false);


--
-- Name: customer_accounts Block inserts; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Block inserts" ON "public"."customer_accounts" FOR INSERT TO "authenticated" WITH CHECK (false);


--
-- Name: order_lines Block inserts; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Block inserts" ON "public"."order_lines" FOR INSERT TO "authenticated" WITH CHECK (false);


--
-- Name: order_service_items Block inserts; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Block inserts" ON "public"."order_service_items" FOR INSERT TO "authenticated" WITH CHECK (false);


--
-- Name: orders Block inserts; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Block inserts" ON "public"."orders" FOR INSERT TO "authenticated" WITH CHECK (false);


--
-- Name: parties Block inserts; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Block inserts" ON "public"."parties" FOR INSERT TO "authenticated" WITH CHECK (false);


--
-- Name: product_variant_attributes Block inserts; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Block inserts" ON "public"."product_variant_attributes" FOR INSERT TO "authenticated" WITH CHECK (false);


--
-- Name: product_variants Block inserts; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Block inserts" ON "public"."product_variants" FOR INSERT TO "authenticated" WITH CHECK (false);


--
-- Name: products Block inserts; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Block inserts" ON "public"."products" FOR INSERT TO "authenticated" WITH CHECK (false);


--
-- Name: roles Block inserts; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Block inserts" ON "public"."roles" FOR INSERT TO "authenticated" WITH CHECK (false);


--
-- Name: work_session_outputs Block inserts; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Block inserts" ON "public"."work_session_outputs" FOR INSERT TO "authenticated" WITH CHECK (false);


--
-- Name: work_sessions Block inserts; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Block inserts" ON "public"."work_sessions" FOR INSERT TO "authenticated" WITH CHECK (false);


--
-- Name: attribute_relationships Block updates; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Block updates" ON "public"."attribute_relationships" FOR UPDATE TO "authenticated" USING (false) WITH CHECK (false);


--
-- Name: attributes Block updates; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Block updates" ON "public"."attributes" FOR UPDATE TO "authenticated" USING (false) WITH CHECK (false);


--
-- Name: channels Block updates; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Block updates" ON "public"."channels" FOR UPDATE TO "authenticated" USING (false) WITH CHECK (false);


--
-- Name: currencies Block updates; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Block updates" ON "public"."currencies" FOR UPDATE TO "authenticated" USING (false) WITH CHECK (false);


--
-- Name: customer_accounts Block updates; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Block updates" ON "public"."customer_accounts" FOR UPDATE TO "authenticated" USING (false) WITH CHECK (false);


--
-- Name: order_lines Block updates; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Block updates" ON "public"."order_lines" FOR UPDATE TO "authenticated" USING (false) WITH CHECK (false);


--
-- Name: order_service_items Block updates; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Block updates" ON "public"."order_service_items" FOR UPDATE TO "authenticated" USING (false) WITH CHECK (false);


--
-- Name: orders Block updates; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Block updates" ON "public"."orders" FOR UPDATE TO "authenticated" USING (false) WITH CHECK (false);


--
-- Name: parties Block updates; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Block updates" ON "public"."parties" FOR UPDATE TO "authenticated" USING (false) WITH CHECK (false);


--
-- Name: product_variant_attributes Block updates; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Block updates" ON "public"."product_variant_attributes" FOR UPDATE TO "authenticated" USING (false) WITH CHECK (false);


--
-- Name: product_variants Block updates; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Block updates" ON "public"."product_variants" FOR UPDATE TO "authenticated" USING (false) WITH CHECK (false);


--
-- Name: products Block updates; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Block updates" ON "public"."products" FOR UPDATE TO "authenticated" USING (false) WITH CHECK (false);


--
-- Name: roles Block updates; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Block updates" ON "public"."roles" FOR UPDATE TO "authenticated" USING (false) WITH CHECK (false);


--
-- Name: work_session_outputs Block updates; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Block updates" ON "public"."work_session_outputs" FOR UPDATE TO "authenticated" USING (false) WITH CHECK (false);


--
-- Name: work_sessions Block updates; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Block updates" ON "public"."work_sessions" FOR UPDATE TO "authenticated" USING (false) WITH CHECK (false);


--
-- Name: currency_transactions Users can create transactions for their managed accounts; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can create transactions for their managed accounts" ON "public"."currency_transactions" FOR INSERT WITH CHECK ((("created_by" = "auth"."uid"()) AND (EXISTS ( SELECT 1
   FROM "public"."game_accounts" "ga"
  WHERE (("ga"."id" = "currency_transactions"."game_account_id") AND ("ga"."manager_profile_id" = "auth"."uid"()))))));


--
-- Name: currency_transactions Users can insert transactions they manage; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can insert transactions they manage" ON "public"."currency_transactions" FOR INSERT WITH CHECK ((("created_by" = "auth"."uid"()) AND (EXISTS ( SELECT 1
   FROM "public"."game_accounts" "ga"
  WHERE (("ga"."id" = "currency_transactions"."game_account_id") AND (("ga"."manager_profile_id" = "auth"."uid"()) OR (EXISTS ( SELECT 1
           FROM ("public"."user_role_assignments" "ura"
             JOIN "public"."roles" "r" ON (("ura"."role_id" = "r"."id")))
          WHERE (("ura"."user_id" = "auth"."uid"()) AND ("r"."code" = ANY (ARRAY['admin'::"public"."app_role", 'manager'::"public"."app_role"])))))))))));


--
-- Name: game_accounts Users can update game accounts they manage; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can update game accounts they manage" ON "public"."game_accounts" FOR UPDATE USING ((("auth"."uid"() = "manager_profile_id") OR (EXISTS ( SELECT 1
   FROM ("public"."user_role_assignments" "ura"
     JOIN "public"."roles" "r" ON (("ura"."role_id" = "r"."id")))
  WHERE (("ura"."user_id" = "auth"."uid"()) AND ("r"."code" = ANY (ARRAY['admin'::"public"."app_role", 'manager'::"public"."app_role"])))))));


--
-- Name: profiles Users can update their own profile; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can update their own profile" ON "public"."profiles" FOR UPDATE USING (("auth"."uid"() = "auth_id")) WITH CHECK (("auth"."uid"() = "auth_id"));


--
-- Name: game_accounts Users can view game accounts they manage; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view game accounts they manage" ON "public"."game_accounts" FOR SELECT USING ((("auth"."uid"() = "manager_profile_id") OR (EXISTS ( SELECT 1
   FROM ("public"."user_role_assignments" "ura"
     JOIN "public"."roles" "r" ON (("ura"."role_id" = "r"."id")))
  WHERE (("ura"."user_id" = "auth"."uid"()) AND ("r"."code" = ANY (ARRAY['admin'::"public"."app_role", 'manager'::"public"."app_role"])))))));


--
-- Name: currency_inventory Users can view inventory they manage; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view inventory they manage" ON "public"."currency_inventory" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."game_accounts" "ga"
  WHERE (("ga"."id" = "currency_inventory"."game_account_id") AND (("ga"."manager_profile_id" = "auth"."uid"()) OR (EXISTS ( SELECT 1
           FROM ("public"."user_role_assignments" "ura"
             JOIN "public"."roles" "r" ON (("ura"."role_id" = "r"."id")))
          WHERE (("ura"."user_id" = "auth"."uid"()) AND ("r"."code" = ANY (ARRAY['admin'::"public"."app_role", 'manager'::"public"."app_role"]))))))))));


--
-- Name: currency_transactions Users can view transactions they created or manage; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view transactions they created or manage" ON "public"."currency_transactions" FOR SELECT USING ((("created_by" = "auth"."uid"()) OR (EXISTS ( SELECT 1
   FROM "public"."game_accounts" "ga"
  WHERE (("ga"."id" = "currency_transactions"."game_account_id") AND ("ga"."manager_profile_id" = "auth"."uid"())))) OR (EXISTS ( SELECT 1
   FROM ("public"."user_role_assignments" "ura"
     JOIN "public"."roles" "r" ON (("ura"."role_id" = "r"."id")))
  WHERE (("ura"."user_id" = "auth"."uid"()) AND ("r"."code" = ANY (ARRAY['admin'::"public"."app_role", 'manager'::"public"."app_role"])))))));


--
-- Name: attribute_relationships; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."attribute_relationships" ENABLE ROW LEVEL SECURITY;

--
-- Name: attributes; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."attributes" ENABLE ROW LEVEL SECURITY;

--
-- Name: audit_logs; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."audit_logs" ENABLE ROW LEVEL SECURITY;

--
-- Name: audit_logs audit_no_delete; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "audit_no_delete" ON "public"."audit_logs" FOR DELETE USING (false);


--
-- Name: audit_logs audit_no_update; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "audit_no_update" ON "public"."audit_logs" FOR UPDATE WITH CHECK (false);


--
-- Name: work_sessions authenticated_delete_work_sessions; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "authenticated_delete_work_sessions" ON "public"."work_sessions" FOR DELETE TO "authenticated" USING (true);


--
-- Name: order_reviews authenticated_insert_order_reviews; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "authenticated_insert_order_reviews" ON "public"."order_reviews" FOR INSERT TO "authenticated" WITH CHECK (true);


--
-- Name: work_sessions authenticated_insert_work_sessions; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "authenticated_insert_work_sessions" ON "public"."work_sessions" FOR INSERT TO "authenticated" WITH CHECK (true);


--
-- Name: attribute_relationships authenticated_read_attribute_relationships; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "authenticated_read_attribute_relationships" ON "public"."attribute_relationships" FOR SELECT TO "authenticated" USING (true);


--
-- Name: attributes authenticated_read_attributes; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "authenticated_read_attributes" ON "public"."attributes" FOR SELECT TO "authenticated" USING (true);


--
-- Name: order_lines authenticated_read_order_lines; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "authenticated_read_order_lines" ON "public"."order_lines" FOR SELECT TO "authenticated" USING (true);


--
-- Name: order_reviews authenticated_read_order_reviews; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "authenticated_read_order_reviews" ON "public"."order_reviews" FOR SELECT TO "authenticated" USING (true);


--
-- Name: order_service_items authenticated_read_order_service_items; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "authenticated_read_order_service_items" ON "public"."order_service_items" FOR SELECT TO "authenticated" USING (true);


--
-- Name: orders authenticated_read_orders; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "authenticated_read_orders" ON "public"."orders" FOR SELECT TO "authenticated" USING (true);


--
-- Name: parties authenticated_read_parties; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "authenticated_read_parties" ON "public"."parties" FOR SELECT TO "authenticated" USING (true);


--
-- Name: product_variants authenticated_read_product_variants; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "authenticated_read_product_variants" ON "public"."product_variants" FOR SELECT TO "authenticated" USING (true);


--
-- Name: profiles authenticated_read_profiles; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "authenticated_read_profiles" ON "public"."profiles" FOR SELECT TO "authenticated" USING (true);


--
-- Name: work_sessions authenticated_read_work_sessions; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "authenticated_read_work_sessions" ON "public"."work_sessions" FOR SELECT TO "authenticated" USING (true);


--
-- Name: order_lines authenticated_update_order_lines; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "authenticated_update_order_lines" ON "public"."order_lines" FOR UPDATE TO "authenticated" USING (true);


--
-- Name: order_service_items authenticated_update_order_service_items; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "authenticated_update_order_service_items" ON "public"."order_service_items" FOR UPDATE TO "authenticated" USING (true);


--
-- Name: orders authenticated_update_orders; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "authenticated_update_orders" ON "public"."orders" FOR UPDATE TO "authenticated" USING (true);


--
-- Name: work_sessions authenticated_update_work_sessions; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "authenticated_update_work_sessions" ON "public"."work_sessions" FOR UPDATE TO "authenticated" USING (true);


--
-- Name: channels; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."channels" ENABLE ROW LEVEL SECURITY;

--
-- Name: currencies; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."currencies" ENABLE ROW LEVEL SECURITY;

--
-- Name: currency_inventory; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."currency_inventory" ENABLE ROW LEVEL SECURITY;

--
-- Name: currency_transactions; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."currency_transactions" ENABLE ROW LEVEL SECURITY;

--
-- Name: customer_accounts; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."customer_accounts" ENABLE ROW LEVEL SECURITY;

--
-- Name: debug_log; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."debug_log" ENABLE ROW LEVEL SECURITY;

--
-- Name: exchange_rates; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."exchange_rates" ENABLE ROW LEVEL SECURITY;

--
-- Name: game_accounts; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."game_accounts" ENABLE ROW LEVEL SECURITY;

--
-- Name: level_exp; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."level_exp" ENABLE ROW LEVEL SECURITY;

--
-- Name: order_lines; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."order_lines" ENABLE ROW LEVEL SECURITY;

--
-- Name: order_reviews; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."order_reviews" ENABLE ROW LEVEL SECURITY;

--
-- Name: order_service_items; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."order_service_items" ENABLE ROW LEVEL SECURITY;

--
-- Name: orders; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."orders" ENABLE ROW LEVEL SECURITY;

--
-- Name: parties; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."parties" ENABLE ROW LEVEL SECURITY;

--
-- Name: permissions; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."permissions" ENABLE ROW LEVEL SECURITY;

--
-- Name: product_variant_attributes; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."product_variant_attributes" ENABLE ROW LEVEL SECURITY;

--
-- Name: product_variants; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."product_variants" ENABLE ROW LEVEL SECURITY;

--
-- Name: products; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."products" ENABLE ROW LEVEL SECURITY;

--
-- Name: profiles; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."profiles" ENABLE ROW LEVEL SECURITY;

--
-- Name: order_lines realtime_order_lines_read; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "realtime_order_lines_read" ON "public"."order_lines" FOR SELECT TO "supabase_realtime_admin" USING (true);


--
-- Name: order_reviews realtime_order_reviews_read; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "realtime_order_reviews_read" ON "public"."order_reviews" FOR SELECT TO "supabase_realtime_admin" USING (true);


--
-- Name: order_service_items realtime_order_service_items_read; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "realtime_order_service_items_read" ON "public"."order_service_items" FOR SELECT TO "supabase_realtime_admin" USING (true);


--
-- Name: orders realtime_orders_read; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "realtime_orders_read" ON "public"."orders" FOR SELECT TO "supabase_realtime_admin" USING (true);


--
-- Name: profiles realtime_profiles_read; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "realtime_profiles_read" ON "public"."profiles" FOR SELECT TO "supabase_realtime_admin" USING (true);


--
-- Name: work_sessions realtime_work_sessions_read; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "realtime_work_sessions_read" ON "public"."work_sessions" FOR SELECT TO "supabase_realtime_admin" USING (true);


--
-- Name: role_permissions; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."role_permissions" ENABLE ROW LEVEL SECURITY;

--
-- Name: roles; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."roles" ENABLE ROW LEVEL SECURITY;

--
-- Name: service_reports; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."service_reports" ENABLE ROW LEVEL SECURITY;

--
-- Name: system_logs; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."system_logs" ENABLE ROW LEVEL SECURITY;

--
-- Name: trading_fee_chains; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."trading_fee_chains" ENABLE ROW LEVEL SECURITY;

--
-- Name: user_role_assignments; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."user_role_assignments" ENABLE ROW LEVEL SECURITY;

--
-- Name: work_session_outputs; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."work_session_outputs" ENABLE ROW LEVEL SECURITY;

--
-- Name: work_sessions; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."work_sessions" ENABLE ROW LEVEL SECURITY;

--
-- Name: messages; Type: ROW SECURITY; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER TABLE "realtime"."messages" ENABLE ROW LEVEL SECURITY;

--
-- Name: objects Allow admins to delete proofs 1a09c6j_0; Type: POLICY; Schema: storage; Owner: supabase_storage_admin
--

CREATE POLICY "Allow admins to delete proofs 1a09c6j_0" ON "storage"."objects" FOR DELETE TO "authenticated" USING ((("bucket_id" = 'work-proofs'::"text") AND "public"."has_permission"('admin:manage_roles'::"text")));


--
-- Name: objects Allow authenticated users to update their proofs 1a09c6j_0; Type: POLICY; Schema: storage; Owner: supabase_storage_admin
--

CREATE POLICY "Allow authenticated users to update their proofs 1a09c6j_0" ON "storage"."objects" FOR UPDATE TO "authenticated" USING ((("bucket_id" = 'work-proofs'::"text") AND ("owner" = "auth"."uid"()))) WITH CHECK ((("bucket_id" = 'work-proofs'::"text") AND ("owner" = "auth"."uid"())));


--
-- Name: objects Allow authenticated users to upload proofs 1a09c6j_0; Type: POLICY; Schema: storage; Owner: supabase_storage_admin
--

CREATE POLICY "Allow authenticated users to upload proofs 1a09c6j_0" ON "storage"."objects" FOR INSERT TO "authenticated" WITH CHECK (("bucket_id" = 'work-proofs'::"text"));


--
-- Name: objects Allow authenticated users to view proofs 1a09c6j_0; Type: POLICY; Schema: storage; Owner: supabase_storage_admin
--

CREATE POLICY "Allow authenticated users to view proofs 1a09c6j_0" ON "storage"."objects" FOR SELECT TO "authenticated" USING (("bucket_id" = 'work-proofs'::"text"));


--
-- Name: buckets; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE "storage"."buckets" ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets_analytics; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE "storage"."buckets_analytics" ENABLE ROW LEVEL SECURITY;

--
-- Name: migrations; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE "storage"."migrations" ENABLE ROW LEVEL SECURITY;

--
-- Name: objects; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE "storage"."objects" ENABLE ROW LEVEL SECURITY;

--
-- Name: prefixes; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE "storage"."prefixes" ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE "storage"."s3_multipart_uploads" ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads_parts; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE "storage"."s3_multipart_uploads_parts" ENABLE ROW LEVEL SECURITY;

--
-- Name: objects storage service role all; Type: POLICY; Schema: storage; Owner: supabase_storage_admin
--

CREATE POLICY "storage service role all" ON "storage"."objects" USING (("auth"."role"() = 'service_role'::"text")) WITH CHECK (("auth"."role"() = 'service_role'::"text"));


--
-- Name: SCHEMA "auth"; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA "auth" TO "anon";
GRANT USAGE ON SCHEMA "auth" TO "authenticated";
GRANT USAGE ON SCHEMA "auth" TO "service_role";
GRANT ALL ON SCHEMA "auth" TO "supabase_auth_admin";
GRANT ALL ON SCHEMA "auth" TO "dashboard_user";
GRANT USAGE ON SCHEMA "auth" TO "postgres";


--
-- Name: SCHEMA "extensions"; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA "extensions" TO "anon";
GRANT USAGE ON SCHEMA "extensions" TO "authenticated";
GRANT USAGE ON SCHEMA "extensions" TO "service_role";
GRANT ALL ON SCHEMA "extensions" TO "dashboard_user";


--
-- Name: SCHEMA "public"; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA "public" FROM PUBLIC;
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT ALL ON SCHEMA "public" TO "service_role";


--
-- Name: SCHEMA "realtime"; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA "realtime" TO "postgres";
GRANT USAGE ON SCHEMA "realtime" TO "anon";
GRANT USAGE ON SCHEMA "realtime" TO "authenticated";
GRANT USAGE ON SCHEMA "realtime" TO "service_role";
GRANT ALL ON SCHEMA "realtime" TO "supabase_realtime_admin";


--
-- Name: SCHEMA "storage"; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA "storage" TO "postgres" WITH GRANT OPTION;
GRANT USAGE ON SCHEMA "storage" TO "anon";
GRANT USAGE ON SCHEMA "storage" TO "authenticated";
GRANT USAGE ON SCHEMA "storage" TO "service_role";
GRANT ALL ON SCHEMA "storage" TO "supabase_storage_admin";
GRANT ALL ON SCHEMA "storage" TO "dashboard_user";


--
-- Name: FUNCTION "email"(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION "auth"."email"() TO "dashboard_user";


--
-- Name: FUNCTION "jwt"(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION "auth"."jwt"() TO "postgres";
GRANT ALL ON FUNCTION "auth"."jwt"() TO "dashboard_user";


--
-- Name: FUNCTION "role"(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION "auth"."role"() TO "dashboard_user";


--
-- Name: FUNCTION "uid"(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION "auth"."uid"() TO "dashboard_user";


--
-- Name: FUNCTION "grant_pg_cron_access"(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

REVOKE ALL ON FUNCTION "extensions"."grant_pg_cron_access"() FROM "supabase_admin";
GRANT ALL ON FUNCTION "extensions"."grant_pg_cron_access"() TO "supabase_admin" WITH GRANT OPTION;
GRANT ALL ON FUNCTION "extensions"."grant_pg_cron_access"() TO "dashboard_user";


--
-- Name: FUNCTION "grant_pg_graphql_access"(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "extensions"."grant_pg_graphql_access"() TO "postgres" WITH GRANT OPTION;


--
-- Name: FUNCTION "grant_pg_net_access"(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

REVOKE ALL ON FUNCTION "extensions"."grant_pg_net_access"() FROM "supabase_admin";
GRANT ALL ON FUNCTION "extensions"."grant_pg_net_access"() TO "supabase_admin" WITH GRANT OPTION;
GRANT ALL ON FUNCTION "extensions"."grant_pg_net_access"() TO "dashboard_user";


--
-- Name: FUNCTION "pgrst_ddl_watch"(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "extensions"."pgrst_ddl_watch"() TO "postgres" WITH GRANT OPTION;


--
-- Name: FUNCTION "pgrst_drop_watch"(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "extensions"."pgrst_drop_watch"() TO "postgres" WITH GRANT OPTION;


--
-- Name: FUNCTION "set_graphql_placeholder"(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "extensions"."set_graphql_placeholder"() TO "postgres" WITH GRANT OPTION;


--
-- Name: FUNCTION "add_vault_secret"("p_name" "text", "p_secret" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."add_vault_secret"("p_name" "text", "p_secret" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."add_vault_secret"("p_name" "text", "p_secret" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."add_vault_secret"("p_name" "text", "p_secret" "text") TO "service_role";


--
-- Name: FUNCTION "admin_get_all_users"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."admin_get_all_users"() TO "anon";
GRANT ALL ON FUNCTION "public"."admin_get_all_users"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."admin_get_all_users"() TO "service_role";


--
-- Name: FUNCTION "admin_get_roles_and_permissions"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."admin_get_roles_and_permissions"() TO "anon";
GRANT ALL ON FUNCTION "public"."admin_get_roles_and_permissions"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."admin_get_roles_and_permissions"() TO "service_role";


--
-- Name: FUNCTION "admin_rebase_item_progress_v1"("p_service_item_id" "uuid", "p_authoritative_done_qty" numeric, "p_new_params" "jsonb", "p_reason" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."admin_rebase_item_progress_v1"("p_service_item_id" "uuid", "p_authoritative_done_qty" numeric, "p_new_params" "jsonb", "p_reason" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."admin_rebase_item_progress_v1"("p_service_item_id" "uuid", "p_authoritative_done_qty" numeric, "p_new_params" "jsonb", "p_reason" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."admin_rebase_item_progress_v1"("p_service_item_id" "uuid", "p_authoritative_done_qty" numeric, "p_new_params" "jsonb", "p_reason" "text") TO "service_role";


--
-- Name: FUNCTION "admin_update_permissions_for_role"("p_role_id" "uuid", "p_permission_ids" "uuid"[]); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."admin_update_permissions_for_role"("p_role_id" "uuid", "p_permission_ids" "uuid"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."admin_update_permissions_for_role"("p_role_id" "uuid", "p_permission_ids" "uuid"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."admin_update_permissions_for_role"("p_role_id" "uuid", "p_permission_ids" "uuid"[]) TO "service_role";


--
-- Name: FUNCTION "admin_update_user_assignments"("p_user_id" "uuid", "p_assignments" "jsonb"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."admin_update_user_assignments"("p_user_id" "uuid", "p_assignments" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."admin_update_user_assignments"("p_user_id" "uuid", "p_assignments" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."admin_update_user_assignments"("p_user_id" "uuid", "p_assignments" "jsonb") TO "service_role";


--
-- Name: FUNCTION "admin_update_user_status"("p_user_id" "uuid", "p_new_status" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."admin_update_user_status"("p_user_id" "uuid", "p_new_status" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."admin_update_user_status"("p_user_id" "uuid", "p_new_status" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."admin_update_user_status"("p_user_id" "uuid", "p_new_status" "text") TO "service_role";


--
-- Name: FUNCTION "archive_league_currency_v1"("p_from_league_id" "uuid", "p_to_league_id" "uuid", "p_archive_type" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."archive_league_currency_v1"("p_from_league_id" "uuid", "p_to_league_id" "uuid", "p_archive_type" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."archive_league_currency_v1"("p_from_league_id" "uuid", "p_to_league_id" "uuid", "p_archive_type" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."archive_league_currency_v1"("p_from_league_id" "uuid", "p_to_league_id" "uuid", "p_archive_type" "text") TO "service_role";


--
-- Name: FUNCTION "audit_ctx_v1"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."audit_ctx_v1"() TO "anon";
GRANT ALL ON FUNCTION "public"."audit_ctx_v1"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."audit_ctx_v1"() TO "service_role";


--
-- Name: FUNCTION "audit_diff_v1"("old_row" "jsonb", "new_row" "jsonb"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."audit_diff_v1"("old_row" "jsonb", "new_row" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."audit_diff_v1"("old_row" "jsonb", "new_row" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."audit_diff_v1"("old_row" "jsonb", "new_row" "jsonb") TO "service_role";


--
-- Name: FUNCTION "auto_create_inventory_records"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."auto_create_inventory_records"() TO "anon";
GRANT ALL ON FUNCTION "public"."auto_create_inventory_records"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."auto_create_inventory_records"() TO "service_role";


--
-- Name: FUNCTION "calculate_chain_costs"("p_chain_id" "uuid", "p_from_amount" numeric, "p_from_currency" "text", "p_to_currency" "text", "p_exchange_rates" "jsonb"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."calculate_chain_costs"("p_chain_id" "uuid", "p_from_amount" numeric, "p_from_currency" "text", "p_to_currency" "text", "p_exchange_rates" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."calculate_chain_costs"("p_chain_id" "uuid", "p_from_amount" numeric, "p_from_currency" "text", "p_to_currency" "text", "p_exchange_rates" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."calculate_chain_costs"("p_chain_id" "uuid", "p_from_amount" numeric, "p_from_currency" "text", "p_to_currency" "text", "p_exchange_rates" "jsonb") TO "service_role";


--
-- Name: FUNCTION "calculate_profit_for_order_v1"("p_order_line_id" "uuid"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."calculate_profit_for_order_v1"("p_order_line_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."calculate_profit_for_order_v1"("p_order_line_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."calculate_profit_for_order_v1"("p_order_line_id" "uuid") TO "service_role";


--
-- Name: FUNCTION "calculate_simple_profit_loss"("p_purchase_amount" numeric, "p_purchase_currency" "text", "p_sale_amount" numeric, "p_sale_currency" "text", "p_chain_id" "uuid", "p_exchange_rates" "jsonb"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."calculate_simple_profit_loss"("p_purchase_amount" numeric, "p_purchase_currency" "text", "p_sale_amount" numeric, "p_sale_currency" "text", "p_chain_id" "uuid", "p_exchange_rates" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."calculate_simple_profit_loss"("p_purchase_amount" numeric, "p_purchase_currency" "text", "p_sale_amount" numeric, "p_sale_currency" "text", "p_chain_id" "uuid", "p_exchange_rates" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."calculate_simple_profit_loss"("p_purchase_amount" numeric, "p_purchase_currency" "text", "p_sale_amount" numeric, "p_sale_currency" "text", "p_chain_id" "uuid", "p_exchange_rates" "jsonb") TO "service_role";


--
-- Name: FUNCTION "can_assign_pilot_order"("p_order_id" "uuid"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."can_assign_pilot_order"("p_order_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."can_assign_pilot_order"("p_order_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."can_assign_pilot_order"("p_order_id" "uuid") TO "service_role";


--
-- Name: FUNCTION "cancel_order_line_v1"("p_line_id" "uuid", "p_cancellation_proof_urls" "text"[], "p_reason" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."cancel_order_line_v1"("p_line_id" "uuid", "p_cancellation_proof_urls" "text"[], "p_reason" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."cancel_order_line_v1"("p_line_id" "uuid", "p_cancellation_proof_urls" "text"[], "p_reason" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."cancel_order_line_v1"("p_line_id" "uuid", "p_cancellation_proof_urls" "text"[], "p_reason" "text") TO "service_role";


--
-- Name: FUNCTION "cancel_work_session_v1"("p_session_id" "uuid"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."cancel_work_session_v1"("p_session_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."cancel_work_session_v1"("p_session_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."cancel_work_session_v1"("p_session_id" "uuid") TO "service_role";


--
-- Name: FUNCTION "check_and_reset_pilot_cycle"("p_order_line_id" "uuid"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."check_and_reset_pilot_cycle"("p_order_line_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."check_and_reset_pilot_cycle"("p_order_line_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_and_reset_pilot_cycle"("p_order_line_id" "uuid") TO "service_role";


--
-- Name: FUNCTION "complete_order_line_v1"("p_line_id" "uuid", "p_completion_proof_urls" "text"[], "p_reason" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."complete_order_line_v1"("p_line_id" "uuid", "p_completion_proof_urls" "text"[], "p_reason" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."complete_order_line_v1"("p_line_id" "uuid", "p_completion_proof_urls" "text"[], "p_reason" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."complete_order_line_v1"("p_line_id" "uuid", "p_completion_proof_urls" "text"[], "p_reason" "text") TO "service_role";


--
-- Name: FUNCTION "create_currency_sell_order_v1"("p_game_account_id" "uuid", "p_currency_attribute_id" "uuid", "p_quantity" numeric, "p_unit_price_vnd" numeric, "p_unit_price_usd" numeric, "p_channel_id" "uuid", "p_customer_name" "text", "p_game_tag" "text", "p_delivery_info" "text", "p_order_line_id" "uuid", "p_notes" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."create_currency_sell_order_v1"("p_game_account_id" "uuid", "p_currency_attribute_id" "uuid", "p_quantity" numeric, "p_unit_price_vnd" numeric, "p_unit_price_usd" numeric, "p_channel_id" "uuid", "p_customer_name" "text", "p_game_tag" "text", "p_delivery_info" "text", "p_order_line_id" "uuid", "p_notes" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."create_currency_sell_order_v1"("p_game_account_id" "uuid", "p_currency_attribute_id" "uuid", "p_quantity" numeric, "p_unit_price_vnd" numeric, "p_unit_price_usd" numeric, "p_channel_id" "uuid", "p_customer_name" "text", "p_game_tag" "text", "p_delivery_info" "text", "p_order_line_id" "uuid", "p_notes" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_currency_sell_order_v1"("p_game_account_id" "uuid", "p_currency_attribute_id" "uuid", "p_quantity" numeric, "p_unit_price_vnd" numeric, "p_unit_price_usd" numeric, "p_channel_id" "uuid", "p_customer_name" "text", "p_game_tag" "text", "p_delivery_info" "text", "p_order_line_id" "uuid", "p_notes" "text") TO "service_role";


--
-- Name: FUNCTION "create_service_order_v1"("p_channel_code" "text", "p_service_type" "text", "p_customer_name" "text", "p_deadline" timestamp with time zone, "p_price" numeric, "p_currency_code" "text", "p_package_type" "text", "p_package_note" "text", "p_customer_account_id" "uuid", "p_new_account_details" "jsonb", "p_game_code" "text", "p_service_items" "jsonb"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."create_service_order_v1"("p_channel_code" "text", "p_service_type" "text", "p_customer_name" "text", "p_deadline" timestamp with time zone, "p_price" numeric, "p_currency_code" "text", "p_package_type" "text", "p_package_note" "text", "p_customer_account_id" "uuid", "p_new_account_details" "jsonb", "p_game_code" "text", "p_service_items" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."create_service_order_v1"("p_channel_code" "text", "p_service_type" "text", "p_customer_name" "text", "p_deadline" timestamp with time zone, "p_price" numeric, "p_currency_code" "text", "p_package_type" "text", "p_package_note" "text", "p_customer_account_id" "uuid", "p_new_account_details" "jsonb", "p_game_code" "text", "p_service_items" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_service_order_v1"("p_channel_code" "text", "p_service_type" "text", "p_customer_name" "text", "p_deadline" timestamp with time zone, "p_price" numeric, "p_currency_code" "text", "p_package_type" "text", "p_package_note" "text", "p_customer_account_id" "uuid", "p_new_account_details" "jsonb", "p_game_code" "text", "p_service_items" "jsonb") TO "service_role";


--
-- Name: FUNCTION "create_service_report_v1"("p_order_service_item_id" "uuid", "p_description" "text", "p_proof_urls" "text"[]); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."create_service_report_v1"("p_order_service_item_id" "uuid", "p_description" "text", "p_proof_urls" "text"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."create_service_report_v1"("p_order_service_item_id" "uuid", "p_description" "text", "p_proof_urls" "text"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_service_report_v1"("p_order_service_item_id" "uuid", "p_description" "text", "p_proof_urls" "text"[]) TO "service_role";


--
-- Name: FUNCTION "current_user_id"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."current_user_id"() TO "anon";
GRANT ALL ON FUNCTION "public"."current_user_id"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."current_user_id"() TO "service_role";


--
-- Name: FUNCTION "exchange_currency_v1"("p_from_account_id" "uuid", "p_from_currency_id" "uuid", "p_to_currency_id" "uuid", "p_from_quantity" numeric, "p_to_quantity" numeric, "p_exchange_rate" numeric, "p_notes" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."exchange_currency_v1"("p_from_account_id" "uuid", "p_from_currency_id" "uuid", "p_to_currency_id" "uuid", "p_from_quantity" numeric, "p_to_quantity" numeric, "p_exchange_rate" numeric, "p_notes" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."exchange_currency_v1"("p_from_account_id" "uuid", "p_from_currency_id" "uuid", "p_to_currency_id" "uuid", "p_from_quantity" numeric, "p_to_quantity" numeric, "p_exchange_rate" numeric, "p_notes" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."exchange_currency_v1"("p_from_account_id" "uuid", "p_from_currency_id" "uuid", "p_to_currency_id" "uuid", "p_from_quantity" numeric, "p_to_quantity" numeric, "p_exchange_rate" numeric, "p_notes" "text") TO "service_role";


--
-- Name: FUNCTION "finish_work_session_idem_v1"("p_session_id" "uuid", "p_outputs" "jsonb", "p_activity_rows" "jsonb", "p_overrun_reason" "text", "p_idem_key" "text", "p_overrun_type" "text", "p_overrun_proof_urls" "text"[]); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."finish_work_session_idem_v1"("p_session_id" "uuid", "p_outputs" "jsonb", "p_activity_rows" "jsonb", "p_overrun_reason" "text", "p_idem_key" "text", "p_overrun_type" "text", "p_overrun_proof_urls" "text"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."finish_work_session_idem_v1"("p_session_id" "uuid", "p_outputs" "jsonb", "p_activity_rows" "jsonb", "p_overrun_reason" "text", "p_idem_key" "text", "p_overrun_type" "text", "p_overrun_proof_urls" "text"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."finish_work_session_idem_v1"("p_session_id" "uuid", "p_outputs" "jsonb", "p_activity_rows" "jsonb", "p_overrun_reason" "text", "p_idem_key" "text", "p_overrun_type" "text", "p_overrun_proof_urls" "text"[]) TO "service_role";


--
-- Name: FUNCTION "fulfill_currency_order_v1"("p_transaction_id" "uuid", "p_proof_urls" "text"[], "p_completion_notes" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."fulfill_currency_order_v1"("p_transaction_id" "uuid", "p_proof_urls" "text"[], "p_completion_notes" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."fulfill_currency_order_v1"("p_transaction_id" "uuid", "p_proof_urls" "text"[], "p_completion_notes" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."fulfill_currency_order_v1"("p_transaction_id" "uuid", "p_proof_urls" "text"[], "p_completion_notes" "text") TO "service_role";


--
-- Name: FUNCTION "get_boosting_filter_options"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."get_boosting_filter_options"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_boosting_filter_options"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_boosting_filter_options"() TO "service_role";


--
-- Name: FUNCTION "get_boosting_order_detail_v1"("p_line_id" "uuid"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."get_boosting_order_detail_v1"("p_line_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_boosting_order_detail_v1"("p_line_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_boosting_order_detail_v1"("p_line_id" "uuid") TO "service_role";


--
-- Name: FUNCTION "get_boosting_orders_v3"("p_limit" integer, "p_offset" integer, "p_channels" "text"[], "p_statuses" "text"[], "p_service_types" "text"[], "p_package_types" "text"[], "p_customer_name" "text", "p_assignee" "text", "p_delivery_status" "text", "p_review_status" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."get_boosting_orders_v3"("p_limit" integer, "p_offset" integer, "p_channels" "text"[], "p_statuses" "text"[], "p_service_types" "text"[], "p_package_types" "text"[], "p_customer_name" "text", "p_assignee" "text", "p_delivery_status" "text", "p_review_status" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_boosting_orders_v3"("p_limit" integer, "p_offset" integer, "p_channels" "text"[], "p_statuses" "text"[], "p_service_types" "text"[], "p_package_types" "text"[], "p_customer_name" "text", "p_assignee" "text", "p_delivery_status" "text", "p_review_status" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_boosting_orders_v3"("p_limit" integer, "p_offset" integer, "p_channels" "text"[], "p_statuses" "text"[], "p_service_types" "text"[], "p_package_types" "text"[], "p_customer_name" "text", "p_assignee" "text", "p_delivery_status" "text", "p_review_status" "text") TO "service_role";


--
-- Name: FUNCTION "get_channel_fee_chain"("p_channel_id" "uuid"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."get_channel_fee_chain"("p_channel_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_channel_fee_chain"("p_channel_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_channel_fee_chain"("p_channel_id" "uuid") TO "service_role";


--
-- Name: FUNCTION "get_currency_inventory_summary_v1"("p_game_code" "text", "p_league_attribute_id" "uuid"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."get_currency_inventory_summary_v1"("p_game_code" "text", "p_league_attribute_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_currency_inventory_summary_v1"("p_game_code" "text", "p_league_attribute_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_currency_inventory_summary_v1"("p_game_code" "text", "p_league_attribute_id" "uuid") TO "service_role";


--
-- Name: FUNCTION "get_currency_transaction_history_v1"("p_game_code" "text", "p_league_id" "uuid", "p_transaction_type" "text", "p_currency_id" "uuid", "p_account_id" "uuid", "p_start_date" timestamp with time zone, "p_end_date" timestamp with time zone, "p_limit" bigint, "p_offset" bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."get_currency_transaction_history_v1"("p_game_code" "text", "p_league_id" "uuid", "p_transaction_type" "text", "p_currency_id" "uuid", "p_account_id" "uuid", "p_start_date" timestamp with time zone, "p_end_date" timestamp with time zone, "p_limit" bigint, "p_offset" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."get_currency_transaction_history_v1"("p_game_code" "text", "p_league_id" "uuid", "p_transaction_type" "text", "p_currency_id" "uuid", "p_account_id" "uuid", "p_start_date" timestamp with time zone, "p_end_date" timestamp with time zone, "p_limit" bigint, "p_offset" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_currency_transaction_history_v1"("p_game_code" "text", "p_league_id" "uuid", "p_transaction_type" "text", "p_currency_id" "uuid", "p_account_id" "uuid", "p_start_date" timestamp with time zone, "p_end_date" timestamp with time zone, "p_limit" bigint, "p_offset" bigint) TO "service_role";


--
-- Name: FUNCTION "get_current_profile_id"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."get_current_profile_id"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_current_profile_id"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_current_profile_id"() TO "service_role";


--
-- Name: FUNCTION "get_customers_by_channel_v1"("p_channel_code" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."get_customers_by_channel_v1"("p_channel_code" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_customers_by_channel_v1"("p_channel_code" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_customers_by_channel_v1"("p_channel_code" "text") TO "service_role";


--
-- Name: FUNCTION "get_game_leagues_v1"("p_game_code" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."get_game_leagues_v1"("p_game_code" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_game_leagues_v1"("p_game_code" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_game_leagues_v1"("p_game_code" "text") TO "service_role";


--
-- Name: FUNCTION "get_games_v1"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."get_games_v1"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_games_v1"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_games_v1"() TO "service_role";


--
-- Name: FUNCTION "get_last_item_proof_v1"("p_item_ids" "uuid"[]); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."get_last_item_proof_v1"("p_item_ids" "uuid"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."get_last_item_proof_v1"("p_item_ids" "uuid"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_last_item_proof_v1"("p_item_ids" "uuid"[]) TO "service_role";


--
-- Name: FUNCTION "get_my_assignments"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."get_my_assignments"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_my_assignments"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_my_assignments"() TO "service_role";


--
-- Name: FUNCTION "get_primary_user_role_v1"("p_user_id" "uuid"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."get_primary_user_role_v1"("p_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_primary_user_role_v1"("p_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_primary_user_role_v1"("p_user_id" "uuid") TO "service_role";


--
-- Name: FUNCTION "get_reviews_for_order_line_v1"("p_line_id" "uuid"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."get_reviews_for_order_line_v1"("p_line_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_reviews_for_order_line_v1"("p_line_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_reviews_for_order_line_v1"("p_line_id" "uuid") TO "service_role";


--
-- Name: FUNCTION "get_service_reports_v1"("p_status" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."get_service_reports_v1"("p_status" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_service_reports_v1"("p_status" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_service_reports_v1"("p_status" "text") TO "service_role";


--
-- Name: FUNCTION "get_session_history_v2"("p_line_id" "uuid"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."get_session_history_v2"("p_line_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_session_history_v2"("p_line_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_session_history_v2"("p_line_id" "uuid") TO "service_role";


--
-- Name: FUNCTION "get_user_auth_context_v1"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."get_user_auth_context_v1"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_user_auth_context_v1"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_user_auth_context_v1"() TO "service_role";


--
-- Name: FUNCTION "get_user_roles_v1"("p_user_id" "uuid"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."get_user_roles_v1"("p_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_user_roles_v1"("p_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_user_roles_v1"("p_user_id" "uuid") TO "service_role";


--
-- Name: FUNCTION "handle_new_user_with_trial_role"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."handle_new_user_with_trial_role"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user_with_trial_role"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user_with_trial_role"() TO "service_role";


--
-- Name: FUNCTION "handle_orders_updated_at"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."handle_orders_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_orders_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_orders_updated_at"() TO "service_role";


--
-- Name: FUNCTION "has_permission"("p_permission_code" "text", "p_context" "jsonb"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."has_permission"("p_permission_code" "text", "p_context" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."has_permission"("p_permission_code" "text", "p_context" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."has_permission"("p_permission_code" "text", "p_context" "jsonb") TO "service_role";


--
-- Name: FUNCTION "manual_reset_pilot_cycle"("p_pilot_cycle_id" "uuid", "p_reason" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."manual_reset_pilot_cycle"("p_pilot_cycle_id" "uuid", "p_reason" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."manual_reset_pilot_cycle"("p_pilot_cycle_id" "uuid", "p_reason" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."manual_reset_pilot_cycle"("p_pilot_cycle_id" "uuid", "p_reason" "text") TO "service_role";


--
-- Name: FUNCTION "mark_order_as_delivered_v1"("p_order_id" "uuid", "p_is_delivered" boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."mark_order_as_delivered_v1"("p_order_id" "uuid", "p_is_delivered" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."mark_order_as_delivered_v1"("p_order_id" "uuid", "p_is_delivered" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."mark_order_as_delivered_v1"("p_order_id" "uuid", "p_is_delivered" boolean) TO "service_role";


--
-- Name: FUNCTION "payout_farmer_v1"("p_farmer_profile_id" "uuid", "p_game_account_id" "uuid", "p_currency_attribute_id" "uuid", "p_quantity" numeric, "p_payout_rate_vnd" numeric, "p_payout_rate_usd" numeric, "p_exchange_rate_vnd_per_usd" numeric, "p_notes" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."payout_farmer_v1"("p_farmer_profile_id" "uuid", "p_game_account_id" "uuid", "p_currency_attribute_id" "uuid", "p_quantity" numeric, "p_payout_rate_vnd" numeric, "p_payout_rate_usd" numeric, "p_exchange_rate_vnd_per_usd" numeric, "p_notes" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."payout_farmer_v1"("p_farmer_profile_id" "uuid", "p_game_account_id" "uuid", "p_currency_attribute_id" "uuid", "p_quantity" numeric, "p_payout_rate_vnd" numeric, "p_payout_rate_usd" numeric, "p_exchange_rate_vnd_per_usd" numeric, "p_notes" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."payout_farmer_v1"("p_farmer_profile_id" "uuid", "p_game_account_id" "uuid", "p_currency_attribute_id" "uuid", "p_quantity" numeric, "p_payout_rate_vnd" numeric, "p_payout_rate_usd" numeric, "p_exchange_rate_vnd_per_usd" numeric, "p_notes" "text") TO "service_role";


--
-- Name: FUNCTION "protect_account_with_currency"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."protect_account_with_currency"() TO "anon";
GRANT ALL ON FUNCTION "public"."protect_account_with_currency"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."protect_account_with_currency"() TO "service_role";


--
-- Name: FUNCTION "record_currency_purchase_v1"("p_game_account_id" "uuid", "p_currency_attribute_id" "uuid", "p_quantity" numeric, "p_unit_price_vnd" numeric, "p_unit_price_usd" numeric, "p_exchange_rate_vnd_per_usd" numeric, "p_partner_id" "uuid", "p_proof_urls" "text"[], "p_notes" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."record_currency_purchase_v1"("p_game_account_id" "uuid", "p_currency_attribute_id" "uuid", "p_quantity" numeric, "p_unit_price_vnd" numeric, "p_unit_price_usd" numeric, "p_exchange_rate_vnd_per_usd" numeric, "p_partner_id" "uuid", "p_proof_urls" "text"[], "p_notes" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."record_currency_purchase_v1"("p_game_account_id" "uuid", "p_currency_attribute_id" "uuid", "p_quantity" numeric, "p_unit_price_vnd" numeric, "p_unit_price_usd" numeric, "p_exchange_rate_vnd_per_usd" numeric, "p_partner_id" "uuid", "p_proof_urls" "text"[], "p_notes" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."record_currency_purchase_v1"("p_game_account_id" "uuid", "p_currency_attribute_id" "uuid", "p_quantity" numeric, "p_unit_price_vnd" numeric, "p_unit_price_usd" numeric, "p_exchange_rate_vnd_per_usd" numeric, "p_partner_id" "uuid", "p_proof_urls" "text"[], "p_notes" "text") TO "service_role";


--
-- Name: FUNCTION "reset_eligible_pilot_cycles"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."reset_eligible_pilot_cycles"() TO "anon";
GRANT ALL ON FUNCTION "public"."reset_eligible_pilot_cycles"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."reset_eligible_pilot_cycles"() TO "service_role";


--
-- Name: FUNCTION "reset_pilot_cycle_on_completion"("p_order_id" "uuid"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."reset_pilot_cycle_on_completion"("p_order_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."reset_pilot_cycle_on_completion"("p_order_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."reset_pilot_cycle_on_completion"("p_order_id" "uuid") TO "service_role";


--
-- Name: FUNCTION "resolve_service_report_v1"("p_report_id" "uuid", "p_resolver_notes" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."resolve_service_report_v1"("p_report_id" "uuid", "p_resolver_notes" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."resolve_service_report_v1"("p_report_id" "uuid", "p_resolver_notes" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."resolve_service_report_v1"("p_report_id" "uuid", "p_resolver_notes" "text") TO "service_role";


--
-- Name: FUNCTION "start_work_session_v1"("p_order_line_id" "uuid", "p_start_state" "jsonb", "p_initial_note" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."start_work_session_v1"("p_order_line_id" "uuid", "p_start_state" "jsonb", "p_initial_note" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."start_work_session_v1"("p_order_line_id" "uuid", "p_start_state" "jsonb", "p_initial_note" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."start_work_session_v1"("p_order_line_id" "uuid", "p_start_state" "jsonb", "p_initial_note" "text") TO "service_role";


--
-- Name: FUNCTION "submit_order_review_v1"("p_line_id" "uuid", "p_rating" numeric, "p_comment" "text", "p_proof_urls" "text"[]); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."submit_order_review_v1"("p_line_id" "uuid", "p_rating" numeric, "p_comment" "text", "p_proof_urls" "text"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."submit_order_review_v1"("p_line_id" "uuid", "p_rating" numeric, "p_comment" "text", "p_proof_urls" "text"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."submit_order_review_v1"("p_line_id" "uuid", "p_rating" numeric, "p_comment" "text", "p_proof_urls" "text"[]) TO "service_role";


--
-- Name: FUNCTION "toggle_customer_playing"("p_order_id" "uuid", "p_enable_customer_playing" boolean, "p_current_user_id" "uuid"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."toggle_customer_playing"("p_order_id" "uuid", "p_enable_customer_playing" boolean, "p_current_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."toggle_customer_playing"("p_order_id" "uuid", "p_enable_customer_playing" boolean, "p_current_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."toggle_customer_playing"("p_order_id" "uuid", "p_enable_customer_playing" boolean, "p_current_user_id" "uuid") TO "service_role";


--
-- Name: FUNCTION "tr_audit_row_v1"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."tr_audit_row_v1"() TO "anon";
GRANT ALL ON FUNCTION "public"."tr_audit_row_v1"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tr_audit_row_v1"() TO "service_role";


--
-- Name: FUNCTION "tr_auto_initialize_pilot_cycle_on_first_session"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."tr_auto_initialize_pilot_cycle_on_first_session"() TO "anon";
GRANT ALL ON FUNCTION "public"."tr_auto_initialize_pilot_cycle_on_first_session"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tr_auto_initialize_pilot_cycle_on_first_session"() TO "service_role";


--
-- Name: FUNCTION "tr_auto_initialize_pilot_cycle_on_order_create"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."tr_auto_initialize_pilot_cycle_on_order_create"() TO "anon";
GRANT ALL ON FUNCTION "public"."tr_auto_initialize_pilot_cycle_on_order_create"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tr_auto_initialize_pilot_cycle_on_order_create"() TO "service_role";


--
-- Name: FUNCTION "tr_auto_update_pilot_cycle_on_pause_change"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."tr_auto_update_pilot_cycle_on_pause_change"() TO "anon";
GRANT ALL ON FUNCTION "public"."tr_auto_update_pilot_cycle_on_pause_change"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tr_auto_update_pilot_cycle_on_pause_change"() TO "service_role";


--
-- Name: FUNCTION "tr_auto_update_pilot_cycle_on_session_end"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."tr_auto_update_pilot_cycle_on_session_end"() TO "anon";
GRANT ALL ON FUNCTION "public"."tr_auto_update_pilot_cycle_on_session_end"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tr_auto_update_pilot_cycle_on_session_end"() TO "service_role";


--
-- Name: FUNCTION "tr_auto_update_pilot_cycle_on_status_change"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."tr_auto_update_pilot_cycle_on_status_change"() TO "anon";
GRANT ALL ON FUNCTION "public"."tr_auto_update_pilot_cycle_on_status_change"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tr_auto_update_pilot_cycle_on_status_change"() TO "service_role";


--
-- Name: FUNCTION "tr_check_all_items_completed_v1"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."tr_check_all_items_completed_v1"() TO "anon";
GRANT ALL ON FUNCTION "public"."tr_check_all_items_completed_v1"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tr_check_all_items_completed_v1"() TO "service_role";


--
-- Name: FUNCTION "try_uuid"("p" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."try_uuid"("p" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."try_uuid"("p" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."try_uuid"("p" "text") TO "service_role";


--
-- Name: FUNCTION "update_action_proofs_v1"("p_line_id" "uuid", "p_new_urls" "text"[]); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."update_action_proofs_v1"("p_line_id" "uuid", "p_new_urls" "text"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."update_action_proofs_v1"("p_line_id" "uuid", "p_new_urls" "text"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_action_proofs_v1"("p_line_id" "uuid", "p_new_urls" "text"[]) TO "service_role";


--
-- Name: FUNCTION "update_currency_inventory"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."update_currency_inventory"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_currency_inventory"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_currency_inventory"() TO "service_role";


--
-- Name: FUNCTION "update_order_details_v1"("p_line_id" "uuid", "p_service_type" "text", "p_deadline" timestamp with time zone, "p_package_note" "text", "p_btag" "text", "p_login_id" "text", "p_login_pwd" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."update_order_details_v1"("p_line_id" "uuid", "p_service_type" "text", "p_deadline" timestamp with time zone, "p_package_note" "text", "p_btag" "text", "p_login_id" "text", "p_login_pwd" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."update_order_details_v1"("p_line_id" "uuid", "p_service_type" "text", "p_deadline" timestamp with time zone, "p_package_note" "text", "p_btag" "text", "p_login_id" "text", "p_login_pwd" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_order_details_v1"("p_line_id" "uuid", "p_service_type" "text", "p_deadline" timestamp with time zone, "p_package_note" "text", "p_btag" "text", "p_login_id" "text", "p_login_pwd" "text") TO "service_role";


--
-- Name: FUNCTION "update_order_line_machine_info_v1"("p_line_id" "uuid", "p_machine_info" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."update_order_line_machine_info_v1"("p_line_id" "uuid", "p_machine_info" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."update_order_line_machine_info_v1"("p_line_id" "uuid", "p_machine_info" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_order_line_machine_info_v1"("p_line_id" "uuid", "p_machine_info" "text") TO "service_role";


--
-- Name: FUNCTION "update_pilot_cycle_warning"("p_order_line_id" "uuid"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."update_pilot_cycle_warning"("p_order_line_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."update_pilot_cycle_warning"("p_order_line_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_pilot_cycle_warning"("p_order_line_id" "uuid") TO "service_role";


--
-- Name: FUNCTION "update_updated_at_column"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "service_role";


--
-- Name: FUNCTION "apply_rls"("wal" "jsonb", "max_record_bytes" integer); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "realtime"."apply_rls"("wal" "jsonb", "max_record_bytes" integer) TO "postgres";
GRANT ALL ON FUNCTION "realtime"."apply_rls"("wal" "jsonb", "max_record_bytes" integer) TO "dashboard_user";
GRANT ALL ON FUNCTION "realtime"."apply_rls"("wal" "jsonb", "max_record_bytes" integer) TO "anon";
GRANT ALL ON FUNCTION "realtime"."apply_rls"("wal" "jsonb", "max_record_bytes" integer) TO "authenticated";
GRANT ALL ON FUNCTION "realtime"."apply_rls"("wal" "jsonb", "max_record_bytes" integer) TO "service_role";
GRANT ALL ON FUNCTION "realtime"."apply_rls"("wal" "jsonb", "max_record_bytes" integer) TO "supabase_realtime_admin";


--
-- Name: FUNCTION "broadcast_changes"("topic_name" "text", "event_name" "text", "operation" "text", "table_name" "text", "table_schema" "text", "new" "record", "old" "record", "level" "text"); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "realtime"."broadcast_changes"("topic_name" "text", "event_name" "text", "operation" "text", "table_name" "text", "table_schema" "text", "new" "record", "old" "record", "level" "text") TO "postgres";
GRANT ALL ON FUNCTION "realtime"."broadcast_changes"("topic_name" "text", "event_name" "text", "operation" "text", "table_name" "text", "table_schema" "text", "new" "record", "old" "record", "level" "text") TO "dashboard_user";


--
-- Name: FUNCTION "build_prepared_statement_sql"("prepared_statement_name" "text", "entity" "regclass", "columns" "realtime"."wal_column"[]); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "realtime"."build_prepared_statement_sql"("prepared_statement_name" "text", "entity" "regclass", "columns" "realtime"."wal_column"[]) TO "postgres";
GRANT ALL ON FUNCTION "realtime"."build_prepared_statement_sql"("prepared_statement_name" "text", "entity" "regclass", "columns" "realtime"."wal_column"[]) TO "dashboard_user";
GRANT ALL ON FUNCTION "realtime"."build_prepared_statement_sql"("prepared_statement_name" "text", "entity" "regclass", "columns" "realtime"."wal_column"[]) TO "anon";
GRANT ALL ON FUNCTION "realtime"."build_prepared_statement_sql"("prepared_statement_name" "text", "entity" "regclass", "columns" "realtime"."wal_column"[]) TO "authenticated";
GRANT ALL ON FUNCTION "realtime"."build_prepared_statement_sql"("prepared_statement_name" "text", "entity" "regclass", "columns" "realtime"."wal_column"[]) TO "service_role";
GRANT ALL ON FUNCTION "realtime"."build_prepared_statement_sql"("prepared_statement_name" "text", "entity" "regclass", "columns" "realtime"."wal_column"[]) TO "supabase_realtime_admin";


--
-- Name: FUNCTION "cast"("val" "text", "type_" "regtype"); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "realtime"."cast"("val" "text", "type_" "regtype") TO "postgres";
GRANT ALL ON FUNCTION "realtime"."cast"("val" "text", "type_" "regtype") TO "dashboard_user";
GRANT ALL ON FUNCTION "realtime"."cast"("val" "text", "type_" "regtype") TO "anon";
GRANT ALL ON FUNCTION "realtime"."cast"("val" "text", "type_" "regtype") TO "authenticated";
GRANT ALL ON FUNCTION "realtime"."cast"("val" "text", "type_" "regtype") TO "service_role";
GRANT ALL ON FUNCTION "realtime"."cast"("val" "text", "type_" "regtype") TO "supabase_realtime_admin";


--
-- Name: FUNCTION "check_equality_op"("op" "realtime"."equality_op", "type_" "regtype", "val_1" "text", "val_2" "text"); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "realtime"."check_equality_op"("op" "realtime"."equality_op", "type_" "regtype", "val_1" "text", "val_2" "text") TO "postgres";
GRANT ALL ON FUNCTION "realtime"."check_equality_op"("op" "realtime"."equality_op", "type_" "regtype", "val_1" "text", "val_2" "text") TO "dashboard_user";
GRANT ALL ON FUNCTION "realtime"."check_equality_op"("op" "realtime"."equality_op", "type_" "regtype", "val_1" "text", "val_2" "text") TO "anon";
GRANT ALL ON FUNCTION "realtime"."check_equality_op"("op" "realtime"."equality_op", "type_" "regtype", "val_1" "text", "val_2" "text") TO "authenticated";
GRANT ALL ON FUNCTION "realtime"."check_equality_op"("op" "realtime"."equality_op", "type_" "regtype", "val_1" "text", "val_2" "text") TO "service_role";
GRANT ALL ON FUNCTION "realtime"."check_equality_op"("op" "realtime"."equality_op", "type_" "regtype", "val_1" "text", "val_2" "text") TO "supabase_realtime_admin";


--
-- Name: FUNCTION "is_visible_through_filters"("columns" "realtime"."wal_column"[], "filters" "realtime"."user_defined_filter"[]); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "realtime"."is_visible_through_filters"("columns" "realtime"."wal_column"[], "filters" "realtime"."user_defined_filter"[]) TO "postgres";
GRANT ALL ON FUNCTION "realtime"."is_visible_through_filters"("columns" "realtime"."wal_column"[], "filters" "realtime"."user_defined_filter"[]) TO "dashboard_user";
GRANT ALL ON FUNCTION "realtime"."is_visible_through_filters"("columns" "realtime"."wal_column"[], "filters" "realtime"."user_defined_filter"[]) TO "anon";
GRANT ALL ON FUNCTION "realtime"."is_visible_through_filters"("columns" "realtime"."wal_column"[], "filters" "realtime"."user_defined_filter"[]) TO "authenticated";
GRANT ALL ON FUNCTION "realtime"."is_visible_through_filters"("columns" "realtime"."wal_column"[], "filters" "realtime"."user_defined_filter"[]) TO "service_role";
GRANT ALL ON FUNCTION "realtime"."is_visible_through_filters"("columns" "realtime"."wal_column"[], "filters" "realtime"."user_defined_filter"[]) TO "supabase_realtime_admin";


--
-- Name: FUNCTION "list_changes"("publication" "name", "slot_name" "name", "max_changes" integer, "max_record_bytes" integer); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "realtime"."list_changes"("publication" "name", "slot_name" "name", "max_changes" integer, "max_record_bytes" integer) TO "postgres";
GRANT ALL ON FUNCTION "realtime"."list_changes"("publication" "name", "slot_name" "name", "max_changes" integer, "max_record_bytes" integer) TO "dashboard_user";
GRANT ALL ON FUNCTION "realtime"."list_changes"("publication" "name", "slot_name" "name", "max_changes" integer, "max_record_bytes" integer) TO "anon";
GRANT ALL ON FUNCTION "realtime"."list_changes"("publication" "name", "slot_name" "name", "max_changes" integer, "max_record_bytes" integer) TO "authenticated";
GRANT ALL ON FUNCTION "realtime"."list_changes"("publication" "name", "slot_name" "name", "max_changes" integer, "max_record_bytes" integer) TO "service_role";
GRANT ALL ON FUNCTION "realtime"."list_changes"("publication" "name", "slot_name" "name", "max_changes" integer, "max_record_bytes" integer) TO "supabase_realtime_admin";


--
-- Name: FUNCTION "quote_wal2json"("entity" "regclass"); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "realtime"."quote_wal2json"("entity" "regclass") TO "postgres";
GRANT ALL ON FUNCTION "realtime"."quote_wal2json"("entity" "regclass") TO "dashboard_user";
GRANT ALL ON FUNCTION "realtime"."quote_wal2json"("entity" "regclass") TO "anon";
GRANT ALL ON FUNCTION "realtime"."quote_wal2json"("entity" "regclass") TO "authenticated";
GRANT ALL ON FUNCTION "realtime"."quote_wal2json"("entity" "regclass") TO "service_role";
GRANT ALL ON FUNCTION "realtime"."quote_wal2json"("entity" "regclass") TO "supabase_realtime_admin";


--
-- Name: FUNCTION "send"("payload" "jsonb", "event" "text", "topic" "text", "private" boolean); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "realtime"."send"("payload" "jsonb", "event" "text", "topic" "text", "private" boolean) TO "postgres";
GRANT ALL ON FUNCTION "realtime"."send"("payload" "jsonb", "event" "text", "topic" "text", "private" boolean) TO "dashboard_user";


--
-- Name: FUNCTION "subscription_check_filters"(); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "realtime"."subscription_check_filters"() TO "postgres";
GRANT ALL ON FUNCTION "realtime"."subscription_check_filters"() TO "dashboard_user";
GRANT ALL ON FUNCTION "realtime"."subscription_check_filters"() TO "anon";
GRANT ALL ON FUNCTION "realtime"."subscription_check_filters"() TO "authenticated";
GRANT ALL ON FUNCTION "realtime"."subscription_check_filters"() TO "service_role";
GRANT ALL ON FUNCTION "realtime"."subscription_check_filters"() TO "supabase_realtime_admin";


--
-- Name: FUNCTION "to_regrole"("role_name" "text"); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "realtime"."to_regrole"("role_name" "text") TO "postgres";
GRANT ALL ON FUNCTION "realtime"."to_regrole"("role_name" "text") TO "dashboard_user";
GRANT ALL ON FUNCTION "realtime"."to_regrole"("role_name" "text") TO "anon";
GRANT ALL ON FUNCTION "realtime"."to_regrole"("role_name" "text") TO "authenticated";
GRANT ALL ON FUNCTION "realtime"."to_regrole"("role_name" "text") TO "service_role";
GRANT ALL ON FUNCTION "realtime"."to_regrole"("role_name" "text") TO "supabase_realtime_admin";


--
-- Name: FUNCTION "topic"(); Type: ACL; Schema: realtime; Owner: supabase_realtime_admin
--

GRANT ALL ON FUNCTION "realtime"."topic"() TO "postgres";
GRANT ALL ON FUNCTION "realtime"."topic"() TO "dashboard_user";


--
-- Name: TABLE "audit_log_entries"; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE "auth"."audit_log_entries" TO "dashboard_user";
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE "auth"."audit_log_entries" TO "postgres";
GRANT SELECT ON TABLE "auth"."audit_log_entries" TO "postgres" WITH GRANT OPTION;


--
-- Name: TABLE "flow_state"; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE "auth"."flow_state" TO "postgres";
GRANT SELECT ON TABLE "auth"."flow_state" TO "postgres" WITH GRANT OPTION;
GRANT ALL ON TABLE "auth"."flow_state" TO "dashboard_user";


--
-- Name: TABLE "identities"; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE "auth"."identities" TO "postgres";
GRANT SELECT ON TABLE "auth"."identities" TO "postgres" WITH GRANT OPTION;
GRANT ALL ON TABLE "auth"."identities" TO "dashboard_user";


--
-- Name: TABLE "instances"; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE "auth"."instances" TO "dashboard_user";
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE "auth"."instances" TO "postgres";
GRANT SELECT ON TABLE "auth"."instances" TO "postgres" WITH GRANT OPTION;


--
-- Name: TABLE "mfa_amr_claims"; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE "auth"."mfa_amr_claims" TO "postgres";
GRANT SELECT ON TABLE "auth"."mfa_amr_claims" TO "postgres" WITH GRANT OPTION;
GRANT ALL ON TABLE "auth"."mfa_amr_claims" TO "dashboard_user";


--
-- Name: TABLE "mfa_challenges"; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE "auth"."mfa_challenges" TO "postgres";
GRANT SELECT ON TABLE "auth"."mfa_challenges" TO "postgres" WITH GRANT OPTION;
GRANT ALL ON TABLE "auth"."mfa_challenges" TO "dashboard_user";


--
-- Name: TABLE "mfa_factors"; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE "auth"."mfa_factors" TO "postgres";
GRANT SELECT ON TABLE "auth"."mfa_factors" TO "postgres" WITH GRANT OPTION;
GRANT ALL ON TABLE "auth"."mfa_factors" TO "dashboard_user";


--
-- Name: TABLE "oauth_clients"; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE "auth"."oauth_clients" TO "postgres";
GRANT ALL ON TABLE "auth"."oauth_clients" TO "dashboard_user";


--
-- Name: TABLE "one_time_tokens"; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE "auth"."one_time_tokens" TO "postgres";
GRANT SELECT ON TABLE "auth"."one_time_tokens" TO "postgres" WITH GRANT OPTION;
GRANT ALL ON TABLE "auth"."one_time_tokens" TO "dashboard_user";


--
-- Name: TABLE "refresh_tokens"; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE "auth"."refresh_tokens" TO "dashboard_user";
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE "auth"."refresh_tokens" TO "postgres";
GRANT SELECT ON TABLE "auth"."refresh_tokens" TO "postgres" WITH GRANT OPTION;


--
-- Name: SEQUENCE "refresh_tokens_id_seq"; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON SEQUENCE "auth"."refresh_tokens_id_seq" TO "dashboard_user";
GRANT ALL ON SEQUENCE "auth"."refresh_tokens_id_seq" TO "postgres";


--
-- Name: TABLE "saml_providers"; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE "auth"."saml_providers" TO "postgres";
GRANT SELECT ON TABLE "auth"."saml_providers" TO "postgres" WITH GRANT OPTION;
GRANT ALL ON TABLE "auth"."saml_providers" TO "dashboard_user";


--
-- Name: TABLE "saml_relay_states"; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE "auth"."saml_relay_states" TO "postgres";
GRANT SELECT ON TABLE "auth"."saml_relay_states" TO "postgres" WITH GRANT OPTION;
GRANT ALL ON TABLE "auth"."saml_relay_states" TO "dashboard_user";


--
-- Name: TABLE "schema_migrations"; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT SELECT ON TABLE "auth"."schema_migrations" TO "postgres" WITH GRANT OPTION;


--
-- Name: TABLE "sessions"; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE "auth"."sessions" TO "postgres";
GRANT SELECT ON TABLE "auth"."sessions" TO "postgres" WITH GRANT OPTION;
GRANT ALL ON TABLE "auth"."sessions" TO "dashboard_user";


--
-- Name: TABLE "sso_domains"; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE "auth"."sso_domains" TO "postgres";
GRANT SELECT ON TABLE "auth"."sso_domains" TO "postgres" WITH GRANT OPTION;
GRANT ALL ON TABLE "auth"."sso_domains" TO "dashboard_user";


--
-- Name: TABLE "sso_providers"; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE "auth"."sso_providers" TO "postgres";
GRANT SELECT ON TABLE "auth"."sso_providers" TO "postgres" WITH GRANT OPTION;
GRANT ALL ON TABLE "auth"."sso_providers" TO "dashboard_user";


--
-- Name: TABLE "users"; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE "auth"."users" TO "dashboard_user";
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE "auth"."users" TO "postgres";
GRANT SELECT ON TABLE "auth"."users" TO "postgres" WITH GRANT OPTION;


--
-- Name: TABLE "attribute_relationships"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."attribute_relationships" TO "anon";
GRANT ALL ON TABLE "public"."attribute_relationships" TO "authenticated";
GRANT ALL ON TABLE "public"."attribute_relationships" TO "service_role";


--
-- Name: TABLE "attributes"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."attributes" TO "anon";
GRANT ALL ON TABLE "public"."attributes" TO "authenticated";
GRANT ALL ON TABLE "public"."attributes" TO "service_role";


--
-- Name: TABLE "audit_logs"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."audit_logs" TO "anon";
GRANT ALL ON TABLE "public"."audit_logs" TO "authenticated";
GRANT ALL ON TABLE "public"."audit_logs" TO "service_role";


--
-- Name: TABLE "channels"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."channels" TO "anon";
GRANT ALL ON TABLE "public"."channels" TO "authenticated";
GRANT ALL ON TABLE "public"."channels" TO "service_role";


--
-- Name: TABLE "currencies"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."currencies" TO "anon";
GRANT ALL ON TABLE "public"."currencies" TO "authenticated";
GRANT ALL ON TABLE "public"."currencies" TO "service_role";


--
-- Name: TABLE "currency_inventory"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."currency_inventory" TO "anon";
GRANT ALL ON TABLE "public"."currency_inventory" TO "authenticated";
GRANT ALL ON TABLE "public"."currency_inventory" TO "service_role";


--
-- Name: TABLE "currency_transactions"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."currency_transactions" TO "anon";
GRANT ALL ON TABLE "public"."currency_transactions" TO "authenticated";
GRANT ALL ON TABLE "public"."currency_transactions" TO "service_role";


--
-- Name: TABLE "customer_accounts"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."customer_accounts" TO "anon";
GRANT ALL ON TABLE "public"."customer_accounts" TO "authenticated";
GRANT ALL ON TABLE "public"."customer_accounts" TO "service_role";


--
-- Name: TABLE "debug_log"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."debug_log" TO "anon";
GRANT ALL ON TABLE "public"."debug_log" TO "authenticated";
GRANT ALL ON TABLE "public"."debug_log" TO "service_role";


--
-- Name: SEQUENCE "debug_log_id_seq"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE "public"."debug_log_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."debug_log_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."debug_log_id_seq" TO "service_role";


--
-- Name: TABLE "exchange_rates"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."exchange_rates" TO "anon";
GRANT ALL ON TABLE "public"."exchange_rates" TO "authenticated";
GRANT ALL ON TABLE "public"."exchange_rates" TO "service_role";


--
-- Name: TABLE "game_accounts"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."game_accounts" TO "anon";
GRANT ALL ON TABLE "public"."game_accounts" TO "authenticated";
GRANT ALL ON TABLE "public"."game_accounts" TO "service_role";


--
-- Name: TABLE "level_exp"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."level_exp" TO "anon";
GRANT ALL ON TABLE "public"."level_exp" TO "authenticated";
GRANT ALL ON TABLE "public"."level_exp" TO "service_role";


--
-- Name: TABLE "order_lines"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."order_lines" TO "anon";
GRANT ALL ON TABLE "public"."order_lines" TO "authenticated";
GRANT ALL ON TABLE "public"."order_lines" TO "service_role";


--
-- Name: TABLE "order_reviews"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."order_reviews" TO "anon";
GRANT ALL ON TABLE "public"."order_reviews" TO "authenticated";
GRANT ALL ON TABLE "public"."order_reviews" TO "service_role";


--
-- Name: TABLE "order_service_items"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."order_service_items" TO "anon";
GRANT ALL ON TABLE "public"."order_service_items" TO "authenticated";
GRANT ALL ON TABLE "public"."order_service_items" TO "service_role";


--
-- Name: TABLE "orders"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."orders" TO "anon";
GRANT ALL ON TABLE "public"."orders" TO "authenticated";
GRANT ALL ON TABLE "public"."orders" TO "service_role";


--
-- Name: TABLE "parties"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."parties" TO "anon";
GRANT ALL ON TABLE "public"."parties" TO "authenticated";
GRANT ALL ON TABLE "public"."parties" TO "service_role";


--
-- Name: TABLE "permissions"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."permissions" TO "anon";
GRANT ALL ON TABLE "public"."permissions" TO "authenticated";
GRANT ALL ON TABLE "public"."permissions" TO "service_role";


--
-- Name: TABLE "product_variant_attributes"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."product_variant_attributes" TO "anon";
GRANT ALL ON TABLE "public"."product_variant_attributes" TO "authenticated";
GRANT ALL ON TABLE "public"."product_variant_attributes" TO "service_role";


--
-- Name: TABLE "product_variants"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."product_variants" TO "anon";
GRANT ALL ON TABLE "public"."product_variants" TO "authenticated";
GRANT ALL ON TABLE "public"."product_variants" TO "service_role";


--
-- Name: TABLE "products"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."products" TO "anon";
GRANT ALL ON TABLE "public"."products" TO "authenticated";
GRANT ALL ON TABLE "public"."products" TO "service_role";


--
-- Name: TABLE "profiles"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."profiles" TO "anon";
GRANT ALL ON TABLE "public"."profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."profiles" TO "service_role";


--
-- Name: TABLE "role_permissions"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."role_permissions" TO "anon";
GRANT ALL ON TABLE "public"."role_permissions" TO "authenticated";
GRANT ALL ON TABLE "public"."role_permissions" TO "service_role";


--
-- Name: TABLE "roles"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."roles" TO "anon";
GRANT ALL ON TABLE "public"."roles" TO "authenticated";
GRANT ALL ON TABLE "public"."roles" TO "service_role";


--
-- Name: TABLE "service_reports"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."service_reports" TO "anon";
GRANT ALL ON TABLE "public"."service_reports" TO "authenticated";
GRANT ALL ON TABLE "public"."service_reports" TO "service_role";


--
-- Name: TABLE "system_logs"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."system_logs" TO "anon";
GRANT ALL ON TABLE "public"."system_logs" TO "authenticated";
GRANT ALL ON TABLE "public"."system_logs" TO "service_role";


--
-- Name: TABLE "trading_fee_chains"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."trading_fee_chains" TO "anon";
GRANT ALL ON TABLE "public"."trading_fee_chains" TO "authenticated";
GRANT ALL ON TABLE "public"."trading_fee_chains" TO "service_role";


--
-- Name: TABLE "user_role_assignments"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."user_role_assignments" TO "anon";
GRANT ALL ON TABLE "public"."user_role_assignments" TO "authenticated";
GRANT ALL ON TABLE "public"."user_role_assignments" TO "service_role";


--
-- Name: TABLE "work_session_outputs"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."work_session_outputs" TO "anon";
GRANT ALL ON TABLE "public"."work_session_outputs" TO "authenticated";
GRANT ALL ON TABLE "public"."work_session_outputs" TO "service_role";


--
-- Name: TABLE "work_sessions"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."work_sessions" TO "anon";
GRANT ALL ON TABLE "public"."work_sessions" TO "authenticated";
GRANT ALL ON TABLE "public"."work_sessions" TO "service_role";


--
-- Name: TABLE "messages"; Type: ACL; Schema: realtime; Owner: supabase_realtime_admin
--

GRANT ALL ON TABLE "realtime"."messages" TO "postgres";
GRANT ALL ON TABLE "realtime"."messages" TO "dashboard_user";
GRANT SELECT,INSERT,UPDATE ON TABLE "realtime"."messages" TO "anon";
GRANT SELECT,INSERT,UPDATE ON TABLE "realtime"."messages" TO "authenticated";
GRANT SELECT,INSERT,UPDATE ON TABLE "realtime"."messages" TO "service_role";


--
-- Name: TABLE "messages_2025_10_07"; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE "realtime"."messages_2025_10_07" TO "postgres";
GRANT ALL ON TABLE "realtime"."messages_2025_10_07" TO "dashboard_user";


--
-- Name: TABLE "messages_2025_10_08"; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE "realtime"."messages_2025_10_08" TO "postgres";
GRANT ALL ON TABLE "realtime"."messages_2025_10_08" TO "dashboard_user";


--
-- Name: TABLE "messages_2025_10_09"; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE "realtime"."messages_2025_10_09" TO "postgres";
GRANT ALL ON TABLE "realtime"."messages_2025_10_09" TO "dashboard_user";


--
-- Name: TABLE "messages_2025_10_10"; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE "realtime"."messages_2025_10_10" TO "postgres";
GRANT ALL ON TABLE "realtime"."messages_2025_10_10" TO "dashboard_user";


--
-- Name: TABLE "messages_2025_10_11"; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE "realtime"."messages_2025_10_11" TO "postgres";
GRANT ALL ON TABLE "realtime"."messages_2025_10_11" TO "dashboard_user";


--
-- Name: TABLE "messages_2025_10_12"; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE "realtime"."messages_2025_10_12" TO "postgres";
GRANT ALL ON TABLE "realtime"."messages_2025_10_12" TO "dashboard_user";


--
-- Name: TABLE "messages_2025_10_13"; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE "realtime"."messages_2025_10_13" TO "postgres";
GRANT ALL ON TABLE "realtime"."messages_2025_10_13" TO "dashboard_user";


--
-- Name: TABLE "schema_migrations"; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE "realtime"."schema_migrations" TO "postgres";
GRANT ALL ON TABLE "realtime"."schema_migrations" TO "dashboard_user";
GRANT SELECT ON TABLE "realtime"."schema_migrations" TO "anon";
GRANT SELECT ON TABLE "realtime"."schema_migrations" TO "authenticated";
GRANT SELECT ON TABLE "realtime"."schema_migrations" TO "service_role";
GRANT ALL ON TABLE "realtime"."schema_migrations" TO "supabase_realtime_admin";


--
-- Name: TABLE "subscription"; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE "realtime"."subscription" TO "postgres";
GRANT ALL ON TABLE "realtime"."subscription" TO "dashboard_user";
GRANT SELECT ON TABLE "realtime"."subscription" TO "anon";
GRANT SELECT ON TABLE "realtime"."subscription" TO "authenticated";
GRANT SELECT ON TABLE "realtime"."subscription" TO "service_role";
GRANT ALL ON TABLE "realtime"."subscription" TO "supabase_realtime_admin";


--
-- Name: SEQUENCE "subscription_id_seq"; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON SEQUENCE "realtime"."subscription_id_seq" TO "postgres";
GRANT ALL ON SEQUENCE "realtime"."subscription_id_seq" TO "dashboard_user";
GRANT USAGE ON SEQUENCE "realtime"."subscription_id_seq" TO "anon";
GRANT USAGE ON SEQUENCE "realtime"."subscription_id_seq" TO "authenticated";
GRANT USAGE ON SEQUENCE "realtime"."subscription_id_seq" TO "service_role";
GRANT ALL ON SEQUENCE "realtime"."subscription_id_seq" TO "supabase_realtime_admin";


--
-- Name: TABLE "buckets"; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE "storage"."buckets" TO "anon";
GRANT ALL ON TABLE "storage"."buckets" TO "authenticated";
GRANT ALL ON TABLE "storage"."buckets" TO "service_role";
GRANT ALL ON TABLE "storage"."buckets" TO "postgres" WITH GRANT OPTION;


--
-- Name: TABLE "buckets_analytics"; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE "storage"."buckets_analytics" TO "service_role";
GRANT ALL ON TABLE "storage"."buckets_analytics" TO "authenticated";
GRANT ALL ON TABLE "storage"."buckets_analytics" TO "anon";


--
-- Name: TABLE "objects"; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE "storage"."objects" TO "anon";
GRANT ALL ON TABLE "storage"."objects" TO "authenticated";
GRANT ALL ON TABLE "storage"."objects" TO "service_role";
GRANT ALL ON TABLE "storage"."objects" TO "postgres" WITH GRANT OPTION;


--
-- Name: TABLE "prefixes"; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE "storage"."prefixes" TO "service_role";
GRANT ALL ON TABLE "storage"."prefixes" TO "authenticated";
GRANT ALL ON TABLE "storage"."prefixes" TO "anon";


--
-- Name: TABLE "s3_multipart_uploads"; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE "storage"."s3_multipart_uploads" TO "service_role";
GRANT SELECT ON TABLE "storage"."s3_multipart_uploads" TO "authenticated";
GRANT SELECT ON TABLE "storage"."s3_multipart_uploads" TO "anon";


--
-- Name: TABLE "s3_multipart_uploads_parts"; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE "storage"."s3_multipart_uploads_parts" TO "service_role";
GRANT SELECT ON TABLE "storage"."s3_multipart_uploads_parts" TO "authenticated";
GRANT SELECT ON TABLE "storage"."s3_multipart_uploads_parts" TO "anon";


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_auth_admin" IN SCHEMA "auth" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_auth_admin" IN SCHEMA "auth" GRANT ALL ON SEQUENCES TO "dashboard_user";


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_auth_admin" IN SCHEMA "auth" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_auth_admin" IN SCHEMA "auth" GRANT ALL ON FUNCTIONS TO "dashboard_user";


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_auth_admin" IN SCHEMA "auth" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_auth_admin" IN SCHEMA "auth" GRANT ALL ON TABLES TO "dashboard_user";


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: extensions; Owner: supabase_admin
--

-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "extensions" GRANT ALL ON SEQUENCES TO "postgres" WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: extensions; Owner: supabase_admin
--

-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "extensions" GRANT ALL ON FUNCTIONS TO "postgres" WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: extensions; Owner: supabase_admin
--

-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "extensions" GRANT ALL ON TABLES TO "postgres" WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: graphql_public; Owner: supabase_admin
--

-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "graphql_public" GRANT ALL ON SEQUENCES TO "postgres";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "graphql_public" GRANT ALL ON SEQUENCES TO "anon";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "graphql_public" GRANT ALL ON SEQUENCES TO "authenticated";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "graphql_public" GRANT ALL ON SEQUENCES TO "service_role";


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: graphql_public; Owner: supabase_admin
--

-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "graphql_public" GRANT ALL ON FUNCTIONS TO "postgres";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "graphql_public" GRANT ALL ON FUNCTIONS TO "anon";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "graphql_public" GRANT ALL ON FUNCTIONS TO "authenticated";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "graphql_public" GRANT ALL ON FUNCTIONS TO "service_role";


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: graphql_public; Owner: supabase_admin
--

-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "graphql_public" GRANT ALL ON TABLES TO "postgres";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "graphql_public" GRANT ALL ON TABLES TO "anon";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "graphql_public" GRANT ALL ON TABLES TO "authenticated";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "graphql_public" GRANT ALL ON TABLES TO "service_role";


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: realtime; Owner: supabase_admin
--

-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "realtime" GRANT ALL ON SEQUENCES TO "postgres";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "realtime" GRANT ALL ON SEQUENCES TO "dashboard_user";


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: realtime; Owner: supabase_admin
--

-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "realtime" GRANT ALL ON FUNCTIONS TO "postgres";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "realtime" GRANT ALL ON FUNCTIONS TO "dashboard_user";


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: realtime; Owner: supabase_admin
--

-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "realtime" GRANT ALL ON TABLES TO "postgres";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "realtime" GRANT ALL ON TABLES TO "dashboard_user";


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: storage; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "storage" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "storage" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "storage" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "storage" GRANT ALL ON SEQUENCES TO "service_role";


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: storage; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "storage" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "storage" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "storage" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "storage" GRANT ALL ON FUNCTIONS TO "service_role";


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: storage; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "storage" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "storage" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "storage" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "storage" GRANT ALL ON TABLES TO "service_role";


--
-- PostgreSQL database dump complete
--

-- \unrestrict 5AGpsGDUgkjoMrugFnCbHDHgSlX4ZczI2fXddzgzqaSG7DuVlLtFKYmp0H01gIe

RESET ALL;
