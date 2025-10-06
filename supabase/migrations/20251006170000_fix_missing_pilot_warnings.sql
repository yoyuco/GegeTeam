-- Fix pilot warnings for orders that should have warnings but were missed
-- Include orders that are not currently online but should still have warnings

-- Update all pilot orders that should have warnings based on their total online time
UPDATE order_lines
SET
    pilot_warning_level = subquery.warning_level,
    pilot_is_blocked = subquery.v_hours_online >= 6 * 24
FROM (
    SELECT
        ol.id,
        -- Calculate online time differently based on paused_at status
        CASE
            WHEN ol.paused_at IS NOT NULL THEN
                -- Currently resting: calculate from cycle_start_at to paused_at
                EXTRACT(EPOCH FROM (ol.paused_at - COALESCE(ol.pilot_cycle_start_at, o.created_at))) / 3600
            ELSE
                -- Currently online: calculate from cycle_start_at to now
                EXTRACT(EPOCH FROM (NOW() - COALESCE(ol.pilot_cycle_start_at, o.created_at))) / 3600
        END as v_hours_online,
        CASE
            WHEN ol.paused_at IS NOT NULL THEN
                CASE
                    WHEN EXTRACT(EPOCH FROM (ol.paused_at - COALESCE(ol.pilot_cycle_start_at, o.created_at))) / 3600 >= 6 * 24 THEN 2
                    WHEN EXTRACT(EPOCH FROM (ol.paused_at - COALESCE(ol.pilot_cycle_start_at, o.created_at))) / 3600 >= 5 * 24 THEN 1
                    ELSE 0
                END
            ELSE
                CASE
                    WHEN EXTRACT(EPOCH FROM (NOW() - COALESCE(ol.pilot_cycle_start_at, o.created_at))) / 3600 >= 6 * 24 THEN 2
                    WHEN EXTRACT(EPOCH FROM (NOW() - COALESCE(ol.pilot_cycle_start_at, o.created_at))) / 3600 >= 5 * 24 THEN 1
                    ELSE 0
                END
        END as warning_level
    FROM order_lines ol
    JOIN orders o ON o.id = ol.order_id
    JOIN product_variants pv ON ol.variant_id = pv.id
    WHERE pv.display_name = 'Service - Pilot'
    AND o.status NOT IN ('completed', 'cancelled', 'delivered', 'pending_completion')
    AND (
        -- Currently online and >= 5 days
        (ol.paused_at IS NULL AND EXTRACT(EPOCH FROM (NOW() - COALESCE(ol.pilot_cycle_start_at, o.created_at))) / 3600 >= 5 * 24)
        OR
        -- Currently resting but was online >= 5 days before pausing
        (ol.paused_at IS NOT NULL AND EXTRACT(EPOCH FROM (ol.paused_at - COALESCE(ol.pilot_cycle_start_at, o.created_at))) / 3600 >= 5 * 24)
    )
) AS subquery
WHERE order_lines.id = subquery.id;

-- Show updated results for verification
SELECT
    o.id as order_id,
    ol.id as order_line_id,
    p.name as customer_name,
    pv.display_name as service_type,
    o.status,
    ol.paused_at as is_paused,
    ol.pilot_warning_level,
    ol.pilot_is_blocked,
    ol.pilot_cycle_start_at,
    o.created_at as order_created_at,
    CASE
        WHEN ol.paused_at IS NOT NULL THEN
            EXTRACT(EPOCH FROM (ol.paused_at - COALESCE(ol.pilot_cycle_start_at, o.created_at))) / 3600
        ELSE
            EXTRACT(EPOCH FROM (NOW() - COALESCE(ol.pilot_cycle_start_at, o.created_at))) / 3600
    END as hours_online,
    CASE
        WHEN ol.paused_at IS NOT NULL THEN
            'Currently resting (calculated to pause time)'
        ELSE
            'Currently online (calculated to now)'
    END as status_description
FROM orders o
JOIN order_lines ol ON o.id = ol.order_id
JOIN parties p ON o.party_id = p.id
JOIN product_variants pv ON ol.variant_id = pv.id
WHERE pv.display_name = 'Service - Pilot'
AND o.status NOT IN ('completed', 'cancelled', 'delivered', 'pending_completion')
AND ol.pilot_warning_level > 0
ORDER BY hours_online DESC;