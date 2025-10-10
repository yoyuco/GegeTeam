-- Debug and fix DIABLO_4 trigger issues
-- Add proper error handling and logging

-- First, let's check if there are any existing inventory records that might conflict
-- and clean up any orphaned records

-- Drop the problematic trigger first
DROP TRIGGER IF EXISTS on_game_account_created ON public.game_accounts;

-- Create a improved trigger function with better error handling
CREATE OR REPLACE FUNCTION public.auto_create_inventory_records()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_currency_record RECORD;
    v_existing_count INTEGER;
BEGIN
    -- Only process INVENTORY accounts
    IF NEW.purpose = 'INVENTORY' THEN
        -- Debug logging (remove in production)
        RAISE LOG 'Creating inventory records for game_account_id: %, game_code: %', NEW.id, NEW.game_code;

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
            -- Check if record already exists to avoid duplicate key error
            SELECT COUNT(*) INTO v_existing_count
            FROM public.currency_inventory
            WHERE game_account_id = NEW.id
            AND currency_attribute_id = v_currency_record.id;

            IF v_existing_count = 0 THEN
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

                RAISE LOG 'Created inventory record for currency_id: %', v_currency_record.id;
            ELSE
                RAISE LOG 'Inventory record already exists for currency_id: %', v_currency_record.id;
            END IF;
        END LOOP;
    END IF;

    RETURN NEW;
EXCEPTION
    WHEN OTHERS THEN
        RAISE LOG 'Error in auto_create_inventory_records: %, SQLSTATE: %', SQLERRM, SQLSTATE;
        -- Re-raise the exception so the transaction fails
        RAISE;
END;
$$;

-- Recreate the trigger
CREATE TRIGGER on_game_account_created
AFTER INSERT ON public.game_accounts
FOR EACH ROW
EXECUTE FUNCTION public.auto_create_inventory_records();

-- Add comment for documentation
COMMENT ON FUNCTION public.auto_create_inventory_records() IS 'Automatically creates inventory records for INVENTORY game accounts based on their game code (POE_1, POE_2, DIABLO_4)';