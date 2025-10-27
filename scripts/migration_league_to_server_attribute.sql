-- Migration: Change league_attribute_id to server_attribute_code
-- This migration converts UUID foreign key references to text code references

-- Step 1: Add new server_attribute_code columns
ALTER TABLE currency_inventory ADD COLUMN server_attribute_code TEXT;
ALTER TABLE currency_orders ADD COLUMN server_attribute_code TEXT;
ALTER TABLE currency_transactions ADD COLUMN server_attribute_code TEXT;
ALTER TABLE game_accounts ADD COLUMN server_attribute_code TEXT;

-- Note: direct_currency_exchanges and service_exchange_orders tables may need to be created first
-- or they may be views/virtual tables - adjust accordingly if they don't exist

-- Step 2: Populate server_attribute_code with values from attributes.code
UPDATE currency_inventory ci
SET server_attribute_code = a.code
FROM attributes a
WHERE ci.league_attribute_id = a.id;

UPDATE currency_orders co
SET server_attribute_code = a.code
FROM attributes a
WHERE co.league_attribute_id = a.id;

UPDATE currency_transactions ct
SET server_attribute_code = a.code
FROM attributes a
WHERE ct.league_attribute_id = a.id;

UPDATE game_accounts ga
SET server_attribute_code = a.code
FROM attributes a
WHERE ga.league_attribute_id = a.id;

-- Step 3: Make server_attribute_code NOT NULL after data migration
-- First ensure all records have values
UPDATE currency_inventory SET server_attribute_code = 'STANDARD_STANDARD_POE1' WHERE server_attribute_code IS NULL;
UPDATE currency_orders SET server_attribute_code = 'STANDARD_STANDARD_POE1' WHERE server_attribute_code IS NULL;
UPDATE currency_transactions SET server_attribute_code = 'STANDARD_STANDARD_POE1' WHERE server_attribute_code IS NULL;
UPDATE game_accounts SET server_attribute_code = 'STANDARD_STANDARD_POE1' WHERE server_attribute_code IS NULL;

-- Add NOT NULL constraint
ALTER TABLE currency_inventory ALTER COLUMN server_attribute_code SET NOT NULL;
ALTER TABLE currency_orders ALTER COLUMN server_attribute_code SET NOT NULL;
ALTER TABLE currency_transactions ALTER COLUMN server_attribute_code SET NOT NULL;
ALTER TABLE game_accounts ALTER COLUMN server_attribute_code SET NOT NULL;

-- Step 4: Add foreign key constraint to attributes.code
ALTER TABLE currency_inventory
ADD CONSTRAINT fk_currency_inventory_server_attribute_code
FOREIGN KEY (server_attribute_code) REFERENCES attributes(code);

ALTER TABLE currency_orders
ADD CONSTRAINT fk_currency_orders_server_attribute_code
FOREIGN KEY (server_attribute_code) REFERENCES attributes(code);

ALTER TABLE currency_transactions
ADD CONSTRAINT fk_currency_transactions_server_attribute_code
FOREIGN KEY (server_attribute_code) REFERENCES attributes(code);

ALTER TABLE game_accounts
ADD CONSTRAINT fk_game_accounts_server_attribute_code
FOREIGN KEY (server_attribute_code) REFERENCES attributes(code);

-- Step 5: Drop old foreign key constraints (they may be named differently)
ALTER TABLE currency_inventory DROP CONSTRAINT IF EXISTS currency_inventory_league_attribute_id_fkey;
ALTER TABLE currency_orders DROP CONSTRAINT IF EXISTS currency_orders_league_attribute_id_fkey;
ALTER TABLE currency_transactions DROP CONSTRAINT IF EXISTS currency_transactions_league_attribute_id_fkey;
ALTER TABLE game_accounts DROP CONSTRAINT IF EXISTS game_accounts_league_attribute_id_fkey;

-- Step 6: Drop old league_attribute_id columns
ALTER TABLE currency_inventory DROP COLUMN IF EXISTS league_attribute_id;
ALTER TABLE currency_orders DROP COLUMN IF EXISTS league_attribute_id;
ALTER TABLE currency_transactions DROP COLUMN IF EXISTS league_attribute_id;
ALTER TABLE game_accounts DROP COLUMN IF EXISTS league_attribute_id;

-- Step 7: Add indexes for performance
CREATE INDEX idx_currency_inventory_server_attribute_code ON currency_inventory(server_attribute_code);
CREATE INDEX idx_currency_orders_server_attribute_code ON currency_orders(server_attribute_code);
CREATE INDEX idx_currency_transactions_server_attribute_code ON currency_transactions(server_attribute_code);
CREATE INDEX idx_game_accounts_server_attribute_code ON game_accounts(server_attribute_code);

-- Comments
COMMENT ON COLUMN currency_inventory.server_attribute_code IS 'Server attribute code referencing GAME_SERVER type attributes';
COMMENT ON COLUMN currency_orders.server_attribute_code IS 'Server attribute code referencing GAME_SERVER type attributes';
COMMENT ON COLUMN currency_transactions.server_attribute_code IS 'Server attribute code referencing GAME_SERVER type attributes';
COMMENT ON COLUMN game_accounts.server_attribute_code IS 'Server attribute code referencing GAME_SERVER type attributes';