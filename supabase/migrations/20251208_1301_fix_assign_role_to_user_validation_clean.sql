-- Fix assign_role_to_user function validation logic
-- Problem: Function incorrectly treats NULL game_attribute_id as matching when business_area_attribute_id differs
-- Solution: Use proper NULL handling and exact match comparison
-- Date: 2025-12-08

-- Drop and recreate function with correct validation logic
CREATE OR REPLACE FUNCTION assign_role_to_user(
    p_user_id uuid,
    p_role_id uuid,
    p_game_attribute_id uuid DEFAULT NULL,
    p_business_area_attribute_id uuid DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO public
AS $$
DECLARE
    v_assignment_id uuid;
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

    -- Check if assignment already exists (exact match including NULL handling)
    -- Use IS NOT DISTINCT FROM to properly handle NULL values comparison
    SELECT id INTO v_assignment_id
    FROM user_role_assignments
    WHERE user_id = p_user_id
      AND role_id = p_role_id
      AND game_attribute_id IS NOT DISTINCT FROM p_game_attribute_id
      AND business_area_attribute_id IS NOT DISTINCT FROM p_business_area_attribute_id;

    IF v_assignment_id IS NOT NULL THEN
        -- Assignment already exists for this exact combination
        RETURN jsonb_build_object(
            'success', false,
            'message', format('Phân quyền này đã tồn tại (User: %s, Role: %s, Game: %s, Lĩnh vực: %s)',
                COALESCE((SELECT display_name FROM profiles WHERE id = p_user_id), 'Unknown'),
                v_role_name,
                COALESCE((SELECT name FROM attributes WHERE id = p_game_attribute_id), 'Tất cả'),
                COALESCE((SELECT name FROM attributes WHERE id = p_business_area_attribute_id), 'Tất cả')
            )
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

-- Grant permissions
GRANT EXECUTE ON FUNCTION assign_role_to_user TO authenticated;
GRANT EXECUTE ON FUNCTION assign_role_to_user TO service_role;