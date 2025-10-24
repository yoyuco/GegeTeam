-- Debug and enable trigger functionality
-- This will check trigger status and try to enable it

-- First, check current trigger status
SELECT 'CURRENT_TRIGGER_STATUS' as check_type,
       trigger_name,
       event_manipulation,
       event_object_table,
       action_timing
FROM information_schema.triggers
WHERE trigger_name = 'trigger_auto_create_inventory_records';

-- Enable the trigger explicitly
ALTER TABLE public.game_accounts ENABLE TRIGGER trigger_auto_create_inventory_records;

-- Check if there are any constraints that might prevent the trigger
SELECT 'CONSTRAINTS_CHECK' as check_type,
       constraint_name,
       constraint_type,
       table_name
FROM information_schema.table_constraints
WHERE table_name = 'game_accounts'
  AND constraint_type = 'CHECK';

-- Check RLS policies that might interfere
SELECT 'RLS_POLICIES' as check_type,
       policyname,
       permissive,
       roles,
       cmd,
       qual
FROM pg_policies
WHERE tablename = 'game_accounts';

-- Simple test - create a function to test trigger directly
CREATE OR REPLACE FUNCTION test_trigger_manually()
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_account_id UUID;
    v_currency_count INTEGER;
BEGIN
    -- Create a test account
    INSERT INTO public.game_accounts (game_code, league_attribute_id, account_name, purpose)
    VALUES (
        'POE_2',
        (SELECT id FROM public.attributes WHERE type = 'LEAGUE_POE2' LIMIT 1),
        'Manual_Function_Test_' || extract(epoch from now()),
        'INVENTORY'
    )
    RETURNING id INTO v_account_id;

    -- Wait a moment (this is just for testing)
    PERFORM pg_sleep(1);

    -- Check if inventory was created
    SELECT COUNT(*) INTO v_currency_count
    FROM public.currency_inventory
    WHERE game_account_id = v_account_id;

    -- Clean up
    DELETE FROM public.currency_inventory WHERE game_account_id = v_account_id;
    DELETE FROM public.game_accounts WHERE id = v_account_id;

    RETURN 'Trigger test: Created ' || v_currency_count || ' inventory records';
EXCEPTION
    WHEN OTHERS THEN
    RETURN 'Trigger test error: ' || SQLERRM;
END;
$$;

-- Grant permission to execute the test function
GRANT EXECUTE ON FUNCTION test_trigger_manually() TO service_role;

-- Test the trigger manually
SELECT 'TRIGGER_MANUAL_TEST' as test_type,
       test_trigger_manually() as result;

-- Clean up the test function
DROP FUNCTION IF EXISTS test_trigger_manually();

SELECT 'ENABLE_TRIGGER_DEBUG_COMPLETED' as status,
       'Trigger has been enabled and tested manually' as message;