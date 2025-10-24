-- Reset all pilot warning values and recalculate correctly
-- This will fix the issue where all pilot orders are showing warnings

-- First, disable triggers temporarily to prevent auto-recalculation
DROP TRIGGER IF EXISTS tr_pilot_cycle_work_session_end ON public.work_sessions;
DROP TRIGGER IF EXISTS tr_pilot_cycle_pause_change ON public.order_lines;
DROP TRIGGER IF EXISTS tr_pilot_cycle_first_session ON public.work_sessions;

-- Reset all pilot warning values to 0 for pilot orders
UPDATE order_lines
SET
    pilot_warning_level = 0,
    pilot_is_blocked = FALSE
WHERE id IN (
    SELECT ol.id
    FROM order_lines ol
    JOIN orders o ON o.id = ol.order_id
    JOIN product_variants pv ON ol.variant_id = pv.id
    WHERE pv.display_name = 'Service - Pilot'
    AND o.status NOT IN ('completed', 'cancelled', 'delivered', 'pending_completion')
);

-- Recalculate warnings correctly based on actual pilot_cycle_start_at
-- Only update orders that should actually have warnings
UPDATE order_lines
SET
    pilot_warning_level = subquery.warning_level,
    pilot_is_blocked = subquery.v_hours_online >= 6 * 24
FROM (
    SELECT
        ol.id,
        EXTRACT(EPOCH FROM (NOW() - COALESCE(ol.pilot_cycle_start_at, o.created_at))) / 3600 as v_hours_online,
        CASE
            WHEN EXTRACT(EPOCH FROM (NOW() - COALESCE(ol.pilot_cycle_start_at, o.created_at))) / 3600 >= 6 * 24 THEN 2
            WHEN EXTRACT(EPOCH FROM (NOW() - COALESCE(ol.pilot_cycle_start_at, o.created_at))) / 3600 >= 5 * 24 THEN 1
            ELSE 0
        END as warning_level
    FROM order_lines ol
    JOIN orders o ON o.id = ol.order_id
    JOIN product_variants pv ON ol.variant_id = pv.id
    WHERE pv.display_name = 'Service - Pilot'
    AND o.status NOT IN ('completed', 'cancelled', 'delivered', 'pending_completion')
    AND ol.paused_at IS NULL  -- Only calculate for currently online pilots
    AND EXTRACT(EPOCH FROM (NOW() - COALESCE(ol.pilot_cycle_start_at, o.created_at))) / 3600 >= 5 * 24  -- Only update if >= 5 days
) AS subquery
WHERE order_lines.id = subquery.id;

-- Set NULL for completed orders (no warnings needed)
UPDATE order_lines
SET
    pilot_warning_level = 0,
    pilot_is_blocked = FALSE,
    pilot_cycle_start_at = NULL
WHERE id IN (
    SELECT ol.id
    FROM order_lines ol
    JOIN orders o ON o.id = ol.order_id
    JOIN product_variants pv ON ol.variant_id = pv.id
    WHERE pv.display_name = 'Service - Pilot'
    AND o.status IN ('completed', 'cancelled', 'delivered', 'pending_completion')
);

-- Re-create the triggers (they will be recreated by the main migration)
-- Note: The main migration file will recreate these triggers properly

-- Log the results for verification
SELECT
    o.id as order_id,
    ol.id as order_line_id,
    p.name as customer_name,
    pv.display_name as service_type,
    o.status,
    ol.pilot_warning_level,
    ol.pilot_is_blocked,
    ol.pilot_cycle_start_at,
    o.created_at as order_created_at,
    EXTRACT(EPOCH FROM (NOW() - COALESCE(ol.pilot_cycle_start_at, o.created_at))) / 3600 as hours_online
FROM orders o
JOIN order_lines ol ON o.id = ol.order_id
JOIN parties p ON o.party_id = p.id
JOIN product_variants pv ON ol.variant_id = pv.id
WHERE pv.display_name = 'Service - Pilot'
AND o.status NOT IN ('completed', 'cancelled', 'delivered', 'pending_completion')
ORDER BY hours_online DESC
LIMIT 10;