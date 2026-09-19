# Database Schema — GegeTeam

> **Project: PRODUCTION `susuoambmzdmcygovkea`**
> Trạng thái ghi nhận: 2026-09-19. Đối chiếu trực tiếp từ database thật, không phải từ file migration.

> ⚠️ Bản trước của tài liệu này mô tả project **staging** `gpmllykxombndvseriph` và đã lỗi thời 9 tháng:
> ghi 28 bảng / 36 hàm trong khi thực tế là 40 bảng / 215 hàm, bỏ sót toàn bộ mảng
> currency, inventory và ca kíp. Nếu bạn từng đọc bản cũ, hãy quên nó đi.

---

## Tổng quan

| Hạng mục | Số lượng |
|---|---|
| Bảng (`BASE TABLE`) | **40** |
| Materialized view | 1 (`mv_active_farmers`, đang trong quá trình loại bỏ) |
| Hàm / thủ tục | **220 chữ ký** (215 tên, 5 hàm có overload) |
| Enum | **7** |
| Extension | **10** |

Mọi bảng đều đã bật RLS.

---

## Bảng

Số dòng là ước lượng của planner (`pg_class.reltuples`); `-1` nghĩa là chưa từng được ANALYZE.

| Bảng | Cột | ~Số dòng | Policy | Nhóm |
|---|---:|---:|---:|---|
| `orders` | 15 | 7.652 | 7 | Đơn hàng dịch vụ |
| `order_lines` | 15 | 8.119 | 7 | Đơn hàng dịch vụ |
| `order_service_items` | 6 | 9.107 | 7 | Đơn hàng dịch vụ |
| `order_reviews` | 7 | 23 | 5 | Đơn hàng dịch vụ |
| `work_sessions` | 11 | 12.066 | 9 | Vận hành |
| `work_session_outputs` | 10 | 9.849 | 4 | Vận hành |
| `service_reports` | 13 | 0 | 4 | Vận hành |
| `assignment_trackers` | 17 | 51 | 1 | Vận hành |
| `shift_assignments` | 10 | 19 | 1 | Ca kíp |
| `work_shifts` | 8 | 2 | 4 | Ca kíp |
| `employee_channels` | 6 | -1 | 1 | Ca kíp |
| `currency_orders` | **46** | 972 | 3 | Currency |
| `currency_transactions` | 16 | 1.036 | 3 | Currency |
| `currencies` | 10 | -1 | 6 | Currency |
| `inventory_pools` | 12 | 45 | 4 | Currency |
| `game_accounts` | 8 | -1 | 1 | Currency |
| `exchange_rates` | 12 | **39.744** | 2 | Tỷ giá |
| `exchange_rate_api_log` | 8 | 10.936 | 2 | Tỷ giá |
| `exchange_rate_config` | 14 | 1 | 1 | Tỷ giá |
| `exchange_rate_trigger` | 3 | -1 | 3 | Tỷ giá |
| `business_processes` | 11 | -1 | 2 | Phí & quy trình |
| `fees` | 10 | -1 | 2 | Phí & quy trình |
| `process_fees_map` | 3 | -1 | 1 | Phí & quy trình |
| `parties` | 9 | 4.668 | 5 | Khách hàng |
| `customer_accounts` | 11 | 5.327 | 4 | Khách hàng |
| `products` | 3 | -1 | 4 | Danh mục |
| `product_variants` | 5 | 4 | 5 | Danh mục |
| `product_variant_attributes` | 2 | -1 | 4 | Danh mục |
| `attributes` | 6 | 469 | 6 | Danh mục |
| `attribute_relationships` | 2 | 407 | 5 | Danh mục |
| `channels` | 11 | 10 | 4 | Danh mục |
| `level_exp` | 2 | 300 | 1 | Danh mục |
| `profiles` | 8 | 30 | 5 | Phân quyền |
| `roles` | 3 | -1 | 4 | Phân quyền |
| `permissions` | 5 | 37 | 2 | Phân quyền |
| `role_permissions` | 2 | 144 | 4 | Phân quyền |
| `user_role_assignments` | 5 | 48 | 4 | Phân quyền |
| `profile_status_logs` | 7 | -1 | 4 | Phân quyền |
| `audit_logs` | 13 | -1 | 4 | Hệ thống |
| `debug_log` | 3 | -1 | 1 | Hệ thống |

---

## Enum

| Tên | Giá trị |
|---|---|
| `account_type_enum` | `btag`, `login` |
| `app_role` | `admin`, `mod`, `manager`, `trader_manager`, `farmer_manager`, `leader`, `trader_leader`, `farmer_leader`, `trader1`, `trader2`, `farmer`, `trial`, `accountant` |
| `order_side_enum` | `BUY`, `SELL` |
| `product_type_enum` | `SERVICE`, `ITEM`, `CURRENCY` |
| `currency_order_type_enum` | `PURCHASE`, `SALE`, `EXCHANGE` |
| `currency_order_status_enum` | `draft`, `pending`, `assigned`, `preparing`, `ready`, `delivering`, `delivered`, `completed`, `cancelled`, `failed` |
| `currency_exchange_type_enum` | `none`, `items`, `service`, `farmer`, `currency` |

---

## Extension

`btree_gin` · `pg_cron` 1.6.4 · `pg_net` 0.19.5 · `pg_stat_statements` 1.11 · `pg_trgm` 1.6 ·
`pgcrypto` · `pgsodium` 3.1.8 · `plpgsql` · `supabase_vault` 0.3.1 · `uuid-ossp`

`pg_graphql` **không** được cài (bản tài liệu cũ ghi sai).

### Cron job

| Tên | Lịch | Chạy dưới role | Lệnh |
|---|---|---|---|
| `half-hourly-pilot-reset` | `*/30 * * * *` | `postgres` | `SELECT public.reset_eligible_pilot_cycles()` |
| `exchange-rate-update-60min` | `0 * * * *` | `postgres` | `SELECT simple_exchange_rate_cron()` |

### Edge function

`fetch-exchange-rates` (`verify_jwt = true`)

---

## Hàm

220 chữ ký, quá nhiều để liệt kê hết ở đây. Lấy danh sách hiện thời bằng:

```sql
SELECT p.oid::regprocedure AS chu_ky,
       p.prosecdef        AS security_definer,
       has_function_privilege('anon', p.oid, 'EXECUTE')          AS anon_goi_duoc,
       has_function_privilege('authenticated', p.oid, 'EXECUTE') AS auth_goi_duoc
FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE n.nspname = 'public' AND p.prokind IN ('f','p')
ORDER BY p.proname;
```

Phân bố:

| | Số lượng |
|---|---:|
| `SECURITY DEFINER` | 206 |
| `SECURITY INVOKER` | 14 |
| Hàm trigger (không gọi qua API) | 21 |
| `anon` gọi được | 159 |
| `authenticated` gọi được | 220 |

Quy ước đặt tên hay gặp: hậu tố `_v1`/`_v2`/`_v3`/`_v4` là phiên bản (bản cũ thường vẫn còn
trong database dù không ai gọi nữa — `get_boosting_orders_v3` là ví dụ); hậu tố `_direct`
là các hàm CRUD cho màn hình quản trị; tiền tố `tr_` và `handle_` là hàm trigger.

---

## Vấn đề đã biết (tính đến 2026-09-19)

Ghi lại để người đọc sau không tưởng nhầm schema này đã sạch.

### 🔴 Policy "Block" không chặn được gì

Trên `orders`, `order_lines`, `order_service_items`, `work_sessions` và `currencies` có các
policy tên `Block updates` / `Block inserts` / `Block deletes` với điều kiện `false`, nhưng
**song song tồn tại policy permissive khác với điều kiện `true`**:

```
Block updates                PERMISSIVE  authenticated  USING false
authenticated_update_orders  PERMISSIVE  authenticated  USING true
```

Policy permissive được OR với nhau, `false OR true = true`, nên lệnh chặn vô tác dụng. Bất kỳ
tài khoản đã đăng nhập nào cũng UPDATE thẳng được các bảng này qua REST API, bỏ qua toàn bộ
các hàm RPC. Riêng `work_sessions` hở cả INSERT, UPDATE lẫn DELETE.

Trên `currencies` còn một biến thể khác: policy `Allow service role full access` dùng
`pg_has_role(SESSION_USER, 'service_role', 'MEMBER')`. PostgREST luôn kết nối bằng role
`authenticator`, mà `authenticator` **là thành viên của `service_role`**, nên biểu thức này
luôn đúng với mọi request — kể cả `anon`.

### 🟡 `authenticated` gọi được toàn bộ 220 hàm

Kể cả `add_vault_secret` và các hàm `delete_*_direct`. Một tài khoản vai trò `trial` vẫn gọi
được. Ngày 2026-09-19 đã chặn `anon` khỏi 61 hàm vừa ghi dữ liệu vừa không kiểm tra quyền
(xem `migrations/20260919_0030_*`), nhưng `authenticated` thì chưa. Sửa triệt để là thêm
`has_permission(...)` vào trong từng hàm.

### 🟡 Frontend gọi 3 bảng không tồn tại

`customers`, `employee_shift_assignments`, `shift_account_access` không có trong database.
Các lời gọi `.from()` tới chúng ở `src/pages/Customers.vue` và `src/utils/assignmentHelper.ts`
chắc chắn luôn lỗi.

### 🟡 Nhiều bảng chưa từng được ANALYZE

Các bảng có `~Số dòng = -1` ở bảng trên. Ngày 2026-09-19 đã ANALYZE 10 bảng nóng sau khi phát
hiện planner ước lượng sai tới 18 lần gây timeout 8s. Nên đặt lịch ANALYZE định kỳ qua pg_cron.

---

## Quy ước

1. **Ghi dữ liệu phải qua hàm RPC**, không INSERT/UPDATE thẳng — nhưng xem mục 🔴 ở trên,
   hiện tại quy ước này *không* được RLS cưỡng chế.
2. `audit_logs` được ghi tự động bằng trigger.
3. Các thao tác có thể lặp dùng khoá idempotency (ví dụ `finish_work_session_idem_v1`).
4. Thêm tính năng mới: viết migration trong `supabase/migrations/`, tạo hàm RPC, thêm RLS
   policy, **cập nhật lại file này**, rồi deploy theo quy trình trong `CONTRIBUTING.md`.

---

## Cách tạo lại tài liệu này

Đừng chép tay. Các truy vấn dùng để dựng file này:

```sql
-- Bảng
SELECT c.relname,
       (SELECT count(*) FROM information_schema.columns ic
         WHERE ic.table_schema='public' AND ic.table_name=c.relname) AS so_cot,
       c.reltuples::bigint AS uoc_so_dong, c.relrowsecurity,
       (SELECT count(*) FROM pg_policies pp
         WHERE pp.schemaname='public' AND pp.tablename=c.relname) AS so_policy
FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
WHERE n.nspname='public' AND c.relkind='r' ORDER BY c.relname;

-- Enum
SELECT t.typname, string_agg(e.enumlabel, ', ' ORDER BY e.enumsortorder)
FROM pg_type t JOIN pg_enum e ON e.enumtypid=t.oid
JOIN pg_namespace n ON n.oid=t.typnamespace
WHERE n.nspname='public' GROUP BY t.typname ORDER BY t.typname;

-- Extension / cron
SELECT extname, extversion FROM pg_extension ORDER BY extname;
SELECT jobid, jobname, schedule, username, command FROM cron.job ORDER BY jobid;
```
