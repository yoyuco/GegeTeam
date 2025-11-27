-- Create RPC functions for shift_assignments management to bypass RLS
-- Created: 2025-11-27
-- Purpose: Allow admin users to manage shift assignments without RLS restrictions

-- Function to create new shift assignment
CREATE OR REPLACE FUNCTION create_shift_assignment_direct(
  p_game_account_id UUID,
  p_employee_profile_id UUID,
  p_shift_id UUID,
  p_channels_id UUID,
  p_currency_code TEXT DEFAULT 'VND',
  p_is_active BOOLEAN DEFAULT true
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
DECLARE
  v_assignment_id UUID;
BEGIN
  -- Generate UUID for new assignment
  v_assignment_id := gen_random_uuid();

  -- Insert new shift assignment (this bypasses RLS due to SECURITY DEFINER)
  INSERT INTO shift_assignments (
    id,
    game_account_id,
    employee_profile_id,
    shift_id,
    channels_id,
    currency_code,
    is_active,
    assigned_at
  ) VALUES (
    v_assignment_id,
    p_game_account_id,
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
$$;

-- Function to update existing shift assignment
CREATE OR REPLACE FUNCTION update_shift_assignment_direct(
  p_assignment_id UUID,
  p_game_account_id UUID,
  p_employee_profile_id UUID,
  p_shift_id UUID,
  p_channels_id UUID,
  p_currency_code TEXT DEFAULT 'VND',
  p_is_active BOOLEAN DEFAULT true
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
DECLARE
  v_assignment_exists BOOLEAN;
BEGIN
  -- Check if assignment exists
  SELECT EXISTS(SELECT 1 FROM shift_assignments WHERE id = p_assignment_id) INTO v_assignment_exists;

  IF NOT v_assignment_exists THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Không tìm thấy phân công ca làm việc'
    );
  END IF;

  -- Update shift assignment (this bypasses RLS due to SECURITY DEFINER)
  UPDATE shift_assignments
  SET
    game_account_id = p_game_account_id,
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
$$;

-- Function to delete shift assignment
CREATE OR REPLACE FUNCTION delete_shift_assignment_direct(
  p_assignment_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
DECLARE
  v_assignment_exists BOOLEAN;
BEGIN
  -- Check if assignment exists
  SELECT EXISTS(SELECT 1 FROM shift_assignments WHERE id = p_assignment_id) INTO v_assignment_exists;

  IF NOT v_assignment_exists THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Không tìm thấy phân công ca làm việc'
    );
  END IF;

  -- Delete shift assignment (this bypasses RLS due to SECURITY DEFINER)
  DELETE FROM shift_assignments WHERE id = p_assignment_id;

  RETURN jsonb_build_object(
    'success', true,
    'message', 'Xóa phân công ca làm việc thành công',
    'assignment_id', p_assignment_id
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Lỗi khi xóa phân công ca làm việc: ' || SQLERRM
    );
END;
$$;

-- Function to get all shift assignments with joined data (bypass RLS)
CREATE OR REPLACE FUNCTION get_all_shift_assignments_direct()
RETURNS TABLE (
  id UUID,
  game_account_id UUID,
  game_account_name TEXT,
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
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
BEGIN
  RETURN QUERY
  SELECT
    sa.id,
    sa.game_account_id,
    COALESCE(ga.account_name, 'Unknown') as game_account_name,
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
  LEFT JOIN game_accounts ga ON sa.game_account_id = ga.id
  LEFT JOIN profiles p ON sa.employee_profile_id = p.id
  LEFT JOIN work_shifts ws ON sa.shift_id = ws.id
  LEFT JOIN channels c ON sa.channels_id = c.id
  LEFT JOIN currencies curr ON sa.currency_code = curr.code
  ORDER BY sa.assigned_at DESC;
END;
$$;

-- Grant execute permissions to authenticated users
GRANT EXECUTE ON FUNCTION create_shift_assignment_direct TO authenticated;
GRANT EXECUTE ON FUNCTION update_shift_assignment_direct TO authenticated;
GRANT EXECUTE ON FUNCTION delete_shift_assignment_direct TO authenticated;
GRANT EXECUTE ON FUNCTION get_all_shift_assignments_direct TO authenticated;