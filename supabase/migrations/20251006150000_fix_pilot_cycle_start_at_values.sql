-- Fix pilot_cycle_start_at values that were incorrectly set by previous triggers
-- Update existing pilot orders to use orders.created_at instead of the wrong date

UPDATE order_lines ol
SET pilot_cycle_start_at = o.created_at
FROM orders o
WHERE o.id = ol.order_id
AND ol.pilot_cycle_start_at = '2025-09-25 05:31:58.013301+00'::timestamp with time zone
AND EXISTS (
    SELECT 1 FROM product_variants pv
    WHERE pv.id = ol.variant_id
    AND pv.display_name = 'Service - Pilot'
);

-- For safety, also update any NULL pilot_cycle_start_at for active pilot orders
UPDATE order_lines ol
SET pilot_cycle_start_at = o.created_at
FROM orders o
WHERE o.id = ol.order_id
AND ol.pilot_cycle_start_at IS NULL
AND o.status NOT IN ('completed', 'cancelled', 'delivered', 'pending_completion')
AND EXISTS (
    SELECT 1 FROM product_variants pv
    WHERE pv.id = ol.variant_id
    AND pv.display_name = 'Service - Pilot'
);

-- Set NULL for completed/cancelled pilot orders (no cycle needed)
UPDATE order_lines ol
SET pilot_cycle_start_at = NULL
FROM orders o
WHERE o.id = ol.order_id
AND o.status IN ('completed', 'cancelled', 'delivered', 'pending_completion')
AND EXISTS (
    SELECT 1 FROM product_variants pv
    WHERE pv.id = ol.variant_id
    AND pv.display_name = 'Service - Pilot'
);

COMMENT ON COLUMN order_lines.pilot_cycle_start_at IS 'Thời gian bắt đầu chu kỳ online hiện tại. Reset khi đủ điều kiện nghỉ. Đã fix từ created_at của orders.';