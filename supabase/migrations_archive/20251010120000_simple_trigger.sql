-- Simple trigger creation - no debugging, no complexity
-- This will create the most basic version to test if triggers work at all

-- Drop existing objects first
DROP TRIGGER IF EXISTS trigger_auto_create_inventory_records ON public.game_accounts;
DROP FUNCTION IF EXISTS public.auto_create_inventory_records() CASCADE;

-- Create simple function
CREATE OR REPLACE FUNCTION public.auto_create_inventory_records()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_currency_record RECORD;
BEGIN
    -- Only process INVENTORY accounts
    IF NEW.purpose = 'INVENTORY' THEN
        -- Create inventory records for all currencies of this game
        FOR v_currency_record IN
            SELECT id FROM public.attributes
            WHERE type = CASE NEW.game_code
                WHEN 'POE_1' THEN 'CURRENCY_POE1'
                WHEN 'POE_2' THEN 'CURRENCY_POE2'
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
                0,
                0,
                0,
                0,
                NOW()
            );
        END LOOP;
    END IF;

    RETURN NEW;
END;
$$;

-- Create trigger
CREATE TRIGGER trigger_auto_create_inventory_records
AFTER INSERT ON public.game_accounts
FOR EACH ROW
EXECUTE FUNCTION public.auto_create_inventory_records();

-- Simple test - create test account
INSERT INTO public.game_accounts (game_code, league_attribute_id, account_name, purpose)
SELECT
    'POE_2',
    (SELECT id FROM public.attributes WHERE type = 'LEAGUE_POE2' LIMIT 1),
    'Simple_Test_' || extract(epoch from now()),
    'INVENTORY'
RETURNING id;

-- Check result immediately
SELECT
    'SIMPLE_TRIGGER_TEST' as test_type,
    a.account_name,
    COUNT(ci.id) as inventory_count
FROM public.game_accounts a
LEFT JOIN public.currency_inventory ci ON a.id = ci.game_account_id
WHERE a.account_name LIKE 'Simple_Test_%'
GROUP BY a.id, a.account_name;

-- Clean up test data
DELETE FROM public.currency_inventory
WHERE game_account_id IN (
    SELECT id FROM public.game_accounts
    WHERE account_name LIKE 'Simple_Test_%'
);

DELETE FROM public.game_accounts
WHERE account_name LIKE 'Simple_Test_%';

SELECT 'SIMPLE_TRIGGER_COMPLETED' as status;