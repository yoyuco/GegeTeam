-- Check current currency attributes in the database

-- Check what games we have
SELECT code, name, type FROM public.attributes WHERE type = 'GAME' ORDER BY code;

-- Check what currency attributes exist
SELECT
    code,
    name,
    type,
    parent_game_code,
    is_active
FROM public.attributes
WHERE type IN ('CURRENCY', 'CURRENCY_TYPE')
ORDER BY code
LIMIT 20;

-- Check if we have POE1, POE2, D4 currency attributes
SELECT
    code,
    name,
    type,
    is_active
FROM public.attributes
WHERE code LIKE '%POE1%' OR code LIKE '%POE2%' OR code LIKE '%D4%'
ORDER BY code;

-- Check what leagues are available
SELECT
    code,
    name,
    type,
    is_active
FROM public.attributes
WHERE type = 'LEAGUE'
ORDER BY code;