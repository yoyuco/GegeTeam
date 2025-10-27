-- Verification script for league_attribute_id to server_attribute_code migration
-- Run this script to verify the migration was successful

-- Step 1: Verify all tables have the new column
SELECT
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE column_name = 'server_attribute_code'
AND table_schema = 'public'
ORDER BY table_name;

-- Step 2: Verify old columns are removed
SELECT
    table_name,
    column_name,
    data_type
FROM information_schema.columns
WHERE column_name = 'league_attribute_id'
AND table_schema = 'public'
ORDER BY table_name;

-- Step 3: Verify data integrity - check that all server_attribute_code values exist in attributes.code
SELECT
    'currency_inventory' as table_name,
    COUNT(*) as total_records,
    COUNT(ci.server_attribute_code) as with_server_code,
    COUNT(a.code) as matching_codes
FROM currency_inventory ci
LEFT JOIN attributes a ON ci.server_attribute_code = a.code

UNION ALL

SELECT
    'currency_orders' as table_name,
    COUNT(*) as total_records,
    COUNT(co.server_attribute_code) as with_server_code,
    COUNT(a.code) as matching_codes
FROM currency_orders co
LEFT JOIN attributes a ON co.server_attribute_code = a.code

UNION ALL

SELECT
    'currency_transactions' as table_name,
    COUNT(*) as total_records,
    COUNT(ct.server_attribute_code) as with_server_code,
    COUNT(a.code) as matching_codes
FROM currency_transactions ct
LEFT JOIN attributes a ON ct.server_attribute_code = a.code

UNION ALL

SELECT
    'game_accounts' as table_name,
    COUNT(*) as total_records,
    COUNT(ga.server_attribute_code) as with_server_code,
    COUNT(a.code) as matching_codes
FROM game_accounts ga
LEFT JOIN attributes a ON ga.server_attribute_code = a.code;

-- Step 4: Check for any NULL server_attribute_code values (should be 0)
SELECT
    'currency_inventory' as table_name,
    COUNT(*) as null_count
FROM currency_inventory
WHERE server_attribute_code IS NULL

UNION ALL

SELECT
    'currency_orders' as table_name,
    COUNT(*) as null_count
FROM currency_orders
WHERE server_attribute_code IS NULL

UNION ALL

SELECT
    'currency_transactions' as table_name,
    COUNT(*) as null_count
FROM currency_transactions
WHERE server_attribute_code IS NULL

UNION ALL

SELECT
    'game_accounts' as table_name,
    COUNT(*) as null_count
FROM game_accounts
WHERE server_attribute_code IS NULL;

-- Step 5: Verify foreign key constraints exist
SELECT
    tc.table_name,
    tc.constraint_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
    AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
AND kcu.column_name = 'server_attribute_code'
AND tc.table_schema = 'public'
ORDER BY tc.table_name;

-- Step 6: Sample data verification
SELECT
    'currency_inventory' as table_name,
    server_attribute_code,
    COUNT(*) as count
FROM currency_inventory
GROUP BY server_attribute_code
ORDER BY count DESC
LIMIT 5

UNION ALL

SELECT
    'currency_orders' as table_name,
    server_attribute_code,
    COUNT(*) as count
FROM currency_orders
GROUP BY server_attribute_code
ORDER BY count DESC
LIMIT 5

UNION ALL

SELECT
    'game_accounts' as table_name,
    server_attribute_code,
    COUNT(*) as count
FROM game_accounts
GROUP BY server_attribute_code
ORDER BY count DESC
LIMIT 5;

-- Step 7: Check if referenced attributes are of type GAME_SERVER
SELECT DISTINCT
    a.type,
    a.code,
    a.name,
    COUNT(*) as usage_count
FROM attributes a
JOIN (
    SELECT server_attribute_code FROM currency_inventory WHERE server_attribute_code IS NOT NULL
    UNION ALL
    SELECT server_attribute_code FROM currency_orders WHERE server_attribute_code IS NOT NULL
    UNION ALL
    SELECT server_attribute_code FROM currency_transactions WHERE server_attribute_code IS NOT NULL
    UNION ALL
    SELECT server_attribute_code FROM game_accounts WHERE server_attribute_code IS NOT NULL
) usage ON a.code = usage.server_attribute_code
GROUP BY a.type, a.code, a.name
ORDER BY usage_count DESC;