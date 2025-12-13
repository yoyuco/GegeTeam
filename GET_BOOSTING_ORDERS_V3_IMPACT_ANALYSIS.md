# Impact Analysis - Modifying get_boosting_orders_v3

## Hiện tại

### 1. Database Status
- **Staging chưa có column `status_order`** (confirm với query)
- **Stored procedure tính `status_order` runtime** với CASE statement

### 2. Frontend Usage
- **ServiceBoosting.vue** gọi `get_boosting_orders_v3`
- **Frontend KHÔNG sử dụng `status_order`**
- Map dữ liệu: `return { ...row, line_id: row.id, service_type: serviceType }`

### 3. Stored Procedure Analysis
```sql
-- Hiện tại trong get_boosting_orders_v3:
CASE o.status
  WHEN 'new' THEN 1
  WHEN 'in_progress' THEN 2
  WHEN 'pending_pilot' THEN 3
  -- ...
END as status_order

ORDER BY
  status_order,  -- Được tính runtime
  ...
```

## Ảnh hưởng nếu sửa stored procedure

### Scenario 1: Sử dụng status_order column đã thêm
**✅ KHÔNG ảnh hưởng**
- Procedure trả về `status_order` từ column (không tính runtime)
- Frontend vẫn nhận được `status_order` (nếu có trong SELECT)
- Frontend bỏ qua column này (không sử dụng)

**Ưu điểm:**
- Tốc độ query nhanh hơn (không tính CASE)
- Index có thể được sử dụng cho ORDER BY

**Nhược điểm:**
- Cần chạy migration thêm column trước
- Migration tốn thời gian với large table

### Scenario 2: Optimized CASE statement
**✅ KHÔNG ảnh hưởng**
- Giữ nguyên logic CASE nhưng optimize
- Frontend không cần thay đổi

**Cách implement:**
```sql
-- Thay thế CASE phức tạp bằng simple lookup
-- Hoặc pre-compute values
```

## Recommendation

### Option 1: Sử dụng status_order column (Recommend)
1. Chạy migration `20251213_add_indexes_for_service_boosting_performance.sql`
2. Update stored procedure để sử dụng column:
```sql
-- Thay thế CASE statement
ol.status_order as status_order,
```
3. Cập nhật ORDER BY:
```sql
ORDER BY
  ol.status_order,  -- Sử dụng column
  ...
```

### Option 2: Keep current approach but optimize
Không sửa stored procedure, chỉ add indexes khác:
- Bỏ phần trigger và column `status_order`
- Giữ nguyên stored procedure
- Thêm các indexes khác cho performance

## Frontend Compatibility Check

### Cần kiểm tra:
1. **API Response** - Có field nào bị breaking change?
2. **Data Binding** - UI có phụ thuộc vào `status_order`?
3. **Sorting Logic** - Frontend có custom sort không?

### Xác nhận:
- ✅ Frontend map toàn bộ row: `{ ...row, line_id: row.id }`
- ✅ Không có custom sử dụng `status_order`
- ✅ Sorting được xử lý ở database level

## Migration Plan (if using Option 1)

### Step 1: Add column and indexes (Safe)
```sql
-- Migration 1: Add indexes only (không cần column)
CREATE INDEX CONCURRENTLY idx_order_lines_order_id ON order_lines(order_id);
CREATE INDEX CONCURRENTLY idx_orders_party_id ON orders(party_id);
-- ... các indexes khác
```

### Step 2: Test Performance
```sql
-- Test query performance trước khi thêm column
EXPLAIN ANALYZE SELECT * FROM get_boosting_orders_v3(...)
```

### Step 3: Add status_order (Optional)
```sql
-- Chỉ add nếu performance vẫn chậm
ALTER TABLE order_lines ADD COLUMN status_order INTEGER;
-- ... trigger và update logic
```

## Conclusion

**Sửa `get_boosting_orders_v3` sẽ KHÔNG ảnh hưởng FE hiện tại** vì:
1. Frontend không sử dụng `status_order`
2. Procedure trả về toàn bộ columns, FE chọn cái cần thiết
3. Thay đổi cách tính `status_order` (runtime vs column) không affect API response

**Recommendation:**
- Chạy migration indexes trước để cải thiện performance
- Nếu vẫn chậm, mới tính đến việc thêm `status_order` column