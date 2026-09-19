-- ⚠️ CHƯA CHẠY. Chỉ chạy SAU KHI frontend đã deploy lên production.
--
-- Sau migration 20260919_0040, get_boosting_orders_v4 không còn dùng
-- mv_active_farmers nữa. Nhưng bản frontend ĐANG CHẠY trên production vẫn gọi
-- refresh_active_farmers() khoảng 356 lần/ngày. Xoá hàm đó bây giờ sẽ khiến các
-- lời gọi kia trả về 404.
--
-- (Frontend hiện bắt lỗi bằng try/catch + console.warn nên giao diện không gãy,
-- nhưng vẫn là 356 lỗi rác mỗi ngày — không đáng.)
--
-- TRÌNH TỰ ĐÚNG:
--   1. Merge PR gỡ 2 lời gọi refresh_active_farmers ở ServiceBoosting.vue
--   2. Deploy develop -> main, xác nhận production đã chạy bản mới
--   3. Kiểm tra log không còn lời gọi nào tới /rest/v1/rpc/refresh_active_farmers
--   4. Mới chạy file này
--
-- Câu kiểm tra ở bước 3 (chạy bằng công cụ log của Supabase):
--   select count(*) from logs
--   where source = 'edge_logs'
--     and log_attributes['request.path'] = '/rest/v1/rpc/refresh_active_farmers'
--     and timestamp > now() - interval 24 hour;
--   -- phải bằng 0

DROP FUNCTION IF EXISTS public.refresh_active_farmers();
DROP MATERIALIZED VIEW IF EXISTS public.mv_active_farmers;
