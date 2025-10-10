-- Final fix for auto_create_inventory_records trigger to work with correct currency types
-- This migration fixes the trigger to properly filter currencies based on game version

-- Drop existing trigger first, then function
DROP TRIGGER IF EXISTS trigger_auto_create_inventory_records ON public.game_accounts;
DROP FUNCTION IF EXISTS public.auto_create_inventory_records() CASCADE;

-- Create updated function with correct logic
CREATE OR REPLACE FUNCTION public.auto_create_inventory_records()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $func$
DECLARE
    v_currency_record RECORD;
    v_currency_type TEXT;
BEGIN
    -- Only process INVENTORY type accounts
    IF NEW.purpose = 'INVENTORY' THEN
        -- Determine currency type based on game code
        v_currency_type := CASE NEW.game_code
            WHEN 'POE_1' THEN 'CURRENCY_POE1'
            WHEN 'POE_2' THEN 'CURRENCY_POE2'
            WHEN 'D4' THEN 'CURRENCY_D4'
            ELSE 'CURRENCY_' || UPPER(REPLACE(NEW.game_code, '_', ''))
        END;

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

            -- Log for debugging
            RAISE LOG 'Created inventory record for game_account_id: %, currency: % (%)',
                NEW.id, v_currency_record.name, v_currency_record.code;
        END LOOP;

        RAISE LOG 'Auto-created % inventory records for new game account: % (Game: %)',
            (SELECT COUNT(*) FROM public.currency_inventory WHERE game_account_id = NEW.id),
            NEW.account_name,
            NEW.game_code;
    END IF;

    RETURN NEW;
EXCEPTION
    WHEN OTHERS THEN
        RAISE LOG 'Error in auto_create_inventory_records for game account %: %',
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
IS 'Tự động tạo record tồn kho cho tài khoản inventory mới với đúng currency types (CURRENCY_POE1, CURRENCY_POE2, CURRENCY_D4)';

COMMENT ON TRIGGER trigger_auto_create_inventory_records ON public.game_accounts
IS 'Trigger tự động tạo inventory records khi tạo game account mới với purpose = INVENTORY';

-- Verification query
SELECT 'TRIGGER UPDATE COMPLETED' as status,
       'auto_create_inventory_records trigger has been updated with correct currency type logic' as message;