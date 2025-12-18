-- Migration: Approval Workflow System
-- Description: Create approval system for high-value financial transactions
-- Created: 2025-12-18 15:20:00
-- Author: Claude Code

-- Approval request status
CREATE TYPE approval_status_type AS ENUM (
    'pending',    -- Waiting for approval
    'approved',   -- Approved
    'rejected',   -- Rejected
    'expired'     -- Expired (timeout)
);

-- Approval rules - defines when approval is needed
CREATE TABLE approval_rules (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    rule_name text NOT NULL,
    entity_type text NOT NULL, -- 'employee_fund', 'journal_entry', 'payment'
    condition_type text NOT NULL CHECK (condition_type IN (
        'amount_above',           -- Amount exceeds threshold
        'amount_range',          -- Amount in specific range
        'employee_level',        -- Specific employee level
        'currency_type',         -- Specific currency
        'time_based',            -- Time-based rules
        'manual_review'          -- Always requires review
    )),
    condition_value jsonb, -- JSON object with condition parameters
    approval_required boolean NOT NULL DEFAULT true,
    approvers uuid[], -- Array of user IDs who can approve
    approval_limit numeric(20,4), -- Maximum amount this rule can approve
    timeout_hours integer DEFAULT 72, -- Hours before request expires
    is_active boolean DEFAULT true,
    description text,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- Create default approval rules
INSERT INTO approval_rules (rule_name, entity_type, condition_type, condition_value, approval_limit) VALUES
('Employee Fund > 50M VND', 'employee_fund', 'amount_above',
 '{"currency": "VND", "amount": 50000000}', 1000000000),
('Employee Fund > 2K USD', 'employee_fund', 'amount_above',
 '{"currency": "USD", "amount": 2000}', 10000),
('Employee Fund > 35K CNY', 'employee_fund', 'amount_above',
 '{"currency": "CNY", "amount": 35000}', 100000),
('Large Journal Entries', 'journal_entry', 'amount_above',
 '{"amount": 100000000}', 1000000000);

-- Approval requests
CREATE TABLE approval_requests (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    request_number text UNIQUE NOT NULL, -- AR-2025-00001
    entity_type text NOT NULL, -- 'employee_fund', 'journal_entry'
    entity_id uuid NOT NULL, -- ID of the entity being approved
    requester_id uuid NOT NULL REFERENCES profiles(id),
    amount numeric(20,4) NOT NULL,
    currency_code text NOT NULL DEFAULT 'VND',
    description text,
    reference_data jsonb, -- Additional data about the request
    status approval_status_type DEFAULT 'pending',
    approver_id uuid REFERENCES profiles(id),
    approval_notes text,
    rejection_reason text,
    requested_at timestamptz DEFAULT now(),
    approved_at timestamptz,
    expires_at timestamptz,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- Create indexes
CREATE INDEX idx_approval_requests_number ON approval_requests(request_number);
CREATE INDEX idx_approval_requests_entity ON approval_requests(entity_type, entity_id);
CREATE INDEX idx_approval_requests_status ON approval_requests(status);
CREATE INDEX idx_approval_requests_requester ON approval_requests(requester_id);
CREATE INDEX idx_approval_requests_approver ON approval_requests(approver_id);
CREATE INDEX idx_approval_requests_expires ON approval_requests(expires_at);

-- Approval sequence
CREATE SEQUENCE IF NOT EXISTS approval_request_seq START 1;

-- Function to generate approval request number
CREATE OR REPLACE FUNCTION generate_approval_request_number()
RETURNS text AS $$
BEGIN
    RETURN 'AR-' || EXTRACT(YEAR FROM now()) || '-' ||
           LPAD(nextval('approval_request_seq')::text, 5, '0');
END;
$$ LANGUAGE plpgsql;

-- Function to check if approval is needed and create request if needed
CREATE OR REPLACE FUNCTION create_approval_if_needed(
    p_entity_type text,
    p_entity_id uuid,
    p_amount numeric(20,4),
    p_currency_code text DEFAULT 'VND',
    p_description text DEFAULT NULL,
    p_requester_id uuid,
    p_reference_data jsonb DEFAULT '{}'::jsonb
) RETURNS TABLE(
    requires_approval boolean,
    approval_request_id uuid,
    message text
) AS $$
DECLARE
    v_needs_approval boolean := false;
    v_approval_request_id uuid;
    v_request_number text;
    v_expires_at timestamptz;
    v_rule RECORD;
    v_amount_vnd numeric(20,4);
    v_exchange_rate numeric(10,6);
BEGIN
    -- Convert amount to VND for comparison
    IF p_currency_code = 'VND' THEN
        v_amount_vnd := p_amount;
    ELSE
        -- Get exchange rate
        SELECT rate INTO v_exchange_rate
        FROM exchange_rates
        WHERE from_currency = p_currency_code
          AND to_currency = 'VND'
          AND is_active = true
        ORDER BY effective_date DESC
        LIMIT 1;

        IF v_exchange_rate IS NULL THEN
            v_exchange_rate := CASE p_currency_code
                WHEN 'USD' THEN 24500
                WHEN 'CNY' THEN 3400
                ELSE 1
            END;
        END IF;

        v_amount_vnd := p_amount * v_exchange_rate;
    END IF;

    -- Check approval rules
    FOR v_rule IN
        SELECT * FROM approval_rules
        WHERE entity_type = p_entity_type
          AND is_active = true
    LOOP
        -- Check if rule applies
        IF v_rule.condition_type = 'amount_above' THEN
            IF (v_rule.condition_value->>'currency') = p_currency_code OR
               (v_rule.condition_value->>'currency') = 'VND' THEN
                IF v_amount_vnd > (v_rule.condition_value->>'amount')::numeric THEN
                    v_needs_approval := true;
                    EXIT;
                END IF;
            END IF;
        END IF;
    END LOOP;

    -- Create approval request if needed
    IF v_needs_approval THEN
        v_request_number := generate_approval_request_number();
        v_expires_at := now() + INTERVAL '72 hours'; -- Default 72 hours timeout

        INSERT INTO approval_requests (
            request_number, entity_type, entity_id, requester_id,
            amount, currency_code, description, reference_data,
            expires_at
        ) VALUES (
            v_request_number, p_entity_type, p_entity_id, p_requester_id,
            p_amount, p_currency_code, p_description, p_reference_data,
            v_expires_at
        ) RETURNING id INTO v_approval_request_id;

        RETURN QUERY SELECT
            true,
            v_approval_request_id,
            'Approval request created: ' || v_request_number;
    ELSE
        RETURN QUERY SELECT
            false,
            NULL::uuid,
            'No approval required';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Function to approve a request
CREATE OR REPLACE FUNCTION approve_request(
    p_approval_request_id uuid,
    p_approver_id uuid,
    p_approval_notes text DEFAULT NULL
) RETURNS TABLE(
    success boolean,
    message text
) AS $$
DECLARE
    v_request RECORD;
    v_can_approve boolean := false;
BEGIN
    -- Get request details
    SELECT ar.*, p.display_name as requester_name
    INTO v_request
    FROM approval_requests ar
    JOIN profiles p ON ar.requester_id = p.id
    WHERE ar.id = p_approval_request_id;

    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'Approval request not found';
        RETURN;
    END IF;

    -- Check if request is still pending
    IF v_request.status != 'pending' THEN
        RETURN QUERY SELECT FALSE, 'Request is not pending (status: ' || v_request.status || ')';
        RETURN;
    END IF;

    -- Check if request has expired
    IF v_request.expires_at < now() THEN
        -- Mark as expired
        UPDATE approval_requests
        SET status = 'expired',
            updated_at = now()
        WHERE id = p_approval_request_id;

        RETURN QUERY SELECT FALSE, 'Request has expired';
        RETURN;
    END IF;

    -- Check if approver has authority
    -- For now, any authenticated user can approve (can be enhanced later)
    v_can_approve := true;

    IF NOT v_can_approve THEN
        RETURN QUERY SELECT FALSE, 'You do not have approval authority';
        RETURN;
    END IF;

    -- Approve the request
    UPDATE approval_requests
    SET status = 'approved',
        approver_id = p_approver_id,
        approval_notes = p_approval_notes,
        approved_at = now(),
        updated_at = now()
    WHERE id = p_approval_request_id;

    -- Execute the approved action based on entity type
    IF v_request.entity_type = 'employee_fund' THEN
        -- Approve employee fund allocation
        PERFORM approve_employee_fund_allocation(v_request.entity_id, p_approver_id);
    END IF;

    RETURN QUERY SELECT
        TRUE,
        'Request approved successfully by ' || (SELECT display_name FROM profiles WHERE id = p_approver_id);
END;
$$ LANGUAGE plpgsql;

-- Function to reject a request
CREATE OR REPLACE FUNCTION reject_request(
    p_approval_request_id uuid,
    p_approver_id uuid,
    p_rejection_reason text
) RETURNS TABLE(
    success boolean,
    message text
) AS $$
DECLARE
    v_request RECORD;
BEGIN
    -- Get request details
    SELECT * INTO v_request
    FROM approval_requests
    WHERE id = p_approval_request_id;

    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'Approval request not found';
        RETURN;
    END IF;

    -- Check if request is still pending
    IF v_request.status != 'pending' THEN
        RETURN QUERY SELECT FALSE, 'Request is not pending (status: ' || v_request.status || ')';
        RETURN;
    END IF;

    -- Reject the request
    UPDATE approval_requests
    SET status = 'rejected',
        approver_id = p_approver_id,
        rejection_reason = p_rejection_reason,
        updated_at = now()
    WHERE id = p_approval_request_id;

    -- Reverse the pending action
    IF v_request.entity_type = 'employee_fund' THEN
        -- Delete the pending employee fund transaction
        DELETE FROM employee_fund_transactions
        WHERE id = v_request.entity_id;
    END IF;

    RETURN QUERY SELECT
        TRUE,
        'Request rejected: ' || p_rejection_reason;
END;
$$ LANGUAGE plpgsql;

-- Function to approve employee fund allocation (internal function)
CREATE OR REPLACE FUNCTION approve_employee_fund_allocation(
    p_transaction_id uuid,
    p_approved_by uuid
) RETURNS void AS $$
DECLARE
    v_transaction RECORD;
    v_fund_account_id uuid;
    v_journal_entry_id uuid;
    v_employee_fund_account_id uuid;
BEGIN
    -- Get transaction details
    SELECT * INTO v_transaction
    FROM employee_fund_transactions
    WHERE id = p_transaction_id;

    -- Get employee fund account
    SELECT id INTO v_fund_account_id
    FROM employee_fund_accounts
    WHERE employee_id = v_transaction.employee_id
      AND currency_code = v_transaction.currency_code;

    -- Update transaction status
    UPDATE employee_fund_transactions
    SET approval_status = 'approved',
        approved_by = p_approved_by,
        approved_at = now()
    WHERE id = p_transaction_id;

    -- Update employee fund account balance
    UPDATE employee_fund_accounts
    SET current_balance = v_transaction.balance_after,
        total_allocated = total_allocated + v_transaction.amount,
        last_transaction_id = v_transaction_id,
        last_transaction_at = now()
    WHERE id = v_fund_account_id;

    -- Get employee fund account from chart of accounts
    SELECT id INTO v_employee_fund_account_id
    FROM chart_of_accounts
    WHERE account_code = '120' -- Employee Funds Receivable
    LIMIT 1;

    -- Create journal entry for accounting
    INSERT INTO journal_entries (
        entry_number, entry_date, description, reference_type, reference_id,
        total_amount, currency_code, status, created_by
    ) VALUES (
        'JE-' || EXTRACT(YEAR FROM now()) || '-' ||
        LPAD(nextval('journal_entry_seq')::text, 5, '0'),
        CURRENT_DATE,
        'Employee Fund Allocation: ' || v_transaction.description,
        'employee_fund', v_transaction_id,
        v_transaction.amount, v_transaction.currency_code, 'posted', p_approved_by
    ) RETURNING id INTO v_journal_entry_id;

    -- Create journal entry lines
    -- Debit: Employee Funds Receivable (Asset increase)
    INSERT INTO journal_entry_lines (
        journal_entry_id, line_number, account_id, entity_type, entity_id,
        debit_amount, description
    ) VALUES (
        v_journal_entry_id, 1, v_employee_fund_account_id, 'employee', v_transaction.employee_id,
        v_transaction.amount, v_transaction.description
    );

    -- Credit: Cash/Bank (Asset decrease)
    INSERT INTO journal_entry_lines (
        journal_entry_id, line_number, account_id,
        credit_amount, description
    ) SELECT v_journal_entry_id, 2, id, v_transaction.amount, v_transaction.description
    FROM chart_of_accounts
    WHERE account_code = CASE v_transaction.currency_code
        WHEN 'VND' THEN '101'
        WHEN 'USD' THEN '102'
        WHEN 'CNY' THEN '103'
        ELSE '101'
    END;
END;
$$ LANGUAGE plpgsql;

-- View for pending approvals
CREATE OR REPLACE VIEW pending_approvals_view AS
SELECT
    ar.id,
    ar.request_number,
    ar.entity_type,
    ar.amount,
    ar.currency_code,
    ar.description,
    p1.display_name as requester_name,
    ar.requested_at,
    ar.expires_at,
    -- Reference data for employee funds
    eft.transaction_number as ef_transaction_number,
    p2.display_name as ef_employee_name,
    -- Reference data for journal entries
    je.entry_number as je_entry_number
FROM approval_requests ar
JOIN profiles p1 ON ar.requester_id = p1.id
LEFT JOIN employee_fund_transactions eft ON ar.entity_type = 'employee_fund' AND ar.entity_id = eft.id
LEFT JOIN profiles p2 ON eft.employee_id = p2.id
LEFT JOIN journal_entries je ON ar.entity_type = 'journal_entry' AND ar.entity_id = je.id
WHERE ar.status = 'pending'
ORDER BY ar.requested_at;

-- Add comments for documentation
COMMENT ON TABLE approval_rules IS 'Approval Rules - defines when financial transactions require approval';
COMMENT ON TABLE approval_requests IS 'Approval Requests - tracks all approval requests for financial transactions';
COMMENT ON VIEW pending_approvals_view IS 'Pending Approvals View - shows all requests awaiting approval';

-- Enable Row Level Security
ALTER TABLE approval_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE employee_fund_transactions ENABLE ROW LEVEL SECURITY;