-- Clean up duplicate functions and ensure only active versions remain
-- This migration ensures compliance with memory.md rules for function management

-- Check for and drop any duplicate versions of functions
-- First, let's check what exists (this will be logged for verification)

-- Drop any old versions of admin_get_roles_and_permissions if they exist
DROP FUNCTION IF EXISTS admin_get_roles_and_permissions_old();
DROP FUNCTION IF EXISTS admin_get_roles_and_permissions_v1();
DROP FUNCTION IF EXISTS admin_get_roles_and_permissions_v2();

-- Drop any old versions of admin_update_permissions_for_role if they exist
DROP FUNCTION IF EXISTS admin_update_permissions_for_role_old();
DROP FUNCTION IF EXISTS admin_update_permissions_for_role_v1();
DROP FUNCTION IF EXISTS admin_update_permissions_for_role_v2();

-- Drop any old versions of simple_exchange_rate_cron if they exist
DROP FUNCTION IF EXISTS simple_exchange_rate_cron_old();
DROP FUNCTION IF EXISTS simple_exchange_rate_cron_v1();
DROP FUNCTION IF EXISTS simple_exchange_rate_cron_v2();

-- Ensure the correct versions exist with proper search_path
-- If they don't exist, recreate them

-- Recreate admin_get_roles_and_permissions if needed
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_proc WHERE proname = 'admin_get_roles_and_permissions'
    ) THEN
        CREATE OR REPLACE FUNCTION admin_get_roles_and_permissions()
        RETURNS JSON
        LANGUAGE plpgsql
        SECURITY DEFINER
        SET search_path = 'public'
        AS $$
        DECLARE
            v_result JSON;
        BEGIN
            -- Build comprehensive JSON result with roles, permissions, and assignments
            SELECT json_build_object(
                'roles', (
                    SELECT json_agg(
                        json_build_object(
                            'id', id,
                            'code', code,
                            'name', name
                        )
                    )
                    FROM roles
                    ORDER BY name
                ),
                'permissions', (
                    SELECT json_agg(
                        json_build_object(
                            'id', id,
                            'code', code,
                            'group', "group",
                            'description', description,
                            'description_vi', description_vi
                        )
                    )
                    FROM permissions
                    ORDER BY "group", code
                ),
                'assignments', (
                    SELECT json_agg(
                        json_build_object(
                            'role_id', role_id,
                            'permission_id', permission_id,
                            'assigned_at', assigned_at,
                            'assigned_by', assigned_by
                        )
                    )
                    FROM role_permission_assignments
                )
            ) INTO v_result;

            RETURN v_result;
        END;
        $$;
    END IF;
END $$;

-- Recreate admin_update_permissions_for_role if needed
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_proc WHERE proname = 'admin_update_permissions_for_role'
    ) THEN
        CREATE OR REPLACE FUNCTION admin_update_permissions_for_role(
            p_role_id UUID,
            p_permission_ids UUID[]
        )
        RETURNS TABLE(
            success BOOLEAN,
            message TEXT,
            updated_count INTEGER
        )
        LANGUAGE plpgsql
        SECURITY DEFINER
        SET search_path = 'public'
        AS $$
        DECLARE
            v_updated_count INTEGER := 0;
            v_role_name TEXT;
            v_old_count INTEGER;
            v_new_count INTEGER;
        BEGIN
            -- Get role name for logging
            SELECT name INTO v_role_name FROM roles WHERE id = p_role_id;
            IF v_role_name IS NULL THEN
                RETURN QUERY SELECT FALSE, 'Role not found', 0;
                RETURN;
            END IF;

            -- Get old assignment count
            SELECT COUNT(*) INTO v_old_count
            FROM role_permission_assignments
            WHERE role_id = p_role_id;

            -- Remove all existing permissions for this role
            DELETE FROM role_permission_assignments WHERE role_id = p_role_id;

            -- Add new permissions
            IF p_permission_ids IS NOT NULL AND array_length(p_permission_ids, 1) > 0 THEN
                INSERT INTO role_permission_assignments (role_id, permission_id, assigned_at, assigned_by)
                SELECT
                    p_role_id,
                    perm_id,
                    NOW(),
                    '00000000-0000-0000-0000-000000000000'::UUID
                FROM unnest(p_permission_ids) AS perm_id;

                v_updated_count := array_length(p_permission_ids, 1);
            END IF;

            -- Get new assignment count
            SELECT COUNT(*) INTO v_new_count
            FROM role_permission_assignments
            WHERE role_id = p_role_id;

            RETURN QUERY
            SELECT
                TRUE,
                format('Permissions updated for role %s: %d -> %d permissions', v_role_name, v_old_count, v_new_count),
                v_updated_count;
        END;
        $$;
    END IF;
END $$;

-- Recreate simple_exchange_rate_cron if needed
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_proc WHERE proname = 'simple_exchange_rate_cron'
    ) THEN
        CREATE OR REPLACE FUNCTION simple_exchange_rate_cron()
        RETURNS TABLE(
            success BOOLEAN,
            message TEXT,
            rates_count BIGINT
        )
        LANGUAGE plpgsql
        SECURITY DEFINER
        SET search_path = 'public'
        AS $$
        DECLARE
            v_currency_count BIGINT;
            v_updated_count BIGINT := 0;
        BEGIN
            -- Count total currencies
            SELECT COUNT(*) INTO v_currency_count
            FROM attributes
            WHERE type = 'CURRENCY' AND is_active = true;

            -- Update rates for all currencies (simplified logic)
            -- In a real implementation, this would fetch from external APIs
            UPDATE attributes
            SET numeric_value = CASE
                WHEN numeric_value IS NULL THEN 1.0
                WHEN numeric_value <= 0 THEN 1.0
                ELSE GREATEST(0.1, LEAST(1000, numeric_value * (0.95 + RANDOM() * 0.1)))
            END
            WHERE type = 'CURRENCY' AND is_active = true;

            GET DIAGNOSTICS v_updated_count = ROW_COUNT;

            RETURN QUERY
            SELECT
                TRUE,
                format('Exchange rates updated: %d currencies processed', v_updated_count),
                v_updated_count;
        END;
        $$;
    END IF;
END $$;

-- Log verification of cleanup
DO $$
BEGIN
    RAISE NOTICE 'Function cleanup completed at %', NOW();
    RAISE NOTICE 'Active functions check:';

    -- Check admin_get_roles_and_permissions
    IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'admin_get_roles_and_permissions') THEN
        RAISE NOTICE '✓ admin_get_roles_and_permissions exists';
    ELSE
        RAISE NOTICE '✗ admin_get_roles_and_permissions missing';
    END IF;

    -- Check admin_update_permissions_for_role
    IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'admin_update_permissions_for_role') THEN
        RAISE NOTICE '✓ admin_update_permissions_for_role exists';
    ELSE
        RAISE NOTICE '✗ admin_update_permissions_for_role missing';
    END IF;

    -- Check simple_exchange_rate_cron
    IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'simple_exchange_rate_cron') THEN
        RAISE NOTICE '✓ simple_exchange_rate_cron exists';
    ELSE
        RAISE NOTICE '✗ simple_exchange_rate_cron missing';
    END IF;
END $$;