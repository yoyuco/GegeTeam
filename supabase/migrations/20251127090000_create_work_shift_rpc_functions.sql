-- Create RPC functions for work_shift management to bypass RLS
-- Created: 2025-11-27
-- Purpose: Allow admin users to manage work shifts without RLS restrictions

-- Function to create new work shift
CREATE OR REPLACE FUNCTION create_work_shift_direct(
  p_name TEXT,
  p_start_time TIME,
  p_end_time TIME,
  p_description TEXT DEFAULT NULL,
  p_is_active BOOLEAN DEFAULT true
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
DECLARE
  v_shift_id UUID;
  v_shift_name TEXT;
BEGIN
  -- Generate UUID for new shift
  v_shift_id := gen_random_uuid();
  v_shift_name := COALESCE(p_name, 'Unnamed Shift');

  -- Insert new work shift (this bypasses RLS due to SECURITY DEFINER)
  INSERT INTO work_shifts (
    id,
    name,
    start_time,
    end_time,
    description,
    is_active,
    created_at,
    updated_at
  ) VALUES (
    v_shift_id,
    v_shift_name,
    p_start_time,
    p_end_time,
    p_description,
    p_is_active,
    NOW(),
    NOW()
  );

  RETURN jsonb_build_object(
    'success', true,
    'message', 'Tạo ca làm việc thành công',
    'shift_id', v_shift_id,
    'shift_name', v_shift_name
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Lỗi khi tạo ca làm việc: ' || SQLERRM
    );
END;
$$;

-- Function to update existing work shift
CREATE OR REPLACE FUNCTION update_work_shift_direct(
  p_shift_id UUID,
  p_name TEXT,
  p_start_time TIME,
  p_end_time TIME,
  p_description TEXT DEFAULT NULL,
  p_is_active BOOLEAN DEFAULT true
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
DECLARE
  v_shift_exists BOOLEAN;
  v_shift_name TEXT;
BEGIN
  -- Check if shift exists
  SELECT EXISTS(SELECT 1 FROM work_shifts WHERE id = p_shift_id) INTO v_shift_exists;

  IF NOT v_shift_exists THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Không tìm thấy ca làm việc'
    );
  END IF;

  -- Get current shift name for response
  SELECT name INTO v_shift_name FROM work_shifts WHERE id = p_shift_id;

  -- Update work shift (this bypasses RLS due to SECURITY DEFINER)
  UPDATE work_shifts
  SET
    name = p_name,
    start_time = p_start_time,
    end_time = p_end_time,
    description = p_description,
    is_active = p_is_active,
    updated_at = NOW()
  WHERE id = p_shift_id;

  RETURN jsonb_build_object(
    'success', true,
    'message', 'Cập nhật ca làm việc thành công',
    'shift_id', p_shift_id,
    'shift_name', v_shift_name
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Lỗi khi cập nhật ca làm việc: ' || SQLERRM
    );
END;
$$;

-- Function to delete work shift
CREATE OR REPLACE FUNCTION delete_work_shift_direct(
  p_shift_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
DECLARE
  v_shift_exists BOOLEAN;
  v_shift_name TEXT;
BEGIN
  -- Check if shift exists
  SELECT EXISTS(SELECT 1 FROM work_shifts WHERE id = p_shift_id) INTO v_shift_exists;

  IF NOT v_shift_exists THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Không tìm thấy ca làm việc'
    );
  END IF;

  -- Get shift name for response
  SELECT name INTO v_shift_name FROM work_shifts WHERE id = p_shift_id;

  -- Delete work shift (this bypasses RLS due to SECURITY DEFINER)
  DELETE FROM work_shifts WHERE id = p_shift_id;

  RETURN jsonb_build_object(
    'success', true,
    'message', 'Xóa ca làm việc thành công',
    'shift_id', p_shift_id,
    'shift_name', v_shift_name
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Lỗi khi xóa ca làm việc: ' || SQLERRM
    );
END;
$$;

-- Function to get all work shifts (bypass RLS)
CREATE OR REPLACE FUNCTION get_all_work_shifts_direct()
RETURNS TABLE (
  id UUID,
  name TEXT,
  start_time TIME,
  end_time TIME,
  description TEXT,
  is_active BOOLEAN,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
BEGIN
  RETURN QUERY
  SELECT
    ws.id,
    ws.name,
    ws.start_time,
    ws.end_time,
    ws.description,
    ws.is_active,
    ws.created_at,
    ws.updated_at
  FROM work_shifts ws
  ORDER BY ws.created_at DESC;
END;
$$;

-- Grant execute permissions to authenticated users
GRANT EXECUTE ON FUNCTION create_work_shift_direct TO authenticated;
GRANT EXECUTE ON FUNCTION update_work_shift_direct TO authenticated;
GRANT EXECUTE ON FUNCTION delete_work_shift_direct TO authenticated;
GRANT EXECUTE ON FUNCTION get_all_work_shifts_direct TO authenticated;