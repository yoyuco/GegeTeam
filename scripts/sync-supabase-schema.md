# Script đồng bộ Supabase Schema - Production ↔ Staging

## 🔄 Quy trình đồng bộ (không dùng Docker)

### **Bước 1: Export Schema từ Production**

#### Cách 1: Qua Supabase Dashboard (Khuyên dùng)
1. Login vào Production account
2. Mở: https://supabase.com/dashboard/project/susuoambmzdmcygovkea
3. Vào **SQL Editor**
4. Chạy lệnh này để export schema:
   ```sql
   -- Export schema definition
   SELECT string_agg(
     pg_get_functiondef(p.oid),
     E'\n\n'
   )
   FROM pg_proc p
   JOIN pg_namespace n ON p.pronamespace = n.oid
   WHERE n.nspname = 'public';
   ```
5. Hoặc dùng **Table Editor** → **Export as SQL**

#### Cách 2: Qua CLI (cần database password)
```bash
# Lấy connection string từ Dashboard:
# Settings → Database → Connection string → URI

supabase db dump \
  --db-url "postgresql://postgres.susuoambmzdmcygovkea:[YOUR-PASSWORD]@aws-0-ap-southeast-1.pooler.supabase.com:6543/postgres" \
  -f supabase/schema_prod.sql
```

---

### **Bước 2: Logout và switch sang Staging**

```bash
# Logout khỏi production account
supabase logout

# Login vào staging account
supabase login

# Link với staging project
supabase link --project-ref fvgjmfytzdnrdlluktdx
```

---

### **Bước 3: Export Schema từ Staging**

```bash
# Export staging schema
supabase db dump \
  --db-url "postgresql://postgres.fvgjmfytzdnrdlluktdx:[YOUR-PASSWORD]@aws-0-ap-southeast-1.pooler.supabase.com:6543/postgres" \
  -f supabase/schema_staging.sql
```

---

### **Bước 4: So sánh schemas**

```bash
# Option 1: Dùng diff tool
diff supabase/schema_prod.sql supabase/schema_staging.sql > schema_diff.txt

# Option 2: Dùng VS Code
code --diff supabase/schema_prod.sql supabase/schema_staging.sql

# Option 3: Dùng git diff
git diff --no-index supabase/schema_prod.sql supabase/schema_staging.sql
```

---

### **Bước 5: Quyết định chiến lược đồng bộ**

#### Option A: Production → Staging (nếu prod mới hơn)
```bash
# Login staging account
supabase login
supabase link --project-ref fvgjmfytzdnrdlluktdx

# Apply prod schema to staging
supabase db push --db-url "postgresql://..." --file supabase/schema_prod.sql
```

#### Option B: Staging → Production (nếu staging mới hơn)
```bash
# Login production account
supabase login
supabase link --project-ref susuoambmzdmcygovkea

# ⚠️ BACKUP PRODUCTION TRƯỚC!
# Dashboard → Database → Backups → Create Backup

# Apply staging schema to production
supabase db push --db-url "postgresql://..." --file supabase/schema_staging.sql
```

---

## 🎯 Giải pháp thay thế: Dùng Migration Files

Thay vì dump toàn bộ schema, sử dụng migration files có sẵn:

```bash
# Pull migrations từ production
supabase login  # Production account
supabase link --project-ref susuoambmzdmcygovkea
supabase db pull

# Logout và switch
supabase logout
supabase login  # Staging account
supabase link --project-ref fvgjmfytzdnrdlluktdx

# Push migrations lên staging
supabase db push
```

---

## 🛠️ Script tự động (PowerShell)

Tạo file `sync-schemas.ps1`:

```powershell
# sync-schemas.ps1
param(
    [string]$ProdPassword,
    [string]$StagingPassword
)

$ProdUrl = "postgresql://postgres.susuoambmzdmcygovkea:$ProdPassword@aws-0-ap-southeast-1.pooler.supabase.com:6543/postgres"
$StagingUrl = "postgresql://postgres.fvgjmfytzdnrdlluktdx:$StagingPassword@aws-0-ap-southeast-1.pooler.supabase.com:6543/postgres"

Write-Host "📥 Exporting Production schema..."
supabase db dump --db-url $ProdUrl -f supabase/schema_prod.sql

Write-Host "📥 Exporting Staging schema..."
supabase db dump --db-url $StagingUrl -f supabase/schema_staging.sql

Write-Host "🔍 Comparing schemas..."
code --diff supabase/schema_prod.sql supabase/schema_staging.sql

Write-Host "✅ Done! Review the diff and decide sync strategy."
```

Chạy:
```bash
.\sync-schemas.ps1 -ProdPassword "your-prod-pass" -StagingPassword "your-staging-pass"
```

---

## 📋 Checklist

### Trước khi đồng bộ:
- [ ] Backup Production database
- [ ] Export cả 2 schemas
- [ ] So sánh và xác định differences
- [ ] Test schema changes trên staging trước
- [ ] Có rollback plan

### Sau khi đồng bộ:
- [ ] Verify schema đã sync
- [ ] Test application trên cả 2 environments
- [ ] Update migrations trong Git
- [ ] Document changes

---

## 🔐 Lấy Database Password

### Production:
1. Dashboard → Settings → Database
2. Click **Reset database password** hoặc dùng password đã lưu

### Staging:
1. Tương tự như Production

---

## 💡 Workflow khuyên dùng (không cần CLI nhiều)

Vì bạn không muốn dùng CLI local:

```
┌─────────────┐
│   Develop   │ → Push code → Vercel (preview)
│   (local)   │              ↓
└─────────────┘         Auto link Staging DB
                              ↓
                        Test on preview
                              ↓
                        Merge to develop
                              ↓
┌─────────────┐         Deploy to Vercel
│   Staging   │ ← ─ ─ ─ (develop branch)
│     DB      │
└─────────────┘
      ↓
   Test OK?
      ↓
   Create PR
      ↓
┌─────────────┐
│    Main     │ → Merge → Deploy Vercel
│             │              ↓
└─────────────┘         Auto link Prod DB
      ↓
┌─────────────┐
│ Production  │
│     DB      │
└─────────────┘
```

**Migrations:**
- Tạo migration files thủ công trong `supabase/migrations/`
- Apply qua Supabase Dashboard SQL Editor
- Hoặc dùng GitHub Actions để auto apply

---

## 🚀 Setup GitHub Actions (Auto sync)

Tạo `.github/workflows/sync-db.yml`:

```yaml
name: Sync Supabase Schema

on:
  push:
    branches: [main]
    paths:
      - 'supabase/migrations/**'

jobs:
  deploy-prod:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - uses: supabase/setup-cli@v1
        with:
          version: latest

      - name: Apply migrations to Production
        env:
          SUPABASE_ACCESS_TOKEN: ${{ secrets.SUPABASE_PROD_TOKEN }}
          SUPABASE_DB_PASSWORD: ${{ secrets.SUPABASE_PROD_PASSWORD }}
        run: |
          supabase link --project-ref susuoambmzdmcygovkea
          supabase db push
```

**Setup secrets:**
- `SUPABASE_PROD_TOKEN`: Personal access token
- `SUPABASE_PROD_PASSWORD`: Database password

---

## 📞 Need Help?

- Supabase Docs: https://supabase.com/docs
- CLI Reference: https://supabase.com/docs/reference/cli
- Support: https://supabase.com/dashboard/support
