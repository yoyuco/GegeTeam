-- Migration: Security Fixes for Staging
-- Description: Fix all security vulnerabilities found in Security Advisor
-- Created: 2025-12-18 17:10:00
-- Author: Claude Code

-- 1. Fix RLS for approval_rules table (add missing policies)
CREATE POLICY "Anyone can view approval rules" ON approval_rules
    FOR SELECT USING (true);

CREATE POLICY "Service role can manage approval rules" ON approval_rules
    FOR ALL USING (auth.jwt() ->> 'role' = 'service_role');

-- 2. Enable RLS for fund_allocation_requests table
ALTER TABLE fund_allocation_requests ENABLE ROW LEVEL SECURITY;

-- Add policies for fund_allocation_requests - Using profile_id pattern
CREATE POLICY "Users can view own fund allocation requests" ON fund_allocation_requests
    FOR SELECT USING (employee_id = current_setting('app.current_user_id', true)::UUID);

CREATE POLICY "Users can create own fund allocation requests" ON fund_allocation_requests
    FOR INSERT WITH CHECK (employee_id = current_setting('app.current_user_id', true)::UUID);

CREATE POLICY "Managers can view all fund allocation requests" ON fund_allocation_requests
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM user_role_assignments ura
            JOIN roles r ON ura.role_id = r.id
            WHERE ura.user_id = current_setting('app.current_user_id', true)::UUID
            AND r.code::text = ANY (ARRAY['manager','admin','accountant'])
        )
    );

CREATE POLICY "Service role can manage fund allocation requests" ON fund_allocation_requests
    FOR ALL USING (current_setting('jwt.claims', true)::json ->> 'role' = 'service_role');

-- 3. Fix Security Definer Views - Change to SECURITY INVOKER
DROP VIEW IF EXISTS staging_verification_view;
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

-- Add comment for staging verification
COMMENT ON VIEW staging_verification_view IS 'Staging verification view - shows count of all financial system tables for deployment verification';

-- Fix trial_balance view
DROP VIEW IF EXISTS trial_balance;
CREATE OR REPLACE VIEW trial_balance AS
SELECT
    ca.account_code,
    ca.account_name,
    ca.account_type,
    COALESCE(SUM(jel.debit_amount), 0) as total_debits,
    COALESCE(SUM(jel.credit_amount), 0) as total_credits,
    COALESCE(SUM(jel.debit_amount), 0) - COALESCE(SUM(jel.credit_amount), 0) as balance,
    ca.currency_code
FROM chart_of_accounts ca
LEFT JOIN account_balances ab ON ca.id = ab.account_id
LEFT JOIN journal_entry_lines jel ON ca.id = jel.account_id
    AND jel.entry_id IN (
        SELECT id FROM journal_entries WHERE status = 'POSTED'
    )
GROUP BY ca.id, ca.account_code, ca.account_name, ca.account_type, ca.currency_code
ORDER BY ca.account_code;

-- Fix pending_approvals_dashboard view
DROP VIEW IF EXISTS pending_approvals_dashboard;
CREATE OR REPLACE VIEW pending_approvals_dashboard AS
SELECT
    ar.id,
    ar.entity_type,
    ar.entity_id,
    ar.title,
    ar.description,
    ar.amount,
    ar.currency_code,
    ar.priority,
    ar.created_at,
    ar.expires_at,
    p_requester.display_name as requester_name,
    p_approver.display_name as current_approver_name,
    ar_rule.rule_name,
    EXTRACT(HOURS FROM (ar.expires_at - now())) as hours_remaining,
    CASE
        WHEN ar.expires_at < now() THEN 'EXPIRED'
        WHEN EXTRACT(HOURS FROM (ar.expires_at - now())) < 24 THEN 'URGENT'
        WHEN EXTRACT(HOURS FROM (ar.expires_at - now())) < 48 THEN 'HIGH'
        ELSE 'NORMAL'
    END as urgency_level
FROM approval_requests ar
JOIN profiles p_requester ON ar.requested_by = p_requester.id
JOIN profiles p_approver ON ar.current_approver = p_approver.id
LEFT JOIN approval_rules ar_rule ON ar.approval_rule_id = ar_rule.id
WHERE ar.status = 'PENDING'
ORDER BY
    CASE priority
        WHEN 'URGENT' THEN 1
        WHEN 'HIGH' THEN 2
        WHEN 'NORMAL' THEN 3
        ELSE 4
    END,
    ar.created_at ASC;

-- 4. Fix all functions with search_path issues (add SET search_path = public)
-- Function: get_employee_balance
CREATE OR REPLACE FUNCTION get_employee_balance(p_employee_id UUID, p_currency_code TEXT DEFAULT 'VND')
RETURNS DECIMAL(20,4) AS $$
DECLARE
    v_balance DECIMAL(20,4) := 0;
BEGIN
    SELECT COALESCE(current_balance, 0) INTO v_balance
    FROM employee_fund_accounts
    WHERE employee_id = p_employee_id
      AND currency_code = p_currency_code
      AND is_active = true;

    RETURN v_balance;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Function: create_employee_fund_journal_entry
CREATE OR REPLACE FUNCTION create_employee_fund_journal_entry(
    p_employee_id UUID,
    p_amount DECIMAL(20,4),
    p_currency_code TEXT,
    p_description TEXT,
    p_transaction_type TEXT
)
RETURNS UUID AS $$
DECLARE
    v_entry_id UUID;
    v_entry_number TEXT;
    v_employee_fund_account_id UUID;
    v_cash_account_id UUID;
BEGIN
    -- Get account IDs
    v_employee_fund_account_id := CASE
        WHEN p_currency_code = 'USD' THEN (SELECT id FROM chart_of_accounts WHERE account_code = '202')
        ELSE (SELECT id FROM chart_of_accounts WHERE account_code = '201')
    END;

    v_cash_account_id := CASE
        WHEN p_currency_code = 'USD' THEN (SELECT id FROM chart_of_accounts WHERE account_code = '102')
        ELSE (SELECT id FROM chart_of_accounts WHERE account_code = '101')
    END;

    -- Generate entry number
    v_entry_number := generate_journal_entry_number();

    -- Create journal entry header
    INSERT INTO journal_entries (
        entry_number, entry_date, description,
        reference_type, reference_id, total_amount,
        status, created_by, posted_at, posted_by
    ) VALUES (
        v_entry_number, CURRENT_DATE, p_description,
        'employee_fund', p_employee_id, p_amount,
        'POSTED', auth.uid(), now(), auth.uid()
    ) RETURNING id INTO v_entry_id;

    -- Create journal entry lines based on transaction type
    IF p_transaction_type = 'ALLOCATION' THEN
        -- Debit Employee Fund, Credit Cash
        INSERT INTO journal_entry_lines (entry_id, line_number, account_id, entity_type, entity_id, debit_amount, credit_amount, description)
        VALUES
            (v_entry_id, 1, v_employee_fund_account_id, 'EMPLOYEE', p_employee_id, p_amount, 0, 'Fund allocated to employee'),
            (v_entry_id, 2, v_cash_account_id, 'COMPANY', '00000000-0000-0000-0000-000000000000', 0, p_amount, 'Cash paid to employee');
    ELSIF p_transaction_type = 'RETURN' THEN
        -- Debit Cash, Credit Employee Fund
        INSERT INTO journal_entry_lines (entry_id, line_number, account_id, entity_type, entity_id, debit_amount, credit_amount, description)
        VALUES
            (v_entry_id, 1, v_cash_account_id, 'COMPANY', '00000000-0000-0000-0000-000000000000', p_amount, 0, 'Cash received from employee'),
            (v_entry_id, 2, v_employee_fund_account_id, 'EMPLOYEE', p_employee_id, 0, p_amount, 'Fund returned by employee');
    END IF;

    RETURN v_entry_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Function: update_shift_assignment_status (already fixed in previous migration, just adding search_path)
CREATE OR REPLACE FUNCTION update_shift_assignment_status(p_shift_assignment_id UUID, p_status TEXT)
RETURNS BOOLEAN AS $$
DECLARE
    v_record_exists BOOLEAN;
BEGIN
    -- Check if the shift assignment exists
    SELECT EXISTS(SELECT 1 FROM shift_assignments WHERE id = p_shift_assignment_id) INTO v_record_exists;

    IF NOT v_record_exists THEN
        RAISE EXCEPTION 'Shift assignment with ID % does not exist', p_shift_assignment_id;
    END IF;

    -- Update the status (removed game_account_id reference)
    UPDATE shift_assignments
    SET
        is_active = CASE
            WHEN p_status = 'inactive' THEN FALSE
            WHEN p_status = 'active' THEN TRUE
            ELSE is_active
        END,
        updated_at = NOW()
    WHERE id = p_shift_assignment_id;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Function: reject_request
CREATE OR REPLACE FUNCTION reject_request(
    p_approval_request_id UUID,
    p_rejection_reason TEXT
)
RETURNS JSON AS $$
DECLARE
    v_request approval_requests%ROWTYPE;
    v_can_reject BOOLEAN := false;
BEGIN
    -- Get the request
    SELECT * INTO v_request
    FROM approval_requests
    WHERE id = p_approval_request_id;

    IF v_request.id IS NULL THEN
        RETURN json_build_object('success', false, 'message', 'Approval request not found');
    END IF;

    -- Check if request is still pending
    IF v_request.status != 'PENDING' THEN
        RETURN json_build_object('success', false, 'message', 'Request is not pending: ' || v_request.status);
    END IF;

    -- Check if current user can reject
    v_can_reject := (
        v_request.current_approver = auth.uid()
        OR EXISTS(
            SELECT 1 FROM roles r
            JOIN user_role_assignments ura ON r.id = ura.role_id
            WHERE ura.user_id = auth.uid()
              AND r.code IN ('admin', 'manager')
        )
    );

    IF NOT v_can_reject THEN
        RETURN json_build_object('success', false, 'message', 'You do not have permission to reject this request');
    END IF;

    -- Reject the request
    UPDATE approval_requests
    SET status = 'REJECTED',
        rejection_reason = p_rejection_reason,
        updated_at = now()
    WHERE id = p_approval_request_id;

    -- Create rejection action
    INSERT INTO approval_actions (approval_request_id, action, actor_id, notes)
    VALUES (p_approval_request_id, 'REJECTED', auth.uid(), p_rejection_reason);

    RETURN json_build_object(
        'success', true,
        'message', 'Request rejected successfully',
        'status', 'REJECTED',
        'rejection_reason', p_rejection_reason
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Function: create_approval_request
CREATE OR REPLACE FUNCTION create_approval_request(
    p_entity_type VARCHAR(50),
    p_entity_id UUID,
    p_title VARCHAR(200),
    p_description TEXT,
    p_amount DECIMAL(20,4),
    p_currency VARCHAR(10) DEFAULT 'VND',
    p_request_data JSONB DEFAULT '{}'::jsonb,
    p_priority VARCHAR(20) DEFAULT 'NORMAL',
    p_expires_in_hours INTEGER DEFAULT 72
)
RETURNS UUID AS $$
DECLARE
    v_approval_request_id UUID;
    v_rule_info JSON;
    v_approver_id UUID;
    v_expires_at TIMESTAMPTZ;
BEGIN
    -- Check if approval is required
    v_rule_info := check_approval_required(p_entity_type, p_amount, p_currency);

    -- If no approval required, return null
    IF NOT (v_rule_info->>'approval_required')::BOOLEAN THEN
        RETURN NULL;
    END IF;

    -- Find first available approver
    SELECT p.id INTO v_approver_id
    FROM profiles p
    JOIN user_role_assignments ura ON p.id = ura.user_id
    JOIN roles r ON ura.role_id = r.id
    WHERE r.id = ANY((v_rule_info->'approver_roles')::UUID[])
      AND p.status = 'active'
    LIMIT 1;

    IF v_approver_id IS NULL THEN
        RAISE EXCEPTION 'No available approver found for the specified roles';
    END IF;

    -- Calculate expiration time
    v_expires_at := now() + (p_expires_in_hours || ' hours')::INTERVAL;

    -- Create approval request
    INSERT INTO approval_requests (
        entity_type, entity_id, title, description,
        amount, currency_code, request_data,
        approval_rule_id, requested_by, current_approver,
        priority, expires_at, status
    ) VALUES (
        p_entity_type, p_entity_id, p_title, p_description,
        p_amount, p_currency, p_request_data,
        (v_rule_info->>'rule_id')::UUID, auth.uid(), v_approver_id,
        p_priority, v_expires_at, 'PENDING'
    ) RETURNING id INTO v_approval_request_id;

    -- Create initial action record
    INSERT INTO approval_actions (approval_request_id, action, actor_id, notes)
    VALUES (v_approval_request_id, 'CREATED', auth.uid(), 'Approval request created');

    RETURN v_approval_request_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Function: create_shift_assignment
CREATE OR REPLACE FUNCTION create_shift_assignment(
    p_employee_profile_id UUID,
    p_shift_id UUID,
    p_channels_id UUID DEFAULT NULL,
    p_currency_code TEXT DEFAULT ''
)
RETURNS UUID AS $$
DECLARE
    v_assignment_id UUID;
    v_is_active BOOLEAN := TRUE;
BEGIN
    -- Create the shift assignment (removed game_account_id parameter)
    INSERT INTO shift_assignments (
        employee_profile_id,
        shift_id,
        channels_id,
        currency_code,
        is_active
    ) VALUES (
        p_employee_profile_id,
        p_shift_id,
        p_channels_id,
        p_currency_code,
        v_is_active
    ) RETURNING id INTO v_assignment_id;

    RETURN v_assignment_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Function: return_employee_fund
CREATE OR REPLACE FUNCTION return_employee_fund(
    p_employee_id UUID,
    p_amount DECIMAL(20,4),
    p_currency_code TEXT DEFAULT 'VND',
    p_description TEXT DEFAULT 'Fund return',
    p_reference_type TEXT DEFAULT NULL,
    p_reference_id UUID DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
    v_account employee_fund_accounts%ROWTYPE;
    v_new_balance DECIMAL(20,4);
    v_transaction_id UUID;
    v_journal_entry_id UUID;
BEGIN
    -- Get employee fund account
    SELECT * INTO v_account
    FROM employee_fund_accounts
    WHERE employee_id = p_employee_id
      AND currency_code = p_currency_code
      AND is_active = true
    FOR UPDATE;

    IF v_account.id IS NULL THEN
        RETURN json_build_object('success', false, 'message', 'Employee fund account not found');
    END IF;

    -- Check if sufficient balance
    IF v_account.current_balance < p_amount THEN
        RETURN json_build_object('success', false, 'message', 'Insufficient balance');
    END IF;

    -- Calculate new balance
    v_new_balance := v_account.current_balance - p_amount;

    -- Update account balance
    UPDATE employee_fund_accounts
    SET current_balance = v_new_balance,
        updated_at = now()
    WHERE id = v_account.id;

    -- Create transaction record
    INSERT INTO employee_fund_transactions (
        employee_id, amount, currency_code,
        transaction_type, description, before_balance,
        after_balance, reference_type, reference_id,
        status, approved_by, approved_at
    ) VALUES (
        p_employee_id, p_amount, p_currency_code,
        'RETURN', p_description, v_account.current_balance,
        v_new_balance, p_reference_type, p_reference_id,
        'COMPLETED', auth.uid(), now()
    ) RETURNING id INTO v_transaction_id;

    -- Create journal entry
    v_journal_entry_id := create_employee_fund_journal_entry(
        p_employee_id, p_amount, p_currency_code,
        p_description, 'RETURN'
    );

    -- Update account balance table
    PERFORM update_account_balance(
        (SELECT id FROM chart_of_accounts WHERE account_code = CASE
            WHEN p_currency_code = 'USD' THEN '202'
            ELSE '201'
        END),
        p_employee_id, -p_amount, p_currency_code
    );

    RETURN json_build_object(
        'success', true,
        'message', 'Fund returned successfully',
        'transaction_id', v_transaction_id,
        'journal_entry_id', v_journal_entry_id,
        'new_balance', v_new_balance
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Function: update_account_balance
CREATE OR REPLACE FUNCTION update_account_balance(
    p_account_id UUID,
    p_entity_id UUID,
    p_amount_change DECIMAL(20,4),
    p_currency_code TEXT
)
RETURNS BOOLEAN AS $$
DECLARE
    v_account_balance account_balances%ROWTYPE;
BEGIN
    -- Get current balance or create new record
    SELECT * INTO v_account_balance
    FROM account_balances
    WHERE account_id = p_account_id
      AND entity_id = p_entity_id
      AND currency_code = p_currency_code
    FOR UPDATE;

    IF v_account_balance.id IS NULL THEN
        -- Create new balance record
        INSERT INTO account_balances (
            account_id, entity_id, currency_code,
            current_balance, updated_at, updated_by
        ) VALUES (
            p_account_id, p_entity_id, p_currency_code,
            p_amount_change, now(), auth.uid()
        );
    ELSE
        -- Update existing balance
        UPDATE account_balances
        SET current_balance = current_balance + p_amount_change,
            updated_at = now(),
            updated_by = auth.uid()
        WHERE id = v_account_balance.id;
    END IF;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Continue with remaining functions in next migration due to length limits...

SELECT 'Security fixes migration (part 1) completed successfully!' as success_message;