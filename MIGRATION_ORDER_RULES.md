# Migration Order Rules for Supabase

## Quy tắc sắp xếp migrations đúng thứ tự

### 1. Database Schema First (Core Structure)
**Prefix: `YYYYMMDD_` + `schema_` + `description.sql`
- Table definitions
- Column definitions
- Constraints
- Indexes
- Enum types
- Sequences

**Ví dụ:**
```
20251206_schema_create_work_shifts.sql
20251206_schema_update_profiles_table.sql
20251206_schema_add_currency_orders_table.sql
```

### 2. Data Initialization (Seeds & Initial Data)
**Prefix: `YYYYMMDD_` + `seed_` + `description.sql`
- Initial data insertion
- Master data (countries, currencies, roles, etc.)
- Default configurations

**Ví dụ:**
```
20251206_seed_default_roles.sql
20251206_seed_initial_shifts.sql
20251206_seed_default_channels.sql
```

### 3. Database Functions & Triggers
**Prefix: `YYYYMMDD_` + `function_` + `description.sql`
- Stored procedures
- Database functions
- Triggers
- Views

**Ví dụ:**
```
20251206_function_get_current_profile_id.sql
20251206_function_create_currency_sell_order.sql
20251206_function_get_or_create_assignment_tracker.sql
```

### 4. Row Level Security (RLS) Policies
**Prefix: `YYYYMMDD_` + `rls_` + `description.sql`
- RLS enablement on tables
- Policy definitions
- Permission grants

**Ví dụ:**
```
20251206_rls_currency_orders_policies.sql
20251206_rls_profiles_policies.sql
20251206_rls_assignments_policies.sql
```

### 5. Storage & Buckets
**Prefix: `YYYYMMDD_` + `storage_` + `description.sql`
- Bucket creation
- Storage policies
- File handling setup

**Ví dụ:**
```
20251206_storage_create_work_proofs_bucket.sql
20251206_storage_work_proofs_policies.sql
```

### 6. Business Logic Updates
**Prefix: `YYYYMMDD_HHMM_` + `type_` + `description.sql`
- Bug fixes
- Logic improvements
- Performance optimizations

**Ví dụ:**
```
20251206_1011_function_fix_shift_time_zone.sql
20251206_1430_fix_tracker_initialization.sql
```

### 7. Data Migration & Cleanup
**Prefix: `YYYYMMDD_HHMM_` + `type_` + `description.sql`
- Data transformations
- Table structure changes
- Data cleanup operations

**Ví dụ:**
```
20251206_1530_migrate_legacy_order_data.sql
20251206_1600_cleanup_unused_columns.sql
```

### 8. Configuration & Features
**Prefix: `YYYYMMDD_HHMM_` + `type_` + `description.sql`
- Feature flags
- System configuration
- Environment settings

**Ví dụ:**
```
20251206_0900_config_enable_new_order_flow.sql
```

---

## Priority Rules (Khi cùng ngày)

### Highest Priority (Nên chạy trước)
1. **`schema_`** - Structure changes
2. **`seed_`** - Data initialization
3. **`function_`** - Functions & Triggers

### Medium Priority
4. **`rls_`** - Security policies
5. **`storage_`** - Storage setup
6. **`migrate_`** - Data migrations

### Lowest Priority (Nên chạy sau)
7. **`fix_`** - Bug fixes
8. **`config_`** - Configuration updates

---

## Thứ tự hiện tại cần sắp xếp lại:

### ✅ Thứ tự hiện tại (ĐÚNG ĐÃ SẮP XẾP):

**Migrations ĐÃ SẮP XẾP:**
```
1. 20251206_1011_function_fix_shift_time_zone.sql (10:11 AM)
2. 20251206_1033_storage_simple_working_policies.sql (09:33 AM)
```

**Migrations Cũ (ĐÃ BỊ XÓA):**
```
- 20251206_exact_copy_staging_policies.sql
- 20251206_safe_update_bucket_public_only.sql
- 20251206_sync_all_buckets_with_staging.sql
- 20251206_fix_storage_metadata_issue.sql
- 20251206_fix_currency_orders_rls_policies_match_staging.sql
- 20251206_fix_work_proofs_bucket_production.sql
- 20251206_emergency_fix_bucket_name_and_policies.sql
- 20251206_fix_sell_order_use_tracker.sql
- 20251206_fixed_exact_copy_staging_policies.sql
- 20251206_diagnose_shift_issue.sql
```

### ✅ Thứ tự triển khai ĐÚNG ĐẨN:
1. **File cũ trước** (theo thời gian thực tế tạo file)
2. **File mới sau** (theo thời gian thực tế tạo file)

**Migration files còn lại:**
```
1. 20251206_1011_function_fix_shift_time_zone.sql (10:11 AM)
2. 20251206_1033_storage_simple_working_policies.sql (10:33 AM)
```

**LUÔN QUAN TRỌNG:** Các migration cũ đã bị xóa, chỉ còn 2 file mới này.

---

## Command để sắp xếp lại migrations:

```bash
# List current migrations
ls -la supabase/migrations/*.sql

# Rename files theo đúng quy tắc (giữ nguyên HHMM thời gian thực tế)
mv 20251206_exact_copy_staging_policies.sql 20251206_0900_rls_exact_copy_staging_policies.sql
mv 20251206_safe_update_bucket_public_only.sql 20251206_1000_storage_safe_update_bucket_public_only.sql
mv 20251206_fix_shift_time_zone.sql 20251206_1011_function_fix_shift_time_zone.sql
# ... và các files khác

# Sort files by name để kiểm tra
ls -la supabase/migrations/20251206_*.sql | sort
```

---

## ⚠️  QUAN TRỌNG:

1. **Không bao giờ change `YYYYMMDD_HHMM`** - ảnh hưởng execution order
2. **Chỉ rename phần type + description** (sau `YYYYMMDD_HHMM_`) để giữ execution order
3. **Test migrations trên staging trước khi chạy production**
4. **Backup database trước khi chạy migrations quan trọng**
5. **Luôn giữ lại `HHMM` từ thời gian thực tế khi tạo file** - quan trọng nhất!

## ✅ Quy tắc final:

**Tên migration format: `YYYYMMDD_HHMM_[type]_[description].sql`**
- **Time Format**: `YYYYMMDD_HHMM` (ngày + giờ phút theo thời gian thực tế tạo file)
- **Type**: schema, seed, function, rls, storage, fix, migrate, config
- **Description**: Rõ ràng, ngắn gọn, snake_case
- **Thứ tự**: Theo type priority + thời gian thực tế tạo file

**⚠️ QUAN TRỌNG:**
- **Giữ nguyên `HHMM` từ thời gian file thực tế** - đảm bảo deployment theo đúng thứ tự
- **Khi file có cùng ngày, thứ tự alphabetical sau `HHMM_` sẽ quyết định
- **KHÔNG BAO GIỜ thay đổi `YYYYMMDD_HHMM`** - sẽ phá vỡ execution order