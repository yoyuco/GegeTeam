-- Create update_profile_status_direct function to bypass RLS
-- Created: 2025-11-27
-- Purpose: Allow admin users to update profile status without RLS restrictions

CREATE OR REPLACE FUNCTION update_profile_status_direct(
  p_profile_id UUID,
  p_new_status TEXT,
  p_change_reason TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
DECLARE
  v_old_status TEXT;
  v_updated_count INTEGER;
BEGIN
  -- Get current status
  SELECT status INTO v_old_status FROM profiles WHERE id = p_profile_id;

  IF v_old_status IS NULL THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Không tìm thấy profile'
    );
  END IF;

  -- Update status (this bypasses RLS due to SECURITY DEFINER)
  UPDATE profiles
  SET status = p_new_status, updated_at = NOW()
  WHERE id = p_profile_id
  RETURNING 1 INTO v_updated_count;

  IF v_updated_count = 0 THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Không thể cập nhật trạng thái'
    );
  END IF;

  -- Log the change with reason
  INSERT INTO profile_status_logs (
    profile_id,
    old_status,
    new_status,
    change_reason,
    changed_by,
    created_at
  ) VALUES (
    p_profile_id,
    v_old_status,
    p_new_status,
    p_change_reason,
    auth.uid(),
    NOW()
  );

  RETURN jsonb_build_object(
    'success', true,
    'message', 'Cập nhật trạng thái thành công'
  );
END;
$$;