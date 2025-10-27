-- Test script for channel-based inventory creation
-- This script tests the updated auto_create_inventory_records trigger

-- Step 1: Verify current channels setup
SELECT
    code,
    name,
    direction,
    is_active,
    purchase_fee_rate,
    sale_fee_rate
FROM channels
WHERE is_active = true
ORDER BY code;

-- Step 2: Check current active currencies (example for POE2)
SELECT
    id,
    code,
    name,
    is_active,
    sort_order
FROM attributes
WHERE type = 'CURRENCY_POE2'
  AND is_active = true
ORDER BY sort_order ASC
LIMIT 10;

-- Step 3: Create test game account with INVENTORY purpose
INSERT INTO game_accounts (
    account_name,
    game_code,
    purpose,
    manager_profile_id
) VALUES (
    'Test Inventory Account',
    'POE2',
    'INVENTORY',
    (SELECT id FROM profiles LIMIT 1)
) RETURNING id;

-- Step 4: Check created inventory records
-- This should show records for each currency x each BUY/BOTH channel
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
WHERE ga.account_name = 'Test Inventory Account'
ORDER BY a.sort_order, ch.code;

-- Step 5: Verify inventory counts
-- Should show: (number_of_active_currencies) × (number_of_buy_or_both_channels) records
SELECT
    COUNT(*) as total_inventory_records,
    COUNT(DISTINCT ci.currency_attribute_id) as unique_currencies,
    COUNT(DISTINCT ci.channel_id) as unique_channels,
    STRING_AGG(DISTINCT ch.code, ', ') as channels_used
FROM currency_inventory ci
JOIN game_accounts ga ON ci.game_account_id = ga.id
JOIN channels ch ON ci.channel_id = ch.id
WHERE ga.account_name = 'Test Inventory Account';

-- Step 6: Cleanup test data
-- DELETE FROM currency_inventory WHERE game_account_id = (SELECT id FROM game_accounts WHERE account_name = 'Test Inventory Account');
-- DELETE FROM game_accounts WHERE account_name = 'Test Inventory Account';