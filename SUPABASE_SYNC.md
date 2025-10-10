# Supabase Sync Guide - Staging ↔ Production

Hướng dẫn đồng bộ database schema giữa Staging và Production.

## 📋 Tình huống hiện tại

- **Staging:** `fvgjmfytzdnrdlluktdx.supabase.co`
- **Production:** `susuoambmzdmcygovkea.supabase.co`
- CLI chưa link đến project nào

---

## 🔗 Bước 1: Link CLI với Projects

### Link với Staging (Development)

```bash
# Link CLI với staging project
supabase link --project-ref fvgjmfytzdnrdlluktdx

# Tạo file .env cho staging (nếu chưa có)
cp .env.local .env.staging
```

### Link với Production

```bash
# Tạo file .env.production
cat > .env.production << EOF
VITE_SITE_URL=https://your-production-domain.com
VITE_SUPABASE_URL=https://susuoambmzdmcygovkea.supabase.co
VITE_SUPABASE_ANON_KEY=<your-production-anon-key>
EOF
```

---

## 📤 Bước 2: Tạo Migration từ Staging

### Option 1: Tạo migration từ local changes

```bash
# Pull schema từ staging về local
supabase db pull --linked

# Review changes trong migrations/
git diff supabase/migrations/
```

### Option 2: Tạo migration thủ công

```bash
# Tạo migration file mới
supabase migration new <migration-name>

# Edit file trong supabase/migrations/
code supabase/migrations/<timestamp>_<migration-name>.sql
```

---

## 🚀 Bước 3: Deploy lên Production

### Cách 1: Qua Supabase CLI (Khuyên dùng)

```bash
# Switch link sang production
supabase link --project-ref susuoambmzdmcygovkea

# Push migrations
supabase db push

# Verify
supabase db diff --linked
```

### Cách 2: Qua Supabase Dashboard

1. Mở Dashboard Production: https://supabase.com/dashboard/project/susuoambmzdmcygovkea
2. Vào **SQL Editor**
3. Copy nội dung migration file và execute
4. Hoặc dùng **Database > Migrations** để upload file

---

## 🔄 Workflow đồng bộ chuẩn

```
1. Dev trên Staging
   ↓
2. Test kỹ trên Staging
   ↓
3. Tạo Migration
   ↓
4. Commit migration vào Git
   ↓
5. Review PR
   ↓
6. Merge vào main
   ↓
7. Deploy migration lên Production
   ↓
8. Verify Production
```

---

## 🛡️ Safety Checklist

### Trước khi deploy Production:

- [ ] Đã test kỹ migration trên Staging
- [ ] Backup Production database
  ```bash
  # Từ Supabase Dashboard
  Database > Backups > Create Backup
  ```
- [ ] Review migration SQL cẩn thận
- [ ] Có rollback plan
- [ ] Test ở non-peak hours (nếu có thể)

### Backup Production trước khi migrate:

```bash
# Download backup qua CLI
supabase db dump --linked > backup_$(date +%Y%m%d_%H%M%S).sql
```

---

## 📝 Các lệnh quan trọng

### Switch giữa projects

```bash
# Link staging
supabase link --project-ref fvgjmfytzdnrdlluktdx

# Link production
supabase link --project-ref susuoambmzdmcygovkea

# Check linked project
supabase projects list
```

### Pull schema từ remote

```bash
supabase db pull --linked
```

### Push migrations lên remote

```bash
supabase db push --linked
```

### Kiểm tra diff

```bash
# So sánh local vs remote
supabase db diff --linked

# So sánh 2 migrations
supabase db diff <file1.sql> <file2.sql>
```

### Reset local database (NGUY HIỂM!)

```bash
supabase db reset
```

---

## 🔥 Rollback nếu có lỗi

### Option 1: Restore từ backup

```bash
# Từ Supabase Dashboard
Database > Backups > Restore
```

### Option 2: Tạo migration rollback

```sql
-- Ví dụ: Nếu migration add column, rollback sẽ drop column
ALTER TABLE orders DROP COLUMN IF EXISTS new_column;
```

---

## 🌿 Branch-based Workflow (Advanced)

Supabase hỗ trợ preview branches cho mỗi git branch:

```bash
# Tạo preview environment
supabase branches create feature/new-ui

# Deploy lên preview
supabase db push --preview-branch feature/new-ui

# Sau khi merge PR → auto deploy production
```

---

## 📚 Tài liệu tham khảo

- [Supabase CLI - Local Development](https://supabase.com/docs/guides/cli/local-development)
- [Database Migrations](https://supabase.com/docs/guides/cli/local-development#database-migrations)
- [Branching](https://supabase.com/docs/guides/platform/branching)

---

## 💡 Tips

1. **Luôn test migration trên staging trước**
2. **Commit migrations vào Git**
3. **Đặt tên migration rõ ràng:** `YYYYMMDD_HHMM_descriptive_name.sql`
4. **Không sửa migrations đã deploy** - tạo migration mới để fix
5. **Backup trước khi deploy production**
6. **Dùng transactions trong migration:**
   ```sql
   BEGIN;
   -- Your changes here
   COMMIT;
   ```

---

## 🔑 Environment Variables

### Staging (.env.local)

```
VITE_SUPABASE_URL=https://fvgjmfytzdnrdlluktdx.supabase.co
VITE_SUPABASE_ANON_KEY=<staging-anon-key>
```

### Production (.env.production)

```
VITE_SUPABASE_URL=https://susuoambmzdmcygovkea.supabase.co
VITE_SUPABASE_ANON_KEY=<production-anon-key>
```

### Build commands:

```bash
# Build for staging
pnpm build --mode staging

# Build for production
pnpm build --mode production
```
