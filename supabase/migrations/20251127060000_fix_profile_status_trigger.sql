-- Fix profile status change trigger
-- Created: 2025-11-27
-- Purpose: Fix column name mismatch in trigger function

-- Update trigger function to use correct column names
CREATE OR REPLACE FUNCTION log_profile_status_change()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
BEGIN
    IF TG_OP = 'UPDATE' AND OLD.status != NEW.status THEN
        INSERT INTO public.profile_status_logs (
            profile_id,
            old_status,
            new_status,
            changed_by,
            created_at
        ) VALUES (
            NEW.id,
            OLD.status,
            NEW.status,
            auth.uid(),
            NOW()
        );
    END IF;
    RETURN NEW;
END;
$$;