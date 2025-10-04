# Archived Migrations

## Ngày archive: 2025-10-04

Các migrations này đã được archive và thay thế bằng baseline migration `20251004011427_remote_schema.sql`.

## Lý do archive:

1. **Simplify migration history** - Giảm số lượng migrations từ 9 files xuống 1 baseline
2. **Production và Staging đã sync** - Cả 2 databases đã có schema giống nhau
3. **Dễ maintain** - Baseline chứa toàn bộ schema hiện tại, dễ review và debug

## Migrations đã archive:

1. `20251002062342_remote_schema.sql` - Initial schema snapshot
2. `20251002090000_fix_cancel_session_selfplay.sql` - Fix cancel session cho selfplay
3. `20251003080000_cleanup_duplicate_functions.sql` - Cleanup duplicate functions
4. `20251003120000_add_filter_options_function.sql` - Add filter options function
5. `20251003170000_fix_deadline_pause_logic.sql` - **QUAN TRỌNG**: Fix deadline pause logic (Selfplay only)
6. `20251003180000_fix_rls_policies_production.sql` - Fix RLS policies
7. `20251003181000_fix_attribute_relationships_rls.sql` - Fix attribute_relationships RLS
8. `20251003182000_fix_orders_tables_rls.sql` - Fix orders tables RLS
9. `20251003184000_sync_production_with_staging.sql` - Sync production với staging

## Lưu ý:

- **Tất cả các thay đổi** trong 9 migrations trên đã được bao gồm trong baseline `20251004011427_remote_schema.sql`
- Nếu cần tham khảo logic cũ, xem các files trong folder này
- **Đừng xóa folder này** - giữ lại để tham khảo và audit trail

## Migration quan trọng nhất:

**20251003170000_fix_deadline_pause_logic.sql** - Chứa logic deadline pause cho Selfplay:
- `complete_order_line_v1`: SET paused_at khi in_progress
- `cancel_order_line_v1`: SET paused_at khi in_progress
- `tr_check_all_items_completed_v1`: SET paused_at cho Selfplay only khi pending_completion
