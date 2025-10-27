-- Test script for currency is_active changes trigger
-- This script tests the handle_currency_is_active_changes trigger

-- Step 1: Check current setup
SELECT
    a.code,
    a.name,
    a.is_active,
    a.type,
    COUNT(ci.id) as inventory_count
FROM attributes a
LEFT JOIN currency_inventory ci ON a.id = ci.currency_attribute_id
WHERE a.type = 'CURRENCY_POE2'
GROUP BY a.id, a.code, a.name, a.is_active, a.type
ORDER BY a.sort_order
LIMIT 5;

-- Step 2: Create test game account for testing
INSERT INTO game_accounts (
    account_name,
    game_code,
    purpose,
    manager_profile_id
) VALUES (
    'Test Currency Activation',
    'POE2',
    'INVENTORY',
    (SELECT id FROM profiles LIMIT 1)
) RETURNING id;

-- Step 3: Find a currency to test with (pick an inactive one)
SELECT
    id, code, name, is_active, type
FROM attributes
WHERE type = 'CURRENCY_POE2'
  AND is_active = false
ORDER BY sort_order
LIMIT 1;

-- Step 4: Test currency activation (false -> true)
-- NOTE: Replace the currency_id with actual ID from Step 3
-- UPDATE attributes
-- SET is_active = true
-- WHERE id = 'your-currency-id-here';

-- Step 5: Check created inventory records after activation
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
    ci.currency_code,
    ci.last_updated_at
FROM currency_inventory ci
JOIN game_accounts ga ON ci.game_account_id = ga.id
JOIN attributes a ON ci.currency_attribute_id = a.id
JOIN channels ch ON ci.channel_id = ch.id
WHERE ga.account_name = 'Test Currency Activation'
  AND a.code = 'TEST_CURRENCY' -- Replace with actual currency code
ORDER BY ch.code;

-- Step 6: Test currency deactivation attempt with inventory (should fail)
-- First add some inventory
-- INSERT INTO currency_inventory (game_account_id, currency_attribute_id, channel_id, quantity, game_code, currency_code)
-- VALUES (
--     (SELECT id FROM game_accounts WHERE account_name = 'Test Currency Activation'),
--     (SELECT id FROM attributes WHERE code = 'TEST_CURRENCY'),
--     (SELECT id FROM channels WHERE code = 'Facebook'),
--     100,
--     'POE2',
--     'VND'
-- );

-- Now try to deactivate (should fail with exception)
-- UPDATE attributes
-- SET is_active = false
-- WHERE id = 'your-currency-id-here';

-- Step 7: Test successful deactivation (after clearing inventory)
-- First clear inventory
-- DELETE FROM currency_inventory
-- WHERE currency_attribute_id = (SELECT id FROM attributes WHERE code = 'TEST_CURRENCY');

-- Now deactivate (should succeed)
-- UPDATE attributes
-- SET is_active = false
-- WHERE id = 'your-currency-id-here';

-- Step 8: Verify inventory records were deleted
SELECT COUNT(*) as remaining_inventory_records
FROM currency_inventory ci
JOIN attributes a ON ci.currency_attribute_id = a.id
WHERE a.code = 'TEST_CURRENCY';

-- Step 9: Cleanup test data
-- DELETE FROM game_accounts WHERE account_name = 'Test Currency Activation';

-- Helper queries for manual testing:

-- Count inventory records per currency
SELECT
    a.code,
    a.name,
    a.is_active,
    COUNT(ci.id) as inventory_records,
    COALESCE(SUM(ci.quantity), 0) as total_quantity
FROM attributes a
LEFT JOIN currency_inventory ci ON a.id = ci.currency_attribute_id
WHERE a.type = 'CURRENCY_POE2'
GROUP BY a.id, a.code, a.name, a.is_active
ORDER BY a.sort_order;

-- Check channels that will be used
SELECT
    code,
    name,
    direction,
    is_active,
    purchase_fee_rate
FROM channels
WHERE is_active = true
  AND (direction = 'BUY' OR direction = 'BOTH')
ORDER BY code;