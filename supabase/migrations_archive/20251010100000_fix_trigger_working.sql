-- Fix trigger that is not working properly
-- This will recreate the trigger and function completely

-- First, drop existing trigger and function to ensure clean state
DROP TRIGGER IF EXISTS trigger_auto_create_inventory_records ON public.game_accounts;
DROP FUNCTION IF EXISTS public.auto_create_inventory_records() CASCADE;

-- Create the function with proper debugging and simplified logic
CREATE OR REPLACE FUNCTION public.auto_create_inventory_records()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $func$
DECLARE
    v_currency_record RECORD;
    v_currency_type TEXT;
    v_currency_count INTEGER := 0;
BEGIN
    -- Log that trigger is firing
    RAISE LOG 'auto_create_inventory_records trigger fired for account: %, game: %, purpose: %',
        NEW.account_name, NEW.game_code, NEW.purpose;

    -- Only process INVENTORY type accounts
    IF NEW.purpose = 'INVENTORY' THEN
        -- Determine currency type based on game code
        v_currency_type := CASE NEW.game_code
            WHEN 'POE_1' THEN 'CURRENCY_POE1'
            WHEN 'POE_2' THEN 'CURRENCY_POE2'
            WHEN 'DIABLO_4' THEN 'CURRENCY_D4'
            ELSE 'CURRENCY_' || UPPER(REPLACE(NEW.game_code, '_', ''))
        END;

        RAISE LOG 'Determined currency type: % for game: %', v_currency_type, NEW.game_code;

        -- Count available currencies first
        SELECT COUNT(*) INTO v_currency_count
        FROM public.attributes
        WHERE type = v_currency_type
          AND is_active = true;

        RAISE LOG 'Found % active currencies for type: %', v_currency_count, v_currency_type;

        -- Create inventory records for all currencies of this game
        FOR v_currency_record IN
            SELECT id, name, code
            FROM public.attributes
            WHERE type = v_currency_type
              AND is_active = true
            ORDER BY sort_order ASC, name ASC
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

            RAISE LOG 'Created inventory record for currency: % (%)',
                v_currency_record.name, v_currency_record.code;
        END LOOP;

        -- Log final count
        SELECT COUNT(*) INTO v_currency_count
        FROM public.currency_inventory
        WHERE game_account_id = NEW.id;

        RAISE LOG 'Final inventory record count for account %: %',
            NEW.account_name, v_currency_count;
    ELSE
        RAISE LOG 'Skipping inventory creation for non-INVENTORY account: % (purpose: %)',
            NEW.account_name, NEW.purpose;
    END IF;

    RETURN NEW;
EXCEPTION
    WHEN OTHERS THEN
        RAISE LOG 'ERROR in auto_create_inventory_records for account %: %',
            NEW.account_name, SQLERRM;
        RETURN NEW;
END;
$func$;

-- Create trigger
CREATE TRIGGER trigger_auto_create_inventory_records
AFTER INSERT ON public.game_accounts
FOR EACH ROW
EXECUTE FUNCTION public.auto_create_inventory_records();

-- Add comments
COMMENT ON FUNCTION public.auto_create_inventory_records()
IS 'Tự động tạo record tồn kho cho tài khoản inventory mới với đúng currency types (CURRENCY_POE1, CURRENCY_POE2, CURRENCY_D4) - FIXED VERSION';

COMMENT ON TRIGGER trigger_auto_create_inventory_records ON public.game_accounts
IS 'Trigger tự động tạo inventory records khi tạo game account mới với purpose = INVENTORY - FIXED VERSION';

-- Verification queries
SELECT 'TRIGGER_FIX_COMPLETED' as status,
       'auto_create_inventory_records trigger has been recreated with debugging and proper logic' as message;