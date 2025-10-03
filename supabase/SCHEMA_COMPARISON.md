# Schema Comparison: Production vs Staging

**Generated:** 2025-10-03

## 📊 Summary

| Metric | Production | Staging | Difference |
|--------|-----------|---------|------------|
| Total Lines | 4,212 | 3,612 | +600 |
| Status | ✅ More Complete | ⚠️ Missing Objects | |

## 🔍 Key Differences

### 1. **Missing in Staging - Schemas**
```sql
CREATE SCHEMA IF NOT EXISTS "reporting";
```
- Production has dedicated reporting schema
- Staging does not have this schema

### 2. **Missing in Staging - Extensions**
```sql
CREATE EXTENSION IF NOT EXISTS "pgsodium";
CREATE EXTENSION IF NOT EXISTS "pg_trgm" WITH SCHEMA "extensions";
CREATE EXTENSION IF NOT EXISTS "btree_gin" WITH SCHEMA "extensions";
```
- `pgsodium`: Encryption support
- `pg_trgm`: Full-text search trigram matching
- `btree_gin`: GIN index support

### 3. **Missing in Staging - Functions**
```sql
CREATE OR REPLACE FUNCTION "public"."create_service_order_v1"(...)
```
- Critical RPC function for creating service orders
- Used by frontend application
- **This is a major difference!**

### 4. **Other Missing Objects**
- Additional RPC functions
- Indexes
- Triggers
- Policies

## ⚠️ Impact Analysis

### Critical (Must Sync):
- ❌ `create_service_order_v1` function - **Frontend depends on this!**
- ❌ Extensions (pgsodium, pg_trgm) - May break features
- ❌ Reporting schema - If used in app

### Medium Priority:
- Extensions (btree_gin) - Performance optimization
- Indexes - Query performance

### Low Priority:
- Schema owner statements
- Comments

## 🎯 Recommendation

**Sync Production → Staging**

Production is more complete and has critical functions that Staging lacks.

### Why Production is the source of truth:
1. ✅ Has all critical RPC functions
2. ✅ Has necessary extensions
3. ✅ Has reporting schema
4. ✅ More complete (+600 lines)

## 🚀 Sync Strategy

### Option 1: Full Schema Replacement (Recommended)
```bash
# Login to staging account
supabase login

# Link staging
supabase link --project-ref fvgjmfytzdnrdlluktdx

# Apply production schema
psql <connection-string> < supabase/schema_prod_full.sql
```

### Option 2: Migration-based (Safer)
1. Create migration from differences
2. Test on staging
3. Apply if successful

### Option 3: Manual via Dashboard
1. Open Staging Dashboard SQL Editor
2. Copy missing functions/schemas from prod schema file
3. Execute one by one

## 📋 Detailed Missing Objects

Run this to see all missing objects:
```bash
diff -u supabase/schema_staging_full.sql supabase/schema_prod_full.sql | grep "^+" | head -50
```

## ⚡ Action Items

- [ ] Backup Staging database
- [ ] Review production schema file
- [ ] Decide sync method
- [ ] Test after sync
- [ ] Update migration files in Git
- [ ] Document changes

## 🔗 Next Steps

1. **Backup Staging** (from Dashboard)
2. **Choose sync method** (Full replacement recommended)
3. **Execute sync**
4. **Test application** on staging
5. **Verify all functions work**
6. **Update Git migrations** to keep in sync

---

**Note:** This comparison was done on local dumps. Always backup before syncing!
