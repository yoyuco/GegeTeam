-- Employee Trading Accounts System
-- Purchase Account: Money allocated by company for buying currency (deducted on completion)
-- Sales Account: Money earned from sales (for tracking - transfer to company is separate)

-- ============================================
-- 1. ADD account_type TO employee_fund_accounts
-- ============================================
ALTER TABLE employee_fund_accounts
ADD COLUMN IF NOT EXISTS account_type TEXT NOT NULL DEFAULT 'purchase'
CHECK (account_type IN ('purchase', 'sales'));

-- Drop old unique constraint and add new one with account_type
ALTER TABLE employee_fund_accounts
DROP CONSTRAINT IF EXISTS employee_fund_accounts_employee_id_currency_code_key;

ALTER TABLE employee_fund_accounts
ADD CONSTRAINT employee_fund_accounts_unique_account
UNIQUE(employee_id, currency_code, account_type);

-- Add index for account_type
CREATE INDEX IF NOT EXISTS idx_employee_fund_accounts_type
ON employee_fund_accounts(account_type);

-- ============================================
-- 2. UPDATE employee_fund_transactions
-- ============================================
ALTER TABLE employee_fund_transactions
ADD COLUMN IF NOT EXISTS account_type TEXT
CHECK (account_type IN ('purchase', 'sales'));

CREATE INDEX IF NOT EXISTS idx_employee_fund_transactions_account_type
ON employee_fund_transactions(account_type);

-- ============================================
-- 3. FUNCTION: Deduct from Purchase Account
-- Uses RETURN transaction type (money going out)
-- ============================================
CREATE OR REPLACE FUNCTION deduct_from_purchase_account(
    p_employee_id UUID,
    p_amount NUMERIC,
    p_currency_code TEXT,
    p_description TEXT,
    p_created_by UUID,
    p_reference_type TEXT,
    p_reference_id UUID
) RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    transaction_id UUID
) SECURITY DEFINER SET search_path = 'public'
AS $$
DECLARE
    v_fund_account_id UUID;
    v_balance_before NUMERIC;
    v_balance_after NUMERIC;
    v_transaction_id UUID;
BEGIN
    -- Get purchase account
    SELECT id, current_balance INTO v_fund_account_id, v_balance_before
    FROM employee_fund_accounts
    WHERE employee_id = p_employee_id
      AND currency_code = p_currency_code
      AND account_type = 'purchase'
      AND is_active = true
    FOR UPDATE;

    IF v_fund_account_id IS NULL THEN
        -- Auto-create purchase account if not exists
        INSERT INTO employee_fund_accounts (
            employee_id, currency_code, account_type, current_balance
        ) VALUES (
            p_employee_id, p_currency_code, 'purchase', 0
        ) RETURNING id, current_balance INTO v_fund_account_id, v_balance_before;
    END IF;

    -- Check if sufficient balance
    IF v_balance_before < p_amount THEN
        RETURN QUERY SELECT FALSE,
            'Insufficient purchase account balance. Current: ' || v_balance_before::TEXT || ' ' || p_currency_code || ', Required: ' || p_amount::TEXT,
            NULL::UUID;
        RETURN;
    END IF;

    -- Calculate new balance
    v_balance_after := v_balance_before - p_amount;

    -- Create transaction record (use RETURN for payment out)
    INSERT INTO employee_fund_transactions (
        employee_id, transaction_type,
        amount, currency_code, balance_before, balance_after,
        account_type, description, reference_type, reference_id,
        status, created_by
    ) VALUES (
        p_employee_id, 'RETURN',
        p_amount, p_currency_code, v_balance_before, v_balance_after,
        'purchase', p_description, p_reference_type, p_reference_id,
        'COMPLETED', p_created_by
    ) RETURNING id INTO v_transaction_id;

    -- Update account balance
    UPDATE employee_fund_accounts
    SET current_balance = v_balance_after,
        updated_at = now()
    WHERE id = v_fund_account_id;

    RETURN QUERY SELECT
        TRUE,
        'Payment deducted from purchase account. New balance: ' || v_balance_after::TEXT || ' ' || p_currency_code,
        v_transaction_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 4. FUNCTION: Credit to Sales Account
-- Uses ALLOCATION transaction type (money coming in)
-- ============================================
CREATE OR REPLACE FUNCTION credit_to_sales_account(
    p_employee_id UUID,
    p_amount NUMERIC,
    p_currency_code TEXT,
    p_description TEXT,
    p_created_by UUID,
    p_reference_type TEXT,
    p_reference_id UUID
) RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    transaction_id UUID
) SECURITY DEFINER SET search_path = 'public'
AS $$
DECLARE
    v_fund_account_id UUID;
    v_balance_before NUMERIC;
    v_balance_after NUMERIC;
    v_transaction_id UUID;
BEGIN
    -- Get or create sales account
    BEGIN
        INSERT INTO employee_fund_accounts (
            employee_id, currency_code, account_type, current_balance
        ) VALUES (
            p_employee_id, p_currency_code, 'sales', 0
        ) RETURNING id, current_balance INTO v_fund_account_id, v_balance_before;
    EXCEPTION
        WHEN unique_violation THEN
            SELECT id, current_balance INTO v_fund_account_id, v_balance_before
            FROM employee_fund_accounts
            WHERE employee_id = p_employee_id
              AND currency_code = p_currency_code
              AND account_type = 'sales'
              AND is_active = true;
    END;

    -- Calculate new balance
    v_balance_after := v_balance_before + p_amount;

    -- Create transaction record (use ALLOCATION for credit in)
    INSERT INTO employee_fund_transactions (
        employee_id, transaction_type,
        amount, currency_code, balance_before, balance_after,
        account_type, description, reference_type, reference_id,
        status, created_by
    ) VALUES (
        p_employee_id, 'ALLOCATION',
        p_amount, p_currency_code, v_balance_before, v_balance_after,
        'sales', p_description, p_reference_type, p_reference_id,
        'COMPLETED', p_created_by
    ) RETURNING id INTO v_transaction_id;

    -- Update account balance
    UPDATE employee_fund_accounts
    SET current_balance = v_balance_after,
        updated_at = now()
    WHERE id = v_fund_account_id;

    RETURN QUERY SELECT
        TRUE,
        'Sale revenue credited to sales account. New balance: ' || v_balance_after::TEXT || ' ' || p_currency_code,
        v_transaction_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 5. FUNCTION: Debit Purchase Account on PURCHASE completion
-- ============================================
CREATE OR REPLACE FUNCTION debit_purchase_account_on_purchase_completion()
RETURNS TRIGGER SECURITY DEFINER SET search_path = 'public'
AS $$
DECLARE
    v_payment_amount NUMERIC;
    v_payment_currency TEXT;
    v_employee_id UUID;
    v_result BOOLEAN;
    v_message TEXT;
    v_transaction_id UUID;
BEGIN
    -- Only trigger on PURCHASE order completion
    IF TG_OP = 'UPDATE'
       AND OLD.status != 'completed'
       AND NEW.status = 'completed'
       AND NEW.order_type = 'PURCHASE'
       AND NEW.cost_amount IS NOT NULL
       AND NEW.cost_amount > 0 THEN

        v_payment_amount := NEW.cost_amount;
        v_payment_currency := NEW.cost_currency_code;
        v_employee_id := NEW.created_by;

        -- Deduct from purchase account
        SELECT success, message, transaction_id INTO v_result, v_message, v_transaction_id
        FROM deduct_from_purchase_account(
            v_employee_id,
            v_payment_amount,
            v_payment_currency,
            'Payment for supplier - Order: ' || COALESCE(NEW.order_number, NEW.id::TEXT),
            NEW.created_by,
            'currency_order',
            NEW.id
        );

        IF NOT v_result THEN
            RAISE WARNING 'Failed to deduct from purchase account: %', v_message;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 6. FUNCTION: Credit Sales Account on SALE completion
-- ============================================
CREATE OR REPLACE FUNCTION credit_sales_account_on_sale_completion()
RETURNS TRIGGER SECURITY DEFINER SET search_path = 'public'
AS $$
DECLARE
    v_sale_amount NUMERIC;
    v_sale_currency TEXT;
    v_employee_id UUID;
    v_result BOOLEAN;
    v_message TEXT;
    v_transaction_id UUID;
BEGIN
    -- Only trigger on SALE order completion
    IF TG_OP = 'UPDATE'
       AND OLD.status != 'completed'
       AND NEW.status = 'completed'
       AND NEW.order_type = 'SALE'
       AND NEW.sale_amount IS NOT NULL
       AND NEW.sale_amount > 0 THEN

        v_sale_amount := NEW.sale_amount;
        v_sale_currency := NEW.sale_currency_code;
        v_employee_id := NEW.created_by;

        -- Credit to sales account
        SELECT success, message, transaction_id INTO v_result, v_message, v_transaction_id
        FROM credit_to_sales_account(
            v_employee_id,
            v_sale_amount,
            v_sale_currency,
            'Sale revenue - Order: ' || COALESCE(NEW.order_number, NEW.id::TEXT),
            NEW.created_by,
            'currency_order',
            NEW.id
        );

        IF NOT v_result THEN
            RAISE WARNING 'Failed to credit sales account: %', v_message;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 7. CREATE VIEWS
-- ============================================
CREATE OR REPLACE VIEW employee_trading_accounts_view AS
SELECT
    ef.id,
    ef.employee_id,
    p.display_name as employee_name,
    ef.account_type,
    ef.currency_code,
    ef.current_balance,
    ef.credit_limit,
    ef.is_active,
    ef.created_at,
    ef.updated_at
FROM employee_fund_accounts ef
JOIN profiles p ON ef.employee_id = p.id
WHERE ef.is_active = true
ORDER BY ef.account_type, p.display_name, ef.currency_code;

CREATE OR REPLACE VIEW employee_trading_transactions_view AS
SELECT
    eft.id,
    eft.employee_id,
    p.display_name as employee_name,
    eft.transaction_type,
    eft.account_type,
    eft.amount,
    eft.currency_code,
    eft.balance_before,
    eft.balance_after,
    eft.description,
    eft.reference_type,
    eft.reference_id,
    eft.status,
    eft.created_at,
    eft.created_by
FROM employee_fund_transactions eft
JOIN profiles p ON eft.employee_id = p.id
ORDER BY eft.created_at DESC;

-- ============================================
-- 8. CREATE TRIGGERS
-- ============================================
-- Drop existing triggers if any
DROP TRIGGER IF EXISTS trigger_employee_fund_on_purchase_completion ON currency_orders;
DROP TRIGGER IF EXISTS trigger_employee_fund_on_sale_completion ON currency_orders;
DROP TRIGGER IF EXISTS tr_currency_order_completion ON currency_orders;
DROP TRIGGER IF EXISTS tr_employee_fund_purchase_completion ON currency_orders;
DROP TRIGGER IF EXISTS tr_employee_fund_sale_completion ON currency_orders;
DROP TRIGGER IF EXISTS trigger_debit_purchase_on_completion ON currency_orders;
DROP TRIGGER IF EXISTS trigger_credit_sales_on_completion ON currency_orders;

-- Create new triggers
CREATE TRIGGER trigger_debit_purchase_on_completion
AFTER UPDATE OF status ON currency_orders
FOR EACH ROW
EXECUTE FUNCTION debit_purchase_account_on_purchase_completion();

CREATE TRIGGER trigger_credit_sales_on_completion
AFTER UPDATE OF status ON currency_orders
FOR EACH ROW
EXECUTE FUNCTION credit_sales_account_on_sale_completion();

-- ============================================
-- 9. HELPER FUNCTION: Get Employee Trading Accounts Summary
-- ============================================
CREATE OR REPLACE FUNCTION get_employee_trading_accounts_summary(p_employee_id UUID DEFAULT NULL)
RETURNS TABLE (
    employee_id UUID,
    employee_name TEXT,
    account_type TEXT,
    currency_code TEXT,
    current_balance NUMERIC,
    credit_limit NUMERIC,
    available_credit NUMERIC
) SECURITY DEFINER SET search_path = 'public'
AS $$
BEGIN
    RETURN QUERY
    SELECT
        ef.employee_id,
        p.display_name as employee_name,
        ef.account_type,
        ef.currency_code,
        ef.current_balance,
        ef.credit_limit,
        ef.credit_limit - ef.current_balance as available_credit
    FROM employee_fund_accounts ef
    JOIN profiles p ON ef.employee_id = p.id
    WHERE ef.is_active = true
      AND (p_employee_id IS NULL OR ef.employee_id = p_employee_id)
    ORDER BY ef.account_type, ef.currency_code;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 10. GRANT PERMISSIONS
-- ============================================
GRANT EXECUTE ON FUNCTION deduct_from_purchase_account(UUID, NUMERIC, TEXT, TEXT, UUID, TEXT, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION credit_to_sales_account(UUID, NUMERIC, TEXT, TEXT, UUID, TEXT, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_employee_trading_accounts_summary(UUID) TO authenticated;
GRANT SELECT ON employee_trading_accounts_view TO authenticated;
GRANT SELECT ON employee_trading_transactions_view TO authenticated;

-- ============================================
-- 11. VERIFY SETUP
-- ============================================
SELECT
    'employee_trading_accounts' as component,
    'CREATED' as status,
    'Purchase/Sales accounts with auto-deduct/credit on order completion' as notes
UNION ALL
SELECT
    'triggers',
    'CREATED',
    'Auto-deduct purchase account on PURCHASE completion, auto-credit sales account on SALE completion'
UNION ALL
SELECT
    'functions',
    'CREATED',
    'deduct_from_purchase_account, credit_to_sales_account, get_employee_trading_accounts_summary'
UNION ALL
SELECT
    'views',
    'CREATED',
    'employee_trading_accounts_view, employee_trading_transactions_view';
