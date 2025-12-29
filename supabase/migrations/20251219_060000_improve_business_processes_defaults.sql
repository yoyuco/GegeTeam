-- Improve business_processes table: Set default values for purchase_channel_id and sale_channel_id
-- This prevents NULL values and ensures data consistency

-- First, let's update any existing NULL values to use Facebook as default
UPDATE business_processes
SET purchase_channel_id = '815d1021-c0d0-4f26-a34f-1036f0a58092' -- Facebook channel
WHERE purchase_channel_id IS NULL;

UPDATE business_processes
SET sale_channel_id = '25e63b01-8c37-4f1e-8dc1-dd3f26771b9b' -- G2G channel
WHERE sale_channel_id IS NULL;

-- Now alter the columns to have default values
ALTER TABLE business_processes
ALTER COLUMN purchase_channel_id SET DEFAULT '815d1021-c0d0-4f26-a34f-1036f0a58092',
ALTER COLUMN sale_channel_id SET DEFAULT '25e63b01-8c37-4f1e-8dc1-dd3f26771b9b';

-- Add check constraints to ensure valid channel references
ALTER TABLE business_processes
ADD CONSTRAINT IF NOT EXISTS fk_business_processes_purchase_channel
    FOREIGN KEY (purchase_channel_id) REFERENCES channels(id) ON DELETE RESTRICT,
ADD CONSTRAINT IF NOT EXISTS fk_business_processes_sale_channel
    FOREIGN KEY (sale_channel_id) REFERENCES channels(id) ON DELETE RESTRICT;

-- Also set default for purchase_currency if it's NULL
UPDATE business_processes
SET purchase_currency = 'VND'
WHERE purchase_currency IS NULL;

ALTER TABLE business_processes
ALTER COLUMN purchase_currency SET DEFAULT 'VND';

-- Add a comment to document the default choices
COMMENT ON COLUMN business_processes.purchase_channel_id IS 'Default: Facebook channel (815d1021-c0d0-4f26-a34f-1036f0a58092)';
COMMENT ON COLUMN business_processes.sale_channel_id IS 'Default: G2G channel (25e63b01-8c37-4f1e-8dc1-dd3f26771b9b)';

-- Verify the changes
SELECT
    column_name,
    data_type,
    is_nullable,
    column_default,
    character_maximum_length
FROM information_schema.columns
WHERE table_name = 'business_processes'
    AND column_name IN ('purchase_channel_id', 'sale_channel_id', 'purchase_currency')
ORDER BY column_name;