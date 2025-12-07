-- Restore staging RLS policies for currency_orders
-- This migration restores the original working policies from staging_full_schema_20251128_171810.sql

-- First, drop all existing policies on currency_orders
DROP POLICY IF EXISTS "Comprehensive currency orders access policy" ON "public"."currency_orders";
DROP POLICY IF EXISTS "Users can insert currency orders" ON "public"."currency_orders";
DROP POLICY IF EXISTS "Users can update currency orders" ON "public"."currency_orders";
DROP POLICY IF EXISTS "Users can delete currency orders" ON "public"."currency_orders";

-- Recreate staging policies with get_current_profile_id()

-- 1. SELECT policy - allows users to see their own orders or if they have admin/mod/manager/leader role
CREATE POLICY "Comprehensive currency orders access policy" ON "public"."currency_orders"
FOR SELECT USING (
    (EXISTS (
        SELECT 1
        FROM "public"."user_role_assignments" "ura"
        JOIN "public"."roles" "r" ON ("ura"."role_id" = "r"."id")
        WHERE (
            "ura"."user_id" = "public"."get_current_profile_id"()
            AND ("r"."code")::text = ANY (ARRAY['admin'::text, 'mod'::text, 'manager'::text, 'leader'::text])
        )
    ))
    OR ("created_by" = "public"."get_current_profile_id"())
    OR ("assigned_to" = "public"."get_current_profile_id"())
);

-- 2. INSERT policy - users can only insert orders they created
CREATE POLICY "Users can insert currency orders" ON "public"."currency_orders"
FOR INSERT WITH CHECK (("created_by" = "public"."get_current_profile_id"()));

-- 3. UPDATE policy - users can update their own orders or if they have admin/mod/manager/leader role
CREATE POLICY "Users can update currency orders" ON "public"."currency_orders"
FOR UPDATE USING (
    ("created_by" = "public"."get_current_profile_id"())
    OR ("assigned_to" = "public"."get_current_profile_id"())
    OR (EXISTS (
        SELECT 1
        FROM "public"."user_role_assignments" "ura"
        JOIN "public"."roles" "r" ON ("ura"."role_id" = "r"."id")
        WHERE (
            "ura"."user_id" = "public"."get_current_profile_id"()
            AND ("r"."code")::text = ANY (ARRAY['admin'::text, 'mod'::text, 'manager'::text, 'leader'::text])
        )
    ))
);

-- Ensure RLS is enabled
ALTER TABLE "public"."currency_orders" ENABLE ROW LEVEL SECURITY;

-- Verification
DO $$
BEGIN
    RAISE NOTICE 'Restored staging RLS policies for currency_orders table';
    RAISE NOTICE 'Policies now use get_current_profile_id() function like in staging';
    RAISE NOTICE 'Users can access their own orders and admins have full access';
END $$;