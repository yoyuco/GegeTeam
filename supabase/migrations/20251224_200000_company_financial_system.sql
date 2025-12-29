-- Company Financial System
-- This migration creates:
-- 1. Company fund accounts (VND, USD, CNY)
-- 2. External transactions (deposit/withdrawal from banks, payment gateways)
-- 3. Functions to manage company money properly

-- ============================================
-- 1. CREATE company_fund_accounts TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS company_fund_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    currency_code TEXT NOT NULL CHECK (currency_code IN ('VND', 'USD', 'CNY')),
    current_balance NUMERIC NOT NULL DEFAULT 0 CHECK (current_balance >= 0),

    -- Metadata
    is_active BOOLEAN NOT NULL DEFAULT true,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),

    -- Constraints
    CONSTRAINT company_fund_accounts_unique_currency UNIQUE (currency_code)
);

-- Insert default company accounts
INSERT INTO company_fund_accounts (currency_code, current_balance)
VALUES
    ('VND', 0),
    ('USD', 0),
    ('CNY', 0)
ON CONFLICT (currency_code) DO NOTHING;

-- ============================================
-- 2. CREATE company_fund_transactions TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS company_fund_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    transaction_number TEXT UNIQUE NOT NULL, -- CFT-2025-00001

    -- Transaction details
    transaction_type TEXT NOT NULL CHECK (transaction_type IN (
        'DEPOSIT',        -- Money coming in from external source
        'WITHDRAWAL',     -- Money going out to external source
        'ALLOCATION',     -- Money allocated to employee (company -> employee)
        'RETURN',         -- Money returned from employee (employee -> company)
        'ADJUSTMENT'      -- Manual adjustment
    )),

    amount NUMERIC NOT NULL CHECK (amount > 0),
    currency_code TEXT NOT NULL CHECK (currency_code IN ('VND', 'USD', 'CNY')),

    -- Balance tracking
    balance_before NUMERIC NOT NULL,
    balance_after NUMERIC NOT NULL,

    -- Related entities
    reference_type TEXT, -- 'external', 'employee', 'transfer_request', 'manual', etc.
    reference_id UUID,

    -- Details
    description TEXT,
    notes TEXT,

    -- External transaction details
    external_source TEXT, -- 'bank_transfer', 'momo', 'zalopay', 'usdt', etc.
    external_account_name TEXT,
    external_account_number TEXT,
    external_transaction_id TEXT,

    -- Metadata
    status TEXT NOT NULL DEFAULT 'COMPLETED' CHECK (status IN ('PENDING', 'COMPLETED', 'CANCELLED')),
    created_by UUID NOT NULL REFERENCES profiles(id),
    created_at TIMESTAMPTZ DEFAULT now(),

    -- Constraints
    CONSTRAINT company_fund_transactions_valid_balance CHECK (
        (transaction_type IN ('DEPOSIT', 'ALLOCATION', 'ADJUSTMENT') AND balance_after >= balance_before) OR
        (transaction_type IN ('WITHDRAWAL', 'RETURN') AND balance_after <= balance_before)
    )
);

-- Indexes
CREATE INDEX idx_company_fund_transactions_type ON company_fund_transactions(transaction_type);
CREATE INDEX idx_company_fund_transactions_currency ON company_fund_transactions(currency_code);
CREATE INDEX idx_company_fund_transactions_reference ON company_fund_transactions(reference_type, reference_id);
CREATE INDEX idx_company_fund_transactions_created ON company_fund_transactions(created_at DESC);

-- ============================================
-- 3. CREATE external_transactions TABLE
-- ============================================
-- This table tracks all money in/out from external sources (banks, payment gateways, etc.)
CREATE TABLE IF NOT EXISTS external_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    transaction_number TEXT UNIQUE NOT NULL, -- EXT-2025-00001

    -- Transaction type
    transaction_type TEXT NOT NULL CHECK (transaction_type IN (
        'DEPOSIT',        -- Money coming INTO company from external source
        'WITHDRAWAL'      -- Money going OUT from company to external source
    )),

    -- Amount
    amount NUMERIC NOT NULL CHECK (amount > 0),
    currency_code TEXT NOT NULL DEFAULT 'VND' CHECK (currency_code IN ('VND', 'USD', 'CNY')),

    -- Company account affected
    company_account_id UUID NOT NULL REFERENCES company_fund_accounts(id),

    -- External source details
    external_source TEXT NOT NULL, -- 'bank_transfer', 'momo', 'zalopay', 'usdt', 'crypto_wallet', etc.
    external_gateway TEXT, -- Specific gateway name if applicable

    -- External account details
    external_account_name TEXT,
    external_account_number TEXT,
    external_bank_name TEXT,
    external_wallet_address TEXT,

    -- Transaction reference from external system
    external_transaction_id TEXT,
    external_transaction_ref TEXT,

    -- Fees
    fee_amount NUMERIC DEFAULT 0,
    fee_currency TEXT,

    -- Exchange rate (if converting)
    from_currency TEXT,
    to_currency TEXT,
    exchange_rate NUMERIC,

    -- Details
    description TEXT,
    notes TEXT,
    attachment_urls TEXT[], -- URLs to screenshots/receipts

    -- Status workflow
    status TEXT NOT NULL DEFAULT 'PENDING' CHECK (status IN (
        'PENDING',     -- Waiting for confirmation
        'CONFIRMED',   -- Confirmed by accountant
        'COMPLETED',   -- Money actually transferred
        'REJECTED',    -- Rejected
        'CANCELLED'    -- Cancelled
    )),

    -- Approval workflow
    confirmed_by UUID REFERENCES profiles(id),
    confirmed_at TIMESTAMPTZ,
    completed_by UUID REFERENCES profiles(id),
    completed_at TIMESTAMPTZ,

    -- Metadata
    created_by UUID NOT NULL REFERENCES profiles(id),
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Indexes
CREATE INDEX idx_external_transactions_type ON external_transactions(transaction_type);
CREATE INDEX idx_external_transactions_status ON external_transactions(status);
CREATE INDEX idx_external_transactions_source ON external_transactions(external_source);
CREATE INDEX idx_external_transactions_created ON external_transactions(created_at DESC);

-- Sequence for transaction numbers
CREATE SEQUENCE IF NOT EXISTS external_transaction_seq START 1;
CREATE SEQUENCE IF NOT EXISTS company_fund_transaction_seq START 1;

-- ============================================
-- 4. FUNCTION: Generate external transaction number
-- ============================================
CREATE OR REPLACE FUNCTION generate_external_transaction_number()
RETURNS TEXT AS $$
BEGIN
    RETURN 'EXT-' || EXTRACT(YEAR FROM now()) || '-' ||
           LPAD(nextval('external_transaction_seq')::text, 5, '0');
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 5. FUNCTION: Generate company fund transaction number
-- ============================================
CREATE OR REPLACE FUNCTION generate_company_fund_transaction_number()
RETURNS TEXT AS $$
BEGIN
    RETURN 'CFT-' || EXTRACT(YEAR FROM now()) || '-' ||
           LPAD(nextval('company_fund_transaction_seq')::text, 5, '0');
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 6. FUNCTION: Deposit to Company Account
-- ============================================
CREATE OR REPLACE FUNCTION deposit_to_company_account(
    p_amount NUMERIC,
    p_currency_code TEXT,
    p_description TEXT,
    p_external_source TEXT,
    p_external_account_name TEXT,
    p_external_account_number TEXT,
    p_external_transaction_id TEXT,
    p_notes TEXT,
    p_attachment_urls TEXT[],
    p_created_by UUID
) RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    transaction_id UUID
) SECURITY DEFINER SET search_path = 'public'
AS $$
DECLARE
    v_account_id UUID;
    v_balance_before NUMERIC;
    v_balance_after NUMERIC;
    v_transaction_id UUID;
    v_transaction_number TEXT;
    v_ext_transaction_id UUID;
    v_ext_transaction_number TEXT;
BEGIN
    -- Get company account
    SELECT id, current_balance INTO v_account_id, v_balance_before
    FROM company_fund_accounts
    WHERE currency_code = p_currency_code
      AND is_active = true
    FOR UPDATE;

    IF v_account_id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'Company account not found for currency: ' || p_currency_code, NULL::UUID;
        RETURN;
    END IF;

    -- Calculate new balance
    v_balance_after := v_balance_before + p_amount;

    -- Generate numbers
    v_transaction_number := generate_company_fund_transaction_number();
    v_ext_transaction_number := generate_external_transaction_number();

    -- Create external transaction record
    INSERT INTO external_transactions (
        transaction_number,
        transaction_type,
        amount,
        currency_code,
        company_account_id,
        external_source,
        external_account_name,
        external_account_number,
        external_transaction_id,
        description,
        notes,
        attachment_urls,
        status,
        created_by
    ) VALUES (
        v_ext_transaction_number,
        'DEPOSIT',
        p_amount,
        p_currency_code,
        v_account_id,
        p_external_source,
        p_external_account_name,
        p_external_account_number,
        p_external_transaction_id,
        p_description,
        p_notes,
        p_attachment_urls,
        'PENDING',
        p_created_by
    ) RETURNING id INTO v_ext_transaction_id;

    -- Create company fund transaction record
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
        external_source,
        external_account_name,
        external_account_number,
        external_transaction_id,
        created_by
    ) VALUES (
        v_transaction_number,
        'DEPOSIT',
        p_amount,
        p_currency_code,
        v_balance_before,
        v_balance_after,
        'external_transaction',
        v_ext_transaction_id,
        p_description,
        p_external_source,
        p_external_account_name,
        p_external_account_number,
        p_external_transaction_id,
        p_created_by
    ) RETURNING id INTO v_transaction_id;

    -- Update company account balance
    UPDATE company_fund_accounts
    SET current_balance = v_balance_after,
        updated_at = now()
    WHERE id = v_account_id;

    RETURN QUERY SELECT
        TRUE,
        'Deposit recorded: ' || v_transaction_number || ' (External: ' || v_ext_transaction_number || '). Amount: ' || p_amount::TEXT || ' ' || p_currency_code,
        v_transaction_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 7. FUNCTION: Withdraw from Company Account
-- ============================================
CREATE OR REPLACE FUNCTION withdraw_from_company_account(
    p_amount NUMERIC,
    p_currency_code TEXT,
    p_description TEXT,
    p_external_source TEXT,
    p_external_account_name TEXT,
    p_external_account_number TEXT,
    p_notes TEXT,
    p_attachment_urls TEXT[],
    p_created_by UUID
) RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    transaction_id UUID
) SECURITY DEFINER SET search_path = 'public'
AS $$
DECLARE
    v_account_id UUID;
    v_balance_before NUMERIC;
    v_balance_after NUMERIC;
    v_transaction_id UUID;
    v_transaction_number TEXT;
    v_ext_transaction_id UUID;
    v_ext_transaction_number TEXT;
BEGIN
    -- Get company account
    SELECT id, current_balance INTO v_account_id, v_balance_before
    FROM company_fund_accounts
    WHERE currency_code = p_currency_code
      AND is_active = true
    FOR UPDATE;

    IF v_account_id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'Company account not found for currency: ' || p_currency_code, NULL::UUID;
        RETURN;
    END IF;

    -- Check if sufficient balance
    IF v_balance_before < p_amount THEN
        RETURN QUERY SELECT FALSE,
            'Insufficient company balance. Current: ' || v_balance_before::TEXT || ' ' || p_currency_code || ', Required: ' || p_amount::TEXT,
            NULL::UUID;
        RETURN;
    END IF;

    -- Calculate new balance
    v_balance_after := v_balance_before - p_amount;

    -- Generate numbers
    v_transaction_number := generate_company_fund_transaction_number();
    v_ext_transaction_number := generate_external_transaction_number();

    -- Create external transaction record
    INSERT INTO external_transactions (
        transaction_number,
        transaction_type,
        amount,
        currency_code,
        company_account_id,
        external_source,
        external_account_name,
        external_account_number,
        description,
        notes,
        attachment_urls,
        status,
        created_by
    ) VALUES (
        v_ext_transaction_number,
        'WITHDRAWAL',
        p_amount,
        p_currency_code,
        v_account_id,
        p_external_source,
        p_external_account_name,
        p_external_account_number,
        p_description,
        p_notes,
        p_attachment_urls,
        'PENDING',
        p_created_by
    ) RETURNING id INTO v_ext_transaction_id;

    -- Create company fund transaction record
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
        external_source,
        external_account_name,
        external_account_number,
        created_by
    ) VALUES (
        v_transaction_number,
        'WITHDRAWAL',
        p_amount,
        p_currency_code,
        v_balance_before,
        v_balance_after,
        'external_transaction',
        v_ext_transaction_id,
        p_description,
        p_external_source,
        p_external_account_name,
        p_external_account_number,
        p_created_by
    ) RETURNING id INTO v_transaction_id;

    -- Update company account balance
    UPDATE company_fund_accounts
    SET current_balance = v_balance_after,
        updated_at = now()
    WHERE id = v_account_id;

    RETURN QUERY SELECT
        TRUE,
        'Withdrawal recorded: ' || v_transaction_number || ' (External: ' || v_ext_transaction_number || '). Amount: ' || p_amount::TEXT || ' ' || p_currency_code,
        v_transaction_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 8. UPDATE allocate_employee_fund to deduct from company
-- ============================================
CREATE OR REPLACE FUNCTION allocate_employee_fund(
    p_user_id UUID,
    p_employee_id UUID,
    p_amount NUMERIC,
    p_currency_code TEXT,
    p_description TEXT,
    p_reference_type TEXT,
    p_reference_id UUID,
    p_auto_approve BOOLEAN DEFAULT false
) RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    request_id UUID
) SECURITY DEFINER SET search_path = 'public'
AS $$
DECLARE
    v_request_id UUID;
    v_company_account_id UUID;
    v_company_balance NUMERIC;
    v_request_number TEXT;
    v_employee_name TEXT;
    v_user_name TEXT;
BEGIN
    -- Check if this is called from transfer confirmation (auto_approve = true)
    -- If not auto_approve, check if pending request exists
    IF NOT p_auto_approve THEN
        -- Check user role - only accountant can allocate
        IF NOT EXISTS (
            SELECT 1 FROM user_roles ur
            JOIN roles r ON ur.role_id = r.id
            WHERE ur.profile_id = p_user_id
            AND r.code = 'accountant'
        ) THEN
            RETURN QUERY SELECT FALSE, 'Only accountants can allocate funds', NULL::UUID;
            RETURN;
        END IF;

        -- Check company balance
        SELECT cfa.id, cfa.current_balance INTO v_company_account_id, v_company_balance
        FROM company_fund_accounts cfa
        WHERE cfa.currency_code = p_currency_code
          AND cfa.is_active = true;

        IF v_company_account_id IS NULL THEN
            RETURN QUERY SELECT FALSE, 'Company account not found for currency: ' || p_currency_code, NULL::UUID;
            RETURN;
        END IF;

        IF v_company_balance < p_amount THEN
            RETURN QUERY SELECT FALSE,
                'Insufficient company balance. Available: ' || v_company_balance::TEXT || ' ' || p_currency_code,
                NULL::UUID;
            RETURN;
        END IF;
    END IF;

    -- Get names
    SELECT display_name INTO v_employee_name FROM profiles WHERE id = p_employee_id;
    SELECT display_name INTO v_user_name FROM profiles WHERE id = p_user_id;

    -- Generate request number
    v_request_number := 'FAR-' || EXTRACT(YEAR FROM now()) || '-' || LPAD(nextval('fund_allocation_seq')::text, 5, '0');

    -- Create allocation request
    INSERT INTO fund_allocation_requests (
        request_number,
        employee_id,
        amount,
        currency_code,
        description,
        status,
        created_by
    ) VALUES (
        v_request_number,
        p_employee_id,
        p_amount,
        p_currency_code,
        p_description,
        CASE WHEN p_auto_approve THEN 'APPROVED' ELSE 'PENDING' END,
        p_user_id
    ) RETURNING id INTO v_request_id;

    -- If auto_approve, process immediately
    IF p_auto_approve THEN
        -- Get company account and deduct
        SELECT id, current_balance INTO v_company_account_id, v_company_balance
        FROM company_fund_accounts
        WHERE currency_code = p_currency_code
          AND is_active = true
        FOR UPDATE;

        -- Deduct from company
        UPDATE company_fund_accounts
        SET current_balance = current_balance - p_amount,
            updated_at = now()
        WHERE id = v_company_account_id;

        -- Create company transaction record
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
            'ALLOCATION',
            p_amount,
            p_currency_code,
            v_company_balance,
            v_company_balance - p_amount,
            p_reference_type,
            p_reference_id,
            'Allocation to ' || v_employee_name || ': ' || p_description,
            p_user_id
        );

        -- Allocate to employee (existing logic)
        PERFORM allocate_fund_to_employee(
            p_employee_id,
            p_amount,
            p_currency_code,
            p_description,
            p_user_id,
            p_reference_type,
            p_reference_id
        );
    END IF;

    RETURN QUERY SELECT
        TRUE,
        'Allocation request created: ' || v_request_number || ' (' || p_amount::TEXT || ' ' || p_currency_code || ' to ' || v_employee_name || ')',
        v_request_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 9. UPDATE return_employee_fund to add to company
-- ============================================
CREATE OR REPLACE FUNCTION return_employee_fund(
    p_employee_id UUID,
    p_amount NUMERIC,
    p_currency_code TEXT,
    p_description TEXT,
    p_confirmer_id UUID,
    p_reference_type TEXT,
    p_reference_id UUID
) RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    transaction_id UUID
) SECURITY DEFINER SET search_path = 'public'
AS $$
DECLARE
    v_company_account_id UUID;
    v_company_balance_before NUMERIC;
    v_company_balance_after NUMERIC;
    v_employee_balance_before NUMERIC;
    v_transaction_id UUID;
    v_employee_name TEXT;
BEGIN
    -- Get employee name
    SELECT display_name INTO v_employee_name FROM profiles WHERE id = p_employee_id;

    -- Get company account
    SELECT id, current_balance INTO v_company_account_id, v_company_balance_before
    FROM company_fund_accounts
    WHERE currency_code = p_currency_code
      AND is_active = true
    FOR UPDATE;

    IF v_company_account_id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'Company account not found for currency: ' || p_currency_code, NULL::UUID;
        RETURN;
    END IF;

    -- Deduct from employee (existing logic)
    SELECT efa.current_balance INTO v_employee_balance_before
    FROM employee_fund_accounts efa
    WHERE efa.employee_id = p_employee_id
      AND efa.currency_code = p_currency_code
      AND efa.is_active = true
    FOR UPDATE;

    IF v_employee_balance_before IS NULL THEN
        RETURN QUERY SELECT FALSE, 'Employee account not found', NULL::UUID;
        RETURN;
    END IF;

    IF v_employee_balance_before < p_amount THEN
        RETURN QUERY SELECT FALSE, 'Insufficient employee balance', NULL::UUID;
        RETURN;
    END IF;

    -- Deduct from employee
    UPDATE employee_fund_accounts
    SET current_balance = current_balance - p_amount,
        updated_at = now()
    WHERE employee_id = p_employee_id
      AND currency_code = p_currency_code
      AND is_active = true;

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
        created_by
    ) VALUES (
        p_employee_id,
        'RETURN',
        p_amount,
        p_currency_code,
        v_employee_balance_before,
        v_employee_balance_before - p_amount,
        p_description,
        p_reference_type,
        p_reference_id,
        'COMPLETED',
        p_confirmer_id
    ) RETURNING id INTO v_transaction_id;

    -- Add to company
    v_company_balance_after := v_company_balance_before + p_amount;
    UPDATE company_fund_accounts
    SET current_balance = v_company_balance_after,
        updated_at = now()
    WHERE id = v_company_account_id;

    -- Create company transaction
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
        'RETURN',
        p_amount,
        p_currency_code,
        v_company_balance_before,
        v_company_balance_after,
        p_reference_type,
        p_reference_id,
        'Return from ' || v_employee_name || ': ' || p_description,
        p_confirmer_id
    );

    RETURN QUERY SELECT
        TRUE,
        'Fund returned. Employee balance updated. Company credited.',
        v_transaction_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 10. VIEW: Company Fund Accounts with Balances
-- ============================================
CREATE OR REPLACE VIEW company_fund_accounts_view AS
SELECT
    cfa.id,
    cfa.currency_code,
    cfa.current_balance,
    cfa.is_active,
    cfa.notes,
    cfa.created_at,
    cfa.updated_at,
    -- Transaction counts
    COALESCE(deposits.deposit_count, 0) as deposit_count,
    COALESCE(deposits.deposit_total, 0) as deposit_total,
    COALESCE(withdrawals.withdrawal_count, 0) as withdrawal_count,
    COALESCE(withdrawals.withdrawal_total, 0) as withdrawal_total
FROM company_fund_accounts cfa
LEFT JOIN (
    SELECT currency_code,
           COUNT(*) as deposit_count,
           SUM(amount) as deposit_total
    FROM company_fund_transactions
    WHERE transaction_type = 'DEPOSIT'
    GROUP BY currency_code
) deposits ON cfa.currency_code = deposits.currency_code
LEFT JOIN (
    SELECT currency_code,
           COUNT(*) as withdrawal_count,
           SUM(amount) as withdrawal_total
    FROM company_fund_transactions
    WHERE transaction_type IN ('WITHDRAWAL', 'ALLOCATION')
    GROUP BY currency_code
) withdrawals ON cfa.currency_code = withdrawals.currency_code
ORDER BY cfa.currency_code;

-- ============================================
-- 11. VIEW: External Transactions Summary
-- ============================================
CREATE OR REPLACE VIEW external_transactions_view AS
SELECT
    ext.id,
    ext.transaction_number,
    ext.transaction_type,
    ext.amount,
    ext.currency_code,
    ext.external_source,
    ext.external_gateway,
    ext.external_account_name,
    ext.external_account_number,
    ext.external_bank_name,
    ext.external_transaction_id,
    ext.description,
    ext.notes,
    ext.status,
    ext.created_at,
    p.display_name as created_by_name,
    ext.confirmed_at,
    cp.display_name as confirmed_by_name,
    ext.completed_at
FROM external_transactions ext
LEFT JOIN profiles p ON ext.created_by = p.id
LEFT JOIN profiles cp ON ext.confirmed_by = cp.id
ORDER BY ext.created_at DESC;

-- ============================================
-- 12. GRANT PERMISSIONS
-- ============================================
GRANT SELECT ON company_fund_accounts TO authenticated;
GRANT SELECT ON company_fund_accounts_view TO authenticated;
GRANT SELECT ON company_fund_transactions TO authenticated;
GRANT SELECT ON external_transactions TO authenticated;
GRANT SELECT ON external_transactions_view TO authenticated;

-- Only accountants can modify company funds
GRANT EXECUTE ON FUNCTION deposit_to_company_account TO authenticated;
GRANT EXECUTE ON FUNCTION withdraw_from_company_account TO authenticated;

-- ============================================
-- 13. VERIFY SETUP
-- ============================================
SELECT
    'company_fund_accounts' as component,
    'CREATED' as status,
    'Company wallet accounts for VND, USD, CNY' as notes
UNION ALL
SELECT
    'external_transactions',
    'CREATED',
    'External deposit/withdrawal tracking'
UNION ALL
SELECT
    'deposit_to_company_account',
    'CREATED',
    'Function to record deposits from external sources'
UNION ALL
SELECT
    'withdraw_from_company_account',
    'CREATED',
    'Function to record withdrawals to external sources'
UNION ALL
SELECT
    'allocate_employee_fund',
    'UPDATED',
    'Now deducts from company balance'
UNION ALL
SELECT
    'return_employee_fund',
    'UPDATED',
    'Now credits to company balance';
