-- Add DIABLO_4 support to auto_create_inventory_records trigger
-- This ensures DIABLO_4 accounts automatically get inventory records for CURRENCY_D4 items

CREATE OR REPLACE FUNCTION public.auto_create_inventory_records()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_currency_record RECORD;
BEGIN
    IF NEW.purpose = 'INVENTORY' THEN
        -- Create inventory records based on game code
        FOR v_currency_record IN
            SELECT id FROM public.attributes
            WHERE type = CASE NEW.game_code
                WHEN 'POE_1' THEN 'CURRENCY_POE1'
                WHEN 'POE_2' THEN 'CURRENCY_POE2'
                WHEN 'DIABLO_4' THEN 'CURRENCY_D4'
                ELSE NULL
            END
            AND is_active = true
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
                0, 0, 0, 0, NOW()
            );
        END LOOP;
    END IF;
    RETURN NEW;
END;
$$;

-- Recreate the trigger
DROP TRIGGER IF EXISTS on_game_account_created ON public.game_accounts;

CREATE TRIGGER on_game_account_created
AFTER INSERT ON public.game_accounts
FOR EACH ROW
EXECUTE FUNCTION public.auto_create_inventory_records();