-- Add sample role assignments for testing
-- This creates sample assignments linking existing users to roles

-- Insert sample role assignments based on production data
INSERT INTO public.user_role_assignments (id, user_id, role_id) VALUES
  ('a25f32bb-ec39-456c-93c8-98af65c69db0', '8710590d-efde-4c63-99de-aba2014fe944', '057fc788-7788-442a-9c32-39cfdbec6547'),
  ('ac573e28-8a0b-4397-b9e5-0d23ff33dc4b', '14a9f40f-3aff-4b9c-92a3-f5a9a364223c', 'c52bfc3b-d628-4576-b68a-1a7ca7c1c994'),
  ('2c3a5891-0f42-49b8-a3ba-ea4c55691759', '4564fd01-dbe8-48c2-b482-03340d6e0e80', '057fc788-7788-442a-9c32-39cfdbec6547'),
  ('3dcde50e-67f6-4c68-bc60-2a24b84f9dd3', '4564fd01-dbe8-48c2-b482-03340d6e0e80', 'f9cc9457-fcd9-4ca0-9ae8-e87c870bb4fc')
ON CONFLICT (id) DO NOTHING;

-- Add additional assignments for remaining users (if roles exist)
-- This assumes the role IDs exist - you may need to adjust these based on your actual roles
DO $$
DECLARE
    v_role_admin UUID;
    v_role_manager UUID;
    v_role_farmer UUID;
BEGIN
    -- Get role IDs (these may need adjustment based on your actual roles)
    SELECT id INTO v_role_admin FROM roles WHERE code = 'admin' LIMIT 1;
    SELECT id INTO v_role_manager FROM roles WHERE code = 'manager' LIMIT 1;
    SELECT id INTO v_role_farmer FROM roles WHERE code = 'farmer' LIMIT 1;

    -- Assign admin role to first user if not already assigned
    IF v_role_admin IS NOT NULL THEN
        INSERT INTO public.user_role_assignments (user_id, role_id)
        SELECT id, v_role_admin FROM profiles
        WHERE id = (SELECT id FROM profiles ORDER BY created_at ASC LIMIT 1)
        AND NOT EXISTS (
            SELECT 1 FROM user_role_assignments
            WHERE user_id = profiles.id AND role_id = v_role_admin
        );
    END IF;

    -- Assign manager role to second user if not already assigned
    IF v_role_manager IS NOT NULL THEN
        INSERT INTO public.user_role_assignments (user_id, role_id)
        SELECT id, v_role_manager FROM profiles
        WHERE id = (SELECT id FROM profiles ORDER BY created_at ASC OFFSET 1 LIMIT 1)
        AND NOT EXISTS (
            SELECT 1 FROM user_role_assignments
            WHERE user_id = profiles.id AND role_id = v_role_manager
        );
    END IF;
END $$;