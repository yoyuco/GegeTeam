-- Add inventory_pool_id column to currency_transactions table
-- Migration Date: 2025-12-11
-- Purpose: Add missing inventory_pool_id column to match staging schema

-- Add the column to currency_transactions
ALTER TABLE currency_transactions
ADD COLUMN IF NOT EXISTS inventory_pool_id UUID REFERENCES inventory_pools(id);

-- Create index for better performance
CREATE INDEX IF NOT EXISTS idx_currency_transactions_inventory_pool
ON currency_transactions(inventory_pool_id)
WHERE inventory_pool_id IS NOT NULL;

-- Verification
DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'currency_transactions'
        AND column_name = 'inventory_pool_id'
    ) THEN
        RAISE NOTICE 'Column inventory_pool_id successfully added to currency_transactions';
    ELSE
        RAISE NOTICE 'Failed to add inventory_pool_id column';
    END IF;
END $$;