-- Comprehensive Channel-Based Inventory System
-- This migration implements channel-based inventory management with automatic creation/updating
-- Combines: auto_create_inventory_records updates, currency is_active triggers, and management functions

-- ================================================================
-- PART 1: Update auto_create_inventory_records function for channel support
-- ================================================================

-- Drop existing trigger and function
DROP TRIGGER IF EXISTS trigger_auto_create_inventory_records ON public.game_accounts;
DROP FUNCTION IF EXISTS public.auto_create_inventory_records();

-- Create updated function with channel support
CREATE OR REPLACE FUNCTION public.auto_create_inventory_records()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
    v_currency_record RECORD;
    v_channel_record RECORD;
    v_inventory_exists BOOLEAN;
    v_currency_code TEXT;
BEGIN
    -- For INVENTORY type accounts, create empty inventory records for all currencies per channel
    IF NEW.purpose = 'INVENTORY' THEN
        -- Get all active currencies for this game
        FOR v_currency_record IN
            SELECT id, code, name
            FROM public.attributes
            WHERE type = NEW.game_code || '_CURRENCY'
              AND is_active = true
            ORDER BY sort_order ASC NULLS LAST
        LOOP
            -- Get all channels that can purchase (BUY or BOTH direction)
            FOR v_channel_record IN
                SELECT id, code, name, direction
                FROM public.channels
                WHERE is_active = true
                  AND (direction = 'BUY' OR direction = 'BOTH')
                ORDER BY code ASC
            LOOP
                -- Check if inventory record already exists for this game_account, currency, and channel
                SELECT EXISTS(
                    SELECT 1 FROM public.currency_inventory
                    WHERE game_account_id = NEW.id
                      AND currency_attribute_id = v_currency_record.id
                      AND channel_id = v_channel_record.id
                ) INTO v_inventory_exists;

                -- Create inventory record if it doesn't exist
                IF NOT v_inventory_exists THEN
                    -- Determine currency code based on channel
                    -- For channels dealing with USD, set USD currency code
                    v_currency_code := CASE
                        WHEN v_channel_record.code LIKE '%USD%' OR v_channel_record.name LIKE '%USD%' THEN 'USD'
                        ELSE 'VND'
                    END;

                    INSERT INTO public.currency_inventory (
                        game_account_id,
                        currency_attribute_id,
                        game_code,
                        league_attribute_id,
                        quantity,
                        reserved_quantity,
                        avg_buy_price,
                        last_updated_at,
                        channel_id,
                        last_updated_by,
                        currency_code
                    ) VALUES (
                        NEW.id,                           -- game_account_id
                        v_currency_record.id,             -- currency_attribute_id
                        NEW.game_code,                    -- game_code
                        NULL,                             -- league_attribute_id (will be set later)
                        0,                                -- quantity
                        0,                                -- reserved_quantity
                        0,                                -- avg_buy_price
                        NOW(),                            -- last_updated_at
                        v_channel_record.id,              -- channel_id
                        NEW.manager_profile_id,           -- last_updated_by (using manager_profile_id)
                        v_currency_code                   -- currency_code based on channel
                    );

                    -- Log the creation for debugging
                    RAISE LOG 'Created inventory record: account=%, currency=%, channel=%',
                        NEW.id, v_currency_record.code, v_channel_record.code;
                END IF;
            END LOOP;
        END LOOP;
    END IF;

    RETURN NEW;
END;
$$;

-- Recreate the trigger
CREATE TRIGGER trigger_auto_create_inventory_records
AFTER INSERT ON public.game_accounts
FOR EACH ROW
EXECUTE FUNCTION public.auto_create_inventory_records();

-- ================================================================
-- PART 2: Handle currency is_active field changes
-- ================================================================

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS trigger_handle_currency_is_active_changes ON public.attributes;

-- Create function to handle currency is_active changes
CREATE OR REPLACE FUNCTION public.handle_currency_is_active_changes()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
    v_currency_record RECORD;
    v_game_account RECORD;
    v_channel_record RECORD;
    v_inventory_exists BOOLEAN;
    v_total_inventory NUMERIC;
    v_currency_code TEXT;
    v_game_code TEXT;
BEGIN
    -- Only process currency type attributes
    IF NEW.type LIKE '%_CURRENCY' THEN
        -- Extract game code from type (e.g., 'CURRENCY_POE2' -> 'POE2')
        v_game_code := REPLACE(NEW.type, 'CURRENCY_', '');

        -- Handle currency activation (false -> true)
        IF OLD.is_active = false AND NEW.is_active = true THEN
            RAISE LOG 'Currency % activated. Creating inventory records for all INVENTORY accounts.', NEW.code;

            -- Get all INVENTORY game accounts for this game
            FOR v_game_account IN
                SELECT id, manager_profile_id
                FROM public.game_accounts
                WHERE purpose = 'INVENTORY'
                  AND game_code = v_game_code
                  AND is_active = true
            LOOP
                -- Get all BUY/BOTH channels
                FOR v_channel_record IN
                    SELECT id, code, name, direction
                    FROM public.channels
                    WHERE is_active = true
                      AND (direction = 'BUY' OR direction = 'BOTH')
                    ORDER BY code ASC
                LOOP
                    -- Check if inventory record already exists
                    SELECT EXISTS(
                        SELECT 1 FROM public.currency_inventory
                        WHERE game_account_id = v_game_account.id
                          AND currency_attribute_id = NEW.id
                          AND channel_id = v_channel_record.id
                    ) INTO v_inventory_exists;

                    -- Create inventory record if it doesn't exist
                    IF NOT v_inventory_exists THEN
                        -- Determine currency code based on channel
                        v_currency_code := CASE
                            WHEN v_channel_record.code LIKE '%USD%' OR v_channel_record.name LIKE '%USD%' THEN 'USD'
                            ELSE 'VND'
                        END;

                        INSERT INTO public.currency_inventory (
                            game_account_id,
                            currency_attribute_id,
                            game_code,
                            league_attribute_id,
                            quantity,
                            reserved_quantity,
                            avg_buy_price,
                            last_updated_at,
                            channel_id,
                            last_updated_by,
                            currency_code
                        ) VALUES (
                            v_game_account.id,
                            NEW.id,
                            v_game_code,
                            NULL, -- league_attribute_id
                            0,
                            0,
                            0,
                            NOW(),
                            v_channel_record.id,
                            v_game_account.manager_profile_id,
                            v_currency_code
                        );

                        RAISE LOG 'Created inventory for activated currency: account=%, currency=%, channel=%',
                            v_game_account.id, NEW.code, v_channel_record.code;
                    END IF;
                END LOOP;
            END LOOP;

        -- Handle currency deactivation (true -> false)
        ELSIF OLD.is_active = true AND NEW.is_active = false THEN
            RAISE LOG 'Currency % deactivation requested. Checking inventory levels.', NEW.code;

            -- Check total inventory across all accounts and channels
            SELECT COALESCE(SUM(quantity), 0) INTO v_total_inventory
            FROM public.currency_inventory
            WHERE currency_attribute_id = NEW.id;

            -- Block deactivation if there is any inventory
            IF v_total_inventory > 0 THEN
                RAISE EXCEPTION 'Cannot deactivate currency %: Total inventory is %. Currency must have zero inventory across all accounts and channels to be deactivated.',
                    NEW.code, v_total_inventory;
            ELSE
                RAISE LOG 'Currency % has zero inventory. Proceeding with deactivation and cleanup.', NEW.code;

                -- Delete all inventory records for this currency
                DELETE FROM public.currency_inventory
                WHERE currency_attribute_id = NEW.id;

                RAISE LOG 'Deleted inventory records for deactivated currency %.', NEW.code;
            END IF;
        END IF;
    END IF;

    RETURN NEW;
EXCEPTION
    WHEN OTHERS THEN
        -- Log error and re-raise with more context
        RAISE WARNING 'Error in handle_currency_is_active_changes for currency %: %', NEW.code, SQLERRM;
        RAISE;
END;
$$;

-- Create the trigger
CREATE TRIGGER trigger_handle_currency_is_active_changes
AFTER UPDATE OF is_active ON public.attributes
FOR EACH ROW
WHEN (OLD.is_active IS DISTINCT FROM NEW.is_active) -- Only fire when is_active actually changes
EXECUTE FUNCTION public.handle_currency_is_active_changes();

-- ================================================================
-- PART 3: Currency Management Helper Functions
-- ================================================================

-- Function to activate currency and create inventory records
CREATE OR REPLACE FUNCTION public.activate_currency(
    p_currency_id UUID,
    p_perform_check BOOLEAN DEFAULT true
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    inventory_records_created INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
    v_currency RECORD;
    v_accounts_count INTEGER;
    v_channels_count INTEGER;
    v_records_created INTEGER := 0;
BEGIN
    -- Get currency info
    SELECT * INTO v_currency
    FROM attributes
    WHERE id = p_currency_id AND type LIKE '%_CURRENCY';

    IF v_currency IS NULL THEN
        RETURN QUERY SELECT false, 'Currency not found or not a currency type', 0;
        RETURN;
    END IF;

    IF v_currency.is_active = true THEN
        RETURN QUERY SELECT false, 'Currency is already active', 0;
        RETURN;
    END IF;

    -- Optional pre-check
    IF p_perform_check THEN
        -- Count potential records to be created
        SELECT COUNT(*) INTO v_accounts_count
        FROM game_accounts
        WHERE purpose = 'INVENTORY'
          AND game_code = REPLACE(v_currency.type, 'CURRENCY_', '')
          AND is_active = true;

        SELECT COUNT(*) INTO v_channels_count
        FROM channels
        WHERE is_active = true
          AND (direction = 'BUY' OR direction = 'BOTH');

        RETURN QUERY SELECT true,
            format('Will create %s inventory records (%s accounts × %s channels)',
                v_accounts_count * v_channels_count, v_accounts_count, v_channels_count),
            v_accounts_count * v_channels_count;
        RETURN;
    END IF;

    -- Perform activation
    UPDATE attributes
    SET is_active = true
    WHERE id = p_currency_id;

    -- Count created records (trigger creates them)
    SELECT COUNT(*) INTO v_records_created
    FROM currency_inventory
    WHERE currency_attribute_id = p_currency_id;

    RETURN QUERY SELECT true,
        format('Currency %s activated successfully. Created %s inventory records.',
            v_currency.code, v_records_created),
        v_records_created;
END;
$$;

-- Function to safely deactivate currency
CREATE OR REPLACE FUNCTION public.safe_deactivate_currency(
    p_currency_id UUID,
    p_force_deactivate BOOLEAN DEFAULT false
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    total_inventory NUMERIC
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
    v_currency RECORD;
    v_total_inventory NUMERIC := 0;
    v_accounts_with_inventory INTEGER;
BEGIN
    -- Get currency info
    SELECT * INTO v_currency
    FROM attributes
    WHERE id = p_currency_id AND type LIKE '%_CURRENCY';

    IF v_currency IS NULL THEN
        RETURN QUERY SELECT false, 'Currency not found or not a currency type', 0;
        RETURN;
    END IF;

    IF v_currency.is_active = false THEN
        RETURN QUERY SELECT false, 'Currency is already inactive', 0;
        RETURN;
    END IF;

    -- Check total inventory
    SELECT COALESCE(SUM(quantity), 0) INTO v_total_inventory
    FROM currency_inventory
    WHERE currency_attribute_id = p_currency_id;

    SELECT COUNT(DISTINCT game_account_id) INTO v_accounts_with_inventory
    FROM currency_inventory
    WHERE currency_attribute_id = p_currency_id
      AND quantity > 0;

    IF v_total_inventory > 0 AND NOT p_force_deactivate THEN
        RETURN QUERY SELECT false,
            format('Cannot deactivate: Currency has %s total inventory across %s accounts. Use force_deactivate=true to override.',
                v_total_inventory, v_accounts_with_inventory),
            v_total_inventory;
        RETURN;
    END IF;

    -- Perform deactivation
    UPDATE attributes
    SET is_active = false
    WHERE id = p_currency_id;

    RETURN QUERY SELECT true,
        format('Currency %s deactivated successfully. Cleaned up inventory records.',
            v_currency.code),
        v_total_inventory;
END;
$$;

-- Function to get currency inventory summary
CREATE OR REPLACE FUNCTION public.get_currency_inventory_summary(p_game_code TEXT DEFAULT NULL)
RETURNS TABLE(
    currency_code TEXT,
    currency_name TEXT,
    is_active BOOLEAN,
    total_quantity NUMERIC,
    total_reserved NUMERIC,
    available_quantity NUMERIC,
    inventory_records INTEGER,
    channels_with_inventory TEXT[],
    accounts_with_inventory INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.code,
        a.name,
        a.is_active,
        COALESCE(SUM(ci.quantity), 0) as total_quantity,
        COALESCE(SUM(ci.reserved_quantity), 0) as total_reserved,
        COALESCE(SUM(ci.quantity - ci.reserved_quantity), 0) as available_quantity,
        COUNT(ci.id) as inventory_records,
        ARRAY_AGG(DISTINCT ch.code ORDER BY ch.code) FILTER (WHERE ci.quantity > 0) as channels_with_inventory,
        COUNT(DISTINCT ci.game_account_id) FILTER (WHERE ci.quantity > 0) as accounts_with_inventory
    FROM attributes a
    LEFT JOIN currency_inventory ci ON a.id = ci.currency_attribute_id
    LEFT JOIN channels ch ON ci.channel_id = ch.id
    WHERE (p_game_code IS NULL OR REPLACE(a.type, 'CURRENCY_', '') = p_game_code)
      AND a.type LIKE '%_CURRENCY'
    GROUP BY a.id, a.code, a.name, a.is_active
    ORDER BY a.sort_order;
END;
$$;

-- Function to identify orphaned inventory records
CREATE OR REPLACE FUNCTION public.find_orphaned_inventory_records()
RETURNS TABLE(
    inventory_id UUID,
    account_name TEXT,
    currency_code TEXT,
    currency_is_active BOOLEAN,
    channel_code TEXT,
    channel_is_active BOOLEAN,
    channel_direction TEXT,
    quantity NUMERIC,
    issue_type TEXT[]
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
BEGIN
    RETURN QUERY
    SELECT
        ci.id,
        ga.account_name,
        a.code,
        a.is_active,
        ch.code,
        ch.is_active,
        ch.direction,
        ci.quantity,
        ARRAY_REMOVE(ARRAY_AGG(
            CASE
                WHEN NOT a.is_active THEN 'Currency is inactive'
                WHEN NOT ch.is_active THEN 'Channel is inactive'
                WHEN ch.direction NOT IN ('BUY', 'BOTH') THEN 'Channel cannot purchase'
                ELSE NULL
            END
        ), NULL) as issue_type
    FROM currency_inventory ci
    JOIN game_accounts ga ON ci.game_account_id = ga.id
    JOIN attributes a ON ci.currency_attribute_id = a.id
    JOIN channels ch ON ci.channel_id = ch.id
    WHERE NOT a.is_active
       OR NOT ch.is_active
       OR ch.direction NOT IN ('BUY', 'BOTH')
    GROUP BY ci.id, ga.account_name, a.code, a.is_active, ch.code, ch.is_active, ch.direction, ci.quantity
    ORDER BY ga.account_name, a.code;
END;
$$;

-- ================================================================
-- PART 4: Documentation and Permissions
-- ================================================================

-- Add comments for documentation
COMMENT ON FUNCTION public.auto_create_inventory_records() IS 'Tự động tạo record tồn kho cho tài khoản inventory mới theo từng kênh mua hàng (BUY/BOTH channels) và currency đang hoạt động';
COMMENT ON FUNCTION public.handle_currency_is_active_changes() IS 'Xử lý thay đổi is_active của currency: tự động tạo inventory khi kích hoạt, kiểm tra và xóa inventory khi vô hiệu hóa';
COMMENT ON FUNCTION public.activate_currency(UUID, BOOLEAN) IS 'Kích hoạt currency và tạo inventory records cho tất cả INVENTORY accounts';
COMMENT ON FUNCTION public.safe_deactivate_currency(UUID, BOOLEAN) IS 'Vô hiệu hóa currency an toàn, kiểm tra inventory levels trước khi xóa';
COMMENT ON FUNCTION public.get_currency_inventory_summary(TEXT) IS 'Lấy tổng quan inventory theo currency, bao gồm quantities và channels sử dụng';
COMMENT ON FUNCTION public.find_orphaned_inventory_records() IS 'Tìm các inventory records không hợp lệ (currency/channel không hoạt động)';

-- Grant necessary permissions for all functions
GRANT ALL ON FUNCTION public.auto_create_inventory_records() TO anon;
GRANT ALL ON FUNCTION public.auto_create_inventory_records() TO authenticated;
GRANT ALL ON FUNCTION public.auto_create_inventory_records() TO service_role;

GRANT ALL ON FUNCTION public.handle_currency_is_active_changes() TO anon;
GRANT ALL ON FUNCTION public.handle_currency_is_active_changes() TO authenticated;
GRANT ALL ON FUNCTION public.handle_currency_is_active_changes() TO service_role;

GRANT ALL ON FUNCTION public.activate_currency(UUID, BOOLEAN) TO anon;
GRANT ALL ON FUNCTION public.activate_currency(UUID, BOOLEAN) TO authenticated;
GRANT ALL ON FUNCTION public.activate_currency(UUID, BOOLEAN) TO service_role;

GRANT ALL ON FUNCTION public.safe_deactivate_currency(UUID, BOOLEAN) TO anon;
GRANT ALL ON FUNCTION public.safe_deactivate_currency(UUID, BOOLEAN) TO authenticated;
GRANT ALL ON FUNCTION public.safe_deactivate_currency(UUID, BOOLEAN) TO service_role;

GRANT ALL ON FUNCTION public.get_currency_inventory_summary(TEXT) TO anon;
GRANT ALL ON FUNCTION public.get_currency_inventory_summary(TEXT) TO authenticated;
GRANT ALL ON FUNCTION public.get_currency_inventory_summary(TEXT) TO service_role;

GRANT ALL ON FUNCTION public.find_orphaned_inventory_records() TO anon;
GRANT ALL ON FUNCTION public.find_orphaned_inventory_records() TO authenticated;
GRANT ALL ON FUNCTION public.find_orphaned_inventory_records() TO service_role;