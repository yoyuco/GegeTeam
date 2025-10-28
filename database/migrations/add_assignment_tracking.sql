-- Migration: Add assignment tracking columns
-- Purpose: Support 4 core scenarios for assignment management

-- Add columns to employee_shift_assignments table
ALTER TABLE employee_shift_assignments
ADD COLUMN IF NOT EXISTS last_handover_time TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS handover_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS backup_employee_id UUID REFERENCES profiles(id),
ADD COLUMN IF NOT EXISTS is_fallback BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS fallback_reason TEXT,
ADD COLUMN IF NOT EXISTS fallback_time TIMESTAMP WITH TIME ZONE;

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_employee_shift_assignments_handover
ON employee_shift_assignments(last_handover_time DESC);

CREATE INDEX IF NOT EXISTS idx_employee_shift_assignments_fallback
ON employee_shift_assignments(is_fallback, fallback_time DESC);

-- Add RLS policies for new columns (if RLS is enabled)
-- These are example policies - adjust according to your security requirements

-- Policy for reading handover information
CREATE POLICY IF NOT EXISTS "Users can read handover info" ON employee_shift_assignments
FOR SELECT USING (
  auth.role() = 'authenticated'
);

-- Policy for updating handover information
CREATE POLICY IF NOT EXISTS "Users can update handover info" ON employee_shift_assignments
FOR UPDATE USING (
  auth.role() = 'authenticated'
);

-- Comments for documentation
COMMENT ON COLUMN employee_shift_assignments.last_handover_time IS 'Timestamp of the last handover for this assignment';
COMMENT ON COLUMN employee_shift_assignments.handover_count IS 'Total number of handovers for this assignment';
COMMENT ON COLUMN employee_shift_assignments.backup_employee_id IS 'Designated backup employee for this assignment';
COMMENT ON COLUMN employee_shift_assignments.is_fallback IS 'True if this assignment is being used as a fallback';
COMMENT ON COLUMN employee_shift_assignments.fallback_reason IS 'Reason why this assignment became a fallback';
COMMENT ON COLUMN employee_shift_assignments.fallback_time IS 'Timestamp when this assignment became a fallback';