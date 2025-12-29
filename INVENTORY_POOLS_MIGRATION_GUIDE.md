# Inventory Pools Migration Guide

## Purpose
This migration optimizes the `inventory_pools` table structure to simplify pool lookup for currency orders.

## Migration File
- **Migration**: `supabase/migrations/20251218_update_inventory_pools_unique_constraint.sql`
- **Timestamp**: 2025-12-18 14:30:00

## Changes Made

### 1. Unique Constraint Update
**Before:**
```sql
UNIQUE (game_account_id, currency_attribute_id, cost_currency, game_code, channel_id)
```

**After:**
```sql
UNIQUE (game_account_id, currency_attribute_id, game_code, COALESCE(server_attribute_code, ''))
```

### 2. Data Cleanup
- Removed 9 duplicate pools (45 → 36 pools)
- Kept pools with highest quantity when duplicates existed
- Standardized all `cost_currency` to VND

### 3. Server Support
- Added `server_attribute_code` to unique constraint
- Uses `COALESCE` to handle games without servers
- Maintains backward compatibility

## Deployment Steps for Production

### 1. Pre-deployment Checks
```sql
-- Check current state
SELECT COUNT(*) as current_pool_count FROM inventory_pools;

-- Check for duplicates
SELECT
  game_code,
  game_account_id,
  currency_attribute_id,
  COUNT(*) as duplicate_count
FROM inventory_pools
GROUP BY game_code, game_account_id, currency_attribute_id
HAVING COUNT(*) > 1;
```

### 2. Backup
```sql
-- Create backup table (optional but recommended)
CREATE TABLE inventory_pools_backup_20251218 AS
SELECT * FROM inventory_pools;
```

### 3. Deploy Migration
```bash
# Using Supabase CLI
supabase db push

# Or apply migration directly
supabase migration up 20251218_update_inventory_pools_unique_constraint.sql
```

### 4. Post-deployment Verification
```sql
-- Verify no duplicates exist
SELECT COUNT(*) FROM (
  SELECT
    game_account_id,
    currency_attribute_id,
    game_code,
    server_attribute_code,
    COUNT(*) as cnt
  FROM inventory_pools
  GROUP BY game_account_id, currency_attribute_id, game_code, server_attribute_code
  HAVING COUNT(*) > 1
) duplicates;

-- Check pool count reduction
SELECT COUNT(*) as new_pool_count FROM inventory_pools;

-- Verify all costs are VND
SELECT COUNT(*) as non_vnd_costs
FROM inventory_pools
WHERE cost_currency != 'VND';
```

## Impact on Application Code

### 1. Query Changes
**Old query (considering channels):**
```sql
SELECT * FROM inventory_pools
WHERE game_account_id = $1
  AND currency_attribute_id = $2
  AND game_code = $3
  AND channel_id = $4
  AND cost_currency = $5
LIMIT 1;
```

**New query (simplified):**
```sql
SELECT * FROM inventory_pools
WHERE game_account_id = $1
  AND currency_attribute_id = $2
  AND game_code = $3
  AND (server_attribute_code = $4 OR (server_attribute_code IS NULL AND $4 = ''))
LIMIT 1;
```

### 2. Order Processing Updates
- Simplified pool selection logic
- No need to consider multiple channels/cost currencies
- Direct mapping from order requirements to single pool

### 3. API Changes
- Remove channel_id from inventory pool lookup endpoints
- Update pool search to use server_attribute_code instead

## Rollback Plan

If issues arise, manually execute:
```sql
-- Restore original unique constraint
DROP INDEX IF EXISTS idx_inventory_pools_unique_business_key;

CREATE UNIQUE INDEX idx_inventory_pools_unique_business_key
ON inventory_pools (game_account_id, currency_attribute_id, cost_currency, game_code, channel_id);

COMMENT ON INDEX idx_inventory_pools_unique_business_key IS 'Original unique business key including channel_id and cost_currency';

-- Note: Data deleted (duplicate pools) would need to be restored from backup
```

## Benefits Achieved

1. **Simplified Pool Lookup**: Single pool per combination
2. **Reduced Complexity**: No channel/cost currency considerations
3. **Better Performance**: Faster queries with fewer joins
4. **Cleaner Data**: Eliminated duplicates
5. **Future-proof**: Supports games with/without servers

## Testing Requirements

1. **Unit Tests**: Update pool lookup tests
2. **Integration Tests**: Order creation with new pool structure
3. **Performance Tests**: Verify query performance improvements
4. **Data Integrity**: Ensure no data loss during migration