-- Transfer Requests System
-- Workflow:
-- 1. COMPANY_TO_EMPLOYEE: Accountant creates request → Employee confirms → Money added
-- 2. EMPLOYEE_TO_COMPANY: Employee creates request → Accountant confirms → Money deducted
-- 3. EMPLOYEE_TO_EMPLOYEE: Sender creates request → Receiver confirms → Money transferred

-- ============================================
-- 1. CREATE transfer_requests TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS transfer_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    request_number TEXT UNIQUE NOT NULL, -- TR-2025-00001
    transfer_type TEXT NOT NULL CHECK (transfer_type IN (
        'COMPANY_TO_EMPLOYEE',  -- Accountant → Employee (allocate)
        'EMPLOYEE_TO_COMPANY',  -- Employee → Accountant (return)
        'EMPLOYEE_TO_EMPLOYEE'  -- Employee → Employee
    )),

    -- Sender (who money is FROM)
    sender_id UUID REFERENCES profiles(id),
    sender_account_type TEXT CHECK (sender_account_type IN ('purchase', 'sales', 'company')),

    -- Receiver (who money is TO)
    receiver_id UUID REFERENCES profiles(id),
    receiver_account_type TEXT CHECK (receiver_account_type IN ('purchase', 'sales', 'company')),

    -- Amount
    amount NUMERIC NOT NULL CHECK (amount > 0),
    currency_code TEXT NOT NULL DEFAULT 'VND' CHECK (currency_code IN ('VND', 'USD', 'CNY')),

    -- Status
    status TEXT NOT NULL DEFAULT 'PENDING' CHECK (status IN (
        'PENDING',        -- Waiting for confirmation
        'APPROVED',       -- Both confirmed
        'REJECTED',       -- Rejected
        'CANCELLED'       -- Cancelled by sender
    )),

    -- Confirmations
    sender_confirmed_at TIMESTAMPTZ,
    receiver_confirmed_at TIMESTAMPTZ,

    -- Rejection
    rejected_by UUID REFERENCES profiles(id),
    rejected_at TIMESTAMPTZ,
    rejection_reason TEXT,

    -- Notes
    description TEXT,
    notes TEXT,

    -- Reference
    reference_type TEXT, -- 'manual', 'salary', 'reimbursement', etc.
    reference_id UUID,

    -- Metadata
    created_by UUID NOT NULL REFERENCES profiles(id),
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),

    -- Constraints
    CONSTRAINT tr_sender_receiver_different CHECK (
        transfer_type != 'EMPLOYEE_TO_EMPLOYEE' OR sender_id != receiver_id
    )
);

-- Indexes
CREATE INDEX idx_transfer_requests_sender ON transfer_requests(sender_id);
CREATE INDEX idx_transfer_requests_receiver ON transfer_requests(receiver_id);
CREATE INDEX idx_transfer_requests_status ON transfer_requests(status);
CREATE INDEX idx_transfer_requests_type ON transfer_requests(transfer_type);
CREATE INDEX idx_transfer_requests_created ON transfer_requests(created_at DESC);

-- ============================================
-- 2. SEQUENCE for request_number
-- ============================================
CREATE SEQUENCE IF NOT EXISTS transfer_request_seq START 1;

-- ============================================
-- 3. FUNCTION: Generate request number
-- ============================================
CREATE OR REPLACE FUNCTION generate_transfer_request_number()
RETURNS TEXT AS $$
BEGIN
    RETURN 'TR-' || EXTRACT(YEAR FROM now()) || '-' ||
           LPAD(nextval('transfer_request_seq')::text, 5, '0');
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 4. FUNCTION: Create Transfer Request
-- ============================================
CREATE OR REPLACE FUNCTION create_transfer_request(
    p_transfer_type TEXT,
    p_sender_id UUID,
    p_sender_account_type TEXT,
    p_receiver_id UUID,
    p_receiver_account_type TEXT,
    p_amount NUMERIC,
    p_currency_code TEXT,
    p_description TEXT,
    p_notes TEXT,
    p_reference_type TEXT,
    p_reference_id UUID,
    p_created_by UUID
) RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    request_id UUID
) SECURITY DEFINER SET search_path = 'public'
AS $$
DECLARE
    v_request_id UUID;
    v_request_number TEXT;
    v_sender_name TEXT;
    v_receiver_name TEXT;
BEGIN
    -- Get names for logging
    SELECT display_name INTO v_sender_name
    FROM profiles WHERE id = p_sender_id;

    SELECT display_name INTO v_receiver_name
    FROM profiles WHERE id = p_receiver_id;

    -- Generate request number
    v_request_number := generate_transfer_request_number();

    -- Create request
    INSERT INTO transfer_requests (
        request_number, transfer_type,
        sender_id, sender_account_type,
        receiver_id, receiver_account_type,
        amount, currency_code,
        description, notes,
        reference_type, reference_id,
        created_by
    ) VALUES (
        v_request_number, p_transfer_type,
        p_sender_id, p_sender_account_type,
        p_receiver_id, p_receiver_account_type,
        p_amount, p_currency_code,
        p_description, p_notes,
        p_reference_type, p_reference_id,
        p_created_by
    ) RETURNING id INTO v_request_id;

    RETURN QUERY SELECT
        TRUE,
        'Transfer request created: ' || v_request_number ||
        ' (' || p_transfer_type || ': ' || v_sender_name || ' → ' || v_receiver_name || ')',
        v_request_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 5. FUNCTION: Confirm Transfer Request
-- ============================================
CREATE OR REPLACE FUNCTION confirm_transfer_request(
    p_request_id UUID,
    p_confirmer_id UUID
) RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) SECURITY DEFINER SET search_path = 'public'
AS $$
DECLARE
    v_request transfer_requests%ROWTYPE;
    v_is_sender BOOLEAN;
    v_is_receiver BOOLEAN;
    v_both_confirmed BOOLEAN;
    v_result JSON;
BEGIN
    -- Get request
    SELECT * INTO v_request
    FROM transfer_requests
    WHERE id = p_request_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'Transfer request not found';
        RETURN;
    END IF;

    IF v_request.status != 'PENDING' THEN
        RETURN QUERY SELECT FALSE, 'Request is not pending (current: ' || v_request.status || ')';
        RETURN;
    END IF;

    -- Check if confirmer is sender or receiver
    v_is_sender := v_request.sender_id = p_confirmer_id;
    v_is_receiver := v_request.receiver_id = p_confirmer_id;

    IF NOT (v_is_sender OR v_is_receiver) THEN
        RETURN QUERY SELECT FALSE, 'You are not authorized to confirm this request';
        RETURN;
    END IF;

    -- Update confirmation timestamp
    IF v_is_sender AND v_request.sender_confirmed_at IS NULL THEN
        UPDATE transfer_requests
        SET sender_confirmed_at = now(),
            updated_at = now()
        WHERE id = p_request_id;
    END IF;

    IF v_is_receiver AND v_request.receiver_confirmed_at IS NULL THEN
        UPDATE transfer_requests
        SET receiver_confirmed_at = now(),
            updated_at = now()
        WHERE id = p_request_id;
    END IF;

    -- Check if both confirmed
    SELECT
        sender_confirmed_at IS NOT NULL
        AND receiver_confirmed_at IS NOT NULL
    INTO v_both_confirmed
    FROM transfer_requests
    WHERE id = p_request_id;

    -- If both confirmed, execute the transfer
    IF v_both_confirmed THEN
        -- Update status to APPROVED
        UPDATE transfer_requests
        SET status = 'APPROVED',
            updated_at = now()
        WHERE id = p_request_id;

        -- Execute transfer based on type
        IF v_request.transfer_type = 'COMPANY_TO_EMPLOYEE' THEN
            -- Use allocate_employee_fund
            SELECT * INTO v_result FROM allocate_employee_fund(
                p_confirmer_id, -- user_id
                v_request.receiver_id, -- employee_id
                v_request.amount,
                v_request.currency_code,
                'Transfer: ' || v_request.description,
                'transfer_request',
                v_request.id,
                true -- auto_approve
            );
        ELSIF v_request.transfer_type = 'EMPLOYEE_TO_COMPANY' THEN
            -- Use return_employee_fund
            SELECT * INTO v_result FROM return_employee_fund(
                v_request.sender_id,
                v_request.amount,
                v_request.currency_code,
                'Transfer: ' || v_request.description,
                p_confirmer_id,
                'transfer_request',
                v_request.id
            );
        ELSIF v_request.transfer_type = 'EMPLOYEE_TO_EMPLOYEE' THEN
            -- Transfer from sender's sales account to receiver's purchase account
            -- Deduct from sender (sales)
            PERFORM deduct_from_purchase_account(
                v_request.sender_id,
                v_request.amount,
                v_request.currency_code,
                'Transfer to: ' || v_request.receiver_id::TEXT,
                p_confirmer_id,
                'transfer_request',
                v_request.id
            );

            -- Add to receiver (purchase) - using allocate for now
            SELECT * INTO v_result FROM allocate_employee_fund(
                p_confirmer_id,
                v_request.receiver_id,
                v_request.amount,
                v_request.currency_code,
                'Transfer from: ' || v_request.sender_id::TEXT,
                'transfer_request',
                v_request.id,
                true
            );
        END IF;

        RETURN QUERY SELECT
            TRUE,
            'Transfer approved and executed. Request: ' || v_request.request_number;
    ELSE
        RETURN QUERY SELECT
            TRUE,
            'Transfer confirmed. Waiting for other party to confirm.';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 6. FUNCTION: Reject Transfer Request
-- ============================================
CREATE OR REPLACE FUNCTION reject_transfer_request(
    p_request_id UUID,
    p_rejected_by UUID,
    p_rejection_reason TEXT
) RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) SECURITY DEFINER SET search_path = 'public'
AS $$
DECLARE
    v_request transfer_requests%ROWTYPE;
BEGIN
    -- Get request
    SELECT * INTO v_request
    FROM transfer_requests
    WHERE id = p_request_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'Transfer request not found';
        RETURN;
    END IF;

    IF v_request.status != 'PENDING' THEN
        RETURN QUERY SELECT FALSE, 'Cannot reject: request is not pending';
        RETURN;
    END IF;

    -- Only sender can cancel, receiver can reject
    IF v_request.sender_id != p_rejected_by AND v_request.receiver_id != p_rejected_by THEN
        RETURN QUERY SELECT FALSE, 'Only sender or receiver can reject/cancel this request';
        RETURN;
    END IF;

    -- Update status
    UPDATE transfer_requests
    SET status = 'REJECTED',
        rejected_by = p_rejected_by,
        rejected_at = now(),
        rejection_reason = p_rejection_reason,
        updated_at = now()
    WHERE id = p_request_id;

    RETURN QUERY SELECT
        TRUE,
        'Transfer request rejected: ' || v_request.request_number;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 7. VIEW: Transfer Requests Summary
-- ============================================
CREATE OR REPLACE VIEW transfer_requests_view AS
SELECT
    tr.id,
    tr.request_number,
    tr.transfer_type,
    tr.sender_id,
    p1.display_name as sender_name,
    tr.sender_account_type,
    tr.receiver_id,
    p2.display_name as receiver_name,
    tr.receiver_account_type,
    tr.amount,
    tr.currency_code,
    tr.status,
    tr.sender_confirmed_at,
    tr.receiver_confirmed_at,
    tr.description,
    tr.notes,
    tr.reference_type,
    tr.created_at,
    tr.created_by,
    p3.display_name as created_by_name,
    tr.rejected_by,
    p4.display_name as rejected_by_name,
    tr.rejected_at,
    tr.rejection_reason
FROM transfer_requests tr
LEFT JOIN profiles p1 ON tr.sender_id = p1.id
LEFT JOIN profiles p2 ON tr.receiver_id = p2.id
LEFT JOIN profiles p3 ON tr.created_by = p3.id
LEFT JOIN profiles p4 ON tr.rejected_by = p4.id
ORDER BY tr.created_at DESC;

-- ============================================
-- 8. HELPER FUNCTION: Get Pending Transfers for User
-- ============================================
CREATE OR REPLACE FUNCTION get_pending_transfers_for_user(p_user_id UUID)
RETURNS TABLE (
    request_id UUID,
    request_number TEXT,
    transfer_type TEXT,
    other_party_name TEXT,
    amount NUMERIC,
    currency_code TEXT,
    is_sender BOOLEAN,
    needs_confirmation BOOLEAN
) SECURITY DEFINER SET search_path = 'public'
AS $$
BEGIN
    RETURN QUERY
    SELECT
        tr.id,
        tr.request_number,
        tr.transfer_type,
        CASE
            WHEN tr.sender_id = p_user_id THEN p2.display_name
            ELSE p1.display_name
        END as other_party_name,
        tr.amount,
        tr.currency_code,
        tr.sender_id = p_user_id as is_sender,
        CASE
            WHEN tr.sender_id = p_user_id THEN tr.sender_confirmed_at IS NULL
            ELSE tr.receiver_confirmed_at IS NULL
        END as needs_confirmation
    FROM transfer_requests tr
    LEFT JOIN profiles p1 ON tr.sender_id = p1.id
    LEFT JOIN profiles p2 ON tr.receiver_id = p2.id
    WHERE tr.status = 'PENDING'
      AND (tr.sender_id = p_user_id OR tr.receiver_id = p_user_id)
      AND (
          (tr.sender_id = p_user_id AND tr.sender_confirmed_at IS NULL) OR
          (tr.receiver_id = p_user_id AND tr.receiver_confirmed_at IS NULL)
      )
    ORDER BY tr.created_at DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 9. HELPER FUNCTION: Get User Financial Summary
-- ============================================
CREATE OR REPLACE FUNCTION get_user_financial_summary(p_user_id UUID)
RETURNS TABLE (
    account_type TEXT,
    currency_code TEXT,
    current_balance NUMERIC,
    credit_limit NUMERIC,
    available_credit NUMERIC,
    pending_outgoing NUMERIC,
    pending_incoming NUMERIC
) SECURITY DEFINER SET search_path = 'public'
AS $$
BEGIN
    RETURN QUERY
    SELECT
        ef.account_type,
        ef.currency_code,
        ef.current_balance,
        ef.credit_limit,
        ef.credit_limit - ef.current_balance as available_credit,
        COALESCE(outgoing.pending_amount, 0) as pending_outgoing,
        COALESCE(incoming.pending_amount, 0) as pending_incoming
    FROM employee_fund_accounts ef
    LEFT JOIN (
        SELECT sender_account_type as account_type, currency_code, SUM(amount) as pending_amount
        FROM transfer_requests
        WHERE status = 'PENDING'
          AND sender_id = p_user_id
          AND sender_confirmed_at IS NOT NULL
          AND receiver_confirmed_at IS NULL
        GROUP BY sender_account_type, currency_code
    ) outgoing ON ef.account_type = outgoing.account_type AND ef.currency_code = outgoing.currency_code
    LEFT JOIN (
        SELECT receiver_account_type as account_type, currency_code, SUM(amount) as pending_amount
        FROM transfer_requests
        WHERE status = 'PENDING'
          AND receiver_id = p_user_id
          AND sender_confirmed_at IS NOT NULL
          AND receiver_confirmed_at IS NULL
        GROUP BY receiver_account_type, currency_code
    ) incoming ON ef.account_type = incoming.account_type AND ef.currency_code = incoming.currency_code
    WHERE ef.employee_id = p_user_id AND ef.is_active = true
    ORDER BY ef.account_type, ef.currency_code;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 10. GRANT PERMISSIONS
-- ============================================
GRANT EXECUTE ON FUNCTION create_transfer_request TO authenticated;
GRANT EXECUTE ON FUNCTION confirm_transfer_request TO authenticated;
GRANT EXECUTE ON FUNCTION reject_transfer_request TO authenticated;
GRANT EXECUTE ON FUNCTION get_pending_transfers_for_user TO authenticated;
GRANT EXECUTE ON FUNCTION get_user_financial_summary TO authenticated;
GRANT SELECT ON transfer_requests TO authenticated;
GRANT SELECT ON transfer_requests_view TO authenticated;

-- ============================================
-- 11. VERIFY SETUP
-- ============================================
SELECT
    'transfer_requests_system' as component,
    'CREATED' as status,
    'Transfer requests with workflow: COMPANY_TO_EMPLOYEE, EMPLOYEE_TO_COMPANY, EMPLOYEE_TO_EMPLOYEE'
UNION ALL
SELECT
    'functions',
    'CREATED',
    'create_transfer_request, confirm_transfer_request, reject_transfer_request, get_pending_transfers_for_user, get_user_financial_summary'
UNION ALL
SELECT
    'views',
    'CREATED',
    'transfer_requests_view';
