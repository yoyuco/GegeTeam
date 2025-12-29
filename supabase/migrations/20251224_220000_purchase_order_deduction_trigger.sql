-- Purchase Order Wallet Deduction Trigger
-- Automatically deduct from employee's purchase account when completing a PURCHASE order
-- Supports multi-currency (VND, USD, CNY) and allows negative balance (debt/overdraft)

-- Enable realtime for employee_fund_accounts
ALTER PUBLICATION supabase_realtime ADD TABLE employee_fund_accounts;

-- Trigger function to deduct from purchase account on order completion
CREATE OR REPLACE FUNCTION deduct_purchase_account_on_order_completion()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_employee_id UUID;
    v_account_id UUID;
    v_amount NUMERIC;
    v_current_balance NUMERIC;
    v_new_balance NUMERIC;
    v_cost_amount NUMERIC;
    v_currency_code TEXT;
BEGIN
    -- Only trigger when status changes to completed
    IF NEW.status <> 'completed' OR OLD.status = 'completed' THEN
        RETURN NEW;
    END IF;

    -- Only for PURCHASE orders
    IF NEW.order_type <> 'PURCHASE' THEN
        RETURN NEW;
    END IF;

    -- Get the employee who completed the order
    v_employee_id := NEW.completed_by;
    IF v_employee_id IS NULL THEN
        v_employee_id := NEW.assigned_to;
    END IF;

    -- Get cost amount and currency
    v_cost_amount := COALESCE(NEW.cost_amount, 0);
    v_currency_code := NEW.cost_currency_code;

    -- Find or create employee's purchase fund account for this currency
    SELECT id, current_balance INTO v_account_id, v_current_balance
    FROM employee_fund_accounts
    WHERE employee_id = v_employee_id
      AND account_type = 'purchase'
      AND currency_code = v_currency_code
      AND is_active = true
    FOR UPDATE;

    -- If account doesn't exist, create it (for VND, USD, CNY, etc.)
    IF v_account_id IS NULL THEN
        INSERT INTO employee_fund_accounts (
            employee_id, account_type, currency_code,
            current_balance, credit_limit, is_active, created_by
        ) VALUES (
            v_employee_id, 'purchase', v_currency_code,
            0, 0, true, v_employee_id
        ) RETURNING id, current_balance INTO v_account_id, v_current_balance;
    END IF;

    -- Deduct from account (ALLOW NEGATIVE - debt/overdraft)
    v_new_balance := v_current_balance - v_cost_amount;

    UPDATE employee_fund_accounts
    SET current_balance = v_new_balance, updated_at = NOW()
    WHERE id = v_account_id;

    -- Create transaction record
    INSERT INTO employee_fund_transactions (
        employee_id, transaction_type, amount, currency_code,
        balance_before, balance_after, description,
        reference_type, reference_id, status, account_type, created_by
    ) VALUES (
        v_employee_id, 'PURCHASE_ORDER', v_cost_amount, v_currency_code,
        v_current_balance, v_new_balance,
        'Thanh toán đơn mua: ' || COALESCE(NEW.order_number, NEW.id::TEXT),
        'currency_order', NEW.id, 'COMPLETED', 'purchase', v_employee_id
    );

    RETURN NEW;
END;
$$;

-- Drop existing trigger if any
DROP TRIGGER IF EXISTS trigger_deduct_purchase_on_completion ON currency_orders;

-- Create trigger
CREATE TRIGGER trigger_deduct_purchase_on_completion
    AFTER UPDATE ON currency_orders
    FOR EACH ROW
    EXECUTE FUNCTION deduct_purchase_account_on_order_completion();

-- Add comment for documentation
COMMENT ON FUNCTION deduct_purchase_account_on_order_completion() IS
'Trigger function to automatically deduct from employee purchase account when completing a PURCHASE order. Supports multi-currency and allows negative balance.';
