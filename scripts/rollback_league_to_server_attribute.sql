-- Rollback: Change server_attribute_code back to league_attribute_id
-- This rollback converts text code references back to UUID foreign key references

-- Step 1: Add back league_attribute_id columns
ALTER TABLE currency_inventory ADD COLUMN league_attribute_id UUID;
ALTER TABLE currency_orders ADD COLUMN league_attribute_id UUID;
ALTER TABLE currency_transactions ADD COLUMN league_attribute_id UUID;
ALTER TABLE game_accounts ADD COLUMN league_attribute_id UUID;

-- Step 2: Populate league_attribute_id with values from attributes.id
UPDATE currency_inventory ci
SET league_attribute_id = a.id
FROM attributes a
WHERE ci.server_attribute_code = a.code;

UPDATE currency_orders co
SET league_attribute_id = a.id
FROM attributes a
WHERE co.server_attribute_code = a.code;

UPDATE currency_transactions ct
SET league_attribute_id = a.id
FROM attributes a
WHERE ct.server_attribute_code = a.code;

UPDATE game_accounts ga
SET league_attribute_id = a.id
FROM attributes a
WHERE ga.server_attribute_code = a.code;

-- Step 3: Make league_attribute_id NOT NULL (allow NULL for now since some might not match)
-- You may need to manually handle any NULL values before setting NOT NULL
-- UPDATE currency_inventory SET league_attribute_id = (SELECT id FROM attributes WHERE code = 'STANDARD_STANDARD_POE1') WHERE league_attribute_id IS NULL;
-- Repeat for other tables if needed

-- Step 4: Add foreign key constraints back to attributes.id
ALTER TABLE currency_inventory
ADD CONSTRAINT currency_inventory_league_attribute_id_fkey
FOREIGN KEY (league_attribute_id) REFERENCES attributes(id);

ALTER TABLE currency_orders
ADD CONSTRAINT currency_orders_league_attribute_id_fkey
FOREIGN KEY (league_attribute_id) REFERENCES attributes(id);

ALTER TABLE currency_transactions
ADD CONSTRAINT currency_transactions_league_attribute_id_fkey
FOREIGN KEY (league_attribute_id) REFERENCES attributes(id);

ALTER TABLE game_accounts
ADD CONSTRAINT game_accounts_league_attribute_id_fkey
FOREIGN KEY (league_attribute_id) REFERENCES attributes(id);

-- Step 5: Drop new foreign key constraints to attributes.code
ALTER TABLE currency_inventory DROP CONSTRAINT IF EXISTS fk_currency_inventory_server_attribute_code;
ALTER TABLE currency_orders DROP CONSTRAINT IF EXISTS fk_currency_orders_server_attribute_code;
ALTER TABLE currency_transactions DROP CONSTRAINT IF EXISTS fk_currency_transactions_server_attribute_code;
ALTER TABLE game_accounts DROP CONSTRAINT IF EXISTS fk_game_accounts_server_attribute_code;

-- Step 6: Drop indexes
DROP INDEX IF EXISTS idx_currency_inventory_server_attribute_code;
DROP INDEX IF EXISTS idx_currency_orders_server_attribute_code;
DROP INDEX IF EXISTS idx_currency_transactions_server_attribute_code;
DROP INDEX IF EXISTS idx_game_accounts_server_attribute_code;

-- Step 7: Drop server_attribute_code columns
ALTER TABLE currency_inventory DROP COLUMN IF EXISTS server_attribute_code;
ALTER TABLE currency_orders DROP COLUMN IF EXISTS server_attribute_code;
ALTER TABLE currency_transactions DROP COLUMN IF EXISTS server_attribute_code;
ALTER TABLE game_accounts DROP COLUMN IF EXISTS server_attribute_code;