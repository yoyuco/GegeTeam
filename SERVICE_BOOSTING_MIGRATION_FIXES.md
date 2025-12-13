# Service Boosting Performance Migration - Fixes Applied

## Issue Fixed
The migration `20251213_add_indexes_for_service_boosting_performance.sql` had a PostgreSQL syntax error:
```
ERROR: 42601: syntax error at or near "CASE" LINE 47: CASE ^
```

## Root Cause
PostgreSQL doesn't support CASE statements directly in index definitions. The problematic code was:
```sql
CREATE INDEX idx_order_lines_delivered_at ON order_lines(
  CASE
    WHEN status = 'new' THEN 1
    -- ... more cases
  END,
  CASE WHEN delivered_at IS NOT NULL THEN 1 ELSE 0 END,
  delivered_at
);
```

## Solution Applied
Replaced the composite index with CASE statements with individual, simpler indexes:

### Before (problematic):
```sql
-- Single composite index with CASE statements
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_order_lines_delivered_at ON order_lines(
  CASE /* ... status mapping ... */ END,
  CASE WHEN delivered_at IS NOT NULL THEN 1 ELSE 0 END,
  delivered_at
);
```

### After (fixed):
```sql
-- Individual indexes for sorting
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_order_lines_status ON order_lines(status);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_order_lines_delivered_at_null ON order_lines(delivered_at) WHERE delivered_at IS NOT NULL;
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_order_lines_delivered_at_sort ON order_lines(delivered_at DESC);
```

## Migration Contents
The migration now includes:
1. ✅ pg_trgm extension for LIKE queries
2. ✅ JOIN indexes for order_lines, orders, parties tables
3. ✅ Filter indexes for game_code, status combinations
4. ✅ Full-text search index for customer names
5. ✅ Trigram index for partial matching
6. ✅ Indexes for work_sessions, order_service_items, service_reports, order_reviews
7. ✅ Timestamp indexes for created_at, updated_at
8. ✅ Individual sorting indexes (fixed)

## Performance Benefits
These indexes will improve:
- JOIN performance between orders, order_lines, and parties tables
- Filter performance on game_code and status
- Customer name search (both full-text and partial matching)
- Sorting by delivered_at
- Overall query performance for Service Boosting page

## Next Steps
1. Run the corrected migration on staging
2. Test query performance with EXPLAIN ANALYZE
3. Monitor Service Boosting page load times
4. If needed, consider Phase 2 (adding status_order column) for further optimization