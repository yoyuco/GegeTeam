# Production Deployment Guide - December 2025

## ✅ Migrations đã áp dụng vào staging thành công

### Core Fixes (BẮT BUỘC phải chạy cho Production)

1. **`20251213_fix_inventory_check_logic.sql`**
   - Fix inventory pool selection logic
   - Chỉ kiểm tra quantity, không kiểm tra reserved_quantity
   - Fix assignment logic: giảm quantity + tăng reserved_quantity

2. **`20251207_1530_fix_sell_order_delivery_filename.sql`**
   - Fix delivery processing errors
   - Giảm cả quantity và reserved_quantity khi delivery

3. **`20251212_update_order_completion_functions_from_staging.sql`**
   - Update 5 hàm completion từ staging
   - Bao gồm complete_sell_order_v2 và các hàm liên quan

4. **`20251213_update_cancel_functions_with_inventory_rollback.sql`**
   - Update cancel functions với đúng logic inventory
   - Khi cancel: tăng quantity + giảm reserved_quantity

5. **`20251213_add_indexes_for_service_boosting_performance.sql`** 🆕
   - Add performance indexes cho Service Boosting page
   - Không thay đổi cấu trúc bảng (chỉ thêm indexes)
   - Tối ưu hóa JOIN, filtering và sorting queries

## ❌ Đã XÓA (Trùng lặp hoặc không cần thiết)

### Debug/Test Files
- `20251213_debug_assignment.sql`
- `20251213_check_shift_time.sql`
- `20251213_check_assigned_order.sql`
- `20251213_check_currency_transactions.sql`
- `20251213_assign_all_pending.sql`

### Files trùng lặp hoặc đã được cover
- `20251212_fix_complete_sell_order_bug_in_staging.sql`
- `20251213_fix_assignment_inventory_logic.sql`
- `20251213_add_cancel_order_function.sql`
- `20251213_update_existing_cancel_functions.sql`
- `20251213_apply_all_fixes_to_staging.sql`
- `20251213_sell_order_assignment_functions.sql`
- `20251213_complete_staging_functions.sql`
- `20251213_sell_order_fix_complete.sql`
- `20251211_deploy_staging_sell_order_functions.sql`

## ✅ Functions đã verify tồn tại trong staging

### Core Functions
- `assign_sell_order_with_inventory_v2` - Đã fix với đúng inventory logic
- `process_sell_order_delivery` - Đã fix giảm cả quantity và reserved_quantity
- `complete_sell_order_with_profit_calculation` - Có 2 phiên bản
- `complete_sale_order_v2` - Hoạt động tốt
- `cancel_sell_order_with_inventory_rollback` - Đã fix với rollback logic

### Helper Functions
- `get_inventory_pool_with_currency_rotation` - Chỉ check quantity
- `get_inventory_pool_with_account_first_rotation` - Đã fix
- `get_employee_for_account_in_shift` - Đã fix timezone logic
- `get_employee_fallback_for_game_code` - Hoạt động tốt
- `process_delivery_confirmation_v2` - Đã tồn tại
- `get_delivery_summary` - Đã tồn tại

## Thứ tự chạy cho Production

### Bước 1: Backup
```bash
pg_dump -h db.susuoambmzdmcygovkea.supabase.co -U postgres -d postgres > production_backup_$(date +%Y%m%d_%H%M%S).sql
```

### Bước 2: Chạy Core Fixes (theo thứ tự)
```bash
# 1. Fix inventory logic
psql -h db.susuoambmzdmcygovkea.supabase.co -U postgres -d postgres < 20251213_fix_inventory_check_logic.sql

# 2. Fix delivery processing
psql -h db.susuoambmzdmcygovkea.supabase.co -U postgres -d postgres < 20251207_1530_fix_sell_order_delivery_filename.sql

# 3. Update cancel functions
psql -h db.susuoambmzdmcygovkea.supabase.co -U postgres -d postgres < 20251213_update_cancel_functions_with_inventory_rollback.sql

# 4. Update completion functions
psql -h db.susuoambmzdmcygovkea.supabase.co -U postgres -d postgres < 20251212_update_order_completion_functions_from_staging.sql
```

### Bước 3: Kiểm tra sau khi deploy
```sql
-- Kiểm tra functions đã tồn tại
SELECT proname FROM pg_proc
WHERE proname IN (
    'assign_sell_order_with_inventory_v2',
    'process_sell_order_delivery',
    'complete_sell_order_with_profit_calculation',
    'cancel_sell_order_with_inventory_rollback'
);

-- Test assignment flow
SELECT * FROM assign_sell_order_with_inventory_v2(
    'TEST_ORDER_ID'::UUID,
    'TEST_USER_ID'::UUID,
    'currency_first'
);
```

## Logic Inventory cuối cùng
| Action | Quantity | Reserved | Available |
|--------|----------|----------|-----------|
| Initial | 1000 | 0 | 1000 |
| Assign 100 | 900 | 100 | 800 |
| Deliver 100 | 800 | 0 | 800 |
| Cancel 100 | 900 | 0 | 900 |

## Contact
Nếu có vấn đề trong quá trình deploy, liên hệ team DBA.