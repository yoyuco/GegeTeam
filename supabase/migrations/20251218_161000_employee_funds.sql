-- Migration: Employee Fund Management System
-- Description: Create tables for tracking money given to employees and returned from employees
-- Created: 2025-12-18 15:10:00
-- Author: Claude Code

-- Transaction types for employee funds
CREATE TYPE employee_fund_transaction_type AS ENUM (
    'FUND_ALLOCATION',  -- Company gives money to employee
    'FUND_RETURN',      -- Employee returns money to company
    'FUND_ADJUSTMENT',  -- Manual adjustment (correction)
    'FUND_TRANSFER'     -- Transfer between employees (future use)
);

-- Employee fund accounts - one per employee per currency
CREATE TABLE employee_fund_accounts (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    employee_id uuid NOT NULL REFERENCES profiles(id),
    currency_code text NOT NULL DEFAULT 'VND' CHECK (currency_code IN ('VND', 'USD', 'CNY')),
    current_balance numeric(20,4) DEFAULT 0 CHECK (current_balance >= 0),
    credit_limit numeric(20,4) DEFAULT 0 CHECK (credit_limit >= 0),
    total_allocated numeric(20,4) DEFAULT 0 CHECK (total_allocated >= 0), -- Total received from company
    total_returned numeric(20,4) DEFAULT 0 CHECK (total_returned >= 0), -- Total returned to company
    last_transaction_id uuid,
    last_transaction_at timestamptz,
    is_active boolean DEFAULT true,
    notes text,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),

    -- Ensure one account per employee per currency
    UNIQUE(employee_id, currency_code)
);

-- Create indexes
CREATE INDEX idx_employee_fund_accounts_employee ON employee_fund_accounts(employee_id);
CREATE INDEX idx_employee_fund_accounts_currency ON employee_fund_accounts(currency_code);
CREATE INDEX idx_employee_fund_accounts_active ON employee_fund_accounts(is_active);

-- Employee fund transactions - detailed history
CREATE TABLE employee_fund_transactions (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    transaction_number text UNIQUE NOT NULL, -- EF-2025-00001
    employee_id uuid NOT NULL REFERENCES profiles(id),
    transaction_type employee_fund_transaction_type NOT NULL,
    amount numeric(20,4) NOT NULL CHECK (amount > 0),
    currency_code text NOT NULL DEFAULT 'VND' CHECK (currency_code IN ('VND', 'USD', 'CNY')),
    balance_before numeric(20,4) NOT NULL CHECK (balance_before >= 0),
    balance_after numeric(20,4) NOT NULL CHECK (balance_after >= 0),
    description text,
    reference_type text, -- 'currency_order', 'manual', 'purchase', 'sale'
    reference_id uuid, -- Links to related transactions
    approval_status text DEFAULT 'auto_approved' CHECK (approval_status IN (
        'auto_approved', 'pending', 'approved', 'rejected'
    )),
    approved_by uuid REFERENCES profiles(id),
    approved_at timestamptz,
    rejection_reason text,
    created_by uuid NOT NULL REFERENCES profiles(id),
    created_at timestamptz DEFAULT now(),

    -- Ensure balance_after is calculated correctly
    CONSTRAINT eft_balance_check CHECK (
        CASE transaction_type
            WHEN 'FUND_ALLOCATION' THEN balance_after = balance_before + amount
            WHEN 'FUND_RETURN' THEN balance_after = balance_before - amount
            WHEN 'FUND_ADJUSTMENT' THEN true -- Manual adjustments can go either way
            ELSE true
        END
    )
);

-- Create indexes
CREATE INDEX idx_employee_fund_transactions_number ON employee_fund_transactions(transaction_number);
CREATE INDEX idx_employee_fund_transactions_employee ON employee_fund_transactions(employee_id);
CREATE INDEX idx_employee_fund_transactions_type ON employee_fund_transactions(transaction_type);
CREATE INDEX idx_employee_fund_transactions_date ON employee_fund_transactions(created_at);
CREATE INDEX idx_employee_fund_transactions_approval ON employee_fund_transactions(approval_status);
CREATE INDEX idx_employee_fund_transactions_reference ON employee_fund_transactions(reference_type, reference_id);

-- Transaction sequence for employee funds
CREATE SEQUENCE IF NOT EXISTS employee_fund_transaction_seq START 1;

-- Function to generate transaction number
CREATE OR REPLACE FUNCTION generate_employee_fund_transaction_number()
RETURNS text AS $$
BEGIN
    RETURN 'EF-' || EXTRACT(YEAR FROM now()) || '-' ||
           LPAD(nextval('employee_fund_transaction_seq')::text, 5, '0');
END;
$$ LANGUAGE plpgsql;

-- Function to check if approval is needed based on amount threshold
CREATE OR REPLACE FUNCTION check_approval_needed(
    p_amount numeric(20,4),
    p_currency_code text DEFAULT 'VND'
) RETURNS boolean AS $$
DECLARE
    v_threshold_vnd numeric(20,4);
    v_threshold_usd numeric(20,4);
    v_threshold_cny numeric(20,4);
    v_exchange_rate numeric(10,6);
    v_amount_vnd numeric(20,4);
BEGIN
    -- Define thresholds (can be made configurable later)
    v_threshold_vnd := 50000000; -- 50 million VND
    v_threshold_usd := 2000;     -- 2,000 USD
    v_threshold_cny := 35000;    -- 35,000 CNY

    -- Get exchange rate if not VND
    IF p_currency_code = 'VND' THEN
        v_amount_vnd := p_amount;
    ELSE
        -- Get latest exchange rate (simplified - should use exchange_rates table)
        SELECT rate INTO v_exchange_rate
        FROM exchange_rates
        WHERE from_currency = p_currency_code
          AND to_currency = 'VND'
          AND is_active = true
        ORDER BY effective_date DESC
        LIMIT 1;

        IF v_exchange_rate IS NULL THEN
            -- Default rates if not found
            v_exchange_rate := CASE p_currency_code
                WHEN 'USD' THEN 24500
                WHEN 'CNY' THEN 3400
                ELSE 1
            END;
        END IF;

        v_amount_vnd := p_amount * v_exchange_rate;
    END IF;

    -- Check against appropriate threshold
    RETURN CASE p_currency_code
        WHEN 'VND' THEN v_amount_vnd > v_threshold_vnd
        WHEN 'USD' THEN p_amount > v_threshold_usd
        WHEN 'CNY' THEN p_amount > v_threshold_cny
        ELSE false
    END;
END;
$$ LANGUAGE plpgsql;

-- Function to allocate funds to employee
CREATE OR REPLACE FUNCTION allocate_employee_fund(
    p_employee_id uuid,
    p_amount numeric(20,4),
    p_currency_code text DEFAULT 'VND',
    p_description text DEFAULT NULL,
    p_created_by uuid,
    p_reference_type text DEFAULT NULL,
    p_reference_id uuid DEFAULT NULL
) RETURNS TABLE(
    success boolean,
    message text,
    transaction_id uuid,
    requires_approval boolean
) AS $$
DECLARE
    v_fund_account_id uuid;
    v_balance_before numeric(20,4);
    v_balance_after numeric(20,4);
    v_transaction_number text;
    v_transaction_id uuid;
    v_needs_approval boolean;
    v_journal_entry_id uuid;
    v_employee_fund_account_id uuid;
BEGIN
    -- Check if approval is needed
    v_needs_approval := check_approval_needed(p_amount, p_currency_code);

    -- Get or create employee fund account
    BEGIN
        INSERT INTO employee_fund_accounts (
            employee_id, currency_code
        ) VALUES (
            p_employee_id, p_currency_code
        ) RETURNING id INTO v_fund_account_id;
    EXCEPTION
        WHEN unique_violation THEN
            SELECT id INTO v_fund_account_id
            FROM employee_fund_accounts
            WHERE employee_id = p_employee_id
              AND currency_code = p_currency_code;
    END;

    -- Get current balance
    SELECT current_balance INTO v_balance_before
    FROM employee_fund_accounts
    WHERE id = v_fund_account_id;

    -- Calculate new balance
    v_balance_after := v_balance_before + p_amount;

    -- Generate transaction number
    v_transaction_number := generate_employee_fund_transaction_number();

    -- Create employee fund transaction
    INSERT INTO employee_fund_transactions (
        transaction_number, employee_id, transaction_type,
        amount, currency_code, balance_before, balance_after,
        description, reference_type, reference_id, approval_status,
        created_by
    ) VALUES (
        v_transaction_number, p_employee_id, 'FUND_ALLOCATION',
        p_amount, p_currency_code, v_balance_before, v_balance_after,
        p_description, p_reference_type, p_reference_id,
        CASE WHEN v_needs_approval THEN 'pending' ELSE 'auto_approved' END,
        p_created_by
    ) RETURNING id INTO v_transaction_id;

    -- If auto-approved, update balance and create journal entry
    IF NOT v_needs_approval THEN
        -- Update employee fund account balance
        UPDATE employee_fund_accounts
        SET current_balance = v_balance_after,
            total_allocated = total_allocated + p_amount,
            last_transaction_id = v_transaction_id,
            last_transaction_at = now(),
            updated_at = now()
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
            'Employee Fund Allocation: ' || COALESCE(p_description, 'No description'),
            'employee_fund', v_transaction_id,
            p_amount, p_currency_code, 'posted', p_created_by
        ) RETURNING id INTO v_journal_entry_id;

        -- Create journal entry lines
        -- Debit: Employee Funds Receivable (Asset increase)
        INSERT INTO journal_entry_lines (
            journal_entry_id, line_number, account_id, entity_type, entity_id,
            debit_amount, description
        ) VALUES (
            v_journal_entry_id, 1, v_employee_fund_account_id, 'employee', p_employee_id,
            p_amount, p_description
        );

        -- Credit: Cash/Bank (Asset decrease)
        INSERT INTO journal_entry_lines (
            journal_entry_id, line_number, account_id,
            credit_amount, description
        ) SELECT v_journal_entry_id, 2, id, p_amount, p_description
        FROM chart_of_accounts
        WHERE account_code = CASE p_currency_code
            WHEN 'VND' THEN '101'
            WHEN 'USD' THEN '102'
            WHEN 'CNY' THEN '103'
            ELSE '101'
        END;
    END IF;

    -- Return result
    RETURN QUERY SELECT
        TRUE,
        CASE WHEN v_needs_approval
            THEN 'Fund allocation created, pending approval'
            ELSE 'Fund allocated successfully. New balance: ' || v_balance_after
        END,
        v_transaction_id,
        v_needs_approval;
END;
$$ LANGUAGE plpgsql;

-- Function to return funds from employee
CREATE OR REPLACE FUNCTION return_employee_fund(
    p_employee_id uuid,
    p_amount numeric(20,4),
    p_currency_code text DEFAULT 'VND',
    p_description text DEFAULT NULL,
    p_created_by uuid,
    p_reference_type text DEFAULT NULL,
    p_reference_id uuid DEFAULT NULL
) RETURNS TABLE(
    success boolean,
    message text,
    transaction_id uuid
) AS $$
DECLARE
    v_fund_account_id uuid;
    v_balance_before numeric(20,4);
    v_balance_after numeric(20,4);
    v_transaction_number text;
    v_transaction_id uuid;
    v_journal_entry_id uuid;
    v_employee_fund_account_id uuid;
BEGIN
    -- Get employee fund account
    SELECT id, current_balance INTO v_fund_account_id, v_balance_before
    FROM employee_fund_accounts
    WHERE employee_id = p_employee_id
      AND currency_code = p_currency_code
      AND is_active = true;

    IF v_fund_account_id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'Employee fund account not found', NULL::uuid;
        RETURN;
    END IF;

    -- Check if sufficient balance
    IF v_balance_before < p_amount THEN
        RETURN QUERY SELECT FALSE, 'Insufficient balance. Current: ' || v_balance_before, NULL::uuid;
        RETURN;
    END IF;

    -- Calculate new balance
    v_balance_after := v_balance_before - p_amount;

    -- Generate transaction number
    v_transaction_number := generate_employee_fund_transaction_number();

    -- Create employee fund transaction
    INSERT INTO employee_fund_transactions (
        transaction_number, employee_id, transaction_type,
        amount, currency_code, balance_before, balance_after,
        description, reference_type, reference_id, approval_status,
        created_by
    ) VALUES (
        v_transaction_number, p_employee_id, 'FUND_RETURN',
        p_amount, p_currency_code, v_balance_before, v_balance_after,
        p_description, p_reference_type, p_reference_id, 'auto_approved',
        p_created_by
    ) RETURNING id INTO v_transaction_id;

    -- Update employee fund account
    UPDATE employee_fund_accounts
    SET current_balance = v_balance_after,
        total_returned = total_returned + p_amount,
        last_transaction_id = v_transaction_id,
        last_transaction_at = now(),
        updated_at = now()
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
        'Employee Fund Return: ' || COALESCE(p_description, 'No description'),
        'employee_fund', v_transaction_id,
        p_amount, p_currency_code, 'posted', p_created_by
    ) RETURNING id INTO v_journal_entry_id;

    -- Create journal entry lines
    -- Debit: Cash/Bank (Asset increase)
    INSERT INTO journal_entry_lines (
        journal_entry_id, line_number, account_id,
        debit_amount, description
    ) SELECT v_journal_entry_id, 1, id, p_amount, p_description
    FROM chart_of_accounts
    WHERE account_code = CASE p_currency_code
        WHEN 'VND' THEN '101'
        WHEN 'USD' THEN '102'
        WHEN 'CNY' THEN '103'
        ELSE '101'
    END;

    -- Credit: Employee Funds Receivable (Asset decrease)
    INSERT INTO journal_entry_lines (
        journal_entry_id, line_number, account_id, entity_type, entity_id,
        credit_amount, description
    ) VALUES (
        v_journal_entry_id, 2, v_employee_fund_account_id, 'employee', p_employee_id,
        p_amount, p_description
    );

    RETURN QUERY SELECT
        TRUE,
        'Fund returned successfully. New balance: ' || v_balance_after,
        v_transaction_id;
END;
$$ LANGUAGE plpgsql;

-- View for employee fund balances
CREATE OR REPLACE VIEW employee_fund_balance_view AS
SELECT
    ef.id,
    p.display_name as employee_name,
    ef.currency_code,
    ef.current_balance,
    ef.total_allocated,
    ef.total_returned,
    ef.total_allocated - ef.total_returned as net_amount,
    ef.last_transaction_at,
    ef.is_active
FROM employee_fund_accounts ef
JOIN profiles p ON ef.employee_id = p.id
WHERE ef.is_active = true
ORDER BY ef.last_transaction_at DESC;

-- View for employee fund transactions
CREATE OR REPLACE VIEW employee_fund_transaction_view AS
SELECT
    eft.transaction_number,
    eft.transaction_type,
    p.display_name as employee_name,
    eft.amount,
    eft.currency_code,
    eft.balance_before,
    eft.balance_after,
    eft.description,
    eft.reference_type,
    eft.approval_status,
    eft.created_at,
    eft.created_by,
    p2.display_name as created_by_name
FROM employee_fund_transactions eft
JOIN profiles p ON eft.employee_id = p.id
LEFT JOIN profiles p2 ON eft.created_by = p2.id
ORDER BY eft.created_at DESC;

-- Add comments for documentation
COMMENT ON TABLE employee_fund_accounts IS 'Employee Fund Accounts - tracks money given to each employee per currency';
COMMENT ON TABLE employee_fund_transactions IS 'Employee Fund Transactions - detailed history of all fund movements';
COMMENT ON VIEW employee_fund_balance_view IS 'Employee Fund Balance View - current balances for all employees';
COMMENT ON VIEW employee_fund_transaction_view IS 'Employee Fund Transaction View - complete transaction history';