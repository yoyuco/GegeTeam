-- Fix foreign key constraint in profile_status_logs
-- Created: 2025-11-27
-- Purpose: Remove constraint that prevents auth.users.id from being used in changed_by field

-- Drop the foreign key constraint that requires changed_by to reference profiles.id
ALTER TABLE profile_status_logs DROP CONSTRAINT IF EXISTS profile_status_logs_changed_by_fkey;