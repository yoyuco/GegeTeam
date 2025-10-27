-- Comprehensive Test Script for Channel-Based Inventory System
-- Tests all functionality: game_accounts creation, currency activation/deactivation, and management functions

-- ================================================================
-- SETUP: Check Current State
-- ================================================================

-- Step 1: Verify current channels setup
SELECT
    code,
    name,
    direction,
    is_active,
    purchase_fee_rate,
    sale_fee_rate,
    CASE
        WHEN direction IN ('BUY', 'BOTH') AND is_active = true THEN '✅ Will create inventory'
        ELSE '❌ Will NOT create inventory'
    END as will_create_inventory
FROM channels
ORDER BY code;

-- Step 2: Count active currencies by game
SELECT
    REPLACE(type, 'CURRENCY_', '') as game_code,
    COUNT(*) as active_currencies,
    STRING_AGG(code, ', ' ORDER BY sort_order) as currency_codes
FROM attributes
WHERE type LIKE '%_CURRENCY'
  AND is_active = true
GROUP BY REPLACE(type, 'CURRENCY_', '')
ORDER BY game_code;

-- ================================================================
-- TEST 1: Game Account Creation
-- ================================================================

-- Step 3: Create test game account with INVENTORY purpose
INSERT INTO game_accounts (
    account_name,
    game_code,
    purpose,
    manager_profile_id
) VALUES (
    'Test Channel-Based Inventory',
    'POE2',
    'INVENTORY',
    (SELECT id FROM profiles LIMIT 1)
) RETURNING id;

-- Step 4: Verify inventory records were created automatically
SELECT
    ci.id,
    ci.game_account_id,
    ga.account_name,
    ci.currency_attribute_id,
    a.code as currency_code,
    a.name as currency_name,
    ci.channel_id,
    ch.code as channel_code,
    ch.name as channel_name,
    ci.quantity,
    ci.currency_code as inventory_currency,
    ci.last_updated_at
FROM currency_inventory ci
JOIN game_accounts ga ON ci.game_account_id = ga.id
JOIN attributes a ON ci.currency_attribute_id = a.id
JOIN channels ch ON ci.channel_id = ch.id
WHERE ga.account_name = 'Test Channel-Based Inventory'
ORDER BY a.sort_order, ch.code;

-- Step 5: Verify inventory counts summary
SELECT
    COUNT(*) as total_inventory_records,
    COUNT(DISTINCT ci.currency_attribute_id) as unique_currencies,
    COUNT(DISTINCT ci.channel_id) as unique_channels,
    STRING_AGG(DISTINCT ch.code, ', ') as channels_used,
    COUNT(DISTINCT ci.currency_code) as currency_types_used
FROM currency_inventory ci
JOIN game_accounts ga ON ci.game_account_id = ga.id
JOIN channels ch ON ci.channel_id = ch.id
WHERE ga.account_name = 'Test Channel-Based Inventory';

-- ================================================================
-- TEST 2: Currency Activation/Deactivation
-- ================================================================

-- Step 6: Find an inactive currency to test activation
SELECT
    id, code, name, is_active, type
FROM attributes
WHERE type = 'CURRENCY_POE2'
  AND is_active = false
ORDER BY sort_order
LIMIT 1;

-- Step 7: Test currency activation (replace currency_id with actual ID from Step 6)
-- NOTE: Uncomment and replace ID when ready to test
/*
SELECT * FROM activate_currency('your-currency-id-here', true) as pre_check;

UPDATE attributes
SET is_active = true
WHERE id = 'your-currency-id-here';

-- Verify new inventory records were created
SELECT
    ci.id,
    a.code as currency_code,
    ch.code as channel_code,
    ci.quantity,
    ci.currency_code
FROM currency_inventory ci
JOIN attributes a ON ci.currency_attribute_id = a.id
JOIN channels ch ON ci.channel_id = ch.id
JOIN game_accounts ga ON ci.game_account_id = ga.id
WHERE a.id = 'your-currency-id-here'
  AND ga.account_name = 'Test Channel-Based Inventory'
ORDER BY ch.code;
*/

-- Step 8: Test currency deactivation with inventory (should fail)
-- First add some inventory to test the safety check
/*
INSERT INTO currency_inventory (
    game_account_id,
    currency_attribute_id,
    channel_id,
    quantity,
    game_code,
    currency_code
) VALUES (
    (SELECT id FROM game_accounts WHERE account_name = 'Test Channel-Based Inventory'),
    (SELECT id FROM attributes WHERE code = 'TEST_CURRENCY' AND is_active = true),
    (SELECT id FROM channels WHERE code = 'Facebook'),
    100,
    'POE2',
    'VND'
);

-- Try to deactivate (should fail with exception)
SELECT * FROM safe_deactivate_currency('your-active-currency-id-here') as deactivation_attempt;
*/

-- Step 9: Test successful deactivation (after clearing inventory)
/*
-- Clear inventory first
DELETE FROM currency_inventory
WHERE currency_attribute_id = 'your-currency-id-here';

-- Now deactivate (should succeed)
SELECT * FROM safe_deactivate_currency('your-currency-id-here') as successful_deactivation;

UPDATE attributes
SET is_active = false
WHERE id = 'your-currency-id-here';
*/

-- ================================================================
-- TEST 3: Management Functions
-- ================================================================

-- Step 10: Test inventory summary function
SELECT * FROM get_currency_inventory_summary('POE2')
ORDER BY currency_code;

-- Step 11: Test orphaned inventory records function
SELECT * FROM find_orphaned_inventory_records()
ORDER BY account_name, currency_code;

-- ================================================================
-- VERIFICATION QUERIES
-- ================================================================

-- Quick health check of the system
SELECT
    'Game Accounts' as table_name,
    COUNT(*) as total_records,
    COUNT(CASE WHEN purpose = 'INVENTORY' THEN 1 END) as inventory_accounts
FROM game_accounts
UNION ALL
SELECT
    'Currency Inventory' as table_name,
    COUNT(*) as total_records,
    COUNT(DISTINCT game_account_id) as unique_accounts
FROM currency_inventory
UNION ALL
SELECT
    'Active Channels (BUY/BOTH)' as table_name,
    COUNT(*) as total_records,
    COUNT(CASE WHEN direction IN ('BUY', 'BOTH') THEN 1 END) as purchase_channels
FROM channels
WHERE is_active = true;

-- ================================================================
-- CLEANUP
-- ================================================================

-- Step 12: Cleanup test data (uncomment when done)
/*
DELETE FROM currency_inventory WHERE game_account_id = (SELECT id FROM game_accounts WHERE account_name = 'Test Channel-Based Inventory');
DELETE FROM game_accounts WHERE account_name = 'Test Channel-Based Inventory';
*/

-- ================================================================
-- HELPER QUERIES FOR MANUAL TESTING
-- ================================================================

-- List all currencies with their inventory status
SELECT
    a.code,
    a.name,
    a.is_active,
    REPLACE(a.type, 'CURRENCY_', '') as game,
    COUNT(ci.id) as inventory_records,
    COALESCE(SUM(ci.quantity), 0) as total_quantity,
    COALESCE(SUM(CASE WHEN ch.direction IN ('BUY', 'BOTH') THEN ci.quantity ELSE 0 END), 0) as buy_channel_quantity
FROM attributes a
LEFT JOIN currency_inventory ci ON a.id = ci.currency_attribute_id
LEFT JOIN channels ch ON ci.channel_id = ch.id
WHERE a.type LIKE '%_CURRENCY'
GROUP BY a.id, a.code, a.name, a.is_active, a.type
ORDER BY REPLACE(a.type, 'CURRENCY_', ''), a.sort_order;