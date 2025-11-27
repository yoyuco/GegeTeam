-- Fix RLS policy for profiles table to use role codes instead of role names
-- Created: 2025-11-27
-- Purpose: Allow admin users to update profiles using role codes

DROP POLICY IF EXISTS "Secure role-based profile update policy" ON profiles;

CREATE POLICY "Secure role-based profile update policy" ON profiles
FOR UPDATE USING (
  auth_id = auth.uid() OR
  EXISTS (
    SELECT 1 FROM user_role_assignments ura
    JOIN roles r ON ura.role_id = r.id
    WHERE ura.user_id = (
      SELECT id FROM profiles WHERE auth_id = auth.uid()
    ) AND r.code::text = ANY (ARRAY['admin', 'administrator'])
  )
);