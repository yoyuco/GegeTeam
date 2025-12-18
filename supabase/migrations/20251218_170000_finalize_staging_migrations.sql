-- Migration: Final Staging Setup with RLS and Permissions (Fixed)
-- Description: Complete financial system setup with RLS policies and permissions
-- Created: 2025-12-18 17:00:00
-- Author: Claude Code

-- 1. Update before_quantity and after_quantity in currency_transactions
ALTER TABLE currency_transactions
ADD COLUMN IF NOT EXISTS before_quantity numeric DEFAULT 0 CHECK (before_quantity >= 0),
ADD COLUMN IF NOT EXISTS after_quantity numeric DEFAULT 0 CHECK (after_quantity >= 0);

-- Add comments for documentation
COMMENT ON COLUMN currency_transactions.before_quantity IS 'Inventory quantity before this transaction was applied';
COMMENT ON COLUMN currency_transactions.after_quantity IS 'Inventory quantity after this transaction was applied';

-- 2. Remove channel_id column if it still exists
DROP INDEX IF EXISTS idx_currency_transactions_channel_id;
ALTER TABLE currency_transactions DROP COLUMN IF EXISTS channel_id;

-- 3. Create improved index for better query performance on inventory tracking
CREATE INDEX IF NOT EXISTS idx_currency_transactions_inventory_tracking
ON currency_transactions (game_account_id, currency_attribute_id, created_at);

-- 4. Update inventory pools unique constraint
DROP INDEX IF EXISTS idx_inventory_pools_unique_business_key;
CREATE UNIQUE INDEX idx_inventory_pools_unique_business_key
ON inventory_pools (game_account_id, currency_attribute_id, game_code, COALESCE(server_attribute_code, ''));

-- 5. Enable Row Level Security for financial tables
ALTER TABLE chart_of_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE account_balances ENABLE ROW LEVEL SECURITY;
ALTER TABLE journal_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE journal_entry_lines ENABLE ROW LEVEL SECURITY;
ALTER TABLE employee_fund_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE employee_fund_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE approval_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE approval_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE approval_actions ENABLE ROW LEVEL SECURITY;

-- 6. Create RLS policies for chart of accounts
CREATE POLICY "Anyone can view chart of accounts" ON chart_of_accounts
    FOR SELECT USING (true);

CREATE POLICY "Service role can manage chart of accounts" ON chart_of_accounts
    FOR ALL USING (auth.jwt() ->> 'role' = 'service_role');

-- 7. Create RLS policies for account balances
CREATE POLICY "Users can view own account balances" ON account_balances
    FOR SELECT USING (
        auth.uid() = entity_id
        OR EXISTS (
            SELECT 1 FROM user_role_assignments ura
            JOIN roles r ON ura.role_id = r.id
            WHERE ura.user_id = auth.uid()
            AND r.code IN ('manager', 'admin', 'accountant')
        )
    );

CREATE POLICY "Service role can manage account balances" ON account_balances
    FOR ALL USING (auth.jwt() ->> 'role' = 'service_role');

-- 8. Create RLS policies for journal entries
CREATE POLICY "Finance team can view journal entries" ON journal_entries
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM user_role_assignments ura
            JOIN roles r ON ura.role_id = r.id
            WHERE ura.user_id = auth.uid()
            AND r.code IN ('manager', 'admin', 'accountant')
        )
    );

CREATE POLICY "Service role can manage journal entries" ON journal_entries
    FOR ALL USING (auth.jwt() ->> 'role' = 'service_role');

-- 9. Create RLS policies for journal entry lines
CREATE POLICY "Finance team can view journal entry lines" ON journal_entry_lines
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM user_role_assignments ura
            JOIN roles r ON ura.role_id = r.id
            WHERE ura.user_id = auth.uid()
            AND r.code IN ('manager', 'admin', 'accountant')
        )
    );

CREATE POLICY "Service role can manage journal entry lines" ON journal_entry_lines
    FOR ALL USING (auth.jwt() ->> 'role' = 'service_role');

-- 10. Create RLS policies for employee fund accounts
CREATE POLICY "Users can view own employee fund accounts" ON employee_fund_accounts
    FOR ALL USING (auth.uid() = employee_id);

CREATE POLICY "Managers can view all employee fund accounts" ON employee_fund_accounts
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM user_role_assignments ura
            JOIN roles r ON ura.role_id = r.id
            WHERE ura.user_id = auth.uid()
            AND r.code IN ('manager', 'admin', 'accountant')
        )
    );

CREATE POLICY "Service role can manage all employee fund accounts" ON employee_fund_accounts
    FOR ALL USING (auth.jwt() ->> 'role' = 'service_role');

-- 11. Create RLS policies for employee fund transactions
CREATE POLICY "Users can view own employee fund transactions" ON employee_fund_transactions
    FOR SELECT USING (auth.uid() = employee_id);

CREATE POLICY "Managers can view all employee fund transactions" ON employee_fund_transactions
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM user_role_assignments ura
            JOIN roles r ON ura.role_id = r.id
            WHERE ura.user_id = auth.uid()
            AND r.code IN ('manager', 'admin', 'accountant')
        )
    );

CREATE POLICY "Service role can manage all employee fund transactions" ON employee_fund_transactions
    FOR ALL USING (auth.jwt() ->> 'role' = 'service_role');

-- 12. Create RLS policies for approval requests
CREATE POLICY "Users can view own approval requests" ON approval_requests
    FOR SELECT USING (auth.uid() = requested_by);

CREATE POLICY "Approvers can view assigned approval requests" ON approval_requests
    FOR SELECT USING (
        auth.uid() = current_approver
        OR EXISTS (
            SELECT 1 FROM user_role_assignments ura
            JOIN roles r ON ura.role_id = r.id
            WHERE ura.user_id = auth.uid()
            AND r.code IN ('manager', 'admin', 'accountant')
        )
    );

CREATE POLICY "Service role can manage all approval requests" ON approval_requests
    FOR ALL USING (auth.jwt() ->> 'role' = 'service_role');

-- 13. Create RLS policies for approval actions
CREATE POLICY "Users can view related approval actions" ON approval_actions
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM approval_requests ar
            WHERE ar.id = approval_request_id
            AND (ar.requested_by = auth.uid()
                 OR ar.current_approver = auth.uid()
                 OR EXISTS (
                     SELECT 1 FROM user_role_assignments ura
                     JOIN roles r ON ura.role_id = r.id
                     WHERE ura.user_id = auth.uid()
                     AND r.code IN ('manager', 'admin', 'accountant')
                 ))
        )
    );

CREATE POLICY "Service role can manage all approval actions" ON approval_actions
    FOR ALL USING (auth.jwt() ->> 'role' = 'service_role');

-- 14. Grant permissions to authenticated users
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO authenticated;

-- 15. Grant specific permissions for financial functions
GRANT EXECUTE ON FUNCTION allocate_employee_fund TO authenticated;
GRANT EXECUTE ON FUNCTION return_employee_fund TO authenticated;
GRANT EXECUTE ON FUNCTION get_employee_balance TO authenticated;
GRANT EXECUTE ON FUNCTION check_approval_required TO authenticated;
GRANT EXECUTE ON FUNCTION create_approval_request TO authenticated;
GRANT EXECUTE ON FUNCTION approve_request TO authenticated;
GRANT EXECUTE ON FUNCTION reject_request TO authenticated;
GRANT EXECUTE ON FUNCTION get_financial_summary TO authenticated;

-- 16. Grant additional permissions for managers
GRANT INSERT, UPDATE ON account_balances TO authenticated;
GRANT INSERT, UPDATE ON journal_entries TO authenticated;
GRANT INSERT, UPDATE ON journal_entry_lines TO authenticated;
GRANT INSERT, UPDATE ON employee_fund_accounts TO authenticated;
GRANT INSERT, UPDATE ON employee_fund_transactions TO authenticated;
GRANT INSERT, UPDATE ON approval_requests TO authenticated;
GRANT INSERT ON approval_actions TO authenticated;

-- 17. Create staging verification view
CREATE OR REPLACE VIEW staging_verification_view AS
SELECT
    'Chart of Accounts' as section_name,
    (SELECT COUNT(*) FROM chart_of_accounts) as count
UNION ALL
SELECT
    'Account Balances' as section_name,
    (SELECT COUNT(*) FROM account_balances) as count
UNION ALL
SELECT
    'Journal Entries' as section_name,
    (SELECT COUNT(*) FROM journal_entries) as count
UNION ALL
SELECT
    'Journal Entry Lines' as section_name,
    (SELECT COUNT(*) FROM journal_entry_lines) as count
UNION ALL
SELECT
    'Employee Fund Accounts' as section_name,
    (SELECT COUNT(*) FROM employee_fund_accounts) as count
UNION ALL
SELECT
    'Employee Fund Transactions' as section_name,
    (SELECT COUNT(*) FROM employee_fund_transactions) as count
UNION ALL
SELECT
    'Approval Rules' as section_name,
    (SELECT COUNT(*) FROM approval_rules) as count
UNION ALL
SELECT
    'Approval Requests' as section_name,
    (SELECT COUNT(*) FROM approval_requests) as count;

-- 18. Add comment for staging verification
COMMENT ON VIEW staging_verification_view IS 'Staging verification view - shows count of all financial system tables for deployment verification';

SELECT 'Final staging setup migration completed successfully!' as success_message;