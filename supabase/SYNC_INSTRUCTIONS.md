# 🔄 Cách đồng bộ Production → Staging qua Dashboard

Vì migration tự động gặp lỗi, hãy làm thủ công qua Dashboard:

## ✅ Đã hoàn thành:
- ✅ Backup staging: `backup_staging_before_sync_20251003_075133.sql`
- ✅ Export production schema: `schema_prod_full.sql`
- ✅ Export staging schema: `schema_staging_full.sql`
- ✅ So sánh: Production có nhiều hơn ~600 dòng

## 📋 Các objects thiếu trong Staging:

### 1. Extensions (Apply trước tiên)
```sql
CREATE EXTENSION IF NOT EXISTS "pgsodium";
CREATE EXTENSION IF NOT EXISTS "btree_gin" WITH SCHEMA "extensions";
CREATE EXTENSION IF NOT EXISTS "pg_trgm" WITH SCHEMA "extensions";
```

### 2. Schema
```sql
CREATE SCHEMA IF NOT EXISTS "reporting";
ALTER SCHEMA "reporting" OWNER TO "postgres";
```

### 3. Critical Function - create_service_order_v1
Hàm này QUAN TRỌNG! Frontend đang dùng.

**Cách apply:**
1. Mở `supabase/schema_prod_full.sql`
2. Tìm `CREATE OR REPLACE FUNCTION "public"."create_service_order_v1"`
3. Copy toàn bộ function (từ CREATE đến END $$;)
4. Apply vào Staging

## 🚀 Cách thực hiện qua Dashboard:

### Bước 1: Mở Staging SQL Editor
```
https://supabase.com/dashboard/project/fvgjmfytzdnrdlluktdx/sql/new
```

### Bước 2: Apply Extensions
Copy và run:
```sql
CREATE EXTENSION IF NOT EXISTS "pgsodium";
CREATE EXTENSION IF NOT EXISTS "btree_gin" WITH SCHEMA "extensions";
CREATE EXTENSION IF NOT EXISTS "pg_trgm" WITH SCHEMA "extensions";
```

### Bước 3: Create Reporting Schema
```sql
CREATE SCHEMA IF NOT EXISTS "reporting";
```

### Bước 4: Apply Functions
1. Mở file: `D:\Web\GegeTeam\supabase\schema_prod_full.sql`
2. Tìm tất cả `CREATE OR REPLACE FUNCTION`
3. Copy từng function và run trong SQL Editor

**Các functions quan trọng:**
- `create_service_order_v1` (line ~564)
- Các functions khác (tìm bằng Ctrl+F "CREATE OR REPLACE FUNCTION")

### Bước 5: Verify
Run query này để check:
```sql
-- Check extensions
SELECT * FROM pg_extension WHERE extname IN ('pgsodium', 'btree_gin', 'pg_trgm');

-- Check schemas
SELECT schema_name FROM information_schema.schemata WHERE schema_name = 'reporting';

-- Check function exists
SELECT routine_name
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_name = 'create_service_order_v1';
```

## 📝 Hoặc Apply toàn bộ qua psql:

Nếu bạn có database password:

```bash
# Get connection string from Dashboard
# Settings → Database → Connection string → Connection pooler

psql "postgresql://postgres.fvgjmfytzdnrdlluktdx:[PASSWORD]@aws-0-ap-southeast-1.pooler.supabase.com:6543/postgres" \
  -f supabase/schema_prod_full.sql
```

**Lưu ý:** Có thể gặp lỗi "already exists" - bỏ qua những lỗi đó, chỉ cần các objects mới được tạo.

## ⚡ Cách nhanh nhất (Recommended):

### Option A: Sử dụng Supabase CLI với --debug
```bash
cd "D:\Web\GegeTeam"
supabase db push --linked --debug
```

### Option B: Reset và import lại (NGUY HIỂM!)
```bash
# ⚠️ CHỈ dùng nếu staging không có data quan trọng
cd "D:\Web\GegeTeam"
supabase db reset --linked  # Nhấn Y khi được hỏi
# Sau đó manually apply schema qua Dashboard
```

## 🔍 Test sau khi sync:

```sql
-- Test function works
SELECT create_service_order_v1(
  'WEB',  -- channel_code
  'Test Customer',  -- customer_name
  'BASIC',  -- package_type
  'Test order',  -- package_note
  NOW() + interval '7 days',  -- deadline
  'selfplay',  -- service_type
  'TestBtag#1234',  -- btag
  NULL, NULL, NULL,  -- login_id, login_pwd, machine_info
  '[]'::jsonb,  -- service_items
  ARRAY[]::text[]  -- action_proof_urls
);
```

---

**Sau khi hoàn tất:**
1. Test application trên staging
2. Commit backup files vào Git
3. Document changes
