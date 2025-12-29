-- Remove auto-assignment functionality for purchase orders only
-- Keep assignment_trackers and related functions for sell orders

-- Step 1: Drop purchase auto-assignment function
DROP FUNCTION IF EXISTS assign_purchase_order(UUID) CASCADE;

-- Step 2: Remove purchase-related validation functions (keep for sell orders)
DROP FUNCTION IF EXISTS validate_and_refresh_assignment_tracker_for_purchase(UUID, TEXT, UUID, TEXT, TEXT, TEXT) CASCADE;
DROP FUNCTION IF EXISTS get_next_employee_round_robin_for_purchase(UUID, TEXT, UUID, TEXT, TEXT, TEXT) CASCADE;

-- Step 3: Update documentation - keep existing functions for sell orders
SELECT 'Purchase auto-assignment functions removed. Sell order assignment functions preserved.' as message;

-- Verify assign_sell_order_with_inventory_v2 still exists (for sell orders)
SELECT
    proname as function_name,
    'PRESERVED' as status
FROM pg_proc
WHERE proname = 'assign_sell_order_with_inventory_v2';

-- Note: get_available_game_accounts function is preserved for future use
SELECT
    proname as function_name,
    'PRESERVED for future use' as status
FROM pg_proc
WHERE proname = 'get_available_game_accounts';

-- assignment_trackers table preserved for sell order rotation
SELECT
    tablename as table_name,
    'PRESERVED for sell orders' as status
FROM pg_tables
WHERE tablename = 'assignment_trackers';