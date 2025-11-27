-- Fix user role assignments functions
-- Created: 2025-11-27
-- Purpose: Fix functions for user role assignments functionality

-- Drop existing broken functions
DROP FUNCTION IF EXISTS get_user_role_assignments;

-- Fixed function to get user role assignments with proper joins
CREATE OR REPLACE FUNCTION get_user_role_assignments(
  p_user_id UUID
)
RETURNS TABLE (
  assignment_id UUID,
  role_name TEXT,
  game_attribute_name TEXT,
  business_area_attribute_name TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
BEGIN
  RETURN QUERY
  SELECT
    ura.id as assignment_id,
    r.name as role_name,
    g.name as game_attribute_name,
    ba.name as business_area_attribute_name
  FROM user_role_assignments ura
  JOIN roles r ON ura.role_id = r.id
  LEFT JOIN attributes g ON ura.game_attribute_id = g.id
  LEFT JOIN attributes ba ON ura.business_area_attribute_id = ba.id
  WHERE ura.user_id = p_user_id
  ORDER BY r.name, g.name, ba.name;
END;
$$;

-- Drop and recreate assign_role_to_user with correct signature
DROP FUNCTION IF EXISTS assign_role_to_user;

CREATE OR REPLACE FUNCTION assign_role_to_user(
  p_user_id UUID,
  p_role_id UUID,
  p_game_attribute_id UUID DEFAULT NULL,
  p_business_area_attribute_id UUID DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
DECLARE
  v_assignment_id UUID;
  v_role_name TEXT;
BEGIN
  -- Get role name for message
  SELECT name INTO v_role_name FROM roles WHERE id = p_role_id;

  IF v_role_name IS NULL THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Vai trò không tồn tại'
    );
  END IF;

  -- Check if assignment already exists (including game attribute for uniqueness)
  SELECT id INTO v_assignment_id
  FROM user_role_assignments
  WHERE user_id = p_user_id
    AND role_id = p_role_id
    AND (game_attribute_id = p_game_attribute_id OR (game_attribute_id IS NULL AND p_game_attribute_id IS NULL));

  IF v_assignment_id IS NOT NULL THEN
    -- Assignment already exists for this specific game
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Người dùng đã được gán vai trò này cho game này rồi'
    );
  END IF;

  -- Create new assignment
  INSERT INTO user_role_assignments (user_id, role_id, game_attribute_id, business_area_attribute_id)
  VALUES (p_user_id, p_role_id, p_game_attribute_id, p_business_area_attribute_id)
  RETURNING id INTO v_assignment_id;

  -- Return success result
  RETURN jsonb_build_object(
    'success', true,
    'message', 'Đã gán vai trò thành công',
    'assignment_id', v_assignment_id
  );
END;
$$;

-- Create remove_role_from_user function
CREATE OR REPLACE FUNCTION remove_role_from_user(
  p_assignment_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
DECLARE
  v_deleted_count INTEGER;
BEGIN
  -- Delete the role assignment
  DELETE FROM user_role_assignments
  WHERE id = p_assignment_id
  RETURNING 1 INTO v_deleted_count;

  IF v_deleted_count = 0 THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Không tìm thấy phân quyền để xóa'
    );
  END IF;

  -- Return success result
  RETURN jsonb_build_object(
    'success', true,
    'message', 'Đã xóa vai trò thành công'
  );
END;
$$;