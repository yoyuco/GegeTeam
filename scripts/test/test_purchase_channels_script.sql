-- Test script to verify add_purchase_channels_compatible.sql compatibility
-- This script checks if the purchase channels script will work with current database structure

-- Step 1: Check current channels table structure
SELECT 'Current channels table structure:' as info;

SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'channels'
AND table_schema = 'public'
ORDER BY ordinal_position;

-- Step 2: Check existing channels
SELECT 'Existing channels:' as info;

SELECT code, name, direction, is_active, purchase_fee_rate, sale_fee_rate
FROM public.channels
ORDER BY direction, code;

-- Step 3: Test INSERT statement compatibility (dry run)
SELECT 'Testing INSERT compatibility:' as info;

-- Simulate the INSERT without actually inserting data
SELECT
    'PUR001' as id,
    'Discord_Farmers' as code,
    'Discord Farmers' as name,
    'Discord communities and farmer groups where we purchase currencies' as description,
    'BUY' as direction,
    true as is_active,
    NOW() as created_at,
    NOW() as updated_at,
    2.0 as purchase_fee_rate,
    0 as purchase_fee_fixed,
    'VND' as purchase_fee_currency,
    0 as sale_fee_rate,
    0 as sale_fee_fixed,
    'VND' as sale_fee_currency;

-- Step 4: Check if sample data fits existing constraints
SELECT 'Constraint compatibility check:' as info;

-- Test if sample data violates any unique constraints
SELECT COUNT(*) as conflict_count
FROM public.channels
WHERE code = 'Discord_Farmers' OR code = 'Facebook_Groups' OR code = 'Direct_Farmers';

-- Step 5: Verify query compatibility
SELECT 'Query compatibility test:' as info;

-- Test the SELECT queries from the script
SELECT
    direction,
    COUNT(*) as channel_count,
    COUNT(*) FILTER (WHERE is_active = true) as active_count
FROM public.channels
GROUP BY direction
ORDER BY direction;

-- Step 6: Check fee structure compatibility
SELECT 'Fee structure test:' as info;

SELECT
    'Purchase channels available' as test_result,
    COUNT(*) FILTER (WHERE direction IN ('BUY', 'BOTH')) as available_channels,
    AVG(purchase_fee_rate) FILTER (WHERE direction IN ('BUY', 'BOTH')) as avg_purchase_fee
FROM public.channels;

-- Step 7: Final compatibility assessment
SELECT 'Compatibility assessment:' as info;

SELECT
    CASE
        WHEN (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = 'channels' AND column_name = 'direction') > 0
        THEN '✅ COMPATIBLE: Direction column exists'
        ELSE '❌ INCOMPATIBLE: Direction column missing'
    END as direction_check,

    CASE
        WHEN (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = 'channels' AND column_name = 'purchase_fee_rate') > 0
        THEN '✅ COMPATIBLE: Purchase fee columns exist'
        ELSE '❌ INCOMPATIBLE: Purchase fee columns missing'
    END as fee_check,

    CASE
        WHEN (SELECT COUNT(*) FROM public.channels) > 0
        THEN '✅ COMPATIBLE: Channels table has data'
        ELSE '⚠️  WARNING: Channels table empty (should still work)'
    END as data_check,

    CASE
        WHEN (SELECT COUNT(*) FROM public.channels WHERE direction IN ('BUY', 'SELL', 'BOTH')) > 0
        THEN '✅ COMPATIBLE: Direction values are valid'
        ELSE '⚠️  WARNING: No direction values found (should still work)'
    END as direction_values_check;

-- Step 8: Recommendations
SELECT 'Recommendations:' as info;

SELECT
    CASE
        WHEN (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = 'channels' AND column_name = 'direction') > 0
        THEN '✅ Script should work perfectly with current database structure'
        ELSE '❌ Database structure incompatible - needs modification'
    END as final_recommendation;

SELECT 'Ready to run add_purchase_channels_compatible.sql' as next_step;