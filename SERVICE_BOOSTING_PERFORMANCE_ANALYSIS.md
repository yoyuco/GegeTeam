# Performance Analysis - Service Boosting Page

## Hiện tại
Hàm `loadOrders()` trong ServiceBoosting.vue gọi `get_boosting_orders_v3` và mất nhiều thời gian để load.

## Phân tích các vấn đề hiệu năng

### 1. Vấn đề trong Stored Procedure `get_boosting_orders_v3`

#### a. Multiple JOINs thiếu indexes
```sql
FROM public.order_lines ol
JOIN public.orders o ON ol.order_id = o.id
JOIN public.parties p ON o.party_id = p.id
LEFT JOIN public.product_variants pv ON ol.variant_id = pv.id
LEFT JOIN public.channels ch ON o.channel_id = ch.id
LEFT JOIN public.customer_accounts ca ON ol.customer_account_id = ca.id
LEFT JOIN line_items li ON ol.id = li.order_line_id
LEFT JOIN active_farmers af ON ol.id = af.order_line_id
```

#### b. CTE `active_farmers` với STRING_AGG
- Group by và aggregation có thể tốn kém với nhiều work sessions
- Không có index trên `ended_at` cho work sessions

#### c. CTE `line_items` với JSON aggregation
- `jsonb_agg` với nhiều joins có thể nặng
- `jsonb_build_object` trong aggregation làm tăng complexity

#### d. LIKE queries không hiệu quả
```sql
-- Filter by customer name (case-insensitive partial match)
AND (p_customer_name IS NULL OR LOWER(p.name) LIKE LOWER('%' || p_customer_name || '%'))
-- Filter by assignee (case-insensitive partial match)
AND (p_assignee IS NULL OR LOWER(af.farmer_names) LIKE LOWER('%' || p_assignee || '%'))
```

#### e. Sorting phức tạp
```sql
ORDER BY
  status_order,
  assignees_text ASC NULLS LAST,
  delivered_at ASC NULLS FIRST,
  review_id ASC NULLS FIRST,
  pilot_is_blocked ASC NULLS LAST,
  pilot_warning_level ASC NULLS LAST,
  CASE WHEN status = 'completed' THEN updated_at ELSE NULL END DESC NULLS LAST,
  deadline ASC NULLS LAST
```

### 2. Vấn đề ở Frontend

#### a. Polling quá thường
- Background poll mỗi 30 giây
- Debounce reload 500ms
- Realtime subscriptions cho nhiều tables

#### b. Reload sau mỗi action
```javascript
await loadOrders() // Được gọi sau nhiều actions
```

## Đề xuất cải tiến

### 1. Database Optimizations

#### a. Thêm indexes cần thiết
```sql
-- Indexes cho JOINs
CREATE INDEX CONCURRENTLY idx_order_lines_order_id ON order_lines(order_id);
CREATE INDEX CONCURRENTLY idx_orders_party_id ON orders(party_id);
CREATE INDEX CONCURRENTLY idx_order_lines_variant_id ON order_lines(variant_id);
CREATE INDEX CONCURRENTLY idx_orders_channel_id ON orders(channel_id);
CREATE INDEX CONCURRENTLY idx_order_lines_customer_account_id ON order_lines(customer_account_id);

-- Indexes cho filtering
CREATE INDEX CONCURRENTLY idx_orders_game_code_status ON orders(game_code, status);
CREATE INDEX CONCURRENTLY idx_parties_name_gin ON parties USING gin(to_tsvector('simple', name));
CREATE INDEX CONCURRENTLY idx_work_sessions_order_line_id ON work_sessions(order_line_id, ended_at);

-- Composite index cho sorting
CREATE INDEX CONCURRENTLY idx_order_lines_status_delivered ON order_lines(
  CASE WHEN status = 'delivered' THEN 1 ELSE 0 END,
  delivered_at
);
```

#### b. Optimize CTEs
```sql
-- Thay STRING_AGG bằng array_agg đơn giản hơn
WITH active_farmers AS (
  SELECT
    ws.order_line_id,
    array_agg(p.display_name) as farmer_names
  FROM public.work_sessions ws
  JOIN public.profiles p ON ws.farmer_id = p.id
  WHERE ws.ended_at IS NULL
  GROUP BY ws.order_line_id
)
```

#### c. Optimize LIKE queries
```sql
-- Sử dụng ILIKE với pg_trgm index cho partial match
CREATE INDEX CONCURRENTLY idx_parties_name_trgm ON parties USING gin(name gin_trgm_ops);
CREATE INDEX CONCURRENTLY idx_active_farmers_names_trgm ON active_farmers USING gin(farmer_names gin_trgm_ops);
```

#### d. Pagination optimization
```sql
-- Sử dụng cursor-based pagination thay vì OFFSET
-- hoặc thêm index cho ORDER BY columns
```

### 2. Frontend Optimizations

#### a. Reduce polling frequency
```javascript
// Tăng từ 30s lên 60s hoặc 120s
backgroundPollTimer = window.setInterval(() => {
  if (!document.hidden) {
    loadOrders()
  }
}, 60000) // 60s thay vì 30s
```

#### b. Debounce filters
```javascript
// Thêm debounce cho filter changes
const debouncedLoadOrders = debounce(loadOrders, 1000)
```

#### c. Conditional reload
```javascript
// Chỉ reload khi cần thiết
const shouldReload = (prevFilters, newFilters) => {
  // Compare filters và chỉ reload khi khác biệt
}

// Hoặc use latest data từ realtime thay vì reload toàn bộ
```

#### d. Lazy load details
```javascript
// Chỉ load service items khi expand row
async function loadServiceItems(orderLineId) {
  // Load riêng items cho row được mở
}
```

### 3. Advanced Optimizations

#### a. Materialized View
```sql
CREATE MATERIALIZED VIEW mv_boosting_orders_list AS
SELECT
  -- Columns cần thiết cho list view
FROM optimized_query;

-- Refresh periodically
CREATE OR REPLACE FUNCTION refresh_boosting_orders()
RETURNS void AS $$
BEGIN
  REFRESH MATERIALIZED VIEW CONCURRENTLY mv_boosting_orders_list;
END;
$$ LANGUAGE plpgsql;
```

#### b. Cache layer
- Implement Redis cache cho common queries
- Cache filters results

#### c. Batch loading
- Load proof URLs separately
- Preload next page data

## Implementation Priority

### High Priority (Làm ngay)
1. **Thêm indexes** cho các JOINs và filters
2. **Tăng polling interval** từ 30s lên 60s
3. **Add debouncing** cho filter changes

### Medium Priority (Làm sau)
1. Optimize stored procedure queries
2. Implement cursor-based pagination
3. Lazy load detailed data

### Low Priority (Optional)
1. Materialized views
2. Redis caching
3. Full rewrite with GraphQL

## Migration cho indexes
```sql
-- File: 20251213_add_indexes_for_service_boosting.sql

-- Performance indexes for Service Boosting page
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_order_lines_order_id ON order_lines(order_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_orders_party_id ON orders(party_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_orders_game_code_status ON orders(game_code, status) WHERE status <> 'draft';
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_parties_name_gin ON parties USING gin(to_tsvector('simple', name));
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_work_sessions_order_line_id ON work_sessions(order_line_id, ended_at) WHERE ended_at IS NULL;

-- Composite index for sorting
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_order_lines_sorting ON order_lines(
  CASE
    WHEN status = 'new' THEN 1
    WHEN status = 'in_progress' THEN 2
    WHEN status = 'pending_pilot' THEN 3
    WHEN status = 'paused_selfplay' THEN 4
    WHEN status = 'customer_playing' THEN 5
    WHEN status = 'pending_completion' THEN 6
    WHEN status = 'completed' THEN 7
    WHEN status = 'cancelled' THEN 8
  END,
  CASE WHEN delivered_at IS NOT NULL THEN 1 ELSE 0 END,
  delivered_at
);

-- Trigram indexes for LIKE queries
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_parties_name_trgm ON parties USING gin(name gin_trgm_ops);
```

## Testing
```sql
-- Test query performance
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM get_boosting_orders_v3(
  p_limit := 50,
  p_offset := 0,
  p_channels := NULL,
  p_statuses := ARRAY['new', 'in_progress'],
  p_service_types := NULL,
  p_package_types := NULL,
  p_customer_name := NULL,
  p_assignee := NULL,
  p_delivery_status := NULL,
  p_review_status := NULL
);
```