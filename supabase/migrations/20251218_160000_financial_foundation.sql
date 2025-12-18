-- Migration: Financial Foundation - Chart of Accounts & General Ledger
-- Description: Create core accounting tables with simplified chart of accounts
-- Created: 2025-12-18 15:00:00
-- Author: Claude Code

-- Account categories for proper classification
CREATE TYPE account_category_enum AS ENUM (
    'ASSET',          -- Cash, inventory, receivables
    'LIABILITY',      -- Payables, debts
    'EQUITY',         -- Owner's equity
    'REVENUE',        -- Sales income
    'EXPENSE'         -- Costs, expenses
);

-- Chart of Accounts
CREATE TABLE chart_of_accounts (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    account_code text UNIQUE NOT NULL, -- e.g., 100, 101, 200, 300, 400
    account_name text NOT NULL,
    account_category account_category_enum NOT NULL,
    parent_account_id uuid REFERENCES chart_of_accounts(id),
    is_active boolean DEFAULT true,
    description text,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- Create indexes
CREATE INDEX idx_chart_of_accounts_code ON chart_of_accounts(account_code);
CREATE INDEX idx_chart_of_accounts_category ON chart_of_accounts(account_category);
CREATE INDEX idx_chart_of_accounts_active ON chart_of_accounts(is_active);

-- Insert simplified chart of accounts for business needs
INSERT INTO chart_of_accounts (account_code, account_name, account_category, description) VALUES
    -- Assets (100s)
    ('100', 'Cash & Bank', 'ASSET', 'All cash and bank accounts'),
    ('101', 'Cash VND', 'ASSET', 'Physical cash in VND'),
    ('102', 'Cash USD', 'ASSET', 'Physical cash in USD'),
    ('103', 'Cash CNY', 'ASSET', 'Physical cash in CNY'),
    ('104', 'Bank VND', 'ASSET', 'Bank accounts in VND'),
    ('105', 'Bank USD', 'ASSET', 'Bank accounts in USD'),
    ('106', 'Bank CNY', 'ASSET', 'Bank accounts in CNY'),
    ('110', 'Inventory', 'ASSET', 'Game currency inventory'),
    ('120', 'Employee Funds Receivable', 'ASSET', 'Money given to employees'),
    ('130', 'Accounts Receivable', 'ASSET', 'Money to receive from customers'),

    -- Liabilities (200s)
    ('200', 'Accounts Payable', 'LIABILITY', 'Money owed to suppliers'),
    ('210', 'Employee Payables', 'LIABILITY', 'Money owed to employees'),

    -- Equity (300s)
    ('300', 'Owner''s Equity', 'EQUITY', 'Owner''s investment in business'),
    ('310', 'Retained Earnings', 'EQUITY', 'Accumulated profits'),

    -- Revenue (400s)
    ('400', 'Sales Revenue', 'REVENUE', 'Income from currency sales'),
    ('410', 'Service Revenue', 'REVENUE', 'Income from services'),
    ('420', 'Exchange Gain', 'REVENUE', 'Gain from currency exchange'),

    -- Expenses (500s)
    ('500', 'Cost of Goods Sold', 'EXPENSE', 'Cost of inventory sold'),
    ('510', 'Operating Expenses', 'EXPENSE', 'Daily operational costs'),
    ('520', 'Employee Expenses', 'EXPENSE', 'Employee-related expenses'),
    ('530', 'Bank Fees', 'EXPENSE', 'Bank transaction fees');

-- Journal Entries (header)
CREATE TABLE journal_entries (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    entry_number text UNIQUE NOT NULL, -- Auto-generated: JE-2025-00001
    entry_date date NOT NULL,
    description text,
    reference_type text, -- 'currency_order', 'employee_fund', 'manual', 'adjustment'
    reference_id uuid, -- Links to currency_orders, employee_funds, etc.
    total_amount numeric(20,4) NOT NULL CHECK (total_amount > 0),
    currency_code text NOT NULL DEFAULT 'VND' CHECK (currency_code IN ('VND', 'USD', 'CNY')),
    exchange_rate numeric(10,6) DEFAULT 1, -- Rate to base currency (VND)
    status text DEFAULT 'draft' CHECK (status IN ('draft', 'posted', 'void')),
    created_by uuid NOT NULL REFERENCES profiles(id),
    approved_by uuid REFERENCES profiles(id),
    approved_at timestamptz,
    posted_at timestamptz,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- Create indexes for journal_entries
CREATE INDEX idx_journal_entries_number ON journal_entries(entry_number);
CREATE INDEX idx_journal_entries_date ON journal_entries(entry_date);
CREATE INDEX idx_journal_entries_status ON journal_entries(status);
CREATE INDEX idx_journal_entries_reference ON journal_entries(reference_type, reference_id);
CREATE INDEX idx_journal_entries_created_by ON journal_entries(created_by);

-- Journal Entry Lines (double-entry details)
CREATE TABLE journal_entry_lines (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    journal_entry_id uuid NOT NULL REFERENCES journal_entries(id) ON DELETE CASCADE,
    line_number integer NOT NULL,
    account_id uuid NOT NULL REFERENCES chart_of_accounts(id),
    entity_type text, -- 'company', 'employee', 'customer', 'supplier'
    entity_id uuid, -- ID of entity
    debit_amount numeric(20,4) DEFAULT 0 CHECK (debit_amount >= 0),
    credit_amount numeric(20,4) DEFAULT 0 CHECK (credit_amount >= 0),
    description text,
    created_at timestamptz DEFAULT now(),

    -- Ensure only debit OR credit is entered
    CONSTRAINT je_line_debit_credit CHECK (
        (debit_amount > 0 AND credit_amount = 0) OR
        (credit_amount > 0 AND debit_amount = 0) OR
        (debit_amount = 0 AND credit_amount = 0)
    )
);

-- Create indexes for journal_entry_lines
CREATE INDEX idx_journal_entry_lines_entry ON journal_entry_lines(journal_entry_id);
CREATE INDEX idx_journal_entry_lines_account ON journal_entry_lines(account_id);
CREATE INDEX idx_journal_entry_lines_entity ON journal_entry_lines(entity_type, entity_id);

-- Account Balances (real-time tracking)
CREATE TABLE account_balances (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id uuid NOT NULL REFERENCES chart_of_accounts(id),
    entity_type text DEFAULT 'company', -- 'company', 'employee', 'customer', 'supplier'
    entity_id uuid, -- ID of entity
    currency_code text NOT NULL DEFAULT 'VND' CHECK (currency_code IN ('VND', 'USD', 'CNY')),
    current_balance numeric(20,4) DEFAULT 0,
    last_transaction_id uuid REFERENCES journal_entries(id),
    last_updated_at timestamptz DEFAULT now(),
    version integer DEFAULT 1, -- For optimistic locking

    UNIQUE(account_id, entity_type, entity_id, currency_code)
);

-- Create indexes for account_balances
CREATE INDEX idx_account_balances_account ON account_balances(account_id);
CREATE INDEX idx_account_balances_entity ON account_balances(entity_type, entity_id);
CREATE INDEX idx_account_balances_currency ON account_balances(currency_code);

-- Transaction sequences
CREATE SEQUENCE IF NOT EXISTS journal_entry_seq START 1;
CREATE SEQUENCE IF NOT EXISTS transaction_number_seq START 1;

-- Function to validate journal entry balance
CREATE OR REPLACE FUNCTION validate_journal_entry_balance()
RETURNS TRIGGER AS $$
DECLARE
    v_total_debit numeric(20,4);
    v_total_credit numeric(20,4);
    v_entry_count integer;
BEGIN
    -- Count lines for this entry
    SELECT COUNT(*) INTO v_entry_count
    FROM journal_entry_lines
    WHERE journal_entry_id = NEW.journal_entry_id;

    -- Skip validation if no lines yet
    IF v_entry_count = 0 THEN
        RETURN NEW;
    END IF;

    -- Calculate totals
    SELECT COALESCE(SUM(debit_amount), 0), COALESCE(SUM(credit_amount), 0)
    INTO v_total_debit, v_total_credit
    FROM journal_entry_lines
    WHERE journal_entry_id = NEW.journal_entry_id;

    -- Balance validation
    IF v_total_debit != v_total_credit THEN
        RAISE EXCEPTION 'Journal entry must balance: Debits (%) != Credits (%)',
            v_total_debit, v_total_credit;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for balance validation
CREATE TRIGGER validate_journal_entry_balance_insert
    AFTER INSERT ON journal_entry_lines
    FOR EACH ROW EXECUTE FUNCTION validate_journal_entry_balance();

CREATE TRIGGER validate_journal_entry_balance_update
    AFTER UPDATE ON journal_entry_lines
    FOR EACH ROW EXECUTE FUNCTION validate_journal_entry_balance();

-- Function to update account balance when journal entry is posted
CREATE OR REPLACE FUNCTION update_account_balances()
RETURNS TRIGGER AS $$
DECLARE
    v_line RECORD;
BEGIN
    -- Only update when entry is posted
    IF NEW.status = 'posted' AND (OLD.status IS NULL OR OLD.status != 'posted') THEN
        -- Process each line
        FOR v_line IN
            SELECT jel.*, ca.account_category
            FROM journal_entry_lines jel
            JOIN chart_of_accounts ca ON jel.account_id = ca.id
            WHERE jel.journal_entry_id = NEW.id
        LOOP
            -- Update or insert account balance
            INSERT INTO account_balances (
                account_id, entity_type, entity_id, currency_code,
                current_balance, last_transaction_id
            ) VALUES (
                v_line.account_id,
                COALESCE(v_line.entity_type, 'company'),
                v_line.entity_id,
                NEW.currency_code,
                0, -- Start from 0
                NEW.id
            )
            ON CONFLICT (account_id, entity_type, entity_id, currency_code) DO UPDATE SET
                current_balance = account_balances.current_balance +
                    CASE
                        WHEN v_line.account_category IN ('ASSET', 'EXPENSE')
                        THEN v_line.debit_amount - v_line.credit_amount
                        ELSE v_line.credit_amount - v_line.debit_amount
                    END,
                last_transaction_id = NEW.id,
                last_updated_at = now(),
                version = account_balances.version + 1;
        END LOOP;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update balances when journal entry is posted
CREATE TRIGGER update_balances_on_post
    AFTER UPDATE ON journal_entries
    FOR EACH ROW EXECUTE FUNCTION update_account_balances();

-- Create view for real-time trial balance
CREATE OR REPLACE VIEW trial_balance AS
SELECT
    ca.account_code,
    ca.account_name,
    ca.account_category,
    ca.description,
    ab.entity_type,
    ab.currency_code,
    COALESCE(ab.current_balance, 0) as balance,
    CASE
        WHEN ca.account_category IN ('ASSET', 'EXPENSE')
        THEN COALESCE(ab.current_balance, 0)
        ELSE -COALESCE(ab.current_balance, 0)
    END as normal_balance,
    ab.last_updated_at
FROM chart_of_accounts ca
LEFT JOIN account_balances ab ON ca.id = ab.account_id
WHERE ca.is_active = true
ORDER BY ca.account_code, ca.account_name;

-- Add comments for documentation
COMMENT ON TABLE chart_of_accounts IS 'Chart of Accounts - defines all financial accounts for the business';
COMMENT ON TABLE journal_entries IS 'Journal Entries - headers for accounting transactions';
COMMENT ON TABLE journal_entry_lines IS 'Journal Entry Lines - debit/credit details following double-entry principle';
COMMENT ON TABLE account_balances IS 'Account Balances - real-time balance tracking for all accounts';
COMMENT ON VIEW trial_balance IS 'Trial Balance - shows current balances for all accounts';