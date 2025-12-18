-- Migration: Final Staging Migrations Completion
-- Description: Update inventory pools with before/after quantity and finalize staging migration setup
-- Created: 2025-12-18 17:00:00
-- Author: Claude Code

-- Move back and update before/after quantity migration
-- This was previously 20251218_143500
ALTER TABLE currency_transactions
ADD COLUMN IF NOT EXISTS before_quantity numeric DEFAULT 0 CHECK (before_quantity >= 0),
ADD COLUMN IF NOT EXISTS after_quantity numeric DEFAULT 0 CHECK (after_quantity >= 0);

-- Add comments for documentation
COMMENT ON COLUMN currency_transactions.before_quantity IS 'Inventory quantity before this transaction was applied';
COMMENT ON COLUMN currency_transactions.after_quantity IS 'Inventory quantity after this transaction was applied';

-- Remove channel_id column if it still exists
DROP INDEX IF EXISTS idx_currency_transactions_channel_id;
ALTER TABLE currency_transactions DROP COLUMN IF EXISTS channel_id;

-- Create improved index for better query performance on inventory tracking
CREATE INDEX IF NOT EXISTS idx_currency_transactions_inventory_tracking
ON currency_transactions (game_account_id, currency_attribute_id, created_at);

-- Update inventory pools unique constraint (from 20251218_143000)
DROP INDEX IF EXISTS idx_inventory_pools_unique_business_key;
CREATE UNIQUE INDEX idx_inventory_pools_unique_business_key
ON inventory_pools (game_account_id, currency_attribute_id, game_code, COALESCE(server_attribute_code, ''));

-- Comment on the new unique constraint
COMMENT ON INDEX idx_inventory_pools_unique_business_key IS 'Unique business key for inventory pools - ensures one pool per game account + currency + game + server combination (empty string for games without servers)';

-- Create function to handle currency transaction quantities properly
CREATE OR REPLACE FUNCTION handle_currency_transaction_quantities()
RETURNS TRIGGER AS $$
DECLARE
    v_before_quantity numeric(20,4);
    v_after_quantity numeric(20,4);
    v_pool_quantity numeric(20,4);
BEGIN
    -- Get current quantity from inventory pool if inventory_pool_id exists
    IF NEW.inventory_pool_id IS NOT NULL THEN
        SELECT COALESCE(quantity, 0) INTO v_pool_quantity
        FROM inventory_pools
        WHERE id = NEW.inventory_pool_id;

        -- Calculate before and after based on transaction type
        IF NEW.transaction_type IN ('sale_delivery', 'exchange_out', 'transfer_out', 'payout') THEN
            -- Outgoing transaction
            v_before_quantity := v_pool_quantity;
            v_after_quantity := v_pool_quantity - NEW.quantity;
        ELSIF NEW.transaction_type IN ('purchase', 'exchange_in', 'transfer_in', 'farm_in') THEN
            -- Incoming transaction
            v_before_quantity := v_pool_quantity;
            v_after_quantity := v_pool_quantity + NEW.quantity;
        ELSE
            -- Manual adjustment or other
            v_before_quantity := v_pool_quantity;
            v_after_quantity := v_pool_quantity;
        END IF;
    ELSE
        -- No inventory pool tracking, set both to 0
        v_before_quantity := 0;
        v_after_quantity := 0;
    END IF;

    -- Update transaction with quantities
    NEW.before_quantity := v_before_quantity;
    NEW.after_quantity := v_after_quantity;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to handle quantities for all currency transactions
CREATE TRIGGER tr_handle_currency_transaction_quantities
    BEFORE INSERT ON currency_transactions
    FOR EACH ROW EXECUTE FUNCTION handle_currency_transaction_quantities();

-- Function to update inventory pool when transactions occur
CREATE OR REPLACE FUNCTION update_inventory_pool_from_transaction()
RETURNS TRIGGER AS $$
DECLARE
    v_new_quantity numeric(20,4);
BEGIN
    -- Only update if inventory_pool_id is provided
    IF NEW.inventory_pool_id IS NULL THEN
        RETURN NEW;
    END IF;

    -- Calculate new quantity based on transaction type
    IF NEW.transaction_type IN ('sale_delivery', 'exchange_out', 'transfer_out', 'payout') THEN
        -- Subtract quantity
        UPDATE inventory_pools
        SET quantity = quantity - NEW.quantity,
            last_updated_at = now()
        WHERE id = NEW.inventory_pool_id;
    ELSIF NEW.transaction_type IN ('purchase', 'exchange_in', 'transfer_in', 'farm_in') THEN
        -- Add quantity
        UPDATE inventory_pools
        SET quantity = quantity + NEW.quantity,
            last_updated_at = now()
        WHERE id = NEW.inventory_pool_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update inventory pools after transaction
CREATE TRIGGER tr_update_inventory_pool_after_transaction
    AFTER INSERT ON currency_transactions
    FOR EACH ROW EXECUTE FUNCTION update_inventory_pool_from_transaction();

-- Create summary view for staging verification
CREATE OR REPLACE VIEW staging_verification_view AS
SELECT
    -- Chart of Accounts
    (SELECT 'chart_of_accounts' as section_name, COUNT(*) as count FROM chart_of_accounts UNION
    UNION ALL
    -- Journal Entries
    SELECT 'journal_entries' as section_name, COUNT(*) as count FROM journal_entries UNION
    UNION ALL
    -- Journal Entry Lines
    SELECT 'journal_entry_lines' as section_name, COUNT(*) as count FROM journal_entry_lines UNION
    UNION ALL
    -- Account Balances
    SELECT 'account_balances' as section_name, COUNT(*) as count FROM account_balances UNION
    UNION ALL
    -- Employee Fund Accounts
    SELECT 'employee_fund_accounts' as section_name, COUNT(*) as count FROM employee_fund_accounts UNION
    UNION ALL
    -- Employee Fund Transactions
    SELECT 'employee_fund_transactions' as section_name, COUNT(*) as count FROM employee_fund_transactions UNION
    UNION ALL
    -- Approval Requests
    SELECT 'approval_requests' as section_name, COUNT(*) as count FROM approval_requests UNION
    UNION ALL
    -- Approval Rules
    SELECT 'approval_rules' as section_name, COUNT(*) as count FROM approval_rules
    ) as verification_summary;

-- Add comment for staging verification
COMMENT ON VIEW staging_verification_view IS 'Staging verification view - shows count of all tables for deployment verification';

-- Insert initial approval rules if they don't exist
INSERT INTO approval_rules (rule_name, entity_type, condition_type, condition_value, approval_limit, description)
SELECT
    'Employee Fund > 50M VND', 'employee_fund', 'amount_above',
    '{"currency": "VND", "amount": 50000000}', 1000000000,
    'Auto-approve up to 1B VND, manual approval above'
WHERE NOT EXISTS (
    SELECT 1 FROM approval_rules WHERE rule_name = 'Employee Fund > 50M VND'
);

-- Set all financial system tables to proper ownership
ALTER TABLE chart_of_tables OWNER TO postgres;
ALTER TABLE journal_entries OWNER TO postgres;
ALTER TABLE journal_entry_lines OWNER TO postgres;
ALTER TABLE account_balances OWNER TO postgres;
ALTER TABLE employee_fund_accounts OWNER TO postgres;
ALTER TABLE employee_fund_transactions OWNER TO postgres;
ALTER TABLE approval_requests OWNER TO postgres;
ALTER TABLE approval_rules OWNER TO postgres;

-- Enable Row Level Security for financial tables
ALTER TABLE employee_fund_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE employee_fund_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE approval_requests ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for employee fund accounts
CREATE POLICY "Users can view own employee fund accounts" ON employee_fund_accounts
    FOR ALL
    USING (auth.uid() = employee_id);

CREATE POLICY "Service role can manage all employee fund accounts" ON employee_fund_accounts
    FOR ALL
    USING (auth.jwt()->>>>'role' = 'service_role');

-- Create RLS policies for employee fund transactions
CREATE POLICY "Users can view own employee fund transactions" ON employee_fund_transactions
    FOR ALL
    USING (auth.uid() = employee_id);

CREATE POLICY "Service role can manage all employee fund transactions" ON employee_fund_transactions
    FOR ALL
    USING (auth.jwt()->>>>'role' = 'service_role');

-- Create RLS policies for approval requests (managers only)
CREATE POLICY "Managers can view all approval requests" ON approval_requests
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM user_role_assignments ura
            JOIN roles r ON ura.role_id = r.id
            WHERE ura.user_id = auth.uid()
            AND r.code IN ('manager', 'admin')
        )
    );

CREATE POLICY "Service role can manage all approval requests" ON approval_requests
    FOR ALL
    USING (auth.jwt()->>>>'role' = 'service_role');

-- Grant permissions to authenticated users
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO authenticated;

-- Grant execute permissions on financial functions
GRANT EXECUTE ON FUNCTION allocate_employee_fund TO authenticated;
GRANT EXECUTE ON FUNCTION return_employee_fund TO authenticated;
GRANT EXECUTE ON FUNCTION create_approval_if_needed TO authenticated;
GRANT EXECUTE ON FUNCTION approve_request TO authenticated;
GRANT EXECUTE ON FUNCTION reject_request TO authenticated;

-- Create audit log for financial system setup
INSERT INTO audit_logs (created_at, message)
VALUES (now(), 'Financial system deployed to staging - Chart of Accounts, Employee Funds, Approval Workflows');

-- Success message
DO $$
DECLARE
    v_message TEXT;
BEGIN
    v_message := '✅ Financial System deployed to staging successfully!' || E'\n' ||
                   '  - Chart of Accounts: 100 (Cash), 200 (Employee Funds), 300 (Revenue), 400 (Expenses)' || E'\n' ||
                   '  - Employee Fund Management with approval workflows' || E'\n' ||
                   '  - Double-entry accounting with journal entries' || E'\n' ||
                   '  - Integration with existing currency orders' || E'\n' ||
                   '  - Row Level Security enabled' || E'\n' ||
                   '  - All functions and permissions configured' || E'\n' ||
                   '  Ready for testing!';

    RAISE LOG '%', v_message;
END;
$$;