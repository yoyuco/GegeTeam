-- Xoá 11 index trùng lặp hoàn toàn (cùng bảng, cùng cột, cùng điều kiện WHERE).
--
-- Đã áp dụng trực tiếp lên production susuoambmzdmcygovkea ngày 2026-09-19.
-- File này ghi lại để repo không lệch với database thật; chạy lại an toàn nhờ IF EXISTS.
--
-- Nguyên tắc chọn cái giữ lại:
--   - Cặp idx_* / ix_*  -> giữ idx_* (do 20251213_add_indexes_for_service_boosting_performance.sql
--     tạo ra và đang được dùng thật), bỏ ix_* (sinh ra từ schema dump cũ).
--   - Cặp index thường trùng với index của UNIQUE constraint -> bỏ index thường,
--     giữ index của constraint (không thể xoá mà không xoá constraint).
--
-- Dùng CONCURRENTLY để không giữ ACCESS EXCLUSIVE lock trên bảng đang phục vụ traffic.
-- Lưu ý: DROP INDEX CONCURRENTLY không chạy được trong transaction block.

-- Trùng với index của UNIQUE constraint
DROP INDEX CONCURRENTLY IF EXISTS public.idx_assignment_trackers_key;   -- ~ unique_assignment_key
DROP INDEX CONCURRENTLY IF EXISTS public.idx_business_processes_code;   -- ~ business_processes_code_key
DROP INDEX CONCURRENTLY IF EXISTS public.idx_fees_code;                 -- ~ fees_code_key
DROP INDEX CONCURRENTLY IF EXISTS public.idx_parties_type_name;         -- ~ parties_type_name_key

-- Hai index thường trùng nhau
DROP INDEX CONCURRENTLY IF EXISTS public.idx_exchange_rate_log_success;      -- ~ idx_exchange_rate_api_log_success
DROP INDEX CONCURRENTLY IF EXISTS public.idx_work_sessions_order_line_id;    -- ~ idx_work_sessions_order_ended

-- Cặp idx_* / ix_* trên các bảng nóng
DROP INDEX CONCURRENTLY IF EXISTS public.ix_order_lines_customer_account_id;    -- ~ idx_order_lines_customer_account_id
DROP INDEX CONCURRENTLY IF EXISTS public.ix_order_lines_order_id;               -- ~ idx_order_lines_order_id
DROP INDEX CONCURRENTLY IF EXISTS public.ix_order_service_items_order_line_id;  -- ~ idx_order_service_items_order_line_id
DROP INDEX CONCURRENTLY IF EXISTS public.ix_orders_channel_id;                  -- ~ idx_orders_channel_id
DROP INDEX CONCURRENTLY IF EXISTS public.ix_orders_party_id;                    -- ~ idx_orders_party_id
