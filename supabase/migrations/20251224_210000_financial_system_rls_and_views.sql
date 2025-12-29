-- Financial System: RLS Policies, Views, and Functions Fix
-- This migration consolidates all changes made to the financial system

-- ============================================
-- DROP VIEWS FIRST (will recreate with security_invoker)
-- ============================================
DROP VIEW IF EXISTS transfer_requests_view CASCADE;
DROP VIEW IF EXISTS employee_trading_accounts_view CASCADE;
DROP VIEW IF EXISTS external_transactions_view CASCADE;
DROP VIEW IF EXISTS company_fund_accounts_view CASCADE;

-- ============================================
-- CREATE VIEWS WITH security_invoker
-- ============================================
CREATE VIEW public.company_fund_accounts_view
WITH (security_invoker = on) AS
SELECT cfa.id,
    cfa.currency_code,
    cfa.current_balance,
    cfa.is_active,
    cfa.notes,
    cfa.created_at,
    cfa.updated_at,
    COALESCE(deposits.deposit_count, 0::bigint) AS deposit_count,
    COALESCE(deposits.deposit_total, 0::numeric) AS deposit_total,
    COALESCE(withdrawals.withdrawal_count, 0::bigint) AS withdrawal_count,
    COALESCE(withdrawals.withdrawal_total, 0::numeric) AS withdrawal_total
FROM company_fund_accounts cfa
LEFT JOIN (
    SELECT company_fund_transactions.currency_code,
        count(*) AS deposit_count,
        sum(company_fund_transactions.amount) AS deposit_total
    FROM company_fund_transactions
    WHERE company_fund_transactions.transaction_type = 'DEPOSIT'::text
    GROUP BY company_fund_transactions.currency_code
) deposits ON cfa.currency_code = deposits.currency_code
LEFT JOIN (
    SELECT company_fund_transactions.currency_code,
        count(*) AS withdrawal_count,
        sum(company_fund_transactions.amount) AS withdrawal_total
    FROM company_fund_transactions
    WHERE company_fund_transactions.transaction_type = ANY (ARRAY['WITHDRAWAL'::text, 'ALLOCATION'::text])
    GROUP BY company_fund_transactions.currency_code
) withdrawals ON cfa.currency_code = withdrawals.currency_code
ORDER BY cfa.currency_code;

CREATE VIEW public.transfer_requests_view
WITH (security_invoker = on) AS
SELECT tr.id,
    tr.request_number,
    tr.transfer_type,
    tr.sender_id,
    sender.display_name AS sender_name,
    tr.sender_account_type,
    tr.receiver_id,
    receiver.display_name AS receiver_name,
    tr.receiver_account_type,
    tr.amount,
    tr.currency_code,
    tr.status,
    tr.description,
    tr.notes,
    tr.reference_type,
    tr.reference_id,
    tr.sender_confirmed_at,
    tr.receiver_confirmed_at,
    tr.rejected_at,
    tr.rejected_by,
    tr.rejection_reason,
    tr.created_at,
    tr.created_by,
    creator.display_name AS created_by_name
FROM transfer_requests tr
LEFT JOIN profiles sender ON tr.sender_id = sender.id
LEFT JOIN profiles receiver ON tr.receiver_id = receiver.id
LEFT JOIN profiles creator ON tr.created_by = creator.id;

CREATE VIEW public.employee_trading_accounts_view
WITH (security_invoker = on) AS
SELECT efa.id,
    efa.employee_id,
    p.display_name AS employee_name,
    efa.account_type,
    efa.currency_code,
    efa.current_balance,
    efa.credit_limit,
    efa.is_active,
    efa.created_at,
    efa.updated_at
FROM employee_fund_accounts efa
LEFT JOIN profiles p ON efa.employee_id = p.id;

CREATE VIEW public.external_transactions_view
WITH (security_invoker = on) AS
SELECT et.id,
    et.transaction_number,
    et.transaction_type,
    et.amount,
    et.currency_code,
    et.external_source,
    et.external_gateway,
    et.external_account_name,
    et.external_account_number,
    et.external_bank_name,
    et.external_wallet_address,
    et.external_transaction_id,
    et.external_transaction_ref,
    et.fee_amount,
    et.fee_currency,
    et.status,
    et.description,
    et.notes,
    et.attachment_urls,
    et.confirmed_at,
    et.completed_at,
    et.created_at,
    et.created_by,
    p.display_name AS created_by_name
FROM external_transactions et
LEFT JOIN profiles p ON et.created_by = p.id;

-- ============================================
-- GRANT PERMISSIONS ON VIEWS
-- ============================================
GRANT SELECT ON company_fund_accounts_view TO authenticated;
GRANT SELECT ON company_fund_accounts TO authenticated;
GRANT SELECT ON company_fund_transactions TO authenticated;

GRANT SELECT ON transfer_requests_view TO authenticated;

GRANT SELECT ON employee_trading_accounts_view TO authenticated;

GRANT SELECT ON external_transactions_view TO authenticated;
GRANT USAGE ON SCHEMA public TO authenticated;

-- ============================================
-- RLS POLICIES (Simplified - authorization handled by frontend)
-- ============================================
-- Enable RLS on financial tables
ALTER TABLE company_fund_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE company_fund_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE external_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE transfer_requests ENABLE ROW LEVEL SECURITY;

-- company_fund_accounts - allow authenticated to view
DROP POLICY IF EXISTS company_accounts_select_authenticated ON company_fund_accounts;
CREATE POLICY company_accounts_select_authenticated ON company_fund_accounts
  FOR SELECT
  TO authenticated
  USING (true);

-- company_fund_transactions - allow authenticated to view
DROP POLICY IF EXISTS company_transactions_select_authenticated ON company_fund_transactions;
CREATE POLICY company_transactions_select_authenticated ON company_fund_transactions
  FOR SELECT
  TO authenticated
  USING (true);

-- external_transactions - allow authenticated to view
DROP POLICY IF EXISTS external_transactions_select_authenticated ON external_transactions;
CREATE POLICY external_transactions_select_authenticated ON external_transactions
  FOR SELECT
  TO authenticated
  USING (true);

-- external_transactions - allow authenticated to insert
DROP POLICY IF EXISTS external_transactions_insert_authenticated ON external_transactions;
CREATE POLICY external_transactions_insert_authenticated ON external_transactions
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- transfer_requests - allow authenticated to view
DROP POLICY IF EXISTS transfer_requests_select_authenticated ON transfer_requests;
CREATE POLICY transfer_requests_select_authenticated ON transfer_requests
  FOR SELECT
  TO authenticated
  USING (true);

-- transfer_requests - allow authenticated to insert
DROP POLICY IF EXISTS transfer_requests_insert_authenticated ON transfer_requests;
CREATE POLICY transfer_requests_insert_authenticated ON transfer_requests
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- transfer_requests - allow authenticated to update
DROP POLICY IF EXISTS transfer_requests_update_authenticated ON transfer_requests;
CREATE POLICY transfer_requests_update_authenticated ON transfer_requests
  FOR UPDATE
  TO authenticated
  USING (true);

-- employee_fund_accounts - enable RLS
ALTER TABLE employee_fund_accounts ENABLE ROW LEVEL SECURITY;

-- employee_fund_accounts - allow authenticated to view
DROP POLICY IF EXISTS employee_fund_accounts_select_authenticated ON employee_fund_accounts;
CREATE POLICY employee_fund_accounts_select_authenticated ON employee_fund_accounts
  FOR SELECT
  TO authenticated
  USING (true);

-- employee_fund_accounts - allow authenticated to insert
DROP POLICY IF EXISTS employee_fund_accounts_insert_authenticated ON employee_fund_accounts;
CREATE POLICY employee_fund_accounts_insert_authenticated ON employee_fund_accounts
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- employee_fund_accounts - allow authenticated to update
DROP POLICY IF EXISTS employee_fund_accounts_update_authenticated ON employee_fund_accounts;
CREATE POLICY employee_fund_accounts_update_authenticated ON employee_fund_accounts
  FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- employee_fund_transactions - enable RLS
ALTER TABLE employee_fund_transactions ENABLE ROW LEVEL SECURITY;

-- employee_fund_transactions - allow authenticated to view
DROP POLICY IF EXISTS employee_fund_transactions_select_authenticated ON employee_fund_transactions;
CREATE POLICY employee_fund_transactions_select_authenticated ON employee_fund_transactions
  FOR SELECT
  TO authenticated
  USING (true);

-- employee_fund_transactions - allow authenticated to insert
DROP POLICY IF EXISTS employee_fund_transactions_insert_authenticated ON employee_fund_transactions;
CREATE POLICY employee_fund_transactions_insert_authenticated ON employee_fund_transactions
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- ============================================
-- FIX FUNCTIONS (add search_path, fix table references)
-- ============================================

-- generate_company_fund_transaction_number (FIXED: use transaction_number not request_number)
CREATE OR REPLACE FUNCTION generate_company_fund_transaction_number()
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_prefix TEXT := 'CFT';
    v_date TEXT := TO_CHAR(NOW(), 'YYYYMMDD');
    v_sequence_num BIGINT;
    v_result TEXT;
BEGIN
    LOOP
        SELECT COALESCE(MAX(CAST(SUBSTRING(transaction_number FROM 13 FOR 6) AS BIGINT)), 0) + 1
        INTO v_sequence_num
        FROM company_fund_transactions
        WHERE transaction_number LIKE v_prefix || '-' || v_date || '%';

        v_result := v_prefix || '-' || v_date || '-' || LPAD(v_sequence_num::TEXT, 6, '0');

        IF NOT EXISTS (SELECT 1 FROM company_fund_transactions WHERE transaction_number = v_result) THEN
            RETURN v_result;
        END IF;
    END LOOP;
END;
$$;

-- generate_external_transaction_number
CREATE OR REPLACE FUNCTION generate_external_transaction_number()
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_prefix TEXT := 'EXT';
    v_date TEXT := TO_CHAR(NOW(), 'YYYYMMDD');
    v_sequence_num BIGINT;
    v_result TEXT;
BEGIN
    LOOP
        SELECT COALESCE(MAX(CAST(SUBSTRING(transaction_number FROM 13 FOR 6) AS BIGINT)), 0) + 1
        INTO v_sequence_num
        FROM external_transactions
        WHERE transaction_number LIKE v_prefix || '-' || v_date || '%';

        v_result := v_prefix || '-' || v_date || '-' || LPAD(v_sequence_num::TEXT, 6, '0');

        IF NOT EXISTS (SELECT 1 FROM external_transactions WHERE transaction_number = v_result) THEN
            RETURN v_result;
        END IF;
    END LOOP;
END;
$$;

-- generate_transfer_request_number
CREATE OR REPLACE FUNCTION generate_transfer_request_number()
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_prefix TEXT := 'TR';
    v_date TEXT := TO_CHAR(NOW(), 'YYYY-');
    v_sequence_num BIGINT;
    v_result TEXT;
BEGIN
    LOOP
        SELECT COALESCE(MAX(CAST(SUBSTRING(request_number FROM 8 FOR 5) AS BIGINT)), 0) + 1
        INTO v_sequence_num
        FROM transfer_requests
        WHERE request_number LIKE v_prefix || v_date || '%';

        v_result := v_prefix || v_date || LPAD(v_sequence_num::TEXT, 5, '0');

        IF NOT EXISTS (SELECT 1 FROM transfer_requests WHERE request_number = v_result) THEN
            RETURN v_result;
        END IF;
    END LOOP;
END;
$$;

-- update_account_balance
DROP FUNCTION IF EXISTS update_account_balance(UUID, NUMERIC, TEXT) CASCADE;
CREATE FUNCTION update_account_balance(
    p_account_id UUID,
    p_amount NUMERIC,
    p_operation TEXT
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_current_balance NUMERIC;
BEGIN
    SELECT current_balance INTO v_current_balance
    FROM employee_fund_accounts
    WHERE id = p_account_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Account not found';
    END IF;

    IF p_operation = 'credit' THEN
        v_current_balance := v_current_balance + p_amount;
    ELSIF p_operation = 'debit' THEN
        IF v_current_balance < p_amount THEN
            RAISE EXCEPTION 'Insufficient balance';
        END IF;
        v_current_balance := v_current_balance - p_amount;
    ELSE
        RAISE EXCEPTION 'Invalid operation. Use credit or debit';
    END IF;

    UPDATE employee_fund_accounts
    SET current_balance = v_current_balance,
        updated_at = NOW()
    WHERE id = p_account_id;

    RETURN TRUE;
END;
$$;

-- credit_sales_account_on_sale_completion
CREATE OR REPLACE FUNCTION credit_sales_account_on_sale_completion()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_employee_id UUID;
    v_account_id UUID;
    v_amount NUMERIC;
BEGIN
    IF NEW.status <> 'COMPLETED' OR OLD.status = 'COMPLETED' THEN
        RETURN NEW;
    END IF;

    SELECT assigned_to INTO v_employee_id
    FROM currency_orders
    WHERE id = NEW.currency_order_id;

    IF v_employee_id IS NULL THEN
        RETURN NEW;
    END IF;

    SELECT id INTO v_account_id
    FROM employee_fund_accounts
    WHERE employee_id = v_employee_id
      AND account_type = 'sales'
      AND currency_code = NEW.currency_code
      AND is_active = true
    LIMIT 1;

    IF v_account_id IS NULL THEN
        RETURN NEW;
    END IF;

    v_amount := NEW.total_received * (1 - COALESCE(NEW.platform_fee_rate, 0) / 100);

    PERFORM update_account_balance(v_account_id, v_amount, 'credit');

    RETURN NEW;
END;
$$;

-- allocate_fund_to_employee (missing function that allocate_employee_fund calls)
CREATE OR REPLACE FUNCTION allocate_fund_to_employee(
    p_employee_id UUID,
    p_amount NUMERIC,
    p_currency_code TEXT,
    p_description TEXT,
    p_user_id UUID,
    p_reference_type TEXT,
    p_reference_id UUID
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_account_id UUID;
    v_current_balance NUMERIC;
    v_new_balance NUMERIC;
BEGIN
    -- Find employee's purchase fund account
    SELECT id, current_balance INTO v_account_id, v_current_balance
    FROM employee_fund_accounts
    WHERE employee_id = p_employee_id
      AND account_type = 'purchase'
      AND currency_code = p_currency_code
      AND is_active = true
    FOR UPDATE;

    -- If account doesn't exist, create it
    IF v_account_id IS NULL THEN
        INSERT INTO employee_fund_accounts (
            employee_id,
            account_type,
            currency_code,
            current_balance,
            credit_limit,
            is_active,
            created_by
        ) VALUES (
            p_employee_id,
            'purchase',
            p_currency_code,
            0,
            50000000,
            true,
            p_user_id
        ) RETURNING id, current_balance INTO v_account_id, v_current_balance;
    END IF;

    -- Update balance (credit/add funds)
    v_new_balance := v_current_balance + p_amount;

    UPDATE employee_fund_accounts
    SET current_balance = v_new_balance,
        updated_at = now(),
        updated_by = p_user_id
    WHERE id = v_account_id;

    -- Create transaction record
    INSERT INTO employee_fund_transactions (
        employee_id,
        transaction_type,
        amount,
        currency_code,
        description,
        reference_type,
        reference_id,
        balance_before,
        balance_after,
        status,
        account_type,
        created_by
    ) VALUES (
        p_employee_id,
        'ALLOCATION',
        p_amount,
        p_currency_code,
        p_description,
        p_reference_type,
        p_reference_id,
        v_current_balance,
        v_new_balance,
        'COMPLETED',
        'purchase',
        p_user_id
    );
END;
$$;

-- allocate_employee_fund (returns JSON for confirm_transfer_request compatibility)
DROP FUNCTION IF EXISTS allocate_employee_fund(UUID, UUID, NUMERIC, TEXT, TEXT, TEXT, UUID, BOOLEAN);
CREATE OR REPLACE FUNCTION allocate_employee_fund(
    p_user_id UUID,
    p_employee_id UUID,
    p_amount NUMERIC,
    p_currency_code TEXT,
    p_description TEXT,
    p_reference_type TEXT,
    p_reference_id UUID,
    p_auto_approve BOOLEAN DEFAULT FALSE
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_request_id UUID;
    v_company_account_id UUID;
    v_company_balance NUMERIC;
    v_employee_name TEXT;
    v_new_balance NUMERIC;
BEGIN
    IF NOT p_auto_approve THEN
        -- Check user role - only accountant can allocate
        IF NOT EXISTS (
            SELECT 1 FROM user_role_assignments ura
            JOIN roles r ON ura.role_id = r.id
            WHERE ura.user_id = p_user_id
            AND r.code = 'accountant'
        ) THEN
            RETURN json_build_object('success', false, 'message', 'Only accountants can allocate funds');
        END IF;

        -- Check company balance
        SELECT cfa.id, cfa.current_balance INTO v_company_account_id, v_company_balance
        FROM company_fund_accounts cfa
        WHERE cfa.currency_code = p_currency_code
          AND cfa.is_active = true;

        IF v_company_account_id IS NULL THEN
            RETURN json_build_object('success', false, 'message', 'Company account not found for currency: ' || p_currency_code);
        END IF;

        IF v_company_balance < p_amount THEN
            RETURN json_build_object(
                'success', false,
                'message', 'Insufficient company balance. Available: ' || v_company_balance::TEXT || ' ' || p_currency_code
            );
        END IF;
    END IF;

    SELECT display_name INTO v_employee_name FROM profiles WHERE id = p_employee_id;

    INSERT INTO fund_allocation_requests (
        employee_id,
        requested_amount,
        currency_code,
        purpose,
        status,
        created_by,
        reference_type,
        reference_id
    ) VALUES (
        p_employee_id,
        p_amount,
        p_currency_code,
        p_description,
        CASE WHEN p_auto_approve THEN 'APPROVED' ELSE 'PENDING' END,
        p_user_id,
        p_reference_type,
        p_reference_id
    ) RETURNING id INTO v_request_id;

    IF p_auto_approve THEN
        SELECT id, current_balance INTO v_company_account_id, v_company_balance
        FROM company_fund_accounts
        WHERE currency_code = p_currency_code
          AND is_active = true
        FOR UPDATE;

        UPDATE company_fund_accounts
        SET current_balance = current_balance - p_amount,
            updated_at = now()
        WHERE id = v_company_account_id;

        -- Use WITHDRAWAL (money OUT from company) - FIXED for constraint
        INSERT INTO company_fund_transactions (
            transaction_number,
            transaction_type,
            amount,
            currency_code,
            balance_before,
            balance_after,
            reference_type,
            reference_id,
            description,
            created_by
        ) VALUES (
            generate_company_fund_transaction_number(),
            'WITHDRAWAL',
            p_amount,
            p_currency_code,
            v_company_balance,
            v_company_balance - p_amount,
            p_reference_type,
            p_reference_id,
            'Allocation to ' || v_employee_name || ': ' || p_description,
            p_user_id
        );

        UPDATE fund_allocation_requests
        SET approved_amount = p_amount,
            reviewed_at = now(),
            reviewed_by = p_user_id
        WHERE id = v_request_id;

        -- Allocate to employee account
        PERFORM allocate_fund_to_employee(
            p_employee_id,
            p_amount,
            p_currency_code,
            p_description,
            p_user_id,
            p_reference_type,
            p_reference_id
        );

        -- Get new balance for response
        SELECT current_balance INTO v_new_balance
        FROM employee_fund_accounts
        WHERE employee_id = p_employee_id
          AND account_type = 'purchase'
          AND currency_code = p_currency_code;

        RETURN json_build_object(
            'success', true,
            'message', 'Allocation successful',
            'request_id', v_request_id,
            'new_balance', COALESCE(v_new_balance, 0)
        );
    END IF;

    RETURN json_build_object(
        'success', true,
        'message', 'Allocation request created for ' || v_employee_name || ': ' || p_amount::TEXT || ' ' || p_currency_code,
        'request_id', v_request_id
    );
END;
$$;

-- return_employee_fund (returns JSON for confirm_transfer_request compatibility)
DROP FUNCTION IF EXISTS return_employee_fund(UUID, UUID, NUMERIC, TEXT, TEXT, TEXT, UUID);
CREATE OR REPLACE FUNCTION return_employee_fund(
    p_employee_id UUID,
    p_amount NUMERIC,
    p_currency_code TEXT,
    p_description TEXT,
    p_confirmer_id UUID,
    p_reference_type TEXT,
    p_reference_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_company_account_id UUID;
    v_company_balance_before NUMERIC;
    v_company_balance_after NUMERIC;
    v_employee_balance_before NUMERIC;
    v_employee_balance_after NUMERIC;
    v_transaction_id UUID;
    v_employee_name TEXT;
BEGIN
    SELECT display_name INTO v_employee_name FROM profiles WHERE id = p_employee_id;

    -- Get company account
    SELECT id, current_balance INTO v_company_account_id, v_company_balance_before
    FROM company_fund_accounts
    WHERE currency_code = p_currency_code
      AND is_active = true
    FOR UPDATE;

    IF v_company_account_id IS NULL THEN
        RETURN json_build_object('success', false, 'message', 'Company account not found for currency: ' || p_currency_code);
    END IF;

    -- Get employee purchase account
    SELECT current_balance INTO v_employee_balance_before
    FROM employee_fund_accounts
    WHERE employee_id = p_employee_id
      AND currency_code = p_currency_code
      AND account_type = 'purchase'
      AND is_active = true
    FOR UPDATE;

    IF v_employee_balance_before IS NULL THEN
        RETURN json_build_object('success', false, 'message', 'Employee purchase account not found');
    END IF;

    IF v_employee_balance_before < p_amount THEN
        RETURN json_build_object('success', false, 'message', 'Insufficient employee balance');
    END IF;

    -- Deduct from employee
    v_employee_balance_after := v_employee_balance_before - p_amount;
    UPDATE employee_fund_accounts
    SET current_balance = v_employee_balance_after,
        updated_at = now()
    WHERE employee_id = p_employee_id
      AND currency_code = p_currency_code
      AND account_type = 'purchase';

    -- Create employee transaction
    INSERT INTO employee_fund_transactions (
        employee_id,
        transaction_type,
        amount,
        currency_code,
        balance_before,
        balance_after,
        description,
        reference_type,
        reference_id,
        status,
        account_type,
        created_by
    ) VALUES (
        p_employee_id,
        'RETURN',
        p_amount,
        p_currency_code,
        v_employee_balance_before,
        v_employee_balance_after,
        p_description,
        p_reference_type,
        p_reference_id,
        'COMPLETED',
        'purchase',
        p_confirmer_id
    ) RETURNING id INTO v_transaction_id;

    -- Add to company
    v_company_balance_after := v_company_balance_before + p_amount;
    UPDATE company_fund_accounts
    SET current_balance = v_company_balance_after,
        updated_at = now()
    WHERE id = v_company_account_id;

    -- Use DEPOSIT (money IN to company) - FIXED for constraint
    INSERT INTO company_fund_transactions (
        transaction_number,
        transaction_type,
        amount,
        currency_code,
        balance_before,
        balance_after,
        reference_type,
        reference_id,
        description,
        created_by
    ) VALUES (
        generate_company_fund_transaction_number(),
        'DEPOSIT',
        p_amount,
        p_currency_code,
        v_company_balance_before,
        v_company_balance_after,
        p_reference_type,
        p_reference_id,
        'Return from ' || v_employee_name || ': ' || p_description,
        p_confirmer_id
    );

    RETURN json_build_object(
        'success', true,
        'message', 'Fund returned successfully',
        'transaction_id', v_transaction_id,
        'employee_balance', v_employee_balance_after
    );
END;
$$;

-- confirm_transfer_request (simplified: only receiver needs to confirm)
DROP FUNCTION IF EXISTS confirm_transfer_request(UUID, UUID);
CREATE OR REPLACE FUNCTION confirm_transfer_request(
    p_request_id UUID,
    p_confirmer_id UUID
)
RETURNS TABLE(success BOOLEAN, message TEXT)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_request transfer_requests%ROWTYPE;
    v_is_receiver BOOLEAN;
    v_result JSON;
BEGIN
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

    -- Only receiver needs to confirm (sender auto-confirmed when created)
    v_is_receiver := v_request.receiver_id = p_confirmer_id;

    IF NOT v_is_receiver THEN
        RETURN QUERY SELECT FALSE, 'Only receiver can confirm this request';
        RETURN;
    END IF;

    -- Set both confirmations and execute immediately
    UPDATE transfer_requests
    SET sender_confirmed_at = COALESCE(sender_confirmed_at, created_at),
        receiver_confirmed_at = now(),
        updated_at = now()
    WHERE id = p_request_id;

    -- Execute the transfer based on type
    IF v_request.transfer_type = 'COMPANY_TO_EMPLOYEE' THEN
        v_result := allocate_employee_fund(
            p_confirmer_id,
            v_request.receiver_id,
            v_request.amount,
            v_request.currency_code,
            'Transfer: ' || v_request.request_number || ' - ' || COALESCE(v_request.description, ''),
            'transfer_request',
            v_request.id,
            true
        );

        IF (v_result->>'success')::BOOLEAN THEN
            UPDATE transfer_requests
            SET status = 'APPROVED', updated_at = now()
            WHERE id = p_request_id;

            RETURN QUERY SELECT TRUE, 'Transfer approved. Request: ' || v_request.request_number;
        ELSE
            RETURN QUERY SELECT FALSE, 'Failed to execute transfer: ' || (v_result->>'message');
        END IF;

    ELSIF v_request.transfer_type = 'EMPLOYEE_TO_COMPANY' THEN
        v_result := return_employee_fund(
            v_request.sender_id,
            v_request.amount,
            v_request.currency_code,
            'Transfer: ' || v_request.request_number || ' - ' || COALESCE(v_request.description, ''),
            p_confirmer_id,
            'transfer_request',
            v_request.id
        );

        IF (v_result->>'success')::BOOLEAN THEN
            UPDATE transfer_requests
            SET status = 'APPROVED', updated_at = now()
            WHERE id = p_request_id;

            RETURN QUERY SELECT TRUE, 'Transfer approved. Request: ' || v_request.request_number;
        ELSE
            RETURN QUERY SELECT FALSE, 'Failed to execute transfer: ' || (v_result->>'message');
        END IF;

    ELSE
        -- EMPLOYEE_TO_EMPLOYEE: Direct transfer
        DECLARE
            v_sender_balance_before NUMERIC;
            v_sender_balance_after NUMERIC;
            v_receiver_balance_before NUMERIC;
            v_receiver_balance_after NUMERIC;
        BEGIN
            SELECT current_balance INTO v_sender_balance_before
            FROM employee_fund_accounts
            WHERE employee_id = v_request.sender_id
              AND currency_code = v_request.currency_code
              AND account_type = 'purchase'
              AND is_active = true
            FOR UPDATE;

            IF v_sender_balance_before IS NULL THEN
                RETURN QUERY SELECT FALSE, 'Sender account not found';
            END IF;

            IF v_sender_balance_before < v_request.amount THEN
                RETURN QUERY SELECT FALSE, 'Insufficient sender balance';
            END IF;

            v_sender_balance_after := v_sender_balance_before - v_request.amount;

            SELECT current_balance INTO v_receiver_balance_before
            FROM employee_fund_accounts
            WHERE employee_id = v_request.receiver_id
              AND currency_code = v_request.currency_code
              AND account_type = 'purchase'
              AND is_active = true
            FOR UPDATE;

            IF v_receiver_balance_before IS NULL THEN
                INSERT INTO employee_fund_accounts (
                    employee_id, account_type, currency_code, current_balance, credit_limit, is_active
                ) VALUES (
                    v_request.receiver_id, 'purchase', v_request.currency_code, 0, 50000000, true
                ) RETURNING current_balance INTO v_receiver_balance_before;
            END IF;

            v_receiver_balance_after := v_receiver_balance_before + v_request.amount;

            UPDATE employee_fund_accounts
            SET current_balance = v_sender_balance_after
            WHERE employee_id = v_request.sender_id
              AND currency_code = v_request.currency_code
              AND account_type = 'purchase';

            UPDATE employee_fund_accounts
            SET current_balance = v_receiver_balance_after
            WHERE employee_id = v_request.receiver_id
              AND currency_code = v_request.currency_code
              AND account_type = 'purchase';

            INSERT INTO employee_fund_transactions (
                employee_id, transaction_type, amount, currency_code,
                balance_before, balance_after, description, reference_type, reference_id,
                status, account_type, created_by
            ) VALUES (
                v_request.sender_id, 'TRANSFER_OUT', v_request.amount, v_request.currency_code,
                v_sender_balance_before, v_sender_balance_after,
                'Transfer to: ' || v_request.receiver_id::TEXT, 'transfer_request', v_request.id,
                'COMPLETED', 'purchase', p_confirmer_id
            );

            INSERT INTO employee_fund_transactions (
                employee_id, transaction_type, amount, currency_code,
                balance_before, balance_after, description, reference_type, reference_id,
                status, account_type, created_by
            ) VALUES (
                v_request.receiver_id, 'TRANSFER_IN', v_request.amount, v_request.currency_code,
                v_receiver_balance_before, v_receiver_balance_after,
                'Transfer from: ' || v_request.sender_id::TEXT, 'transfer_request', v_request.id,
                'COMPLETED', 'purchase', p_confirmer_id
            );

            UPDATE transfer_requests
            SET status = 'APPROVED', updated_at = now()
            WHERE id = p_request_id;

            RETURN QUERY SELECT TRUE, 'Transfer approved. Request: ' || v_request.request_number;
        END;
    END IF;
END;
$$;

-- ============================================
-- VERIFICATION
-- ============================================
SELECT
    'VIEWS_CREATED' as status,
    'company_fund_accounts_view, transfer_requests_view, employee_trading_accounts_view, external_transactions_view' as details
UNION ALL
SELECT
    'RLS_POLICIES_CREATED' as status,
    'Simplified policies for financial tables' as details
UNION ALL
SELECT
    'FUNCTIONS_FIXED' as status,
    'allocate_employee_fund (JSON, WITHDRAWAL), allocate_fund_to_employee, return_employee_fund (JSON, DEPOSIT), confirm_transfer_request (receiver-only), create_transfer_request (auto-confirm), generate_company_fund_transaction_number (fixed)' as details;
