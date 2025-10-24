-- Migration: DEPRECATED - DO NOT USE
-- Date: 2025-10-04
-- Status: SUPERSEDED by 20251004081500_fix_service_variant_name_minimal.sql
--
-- This migration contained errors and changed too much of the function structure.
-- It has been replaced by a minimal fix in migration 20251004081500.
--
-- This file is kept for migration history consistency only.
-- The function has already been overridden by the correct version.

-- No-op: This migration does nothing to avoid re-applying broken changes
DO $$
BEGIN
    -- This migration has been superseded and does nothing
    RAISE NOTICE 'Migration 20251004080000 is deprecated. See 20251004081500 instead.';
END $$;
