-- ============================================================================
-- Cleanup Migration: Remove Duplicate and Unused Functions
-- ============================================================================
-- Date: 2025-10-03
-- Purpose: Remove old versions of functions that have been replaced
--
-- Functions to be removed:
-- 1. create_service_order_v1 (old signature)
-- 2. get_boosting_orders_v2 (replaced by v3)
-- 3. get_session_history_v1 (replaced by v2)
-- ============================================================================

-- Remove old version of create_service_order_v1
-- This is the version WITHOUT p_price, p_currency parameters
DROP FUNCTION IF EXISTS "public"."create_service_order_v1"(
  "p_channel_code" "text",
  "p_customer_name" "text",
  "p_package_type" "text",
  "p_package_note" "text",
  "p_deadline" timestamp with time zone,
  "p_service_type" "text",
  "p_btag" "text",
  "p_login_id" "text",
  "p_login_pwd" "text",
  "p_machine_info" "text",
  "p_service_items" "jsonb",
  "p_action_proof_urls" "text"[]
);

-- Remove old version of get_boosting_orders (v2)
-- v3 is the current version being used
DROP FUNCTION IF EXISTS "public"."get_boosting_orders_v2"();

-- Remove old version of get_session_history (v1)
-- v2 is the current version being used
DROP FUNCTION IF EXISTS "public"."get_session_history_v1"(
  "p_order_line_id" "uuid"
);

-- Add comment for audit trail
COMMENT ON SCHEMA public IS 'Cleaned up duplicate functions on 2025-10-03';
