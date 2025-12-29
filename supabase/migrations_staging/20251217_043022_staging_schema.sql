--
-- PostgreSQL database dump
--

\restrict 7y4Gvm6PkQpDzZ76biGV1IgDozDHyWjuiRUzS2GFwfNQ2Yb6MSTolWXIoDWm0ku

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: auth; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA auth;


--
-- Name: pg_cron; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_cron WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION pg_cron; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_cron IS 'Job scheduler for PostgreSQL';


--
-- Name: extensions; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA extensions;


--
-- Name: SCHEMA extensions; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA extensions IS 'Dedicated schema for database extensions - moved from public for security';


--
-- Name: graphql; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA graphql;


--
-- Name: graphql_public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA graphql_public;


--
-- Name: pg_net; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_net WITH SCHEMA extensions;


--
-- Name: EXTENSION pg_net; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_net IS 'Network extension for PostgreSQL - installed in extensions schema for security';


--
-- Name: pgbouncer; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA pgbouncer;


--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

-- *not* creating schema, since initdb creates it


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS 'Public schema - fixed duplicate indexes and constraints for optimal performance';


--
-- Name: realtime; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA realtime;


--
-- Name: storage; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA storage;


--
-- Name: supabase_migrations; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA supabase_migrations;


--
-- Name: vault; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA vault;


--
-- Name: pg_graphql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_graphql WITH SCHEMA graphql;


--
-- Name: EXTENSION pg_graphql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_graphql IS 'pg_graphql: GraphQL support';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA extensions;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: supabase_vault; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS supabase_vault WITH SCHEMA vault;


--
-- Name: EXTENSION supabase_vault; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION supabase_vault IS 'Supabase Vault Extension';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA extensions;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: aal_level; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.aal_level AS ENUM (
    'aal1',
    'aal2',
    'aal3'
);


--
-- Name: code_challenge_method; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.code_challenge_method AS ENUM (
    's256',
    'plain'
);


--
-- Name: factor_status; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.factor_status AS ENUM (
    'unverified',
    'verified'
);


--
-- Name: factor_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.factor_type AS ENUM (
    'totp',
    'webauthn',
    'phone'
);


--
-- Name: oauth_authorization_status; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.oauth_authorization_status AS ENUM (
    'pending',
    'approved',
    'denied',
    'expired'
);


--
-- Name: oauth_client_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.oauth_client_type AS ENUM (
    'public',
    'confidential'
);


--
-- Name: oauth_registration_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.oauth_registration_type AS ENUM (
    'dynamic',
    'manual'
);


--
-- Name: oauth_response_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.oauth_response_type AS ENUM (
    'code'
);


--
-- Name: one_time_token_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.one_time_token_type AS ENUM (
    'confirmation_token',
    'reauthentication_token',
    'recovery_token',
    'email_change_token_new',
    'email_change_token_current',
    'phone_change_token'
);


--
-- Name: account_type_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.account_type_enum AS ENUM (
    'btag',
    'login'
);


--
-- Name: app_role; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.app_role AS ENUM (
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


--
-- Name: currency_exchange_type_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.currency_exchange_type_enum AS ENUM (
    'none',
    'items',
    'service',
    'farmer',
    'currency'
);


--
-- Name: currency_order_status_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.currency_order_status_enum AS ENUM (
    'draft',
    'pending',
    'assigned',
    'preparing',
    'ready',
    'delivering',
    'delivered',
    'completed',
    'cancelled',
    'failed'
);


--
-- Name: currency_order_type_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.currency_order_type_enum AS ENUM (
    'PURCHASE',
    'SALE',
    'EXCHANGE'
);


--
-- Name: order_side_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.order_side_enum AS ENUM (
    'BUY',
    'SELL'
);


--
-- Name: product_type_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.product_type_enum AS ENUM (
    'SERVICE',
    'ITEM',
    'CURRENCY'
);


--
-- Name: action; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.action AS ENUM (
    'INSERT',
    'UPDATE',
    'DELETE',
    'TRUNCATE',
    'ERROR'
);


--
-- Name: equality_op; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.equality_op AS ENUM (
    'eq',
    'neq',
    'lt',
    'lte',
    'gt',
    'gte',
    'in'
);


--
-- Name: user_defined_filter; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.user_defined_filter AS (
	column_name text,
	op realtime.equality_op,
	value text
);


--
-- Name: wal_column; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.wal_column AS (
	name text,
	type_name text,
	type_oid oid,
	value jsonb,
	is_pkey boolean,
	is_selectable boolean
);


--
-- Name: wal_rls; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.wal_rls AS (
	wal jsonb,
	is_rls_enabled boolean,
	subscription_ids uuid[],
	errors text[]
);


--
-- Name: buckettype; Type: TYPE; Schema: storage; Owner: -
--

CREATE TYPE storage.buckettype AS ENUM (
    'STANDARD',
    'ANALYTICS',
    'VECTOR'
);


--
-- Name: email(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.email() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.email', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'email')
  )::text
$$;


--
-- Name: FUNCTION email(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION auth.email() IS 'Deprecated. Use auth.jwt() -> ''email'' instead.';


--
-- Name: jwt(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.jwt() RETURNS jsonb
    LANGUAGE sql STABLE
    AS $$
  select 
    coalesce(
        nullif(current_setting('request.jwt.claim', true), ''),
        nullif(current_setting('request.jwt.claims', true), '')
    )::jsonb
$$;


--
-- Name: role(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.role() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.role', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'role')
  )::text
$$;


--
-- Name: FUNCTION role(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION auth.role() IS 'Deprecated. Use auth.jwt() -> ''role'' instead.';


--
-- Name: uid(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.uid() RETURNS uuid
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.sub', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
  )::uuid
$$;


--
-- Name: FUNCTION uid(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION auth.uid() IS 'Deprecated. Use auth.jwt() -> ''sub'' instead.';


--
-- Name: grant_pg_cron_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.grant_pg_cron_access() RETURNS event_trigger
    LANGUAGE plpgsql
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


--
-- Name: FUNCTION grant_pg_cron_access(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.grant_pg_cron_access() IS 'Grants access to pg_cron';


--
-- Name: grant_pg_graphql_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.grant_pg_graphql_access() RETURNS event_trigger
    LANGUAGE plpgsql
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


--
-- Name: FUNCTION grant_pg_graphql_access(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.grant_pg_graphql_access() IS 'Grants access to pg_graphql';


--
-- Name: grant_pg_net_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.grant_pg_net_access() RETURNS event_trigger
    LANGUAGE plpgsql
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


--
-- Name: FUNCTION grant_pg_net_access(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.grant_pg_net_access() IS 'Grants access to pg_net';


--
-- Name: pgrst_ddl_watch(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.pgrst_ddl_watch() RETURNS event_trigger
    LANGUAGE plpgsql
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


--
-- Name: pgrst_drop_watch(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.pgrst_drop_watch() RETURNS event_trigger
    LANGUAGE plpgsql
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


--
-- Name: set_graphql_placeholder(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.set_graphql_placeholder() RETURNS event_trigger
    LANGUAGE plpgsql
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


--
-- Name: FUNCTION set_graphql_placeholder(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.set_graphql_placeholder() IS 'Reintroduces placeholder function for graphql_public.graphql';


--
-- Name: get_auth(text); Type: FUNCTION; Schema: pgbouncer; Owner: -
--

CREATE FUNCTION pgbouncer.get_auth(p_usename text) RETURNS TABLE(username text, password text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $_$
  BEGIN
      RAISE DEBUG 'PgBouncer auth request: %', p_usename;

      RETURN QUERY
      SELECT
          rolname::text,
          CASE WHEN rolvaliduntil < now()
              THEN null
              ELSE rolpassword::text
          END
      FROM pg_authid
      WHERE rolname=$1 and rolcanlogin;
  END;
  $_$;


--
-- Name: add_vault_secret(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.add_vault_secret(p_name text, p_secret text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
    INSERT INTO vault.secrets (name, secret)
    VALUES (p_name, p_secret);
END;
$$;


--
-- Name: admin_get_all_users(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.admin_get_all_users() RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
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
        JOIN profiles p ON u.id = p.auth_id
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
            FROM user_role_assignments ura
            JOIN roles r ON ura.role_id = r.id
            LEFT JOIN attributes game_attr ON ura.game_attribute_id = game_attr.id
            LEFT JOIN attributes area_attr ON ura.business_area_attribute_id = area_attr.id
            GROUP BY ura.user_id
        ) asg ON p.id = asg.user_id -- <<< SỬA LỖI Ở ĐÂY (từ u.id thành p.id)
    );
END;
$$;


--
-- Name: admin_get_roles_and_permissions(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.admin_get_roles_and_permissions() RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
  -- Return roles and permissions data without permission checks
  -- This avoids the auth.uid() issue when called from backend
  RETURN jsonb_build_object(
    'roles', (SELECT jsonb_agg(
      jsonb_build_object(
        'id', id::text,
        'code', code,
        'name', name
      ) ORDER BY name
    ) FROM roles),
    
    'permissions', (SELECT jsonb_agg(
      jsonb_build_object(
        'id', id::text,
        'code', code,
        'description', description,
        'group', "group",
        'description_vi', description_vi
      ) ORDER BY "group", code
    ) FROM permissions),
    
    'assignments', (SELECT jsonb_agg(
      jsonb_build_object(
        'role_id', role_id::text,
        'permission_id', permission_id::text
      )
    ) FROM role_permissions)
  );
END;
$$;


--
-- Name: admin_rebase_item_progress_v1(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.admin_rebase_item_progress_v1() RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    last_session_id uuid;
BEGIN
    -- 1. Kiểm tra quyền hạn
    IF NOT has_permission('reports:resolve') THEN
        RAISE EXCEPTION 'Authorization failed.';
    END IF;

    -- 2. Đánh dấu tất cả các output cũ của item này là lỗi thời (obsolete)
    UPDATE work_session_outputs
    SET is_obsolete = TRUE
    WHERE order_service_item_id = p_service_item_id;

    -- 3. Tìm session ID cuối cùng để gắn bản ghi "chuẩn hóa" vào cho có ngữ cảnh
    SELECT work_session_id INTO last_session_id
    FROM work_session_outputs
    WHERE order_service_item_id = p_service_item_id
    ORDER BY id DESC
    LIMIT 1;

    -- 4. Tạo một bản ghi output "chuẩn" duy nhất, ghi đè lên tất cả lịch sử cũ
    INSERT INTO work_session_outputs(work_session_id, order_service_item_id, start_value, delta, params)
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
    UPDATE order_service_items
    SET 
        done_qty = p_authoritative_done_qty,
        params = p_new_params
    WHERE id = p_service_item_id;

END;
$$;


--
-- Name: admin_update_permissions_for_role(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.admin_update_permissions_for_role() RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
  v_permission_id uuid;
BEGIN
  -- Chỉ người có quyền mới được thực thi
  IF NOT has_permission('admin:manage_roles') THEN
    RAISE EXCEPTION 'Authorization failed.';
  END IF;
  
  -- Xóa tất cả các quyền cũ của role này
  DELETE FROM role_permissions WHERE role_id = p_role_id;
  
  -- Thêm lại các quyền mới từ danh sách được cung cấp
  IF array_length(p_permission_ids, 1) > 0 THEN
    FOREACH v_permission_id IN ARRAY p_permission_ids
    LOOP
      INSERT INTO role_permissions (role_id, permission_id)
      VALUES (p_role_id, v_permission_id);
    END LOOP;
  END IF;
END;
$$;


--
-- Name: admin_update_permissions_for_role(uuid, uuid[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.admin_update_permissions_for_role(p_role_id uuid, p_permission_ids uuid[]) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    current_permission_id UUID;
BEGIN
    -- Validate inputs
    IF p_role_id IS NULL THEN
        RAISE EXCEPTION 'Role ID cannot be null';
    END IF;

    IF p_permission_ids IS NULL THEN
        RAISE EXCEPTION 'Permission IDs array cannot be null';
    END IF;

    -- Check if role exists
    IF NOT EXISTS (SELECT 1 FROM roles WHERE id = p_role_id) THEN
        RAISE EXCEPTION 'Role with ID % does not exist', p_role_id;
    END IF;

    -- Remove all existing permissions for the role
    DELETE FROM role_permissions WHERE role_id = p_role_id;

    -- Insert new permissions if any are provided
    IF array_length(p_permission_ids, 1) > 0 THEN
        -- Loop through each permission ID and validate before inserting
        FOREACH current_permission_id IN ARRAY p_permission_ids
        LOOP
            -- Check if permission exists before inserting
            IF EXISTS (SELECT 1 FROM permissions WHERE id = current_permission_id) THEN
                INSERT INTO role_permissions (role_id, permission_id)
                VALUES (p_role_id, current_permission_id);
            END IF;
        END LOOP;
    END IF;

END;
$$;


--
-- Name: admin_update_user_assignments(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.admin_update_user_assignments() RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
    IF NOT has_permission('admin:manage_roles') THEN
        RAISE EXCEPTION 'Authorization failed.';
    END IF;

    -- Xóa tất cả các gán quyền cũ của người dùng này
    DELETE FROM user_role_assignments WHERE user_id = p_user_id;

    -- Thêm các gán quyền mới từ payload
    IF jsonb_array_length(p_assignments) > 0 THEN
        INSERT INTO user_role_assignments (user_id, role_id, game_attribute_id, business_area_attribute_id)
        SELECT
            p_user_id,
            (a->>'role_id')::uuid,
            (a->>'game_attribute_id')::uuid,
            (a->>'business_area_attribute_id')::uuid
        FROM jsonb_array_elements(p_assignments) a;
    END IF;
END;
$$;


--
-- Name: admin_update_user_status(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.admin_update_user_status() RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
    -- Chỉ người có quyền mới được thực hiện
    IF NOT has_permission('admin:manage_roles') THEN
        RAISE EXCEPTION 'Authorization failed.';
    END IF;

    -- Cập nhật trạng thái trong bảng profiles
    UPDATE profiles
    SET status = p_new_status
    WHERE id = p_user_id;
END;
$$;


--
-- Name: analyze_service_boosting_performance(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.analyze_service_boosting_performance() RETURNS TABLE(table_name text, index_name text, index_size text, index_usage bigint, last_used timestamp with time zone, efficiency_score numeric)
    LANGUAGE sql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
    SELECT
        pi.schemaname || '.' || pi.tablename as table_name,
        pi.indexname,
        pg_size_pretty(pg_relation_size(psi.indexrelid::regclass)) as index_size,
        psi.idx_scan as index_usage,
        NULL::TIMESTAMPTZ as last_used,
        CASE
            WHEN psi.idx_scan = 0 THEN 0
            ELSE psi.idx_scan
        END as efficiency_score
    FROM pg_stat_user_indexes psi
    JOIN pg_indexes pi ON psi.schemaname = pi.schemaname AND psi.indexrelname = pi.indexname
    WHERE pi.tablename IN ('orders', 'order_lines', 'work_sessions', 'parties', 'customer_accounts', 'product_variants')
      AND pi.indexname LIKE ANY(ARRAY[
        '%game_status%',
        '%order_deadline%',
        '%order_ended%',
        '%name_gin%',
        '%completed_recent%',
        '%order_reviews_order_line_id%',
        '%orders_for_review%'
      ])
    ORDER BY efficiency_score DESC;
$$;


--
-- Name: assign_currency_order_v1(uuid, uuid, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.assign_currency_order_v1(p_order_id uuid, p_game_account_id uuid, p_assignment_notes text) RETURNS TABLE(success boolean, message text, status text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_user_id uuid := get_current_profile_id();
    v_order RECORD;
    v_can_assign boolean := false;
    v_account_name text;
BEGIN
    -- Permission Check using has_permission function
    v_can_assign := has_permission('currency:assign', jsonb_build_object('game_code', (SELECT game_code FROM currency_orders WHERE id = p_order_id)));

    IF NOT v_can_assign THEN
        RETURN QUERY SELECT FALSE, 'Permission denied: Cannot assign order', NULL::TEXT;
        RETURN;
    END IF;

    -- Get order info
    SELECT * INTO v_order FROM currency_orders
    WHERE id = p_order_id AND status = 'pending';

    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'Order not found or not in pending status', NULL::TEXT;
        RETURN;
    END IF;

    -- Validate game account exists and matches game/league context
    SELECT account_name INTO v_account_name
    FROM game_accounts
    WHERE id = p_game_account_id
      AND game_code = v_order.game_code
      AND (
          (v_order.league_attribute_id IS NOT NULL AND league_attribute_id = v_order.league_attribute_id) OR
          (v_order.league_attribute_id IS NULL AND league_attribute_id IS NULL)
      );

    IF v_account_name IS NULL THEN
        RETURN QUERY SELECT FALSE, 'Game account not found or does not match order context', NULL::TEXT;
        RETURN;
    END IF;

    -- Update order
    UPDATE currency_orders
    SET status = 'assigned',
        game_account_id = p_game_account_id,
        assigned_to = v_user_id,
        ops_notes = p_assignment_notes,
        updated_at = NOW(),
        updated_by = v_user_id
    WHERE id = p_order_id;

    RETURN QUERY SELECT TRUE, format('Order assigned to account %s successfully', v_account_name), 'assigned';
END;
$$;


--
-- Name: assign_purchase_order(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.assign_purchase_order(p_purchase_order_id uuid) RETURNS TABLE(success boolean, message text, employee_id uuid, game_account_id uuid, server_code text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_order RECORD;
    v_channel RECORD;
    v_available_accounts RECORD;
    v_employee_shift RECORD;
    v_current_time TIMESTAMPTZ := NOW();
    -- FIXED: Removed timezone conversion - v_gmt7_time now uses v_current_time directly
    v_gmt7_time TIMESTAMPTZ := v_current_time;  -- FIXED: No more double conversion!
    v_matched_server TEXT;
    v_currency_code TEXT;
    v_shift_id UUID;
    v_next_employee RECORD;
    v_selected_employee_id UUID;
    v_selected_account_id UUID;
    v_server_code TEXT;
    v_tracker_id UUID;
    v_current_employee_count INTEGER;
    v_actual_employee_count INTEGER;
    v_group_key TEXT;
    v_tracker_refreshed BOOLEAN := FALSE;
BEGIN
    -- Get order details with strict validation
    SELECT co.*, c.code as channel_code, c.direction
    INTO v_order
    FROM currency_orders co
    JOIN channels c ON co.channel_id = c.id
    WHERE co.id = p_purchase_order_id
      AND co.status = 'pending'
      AND co.order_type = 'PURCHASE';

    -- Order not found or invalid status
    IF NOT FOUND THEN
        RETURN QUERY SELECT false, 'Order not found, not in pending status, or not a purchase order', NULL::UUID, NULL::UUID, NULL::TEXT;
        RETURN;
    END IF;

    -- Channel validation
    IF v_order.direction NOT IN ('BUY', 'BOTH') THEN
        RETURN QUERY SELECT false, format('Channel %s does not support purchase operations', v_order.channel_code), NULL::UUID, NULL::UUID, NULL::TEXT;
        RETURN;
    END IF;

    -- Determine currency code for shift assignments based on cost_currency
    v_currency_code := COALESCE(v_order.cost_currency_code, 'VND');

    -- If cost currency is VND but channel is WeChat, use CNY for shift assignment
    IF v_order.channel_code = 'WeChat' AND v_currency_code = 'VND' THEN
        v_currency_code := 'CNY';
    END IF;

    -- Find current shift based on GMT+7 time
    SELECT id INTO v_shift_id
    FROM work_shifts ws
    WHERE ws.is_active = true
      AND (
        -- Regular shift: current time between start and end
        (ws.start_time <= ws.end_time AND
         v_gmt7_time::time >= ws.start_time AND
         v_gmt7_time::time <= ws.end_time)
        OR
        -- Overnight shift: current time >= start OR current time <= end
        (ws.start_time > ws.end_time AND
         (v_gmt7_time::time >= ws.start_time OR
          v_gmt7_time::time <= ws.end_time))
      )
    LIMIT 1;

    -- No active shift found
    IF v_shift_id IS NULL THEN
        RETURN QUERY SELECT false,
            format('No active shift found at GMT+7 time: %s', v_gmt7_time::time),
            NULL::UUID, NULL::UUID, NULL::TEXT;
        RETURN;
    END IF;

    -- ENHANCED: Use comprehensive validation function
    v_tracker_refreshed := validate_and_refresh_assignment_tracker(
        v_order.channel_id,
        v_currency_code,
        v_shift_id,
        'PURCHASE',
        v_order.game_code,
        v_order.server_attribute_code
    );

    -- Build the group key to find existing tracker
    v_group_key := format('%s|%s|%s|%s|%s|PURCHASE',
        v_order.channel_id,
        v_currency_code, v_order.game_code,
        COALESCE(v_order.server_attribute_code, 'ANY_SERVER'),
        v_shift_id
    );

    -- Try to get existing tracker
    SELECT id, available_count INTO v_tracker_id, v_current_employee_count
    FROM assignment_trackers
    WHERE assignment_group_key = v_group_key;

    -- Get next employee using round-robin assignment (will create fresh tracker if needed)
    SELECT * INTO v_next_employee
    FROM get_next_employee_round_robin(
        v_order.channel_id,
        v_currency_code,
        v_shift_id,
        'PURCHASE',
        v_order.game_code,
        v_order.server_attribute_code
    );

    -- No employee available for round-robin assignment
    IF v_next_employee.employee_id IS NULL THEN
        RETURN QUERY SELECT false,
            format('No employees available for round-robin assignment (Channel: %s, Currency: %s, Game: %s, Server: %s, Shift: %s, Order Type: PURCHASE)',
                   v_order.channel_code, v_currency_code, v_order.game_code, v_order.server_attribute_code, v_shift_id),
            NULL::UUID, NULL::UUID, NULL::TEXT;
        RETURN;
    END IF;

    -- Find game account for this employee that matches order requirements
    -- IMPORTANT: Prioritize specific server accounts, then global accounts
    SELECT sa.*, p.display_name, p.status as employee_status, ga.server_attribute_code
    INTO v_employee_shift
    FROM shift_assignments sa
    JOIN profiles p ON sa.employee_profile_id = p.id
    JOIN game_accounts ga ON sa.game_account_id = ga.id
    WHERE sa.employee_profile_id = v_next_employee.employee_id
      AND sa.channels_id = v_order.channel_id
      AND sa.currency_code = v_currency_code
      AND sa.shift_id = v_shift_id
      AND sa.is_active = true
      AND p.status = 'active'
      AND ga.game_code = v_order.game_code
      AND ga.is_active = true
      -- CRITICAL: Include both specific server accounts AND global accounts (NULL)
      AND (ga.server_attribute_code = v_order.server_attribute_code
           OR ga.server_attribute_code IS NULL)
    ORDER BY
        -- Prefer specific server accounts first, then global accounts
        CASE WHEN ga.server_attribute_code = v_order.server_attribute_code THEN 1 ELSE 2 END,
        ga.account_name
    LIMIT 1;

    -- Employee not found for this specific combination
    IF v_employee_shift IS NULL THEN
        RETURN QUERY SELECT false,
            format('Employee %s found in round-robin but no matching game account for %s server %s (tried both specific and global accounts)',
                   v_next_employee.employee_name, v_order.game_code, v_order.server_attribute_code),
            NULL::UUID, NULL::UUID, NULL::TEXT;
        RETURN;
    END IF;

    -- Assign order to the selected employee and account
    v_selected_employee_id := v_employee_shift.employee_profile_id;
    v_selected_account_id := v_employee_shift.game_account_id;
    v_server_code := v_employee_shift.server_attribute_code;

    UPDATE currency_orders
    SET
        assigned_to = v_selected_employee_id,
        game_account_id = v_selected_account_id,
        assigned_at = v_current_time,
        status = 'assigned'
    WHERE id = p_purchase_order_id;

    -- Success response with enhanced validation information
    RETURN QUERY SELECT true,
        format('Order assigned to employee %s using game account %s (Server: %s, Type: %s) at %s [Round-Robin Index: %s, Order Type: PURCHASE, Consecutive: %s]%s',
               v_employee_shift.display_name,
               (SELECT account_name FROM game_accounts WHERE id = v_selected_account_id),
               COALESCE(v_server_code, 'Global'),
               CASE WHEN v_server_code IS NULL THEN 'Global Account' ELSE 'Server-Specific Account' END,
               v_gmt7_time::time,
               v_next_employee.new_index,
               v_next_employee.consecutive_assignments_count,
               CASE WHEN v_tracker_refreshed THEN ' [Tracker Auto-Refreshed]' ELSE '' END),
        v_selected_employee_id, v_selected_account_id, v_server_code;

    RAISE LOG '[ASSIGN_PURCHASE_ORDER] Enhanced validation: Order % assigned to employee % (account: % server: % type: %s tracker: % index: % refreshed: %s validated: %s) at %',
                p_purchase_order_id, v_selected_employee_id,
                (SELECT account_name FROM game_accounts WHERE id = v_selected_account_id),
                COALESCE(v_server_code, 'Global'),
                CASE WHEN v_server_code IS NULL THEN 'Global' ELSE 'Specific' END,
                v_next_employee.tracker_id, v_next_employee.new_index,
                CASE WHEN v_tracker_refreshed THEN 'YES' ELSE 'NO' END,
                'ENHANCED',
                v_gmt7_time::time;
END;
$$;


--
-- Name: assign_role_to_user(uuid, uuid, uuid, uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.assign_role_to_user(p_user_id uuid, p_role_id uuid, p_game_attribute_id uuid DEFAULT NULL::uuid, p_business_area_attribute_id uuid DEFAULT NULL::uuid) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_assignment_id uuid;
    v_role_name TEXT;
BEGIN
    -- Get role name for message
    SELECT name INTO v_role_name FROM roles WHERE id = p_role_id;

    IF v_role_name IS NULL THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Vai trò không tồn tại'
        );
    END IF;

    -- Check if assignment already exists (exact match including NULL handling)
    -- Use IS NOT DISTINCT FROM to properly handle NULL values comparison
    SELECT id INTO v_assignment_id
    FROM user_role_assignments
    WHERE user_id = p_user_id
      AND role_id = p_role_id
      AND game_attribute_id IS NOT DISTINCT FROM p_game_attribute_id
      AND business_area_attribute_id IS NOT DISTINCT FROM p_business_area_attribute_id;

    IF v_assignment_id IS NOT NULL THEN
        -- Assignment already exists for this exact combination
        RETURN jsonb_build_object(
            'success', false,
            'message', format('Phân quyền này đã tồn tại (User: %s, Role: %s, Game: %s, Lĩnh vực: %s)',
                COALESCE((SELECT display_name FROM profiles WHERE id = p_user_id), 'Unknown'),
                v_role_name,
                COALESCE((SELECT name FROM attributes WHERE id = p_game_attribute_id), 'Tất cả'),
                COALESCE((SELECT name FROM attributes WHERE id = p_business_area_attribute_id), 'Tất cả')
            )
        );
    END IF;

    -- Create new assignment
    INSERT INTO user_role_assignments (user_id, role_id, game_attribute_id, business_area_attribute_id)
    VALUES (p_user_id, p_role_id, p_game_attribute_id, p_business_area_attribute_id)
    RETURNING id INTO v_assignment_id;

    -- Return success result
    RETURN jsonb_build_object(
        'success', true,
        'message', 'Đã gán vai trò thành công',
        'assignment_id', v_assignment_id
    );
END;
$$;


--
-- Name: assign_sell_order_with_inventory_v2(uuid, uuid, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.assign_sell_order_with_inventory_v2(p_order_id uuid DEFAULT NULL::uuid, p_user_id uuid DEFAULT NULL::uuid, p_rotation_type text DEFAULT 'currency_first'::text) RETURNS TABLE(success boolean, message text, assigned_employee_id uuid, assigned_employee_name text, game_account_id uuid, game_account_name text, channel_id uuid, channel_name text, cost_amount numeric, cost_currency text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_current_user_id UUID := COALESCE(p_user_id, auth.uid());
    v_order RECORD;
    v_inventory_pool RECORD;
    v_employee RECORD;
    v_fallback_employee RECORD;
    v_cost_amount DECIMAL;
    v_cost_currency TEXT;
    v_bot_profile_id UUID DEFAULT '3c6f63c0-6cc5-4e04-9ccc-c5b92a8868dc';
BEGIN
    -- Get order details
    SELECT * INTO v_order
    FROM currency_orders
    WHERE id = p_order_id AND status = 'pending';

    IF NOT FOUND THEN
        RETURN QUERY
        SELECT
            false as success,
            'Order not found or not in pending status' as message,
            NULL::UUID, NULL::TEXT, NULL::UUID, NULL::TEXT,
            NULL::UUID, NULL::TEXT, NULL::NUMERIC, NULL::TEXT;
        RETURN;
    END IF;

    -- Step 1: Find best inventory pool using selected rotation type
    IF p_rotation_type = 'account_first' THEN
        SELECT * INTO v_inventory_pool FROM get_inventory_pool_with_account_first_rotation(
            v_order.game_code,
            v_order.server_attribute_code,
            v_order.currency_attribute_id,
            v_order.quantity
        );
    ELSE
        -- Fall back to original currency-first rotation
        SELECT * INTO v_inventory_pool FROM get_inventory_pool_with_currency_rotation(
            v_order.game_code,
            v_order.server_attribute_code,
            v_order.currency_attribute_id,
            v_order.quantity
        );
    END IF;

    IF v_inventory_pool IS NULL OR NOT v_inventory_pool.success THEN
        RETURN QUERY
        SELECT
            false as success,
            CASE
                WHEN v_inventory_pool.message IS NOT NULL THEN v_inventory_pool.message
                ELSE format('No suitable inventory pool found with %s rotation', p_rotation_type)
            END as message,
            NULL::UUID, NULL::TEXT, NULL::UUID, NULL::TEXT,
            NULL::UUID, NULL::TEXT, NULL::NUMERIC, NULL::TEXT;
        RETURN;
    END IF;

    -- Calculate cost amount
    v_cost_amount := v_order.quantity * COALESCE(v_inventory_pool.average_cost, 0);
    v_cost_currency := COALESCE(v_inventory_pool.cost_currency, 'VND');

    -- Step 2: Find employee with fallback mechanism
    SELECT * INTO v_employee
    FROM get_employee_for_account_in_shift(v_inventory_pool.game_account_id)
    LIMIT 1;

    IF v_employee.success THEN
        -- Direct assignment successful
    ELSE
        -- Fallback to any employee with same game code
        SELECT * INTO v_fallback_employee
        FROM get_employee_fallback_for_game_code(
            v_order.game_code,
            NOW()::TIME,
            v_inventory_pool.game_account_id
        )
        LIMIT 1;

        IF v_fallback_employee.success THEN
            v_employee.employee_profile_id := v_fallback_employee.employee_profile_id;
            v_employee.employee_name := v_fallback_employee.employee_name;
            v_employee.success := true;
        ELSE
            -- No employee found
            RETURN QUERY
            SELECT
                false as success,
                format('No employee available for account %s and no fallback for game %s',
                       COALESCE(v_inventory_pool.account_name, 'Unknown'),
                       v_order.game_code) as message,
                NULL::UUID, NULL::TEXT,
                v_inventory_pool.game_account_id, COALESCE(v_inventory_pool.account_name, 'Unknown'),
                v_inventory_pool.channel_id, v_inventory_pool.channel_name,
                v_cost_amount, v_cost_currency;
            RETURN;
        END IF;
    END IF;

    -- Step 3: Update database
    UPDATE currency_orders
    SET assigned_to = v_employee.employee_profile_id,
        game_account_id = v_inventory_pool.game_account_id,
        inventory_pool_id = v_inventory_pool.inventory_pool_id,
        assigned_at = NOW(),
        status = 'assigned',
        submitted_by = CASE WHEN submitted_by IS NULL THEN v_bot_profile_id ELSE submitted_by END,
        updated_at = NOW(),
        updated_by = v_current_user_id,
        cost_amount = v_cost_amount,
        cost_currency_code = v_cost_currency
    WHERE id = p_order_id;

    -- Step 4: Update inventory - CORRECT LOGIC: Reduce quantity AND increase reserved_quantity
    UPDATE inventory_pools
    SET quantity = quantity - v_order.quantity,
        reserved_quantity = reserved_quantity + v_order.quantity,
        last_updated_at = NOW(),
        last_updated_by = v_current_user_id
    WHERE id = v_inventory_pool.inventory_pool_id;

    -- Return success
    RETURN QUERY
    SELECT
        true as success,
        format('%s assignment: %s -> %s (Account: %s)',
               CASE WHEN p_rotation_type = 'account_first' THEN 'Account-first' ELSE 'Currency-first' END,
               COALESCE(v_employee.employee_name, 'Unknown'), v_inventory_pool.channel_name,
               COALESCE(v_inventory_pool.account_name, 'Unknown')) as message,
        v_employee.employee_profile_id as assigned_employee_id,
        COALESCE(v_employee.employee_name, 'Unknown') as assigned_employee_name,
        v_inventory_pool.game_account_id as game_account_id,
        COALESCE(v_inventory_pool.account_name, 'Unknown') as game_account_name,
        v_inventory_pool.channel_id as channel_id,
        v_inventory_pool.channel_name as channel_name,
        v_cost_amount as cost_amount,
        v_cost_currency as cost_currency;

    RETURN;
END;
$$;


--
-- Name: audit_ctx_v1(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.audit_ctx_v1() RETURNS jsonb
    LANGUAGE sql STABLE
    SET search_path TO 'public'
    AS $$
select jsonb_strip_nulls(jsonb_build_object(
  'role', current_setting('role', true),
  'sub',  nullif(current_setting('request.jwt.claim.sub',  true), ''),
  'email',nullif(current_setting('request.jwt.claim.email',true), ''),
  'aud',  nullif(current_setting('request.jwt.claim.aud',  true), '')
));
$$;


--
-- Name: audit_diff_v1(jsonb, jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.audit_diff_v1(old_row jsonb, new_row jsonb) RETURNS jsonb
    LANGUAGE plpgsql STABLE
    SET search_path TO 'public'
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


--
-- Name: auto_assign_buy_order(uuid, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.auto_assign_buy_order(p_order_id uuid, p_channel_type text) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_order RECORD;
    v_current_shift UUID;
    v_assigned_trader UUID;
    -- FIXED: Removed timezone conversion - v_gmt7_date now uses NOW() directly
    v_gmt7_date DATE;
BEGIN
    -- Get order details
    SELECT * INTO v_order
    FROM currency_orders
    WHERE id = p_order_id;

    IF v_order.id IS NULL THEN
        RETURN FALSE;
    END IF;

    -- Get current date in GMT+7
    v_gmt7_date := NOW()::DATE;  -- FIXED: Removed timezone conversion

    -- Find current shift based on GMT+7 time
    SELECT id INTO v_current_shift
    FROM work_shifts
    WHERE is_active = true
      AND (
        -- Day shift: 08:00-20:00
        (name = 'Ca Ngày' AND EXTRACT(HOUR FROM NOW()) >= 8
         AND EXTRACT(HOUR FROM NOW()) < 20)
        OR
        -- Night shift: 20:00-08:00 (next day)
        (name = 'Ca Đêm' AND (EXTRACT(HOUR FROM NOW()) >= 20
                              OR EXTRACT(HOUR FROM NOW()) < 8))
      )
    LIMIT 1;

    IF v_current_shift IS NULL THEN
        RETURN FALSE;
    END IF;

    -- Get next available trader
    v_assigned_trader := get_next_available_trader(p_channel_type, 'buyer', v_current_shift, v_gmt7_date);

    IF v_assigned_trader IS NULL THEN
        RETURN FALSE;
    END IF;

    -- Assign order to trader
    UPDATE currency_orders
    SET assigned_to = v_assigned_trader,
        assigned_at = NOW(),
        status = 'assigned'
    WHERE id = p_order_id;

    RETURN TRUE;
END;
$$;


--
-- Name: auto_calculate_order_fees_simple(uuid, numeric, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.auto_calculate_order_fees_simple(p_channel_id uuid, p_amount numeric, p_order_type text) RETURNS numeric
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
    RETURN calculate_channel_fees(p_channel_id, p_amount, p_order_type);
END;
$$;


--
-- Name: auto_create_inventory_pools_records(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.auto_create_inventory_pools_records() RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
    -- Auto-create inventory pool records for game accounts without existing pools
    INSERT INTO inventory_pools (
        game_account_id,
        game_code,
        quantity,
        is_available,
        created_at
    )
    SELECT 
        ga.id,
        ga.game_code,
        1 as quantity,
        ga.is_active as is_available,
        NOW()
    FROM game_accounts ga
    WHERE ga.is_active = true
      AND NOT EXISTS (
          SELECT 1 FROM inventory_pools ip 
          WHERE ip.game_account_id = ga.id
      );
END;
$$;


--
-- Name: auto_create_inventory_records(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.auto_create_inventory_records() RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    record_count integer;
BEGIN
    -- Auto-create inventory records for new game accounts
    PERFORM auto_create_inventory_pools_records();
    
    -- Get count of created records
    SELECT COUNT(*) INTO record_count
    FROM inventory_pools ip
    WHERE DATE(ip.created_at) = CURRENT_DATE;
    
    RETURN record_count;
END;
$$;


--
-- Name: calculate_avg_cost_by_channel(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.calculate_avg_cost_by_channel() RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_avg_cost NUMERIC := 0;
    v_total_quantity NUMERIC := 0;
    v_total_cost NUMERIC := 0;
BEGIN
    -- Calculate weighted average cost from currency orders
    SELECT 
        COALESCE(SUM(quantity), 0),
        COALESCE(SUM(unit_price_vnd * quantity), 0)
    INTO v_total_quantity, v_total_cost
    FROM currency_orders
    WHERE channel_id = p_channel_id
      AND currency_attribute_id = p_currency_attribute_id
      AND game_code = p_game_code
      AND league_attribute_id = p_league_attribute_id
      AND status = 'COMPLETED'
      AND order_type = 'PURCHASE';
    
    -- Calculate average cost
    IF v_total_quantity > 0 THEN
        v_avg_cost := v_total_cost / v_total_quantity;
    END IF;
    
    RETURN v_avg_cost;
END;
$$;


--
-- Name: calculate_channel_fee(uuid, numeric, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.calculate_channel_fee(p_channel_id uuid, p_amount numeric, p_order_type text) RETURNS numeric
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
    RETURN calculate_channel_fees(p_channel_id, p_amount, p_order_type);
END;
$$;


--
-- Name: calculate_channel_fees(uuid, numeric, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.calculate_channel_fees(p_channel_id uuid, p_amount numeric, p_order_type text) RETURNS numeric
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_fee_rate NUMERIC;
    v_fee_fixed NUMERIC;
    v_fee NUMERIC;
BEGIN
    IF p_order_type = 'BUY' THEN
        SELECT purchase_fee_rate, purchase_fee_fixed 
        INTO v_fee_rate, v_fee_fixed
        FROM channels 
        WHERE id = p_channel_id;
    ELSIF p_order_type = 'SELL' THEN
        SELECT sale_fee_rate, sale_fee_fixed 
        INTO v_fee_rate, v_fee_fixed
        FROM channels 
        WHERE id = p_channel_id;
    ELSE
        RETURN 0;
    END IF;
    
    IF v_fee_rate IS NOT NULL THEN
        v_fee := (p_amount * v_fee_rate / 100) + COALESCE(v_fee_fixed, 0);
    ELSE
        v_fee := 0;
    END IF;
    
    RETURN v_fee;
END;
$$;


--
-- Name: calculate_cost_in_usd(numeric, text, date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.calculate_cost_in_usd(p_cost_amount numeric, p_cost_currency text, p_effective_date date DEFAULT CURRENT_DATE) RETURNS TABLE(success boolean, cost_usd numeric, rate_used numeric, message text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_exchange_rate DECIMAL;
BEGIN
    -- If cost is already in USD, return as-is
    IF p_cost_currency = 'USD' THEN
        RETURN QUERY
        SELECT true, p_cost_amount, 1.0, 'Cost is already in USD';
        RETURN;
    END IF;

    -- Try to get exchange rate from exchange_rate_monitor (simplified query)
    SELECT rate INTO v_exchange_rate
    FROM exchange_rate_monitor
    WHERE from_currency = p_cost_currency
      AND to_currency = 'USD'
      AND status = 'Valid'
    ORDER BY effective_date DESC
    LIMIT 1;

    -- If no rate found, try reverse rate
    IF v_exchange_rate IS NULL THEN
        SELECT rate INTO v_exchange_rate
        FROM exchange_rate_monitor
        WHERE from_currency = 'USD'
          AND to_currency = p_cost_currency
          AND status = 'Valid'
        ORDER BY effective_date DESC
        LIMIT 1;

        -- If reverse rate found, calculate inverse
        IF v_exchange_rate IS NOT NULL AND v_exchange_rate != 0 THEN
            v_exchange_rate := 1 / v_exchange_rate;
        END IF;
    END IF;

    -- If still no rate found, return failure
    IF v_exchange_rate IS NULL OR v_exchange_rate = 0 THEN
        RETURN QUERY
        SELECT false, 0::DECIMAL, 0::DECIMAL,
               format('No exchange rate found for %s to USD', p_cost_currency);
        RETURN;
    END IF;

    -- Calculate cost in USD
    RETURN QUERY
    SELECT true,
           p_cost_amount * v_exchange_rate,
           v_exchange_rate,
           format('Converted %s %s to USD using rate %s', 
                  p_cost_amount, p_cost_currency, v_exchange_rate);
    RETURN;
END;
$$;


--
-- Name: calculate_fees_multi_currency(uuid, numeric, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.calculate_fees_multi_currency(p_channel_id uuid, p_amount numeric, p_order_type text, p_currency text) RETURNS numeric
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_fee NUMERIC;
    v_amount_base NUMERIC;
BEGIN
    -- Convert amount to base currency if needed
    v_amount_base := convert_order_price(p_amount, p_currency, 'VND');
    
    -- Calculate fee in base currency
    v_fee := calculate_channel_fees(p_channel_id, v_amount_base, p_order_type);
    
    -- Convert fee back to original currency
    RETURN convert_order_price(v_fee, 'VND', p_currency);
END;
$$;


--
-- Name: calculate_simple_fees(uuid, numeric, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.calculate_simple_fees(p_channel_id uuid, p_amount numeric, p_direction text, p_currency text DEFAULT 'VND'::text) RETURNS numeric
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_fee NUMERIC := 0;
    v_channel_record RECORD;
BEGIN
    -- Get channel fee configuration
    SELECT * INTO v_channel_record FROM channels WHERE id = p_channel_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Channel not found';
    END IF;

    -- Calculate fee based on direction
    IF p_direction = 'PURCHASE' THEN
        v_fee := (p_amount * v_channel_record.purchase_fee_rate / 100) + v_channel_record.purchase_fee_fixed;
    ELSIF p_direction = 'SALE' THEN
        v_fee := (p_amount * v_channel_record.sale_fee_rate / 100) + v_channel_record.sale_fee_fixed;
    END IF;

    RETURN v_fee;
END;
$$;


--
-- Name: calculate_unit_price(uuid, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.calculate_unit_price(p_order_id uuid, p_price_type text) RETURNS TABLE(unit_price_vnd numeric, unit_price_usd numeric)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_order RECORD;
    v_amount NUMERIC;
    v_currency_code TEXT;
    v_exchange_rate NUMERIC;
    v_unit_price_vnd NUMERIC;
    v_unit_price_usd NUMERIC;
BEGIN
    -- Get order data
    SELECT * INTO v_order FROM currency_orders WHERE id = p_order_id;
    
    IF NOT FOUND THEN
        RETURN;
    END IF;
    
    -- Get amount based on price type
    IF p_price_type = 'cost' THEN
        v_amount := v_order.cost_amount;
        v_currency_code := v_order.cost_currency_code;
    ELSIF p_price_type = 'sale' THEN
        v_amount := v_order.sale_amount;
        v_currency_code := v_order.sale_currency_code;
    ELSE
        RAISE EXCEPTION 'Invalid price_type. Use "cost" or "sale"';
    END IF;
    
    -- Calculate unit price in VND
    IF v_currency_code = 'VND' THEN
        v_unit_price_vnd := v_amount / v_order.quantity;
        v_unit_price_usd := NULL; -- Will be calculated below
    ELSE
        -- Convert to VND
        SELECT rate INTO v_exchange_rate
        FROM exchange_rates
        WHERE from_currency = v_currency_code
          AND to_currency = 'VND'
          AND effective_date <= COALESCE(v_order.exchange_rate_date, CURRENT_DATE)
          AND is_active = true
        ORDER BY effective_date DESC
        LIMIT 1;
        
        IF v_exchange_rate IS NULL THEN
            v_exchange_rate := 1; -- Fallback
        END IF;
        
        v_unit_price_vnd := (v_amount / v_order.quantity) * v_exchange_rate;
    END IF;
    
    -- Calculate unit price in USD
    IF v_currency_code = 'USD' THEN
        v_unit_price_usd := v_amount / v_order.quantity;
    ELSE
        -- Convert to USD
        SELECT rate INTO v_exchange_rate
        FROM exchange_rates
        WHERE from_currency = v_currency_code
          AND to_currency = 'USD'
          AND effective_date <= COALESCE(v_order.exchange_rate_date, CURRENT_DATE)
          AND is_active = true
        ORDER BY effective_date DESC
        LIMIT 1;
        
        IF v_exchange_rate IS NULL THEN
            v_exchange_rate := 1; -- Fallback
        END IF;
        
        v_unit_price_usd := (v_amount / v_order.quantity) * v_exchange_rate;
    END IF;
    
    -- Return results
    RETURN QUERY
    SELECT v_unit_price_vnd, v_unit_price_usd;
    
END;
$$;


--
-- Name: FUNCTION calculate_unit_price(p_order_id uuid, p_price_type text); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.calculate_unit_price(p_order_id uuid, p_price_type text) IS 'Calculate unit price from cost/sale amounts with currency conversion';


--
-- Name: call_fetch_exchange_rates_edge_function(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.call_fetch_exchange_rates_edge_function() RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
  edge_function_url text := 'https://nxlrnwijsxqalcxyavkj.supabase.co/functions/v1/fetch-exchange-rates';
  service_role_key text := 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im54bHJud2lqc3hxYWxjeGF2a2oiLCJyb2xlIjoic2VydmljZV9yb2xlIiwiaWF0IjoxNzM3NTQ2NDE1LCJleHAiOjIwNTMxMjI0MTV9.S2sEaQRGZqTyJ93XZkIXN1tP_8N2Ww1h7G2XNLJXg-c';
  request_id bigint;
BEGIN
  -- Call the edge function using pg_net with service role key
  SELECT net.http_get(
    edge_function_url,
    jsonb_build_object(
      'Authorization', 'Bearer ' || service_role_key,
      'apikey', service_role_key
    )
  ) INTO request_id;
  
  -- Log the request
  RAISE LOG 'Edge function fetch-exchange-rates called with request_id: %', request_id;
END;
$$;


--
-- Name: cancel_currency_order(uuid, uuid, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.cancel_currency_order(p_order_id uuid, p_user_id uuid DEFAULT NULL::uuid, p_reason text DEFAULT NULL::text) RETURNS TABLE(success boolean, message text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_order_type TEXT;
BEGIN
    -- Get order type
    SELECT order_type INTO v_order_type
    FROM currency_orders
    WHERE id = p_order_id;

    IF v_order_type IS NULL THEN
        RETURN QUERY SELECT false, 'Order not found';
        RETURN;
    END IF;

    -- Route to appropriate cancel function
    IF v_order_type = 'SALE' THEN
        RETURN QUERY
        SELECT success, message
        FROM cancel_sell_order_with_inventory_rollback(p_order_id, p_user_id);
    ELSIF v_order_type = 'PURCHASE' THEN
        RETURN QUERY
        SELECT success, message
        FROM cancel_purchase_order(p_order_id, p_user_id);
    ELSE
        RETURN QUERY SELECT false, 'Unknown order type: ' || v_order_type;
    END IF;
END;
$$;


--
-- Name: cancel_order_line_v1(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.cancel_order_line_v1() RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
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
  FROM order_lines ol
  JOIN orders o ON ol.order_id = o.id
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
    UPDATE order_lines
    SET paused_at = NOW()
    WHERE id = p_line_id;
  END IF;

  -- Bước 4: Cập nhật trạng thái và lưu bằng chứng
  UPDATE orders
  SET
    status = 'cancelled',
    notes = p_reason
  WHERE id = target_order_id;

  UPDATE order_lines
  SET
    action_proof_urls = p_cancellation_proof_urls
  WHERE id = p_line_id;

END;
$$;


--
-- Name: cancel_purchase_order(uuid, uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.cancel_purchase_order(p_order_id uuid, p_user_id uuid DEFAULT NULL::uuid) RETURNS TABLE(success boolean, message text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_order RECORD;
    v_current_user_id UUID;
    v_inventory_pool RECORD;
BEGIN
    -- Get current user (from parameter or auth)
    v_current_user_id := COALESCE(p_user_id, get_current_profile_id());

    -- Get order details
    SELECT * INTO v_order
    FROM currency_orders
    WHERE id = p_order_id;

    IF NOT FOUND THEN
        RETURN QUERY
        SELECT false, 'Order not found';
        RETURN;
    END IF;

    -- Only process purchase orders
    IF v_order.order_type != 'PURCHASE' THEN
        RETURN QUERY
        SELECT false, 'This function only handles purchase orders';
        RETURN;
    END IF;

    -- Only allow cancellation for certain statuses
    IF v_order.status IN ('completed', 'cancelled') THEN
        RETURN QUERY
        SELECT false, 'Order cannot be cancelled in current status: ' || v_order.status;
        RETURN;
    END IF;

    -- Handle inventory rollback based on order status
    IF v_order.inventory_pool_id IS NOT NULL THEN
        -- Get inventory pool record
        SELECT * INTO v_inventory_pool
        FROM inventory_pools
        WHERE id = v_order.inventory_pool_id
        FOR UPDATE;

        IF v_inventory_pool.id IS NOT NULL THEN
            -- For delivered orders: remove the quantity that was added
            IF v_order.status = 'delivered' THEN
                UPDATE inventory_pools
                SET
                    quantity = GREATEST(0, quantity - v_order.quantity),
                    last_updated_at = NOW(),
                    last_updated_by = v_current_user_id
                WHERE id = v_order.inventory_pool_id;

                RAISE LOG 'Rolled back delivered purchase order %: pool_id=%s, quantity=%s',
                    p_order_id, v_order.inventory_pool_id, v_order.quantity;

            -- For preparing/assigned orders: no inventory was added yet, nothing to rollback
            ELSE
                RAISE LOG 'Purchase order % status=%s has no inventory to rollback',
                    p_order_id, v_order.status;
            END IF;
        END IF;
    END IF;

    -- Update order status to cancelled with timestamp
    UPDATE currency_orders
    SET
        status = 'cancelled',
        cancelled_at = NOW(),
        updated_at = NOW(),
        updated_by = v_current_user_id
    WHERE id = p_order_id;

    RETURN QUERY
    SELECT true, 'Purchase order cancelled successfully';
    RETURN;
END;
$$;


--
-- Name: cancel_sell_order_with_inventory_rollback(uuid, uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.cancel_sell_order_with_inventory_rollback(p_order_id uuid, p_user_id uuid DEFAULT NULL::uuid) RETURNS TABLE(success boolean, message text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_order RECORD;
    v_current_user_id UUID;
    v_inventory_pool RECORD;
BEGIN
    -- Get current user with fallback
    v_current_user_id := COALESCE(
        p_user_id,
        get_current_profile_id(),
        (SELECT created_by FROM currency_orders WHERE id = p_order_id LIMIT 1)
    );

    -- Get order details
    SELECT * INTO v_order
    FROM currency_orders
    WHERE id = p_order_id;

    IF NOT FOUND THEN
        RETURN QUERY
        SELECT false, 'Order not found';
        RETURN;
    END IF;

    -- Only process sell orders
    IF v_order.order_type != 'SALE' THEN
        RETURN QUERY
        SELECT false, 'This function only handles sell orders';
        RETURN;
    END IF;

    -- Only allow cancellation for certain statuses
    IF v_order.status IN ('completed', 'cancelled') THEN
        -- For cancelled orders, check if inventory needs fixing
        IF v_order.status = 'cancelled' THEN
            -- Check if inventory_pool_id exists
            IF v_order.inventory_pool_id IS NOT NULL THEN
                SELECT * INTO v_inventory_pool
                FROM inventory_pools
                WHERE id = v_order.inventory_pool_id
                FOR UPDATE;

                -- Fix inventory if reserved_quantity > 0
                IF v_inventory_pool.id IS NOT NULL AND v_inventory_pool.reserved_quantity >= v_order.quantity THEN
                    UPDATE inventory_pools
                    SET
                        quantity = GREATEST(0, quantity + v_order.quantity),
                        reserved_quantity = GREATEST(0, COALESCE(reserved_quantity, 0) - v_order.quantity),
                        last_updated_at = NOW(),
                        last_updated_by = v_current_user_id
                    WHERE id = v_inventory_pool.id;

                    RETURN QUERY
                    SELECT true, 'Cancelled order inventory corrected';
                    RETURN;
                END IF;
            END IF;

            RETURN QUERY
            SELECT true, 'Order already cancelled (inventory correct)';
            RETURN;
        END IF;

        RETURN QUERY
        SELECT false, 'Order cannot be cancelled in current status: ' || v_order.status;
        RETURN;
    END IF;

    -- Get inventory pool (use inventory_pool_id from order if available)
    IF v_order.inventory_pool_id IS NOT NULL THEN
        SELECT * INTO v_inventory_pool
        FROM inventory_pools
        WHERE id = v_order.inventory_pool_id
        FOR UPDATE;
    ELSE
        -- Fallback: find pool by game account and currency
        SELECT * INTO v_inventory_pool
        FROM inventory_pools
        WHERE game_account_id = v_order.game_account_id
          AND currency_attribute_id = v_order.currency_attribute_id
          AND COALESCE(channel_id, '00000000-0000-0000-0000-000000000000'::UUID) = COALESCE(v_order.channel_id, '00000000-0000-0000-0000-000000000000'::UUID)
          AND game_code = v_order.game_code
        FOR UPDATE;
    END IF;

    -- Update inventory if pool found
    IF v_inventory_pool.id IS NOT NULL THEN
        -- For sell orders, when cancelling:
        -- - quantity += order_quantity (return to available stock)
        -- - reserved_quantity -= order_quantity (remove from reserved)
        UPDATE inventory_pools
        SET
            quantity = GREATEST(0, quantity + v_order.quantity),
            reserved_quantity = GREATEST(0, COALESCE(reserved_quantity, 0) - v_order.quantity),
            last_updated_at = NOW(),
            last_updated_by = v_current_user_id
        WHERE id = v_inventory_pool.id;

        -- Update order with inventory pool reference
        UPDATE currency_orders
        SET inventory_pool_id = v_inventory_pool.id
        WHERE id = p_order_id;

        RAISE LOG 'Cancelled sell order %: pool_id=%s, quantity_returned=%s, reserved_removed=%s',
            p_order_id, v_inventory_pool.id, v_order.quantity, v_order.quantity;
    END IF;

    -- Update order status to cancelled
    UPDATE currency_orders
    SET
        status = 'cancelled',
        cancelled_at = NOW(),
        updated_at = NOW(),
        updated_by = v_current_user_id
    WHERE id = p_order_id;

    RETURN QUERY
    SELECT true, 'Sell order cancelled and inventory rolled back';
    RETURN;
END;
$$;


--
-- Name: cancel_work_session_v1(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.cancel_work_session_v1(p_session_id uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
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

    -- Lấy service_type từ product_variants.display_name
    SELECT
        ol.order_id,
        pv.display_name
    INTO
        v_order_id,
        v_service_type
    FROM public.order_lines ol
    LEFT JOIN public.product_variants pv ON ol.variant_id = pv.id
    WHERE ol.id = v_order_line_id;

    -- Dùng tên đúng 'Service - Selfplay' và luôn set paused_at khi cancel
    IF v_service_type = 'Service - Selfplay' THEN
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
        IF v_service_type = 'Service - Pilot' THEN
            UPDATE public.orders SET status = 'pending_pilot' WHERE id = v_order_id;
        ELSIF v_service_type = 'Service - Selfplay' THEN
            UPDATE public.orders SET status = 'paused_selfplay' WHERE id = v_order_id;
        END IF;
    ELSE
        UPDATE public.orders SET status = 'new' WHERE id = v_order_id;
    END IF;
END;
$$;


--
-- Name: check_and_reset_pilot_cycle(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.check_and_reset_pilot_cycle(p_order_line_id uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
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
    -- ORIGINAL PRODUCTION LOGIC (no order_service_items or profile_view)
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

    -- Calculate hours online and rest
    v_hours_online := EXTRACT(EPOCH FROM (NOW() - v_cycle_start_at)) / 3600;
    v_hours_rest := COALESCE(EXTRACT(EPOCH FROM (NOW() - v_current_paused_at)) / 3600, 0);

    -- Required rest hours based on service type
    v_required_rest_hours := CASE
        WHEN v_service_type LIKE '%Boss%' THEN 8
        WHEN v_service_type LIKE '%Dungeon%' THEN 6
        WHEN v_service_type LIKE '%Quest%' THEN 4
        ELSE 3
    END;

    -- Reset cycle if conditions are met
    IF v_hours_online >= 10 AND v_hours_rest >= v_required_rest_hours THEN
        NULL; -- Original production logic was simpler
    END IF;
END;
$$;


--
-- Name: check_currency_order_sla_breaches(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.check_currency_order_sla_breaches() RETURNS TABLE(order_id uuid, order_number text, customer_name text, sla_breached boolean, hours_overdue numeric)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        o.id as order_id,
        o.order_number,
        o.customer_name,
        CASE WHEN o.created_at < NOW() - INTERVAL '24 hours' 
             AND o.status NOT IN ('completed', 'cancelled', 'delivered') 
             THEN true ELSE false END as sla_breached,
        EXTRACT(EPOCH FROM (NOW() - o.created_at))/3600 - 24 as hours_overdue
    FROM orders o
    WHERE o.order_type IN ('currency_purchase', 'currency_sell')
      AND o.created_at < NOW() - INTERVAL '24 hours'
      AND o.status NOT IN ('completed', 'cancelled', 'delivered');
END;
$$;


--
-- Name: check_inventory_pool_availability(uuid, text, numeric, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.check_inventory_pool_availability(p_currency_attribute_id uuid, p_game_code text, p_required_quantity numeric, p_server_attribute_code text DEFAULT NULL::text) RETURNS TABLE(available boolean, total_available_pools integer, total_available_quantity numeric, message text, suggested_accounts jsonb, suggested_cost_currencies jsonb)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'extensions'
    AS $$
BEGIN
    RETURN QUERY
    WITH available_pools AS (
        SELECT
            ip.id,
            ip.game_account_id,
            ga.account_name,
            ip.cost_currency,
            ip.quantity,  -- FIXED: Use simple quantity instead of calculated available
            ip.quantity as available_quantity  -- FIXED: quantity = available stock
        FROM inventory_pools ip
        JOIN game_accounts ga ON ip.game_account_id = ga.id
        WHERE ip.currency_attribute_id = p_currency_attribute_id
          AND ip.game_code = p_game_code
          AND (p_server_attribute_code IS NULL OR ip.server_attribute_code = p_server_attribute_code OR ip.server_attribute_code IS NULL)
          AND ip.quantity >= p_required_quantity  -- FIXED: Use simple quantity check
          AND ga.is_active = true
    ),
    summary AS (
        SELECT
            COUNT(*)::INTEGER as pool_count,
            SUM(available_quantity) as total_quantity,
            JSONB_AGG(DISTINCT account_name) as accounts,
            JSONB_AGG(DISTINCT cost_currency) as cost_currencies
        FROM available_pools
    )
    SELECT
        CASE WHEN s.pool_count > 0 THEN true ELSE false END as available,
        s.pool_count as total_available_pools,
        COALESCE(s.total_quantity, 0) as total_available_quantity,
        CASE 
            WHEN s.pool_count > 0 THEN 
                'Found ' || s.pool_count || ' suitable pool(s) with total available quantity: ' || COALESCE(s.total_quantity::TEXT, '0')
            ELSE 
                'No suitable inventory pools found for game: ' || p_game_code || ', required: ' || p_required_quantity
        END as message,
        s.accounts as suggested_accounts,
        s.cost_currencies as suggested_cost_currencies
    FROM summary s;
    
    RETURN;
END;
$$;


--
-- Name: check_purchase_price_vs_inventory(text, text, uuid, uuid, text, numeric); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.check_purchase_price_vs_inventory(p_game_code text, p_server_attribute_code text, p_currency_attribute_id uuid, p_channel_id uuid, p_currency_code text, p_unit_price numeric) RETURNS TABLE(has_inventory_pool boolean, average_cost numeric, cost_currency text, price_difference_percent numeric, warning_level text, comparison_message text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_inventory_pool RECORD;
    v_price_diff_percent DECIMAL;
    v_warning_level TEXT;
    v_comparison_message TEXT;
BEGIN
    -- Find matching inventory pool
    SELECT * INTO v_inventory_pool
    FROM inventory_pools
    WHERE game_code = p_game_code
      AND (p_server_attribute_code IS NULL OR server_attribute_code = p_server_attribute_code)
      AND currency_attribute_id = p_currency_attribute_id
      AND (p_channel_id IS NULL OR channel_id = p_channel_id)
    LIMIT 1;
    
    IF NOT FOUND THEN
        -- No matching inventory pool found - return 0 as DECIMAL
        RETURN QUERY SELECT 
            false as has_inventory_pool,
            0.0 as average_cost,
            '' as cost_currency,
            0.0 as price_difference_percent,
            'no_data' as warning_level,
            'Không có dữ liệu inventory để so sánh' as comparison_message;
        RETURN;
    END IF;
    
    -- Calculate price difference percentage
    IF COALESCE(v_inventory_pool.average_cost, 0) > 0 AND v_inventory_pool.cost_currency = p_currency_code THEN
        v_price_diff_percent := ((p_unit_price - v_inventory_pool.average_cost) / v_inventory_pool.average_cost) * 100;
    ELSE
        -- Different currency or zero cost, cannot compare
        RETURN QUERY SELECT 
            true as has_inventory_pool,
            COALESCE(v_inventory_pool.average_cost, 0.0) as average_cost,
            v_inventory_pool.cost_currency as cost_currency,
            0.0 as price_difference_percent,
            'no_data' as warning_level,
            'Không thể so sánh: khác loại tiền hoặc giá trung bình = 0' as comparison_message;
        RETURN;
    END IF;
    
    -- Determine warning level
    IF ABS(v_price_diff_percent) >= 10 THEN
        v_warning_level := 'high';
    ELSIF ABS(v_price_diff_percent) >= 5 THEN
        v_warning_level := 'medium';
    ELSIF ABS(v_price_diff_percent) >= 2 THEN
        v_warning_level := 'low';
    ELSE
        v_warning_level := 'normal';
    END IF;
    
    -- Create comparison message with proper string concatenation instead of FORMAT
    IF ABS(v_price_diff_percent) >= 10 THEN
        v_comparison_message := 'Giá nhập lệch ' || ROUND(ABS(v_price_diff_percent), 1) || '% so với giá trung bình (' || v_inventory_pool.average_cost || ' ' || v_inventory_pool.cost_currency || '). CẢNH BÁO: Giá quá ' || CASE WHEN v_price_diff_percent > 0 THEN 'cao' ELSE 'thấp' END || '!';
    ELSIF ABS(v_price_diff_percent) >= 5 THEN
        v_comparison_message := 'Giá nhập lệch ' || ROUND(ABS(v_price_diff_percent), 1) || '% so với giá trung bình (' || v_inventory_pool.average_cost || ' ' || v_inventory_pool.cost_currency || ')';
    ELSE
        v_comparison_message := 'Giá nhập phù hợp (chênh lệch ' || ROUND(ABS(v_price_diff_percent), 1) || '% so với giá trung bình ' || v_inventory_pool.average_cost || ' ' || v_inventory_pool.cost_currency || ')';
    END IF;
    
    -- Return results
    RETURN QUERY SELECT 
        true as has_inventory_pool,
        v_inventory_pool.average_cost as average_cost,
        v_inventory_pool.cost_currency as cost_currency,
        v_price_diff_percent as price_difference_percent,
        v_warning_level as warning_level,
        v_comparison_message as comparison_message;
        
END;
$$;


--
-- Name: complete_currency_order_v1(uuid, text, text[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.complete_currency_order_v1(p_order_id uuid, p_completion_notes text DEFAULT NULL::text, p_proof_urls text[] DEFAULT NULL::text[]) RETURNS TABLE(success boolean, message text, transaction_id uuid, profit_vnd numeric)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_user_id uuid := public.get_current_profile_id();
    v_order RECORD;
    v_transaction_id uuid;
    v_can_complete boolean := false;
    v_avg_cost_vnd numeric;
    v_inventory_pool RECORD;
BEGIN
    -- Permission Check
    v_can_complete := public.has_permission('currency:complete', jsonb_build_object('game_code', (SELECT game_code FROM public.currency_orders WHERE id = p_order_id)));

    IF NOT v_can_complete THEN
        RETURN QUERY SELECT FALSE, 'Permission denied: Cannot complete order', NULL::UUID, NULL::NUMERIC;
        RETURN;
    END IF;

    -- Get order info
    SELECT * INTO v_order FROM public.currency_orders
    WHERE id = p_order_id AND status IN ('assigned', 'preparing', 'ready', 'delivering');

    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'Order not found or not ready for completion', NULL::UUID, NULL::NUMERIC;
        RETURN;
    END IF;

    -- Find inventory pool and get average cost
    SELECT * INTO v_inventory_pool
    FROM public.inventory_pools
    WHERE game_account_id = v_order.game_account_id
      AND currency_attribute_id = v_order.currency_attribute_id
      AND game_code = v_order.game_code
      AND COALESCE(server_attribute_code, '') = COALESCE(v_order.server_attribute_code, '')
      AND COALESCE(channel_id, '00000000-0000-0000-0000-000000000000'::UUID) = COALESCE(v_order.channel_id, '00000000-0000-0000-0000-000000000000'::UUID)
    FOR UPDATE;

    IF v_inventory_pool.id IS NOT NULL THEN
        v_avg_cost_vnd := v_inventory_pool.average_cost;
    END IF;

    -- Create transaction
    INSERT INTO public.currency_transactions (
        game_account_id, game_code, server_attribute_code,
        transaction_type, currency_attribute_id, quantity,
        unit_price, currency_code,
        channel_id, currency_order_id, proofs, notes, created_by
    ) VALUES (
        v_order.game_account_id, v_order.game_code, v_order.server_attribute_code,
        'sale_delivery', v_order.currency_attribute_id, -v_order.quantity,
        v_order.unit_price_vnd, v_order.unit_price_currency,
        v_order.channel_id, p_order_id,
        CASE
            WHEN p_proof_urls IS NOT NULL THEN to_jsonb(p_proof_urls)
            ELSE NULL
        END,
        p_completion_notes, v_user_id
    ) RETURNING id INTO v_transaction_id;

    -- Update inventory pool (only reserved_quantity for sell orders)
    IF v_inventory_pool.id IS NOT NULL THEN
        UPDATE public.inventory_pools
        SET
            reserved_quantity = GREATEST(0, COALESCE(reserved_quantity, 0) - v_order.quantity),
            last_updated_at = NOW(),
            last_updated_by = v_user_id
        WHERE id = v_inventory_pool.id;

        RAISE LOG 'Completed sell order %: pool_id=%s, reserved_removed=%s',
            p_order_id, v_inventory_pool.id, v_order.quantity;
    END IF;

    -- Update order status
    UPDATE public.currency_orders
    SET status = 'delivered',
        delivered_at = NOW(),
        delivered_by = v_user_id,
        completion_notes = p_completion_notes,
        proofs = CASE
            WHEN p_proof_urls IS NOT NULL THEN to_jsonb(p_proof_urls)
            ELSE NULL
        END,
        cost_per_unit_vnd = v_avg_cost_vnd,
        inventory_pool_id = v_inventory_pool.id,
        updated_at = NOW(),
        updated_by = v_user_id
    WHERE id = p_order_id;

    RETURN QUERY SELECT
        TRUE,
        'Order marked as delivered. Upload proof to complete.',
        v_transaction_id,
        (v_order.unit_price_vnd - COALESCE(v_avg_cost_vnd, 0)) * v_order.quantity;
END;
$$;


--
-- Name: complete_exchange_currency_order(uuid, uuid, jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.complete_exchange_currency_order(p_order_id uuid, p_completed_by_id uuid DEFAULT NULL::uuid, p_proofs jsonb DEFAULT NULL::jsonb) RETURNS TABLE(success boolean, message text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_current_user_id UUID;
    v_order RECORD;
    v_source_pool_id UUID;
    v_target_pool_id UUID;
    v_source_pool_cost_currency TEXT;
    v_server_code TEXT;
    v_game_code TEXT;
    v_game_account_id UUID;
    v_source_currency_id UUID;
    v_source_quantity NUMERIC;
    v_target_currency_id UUID;
    v_target_quantity NUMERIC;
    v_channel_id UUID;
    v_target_pool_existing_value NUMERIC;
    v_target_pool_existing_quantity NUMERIC;
    v_target_pool_new_quantity NUMERIC;
    v_target_pool_new_average_cost NUMERIC;
    v_target_unit_cost_from_order NUMERIC;
    v_proofs_count INTEGER;
BEGIN
    -- Get current user ID from parameter (memory.md compliant)
    IF p_completed_by_id IS NOT NULL THEN
        v_current_user_id := p_completed_by_id;
    ELSE
        -- Fallback to profiles lookup if not provided
        SELECT id INTO v_current_user_id
        FROM profiles
        WHERE user_id = auth.uid();
    END IF;
    
    IF v_current_user_id IS NULL THEN
        RAISE EXCEPTION 'Invalid user profile';
    END IF;
    
    -- Get order information
    SELECT * INTO v_order
    FROM currency_orders
    WHERE id = p_order_id AND order_type = 'EXCHANGE' AND status = 'draft';
    
    IF v_order IS NULL THEN
        RETURN QUERY SELECT FALSE, 'Order không tồn tại hoặc không ở trạng thái draft'::TEXT;
        RETURN;
    END IF;
    
    -- ✅ VALIDATE PROOFS ARE PROVIDED (Mandatory)
    IF p_proofs IS NULL OR jsonb_array_length(p_proofs) = 0 THEN
        RETURN QUERY SELECT FALSE, 'Exchange order yêu cầu phải có proofs (hình ảnh chụp màn hình) trước khi hoàn thành'::TEXT;
        RETURN;
    END IF;
    
    -- Validate proofs structure
    SELECT jsonb_array_length(p_proofs) INTO v_proofs_count;
    IF v_proofs_count IS NULL OR v_proofs_count = 0 THEN
        RETURN QUERY SELECT FALSE, 'Proofs không hợp lệ. Vui lòng upload ít nhất 1 file hình ảnh.'::TEXT;
        RETURN;
    END IF;
    
    -- Assign variables from order
    v_game_account_id := v_order.game_account_id;
    v_source_currency_id := v_order.currency_attribute_id;
    v_source_quantity := v_order.quantity;
    v_target_currency_id := v_order.foreign_currency_id;
    v_target_quantity := v_order.foreign_amount;
    v_channel_id := v_order.channel_id;
    v_game_code := v_order.game_code;
    v_server_code := v_order.server_attribute_code;
    
    -- Calculate unit costs from order (they should be based on equal total values)
    v_target_unit_cost_from_order := v_order.cost_amount / v_target_quantity;
    
    -- Find source pool to determine cost currency
    SELECT id, cost_currency INTO v_source_pool_id, v_source_pool_cost_currency
    FROM inventory_pools
    WHERE currency_attribute_id = v_source_currency_id
      AND game_account_id = v_game_account_id
      AND game_code = v_game_code
      AND (server_attribute_code = v_server_code OR (server_attribute_code IS NULL AND v_server_code IS NULL))
      AND channel_id = v_channel_id
      AND quantity >= v_source_quantity
    ORDER BY last_updated_at ASC  -- FIFO: oldest pool first
    LIMIT 1;
    
    IF v_source_pool_id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'Không tìm thấy inventory pool phù hợp hoặc không đủ tồn kho'::TEXT;
        RETURN;
    END IF;
    
    -- Update source pool (reduce quantity)
    UPDATE inventory_pools
    SET quantity = quantity - v_source_quantity,
        last_updated_by = v_current_user_id,
        last_updated_at = NOW()
    WHERE id = v_source_pool_id;
    
    -- Find existing target pool to calculate weighted average
    SELECT id, quantity, average_cost, 
           quantity * average_cost as existing_value
    INTO v_target_pool_id, v_target_pool_existing_quantity, v_target_pool_existing_value
    FROM inventory_pools
    WHERE currency_attribute_id = v_target_currency_id
      AND game_account_id = v_game_account_id
      AND game_code = v_game_code
      AND (server_attribute_code = v_server_code OR (server_attribute_code IS NULL AND v_server_code IS NULL))
      AND channel_id = v_channel_id
      AND cost_currency = v_source_pool_cost_currency;
    
    IF v_target_pool_id IS NOT NULL THEN
        -- ✅ UPDATE EXISTING TARGET POOL WITH WEIGHTED AVERAGE
        -- Formula: (old_avg * old_qty + new_avg * new_qty) / (old_qty + new_qty)
        
        v_target_pool_new_quantity := v_target_pool_existing_quantity + v_target_quantity;
        v_target_pool_new_average_cost := (
            (v_target_pool_existing_value + v_order.cost_amount) / v_target_pool_new_quantity
        );
        
        UPDATE inventory_pools
        SET quantity = v_target_pool_new_quantity,
            average_cost = v_target_pool_new_average_cost,
            last_updated_by = v_current_user_id,
            last_updated_at = NOW()
        WHERE id = v_target_pool_id;
        
    ELSE
        -- ✅ CREATE NEW TARGET POOL WITH CORRECT UNIT COST
        v_target_pool_new_average_cost := v_target_unit_cost_from_order;
        
        INSERT INTO inventory_pools (
            game_account_id,
            currency_attribute_id,
            channel_id,
            cost_currency,
            quantity,
            average_cost,
            game_code,
            server_attribute_code,
            reserved_quantity,
            last_updated_by,
            last_updated_at
        ) VALUES (
            v_game_account_id,
            v_target_currency_id,
            v_channel_id,
            v_source_pool_cost_currency,
            v_target_quantity,
            v_target_pool_new_average_cost,  -- Use correct unit cost from order
            v_game_code,
            v_server_code,
            0,
            v_current_user_id,
            NOW()
        );
    END IF;
    
    -- Create currency transactions with CORRECT unit prices
    INSERT INTO currency_transactions (
        game_account_id,
        game_code,
        currency_attribute_id,
        transaction_type,
        quantity,
        unit_price,
        currency_code,
        currency_order_id,
        created_by
    ) VALUES (
        v_game_account_id,
        v_game_code,
        v_source_currency_id,
        'exchange_out',
        v_source_quantity,
        v_order.cost_amount / v_source_quantity,  -- Source unit cost
        v_order.cost_currency_code,
        p_order_id,
        v_current_user_id
    );
    
    INSERT INTO currency_transactions (
        game_account_id,
        game_code,
        currency_attribute_id,
        transaction_type,
        quantity,
        unit_price,
        currency_code,
        currency_order_id,
        created_by
    ) VALUES (
        v_game_account_id,
        v_game_code,
        v_target_currency_id,
        'exchange_in',
        v_target_quantity,
        v_target_unit_cost_from_order,  -- ✅ CORRECT: Target unit cost from order
        v_order.cost_currency_code,
        p_order_id,
        v_current_user_id
    );
    
    -- Update order status to completed with MANDATORY proofs
    UPDATE currency_orders
    SET status = 'completed',
        delivery_at = NOW(),
        completed_at = NOW(),
        proofs = p_proofs,  -- ✅ MANDATORY: Store provided proofs
        updated_by = v_current_user_id,
        updated_at = NOW()
    WHERE id = p_order_id;
    
    RETURN QUERY SELECT TRUE, format('Hoàn thành exchange currency thành công. %s proofs đã được lưu.', v_proofs_count)::TEXT;
    
END;
$$;


--
-- Name: complete_order_line_v1(uuid, text[], text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.complete_order_line_v1(p_line_id uuid, p_completion_proof_urls text[], p_reason text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
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


--
-- Name: complete_purchase_order_wac(uuid, uuid, text[], uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.complete_purchase_order_wac(p_order_id uuid, p_completed_by uuid DEFAULT NULL::uuid, p_proofs text[] DEFAULT NULL::text[], p_channel_id uuid DEFAULT NULL::uuid) RETURNS TABLE(success boolean, message text, details jsonb)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_order RECORD;
    v_user_id UUID;
    v_existing_proofs JSONB;
    v_new_payment_proofs JSONB;
    v_final_proofs JSONB;
BEGIN
    -- Get user ID from parameter or current profile
    IF p_completed_by IS NOT NULL THEN
        v_user_id := p_completed_by;
    ELSE
        v_user_id := get_current_profile_id();
    END IF;
    
    -- Get order info - should already be delivered
    SELECT * INTO v_order FROM currency_orders
    WHERE id = p_order_id AND order_type = 'PURCHASE' AND status = 'delivered';

    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'Purchase order not found or not delivered yet. Use receive function first.', NULL::JSONB;
        RETURN;
    END IF;

    -- Get existing proofs from order
    v_existing_proofs := COALESCE(v_order.proofs, '{}'::jsonb);
    
    -- Build new payment proofs array from p_proofs parameter
    v_new_payment_proofs := '[]'::jsonb;
    
    -- Add new payment proofs from parameter
    IF p_proofs IS NOT NULL THEN
        FOR i IN 1..array_length(p_proofs, 1) LOOP
            v_new_payment_proofs := v_new_payment_proofs || 
                jsonb_build_object(
                    'type', 'payment',
                    'url', p_proofs[i],
                    'uploaded_at', NOW()::text
                );
        END LOOP;
    END IF;
    
    -- Merge existing proofs with new payment proofs
    v_final_proofs := v_existing_proofs || v_new_payment_proofs;

    -- Update order status to completed with completion timestamp
    UPDATE currency_orders SET
        status = 'completed',
        completed_at = NOW(),  -- Set completion timestamp
        proofs = v_final_proofs,
        updated_at = NOW(),
        updated_by = v_user_id
    WHERE id = p_order_id;

    -- Return success result
    RETURN QUERY SELECT TRUE, 
        format('Purchase order completed! %s payment proof(s) uploaded. Order: %s', 
               jsonb_array_length(v_new_payment_proofs),
               COALESCE(v_order.order_number, p_order_id::TEXT)
        ),
        jsonb_build_object(
            'order_id', p_order_id,
            'order_number', v_order.order_number,
            'status', 'completed',
            'completed_at', NOW(),
            'new_payment_proofs_count', jsonb_array_length(v_new_payment_proofs),
            'total_proofs_count', jsonb_array_length(v_final_proofs),
            'inventory_pool_id', v_order.inventory_pool_id  -- Reference to existing pool
        );
        
EXCEPTION
    WHEN OTHERS THEN
        -- Rollback any changes and return error
        RAISE WARNING 'Error in complete_purchase_order_wac: %', SQLERRM;
        RETURN QUERY SELECT FALSE, 'Error completing purchase order: ' || SQLERRM, NULL::JSONB;
END;
$$;


--
-- Name: complete_sale_order_v2(uuid, uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.complete_sale_order_v2(p_order_id uuid, p_user_id uuid DEFAULT NULL::uuid) RETURNS TABLE(success boolean, message text, order_id uuid)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_order RECORD;
    v_user_role TEXT;
    v_has_delivery_proof BOOLEAN := FALSE;
BEGIN
    -- Get order information
    SELECT * INTO v_order FROM currency_orders WHERE id = p_order_id;

    IF v_order IS NULL THEN
        RETURN QUERY SELECT false, 'Order not found', NULL::UUID;
        RETURN;
    END IF;

    -- Check if order type is SALE
    IF v_order.order_type != 'SALE' THEN
        RETURN QUERY SELECT false, 'Order is not a sale order', NULL::UUID;
        RETURN;
    END IF;

    -- Check if order is in delivered status
    IF v_order.status != 'delivered' THEN
        RETURN QUERY SELECT false, 'Order must be in delivered status to complete', NULL::UUID;
        RETURN;
    END IF;

    -- Get user role if user_id provided
    IF p_user_id IS NOT NULL THEN
        SELECT r.code INTO v_user_role
        FROM user_role_assignments ura
        JOIN roles r ON ura.role_id = r.id
        WHERE ura.user_id = p_user_id
        LIMIT 1;
    END IF;

    -- Check if user is admin/mod/manager/leader or created the order
    IF p_user_id IS NOT NULL AND (
        v_user_role IN ('admin', 'mod', 'manager', 'leader') OR
        v_order.created_by = p_user_id OR
        v_order.assigned_to = p_user_id
    ) THEN
        -- Check if delivery proof exists
        SELECT EXISTS (
            SELECT 1 FROM jsonb_array_elements(v_order.proofs) elem
            WHERE elem->>'type' = 'delivery'
        ) INTO v_has_delivery_proof;

        IF NOT v_has_delivery_proof THEN
            RETURN QUERY SELECT false, 'Delivery proof is required to complete sale order', NULL::UUID;
            RETURN;
        END IF;

        -- Update order status
        UPDATE currency_orders SET
            status = 'completed',
            completed_at = NOW(),
            updated_at = NOW()
        WHERE id = p_order_id;

        RETURN QUERY SELECT true, 'Sale order completed successfully', p_order_id;
        RETURN;
    END IF;

    RETURN QUERY SELECT false, 'Permission denied', NULL::UUID;
END;
$$;


--
-- Name: complete_sell_order_with_profit_calculation(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.complete_sell_order_with_profit_calculation() RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    profit_amount numeric;
    cost_amount numeric;
    revenue_amount numeric;
BEGIN
    -- Calculate cost from assigned inventory
    SELECT COALESCE(SUM(ip.cost_usd * soi.quantity), 0) INTO cost_amount
    FROM sell_orders so
    JOIN sell_order_items soi ON so.id = soi.sell_order_id
    JOIN order_assignments oa ON so.id = oa.order_id
    JOIN inventory_pools ip ON oa.inventory_pool_id = ip.id
    WHERE so.id = p_order_id;
    
    -- Get revenue from order
    SELECT COALESCE(SUM(soi.quantity * soi.unit_price), 0) INTO revenue_amount
    FROM sell_order_items soi
    WHERE soi.sell_order_id = p_order_id;
    
    -- Calculate profit
    profit_amount := revenue_amount - cost_amount;
    
    -- Update order with profit information
    UPDATE sell_orders
    SET status = 'completed',
        completed_at = NOW(),
        profit_amount = profit_amount,
        cost_amount = cost_amount,
        revenue_amount = revenue_amount
    WHERE id = p_order_id;
    
    RETURN profit_amount;
END;
$$;


--
-- Name: complete_sell_order_with_profit_calculation(uuid, uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.complete_sell_order_with_profit_calculation(p_order_id uuid, p_user_id uuid DEFAULT NULL::uuid) RETURNS TABLE(success boolean, message text, profit_amount numeric, profit_currency text, profit_margin_percentage numeric)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_order RECORD;
    v_inventory_pool RECORD;
    v_current_user_id UUID;
    v_profit_amount DECIMAL;
    v_profit_margin_percentage DECIMAL;
BEGIN
    -- Get current user (from parameter or auth)
    v_current_user_id := COALESCE(p_user_id, auth.uid());

    -- Get order details with inventory pool information
    SELECT 
        co.*,
        ip.average_cost as pool_average_cost,
        ip.cost_currency as pool_cost_currency
    INTO v_order
    FROM currency_orders co
    LEFT JOIN inventory_pools ip ON co.inventory_pool_id = ip.id
    WHERE co.id = p_order_id;

    IF NOT FOUND THEN
        RETURN QUERY
        SELECT false, 'Order not found', 0::DECIMAL, NULL::TEXT, 0::DECIMAL;
        RETURN;
    END IF;

    -- Only process sell orders
    IF v_order.order_type != 'SELL' THEN
        RETURN QUERY
        SELECT false, 'This function only handles sell orders', 0::DECIMAL, NULL::TEXT, 0::DECIMAL;
        RETURN;
    END IF;

    -- Only allow completion for 'delivered' status
    IF v_order.status != 'delivered' THEN
        RETURN QUERY
        SELECT false, 'Order must be in delivered status to complete', 0::DECIMAL, NULL::TEXT, 0::DECIMAL;
        RETURN;
    END IF;

    -- Check if we have inventory pool information
    IF v_order.inventory_pool_id IS NULL THEN
        RETURN QUERY
        SELECT false, 'No inventory pool assigned to this order', 0::DECIMAL, NULL::TEXT, 0::DECIMAL;
        RETURN;
    END IF;

    -- Calculate profit if we have sale amount
    IF v_order.sale_amount IS NOT NULL AND v_order.pool_average_cost IS NOT NULL THEN
        v_profit_amount := v_order.sale_amount - (v_order.quantity * v_order.pool_average_cost);
        
        -- Calculate profit margin percentage
        IF v_order.sale_amount != 0 THEN
            v_profit_margin_percentage := (v_profit_amount / v_order.sale_amount) * 100;
        END IF;
    END IF;

    -- Update inventory pool: reduce reserved quantity (actual delivery)
    UPDATE inventory_pools
    SET 
        reserved_quantity = reserved_quantity - v_order.quantity,
        last_updated_at = NOW(),
        last_updated_by = v_current_user_id
    WHERE id = v_order.inventory_pool_id;

    -- Update order with profit information and completion status
    UPDATE currency_orders
    SET 
        status = 'completed',
        completed_at = NOW(),
        updated_at = NOW(),
        updated_by = v_current_user_id,
        profit_amount = v_profit_amount,
        profit_currency_code = v_order.pool_cost_currency,
        profit_margin_percentage = v_profit_margin_percentage
    WHERE id = p_order_id;

    -- Return success result with profit calculation
    RETURN QUERY
    SELECT 
        true,
        format('Sell order completed successfully. Pool: %s | Profit: %s %s (%.2f%%)',
               v_order.inventory_pool_id, 
               COALESCE(v_profit_amount, 0), 
               COALESCE(v_order.pool_cost_currency, 'N/A'),
               COALESCE(v_profit_margin_percentage, 0))::TEXT,
        v_profit_amount,
        v_order.pool_cost_currency,
        v_profit_margin_percentage;

    RETURN;
END;
$$;


--
-- Name: confirm_purchase_order_receiving_v2(uuid, uuid, jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.confirm_purchase_order_receiving_v2(p_order_id uuid, p_completed_by uuid, p_proofs jsonb DEFAULT NULL::jsonb) RETURNS TABLE(success boolean, message text, details jsonb)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_order RECORD;
    v_user_id UUID := p_completed_by;
    v_inventory_pool RECORD;
    v_transaction_id UUID;
    v_new_average_cost DECIMAL;
    v_old_average_cost DECIMAL;
    v_new_quantity DECIMAL;
    v_cost_amount DECIMAL;
    v_cost_currency TEXT;
    v_game_account_id UUID;
    v_proof_urls TEXT[];
    v_existing_pool_found BOOLEAN := FALSE;
    v_order_channel_id UUID;
    v_channel_exists BOOLEAN := FALSE;
    v_existing_proofs JSONB;
    v_final_proofs JSONB;
    v_index INTEGER;
BEGIN
    -- Temporarily disable RLS for this function
    SET LOCAL row_security = off;

    -- Get order info
    SELECT * INTO v_order FROM currency_orders
    WHERE id = p_order_id AND order_type = 'PURCHASE' AND status IN ('assigned', 'preparing', 'ready', 'delivering');

    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'Purchase order not found or not ready for receiving confirmation', NULL::JSONB;
        RETURN;
    END IF;

    -- Validate required fields
    IF v_order.game_account_id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'Purchase order must be assigned to a game account first', NULL::JSONB;
        RETURN;
    END IF;

    -- Set values from order
    v_game_account_id := v_order.game_account_id;
    v_cost_amount := COALESCE(v_order.cost_amount, 0);
    v_cost_currency := COALESCE(v_order.cost_currency_code, 'VND');
    v_order_channel_id := v_order.channel_id;

    -- Validate that the channel exists
    SELECT EXISTS(SELECT 1 FROM channels WHERE id = v_order_channel_id AND is_active = true) INTO v_channel_exists;

    IF v_order_channel_id IS NOT NULL AND NOT v_channel_exists THEN
        RETURN QUERY SELECT FALSE, 'Invalid channel: Channel does not exist or is not active', NULL::JSONB;
        RETURN;
    END IF;

    -- Handle existing proofs - Append instead of replace
    v_existing_proofs := COALESCE(v_order.proofs, '[]'::JSONB);

    -- Ensure proofs is an array
    IF jsonb_typeof(v_existing_proofs) != 'array' THEN
        v_existing_proofs := '[]'::JSONB;
    END IF;

    -- Remove existing receiving proofs to avoid duplicates
    v_existing_proofs := (
        SELECT jsonb_agg(proof)
        FROM jsonb_array_elements(v_existing_proofs) AS proof
        WHERE proof->>'type' != 'receiving'
    );

    -- Process new proofs if provided
    IF p_proofs IS NOT NULL THEN
        -- Convert single proof to array if needed
        IF jsonb_typeof(p_proofs) != 'array' THEN
            p_proofs := jsonb_build_array(p_proofs);
        END IF;

        -- Build receiving proof objects
        v_final_proofs := '[]'::JSONB;

        FOR v_index IN 0..jsonb_array_length(p_proofs) - 1 LOOP
            v_final_proofs := v_final_proofs || jsonb_build_array(
                jsonb_set(
                    jsonb_set(
                        jsonb_extract_path(p_proofs, v_index::TEXT),
                        '{type}', '"receiving"'::jsonb
                    ),
                    '{uploaded_at}', to_jsonb(NOW())
                )
            );
        END LOOP;

        -- Combine existing proofs with new receiving proofs
        v_final_proofs := v_existing_proofs || v_final_proofs;
    ELSE
        v_final_proofs := v_existing_proofs;
    END IF;

    -- Find existing inventory pool - FIXED: Added channel_id to match unique constraint
    SELECT * INTO v_inventory_pool
    FROM inventory_pools
    WHERE game_account_id = v_game_account_id
      AND currency_attribute_id = v_order.currency_attribute_id
      AND game_code = v_order.game_code
      AND COALESCE(server_attribute_code, '') = COALESCE(v_order.server_attribute_code, '')
      AND COALESCE(channel_id, '00000000-0000-0000-0000-000000000000') = COALESCE(v_order_channel_id, '00000000-0000-0000-0000-000000000000')
    FOR UPDATE;

    IF v_inventory_pool.id IS NOT NULL THEN
        v_existing_pool_found := TRUE;
        v_old_average_cost := COALESCE(v_inventory_pool.average_cost, 0);
    END IF;

    -- Update or create inventory pool
    IF v_existing_pool_found THEN
        v_new_quantity := COALESCE(v_inventory_pool.quantity, 0) + v_order.quantity;

        IF v_new_quantity > 0 THEN
            v_new_average_cost := (
                (COALESCE(v_inventory_pool.quantity, 0) * COALESCE(v_inventory_pool.average_cost, 0)) +
                (v_order.quantity * v_cost_amount / v_order.quantity)
            ) / v_new_quantity;
        ELSE
            v_new_average_cost := v_cost_amount / v_order.quantity;
        END IF;

        UPDATE inventory_pools SET
            quantity = v_new_quantity,
            average_cost = v_new_average_cost,
            cost_currency = v_cost_currency,
            last_updated_at = NOW(),
            last_updated_by = v_user_id,
            channel_id = v_order_channel_id
        WHERE id = v_inventory_pool.id;

    ELSE
        v_new_quantity := v_order.quantity;
        v_new_average_cost := v_cost_amount / v_order.quantity;

        INSERT INTO inventory_pools (
            game_account_id,
            currency_attribute_id,
            quantity,
            average_cost,
            cost_currency,
            game_code,
            server_attribute_code,
            channel_id,
            last_updated_at,
            last_updated_by
        ) VALUES (
            v_game_account_id,
            v_order.currency_attribute_id,
            v_order.quantity,
            v_new_average_cost,
            v_cost_currency,
            v_order.game_code,
            v_order.server_attribute_code,
            v_order_channel_id,
            NOW(),
            v_user_id
        ) RETURNING * INTO v_inventory_pool;
    END IF;

    -- Create transaction record
    INSERT INTO currency_transactions (
        game_account_id,
        game_code,
        server_attribute_code,
        transaction_type,
        currency_attribute_id,
        quantity,
        unit_price,
        currency_code,
        channel_id,
        currency_order_id,
        proofs,
        notes,
        created_by
    ) VALUES (
        v_game_account_id,
        v_order.game_code,
        v_order.server_attribute_code,
        'purchase',
        v_order.currency_attribute_id,
        v_order.quantity,
        v_cost_amount / v_order.quantity,
        v_cost_currency,
        v_order_channel_id,
        p_order_id,
        v_final_proofs,
        'Purchase receiving confirmation - Order: ' || COALESCE(v_order.order_number, p_order_id::TEXT),
        v_user_id
    ) RETURNING id INTO v_transaction_id;

    -- Update order status with proofs
    UPDATE currency_orders SET
        status = 'delivered',
        delivered_by = v_user_id,
        delivery_at = NOW(),
        inventory_pool_id = v_inventory_pool.id,
        proofs = v_final_proofs,
        updated_at = NOW(),
        updated_by = v_user_id
    WHERE id = p_order_id;

    -- Return success
    RETURN QUERY SELECT TRUE,
        format('Purchase order receiving confirmed! %s added to inventory (Pool: %s)',
               v_order.quantity,
               v_inventory_pool.id::TEXT
        ),
        jsonb_build_object(
            'transaction_id', v_transaction_id,
            'inventory_pool_id', v_inventory_pool.id,
            'delivery_at', NOW(),
            'new_quantity', v_new_quantity,
            'proofs_added', COALESCE(jsonb_array_length(p_proofs), 0)
        );

EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'Error in confirm_purchase_order_receiving_v2: %', SQLERRM;
        RETURN QUERY SELECT FALSE, 'Error confirming purchase order receiving: ' || SQLERRM, NULL::JSONB;
END;
$$;


--
-- Name: convert_currency(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.convert_currency() RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
  rate NUMERIC;
BEGIN
  IF p_from_currency = p_to_currency THEN
    RETURN p_amount;
  END IF;
  
  rate := get_latest_exchange_rate(p_from_currency, p_to_currency);
  
  IF rate IS NULL THEN
    RAISE EXCEPTION 'Exchange rate not found for % to %', p_from_currency, p_to_currency;
  END IF;
  
  RETURN p_amount * rate;
END;
$$;


--
-- Name: convert_order_price(numeric, text, text, date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.convert_order_price(p_amount numeric, p_from_currency text, p_to_currency text, p_date date DEFAULT CURRENT_DATE) RETURNS numeric
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
    -- If same currency, no conversion needed
    IF p_from_currency = p_to_currency THEN
        RETURN p_amount;
    END IF;
    
    -- Convert using exchange rate
    RETURN p_amount * get_exchange_rate(p_from_currency, p_to_currency, p_date);
END;
$$;


--
-- Name: convert_order_to_usd(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.convert_order_to_usd(p_order_id uuid) RETURNS TABLE(order_id uuid, cost_amount_usd numeric, sale_amount_usd numeric, profit_amount_usd numeric, cost_currency text, sale_currency text, profit_currency text, exchange_rate_used numeric)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_order RECORD;
    v_cost_rate NUMERIC;
    v_sale_rate NUMERIC;
    v_profit_rate NUMERIC;
BEGIN
    -- Get order data
    SELECT * INTO v_order FROM currency_orders WHERE id = p_order_id;
    
    IF NOT FOUND THEN
        RETURN;
    END IF;
    
    -- Get exchange rate for cost to USD
    IF v_order.cost_currency_code = 'USD' THEN
        v_cost_rate := 1;
    ELSE
        SELECT rate INTO v_cost_rate
        FROM exchange_rates
        WHERE from_currency = v_order.cost_currency_code
          AND to_currency = 'USD'
          AND effective_date <= v_order.exchange_rate_date
          AND is_active = true
        ORDER BY effective_date DESC
        LIMIT 1;
        
        IF v_cost_rate IS NULL THEN
            v_cost_rate := 1; -- Default fallback
        END IF;
    END IF;
    
    -- Get exchange rate for sale to USD
    IF v_order.sale_currency_code = 'USD' THEN
        v_sale_rate := 1;
    ELSE
        SELECT rate INTO v_sale_rate
        FROM exchange_rates
        WHERE from_currency = v_order.sale_currency_code
          AND to_currency = 'USD'
          AND effective_date <= v_order.exchange_rate_date
          AND is_active = true
        ORDER BY effective_date DESC
        LIMIT 1;
        
        IF v_sale_rate IS NULL THEN
            v_sale_rate := 1; -- Default fallback
        END IF;
    END IF;
    
    -- Get exchange rate for profit to USD (should be same as sale rate)
    v_profit_rate := v_sale_rate;
    
    -- Return converted values
    RETURN QUERY
    SELECT 
        v_order.id as order_id,
        v_order.cost_amount * v_cost_rate as cost_amount_usd,
        v_order.sale_amount * v_sale_rate as sale_amount_usd,
        v_order.profit_amount * v_profit_rate as profit_amount_usd,
        v_order.cost_currency_code as cost_currency,
        v_order.sale_currency_code as sale_currency,
        v_order.profit_currency_code as profit_currency,
        v_order.cost_to_sale_exchange_rate as exchange_rate_used;
    
END;
$$;


--
-- Name: FUNCTION convert_order_to_usd(p_order_id uuid); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.convert_order_to_usd(p_order_id uuid) IS 'Convert order amounts to USD for reporting purposes (on-the-fly conversion)';


--
-- Name: count_proofs_by_stage(jsonb, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.count_proofs_by_stage(order_proofs jsonb, stage text) RETURNS integer
    LANGUAGE plpgsql IMMUTABLE
    SET search_path TO 'public, pg_temp'
    AS $$
BEGIN
    RETURN (
        SELECT COALESCE(SUM(
            CASE
                WHEN jsonb_typeof(proof_data) = 'object'
                THEN jsonb_array_length(proof_data->'files')
                ELSE 0
            END
        ), 0)
        FROM (
            SELECT jsonb_array_elements(order_proofs->stage) AS proof_data
        ) AS stages
    );
END;
$$;


--
-- Name: create_business_process_direct(text, text, text, boolean, uuid, uuid, text, uuid, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.create_business_process_direct(p_code text, p_name text, p_description text DEFAULT NULL::text, p_is_active boolean DEFAULT true, p_created_by uuid DEFAULT NULL::uuid, p_sale_channel_id uuid DEFAULT NULL::uuid, p_sale_currency text DEFAULT NULL::text, p_purchase_channel_id uuid DEFAULT NULL::uuid, p_purchase_currency text DEFAULT NULL::text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
  v_process_id UUID;
BEGIN
  -- Generate UUID for new process
  v_process_id := gen_random_uuid();

  -- Insert new business process (this bypasses RLS due to SECURITY DEFINER)
  INSERT INTO business_processes (
    id,
    code,
    name,
    description,
    is_active,
    created_at,
    created_by,
    sale_channel_id,
    sale_currency,
    purchase_channel_id,
    purchase_currency
  ) VALUES (
    v_process_id,
    p_code,
    p_name,
    p_description,
    p_is_active,
    NOW(),
    p_created_by,
    p_sale_channel_id,
    p_sale_currency,
    p_purchase_channel_id,
    p_purchase_currency
  );

  RETURN jsonb_build_object(
    'success', true,
    'message', 'Tạo quy trình kinh doanh thành công',
    'process_id', v_process_id
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Lỗi khi tạo quy trình kinh doanh: ' || SQLERRM
    );
END;
$$;


--
-- Name: create_channel_direct(text, text, text, text, text, boolean, uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.create_channel_direct(p_code text, p_name text, p_description text DEFAULT NULL::text, p_website_url text DEFAULT NULL::text, p_direction text DEFAULT 'BOTH'::text, p_is_active boolean DEFAULT true, p_created_by uuid DEFAULT NULL::uuid) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
  v_channel_id UUID;
  v_channel_name TEXT;
BEGIN
  -- Generate UUID for new channel
  v_channel_id := gen_random_uuid();
  v_channel_name := COALESCE(p_name, 'Unnamed Channel');

  -- Insert new channel (this bypasses RLS due to SECURITY DEFINER)
  INSERT INTO channels (
    id,
    code,
    name,
    description,
    website_url,
    direction,
    is_active,
    created_by,
    created_at,
    updated_at
  ) VALUES (
    v_channel_id,
    p_code,
    v_channel_name,
    p_description,
    p_website_url,
    p_direction,
    p_is_active,
    p_created_by,
    NOW(),
    NOW()
  );

  RETURN jsonb_build_object(
    'success', true,
    'message', 'Tạo kênh giao dịch thành công',
    'channel_id', v_channel_id,
    'channel_name', v_channel_name,
    'channel_code', p_code
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Lỗi khi tạo kênh giao dịch: ' || SQLERRM
    );
END;
$$;


--
-- Name: create_currency_exchange_order(uuid, numeric, numeric, text, uuid, numeric, uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.create_currency_exchange_order(p_source_currency_id uuid, p_source_quantity numeric, p_source_cost_amount numeric, p_source_cost_currency_code text, p_target_currency_id uuid, p_target_quantity numeric, p_game_account_id uuid) RETURNS TABLE(order_id uuid, order_number text, status text, message text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_current_user_id UUID;
    v_order_number TEXT;
    v_order_id UUID;
    v_source_currency_code TEXT;
    v_target_currency_code TEXT;
    v_source_currency_name TEXT;
    v_target_currency_name TEXT;
    v_source_total_value_vnd NUMERIC;
    v_target_unit_price_vnd NUMERIC;
    v_pool_id UUID;
    v_party_id UUID;
    v_channel_id UUID;
    v_server_code TEXT;
    v_game_code TEXT;
    v_exchange_details JSONB;
    v_source_pool_cost_currency TEXT;
    v_quantity_needed NUMERIC;
    v_available_quantity NUMERIC;
BEGIN
    -- Lấy user ID hiện tại
    SELECT get_current_profile_id() INTO v_current_user_id;
    
    IF v_current_user_id IS NULL THEN
        RAISE EXCEPTION 'User not authenticated';
    END IF;
    
    -- Lấy thông tin game account để kiểm tra
    SELECT game_code, server_attribute_code
    INTO v_game_code, v_server_code
    FROM game_accounts
    WHERE id = p_game_account_id AND is_active = true;
    
    IF v_game_code IS NULL THEN
        RETURN QUERY SELECT NULL::UUID, NULL::TEXT, 'ERROR'::TEXT, 'Game account không tồn tại hoặc không hoạt động'::TEXT;
        RETURN;
    END IF;
    
    -- Lấy thông tin currency
    SELECT code, name
    INTO v_source_currency_code, v_source_currency_name
    FROM currency_attributes
    WHERE id = p_source_currency_id AND is_active = true;
    
    SELECT code, name
    INTO v_target_currency_code, v_target_currency_name
    FROM currency_attributes
    WHERE id = p_target_currency_id AND is_active = true;
    
    IF v_source_currency_code IS NULL OR v_target_currency_code IS NULL THEN
        RETURN QUERY SELECT NULL::UUID, NULL::TEXT, 'ERROR'::TEXT, 'Currency không tồn tại hoặc không hoạt động'::TEXT;
        RETURN;
    END IF;
    
    -- Tính toán giá trị
    v_source_total_value_vnd := p_source_cost_amount * 
        CASE WHEN p_source_cost_currency_code = 'VND' THEN 1
             ELSE (SELECT rate FROM exchange_rates WHERE from_currency = p_source_cost_currency_code AND to_currency = 'VND' AND is_active = true LIMIT 1)
        END;
    
    v_target_unit_price_vnd := v_source_total_value_vnd / p_target_quantity;
    
    -- Tìm inventory pools của source currency để xác định channel và cost currency
    SELECT id, channel_id, cost_currency
    INTO v_pool_id, v_channel_id, v_source_pool_cost_currency
    FROM inventory_pools
    WHERE currency_attribute_id = p_source_currency_id
      AND game_account_id = p_game_account_id
      AND game_code = v_game_code
      AND (server_attribute_code = v_server_code OR (server_attribute_code IS NULL AND v_server_code IS NULL))
      AND quantity > 0
    LIMIT 1;
    
    IF v_pool_id IS NULL THEN
        RETURN QUERY SELECT NULL::UUID, NULL::TEXT, 'ERROR'::TEXT, 'Không tìm thấy inventory pool cho source currency'::TEXT;
        RETURN;
    END IF;
    
    -- Kiểm tra tồn kho source currency
    v_quantity_needed := p_source_quantity;
    v_available_quantity := 0;
    
    -- Tính tổng available quantity từ các pools
    SELECT SUM(quantity) INTO v_available_quantity
    FROM inventory_pools
    WHERE currency_attribute_id = p_source_currency_id
      AND game_account_id = p_game_account_id
      AND game_code = v_game_code
      AND (server_attribute_code = v_server_code OR (server_attribute_code IS NULL AND v_server_code IS NULL))
      AND channel_id = v_channel_id
      AND cost_currency = v_source_pool_cost_currency
      AND quantity > 0;
    
    IF v_available_quantity < v_quantity_needed THEN
        RETURN QUERY SELECT NULL::UUID, NULL::TEXT, 'ERROR'::TEXT, 
            'Không đủ tồn kho. Cần: ' || v_quantity_needed || ', Có: ' || v_available_quantity::TEXT;
        RETURN;
    END IF;
    
    -- Tạo party cho exchange nếu chưa có
    SELECT id INTO v_party_id FROM parties WHERE name = 'Currency Exchange System';
    
    IF v_party_id IS NULL THEN
        INSERT INTO parties (name, description, created_by, updated_by)
        VALUES ('Currency Exchange System', 'Hệ thống xử lý đổi currency nội bộ', v_current_user_id, v_current_user_id)
        RETURNING id INTO v_party_id;
    END IF;
    
    -- Tạo order number
    v_order_number := 'EX' || TO_CHAR(NOW(), 'YYYYMMDD') || LPAD(FLOOR(RANDOM() * 1000000)::TEXT, 6, '0');
    
    -- Tạo exchange details JSON
    v_exchange_details := jsonb_build_object(
        'source_currency', jsonb_build_object(
            'id', p_source_currency_id,
            'code', v_source_currency_code,
            'name', v_source_currency_name,
            'quantity', p_source_quantity,
            'cost_amount', p_source_cost_amount,
            'cost_currency_code', p_source_cost_currency_code
        ),
        'target_currency', jsonb_build_object(
            'id', p_target_currency_id,
            'code', v_target_currency_code,
            'name', v_target_currency_name,
            'quantity', p_target_quantity,
            'unit_price_vnd', v_target_unit_price_vnd,
            'total_value_vnd', v_source_total_value_vnd
        ),
        'exchange_rate', jsonb_build_object(
            'source_to_target', (p_target_quantity::NUMERIC / p_source_quantity::NUMERIC),
            'vnd_per_target', v_target_unit_price_vnd,
            'created_at', NOW()
        )
    );
    
    -- Tạo currency order với status COMPLETED (đổi currency hoàn thành ngay lập tức)
    INSERT INTO currency_orders (
        order_type,
        order_number,
        status,
        party_id,
        game_account_id,
        game_code,
        server_attribute_code,
        channel_id,
        currency_attribute_id,
        quantity,
        cost_amount,
        cost_currency_code,
        foreign_currency_id,
        foreign_currency_code,
        foreign_amount,
        sale_amount,
        sale_currency_code,
        exchange_type,
        exchange_details,
        submitted_at,
        delivery_at,
        completed_at,
        created_by
    ) VALUES (
        'EXCHANGE',
        v_order_number,
        'completed',  -- Hoàn thành ngay lập tức
        v_party_id,
        p_game_account_id,
        v_game_code,
        v_server_code,
        v_channel_id,
        p_source_currency_id,
        p_source_quantity,
        p_source_cost_amount,
        p_source_cost_currency_code,
        p_target_currency_id,
        v_target_currency_code,
        p_target_quantity,
        v_source_total_value_vnd,
        'VND',
        'MUA_NGANG_GIA',
        v_exchange_details,
        NOW(),  -- submitted_at
        NOW(),  -- delivery_at
        NOW(),  -- completed_at
        v_current_user_id
    ) RETURNING id INTO v_order_id;
    
    -- Trả về kết quả
    RETURN QUERY SELECT v_order_id, v_order_number, 'completed'::TEXT, 'Tạo đơn hàng thành công'::TEXT;
    
END;
$$;


--
-- Name: create_currency_order(uuid, uuid, text, text, numeric, numeric, text, timestamp with time zone); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.create_currency_order(p_customer_id uuid, p_channel_id uuid, p_currency_code text, p_order_type text, p_quantity numeric, p_unit_price numeric, p_notes text DEFAULT NULL::text, p_expires_at timestamp with time zone DEFAULT NULL::timestamp with time zone) RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_order_id UUID;
    v_channel RECORD;
    v_total_value NUMERIC;
    v_fee_amount NUMERIC;
    v_final_rate NUMERIC;
BEGIN
    -- Validate inputs
    IF p_customer_id IS NULL OR p_channel_id IS NULL OR p_currency_code IS NULL
       OR p_order_type IS NULL OR p_quantity IS NULL OR p_unit_price IS NULL THEN
        RAISE EXCEPTION 'Missing required fields';
    END IF;

    IF p_quantity <= 0 OR p_unit_price <= 0 THEN
        RAISE EXCEPTION 'Quantity and unit price must be positive';
    END IF;

    -- Get channel information
    SELECT * INTO v_channel FROM channels WHERE id = p_channel_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Channel not found: %', p_channel_id;
    END IF;

    -- Calculate total value
    v_total_value := p_quantity * p_unit_price;

    -- Calculate fee amount
    IF p_order_type = 'BUY' THEN
        v_fee_amount := v_total_value * (COALESCE(v_channel.purchase_fee_rate, 0) / 100) + COALESCE(v_channel.purchase_fee_fixed, 0);
    ELSIF p_order_type = 'SELL' THEN
        v_fee_amount := v_total_value * (COALESCE(v_channel.sale_fee_rate, 0) / 100) + COALESCE(v_channel.sale_fee_fixed, 0);
    ELSE
        v_fee_amount := 0;
    END IF;

    -- Calculate final rate
    v_final_rate := p_unit_price - (v_fee_amount / p_quantity);

    -- Create the order
    INSERT INTO currency_orders (
        customer_id,
        channel_id,
        currency_code,
        order_type,
        quantity,
        unit_price,
        total_value,
        fee_amount,
        final_rate,
        notes,
        expires_at,
        status
    ) VALUES (
        p_customer_id,
        p_channel_id,
        p_currency_code,
        p_order_type,
        p_quantity,
        p_unit_price,
        v_total_value,
        v_fee_amount,
        v_final_rate,
        p_notes,
        p_expires_at,
        'PENDING'
    ) RETURNING id INTO v_order_id;

    RETURN v_order_id;
END;
$$;


--
-- Name: create_currency_purchase_order(uuid, numeric, numeric, text, text, text, uuid, text, text, text, text, integer, uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.create_currency_purchase_order(p_currency_attribute_id uuid, p_quantity numeric, p_cost_amount numeric, p_cost_currency_code text, p_game_code text, p_server_attribute_code text, p_channel_id uuid, p_supplier_name text, p_supplier_contact text, p_delivery_info text, p_notes text, p_priority_level integer, p_user_id uuid) RETURNS TABLE(success boolean, order_id uuid, order_number text, message text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_order_id UUID;
    v_order_number TEXT;
    v_currency_code TEXT;
    v_supplier_party_id UUID;
    v_currency_exists BOOLEAN;
BEGIN
    -- Validate user_id parameter (following authentication rule)
    IF p_user_id IS NULL THEN
        RETURN QUERY SELECT FALSE, NULL::UUID, NULL::TEXT, 'Authentication required: user_id cannot be null';
        RETURN;
    END IF;

    -- Validate currency exists
    SELECT EXISTS(SELECT 1 FROM attributes WHERE id = p_currency_attribute_id AND type LIKE '%CURRENCY%')
    INTO v_currency_exists;

    IF NOT v_currency_exists THEN
        RETURN QUERY SELECT FALSE, NULL::UUID, NULL::TEXT, 'Currency attribute not found or not a currency type';
        RETURN;
    END IF;

    -- Get currency code for reference
    SELECT code INTO v_currency_code
    FROM attributes
    WHERE id = p_currency_attribute_id;

    -- Validate channel exists
    IF NOT EXISTS(SELECT 1 FROM channels WHERE id = p_channel_id) THEN
        RETURN QUERY SELECT FALSE, NULL::UUID, NULL::TEXT, 'Channel not found';
        RETURN;
    END IF;

    -- Create or find supplier party with more flexible lookup
    IF p_supplier_name IS NOT NULL THEN
        -- Try to find existing supplier by name and type
        SELECT id INTO v_supplier_party_id
        FROM parties
        WHERE name = p_supplier_name
        AND type = 'supplier'
        LIMIT 1;

        -- Create new supplier if not found
        IF v_supplier_party_id IS NULL THEN
            BEGIN
                INSERT INTO parties (name, type, contact_info, notes, channel_id, game_code)
                VALUES (p_supplier_name, 'supplier',
                        jsonb_build_object('contact', COALESCE(p_supplier_contact, '')),
                        'Auto-created for purchase order',
                        p_channel_id,
                        p_game_code)
                RETURNING id INTO v_supplier_party_id;
            EXCEPTION
                WHEN unique_violation THEN
                    -- If we get a unique violation, try to find the existing supplier again
                    SELECT id INTO v_supplier_party_id
                    FROM parties
                    WHERE name = p_supplier_name
                    AND type = 'supplier'
                    LIMIT 1;

                    -- If still not found, return error
                    IF v_supplier_party_id IS NULL THEN
                        RETURN QUERY SELECT FALSE, NULL::UUID, NULL::TEXT, 'Unable to create or find supplier: ' || p_supplier_name;
                        RETURN;
                    END IF;
            END;
        END IF;
    ELSE
        RETURN QUERY SELECT FALSE, NULL::UUID, NULL::TEXT, 'Supplier name is required';
        RETURN;
    END IF;

    -- Create the purchase order - order_number will be auto-generated by trigger
    INSERT INTO public.currency_orders (
        order_type,
        currency_attribute_id,
        quantity,
        cost_amount,
        cost_currency_code,
        game_code,
        server_attribute_code,
        channel_id,
        party_id,
        delivery_info,
        notes,
        status,
        priority_level,
        deadline_at,
        created_at,
        created_by  -- Use proper profiles.id from parameter
    ) VALUES (
        'PURCHASE',
        p_currency_attribute_id,
        p_quantity,
        p_cost_amount,
        p_cost_currency_code,
        p_game_code,
        p_server_attribute_code,
        p_channel_id,
        v_supplier_party_id,
        p_delivery_info,
        p_notes,
        'pending',
        p_priority_level,
        NOW() + INTERVAL '24 hours',
        NOW(),
        p_user_id  -- Proper authentication: use profiles.id from frontend
    )
    RETURNING public.currency_orders.id, public.currency_orders.order_number INTO v_order_id, v_order_number;

    -- Return success
    RETURN QUERY SELECT
        TRUE,
        v_order_id,
        v_order_number,
        'Purchase order created successfully';

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT
            FALSE,
            NULL::UUID,
            NULL::TEXT,
            'Error creating purchase order: ' || SQLERRM;
END;
$$;


--
-- Name: create_currency_purchase_order_draft(uuid, numeric, numeric, text, text, text, uuid, text, text, text, text, integer, uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.create_currency_purchase_order_draft(p_currency_attribute_id uuid, p_quantity numeric, p_cost_amount numeric, p_cost_currency_code text, p_game_code text, p_server_attribute_code text, p_channel_id uuid, p_supplier_name text, p_supplier_contact text, p_delivery_info text, p_notes text, p_priority_level integer, p_user_id uuid) RETURNS TABLE(success boolean, order_id uuid, order_number text, message text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_order_id UUID;
    v_order_number TEXT;
    v_currency_code TEXT;
    v_supplier_party_id UUID;
    v_currency_exists BOOLEAN;
    v_channel_code TEXT;
    v_cost_amount_final NUMERIC;
    v_cost_currency_code_final TEXT;
    v_delivery_info_final TEXT;      -- Game tag only
    v_notes_final TEXT;              -- Combined: delivery_contact_info | user_notes
    v_priority_level INTEGER;        -- Added missing declaration
BEGIN
    -- Set priority level from parameter or default
    v_priority_level := p_priority_level;

    -- Validate user_id parameter (following authentication rule)
    IF p_user_id IS NULL THEN
        RETURN QUERY SELECT FALSE, NULL::UUID, NULL::TEXT, 'Authentication required: user_id cannot be null';
        RETURN;
    END IF;

    -- Validate currency exists
    SELECT EXISTS(SELECT 1 FROM attributes WHERE id = p_currency_attribute_id AND type LIKE '%CURRENCY%')
    INTO v_currency_exists;

    IF NOT v_currency_exists THEN
        RETURN QUERY SELECT FALSE, NULL::UUID, NULL::TEXT, 'Currency attribute not found or not a currency type';
        RETURN;
    END IF;

    -- Get currency code for reference
    SELECT code INTO v_currency_code
    FROM attributes
    WHERE id = p_currency_attribute_id;

    -- Validate channel exists and get channel code
    SELECT code INTO v_channel_code
    FROM channels
    WHERE id = p_channel_id;

    IF v_channel_code IS NULL THEN
        RETURN QUERY SELECT FALSE, NULL::UUID, NULL::TEXT, 'Channel not found';
        RETURN;
    END IF;

    -- Use provided cost amount and currency, or defaults
    v_cost_amount_final := COALESCE(p_cost_amount, 0);
    v_cost_currency_code_final := COALESCE(p_cost_currency_code, 'VND');

    -- For WeChat channel, default to CNY if no currency specified
    IF v_channel_code = 'WeChat' AND v_cost_currency_code_final = 'VND' AND p_cost_currency_code IS NULL THEN
        v_cost_currency_code_final := 'CNY';
    END IF;

    -- Generate order number for purchase orders (using PO prefix instead of SO)
    v_order_number := 'PO' || TO_CHAR(NOW(), 'YYYYMMDD') || LPAD(EXTRACT(MICROSECONDS FROM NOW())::TEXT, 6, '0');

    -- UPDATED LOGIC: delivery_info contains game tag only
    v_delivery_info_final := COALESCE(p_delivery_info, '');

    -- UPDATED LOGIC: Build combined notes (delivery_contact_info | user_notes)
    v_notes_final := COALESCE(p_notes, '');

    -- Create or find supplier party with enhanced contact_info JSON
    IF p_supplier_name IS NOT NULL THEN
        SELECT id INTO v_supplier_party_id
        FROM parties
        WHERE name = p_supplier_name
        AND type = 'supplier'
        LIMIT 1;

        -- Create new supplier if not found
        IF v_supplier_party_id IS NULL THEN
            BEGIN
                INSERT INTO parties (name, type, contact_info, notes, channel_id, game_code)
                VALUES (p_supplier_name, 'supplier',
                        jsonb_build_object(
                            'contact', COALESCE(p_supplier_contact, ''),
                            'gameTag', v_delivery_info_final,      -- Game tag from delivery_info
                            'deliveryInfo', ''                    -- Suppliers don't need delivery info
                        ),
                        'Auto-created for purchase order draft',
                        p_channel_id,
                        p_game_code)
                RETURNING id INTO v_supplier_party_id;
            EXCEPTION
                WHEN unique_violation THEN
                    SELECT id INTO v_supplier_party_id
                    FROM parties
                    WHERE name = p_supplier_name
                    AND type = 'supplier'
                    LIMIT 1;

                    IF v_supplier_party_id IS NULL THEN
                        RETURN QUERY SELECT FALSE, NULL::UUID, NULL::TEXT, 'Unable to create or find supplier: ' || p_supplier_name;
                        RETURN;
                    END IF;
            END;
        ELSE
            -- Update existing supplier party with new contact info if provided
            UPDATE parties
            SET
                contact_info = jsonb_build_object(
                    'contact', COALESCE(p_supplier_contact, (contact_info->>'contact')),
                    'gameTag', v_delivery_info_final,      -- Game tag from delivery_info
                    'deliveryInfo', ''                    -- Suppliers don't need delivery info
                ),
                updated_at = NOW()
            WHERE id = v_supplier_party_id;
        END IF;
    ELSE
        RETURN QUERY SELECT FALSE, NULL::UUID, NULL::TEXT, 'Supplier name is required';
        RETURN;
    END IF;

    -- FIXED: Purchase orders only track cost, sale/profit fields are NULL
    INSERT INTO public.currency_orders (
        order_number,
        order_type,
        currency_attribute_id,
        quantity,
        cost_amount,
        cost_currency_code,
        sale_amount,                    -- NULL for purchase orders
        sale_currency_code,              -- NULL for purchase orders
        profit_amount,                   -- NULL for purchase orders
        profit_currency_code,            -- NULL for purchase orders
        profit_margin_percentage,         -- NULL for purchase orders
        cost_to_sale_exchange_rate,       -- NULL for purchase orders
        exchange_rate_date,               -- NULL for purchase orders
        exchange_rate_source,             -- NULL for purchase orders
        game_code,
        server_attribute_code,
        channel_id,
        party_id,
        delivery_info,                   -- Game tag only
        notes,                            -- delivery_contact_info | user_notes
        status,
        priority_level,
        deadline_at,
        created_at,
        created_by,                      -- Use proper profiles.id from parameter
        proofs
    ) VALUES (
        v_order_number,                  -- Generated order number
        'PURCHASE',
        p_currency_attribute_id,
        p_quantity,
        v_cost_amount_final,
        v_cost_currency_code_final,
        NULL,        -- sale_amount = NULL for purchase orders
        NULL,        -- sale_currency_code = NULL for purchase orders
        NULL,        -- profit_amount = NULL for purchase orders
        NULL,        -- profit_currency_code = NULL for purchase orders
        NULL,        -- profit_margin_percentage = NULL for purchase orders
        NULL,        -- cost_to_sale_exchange_rate = NULL for purchase orders
        NULL,        -- exchange_rate_date = NULL for purchase orders
        NULL,        -- exchange_rate_source = NULL for purchase orders
        p_game_code,
        p_server_attribute_code,
        p_channel_id,
        v_supplier_party_id,
        v_delivery_info_final,            -- Game tag only
        v_notes_final,                     -- delivery_contact_info | user_notes
        'draft',
        v_priority_level,                -- Use declared variable
        NOW() + INTERVAL '24 hours',
        NOW(),
        p_user_id,                        -- Proper authentication: use profiles.id from frontend
        '{}'::jsonb
    ) RETURNING public.currency_orders.id, public.currency_orders.order_number INTO v_order_id, v_order_number;

    -- Return success - updated message to reflect the fix
    RETURN QUERY SELECT
        TRUE,
        v_order_id,
        v_order_number,
        format('Purchase order draft created successfully - Order: %s. Cost: %s %s. Sale/profit will be calculated when order is actually sold.',
               v_order_number, v_cost_amount_final, v_cost_currency_code_final);

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT
            FALSE,
            NULL::UUID,
            NULL::TEXT,
            'Error creating purchase order draft: ' || SQLERRM;
END;
$$;


--
-- Name: create_currency_sell_order(uuid, numeric, text, text, uuid, uuid, text, text, text, text, jsonb, uuid, text, timestamp with time zone, text, numeric, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.create_currency_sell_order(p_currency_attribute_id uuid, p_quantity numeric, p_game_code text, p_delivery_info text, p_channel_id uuid, p_user_id uuid, p_server_attribute_code text DEFAULT NULL::text, p_character_id text DEFAULT NULL::text, p_character_name text DEFAULT NULL::text, p_exchange_type text DEFAULT 'none'::text, p_exchange_details jsonb DEFAULT NULL::jsonb, p_party_id uuid DEFAULT NULL::uuid, p_priority_level text DEFAULT 'normal'::text, p_deadline_at timestamp with time zone DEFAULT NULL::timestamp with time zone, p_notes text DEFAULT NULL::text, p_sale_amount numeric DEFAULT NULL::numeric, p_sale_currency_code text DEFAULT 'USD'::text) RETURNS TABLE(success boolean, order_id uuid, order_number text, message text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_order_id UUID;
    v_order_number TEXT;
    v_currency_record RECORD;
    v_channel_record RECORD;
    v_customer_party_id UUID;
    v_existing_customer RECORD;
    v_inventory_pool_id UUID;
    v_game_account_id UUID;
    v_assigned_to UUID;
    v_has_assignment BOOLEAN := false;
    v_order_status currency_order_status_enum := 'pending';
    v_employee RECORD;  -- IMPORTANT: Added v_employee variable declaration
    v_contact_info_json JSONB;
    v_delivery_info_final TEXT;      -- Game tag only
    v_notes_final TEXT;              -- Combined: delivery_contact_info | user_notes
    v_game_tag TEXT;
    v_customer_name TEXT;
    v_exchange_type_cast currency_exchange_type_enum; -- Cast variable
    v_delivery_contact_info TEXT;    -- Extracted delivery contact info
    v_priority_level_num INTEGER;    -- Convert priority level to integer
BEGIN
    -- Validate user_id parameter (following authentication rule)
    IF p_user_id IS NULL THEN
        RETURN QUERY SELECT FALSE, NULL::UUID, NULL::TEXT, 'Authentication required: user_id cannot be null';
        RETURN;
    END IF;

    -- Cast the exchange_type text to enum, handling NULL values
    IF p_exchange_type IS NOT NULL AND p_exchange_type != '' THEN
        v_exchange_type_cast := p_exchange_type::currency_exchange_type_enum;
    ELSE
        v_exchange_type_cast := 'none'::currency_exchange_type_enum;
    END IF;

    -- Convert text priority level to integer
    v_priority_level_num := CASE
        WHEN p_priority_level = 'high' OR p_priority_level = 'urgent' THEN 1
        WHEN p_priority_level = 'normal' OR p_priority_level = 'medium' THEN 2
        WHEN p_priority_level = 'low' THEN 3
        ELSE 2  -- Default to normal
    END;

    -- Validate currency exists and is active
    SELECT * INTO v_currency_record
    FROM public.attributes
    WHERE id = p_currency_attribute_id
      AND type = 'GAME_CURRENCY'
      AND is_active = true;

    IF NOT FOUND THEN
        RETURN QUERY
        SELECT false, NULL::UUID, NULL::TEXT,
               'Invalid or inactive currency';
        RETURN;
    END IF;

    -- Validate channel exists and is active
    SELECT * INTO v_channel_record
    FROM public.channels
    WHERE id = p_channel_id
      AND is_active = true;

    IF NOT FOUND THEN
        RETURN QUERY
        SELECT false, NULL::UUID, NULL::TEXT,
               'Invalid or inactive channel';
        RETURN;
    END IF;

    -- *** CRITICAL: Validate stock and assignment availability BEFORE creating order ***
    -- Step 1: Check if any inventory pool has sufficient quantity
    IF NOT EXISTS (
        SELECT 1 FROM inventory_pools ip
        WHERE ip.game_code = p_game_code
          AND COALESCE(ip.server_attribute_code, '') = COALESCE(p_server_attribute_code, '')
          AND ip.currency_attribute_id = p_currency_attribute_id
          AND ip.quantity >= p_quantity
          AND ip.game_account_id IN (
              SELECT ga.id FROM game_accounts ga
              WHERE ga.is_active = true
          )
    ) THEN
        RETURN QUERY
        SELECT false, NULL::UUID, NULL::TEXT,
               format('Insufficient stock: No inventory pool has %s %s available', p_quantity, v_currency_record.name);
        RETURN;
    END IF;

    -- Step 2: Try to find inventory pool and employee assignment BEFORE creating order
    SELECT inventory_pool_id, game_account_id
    INTO v_inventory_pool_id, v_game_account_id
    FROM get_best_inventory_pool_for_sell_order(
        p_game_code,
        p_server_attribute_code,
        p_currency_attribute_id,
        p_quantity
    )
    WHERE get_best_inventory_pool_for_sell_order.success = true
    LIMIT 1;

    -- If no suitable inventory pool found, reject order creation
    IF v_inventory_pool_id IS NULL THEN
        RETURN QUERY
        SELECT false, NULL::UUID, NULL::TEXT,
               format('Cannot create sell order: No suitable inventory pool found for %s %s', p_quantity, v_currency_record.name);
        RETURN;
    END IF;

    -- Step 3: Try to find employee assignment (optional - if no assignment, order stays pending)
    -- FIXED: Use single parameter function call (get_employee_for_account_in_shift only needs game_account_id)
    SELECT * INTO v_employee
    FROM get_employee_for_account_in_shift(v_game_account_id)
    WHERE get_employee_for_account_in_shift.success = true
    LIMIT 1;

    IF v_employee.employee_profile_id IS NOT NULL THEN
        v_assigned_to := v_employee.employee_profile_id;
        v_has_assignment := true;
        v_order_status := 'assigned';
    END IF;

    -- CORRECTED LOGIC: Use character_id as game tag, character_name as customer name
    v_game_tag := COALESCE(p_character_id, '');  -- p_character_id is the game tag
    v_customer_name := COALESCE(p_character_name, 'Customer');  -- p_character_name is customer name

    -- UPDATED LOGIC: delivery_info for order contains game tag only
    v_delivery_info_final := v_game_tag;

    -- UPDATED LOGIC: Parse delivery info from p_delivery_info (combined format from frontend)
    -- Expected format: "gameTag | deliveryInfo" or just "gameTag" or just "deliveryInfo"
    v_delivery_contact_info := '';
    IF p_delivery_info IS NOT NULL AND p_delivery_info != '' THEN
        IF POSITION('|' IN p_delivery_info) > 0 THEN
            -- Split "gameTag | deliveryInfo"
            DECLARE
                v_temp_game_tag TEXT;
                v_temp_delivery_info TEXT;
            BEGIN
                v_temp_game_tag := TRIM(SUBSTRING(p_delivery_info FROM 1 FOR POSITION('|' IN p_delivery_info) - 1));
                v_temp_delivery_info := TRIM(SUBSTRING(p_delivery_info FROM POSITION('|' IN p_delivery_info) + 1));

                -- Use gameTag from p_character_id, but deliveryInfo from p_delivery_info
                v_delivery_contact_info := v_temp_delivery_info;
            END;
        ELSE
            -- Check if it's just delivery info (no gameTag separator)
            -- If p_delivery_info doesn't match p_character_id, treat it as delivery info
            IF TRIM(p_delivery_info) != TRIM(v_game_tag) THEN
                v_delivery_contact_info := TRIM(p_delivery_info);
            END IF;
        END IF;
    END IF;

    -- UPDATED LOGIC: Build combined notes (delivery_contact_info | user_notes)
    -- For sell orders, we need to get delivery info from the customer party if exists
    v_notes_final := COALESCE(p_notes, '');

    -- Try to get customer's delivery info from existing party
    IF p_party_id IS NOT NULL THEN
        SELECT contact_info INTO v_contact_info_json
        FROM parties
        WHERE id = p_party_id;

        IF v_contact_info_json IS NOT NULL THEN
            DECLARE
                v_existing_delivery_info TEXT;
            BEGIN
                v_existing_delivery_info := COALESCE(v_contact_info_json->>'deliveryInfo', '');

                -- Use existing delivery info if no new delivery info provided
                IF v_delivery_contact_info IS NULL OR v_delivery_contact_info = '' THEN
                    v_delivery_contact_info := v_existing_delivery_info;
                END IF;
            END;
        END IF;
    END IF;

    -- Combine delivery contact info with user notes for order notes
    IF v_delivery_contact_info IS NOT NULL AND v_delivery_contact_info != '' THEN
        IF v_notes_final IS NOT NULL AND v_notes_final != '' THEN
            v_notes_final := v_delivery_contact_info || ' | ' || v_notes_final;
        ELSE
            v_notes_final := v_delivery_contact_info;
        END IF;
    END IF;

    -- NEW LOGIC: Build contact_info JSON for customer party with separate fields
    v_contact_info_json := jsonb_build_object(
        'gameTag', v_game_tag,                    -- From p_character_id
        'deliveryInfo', v_delivery_contact_info   -- From parsed p_delivery_info
    );

    -- Handle customer party - use existing if available, create new if not
    IF p_party_id IS NOT NULL THEN
        v_customer_party_id := p_party_id;
        -- Update existing party with new contact info
        UPDATE parties SET
            contact_info = v_contact_info_json,
            updated_at = NOW()
        WHERE id = p_party_id;
    ELSIF p_character_name IS NOT NULL THEN
        -- Try to find existing customer by name and type
        SELECT id, contact_info INTO v_existing_customer
        FROM parties
        WHERE name = p_character_name
          AND type = 'customer'
        LIMIT 1;

        IF v_existing_customer.id IS NOT NULL THEN
            -- Use existing customer and update contact info
            v_customer_party_id := v_existing_customer.id;
            UPDATE parties SET
                contact_info = v_contact_info_json,
                updated_at = NOW()
            WHERE id = v_existing_customer.id;
        ELSE
            -- Create new customer party
            INSERT INTO public.parties (
                name,
                type,
                game_code,
                channel_id,
                contact_info,
                notes,
                created_at,
                updated_at
            ) VALUES (
                p_character_name,
                'customer',
                p_game_code,
                p_channel_id,
                v_contact_info_json,
                'Auto-created for sell order',
                NOW(),
                NOW()
            ) RETURNING id INTO v_customer_party_id;
        END IF;
    ELSE
        v_customer_party_id := NULL;
    END IF;

    -- Generate order number using correct format
    v_order_number := public.generate_sell_order_number();

    -- Create the sell order with validated inventory pool and assignment
    INSERT INTO public.currency_orders (
        order_type,
        currency_attribute_id,
        quantity,
        game_code,
        delivery_info,                   -- Game tag only
        channel_id,
        server_attribute_code,
        created_by,                      -- FIXED: Use p_user_id instead of auth.uid()
        game_account_id,
        exchange_type,                   -- Use the properly cast enum value
        exchange_details,
        party_id,
        priority_level,                   -- INTEGER column
        deadline_at,
        notes,                            -- delivery_contact_info | user_notes
        proofs,
        sale_amount,
        sale_currency_code,
        order_number,
        status,                          -- validated status
        assigned_to,
        assigned_at,
        inventory_pool_id,
        created_at,
        updated_at
    ) VALUES (
        'SALE',
        p_currency_attribute_id,
        p_quantity,
        p_game_code,
        v_delivery_info_final,            -- Game tag only
        p_channel_id,
        p_server_attribute_code,
        p_user_id,                       -- FIXED: Use profiles.id from frontend
        v_game_account_id,
        v_exchange_type_cast,             -- Use the properly cast enum value
        p_exchange_details,
        v_customer_party_id,
        v_priority_level_num,             -- FIXED: Use converted integer value
        p_deadline_at,
        v_notes_final,                     -- delivery_contact_info | user_notes
        '{}'::jsonb, -- Will be updated with proof uploads
        p_sale_amount,
        p_sale_currency_code,
        v_order_number,
        v_order_status,                   -- Use validated status
        v_assigned_to,
        CASE WHEN v_has_assignment THEN NOW() ELSE NULL END,
        v_inventory_pool_id,
        NOW(),
        NOW()
    ) RETURNING id INTO v_order_id;

    -- Return success with assignment info
    RETURN QUERY
    SELECT true, v_order_id, v_order_number,
           CASE
               WHEN v_has_assignment
               THEN format('Sell order created and auto-assigned to employee ID %s (account: %s)',
                          v_assigned_to,
                          (SELECT account_name FROM public.game_accounts WHERE id = v_game_account_id))
               ELSE 'Sell order created successfully, pending assignment'
           END;

END;
$$;


--
-- Name: create_currency_sell_order_draft(uuid, numeric, text, text, uuid, uuid, text, text, text, text, jsonb, uuid, text, timestamp with time zone, text, numeric, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.create_currency_sell_order_draft(p_currency_attribute_id uuid, p_quantity numeric, p_game_code text, p_delivery_info text, p_channel_id uuid, p_user_id uuid, p_server_attribute_code text DEFAULT NULL::text, p_character_id text DEFAULT NULL::text, p_character_name text DEFAULT NULL::text, p_exchange_type text DEFAULT 'none'::text, p_exchange_details jsonb DEFAULT NULL::jsonb, p_party_id uuid DEFAULT NULL::uuid, p_priority_level text DEFAULT 'normal'::text, p_deadline_at timestamp with time zone DEFAULT NULL::timestamp with time zone, p_notes text DEFAULT NULL::text, p_sale_amount numeric DEFAULT NULL::numeric, p_sale_currency_code text DEFAULT 'USD'::text) RETURNS TABLE(success boolean, order_id uuid, order_number text, message text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_order_id UUID;
    v_order_number TEXT;
    v_currency_record RECORD;
    v_channel_record RECORD;
    v_customer_party_id UUID;
    v_existing_customer RECORD;
    v_contact_info_json JSONB;
    v_delivery_info_final TEXT;      -- Game tag only
    v_notes_final TEXT;              -- Combined: delivery_contact_info | user_notes
    v_game_tag TEXT;
    v_customer_name TEXT;
    v_exchange_type_cast currency_exchange_type_enum; -- Cast variable
    v_delivery_contact_info TEXT;    -- Extracted delivery contact info
    v_priority_level_num INTEGER;    -- Convert priority level to integer
BEGIN
    -- Validate user_id parameter (following authentication rule)
    IF p_user_id IS NULL THEN
        RETURN QUERY SELECT FALSE, NULL::UUID, NULL::TEXT, 'Authentication required: user_id cannot be null';
        RETURN;
    END IF;

    -- Cast the exchange_type text to enum, handling NULL values
    IF p_exchange_type IS NOT NULL AND p_exchange_type != '' THEN
        v_exchange_type_cast := p_exchange_type::currency_exchange_type_enum;
    ELSE
        v_exchange_type_cast := 'none'::currency_exchange_type_enum;
    END IF;

    -- Convert text priority level to integer
    v_priority_level_num := CASE
        WHEN p_priority_level = 'high' OR p_priority_level = 'urgent' THEN 1
        WHEN p_priority_level = 'normal' OR p_priority_level = 'medium' THEN 2
        WHEN p_priority_level = 'low' THEN 3
        ELSE 2  -- Default to normal
    END;

    -- Validate currency exists and is active
    SELECT * INTO v_currency_record
    FROM public.attributes
    WHERE id = p_currency_attribute_id
      AND type = 'GAME_CURRENCY'
      AND is_active = true;

    IF NOT FOUND THEN
        RETURN QUERY
        SELECT false, NULL::UUID, NULL::TEXT,
               'Invalid or inactive currency';
        RETURN;
    END IF;

    -- Validate channel exists and is active
    SELECT * INTO v_channel_record
    FROM public.channels
    WHERE id = p_channel_id
      AND is_active = true;

    IF NOT FOUND THEN
        RETURN QUERY
        SELECT false, NULL::UUID, NULL::TEXT,
               'Invalid or inactive channel';
        RETURN;
    END IF;

    -- CORRECTED LOGIC: Use character_id as game tag, character_name as customer name
    v_game_tag := COALESCE(p_character_id, '');  -- p_character_id is the game tag
    v_customer_name := COALESCE(p_character_name, 'Customer');  -- p_character_name is customer name

    -- UPDATED LOGIC: delivery_info for order contains game tag only
    v_delivery_info_final := v_game_tag;

    -- UPDATED LOGIC: Parse delivery info from p_delivery_info (combined format from frontend)
    -- Expected format: "gameTag | deliveryInfo" or just "gameTag" or just "deliveryInfo"
    v_delivery_contact_info := '';
    IF p_delivery_info IS NOT NULL AND p_delivery_info != '' THEN
        IF POSITION('|' IN p_delivery_info) > 0 THEN
            -- Split "gameTag | deliveryInfo"
            DECLARE
                v_temp_game_tag TEXT;
                v_temp_delivery_info TEXT;
            BEGIN
                v_temp_game_tag := TRIM(SUBSTRING(p_delivery_info FROM 1 FOR POSITION('|' IN p_delivery_info) - 1));
                v_temp_delivery_info := TRIM(SUBSTRING(p_delivery_info FROM POSITION('|' IN p_delivery_info) + 1));

                -- Use gameTag from p_character_id, but deliveryInfo from p_delivery_info
                v_delivery_contact_info := v_temp_delivery_info;
            END;
        ELSE
            -- Check if it's just delivery info (no gameTag separator)
            -- If p_delivery_info doesn't match p_character_id, treat it as delivery info
            IF TRIM(p_delivery_info) != TRIM(v_game_tag) THEN
                v_delivery_contact_info := TRIM(p_delivery_info);
            END IF;
        END IF;
    END IF;

    -- UPDATED LOGIC: Build combined notes (delivery_contact_info | user_notes)
    -- For sell orders, we need to get delivery info from the customer party if exists
    v_notes_final := COALESCE(p_notes, '');

    -- Try to get customer's delivery info from existing party
    IF p_party_id IS NOT NULL THEN
        SELECT contact_info INTO v_contact_info_json
        FROM parties
        WHERE id = p_party_id;

        IF v_contact_info_json IS NOT NULL THEN
            DECLARE
                v_existing_delivery_info TEXT;
            BEGIN
                v_existing_delivery_info := COALESCE(v_contact_info_json->>'deliveryInfo', '');

                -- Use existing delivery info if no new delivery info provided
                IF v_delivery_contact_info IS NULL OR v_delivery_contact_info = '' THEN
                    v_delivery_contact_info := v_existing_delivery_info;
                END IF;
            END;
        END IF;
    END IF;

    -- Combine delivery contact info with user notes for order notes
    IF v_delivery_contact_info IS NOT NULL AND v_delivery_contact_info != '' THEN
        IF v_notes_final IS NOT NULL AND v_notes_final != '' THEN
            v_notes_final := v_delivery_contact_info || ' | ' || v_notes_final;
        ELSE
            v_notes_final := v_delivery_contact_info;
        END IF;
    END IF;

    -- NEW LOGIC: Build contact_info JSON for customer party with separate fields
    v_contact_info_json := jsonb_build_object(
        'gameTag', v_game_tag,                    -- From p_character_id
        'deliveryInfo', v_delivery_contact_info   -- From parsed p_delivery_info
    );

    -- Handle customer party - use existing if available, create new if not
    IF p_party_id IS NOT NULL THEN
        v_customer_party_id := p_party_id;
        -- Update existing party with new contact info
        UPDATE parties SET
            contact_info = v_contact_info_json,
            updated_at = NOW()
        WHERE id = p_party_id;
    ELSIF p_character_name IS NOT NULL THEN
        -- Try to find existing customer by name and type
        SELECT id, contact_info INTO v_existing_customer
        FROM parties
        WHERE name = p_character_name
          AND type = 'customer'
        LIMIT 1;

        IF v_existing_customer.id IS NOT NULL THEN
            -- Use existing customer and update contact info
            v_customer_party_id := v_existing_customer.id;
            UPDATE parties SET
                contact_info = v_contact_info_json,
                updated_at = NOW()
            WHERE id = v_existing_customer.id;
        ELSE
            -- Create new customer party
            INSERT INTO public.parties (
                name,
                type,
                game_code,
                channel_id,
                contact_info,
                notes,
                created_at,
                updated_at
            ) VALUES (
                p_character_name,
                'customer',
                p_game_code,
                p_channel_id,
                v_contact_info_json,
                'Auto-created for sell order draft',
                NOW(),
                NOW()
            ) RETURNING id INTO v_customer_party_id;
        END IF;
    ELSE
        v_customer_party_id := NULL;
    END IF;

    -- Generate order number using correct format
    v_order_number := public.generate_sell_order_number();

    -- Create the sell order draft (no inventory assignment for drafts)
    INSERT INTO public.currency_orders (
        order_type,
        currency_attribute_id,
        quantity,
        game_code,
        delivery_info,                   -- Game tag only
        channel_id,
        server_attribute_code,
        created_by,                      -- FIXED: Use p_user_id instead of auth.uid()
        exchange_type,                   -- Use the properly cast enum value
        exchange_details,
        party_id,
        priority_level,                   -- INTEGER column
        deadline_at,
        notes,                            -- delivery_contact_info | user_notes
        proofs,
        sale_amount,
        sale_currency_code,
        order_number,
        status,                          -- draft status
        created_at,
        updated_at
    ) VALUES (
        'SALE',
        p_currency_attribute_id,
        p_quantity,
        p_game_code,
        v_delivery_info_final,            -- Game tag only
        p_channel_id,
        p_server_attribute_code,
        p_user_id,                       -- FIXED: Use profiles.id from frontend
        v_exchange_type_cast,             -- Use the properly cast enum value
        p_exchange_details,
        v_customer_party_id,
        v_priority_level_num,             -- FIXED: Use converted integer value
        p_deadline_at,
        v_notes_final,                     -- delivery_contact_info | user_notes
        '{}'::jsonb, -- Will be updated with proof uploads
        p_sale_amount,
        p_sale_currency_code,
        v_order_number,
        'draft',                          -- Draft status
        NOW(),
        NOW()
    ) RETURNING id INTO v_order_id;

    -- Return success
    RETURN QUERY
    SELECT true, v_order_id, v_order_number,
           'Sell order draft created successfully';

END;
$$;


--
-- Name: create_direct_currency_exchange(text, uuid, uuid, uuid, numeric, numeric, numeric, uuid, uuid, text, uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.create_direct_currency_exchange(p_game_code text, p_league_attribute_id uuid, p_from_currency_id uuid, p_to_currency_id uuid, p_from_amount numeric, p_to_amount numeric, p_exchange_rate numeric, p_channel_id uuid, p_party_id uuid DEFAULT NULL::uuid, p_notes text DEFAULT NULL::text, p_created_by uuid DEFAULT NULL::uuid) RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_order_id UUID;
BEGIN
    INSERT INTO currency_orders (
        order_type,
        exchange_type,
        game_code,
        league_attribute_id,
        currency_attribute_id,
        quantity,
        unit_price_vnd,
        foreign_currency_id,
        foreign_currency_code,
        foreign_amount,
        exchange_rate,
        party_id,
        channel_id,
        notes,
        created_by,
        status
    ) VALUES (
        'EXCHANGE',
        'currency',
        p_game_code,
        p_league_attribute_id,
        p_from_currency_id,
        p_from_amount,
        0, -- No VND price for internal inventory exchange
        p_to_currency_id,
        (SELECT name FROM attributes WHERE id = p_to_currency_id),
        p_to_amount,
        p_exchange_rate,
        p_party_id,
        p_channel_id,
        p_notes,
        COALESCE(p_created_by, auth.uid()),
        'draft'
    ) RETURNING id INTO v_order_id;

    RETURN v_order_id;
END;
$$;


--
-- Name: FUNCTION create_direct_currency_exchange(p_game_code text, p_league_attribute_id uuid, p_from_currency_id uuid, p_to_currency_id uuid, p_from_amount numeric, p_to_amount numeric, p_exchange_rate numeric, p_channel_id uuid, p_party_id uuid, p_notes text, p_created_by uuid); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.create_direct_currency_exchange(p_game_code text, p_league_attribute_id uuid, p_from_currency_id uuid, p_to_currency_id uuid, p_from_amount numeric, p_to_amount numeric, p_exchange_rate numeric, p_channel_id uuid, p_party_id uuid, p_notes text, p_created_by uuid) IS 'Create a direct currency exchange order for inventory management (System 2)';


--
-- Name: create_exchange_currency_order(uuid, uuid, uuid, numeric, uuid, numeric, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.create_exchange_currency_order(p_user_id uuid, p_game_account_id uuid, p_source_currency_id uuid, p_source_quantity numeric, p_target_currency_id uuid, p_target_quantity numeric, p_server_attribute_code text DEFAULT NULL::text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_order_id UUID;
    v_order_number TEXT;
    v_channel_id UUID;
    v_game_account RECORD;
    v_source_cost_amount NUMERIC;
    v_source_cost_currency_code TEXT;
    v_source_currency_code TEXT;
    v_target_currency_code TEXT;
    v_available_quantity NUMERIC;
    v_current_user_id UUID;
    v_party_exists BOOLEAN;
    v_total_exchange_value NUMERIC;
    v_source_unit_cost NUMERIC;
    v_target_unit_cost NUMERIC;
    v_user_display_name TEXT;
BEGIN
    -- Get current user ID from profiles
    SELECT id, display_name INTO v_current_user_id, v_user_display_name
    FROM profiles
    WHERE id = p_user_id;

    IF v_current_user_id IS NULL THEN
        RAISE EXCEPTION 'Invalid user profile';
    END IF;

    -- Auto-create party record if not exists with UNIQUE name
    -- Use user display name + timestamp to ensure uniqueness
    SELECT EXISTS(SELECT 1 FROM parties WHERE id = p_user_id) INTO v_party_exists;

    IF NOT v_party_exists THEN
        INSERT INTO parties (id, type, name, created_at, updated_at)
        VALUES (
            p_user_id,
            'customer',
            COALESCE(v_user_display_name, 'Exchange User') || ' - ' || TO_CHAR(NOW(), 'YYYY-MM-DD HH24:MI:SS'),
            NOW(),
            NOW()
        );
    END IF;

    -- Get game account details (for game_code only, server can be NULL for global accounts)
    SELECT game_code
    INTO v_game_account
    FROM game_accounts
    WHERE id = p_game_account_id AND is_active = true;

    IF v_game_account IS NULL THEN
        RAISE EXCEPTION 'Game account not found or inactive';
    END IF;

    -- Get source currency cost info from inventory_pools
    -- Logic: use server from GameServerSelector, game from account, specific account_id, currency_id, sufficient_quantity
    SELECT average_cost, cost_currency, quantity, channel_id
    INTO v_source_unit_cost, v_source_cost_currency_code, v_available_quantity, v_channel_id
    FROM inventory_pools
    WHERE game_code = v_game_account.game_code
      AND (
        -- Handle both NULL and specific server codes
        (p_server_attribute_code IS NULL AND server_attribute_code IS NULL)
        OR
        (p_server_attribute_code IS NOT NULL AND server_attribute_code = p_server_attribute_code)
      )
      AND game_account_id = p_game_account_id
      AND currency_attribute_id = p_source_currency_id
      AND quantity >= p_source_quantity
    ORDER BY last_updated_at ASC  -- FIFO: oldest pool first
    LIMIT 1;

    IF v_source_unit_cost IS NULL THEN
        RAISE EXCEPTION 'Không tìm thấy inventory pool phù hợp hoặc không đủ tồn kho. Game: %, Server: %, Account: %, Currency: %, Quantity: %',
            v_game_account.game_code, p_server_attribute_code, p_game_account_id, p_source_currency_id, p_source_quantity;
    END IF;

    -- Calculate total exchange value (both cost and sale should be equal)
    v_total_exchange_value := p_source_quantity * v_source_unit_cost;

    -- Calculate target unit cost (ensuring equal total value)
    v_target_unit_cost := v_total_exchange_value / p_target_quantity;

    -- Get currency codes
    SELECT code INTO v_source_currency_code
    FROM attributes
    WHERE id = p_source_currency_id AND type = 'GAME_CURRENCY';

    SELECT code INTO v_target_currency_code
    FROM attributes
    WHERE id = p_target_currency_id AND type = 'GAME_CURRENCY';

    -- Generate order number - Match purchase/sale timestamp format
    v_order_number := 'EO' || TO_CHAR(NOW(), 'YYYYMMDDHH24MISSMS');

    -- Create the order with CORRECT equal cost/sale values
    INSERT INTO currency_orders (
        order_type,
        status,
        order_number,
        game_code,
        game_account_id,
        server_attribute_code,
        channel_id,
        currency_attribute_id,
        quantity,
        cost_amount,
        cost_currency_code,
        foreign_currency_id,
        foreign_currency_code,
        foreign_amount,
        sale_amount,
        sale_currency_code,
        exchange_type,
        exchange_details,
        party_id,
        created_by
    ) VALUES (
        'EXCHANGE',
        'draft',
        v_order_number,
        v_game_account.game_code,
        p_game_account_id,
        p_server_attribute_code,  -- Use server from GameServerSelector
        v_channel_id,
        p_source_currency_id,
        p_source_quantity,
        v_total_exchange_value,  -- ✅ CORRECT: Total value
        v_source_cost_currency_code,
        p_target_currency_id,
        v_target_currency_code,
        p_target_quantity,
        v_total_exchange_value,  -- ✅ CORRECT: EQUAL TO COST AMOUNT
        v_source_cost_currency_code,
        'currency',
        json_build_object(
            'source_currency', json_build_object(
                'id', p_source_currency_id,
                'code', v_source_currency_code,
                'quantity', p_source_quantity,
                'unit_cost', v_source_unit_cost,
                'total_value', v_total_exchange_value,
                'cost_currency_code', v_source_cost_currency_code
            ),
            'target_currency', json_build_object(
                'id', p_target_currency_id,
                'code', v_target_currency_code,
                'quantity', p_target_quantity,
                'unit_cost', v_target_unit_cost,
                'total_value', v_total_exchange_value,
                'value_currency_code', v_source_cost_currency_code
            ),
            'exchange_rate', json_build_object(
                'source_to_target', (p_target_quantity::NUMERIC / p_source_quantity::NUMERIC),
                'source_unit_cost', v_source_unit_cost,
                'target_unit_cost', v_target_unit_cost,
                'calculated_at', NOW()
            )
        ),
        v_current_user_id,
        v_current_user_id
    ) RETURNING id INTO v_order_id;

    -- Return success result
    RETURN json_build_object(
        'order_id', v_order_id,
        'order_number', v_order_number,
        'status', 'draft',
        'message', 'Exchange order created successfully',
        'party_id', v_current_user_id,
        'exchange_values', json_build_object(
            'total_exchange_value', v_total_exchange_value,
            'source_unit_cost', v_source_unit_cost,
            'target_unit_cost', v_target_unit_cost,
            'cost_currency', v_source_cost_currency_code
        )
    );
END;
$$;


--
-- Name: create_fee_direct(text, text, text, text, numeric, text, boolean, uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.create_fee_direct(p_code text, p_name text, p_direction text, p_fee_type text, p_amount numeric, p_currency text, p_is_active boolean DEFAULT true, p_created_by uuid DEFAULT NULL::uuid) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
  v_fee_id UUID;
BEGIN
  -- Generate UUID for new fee
  v_fee_id := gen_random_uuid();

  -- Insert new fee (this bypasses RLS due to SECURITY DEFINER)
  INSERT INTO fees (
    id,
    code,
    name,
    direction,
    fee_type,
    amount,
    currency,
    is_active,
    created_at,
    created_by
  ) VALUES (
    v_fee_id,
    p_code,
    p_name,
    p_direction,
    p_fee_type,
    p_amount,
    p_currency,
    p_is_active,
    NOW(),
    p_created_by
  );

  RETURN jsonb_build_object(
    'success', true,
    'message', 'Tạo phí thành công',
    'fee_id', v_fee_id
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Lỗi khi tạo phí: ' || SQLERRM
    );
END;
$$;


--
-- Name: create_game_account_direct(text, text, text, text, boolean); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.create_game_account_direct(p_game_code text, p_account_name text, p_purpose text DEFAULT 'INVENTORY'::text, p_server_attribute_code text DEFAULT NULL::text, p_is_active boolean DEFAULT true) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
  v_account_id UUID;
  v_account_name TEXT;
BEGIN
  -- Generate UUID for new account
  v_account_id := gen_random_uuid();
  v_account_name := COALESCE(p_account_name, 'Unnamed Account');

  -- Insert new game account (this bypasses RLS due to SECURITY DEFINER)
  INSERT INTO game_accounts (
    id,
    game_code,
    account_name,
    purpose,
    server_attribute_code,
    is_active,
    created_at,
    updated_at
  ) VALUES (
    v_account_id,
    p_game_code,
    v_account_name,
    p_purpose,
    p_server_attribute_code,
    p_is_active,
    NOW(),
    NOW()
  );

  RETURN jsonb_build_object(
    'success', true,
    'message', 'Tạo tài khoản game thành công',
    'account_id', v_account_id,
    'account_name', v_account_name,
    'game_code', p_game_code
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Lỗi khi tạo tài khoản game: ' || SQLERRM
    );
END;
$$;


--
-- Name: create_service_order_v1(text, text, text, timestamp with time zone, numeric, text, text, text, uuid, jsonb, text, jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.create_service_order_v1(p_channel_code text, p_service_type text, p_customer_name text, p_deadline timestamp with time zone, p_price numeric, p_currency_code text, p_package_type text, p_package_note text, p_customer_account_id uuid, p_new_account_details jsonb, p_game_code text, p_service_items jsonb) RETURNS TABLE(order_id uuid, line_id uuid)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
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


--
-- Name: FUNCTION create_service_order_v1(p_channel_code text, p_service_type text, p_customer_name text, p_deadline timestamp with time zone, p_price numeric, p_currency_code text, p_package_type text, p_package_note text, p_customer_account_id uuid, p_new_account_details jsonb, p_game_code text, p_service_items jsonb); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.create_service_order_v1(p_channel_code text, p_service_type text, p_customer_name text, p_deadline timestamp with time zone, p_price numeric, p_currency_code text, p_package_type text, p_package_note text, p_customer_account_id uuid, p_new_account_details jsonb, p_game_code text, p_service_items jsonb) IS 'MINIMAL FIX: Only changed (1) variant names to "Service - Selfplay/Pilot", (2) SELFPAY→SELFPLAY, (3) order:create→orders:create';


--
-- Name: create_service_sale_with_exchange(text, uuid, uuid, numeric, numeric, uuid, uuid, text, uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.create_service_sale_with_exchange(p_game_code text, p_league_attribute_id uuid, p_currency_attribute_id uuid, p_quantity numeric, p_unit_price_vnd numeric, p_party_id uuid, p_channel_id uuid, p_notes text DEFAULT NULL::text, p_created_by uuid DEFAULT NULL::uuid) RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_order_id UUID;
BEGIN
    INSERT INTO currency_orders (
        order_type,
        exchange_type,
        game_code,
        league_attribute_id,
        currency_attribute_id,
        quantity,
        unit_price_vnd,
        party_id,
        channel_id,
        notes,
        created_by,
        status
    ) VALUES (
        'SALE',
        'service',
        p_game_code,
        p_league_attribute_id,
        p_currency_attribute_id,
        p_quantity,
        p_unit_price_vnd,
        p_party_id,
        p_channel_id,
        p_notes,
        COALESCE(p_created_by, auth.uid()),
        'draft'
    ) RETURNING id INTO v_order_id;

    RETURN v_order_id;
END;
$$;


--
-- Name: FUNCTION create_service_sale_with_exchange(p_game_code text, p_league_attribute_id uuid, p_currency_attribute_id uuid, p_quantity numeric, p_unit_price_vnd numeric, p_party_id uuid, p_channel_id uuid, p_notes text, p_created_by uuid); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.create_service_sale_with_exchange(p_game_code text, p_league_attribute_id uuid, p_currency_attribute_id uuid, p_quantity numeric, p_unit_price_vnd numeric, p_party_id uuid, p_channel_id uuid, p_notes text, p_created_by uuid) IS 'Create a service sale order with exchange tracking';


--
-- Name: create_shift_alert(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.create_shift_alert() RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    new_alert_id UUID;
BEGIN
    INSERT INTO shift_alerts (
        shift_id, alert_type, title, message, severity,
        game_account_id, channel_id, currency_attribute_id,
        employee_profile_id, alert_data
    ) VALUES (
        p_shift_id, p_alert_type, p_title, p_message, p_severity,
        p_game_account_id, p_channel_id, p_currency_attribute_id,
        p_employee_profile_id, p_alert_data
    ) RETURNING id INTO new_alert_id;

    RETURN new_alert_id;
END;
$$;


--
-- Name: create_shift_assignment_direct(uuid, uuid, uuid, uuid, text, boolean); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.create_shift_assignment_direct(p_game_account_id uuid, p_employee_profile_id uuid, p_shift_id uuid, p_channels_id uuid, p_currency_code text DEFAULT 'VND'::text, p_is_active boolean DEFAULT true) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
  v_assignment_id UUID;
BEGIN
  -- Generate UUID for new assignment
  v_assignment_id := gen_random_uuid();

  -- Insert new shift assignment (this bypasses RLS due to SECURITY DEFINER)
  INSERT INTO shift_assignments (
    id,
    game_account_id,
    employee_profile_id,
    shift_id,
    channels_id,
    currency_code,
    is_active,
    assigned_at
  ) VALUES (
    v_assignment_id,
    p_game_account_id,
    p_employee_profile_id,
    p_shift_id,
    p_channels_id,
    p_currency_code,
    p_is_active,
    NOW()
  );

  RETURN jsonb_build_object(
    'success', true,
    'message', 'Tạo phân công ca làm việc thành công',
    'assignment_id', v_assignment_id
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Lỗi khi tạo phân công ca làm việc: ' || SQLERRM
    );
END;
$$;


--
-- Name: create_work_shift_direct(text, time without time zone, time without time zone, text, boolean); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.create_work_shift_direct(p_name text, p_start_time time without time zone, p_end_time time without time zone, p_description text DEFAULT NULL::text, p_is_active boolean DEFAULT true) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
  v_shift_id UUID;
  v_shift_name TEXT;
BEGIN
  -- Generate UUID for new shift
  v_shift_id := gen_random_uuid();
  v_shift_name := COALESCE(p_name, 'Unnamed Shift');

  -- Insert new work shift (this bypasses RLS due to SECURITY DEFINER)
  INSERT INTO work_shifts (
    id,
    name,
    start_time,
    end_time,
    description,
    is_active,
    created_at,
    updated_at
  ) VALUES (
    v_shift_id,
    v_shift_name,
    p_start_time,
    p_end_time,
    p_description,
    p_is_active,
    NOW(),
    NOW()
  );

  RETURN jsonb_build_object(
    'success', true,
    'message', 'Tạo ca làm việc thành công',
    'shift_id', v_shift_id,
    'shift_name', v_shift_name
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Lỗi khi tạo ca làm việc: ' || SQLERRM
    );
END;
$$;


--
-- Name: current_user_id(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.current_user_id() RETURNS uuid
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'public'
    AS $$ 
  SELECT (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')::uuid; 
$$;


--
-- Name: debug_currency_rotation_status(text, uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.debug_currency_rotation_status(p_game_code text DEFAULT NULL::text, p_currency_attribute_id uuid DEFAULT NULL::uuid) RETURNS TABLE(tracker_key text, all_currencies text[], current_index integer, current_currency text, next_currency text, total_currencies integer, last_updated timestamp with time zone, rotation_count integer)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        at.assignment_group_key as tracker_key,
        at.employee_rotation_order as all_currencies,
        at.current_rotation_index,
        CASE 
            WHEN at.employee_rotation_order IS NOT NULL AND at.current_rotation_index < array_length(at.employee_rotation_order, 1)
            THEN at.employee_rotation_order[at.current_rotation_index]
            ELSE NULL
        END as current_currency,
        CASE 
            WHEN at.employee_rotation_order IS NOT NULL AND at.current_rotation_index < array_length(at.employee_rotation_order, 1)
            THEN at.employee_rotation_order[(at.current_rotation_index + 1) % array_length(at.employee_rotation_order, 1)]
            ELSE NULL
        END as next_currency,
        COALESCE(array_length(at.employee_rotation_order, 1), 0) as total_currencies,
        at.updated_at as last_updated,
        0 as rotation_count
    FROM assignment_trackers at
    WHERE at.assignment_type = 'inventory_pool_rotation'
      AND at.assignment_group_key LIKE '%_CURRENCY'
      AND (p_game_code IS NULL OR at.assignment_group_key LIKE format('INVENTORY_POOL_%s_%%', p_game_code))
      AND (p_currency_attribute_id IS NULL OR at.assignment_group_key LIKE format('%%_%s_CURRENCY', p_currency_attribute_id::TEXT))
    ORDER BY at.assignment_group_key;
END;
$$;


--
-- Name: debug_sell_order_assignment(uuid, text, uuid, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.debug_sell_order_assignment(p_order_id uuid DEFAULT NULL::uuid, p_game_code text DEFAULT NULL::text, p_currency_attribute_id uuid DEFAULT NULL::uuid, p_limit integer DEFAULT 10) RETURNS TABLE(debug_section text, debug_data jsonb)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
    -- If order_id is provided, debug assignment for that specific order
    IF p_order_id IS NOT NULL THEN
        RETURN QUERY
        SELECT 
            'ORDER_ASSIGNMENT_DEBUG' as debug_section,
            (SELECT debug_info FROM assign_sell_order_with_inventory_debug(p_order_id, NULL, true) LIMIT 1) as debug_data;
        RETURN;
    END IF;
    
    -- Otherwise, debug rotation status for game+currency combination
    RETURN QUERY
        SELECT 
            'ROTATION_STATUS_DEBUG' as debug_section,
            jsonb_agg(
                jsonb_build_object(
                    'debug_level', debug_level,
                    'tracker_key', tracker_key,
                    'rotation_info', rotation_data,
                    'recommendations', recommendations
                )
            ) as debug_data
        FROM debug_hierarchical_rotation_status(p_game_code, p_currency_attribute_id)
        LIMIT p_limit;
        
    -- Also include inventory pool analysis
    RETURN QUERY
    SELECT 
        'INVENTORY_POOL_ANALYSIS' as debug_section,
        jsonb_build_object(
            'analysis_params', jsonb_build_object(
                'game_code', p_game_code,
                'currency_id', COALESCE(p_currency_attribute_id::TEXT, 'ALL'),
                'limit', p_limit
            ),
            'pool_summary', (
                SELECT jsonb_agg(
                    jsonb_build_object(
                        'pool_id', ip.id,
                        'account_name', ga.account_name,
                        'channel_name', ch.name,
                        'cost_currency', ip.cost_currency,
                        'available_quantity', (ip.quantity - COALESCE(ip.reserved_quantity, 0)),
                        'average_cost', ip.average_cost,
                        'last_updated', ip.last_updated_at
                    )
                )
                FROM inventory_pools ip
                JOIN game_accounts ga ON ip.game_account_id = ga.id
                JOIN channels ch ON ip.channel_id = ch.id
                WHERE (p_game_code IS NULL OR ip.game_code = p_game_code)
                  AND (p_currency_attribute_id IS NULL OR ip.currency_attribute_id = p_currency_attribute_id)
                  AND ga.is_active = true
                ORDER BY ip.cost_currency, ch.name, ga.account_name
                LIMIT p_limit
            )
        ) as debug_data;
END;
$$;


--
-- Name: delete_business_process_direct(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.delete_business_process_direct(p_process_id uuid) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
  v_process_exists BOOLEAN;
BEGIN
  -- Check if process exists
  SELECT EXISTS(SELECT 1 FROM business_processes WHERE id = p_process_id) INTO v_process_exists;

  IF NOT v_process_exists THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Không tìm thấy quy trình kinh doanh'
    );
  END IF;

  -- Delete business process (this bypasses RLS due to SECURITY DEFINER)
  DELETE FROM business_processes WHERE id = p_process_id;

  RETURN jsonb_build_object(
    'success', true,
    'message', 'Xóa quy trình kinh doanh thành công',
    'process_id', p_process_id
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Lỗi khi xóa quy trình kinh doanh: ' || SQLERRM
    );
END;
$$;


--
-- Name: delete_channel_direct(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.delete_channel_direct(p_channel_id uuid) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
  v_channel_exists BOOLEAN;
  v_channel_name TEXT;
  v_channel_code TEXT;
BEGIN
  -- Check if channel exists
  SELECT EXISTS(SELECT 1 FROM channels WHERE id = p_channel_id) INTO v_channel_exists;

  IF NOT v_channel_exists THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Không tìm thấy kênh giao dịch'
    );
  END IF;

  -- Get channel info for response
  SELECT name, code INTO v_channel_name, v_channel_code 
  FROM channels WHERE id = p_channel_id;

  -- Delete channel (this bypasses RLS due to SECURITY DEFINER)
  DELETE FROM channels WHERE id = p_channel_id;

  RETURN jsonb_build_object(
    'success', true,
    'message', 'Xóa kênh giao dịch thành công',
    'channel_id', p_channel_id,
    'channel_name', v_channel_name,
    'channel_code', v_channel_code
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Lỗi khi xóa kênh giao dịch: ' || SQLERRM
    );
END;
$$;


--
-- Name: delete_fee_direct(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.delete_fee_direct(p_fee_id uuid) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
  v_fee_exists BOOLEAN;
BEGIN
  -- Check if fee exists
  SELECT EXISTS(SELECT 1 FROM fees WHERE id = p_fee_id) INTO v_fee_exists;

  IF NOT v_fee_exists THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Không tìm thấy phí'
    );
  END IF;

  -- Delete fee (this bypasses RLS due to SECURITY DEFINER)
  DELETE FROM fees WHERE id = p_fee_id;

  RETURN jsonb_build_object(
    'success', true,
    'message', 'Xóa phí thành công',
    'fee_id', p_fee_id
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Lỗi khi xóa phí: ' || SQLERRM
    );
END;
$$;


--
-- Name: delete_game_account_direct(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.delete_game_account_direct(p_account_id uuid) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
  v_account_exists BOOLEAN;
  v_account_name TEXT;
  v_account_game_code TEXT;
  v_inventory_count INTEGER;
BEGIN
  -- Check if account exists
  SELECT EXISTS(SELECT 1 FROM game_accounts WHERE id = p_account_id) INTO v_account_exists;

  IF NOT v_account_exists THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Không tìm thấy tài khoản game'
    );
  END IF;

  -- Get account info for response and inventory check
  SELECT account_name, game_code INTO v_account_name, v_account_game_code 
  FROM game_accounts WHERE id = p_account_id;

  -- Check for existing inventory in inventory_pools
  SELECT COUNT(*) INTO v_inventory_count
  FROM inventory_pools
  WHERE game_account_id = p_account_id AND quantity > 0;

  IF v_inventory_count > 0 THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Không thể xóa tài khoản game vì vẫn còn tồn kho trong inventory pools. Vui lòng xóa hết tồn kho trước.',
      'inventory_count', v_inventory_count
    );
  END IF;

  -- Delete game account (this bypasses RLS due to SECURITY DEFINER)
  DELETE FROM game_accounts WHERE id = p_account_id;

  RETURN jsonb_build_object(
    'success', true,
    'message', 'Xóa tài khoản game thành công',
    'account_id', p_account_id,
    'account_name', v_account_name,
    'game_code', v_account_game_code
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Lỗi khi xóa tài khoản game: ' || SQLERRM
    );
END;
$$;


--
-- Name: delete_process_fee_mappings_direct(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.delete_process_fee_mappings_direct(p_process_id uuid) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
  v_count INTEGER;
BEGIN
  -- Count and delete existing mappings
  SELECT COUNT(*) INTO v_count 
  FROM process_fees_map 
  WHERE process_id = p_process_id;
  
  DELETE FROM process_fees_map 
  WHERE process_id = p_process_id;
  
  RETURN jsonb_build_object(
    'success', true,
    'message', 'Xóa ' || v_count || ' mapping phí thành công',
    'deleted_count', v_count
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Lỗi khi xóa mapping phí: ' || SQLERRM
    );
END;
$$;


--
-- Name: delete_shift_assignment_direct(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.delete_shift_assignment_direct(p_assignment_id uuid) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
  v_assignment_exists BOOLEAN;
BEGIN
  -- Check if assignment exists
  SELECT EXISTS(SELECT 1 FROM shift_assignments WHERE id = p_assignment_id) INTO v_assignment_exists;

  IF NOT v_assignment_exists THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Không tìm thấy phân công ca làm việc'
    );
  END IF;

  -- Delete shift assignment (this bypasses RLS due to SECURITY DEFINER)
  DELETE FROM shift_assignments WHERE id = p_assignment_id;

  RETURN jsonb_build_object(
    'success', true,
    'message', 'Xóa phân công ca làm việc thành công',
    'assignment_id', p_assignment_id
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Lỗi khi xóa phân công ca làm việc: ' || SQLERRM
    );
END;
$$;


--
-- Name: delete_work_shift_direct(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.delete_work_shift_direct(p_shift_id uuid) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
  v_shift_exists BOOLEAN;
  v_shift_name TEXT;
BEGIN
  -- Check if shift exists
  SELECT EXISTS(SELECT 1 FROM work_shifts WHERE id = p_shift_id) INTO v_shift_exists;

  IF NOT v_shift_exists THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Không tìm thấy ca làm việc'
    );
  END IF;

  -- Get shift name for response
  SELECT name INTO v_shift_name FROM work_shifts WHERE id = p_shift_id;

  -- Delete work shift (this bypasses RLS due to SECURITY DEFINER)
  DELETE FROM work_shifts WHERE id = p_shift_id;

  RETURN jsonb_build_object(
    'success', true,
    'message', 'Xóa ca làm việc thành công',
    'shift_id', p_shift_id,
    'shift_name', v_shift_name
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Lỗi khi xóa ca làm việc: ' || SQLERRM
    );
END;
$$;


--
-- Name: fetch_exchange_rates_direct(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fetch_exchange_rates_direct() RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_api_url TEXT := 'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/usd.json';
    v_response TEXT;
    v_request_id BIGINT;
    v_result JSONB;
    v_log_id UUID;
BEGIN
    -- Log the attempt
    INSERT INTO exchange_rate_api_log (api_provider, endpoint_url, success)
    VALUES ('direct_fetch', v_api_url, true)
    RETURNING id INTO v_log_id;
    
    -- Make HTTP request using pg_net
    SELECT net.http_get(v_api_url) INTO v_request_id;
    
    -- Wait for response (simple approach)
    PERFORM pg_sleep(2);
    
    -- Try to get response
    BEGIN
        SELECT response INTO v_response 
        FROM net.http_response 
        WHERE id = v_request_id;
        
        IF v_response IS NOT NULL THEN
            -- Parse and update exchange rates
            v_result := jsonb_extract_path_text(v_response, 'data');
            
            -- Update log with success
            UPDATE exchange_rate_api_log 
            SET success = true, currencies_fetched = 1 
            WHERE id = v_log_id;
            
            RETURN 'Exchange rates fetched successfully';
        ELSE
            -- Update log with failure
            UPDATE exchange_rate_api_log 
            SET success = false, error_message = 'No response received' 
            WHERE id = v_log_id;
            
            RETURN 'Failed to fetch exchange rates';
        END IF;
    EXCEPTION WHEN OTHERS THEN
        -- Update log with error
        UPDATE exchange_rate_api_log 
        SET success = false, error_message = SQLERRM 
        WHERE id = v_log_id;
        
        RETURN 'Error: ' || SQLERRM;
    END;
END;
$$;


--
-- Name: finalize_currency_order_v1(uuid, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.finalize_currency_order_v1(p_order_id uuid, p_final_notes text DEFAULT NULL::text) RETURNS TABLE(success boolean, message text)
    LANGUAGE plpgsql
    SET search_path TO 'public, pg_temp'
    AS $$
DECLARE
    v_user_id uuid := public.get_current_profile_id();
    v_order RECORD;
    v_can_finalize boolean := false;
BEGIN
    -- Permission Check using has_permission function
    v_can_finalize := public.has_permission('currency:finalize', jsonb_build_object('game_code', (SELECT game_code FROM public.currency_orders WHERE id = p_order_id)));

    IF NOT v_can_finalize THEN
        RETURN QUERY SELECT FALSE, 'Permission denied: Cannot finalize order', NULL::TEXT;
        RETURN;
    END IF;

    -- Get order info - must be in 'delivered' status
    SELECT * INTO v_order FROM public.currency_orders
    WHERE id = p_order_id AND status = 'delivered';

    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'Order not found or not in delivered status', NULL::TEXT;
        RETURN;
    END IF;

    -- Validate that proof is uploaded
    IF v_order.proof_urls IS NULL OR array_length(v_order.proof_urls, 1) IS NULL THEN
        RETURN QUERY SELECT FALSE, 'Cannot finalize order without proof. Please upload proof first.', NULL::TEXT;
        RETURN;
    END IF;

    -- Finalize order: move from delivered to completed
    UPDATE public.currency_orders
    SET status = 'completed',
        completed_at = NOW(),
        completion_notes = COALESCE(p_final_notes, v_order.completion_notes),
        updated_at = NOW(),
        updated_by = v_user_id
    WHERE id = p_order_id;

    RETURN QUERY SELECT TRUE, 'Order finalized and completed successfully';
END;
$$;


--
-- Name: find_available_account_for_sell_order(uuid, numeric, uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.find_available_account_for_sell_order(p_currency_attribute_id uuid, p_quantity numeric, p_channel_id uuid) RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
  v_game_account_id UUID;
BEGIN
  -- Find an account that has sufficient inventory for the requested currency and channel
  SELECT DISTINCT ci.game_account_id INTO v_game_account_id
  FROM currency_inventory ci
  WHERE ci.currency_attribute_id = p_currency_attribute_id
    AND ci.channel_id = p_channel_id
    AND (ci.quantity - ci.reserved_quantity) >= p_quantity
    AND EXISTS (
      SELECT 1 FROM game_accounts ga 
      WHERE ga.id = ci.game_account_id AND ga.is_active = true
    )
  ORDER BY ci.quantity DESC  -- Prefer account with most inventory
  LIMIT 1;
  
  RETURN v_game_account_id;
END;
$$;


--
-- Name: find_best_pool_in_currency(text, text, uuid, numeric, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.find_best_pool_in_currency(p_game_code text, p_server_attribute_code text, p_currency_attribute_id uuid, p_required_quantity numeric, p_cost_currency text) RETURNS TABLE(success boolean, inventory_pool_id uuid, game_account_id uuid, channel_id uuid, channel_name text, account_name text, average_cost numeric, cost_currency text, match_reason text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        true as success,
        ip.id as inventory_pool_id,
        ip.game_account_id,
        ip.channel_id,
        ch.name as channel_name,
        ga.account_name,
        ip.average_cost,  -- numeric
        ip.cost_currency,  -- text
        format('%s currency: Available %s, Cost: %s %s, Account: %s',
               p_cost_currency,
               (ip.quantity - COALESCE(ip.reserved_quantity, 0)),
               ip.average_cost,
               ip.cost_currency,
               ga.account_name
        ) as match_reason
    FROM public.inventory_pools ip
    JOIN public.game_accounts ga ON ip.game_account_id = ga.id
    JOIN public.channels ch ON ip.channel_id = ch.id
    WHERE ip.game_code = p_game_code
      AND COALESCE(ip.server_attribute_code, '') = COALESCE(p_server_attribute_code, '')
      AND ip.currency_attribute_id = p_currency_attribute_id
      AND ip.cost_currency = p_cost_currency
      AND (ip.quantity - COALESCE(ip.reserved_quantity, 0)) >= p_required_quantity
      AND ga.is_active = true
      AND ch.is_active = true
    ORDER BY 
        -- FIFO within same currency: oldest pool first
        ip.last_updated_at ASC,
        -- Tie-breaker: pool ID for consistency
        ip.id ASC
    LIMIT 1;
    
    -- If no pools found, return failure
    IF NOT FOUND THEN
        RETURN QUERY
        SELECT 
            false as success,
            NULL::UUID, NULL::UUID, NULL::UUID, NULL::TEXT, NULL::TEXT,
            NULL::NUMERIC, NULL::TEXT,
            format('No suitable pool found for %s currency', p_cost_currency) as match_reason
        LIMIT 1;
    END IF;
END;
$$;


--
-- Name: find_best_pool_in_currency_with_channel_rotation(text, text, uuid, numeric, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.find_best_pool_in_currency_with_channel_rotation(p_game_code text, p_server_attribute_code text, p_currency_attribute_id uuid, p_required_quantity numeric, p_cost_currency text) RETURNS TABLE(success boolean, inventory_pool_id uuid, game_account_id uuid, channel_id uuid, channel_name text, account_name text, average_cost numeric, cost_currency text, match_reason text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_base_key TEXT;
    v_selected_pool RECORD;
    v_channels TEXT[];
    v_current_index INTEGER;
    v_channel_order_json JSONB;
    v_array_length INTEGER;
    v_new_index INTEGER;
    v_channel_tracker_key TEXT;
BEGIN
    -- Build base key for this game+currency combination
    v_base_key := format('INVENTORY_POOL_%s_%s', p_game_code, p_currency_attribute_id::TEXT);
    v_channel_tracker_key := v_base_key || '_CHANNEL_' || p_cost_currency;
    
    -- Step 1: Update channel rotation tracker with detection
    PERFORM update_channel_rotation_tracker_with_detection(
        p_game_code, p_currency_attribute_id, p_cost_currency, v_base_key
    );
    
    -- Step 2: Get current channel rotation state
    SELECT employee_rotation_order, current_rotation_index
    INTO v_channel_order_json, v_current_index
    FROM assignment_trackers 
    WHERE assignment_type = 'inventory_pool_rotation'
      AND assignment_group_key = v_channel_tracker_key
    FOR UPDATE;
    
    -- Convert JSONB array to text array
    IF v_channel_order_json IS NOT NULL THEN
        SELECT array_agg(elem ORDER BY elem) INTO v_channels
        FROM jsonb_array_elements_text(v_channel_order_json) as elem;
    END IF;
    
    -- Get array length safely
    v_array_length := COALESCE(array_length(v_channels, 1), 0);
    
    -- Safety check - if no channels or single channel, fallback to Level 3 directly
    IF v_channels IS NULL OR v_array_length <= 1 THEN
        -- Single channel or no channels - try Level 3 directly
        IF v_array_length = 1 THEN
            SELECT * INTO v_selected_pool FROM find_best_pool_with_account_rotation(
                p_game_code,
                p_server_attribute_code,
                p_currency_attribute_id,
                p_required_quantity,
                p_cost_currency,
                v_channels[1],
                v_base_key
            );
            
            IF v_selected_pool.success THEN
                RETURN QUERY
                SELECT 
                    v_selected_pool.success,
                    v_selected_pool.inventory_pool_id,
                    v_selected_pool.game_account_id,
                    v_selected_pool.channel_id,
                    v_selected_pool.channel_name,
                    v_selected_pool.account_name,
                    v_selected_pool.average_cost,
                    v_selected_pool.cost_currency,
                    v_selected_pool.match_reason;
                RETURN;
            END IF;
        END IF;
        
        -- Fallback to original logic without channel rotation
        RETURN QUERY
        SELECT 
            pool_query.success,
            pool_query.inventory_pool_id,
            pool_query.game_account_id,
            pool_query.channel_id,
            pool_query.channel_name,
            pool_query.account_name,
            pool_query.average_cost,
            pool_query.cost_currency,
            pool_query.match_reason
        FROM (
            SELECT 
                true as success,
                ip.id as inventory_pool_id,
                ip.game_account_id,
                ip.channel_id,
                ch.name as channel_name,
                ga.account_name,
                ip.average_cost,
                ip.cost_currency,
                format('%s currency: Available %s, Cost: %s %s, Account: %s',
                       p_cost_currency,
                       (ip.quantity - COALESCE(ip.reserved_quantity, 0)),
                       ip.average_cost,
                       ip.cost_currency,
                       ga.account_name
                ) as match_reason
            FROM public.inventory_pools ip
            JOIN public.game_accounts ga ON ip.game_account_id = ga.id
            JOIN public.channels ch ON ip.channel_id = ch.id
            WHERE ip.game_code = p_game_code
              AND COALESCE(ip.server_attribute_code, '') = COALESCE(p_server_attribute_code, '')
              AND ip.currency_attribute_id = p_currency_attribute_id
              AND ip.cost_currency = p_cost_currency
              AND (ip.quantity - COALESCE(ip.reserved_quantity, 0)) >= p_required_quantity
              AND ga.is_active = true
              AND ch.is_active = true
            ORDER BY 
                ip.last_updated_at ASC,
                ip.id ASC
            LIMIT 1
        ) as pool_query;
        RETURN;
    END IF;
    
    -- Step 3: Multi-channel rotation - try each channel with Level 3 Account Rotation
    FOR i IN 0..v_array_length-1 LOOP
        DECLARE
            v_try_channel TEXT;
            v_try_channel_idx INTEGER;
        BEGIN
            -- Calculate correct array index (convert 0-based to 1-based)
            v_try_channel_idx := ((v_current_index + i) % v_array_length) + 1;
            v_try_channel := v_channels[v_try_channel_idx];
            
            -- Try to find suitable pool in this channel using Level 3 Account Rotation
            SELECT * INTO v_selected_pool FROM (
                SELECT * FROM find_best_pool_with_account_rotation(
                    p_game_code,
                    p_server_attribute_code,
                    p_currency_attribute_id,
                    p_required_quantity,
                    p_cost_currency,
                    v_try_channel,
                    v_base_key
                )
            ) as level3_result;
            
            IF v_selected_pool.success THEN
                -- Found suitable pool! Update channel rotation tracker
                -- Calculate new index (keep 0-based for rotation tracker)
                v_new_index := (v_current_index + i + 1) % v_array_length;
                
                -- Update channel rotation tracker
                UPDATE assignment_trackers 
                SET current_rotation_index = v_new_index,
                    last_assigned_employee_id = v_selected_pool.inventory_pool_id,
                    last_assigned_at = NOW(),
                    updated_at = NOW(),
                    description = format('Channel rotation (%s): %s → %s (Index: %s → %s) | Level 3: %s', 
                                      p_cost_currency,
                                      CASE WHEN v_current_index < v_array_length 
                                           THEN v_channels[v_current_index + 1] 
                                           ELSE 'UNKNOWN' END, 
                                      v_try_channel,
                                      v_current_index,
                                      v_new_index,
                                      v_selected_pool.account_name)
                WHERE assignment_type = 'inventory_pool_rotation'
                  AND assignment_group_key = v_channel_tracker_key;
                
                RETURN QUERY
                SELECT 
                    v_selected_pool.success,
                    v_selected_pool.inventory_pool_id,
                    v_selected_pool.game_account_id,
                    v_selected_pool.channel_id,
                    v_selected_pool.channel_name,
                    v_selected_pool.account_name,
                    v_selected_pool.average_cost,
                    v_selected_pool.cost_currency,
                    v_selected_pool.match_reason || format(' | Channel rotation position: %s', i);
                RETURN;
            END IF;
        END;
    END LOOP;
    
    -- If no channels found suitable pool, return failure
    RETURN QUERY
    SELECT 
        false as success,
        NULL::UUID, NULL::UUID, NULL::UUID, NULL::TEXT, NULL::TEXT,
        NULL::NUMERIC, NULL::TEXT,
        format('No suitable pool found for %s currency across all %s channels', p_cost_currency, v_array_length);
END;
$$;


--
-- Name: find_best_pool_with_account_rotation(text, text, uuid, numeric, text, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.find_best_pool_with_account_rotation(p_game_code text, p_server_attribute_code text, p_currency_attribute_id uuid, p_required_quantity numeric, p_cost_currency text, p_channel_name text, p_base_key text) RETURNS TABLE(success boolean, inventory_pool_id uuid, game_account_id uuid, channel_id uuid, channel_name text, account_name text, cost_currency text, average_cost numeric, match_reason text, priority_info jsonb)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_account_rotation JSONB;
    v_account_tracker_key TEXT;
    v_current_index INTEGER;
    v_accounts TEXT[];
    v_array_length INTEGER;
    v_new_index INTEGER;
    v_selected_pool RECORD;
    v_insufficient_accounts TEXT[];
    v_priority_queue JSONB;
    v_tracker_exists BOOLEAN;
BEGIN
    -- Build account tracker key
    v_account_tracker_key := p_base_key || '_ACCOUNT_' || p_cost_currency || '_' || p_channel_name;
    
    -- Check if tracker exists
    SELECT EXISTS(
        SELECT 1 FROM assignment_trackers 
        WHERE assignment_type = 'inventory_pool_rotation'
          AND assignment_group_key = v_account_tracker_key
    ) INTO v_tracker_exists;
    
    -- Step 1: Get current account rotation or create tracker
    IF v_tracker_exists THEN
        SELECT employee_rotation_order, current_rotation_index
        INTO v_account_rotation, v_current_index
        FROM assignment_trackers 
        WHERE assignment_type = 'inventory_pool_rotation'
          AND assignment_group_key = v_account_tracker_key
        FOR UPDATE;
    END IF;
    
    -- Step 2: Initialize tracker if doesn't exist
    IF v_account_rotation IS NULL THEN
        SELECT jsonb_agg(DISTINCT ga.account_name ORDER BY ga.account_name)
        INTO v_account_rotation
        FROM inventory_pools ip
        JOIN game_accounts ga ON ip.game_account_id = ga.id
        JOIN channels ch ON ip.channel_id = ch.id
        WHERE ip.game_code = p_game_code
          AND ip.currency_attribute_id = p_currency_attribute_id
          AND ip.cost_currency = p_cost_currency
          AND ch.name = p_channel_name
          AND ga.is_active = true
          AND (ip.quantity - COALESCE(ip.reserved_quantity, 0)) > 0;
        
        -- Create account rotation tracker
        INSERT INTO assignment_trackers (
            assignment_type, assignment_group_key, employee_rotation_order,
            current_rotation_index, order_type_filter, business_domain, description
        ) VALUES (
            'inventory_pool_rotation', v_account_tracker_key,
            v_account_rotation, 0, 'SELL', 'CURRENCY_TRADING',
            format('Account rotation for %s - %s - %s', p_cost_currency, p_channel_name, p_base_key)
        );
        
        v_current_index := 0;
        v_tracker_exists := TRUE;
    END IF;
    
    -- Convert JSONB to text array
    SELECT array_agg(elem ORDER BY elem) INTO v_accounts
    FROM jsonb_array_elements_text(v_account_rotation) as elem;
    
    v_array_length := COALESCE(array_length(v_accounts, 1), 0);
    
    -- Safety check
    IF v_accounts IS NULL OR v_array_length = 0 THEN
        RETURN QUERY
        SELECT false, NULL::UUID, NULL::UUID, NULL::UUID, NULL::TEXT, NULL::TEXT,
               NULL::TEXT, NULL::NUMERIC, 'No active accounts found',
               jsonb_build_object('error', 'No accounts available');
        RETURN;
    END IF;
    
    -- Step 3: Check for insufficient quantity accounts (for priority queue)
    SELECT array_agg(DISTINCT ga.account_name)
    INTO v_insufficient_accounts
    FROM inventory_pools ip
    JOIN game_accounts ga ON ip.game_account_id = ga.id
    JOIN channels ch ON ip.channel_id = ch.id
    WHERE ip.game_code = p_game_code
      AND ip.currency_attribute_id = p_currency_attribute_id
      AND ip.cost_currency = p_cost_currency
      AND ch.name = p_channel_name
      AND ga.is_active = true
      AND (ip.quantity - COALESCE(ip.reserved_quantity, 0)) < p_required_quantity
      AND (ip.quantity - COALESCE(ip.reserved_quantity, 0)) > 0; -- Still positive but insufficient
    
    -- Build priority queue JSONB
    v_priority_queue := jsonb_build_object(
        'insufficient_accounts', COALESCE(v_insufficient_accounts, '{}'::TEXT[]),
        'required_quantity', p_required_quantity,
        'total_accounts', v_array_length,
        'current_rotation_index', v_current_index
    );
    
    -- Step 4: Try rotation with priority mechanism
    FOR i IN 0..v_array_length-1 LOOP
        DECLARE
            v_try_account TEXT;
            v_try_account_idx INTEGER;
        BEGIN
            -- Calculate correct array index (convert 0-based to 1-based)
            v_try_account_idx := ((v_current_index + i) % v_array_length) + 1;
            v_try_account := v_accounts[v_try_account_idx];
            
            -- Try to find suitable pool for this account with priority scoring
            SELECT * INTO v_selected_pool FROM (
                SELECT 
                    true as success,
                    ip.id as inventory_pool_id,
                    ip.game_account_id,
                    ip.channel_id,
                    ch.name as channel_name,
                    ga.account_name,
                    ip.cost_currency,
                    ip.average_cost,
                    ip.quantity - COALESCE(ip.reserved_quantity, 0) as available_quantity,
                    format('Account rotation pos: %s | Available: %s | Cost: %s %s | %s channel | Priority: %s', 
                           i,
                           (ip.quantity - COALESCE(ip.reserved_quantity, 0)),
                           ip.average_cost,
                           ip.cost_currency,
                           p_channel_name,
                           CASE 
                               WHEN (ip.quantity - COALESCE(ip.reserved_quantity, 0)) >= p_required_quantity THEN 100
                               WHEN ga.account_name = ANY(v_insufficient_accounts) THEN 90
                               ELSE 50
                           END) as match_reason,
                    -- Priority scoring: Higher score = higher priority
                    CASE 
                        WHEN (ip.quantity - COALESCE(ip.reserved_quantity, 0)) >= p_required_quantity THEN 100
                        WHEN ga.account_name = ANY(v_insufficient_accounts) THEN 90
                        ELSE 50
                    END as priority_score
                FROM inventory_pools ip
                JOIN game_accounts ga ON ip.game_account_id = ga.id
                JOIN channels ch ON ip.channel_id = ch.id
                WHERE ip.game_code = p_game_code
                  AND COALESCE(ip.server_attribute_code, '') = COALESCE(p_server_attribute_code, '')
                  AND ip.currency_attribute_id = p_currency_attribute_id
                  AND ip.cost_currency = p_cost_currency
                  AND ch.name = p_channel_name
                  AND ga.account_name = v_try_account
                  AND ga.is_active = true
                  AND (ip.quantity - COALESCE(ip.reserved_quantity, 0)) > 0
                ORDER BY 
                    priority_score DESC,  -- Highest priority first
                    ip.last_updated_at ASC,  -- FIFO within same priority
                    ip.id ASC
                LIMIT 1
            ) as pool_query;
            
            IF v_selected_pool.success THEN
                -- Found suitable pool! Update rotation tracker
                v_new_index := (v_current_index + i + 1) % v_array_length;
                
                -- Update account rotation tracker
                UPDATE assignment_trackers 
                SET current_rotation_index = v_new_index,
                    last_assigned_employee_id = v_selected_pool.inventory_pool_id,
                    last_assigned_at = NOW(),
                    updated_at = NOW(),
                    description = format('Account rotation (%s): %s → %s (Index: %s → %s) | Priority: %s', 
                                      p_cost_currency || '_' || p_channel_name,
                                      CASE WHEN v_current_index < v_array_length 
                                           THEN v_accounts[v_current_index + 1] 
                                           ELSE 'UNKNOWN' END, 
                                      v_try_account,
                                      v_current_index,
                                      v_new_index,
                                      v_selected_pool.priority_score)
                WHERE assignment_type = 'inventory_pool_rotation'
                  AND assignment_group_key = v_account_tracker_key;
                
                -- Enhanced priority info
                v_priority_queue := v_priority_queue || jsonb_build_object(
                    'selected_account', v_try_account,
                    'rotation_position', i,
                    'priority_score', v_selected_pool.priority_score,
                    'was_insufficient', CASE WHEN v_try_account = ANY(v_insufficient_accounts) THEN true ELSE false END,
                    'had_sufficient_quantity', CASE WHEN v_selected_pool.available_quantity >= p_required_quantity THEN true ELSE false END,
                    'available_quantity', v_selected_pool.available_quantity
                );
                
                RETURN QUERY
                SELECT 
                    v_selected_pool.success,
                    v_selected_pool.inventory_pool_id,
                    v_selected_pool.game_account_id,
                    v_selected_pool.channel_id,
                    v_selected_pool.channel_name,
                    v_selected_pool.account_name,
                    v_selected_pool.cost_currency,
                    v_selected_pool.average_cost,
                    v_selected_pool.match_reason,
                    v_priority_queue;
                RETURN;
            END IF;
        END;
    END LOOP;
    
    -- Step 5: If no suitable pool found, return detailed failure info
    RETURN QUERY
    SELECT 
        false, NULL::UUID, NULL::UUID, NULL::UUID, NULL::TEXT, NULL::TEXT,
        NULL::TEXT, NULL::NUMERIC, 
        format('No suitable pool found for %s - %s across all %s accounts', p_cost_currency, p_channel_name, v_array_length),
        v_priority_queue || jsonb_build_object('failure_reason', 'No account had sufficient quantity');
END;
$$;


--
-- Name: finish_work_session_idem_v1(uuid, jsonb, jsonb, text, text, text, text[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.finish_work_session_idem_v1(p_session_id uuid, p_outputs jsonb, p_activity_rows jsonb, p_overrun_reason text, p_idem_key text, p_overrun_type text, p_overrun_proof_urls text[]) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
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


--
-- Name: generate_order_number(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.generate_order_number() RETURNS TABLE(order_number text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
BEGIN
    RETURN QUERY SELECT 'ORD-' || to_char(NOW(), 'YYYYMMDD-HH24MISS') as order_number;
END;
$$;


--
-- Name: generate_sell_order_number(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.generate_sell_order_number() RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
    -- Generate order number for sell orders (using SO prefix like PO)
    RETURN 'SO' || TO_CHAR(NOW(), 'YYYYMMDD') || LPAD(EXTRACT(MICROSECONDS FROM NOW())::TEXT, 6, '0');
END;
$$;


--
-- Name: get_account_access_with_details(date, uuid, uuid, uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_account_access_with_details(p_date date DEFAULT CURRENT_DATE, p_employee_id uuid DEFAULT NULL::uuid, p_shift_id uuid DEFAULT NULL::uuid, p_channel_id uuid DEFAULT NULL::uuid) RETURNS TABLE(access_id uuid, employee_profile_id uuid, employee_name text, shift_id uuid, shift_name text, game_account_id uuid, game_account_name text, game_code text, channel_id uuid, channel_name text, access_level text, assigned_date date, is_active boolean, notes text, granted_at timestamp with time zone)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        saa.id,
        saa.employee_profile_id,
        p.display_name,
        saa.shift_id,
        ws.name,
        saa.game_account_id,
        ga.account_name,
        ga.game_code,
        saa.channel_id,
        c.name,
        saa.access_level,
        saa.assigned_date,
        saa.is_active,
        saa.notes,
        saa.granted_at
    FROM shift_account_access saa
    JOIN profiles p ON saa.employee_profile_id = p.id
    JOIN work_shifts ws ON saa.shift_id = ws.id
    JOIN game_accounts ga ON saa.game_account_id = ga.id
    JOIN channels c ON saa.channel_id = c.id
    WHERE saa.assigned_date = p_date
      AND (p_employee_id IS NULL OR saa.employee_profile_id = p_employee_id)
      AND (p_shift_id IS NULL OR saa.shift_id = p_shift_id)
      AND (p_channel_id IS NULL OR saa.channel_id = p_channel_id)
    ORDER BY ws.name, p.display_name, ga.account_name;
END;
$$;


--
-- Name: get_all_active_profiles_direct(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_all_active_profiles_direct() RETURNS TABLE(id uuid, display_name text, status text, created_at timestamp with time zone, updated_at timestamp with time zone)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
  RETURN QUERY
  SELECT
    p.id,
    p.display_name,
    p.status,
    p.created_at,
    p.updated_at
  FROM profiles p
  WHERE p.status = 'active'
  ORDER BY p.display_name ASC;
END;
$$;


--
-- Name: get_all_business_processes_direct(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_all_business_processes_direct() RETURNS TABLE(id uuid, code text, name text, description text, is_active boolean, created_at timestamp with time zone, created_by uuid, sale_channel_id uuid, sale_channel_name text, sale_currency text, purchase_channel_id uuid, purchase_channel_name text, purchase_currency text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
  RETURN QUERY
  SELECT
    bp.id,
    bp.code::text,
    bp.name::text,
    bp.description::text,
    bp.is_active,
    bp.created_at,
    bp.created_by,
    bp.sale_channel_id,
    COALESCE(c1.name::text, 'Unknown'::text) as sale_channel_name,
    bp.sale_currency::text,
    bp.purchase_channel_id,
    COALESCE(c2.name::text, 'Unknown'::text) as purchase_channel_name,
    bp.purchase_currency::text
  FROM business_processes bp
  LEFT JOIN channels c1 ON bp.sale_channel_id = c1.id
  LEFT JOIN channels c2 ON bp.purchase_channel_id = c2.id
  ORDER BY bp.created_at DESC;
END;
$$;


--
-- Name: get_all_channels_direct(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_all_channels_direct() RETURNS TABLE(id uuid, code text, name text, description text, website_url text, direction text, is_active boolean, created_at timestamp with time zone, updated_at timestamp with time zone, created_by uuid, updated_by uuid)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
  RETURN QUERY
  SELECT
    c.id,
    c.code,
    c.name,
    c.description,
    c.website_url,
    c.direction,
    c.is_active,
    c.created_at,
    c.updated_at,
    c.created_by,
    c.updated_by
  FROM channels c
  ORDER BY c.created_at DESC;
END;
$$;


--
-- Name: get_all_currencies_direct(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_all_currencies_direct() RETURNS TABLE(code text, name text, is_active boolean)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
  RETURN QUERY
  SELECT
    curr.code,
    curr.name,
    curr.is_active
  FROM currencies curr
  WHERE curr.is_active = true
  ORDER BY curr.code;
END;
$$;


--
-- Name: get_all_fees_direct(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_all_fees_direct() RETURNS TABLE(id uuid, code text, name text, direction text, fee_type text, amount numeric, currency text, is_active boolean, created_at timestamp with time zone, created_by uuid)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
  RETURN QUERY
  SELECT
    f.id,
    f.code,
    f.name,
    f.direction,
    f.fee_type,
    f.amount,
    f.currency,
    f.is_active,
    f.created_at,
    f.created_by
  FROM fees f
  ORDER BY f.created_at DESC;
END;
$$;


--
-- Name: get_all_game_accounts_direct(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_all_game_accounts_direct() RETURNS TABLE(id uuid, game_code text, account_name text, purpose text, is_active boolean, server_attribute_code text, created_at timestamp with time zone, updated_at timestamp with time zone)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
  RETURN QUERY
  SELECT
    ga.id,
    ga.game_code,
    ga.account_name,
    ga.purpose,
    ga.is_active,
    ga.server_attribute_code,
    ga.created_at,
    ga.updated_at
  FROM game_accounts ga
  ORDER BY ga.created_at DESC;
END;
$$;


--
-- Name: get_all_inventory_pools(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_all_inventory_pools() RETURNS TABLE(id uuid, game_code text, server_attribute_code text, currency_attribute_id uuid, game_account_id uuid, quantity numeric, reserved_quantity numeric, average_cost numeric, cost_currency text, channel_id uuid, last_updated_at timestamp with time zone, last_updated_by uuid, currency_name text, currency_code text, account_name text, channel_name text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
    -- Return comprehensive inventory data with all necessary joins
    -- Không cần profile ID cho việc đọc data chỉ để xem
    RETURN QUERY
    SELECT 
        ip.id,
        ip.game_code,
        ip.server_attribute_code,
        ip.currency_attribute_id,
        ip.game_account_id,
        ip.quantity,
        ip.reserved_quantity,
        ip.average_cost,
        ip.cost_currency,
        ip.channel_id,
        ip.last_updated_at,
        ip.last_updated_by,
        attr.name as currency_name,
        attr.code as currency_code,
        ga.account_name,
        ch.name as channel_name
    FROM inventory_pools ip
    LEFT JOIN attributes attr ON ip.currency_attribute_id = attr.id
    LEFT JOIN game_accounts ga ON ip.game_account_id = ga.id
    LEFT JOIN channels ch ON ip.channel_id = ch.id
    WHERE ip.quantity > 0 OR ip.reserved_quantity > 0
    ORDER BY 
        ip.game_code ASC,
        attr.name ASC,
        ip.cost_currency ASC,
        ip.quantity DESC;
END;
$$;


--
-- Name: get_all_process_fee_counts_direct(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_all_process_fee_counts_direct() RETURNS TABLE(process_id uuid, fee_count bigint)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
  RETURN QUERY
  SELECT 
    pfm.process_id,
    COUNT(*)::BIGINT as fee_count
  FROM process_fees_map pfm
  GROUP BY pfm.process_id;
END;
$$;


--
-- Name: get_all_proof_files(jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_all_proof_files(order_proofs jsonb) RETURNS jsonb
    LANGUAGE plpgsql IMMUTABLE
    SET search_path TO 'public, pg_temp'
    AS $$
DECLARE
    result JSONB := '[]'::JSONB;
    stage JSONB;
    order_type JSONB;
    category JSONB;
    files JSONB;
BEGIN
    -- Loop through all stages
    FOR stage IN SELECT jsonb_array_elements(order_proofs) LOOP
        -- Loop through all order types in this stage
        FOR order_type IN SELECT jsonb_array_elements(stage) LOOP
            -- Loop through all categories in this order type
            FOR category IN SELECT jsonb_array_elements(order_type) LOOP
                -- Get files array
                files := category->'files';

                -- If files exist, merge into result
                IF jsonb_array_length(files) > 0 THEN
                    result := result || files;
                END IF;
            END LOOP;
        END LOOP;
    END LOOP;

    RETURN result;
END;
$$;


--
-- Name: get_all_shift_assignments_direct(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_all_shift_assignments_direct() RETURNS TABLE(id uuid, game_account_id uuid, game_account_name text, employee_profile_id uuid, employee_name text, shift_id uuid, shift_name text, shift_start_time time without time zone, shift_end_time time without time zone, channels_id uuid, channel_name text, currency_code text, currency_name text, is_active boolean, assigned_at timestamp with time zone)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
  RETURN QUERY
  SELECT
    sa.id,
    sa.game_account_id,
    COALESCE(ga.account_name, 'Unknown') as game_account_name,
    sa.employee_profile_id,
    COALESCE(p.display_name, 'Unknown') as employee_name,
    sa.shift_id,
    COALESCE(ws.name, 'Unknown') as shift_name,
    ws.start_time as shift_start_time,
    ws.end_time as shift_end_time,
    sa.channels_id,
    COALESCE(c.name, 'Unknown') as channel_name,
    sa.currency_code,
    COALESCE(curr.name, sa.currency_code) as currency_name,
    sa.is_active,
    sa.assigned_at
  FROM shift_assignments sa
  LEFT JOIN game_accounts ga ON sa.game_account_id = ga.id
  LEFT JOIN profiles p ON sa.employee_profile_id = p.id
  LEFT JOIN work_shifts ws ON sa.shift_id = ws.id
  LEFT JOIN channels c ON sa.channels_id = c.id
  LEFT JOIN currencies curr ON sa.currency_code = curr.code
  ORDER BY sa.assigned_at DESC;
END;
$$;


--
-- Name: get_all_work_shifts_direct(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_all_work_shifts_direct() RETURNS TABLE(id uuid, name text, start_time time without time zone, end_time time without time zone, description text, is_active boolean, created_at timestamp with time zone, updated_at timestamp with time zone)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
  RETURN QUERY
  SELECT
    ws.id,
    ws.name,
    ws.start_time,
    ws.end_time,
    ws.description,
    ws.is_active,
    ws.created_at,
    ws.updated_at
  FROM work_shifts ws
  ORDER BY ws.created_at DESC;
END;
$$;


--
-- Name: get_available_employee_for_channel(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_available_employee_for_channel(p_channel_id uuid) RETURNS TABLE(employee_id uuid, employee_name text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
    RETURN QUERY
    SELECT e.id, e.full_name
    FROM public.employees e
    JOIN public.employee_channels ec ON e.id = ec.employee_id
    WHERE ec.channel_id = p_channel_id
      AND e.status = 'active'
      AND e.is_available = true
    ORDER BY e.last_assignment_at ASC NULLS FIRST
    LIMIT 1;
END;
$$;


--
-- Name: get_available_game_accounts(text, text, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_available_game_accounts(p_game_code text, p_server_attribute_code text DEFAULT NULL::text, p_limit integer DEFAULT 1) RETURNS TABLE(account_id uuid, game_code text, server_attribute_code text, account_name text, purpose text, is_active boolean, created_at timestamp with time zone, updated_at timestamp with time zone)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
    -- Strict matching: Only exact server match or global accounts (NULL server)
    -- Priority: 1. Exact server match, 2. Global accounts (NULL server)
    RETURN QUERY
    SELECT
        ga.id as account_id,
        ga.game_code,
        ga.server_attribute_code,
        ga.account_name,
        ga.purpose,
        ga.is_active,
        ga.created_at,
        ga.updated_at
    FROM public.game_accounts ga
    WHERE ga.game_code = p_game_code
      AND ga.is_active = true
      AND (
        ga.server_attribute_code = p_server_attribute_code  -- Exact server match
        OR (ga.server_attribute_code IS NULL AND p_server_attribute_code IS NOT NULL)  -- Global account
        OR (ga.server_attribute_code IS NULL AND p_server_attribute_code IS NULL)  -- Both null (games without servers)
      )
    ORDER BY
        CASE
            WHEN ga.server_attribute_code = p_server_attribute_code THEN 1  -- Priority to exact match
            WHEN ga.server_attribute_code IS NULL THEN 2  -- Then global accounts
            ELSE 3
        END,
        random()  -- Random within same priority
    LIMIT p_limit;

    -- Fixed logging with qualified column names
    RAISE LOG '[GET_AVAILABLE_GAME_ACCOUNTS] Fixed function for game:% server:% found:% accounts',
                p_game_code, p_server_attribute_code,
                (SELECT COUNT(*) FROM public.game_accounts ga2 WHERE ga2.game_code = p_game_code AND ga2.is_active = true
                 AND (ga2.server_attribute_code = p_server_attribute_code
                      OR (ga2.server_attribute_code IS NULL AND p_server_attribute_code IS NOT NULL)
                      OR (ga2.server_attribute_code IS NULL AND p_server_attribute_code IS NULL)));
END;
$$;


--
-- Name: get_best_inventory_pool_for_sell_order(text, text, uuid, numeric); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_best_inventory_pool_for_sell_order(p_game_code text, p_server_attribute_code text, p_currency_attribute_id uuid, p_required_quantity numeric) RETURNS TABLE(success boolean, message text, inventory_pool_id uuid, game_account_id uuid, channel_id uuid, channel_name text, account_name text, average_cost numeric, cost_currency text, match_reason text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_base_key TEXT;
    v_selected_pool RECORD;
BEGIN
    -- Build base key for this game+currency combination
    v_base_key := format('INVENTORY_POOL_%s_%s', p_game_code, p_currency_attribute_id::TEXT);
    
    -- Try to find suitable pool using account-first rotation (most comprehensive)
    SELECT * INTO v_selected_pool FROM (
        SELECT 
            result.success,
            result.message,
            result.inventory_pool_id,
            result.game_account_id,
            result.channel_id,
            result.channel_name,
            result.account_name,
            result.average_cost,
            result.cost_currency,
            result.match_reason
        FROM get_inventory_pool_with_account_first_rotation(
            p_game_code,
            p_server_attribute_code,
            p_currency_attribute_id,
            p_required_quantity
        ) AS result
        WHERE result.success = true
        LIMIT 1
    ) as result_query;
    
    -- If found, return it
    IF v_selected_pool.success THEN
        RETURN QUERY
        SELECT 
            v_selected_pool.success,
            v_selected_pool.message,
            v_selected_pool.inventory_pool_id,
            v_selected_pool.game_account_id,
            v_selected_pool.channel_id,
            v_selected_pool.channel_name,
            v_selected_pool.account_name,
            v_selected_pool.average_cost,
            v_selected_pool.cost_currency,
            v_selected_pool.match_reason;
        RETURN;
    END IF;
    
    -- If no suitable pool found, return failure
    RETURN QUERY
    SELECT 
        false as success,
        format('No suitable inventory pool found for %s quantity', p_required_quantity) as message,
        NULL::UUID, NULL::UUID, NULL::UUID, NULL::TEXT, NULL::TEXT, 
        NULL::DECIMAL, NULL::TEXT, NULL::TEXT;
END;
$$;


--
-- Name: get_boosting_filter_options(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_boosting_filter_options() RETURNS TABLE(channels text[], service_types text[], package_types text[], statuses text[])
    LANGUAGE sql SECURITY DEFINER
    SET search_path TO 'public'
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


--
-- Name: FUNCTION get_boosting_filter_options(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.get_boosting_filter_options() IS 'Returns all distinct filter option values for the Service Boosting page. Used to populate filter dropdowns with all possible values from the database, not just from currently loaded records.';


--
-- Name: get_boosting_order_detail_v1(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_boosting_order_detail_v1(p_line_id uuid) RETURNS json
    LANGUAGE sql STABLE
    SET search_path TO 'public'
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


--
-- Name: get_boosting_orders_v3(integer, integer, text[], text[], text[], text[], text, text, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_boosting_orders_v3(p_limit integer DEFAULT 50, p_offset integer DEFAULT 0, p_channels text[] DEFAULT NULL::text[], p_statuses text[] DEFAULT NULL::text[], p_service_types text[] DEFAULT NULL::text[], p_package_types text[] DEFAULT NULL::text[], p_customer_name text DEFAULT NULL::text, p_assignee text DEFAULT NULL::text, p_delivery_status text DEFAULT NULL::text, p_review_status text DEFAULT NULL::text) RETURNS TABLE(id uuid, order_id uuid, created_at timestamp with time zone, updated_at timestamp with time zone, status text, channel_code text, customer_name text, deadline timestamp with time zone, btag text, login_id text, login_pwd text, service_type text, package_type text, package_note text, assignees_text text, service_items jsonb, review_id uuid, machine_info text, paused_at timestamp with time zone, delivered_at timestamp with time zone, action_proof_urls text[], pilot_warning_level integer, pilot_is_blocked boolean, pilot_cycle_start_at timestamp with time zone, total_count bigint)
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'public'
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


--
-- Name: get_boosting_orders_v4(integer, integer, uuid[], text[], text[], text[], text, text, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_boosting_orders_v4(p_limit integer DEFAULT 50, p_offset integer DEFAULT 0, p_channels uuid[] DEFAULT NULL::uuid[], p_statuses text[] DEFAULT NULL::text[], p_service_types text[] DEFAULT NULL::text[], p_package_types text[] DEFAULT NULL::text[], p_customer_name text DEFAULT NULL::text, p_assignee text DEFAULT NULL::text, p_delivery_status text DEFAULT NULL::text, p_review_status text DEFAULT NULL::text) RETURNS TABLE(id uuid, order_id uuid, created_at timestamp with time zone, updated_at timestamp with time zone, status text, channel_code text, customer_name text, deadline timestamp with time zone, btag text, login_id text, login_pwd text, service_type text, package_type text, package_note text, assignees_text text, service_items jsonb, review_id uuid, machine_info text, paused_at timestamp with time zone, delivered_at timestamp with time zone, action_proof_urls text[], pilot_warning_level integer, pilot_is_blocked boolean, pilot_cycle_start_at timestamp with time zone, total_count bigint)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
  RETURN QUERY
    WITH active_farmers AS (
      -- Use the materialized view for better performance
      SELECT
        mv_active_farmers.order_line_id,
        mv_active_farmers.farmer_names,
        mv_active_farmers.active_session_count,
        mv_active_farmers.last_updated
      FROM mv_active_farmers
    ),
    line_items AS (
      -- Aggregate service items for each order line (from v3)
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
      FROM order_service_items osi
      JOIN attributes a_kind ON osi.service_kind_id = a_kind.id
      GROUP BY osi.order_line_id
    ),
    base_query AS (
      SELECT
        ol.id,
        ol.order_id,
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
        -- Only show assignees if there are actually active sessions
        af.farmer_names as assignees_text,
        COALESCE(li.items, '[]'::jsonb) as service_items,
        (SELECT r.id FROM order_reviews r WHERE r.order_line_id = ol.id LIMIT 1) as review_id,
        ol.machine_info,
        ol.paused_at,
        o.delivered_at,
        ol.action_proof_urls,
        COALESCE(ol.pilot_warning_level, 0) as pilot_warning_level,
        COALESCE(ol.pilot_is_blocked, FALSE) as pilot_is_blocked,
        COALESCE(ol.pilot_cycle_start_at, o.created_at) as pilot_cycle_start_at
      FROM order_lines ol
      JOIN orders o ON ol.order_id = o.id
      JOIN parties p ON o.party_id = p.id
      LEFT JOIN product_variants pv ON ol.variant_id = pv.id
      LEFT JOIN channels ch ON o.channel_id = ch.id
      LEFT JOIN customer_accounts ca ON ol.customer_account_id = ca.id
      LEFT JOIN active_farmers af ON ol.id = af.order_line_id
      LEFT JOIN line_items li ON ol.id = li.order_line_id
      WHERE o.game_code = 'DIABLO_4' AND o.status <> 'draft'
        AND (p_channels IS NULL OR o.channel_id = ANY(p_channels))
        AND (p_statuses IS NULL OR o.status = ANY(p_statuses))
        AND (p_service_types IS NULL OR pv.display_name = ANY(p_service_types))
        AND (p_package_types IS NULL OR o.package_type = ANY(p_package_types))
        AND (p_customer_name IS NULL OR LOWER(p.name) LIKE LOWER('%' || TRIM(p_customer_name) || '%'))
        AND (p_assignee IS NULL OR (af.farmer_names IS NOT NULL AND LOWER(af.farmer_names) LIKE LOWER('%' || TRIM(p_assignee) || '%')))
    ),
    filtered_query AS (
      SELECT * FROM base_query
      -- Additional filtering for delivery status if specified
      WHERE
        CASE
          WHEN p_delivery_status = 'delivered' THEN base_query.delivered_at IS NOT NULL
          WHEN p_delivery_status = 'not_delivered' THEN base_query.delivered_at IS NULL
          ELSE TRUE
        END
        -- Additional filtering for review status if specified
        AND CASE
          WHEN p_review_status = 'reviewed' THEN base_query.review_id IS NOT NULL
          WHEN p_review_status = 'not_reviewed' THEN base_query.review_id IS NULL
          ELSE TRUE
        END
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
      bq.pilot_warning_level,
      bq.pilot_is_blocked,
      bq.pilot_cycle_start_at,
      COUNT(*) OVER() as total_count
    FROM filtered_query bq
    ORDER BY
      CASE bq.status
        WHEN 'new' THEN 1
        WHEN 'in_progress' THEN 2
        WHEN 'pending_pilot' THEN 3
        WHEN 'paused_selfplay' THEN 4
        WHEN 'customer_playing' THEN 5
        WHEN 'pending_completion' THEN 6
        WHEN 'completed' THEN 7
        WHEN 'cancelled' THEN 8
        ELSE 99
      END,
      bq.delivered_at ASC NULLS FIRST,
      bq.assignees_text ASC NULLS LAST,
      bq.updated_at DESC NULLS LAST,
      bq.deadline ASC NULLS LAST
    LIMIT p_limit OFFSET p_offset;
END;
$$;


--
-- Name: get_currency_orders_optimized(uuid, boolean, integer, integer, text, text, text, text, timestamp with time zone, timestamp with time zone); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_currency_orders_optimized(p_current_profile_id uuid, p_for_delivery boolean DEFAULT false, p_limit integer DEFAULT 100, p_offset integer DEFAULT 0, p_search_query text DEFAULT NULL::text, p_status_filter text DEFAULT NULL::text, p_order_type_filter text DEFAULT NULL::text, p_game_code_filter text DEFAULT NULL::text, p_start_date timestamp with time zone DEFAULT NULL::timestamp with time zone, p_end_date timestamp with time zone DEFAULT NULL::timestamp with time zone) RETURNS TABLE(id uuid, order_number text, order_type text, status text, game_code text, server_attribute_code text, quantity numeric, cost_amount numeric, cost_currency_code text, sale_amount numeric, sale_currency_code text, profit_amount numeric, profit_currency_code text, foreign_currency_id uuid, foreign_currency_code text, foreign_amount numeric, profit_margin_percentage numeric, cost_to_sale_exchange_rate numeric, exchange_rate_date date, exchange_rate_source text, currency_attribute_id uuid, currency_attribute jsonb, channel_id uuid, channel jsonb, game_account_id uuid, game_account jsonb, party_id uuid, party jsonb, assigned_to uuid, assigned_employee jsonb, created_by uuid, created_by_profile jsonb, foreign_currency_attribute jsonb, created_at timestamp with time zone, updated_at timestamp with time zone, submitted_at timestamp with time zone, submitted_by uuid, assigned_at timestamp with time zone, preparation_at timestamp with time zone, ready_at timestamp with time zone, delivery_at timestamp with time zone, delivered_by uuid, completed_at timestamp with time zone, cancelled_at timestamp with time zone, priority_level integer, deadline_at timestamp with time zone, delivery_info text, notes text, proofs jsonb, inventory_pool_id uuid, exchange_type text, exchange_details jsonb)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_is_admin boolean := false;
    v_current_profile_id uuid := p_current_profile_id;
BEGIN
    -- SECURITY: Require valid profile ID
    IF v_current_profile_id IS NULL THEN
        RAISE EXCEPTION 'Authentication required: profile ID cannot be null';
    END IF;
    
    -- Check if user has admin/mod role using role codes
    SELECT EXISTS(
        SELECT 1 
        FROM user_role_assignments ura 
        JOIN roles r ON ura.role_id = r.id 
        WHERE ura.user_id = v_current_profile_id
        AND r.code IN ('admin', 'mod')
    ) INTO v_is_admin;
    
    -- Apply access control - ALWAYS enforce access rules with server-side filtering
    RETURN QUERY
    SELECT 
        co.id,
        co.order_number,
        co.order_type::text,
        co.status::text,
        co.game_code,
        co.server_attribute_code,
        co.quantity,
        co.cost_amount,
        co.cost_currency_code,
        co.sale_amount,
        co.sale_currency_code,
        co.profit_amount,
        co.profit_currency_code,
        co.foreign_currency_id,
        co.foreign_currency_code,
        co.foreign_amount,
        co.profit_margin_percentage,
        co.cost_to_sale_exchange_rate,
        co.exchange_rate_date,
        co.exchange_rate_source,
        co.currency_attribute_id,
        jsonb_build_object(
            'id', ca.id,
            'code', ca.code,
            'name', ca.name,
            'type', ca.type
        ) as currency_attribute,
        co.channel_id,
        jsonb_build_object(
            'id', ch.id,
            'code', ch.code,
            'name', ch.name
        ) as channel,
        co.game_account_id,
        jsonb_build_object(
            'id', ga.id,
            'account_name', ga.account_name,
            'game_code', ga.game_code,
            'purpose', ga.purpose
        ) as game_account,
        co.party_id,
        jsonb_build_object(
            'id', pt.id,
            'name', pt.name,
            'type', pt.type
        ) as party,
        co.assigned_to,
        jsonb_build_object(
            'id', p_assigned.id,
            'display_name', p_assigned.display_name
        ) as assigned_employee,
        co.created_by,
        jsonb_build_object(
            'id', p_creator.id,
            'display_name', p_creator.display_name
        ) as created_by_profile,
        jsonb_build_object(
            'id', fca.id,
            'code', fca.code,
            'name', fca.name,
            'type', fca.type
        ) as foreign_currency_attribute,
        co.created_at,
        co.updated_at,
        co.submitted_at,
        co.submitted_by,
        co.assigned_at,
        co.preparation_at,
        co.ready_at,
        co.delivery_at,
        co.delivered_by,
        co.completed_at,
        co.cancelled_at,
        co.priority_level,
        co.deadline_at,
        co.delivery_info,
        co.notes,
        co.proofs,
        co.inventory_pool_id,
        co.exchange_type::text,
        co.exchange_details
    FROM currency_orders co
    LEFT JOIN attributes ca ON co.currency_attribute_id = ca.id
    LEFT JOIN channels ch ON co.channel_id = ch.id
    LEFT JOIN game_accounts ga ON co.game_account_id = ga.id
    LEFT JOIN parties pt ON co.party_id = pt.id
    LEFT JOIN profiles p_assigned ON co.assigned_to = p_assigned.id
    LEFT JOIN profiles p_creator ON co.created_by = p_creator.id
    LEFT JOIN attributes fca ON co.foreign_currency_id = fca.id
    WHERE 
        -- Server-side search filter
        (
            p_search_query IS NULL 
            OR 
            (
                co.order_number ILIKE '%' || p_search_query || '%'
                OR co.notes ILIKE '%' || p_search_query || '%'
                OR ca.name ILIKE '%' || p_search_query || '%'
                OR ca.code ILIKE '%' || p_search_query || '%'
                OR ch.name ILIKE '%' || p_search_query || '%'
                OR p_creator.display_name ILIKE '%' || p_search_query || '%'
                OR ga.account_name ILIKE '%' || p_search_query || '%'
            )
        )
        -- Server-side status filter
        AND (p_status_filter IS NULL OR co.status::text = p_status_filter)
        -- Server-side order type filter
        AND (p_order_type_filter IS NULL OR co.order_type::text = p_order_type_filter)
        -- Server-side game code filter
        AND (p_game_code_filter IS NULL OR co.game_code = p_game_code_filter)
        -- NEW: Server-side date range filter
        AND (p_start_date IS NULL OR p_end_date IS NULL OR co.created_at BETWEEN p_start_date AND p_end_date)
        -- SECURITY: Always apply access control
        AND (
            v_is_admin 
            OR co.created_by = v_current_profile_id 
            OR co.assigned_to = v_current_profile_id
        )
        -- For delivery tab, filter specific statuses
        AND (
            NOT p_for_delivery
            OR co.status IN ('assigned', 'preparing', 'delivering', 'ready', 'delivered')
        )
    ORDER BY co.created_at DESC
    LIMIT p_limit OFFSET p_offset;
END;
$$;


--
-- Name: get_currency_sell_orders_v1(text, text, text, timestamp with time zone, timestamp with time zone, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_currency_sell_orders_v1(p_status text DEFAULT NULL::text, p_game_code text DEFAULT NULL::text, p_customer_name text DEFAULT NULL::text, p_date_from timestamp with time zone DEFAULT NULL::timestamp with time zone, p_date_to timestamp with time zone DEFAULT NULL::timestamp with time zone, p_limit integer DEFAULT 50, p_offset integer DEFAULT 0) RETURNS TABLE(order_id uuid, order_number text, order_type text, status text, customer_name text, customer_game_tag text, currency_name text, quantity numeric, unit_price_vnd numeric, total_price_vnd numeric, total_profit_vnd numeric, game_code text, league_name text, exchange_type text, created_at timestamp with time zone, assigned_at timestamp with time zone, completed_at timestamp with time zone, assigned_to_name text, channel_id uuid, priority_level integer, sla_status text, deadline_at timestamp with time zone)
    LANGUAGE sql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
    SELECT
        co.id,
        co.order_number,
        co.order_type::text,
        co.status::text,
        co.customer_name,
        co.customer_game_tag,
        curr.name as currency_name,
        co.quantity,
        co.unit_price_vnd,
        co.total_price_vnd,
        (co.total_price_vnd - COALESCE(co.total_cost_vnd, 0)) as total_profit_vnd,
        co.game_code,
        league.name as league_name,
        co.exchange_type::text,
        co.created_at,
        co.assigned_at,
        co.completed_at,
        p.display_name as assigned_to_name,
        co.channel_id,
        co.priority_level,
        co.sla_status,
        co.deadline_at
    FROM public.currency_orders co
    JOIN public.attributes curr ON co.currency_attribute_id = curr.id
    LEFT JOIN public.attributes league ON co.league_attribute_id = league.id
    LEFT JOIN public.profiles p ON co.assigned_to = p.id
    WHERE
        co.order_type = 'SALE'
        AND (p_status IS NULL OR co.status::text = p_status)
        AND (p_game_code IS NULL OR co.game_code = p_game_code)
        AND (p_customer_name IS NULL OR co.customer_name ILIKE '%' || p_customer_name || '%')
        AND (p_date_from IS NULL OR co.created_at >= p_date_from)
        AND (p_date_to IS NULL OR co.created_at <= p_date_to)
    ORDER BY co.created_at DESC
    LIMIT p_limit OFFSET p_offset;
$$;


--
-- Name: FUNCTION get_currency_sell_orders_v1(p_status text, p_game_code text, p_customer_name text, p_date_from timestamp with time zone, p_date_to timestamp with time zone, p_limit integer, p_offset integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.get_currency_sell_orders_v1(p_status text, p_game_code text, p_customer_name text, p_date_from timestamp with time zone, p_date_to timestamp with time zone, p_limit integer, p_offset integer) IS 'Query currency sell orders with filters and full details';


--
-- Name: get_current_profile_id(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_current_profile_id() RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_profile_id UUID;
BEGIN
    -- Get current user's profile ID - không cần public prefix vì đã có search_path = public
    SELECT id INTO v_profile_id
    FROM profiles
    WHERE auth_id = auth.uid()
      AND status = 'active';
    
    IF v_profile_id IS NULL THEN
        -- Create profile if doesn't exist
        INSERT INTO profiles (auth_id, display_name, status, created_at, updated_at)
        VALUES (auth.uid(), 'New User', 'active', NOW(), NOW())
        RETURNING id INTO v_profile_id;
    END IF;
    
    RETURN v_profile_id;
END;
$$;


--
-- Name: get_current_shift(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_current_shift() RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    current_shift UUID;
BEGIN
    SELECT id INTO current_shift
    FROM work_shifts
    WHERE is_active = true
    AND (
        (start_time <= end_time AND start_time <= CURRENT_TIME::time AND end_time >= CURRENT_TIME::time) OR
        (start_time > end_time AND (start_time <= CURRENT_TIME::time OR end_time >= CURRENT_TIME::time))
    )
    LIMIT 1;

    RETURN current_shift;
END;
$$;


--
-- Name: get_customer_accounts_by_game(uuid, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_customer_accounts_by_game(p_party_id uuid, p_game_code text DEFAULT NULL::text) RETURNS TABLE(id uuid, account_type text, label text, btag text, login_id text, game_code text, is_active boolean)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        ca.id,
        ca.account_type,
        ca.label,
        ca.btag,
        ca.login_id,
        ca.game_code,
        ca.is_active
    FROM public.customer_accounts ca
    WHERE ca.party_id = p_party_id
      AND ca.is_active = true
      AND (p_game_code IS NULL OR ca.game_code = p_game_code OR ca.game_code IS NULL)
    ORDER BY ca.created_at DESC;
END;
$$;


--
-- Name: get_customers_by_channel_v1(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_customers_by_channel_v1(p_channel_code text) RETURNS TABLE(name text)
    LANGUAGE sql STABLE
    SET search_path TO 'public'
    AS $$
  SELECT DISTINCT p.name
  FROM public.parties p
  JOIN public.orders o ON o.party_id = p.id
  JOIN public.channels c ON o.channel_id = c.id
  WHERE c.code = p_channel_code AND p.type = 'customer'
  ORDER BY p.name;
$$;


--
-- Name: get_delivery_summary(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_delivery_summary(p_order_id uuid) RETURNS TABLE(order_number text, status text, quantity numeric, cost_amount numeric, cost_currency_code text, sale_amount numeric, sale_currency_code text, profit_amount numeric, profit_currency_code text, profit_margin_percentage numeric, delivery_proofs jsonb, can_process_delivery boolean, delivery_status text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        co.order_number,
        co.status::TEXT,
        co.quantity,
        co.cost_amount,
        co.cost_currency_code,
        co.sale_amount,
        co.sale_currency_code,
        co.profit_amount,
        co.profit_currency_code,
        co.profit_margin_percentage,
        co.proofs,
        (co.order_type = 'SALE' AND co.status IN ('ready', 'delivering')) as can_process_delivery,
        CASE
            WHEN co.status = 'completed' THEN 'Delivered'
            WHEN co.status = 'delivering' THEN 'In Progress'
            WHEN co.status = 'ready' THEN 'Ready for Delivery'
            ELSE 'Not Ready'
        END as delivery_status
    FROM currency_orders co
    WHERE co.id = p_order_id
      AND co.order_type = 'SALE';
END;
$$;


--
-- Name: get_employee_fallback_for_game_code(text, time without time zone, uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_employee_fallback_for_game_code(p_game_code text, p_current_time time without time zone DEFAULT NULL::time without time zone, p_exclude_account_id uuid DEFAULT NULL::uuid) RETURNS TABLE(success boolean, employee_profile_id uuid, employee_name text, fallback_reason text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_current_local_time TIME := COALESCE(p_current_time, NOW()::TIME);
    v_current_shift_id UUID;
BEGIN
    -- Get current shift ID
    SELECT id INTO v_current_shift_id
    FROM work_shifts
    WHERE is_active = true
      AND (
        (start_time <= end_time AND start_time <= v_current_local_time AND end_time >= v_current_local_time)
        OR (start_time > end_time AND (v_current_local_time >= start_time OR v_current_local_time <= end_time))
      )
    LIMIT 1;
    
    IF v_current_shift_id IS NULL THEN
        RETURN QUERY
        SELECT false, NULL::UUID, 'No active shift found', NULL::TEXT;
        RETURN;
    END IF;
    
    -- Find any employee working with this game code
    RETURN QUERY
    SELECT 
        true as success,
        se.employee_profile_id,
        p.display_name as employee_name,
        format('Fallback: Found %s working with %s game (shift: %s)', 
               p.display_name, p_game_code, 
               (SELECT name FROM work_shifts WHERE id = v_current_shift_id)) as fallback_reason
    FROM shift_assignments se
    JOIN work_shifts sa ON se.shift_id = sa.id
    JOIN profiles p ON se.employee_profile_id = p.id
    JOIN game_accounts ga ON se.game_account_id = ga.id
    WHERE ga.game_code = p_game_code
      AND se.is_active = true
      AND sa.is_active = true
      AND sa.id = v_current_shift_id
      AND (p_exclude_account_id IS NULL OR se.game_account_id != p_exclude_account_id)
      AND p.status = 'active'
    ORDER BY 
        -- Prioritize employees with fewer active assignments (only check 'assigned' status)
        (
            SELECT COUNT(*) 
            FROM currency_orders co
            WHERE co.assigned_to = se.employee_profile_id
              AND co.status = 'assigned'
        ) ASC,
        -- Then by account name for consistency
        ga.account_name ASC
    LIMIT 1;
    
    -- If no employees found for this game code
    IF NOT FOUND THEN
        RETURN QUERY
        SELECT false, NULL::UUID, 
               format('No employees found working with %s game in current shift', p_game_code) as employee_name,
               NULL::TEXT;
    END IF;
    
    RETURN;
END;
$$;


--
-- Name: get_employee_for_account_in_shift(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_employee_for_account_in_shift(p_game_account_id uuid) RETURNS TABLE(success boolean, employee_profile_id uuid, employee_name text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_employee_profile_id UUID;
    v_employee_name TEXT;
    v_current_local_time TIME;
BEGIN
    -- Get current time in GMT+7 (database timezone already set to Asia/Ho_Chi_Minh)
    SELECT NOW()::TIME INTO v_current_local_time;

    -- Find employee assigned to this game account in current shift using PROPER TIME LOGIC
    -- Fix: Use OR condition to handle overnight shifts properly
    -- Example: Ca Đêm (20:00-08:00) should match any time >= 20:00 OR <= 08:00
    SELECT se.employee_profile_id, p.display_name
    INTO v_employee_profile_id, v_employee_name
    FROM shift_assignments se
    JOIN work_shifts sa ON se.shift_id = sa.id
    JOIN profiles p ON se.employee_profile_id = p.id
    WHERE se.game_account_id = p_game_account_id
      AND se.is_active = true
      AND sa.is_active = true
      AND (
        -- Normal time range (e.g., 08:00-17:00)
        (sa.start_time <= sa.end_time AND sa.start_time <= v_current_local_time AND sa.end_time >= v_current_local_time)
        OR
        -- Overnight/wrap-around range (e.g., 20:00-08:00)
        (sa.start_time > sa.end_time AND (v_current_local_time >= sa.start_time OR v_current_local_time <= sa.end_time))
      )
    LIMIT 1;

    -- Check if we found an employee
    IF v_employee_profile_id IS NOT NULL THEN
        RETURN QUERY
        SELECT true, v_employee_profile_id, v_employee_name;
    ELSE
        RETURN QUERY
        SELECT false, NULL::UUID, 'No employee assigned to this account in current shift';
    END IF;

    RETURN;
END;
$$;


--
-- Name: get_employee_for_account_shift(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_employee_for_account_shift() RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    employee_id uuid;
BEGIN
    SELECT a.employee_id INTO employee_id
    FROM account_shifts a
    WHERE a.game_account_id = p_game_account_id
      AND a.status = 'active'
      AND a.start_time <= NOW()
      AND (a.end_time IS NULL OR a.end_time > NOW())
    ORDER BY a.created_at DESC
    LIMIT 1;
    
    RETURN employee_id;
END;
$$;


--
-- Name: get_employee_for_game_in_shift_round_robin(text, uuid, uuid, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_employee_for_game_in_shift_round_robin(p_game_code text, p_shift_id uuid, p_channel_id uuid DEFAULT NULL::uuid, p_currency_code text DEFAULT NULL::text, p_server_code text DEFAULT NULL::text) RETURNS TABLE(employee_id uuid, employee_name text, game_account_id uuid, account_name text, server_code text, match_type text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_next_employee_id UUID;
    v_employee_name TEXT;
BEGIN
    -- Priority 1: game_code + currency_code + shift_id
    BEGIN
        SELECT p.id, p.display_name INTO v_next_employee_id, v_employee_name
        FROM profiles p
        JOIN shift_assignments sa ON sa.employee_profile_id = p.id
        WHERE sa.game_code = p_game_code 
          AND (sa.currency_code = COALESCE(p_currency_code, sa.currency_code) OR sa.currency_code IS NULL OR sa.currency_code = '')
          AND sa.shift_id = p_shift_id
          AND sa.is_active = true AND p.status = 'active'
        LIMIT 1;
        IF v_next_employee_id IS NOT NULL THEN
            RETURN QUERY SELECT v_next_employee_id, v_employee_name, NULL::UUID, NULL::TEXT, NULL::TEXT, 'game_currency_match'::TEXT;
            RETURN;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        NULL;
    END;

    -- Priority 2: game_code + channel + shift_id
    BEGIN
        SELECT p.id, p.display_name INTO v_next_employee_id, v_employee_name
        FROM profiles p
        JOIN shift_assignments sa ON sa.employee_profile_id = p.id
        WHERE sa.game_code = p_game_code AND sa.channels_id = p_channel_id 
          AND sa.shift_id = p_shift_id AND sa.is_active = true AND p.status = 'active'
        LIMIT 1;
        IF v_next_employee_id IS NOT NULL THEN
            RETURN QUERY SELECT v_next_employee_id, v_employee_name, NULL::UUID, NULL::TEXT, NULL::TEXT, 'game_channel_match'::TEXT;
            RETURN;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        NULL;
    END;

    -- Priority 3: game_code + shift_id (any channel, any currency)
    BEGIN
        SELECT p.id, p.display_name INTO v_next_employee_id, v_employee_name
        FROM profiles p
        JOIN shift_assignments sa ON sa.employee_profile_id = p.id
        WHERE sa.game_code = p_game_code AND sa.shift_id = p_shift_id 
          AND sa.is_active = true AND p.status = 'active'
        LIMIT 1;
        IF v_next_employee_id IS NOT NULL THEN
            RETURN QUERY SELECT v_next_employee_id, v_employee_name, NULL::UUID, NULL::TEXT, NULL::TEXT, 'game_only_match'::TEXT;
            RETURN;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        NULL;
    END;

    -- No employee found
    RETURN QUERY SELECT NULL::UUID, NULL::TEXT, NULL::UUID, NULL::TEXT, NULL::TEXT, 'no_available_employees'::TEXT;
END;
$$;


--
-- Name: get_exchange_rate_for_delivery(text, text, date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_exchange_rate_for_delivery(p_from_currency text, p_to_currency text, p_date date DEFAULT CURRENT_DATE) RETURNS numeric
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_rate NUMERIC;
    v_expiry_timestamp TIMESTAMP;
BEGIN
    -- Set expiry timestamp to end of the given date
    v_expiry_timestamp := p_date + INTERVAL '1 day' - INTERVAL '1 second';
    
    -- Get the most recent active exchange rate for the given currencies
    SELECT rate INTO v_rate
    FROM exchange_rates
    WHERE from_currency = p_from_currency
      AND to_currency = p_to_currency
      AND is_active = true
      AND DATE(effective_date) <= p_date
      AND (expires_at IS NULL OR expires_at > v_expiry_timestamp)
    ORDER BY effective_date DESC
    LIMIT 1;
    
    -- If no direct rate found, try reverse rate
    IF v_rate IS NULL THEN
        SELECT rate INTO v_rate
        FROM exchange_rates
        WHERE from_currency = p_to_currency
          AND to_currency = p_from_currency
          AND is_active = true
          AND DATE(effective_date) <= p_date
          AND (expires_at IS NULL OR expires_at > v_expiry_timestamp)
        ORDER BY effective_date DESC
        LIMIT 1;
        
        -- If reverse rate found, calculate its inverse
        IF v_rate IS NOT NULL AND v_rate != 0 THEN
            v_rate := 1 / v_rate;
        END IF;
    END IF;
    
    -- If still no rate found, raise exception
    IF v_rate IS NULL THEN
        RAISE EXCEPTION 'Exchange rate not found for % to % on %', p_from_currency, p_to_currency, p_date;
    END IF;
    
    RETURN v_rate;
END;
$$;


--
-- Name: get_game_currencies(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_game_currencies(p_game_code text) RETURNS TABLE(currency_attribute_id uuid, currency_code text, currency_name text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.id,
        a.code,
        a.name
    FROM attributes a
    WHERE a.type = 'GAME_CURRENCY'
      AND a.is_active = true
      AND (
        (p_game_code = 'DIABLO_4' AND a.code LIKE '%_D4')
        OR (p_game_code = 'POE_1' AND a.code LIKE '%_POE1')
        OR (p_game_code = 'POE_2' AND a.code LIKE '%_POE2')
        OR (p_game_code NOT IN ('DIABLO_4', 'POE_1', 'POE_2') AND a.code LIKE '%' || REPLACE(p_game_code, '_', '') || '%')
      )
    ORDER BY a.sort_order, a.name;
END;
$$;


--
-- Name: FUNCTION get_game_currencies(p_game_code text); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.get_game_currencies(p_game_code text) IS 'Get all available currencies for a specific game';


--
-- Name: get_game_servers(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_game_servers(p_game_code text) RETURNS TABLE(server_attribute_id uuid, server_code text, server_name text, display_name text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.id,
        a.code,
        a.name,
        a.name || ' (' || 
            CASE p_game_code
                WHEN 'POE_1' THEN 'Path of Exile 1'
                WHEN 'POE_2' THEN 'Path of Exile 2'
                WHEN 'DIABLO_4' THEN 'Diablo 4'
                ELSE p_game_code
            END || ')'
    FROM attributes a
    WHERE a.type = 'GAME_SERVER'
      AND a.is_active = true
      AND (
        (p_game_code = 'DIABLO_4' AND a.code LIKE '%_D4')
        OR (p_game_code = 'POE_1' AND a.code LIKE '%_POE1')
        OR (p_game_code = 'POE_2' AND a.code LIKE '%_POE2')
        OR (p_game_code NOT IN ('DIABLO_4', 'POE_1', 'POE_2') AND a.code LIKE '%' || REPLACE(p_game_code, '_', '') || '%')
      )
    ORDER BY a.sort_order, a.name;
END;
$$;


--
-- Name: FUNCTION get_game_servers(p_game_code text); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.get_game_servers(p_game_code text) IS 'Get all available game servers/leagues/seasons for a specific game';


--
-- Name: get_games_v1(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_games_v1() RETURNS TABLE(id uuid, code text, name text, currency_prefix text, has_leagues boolean, sort_order integer, is_active boolean)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.id,
        a.code,
        a.name,
        -- Extract currency prefix from game type
        CASE
            WHEN a.code = 'POE_1' THEN 'POE1'
            WHEN a.code = 'POE_2' THEN 'POE2'
            WHEN a.code = 'DIABLO_4' THEN 'D4'
            ELSE 'UNKNOWN'
        END as currency_prefix,
        -- Check if game has leagues/seasons
        CASE
            WHEN a.code IN ('POE_1', 'POE_2', 'DIABLO_4') THEN true
            ELSE false
        END as has_leagues,
        a.sort_order,
        a.is_active
    FROM public.attributes a
    WHERE a.type = 'GAME'
      AND a.is_active = true
    ORDER BY a.sort_order ASC, a.name ASC;
END;
$$;


--
-- Name: get_inventory_accounts(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_inventory_accounts(p_game_code text, p_server_attribute_code text DEFAULT NULL::text) RETURNS TABLE(id uuid, account_name text, purpose text, server_attribute_code text, is_active boolean)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ga.id,
        ga.account_name,
        ga.purpose,
        ga.server_attribute_code,
        ga.is_active
    FROM game_accounts ga
    WHERE 
        ga.game_code = p_game_code
        AND ga.purpose = 'INVENTORY'
        AND ga.is_active = true
        AND (
            -- Include server-specific accounts for this server
            ga.server_attribute_code = p_server_attribute_code
            OR 
            -- Include global accounts (NULL server_attribute_code)
            ga.server_attribute_code IS NULL
        )
    ORDER BY 
        -- Server-specific accounts first, then global accounts
        CASE 
            WHEN ga.server_attribute_code IS NULL THEN 2 
            ELSE 1 
        END,
        ga.account_name;
END;
$$;


--
-- Name: get_inventory_cost_in_usd(uuid, numeric, date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_inventory_cost_in_usd(p_inventory_pool_id uuid, p_quantity numeric, p_effective_date date DEFAULT CURRENT_DATE) RETURNS TABLE(success boolean, cost_amount numeric, cost_currency text, cost_usd numeric, exchange_rate numeric, message text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_pool RECORD;
    v_total_cost DECIMAL;
    v_usd_result RECORD;
BEGIN
    -- Get inventory pool details
    SELECT * INTO v_pool
    FROM inventory_pools
    WHERE id = p_inventory_pool_id;

    IF NOT FOUND THEN
        RETURN QUERY
        SELECT false, 0::DECIMAL, NULL::TEXT, 0::DECIMAL, 0::DECIMAL,
               'Inventory pool not found';
        RETURN;
    END IF;

    -- Calculate total cost in pool's currency
    v_total_cost := p_quantity * COALESCE(v_pool.average_cost, 0);

    -- Convert to USD
    SELECT * INTO v_usd_result
    FROM calculate_cost_in_usd(v_total_cost, v_pool.cost_currency, p_effective_date)
    LIMIT 1;

    IF NOT v_usd_result.success THEN
        RETURN QUERY
        SELECT false, v_total_cost, v_pool.cost_currency, 0::DECIMAL, 0::DECIMAL,
               v_usd_result.message;
        RETURN;
    END IF;

    -- Return successful result
    RETURN QUERY
    SELECT true,
           v_total_cost,
           v_pool.cost_currency,
           v_usd_result.cost_usd,
           v_usd_result.rate_used,
           format('Cost: %s %s = %s USD (rate: %s)',
                  v_total_cost, v_pool.cost_currency, v_usd_result.cost_usd, v_usd_result.rate_used);
    RETURN;
END;
$$;


--
-- Name: get_inventory_pool_with_account_first_rotation(text, text, uuid, numeric); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_inventory_pool_with_account_first_rotation(p_game_code text, p_server_attribute_code text, p_currency_attribute_id uuid, p_required_quantity numeric) RETURNS TABLE(success boolean, message text, inventory_pool_id uuid, game_account_id uuid, channel_id uuid, channel_name text, account_name text, average_cost numeric, cost_currency text, available_quantity numeric, match_reason text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
    -- Try to find pool with existing assignments first (account-first rotation)
    RETURN QUERY
    SELECT
        true as success,
        'Found inventory pool with existing assignments' as message,
        ip.id as inventory_pool_id,
        ip.game_account_id,
        ip.channel_id,
        c.name as channel_name,
        ga.account_name,
        ip.average_cost,
        ip.cost_currency,
        ip.quantity as available_quantity,  -- Only check actual quantity
        'Account-first rotation: Existing assignments' as match_reason
    FROM inventory_pools ip
    JOIN game_accounts ga ON ip.game_account_id = ga.id
    JOIN channels c ON ip.channel_id = c.id
    LEFT JOIN currency_orders co ON co.inventory_pool_id = ip.id AND co.status = 'assigned'
    WHERE ip.game_code = p_game_code
      AND COALESCE(ip.server_attribute_code, '') = COALESCE(p_server_attribute_code, '')
      AND ip.currency_attribute_id = p_currency_attribute_id
      AND ip.quantity >= p_required_quantity  -- Only check quantity, not reserved_quantity
      AND ip.average_cost > 0
    GROUP BY ip.id, ip.game_account_id, ip.channel_id, c.name, ga.account_name,
             ip.average_cost, ip.cost_currency, ip.quantity
    HAVING COUNT(co.id) > 0  -- Has existing assignments
    ORDER BY COUNT(co.id) DESC, ip.average_cost ASC
    LIMIT 1;

    -- If no pool with assignments found, try regular pool search
    IF NOT FOUND THEN
        RETURN QUERY
        SELECT
            true as success,
            'Found suitable inventory pool (no existing assignments)' as message,
            ip.id as inventory_pool_id,
            ip.game_account_id,
            ip.channel_id,
            c.name as channel_name,
            ga.account_name,
            ip.average_cost,
            ip.cost_currency,
            ip.quantity as available_quantity,  -- Only check actual quantity
            'Account-first rotation: New pool' as match_reason
        FROM inventory_pools ip
        JOIN game_accounts ga ON ip.game_account_id = ga.id
        JOIN channels c ON ip.channel_id = c.id
        WHERE ip.game_code = p_game_code
          AND COALESCE(ip.server_attribute_code, '') = COALESCE(p_server_attribute_code, '')
          AND ip.currency_attribute_id = p_currency_attribute_id
          AND ip.quantity >= p_required_quantity  -- Only check quantity, not reserved_quantity
          AND ip.average_cost > 0
        ORDER BY ip.average_cost ASC
        LIMIT 1;
    END IF;

    -- If still no pool found, return empty result
    IF NOT FOUND THEN
        RETURN QUERY
        SELECT false, 'No suitable inventory pool found', NULL::UUID, NULL::UUID, NULL::UUID,
               NULL::TEXT, NULL::TEXT, NULL::NUMERIC, NULL::TEXT, 0::NUMERIC, 'No match';
    END IF;
END;
$$;


--
-- Name: get_inventory_pool_with_currency_rotation(text, text, uuid, numeric); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_inventory_pool_with_currency_rotation(p_game_code text, p_server_attribute_code text, p_currency_attribute_id uuid, p_required_quantity numeric) RETURNS TABLE(success boolean, message text, inventory_pool_id uuid, game_account_id uuid, channel_id uuid, channel_name text, account_name text, average_cost numeric, cost_currency text, available_quantity numeric, match_reason text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        true as success,
        'Found suitable inventory pool' as message,
        ip.id as inventory_pool_id,
        ip.game_account_id,
        ip.channel_id,
        c.name as channel_name,
        ga.account_name,
        ip.average_cost,
        ip.cost_currency,
        ip.quantity as available_quantity,  -- Only check actual quantity
        'Currency-first rotation match' as match_reason
    FROM inventory_pools ip
    JOIN game_accounts ga ON ip.game_account_id = ga.id
    JOIN channels c ON ip.channel_id = c.id
    WHERE ip.game_code = p_game_code
      AND COALESCE(ip.server_attribute_code, '') = COALESCE(p_server_attribute_code, '')
      AND ip.currency_attribute_id = p_currency_attribute_id
      AND ip.quantity >= p_required_quantity  -- Only check quantity, not reserved_quantity
      AND ip.average_cost > 0
    ORDER BY ip.average_cost ASC
    LIMIT 1;

    -- If no pool found, return empty result
    IF NOT FOUND THEN
        RETURN QUERY
        SELECT false, 'No suitable inventory pool found', NULL::UUID, NULL::UUID, NULL::UUID,
               NULL::TEXT, NULL::TEXT, NULL::NUMERIC, NULL::TEXT, 0::NUMERIC, 'No match';
    END IF;
END;
$$;


--
-- Name: get_last_item_proof_v1(uuid[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_last_item_proof_v1(p_item_ids uuid[]) RETURNS TABLE(item_id uuid, last_start_proof_url text, last_end_proof_url text, last_end numeric, last_delta numeric, last_exp_percent numeric)
    LANGUAGE sql STABLE
    SET search_path TO 'public'
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


--
-- Name: get_latest_exchange_rate(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_latest_exchange_rate(p_from_currency text, p_to_currency text) RETURNS numeric
    LANGUAGE plpgsql
    SET search_path TO 'public, pg_temp'
    AS $$
DECLARE
  rate NUMERIC;
BEGIN
  SELECT r.rate INTO rate
  FROM exchange_rates r
  WHERE r.from_currency = p_from_currency
    AND r.to_currency = p_to_currency
    AND r.is_active = true
    AND r.effective_date <= NOW()
    AND (r.expires_at IS NULL OR r.expires_at > NOW())
  ORDER BY r.effective_date DESC
  LIMIT 1;
  
  RETURN rate;
END;
$$;


--
-- Name: get_my_assignments(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_my_assignments() RETURNS jsonb
    LANGUAGE sql STABLE
    SET search_path TO 'public, pg_temp'
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


--
-- Name: get_next_available_stock_trader(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_next_available_stock_trader() RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    trader_id uuid;
BEGIN
    SELECT e.id INTO trader_id
    FROM employees e
    JOIN employee_channels ec ON e.id = ec.employee_id
    WHERE ec.channel_id = p_channel_id
      AND e.status = 'active'
      AND e.is_available = true
      AND e.department = 'stock'
    ORDER BY e.last_assignment_at ASC NULLS FIRST
    LIMIT 1;
    
    RETURN trader_id;
END;
$$;


--
-- Name: get_next_available_stock_trader(uuid, date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_next_available_stock_trader(p_shift_id uuid, p_assigned_date date DEFAULT CURRENT_DATE) RETURNS TABLE(employee_profile_id uuid, channel_type text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_available_traders JSON[];
    v_current_index INTEGER;
    v_selected_trader JSON;
    v_counter_id UUID;
BEGIN
    -- Get all active stock traders for this shift (both facebook and wechat)
    SELECT array_agg(json_build_object(
        'employee_profile_id', ts.employee_profile_id,
        'channel_type', ts.channel_type,
        'priority', ts.priority
    ) ORDER BY ts.channel_type, ts.priority) INTO v_available_traders
    FROM trader_specializations ts
    JOIN employee_shift_assignments esa ON ts.employee_profile_id = esa.employee_profile_id
    WHERE ts.role_type = 'stock'
      AND esa.shift_id = p_shift_id
      AND esa.assigned_date = p_assigned_date
      AND esa.is_active = true
      AND ts.is_active = true
      ORDER BY 
        CASE WHEN ts.channel_type = 'facebook' THEN 1 ELSE 2 END,  -- Facebook first
        ts.priority;
    
    IF v_available_traders IS NULL OR array_length(v_available_traders, 1) = 0 THEN
        RETURN;
    END IF;
    
    -- Get current counter for stock traders (regardless of channel)
    SELECT id, current_index INTO v_counter_id, v_current_index
    FROM assignment_counters
    WHERE channel_type = 'stock_all' AND role_type = 'stock';
    
    IF v_counter_id IS NULL THEN
        -- Initialize counter for all stock traders
        INSERT INTO assignment_counters (channel_type, role_type, current_index)
        VALUES ('stock_all', 'stock', 0)
        RETURNING id INTO v_counter_id;
        v_current_index := 0;
    END IF;
    
    -- Select trader using round-robin across all stock traders
    v_selected_trader := v_available_traders[(v_current_index % array_length(v_available_traders, 1)) + 1];
    
    -- Update counter
    UPDATE assignment_counters
    SET current_index = (v_current_index + 1) % array_length(v_available_traders, 1),
        last_assigned_at = NOW(),
        updated_at = NOW()
    WHERE id = v_counter_id;
    
    -- Return the selected trader
    RETURN QUERY
    SELECT 
        (v_selected_trader->>'employee_profile_id')::UUID as employee_profile_id,
        v_selected_trader->>'channel_type' as channel_type;
END;
$$;


--
-- Name: get_next_available_trader(text, text, uuid, date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_next_available_trader(p_channel_type text, p_role_type text, p_shift_id uuid, p_assigned_date date DEFAULT CURRENT_DATE) RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_available_traders UUID[];
    v_current_index INTEGER;
    v_selected_trader UUID;
    v_counter_id UUID;
BEGIN
    -- Get all active traders for this channel/role/shift
    SELECT ARRAY_AGG(employee_profile_id) INTO v_available_traders
    FROM trader_specializations ts
    JOIN employee_shift_assignments esa ON ts.employee_profile_id = esa.employee_profile_id
    WHERE ts.channel_type = p_channel_type
      AND ts.role_type = p_role_type
      AND esa.shift_id = p_shift_id
      AND esa.assigned_date = p_assigned_date
      AND esa.is_active = true
      AND ts.is_active = true;
    
    IF v_available_traders IS NULL OR ARRAY_LENGTH(v_available_traders, 1) = 0 THEN
        RETURN NULL;
    END IF;
    
    -- Get current counter
    SELECT id, current_index INTO v_counter_id, v_current_index
    FROM assignment_counters
    WHERE channel_type = p_channel_type AND role_type = p_role_type;
    
    IF v_counter_id IS NULL THEN
        -- Initialize counter
        INSERT INTO assignment_counters (channel_type, role_type, current_index)
        VALUES (p_channel_type, p_role_type, 0)
        RETURNING id INTO v_counter_id;
        v_current_index := 0;
    END IF;
    
    -- Select trader using round-robin
    v_selected_trader := v_available_traders[(v_current_index % ARRAY_LENGTH(v_available_traders, 1)) + 1];
    
    -- Update counter
    UPDATE assignment_counters
    SET current_index = (v_current_index + 1) % ARRAY_LENGTH(v_available_traders, 1),
        last_assigned_at = NOW(),
        updated_at = NOW()
    WHERE id = v_counter_id;
    
    RETURN v_selected_trader;
END;
$$;


--
-- Name: get_next_employee_for_pool(uuid, uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_next_employee_for_pool(p_pool_id uuid, p_game_account_id uuid) RETURNS TABLE(employee_id uuid, employee_name text, pool_id uuid)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_selected_employee RECORD;
    -- FIXED: Removed timezone conversion - v_gmt7_time now uses NOW() directly
    v_gmt7_time TIMESTAMPTZ := NOW();  -- FIXED: No more double conversion!
    v_shift_id uuid;
BEGIN
    -- Find current shift based on GMT+7 time
    SELECT id INTO v_shift_id
    FROM work_shifts ws
    WHERE ws.is_active = true
      AND (
        -- Regular shift: current time between start and end
        (ws.start_time <= ws.end_time AND
         v_gmt7_time::time >= ws.start_time AND
         v_gmt7_time::time <= ws.end_time)
        OR
        -- Overnight shift: current time >= start OR current time <= end
        (ws.start_time > ws.end_time AND
         (v_gmt7_time::time >= ws.start_time OR
          v_gmt7_time::time <= ws.end_time))
      )
    LIMIT 1;

    -- Find employee assigned to this pool/account and shift
    SELECT
        sa.employee_profile_id as employee_id,
        p.display_name as employee_name,
        sa.id as pool_id
    INTO v_selected_employee
    FROM shift_assignments sa
    JOIN profiles p ON sa.employee_profile_id = p.id
    WHERE sa.game_account_id = p_game_account_id
      AND sa.channels_id = (SELECT channel_id FROM inventory_pools WHERE id = p_pool_id)
      AND sa.shift_id = v_shift_id
      AND sa.is_active = true
      AND p.status = 'active'
    ORDER BY
        -- Prefer employees with less load
        (SELECT COUNT(*) FROM currency_orders WHERE assigned_to = sa.employee_profile_id AND status NOT IN ('completed', 'cancelled')) ASC,
        p.display_name
    LIMIT 1;

    RETURN QUERY SELECT * FROM (SELECT v_selected_employee.employee_id, v_selected_employee.employee_name, v_selected_employee.pool_id AS t)
                          WHERE v_selected_employee.employee_id IS NOT NULL;
END;
$$;


--
-- Name: get_next_employee_round_robin(uuid, text, uuid, text, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_next_employee_round_robin(p_channel_id uuid, p_currency_code text, p_shift_id uuid, p_order_type_filter text DEFAULT 'PURCHASE'::text, p_game_code text DEFAULT NULL::text, p_server_attribute_code text DEFAULT NULL::text) RETURNS TABLE(employee_id uuid, employee_name text, tracker_id uuid, new_index integer, consecutive_assignments_count integer)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_group_key TEXT;
    v_tracker_id UUID;
    v_rotation_order JSON;
    v_current_index INTEGER;
    v_available_count INTEGER;
    v_next_index INTEGER;
    v_next_employee_id UUID;
    v_employee_name TEXT;
    v_employee_text TEXT;
    v_consecutive_count INTEGER;
    v_consecutive_threshold INTEGER;
BEGIN
    -- Create composite group key with new structure including game_code + server_code
    v_group_key := format('%s|%s|%s|%s|%s|%s', 
        p_channel_id, 
        p_currency_code, 
        COALESCE(p_game_code, 'ANY_GAME'), 
        COALESCE(p_server_attribute_code, 'ANY_SERVER'), 
        p_shift_id, 
        p_order_type_filter
    );
    
    -- Get or create tracker
    SELECT get_or_create_assignment_tracker(p_channel_id, p_currency_code, p_shift_id, p_order_type_filter, p_game_code, p_server_attribute_code) INTO v_tracker_id;
    
    -- Get current tracker state with burnout protection
    SELECT employee_rotation_order, current_rotation_index, available_count, max_consecutive_assignments
    INTO v_rotation_order, v_current_index, v_available_count, v_consecutive_threshold
    FROM assignment_trackers 
    WHERE id = v_tracker_id;
    
    -- Handle case with no available employees
    IF v_available_count = 0 OR v_rotation_order IS NULL THEN
        RETURN QUERY SELECT NULL::UUID, NULL::TEXT, v_tracker_id, 0, 0;
        RETURN;
    END IF;
    
    -- Calculate next index (round-robin) using proper PostgreSQL syntax
    v_next_index := (v_current_index + 1) % v_available_count;
    
    -- Extract employee ID as text first, then cast to UUID
    BEGIN
        SELECT (employee_rotation_order->>v_next_index) INTO v_employee_text
        FROM assignment_trackers 
        WHERE id = v_tracker_id;
        
        IF v_employee_text IS NOT NULL THEN
            v_next_employee_id := v_employee_text::uuid;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        v_next_employee_id := NULL;
    END;
    
    -- Get employee name
    IF v_next_employee_id IS NOT NULL THEN
        SELECT display_name INTO v_employee_name
        FROM profiles 
        WHERE id = v_next_employee_id;
    END IF;
    
    -- Calculate consecutive assignments (simplified - would need proper tracking in production)
    v_consecutive_count := CASE 
        WHEN v_next_index = 0 THEN 1  -- Reset to beginning
        ELSE (v_current_index + 1)
    END;
    
    -- Check for burnout threshold
    IF v_consecutive_count > v_consecutive_threshold THEN
        -- Reset to first employee to prevent burnout
        SELECT (employee_rotation_order->>0)::text INTO v_employee_text;
        v_next_employee_id := v_employee_text::uuid;
        
        SELECT display_name INTO v_employee_name
        FROM profiles 
        WHERE id = v_next_employee_id;
        
        v_next_index := 0;
        v_consecutive_count := 1;
    END IF;
    
    -- Update tracker with new position and metadata
    UPDATE assignment_trackers 
    SET current_rotation_index = v_next_index,
        last_assigned_employee_id = v_next_employee_id,
        last_assigned_at = NOW()
    WHERE id = v_tracker_id;
    
    -- Return result with enhanced information
    RETURN QUERY SELECT v_next_employee_id, v_employee_name, v_tracker_id, v_next_index, v_consecutive_count;
END;
$$;


--
-- Name: get_next_pool_round_robin(text, uuid, uuid, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_next_pool_round_robin(p_game_code text, p_currency_attribute_id uuid, p_channel_id uuid, p_server_attribute_code text DEFAULT NULL::text) RETURNS TABLE(pool_id uuid, game_account_id uuid, quantity numeric, average_cost numeric, cost_currency text, source_channel_id uuid, source_currency text, game_code text, server_attribute_code text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_pool_key text;
    v_tracker_id uuid;
    v_selected_pool RECORD;
BEGIN
    -- Build round-robin key for pools
    v_pool_key := format('%s|%s|%s|%s|SELL', 
        p_game_code, 
        COALESCE(p_server_attribute_code, 'ANY_SERVER'),
        p_currency_attribute_id::TEXT,
        p_channel_id::TEXT
    );
    
    -- Try to get existing tracker
    SELECT id INTO v_tracker_id
    FROM assignment_trackers 
    WHERE assignment_group_key = v_pool_key;
    
    -- If no tracker exists, create one and return first available pool
    IF v_tracker_id IS NULL THEN
        -- Get all available pools with sufficient quantity
        SELECT 
            ip.id as pool_id,
            ip.game_account_id,
            ip.quantity,
            ip.average_cost,
            ip.cost_currency,
            ip.channel_id as source_channel_id,
            ip.cost_currency as source_currency,
            ip.game_code,
            ip.server_attribute_code
        INTO v_selected_pool
        FROM inventory_pools ip
        WHERE ip.game_code = p_game_code
          AND (ip.server_attribute_code = p_server_attribute_code OR 
               (p_server_attribute_code IS NULL AND ip.server_attribute_code IS NULL))
          AND ip.currency_attribute_id = p_currency_attribute_id
          AND ip.quantity > 0
        ORDER BY ip.last_updated_at ASC
        LIMIT 1;
        
        IF v_selected_pool.pool_id IS NOT NULL THEN
            -- Create new tracker
            INSERT INTO assignment_trackers (
                assignment_group_key,
                last_assigned_pool_id,
                last_assigned_at,
                created_at
            ) VALUES (
                v_pool_key,
                v_selected_pool.pool_id,
                NOW(),
                NOW()
            ) RETURNING id INTO v_tracker_id;
        END IF;
    ELSE
        -- Get all available pools except the last assigned one
        SELECT 
            ip.id as pool_id,
            ip.game_account_id,
            ip.quantity,
            ip.average_cost,
            ip.cost_currency,
            ip.channel_id as source_channel_id,
            ip.cost_currency as source_currency,
            ip.game_code,
            ip.server_attribute_code
        INTO v_selected_pool
        FROM inventory_pools ip
        WHERE ip.game_code = p_game_code
          AND (ip.server_attribute_code = p_server_attribute_code OR 
               (p_server_attribute_code IS NULL AND ip.server_attribute_code IS NULL))
          AND ip.currency_attribute_id = p_currency_attribute_id
          AND ip.quantity > 0
          AND ip.id != (SELECT last_assigned_pool_id FROM assignment_trackers WHERE id = v_tracker_id)
        ORDER BY ip.last_updated_at ASC
        LIMIT 1;
        
        -- If no other pools available, reset to the first one (cycle)
        IF v_selected_pool.pool_id IS NULL THEN
            SELECT 
                ip.id as pool_id,
                ip.game_account_id,
                ip.quantity,
                ip.average_cost,
                ip.cost_currency,
                ip.channel_id as source_channel_id,
                ip.cost_currency as source_currency,
                ip.game_code,
                ip.server_attribute_code
            INTO v_selected_pool
            FROM inventory_pools ip
            WHERE ip.game_code = p_game_code
              AND (ip.server_attribute_code = p_server_attribute_code OR 
                   (p_server_attribute_code IS NULL AND ip.server_attribute_code IS NULL))
              AND ip.currency_attribute_id = p_currency_attribute_id
              AND ip.quantity > 0
            ORDER BY ip.last_updated_at ASC
            LIMIT 1;
            
            -- Update tracker to the first pool
            UPDATE assignment_trackers
            SET 
                last_assigned_pool_id = v_selected_pool.pool_id,
                last_assigned_at = NOW()
            WHERE id = v_tracker_id;
        ELSE
            -- Update tracker to the new pool
            UPDATE assignment_trackers
            SET 
                last_assigned_pool_id = v_selected_pool.pool_id,
                last_assigned_at = NOW()
            WHERE id = v_tracker_id;
        END IF;
    END IF;
    
    -- Return the selected pool
    RETURN QUERY SELECT * FROM (SELECT v_selected_pool.pool_id, v_selected_pool.game_account_id, v_selected_pool.quantity, 
                              v_selected_pool.average_cost, v_selected_pool.cost_currency, 
                              v_selected_pool.source_channel_id, v_selected_pool.source_currency,
                              v_selected_pool.game_code, v_selected_pool.server_attribute_code) AS t 
                          WHERE v_selected_pool.pool_id IS NOT NULL;
END;
$$;


--
-- Name: get_or_create_assignment_tracker(uuid, text, uuid, text, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_or_create_assignment_tracker(p_channel_id uuid, p_currency_code text, p_shift_id uuid, p_order_type_filter text, p_game_code text DEFAULT NULL::text, p_server_attribute_code text DEFAULT NULL::text) RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_group_key TEXT;
    v_tracker_id UUID;
    v_available_employees JSON;
    v_employee_ids JSON;
BEGIN
    -- Create composite group key with proper delimiter (|) to avoid _ conflicts
    -- Format: channel_id|currency_code|game_code|server_code|shift_id|order_type_filter
    v_group_key := format('%s|%s|%s|%s|%s|%s', 
        p_channel_id, 
        p_currency_code, 
        COALESCE(p_game_code, 'ANY_GAME'), 
        COALESCE(p_server_attribute_code, 'ANY_SERVER'), 
        p_shift_id, 
        p_order_type_filter
    );

    -- Try to get existing tracker
    SELECT id INTO v_tracker_id
    FROM assignment_trackers 
    WHERE assignment_group_key = v_group_key;

    -- If not found, create new tracker
    IF v_tracker_id IS NULL THEN
        -- Get all available employees for this specific combination
        -- IMPORTANT: Include both global accounts (server_code = NULL) and specific accounts
        WITH available_employees AS (
            SELECT 
                sa.employee_profile_id, 
                p.display_name as employee_name,
                sa.game_account_id,
                ga.account_name,
                ga.server_attribute_code
            FROM shift_assignments sa
            JOIN profiles p ON sa.employee_profile_id = p.id
            JOIN game_accounts ga ON sa.game_account_id = ga.id
            WHERE sa.channels_id = p_channel_id
              AND sa.currency_code = p_currency_code
              AND sa.shift_id = p_shift_id
              AND sa.is_active = true
              AND p.status = 'active'
              AND ga.is_active = true
              -- Filter by game code if provided
              AND (p_game_code IS NULL OR ga.game_code = p_game_code)
              -- CRITICAL: Include both global accounts (NULL) AND specific accounts matching the server
              AND (p_server_attribute_code IS NULL OR ga.server_attribute_code = p_server_attribute_code OR ga.server_attribute_code IS NULL)
            ORDER BY p.display_name, 
                     -- Order global accounts first, then specific server accounts
                     CASE WHEN ga.server_attribute_code IS NULL THEN 0 ELSE 1 END,
                     ga.account_name
        )
        SELECT json_agg(json_build_object(
            'employee_id', employee_profile_id, 
            'employee_name', employee_name,
            'game_account_id', game_account_id,
            'account_name', account_name,
            'server_code', server_attribute_code,
            'is_global', CASE WHEN server_attribute_code IS NULL THEN true ELSE false END,
            'joined_at', NOW()
        ))
        INTO v_available_employees
        FROM available_employees;
        
        -- Extract employee IDs as JSON array for rotation order
        IF v_available_employees IS NOT NULL THEN
            SELECT json_agg((elem->>'employee_id')::text)
            INTO v_employee_ids
            FROM json_array_elements(v_available_employees) elem;
        END IF;

        -- Create new tracker with enhanced metadata
        INSERT INTO assignment_trackers (
            assignment_type,
            assignment_group_key,
            last_assigned_employee_id,
            employee_rotation_order,
            current_rotation_index,
            available_count,
            order_type_filter,
            business_domain,
            priority_ordering,
            max_consecutive_assignments,
            reset_frequency_hours,
            last_reset_at,
            description,
            created_at
        ) VALUES (
            'round_robin_employee_rotation',
            v_group_key,
            COALESCE((SELECT (elem->>'employee_id')::uuid 
                     FROM json_array_elements(v_available_employees) elem 
                     LIMIT 1), '00000000-0000-0000-0000-000000000000'::uuid),
            COALESCE(v_employee_ids, '[]'::json),
            0,
            COALESCE(json_array_length(v_available_employees), 0),
            p_order_type_filter,
            'CURRENCY_TRADING',
            'GLOBAL_FIRST', -- Global accounts prioritized
            10,
            24,
            NOW(),
            format('Round-robin rotation for %s orders - %s channel, Currency: %s, Game: %s, Server: %s, Shift: %s', 
                   p_order_type_filter,
                   (SELECT code FROM channels WHERE id = p_channel_id),
                   p_currency_code,
                   COALESCE(p_game_code, 'ANY_GAME'),
                   COALESCE(p_server_attribute_code, 'ANY_SERVER'),
                   (SELECT name FROM work_shifts WHERE id = p_shift_id)),
            NOW()
        )
        RETURNING id INTO v_tracker_id;
    END IF;

    RETURN v_tracker_id;
EXCEPTION WHEN OTHERS THEN
    RAISE EXCEPTION 'Error in get_or_create_assignment_tracker: %', SQLERRM;
END;
$$;


--
-- Name: get_party_by_name_type(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_party_by_name_type(p_name text, p_type text) RETURNS TABLE(party_id uuid, name text, type text, contact_info jsonb, notes text, channel_id uuid, game_code text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id,
        p.name,
        p.type,
        p.contact_info,
        p.notes,
        p.channel_id,
        p.game_code
    FROM parties p
    WHERE p.name = p_name 
      AND p.type = p_type
    LIMIT 1;
END;
$$;


--
-- Name: get_party_role_from_order_type(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_party_role_from_order_type(p_order_type text) RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
    -- Return party role based on order type
    CASE p_order_type
        WHEN 'PURCHASE' THEN
            RETURN 'BUYER';
        WHEN 'SALE' THEN
            RETURN 'SUPPLIER';
        ELSE
            RETURN NULL;
    END CASE;
END;
$$;


--
-- Name: get_process_fee_mappings_direct(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_process_fee_mappings_direct(p_process_id uuid) RETURNS TABLE(fee_id uuid, fee_name text, fee_direction text, fee_amount numeric, fee_currency text, created_at timestamp with time zone)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
  RETURN QUERY
  SELECT
    pfm.fee_id,
    COALESCE(f.name::text, 'Unknown'::text) as fee_name,
    COALESCE(f.direction::text, 'Unknown'::text) as fee_direction,
    f.amount,
    COALESCE(f.currency::text, 'Unknown'::text) as fee_currency,
    pfm.created_at
  FROM process_fees_map pfm
  LEFT JOIN fees f ON pfm.fee_id = f.id
  WHERE pfm.process_id = p_process_id
  ORDER BY pfm.created_at ASC;
END;
$$;


--
-- Name: get_proofs_by_stage(jsonb, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_proofs_by_stage(order_proofs jsonb, stage text, order_type text DEFAULT NULL::text) RETURNS jsonb
    LANGUAGE plpgsql IMMUTABLE
    SET search_path TO 'public, pg_temp'
    AS $$
BEGIN
    -- Extract proofs for specific stage and optional order type
    IF order_type IS NOT NULL THEN
        RETURN order_proofs->stage->order_type;
    ELSE
        -- Return all proofs for the stage (across all order types)
        RETURN order_proofs->stage;
    END IF;
END;
$$;


--
-- Name: get_reviews_for_order_line_v1(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_reviews_for_order_line_v1(p_line_id uuid) RETURNS jsonb
    LANGUAGE sql SECURITY DEFINER
    SET search_path TO 'public'
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


--
-- Name: get_service_boosting_table_stats(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_service_boosting_table_stats() RETURNS TABLE(table_name text, row_count bigint, table_size text, index_size text, dead_row_ratio numeric)
    LANGUAGE sql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
    SELECT
        schemaname || '.' || relname as table_name,
        n_tup_ins as row_count,
        pg_size_pretty(pg_total_relation_size(schemaname || '.' || relname)) as table_size,
        pg_size_pretty(pg_indexes_size(schemaname || '.' || relname)) as index_size,
        ROUND((n_dead_tup::NUMERIC / NULLIF(n_live_tup, 0)) * 100, 2) as dead_row_ratio
    FROM pg_stat_user_tables
    WHERE relname IN ('orders', 'order_lines', 'work_sessions', 'parties', 'customer_accounts', 'product_variants', 'order_service_items', 'service_reports')
    ORDER BY n_tup_ins DESC;
$$;


--
-- Name: get_service_reports_v1(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_service_reports_v1(p_status text DEFAULT 'new'::text) RETURNS TABLE(report_id uuid, reported_at timestamp with time zone, report_status text, report_description text, report_proof_urls text[], reporter_name text, order_line_id uuid, customer_name text, channel_code text, service_type text, deadline timestamp with time zone, package_note text, btag text, login_id text, login_pwd text, reported_item jsonb)
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
  SELECT sr.id, sr.created_at, sr.status, sr.description, sr.current_proof_urls, reporter.display_name, ol.id, p.name, ch.code, (SELECT a.name FROM public.product_variant_attributes pva JOIN public.attributes a ON pva.attribute_id = a.id WHERE pva.variant_id = ol.variant_id AND a.type = 'SERVICE_TYPE' LIMIT 1), ol.deadline_to, o.package_note, ca.btag, ca.login_id, ca.login_pwd, jsonb_build_object('id', osi.id, 'kind_code', a.code, 'params', osi.params, 'plan_qty', osi.plan_qty, 'done_qty', osi.done_qty)
  FROM public.service_reports sr JOIN public.profiles reporter ON sr.reported_by = reporter.id JOIN public.order_lines ol ON sr.order_line_id = ol.id JOIN public.orders o ON ol.order_id = o.id JOIN public.parties p ON o.party_id = p.id LEFT JOIN public.channels ch ON o.channel_id = ch.id LEFT JOIN public.customer_accounts ca ON ol.customer_account_id = ca.id JOIN public.order_service_items osi ON sr.order_service_item_id = osi.id JOIN public.attributes a ON osi.service_kind_id = a.id
  WHERE has_permission('reports:view') AND sr.status = p_status ORDER BY sr.created_at ASC;
$$;


--
-- Name: get_session_history_v2(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_session_history_v2(p_line_id uuid) RETURNS jsonb
    LANGUAGE sql SECURITY DEFINER
    SET search_path TO 'public'
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


--
-- Name: get_shift_assignments_with_details(date, uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_shift_assignments_with_details(p_date date DEFAULT CURRENT_DATE, p_shift_id uuid DEFAULT NULL::uuid) RETURNS TABLE(assignment_id uuid, employee_profile_id uuid, employee_name text, shift_id uuid, shift_name text, assigned_date date, is_active boolean, assigned_at timestamp with time zone)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        esa.id,
        esa.employee_profile_id,
        p.display_name,
        esa.shift_id,
        ws.name,
        esa.assigned_date,
        esa.is_active,
        esa.assigned_at
    FROM employee_shift_assignments esa
    JOIN profiles p ON esa.employee_profile_id = p.id
    JOIN work_shifts ws ON esa.shift_id = ws.id
    WHERE esa.assigned_date = p_date
      AND (p_shift_id IS NULL OR esa.shift_id = p_shift_id)
    ORDER BY ws.name, p.display_name;
END;
$$;


--
-- Name: get_user_auth_context_v1(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_user_auth_context_v1() RETURNS json
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'public'
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


--
-- Name: get_user_emails(uuid[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_user_emails(user_ids uuid[]) RETURNS TABLE(user_id uuid, email text, last_sign_in_at timestamp with time zone)
    LANGUAGE sql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
  SELECT
    id as user_id,
    email,
    last_sign_in_at
  FROM auth.users
  WHERE id = ANY(user_ids)
  ORDER BY email;
$$;


--
-- Name: FUNCTION get_user_emails(user_ids uuid[]); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.get_user_emails(user_ids uuid[]) IS 'Retrieves user emails and last_sign_in_at from auth.users for given user IDs';


--
-- Name: get_user_profile_id(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_user_profile_id() RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_profile_id UUID;
BEGIN
    -- Get profile ID from auth UID for RLS policies
    SELECT id INTO v_profile_id
    FROM profiles
    WHERE auth_id = auth.uid()
      AND status = 'active';
    
    RETURN v_profile_id;
END;
$$;


--
-- Name: get_user_role_assignments(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_user_role_assignments(p_user_id uuid) RETURNS TABLE(assignment_id uuid, role_name text, game_attribute_name text, business_area_attribute_name text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
  RETURN QUERY
  SELECT
    ura.id as assignment_id,
    r.name as role_name,
    g.name as game_attribute_name,
    ba.name as business_area_attribute_name
  FROM user_role_assignments ura
  JOIN roles r ON ura.role_id = r.id
  LEFT JOIN attributes g ON ura.game_attribute_id = g.id
  LEFT JOIN attributes ba ON ura.business_area_attribute_id = ba.id
  WHERE ura.user_id = p_user_id
  ORDER BY r.name, g.name, ba.name;
END;
$$;


--
-- Name: get_user_role_assignments_with_roles(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_user_role_assignments_with_roles() RETURNS TABLE(id uuid, user_id uuid, role_id uuid, role_name text, game_name text, business_area_name text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
  RETURN QUERY
  SELECT
    ura.id,
    ura.user_id,
    ura.role_id,
    r.name as role_name,
    g.name as game_name,
    ba.name as business_area_name
  FROM public.user_role_assignments ura
  JOIN public.roles r ON ura.role_id = r.id
  LEFT JOIN public.attributes g ON ura.game_attribute_id = g.id
  LEFT JOIN public.attributes ba ON ura.business_area_attribute_id = ba.id
  ORDER BY ura.user_id, r.name;
END;
$$;


--
-- Name: handle_channels_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.handle_channels_updated_at() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


--
-- Name: handle_currencies_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.handle_currencies_updated_at() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
    NEW.updated_at = NOW();
    NEW.updated_by = auth.uid();
    RETURN NEW;
END;
$$;


--
-- Name: handle_fee_chain_items_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.handle_fee_chain_items_updated_at() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
    NEW.updated_at = NOW();
    NEW.updated_by = auth.uid();
    RETURN NEW;
END;
$$;


--
-- Name: handle_fee_chains_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.handle_fee_chains_updated_at() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
    NEW.updated_at = NOW();
    NEW.updated_by = auth.uid();
    RETURN NEW;
END;
$$;


--
-- Name: handle_fee_types_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.handle_fee_types_updated_at() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
    NEW.updated_at = NOW();
    NEW.updated_by = auth.uid();
    RETURN NEW;
END;
$$;


--
-- Name: handle_game_account_status_change(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.handle_game_account_status_change() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
    IF TG_OP = 'UPDATE' AND OLD.status != NEW.status THEN
        IF NEW.status = 'unavailable' THEN
            UPDATE public.inventory_pools
            SET is_available = false
            WHERE game_account_id = NEW.id;
        ELSIF NEW.status = 'available' THEN
            UPDATE public.inventory_pools
            SET is_available = true
            WHERE game_account_id = NEW.id;
        END IF;
    END IF;
    RETURN NEW;
END;
$$;


--
-- Name: handle_game_account_status_change_for_pools(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.handle_game_account_status_change_for_pools() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
    IF TG_OP = 'UPDATE' AND OLD.status != NEW.status THEN
        IF NEW.status = 'unavailable' THEN
            UPDATE public.inventory_pools
            SET is_available = false
            WHERE game_account_id = NEW.id;
        ELSIF NEW.status = 'available' THEN
            UPDATE public.inventory_pools
            SET is_available = true
            WHERE game_account_id = NEW.id;
        END IF;
    END IF;
    RETURN NEW;
END;
$$;


--
-- Name: handle_game_account_status_change_for_pools(uuid, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.handle_game_account_status_change_for_pools(p_game_account_id uuid, p_new_status text) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
    -- If game account is being deactivated, reserve all inventory pools
    IF p_new_status = 'inactive' THEN
        UPDATE public.inventory_pools 
        SET available = false, 
            reserved_quantity = quantity,
            last_updated_at = NOW()
        WHERE game_account_id = p_game_account_id;
        
    -- If game account is being activated, make pools available again
    ELSIF p_new_status = 'active' THEN
        UPDATE public.inventory_pools 
        SET available = true,
            reserved_quantity = 0,
            last_updated_at = NOW()
        WHERE game_account_id = p_game_account_id
        AND quantity > 0;
    END IF;
    
    RETURN TRUE;
END;
$$;


--
-- Name: handle_new_user_with_trial_role(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.handle_new_user_with_trial_role() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
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


--
-- Name: handle_orders_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.handle_orders_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'public'
    AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;


--
-- Name: has_permission(text, jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.has_permission(p_permission_code text, p_context jsonb DEFAULT '{}'::jsonb) RETURNS boolean
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'public'
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


--
-- Name: initialize_account_channel_rotation_tracker(text, text, uuid, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.initialize_account_channel_rotation_tracker(p_channel_tracker_key text, p_game_code text, p_currency_attribute_id uuid, p_account_name text, p_cost_currency text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_channels TEXT[];
    v_tracker_exists BOOLEAN;
BEGIN
    -- Check if tracker already exists
    SELECT EXISTS(
        SELECT 1 FROM assignment_trackers
        WHERE assignment_type = 'inventory_pool_rotation'
          AND assignment_group_key = p_channel_tracker_key
    ) INTO v_tracker_exists;

    -- Return early if tracker exists
    IF v_tracker_exists THEN
        RETURN;
    END IF;

    -- Get all channels for this specific account+currency combination
    SELECT array_agg(DISTINCT ch.name ORDER BY ch.name)
    INTO v_channels
    FROM inventory_pools ip
    JOIN game_accounts ga ON ip.game_account_id = ga.id
    JOIN channels ch ON ip.channel_id = ch.id
    WHERE ip.game_code = p_game_code
      AND ip.currency_attribute_id = p_currency_attribute_id
      AND ip.cost_currency = p_cost_currency
      AND ga.account_name = p_account_name
      AND ga.is_active = true
      AND ch.is_active = true
      AND (ip.quantity - COALESCE(ip.reserved_quantity, 0)) > 0;

    -- Create channel rotation tracker for this account+currency
    IF v_channels IS NOT NULL AND array_length(v_channels, 1) > 0 THEN
        INSERT INTO assignment_trackers (
            assignment_type,
            assignment_group_key,
            employee_rotation_order,
            current_rotation_index,
            order_type_filter,
            business_domain,
            description
        ) VALUES (
            'inventory_pool_rotation',
            p_channel_tracker_key,
            to_jsonb(v_channels),  -- Use to_jsonb instead of jsonb_build_array
            0,
            'SELL',
            'CURRENCY_TRADING',
            format('Account %s + %s channel rotation for %s', p_account_name, p_cost_currency, p_game_code)
        );
    END IF;
END;
$$;


--
-- Name: initialize_account_currency_rotation_tracker(text, text, uuid, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.initialize_account_currency_rotation_tracker(p_currency_tracker_key text, p_game_code text, p_currency_attribute_id uuid, p_account_name text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_cost_currencies TEXT[];
    v_tracker_exists BOOLEAN;
BEGIN
    -- Check if tracker already exists
    SELECT EXISTS(
        SELECT 1 FROM assignment_trackers
        WHERE assignment_type = 'inventory_pool_rotation'
          AND assignment_group_key = p_currency_tracker_key
    ) INTO v_tracker_exists;

    -- Return early if tracker exists
    IF v_tracker_exists THEN
        RETURN;
    END IF;

    -- Get all cost currencies for this specific account
    SELECT array_agg(DISTINCT ip.cost_currency ORDER BY ip.cost_currency)
    INTO v_cost_currencies
    FROM inventory_pools ip
    JOIN game_accounts ga ON ip.game_account_id = ga.id
    WHERE ip.game_code = p_game_code
      AND ip.currency_attribute_id = p_currency_attribute_id
      AND ga.account_name = p_account_name
      AND ga.is_active = true
      AND (ip.quantity - COALESCE(ip.reserved_quantity, 0)) > 0;

    -- Create currency rotation tracker for this account
    IF v_cost_currencies IS NOT NULL AND array_length(v_cost_currencies, 1) > 0 THEN
        INSERT INTO assignment_trackers (
            assignment_type,
            assignment_group_key,
            employee_rotation_order,
            current_rotation_index,
            order_type_filter,
            business_domain,
            description
        ) VALUES (
            'inventory_pool_rotation',
            p_currency_tracker_key,
            to_jsonb(v_cost_currencies),  -- Use to_jsonb instead of jsonb_build_array
            0,
            'SELL',
            'CURRENCY_TRADING',
            format('Account %s currency rotation for %s', p_account_name, p_game_code)
        );
    END IF;
END;
$$;


--
-- Name: initialize_account_first_rotation_tracker(text, text, uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.initialize_account_first_rotation_tracker(p_base_key text, p_game_code text, p_currency_attribute_id uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_accounts TEXT[];
    v_account_tracker_key TEXT;
    v_tracker_exists BOOLEAN;
BEGIN
    v_account_tracker_key := p_base_key || '_ACCOUNT_GLOBAL';

    -- Check if tracker already exists
    SELECT EXISTS(
        SELECT 1 FROM assignment_trackers
        WHERE assignment_type = 'inventory_pool_rotation'
          AND assignment_group_key = v_account_tracker_key
    ) INTO v_tracker_exists;

    -- Return early if tracker exists
    IF v_tracker_exists THEN
        RETURN;
    END IF;

    -- Get all active accounts for this game+currency
    SELECT array_agg(DISTINCT ga.account_name ORDER BY ga.account_name)
    INTO v_accounts
    FROM inventory_pools ip
    JOIN game_accounts ga ON ip.game_account_id = ga.id
    WHERE ip.game_code = p_game_code
      AND ip.currency_attribute_id = p_currency_attribute_id
      AND ga.is_active = true
      AND (ip.quantity - COALESCE(ip.reserved_quantity, 0)) > 0;

    -- Create account rotation tracker
    IF v_accounts IS NOT NULL AND array_length(v_accounts, 1) > 0 THEN
        INSERT INTO assignment_trackers (
            assignment_type,
            assignment_group_key,
            employee_rotation_order,
            current_rotation_index,
            order_type_filter,
            business_domain,
            description
        ) VALUES (
            'inventory_pool_rotation',
            v_account_tracker_key,
            to_jsonb(v_accounts),  -- Use to_jsonb instead of jsonb_build_array
            0,
            'SELL',
            'CURRENCY_TRADING',
            format('Account-first rotation for %s - %s', p_game_code, p_base_key)
        );
    END IF;
END;
$$;


--
-- Name: insert_process_fee_mappings_direct(uuid, uuid[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.insert_process_fee_mappings_direct(p_process_id uuid, p_fee_ids uuid[]) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
  v_count INTEGER;
  v_fee_id UUID;
BEGIN
  v_count := 0;
  
  -- Insert each fee mapping
  FOREACH v_fee_id IN ARRAY p_fee_ids
  LOOP
    INSERT INTO process_fees_map (process_id, fee_id)
    VALUES (p_process_id, v_fee_id);
    v_count := v_count + 1;
  END LOOP;
  
  RETURN jsonb_build_object(
    'success', true,
    'message', 'Thêm ' || v_count || ' mapping phí thành công',
    'inserted_count', v_count
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Lỗi khi thêm mapping phí: ' || SQLERRM
    );
END;
$$;


--
-- Name: log_profile_status_change(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.log_profile_status_change() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
    IF TG_OP = 'UPDATE' AND OLD.status != NEW.status THEN
        INSERT INTO public.profile_status_logs (
            profile_id,
            old_status,
            new_status,
            changed_by,
            created_at
        ) VALUES (
            NEW.id,
            OLD.status,
            NEW.status,
            auth.uid(),
            NOW()
        );
    END IF;
    RETURN NEW;
END;
$$;


--
-- Name: FUNCTION log_profile_status_change(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.log_profile_status_change() IS 'Logs profile status changes with safe auth mapping';


--
-- Name: manually_assign_order(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.manually_assign_order() RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
    -- Create assignment record
    INSERT INTO order_assignments (
        order_id,
        employee_id,
        order_type,
        assigned_at
    ) VALUES (
        p_order_id,
        p_employee_id,
        p_order_type,
        NOW()
    );
    
    -- Update employee last assignment time
    UPDATE employees
    SET last_assignment_at = NOW()
    WHERE id = p_employee_id;
    
    RETURN true;
END;
$$;


--
-- Name: manually_assign_order(uuid, boolean); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.manually_assign_order(p_order_id uuid, p_force_reassign boolean DEFAULT false) RETURNS TABLE(success boolean, message text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_order RECORD;
    v_channel_type TEXT;
    v_success BOOLEAN;
BEGIN
    -- Get order details
    SELECT * INTO v_order
    FROM currency_orders
    WHERE id = p_order_id;
    
    IF v_order.id IS NULL THEN
        RETURN QUERY
        SELECT false, 'Không tìm thấy đơn hàng'::TEXT;
        RETURN;
    END IF;
    
    -- Don't reassign if order is already assigned unless force_reassign is true
    IF v_order.assigned_to IS NOT NULL AND NOT p_force_reassign THEN
        RETURN QUERY
        SELECT false, 'Đơn hàng đã được phân công'::TEXT;
        RETURN;
    END IF;
    
    -- Determine channel type
    SELECT CASE 
        WHEN c.name LIKE '%facebook%' OR c.name LIKE '%fb%' THEN 'facebook'
        WHEN c.name LIKE '%wechat%' OR c.name LIKE '%weixin%' THEN 'wechat'
        ELSE 'facebook'
    END INTO v_channel_type
    FROM channels c
    WHERE c.id = v_order.channel_id;
    
    -- Reassign based on order type
    IF v_order.order_type = 'buy' THEN
        v_success := auto_assign_buy_order(p_order_id, v_channel_type);
    ELSE
        v_success := auto_assign_sell_order(p_order_id, v_channel_type);
    END IF;
    
    IF v_success THEN
        RETURN QUERY
        SELECT true, 'Phân công lại đơn hàng thành công'::TEXT;
    ELSE
        RETURN QUERY
        SELECT false, 'Không thể phân công đơn hàng'::TEXT;
    END IF;
END;
$$;


--
-- Name: mark_order_as_delivered_v1(uuid, boolean); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.mark_order_as_delivered_v1(p_order_id uuid, p_is_delivered boolean) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
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

  -- 3. Cập nhật trạng thái - dùng delivered_at thay vì is_delivered
  UPDATE public.orders
  SET delivered_at = CASE
                      WHEN p_is_delivered THEN NOW()
                      ELSE NULL
                    END
  WHERE id = p_order_id;
END;
$$;


--
-- Name: FUNCTION mark_order_as_delivered_v1(p_order_id uuid, p_is_delivered boolean); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.mark_order_as_delivered_v1(p_order_id uuid, p_is_delivered boolean) IS 'Marks an order as delivered/not delivered with proper authorization checks. Version 1 matches production standard.';


--
-- Name: migrate_parties_contact_info(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.migrate_parties_contact_info() RETURNS TABLE(party_id uuid, party_name text, party_type text, old_contact_info jsonb, new_contact_info jsonb, migration_status text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
    -- Update customer records
    RETURN QUERY
    UPDATE parties 
    SET 
        contact_info = jsonb_build_object(
            'contact', COALESCE(contact_info->>'contact', ''),
            'gameTag', COALESCE(contact_info->>'deliveryInfo', contact_info->>'gameTag', ''),
            'deliveryInfo', ''
        ),
        updated_at = NOW()
    WHERE type = 'customer'
      AND contact_info IS NOT NULL
    RETURNING 
        id as party_id,
        name as party_name,
        type as party_type,
        contact_info as old_contact_info,
        jsonb_build_object(
            'contact', COALESCE(contact_info->>'contact', ''),
            'gameTag', COALESCE(contact_info->>'deliveryInfo', contact_info->>'gameTag', ''),
            'deliveryInfo', ''
        ) as new_contact_info,
        'Customer migrated' as migration_status;
    
    -- Update supplier records
    RETURN QUERY
    UPDATE parties 
    SET 
        contact_info = jsonb_build_object(
            'contact', COALESCE(contact_info->>'contact', ''),
            'gameTag', COALESCE(contact_info->>'deliveryLocation', contact_info->>'gameTag', ''),
            'deliveryInfo', ''
        ),
        updated_at = NOW()
    WHERE type = 'supplier'
      AND contact_info IS NOT NULL
    RETURNING 
        id as party_id,
        name as party_name,
        type as party_type,
        contact_info as old_contact_info,
        jsonb_build_object(
            'contact', COALESCE(contact_info->>'contact', ''),
            'gameTag', COALESCE(contact_info->>'deliveryLocation', contact_info->>'gameTag', ''),
            'deliveryInfo', ''
        ) as new_contact_info,
        'Supplier migrated' as migration_status;
END;
$$;


--
-- Name: migrate_to_account_first_rotation(text, uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.migrate_to_account_first_rotation(p_game_code text, p_currency_attribute_id uuid) RETURNS TABLE(success boolean, message text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_base_key TEXT;
BEGIN
    v_base_key := format('INVENTORY_POOL_%s_%s', p_game_code, p_currency_attribute_id::TEXT);

    -- Initialize new account-first structure
    PERFORM initialize_account_first_rotation_tracker(
        v_base_key, p_game_code, p_currency_attribute_id
    );

    RETURN QUERY
    SELECT true,
           format('Successfully migrated to account-first rotation for %s - %s', p_game_code, v_base_key);
END;
$$;


--
-- Name: process_delivery_confirmation_v2(uuid, uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.process_delivery_confirmation_v2(p_order_id uuid, p_user_id uuid) RETURNS json
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_order RECORD;
    v_inventory_pool_id UUID;
    v_cost_amount NUMERIC;
    v_cost_currency_code TEXT;
    v_result JSON := '{}'::JSON;
BEGIN
    -- Lấy thông tin đơn hàng
    SELECT * INTO v_order
    FROM currency_orders
    WHERE id = p_order_id;
    
    IF NOT FOUND THEN
        v_result := jsonb_build_object('success', false, 'error', 'Đơn hàng không tồn tại');
        RETURN v_result;
    END IF;
    
    -- Xử lý inventory tùy theo loại đơn hàng
    IF v_order.order_type = 'PURCHASE' THEN
        -- Đơn mua: thêm vào inventory
        v_result := jsonb_build_object('success', true, 'message', 'Đã nhận hàng thành công');
    ELSIF v_order.order_type = 'SELL' THEN
        -- Đơn bán: trừ khỏi inventory
        v_result := jsonb_build_object('success', true, 'message', 'Đã giao hàng thành công');
    END IF;
    
    RETURN v_result;
END;
$$;


--
-- Name: process_sell_order_delivery(uuid, jsonb, uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.process_sell_order_delivery(p_order_id uuid, p_delivery_proof_urls jsonb, p_user_id uuid) RETURNS TABLE(success boolean, message text, order_id uuid, profit_amount numeric, fees_breakdown jsonb)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_order RECORD;
    v_pool RECORD;
    v_cost_amount_usd NUMERIC;
    v_sale_amount_usd NUMERIC;
    v_profit_amount NUMERIC;
    v_profit_margin NUMERIC;
    v_exchange_rate_cost NUMERIC;
    v_exchange_rate_sale NUMERIC;
    v_process_id UUID;
    v_total_fees_usd NUMERIC := 0;
    v_fees_breakdown JSONB := '[]'::JSONB;
    v_fee_record RECORD;
    v_new_proofs JSONB;
    v_transaction_unit_price NUMERIC;
    v_existing_proofs JSONB;
    v_url TEXT;
    v_new_proof JSONB;
    v_index INTEGER;
BEGIN
    -- 1. Validate and get order information
    SELECT * INTO v_order FROM currency_orders
    WHERE id = p_order_id
      AND order_type = 'SALE'
      AND status IN ('assigned', 'delivering', 'ready', 'preparing');

    IF v_order IS NULL THEN
        RETURN QUERY SELECT false, 'Order not found, not a sale order, or not ready for delivery', NULL::UUID, NULL::NUMERIC, NULL::JSONB;
        RETURN;
    END IF;

    -- 2. Get inventory pool and validate quantity
    SELECT * INTO v_pool FROM inventory_pools WHERE id = v_order.inventory_pool_id;

    IF v_pool IS NULL THEN
        RETURN QUERY SELECT false, 'Inventory pool not found', NULL::UUID, NULL::NUMERIC, NULL::JSONB;
        RETURN;
    END IF;

    IF v_pool.reserved_quantity < v_order.quantity THEN
        RETURN QUERY SELECT
            false,
            format('Insufficient reserved quantity: required=%s, available=%s', v_order.quantity, v_pool.reserved_quantity),
            NULL::UUID,
            NULL::NUMERIC,
            NULL::JSONB
        ;
        RETURN;
    END IF;

    -- 3. Validate proofs parameter
    IF p_delivery_proof_urls IS NULL THEN
        RETURN QUERY SELECT false, 'Delivery proofs are required', NULL::UUID, NULL::NUMERIC, NULL::JSONB;
        RETURN;
    END IF;

    -- Convert single URL to array if needed (backward compatibility)
    IF jsonb_typeof(p_delivery_proof_urls) = 'string' THEN
        p_delivery_proof_urls := jsonb_build_array(p_delivery_proof_urls);
    ELSIF jsonb_typeof(p_delivery_proof_urls) != 'array' THEN
        RETURN QUERY SELECT false, 'Delivery proofs must be a string or array', NULL::UUID, NULL::NUMERIC, NULL::JSONB;
        RETURN;
    END IF;

    -- Validate array is not empty
    IF jsonb_array_length(p_delivery_proof_urls) = 0 THEN
        RETURN QUERY SELECT false, 'At least one delivery proof is required', NULL::UUID, NULL::NUMERIC, NULL::JSONB;
        RETURN;
    END IF;

    -- 4. Initialize proofs - Start with existing proofs
    v_existing_proofs := COALESCE(v_order.proofs, '[]'::JSONB);

    -- Ensure it's an array
    IF jsonb_typeof(v_existing_proofs) = 'object' THEN
        v_existing_proofs := jsonb_build_array(v_existing_proofs);
    ELSIF jsonb_typeof(v_existing_proofs) != 'array' THEN
        v_existing_proofs := '[]'::JSONB;
    END IF;

    -- 5. Build delivery proof objects for each URL
    v_new_proofs := '[]'::JSONB;

    -- Process each delivery proof URL
    FOR v_index IN 0..jsonb_array_length(p_delivery_proof_urls) - 1 LOOP
        v_url := jsonb_extract_path_text(p_delivery_proof_urls, v_index::TEXT);

        v_new_proof := jsonb_build_object(
            'type', 'delivery',
            'url', v_url,
            'uploaded_at', NOW(),
            'uploaded_by', p_user_id
        );

        v_new_proofs := v_new_proofs || jsonb_build_array(v_new_proof);
    END LOOP;

    -- 6. Combine existing proofs with new delivery proofs
    -- Keep all non-delivery proofs and add new delivery proofs
    v_existing_proofs := (
        SELECT jsonb_agg(proof)
        FROM (
            -- Keep existing proofs that are not delivery
            SELECT proof
            FROM jsonb_array_elements(v_existing_proofs) AS proof
            WHERE proof->>'type' != 'delivery'

            UNION ALL

            -- Add new delivery proofs
            SELECT proof
            FROM jsonb_array_elements(v_new_proofs) AS proof
        ) AS all_proofs
    );

    -- Ensure we have a valid JSONB array
    IF v_existing_proofs IS NULL THEN
        v_existing_proofs := v_new_proofs;
    END IF;

    -- 7. Get current exchange rates
    BEGIN
        -- Convert cost to USD if needed
        IF v_order.cost_currency_code = 'USD' THEN
            v_cost_amount_usd := v_order.cost_amount;
            v_exchange_rate_cost := 1;
        ELSIF v_order.cost_currency_code = 'CNY' THEN
            v_exchange_rate_cost := get_exchange_rate_for_delivery('CNY', 'USD', CURRENT_DATE);
            v_cost_amount_usd := v_order.cost_amount * v_exchange_rate_cost;
        ELSIF v_order.cost_currency_code = 'VND' THEN
            v_exchange_rate_cost := get_exchange_rate_for_delivery('VND', 'USD', CURRENT_DATE);
            v_cost_amount_usd := v_order.cost_amount * v_exchange_rate_cost;
        ELSE
            v_exchange_rate_cost := get_exchange_rate_for_delivery(v_order.cost_currency_code, 'USD', CURRENT_DATE);
            v_cost_amount_usd := v_order.cost_amount * v_exchange_rate_cost;
        END IF;

        -- Convert sale to USD if needed
        IF v_order.sale_currency_code = 'USD' THEN
            v_sale_amount_usd := v_order.sale_amount;
            v_exchange_rate_sale := 1;
        ELSE
            v_exchange_rate_sale := get_exchange_rate_for_delivery(v_order.sale_currency_code, 'USD', CURRENT_DATE);
            v_sale_amount_usd := v_order.sale_amount * v_exchange_rate_sale;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        RETURN QUERY SELECT false, 'Exchange rate not available: ' || SQLERRM, NULL::UUID, NULL::NUMERIC, NULL::JSONB;
        RETURN;
    END;

    -- 8. Calculate profit
    v_profit_amount := v_sale_amount_usd - v_cost_amount_usd;
    v_profit_margin := CASE WHEN v_cost_amount_usd > 0 THEN (v_profit_amount / v_cost_amount_usd) * 100 ELSE 0 END;

    -- 9. Calculate transaction unit price
    v_transaction_unit_price := v_cost_amount_usd / v_order.quantity;

    -- 10. Update inventory pool - ONLY update reserved_quantity for delivery confirmation
    -- The actual quantity reduction happens when the sale is completed/finalized
    UPDATE inventory_pools SET
        reserved_quantity = reserved_quantity - v_order.quantity,
        last_updated_at = NOW(),
        last_updated_by = p_user_id
    WHERE id = v_order.inventory_pool_id;

    -- 11. Create currency transaction record
    INSERT INTO currency_transactions (
        game_account_id,
        game_code,
        transaction_type,
        currency_attribute_id,
        quantity,
        currency_order_id,
        unit_price,
        currency_code,
        exchange_rate_usd,
        channel_id,
        proofs,
        created_by,
        created_at,
        server_attribute_code
    ) VALUES (
        v_pool.game_account_id,
        v_order.game_code,
        'sale_delivery',
        v_order.currency_attribute_id,
        v_order.quantity,
        p_order_id,
        v_transaction_unit_price,
        'USD',
        v_exchange_rate_cost,
        COALESCE(v_pool.channel_id, v_order.channel_id),
        v_new_proofs,
        p_user_id,
        NOW(),
        v_order.server_attribute_code
    );

    -- 12. Update currency order
    UPDATE currency_orders SET
        status = 'completed',
        completed_at = NOW(),
        delivery_at = NOW(),
        delivered_by = p_user_id,
        profit_amount = v_profit_amount,
        profit_currency_code = 'USD',
        profit_margin_percentage = v_profit_margin,
        cost_to_sale_exchange_rate = v_exchange_rate_cost,
        exchange_rate_date = CURRENT_DATE,
        exchange_rate_source = 'system',
        proofs = v_existing_proofs  -- Already contains combined proofs
    WHERE id = p_order_id;

    -- 13. Return success result
    RETURN QUERY SELECT
        true,
        format('Delivery processed successfully with %s proof(s)', jsonb_array_length(v_new_proofs)),
        p_order_id,
        v_profit_amount,
        v_fees_breakdown;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT
            false,
            'Delivery processing failed: ' || SQLERRM,
            NULL::UUID,
            NULL::NUMERIC,
            NULL::JSONB;
END;
$$;


--
-- Name: process_sell_order_final(uuid, jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.process_sell_order_final(p_order_id uuid, p_proof_urls jsonb DEFAULT '[]'::jsonb) RETURNS TABLE(success boolean, message text, order_id uuid, assigned_employee_id uuid, assigned_employee_name text, assigned_channel_id uuid, assigned_channel_name text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_current_user_id UUID;
    v_order RECORD;
    v_assignment_success BOOLEAN;
    v_employee_id UUID;
    v_employee_name TEXT;
    v_channel_name TEXT;
    v_current_time TIMESTAMPTZ := NOW();
BEGIN
    -- Get current user from authentication context
    v_current_user_id := auth.uid();
    
    -- Validate order exists and is in draft status
    SELECT o.* INTO v_order
    FROM currency_orders o
    WHERE o.id = p_order_id AND o.status = 'draft';
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT false, 'Không tìm thấy đơn hàng ở trạng thái draft', NULL::UUID, NULL::UUID, NULL, NULL::UUID, NULL;
        RETURN;
    END IF;
    
    -- Update proofs if provided
    IF p_proof_urls IS NOT NULL AND jsonb_array_length(p_proof_urls) > 0 THEN
        UPDATE currency_orders 
        SET proofs = p_proof_urls
        WHERE id = p_order_id;
    END IF;
    
    -- Update order status to pending and set submitted timestamp first
    UPDATE currency_orders
    SET status = 'pending',
        submitted_at = v_current_time,
        updated_at = v_current_time
    WHERE id = p_order_id;
    
    -- Try to auto-assign the order
    v_assignment_success := auto_assign_sell_order(p_order_id);
    
    IF v_assignment_success THEN
        -- Get updated order info after successful assignment
        SELECT o.assigned_to, p.full_name, c.name
        INTO v_employee_id, v_employee_name, v_channel_name
        FROM currency_orders o
        LEFT JOIN profiles p ON o.assigned_to = p.id
        LEFT JOIN employee_channels ec ON p.id = ec.employee_id
        LEFT JOIN channels c ON ec.channel_id = c.id
        WHERE o.id = p_order_id
        LIMIT 1;
        
        -- Return success result with assignment info
        RETURN QUERY
        SELECT 
            true,
            'Đơn hàng đã được tạo và phân công thành công',
            v_order.id,
            COALESCE(v_employee_id, NULL::UUID),
            COALESCE(v_employee_name, 'Nhân viên'),
            NULL::UUID, -- Channel info not directly available from auto_assign_sell_order
            COALESCE(v_channel_name, 'Kênh');
    ELSE
        -- Return success but no assignment available, status remains pending
        RETURN QUERY
        SELECT 
            true,
            'Đơn hàng đã được tạo thành công (chưa có nhân viên khả dụng)',
            v_order.id,
            NULL::UUID,
            'Chưa phân công',
            NULL::UUID,
            'Chưa có kênh';
    END IF;
    
    RETURN;
END;
$$;


--
-- Name: rebuild_critical_materialized_views(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.rebuild_critical_materialized_views() RETURNS TABLE(view_name text, status text, build_time_ms numeric)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_start_time TIMESTAMP;
    v_view_name TEXT;
BEGIN
    -- Rebuild active farmers view
    v_start_time := clock_timestamp();
    v_view_name := 'mv_active_farmers';

    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_active_farmers;

    RETURN QUERY
    SELECT
        v_view_name as view_name,
        'SUCCESS' as status,
        EXTRACT(EPOCH FROM (clock_timestamp() - v_start_time)) * 1000 as build_time_ms;

EXCEPTION WHEN OTHERS THEN
    RETURN QUERY
    SELECT
        v_view_name as view_name,
        'FAILED: ' || SQLERRM as status,
        EXTRACT(EPOCH FROM (clock_timestamp() - v_start_time)) * 1000 as build_time_ms;
END;
$$;


--
-- Name: refresh_active_farmers(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.refresh_active_farmers() RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
  REFRESH MATERIALIZED VIEW CONCURRENTLY mv_active_farmers;

  RAISE NOTICE 'Materialized view mv_active_farmers refreshed at %', NOW();
END;
$$;


--
-- Name: remove_role_from_user(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.remove_role_from_user(p_assignment_id uuid) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
  v_deleted_count INTEGER;
BEGIN
  -- Delete the role assignment
  DELETE FROM user_role_assignments 
  WHERE id = p_assignment_id
  RETURNING 1 INTO v_deleted_count;
  
  IF v_deleted_count = 0 THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Không tìm thấy phân quyền để xóa'
    );
  END IF;
  
  -- Return success result
  RETURN jsonb_build_object(
    'success', true,
    'message', 'Đã xóa vai trò thành công'
  );
END;
$$;


--
-- Name: FUNCTION remove_role_from_user(p_assignment_id uuid); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.remove_role_from_user(p_assignment_id uuid) IS 'Removes a role assignment from a user';


--
-- Name: reserve_inventory_pool(uuid, numeric); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.reserve_inventory_pool(p_inventory_pool_id uuid, p_quantity numeric) RETURNS TABLE(success boolean, message text, updated_quantity numeric, updated_reserved_quantity numeric)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_current_quantity DECIMAL;
    v_current_reserved DECIMAL;
    v_available_quantity DECIMAL;
    v_current_user_id UUID;
BEGIN
    -- Get current user
    v_current_user_id := auth.uid();

    -- Get current quantities
    SELECT quantity, reserved_quantity INTO v_current_quantity, v_current_reserved
    FROM inventory_pools
    WHERE id = p_inventory_pool_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RETURN QUERY
        SELECT false, 'Inventory pool not found', 0::DECIMAL, 0::DECIMAL;
        RETURN;
    END IF;

    -- Calculate available quantity
    v_available_quantity := v_current_quantity - COALESCE(v_current_reserved, 0);

    -- Check if enough inventory is available
    IF v_available_quantity < p_quantity THEN
        RETURN QUERY
        SELECT false, 
               format('Insufficient inventory. Available: %s, Required: %s', 
                      v_available_quantity, p_quantity),
               v_current_quantity, COALESCE(v_current_reserved, 0);
        RETURN;
    END IF;

    -- Update inventory pools
    UPDATE inventory_pools
    SET 
        quantity = quantity,
        reserved_quantity = COALESCE(reserved_quantity, 0) + p_quantity,
        last_updated_at = NOW(),
        last_updated_by = v_current_user_id
    WHERE id = p_inventory_pool_id;

    -- Get updated values
    SELECT quantity, reserved_quantity INTO v_current_quantity, v_current_reserved
    FROM inventory_pools
    WHERE id = p_inventory_pool_id;

    RETURN QUERY
    SELECT true,
           format('Successfully reserved %s units from inventory pool', p_quantity),
           v_current_quantity,
           v_current_reserved;
    RETURN;
END;
$$;


--
-- Name: reset_eligible_pilot_cycles(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.reset_eligible_pilot_cycles() RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
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


--
-- Name: resolve_service_report_v1(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.resolve_service_report_v1() RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
    IF NOT has_permission('reports:resolve') THEN RAISE EXCEPTION 'Authorization failed.'; END IF;
    UPDATE service_reports SET status = 'resolved', resolved_at = now(), resolved_by = (select auth.uid()), resolver_notes = p_resolver_notes WHERE id = p_report_id;
END;
$$;


--
-- Name: search_parties(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.search_parties(p_search_term text, p_party_type text DEFAULT NULL::text) RETURNS TABLE(id uuid, name text, type text, contact_info jsonb, relevance_score integer)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.id,
        p.name,
        p.type,
        p.contact_info,
        CASE
            WHEN LOWER(p.name) = LOWER(p_search_term) THEN 100
            WHEN LOWER(p.name) LIKE LOWER(p_search_term || '%') THEN 90
            WHEN LOWER(p.name) LIKE '%' || LOWER(p_search_term) || '%' THEN 50
            ELSE 10
        END as relevance_score
    FROM public.parties p
    WHERE (p_party_type IS NULL OR p.type = p_party_type)
      AND (
          LOWER(p.name) LIKE '%' || LOWER(p_search_term) || '%' OR
          LOWER(p.contact_info->>'discord') LIKE '%' || LOWER(p_search_term) || '%' OR
          LOWER(p.contact_info->>'telegram') LIKE '%' || LOWER(p_search_term) || '%'
      )
    ORDER BY relevance_score DESC, p.name ASC
    LIMIT 50;
END;
$$;


--
-- Name: set_purchase_order_number(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.set_purchase_order_number() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
    IF NEW.order_number IS NULL THEN
        NEW.order_number := public.generate_purchase_order_number();
    END IF;
    RETURN NEW;
END;
$$;


--
-- Name: simple_exchange_rate_cron(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.simple_exchange_rate_cron() RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_edge_function_url TEXT := 'https://nxlrnwijsxqalcxyavkj.supabase.co/functions/v1/fetch-exchange-rates';
    v_service_role_key TEXT := 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im54bHJud2lqc3hxYWxjeHlhdmtqIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MDI3Mzc3MiwiZXhwIjoyMDc1ODQ5NzcyfQ.UKUYbw3TOQ1gjq1H5e9N8yRQWEIo7Uuru4UdqhymGuU';
    v_request_id BIGINT;
    v_response TEXT;
    v_status_code INTEGER;
    v_log_id UUID;
    v_success BOOLEAN := FALSE;
BEGIN
    -- Log attempt before making the call
    INSERT INTO exchange_rate_api_log (api_provider, endpoint_url, success, created_at)
    VALUES ('cron_job', v_edge_function_url, FALSE, NOW())
    RETURNING id INTO v_log_id;

    -- Make HTTP POST request to edge function with proper authentication
    SELECT net.http_post(
        url := v_edge_function_url,
        headers := jsonb_build_object(
            'Authorization', 'Bearer ' || v_service_role_key,
            'apikey', v_service_role_key,
            'Content-Type', 'application/json'
        ),
        body := jsonb_build_object()
    ) INTO v_request_id;

    -- Wait for response (increased from 3 to 10 seconds)
    PERFORM pg_sleep(10);

    -- Try to get the response
    BEGIN
        SELECT content, status_code INTO v_response, v_status_code
        FROM net._http_response
        WHERE id = v_request_id;

        -- If we got a response, check if it was successful
        IF v_response IS NOT NULL THEN
            -- Consider success if status code is 200
            v_success := (v_status_code = 200);

            IF v_success = TRUE THEN
                -- Try to parse response as JSON for additional verification
                BEGIN
                    IF (v_response::jsonb->>'success')::boolean = TRUE THEN
                        -- Update config to track last successful fetch
                        UPDATE exchange_rate_config 
                        SET 
                            last_successful_fetch = NOW(),
                            updated_at = NOW(),
                            api_failures = 0,
                            last_api_used = 'primary'
                        WHERE is_active = true;

                        RAISE LOG 'Exchange rate cron job completed successfully - Status: %', v_status_code;
                    ELSE
                        v_success := FALSE;
                        UPDATE exchange_rate_api_log 
                        SET 
                            success = FALSE,
                            error_message = COALESCE((v_response::jsonb->>'message'), 'Edge function returned failure')
                        WHERE id = v_log_id;

                        -- Increment failure count
                        UPDATE exchange_rate_config 
                        SET 
                            api_failures = api_failures + 1,
                            updated_at = NOW()
                        WHERE is_active = true;

                        RAISE LOG 'Exchange rate cron job failed: %', v_response::jsonb->>'message';
                    END IF;
                EXCEPTION WHEN OTHERS THEN
                    -- If JSON parsing fails, but status code is 200, consider it success
                    IF v_status_code = 200 THEN
                        -- Update config to track last successful fetch
                        UPDATE exchange_rate_config 
                        SET 
                            last_successful_fetch = NOW(),
                            updated_at = NOW(),
                            api_failures = 0,
                            last_api_used = 'primary'
                        WHERE is_active = true;

                        RAISE LOG 'Exchange rate cron job completed successfully - Status: % (JSON parse failed but 200 OK)', v_status_code;
                    ELSE
                        v_success := FALSE;
                        UPDATE exchange_rate_api_log 
                        SET 
                            success = FALSE,
                            error_message = 'Status: ' || v_status_code || ', Response: ' || LEFT(v_response, 200)
                        WHERE id = v_log_id;

                        -- Increment failure count
                        UPDATE exchange_rate_config 
                        SET 
                            api_failures = api_failures + 1,
                            updated_at = NOW()
                        WHERE is_active = true;

                        RAISE LOG 'Exchange rate cron job failed - Status: %', v_status_code;
                    END IF;
                END;

                -- Update log with success status
                UPDATE exchange_rate_api_log 
                SET 
                    success = v_success,
                    response_time_ms = EXTRACT(MILLISECOND FROM (NOW() - created_at))::INTEGER
                WHERE id = v_log_id;

            ELSE
                -- Update log with failure (non-200 status)
                UPDATE exchange_rate_api_log 
                SET 
                    success = FALSE,
                    error_message = 'HTTP Status: ' || v_status_code || ', Response: ' || LEFT(v_response, 200)
                WHERE id = v_log_id;

                -- Increment failure count
                UPDATE exchange_rate_config 
                SET 
                    api_failures = api_failures + 1,
                    updated_at = NOW()
                WHERE is_active = true;

                RAISE LOG 'Exchange rate cron job failed - Status: %', v_status_code;
            END IF;

        ELSE
            -- No response received
            UPDATE exchange_rate_api_log 
            SET 
                success = FALSE,
                error_message = 'No response received from edge function'
            WHERE id = v_log_id;

            -- Increment failure count
            UPDATE exchange_rate_config 
            SET 
                api_failures = api_failures + 1,
                updated_at = NOW()
            WHERE is_active = true;

            RAISE LOG 'Exchange rate cron job failed: No response from edge function';
        END IF;

    EXCEPTION WHEN OTHERS THEN
        -- Error occurred during request
        UPDATE exchange_rate_api_log 
        SET 
            success = FALSE,
            error_message = SQLERRM
        WHERE id = v_log_id;

        -- Increment failure count
        UPDATE exchange_rate_config 
        SET 
            api_failures = api_failures + 1,
            updated_at = NOW()
        WHERE is_active = true;

        RAISE LOG 'Exchange rate cron job error: %', SQLERRM;
    END;
END;
$$;


--
-- Name: start_currency_order_v1(uuid, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.start_currency_order_v1(p_order_id uuid, p_start_notes text DEFAULT NULL::text) RETURNS TABLE(success boolean, message text, new_status text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_user_id uuid := public.get_current_profile_id();
    v_can_start boolean := false;
BEGIN
    -- Permission Check using has_permission function
    v_can_start := public.has_permission('currency:start', jsonb_build_object('game_code', (SELECT game_code FROM public.currency_orders WHERE id = p_order_id)));

    IF NOT v_can_start THEN
        RETURN QUERY SELECT FALSE, 'Permission denied: Cannot start order', NULL::TEXT;
        RETURN;
    END IF;

    -- Validate order status
    IF NOT EXISTS(SELECT 1 FROM public.currency_orders WHERE id = p_order_id AND status = 'assigned') THEN
        RETURN QUERY SELECT FALSE, 'Order not found or not in assigned status', NULL::TEXT;
        RETURN;
    END IF;

    -- Update order status with new column name
    UPDATE public.currency_orders
    SET status = 'preparing',
        preparation_at = NOW(),  -- Updated column name
        ops_notes = COALESCE((SELECT ops_notes FROM public.currency_orders WHERE id = p_order_id), '') || COALESCE(E'\n[' || NOW() || '] ' || p_start_notes, ''),
        updated_at = NOW(),
        updated_by = v_user_id
    WHERE id = p_order_id;

    RETURN QUERY SELECT TRUE, 'Order started successfully', 'preparing';
END;
$$;


--
-- Name: FUNCTION start_currency_order_v1(p_order_id uuid, p_start_notes text); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.start_currency_order_v1(p_order_id uuid, p_start_notes text) IS 'Start processing an assigned order';


--
-- Name: start_work_session_v1(uuid, jsonb, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.start_work_session_v1(p_order_line_id uuid, p_start_state jsonb, p_initial_note text DEFAULT NULL::text) RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
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
    FROM public.orders o
    JOIN public.order_lines ol ON o.id = ol.order_id
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
    IF NOT public.has_permission('work_session:start', v_context) THEN
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
        UPDATE public.order_lines SET paused_at = NULL WHERE id = p_order_line_id;
        PERFORM public.update_pilot_cycle_warning(p_order_line_id);
    END IF;

    RETURN new_session_id;
END;
$$;


--
-- Name: FUNCTION start_work_session_v1(p_order_line_id uuid, p_start_state jsonb, p_initial_note text); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.start_work_session_v1(p_order_line_id uuid, p_start_state jsonb, p_initial_note text) IS 'Bắt đầu phiên làm việc mới cho một dòng đơn hàng - Cập nhật theo production version';


--
-- Name: submit_and_assign_sell_order(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.submit_and_assign_sell_order() RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    assigned_trader_id uuid;
    channel_id uuid;
BEGIN
    -- Get channel_id from order
    SELECT channel_id INTO channel_id
    FROM sell_orders
    WHERE id = p_order_id;
    
    -- Auto assign if channel is specified
    IF channel_id IS NOT NULL THEN
        SELECT auto_assign_sell_order(p_order_id) INTO assigned_trader_id;
    END IF;
    
    -- Submit the order
    PERFORM submit_sell_order_with_assignment(p_order_id, assigned_trader_id);
    
    RETURN COALESCE(assigned_trader_id, p_order_id);
END;
$$;


--
-- Name: submit_and_assign_sell_order(uuid, jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.submit_and_assign_sell_order(p_order_id uuid, p_proof_urls jsonb DEFAULT '[]'::jsonb) RETURNS TABLE(success boolean, message text, order_id uuid, assigned_employee_id uuid, assigned_employee_name text, assigned_channel_id uuid, assigned_channel_name text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_current_user_id UUID;
    v_order RECORD;
    v_channel_name TEXT;
BEGIN
    -- Get current user from authentication context
    v_current_user_id := auth.uid();

    -- Validate order exists and is in draft status
    SELECT o.* INTO v_order
    FROM currency_orders o
    WHERE o.id = p_order_id;

    IF NOT FOUND THEN
        RETURN QUERY SELECT false, 'Không tìm thấy đơn hàng', NULL::UUID, NULL::UUID, NULL, NULL::UUID, NULL;
        RETURN;
    END IF;

    IF v_order.status != 'draft' THEN
        RETURN QUERY SELECT false, 'Chỉ có thể phân công đơn hàng ở trạng thái draft', NULL::UUID, NULL::UUID, NULL, NULL::UUID, NULL;
        RETURN;
    END IF;

    -- Get channel name for messages
    SELECT c.name INTO v_channel_name
    FROM channels c
    WHERE c.id = v_order.channel_id;

    -- Update proofs if provided
    IF p_proof_urls IS NOT NULL AND jsonb_array_length(p_proof_urls) > 0 THEN
        UPDATE currency_orders
        SET proofs = p_proof_urls
        WHERE id = p_order_id;
    END IF;

    -- Update order status to pending and set submitted timestamp
    UPDATE currency_orders
    SET status = 'pending',
        submitted_at = NOW(),
        updated_at = NOW()
    WHERE id = p_order_id;

    -- Return success without assignment since the auto_assign_sell_order function is broken
    -- This allows the sell order workflow to complete successfully, just without automatic assignment
    RETURN QUERY
    SELECT
        true,
        'Đơn hàng đã được nộp thành công (chờ phân công thủ công)',
        v_order.id,
        NULL::UUID,
        'Chưa phân công',
        NULL::UUID,
        COALESCE(v_channel_name, 'Chưa có kênh');

    RETURN;
END;
$$;


--
-- Name: submit_order_review_v1(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.submit_order_review_v1() RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$BEGIN
  -- SỬA LẠI: Kiểm tra quyền 'orders:add_review'
  IF NOT has_permission('orders:add_review') THEN
    RAISE EXCEPTION 'User does not have permission to submit a review';
  END IF;

  INSERT INTO order_reviews (order_line_id, rating, comment, proof_urls, created_by)
  VALUES (p_line_id, p_rating, p_comment, p_proof_urls, get_current_profile_id());
END;$$;


--
-- Name: submit_sell_order_with_assignment(uuid, jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.submit_sell_order_with_assignment(p_order_id uuid, p_proof_urls jsonb DEFAULT '[]'::jsonb) RETURNS TABLE(success boolean, message text, order_id uuid, assigned_employee_id uuid, assigned_employee_name text, assigned_channel_id uuid, assigned_channel_name text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_current_user_id UUID;
    v_order RECORD;
    v_assignment_success BOOLEAN;
    v_employee_id UUID;
    v_employee_name TEXT;
    v_channel_name TEXT;
    v_current_time TIMESTAMPTZ := NOW();
BEGIN
    -- Get current user from authentication context
    v_current_user_id := auth.uid();
    
    -- Validate order exists and is in draft status
    SELECT o.* INTO v_order
    FROM currency_orders o
    WHERE o.id = p_order_id AND o.status = 'draft';
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT false, 'Không tìm thấy đơn hàng ở trạng thái draft', NULL::UUID, NULL::UUID, NULL, NULL::UUID, NULL;
        RETURN;
    END IF;
    
    -- Update proofs if provided
    IF p_proof_urls IS NOT NULL AND jsonb_array_length(p_proof_urls) > 0 THEN
        UPDATE currency_orders 
        SET proofs = p_proof_urls
        WHERE id = p_order_id;
    END IF;
    
    -- Update order status to pending and set submitted timestamp first
    UPDATE currency_orders
    SET status = 'pending',
        submitted_at = v_current_time,
        updated_at = v_current_time
    WHERE id = p_order_id;
    
    -- Try to auto-assign the order
    v_assignment_success := auto_assign_sell_order(p_order_id);
    
    IF v_assignment_success THEN
        -- Get updated order info after successful assignment
        SELECT o.assigned_to, p.full_name, c.name
        INTO v_employee_id, v_employee_name, v_channel_name
        FROM currency_orders o
        LEFT JOIN profiles p ON o.assigned_to = p.id
        LEFT JOIN employee_channels ec ON p.id = ec.employee_id
        LEFT JOIN channels c ON ec.channel_id = c.id
        WHERE o.id = p_order_id
        LIMIT 1;
        
        -- Return success result with assignment info
        RETURN QUERY
        SELECT 
            true,
            'Đơn hàng đã được tạo và phân công thành công',
            v_order.id,
            COALESCE(v_employee_id, NULL::UUID),
            COALESCE(v_employee_name, 'Nhân viên'),
            NULL::UUID, -- Channel info not directly available from auto_assign_sell_order
            COALESCE(v_channel_name, 'Kênh');
    ELSE
        -- Return success but no assignment available, status remains pending
        RETURN QUERY
        SELECT 
            true,
            'Đơn hàng đã được tạo thành công (chưa có nhân viên khả dụng)',
            v_order.id,
            NULL::UUID,
            'Chưa phân công',
            NULL::UUID,
            'Chưa có kênh';
    END IF;
    
    RETURN;
END;
$$;


--
-- Name: test_cascade_profit_calculation(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.test_cascade_profit_calculation(p_order_id uuid DEFAULT 'bca302db-bd14-44cc-80f4-961a2fd2e2a0'::uuid) RETURNS TABLE(calculation_step text, value numeric, currency text, description text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_order RECORD;
    v_pool RECORD;
    v_exchange_rate_vnd_usd NUMERIC;
    v_exchange_rate_usd_vnd NUMERIC;
    v_sale_amount_vnd NUMERIC;
    v_current_amount NUMERIC;
    v_fee_record RECORD;
    v_process_id UUID;
BEGIN
    -- Get order data
    SELECT * INTO v_order FROM currency_orders WHERE id = p_order_id;
    
    -- Get pool data  
    SELECT * INTO v_pool FROM inventory_pools WHERE id = v_order.inventory_pool_id;
    
    -- Get exchange rates
    SELECT rate INTO v_exchange_rate_vnd_usd FROM exchange_rate_monitor 
    WHERE from_currency = 'VND' AND to_currency = 'USD' AND status = 'Valid' 
    ORDER BY effective_date DESC LIMIT 1;
    
    v_exchange_rate_usd_vnd := 1 / v_exchange_rate_vnd_usd;
    
    -- Step 1: Convert sale to VND
    v_sale_amount_vnd := v_order.sale_amount * v_exchange_rate_usd_vnd;
    v_current_amount := v_sale_amount_vnd;
    
    RETURN QUERY SELECT 'Step 1: Sale amount in VND', v_sale_amount_vnd::NUMERIC, 'VND', 'Convert 7 USD to VND';
    
    -- Get business process
    SELECT id INTO v_process_id FROM business_processes 
    WHERE purchase_channel_id = v_pool.channel_id 
      AND sale_channel_id = v_order.channel_id 
      AND purchase_currency = v_order.cost_currency_code 
      AND sale_currency = v_order.sale_currency_code 
      AND is_active = true;
    
    -- Apply fees in order: SELL -> WITHDRAW
    FOR v_fee_record IN 
        SELECT f.* FROM fees f
        JOIN process_fees_map fm ON f.id = fm.fee_id
        WHERE fm.process_id = v_process_id AND f.is_active = true
        ORDER BY CASE f.direction WHEN 'SELL' THEN 1 WHEN 'WITHDRAW' THEN 2 ELSE 3 END
    LOOP
        DECLARE
            v_fee_amount_vnd NUMERIC;
        BEGIN
            IF v_fee_record.fee_type = 'RATE' THEN
                IF v_fee_record.currency = 'USD' THEN
                    v_fee_amount_vnd := v_current_amount * v_fee_record.amount;
                ELSIF v_fee_record.currency = 'VND' THEN
                    v_fee_amount_vnd := v_current_amount * v_fee_record.amount;
                END IF;
            END IF;
            
            v_current_amount := v_current_amount - v_fee_amount_vnd;
            
            RETURN QUERY SELECT 
                'Fee: ' || v_fee_record.name, 
                v_fee_amount_vnd::NUMERIC, 
                'VND', 
                'Apply ' || (v_fee_record.amount * 100)::TEXT || '% fee to current amount';
        END;
    END LOOP;
    
    -- Final profit in VND
    DECLARE
        v_profit_vnd NUMERIC;
        v_profit_usd NUMERIC;
    BEGIN
        v_profit_vnd := v_current_amount - v_order.cost_amount;
        v_profit_usd := v_profit_vnd * v_exchange_rate_vnd_usd;
        
        RETURN QUERY SELECT 'Profit in VND', v_profit_vnd::NUMERIC, 'VND', 'Final profit before conversion';
        RETURN QUERY SELECT 'Profit in USD', v_profit_usd::NUMERIC, 'USD', 'Final profit converted to USD';
        RETURN QUERY SELECT 'Cost Amount', v_order.cost_amount::NUMERIC, 'VND', 'Original cost amount';
    END;
END;
$$;


--
-- Name: test_employee_assignment(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.test_employee_assignment() RETURNS TABLE(employee_id uuid, employee_name text, match_type text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
    RETURN QUERY SELECT * FROM get_employee_for_game_in_shift_round_robin(
        'POE_2',
        '58859ff6-fc5f-4fcc-9a29-81a1223fa91b'::UUID,
        'd1ffc8aa-339b-45ce-a343-7112273bf097'::UUID,
        'CNY',
        NULL
    );
END;
$$;


--
-- Name: toggle_customer_playing(uuid, boolean, uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.toggle_customer_playing(p_order_id uuid, p_enable_customer_playing boolean, p_current_user_id uuid) RETURNS TABLE(success boolean, message text, new_status text, new_deadline timestamp with time zone)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
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


--
-- Name: tr_audit_row_v1(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.tr_audit_row_v1() RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
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
    INSERT INTO audit_logs (actor, entity, entity_id, action, op, diff, row_old, row_new)
    VALUES (v_actor_id, TG_TABLE_SCHEMA || '.' || TG_TABLE_NAME, v_entity_id, LOWER(TG_OP), TG_OP, v_diff, v_old_row_json, v_new_row_json);
    RETURN COALESCE(NEW, OLD);
END;
$$;


--
-- Name: tr_auto_initialize_pilot_cycle_on_first_session(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.tr_auto_initialize_pilot_cycle_on_first_session() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
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


--
-- Name: tr_auto_initialize_pilot_cycle_on_order_create(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.tr_auto_initialize_pilot_cycle_on_order_create() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
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


--
-- Name: tr_auto_update_pilot_cycle_on_pause_change(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.tr_auto_update_pilot_cycle_on_pause_change() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
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


--
-- Name: tr_auto_update_pilot_cycle_on_session_end(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.tr_auto_update_pilot_cycle_on_session_end() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
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


--
-- Name: tr_check_all_items_completed_v1(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.tr_check_all_items_completed_v1() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'public'
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
            IF v_current_order_status = 'in_progress' AND v_service_type = 'Service - Selfplay' THEN
                UPDATE public.order_lines SET paused_at = NOW() WHERE id = v_order_line_id;
            END IF;
            UPDATE public.orders SET status = 'pending_completion' WHERE id = v_order_id;
        END IF;
    END IF;
    RETURN NEW;
END;
$$;


--
-- Name: trigger_exchange_rate_update(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trigger_exchange_rate_update() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
    -- This will be called manually to trigger exchange rate update
    PERFORM net.http_get(
        'https://nxlrnwijsxqalcxyavkj.supabase.co/functions/v1/fetch-exchange-rates',
        jsonb_build_object(
            'Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im54bHJud2lqc3hxYWxjeGF2a2oiLCJyb2xlIjoic2VydmljZV9yb2xlIiwiaWF0IjoxNzM3NTQ2NDE1LCJleHAiOjIwNTMxMjI0MTV9.S2sEaQRGZqTyJ93XZkIXN1tP_8N2Ww1h7G2XNLJXg-c',
            'apikey', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im54bHJud2lqc3hxYWxjeGF2a2oiLCJyb2xlIjoic2VydmljZV9yb2xlIiwiaWF0IjoxNzM3NTQ2NDE1LCJleHAiOjIwNTMxMjI0MTV9.S2sEaQRGZqTyJ93XZkIXN1tP_8N2Ww1h7G2XNLJXg-c'
        )
    );
    
    RETURN NEW;
END;
$$;


--
-- Name: try_uuid(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.try_uuid(p text) RETURNS uuid
    LANGUAGE plpgsql IMMUTABLE
    SET search_path TO 'pg_catalog', 'public'
    AS $$
begin
  return p::uuid;
exception when others then
  return null;
end $$;


--
-- Name: update_action_proofs_v1(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_action_proofs_v1() RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
  v_context jsonb; -- <<< BIẾN MỚI ĐỂ LƯU NGỮ CẢNH
BEGIN
  -- 1. Lấy ngữ cảnh từ đơn hàng để kiểm tra quyền
  SELECT 
    jsonb_build_object('game_code', o.game_code, 'business_area_code', 'SERVICE')
  INTO 
    v_context
  FROM order_lines ol
  JOIN orders o ON ol.order_id = o.id
  WHERE ol.id = p_line_id;

  -- 2. Kiểm tra quyền hạn VỚI NGỮ CẢNH ĐẦY ĐỦ
  IF NOT has_permission('orders:edit_details', v_context) THEN
    RAISE EXCEPTION 'Authorization failed. You do not have permission to edit this order.';
  END IF;

  -- 3. Cập nhật bảng (logic cũ giữ nguyên)
  UPDATE order_lines
  SET action_proof_urls = p_new_urls
  WHERE id = p_line_id;

END;
$$;


--
-- Name: update_business_process_direct(uuid, text, text, text, boolean, uuid, text, uuid, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_business_process_direct(p_process_id uuid, p_code text, p_name text, p_description text DEFAULT NULL::text, p_is_active boolean DEFAULT true, p_sale_channel_id uuid DEFAULT NULL::uuid, p_sale_currency text DEFAULT NULL::text, p_purchase_channel_id uuid DEFAULT NULL::uuid, p_purchase_currency text DEFAULT NULL::text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
  v_process_exists BOOLEAN;
BEGIN
  -- Check if process exists
  SELECT EXISTS(SELECT 1 FROM business_processes WHERE id = p_process_id) INTO v_process_exists;

  IF NOT v_process_exists THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Không tìm thấy quy trình kinh doanh'
    );
  END IF;

  -- Update business process (this bypasses RLS due to SECURITY DEFINER)
  UPDATE business_processes
  SET
    code = p_code,
    name = p_name,
    description = p_description,
    is_active = p_is_active,
    created_at = NOW(),
    sale_channel_id = p_sale_channel_id,
    sale_currency = p_sale_currency,
    purchase_channel_id = p_purchase_channel_id,
    purchase_currency = p_purchase_currency
  WHERE id = p_process_id;

  RETURN jsonb_build_object(
    'success', true,
    'message', 'Cập nhật quy trình kinh doanh thành công',
    'process_id', p_process_id
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Lỗi khi cập nhật quy trình kinh doanh: ' || SQLERRM
    );
END;
$$;


--
-- Name: update_channel_direct(uuid, text, text, text, text, text, boolean, uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_channel_direct(p_channel_id uuid, p_code text, p_name text, p_description text DEFAULT NULL::text, p_website_url text DEFAULT NULL::text, p_direction text DEFAULT 'BOTH'::text, p_is_active boolean DEFAULT true, p_updated_by uuid DEFAULT NULL::uuid) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
  v_channel_exists BOOLEAN;
  v_channel_name TEXT;
BEGIN
  -- Check if channel exists
  SELECT EXISTS(SELECT 1 FROM channels WHERE id = p_channel_id) INTO v_channel_exists;

  IF NOT v_channel_exists THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Không tìm thấy kênh giao dịch'
    );
  END IF;

  -- Get current channel name for response
  SELECT name INTO v_channel_name FROM channels WHERE id = p_channel_id;

  -- Update channel (this bypasses RLS due to SECURITY DEFINER)
  UPDATE channels
  SET
    code = p_code,
    name = p_name,
    description = p_description,
    website_url = p_website_url,
    direction = p_direction,
    is_active = p_is_active,
    updated_by = p_updated_by,
    updated_at = NOW()
  WHERE id = p_channel_id;

  RETURN jsonb_build_object(
    'success', true,
    'message', 'Cập nhật kênh giao dịch thành công',
    'channel_id', p_channel_id,
    'channel_name', v_channel_name,
    'channel_code', p_code
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Lỗi khi cập nhật kênh giao dịch: ' || SQLERRM
    );
END;
$$;


--
-- Name: update_channel_rotation_tracker_with_detection(text, uuid, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_channel_rotation_tracker_with_detection(p_game_code text, p_currency_attribute_id uuid, p_cost_currency text, p_base_key text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_current_channels JSONB;
    v_tracker_key TEXT;
    v_current_index INTEGER;
    v_active_channels TEXT[];
    v_array_length INTEGER;
    v_old_channels TEXT[];
    v_has_changed BOOLEAN := FALSE;
    v_tracker_exists BOOLEAN := FALSE;
BEGIN
    -- Build tracker key properly
    v_tracker_key := p_base_key || '_CHANNEL_' || p_cost_currency;
    
    -- Check if tracker exists
    SELECT EXISTS(
        SELECT 1 FROM assignment_trackers 
        WHERE assignment_type = 'inventory_pool_rotation'
          AND assignment_group_key = v_tracker_key
    ) INTO v_tracker_exists;
    
    -- Get current active channels for this specific cost currency
    SELECT array_agg(DISTINCT ch.name ORDER BY ch.name)
    INTO v_active_channels
    FROM inventory_pools ip
    JOIN channels ch ON ip.channel_id = ch.id
    JOIN game_accounts ga ON ip.game_account_id = ga.id
    WHERE ip.game_code = p_game_code
      AND ip.currency_attribute_id = p_currency_attribute_id
      AND ip.cost_currency = p_cost_currency
      AND ga.is_active = true
      AND (ip.quantity - COALESCE(ip.reserved_quantity, 0)) > 0;
    
    -- Get array length safely
    v_array_length := COALESCE(array_length(v_active_channels, 1), 0);
    
    -- If no channels found, don't create/update tracker
    IF v_array_length = 0 THEN
        -- Delete tracker if exists since no active channels
        DELETE FROM assignment_trackers 
        WHERE assignment_type = 'inventory_pool_rotation'
          AND assignment_group_key = v_tracker_key;
        RETURN;
    END IF;
    
    -- Get existing tracker only if it exists
    IF v_tracker_exists THEN
        SELECT employee_rotation_order, current_rotation_index
        INTO v_current_channels, v_current_index
        FROM assignment_trackers 
        WHERE assignment_type = 'inventory_pool_rotation'
          AND assignment_group_key = v_tracker_key
        FOR UPDATE;
        
        -- Extract old channels for comparison
        SELECT array_agg(element ORDER BY element) INTO v_old_channels
        FROM jsonb_array_elements_text(v_current_channels) AS element;
        
        -- Check if channels have changed
        IF NOT (v_old_channels = v_active_channels) THEN
            v_has_changed := TRUE;
        END IF;
    END IF;
    
    -- Create tracker if doesn't exist
    IF NOT v_tracker_exists THEN
        INSERT INTO assignment_trackers (
            assignment_type, assignment_group_key, employee_rotation_order,
            current_rotation_index, available_count, order_type_filter, business_domain,
            priority_ordering, max_consecutive_assignments, reset_frequency_hours,
            description
        ) VALUES (
            'inventory_pool_rotation', v_tracker_key,
            to_jsonb(v_active_channels),
            0, v_array_length, 'SELL', 'CURRENCY_TRADING',
            'CHANNEL_FIFO', 999, 24,
            format('Auto-created channel rotation for %s: %s', p_cost_currency, p_base_key)
        );
        RETURN;
    END IF;
    
    -- Update tracker ONLY if channels have changed
    IF v_has_changed THEN
        UPDATE assignment_trackers 
        SET 
            employee_rotation_order = to_jsonb(v_active_channels),
            available_count = v_array_length,
            current_rotation_index = 0,  -- Reset to 0 when channels change
            description = format('Channel rotation reset for %s: %s → %s (Index: 0)', 
                             p_cost_currency,
                             array_to_string(v_old_channels, ', '),
                             array_to_string(v_active_channels, ', ')),
            updated_at = NOW()
        WHERE assignment_type = 'inventory_pool_rotation'
          AND assignment_group_key = v_tracker_key;
    END IF;
    
    -- If no changes, do NOTHING - preserve current rotation index and last_assigned info
    -- This is the key fix: don't update on every call, only when structure changes
END;
$$;


--
-- Name: update_currency_order_proofs(uuid, jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_currency_order_proofs(p_order_id uuid, p_proofs jsonb) RETURNS TABLE(success boolean, message text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_order_exists BOOLEAN;
    v_current_user_id UUID;
    v_bot_profile_id UUID DEFAULT '3c6f63c0-6cc5-4e04-9ccc-c5b92a8868dc';  -- Bot (auto) profile ID
    v_existing_proofs JSONB;
    v_final_proofs JSONB;
    v_new_proof JSONB;
    v_index INTEGER;
BEGIN
    -- Get current user profile ID for updated_by
    BEGIN
        SELECT id INTO v_current_user_id FROM get_current_profile_id();
    EXCEPTION WHEN OTHERS THEN
        -- Fixed: Add public.profiles prefix
        SELECT id INTO v_current_user_id FROM public.profiles ORDER BY created_at ASC LIMIT 1;
    END;

    -- Check if order exists
    SELECT EXISTS(SELECT 1 FROM public.currency_orders WHERE id = p_order_id)
    INTO v_order_exists;

    IF NOT v_order_exists THEN
        RETURN QUERY SELECT FALSE, 'Order not found';
        RETURN;
    END IF;

    -- Handle existing proofs - Append instead of replace
    v_existing_proofs := COALESCE(
        (SELECT proofs FROM public.currency_orders WHERE id = p_order_id),
        '[]'::jsonb
    );

    -- Ensure proofs is an array
    IF jsonb_typeof(v_existing_proofs) != 'array' THEN
        v_existing_proofs := '[]'::jsonb;
    END IF;

    -- Convert p_proofs to array if single object
    IF jsonb_typeof(p_proofs) != 'array' THEN
        p_proofs := jsonb_build_array(p_proofs);
    END IF;

    -- Process new proofs and ensure required fields
    v_final_proofs := '[]'::jsonb;

    FOR v_index IN 0..jsonb_array_length(p_proofs) - 1 LOOP
        v_new_proof := jsonb_extract_path(p_proofs, v_index::TEXT);

        -- Ensure required fields exist
        IF v_new_proof ? 'url' AND v_new_proof ? 'type' THEN
            -- Set uploaded_at and uploaded_by if not present
            IF NOT (v_new_proof ? 'uploaded_at') THEN
                v_new_proof := jsonb_set(v_new_proof, '{uploaded_at}', to_jsonb(NOW()));
            END IF;

            IF NOT (v_new_proof ? 'uploaded_by') THEN
                v_new_proof := jsonb_set(v_new_proof, '{uploaded_by}', to_jsonb(v_bot_profile_id));
            END IF;

            v_final_proofs := v_final_proofs || jsonb_build_array(v_new_proof);
        END IF;
    END LOOP;

    -- Append new proofs to existing proofs
    v_final_proofs := v_existing_proofs || v_final_proofs;

    -- Update order with appended proofs
    UPDATE public.currency_orders
    SET proofs = v_final_proofs,
        status = 'pending',
        submitted_at = NOW(),
        submitted_by = v_bot_profile_id,
        updated_at = NOW(),
        updated_by = v_current_user_id
    WHERE id = p_order_id;

    RETURN QUERY SELECT TRUE,
        format('Successfully added %s proof(s) to order', jsonb_array_length(v_final_proofs) - jsonb_array_length(v_existing_proofs));

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, 'Error updating order proofs: ' || SQLERRM;
END;
$$;


--
-- Name: update_currency_rotation_tracker_with_detection(text, text, uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_currency_rotation_tracker_with_detection(p_base_key text, p_game_code text, p_currency_attribute_id uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_current_currencies JSONB;
    v_tracker_key TEXT;
    v_current_index INTEGER;
    v_active_currencies TEXT[];
    v_array_length INTEGER;
    v_old_currencies TEXT[];
    v_has_changed BOOLEAN := FALSE;
    v_tracker_exists BOOLEAN := FALSE;
BEGIN
    -- Build tracker key
    v_tracker_key := p_base_key || '_CURRENCY';
    
    -- Check if tracker exists
    SELECT EXISTS(
        SELECT 1 FROM assignment_trackers 
        WHERE assignment_type = 'inventory_pool_rotation'
          AND assignment_group_key = v_tracker_key
    ) INTO v_tracker_exists;
    
    -- Get current active cost currencies
    SELECT array_agg(DISTINCT ip.cost_currency ORDER BY ip.cost_currency)
    INTO v_active_currencies
    FROM inventory_pools ip
    JOIN game_accounts ga ON ip.game_account_id = ga.id
    WHERE ip.game_code = p_game_code
      AND ip.currency_attribute_id = p_currency_attribute_id
      AND ga.is_active = true
      AND (ip.quantity - COALESCE(ip.reserved_quantity, 0)) > 0;
    
    -- Get array length safely
    v_array_length := COALESCE(array_length(v_active_currencies, 1), 0);
    
    -- If no currencies found, don't create/update tracker
    IF v_array_length = 0 THEN
        -- Delete tracker if exists since no active currencies
        DELETE FROM assignment_trackers 
        WHERE assignment_type = 'inventory_pool_rotation'
          AND assignment_group_key = v_tracker_key;
        RETURN;
    END IF;
    
    -- Get existing tracker only if it exists
    IF v_tracker_exists THEN
        SELECT employee_rotation_order, current_rotation_index
        INTO v_current_currencies, v_current_index
        FROM assignment_trackers 
        WHERE assignment_type = 'inventory_pool_rotation'
          AND assignment_group_key = v_tracker_key
        FOR UPDATE;
        
        -- Extract old currencies for comparison
        SELECT array_agg(element ORDER BY element) INTO v_old_currencies
        FROM jsonb_array_elements_text(v_current_currencies) AS element;
        
        -- Check if currencies have changed
        IF NOT (v_old_currencies = v_active_currencies) THEN
            v_has_changed := TRUE;
        END IF;
    END IF;
    
    -- Create tracker if doesn't exist
    IF NOT v_tracker_exists THEN
        INSERT INTO assignment_trackers (
            assignment_type, assignment_group_key, employee_rotation_order,
            current_rotation_index, available_count, order_type_filter, business_domain,
            priority_ordering, max_consecutive_assignments, reset_frequency_hours,
            description
        ) VALUES (
            'inventory_pool_rotation', v_tracker_key,
            to_jsonb(v_active_currencies),
            0, v_array_length, 'SELL', 'CURRENCY_TRADING',
            'CURRENCY_FIFO', 999, 24,
            format('Auto-created currency rotation for %s', p_base_key)
        );
        RETURN;
    END IF;
    
    -- Update tracker ONLY if currencies have changed
    IF v_has_changed THEN
        UPDATE assignment_trackers 
        SET 
            employee_rotation_order = to_jsonb(v_active_currencies),
            available_count = v_array_length,
            current_rotation_index = 0,  -- Reset to 0 when currencies change
            description = format('Currency rotation reset: %s → %s (Index: 0)', 
                             array_to_string(v_old_currencies, ', '),
                             array_to_string(v_active_currencies, ', ')),
            updated_at = NOW()
        WHERE assignment_type = 'inventory_pool_rotation'
          AND assignment_group_key = v_tracker_key;
    END IF;
    
    -- If no changes, do NOTHING - preserve current rotation index and last_assigned info
END;
$$;


--
-- Name: update_customer_accounts_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_customer_accounts_updated_at() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


--
-- Name: update_delivery_proof(uuid, text, uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_delivery_proof(p_order_id uuid, p_proof_url text, p_user_id uuid) RETURNS TABLE(success boolean, message text, updated_proofs jsonb)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_order RECORD;
    v_new_proof JSONB;
    v_updated_proofs JSONB;
BEGIN
    -- Validate order
    SELECT * INTO v_order FROM currency_orders
    WHERE id = p_order_id AND order_type = 'SALE';

    IF v_order IS NULL THEN
        RETURN QUERY SELECT false, 'Order not found or not a sale order', NULL::JSONB;
        RETURN;
    END IF;

    -- Create new proof object
    v_new_proof := jsonb_build_object(
        'type', 'delivery_proof',
        'url', p_proof_url,
        'uploaded_at', NOW(),
        'uploaded_by', p_user_id
    );

    -- Update proofs
    v_updated_proofs := COALESCE(v_order.proofs, '[]'::JSONB) || v_new_proof;

    UPDATE currency_orders SET
        proofs = v_updated_proofs,
        updated_at = NOW(),
        updated_by = p_user_id
    WHERE id = p_order_id;

    RETURN QUERY SELECT true, 'Delivery proof updated successfully', v_updated_proofs;
END;
$$;


--
-- Name: update_fee_direct(uuid, text, text, text, text, numeric, text, boolean); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_fee_direct(p_fee_id uuid, p_code text, p_name text, p_direction text, p_fee_type text, p_amount numeric, p_currency text, p_is_active boolean DEFAULT true) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
  v_fee_exists BOOLEAN;
BEGIN
  -- Check if fee exists
  SELECT EXISTS(SELECT 1 FROM fees WHERE id = p_fee_id) INTO v_fee_exists;

  IF NOT v_fee_exists THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Không tìm thấy phí'
    );
  END IF;

  -- Update fee (this bypasses RLS due to SECURITY DEFINER)
  UPDATE fees
  SET
    code = p_code,
    name = p_name,
    direction = p_direction,
    fee_type = p_fee_type,
    amount = p_amount,
    currency = p_currency,
    is_active = p_is_active,
    created_at = NOW()
  WHERE id = p_fee_id;

  RETURN jsonb_build_object(
    'success', true,
    'message', 'Cập nhật phí thành công',
    'fee_id', p_fee_id
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Lỗi khi cập nhật phí: ' || SQLERRM
    );
END;
$$;


--
-- Name: update_game_account_direct(uuid, text, text, text, text, boolean); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_game_account_direct(p_account_id uuid, p_game_code text, p_account_name text, p_purpose text DEFAULT 'INVENTORY'::text, p_server_attribute_code text DEFAULT NULL::text, p_is_active boolean DEFAULT true) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
  v_account_exists BOOLEAN;
  v_account_name TEXT;
BEGIN
  -- Check if account exists
  SELECT EXISTS(SELECT 1 FROM game_accounts WHERE id = p_account_id) INTO v_account_exists;

  IF NOT v_account_exists THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Không tìm thấy tài khoản game'
    );
  END IF;

  -- Get current account name for response
  SELECT account_name INTO v_account_name FROM game_accounts WHERE id = p_account_id;

  -- Update game account (this bypasses RLS due to SECURITY DEFINER)
  UPDATE game_accounts
  SET
    game_code = p_game_code,
    account_name = p_account_name,
    purpose = p_purpose,
    server_attribute_code = p_server_attribute_code,
    is_active = p_is_active,
    updated_at = NOW()
  WHERE id = p_account_id;

  RETURN jsonb_build_object(
    'success', true,
    'message', 'Cập nhật tài khoản game thành công',
    'account_id', p_account_id,
    'account_name', v_account_name,
    'game_code', p_game_code
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Lỗi khi cập nhật tài khoản game: ' || SQLERRM
    );
END;
$$;


--
-- Name: update_inventory_avg_cost(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_inventory_avg_cost() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
    -- Update average cost when inventory changes
    IF TG_OP = 'INSERT' THEN
        -- For new inventory, set the average cost
        NEW.avg_buy_price := public.calculate_avg_cost_by_channel(
            NEW.channel_id, 
            NEW.currency_attribute_id, 
            NEW.game_code, 
            NEW.league_attribute_id
        );
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        -- For updated inventory, recalculate average cost
        NEW.avg_buy_price := public.calculate_avg_cost_by_channel(
            NEW.channel_id, 
            NEW.currency_attribute_id, 
            NEW.game_code, 
            NEW.league_attribute_id
        );
        RETURN NEW;
    END IF;
    
    RETURN NULL;
END;
$$;


--
-- Name: update_inventory_pool_rotation_tracker(uuid, text, uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_inventory_pool_rotation_tracker(p_inventory_pool_id uuid, p_game_code text, p_currency_attribute_id uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
    -- Update rotation tracker - explicit schema
    UPDATE public.inventory_pool_rotation_tracker
    SET last_used_at = NOW(),
        usage_count = usage_count + 1
    WHERE inventory_pool_id = p_inventory_pool_id
      AND game_code = p_game_code
      AND currency_attribute_id = p_currency_attribute_id;
    
    -- If no record exists, create one
    IF NOT FOUND THEN
        INSERT INTO public.inventory_pool_rotation_tracker (
            inventory_pool_id,
            game_code,
            currency_attribute_id,
            last_used_at,
            usage_count
        ) VALUES (
            p_inventory_pool_id,
            p_game_code,
            p_currency_attribute_id,
            NOW(),
            1
        );
    END IF;
END;
$$;


--
-- Name: update_order_details_v1(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_order_details_v1() RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
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
  FROM order_lines ol
  JOIN orders o ON ol.order_id = o.id
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
  UPDATE order_lines
  SET deadline_to = p_deadline
  WHERE id = p_line_id;

  -- 3.2 Cập nhật package_note trên orders
  UPDATE orders
  SET package_note = p_package_note
  WHERE id = v_order_id;

  -- 3.3 Cập nhật thông tin tài khoản khách hàng (nếu có)
  IF v_customer_account_id IS NOT NULL THEN
    UPDATE customer_accounts
    SET 
      btag = p_btag,
      login_id = p_login_id,
      login_pwd = p_login_pwd
    WHERE id = v_customer_account_id;
  END IF;

  -- 3.4 Cập nhật Service Type (thông qua product_variant)
  IF p_service_type IS NOT NULL THEN
    SELECT prod.id INTO v_product_id FROM products prod WHERE prod.name = 'Boosting Service' LIMIT 1;
    
    IF v_product_id IS NOT NULL THEN
      v_variant_name := 'Service-' || lower(p_service_type);

      WITH new_variant AS (
        INSERT INTO product_variants (product_id, display_name)
        VALUES (v_product_id, v_variant_name)
        ON CONFLICT (product_id, display_name) DO UPDATE SET display_name = EXCLUDED.display_name
        RETURNING id
      )
      SELECT id INTO v_variant_id FROM new_variant;

      UPDATE order_lines
      SET variant_id = v_variant_id
      WHERE id = p_line_id;
    END IF;
  END IF;

END;
$$;


--
-- Name: update_order_details_v1(uuid, text, timestamp with time zone, text, text, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_order_details_v1(p_line_id uuid, p_service_type text, p_deadline timestamp with time zone, p_package_note text, p_btag text, p_login_id text, p_login_pwd text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
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
  FROM order_lines ol
  JOIN orders o ON ol.order_id = o.id
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
  UPDATE order_lines
  SET deadline_to = p_deadline
  WHERE id = p_line_id;

  -- 3.2 Cập nhật package_note trên orders
  UPDATE orders
  SET package_note = p_package_note
  WHERE id = v_order_id;

  -- 3.3 Cập nhật thông tin tài khoản khách hàng (nếu có)
  IF v_customer_account_id IS NOT NULL THEN
    UPDATE customer_accounts
    SET
      btag = p_btag,
      login_id = p_login_id,
      login_pwd = p_login_pwd
    WHERE id = v_customer_account_id;
  END IF;

  -- 3.4 Cập nhật Service Type (thông qua product_variant)
  IF p_service_type IS NOT NULL THEN
    SELECT prod.id INTO v_product_id FROM products prod WHERE prod.name = 'Boosting Service' LIMIT 1;

    IF v_product_id IS NOT NULL THEN
      v_variant_name := 'Service-' || lower(p_service_type);

      WITH new_variant AS (
        INSERT INTO product_variants (product_id, display_name)
        VALUES (v_product_id, v_variant_name)
        ON CONFLICT (product_id, display_name) DO UPDATE SET display_name = EXCLUDED.display_name
        RETURNING id
      )
      SELECT id INTO v_variant_id FROM new_variant;

      UPDATE order_lines
      SET variant_id = v_variant_id
      WHERE id = p_line_id;
    END IF;
  END IF;

END;
$$;


--
-- Name: update_order_line_machine_info_v1(uuid, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_order_line_machine_info_v1(p_line_id uuid, p_machine_info text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
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


--
-- Name: update_parties_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_parties_updated_at() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


--
-- Name: update_party_info(uuid, text, jsonb, text, uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_party_info(p_party_id uuid, p_name text DEFAULT NULL::text, p_contact_info jsonb DEFAULT NULL::jsonb, p_notes text DEFAULT NULL::text, p_channel_id uuid DEFAULT NULL::uuid) RETURNS TABLE(success boolean, party_id uuid, message text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_existing_party RECORD;
    v_has_changes BOOLEAN := FALSE;
BEGIN
    -- Validate party exists
    SELECT * INTO v_existing_party
    FROM parties
    WHERE id = p_party_id;
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, NULL::UUID, 'Party not found';
        RETURN;
    END IF;
    
    -- Check for changes and update if needed
    IF p_name IS NOT NULL AND p_name != v_existing_party.name THEN
        UPDATE parties SET name = p_name WHERE id = p_party_id;
        v_has_changes := TRUE;
    END IF;
    
    IF p_contact_info IS NOT NULL AND p_contact_info != v_existing_party.contact_info THEN
        UPDATE parties SET contact_info = p_contact_info WHERE id = p_party_id;
        v_has_changes := TRUE;
    END IF;
    
    IF p_notes IS NOT NULL AND p_notes != v_existing_party.notes THEN
        UPDATE parties SET notes = p_notes WHERE id = p_party_id;
        v_has_changes := TRUE;
    END IF;
    
    IF p_channel_id IS NOT NULL AND p_channel_id != v_existing_party.channel_id THEN
        UPDATE parties SET channel_id = p_channel_id WHERE id = p_party_id;
        v_has_changes := TRUE;
    END IF;
    
    -- Update timestamp if any changes were made
    IF v_has_changes THEN
        UPDATE parties SET updated_at = NOW() WHERE id = p_party_id;
    END IF;
    
    RETURN QUERY SELECT 
        TRUE, 
        p_party_id, 
        CASE WHEN v_has_changes 
             THEN 'Party information updated successfully' 
             ELSE 'No changes detected' 
        END;
END;
$$;


--
-- Name: update_pilot_cycle_warning(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_pilot_cycle_warning(p_order_line_id uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
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


--
-- Name: update_profile_status(uuid, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_profile_status(p_profile_id uuid, p_new_status text, p_change_reason text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
  v_old_status TEXT;
  v_updated_count INTEGER;
BEGIN
  -- Get current status
  SELECT status INTO v_old_status FROM profiles WHERE id = p_profile_id;
  
  IF v_old_status IS NULL THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Không tìm thấy profile'
    );
  END IF;
  
  -- Update status
  UPDATE profiles 
  SET status = p_new_status, updated_at = NOW()
  WHERE id = p_profile_id
  RETURNING 1 INTO v_updated_count;
  
  IF v_updated_count = 0 THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Không thể cập nhật trạng thái'
    );
  END IF;
  
  -- Log the change
  INSERT INTO profile_status_logs (
    profile_id, 
    old_status, 
    new_status, 
    change_reason, 
    changed_by,
    created_at
  ) VALUES (
    p_profile_id,
    v_old_status,
    p_new_status,
    p_change_reason,
    auth.uid(),
    NOW()
  );
  
  RETURN jsonb_build_object(
    'success', true,
    'message', 'Cập nhật trạng thái thành công'
  );
END;
$$;


--
-- Name: update_profile_status_direct(uuid, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_profile_status_direct(p_profile_id uuid, p_new_status text, p_change_reason text DEFAULT NULL::text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
  v_old_status TEXT;
  v_updated_count INTEGER;
BEGIN
  -- Get current status
  SELECT status INTO v_old_status FROM profiles WHERE id = p_profile_id;
  
  IF v_old_status IS NULL THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Không tìm thấy profile'
    );
  END IF;
  
  -- Update status (this bypasses RLS due to SECURITY DEFINER)
  UPDATE profiles 
  SET status = p_new_status, updated_at = NOW()
  WHERE id = p_profile_id
  RETURNING 1 INTO v_updated_count;
  
  IF v_updated_count = 0 THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Không thể cập nhật trạng thái'
    );
  END IF;
  
  -- Log the change with reason
  INSERT INTO profile_status_logs (
    profile_id,
    old_status,
    new_status,
    change_reason,
    changed_by,
    created_at
  ) VALUES (
    p_profile_id,
    v_old_status,
    p_new_status,
    p_change_reason,
    auth.uid(),
    NOW()
  );
  
  RETURN jsonb_build_object(
    'success', true,
    'message', 'Cập nhật trạng thái thành công'
  );
END;
$$;


--
-- Name: update_sell_order_proofs(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_sell_order_proofs() RETURNS TABLE(order_id uuid, proof_count integer, last_updated timestamp with time zone)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        o.id as order_id,
        COUNT(pf.id) as proof_count,
        MAX(pf.created_at) as last_updated
    FROM orders o
    LEFT JOIN proof_files pf ON o.id = pf.order_id
    WHERE o.order_type = 'currency_sell'
      AND o.status IN ('completed', 'delivered')
    GROUP BY o.id
    ORDER BY o.created_at DESC
    LIMIT 10;
END;
$$;


--
-- Name: update_shift_assignment_direct(uuid, uuid, uuid, uuid, uuid, text, boolean); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_shift_assignment_direct(p_assignment_id uuid, p_game_account_id uuid, p_employee_profile_id uuid, p_shift_id uuid, p_channels_id uuid, p_currency_code text DEFAULT 'VND'::text, p_is_active boolean DEFAULT true) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
  v_assignment_exists BOOLEAN;
BEGIN
  -- Check if assignment exists
  SELECT EXISTS(SELECT 1 FROM shift_assignments WHERE id = p_assignment_id) INTO v_assignment_exists;

  IF NOT v_assignment_exists THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Không tìm thấy phân công ca làm việc'
    );
  END IF;

  -- Update shift assignment (this bypasses RLS due to SECURITY DEFINER)
  UPDATE shift_assignments
  SET
    game_account_id = p_game_account_id,
    employee_profile_id = p_employee_profile_id,
    shift_id = p_shift_id,
    channels_id = p_channels_id,
    currency_code = p_currency_code,
    is_active = p_is_active,
    assigned_at = NOW()
  WHERE id = p_assignment_id;

  RETURN jsonb_build_object(
    'success', true,
    'message', 'Cập nhật phân công ca làm việc thành công',
    'assignment_id', p_assignment_id
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Lỗi khi cập nhật phân công ca làm việc: ' || SQLERRM
    );
END;
$$;


--
-- Name: update_work_shift_direct(uuid, text, time without time zone, time without time zone, text, boolean); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_work_shift_direct(p_shift_id uuid, p_name text, p_start_time time without time zone, p_end_time time without time zone, p_description text DEFAULT NULL::text, p_is_active boolean DEFAULT true) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
  v_shift_exists BOOLEAN;
  v_shift_name TEXT;
BEGIN
  -- Check if shift exists
  SELECT EXISTS(SELECT 1 FROM work_shifts WHERE id = p_shift_id) INTO v_shift_exists;

  IF NOT v_shift_exists THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Không tìm thấy ca làm việc'
    );
  END IF;

  -- Get current shift name for response
  SELECT name INTO v_shift_name FROM work_shifts WHERE id = p_shift_id;

  -- Update work shift (this bypasses RLS due to SECURITY DEFINER)
  UPDATE work_shifts
  SET
    name = p_name,
    start_time = p_start_time,
    end_time = p_end_time,
    description = p_description,
    is_active = p_is_active,
    updated_at = NOW()
  WHERE id = p_shift_id;

  RETURN jsonb_build_object(
    'success', true,
    'message', 'Cập nhật ca làm việc thành công',
    'shift_id', p_shift_id,
    'shift_name', v_shift_name
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Lỗi khi cập nhật ca làm việc: ' || SQLERRM
    );
END;
$$;


--
-- Name: validate_and_refresh_assignment_tracker(uuid, text, uuid, text, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.validate_and_refresh_assignment_tracker(p_channel_id uuid, p_currency_code text, p_shift_id uuid, p_order_type_filter text, p_game_code text, p_server_attribute_code text DEFAULT NULL::text) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_group_key TEXT;
    v_tracker_id UUID;
    v_current_employees JSON;
    v_expected_employees JSON;
    v_current_count INTEGER;
    v_expected_count INTEGER;
    v_needs_refresh BOOLEAN := FALSE;
    v_current_employee_ids TEXT[];
    v_expected_employee_ids TEXT[];
    v_invalid_employee TEXT;
    v_elem TEXT;
BEGIN
    -- Build group key format used by assign_purchase_order
    v_group_key := format('%s|%s|%s|%s|%s|%s', 
        p_channel_id, p_currency_code, p_game_code, 
        COALESCE(p_server_attribute_code, 'ANY_SERVER'), 
        p_shift_id, p_order_type_filter);
    
    -- Get existing tracker
    SELECT id, employee_rotation_order, available_count
    INTO v_tracker_id, v_current_employees, v_current_count
    FROM assignment_trackers 
    WHERE assignment_group_key = v_group_key;
    
    -- No tracker exists, no validation needed
    IF v_tracker_id IS NULL THEN
        RETURN FALSE;
    END IF;
    
    -- Get expected employees for current conditions
    WITH available_employees AS (
        SELECT sa.employee_profile_id::text as employee_id
        FROM shift_assignments sa
        JOIN profiles p ON sa.employee_profile_id = p.id
        JOIN game_accounts ga ON sa.game_account_id = ga.id
        WHERE sa.channels_id = p_channel_id
          AND sa.currency_code = p_currency_code
          AND sa.shift_id = p_shift_id
          AND sa.is_active = true
          AND p.status = 'active'
          AND ga.is_active = true
          AND ga.game_code = p_game_code
          AND (ga.server_attribute_code = p_server_attribute_code OR ga.server_attribute_code IS NULL)
        ORDER BY p.display_name
    )
    SELECT json_agg(employee_id), COUNT(*)
    INTO v_expected_employees, v_expected_count
    FROM available_employees;
    
    -- No expected employees, mark for refresh
    IF v_expected_employees IS NULL OR v_expected_count = 0 THEN
        RAISE LOG '[VALIDATE_TRACKER] No available employees found for group: %s', v_group_key;
        DELETE FROM assignment_trackers WHERE id = v_tracker_id;
        RETURN TRUE;
    END IF;
    
    -- Count mismatch: refresh needed
    IF v_current_count != v_expected_count THEN
        RAISE LOG '[VALIDATE_TRACKER] Count mismatch: current=%d, expected=%d for group: %s', 
                   v_current_count, v_expected_count, v_group_key;
        v_needs_refresh := TRUE;
    END IF;
    
    -- Extract current employee IDs from JSON
    IF v_current_employees IS NOT NULL THEN
        v_current_employee_ids := ARRAY(
            SELECT elem::text 
            FROM json_array_elements_text(v_current_employees) elem
        );
    END IF;
    
    -- Extract expected employee IDs from JSON
    IF v_expected_employees IS NOT NULL THEN
        v_expected_employee_ids := ARRAY(
            SELECT elem::text 
            FROM json_array_elements_text(v_expected_employees) elem
        );
    END IF;
    
    -- Check for invalid employees (employees in tracker who no longer meet criteria)
    IF v_current_employee_ids IS NOT NULL THEN
        FOREACH v_invalid_employee IN ARRAY v_current_employee_ids
        LOOP
            IF NOT (v_invalid_employee = ANY(v_expected_employee_ids)) THEN
                RAISE LOG '[VALIDATE_TRACKER] Invalid employee found in tracker: %s for group: %s', 
                           v_invalid_employee, v_group_key;
                v_needs_refresh := TRUE;
                EXIT;
            END IF;
        END LOOP;
    END IF;
    
    -- Refresh tracker if needed
    IF v_needs_refresh THEN
        RAISE LOG '[VALIDATE_TRACKER] Refreshing tracker for group: %s', v_group_key;
        
        DELETE FROM assignment_trackers WHERE id = v_tracker_id;
        
        -- Create new tracker with updated data
        INSERT INTO assignment_trackers (
            assignment_type,
            assignment_group_key,
            last_assigned_employee_id,
            employee_rotation_order,
            current_rotation_index,
            available_count,
            order_type_filter,
            business_domain,
            priority_ordering,
            max_consecutive_assignments,
            reset_frequency_hours,
            last_reset_at,
            description,
            created_at
        ) VALUES (
            'round_robin_employee_rotation',
            v_group_key,
            COALESCE((v_expected_employee_ids[1])::uuid, '00000000-0000-0000-0000-000000000000'::uuid),
            COALESCE(v_expected_employees, '[]'::json),
            0,
            v_expected_count,
            p_order_type_filter,
            'CURRENCY_TRADING',
            'ALPHABETICAL',
            10,
            24,
            NOW(),
            format('Auto-refreshed tracker for %s orders - %s channel, Currency: %s, Game: %s, Server: %s, Shift: %s', 
                   p_order_type_filter,
                   (SELECT code FROM channels WHERE id = p_channel_id),
                   p_currency_code,
                   p_game_code,
                   COALESCE(p_server_attribute_code, 'ANY_SERVER'),
                   (SELECT name FROM work_shifts WHERE id = p_shift_id)),
            NOW()
        );
        
        RETURN TRUE;
    END IF;
    
    RETURN FALSE;
END;
$$;


--
-- Name: validate_business_processes_channels_currencies(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.validate_business_processes_channels_currencies() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
    -- Validate sale_channel_id if provided
    IF NEW.sale_channel_id IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM public.channels 
            WHERE id = NEW.sale_channel_id AND is_active = true
        ) THEN
            RAISE EXCEPTION 'Sale channel ID "%" does not exist or is not active', NEW.sale_channel_id;
        END IF;
    END IF;
    
    -- Validate purchase_channel_id if provided
    IF NEW.purchase_channel_id IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM public.channels 
            WHERE id = NEW.purchase_channel_id AND is_active = true
        ) THEN
            RAISE EXCEPTION 'Purchase channel ID "%" does not exist or is not active', NEW.purchase_channel_id;
        END IF;
    END IF;
    
    -- Validate sale_currency
    IF NOT EXISTS (
        SELECT 1 FROM public.currencies 
        WHERE code = NEW.sale_currency AND is_active = true
    ) THEN
        RAISE EXCEPTION 'Sale currency code "%" does not exist or is not active', NEW.sale_currency;
    END IF;
    
    -- Validate purchase_currency
    IF NOT EXISTS (
        SELECT 1 FROM public.currencies 
        WHERE code = NEW.purchase_currency AND is_active = true
    ) THEN
        RAISE EXCEPTION 'Purchase currency code "%" does not exist or is not active', NEW.purchase_currency;
    END IF;
    
    RETURN NEW;
END;
$$;


--
-- Name: validate_business_processes_sale_channels_currencies(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.validate_business_processes_sale_channels_currencies() RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
    -- Validate sale_channel_id if provided
    IF NEW.sale_channel_id IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM channels 
            WHERE id = NEW.sale_channel_id AND is_active = true
        ) THEN
            RAISE EXCEPTION 'Sale channel ID "%" does not exist or is not active', NEW.sale_channel_id;
        END IF;
    END IF;
    
    -- Validate sale_currency
    IF NOT EXISTS (
        SELECT 1 FROM currencies 
        WHERE code = NEW.sale_currency AND is_active = true
    ) THEN
        RAISE EXCEPTION 'Sale currency code "%" does not exist or is not active', NEW.sale_currency;
    END IF;
    
    RETURN NEW;
END;
$$;


--
-- Name: validate_currency_server_scope(uuid, uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.validate_currency_server_scope(p_currency_attribute_id uuid, p_server_attribute_id uuid) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_currency_game_code TEXT;
    v_server_game_code TEXT;
    v_is_valid BOOLEAN := FALSE;
BEGIN
    -- Extract game code from currency code
    SELECT 
        CASE 
            WHEN code LIKE '%POE1%' THEN 'POE_1'
            WHEN code LIKE '%POE2%' THEN 'POE_2'
            WHEN code LIKE '%D4%' THEN 'DIABLO_4'
            ELSE NULL
        END INTO v_currency_game_code
    FROM attributes 
    WHERE id = p_currency_attribute_id AND type = 'GAME_CURRENCY';
    
    -- Extract game code from server code
    SELECT 
        CASE 
            WHEN code LIKE '%POE1%' THEN 'POE_1'
            WHEN code LIKE '%POE2%' THEN 'POE_2'
            WHEN code LIKE '%D4%' THEN 'DIABLO_4'
            ELSE NULL
        END INTO v_server_game_code
    FROM attributes 
    WHERE id = p_server_attribute_id AND type = 'GAME_SERVER';
    
    -- Validate they match
    v_is_valid := (v_currency_game_code = v_server_game_code AND v_currency_game_code IS NOT NULL);
    
    RETURN v_is_valid;
END;
$$;


--
-- Name: FUNCTION validate_currency_server_scope(p_currency_attribute_id uuid, p_server_attribute_id uuid); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.validate_currency_server_scope(p_currency_attribute_id uuid, p_server_attribute_id uuid) IS 'Validate if a currency belongs to the same game as the server/league/season';


--
-- Name: validate_inventory_pools_channel_id(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.validate_inventory_pools_channel_id(p_channel_id uuid) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
DECLARE
    is_valid boolean := false;
BEGIN
    SELECT EXISTS(
        SELECT 1 FROM channels 
        WHERE id = p_channel_id AND is_active = true
    ) INTO is_valid;
    
    RETURN is_valid;
END;
$$;


--
-- Name: validate_sell_order_inventory_availability(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.validate_sell_order_inventory_availability(p_order_id uuid) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
DECLARE
    is_valid boolean := false;
BEGIN
    SELECT EXISTS(
        SELECT 1 FROM inventory_pools ip
        JOIN order_items oi ON ip.currency_code = oi.currency_code
        WHERE oi.order_id = p_order_id
          AND ip.available_quantity >= oi.quantity
          AND ip.is_active = true
    ) INTO is_valid;
    
    RETURN is_valid;
END;
$$;


--
-- Name: apply_rls(jsonb, integer); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer DEFAULT (1024 * 1024)) RETURNS SETOF realtime.wal_rls
    LANGUAGE plpgsql
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


--
-- Name: broadcast_changes(text, text, text, text, text, record, record, text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text DEFAULT 'ROW'::text) RETURNS void
    LANGUAGE plpgsql
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


--
-- Name: build_prepared_statement_sql(text, regclass, realtime.wal_column[]); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) RETURNS text
    LANGUAGE sql
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


--
-- Name: cast(text, regtype); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime."cast"(val text, type_ regtype) RETURNS jsonb
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    declare
      res jsonb;
    begin
      execute format('select to_jsonb(%L::'|| type_::text || ')', val)  into res;
      return res;
    end
    $$;


--
-- Name: check_equality_op(realtime.equality_op, regtype, text, text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
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


--
-- Name: is_visible_through_filters(realtime.wal_column[], realtime.user_defined_filter[]); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) RETURNS boolean
    LANGUAGE sql IMMUTABLE
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


--
-- Name: list_changes(name, name, integer, integer); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) RETURNS SETOF realtime.wal_rls
    LANGUAGE sql
    SET log_min_messages TO 'fatal'
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


--
-- Name: quote_wal2json(regclass); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.quote_wal2json(entity regclass) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
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


--
-- Name: send(jsonb, text, text, boolean); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean DEFAULT true) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  generated_id uuid;
  final_payload jsonb;
BEGIN
  BEGIN
    -- Generate a new UUID for the id
    generated_id := gen_random_uuid();

    -- Check if payload has an 'id' key, if not, add the generated UUID
    IF payload ? 'id' THEN
      final_payload := payload;
    ELSE
      final_payload := jsonb_set(payload, '{id}', to_jsonb(generated_id));
    END IF;

    -- Set the topic configuration
    EXECUTE format('SET LOCAL realtime.topic TO %L', topic);

    -- Attempt to insert the message
    INSERT INTO realtime.messages (id, payload, event, topic, private, extension)
    VALUES (generated_id, final_payload, event, topic, private, 'broadcast');
  EXCEPTION
    WHEN OTHERS THEN
      -- Capture and notify the error
      RAISE WARNING 'ErrorSendingBroadcastMessage: %', SQLERRM;
  END;
END;
$$;


--
-- Name: subscription_check_filters(); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.subscription_check_filters() RETURNS trigger
    LANGUAGE plpgsql
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


--
-- Name: to_regrole(text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.to_regrole(role_name text) RETURNS regrole
    LANGUAGE sql IMMUTABLE
    AS $$ select role_name::regrole $$;


--
-- Name: topic(); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.topic() RETURNS text
    LANGUAGE sql STABLE
    AS $$
select nullif(current_setting('realtime.topic', true), '')::text;
$$;


--
-- Name: add_prefixes(text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.add_prefixes(_bucket_id text, _name text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
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


--
-- Name: can_insert_object(text, text, uuid, jsonb); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.can_insert_object(bucketid text, name text, owner uuid, metadata jsonb) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "storage"."objects" ("bucket_id", "name", "owner", "metadata") VALUES (bucketid, name, owner, metadata);
  -- hack to rollback the successful insert
  RAISE sqlstate 'PT200' using
  message = 'ROLLBACK',
  detail = 'rollback successful insert';
END
$$;


--
-- Name: delete_leaf_prefixes(text[], text[]); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.delete_leaf_prefixes(bucket_ids text[], names text[]) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
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


--
-- Name: delete_prefix(text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.delete_prefix(_bucket_id text, _name text) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
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


--
-- Name: delete_prefix_hierarchy_trigger(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.delete_prefix_hierarchy_trigger() RETURNS trigger
    LANGUAGE plpgsql
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


--
-- Name: enforce_bucket_name_length(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.enforce_bucket_name_length() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    if length(new.name) > 100 then
        raise exception 'bucket name "%" is too long (% characters). Max is 100.', new.name, length(new.name);
    end if;
    return new;
end;
$$;


--
-- Name: extension(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.extension(name text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
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


--
-- Name: filename(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.filename(name text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
_parts text[];
BEGIN
	select string_to_array(name, '/') into _parts;
	return _parts[array_length(_parts,1)];
END
$$;


--
-- Name: foldername(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.foldername(name text) RETURNS text[]
    LANGUAGE plpgsql IMMUTABLE
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


--
-- Name: get_level(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.get_level(name text) RETURNS integer
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
SELECT array_length(string_to_array("name", '/'), 1);
$$;


--
-- Name: get_prefix(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.get_prefix(name text) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
SELECT
    CASE WHEN strpos("name", '/') > 0 THEN
             regexp_replace("name", '[\/]{1}[^\/]+\/?$', '')
         ELSE
             ''
        END;
$_$;


--
-- Name: get_prefixes(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.get_prefixes(name text) RETURNS text[]
    LANGUAGE plpgsql IMMUTABLE STRICT
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


--
-- Name: get_size_by_bucket(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.get_size_by_bucket() RETURNS TABLE(size bigint, bucket_id text)
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    return query
        select sum((metadata->>'size')::bigint) as size, obj.bucket_id
        from "storage".objects as obj
        group by obj.bucket_id;
END
$$;


--
-- Name: list_multipart_uploads_with_delimiter(text, text, text, integer, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.list_multipart_uploads_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, next_key_token text DEFAULT ''::text, next_upload_token text DEFAULT ''::text) RETURNS TABLE(key text, id text, created_at timestamp with time zone)
    LANGUAGE plpgsql
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


--
-- Name: list_objects_with_delimiter(text, text, text, integer, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.list_objects_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, start_after text DEFAULT ''::text, next_token text DEFAULT ''::text) RETURNS TABLE(name text, id uuid, metadata jsonb, updated_at timestamp with time zone)
    LANGUAGE plpgsql
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


--
-- Name: lock_top_prefixes(text[], text[]); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.lock_top_prefixes(bucket_ids text[], names text[]) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
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


--
-- Name: objects_delete_cleanup(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.objects_delete_cleanup() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
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


--
-- Name: objects_insert_prefix_trigger(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.objects_insert_prefix_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    PERFORM "storage"."add_prefixes"(NEW."bucket_id", NEW."name");
    NEW.level := "storage"."get_level"(NEW."name");

    RETURN NEW;
END;
$$;


--
-- Name: objects_update_cleanup(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.objects_update_cleanup() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
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


--
-- Name: objects_update_level_trigger(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.objects_update_level_trigger() RETURNS trigger
    LANGUAGE plpgsql
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


--
-- Name: objects_update_prefix_trigger(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.objects_update_prefix_trigger() RETURNS trigger
    LANGUAGE plpgsql
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


--
-- Name: operation(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.operation() RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    RETURN current_setting('storage.operation', true);
END;
$$;


--
-- Name: prefixes_delete_cleanup(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.prefixes_delete_cleanup() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
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


--
-- Name: prefixes_insert_trigger(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.prefixes_insert_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    PERFORM "storage"."add_prefixes"(NEW."bucket_id", NEW."name");
    RETURN NEW;
END;
$$;


--
-- Name: search(text, text, integer, integer, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.search(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql
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


--
-- Name: search_legacy_v1(text, text, integer, integer, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.search_legacy_v1(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
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


--
-- Name: search_v1_optimised(text, text, integer, integer, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.search_v1_optimised(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
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


--
-- Name: search_v2(text, text, integer, integer, text, text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.search_v2(prefix text, bucket_name text, limits integer DEFAULT 100, levels integer DEFAULT 1, start_after text DEFAULT ''::text, sort_order text DEFAULT 'asc'::text, sort_column text DEFAULT 'name'::text, sort_column_after text DEFAULT ''::text) RETURNS TABLE(key text, name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
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


--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW; 
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: audit_log_entries; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.audit_log_entries (
    instance_id uuid,
    id uuid NOT NULL,
    payload json,
    created_at timestamp with time zone,
    ip_address character varying(64) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE audit_log_entries; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.audit_log_entries IS 'Auth: Audit trail for user actions.';


--
-- Name: flow_state; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.flow_state (
    id uuid NOT NULL,
    user_id uuid,
    auth_code text NOT NULL,
    code_challenge_method auth.code_challenge_method NOT NULL,
    code_challenge text NOT NULL,
    provider_type text NOT NULL,
    provider_access_token text,
    provider_refresh_token text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    authentication_method text NOT NULL,
    auth_code_issued_at timestamp with time zone
);


--
-- Name: TABLE flow_state; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.flow_state IS 'stores metadata for pkce logins';


--
-- Name: identities; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.identities (
    provider_id text NOT NULL,
    user_id uuid NOT NULL,
    identity_data jsonb NOT NULL,
    provider text NOT NULL,
    last_sign_in_at timestamp with time zone,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    email text GENERATED ALWAYS AS (lower((identity_data ->> 'email'::text))) STORED,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


--
-- Name: TABLE identities; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.identities IS 'Auth: Stores identities associated to a user.';


--
-- Name: COLUMN identities.email; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.identities.email IS 'Auth: Email is a generated column that references the optional email property in the identity_data';


--
-- Name: instances; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.instances (
    id uuid NOT NULL,
    uuid uuid,
    raw_base_config text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


--
-- Name: TABLE instances; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.instances IS 'Auth: Manages users across multiple sites.';


--
-- Name: mfa_amr_claims; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_amr_claims (
    session_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    authentication_method text NOT NULL,
    id uuid NOT NULL
);


--
-- Name: TABLE mfa_amr_claims; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.mfa_amr_claims IS 'auth: stores authenticator method reference claims for multi factor authentication';


--
-- Name: mfa_challenges; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_challenges (
    id uuid NOT NULL,
    factor_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    verified_at timestamp with time zone,
    ip_address inet NOT NULL,
    otp_code text,
    web_authn_session_data jsonb
);


--
-- Name: TABLE mfa_challenges; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.mfa_challenges IS 'auth: stores metadata about challenge requests made';


--
-- Name: mfa_factors; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_factors (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    friendly_name text,
    factor_type auth.factor_type NOT NULL,
    status auth.factor_status NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    secret text,
    phone text,
    last_challenged_at timestamp with time zone,
    web_authn_credential jsonb,
    web_authn_aaguid uuid,
    last_webauthn_challenge_data jsonb
);


--
-- Name: TABLE mfa_factors; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.mfa_factors IS 'auth: stores metadata about factors';


--
-- Name: COLUMN mfa_factors.last_webauthn_challenge_data; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.mfa_factors.last_webauthn_challenge_data IS 'Stores the latest WebAuthn challenge data including attestation/assertion for customer verification';


--
-- Name: oauth_authorizations; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.oauth_authorizations (
    id uuid NOT NULL,
    authorization_id text NOT NULL,
    client_id uuid NOT NULL,
    user_id uuid,
    redirect_uri text NOT NULL,
    scope text NOT NULL,
    state text,
    resource text,
    code_challenge text,
    code_challenge_method auth.code_challenge_method,
    response_type auth.oauth_response_type DEFAULT 'code'::auth.oauth_response_type NOT NULL,
    status auth.oauth_authorization_status DEFAULT 'pending'::auth.oauth_authorization_status NOT NULL,
    authorization_code text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone DEFAULT (now() + '00:03:00'::interval) NOT NULL,
    approved_at timestamp with time zone,
    nonce text,
    CONSTRAINT oauth_authorizations_authorization_code_length CHECK ((char_length(authorization_code) <= 255)),
    CONSTRAINT oauth_authorizations_code_challenge_length CHECK ((char_length(code_challenge) <= 128)),
    CONSTRAINT oauth_authorizations_expires_at_future CHECK ((expires_at > created_at)),
    CONSTRAINT oauth_authorizations_nonce_length CHECK ((char_length(nonce) <= 255)),
    CONSTRAINT oauth_authorizations_redirect_uri_length CHECK ((char_length(redirect_uri) <= 2048)),
    CONSTRAINT oauth_authorizations_resource_length CHECK ((char_length(resource) <= 2048)),
    CONSTRAINT oauth_authorizations_scope_length CHECK ((char_length(scope) <= 4096)),
    CONSTRAINT oauth_authorizations_state_length CHECK ((char_length(state) <= 4096))
);


--
-- Name: oauth_client_states; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.oauth_client_states (
    id uuid NOT NULL,
    provider_type text NOT NULL,
    code_verifier text,
    created_at timestamp with time zone NOT NULL
);


--
-- Name: TABLE oauth_client_states; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.oauth_client_states IS 'Stores OAuth states for third-party provider authentication flows where Supabase acts as the OAuth client.';


--
-- Name: oauth_clients; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.oauth_clients (
    id uuid NOT NULL,
    client_secret_hash text,
    registration_type auth.oauth_registration_type NOT NULL,
    redirect_uris text NOT NULL,
    grant_types text NOT NULL,
    client_name text,
    client_uri text,
    logo_uri text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    client_type auth.oauth_client_type DEFAULT 'confidential'::auth.oauth_client_type NOT NULL,
    CONSTRAINT oauth_clients_client_name_length CHECK ((char_length(client_name) <= 1024)),
    CONSTRAINT oauth_clients_client_uri_length CHECK ((char_length(client_uri) <= 2048)),
    CONSTRAINT oauth_clients_logo_uri_length CHECK ((char_length(logo_uri) <= 2048))
);


--
-- Name: oauth_consents; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.oauth_consents (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    client_id uuid NOT NULL,
    scopes text NOT NULL,
    granted_at timestamp with time zone DEFAULT now() NOT NULL,
    revoked_at timestamp with time zone,
    CONSTRAINT oauth_consents_revoked_after_granted CHECK (((revoked_at IS NULL) OR (revoked_at >= granted_at))),
    CONSTRAINT oauth_consents_scopes_length CHECK ((char_length(scopes) <= 2048)),
    CONSTRAINT oauth_consents_scopes_not_empty CHECK ((char_length(TRIM(BOTH FROM scopes)) > 0))
);


--
-- Name: one_time_tokens; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.one_time_tokens (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    token_type auth.one_time_token_type NOT NULL,
    token_hash text NOT NULL,
    relates_to text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT one_time_tokens_token_hash_check CHECK ((char_length(token_hash) > 0))
);


--
-- Name: refresh_tokens; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.refresh_tokens (
    instance_id uuid,
    id bigint NOT NULL,
    token character varying(255),
    user_id character varying(255),
    revoked boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    parent character varying(255),
    session_id uuid
);


--
-- Name: TABLE refresh_tokens; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.refresh_tokens IS 'Auth: Store of tokens used to refresh JWT tokens once they expire.';


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE; Schema: auth; Owner: -
--

CREATE SEQUENCE auth.refresh_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: auth; Owner: -
--

ALTER SEQUENCE auth.refresh_tokens_id_seq OWNED BY auth.refresh_tokens.id;


--
-- Name: saml_providers; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.saml_providers (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    entity_id text NOT NULL,
    metadata_xml text NOT NULL,
    metadata_url text,
    attribute_mapping jsonb,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    name_id_format text,
    CONSTRAINT "entity_id not empty" CHECK ((char_length(entity_id) > 0)),
    CONSTRAINT "metadata_url not empty" CHECK (((metadata_url = NULL::text) OR (char_length(metadata_url) > 0))),
    CONSTRAINT "metadata_xml not empty" CHECK ((char_length(metadata_xml) > 0))
);


--
-- Name: TABLE saml_providers; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.saml_providers IS 'Auth: Manages SAML Identity Provider connections.';


--
-- Name: saml_relay_states; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.saml_relay_states (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    request_id text NOT NULL,
    for_email text,
    redirect_to text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    flow_state_id uuid,
    CONSTRAINT "request_id not empty" CHECK ((char_length(request_id) > 0))
);


--
-- Name: TABLE saml_relay_states; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.saml_relay_states IS 'Auth: Contains SAML Relay State information for each Service Provider initiated login.';


--
-- Name: schema_migrations; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: TABLE schema_migrations; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.schema_migrations IS 'Auth: Manages updates to the auth system.';


--
-- Name: sessions; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.sessions (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    factor_id uuid,
    aal auth.aal_level,
    not_after timestamp with time zone,
    refreshed_at timestamp without time zone,
    user_agent text,
    ip inet,
    tag text,
    oauth_client_id uuid,
    refresh_token_hmac_key text,
    refresh_token_counter bigint,
    scopes text,
    CONSTRAINT sessions_scopes_length CHECK ((char_length(scopes) <= 4096))
);


--
-- Name: TABLE sessions; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.sessions IS 'Auth: Stores session data associated to a user.';


--
-- Name: COLUMN sessions.not_after; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sessions.not_after IS 'Auth: Not after is a nullable column that contains a timestamp after which the session should be regarded as expired.';


--
-- Name: COLUMN sessions.refresh_token_hmac_key; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sessions.refresh_token_hmac_key IS 'Holds a HMAC-SHA256 key used to sign refresh tokens for this session.';


--
-- Name: COLUMN sessions.refresh_token_counter; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sessions.refresh_token_counter IS 'Holds the ID (counter) of the last issued refresh token.';


--
-- Name: sso_domains; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.sso_domains (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    domain text NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    CONSTRAINT "domain not empty" CHECK ((char_length(domain) > 0))
);


--
-- Name: TABLE sso_domains; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.sso_domains IS 'Auth: Manages SSO email address domain mapping to an SSO Identity Provider.';


--
-- Name: sso_providers; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.sso_providers (
    id uuid NOT NULL,
    resource_id text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    disabled boolean,
    CONSTRAINT "resource_id not empty" CHECK (((resource_id = NULL::text) OR (char_length(resource_id) > 0)))
);


--
-- Name: TABLE sso_providers; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.sso_providers IS 'Auth: Manages SSO identity provider information; see saml_providers for SAML.';


--
-- Name: COLUMN sso_providers.resource_id; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sso_providers.resource_id IS 'Auth: Uniquely identifies a SSO provider according to a user-chosen resource ID (case insensitive), useful in infrastructure as code.';


--
-- Name: users; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.users (
    instance_id uuid,
    id uuid NOT NULL,
    aud character varying(255),
    role character varying(255),
    email character varying(255),
    encrypted_password character varying(255),
    email_confirmed_at timestamp with time zone,
    invited_at timestamp with time zone,
    confirmation_token character varying(255),
    confirmation_sent_at timestamp with time zone,
    recovery_token character varying(255),
    recovery_sent_at timestamp with time zone,
    email_change_token_new character varying(255),
    email_change character varying(255),
    email_change_sent_at timestamp with time zone,
    last_sign_in_at timestamp with time zone,
    raw_app_meta_data jsonb,
    raw_user_meta_data jsonb,
    is_super_admin boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    phone text DEFAULT NULL::character varying,
    phone_confirmed_at timestamp with time zone,
    phone_change text DEFAULT ''::character varying,
    phone_change_token character varying(255) DEFAULT ''::character varying,
    phone_change_sent_at timestamp with time zone,
    confirmed_at timestamp with time zone GENERATED ALWAYS AS (LEAST(email_confirmed_at, phone_confirmed_at)) STORED,
    email_change_token_current character varying(255) DEFAULT ''::character varying,
    email_change_confirm_status smallint DEFAULT 0,
    banned_until timestamp with time zone,
    reauthentication_token character varying(255) DEFAULT ''::character varying,
    reauthentication_sent_at timestamp with time zone,
    is_sso_user boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone,
    is_anonymous boolean DEFAULT false NOT NULL,
    CONSTRAINT users_email_change_confirm_status_check CHECK (((email_change_confirm_status >= 0) AND (email_change_confirm_status <= 2)))
);


--
-- Name: TABLE users; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.users IS 'Auth: Stores user login data within a secure schema.';


--
-- Name: COLUMN users.is_sso_user; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.users.is_sso_user IS 'Auth: Set this column to true when the account comes from SSO. These accounts can have duplicate emails.';


--
-- Name: assignment_trackers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assignment_trackers (
    assignment_type text NOT NULL,
    last_assigned_employee_id uuid,
    updated_at timestamp with time zone DEFAULT now(),
    assignment_group_key text,
    available_count integer DEFAULT 0,
    employee_rotation_order jsonb DEFAULT '[]'::jsonb,
    current_rotation_index integer DEFAULT 0,
    last_assigned_at timestamp with time zone DEFAULT now(),
    created_at timestamp with time zone DEFAULT now(),
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    order_type_filter text DEFAULT 'PURCHASE'::text,
    business_domain text DEFAULT 'CURRENCY_TRADING'::text,
    priority_ordering text DEFAULT 'FIRST_CREATED'::text,
    max_consecutive_assignments integer DEFAULT 10,
    reset_frequency_hours integer DEFAULT 24,
    last_reset_at timestamp with time zone DEFAULT now(),
    description text
);


--
-- Name: TABLE assignment_trackers; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.assignment_trackers IS 'Assignment Trackers table - Bộ nhớ phân công tuần tự theo đúng bản thảo. Đảm bảo phân công công bằng cho employees và round-robin cho stock pools.';


--
-- Name: COLUMN assignment_trackers.assignment_group_key; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.assignment_trackers.assignment_group_key IS 'Composite key: channel_id + currency_code + shift_id';


--
-- Name: COLUMN assignment_trackers.employee_rotation_order; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.assignment_trackers.employee_rotation_order IS 'Array of employee_profile_ids in round-robin order';


--
-- Name: COLUMN assignment_trackers.current_rotation_index; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.assignment_trackers.current_rotation_index IS 'Current position in rotation (0-based)';


--
-- Name: attribute_relationships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.attribute_relationships (
    parent_attribute_id uuid NOT NULL,
    child_attribute_id uuid NOT NULL
);


--
-- Name: attributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.attributes (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    type text NOT NULL,
    sort_order integer DEFAULT 0,
    is_active boolean DEFAULT true
);


--
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    at timestamp with time zone DEFAULT now(),
    actor uuid,
    entity text,
    entity_id uuid,
    action text,
    diff jsonb,
    table_name text,
    op text,
    pk jsonb,
    row_old jsonb,
    row_new jsonb,
    ctx jsonb
);


--
-- Name: TABLE audit_logs; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.audit_logs IS 'all logs';


--
-- Name: business_processes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.business_processes (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    description text,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    created_by uuid,
    sale_channel_id uuid,
    sale_currency text DEFAULT 'VND'::text NOT NULL,
    purchase_channel_id uuid,
    purchase_currency character varying(3),
    CONSTRAINT business_processes_purchase_currency_check CHECK (((purchase_currency)::text = ANY ((ARRAY['VND'::character varying, 'USD'::character varying, 'CNY'::character varying])::text[])))
);


--
-- Name: TABLE business_processes; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.business_processes IS 'Business processes table with sale channel and currency references';


--
-- Name: COLUMN business_processes.sale_channel_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.business_processes.sale_channel_id IS 'Default channel for sale operations (FK to channels.id)';


--
-- Name: COLUMN business_processes.sale_currency; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.business_processes.sale_currency IS 'Default currency for sale operations (references currencies.code, validated by trigger)';


--
-- Name: channels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.channels (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    code text NOT NULL,
    name text,
    description text,
    website_url text,
    is_active boolean DEFAULT true NOT NULL,
    direction text DEFAULT 'BOTH'::text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid,
    updated_by uuid,
    CONSTRAINT channels_direction_check CHECK ((direction = ANY (ARRAY['BUY'::text, 'SELL'::text, 'BOTH'::text])))
);


--
-- Name: currencies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.currencies (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    code text NOT NULL,
    name text,
    symbol text,
    decimal_places integer DEFAULT 2,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid,
    updated_by uuid
);


--
-- Name: TABLE currencies; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.currencies IS 'Currencies for exchange rate management';


--
-- Name: inventory_pools; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.inventory_pools (
    game_account_id uuid NOT NULL,
    currency_attribute_id uuid NOT NULL,
    quantity numeric(18,8) DEFAULT 0,
    average_cost numeric(18,8) DEFAULT 0,
    cost_currency text DEFAULT 'VND'::text NOT NULL,
    last_updated_at timestamp with time zone DEFAULT now(),
    last_updated_by uuid,
    reserved_quantity numeric(18,8) DEFAULT 0,
    game_code text DEFAULT ''::text NOT NULL,
    server_attribute_code text DEFAULT ''::text,
    channel_id uuid DEFAULT '8757fc30-4657-48d9-b58e-d9f8a0af3874'::uuid NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    CONSTRAINT inventory_pools_average_cost_check CHECK ((average_cost >= (0)::numeric)),
    CONSTRAINT inventory_pools_cost_currency_check CHECK ((cost_currency = ANY (ARRAY['VND'::text, 'USD'::text, 'EUR'::text, 'GBP'::text, 'JPY'::text, 'CNY'::text, 'KRW'::text, 'SGD'::text, 'AUD'::text, 'CAD'::text]))),
    CONSTRAINT inventory_pools_quantity_check CHECK ((quantity >= (0)::numeric)),
    CONSTRAINT inventory_pools_reserved_quantity_check CHECK ((reserved_quantity >= (0)::numeric))
);


--
-- Name: TABLE inventory_pools; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.inventory_pools IS 'Inventory pools table with auto-generated UUID primary key and unique business key index. Each row represents inventory for a specific game account, currency, channel, and server combination.';


--
-- Name: COLUMN inventory_pools.cost_currency; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.inventory_pools.cost_currency IS 'Currency code for cost calculation (references currencies.code, validated by trigger)';


--
-- Name: COLUMN inventory_pools.reserved_quantity; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.inventory_pools.reserved_quantity IS 'Số lượng đã được đặt hàng nhưng chưa giao';


--
-- Name: COLUMN inventory_pools.game_code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.inventory_pools.game_code IS 'Mã game (POE_1, DIABLO_4, etc.) - Cần cho business logic';


--
-- Name: COLUMN inventory_pools.server_attribute_code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.inventory_pools.server_attribute_code IS 'Server attribute code (can be raw or normalized format)';


--
-- Name: COLUMN inventory_pools.channel_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.inventory_pools.channel_id IS 'Channel reference (links to channels.id)';


--
-- Name: currency_inventory; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.currency_inventory WITH (security_invoker='true') AS
 SELECT game_account_id,
    currency_attribute_id,
    game_code,
    server_attribute_code,
    quantity,
    0 AS reserved_quantity,
    average_cost AS avg_buy_price,
    last_updated_at,
    channel_id,
    last_updated_by,
    cost_currency AS currency_code,
    NULL::text AS league_attribute_id,
    NULL::text AS avg_buy_price_vnd,
    NULL::text AS avg_buy_price_usd
   FROM public.inventory_pools ip;


--
-- Name: currency_orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.currency_orders (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    order_number text,
    order_type public.currency_order_type_enum NOT NULL,
    status public.currency_order_status_enum DEFAULT 'draft'::public.currency_order_status_enum,
    currency_attribute_id uuid NOT NULL,
    quantity numeric NOT NULL,
    game_code text NOT NULL,
    delivery_info text,
    channel_id uuid,
    game_account_id uuid,
    exchange_type public.currency_exchange_type_enum DEFAULT 'none'::public.currency_exchange_type_enum,
    exchange_details jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    submitted_at timestamp with time zone,
    assigned_at timestamp with time zone,
    preparation_at timestamp with time zone,
    ready_at timestamp with time zone,
    delivery_at timestamp with time zone,
    completed_at timestamp with time zone,
    cancelled_at timestamp with time zone,
    created_by uuid NOT NULL,
    updated_by uuid,
    submitted_by uuid,
    assigned_to uuid,
    delivered_by uuid,
    priority_level integer DEFAULT 3,
    deadline_at timestamp with time zone,
    party_id uuid NOT NULL,
    foreign_currency_id uuid,
    foreign_currency_code text,
    foreign_amount numeric,
    cost_amount numeric,
    cost_currency_code text DEFAULT 'VND'::text NOT NULL,
    sale_amount numeric,
    sale_currency_code text,
    profit_amount numeric,
    profit_currency_code text,
    profit_margin_percentage numeric,
    cost_to_sale_exchange_rate numeric,
    exchange_rate_date date DEFAULT CURRENT_DATE,
    exchange_rate_source text DEFAULT 'system'::text,
    notes text,
    proofs jsonb DEFAULT '{}'::jsonb,
    server_attribute_code text,
    inventory_pool_id uuid,
    CONSTRAINT check_orders_have_party_id CHECK ((party_id IS NOT NULL)),
    CONSTRAINT chk_foreign_currency_only_for_exchange CHECK ((((order_type <> 'EXCHANGE'::public.currency_order_type_enum) AND (foreign_currency_id IS NULL) AND (foreign_currency_code IS NULL) AND (foreign_amount IS NULL)) OR ((order_type = 'EXCHANGE'::public.currency_order_type_enum) AND (foreign_currency_id IS NOT NULL) AND (foreign_currency_code IS NOT NULL) AND (foreign_amount IS NOT NULL)))),
    CONSTRAINT currency_orders_cost_amount_check CHECK ((cost_amount >= (0)::numeric)),
    CONSTRAINT currency_orders_cost_to_sale_exchange_rate_check CHECK (((cost_to_sale_exchange_rate IS NULL) OR (cost_to_sale_exchange_rate > (0)::numeric))),
    CONSTRAINT currency_orders_foreign_amount_check CHECK ((foreign_amount > (0)::numeric)),
    CONSTRAINT currency_orders_priority_level_check CHECK (((priority_level >= 1) AND (priority_level <= 5))),
    CONSTRAINT currency_orders_quantity_check CHECK ((quantity > (0)::numeric)),
    CONSTRAINT currency_orders_sale_amount_check CHECK (((sale_amount IS NULL) OR (sale_amount >= (0)::numeric)))
);


--
-- Name: TABLE currency_orders; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.currency_orders IS 'Currency orders with simple columns (no generated columns)';


--
-- Name: COLUMN currency_orders.order_number; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.currency_orders.order_number IS 'Auto-generated order number in format CUR-XXXXXX';


--
-- Name: COLUMN currency_orders.quantity; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.currency_orders.quantity IS 'Main quantity field for order calculations';


--
-- Name: COLUMN currency_orders.exchange_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.currency_orders.exchange_type IS 'Exchange type: none (regular orders), service/farmer/items (System 1 - service sales markers), currency (System 2 - direct currency exchange between inventory items)';


--
-- Name: COLUMN currency_orders.exchange_details; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.currency_orders.exchange_details IS 'Additional details about the exchange in JSON format';


--
-- Name: COLUMN currency_orders.assigned_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.currency_orders.assigned_at IS 'Timestamp when order was assigned to staff';


--
-- Name: COLUMN currency_orders.ready_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.currency_orders.ready_at IS 'Timestamp when order is ready for delivery';


--
-- Name: COLUMN currency_orders.deadline_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.currency_orders.deadline_at IS 'Order deadline for SLA tracking';


--
-- Name: COLUMN currency_orders.party_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.currency_orders.party_id IS 'Party ID: Customer for SALE orders, Supplier for PURCHASE orders';


--
-- Name: COLUMN currency_orders.foreign_currency_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.currency_orders.foreign_currency_id IS 'Target currency for EXCHANGE orders only';


--
-- Name: COLUMN currency_orders.foreign_currency_code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.currency_orders.foreign_currency_code IS 'Target currency code for EXCHANGE orders only';


--
-- Name: COLUMN currency_orders.foreign_amount; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.currency_orders.foreign_amount IS 'Target currency amount for EXCHANGE orders only';


--
-- Name: COLUMN currency_orders.cost_amount; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.currency_orders.cost_amount IS 'Total cost amount in original currency';


--
-- Name: COLUMN currency_orders.cost_currency_code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.currency_orders.cost_currency_code IS 'Currency code for cost (VND, USD, EUR, etc.)';


--
-- Name: COLUMN currency_orders.sale_amount; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.currency_orders.sale_amount IS 'Total sale amount in original currency';


--
-- Name: COLUMN currency_orders.sale_currency_code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.currency_orders.sale_currency_code IS 'Currency code for sale (VND, USD, EUR, etc.)';


--
-- Name: COLUMN currency_orders.profit_amount; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.currency_orders.profit_amount IS 'Profit amount in base currency (can be negative for loss)';


--
-- Name: COLUMN currency_orders.profit_currency_code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.currency_orders.profit_currency_code IS 'Currency code for profit calculation';


--
-- Name: COLUMN currency_orders.profit_margin_percentage; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.currency_orders.profit_margin_percentage IS 'Profit margin percentage (profit/cost * 100)';


--
-- Name: COLUMN currency_orders.cost_to_sale_exchange_rate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.currency_orders.cost_to_sale_exchange_rate IS 'Exchange rate used to convert cost to sale currency (for profit calculation)';


--
-- Name: COLUMN currency_orders.exchange_rate_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.currency_orders.exchange_rate_date IS 'Date when exchange rate was obtained';


--
-- Name: COLUMN currency_orders.exchange_rate_source; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.currency_orders.exchange_rate_source IS 'Source of exchange rate (system, manual, external)';


--
-- Name: COLUMN currency_orders.server_attribute_code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.currency_orders.server_attribute_code IS 'Server attribute code referencing GAME_SERVER type attributes';


--
-- Name: currency_transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.currency_transactions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    game_account_id uuid,
    game_code text NOT NULL,
    transaction_type text NOT NULL,
    currency_attribute_id uuid NOT NULL,
    quantity numeric NOT NULL,
    currency_order_id uuid,
    notes text,
    created_by uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    server_attribute_code text,
    unit_price numeric DEFAULT 0 NOT NULL,
    currency_code text DEFAULT 'VND'::text NOT NULL,
    channel_id uuid,
    exchange_rate_usd numeric,
    proofs jsonb,
    CONSTRAINT currency_transactions_transaction_type_check CHECK ((transaction_type = ANY (ARRAY['purchase'::text, 'sale_delivery'::text, 'exchange_out'::text, 'exchange_in'::text, 'transfer_out'::text, 'transfer_in'::text, 'manual_adjustment'::text, 'farm_in'::text, 'payout'::text, 'league_archive'::text])))
);


--
-- Name: TABLE currency_transactions; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.currency_transactions IS 'Currency transactions with league/season support';


--
-- Name: COLUMN currency_transactions.transaction_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.currency_transactions.transaction_type IS 'Type: purchase, sale, transfer, adjustment';


--
-- Name: COLUMN currency_transactions.server_attribute_code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.currency_transactions.server_attribute_code IS 'Server attribute code referencing GAME_SERVER type attributes';


--
-- Name: COLUMN currency_transactions.unit_price; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.currency_transactions.unit_price IS 'Unit price in the specified currency';


--
-- Name: COLUMN currency_transactions.currency_code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.currency_transactions.currency_code IS 'Currency code (references currencies.code)';


--
-- Name: COLUMN currency_transactions.channel_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.currency_transactions.channel_id IS 'Channel ID for tracking source of transaction';


--
-- Name: COLUMN currency_transactions.exchange_rate_usd; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.currency_transactions.exchange_rate_usd IS 'USD exchange rate at transaction time (USD per 1 unit of currency_code)';


--
-- Name: COLUMN currency_transactions.proofs; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.currency_transactions.proofs IS 'JSON array of proof objects (similar to currency_orders.proofs)';


--
-- Name: customer_accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customer_accounts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    party_id uuid NOT NULL,
    account_type text,
    label text NOT NULL,
    btag text,
    login_id text,
    login_pwd text,
    game_code text,
    is_active boolean DEFAULT true,
    updated_at timestamp with time zone DEFAULT now(),
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT check_account_type CHECK (((account_type = ANY (ARRAY['btag'::text, 'login'::text, 'discord'::text, 'telegram'::text, 'other'::text])) OR (account_type IS NULL))),
    CONSTRAINT check_game_code CHECK (((game_code = ANY (ARRAY['POE_1'::text, 'POE_2'::text, 'DIABLO_4'::text])) OR (game_code IS NULL)))
);


--
-- Name: debug_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.debug_log (
    id integer NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    message text
);


--
-- Name: debug_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.debug_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: debug_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.debug_log_id_seq OWNED BY public.debug_log.id;


--
-- Name: employee_channels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.employee_channels (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    employee_profile_id uuid NOT NULL,
    channel_type text NOT NULL,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: TABLE employee_channels; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.employee_channels IS 'Many-to-many relationship between employees and channels. An employee can handle multiple channels (Facebook, WeChat) and a channel can have multiple employees.';


--
-- Name: exchange_order_number_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.exchange_order_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: exchange_rate_api_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.exchange_rate_api_log (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    api_provider text NOT NULL,
    endpoint_url text NOT NULL,
    success boolean NOT NULL,
    response_time_ms integer,
    currencies_fetched integer,
    error_message text,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: exchange_rate_config; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.exchange_rate_config (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    primary_api text DEFAULT 'fawazahmed0'::text,
    fallback_api text DEFAULT 'exchangerate-api'::text,
    base_currency text DEFAULT 'USD'::text,
    update_frequency_minutes integer DEFAULT 15,
    primary_api_url text DEFAULT 'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/usd.json'::text,
    fallback_api_url text DEFAULT 'https://v6.exchangerate-api.com/v6/latest/USD'::text,
    is_active boolean DEFAULT true,
    last_api_used text,
    api_failures integer DEFAULT 0,
    max_failures_before_switch integer DEFAULT 3,
    last_successful_fetch timestamp with time zone,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: exchange_rate_trigger; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.exchange_rate_trigger (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    trigger_time timestamp with time zone DEFAULT now(),
    triggered_by text DEFAULT 'system'::text
);


--
-- Name: exchange_rates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.exchange_rates (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    rate numeric(20,8) NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    effective_date timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid,
    updated_by uuid,
    from_currency text NOT NULL,
    to_currency text NOT NULL,
    config_id uuid,
    CONSTRAINT exchange_rates_rate_check CHECK ((rate > (0)::numeric))
);


--
-- Name: TABLE exchange_rates; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.exchange_rates IS 'Exchange rates table with currency code references to currencies.code';


--
-- Name: COLUMN exchange_rates.from_currency; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.exchange_rates.from_currency IS 'Source currency code (references currencies.code, validated by trigger)';


--
-- Name: COLUMN exchange_rates.to_currency; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.exchange_rates.to_currency IS 'Target currency code (references currencies.code, validated by trigger)';


--
-- Name: fees; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fees (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    direction text NOT NULL,
    fee_type text NOT NULL,
    amount numeric(18,8) NOT NULL,
    currency text DEFAULT 'VND'::text NOT NULL,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    created_by uuid,
    CONSTRAINT fees_amount_check CHECK ((amount >= (0)::numeric)),
    CONSTRAINT fees_currency_check CHECK ((currency = ANY (ARRAY['VND'::text, 'USD'::text, 'EUR'::text, 'GBP'::text, 'JPY'::text, 'CNY'::text, 'KRW'::text, 'SGD'::text, 'AUD'::text, 'CAD'::text]))),
    CONSTRAINT fees_direction_check CHECK ((direction = ANY (ARRAY['BUY'::text, 'SELL'::text, 'WITHDRAW'::text, 'TAX'::text, 'OTHER'::text]))),
    CONSTRAINT fees_fee_type_check CHECK ((fee_type = ANY (ARRAY['RATE'::text, 'FIXED'::text])))
);


--
-- Name: TABLE fees; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.fees IS 'Fees table - Quản lý tất cả các loại phí trong hệ thống (phí sàn, phí rút, thuế, etc.) theo đúng bản thảo';


--
-- Name: COLUMN fees.currency; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.fees.currency IS 'Currency code for fee calculation (references currencies.code, validated by trigger)';


--
-- Name: game_accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.game_accounts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    game_code text NOT NULL,
    account_name text NOT NULL,
    purpose text DEFAULT 'INVENTORY'::text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    server_attribute_code text,
    CONSTRAINT game_accounts_purpose_check CHECK ((purpose = ANY (ARRAY['FARM'::text, 'INVENTORY'::text, 'TRADE'::text])))
);


--
-- Name: TABLE game_accounts; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.game_accounts IS 'Game accounts with purpose (FARM, INVENTORY, TRADE) and league/season support';


--
-- Name: COLUMN game_accounts.server_attribute_code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.game_accounts.server_attribute_code IS 'References to GAME_SERVER type attributes, linked to game_code via attribute_relationships';


--
-- Name: level_exp; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.level_exp (
    level integer NOT NULL,
    cumulative_exp bigint NOT NULL
);

ALTER TABLE ONLY public.level_exp FORCE ROW LEVEL SECURITY;


--
-- Name: profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.profiles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    display_name text,
    status text DEFAULT 'active'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    auth_id uuid NOT NULL,
    notes text,
    phone text
);

ALTER TABLE ONLY public.profiles FORCE ROW LEVEL SECURITY;


--
-- Name: COLUMN profiles.auth_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.profiles.auth_id IS 'Foreign key to auth.users.id';


--
-- Name: work_sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.work_sessions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    order_line_id uuid NOT NULL,
    farmer_id uuid NOT NULL,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    ended_at timestamp with time zone,
    notes text,
    overrun_reason text,
    start_state jsonb,
    unpaused_duration interval,
    overrun_type text,
    overrun_proof_urls text[]
);


--
-- Name: COLUMN work_sessions.overrun_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.work_sessions.overrun_type IS 'Loại lý do vượt chỉ tiêu (OBJECTIVE | KPI_FAIL)';


--
-- Name: COLUMN work_sessions.overrun_proof_urls; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.work_sessions.overrun_proof_urls IS 'Danh sách URL bằng chứng khi vượt chỉ tiêu.';


--
-- Name: mv_active_farmers; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.mv_active_farmers AS
 SELECT ws.order_line_id,
    string_agg(DISTINCT p.display_name, ', '::text ORDER BY p.display_name) AS farmer_names,
    count(*) AS active_session_count,
    now() AS last_updated
   FROM (public.work_sessions ws
     JOIN public.profiles p ON ((ws.farmer_id = p.id)))
  WHERE (ws.ended_at IS NULL)
  GROUP BY ws.order_line_id
  WITH NO DATA;


--
-- Name: order_lines; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_lines (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    order_id uuid NOT NULL,
    variant_id uuid NOT NULL,
    customer_account_id uuid,
    qty numeric DEFAULT 1 NOT NULL,
    unit_price numeric DEFAULT 0 NOT NULL,
    deadline_to timestamp with time zone,
    notes text,
    paused_at timestamp with time zone,
    total_paused_duration interval DEFAULT '00:00:00'::interval,
    action_proof_urls text[],
    machine_info text,
    pilot_warning_level integer DEFAULT 0,
    pilot_is_blocked boolean DEFAULT false,
    pilot_cycle_start_at timestamp with time zone,
    CONSTRAINT order_lines_pilot_warning_level_check CHECK ((pilot_warning_level = ANY (ARRAY[0, 1, 2])))
);


--
-- Name: COLUMN order_lines.machine_info; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.order_lines.machine_info IS 'Thông tin máy tính đang thực hiện đơn hàng Pilot (ví dụ: Máy 35).';


--
-- Name: COLUMN order_lines.pilot_warning_level; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.order_lines.pilot_warning_level IS 'Mức cảnh báo chu kỳ online pilot: 0=none, 1=warning (5 ngày), 2=blocked (6 ngày). Chỉ áp dụng cho pilot orders đang hoạt động';


--
-- Name: COLUMN order_lines.pilot_is_blocked; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.order_lines.pilot_is_blocked IS 'Khóa gán đơn hàng mới khi = TRUE (>= 6 ngày online). Chỉ áp dụng cho pilot orders đang hoạt động';


--
-- Name: COLUMN order_lines.pilot_cycle_start_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.order_lines.pilot_cycle_start_at IS 'Thời gian bắt đầu chu kỳ online hiện tại. Reset khi đủ điều kiện nghỉ. Đã fix từ created_at của orders.';


--
-- Name: order_reviews; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_reviews (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    order_line_id uuid NOT NULL,
    rating numeric NOT NULL,
    comment text,
    proof_urls text[],
    created_by uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT order_reviews_rating_check CHECK (((rating >= (0)::numeric) AND (rating <= (5)::numeric)))
);


--
-- Name: order_service_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_service_items (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    order_line_id uuid NOT NULL,
    params jsonb,
    plan_qty numeric DEFAULT 0,
    service_kind_id uuid NOT NULL,
    done_qty numeric DEFAULT 0 NOT NULL
);


--
-- Name: orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.orders (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    side public.order_side_enum DEFAULT 'SELL'::public.order_side_enum NOT NULL,
    status text DEFAULT 'new'::text NOT NULL,
    party_id uuid NOT NULL,
    channel_id uuid,
    currency_id uuid,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    price_total numeric DEFAULT 0 NOT NULL,
    notes text,
    game_code text,
    package_type text,
    package_note text,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    delivered_at timestamp with time zone
);


--
-- Name: parties; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.parties (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    type text NOT NULL,
    name text NOT NULL,
    notes text,
    contact_info jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    channel_id uuid,
    game_code text DEFAULT 'DIABLO_4'::text,
    CONSTRAINT check_party_type CHECK ((type = ANY (ARRAY['customer'::text, 'supplier'::text, 'admin'::text, 'other'::text])))
);


--
-- Name: COLUMN parties.channel_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.parties.channel_id IS 'Primary channel for this supplier/customer (UUID reference to channels table)';


--
-- Name: permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.permissions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    code text NOT NULL,
    description text,
    "group" text DEFAULT 'General'::text NOT NULL,
    description_vi text
);


--
-- Name: process_fees_map; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.process_fees_map (
    process_id uuid NOT NULL,
    fee_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: TABLE process_fees_map; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.process_fees_map IS 'Process Fees Map table - Ánh xạ phí bổ sung vào quy trình theo đúng bản thảo. Cho phép mỗi quy trình có nhiều loại phí bổ sung (thuế, phí rút, etc.).';


--
-- Name: product_variant_attributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_variant_attributes (
    variant_id uuid NOT NULL,
    attribute_id uuid NOT NULL
);


--
-- Name: product_variants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_variants (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    product_id uuid NOT NULL,
    display_name text NOT NULL,
    price numeric DEFAULT 0 NOT NULL,
    is_active boolean DEFAULT true NOT NULL
);


--
-- Name: products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.products (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    type public.product_type_enum NOT NULL
);


--
-- Name: profile_status_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.profile_status_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    profile_id uuid NOT NULL,
    old_status text,
    new_status text NOT NULL,
    changed_by uuid,
    change_reason text,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: TABLE profile_status_logs; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.profile_status_logs IS 'Logs all profile status changes for audit purposes';


--
-- Name: purchase_order_number_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.purchase_order_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: role_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.role_permissions (
    role_id uuid NOT NULL,
    permission_id uuid NOT NULL
);


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    code public.app_role NOT NULL,
    name text NOT NULL
);


--
-- Name: sale_order_number_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sale_order_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: service_reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.service_reports (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    order_line_id uuid NOT NULL,
    order_service_item_id uuid NOT NULL,
    reported_by uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    description text NOT NULL,
    current_proof_urls text[],
    disputed_start_value numeric,
    disputed_proof_url text,
    status text DEFAULT 'new'::text NOT NULL,
    resolved_at timestamp with time zone,
    resolved_by uuid,
    resolver_notes text
);


--
-- Name: shift_assignments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shift_assignments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    game_account_id uuid NOT NULL,
    employee_profile_id uuid NOT NULL,
    shift_id uuid NOT NULL,
    is_active boolean DEFAULT true,
    assigned_at timestamp with time zone DEFAULT now(),
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    channels_id uuid,
    currency_code text DEFAULT ''::text NOT NULL
);


--
-- Name: COLUMN shift_assignments.channels_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.shift_assignments.channels_id IS 'Channel associated with this shift assignment';


--
-- Name: COLUMN shift_assignments.currency_code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.shift_assignments.currency_code IS 'Currency code for this assignment (e.g., VND, USD)';


--
-- Name: user_role_assignments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_role_assignments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    role_id uuid NOT NULL,
    game_attribute_id uuid,
    business_area_attribute_id uuid
);


--
-- Name: work_session_outputs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.work_session_outputs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    work_session_id uuid NOT NULL,
    order_service_item_id uuid NOT NULL,
    delta numeric DEFAULT 0 NOT NULL,
    proof_url text,
    start_value numeric DEFAULT 0 NOT NULL,
    start_proof_url text,
    end_proof_url text,
    params jsonb,
    is_obsolete boolean DEFAULT false NOT NULL
);


--
-- Name: work_shifts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.work_shifts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    start_time time without time zone NOT NULL,
    end_time time without time zone NOT NULL,
    description text,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: messages; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.messages (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
)
PARTITION BY RANGE (inserted_at);


--
-- Name: messages_2025_12_13; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.messages_2025_12_13 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


--
-- Name: messages_2025_12_14; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.messages_2025_12_14 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


--
-- Name: messages_2025_12_15; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.messages_2025_12_15 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


--
-- Name: messages_2025_12_16; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.messages_2025_12_16 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


--
-- Name: messages_2025_12_17; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.messages_2025_12_17 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


--
-- Name: messages_2025_12_18; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.messages_2025_12_18 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


--
-- Name: messages_2025_12_19; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.messages_2025_12_19 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


--
-- Name: subscription; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.subscription (
    id bigint NOT NULL,
    subscription_id uuid NOT NULL,
    entity regclass NOT NULL,
    filters realtime.user_defined_filter[] DEFAULT '{}'::realtime.user_defined_filter[] NOT NULL,
    claims jsonb NOT NULL,
    claims_role regrole GENERATED ALWAYS AS (realtime.to_regrole((claims ->> 'role'::text))) STORED NOT NULL,
    created_at timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);


--
-- Name: subscription_id_seq; Type: SEQUENCE; Schema: realtime; Owner: -
--

ALTER TABLE realtime.subscription ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME realtime.subscription_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: buckets; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.buckets (
    id text NOT NULL,
    name text NOT NULL,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    public boolean DEFAULT false,
    avif_autodetection boolean DEFAULT false,
    file_size_limit bigint,
    allowed_mime_types text[],
    owner_id text,
    type storage.buckettype DEFAULT 'STANDARD'::storage.buckettype NOT NULL
);


--
-- Name: COLUMN buckets.owner; Type: COMMENT; Schema: storage; Owner: -
--

COMMENT ON COLUMN storage.buckets.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: buckets_analytics; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.buckets_analytics (
    name text NOT NULL,
    type storage.buckettype DEFAULT 'ANALYTICS'::storage.buckettype NOT NULL,
    format text DEFAULT 'ICEBERG'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: buckets_vectors; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.buckets_vectors (
    id text NOT NULL,
    type storage.buckettype DEFAULT 'VECTOR'::storage.buckettype NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: migrations; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.migrations (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    hash character varying(40) NOT NULL,
    executed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: objects; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.objects (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    bucket_id text,
    name text,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    last_accessed_at timestamp with time zone DEFAULT now(),
    metadata jsonb,
    path_tokens text[] GENERATED ALWAYS AS (string_to_array(name, '/'::text)) STORED,
    version text,
    owner_id text,
    user_metadata jsonb,
    level integer
);


--
-- Name: COLUMN objects.owner; Type: COMMENT; Schema: storage; Owner: -
--

COMMENT ON COLUMN storage.objects.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: prefixes; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.prefixes (
    bucket_id text NOT NULL,
    name text NOT NULL COLLATE pg_catalog."C",
    level integer GENERATED ALWAYS AS (storage.get_level(name)) STORED NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: s3_multipart_uploads; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.s3_multipart_uploads (
    id text NOT NULL,
    in_progress_size bigint DEFAULT 0 NOT NULL,
    upload_signature text NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    version text NOT NULL,
    owner_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    user_metadata jsonb
);


--
-- Name: s3_multipart_uploads_parts; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.s3_multipart_uploads_parts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    upload_id text NOT NULL,
    size bigint DEFAULT 0 NOT NULL,
    part_number integer NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    etag text NOT NULL,
    owner_id text,
    version text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: vector_indexes; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.vector_indexes (
    id text DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL COLLATE pg_catalog."C",
    bucket_id text NOT NULL,
    data_type text NOT NULL,
    dimension integer NOT NULL,
    distance_metric text NOT NULL,
    metadata_configuration jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: supabase_migrations; Owner: -
--

CREATE TABLE supabase_migrations.schema_migrations (
    version text NOT NULL,
    statements text[],
    name text,
    created_by text,
    idempotency_key text,
    rollback text[]
);


--
-- Name: seed_files; Type: TABLE; Schema: supabase_migrations; Owner: -
--

CREATE TABLE supabase_migrations.seed_files (
    path text NOT NULL,
    hash text NOT NULL
);


--
-- Name: messages_2025_12_13; Type: TABLE ATTACH; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2025_12_13 FOR VALUES FROM ('2025-12-13 00:00:00') TO ('2025-12-14 00:00:00');


--
-- Name: messages_2025_12_14; Type: TABLE ATTACH; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2025_12_14 FOR VALUES FROM ('2025-12-14 00:00:00') TO ('2025-12-15 00:00:00');


--
-- Name: messages_2025_12_15; Type: TABLE ATTACH; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2025_12_15 FOR VALUES FROM ('2025-12-15 00:00:00') TO ('2025-12-16 00:00:00');


--
-- Name: messages_2025_12_16; Type: TABLE ATTACH; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2025_12_16 FOR VALUES FROM ('2025-12-16 00:00:00') TO ('2025-12-17 00:00:00');


--
-- Name: messages_2025_12_17; Type: TABLE ATTACH; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2025_12_17 FOR VALUES FROM ('2025-12-17 00:00:00') TO ('2025-12-18 00:00:00');


--
-- Name: messages_2025_12_18; Type: TABLE ATTACH; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2025_12_18 FOR VALUES FROM ('2025-12-18 00:00:00') TO ('2025-12-19 00:00:00');


--
-- Name: messages_2025_12_19; Type: TABLE ATTACH; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2025_12_19 FOR VALUES FROM ('2025-12-19 00:00:00') TO ('2025-12-20 00:00:00');


--
-- Name: refresh_tokens id; Type: DEFAULT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens ALTER COLUMN id SET DEFAULT nextval('auth.refresh_tokens_id_seq'::regclass);


--
-- Name: debug_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.debug_log ALTER COLUMN id SET DEFAULT nextval('public.debug_log_id_seq'::regclass);


--
-- Name: mfa_amr_claims amr_id_pk; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT amr_id_pk PRIMARY KEY (id);


--
-- Name: audit_log_entries audit_log_entries_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.audit_log_entries
    ADD CONSTRAINT audit_log_entries_pkey PRIMARY KEY (id);


--
-- Name: flow_state flow_state_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.flow_state
    ADD CONSTRAINT flow_state_pkey PRIMARY KEY (id);


--
-- Name: identities identities_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_pkey PRIMARY KEY (id);


--
-- Name: identities identities_provider_id_provider_unique; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_provider_id_provider_unique UNIQUE (provider_id, provider);


--
-- Name: instances instances_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.instances
    ADD CONSTRAINT instances_pkey PRIMARY KEY (id);


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_authentication_method_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_authentication_method_pkey UNIQUE (session_id, authentication_method);


--
-- Name: mfa_challenges mfa_challenges_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_pkey PRIMARY KEY (id);


--
-- Name: mfa_factors mfa_factors_last_challenged_at_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_last_challenged_at_key UNIQUE (last_challenged_at);


--
-- Name: mfa_factors mfa_factors_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_pkey PRIMARY KEY (id);


--
-- Name: oauth_authorizations oauth_authorizations_authorization_code_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_authorization_code_key UNIQUE (authorization_code);


--
-- Name: oauth_authorizations oauth_authorizations_authorization_id_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_authorization_id_key UNIQUE (authorization_id);


--
-- Name: oauth_authorizations oauth_authorizations_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_pkey PRIMARY KEY (id);


--
-- Name: oauth_client_states oauth_client_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_client_states
    ADD CONSTRAINT oauth_client_states_pkey PRIMARY KEY (id);


--
-- Name: oauth_clients oauth_clients_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_clients
    ADD CONSTRAINT oauth_clients_pkey PRIMARY KEY (id);


--
-- Name: oauth_consents oauth_consents_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_pkey PRIMARY KEY (id);


--
-- Name: oauth_consents oauth_consents_user_client_unique; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_user_client_unique UNIQUE (user_id, client_id);


--
-- Name: one_time_tokens one_time_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_token_unique; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_token_unique UNIQUE (token);


--
-- Name: saml_providers saml_providers_entity_id_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_entity_id_key UNIQUE (entity_id);


--
-- Name: saml_providers saml_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_pkey PRIMARY KEY (id);


--
-- Name: saml_relay_states saml_relay_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sso_domains sso_domains_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_pkey PRIMARY KEY (id);


--
-- Name: sso_providers sso_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sso_providers
    ADD CONSTRAINT sso_providers_pkey PRIMARY KEY (id);


--
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: shift_assignments account_shift_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shift_assignments
    ADD CONSTRAINT account_shift_assignments_pkey PRIMARY KEY (id);


--
-- Name: assignment_trackers assignment_trackers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assignment_trackers
    ADD CONSTRAINT assignment_trackers_pkey PRIMARY KEY (id);


--
-- Name: attribute_relationships attribute_relationships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attribute_relationships
    ADD CONSTRAINT attribute_relationships_pkey PRIMARY KEY (parent_attribute_id, child_attribute_id);


--
-- Name: attributes attributes_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attributes
    ADD CONSTRAINT attributes_code_key UNIQUE (code);


--
-- Name: attributes attributes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attributes
    ADD CONSTRAINT attributes_pkey PRIMARY KEY (id);


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);


--
-- Name: business_processes business_processes_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.business_processes
    ADD CONSTRAINT business_processes_code_key UNIQUE (code);


--
-- Name: business_processes business_processes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.business_processes
    ADD CONSTRAINT business_processes_pkey PRIMARY KEY (id);


--
-- Name: channels channels_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.channels
    ADD CONSTRAINT channels_code_key UNIQUE (code);


--
-- Name: channels channels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.channels
    ADD CONSTRAINT channels_pkey PRIMARY KEY (id);


--
-- Name: currencies currencies_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.currencies
    ADD CONSTRAINT currencies_code_key UNIQUE (code);


--
-- Name: currencies currencies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.currencies
    ADD CONSTRAINT currencies_pkey PRIMARY KEY (id);


--
-- Name: currency_orders currency_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.currency_orders
    ADD CONSTRAINT currency_orders_pkey PRIMARY KEY (id);


--
-- Name: currency_transactions currency_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.currency_transactions
    ADD CONSTRAINT currency_transactions_pkey PRIMARY KEY (id);


--
-- Name: customer_accounts customer_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_accounts
    ADD CONSTRAINT customer_accounts_pkey PRIMARY KEY (id);


--
-- Name: debug_log debug_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.debug_log
    ADD CONSTRAINT debug_log_pkey PRIMARY KEY (id);


--
-- Name: employee_channels employee_channels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employee_channels
    ADD CONSTRAINT employee_channels_pkey PRIMARY KEY (id);


--
-- Name: exchange_rate_api_log exchange_rate_api_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exchange_rate_api_log
    ADD CONSTRAINT exchange_rate_api_log_pkey PRIMARY KEY (id);


--
-- Name: exchange_rate_config exchange_rate_config_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exchange_rate_config
    ADD CONSTRAINT exchange_rate_config_pkey PRIMARY KEY (id);


--
-- Name: exchange_rate_trigger exchange_rate_trigger_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exchange_rate_trigger
    ADD CONSTRAINT exchange_rate_trigger_pkey PRIMARY KEY (id);


--
-- Name: exchange_rates exchange_rates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exchange_rates
    ADD CONSTRAINT exchange_rates_pkey PRIMARY KEY (id);


--
-- Name: fees fees_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fees
    ADD CONSTRAINT fees_code_key UNIQUE (code);


--
-- Name: fees fees_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fees
    ADD CONSTRAINT fees_pkey PRIMARY KEY (id);


--
-- Name: game_accounts game_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.game_accounts
    ADD CONSTRAINT game_accounts_pkey PRIMARY KEY (id);


--
-- Name: inventory_pools inventory_pools_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_pools
    ADD CONSTRAINT inventory_pools_pkey PRIMARY KEY (id);


--
-- Name: level_exp level_exp_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.level_exp
    ADD CONSTRAINT level_exp_pkey PRIMARY KEY (level);


--
-- Name: order_lines order_lines_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_lines
    ADD CONSTRAINT order_lines_pkey PRIMARY KEY (id);


--
-- Name: order_reviews order_reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_reviews
    ADD CONSTRAINT order_reviews_pkey PRIMARY KEY (id);


--
-- Name: order_service_items order_service_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_service_items
    ADD CONSTRAINT order_service_items_pkey PRIMARY KEY (id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: parties parties_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parties
    ADD CONSTRAINT parties_pkey PRIMARY KEY (id);


--
-- Name: parties parties_type_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parties
    ADD CONSTRAINT parties_type_name_key UNIQUE (type, name);


--
-- Name: permissions permissions_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_code_key UNIQUE (code);


--
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- Name: process_fees_map process_fees_map_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.process_fees_map
    ADD CONSTRAINT process_fees_map_pkey PRIMARY KEY (process_id, fee_id);


--
-- Name: product_variant_attributes product_variant_attributes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_variant_attributes
    ADD CONSTRAINT product_variant_attributes_pkey PRIMARY KEY (variant_id, attribute_id);


--
-- Name: product_variants product_variants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_variants
    ADD CONSTRAINT product_variants_pkey PRIMARY KEY (id);


--
-- Name: product_variants product_variants_product_id_display_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_variants
    ADD CONSTRAINT product_variants_product_id_display_name_key UNIQUE (product_id, display_name);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: profile_status_logs profile_status_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profile_status_logs
    ADD CONSTRAINT profile_status_logs_pkey PRIMARY KEY (id);


--
-- Name: profiles profiles_auth_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_auth_id_key UNIQUE (auth_id);


--
-- Name: profiles profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);


--
-- Name: role_permissions role_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_pkey PRIMARY KEY (role_id, permission_id);


--
-- Name: roles roles_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_code_key UNIQUE (code);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: service_reports service_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.service_reports
    ADD CONSTRAINT service_reports_pkey PRIMARY KEY (id);


--
-- Name: shift_assignments shift_assignments_unique_combination; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shift_assignments
    ADD CONSTRAINT shift_assignments_unique_combination UNIQUE (game_account_id, employee_profile_id, shift_id, channels_id, currency_code);


--
-- Name: currency_orders uk_currency_orders_order_number; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.currency_orders
    ADD CONSTRAINT uk_currency_orders_order_number UNIQUE (order_number);


--
-- Name: assignment_trackers unique_assignment_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assignment_trackers
    ADD CONSTRAINT unique_assignment_key UNIQUE (assignment_group_key);


--
-- Name: exchange_rates unique_exchange_rate_currency; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exchange_rates
    ADD CONSTRAINT unique_exchange_rate_currency UNIQUE (from_currency, to_currency, effective_date);


--
-- Name: user_role_assignments user_role_assignments_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_role_assignments
    ADD CONSTRAINT user_role_assignments_pkey1 PRIMARY KEY (id);


--
-- Name: user_role_assignments user_role_assignments_user_id_role_id_game_attribute_id_bus_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_role_assignments
    ADD CONSTRAINT user_role_assignments_user_id_role_id_game_attribute_id_bus_key UNIQUE (user_id, role_id, game_attribute_id, business_area_attribute_id);


--
-- Name: work_session_outputs work_session_outputs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_session_outputs
    ADD CONSTRAINT work_session_outputs_pkey PRIMARY KEY (id);


--
-- Name: work_sessions work_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_sessions
    ADD CONSTRAINT work_sessions_pkey PRIMARY KEY (id);


--
-- Name: work_shifts work_shifts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_shifts
    ADD CONSTRAINT work_shifts_pkey PRIMARY KEY (id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2025_12_13 messages_2025_12_13_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages_2025_12_13
    ADD CONSTRAINT messages_2025_12_13_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2025_12_14 messages_2025_12_14_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages_2025_12_14
    ADD CONSTRAINT messages_2025_12_14_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2025_12_15 messages_2025_12_15_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages_2025_12_15
    ADD CONSTRAINT messages_2025_12_15_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2025_12_16 messages_2025_12_16_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages_2025_12_16
    ADD CONSTRAINT messages_2025_12_16_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2025_12_17 messages_2025_12_17_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages_2025_12_17
    ADD CONSTRAINT messages_2025_12_17_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2025_12_18 messages_2025_12_18_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages_2025_12_18
    ADD CONSTRAINT messages_2025_12_18_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2025_12_19 messages_2025_12_19_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages_2025_12_19
    ADD CONSTRAINT messages_2025_12_19_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: subscription pk_subscription; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.subscription
    ADD CONSTRAINT pk_subscription PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: buckets_analytics buckets_analytics_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.buckets_analytics
    ADD CONSTRAINT buckets_analytics_pkey PRIMARY KEY (id);


--
-- Name: buckets buckets_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.buckets
    ADD CONSTRAINT buckets_pkey PRIMARY KEY (id);


--
-- Name: buckets_vectors buckets_vectors_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.buckets_vectors
    ADD CONSTRAINT buckets_vectors_pkey PRIMARY KEY (id);


--
-- Name: migrations migrations_name_key; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_name_key UNIQUE (name);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: objects objects_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT objects_pkey PRIMARY KEY (id);


--
-- Name: prefixes prefixes_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.prefixes
    ADD CONSTRAINT prefixes_pkey PRIMARY KEY (bucket_id, level, name);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_pkey PRIMARY KEY (id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_pkey PRIMARY KEY (id);


--
-- Name: vector_indexes vector_indexes_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.vector_indexes
    ADD CONSTRAINT vector_indexes_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_idempotency_key_key; Type: CONSTRAINT; Schema: supabase_migrations; Owner: -
--

ALTER TABLE ONLY supabase_migrations.schema_migrations
    ADD CONSTRAINT schema_migrations_idempotency_key_key UNIQUE (idempotency_key);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: supabase_migrations; Owner: -
--

ALTER TABLE ONLY supabase_migrations.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: seed_files seed_files_pkey; Type: CONSTRAINT; Schema: supabase_migrations; Owner: -
--

ALTER TABLE ONLY supabase_migrations.seed_files
    ADD CONSTRAINT seed_files_pkey PRIMARY KEY (path);


--
-- Name: audit_logs_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX audit_logs_instance_id_idx ON auth.audit_log_entries USING btree (instance_id);


--
-- Name: confirmation_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX confirmation_token_idx ON auth.users USING btree (confirmation_token) WHERE ((confirmation_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_current_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX email_change_token_current_idx ON auth.users USING btree (email_change_token_current) WHERE ((email_change_token_current)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_new_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX email_change_token_new_idx ON auth.users USING btree (email_change_token_new) WHERE ((email_change_token_new)::text !~ '^[0-9 ]*$'::text);


--
-- Name: factor_id_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX factor_id_created_at_idx ON auth.mfa_factors USING btree (user_id, created_at);


--
-- Name: flow_state_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX flow_state_created_at_idx ON auth.flow_state USING btree (created_at DESC);


--
-- Name: identities_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX identities_email_idx ON auth.identities USING btree (email text_pattern_ops);


--
-- Name: INDEX identities_email_idx; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON INDEX auth.identities_email_idx IS 'Auth: Ensures indexed queries on the email column';


--
-- Name: identities_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX identities_user_id_idx ON auth.identities USING btree (user_id);


--
-- Name: idx_auth_code; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_auth_code ON auth.flow_state USING btree (auth_code);


--
-- Name: idx_oauth_client_states_created_at; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_oauth_client_states_created_at ON auth.oauth_client_states USING btree (created_at);


--
-- Name: idx_user_id_auth_method; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_user_id_auth_method ON auth.flow_state USING btree (user_id, authentication_method);


--
-- Name: mfa_challenge_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX mfa_challenge_created_at_idx ON auth.mfa_challenges USING btree (created_at DESC);


--
-- Name: mfa_factors_user_friendly_name_unique; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX mfa_factors_user_friendly_name_unique ON auth.mfa_factors USING btree (friendly_name, user_id) WHERE (TRIM(BOTH FROM friendly_name) <> ''::text);


--
-- Name: mfa_factors_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX mfa_factors_user_id_idx ON auth.mfa_factors USING btree (user_id);


--
-- Name: oauth_auth_pending_exp_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_auth_pending_exp_idx ON auth.oauth_authorizations USING btree (expires_at) WHERE (status = 'pending'::auth.oauth_authorization_status);


--
-- Name: oauth_clients_deleted_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_clients_deleted_at_idx ON auth.oauth_clients USING btree (deleted_at);


--
-- Name: oauth_consents_active_client_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_consents_active_client_idx ON auth.oauth_consents USING btree (client_id) WHERE (revoked_at IS NULL);


--
-- Name: oauth_consents_active_user_client_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_consents_active_user_client_idx ON auth.oauth_consents USING btree (user_id, client_id) WHERE (revoked_at IS NULL);


--
-- Name: oauth_consents_user_order_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_consents_user_order_idx ON auth.oauth_consents USING btree (user_id, granted_at DESC);


--
-- Name: one_time_tokens_relates_to_hash_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX one_time_tokens_relates_to_hash_idx ON auth.one_time_tokens USING hash (relates_to);


--
-- Name: one_time_tokens_token_hash_hash_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX one_time_tokens_token_hash_hash_idx ON auth.one_time_tokens USING hash (token_hash);


--
-- Name: one_time_tokens_user_id_token_type_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX one_time_tokens_user_id_token_type_key ON auth.one_time_tokens USING btree (user_id, token_type);


--
-- Name: reauthentication_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX reauthentication_token_idx ON auth.users USING btree (reauthentication_token) WHERE ((reauthentication_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: recovery_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX recovery_token_idx ON auth.users USING btree (recovery_token) WHERE ((recovery_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: refresh_tokens_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_instance_id_idx ON auth.refresh_tokens USING btree (instance_id);


--
-- Name: refresh_tokens_instance_id_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_instance_id_user_id_idx ON auth.refresh_tokens USING btree (instance_id, user_id);


--
-- Name: refresh_tokens_parent_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_parent_idx ON auth.refresh_tokens USING btree (parent);


--
-- Name: refresh_tokens_session_id_revoked_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_session_id_revoked_idx ON auth.refresh_tokens USING btree (session_id, revoked);


--
-- Name: refresh_tokens_updated_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_updated_at_idx ON auth.refresh_tokens USING btree (updated_at DESC);


--
-- Name: saml_providers_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_providers_sso_provider_id_idx ON auth.saml_providers USING btree (sso_provider_id);


--
-- Name: saml_relay_states_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_relay_states_created_at_idx ON auth.saml_relay_states USING btree (created_at DESC);


--
-- Name: saml_relay_states_for_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_relay_states_for_email_idx ON auth.saml_relay_states USING btree (for_email);


--
-- Name: saml_relay_states_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_relay_states_sso_provider_id_idx ON auth.saml_relay_states USING btree (sso_provider_id);


--
-- Name: sessions_not_after_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sessions_not_after_idx ON auth.sessions USING btree (not_after DESC);


--
-- Name: sessions_oauth_client_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sessions_oauth_client_id_idx ON auth.sessions USING btree (oauth_client_id);


--
-- Name: sessions_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sessions_user_id_idx ON auth.sessions USING btree (user_id);


--
-- Name: sso_domains_domain_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX sso_domains_domain_idx ON auth.sso_domains USING btree (lower(domain));


--
-- Name: sso_domains_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sso_domains_sso_provider_id_idx ON auth.sso_domains USING btree (sso_provider_id);


--
-- Name: sso_providers_resource_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX sso_providers_resource_id_idx ON auth.sso_providers USING btree (lower(resource_id));


--
-- Name: sso_providers_resource_id_pattern_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sso_providers_resource_id_pattern_idx ON auth.sso_providers USING btree (resource_id text_pattern_ops);


--
-- Name: unique_phone_factor_per_user; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX unique_phone_factor_per_user ON auth.mfa_factors USING btree (user_id, phone);


--
-- Name: user_id_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX user_id_created_at_idx ON auth.sessions USING btree (user_id, created_at);


--
-- Name: users_email_partial_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX users_email_partial_key ON auth.users USING btree (email) WHERE (is_sso_user = false);


--
-- Name: INDEX users_email_partial_key; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON INDEX auth.users_email_partial_key IS 'Auth: A partial unique index that applies only when is_sso_user is false';


--
-- Name: users_instance_id_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX users_instance_id_email_idx ON auth.users USING btree (instance_id, lower((email)::text));


--
-- Name: users_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX users_instance_id_idx ON auth.users USING btree (instance_id);


--
-- Name: users_is_anonymous_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX users_is_anonymous_idx ON auth.users USING btree (is_anonymous);


--
-- Name: idx_account_shift_assignments_account; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_account_shift_assignments_account ON public.shift_assignments USING btree (game_account_id);


--
-- Name: idx_account_shift_assignments_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_account_shift_assignments_active ON public.shift_assignments USING btree (is_active);


--
-- Name: idx_account_shift_assignments_shift; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_account_shift_assignments_shift ON public.shift_assignments USING btree (shift_id);


--
-- Name: idx_assignment_trackers_key; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_assignment_trackers_key ON public.assignment_trackers USING btree (assignment_group_key);


--
-- Name: idx_attributes_is_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_attributes_is_active ON public.attributes USING btree (is_active);


--
-- Name: idx_attributes_sort_order; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_attributes_sort_order ON public.attributes USING btree (sort_order);


--
-- Name: idx_business_processes_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_business_processes_code ON public.business_processes USING btree (code);


--
-- Name: idx_business_processes_created_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_business_processes_created_by ON public.business_processes USING btree (created_by);


--
-- Name: idx_business_processes_purchase_channel_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_business_processes_purchase_channel_id ON public.business_processes USING btree (purchase_channel_id);


--
-- Name: idx_business_processes_sale_channel_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_business_processes_sale_channel_id ON public.business_processes USING btree (sale_channel_id);


--
-- Name: idx_channels_created_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_channels_created_by ON public.channels USING btree (created_by);


--
-- Name: idx_channels_updated_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_channels_updated_by ON public.channels USING btree (updated_by);


--
-- Name: idx_currencies_created_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_currencies_created_by ON public.currencies USING btree (created_by);


--
-- Name: idx_currencies_updated_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_currencies_updated_by ON public.currencies USING btree (updated_by);


--
-- Name: idx_currency_orders_assigned_to; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_currency_orders_assigned_to ON public.currency_orders USING btree (assigned_to);


--
-- Name: idx_currency_orders_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_currency_orders_created_at ON public.currency_orders USING btree (created_at DESC);


--
-- Name: idx_currency_orders_created_at_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_currency_orders_created_at_status ON public.currency_orders USING btree (created_at DESC, status);


--
-- Name: idx_currency_orders_created_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_currency_orders_created_by ON public.currency_orders USING btree (created_by);


--
-- Name: idx_currency_orders_currency_attribute_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_currency_orders_currency_attribute_id ON public.currency_orders USING btree (currency_attribute_id);


--
-- Name: idx_currency_orders_delivered_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_currency_orders_delivered_by ON public.currency_orders USING btree (delivered_by);


--
-- Name: idx_currency_orders_game_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_currency_orders_game_account_id ON public.currency_orders USING btree (game_account_id);


--
-- Name: idx_currency_orders_game_server; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_currency_orders_game_server ON public.currency_orders USING btree (game_code, server_attribute_code);


--
-- Name: idx_currency_orders_party_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_currency_orders_party_type ON public.currency_orders USING btree (party_id, order_type);


--
-- Name: idx_currency_orders_server_attribute_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_currency_orders_server_attribute_code ON public.currency_orders USING btree (server_attribute_code);


--
-- Name: idx_currency_orders_status_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_currency_orders_status_created ON public.currency_orders USING btree (status, created_at DESC);


--
-- Name: idx_currency_orders_submitted_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_currency_orders_submitted_by ON public.currency_orders USING btree (submitted_by);


--
-- Name: idx_currency_orders_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_currency_orders_type ON public.currency_orders USING btree (order_type);


--
-- Name: idx_currency_orders_type_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_currency_orders_type_status ON public.currency_orders USING btree (order_type, status);


--
-- Name: idx_currency_orders_updated_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_currency_orders_updated_by ON public.currency_orders USING btree (updated_by);


--
-- Name: idx_currency_transactions_created_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_currency_transactions_created_by ON public.currency_transactions USING btree (created_by);


--
-- Name: idx_currency_transactions_currency_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_currency_transactions_currency_code ON public.currency_transactions USING btree (currency_code);


--
-- Name: idx_currency_transactions_currency_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_currency_transactions_currency_order_id ON public.currency_transactions USING btree (currency_order_id);


--
-- Name: idx_currency_transactions_game_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_currency_transactions_game_account_id ON public.currency_transactions USING btree (game_account_id);


--
-- Name: idx_currency_transactions_game_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_currency_transactions_game_code ON public.currency_transactions USING btree (game_code);


--
-- Name: idx_currency_transactions_server_attribute_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_currency_transactions_server_attribute_code ON public.currency_transactions USING btree (server_attribute_code);


--
-- Name: idx_customer_accounts_btag; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_customer_accounts_btag ON public.customer_accounts USING btree (btag, login_id) WHERE ((btag IS NOT NULL) AND (login_id IS NOT NULL));


--
-- Name: idx_customer_accounts_game_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_customer_accounts_game_code ON public.customer_accounts USING btree (game_code);


--
-- Name: idx_customer_accounts_party_game; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_customer_accounts_party_game ON public.customer_accounts USING btree (party_id, game_code);


--
-- Name: idx_customer_accounts_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_customer_accounts_type ON public.customer_accounts USING btree (account_type);


--
-- Name: idx_employee_channels_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_employee_channels_active ON public.employee_channels USING btree (is_active);


--
-- Name: idx_employee_channels_channel; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_employee_channels_channel ON public.employee_channels USING btree (channel_type);


--
-- Name: idx_employee_channels_employee; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_employee_channels_employee ON public.employee_channels USING btree (employee_profile_id);


--
-- Name: idx_exchange_rate_api_log_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_exchange_rate_api_log_created_at ON public.exchange_rate_api_log USING btree (created_at);


--
-- Name: idx_exchange_rate_api_log_success; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_exchange_rate_api_log_success ON public.exchange_rate_api_log USING btree (success);


--
-- Name: idx_exchange_rates_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_exchange_rates_active ON public.exchange_rates USING btree (is_active) WHERE (is_active = true);


--
-- Name: idx_exchange_rates_config_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_exchange_rates_config_id ON public.exchange_rates USING btree (config_id);


--
-- Name: idx_exchange_rates_created_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_exchange_rates_created_by ON public.exchange_rates USING btree (created_by);


--
-- Name: idx_exchange_rates_effective_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_exchange_rates_effective_date ON public.exchange_rates USING btree (effective_date);


--
-- Name: idx_exchange_rates_updated_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_exchange_rates_updated_by ON public.exchange_rates USING btree (updated_by);


--
-- Name: idx_fees_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_fees_code ON public.fees USING btree (code);


--
-- Name: idx_fees_created_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_fees_created_by ON public.fees USING btree (created_by);


--
-- Name: idx_fees_direction; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_fees_direction ON public.fees USING btree (direction);


--
-- Name: idx_game_accounts_game_code_purpose; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_game_accounts_game_code_purpose ON public.game_accounts USING btree (game_code, purpose, is_active) WHERE (is_active = true);


--
-- Name: idx_game_accounts_server_attribute_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_game_accounts_server_attribute_code ON public.game_accounts USING btree (server_attribute_code);


--
-- Name: idx_inventory_pools_channel_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_inventory_pools_channel_id ON public.inventory_pools USING btree (channel_id);


--
-- Name: idx_inventory_pools_currency_attribute_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_inventory_pools_currency_attribute_id ON public.inventory_pools USING btree (currency_attribute_id);


--
-- Name: idx_inventory_pools_game_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_inventory_pools_game_account_id ON public.inventory_pools USING btree (game_account_id);


--
-- Name: idx_inventory_pools_game_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_inventory_pools_game_code ON public.inventory_pools USING btree (game_code);


--
-- Name: idx_inventory_pools_last_updated_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_inventory_pools_last_updated_by ON public.inventory_pools USING btree (last_updated_by);


--
-- Name: idx_inventory_pools_unique_business_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_inventory_pools_unique_business_key ON public.inventory_pools USING btree (game_account_id, currency_attribute_id, channel_id, cost_currency, game_code, COALESCE(server_attribute_code, ''::text));


--
-- Name: idx_order_lines_customer_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_order_lines_customer_account_id ON public.order_lines USING btree (customer_account_id);


--
-- Name: idx_order_lines_order_deadline; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_order_lines_order_deadline ON public.order_lines USING btree (order_id, deadline_to DESC);


--
-- Name: idx_order_lines_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_order_lines_order_id ON public.order_lines USING btree (order_id);


--
-- Name: idx_order_lines_variant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_order_lines_variant_id ON public.order_lines USING btree (variant_id);


--
-- Name: idx_order_reviews_created_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_order_reviews_created_by ON public.order_reviews USING btree (created_by);


--
-- Name: idx_order_reviews_order_line_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_order_reviews_order_line_id ON public.order_reviews USING btree (order_line_id);


--
-- Name: idx_order_reviews_order_line_id_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_order_reviews_order_line_id_created ON public.order_reviews USING btree (order_line_id, created_at DESC) WHERE (id IS NOT NULL);


--
-- Name: idx_order_service_items_order_line_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_order_service_items_order_line_id ON public.order_service_items USING btree (order_line_id);


--
-- Name: idx_orders_channel_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_orders_channel_id ON public.orders USING btree (channel_id);


--
-- Name: idx_orders_completed_recent; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_orders_completed_recent ON public.orders USING btree (updated_at DESC) WHERE (status = 'completed'::text);


--
-- Name: idx_orders_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_orders_created_at ON public.orders USING btree (created_at DESC);


--
-- Name: idx_orders_delivered_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_orders_delivered_at ON public.orders USING btree (delivered_at DESC);


--
-- Name: idx_orders_exchange_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_orders_exchange_type ON public.currency_orders USING btree (exchange_type) WHERE (exchange_type <> 'none'::public.currency_exchange_type_enum);


--
-- Name: idx_orders_for_review; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_orders_for_review ON public.orders USING btree (created_at DESC) WHERE (status = ANY (ARRAY['completed'::text, 'pending_completion'::text]));


--
-- Name: idx_orders_game_channel_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_orders_game_channel_status ON public.orders USING btree (game_code, channel_id, status, created_at DESC) INCLUDE (party_id, updated_at);


--
-- Name: idx_orders_game_code_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_orders_game_code_status ON public.orders USING btree (game_code, status) WHERE (status <> 'draft'::text);


--
-- Name: idx_orders_game_status_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_orders_game_status_created ON public.orders USING btree (game_code, status, created_at DESC);


--
-- Name: idx_orders_party_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_orders_party_id ON public.orders USING btree (party_id);


--
-- Name: idx_orders_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_orders_status ON public.orders USING btree (status);


--
-- Name: idx_orders_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_orders_updated_at ON public.orders USING btree (updated_at DESC);


--
-- Name: idx_parties_channel_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_parties_channel_id ON public.parties USING btree (channel_id);


--
-- Name: idx_parties_game_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_parties_game_code ON public.parties USING btree (game_code);


--
-- Name: idx_parties_name_gin; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_parties_name_gin ON public.parties USING gin (to_tsvector('simple'::regconfig, name));


--
-- Name: idx_parties_name_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_parties_name_trgm ON public.parties USING gin (name public.gin_trgm_ops);


--
-- Name: idx_parties_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_parties_type ON public.parties USING btree (type);


--
-- Name: idx_parties_type_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_parties_type_name ON public.parties USING btree (type, name);


--
-- Name: idx_process_fees_map_fee; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_process_fees_map_fee ON public.process_fees_map USING btree (fee_id);


--
-- Name: idx_process_fees_map_process; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_process_fees_map_process ON public.process_fees_map USING btree (process_id);


--
-- Name: idx_product_variants_display_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_product_variants_display_name ON public.product_variants USING btree (display_name, id) WHERE (display_name IS NOT NULL);


--
-- Name: idx_profile_status_logs_changed_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_profile_status_logs_changed_by ON public.profile_status_logs USING btree (changed_by);


--
-- Name: idx_profile_status_logs_profile_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_profile_status_logs_profile_id ON public.profile_status_logs USING btree (profile_id);


--
-- Name: idx_role_permissions_permission_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_role_permissions_permission_id ON public.role_permissions USING btree (permission_id);


--
-- Name: idx_service_reports_order_line_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_service_reports_order_line_id ON public.service_reports USING btree (order_line_id);


--
-- Name: idx_service_reports_order_service_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_service_reports_order_service_item_id ON public.service_reports USING btree (order_service_item_id);


--
-- Name: idx_service_reports_reported_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_service_reports_reported_by ON public.service_reports USING btree (reported_by);


--
-- Name: idx_service_reports_resolved_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_service_reports_resolved_by ON public.service_reports USING btree (resolved_by);


--
-- Name: idx_service_reports_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_service_reports_status ON public.service_reports USING btree (status) WHERE (status = 'new'::text);


--
-- Name: idx_user_role_assignments_business_area_attribute_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_role_assignments_business_area_attribute_id ON public.user_role_assignments USING btree (business_area_attribute_id);


--
-- Name: idx_user_role_assignments_game_attribute_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_role_assignments_game_attribute_id ON public.user_role_assignments USING btree (game_attribute_id);


--
-- Name: idx_user_role_assignments_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_role_assignments_role_id ON public.user_role_assignments USING btree (role_id);


--
-- Name: idx_user_role_assignments_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_role_assignments_user_id ON public.user_role_assignments USING btree (user_id);


--
-- Name: idx_work_sessions_order_ended; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_work_sessions_order_ended ON public.work_sessions USING btree (order_line_id, ended_at) WHERE (ended_at IS NULL);


--
-- Name: idx_work_sessions_order_line_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_work_sessions_order_line_id ON public.work_sessions USING btree (order_line_id, ended_at) WHERE (ended_at IS NULL);


--
-- Name: ix_attribute_relationships_child; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_attribute_relationships_child ON public.attribute_relationships USING btree (child_attribute_id);


--
-- Name: ix_attribute_relationships_parent; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_attribute_relationships_parent ON public.attribute_relationships USING btree (parent_attribute_id);


--
-- Name: ix_order_lines_customer_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_order_lines_customer_account_id ON public.order_lines USING btree (customer_account_id);


--
-- Name: ix_order_lines_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_order_lines_order_id ON public.order_lines USING btree (order_id);


--
-- Name: ix_order_service_items_order_line_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_order_service_items_order_line_id ON public.order_service_items USING btree (order_line_id);


--
-- Name: ix_orders_channel_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_orders_channel_id ON public.orders USING btree (channel_id);


--
-- Name: ix_orders_created_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_orders_created_by ON public.orders USING btree (created_by);


--
-- Name: ix_orders_currency_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_orders_currency_id ON public.orders USING btree (currency_id);


--
-- Name: ix_orders_party_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_orders_party_id ON public.orders USING btree (party_id);


--
-- Name: ix_work_session_outputs_osid_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_work_session_outputs_osid_id ON public.work_session_outputs USING btree (order_service_item_id);


--
-- Name: ix_work_session_outputs_work_session_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_work_session_outputs_work_session_id ON public.work_session_outputs USING btree (work_session_id);


--
-- Name: ix_work_sessions_farmer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_work_sessions_farmer_id ON public.work_sessions USING btree (farmer_id);


--
-- Name: ix_work_sessions_order_line_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_work_sessions_order_line_id ON public.work_sessions USING btree (order_line_id);


--
-- Name: mv_active_farmers_order_line_id_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mv_active_farmers_order_line_id_unique ON public.mv_active_farmers USING btree (order_line_id);


--
-- Name: ix_realtime_subscription_entity; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX ix_realtime_subscription_entity ON realtime.subscription USING btree (entity);


--
-- Name: messages_inserted_at_topic_index; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX messages_inserted_at_topic_index ON ONLY realtime.messages USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: messages_2025_12_13_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX messages_2025_12_13_inserted_at_topic_idx ON realtime.messages_2025_12_13 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: messages_2025_12_14_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX messages_2025_12_14_inserted_at_topic_idx ON realtime.messages_2025_12_14 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: messages_2025_12_15_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX messages_2025_12_15_inserted_at_topic_idx ON realtime.messages_2025_12_15 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: messages_2025_12_16_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX messages_2025_12_16_inserted_at_topic_idx ON realtime.messages_2025_12_16 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: messages_2025_12_17_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX messages_2025_12_17_inserted_at_topic_idx ON realtime.messages_2025_12_17 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: messages_2025_12_18_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX messages_2025_12_18_inserted_at_topic_idx ON realtime.messages_2025_12_18 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: messages_2025_12_19_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX messages_2025_12_19_inserted_at_topic_idx ON realtime.messages_2025_12_19 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: subscription_subscription_id_entity_filters_key; Type: INDEX; Schema: realtime; Owner: -
--

CREATE UNIQUE INDEX subscription_subscription_id_entity_filters_key ON realtime.subscription USING btree (subscription_id, entity, filters);


--
-- Name: bname; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX bname ON storage.buckets USING btree (name);


--
-- Name: bucketid_objname; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX bucketid_objname ON storage.objects USING btree (bucket_id, name);


--
-- Name: buckets_analytics_unique_name_idx; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX buckets_analytics_unique_name_idx ON storage.buckets_analytics USING btree (name) WHERE (deleted_at IS NULL);


--
-- Name: idx_multipart_uploads_list; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX idx_multipart_uploads_list ON storage.s3_multipart_uploads USING btree (bucket_id, key, created_at);


--
-- Name: idx_name_bucket_level_unique; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX idx_name_bucket_level_unique ON storage.objects USING btree (name COLLATE "C", bucket_id, level);


--
-- Name: idx_objects_bucket_id_name; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX idx_objects_bucket_id_name ON storage.objects USING btree (bucket_id, name COLLATE "C");


--
-- Name: idx_objects_lower_name; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX idx_objects_lower_name ON storage.objects USING btree ((path_tokens[level]), lower(name) text_pattern_ops, bucket_id, level);


--
-- Name: idx_prefixes_lower_name; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX idx_prefixes_lower_name ON storage.prefixes USING btree (bucket_id, level, ((string_to_array(name, '/'::text))[level]), lower(name) text_pattern_ops);


--
-- Name: name_prefix_search; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX name_prefix_search ON storage.objects USING btree (name text_pattern_ops);


--
-- Name: objects_bucket_id_level_idx; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX objects_bucket_id_level_idx ON storage.objects USING btree (bucket_id, level, name COLLATE "C");


--
-- Name: vector_indexes_name_bucket_id_idx; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX vector_indexes_name_bucket_id_idx ON storage.vector_indexes USING btree (name, bucket_id);


--
-- Name: messages_2025_12_13_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2025_12_13_inserted_at_topic_idx;


--
-- Name: messages_2025_12_13_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2025_12_13_pkey;


--
-- Name: messages_2025_12_14_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2025_12_14_inserted_at_topic_idx;


--
-- Name: messages_2025_12_14_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2025_12_14_pkey;


--
-- Name: messages_2025_12_15_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2025_12_15_inserted_at_topic_idx;


--
-- Name: messages_2025_12_15_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2025_12_15_pkey;


--
-- Name: messages_2025_12_16_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2025_12_16_inserted_at_topic_idx;


--
-- Name: messages_2025_12_16_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2025_12_16_pkey;


--
-- Name: messages_2025_12_17_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2025_12_17_inserted_at_topic_idx;


--
-- Name: messages_2025_12_17_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2025_12_17_pkey;


--
-- Name: messages_2025_12_18_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2025_12_18_inserted_at_topic_idx;


--
-- Name: messages_2025_12_18_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2025_12_18_pkey;


--
-- Name: messages_2025_12_19_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2025_12_19_inserted_at_topic_idx;


--
-- Name: messages_2025_12_19_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2025_12_19_pkey;


--
-- Name: users on_auth_user_created; Type: TRIGGER; Schema: auth; Owner: -
--

CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user_with_trial_role();


--
-- Name: business_processes business_processes_channels_currencies_validate; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER business_processes_channels_currencies_validate BEFORE INSERT OR UPDATE ON public.business_processes FOR EACH ROW EXECUTE FUNCTION public.validate_business_processes_channels_currencies();


--
-- Name: customer_accounts customer_accounts_updated_at_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER customer_accounts_updated_at_trigger BEFORE UPDATE ON public.customer_accounts FOR EACH ROW EXECUTE FUNCTION public.update_customer_accounts_updated_at();


--
-- Name: channels handle_channels_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER handle_channels_updated_at BEFORE UPDATE ON public.channels FOR EACH ROW EXECUTE FUNCTION public.handle_channels_updated_at();


--
-- Name: currencies handle_currencies_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER handle_currencies_updated_at BEFORE UPDATE ON public.currencies FOR EACH ROW EXECUTE FUNCTION public.handle_currencies_updated_at();


--
-- Name: orders on_orders_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER on_orders_update BEFORE UPDATE ON public.orders FOR EACH ROW EXECUTE FUNCTION public.handle_orders_updated_at();


--
-- Name: parties parties_updated_at_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER parties_updated_at_trigger BEFORE UPDATE ON public.parties FOR EACH ROW EXECUTE FUNCTION public.update_parties_updated_at();


--
-- Name: profiles profile_status_change_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER profile_status_change_trigger AFTER UPDATE OF status ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.log_profile_status_change();


--
-- Name: order_service_items tr_after_update_order_service_items; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER tr_after_update_order_service_items AFTER UPDATE ON public.order_service_items FOR EACH ROW EXECUTE FUNCTION public.tr_check_all_items_completed_v1();


--
-- Name: work_sessions tr_auto_initialize_pilot_cycle_on_first_session; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER tr_auto_initialize_pilot_cycle_on_first_session AFTER INSERT ON public.work_sessions FOR EACH ROW EXECUTE FUNCTION public.tr_auto_initialize_pilot_cycle_on_first_session();


--
-- Name: order_lines tr_auto_initialize_pilot_cycle_on_order_create; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER tr_auto_initialize_pilot_cycle_on_order_create AFTER INSERT ON public.order_lines FOR EACH ROW EXECUTE FUNCTION public.tr_auto_initialize_pilot_cycle_on_order_create();


--
-- Name: order_lines tr_auto_update_pilot_cycle_on_pause_change; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER tr_auto_update_pilot_cycle_on_pause_change AFTER UPDATE OF paused_at ON public.order_lines FOR EACH ROW WHEN ((old.paused_at IS DISTINCT FROM new.paused_at)) EXECUTE FUNCTION public.tr_auto_update_pilot_cycle_on_pause_change();


--
-- Name: work_sessions tr_auto_update_pilot_cycle_on_session_end; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER tr_auto_update_pilot_cycle_on_session_end AFTER UPDATE OF ended_at ON public.work_sessions FOR EACH ROW WHEN (((old.ended_at IS NULL) AND (new.ended_at IS NOT NULL))) EXECUTE FUNCTION public.tr_auto_update_pilot_cycle_on_session_end();


--
-- Name: work_sessions tr_pilot_cycle_first_session; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER tr_pilot_cycle_first_session AFTER INSERT ON public.work_sessions FOR EACH ROW WHEN ((new.ended_at IS NULL)) EXECUTE FUNCTION public.tr_auto_initialize_pilot_cycle_on_first_session();


--
-- Name: order_lines tr_pilot_cycle_order_create; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER tr_pilot_cycle_order_create BEFORE INSERT ON public.order_lines FOR EACH ROW EXECUTE FUNCTION public.tr_auto_initialize_pilot_cycle_on_order_create();


--
-- Name: order_lines tr_pilot_cycle_pause_change; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER tr_pilot_cycle_pause_change AFTER UPDATE ON public.order_lines FOR EACH ROW WHEN ((old.paused_at IS DISTINCT FROM new.paused_at)) EXECUTE FUNCTION public.tr_auto_update_pilot_cycle_on_pause_change();


--
-- Name: work_sessions tr_pilot_cycle_work_session_end; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER tr_pilot_cycle_work_session_end AFTER UPDATE ON public.work_sessions FOR EACH ROW WHEN (((old.ended_at IS NULL) AND (new.ended_at IS NOT NULL))) EXECUTE FUNCTION public.tr_auto_update_pilot_cycle_on_session_end();


--
-- Name: game_accounts trigger_handle_game_account_status_change; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_handle_game_account_status_change AFTER UPDATE OF is_active ON public.game_accounts FOR EACH ROW WHEN ((old.is_active IS DISTINCT FROM new.is_active)) EXECUTE FUNCTION public.handle_game_account_status_change();


--
-- Name: game_accounts trigger_handle_game_account_status_change_for_pools; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_handle_game_account_status_change_for_pools AFTER UPDATE ON public.game_accounts FOR EACH ROW EXECUTE FUNCTION public.handle_game_account_status_change_for_pools();


--
-- Name: subscription tr_check_filters; Type: TRIGGER; Schema: realtime; Owner: -
--

CREATE TRIGGER tr_check_filters BEFORE INSERT OR UPDATE ON realtime.subscription FOR EACH ROW EXECUTE FUNCTION realtime.subscription_check_filters();


--
-- Name: buckets enforce_bucket_name_length_trigger; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER enforce_bucket_name_length_trigger BEFORE INSERT OR UPDATE OF name ON storage.buckets FOR EACH ROW EXECUTE FUNCTION storage.enforce_bucket_name_length();


--
-- Name: objects objects_delete_delete_prefix; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER objects_delete_delete_prefix AFTER DELETE ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.delete_prefix_hierarchy_trigger();


--
-- Name: objects objects_insert_create_prefix; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER objects_insert_create_prefix BEFORE INSERT ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.objects_insert_prefix_trigger();


--
-- Name: objects objects_update_create_prefix; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER objects_update_create_prefix BEFORE UPDATE ON storage.objects FOR EACH ROW WHEN (((new.name <> old.name) OR (new.bucket_id <> old.bucket_id))) EXECUTE FUNCTION storage.objects_update_prefix_trigger();


--
-- Name: prefixes prefixes_create_hierarchy; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER prefixes_create_hierarchy BEFORE INSERT ON storage.prefixes FOR EACH ROW WHEN ((pg_trigger_depth() < 1)) EXECUTE FUNCTION storage.prefixes_insert_trigger();


--
-- Name: prefixes prefixes_delete_hierarchy; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER prefixes_delete_hierarchy AFTER DELETE ON storage.prefixes FOR EACH ROW EXECUTE FUNCTION storage.delete_prefix_hierarchy_trigger();


--
-- Name: objects update_objects_updated_at; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER update_objects_updated_at BEFORE UPDATE ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.update_updated_at_column();


--
-- Name: identities identities_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: mfa_challenges mfa_challenges_auth_factor_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_auth_factor_id_fkey FOREIGN KEY (factor_id) REFERENCES auth.mfa_factors(id) ON DELETE CASCADE;


--
-- Name: mfa_factors mfa_factors_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: oauth_authorizations oauth_authorizations_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_client_id_fkey FOREIGN KEY (client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: oauth_authorizations oauth_authorizations_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: oauth_consents oauth_consents_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_client_id_fkey FOREIGN KEY (client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: oauth_consents oauth_consents_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: one_time_tokens one_time_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: refresh_tokens refresh_tokens_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: saml_providers saml_providers_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_flow_state_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_flow_state_id_fkey FOREIGN KEY (flow_state_id) REFERENCES auth.flow_state(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_oauth_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_oauth_client_id_fkey FOREIGN KEY (oauth_client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: sso_domains sso_domains_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: shift_assignments account_shift_assignments_employee_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shift_assignments
    ADD CONSTRAINT account_shift_assignments_employee_profile_id_fkey FOREIGN KEY (employee_profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: shift_assignments account_shift_assignments_game_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shift_assignments
    ADD CONSTRAINT account_shift_assignments_game_account_id_fkey FOREIGN KEY (game_account_id) REFERENCES public.game_accounts(id) ON DELETE CASCADE;


--
-- Name: shift_assignments account_shift_assignments_shift_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shift_assignments
    ADD CONSTRAINT account_shift_assignments_shift_id_fkey FOREIGN KEY (shift_id) REFERENCES public.work_shifts(id) ON DELETE CASCADE;


--
-- Name: attribute_relationships attribute_relationships_child_attribute_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attribute_relationships
    ADD CONSTRAINT attribute_relationships_child_attribute_id_fkey FOREIGN KEY (child_attribute_id) REFERENCES public.attributes(id) ON DELETE CASCADE;


--
-- Name: attribute_relationships attribute_relationships_parent_attribute_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attribute_relationships
    ADD CONSTRAINT attribute_relationships_parent_attribute_id_fkey FOREIGN KEY (parent_attribute_id) REFERENCES public.attributes(id) ON DELETE CASCADE;


--
-- Name: business_processes business_processes_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.business_processes
    ADD CONSTRAINT business_processes_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.profiles(id);


--
-- Name: business_processes business_processes_purchase_channel_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.business_processes
    ADD CONSTRAINT business_processes_purchase_channel_id_fkey FOREIGN KEY (purchase_channel_id) REFERENCES public.channels(id);


--
-- Name: business_processes business_processes_sale_channel_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.business_processes
    ADD CONSTRAINT business_processes_sale_channel_id_fkey FOREIGN KEY (sale_channel_id) REFERENCES public.channels(id);


--
-- Name: channels channels_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.channels
    ADD CONSTRAINT channels_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.profiles(id);


--
-- Name: channels channels_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.channels
    ADD CONSTRAINT channels_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.profiles(id);


--
-- Name: currencies currencies_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.currencies
    ADD CONSTRAINT currencies_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.profiles(id);


--
-- Name: currencies currencies_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.currencies
    ADD CONSTRAINT currencies_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.profiles(id);


--
-- Name: currency_orders currency_orders_assigned_to_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.currency_orders
    ADD CONSTRAINT currency_orders_assigned_to_fkey FOREIGN KEY (assigned_to) REFERENCES public.profiles(id);


--
-- Name: currency_orders currency_orders_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.currency_orders
    ADD CONSTRAINT currency_orders_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.profiles(id);


--
-- Name: currency_orders currency_orders_currency_attribute_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.currency_orders
    ADD CONSTRAINT currency_orders_currency_attribute_id_fkey FOREIGN KEY (currency_attribute_id) REFERENCES public.attributes(id);


--
-- Name: currency_orders currency_orders_delivered_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.currency_orders
    ADD CONSTRAINT currency_orders_delivered_by_fkey FOREIGN KEY (delivered_by) REFERENCES public.profiles(id);


--
-- Name: currency_orders currency_orders_foreign_currency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.currency_orders
    ADD CONSTRAINT currency_orders_foreign_currency_id_fkey FOREIGN KEY (foreign_currency_id) REFERENCES public.attributes(id);


--
-- Name: currency_orders currency_orders_game_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.currency_orders
    ADD CONSTRAINT currency_orders_game_account_id_fkey FOREIGN KEY (game_account_id) REFERENCES public.game_accounts(id);


--
-- Name: currency_orders currency_orders_party_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.currency_orders
    ADD CONSTRAINT currency_orders_party_id_fkey FOREIGN KEY (party_id) REFERENCES public.parties(id);


--
-- Name: currency_orders currency_orders_submitted_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.currency_orders
    ADD CONSTRAINT currency_orders_submitted_by_fkey FOREIGN KEY (submitted_by) REFERENCES public.profiles(id);


--
-- Name: currency_orders currency_orders_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.currency_orders
    ADD CONSTRAINT currency_orders_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.profiles(id);


--
-- Name: currency_transactions currency_transactions_channel_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.currency_transactions
    ADD CONSTRAINT currency_transactions_channel_id_fkey FOREIGN KEY (channel_id) REFERENCES public.channels(id);


--
-- Name: currency_transactions currency_transactions_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.currency_transactions
    ADD CONSTRAINT currency_transactions_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.profiles(id);


--
-- Name: currency_transactions currency_transactions_currency_attribute_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.currency_transactions
    ADD CONSTRAINT currency_transactions_currency_attribute_id_fkey FOREIGN KEY (currency_attribute_id) REFERENCES public.attributes(id);


--
-- Name: currency_transactions currency_transactions_currency_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.currency_transactions
    ADD CONSTRAINT currency_transactions_currency_order_id_fkey FOREIGN KEY (currency_order_id) REFERENCES public.currency_orders(id) ON DELETE SET NULL;


--
-- Name: currency_transactions currency_transactions_game_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.currency_transactions
    ADD CONSTRAINT currency_transactions_game_account_id_fkey FOREIGN KEY (game_account_id) REFERENCES public.game_accounts(id);


--
-- Name: customer_accounts customer_accounts_party_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_accounts
    ADD CONSTRAINT customer_accounts_party_id_fkey FOREIGN KEY (party_id) REFERENCES public.parties(id);


--
-- Name: employee_channels employee_channels_employee_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employee_channels
    ADD CONSTRAINT employee_channels_employee_profile_id_fkey FOREIGN KEY (employee_profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: exchange_rates exchange_rates_config_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exchange_rates
    ADD CONSTRAINT exchange_rates_config_id_fkey FOREIGN KEY (config_id) REFERENCES public.exchange_rate_config(id);


--
-- Name: exchange_rates exchange_rates_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exchange_rates
    ADD CONSTRAINT exchange_rates_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.profiles(id);


--
-- Name: exchange_rates exchange_rates_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exchange_rates
    ADD CONSTRAINT exchange_rates_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.profiles(id);


--
-- Name: fees fees_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fees
    ADD CONSTRAINT fees_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.profiles(id);


--
-- Name: currency_orders fk_currency_orders_game_code; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.currency_orders
    ADD CONSTRAINT fk_currency_orders_game_code FOREIGN KEY (game_code) REFERENCES public.attributes(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: currency_orders fk_currency_orders_inventory_pool; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.currency_orders
    ADD CONSTRAINT fk_currency_orders_inventory_pool FOREIGN KEY (inventory_pool_id) REFERENCES public.inventory_pools(id) ON DELETE SET NULL;


--
-- Name: currency_orders fk_currency_orders_server_attribute_code; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.currency_orders
    ADD CONSTRAINT fk_currency_orders_server_attribute_code FOREIGN KEY (server_attribute_code) REFERENCES public.attributes(code);


--
-- Name: currency_transactions fk_currency_transactions_currency_code; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.currency_transactions
    ADD CONSTRAINT fk_currency_transactions_currency_code FOREIGN KEY (currency_code) REFERENCES public.currencies(code);


--
-- Name: currency_transactions fk_currency_transactions_game_code; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.currency_transactions
    ADD CONSTRAINT fk_currency_transactions_game_code FOREIGN KEY (game_code) REFERENCES public.attributes(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: currency_transactions fk_currency_transactions_server_attribute_code; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.currency_transactions
    ADD CONSTRAINT fk_currency_transactions_server_attribute_code FOREIGN KEY (server_attribute_code) REFERENCES public.attributes(code);


--
-- Name: customer_accounts fk_customer_accounts_game_code; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_accounts
    ADD CONSTRAINT fk_customer_accounts_game_code FOREIGN KEY (game_code) REFERENCES public.attributes(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: game_accounts fk_game_accounts_game_code; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.game_accounts
    ADD CONSTRAINT fk_game_accounts_game_code FOREIGN KEY (game_code) REFERENCES public.attributes(code) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CONSTRAINT fk_game_accounts_game_code ON game_accounts; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON CONSTRAINT fk_game_accounts_game_code ON public.game_accounts IS 'Ensures game_code references a valid game attribute (type=GAME)';


--
-- Name: inventory_pools fk_inventory_pools_game_code; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_pools
    ADD CONSTRAINT fk_inventory_pools_game_code FOREIGN KEY (game_code) REFERENCES public.attributes(code);


--
-- Name: CONSTRAINT fk_inventory_pools_game_code ON inventory_pools; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON CONSTRAINT fk_inventory_pools_game_code ON public.inventory_pools IS 'Foreign key to attributes table for game_code - ensuring consistency with currency_inventory structure';


--
-- Name: order_service_items fk_service_kind; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_service_items
    ADD CONSTRAINT fk_service_kind FOREIGN KEY (service_kind_id) REFERENCES public.attributes(id);


--
-- Name: game_accounts game_accounts_server_attribute_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.game_accounts
    ADD CONSTRAINT game_accounts_server_attribute_code_fkey FOREIGN KEY (server_attribute_code) REFERENCES public.attributes(code);


--
-- Name: inventory_pools inventory_pools_channel_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_pools
    ADD CONSTRAINT inventory_pools_channel_id_fkey FOREIGN KEY (channel_id) REFERENCES public.channels(id);


--
-- Name: inventory_pools inventory_pools_currency_attribute_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_pools
    ADD CONSTRAINT inventory_pools_currency_attribute_id_fkey FOREIGN KEY (currency_attribute_id) REFERENCES public.attributes(id);


--
-- Name: inventory_pools inventory_pools_game_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_pools
    ADD CONSTRAINT inventory_pools_game_account_id_fkey FOREIGN KEY (game_account_id) REFERENCES public.game_accounts(id);


--
-- Name: inventory_pools inventory_pools_last_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_pools
    ADD CONSTRAINT inventory_pools_last_updated_by_fkey FOREIGN KEY (last_updated_by) REFERENCES public.profiles(id);


--
-- Name: inventory_pools inventory_pools_server_attribute_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_pools
    ADD CONSTRAINT inventory_pools_server_attribute_code_fkey FOREIGN KEY (server_attribute_code) REFERENCES public.attributes(code);


--
-- Name: order_lines order_lines_customer_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_lines
    ADD CONSTRAINT order_lines_customer_account_id_fkey FOREIGN KEY (customer_account_id) REFERENCES public.customer_accounts(id);


--
-- Name: order_lines order_lines_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_lines
    ADD CONSTRAINT order_lines_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE;


--
-- Name: order_lines order_lines_variant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_lines
    ADD CONSTRAINT order_lines_variant_id_fkey FOREIGN KEY (variant_id) REFERENCES public.product_variants(id);


--
-- Name: order_reviews order_reviews_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_reviews
    ADD CONSTRAINT order_reviews_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.profiles(id);


--
-- Name: order_reviews order_reviews_order_line_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_reviews
    ADD CONSTRAINT order_reviews_order_line_id_fkey FOREIGN KEY (order_line_id) REFERENCES public.order_lines(id) ON DELETE CASCADE;


--
-- Name: order_service_items order_service_items_order_line_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_service_items
    ADD CONSTRAINT order_service_items_order_line_id_fkey FOREIGN KEY (order_line_id) REFERENCES public.order_lines(id) ON DELETE CASCADE;


--
-- Name: orders orders_channel_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_channel_id_fkey FOREIGN KEY (channel_id) REFERENCES public.channels(id);


--
-- Name: orders orders_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.profiles(id);


--
-- Name: orders orders_currency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_currency_id_fkey FOREIGN KEY (currency_id) REFERENCES public.currencies(id);


--
-- Name: orders orders_party_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_party_id_fkey FOREIGN KEY (party_id) REFERENCES public.parties(id);


--
-- Name: parties parties_channel_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parties
    ADD CONSTRAINT parties_channel_id_fkey FOREIGN KEY (channel_id) REFERENCES public.channels(id);


--
-- Name: process_fees_map process_fees_map_fee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.process_fees_map
    ADD CONSTRAINT process_fees_map_fee_id_fkey FOREIGN KEY (fee_id) REFERENCES public.fees(id) ON DELETE CASCADE;


--
-- Name: process_fees_map process_fees_map_process_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.process_fees_map
    ADD CONSTRAINT process_fees_map_process_id_fkey FOREIGN KEY (process_id) REFERENCES public.business_processes(id) ON DELETE CASCADE;


--
-- Name: product_variant_attributes product_variant_attributes_attribute_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_variant_attributes
    ADD CONSTRAINT product_variant_attributes_attribute_id_fkey FOREIGN KEY (attribute_id) REFERENCES public.attributes(id) ON DELETE CASCADE;


--
-- Name: product_variant_attributes product_variant_attributes_variant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_variant_attributes
    ADD CONSTRAINT product_variant_attributes_variant_id_fkey FOREIGN KEY (variant_id) REFERENCES public.product_variants(id) ON DELETE CASCADE;


--
-- Name: product_variants product_variants_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_variants
    ADD CONSTRAINT product_variants_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: profile_status_logs profile_status_logs_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profile_status_logs
    ADD CONSTRAINT profile_status_logs_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: profiles profiles_auth_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_auth_id_fkey FOREIGN KEY (auth_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: role_permissions role_permissions_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES public.permissions(id) ON DELETE CASCADE;


--
-- Name: role_permissions role_permissions_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE CASCADE;


--
-- Name: service_reports service_reports_order_line_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.service_reports
    ADD CONSTRAINT service_reports_order_line_id_fkey FOREIGN KEY (order_line_id) REFERENCES public.order_lines(id);


--
-- Name: service_reports service_reports_order_service_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.service_reports
    ADD CONSTRAINT service_reports_order_service_item_id_fkey FOREIGN KEY (order_service_item_id) REFERENCES public.order_service_items(id);


--
-- Name: service_reports service_reports_reported_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.service_reports
    ADD CONSTRAINT service_reports_reported_by_fkey FOREIGN KEY (reported_by) REFERENCES public.profiles(id);


--
-- Name: service_reports service_reports_resolved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.service_reports
    ADD CONSTRAINT service_reports_resolved_by_fkey FOREIGN KEY (resolved_by) REFERENCES public.profiles(id);


--
-- Name: shift_assignments shift_assignments_channels_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shift_assignments
    ADD CONSTRAINT shift_assignments_channels_id_fkey FOREIGN KEY (channels_id) REFERENCES public.channels(id);


--
-- Name: user_role_assignments user_role_assignments_business_area_attribute_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_role_assignments
    ADD CONSTRAINT user_role_assignments_business_area_attribute_id_fkey FOREIGN KEY (business_area_attribute_id) REFERENCES public.attributes(id) ON DELETE SET NULL;


--
-- Name: user_role_assignments user_role_assignments_game_attribute_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_role_assignments
    ADD CONSTRAINT user_role_assignments_game_attribute_id_fkey FOREIGN KEY (game_attribute_id) REFERENCES public.attributes(id) ON DELETE SET NULL;


--
-- Name: user_role_assignments user_role_assignments_role_id_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_role_assignments
    ADD CONSTRAINT user_role_assignments_role_id_fkey1 FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE CASCADE;


--
-- Name: user_role_assignments user_role_assignments_user_id_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_role_assignments
    ADD CONSTRAINT user_role_assignments_user_id_fkey1 FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: work_session_outputs work_session_outputs_order_service_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_session_outputs
    ADD CONSTRAINT work_session_outputs_order_service_item_id_fkey FOREIGN KEY (order_service_item_id) REFERENCES public.order_service_items(id);


--
-- Name: work_session_outputs work_session_outputs_work_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_session_outputs
    ADD CONSTRAINT work_session_outputs_work_session_id_fkey FOREIGN KEY (work_session_id) REFERENCES public.work_sessions(id) ON DELETE CASCADE;


--
-- Name: work_sessions work_sessions_farmer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_sessions
    ADD CONSTRAINT work_sessions_farmer_id_fkey FOREIGN KEY (farmer_id) REFERENCES public.profiles(id);


--
-- Name: work_sessions work_sessions_order_line_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_sessions
    ADD CONSTRAINT work_sessions_order_line_id_fkey FOREIGN KEY (order_line_id) REFERENCES public.order_lines(id);


--
-- Name: objects objects_bucketId_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT "objects_bucketId_fkey" FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: prefixes prefixes_bucketId_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.prefixes
    ADD CONSTRAINT "prefixes_bucketId_fkey" FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_upload_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_upload_id_fkey FOREIGN KEY (upload_id) REFERENCES storage.s3_multipart_uploads(id) ON DELETE CASCADE;


--
-- Name: vector_indexes vector_indexes_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.vector_indexes
    ADD CONSTRAINT vector_indexes_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets_vectors(id);


--
-- Name: audit_log_entries; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.audit_log_entries ENABLE ROW LEVEL SECURITY;

--
-- Name: flow_state; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.flow_state ENABLE ROW LEVEL SECURITY;

--
-- Name: identities; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.identities ENABLE ROW LEVEL SECURITY;

--
-- Name: instances; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.instances ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_amr_claims; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.mfa_amr_claims ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_challenges; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.mfa_challenges ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_factors; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.mfa_factors ENABLE ROW LEVEL SECURITY;

--
-- Name: one_time_tokens; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.one_time_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: refresh_tokens; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.refresh_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_providers; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.saml_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_relay_states; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.saml_relay_states ENABLE ROW LEVEL SECURITY;

--
-- Name: schema_migrations; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.schema_migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: sessions; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.sessions ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_domains; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.sso_domains ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_providers; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.sso_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: users; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;

--
-- Name: role_permissions Allow admin to delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow admin to delete" ON public.role_permissions FOR DELETE TO authenticated USING (public.has_permission('admin:manage_roles'::text));


--
-- Name: role_permissions Allow admin to insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow admin to insert" ON public.role_permissions FOR INSERT TO authenticated WITH CHECK (public.has_permission('admin:manage_roles'::text));


--
-- Name: debug_log Allow admin to manage debug logs; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow admin to manage debug logs" ON public.debug_log TO authenticated USING (public.has_permission('admin:manage_roles'::text)) WITH CHECK (public.has_permission('admin:manage_roles'::text));


--
-- Name: permissions Allow admin to manage permissions; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow admin to manage permissions" ON public.permissions TO authenticated USING (public.has_permission('admin:manage_roles'::text)) WITH CHECK (public.has_permission('admin:manage_roles'::text));


--
-- Name: role_permissions Allow admin to update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow admin to update" ON public.role_permissions FOR UPDATE TO authenticated USING (public.has_permission('admin:manage_roles'::text));


--
-- Name: user_role_assignments Allow admins to delete assignments; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow admins to delete assignments" ON public.user_role_assignments FOR DELETE TO authenticated USING (public.has_permission('admin:manage_roles'::text));


--
-- Name: user_role_assignments Allow admins to insert assignments; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow admins to insert assignments" ON public.user_role_assignments FOR INSERT TO authenticated WITH CHECK (public.has_permission('admin:manage_roles'::text));


--
-- Name: user_role_assignments Allow admins to update assignments; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow admins to update assignments" ON public.user_role_assignments FOR UPDATE TO authenticated USING (public.has_permission('admin:manage_roles'::text));


--
-- Name: attribute_relationships Allow authenticated read access; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow authenticated read access" ON public.attribute_relationships FOR SELECT TO authenticated USING (true);


--
-- Name: attributes Allow authenticated read access; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow authenticated read access" ON public.attributes FOR SELECT TO authenticated USING (true);


--
-- Name: currencies Allow authenticated read access; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow authenticated read access" ON public.currencies FOR SELECT USING ((is_active = true));


--
-- Name: customer_accounts Allow authenticated read access; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow authenticated read access" ON public.customer_accounts FOR SELECT TO authenticated USING (true);


--
-- Name: exchange_rates Allow authenticated read access; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow authenticated read access" ON public.exchange_rates FOR SELECT USING ((is_active = true));


--
-- Name: order_lines Allow authenticated read access; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow authenticated read access" ON public.order_lines FOR SELECT TO authenticated USING (true);


--
-- Name: order_service_items Allow authenticated read access; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow authenticated read access" ON public.order_service_items FOR SELECT TO authenticated USING (true);


--
-- Name: orders Allow authenticated read access; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow authenticated read access" ON public.orders FOR SELECT TO authenticated USING (true);


--
-- Name: parties Allow authenticated read access; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow authenticated read access" ON public.parties FOR SELECT TO authenticated USING (true);


--
-- Name: product_variant_attributes Allow authenticated read access; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow authenticated read access" ON public.product_variant_attributes FOR SELECT TO authenticated USING (true);


--
-- Name: product_variants Allow authenticated read access; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow authenticated read access" ON public.product_variants FOR SELECT TO authenticated USING (true);


--
-- Name: products Allow authenticated read access; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow authenticated read access" ON public.products FOR SELECT TO authenticated USING (true);


--
-- Name: roles Allow authenticated read access; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow authenticated read access" ON public.roles FOR SELECT TO authenticated USING (true);


--
-- Name: work_session_outputs Allow authenticated read access; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow authenticated read access" ON public.work_session_outputs FOR SELECT TO authenticated USING (true);


--
-- Name: work_sessions Allow authenticated read access; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow authenticated read access" ON public.work_sessions FOR SELECT TO authenticated USING (true);


--
-- Name: service_reports Allow authenticated users to create reports; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow authenticated users to create reports" ON public.service_reports FOR INSERT TO authenticated WITH CHECK (true);


--
-- Name: parties Allow authenticated users to insert parties; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow authenticated users to insert parties" ON public.parties FOR INSERT WITH CHECK (true);


--
-- Name: parties Allow authenticated users to read parties; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow authenticated users to read parties" ON public.parties FOR SELECT USING (true);


--
-- Name: permissions Allow authenticated users to read permissions; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow authenticated users to read permissions" ON public.permissions FOR SELECT TO authenticated USING (true);


--
-- Name: profiles Allow authenticated users to read profiles; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow authenticated users to read profiles" ON public.profiles FOR SELECT TO authenticated USING (true);


--
-- Name: role_permissions Allow authenticated users to read role permissions; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow authenticated users to read role permissions" ON public.role_permissions FOR SELECT TO authenticated USING (true);


--
-- Name: parties Allow authenticated users to update parties; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow authenticated users to update parties" ON public.parties FOR UPDATE USING (true);


--
-- Name: service_reports Allow managers to resolve reports; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow managers to resolve reports" ON public.service_reports FOR UPDATE TO authenticated USING (public.has_permission('reports:resolve'::text)) WITH CHECK (public.has_permission('reports:resolve'::text));


--
-- Name: audit_logs Allow privileged users to read audit logs; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow privileged users to read audit logs" ON public.audit_logs FOR SELECT TO authenticated USING (public.has_permission('system:view_audit_logs'::text));


--
-- Name: currencies Allow public read access; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow public read access" ON public.currencies FOR SELECT TO anon USING ((is_active = true));


--
-- Name: level_exp Allow read access to all authenticated users; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow read access to all authenticated users" ON public.level_exp FOR SELECT TO authenticated USING (true);


--
-- Name: currencies Allow service role full access; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow service role full access" ON public.currencies USING (pg_has_role(SESSION_USER, 'service_role'::name, 'MEMBER'::text)) WITH CHECK (pg_has_role(SESSION_USER, 'service_role'::name, 'MEMBER'::text));


--
-- Name: exchange_rate_config Allow service role operations on exchange_rate_config; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow service role operations on exchange_rate_config" ON public.exchange_rate_config USING (pg_has_role(SESSION_USER, 'service_role'::name, 'MEMBER'::text)) WITH CHECK (pg_has_role(SESSION_USER, 'service_role'::name, 'MEMBER'::text));


--
-- Name: exchange_rates Allow service role operations on exchange_rates; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow service role operations on exchange_rates" ON public.exchange_rates USING (pg_has_role(SESSION_USER, 'service_role'::name, 'MEMBER'::text)) WITH CHECK (pg_has_role(SESSION_USER, 'service_role'::name, 'MEMBER'::text));


--
-- Name: parties Allow service_role to delete parties; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow service_role to delete parties" ON public.parties FOR DELETE USING ((current_setting('app.settings.current_user_email'::text, true) = 'service_role'::text));


--
-- Name: audit_logs Allow users to insert audit logs for their own records; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow users to insert audit logs for their own records" ON public.audit_logs FOR INSERT WITH CHECK ((actor = ( SELECT auth.uid() AS uid)));


--
-- Name: service_reports Allow users to read relevant reports; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow users to read relevant reports" ON public.service_reports FOR SELECT TO authenticated USING (((reported_by = ( SELECT auth.uid() AS uid)) OR public.has_permission('reports:view'::text)));


--
-- Name: user_role_assignments Allow users to read their own assignments; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow users to read their own assignments" ON public.user_role_assignments FOR SELECT USING ((user_id = auth.uid()));


--
-- Name: order_reviews Allow users with permission to add reviews; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow users with permission to add reviews" ON public.order_reviews FOR INSERT WITH CHECK ((created_by = ( SELECT auth.uid() AS uid)));


--
-- Name: order_reviews Allow users with permission to view reviews; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow users with permission to view reviews" ON public.order_reviews FOR SELECT USING (((EXISTS ( SELECT 1
   FROM (public.user_role_assignments ura
     JOIN public.roles r ON ((ura.role_id = r.id)))
  WHERE ((ura.user_id = public.get_current_profile_id()) AND ((r.code)::text = ANY (ARRAY['admin'::text]))))) OR (created_by = auth.uid())));


--
-- Name: POLICY "Allow users with permission to view reviews" ON order_reviews; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY "Allow users with permission to view reviews" ON public.order_reviews IS 'Allows admin users to view all reviews and users to view their own reviews';


--
-- Name: exchange_rate_api_log Authenticated users can read logs; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Authenticated users can read logs" ON public.exchange_rate_api_log FOR SELECT USING ((auth.role() = 'authenticated'::text));


--
-- Name: game_accounts Authenticated users can view game accounts; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Authenticated users can view game accounts" ON public.game_accounts FOR SELECT USING (((( SELECT auth.uid() AS uid) IS NOT NULL) AND (is_active = true)));


--
-- Name: service_reports Block all deletes; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Block all deletes" ON public.service_reports FOR DELETE TO authenticated USING (false);


--
-- Name: attribute_relationships Block deletes; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Block deletes" ON public.attribute_relationships FOR DELETE TO authenticated USING (false);


--
-- Name: attributes Block deletes; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Block deletes" ON public.attributes FOR DELETE TO authenticated USING (false);


--
-- Name: currencies Block deletes; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Block deletes" ON public.currencies FOR DELETE TO authenticated USING (false);


--
-- Name: customer_accounts Block deletes; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Block deletes" ON public.customer_accounts FOR DELETE TO authenticated USING (false);


--
-- Name: order_lines Block deletes; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Block deletes" ON public.order_lines FOR DELETE TO authenticated USING (false);


--
-- Name: order_service_items Block deletes; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Block deletes" ON public.order_service_items FOR DELETE TO authenticated USING (false);


--
-- Name: orders Block deletes; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Block deletes" ON public.orders FOR DELETE TO authenticated USING (false);


--
-- Name: product_variant_attributes Block deletes; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Block deletes" ON public.product_variant_attributes FOR DELETE TO authenticated USING (false);


--
-- Name: product_variants Block deletes; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Block deletes" ON public.product_variants FOR DELETE TO authenticated USING (false);


--
-- Name: products Block deletes; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Block deletes" ON public.products FOR DELETE TO authenticated USING (false);


--
-- Name: roles Block deletes; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Block deletes" ON public.roles FOR DELETE TO authenticated USING (false);


--
-- Name: work_session_outputs Block deletes; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Block deletes" ON public.work_session_outputs FOR DELETE TO authenticated USING (false);


--
-- Name: work_sessions Block deletes; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Block deletes" ON public.work_sessions FOR DELETE TO authenticated USING (false);


--
-- Name: attribute_relationships Block inserts; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Block inserts" ON public.attribute_relationships FOR INSERT TO authenticated WITH CHECK (false);


--
-- Name: attributes Block inserts; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Block inserts" ON public.attributes FOR INSERT TO authenticated WITH CHECK (false);


--
-- Name: currencies Block inserts; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Block inserts" ON public.currencies FOR INSERT TO authenticated WITH CHECK (false);


--
-- Name: customer_accounts Block inserts; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Block inserts" ON public.customer_accounts FOR INSERT TO authenticated WITH CHECK (false);


--
-- Name: order_lines Block inserts; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Block inserts" ON public.order_lines FOR INSERT TO authenticated WITH CHECK (false);


--
-- Name: order_service_items Block inserts; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Block inserts" ON public.order_service_items FOR INSERT TO authenticated WITH CHECK (false);


--
-- Name: orders Block inserts; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Block inserts" ON public.orders FOR INSERT TO authenticated WITH CHECK (false);


--
-- Name: product_variant_attributes Block inserts; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Block inserts" ON public.product_variant_attributes FOR INSERT TO authenticated WITH CHECK (false);


--
-- Name: product_variants Block inserts; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Block inserts" ON public.product_variants FOR INSERT TO authenticated WITH CHECK (false);


--
-- Name: products Block inserts; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Block inserts" ON public.products FOR INSERT TO authenticated WITH CHECK (false);


--
-- Name: roles Block inserts; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Block inserts" ON public.roles FOR INSERT TO authenticated WITH CHECK (false);


--
-- Name: work_session_outputs Block inserts; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Block inserts" ON public.work_session_outputs FOR INSERT TO authenticated WITH CHECK (false);


--
-- Name: work_sessions Block inserts; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Block inserts" ON public.work_sessions FOR INSERT TO authenticated WITH CHECK (false);


--
-- Name: attribute_relationships Block updates; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Block updates" ON public.attribute_relationships FOR UPDATE TO authenticated USING (false) WITH CHECK (false);


--
-- Name: attributes Block updates; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Block updates" ON public.attributes FOR UPDATE TO authenticated USING (false) WITH CHECK (false);


--
-- Name: currencies Block updates; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Block updates" ON public.currencies FOR UPDATE TO authenticated USING (false) WITH CHECK (false);


--
-- Name: customer_accounts Block updates; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Block updates" ON public.customer_accounts FOR UPDATE TO authenticated USING (false) WITH CHECK (false);


--
-- Name: order_lines Block updates; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Block updates" ON public.order_lines FOR UPDATE TO authenticated USING (false) WITH CHECK (false);


--
-- Name: order_service_items Block updates; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Block updates" ON public.order_service_items FOR UPDATE TO authenticated USING (false) WITH CHECK (false);


--
-- Name: orders Block updates; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Block updates" ON public.orders FOR UPDATE TO authenticated USING (false) WITH CHECK (false);


--
-- Name: product_variant_attributes Block updates; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Block updates" ON public.product_variant_attributes FOR UPDATE TO authenticated USING (false) WITH CHECK (false);


--
-- Name: product_variants Block updates; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Block updates" ON public.product_variants FOR UPDATE TO authenticated USING (false) WITH CHECK (false);


--
-- Name: products Block updates; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Block updates" ON public.products FOR UPDATE TO authenticated USING (false) WITH CHECK (false);


--
-- Name: roles Block updates; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Block updates" ON public.roles FOR UPDATE TO authenticated USING (false) WITH CHECK (false);


--
-- Name: work_session_outputs Block updates; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Block updates" ON public.work_session_outputs FOR UPDATE TO authenticated USING (false) WITH CHECK (false);


--
-- Name: work_sessions Block updates; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Block updates" ON public.work_sessions FOR UPDATE TO authenticated USING (false) WITH CHECK (false);


--
-- Name: currency_orders Comprehensive currency orders access policy; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Comprehensive currency orders access policy" ON public.currency_orders FOR SELECT TO authenticated USING (((EXISTS ( SELECT 1
   FROM (public.user_role_assignments ura
     JOIN public.roles r ON ((ura.role_id = r.id)))
  WHERE ((ura.user_id = public.get_current_profile_id()) AND (r.code = ANY (ARRAY['admin'::public.app_role, 'mod'::public.app_role, 'manager'::public.app_role, 'leader'::public.app_role]))))) OR (created_by = public.get_current_profile_id()) OR (assigned_to = public.get_current_profile_id())));


--
-- Name: shift_assignments Enable all operations for authenticated users on account_shift_; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Enable all operations for authenticated users on account_shift_" ON public.shift_assignments USING ((( SELECT auth.uid() AS uid) IS NOT NULL));


--
-- Name: employee_channels Enable all operations for authenticated users on employee_chann; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Enable all operations for authenticated users on employee_chann" ON public.employee_channels USING ((( SELECT auth.uid() AS uid) IS NOT NULL));


--
-- Name: channels Enable delete for admin role only; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Enable delete for admin role only" ON public.channels FOR DELETE USING ((EXISTS ( SELECT 1
   FROM (public.user_role_assignments ura
     JOIN public.roles r ON ((ura.role_id = r.id)))
  WHERE ((ura.user_id = public.get_current_profile_id()) AND ((r.code)::text = ANY (ARRAY['admin'::text]))))));


--
-- Name: POLICY "Enable delete for admin role only" ON channels; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY "Enable delete for admin role only" ON public.channels IS 'Allows only users with admin role code to delete channels';


--
-- Name: channels Enable insert for admin and moderator roles; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Enable insert for admin and moderator roles" ON public.channels FOR INSERT WITH CHECK (((created_by = auth.uid()) AND (EXISTS ( SELECT 1
   FROM (public.user_role_assignments ura
     JOIN public.roles r ON ((ura.role_id = r.id)))
  WHERE ((ura.user_id = public.get_current_profile_id()) AND ((r.code)::text = ANY (ARRAY['admin'::text, 'mod'::text])))))));


--
-- Name: POLICY "Enable insert for admin and moderator roles" ON channels; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY "Enable insert for admin and moderator roles" ON public.channels IS 'Allows users with admin or mod role codes to create channels';


--
-- Name: exchange_rate_trigger Enable insert for service role; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Enable insert for service role" ON public.exchange_rate_trigger FOR INSERT WITH CHECK (((auth.jwt() ->> 'role'::text) = 'service_role'::text));


--
-- Name: channels Enable read access for all authenticated users; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Enable read access for all authenticated users" ON public.channels FOR SELECT USING ((( SELECT auth.uid() AS uid) IS NOT NULL));


--
-- Name: exchange_rate_trigger Enable read for authenticated users; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Enable read for authenticated users" ON public.exchange_rate_trigger FOR SELECT USING ((auth.role() = 'authenticated'::text));


--
-- Name: channels Enable update for admin and moderator roles; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Enable update for admin and moderator roles" ON public.channels FOR UPDATE USING ((EXISTS ( SELECT 1
   FROM (public.user_role_assignments ura
     JOIN public.roles r ON ((ura.role_id = r.id)))
  WHERE ((ura.user_id = public.get_current_profile_id()) AND ((r.code)::text = ANY (ARRAY['admin'::text, 'mod'::text]))))));


--
-- Name: POLICY "Enable update for admin and moderator roles" ON channels; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY "Enable update for admin and moderator roles" ON public.channels IS 'Allows users with admin or mod role codes to update channels';


--
-- Name: exchange_rate_trigger Enable update for service role; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Enable update for service role" ON public.exchange_rate_trigger FOR UPDATE USING (((auth.jwt() ->> 'role'::text) = 'service_role'::text));


--
-- Name: profiles Secure role-based profile update policy; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Secure role-based profile update policy" ON public.profiles FOR UPDATE USING (((auth_id = auth.uid()) OR (EXISTS ( SELECT 1
   FROM ((auth.users u
     JOIN public.user_role_assignments ura ON ((u.id = ( SELECT profiles_1.id
           FROM public.profiles profiles_1
          WHERE (profiles_1.auth_id = auth.uid())
         LIMIT 1))))
     JOIN public.roles r ON ((ura.role_id = r.id)))
  WHERE ((u.id = auth.uid()) AND ((r.code)::text = ANY (ARRAY['admin'::text, 'administrator'::text])))))));


--
-- Name: profile_status_logs Service role can delete status logs; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Service role can delete status logs" ON public.profile_status_logs FOR DELETE USING (true);


--
-- Name: exchange_rate_api_log Service role can insert logs; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Service role can insert logs" ON public.exchange_rate_api_log FOR INSERT WITH CHECK (((auth.jwt() ->> 'role'::text) = 'service_role'::text));


--
-- Name: profile_status_logs Service role can insert status logs; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Service role can insert status logs" ON public.profile_status_logs FOR INSERT WITH CHECK (true);


--
-- Name: inventory_pools Service role can manage inventory pools; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Service role can manage inventory pools" ON public.inventory_pools USING ((auth.role() = 'service_role'::text));


--
-- Name: profile_status_logs Service role can update status logs; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Service role can update status logs" ON public.profile_status_logs FOR UPDATE USING (true);


--
-- Name: work_shifts Users can delete work shifts; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can delete work shifts" ON public.work_shifts FOR DELETE USING (true);


--
-- Name: currency_orders Users can insert currency orders; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can insert currency orders" ON public.currency_orders FOR INSERT WITH CHECK ((created_by = public.get_current_profile_id()));


--
-- Name: currency_transactions Users can insert currency transactions; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can insert currency transactions" ON public.currency_transactions FOR INSERT TO authenticated WITH CHECK ((created_by IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = auth.uid()))));


--
-- Name: inventory_pools Users can insert inventory pools; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can insert inventory pools" ON public.inventory_pools FOR INSERT TO authenticated WITH CHECK (true);


--
-- Name: POLICY "Users can insert inventory pools" ON inventory_pools; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY "Users can insert inventory pools" ON public.inventory_pools IS 'Cho phép authenticated users tạo inventory pool records khi xác nhận nhận hàng';


--
-- Name: work_shifts Users can insert work shifts; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can insert work shifts" ON public.work_shifts FOR INSERT WITH CHECK (true);


--
-- Name: currency_orders Users can update currency orders; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can update currency orders" ON public.currency_orders FOR UPDATE TO authenticated USING (((created_by = public.get_current_profile_id()) OR (assigned_to = public.get_current_profile_id()) OR (EXISTS ( SELECT 1
   FROM (public.user_role_assignments ura
     JOIN public.roles r ON ((ura.role_id = r.id)))
  WHERE ((ura.user_id = public.get_current_profile_id()) AND (r.code = ANY (ARRAY['admin'::public.app_role, 'mod'::public.app_role, 'manager'::public.app_role, 'leader'::public.app_role])))))));


--
-- Name: currency_transactions Users can update currency transactions; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can update currency transactions" ON public.currency_transactions FOR UPDATE TO authenticated USING ((created_by IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = auth.uid())))) WITH CHECK ((created_by IN ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = auth.uid()))));


--
-- Name: inventory_pools Users can update inventory pools; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can update inventory pools" ON public.inventory_pools FOR UPDATE TO authenticated USING (true) WITH CHECK (true);


--
-- Name: POLICY "Users can update inventory pools" ON inventory_pools; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY "Users can update inventory pools" ON public.inventory_pools IS 'Cho phép authenticated users cập nhật inventory pool records khi xác nhận nhận hàng';


--
-- Name: profiles Users can update their own profile; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can update their own profile" ON public.profiles FOR UPDATE USING ((auth_id = ( SELECT auth.uid() AS uid)));


--
-- Name: work_shifts Users can update work shifts; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can update work shifts" ON public.work_shifts FOR UPDATE USING (true);


--
-- Name: attributes Users can view active attributes; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view active attributes" ON public.attributes FOR SELECT USING ((is_active = true));


--
-- Name: currency_transactions Users can view currency transactions; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view currency transactions" ON public.currency_transactions FOR SELECT TO authenticated USING ((created_by = public.get_user_profile_id()));


--
-- Name: inventory_pools Users can view inventory pools; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view inventory pools" ON public.inventory_pools FOR SELECT USING ((auth.role() = 'authenticated'::text));


--
-- Name: profile_status_logs Users can view their own status logs; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view their own status logs" ON public.profile_status_logs FOR SELECT USING (((profile_id = ( SELECT profiles.id
   FROM public.profiles
  WHERE (profiles.auth_id = auth.uid()))) OR (EXISTS ( SELECT 1
   FROM (public.user_role_assignments ura
     JOIN public.roles r ON ((ura.role_id = r.id)))
  WHERE ((ura.user_id = public.get_current_profile_id()) AND ((r.code)::text = ANY (ARRAY['admin'::text])))))));


--
-- Name: POLICY "Users can view their own status logs" ON profile_status_logs; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY "Users can view their own status logs" ON public.profile_status_logs IS 'Allows users to view their own status logs and admin users to view all status logs';


--
-- Name: work_shifts Users can view work shifts; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view work shifts" ON public.work_shifts FOR SELECT USING (true);


--
-- Name: assignment_trackers; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.assignment_trackers ENABLE ROW LEVEL SECURITY;

--
-- Name: assignment_trackers assignment_trackers_deny_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY assignment_trackers_deny_all ON public.assignment_trackers USING (false);


--
-- Name: attribute_relationships; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.attribute_relationships ENABLE ROW LEVEL SECURITY;

--
-- Name: attributes; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.attributes ENABLE ROW LEVEL SECURITY;

--
-- Name: audit_logs; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

--
-- Name: audit_logs audit_no_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY audit_no_delete ON public.audit_logs FOR DELETE USING (false);


--
-- Name: audit_logs audit_no_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY audit_no_update ON public.audit_logs FOR UPDATE WITH CHECK (false);


--
-- Name: work_sessions authenticated_delete_work_sessions; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY authenticated_delete_work_sessions ON public.work_sessions FOR DELETE TO authenticated USING (true);


--
-- Name: order_reviews authenticated_insert_order_reviews; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY authenticated_insert_order_reviews ON public.order_reviews FOR INSERT TO authenticated WITH CHECK (true);


--
-- Name: work_sessions authenticated_insert_work_sessions; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY authenticated_insert_work_sessions ON public.work_sessions FOR INSERT TO authenticated WITH CHECK (true);


--
-- Name: attribute_relationships authenticated_read_attribute_relationships; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY authenticated_read_attribute_relationships ON public.attribute_relationships FOR SELECT TO authenticated USING (true);


--
-- Name: attributes authenticated_read_attributes; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY authenticated_read_attributes ON public.attributes FOR SELECT TO authenticated USING (true);


--
-- Name: order_lines authenticated_read_order_lines; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY authenticated_read_order_lines ON public.order_lines FOR SELECT TO authenticated USING (true);


--
-- Name: order_reviews authenticated_read_order_reviews; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY authenticated_read_order_reviews ON public.order_reviews FOR SELECT TO authenticated USING (true);


--
-- Name: order_service_items authenticated_read_order_service_items; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY authenticated_read_order_service_items ON public.order_service_items FOR SELECT TO authenticated USING (true);


--
-- Name: orders authenticated_read_orders; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY authenticated_read_orders ON public.orders FOR SELECT TO authenticated USING (true);


--
-- Name: product_variants authenticated_read_product_variants; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY authenticated_read_product_variants ON public.product_variants FOR SELECT TO authenticated USING (true);


--
-- Name: profiles authenticated_read_profiles; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY authenticated_read_profiles ON public.profiles FOR SELECT TO authenticated USING (true);


--
-- Name: work_sessions authenticated_read_work_sessions; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY authenticated_read_work_sessions ON public.work_sessions FOR SELECT TO authenticated USING (true);


--
-- Name: order_lines authenticated_update_order_lines; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY authenticated_update_order_lines ON public.order_lines FOR UPDATE TO authenticated USING (true);


--
-- Name: order_service_items authenticated_update_order_service_items; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY authenticated_update_order_service_items ON public.order_service_items FOR UPDATE TO authenticated USING (true);


--
-- Name: orders authenticated_update_orders; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY authenticated_update_orders ON public.orders FOR UPDATE TO authenticated USING (true);


--
-- Name: work_sessions authenticated_update_work_sessions; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY authenticated_update_work_sessions ON public.work_sessions FOR UPDATE TO authenticated USING (true);


--
-- Name: business_processes; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.business_processes ENABLE ROW LEVEL SECURITY;

--
-- Name: business_processes business_processes_all_service_role; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY business_processes_all_service_role ON public.business_processes USING ((auth.role() = 'service_role'::text));


--
-- Name: business_processes business_processes_select_authenticated; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY business_processes_select_authenticated ON public.business_processes FOR SELECT USING ((auth.role() = 'authenticated'::text));


--
-- Name: channels; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.channels ENABLE ROW LEVEL SECURITY;

--
-- Name: currencies; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.currencies ENABLE ROW LEVEL SECURITY;

--
-- Name: currency_orders; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.currency_orders ENABLE ROW LEVEL SECURITY;

--
-- Name: currency_transactions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.currency_transactions ENABLE ROW LEVEL SECURITY;

--
-- Name: customer_accounts; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.customer_accounts ENABLE ROW LEVEL SECURITY;

--
-- Name: debug_log; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.debug_log ENABLE ROW LEVEL SECURITY;

--
-- Name: employee_channels; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.employee_channels ENABLE ROW LEVEL SECURITY;

--
-- Name: exchange_rate_api_log; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.exchange_rate_api_log ENABLE ROW LEVEL SECURITY;

--
-- Name: exchange_rate_config; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.exchange_rate_config ENABLE ROW LEVEL SECURITY;

--
-- Name: exchange_rate_trigger; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.exchange_rate_trigger ENABLE ROW LEVEL SECURITY;

--
-- Name: exchange_rates; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.exchange_rates ENABLE ROW LEVEL SECURITY;

--
-- Name: fees; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.fees ENABLE ROW LEVEL SECURITY;

--
-- Name: fees fees_all_service_role; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY fees_all_service_role ON public.fees USING ((auth.role() = 'service_role'::text));


--
-- Name: fees fees_select_authenticated; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY fees_select_authenticated ON public.fees FOR SELECT USING ((auth.role() = 'authenticated'::text));


--
-- Name: game_accounts; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.game_accounts ENABLE ROW LEVEL SECURITY;

--
-- Name: inventory_pools; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.inventory_pools ENABLE ROW LEVEL SECURITY;

--
-- Name: level_exp; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.level_exp ENABLE ROW LEVEL SECURITY;

--
-- Name: order_lines; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.order_lines ENABLE ROW LEVEL SECURITY;

--
-- Name: order_reviews; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.order_reviews ENABLE ROW LEVEL SECURITY;

--
-- Name: order_service_items; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.order_service_items ENABLE ROW LEVEL SECURITY;

--
-- Name: orders; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;

--
-- Name: parties; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.parties ENABLE ROW LEVEL SECURITY;

--
-- Name: permissions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.permissions ENABLE ROW LEVEL SECURITY;

--
-- Name: process_fees_map; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.process_fees_map ENABLE ROW LEVEL SECURITY;

--
-- Name: process_fees_map process_fees_map_deny_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY process_fees_map_deny_all ON public.process_fees_map USING (false);


--
-- Name: product_variant_attributes; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.product_variant_attributes ENABLE ROW LEVEL SECURITY;

--
-- Name: product_variants; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.product_variants ENABLE ROW LEVEL SECURITY;

--
-- Name: products; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;

--
-- Name: profile_status_logs; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.profile_status_logs ENABLE ROW LEVEL SECURITY;

--
-- Name: profiles; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

--
-- Name: order_lines realtime_order_lines_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY realtime_order_lines_read ON public.order_lines FOR SELECT TO supabase_realtime_admin USING (true);


--
-- Name: order_reviews realtime_order_reviews_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY realtime_order_reviews_read ON public.order_reviews FOR SELECT TO supabase_realtime_admin USING (true);


--
-- Name: order_service_items realtime_order_service_items_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY realtime_order_service_items_read ON public.order_service_items FOR SELECT TO supabase_realtime_admin USING (true);


--
-- Name: orders realtime_orders_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY realtime_orders_read ON public.orders FOR SELECT TO supabase_realtime_admin USING (true);


--
-- Name: profiles realtime_profiles_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY realtime_profiles_read ON public.profiles FOR SELECT TO supabase_realtime_admin USING (true);


--
-- Name: work_sessions realtime_work_sessions_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY realtime_work_sessions_read ON public.work_sessions FOR SELECT TO supabase_realtime_admin USING (true);


--
-- Name: role_permissions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.role_permissions ENABLE ROW LEVEL SECURITY;

--
-- Name: roles; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.roles ENABLE ROW LEVEL SECURITY;

--
-- Name: service_reports; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.service_reports ENABLE ROW LEVEL SECURITY;

--
-- Name: shift_assignments; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.shift_assignments ENABLE ROW LEVEL SECURITY;

--
-- Name: user_role_assignments; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.user_role_assignments ENABLE ROW LEVEL SECURITY;

--
-- Name: work_session_outputs; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.work_session_outputs ENABLE ROW LEVEL SECURITY;

--
-- Name: work_sessions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.work_sessions ENABLE ROW LEVEL SECURITY;

--
-- Name: work_shifts; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.work_shifts ENABLE ROW LEVEL SECURITY;

--
-- Name: messages; Type: ROW SECURITY; Schema: realtime; Owner: -
--

ALTER TABLE realtime.messages ENABLE ROW LEVEL SECURITY;

--
-- Name: objects Allow authenticated users to update work-proofs; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "Allow authenticated users to update work-proofs" ON storage.objects FOR UPDATE USING (((bucket_id = 'work-proofs'::text) AND (auth.role() = 'authenticated'::text))) WITH CHECK (((bucket_id = 'work-proofs'::text) AND (auth.role() = 'authenticated'::text)));


--
-- Name: objects Allow authenticated users to upload work-proofs; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "Allow authenticated users to upload work-proofs" ON storage.objects FOR INSERT WITH CHECK (((bucket_id = 'work-proofs'::text) AND (auth.role() = 'authenticated'::text)));


--
-- Name: objects Allow authenticated users to view work-proofs; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "Allow authenticated users to view work-proofs" ON storage.objects FOR SELECT USING (((bucket_id = 'work-proofs'::text) AND (auth.role() = 'authenticated'::text)));


--
-- Name: objects Service role full access to work-proofs; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "Service role full access to work-proofs" ON storage.objects USING ((auth.role() = 'service_role'::text)) WITH CHECK ((auth.role() = 'service_role'::text));


--
-- Name: buckets; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.buckets ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets_analytics; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.buckets_analytics ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets_vectors; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.buckets_vectors ENABLE ROW LEVEL SECURITY;

--
-- Name: migrations; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: objects; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

--
-- Name: prefixes; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.prefixes ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.s3_multipart_uploads ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads_parts; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.s3_multipart_uploads_parts ENABLE ROW LEVEL SECURITY;

--
-- Name: vector_indexes; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.vector_indexes ENABLE ROW LEVEL SECURITY;

--
-- Name: supabase_realtime; Type: PUBLICATION; Schema: -; Owner: -
--

CREATE PUBLICATION supabase_realtime WITH (publish = 'insert, update, delete, truncate');


--
-- Name: supabase_realtime_messages_publication; Type: PUBLICATION; Schema: -; Owner: -
--

CREATE PUBLICATION supabase_realtime_messages_publication WITH (publish = 'insert, update, delete, truncate');


--
-- Name: supabase_realtime currency_orders; Type: PUBLICATION TABLE; Schema: public; Owner: -
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.currency_orders;


--
-- Name: supabase_realtime inventory_pools; Type: PUBLICATION TABLE; Schema: public; Owner: -
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.inventory_pools;


--
-- Name: supabase_realtime order_lines; Type: PUBLICATION TABLE; Schema: public; Owner: -
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.order_lines;


--
-- Name: supabase_realtime order_service_items; Type: PUBLICATION TABLE; Schema: public; Owner: -
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.order_service_items;


--
-- Name: supabase_realtime orders; Type: PUBLICATION TABLE; Schema: public; Owner: -
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.orders;


--
-- Name: supabase_realtime_messages_publication messages; Type: PUBLICATION TABLE; Schema: realtime; Owner: -
--

ALTER PUBLICATION supabase_realtime_messages_publication ADD TABLE ONLY realtime.messages;


--
-- Name: issue_graphql_placeholder; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_graphql_placeholder ON sql_drop
         WHEN TAG IN ('DROP EXTENSION')
   EXECUTE FUNCTION extensions.set_graphql_placeholder();


--
-- Name: issue_pg_cron_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_pg_cron_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_cron_access();


--
-- Name: issue_pg_graphql_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_pg_graphql_access ON ddl_command_end
         WHEN TAG IN ('CREATE FUNCTION')
   EXECUTE FUNCTION extensions.grant_pg_graphql_access();


--
-- Name: issue_pg_net_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_pg_net_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_net_access();


--
-- Name: pgrst_ddl_watch; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER pgrst_ddl_watch ON ddl_command_end
   EXECUTE FUNCTION extensions.pgrst_ddl_watch();


--
-- Name: pgrst_drop_watch; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER pgrst_drop_watch ON sql_drop
   EXECUTE FUNCTION extensions.pgrst_drop_watch();


--
-- PostgreSQL database dump complete
--

\unrestrict 7y4Gvm6PkQpDzZ76biGV1IgDozDHyWjuiRUzS2GFwfNQ2Yb6MSTolWXIoDWm0ku

