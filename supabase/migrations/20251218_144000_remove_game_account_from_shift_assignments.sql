-- Migration: Remove game_account_id from shift_assignments and update all functions
-- Description: Remove game_account_id column from shift_assignments table and update all dependent functions
-- Created: 2025-12-18 14:40:00
-- Author: Claude Code

-- Step 1: Backup current shift assignments
CREATE TABLE shift_assignments_backup_20251218 AS
SELECT * FROM shift_assignments;

-- Step 2: Remove game_account_id column and its foreign key constraint
ALTER TABLE shift_assignments
DROP CONSTRAINT IF EXISTS account_shift_assignments_game_account_id_fkey,
DROP COLUMN IF EXISTS game_account_id;

-- Step 3: Add comment for documentation
COMMENT ON TABLE shift_assignments IS 'Employee shift assignments by channel, currency, and shift';

-- Step 4: Update functions to remove game_account_id dependencies

-- Function 1: assign_purchase_order - simplified without game_account lookups
CREATE OR REPLACE FUNCTION assign_purchase_order(p_purchase_order_id UUID)
RETURNS TABLE(success BOOLEAN, message TEXT, employee_id UUID, account_id UUID, server_code TEXT) AS $$
DECLARE
    v_order RECORD;
    v_channel RECORD;
    v_employee_shift RECORD;
    v_current_time TIMESTAMPTZ := NOW();
    v_gmt7_time TIMESTAMPTZ := v_current_time;
    v_currency_code TEXT;
    v_shift_id UUID;
    v_next_employee RECORD;
    v_selected_employee_id UUID;
    v_tracker_id UUID;
    v_current_employee_count INTEGER;
    v_group_key TEXT;
    v_tracker_refreshed BOOLEAN := FALSE;
BEGIN
    -- Get order details with strict validation
    SELECT co.*, c.code as channel_code, c.direction
    INTO v_order
    FROM currency_orders co
    JOIN channels c ON co.channel_id = c.id
    WHERE co.id = p_purchase_order_id
      AND co.status = 'pending'
      AND co.order_type = 'PURCHASE';

    IF NOT FOUND THEN
        RETURN QUERY SELECT false, 'Order not found, not in pending status, or not a purchase order', NULL::UUID, NULL::UUID, NULL::TEXT;
        RETURN;
    END IF;

    IF v_order.direction NOT IN ('BUY', 'BOTH') THEN
        RETURN QUERY SELECT false, format('Channel %s does not support purchase operations', v_order.channel_code), NULL::UUID, NULL::UUID, NULL::TEXT;
        RETURN;
    END IF;

    v_currency_code := COALESCE(v_order.cost_currency_code, 'VND');
    IF v_order.channel_code = 'WeChat' AND v_currency_code = 'VND' THEN
        v_currency_code := 'CNY';
    END IF;

    -- Find current shift
    SELECT id INTO v_shift_id
    FROM work_shifts ws
    WHERE ws.is_active = true
      AND (
        (ws.start_time <= ws.end_time AND
         v_gmt7_time::time >= ws.start_time AND
         v_gmt7_time::time <= ws.end_time)
        OR
        (ws.start_time > ws.end_time AND
         (v_gmt7_time::time >= ws.start_time OR
          v_gmt7_time::time <= ws.end_time))
      )
    LIMIT 1;

    IF v_shift_id IS NULL THEN
        RETURN QUERY SELECT false,
            format('No active shift found at GMT+7 time: %s', v_gmt7_time::time),
            NULL::UUID, NULL::UUID, NULL::TEXT;
        RETURN;
    END IF;

    -- Get next employee using round-robin assignment
    SELECT * INTO v_next_employee
    FROM get_next_employee_round_robin(
        v_order.channel_id,
        v_currency_code,
        v_shift_id,
        'PURCHASE',
        v_order.game_code,
        v_order.server_attribute_code
    );

    IF v_next_employee.employee_id IS NULL THEN
        RETURN QUERY SELECT false,
            format('No employees available for assignment (Channel: %s, Currency: %s, Game: %s)',
                   v_order.channel_code, v_currency_code, v_order.game_code),
            NULL::UUID, NULL::UUID, NULL::TEXT;
        RETURN;
    END IF;

    -- Find inventory pool for this order (employee doesn't need specific game account assignment)
    SELECT id INTO v_selected_employee_id
    FROM inventory_pools
    WHERE game_account_id IS NOT NULL  -- Just need any valid account
      AND currency_attribute_id = v_order.currency_attribute_id
      AND game_code = v_order.game_code
      AND (server_attribute_code = v_order.server_attribute_code OR server_attribute_code IS NULL)
      AND quantity > 0
    LIMIT 1;

    IF v_selected_employee_id IS NULL THEN
        RETURN QUERY SELECT false,
            format('No inventory pool available for %s server %s',
                   v_order.game_code, v_order.server_attribute_code),
            NULL::UUID, NULL::UUID, NULL::TEXT;
        RETURN;
    END IF;

    -- Update order
    UPDATE currency_orders
    SET assigned_to = v_next_employee.employee_id,
        assigned_at = v_current_time,
        status = 'assigned'
    WHERE id = p_purchase_order_id;

    RETURN QUERY SELECT true,
        format('Order assigned to employee %s at %s',
               v_next_employee.employee_name, v_gmt7_time::time),
        v_next_employee.employee_id, NULL::UUID, v_order.server_attribute_code;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function 2: create_shift_assignment_direct - simplified without game_account
CREATE OR REPLACE FUNCTION create_shift_assignment_direct(
    p_employee_profile_id UUID,
    p_shift_id UUID,
    p_channels_id UUID,
    p_currency_code TEXT,
    p_is_active BOOLEAN DEFAULT true
)
RETURNS JSONB AS $$
DECLARE
    v_assignment_id UUID;
BEGIN
    v_assignment_id := gen_random_uuid();

    INSERT INTO shift_assignments (
        id,
        employee_profile_id,
        shift_id,
        channels_id,
        currency_code,
        is_active,
        assigned_at
    ) VALUES (
        v_assignment_id,
        p_employee_profile_id,
        p_shift_id,
        p_channels_id,
        p_currency_code,
        p_is_active,
        NOW()
    );

    RETURN jsonb_build_object(
        'success', true,
        'message', 'Tạo phân công ca làm việc thành công',
        'assignment_id', v_assignment_id
    );
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Lỗi khi tạo phân công ca làm việc: ' || SQLERRM
        );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function 3: get_all_shift_assignments_direct - simplified without game_account joins
CREATE OR REPLACE FUNCTION get_all_shift_assignments_direct()
RETURNS TABLE (
    id UUID,
    employee_profile_id UUID,
    employee_name TEXT,
    shift_id UUID,
    shift_name TEXT,
    shift_start_time TIME,
    shift_end_time TIME,
    channels_id UUID,
    channel_name TEXT,
    currency_code TEXT,
    currency_name TEXT,
    is_active BOOLEAN,
    assigned_at TIMESTAMPTZ
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        sa.id,
        sa.employee_profile_id,
        COALESCE(p.display_name, 'Unknown') as employee_name,
        sa.shift_id,
        COALESCE(ws.name, 'Unknown') as shift_name,
        ws.start_time as shift_start_time,
        ws.end_time as shift_end_time,
        sa.channels_id,
        COALESCE(c.name, 'Unknown') as channel_name,
        sa.currency_code,
        COALESCE(curr.name, sa.currency_code) as currency_name,
        sa.is_active,
        sa.assigned_at
    FROM shift_assignments sa
    LEFT JOIN profiles p ON sa.employee_profile_id = p.id
    LEFT JOIN work_shifts ws ON sa.shift_id = ws.id
    LEFT JOIN channels c ON sa.channels_id = c.id
    LEFT JOIN currencies curr ON sa.currency_code = curr.code
    ORDER BY sa.assigned_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function 4: get_next_employee_for_pool - simplified without game_account
CREATE OR REPLACE FUNCTION get_next_employee_for_pool(
    p_pool_id UUID,
    p_game_account_id UUID  -- kept for compatibility but not used in lookup
)
RETURNS TABLE(employee_id UUID, employee_name TEXT) AS $$
DECLARE
    v_selected_employee RECORD;
    v_gmt7_time TIMESTAMPTZ := NOW();
    v_shift_id uuid;
    v_channel_id UUID;
BEGIN
    -- Get channel_id from pool
    SELECT channel_id INTO v_channel_id
    FROM inventory_pools
    WHERE id = p_pool_id;

    IF v_channel_id IS NULL THEN
        RETURN;
    END IF;

    -- Find current shift
    SELECT id INTO v_shift_id
    FROM work_shifts ws
    WHERE ws.is_active = true
      AND (
        (ws.start_time <= ws.end_time AND
         v_gmt7_time::time >= ws.start_time AND
         v_gmt7_time::time <= ws.end_time)
        OR
        (ws.start_time > ws.end_time AND
         (v_gmt7_time::time >= ws.start_time OR
          v_gmt7_time::time <= ws.end_time))
      )
    LIMIT 1;

    -- Find any available employee for this channel and shift
    SELECT
        sa.employee_profile_id as employee_id,
        p.display_name as employee_name
    INTO v_selected_employee
    FROM shift_assignments sa
    JOIN profiles p ON sa.employee_profile_id = p.id
    WHERE sa.channels_id = v_channel_id
      AND sa.shift_id = v_shift_id
      AND sa.is_active = true
      AND p.status = 'active'
    ORDER BY
        (SELECT COUNT(*) FROM currency_orders WHERE assigned_to = sa.employee_profile_id AND status NOT IN ('completed', 'cancelled')) ASC,
        p.display_name
    LIMIT 1;

    RETURN QUERY SELECT * FROM (SELECT v_selected_employee.employee_id, v_selected_employee.employee_name AS t)
                          WHERE v_selected_employee.employee_id IS NOT NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function 5: update_shift_assignment_direct - simplified without game_account
CREATE OR REPLACE FUNCTION update_shift_assignment_direct(
    p_assignment_id UUID,
    p_employee_profile_id UUID,
    p_shift_id UUID,
    p_channels_id UUID,
    p_currency_code TEXT,
    p_is_active BOOLEAN DEFAULT true
)
RETURNS JSONB AS $$
DECLARE
    v_assignment_exists BOOLEAN;
BEGIN
    SELECT EXISTS(SELECT 1 FROM shift_assignments WHERE id = p_assignment_id) INTO v_assignment_exists;

    IF NOT v_assignment_exists THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Không tìm thấy phân công ca làm việc'
        );
    END IF;

    UPDATE shift_assignments
    SET
        employee_profile_id = p_employee_profile_id,
        shift_id = p_shift_id,
        channels_id = p_channels_id,
        currency_code = p_currency_code,
        is_active = p_is_active,
        assigned_at = NOW()
    WHERE id = p_assignment_id;

    RETURN jsonb_build_object(
        'success', true,
        'message', 'Cập nhật phân công ca làm việc thành công',
        'assignment_id', p_assignment_id
    );
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Lỗi khi cập nhật phân công ca làm việc: ' || SQLERRM
        );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;