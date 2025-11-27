-- Add phone and notes columns to profiles table
-- Created: 2025-11-27
-- Purpose: Add missing columns for employee contact information and notes

ALTER TABLE profiles ADD COLUMN phone TEXT;
ALTER TABLE profiles ADD COLUMN notes TEXT;

-- Add index for phone if frequently searched
CREATE INDEX idx_profiles_phone ON profiles(phone) WHERE phone IS NOT NULL;