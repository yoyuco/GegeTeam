-- Migration: Fix Currency Security Policies
-- Version: 1.0
-- Date: 2025-10-08
-- Description: Fix security policies to use correct table names from existing schema

-- First, drop existing policies
DROP POLICY IF EXISTS "Users can view game accounts they manage" ON public.game_accounts;
DROP POLICY IF EXISTS "Admins can insert game accounts" ON public.game_accounts;
DROP POLICY IF EXISTS "Users can update game accounts they manage" ON public.game_accounts;
DROP POLICY IF EXISTS "Users can view inventory they manage" ON public.currency_inventory;
DROP POLICY IF EXISTS "Users can view transactions they created or manage" ON public.currency_transactions;
DROP POLICY IF EXISTS "Users can insert transactions they manage" ON public.currency_transactions;

-- Create corrected security policies using existing schema

-- Game Accounts RLS policies
CREATE POLICY "Users can view game accounts they manage"
    ON public.game_accounts FOR SELECT
    USING (
        auth.uid() = manager_profile_id
        OR EXISTS (
            SELECT 1 FROM public.user_role_assignments ura
            JOIN public.roles r ON ura.role_id = r.id
            WHERE ura.user_id = auth.uid()
            AND r.code IN ('admin', 'manager')
        )
    );

CREATE POLICY "Admins and managers can insert game accounts"
    ON public.game_accounts FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.user_role_assignments ura
            JOIN public.roles r ON ura.role_id = r.id
            WHERE ura.user_id = auth.uid()
            AND r.code IN ('admin', 'manager')
        )
    );

CREATE POLICY "Users can update game accounts they manage"
    ON public.game_accounts FOR UPDATE
    USING (
        auth.uid() = manager_profile_id
        OR EXISTS (
            SELECT 1 FROM public.user_role_assignments ura
            JOIN public.roles r ON ura.role_id = r.id
            WHERE ura.user_id = auth.uid()
            AND r.code IN ('admin', 'manager')
        )
    );

-- Currency Inventory RLS policies
CREATE POLICY "Users can view inventory they manage"
    ON public.currency_inventory FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.game_accounts ga
            WHERE ga.id = game_account_id
            AND (
                ga.manager_profile_id = auth.uid()
                OR EXISTS (
                    SELECT 1 FROM public.user_role_assignments ura
                    JOIN public.roles r ON ura.role_id = r.id
                    WHERE ura.user_id = auth.uid()
                    AND r.code IN ('admin', 'manager')
                )
            )
        )
    );

-- Currency Transactions RLS policies
CREATE POLICY "Users can view transactions they created or manage"
    ON public.currency_transactions FOR SELECT
    USING (
        created_by = auth.uid()
        OR EXISTS (
            SELECT 1 FROM public.game_accounts ga
            WHERE ga.id = game_account_id
            AND ga.manager_profile_id = auth.uid()
        )
        OR EXISTS (
            SELECT 1 FROM public.user_role_assignments ura
            JOIN public.roles r ON ura.role_id = r.id
            WHERE ura.user_id = auth.uid()
            AND r.code IN ('admin', 'manager')
        )
    );

CREATE POLICY "Users can insert transactions they manage"
    ON public.currency_transactions FOR INSERT
    WITH CHECK (
        created_by = auth.uid()
        AND EXISTS (
            SELECT 1 FROM public.game_accounts ga
            WHERE ga.id = game_account_id
            AND (
                ga.manager_profile_id = auth.uid()
                OR EXISTS (
                    SELECT 1 FROM public.user_role_assignments ura
                    JOIN public.roles r ON ura.role_id = r.id
                    WHERE ura.user_id = auth.uid()
                    AND r.code IN ('admin', 'manager')
                )
            )
        )
    );

-- Also allow users to insert transactions for game accounts they manage
CREATE POLICY "Users can create transactions for their managed accounts"
    ON public.currency_transactions FOR INSERT
    WITH CHECK (
        created_by = auth.uid()
        AND EXISTS (
            SELECT 1 FROM public.game_accounts ga
            WHERE ga.id = game_account_id
            AND ga.manager_profile_id = auth.uid()
        )
    );

-- Grant necessary permissions
GRANT SELECT ON public.trading_fee_chains TO authenticated;
GRANT SELECT ON public.exchange_rates TO authenticated;
GRANT EXECUTE ON FUNCTION public.calculate_chain_costs TO authenticated;
GRANT EXECUTE ON FUNCTION public.calculate_simple_profit_loss TO authenticated;