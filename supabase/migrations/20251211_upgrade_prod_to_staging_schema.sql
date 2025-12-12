-- Upgrade PROD to STAGING schema
-- Migration Date: 2025-12-11
-- Purpose: Add missing currency_inventory_pools table and update currency_transactions

-- 1. Create currency_inventory_pools table
CREATE TABLE IF NOT EXISTS currency_inventory_pools (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    game_code TEXT NOT NULL,
    server_attribute_code TEXT NOT NULL,
    currency_attribute_id UUID NOT NULL,
    game_account_id UUID NOT NULL,
    quantity NUMERIC NOT NULL DEFAULT 0,
    reserved_quantity NUMERIC NOT NULL DEFAULT 0,
    available_quantity NUMERIC GENERATED ALWAYS AS (quantity - reserved_quantity) STORED,
    cost_usd NUMERIC NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    created_by UUID NOT NULL,

    CONSTRAINT fk_inventory_pools_game_code
        FOREIGN KEY (game_code) REFERENCES attributes(code),
    CONSTRAINT fk_inventory_pools_server_code
        FOREIGN KEY (server_attribute_code) REFERENCES attributes(code),
    CONSTRAINT fk_inventory_pools_currency
        FOREIGN KEY (currency_attribute_id) REFERENCES attributes(id),
    CONSTRAINT fk_inventory_pools_account
        FOREIGN KEY (game_account_id) REFERENCES game_accounts(id),
    CONSTRAINT fk_inventory_pools_created_by
        FOREIGN KEY (created_by) REFERENCES profiles(id)
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_inventory_pools_game_server ON currency_inventory_pools(game_code, server_attribute_code);
CREATE INDEX IF NOT EXISTS idx_inventory_pools_currency ON currency_inventory_pools(currency_attribute_id);
CREATE INDEX IF NOT EXISTS idx_inventory_pools_account ON currency_inventory_pools(game_account_id);
CREATE INDEX IF NOT EXISTS idx_inventory_pools_available ON currency_inventory_pools(available_quantity) WHERE available_quantity > 0;

-- 2. Add inventory_pool_id column to currency_transactions
ALTER TABLE currency_transactions
ADD COLUMN IF NOT EXISTS inventory_pool_id UUID REFERENCES currency_inventory_pools(id);

-- 3. Create trigger to update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_inventory_pools_updated_at
    BEFORE UPDATE ON currency_inventory_pools
    FOR EACH ROW
    EXECUTE PROCEDURE update_updated_at_column();

-- 4. Grant permissions
GRANT ALL ON currency_inventory_pools TO authenticated;
GRANT ALL ON currency_inventory_pools TO service_role;

-- 5. Migration data from existing currency_inventory (if exists)
-- This would need to be customized based on your existing data structure
DO $$
BEGIN
    RAISE NOTICE 'Schema upgrade completed';
    RAISE NOTICE '- Created currency_inventory_pools table';
    RAISE NOTICE '- Added inventory_pool_id column to currency_transactions';
    RAISE NOTICE 'NOTE: Manual data migration may be required to populate currency_inventory_pools';
END;
$$;