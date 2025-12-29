-- Cleanup duplicate shift assignments
-- Keep only the latest record for each employee+shift+channel+currency combination
-- This migration removes duplicates created after removing game_account_id column

-- Step 1: Show what will be deleted first (for verification)
SELECT 'About to delete the following duplicate assignments:' as message;

SELECT
    sa.id,
    p.display_name as employee_name,
    ws.name as shift_name,
    c.name as channel_name,
    sa.currency_code,
    sa.is_active,
    sa.created_at
FROM shift_assignments sa
LEFT JOIN profiles p ON sa.employee_profile_id = p.id
LEFT JOIN work_shifts ws ON sa.shift_id = ws.id
LEFT JOIN channels c ON sa.channels_id = c.id
WHERE sa.id NOT IN (
    SELECT DISTINCT ON (employee_profile_id, shift_id, channels_id, currency_code) id
    FROM shift_assignments
    ORDER BY employee_profile_id, shift_id, channels_id, currency_code, created_at DESC, id DESC
)
ORDER BY sa.created_at DESC;

-- Step 2: Delete the duplicates (keeping only the latest record for each combination)
DELETE FROM shift_assignments
WHERE id NOT IN (
    SELECT DISTINCT ON (employee_profile_id, shift_id, channels_id, currency_code) id
    FROM shift_assignments
    ORDER BY employee_profile_id, shift_id, channels_id, currency_code, created_at DESC, id DESC
);

-- Step 3: Verify the cleanup
SELECT 'Cleanup completed. Verifying remaining assignments:' as message;

SELECT
    employee_profile_id,
    shift_id,
    channels_id,
    currency_code,
    COUNT(*) as record_count
FROM shift_assignments
GROUP BY employee_profile_id, shift_id, channels_id, currency_code
HAVING COUNT(*) > 1
ORDER BY record_count DESC;