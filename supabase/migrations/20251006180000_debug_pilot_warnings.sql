-- Debug query to check actual pilot warning data
-- This will help identify if the issue is in database or frontend

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
    ol.paused_at,
    -- Calculate online hours as database would calculate
    CASE
        WHEN ol.paused_at IS NOT NULL THEN
            EXTRACT(EPOCH FROM (ol.paused_at - COALESCE(ol.pilot_cycle_start_at, o.created_at))) / 3600
        ELSE
            EXTRACT(EPOCH FROM (NOW() - COALESCE(ol.pilot_cycle_start_at, o.created_at))) / 3600
    END as calculated_hours_online,
    -- Expected warning level based on calculation
    CASE
        WHEN EXTRACT(EPOCH FROM (
            CASE
                WHEN ol.paused_at IS NOT NULL THEN ol.paused_at - COALESCE(ol.pilot_cycle_start_at, o.created_at)
                ELSE NOW() - COALESCE(ol.pilot_cycle_start_at, o.created_at)
            END
        )) / 3600 >= 6 * 24 THEN 2
        WHEN EXTRACT(EPOCH FROM (
            CASE
                WHEN ol.paused_at IS NOT NULL THEN ol.paused_at - COALESCE(ol.pilot_cycle_start_at, o.created_at)
                ELSE NOW() - COALESCE(ol.pilot_cycle_start_at, o.created_at)
            END
        )) / 3600 >= 5 * 24 THEN 1
        ELSE 0
    END as expected_warning_level
FROM orders o
JOIN order_lines ol ON o.id = ol.order_id
JOIN parties p ON o.party_id = p.id
JOIN product_variants pv ON ol.variant_id = pv.id
WHERE pv.display_name = 'Service - Pilot'
AND o.status NOT IN ('completed', 'cancelled', 'delivered', 'pending_completion')
AND p.name IN ('unknownnyx', 'anongaming')
ORDER BY calculated_hours_online DESC;

-- Test the get_boosting_orders_v3 function directly
SELECT
    order_id,
    id,
    customer_name,
    service_type,
    status,
    pilot_warning_level,
    pilot_is_blocked,
    pilot_cycle_start_at,
    paused_at
FROM public.get_boosting_orders_v3(50, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
WHERE service_type = 'Service - Pilot'
AND customer_name IN ('unknownnyx', 'anongaming')
ORDER BY pilot_warning_level DESC;