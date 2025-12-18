-- Migration: Integration Triggers with Existing System (Fixed)
-- Description: Triggers for automatic journal entries and integration with currency orders
-- Created: 2025-12-18 16:30:00
-- Author: Claude Code

-- 1. Trigger to create journal entry when currency order is completed
CREATE OR REPLACE FUNCTION create_journal_entry_on_currency_order_completion()
RETURNS TRIGGER AS $$
DECLARE
    v_journal_entry_id UUID;
    v_entry_number TEXT;
    v_cash_account_id UUID;
    v_revenue_account_id UUID;
    v_cogs_account_id UUID;
    v_inventory_account_id UUID;
    v_party_name TEXT;
    v_description TEXT;
BEGIN
    -- Only process when status changes to 'completed'
    IF TG_OP = 'UPDATE' AND OLD.status != 'completed' AND NEW.status = 'completed' THEN

        -- Get party name for description
        SELECT name INTO v_party_name FROM parties WHERE id = NEW.party_id;

        v_description := CASE
            WHEN NEW.order_type = 'SALE' THEN
                'Sales to ' || COALESCE(v_party_name, 'Customer') || ' - Order #' || NEW.order_number
            WHEN NEW.order_type = 'PURCHASE' THEN
                'Purchase from ' || COALESCE(v_party_name, 'Supplier') || ' - Order #' || NEW.order_number
            ELSE
                'Currency transaction - Order #' || NEW.order_number
        END;

        -- Generate entry number
        v_entry_number := generate_journal_entry_number();

        -- Get account IDs based on currency
        v_cash_account_id := CASE
            WHEN NEW.sale_currency_code = 'USD' THEN (SELECT id FROM chart_of_accounts WHERE account_code = '102')
            ELSE (SELECT id FROM chart_of_accounts WHERE account_code = '101')
        END;

        v_revenue_account_id := (SELECT id FROM chart_of_accounts WHERE account_code = '500');
        v_cogs_account_id := (SELECT id FROM chart_of_accounts WHERE account_code = '600');
        v_inventory_account_id := (SELECT id FROM chart_of_accounts WHERE account_code = '400');

        -- Create journal entry header
        INSERT INTO journal_entries (
            entry_number, entry_date, description,
            reference_type, reference_id, total_amount,
            status, created_by, posted_at, posted_by
        ) VALUES (
            v_entry_number, NEW.completed_at::DATE, v_description,
            'currency_order', NEW.id, NEW.sale_amount,
            'POSTED', NEW.assigned_to, now(), NEW.assigned_to
        ) RETURNING id INTO v_journal_entry_id;

        -- Create journal entry lines based on order type
        IF NEW.order_type = 'SALE' THEN
            -- Sales transaction: Debit Cash, Credit Revenue
            INSERT INTO journal_entry_lines (entry_id, line_number, account_id, entity_type, entity_id, debit_amount, credit_amount, description)
            VALUES
                (v_journal_entry_id, 1, v_cash_account_id, 'COMPANY', '00000000-0000-0000-0000-000000000000', NEW.sale_amount, 0, 'Cash received from customer'),
                (v_journal_entry_id, 2, v_revenue_account_id, 'COMPANY', '00000000-0000-0000-0000-000000000000', 0, NEW.sale_amount, 'Sales revenue');

            -- If there's cost, also record COGS and inventory reduction
            IF NEW.cost_amount > 0 THEN
                INSERT INTO journal_entry_lines (entry_id, line_number, account_id, entity_type, entity_id, debit_amount, credit_amount, description)
                VALUES
                    (v_journal_entry_id, 3, v_cogs_account_id, 'COMPANY', '00000000-0000-0000-0000-000000000000', NEW.cost_amount, 0, 'Cost of goods sold'),
                    (v_journal_entry_id, 4, v_inventory_account_id, 'COMPANY', '00000000-0000-0000-0000-000000000000', 0, NEW.cost_amount, 'Inventory reduction');
            END IF;

        ELSIF NEW.order_type = 'PURCHASE' THEN
            -- Purchase transaction: Debit Inventory, Credit Cash
            INSERT INTO journal_entry_lines (entry_id, line_number, account_id, entity_type, entity_id, debit_amount, credit_amount, description)
            VALUES
                (v_journal_entry_id, 1, v_inventory_account_id, 'COMPANY', '00000000-0000-0000-0000-000000000000', NEW.cost_amount, 0, 'Inventory purchased'),
                (v_journal_entry_id, 2, v_cash_account_id, 'COMPANY', '00000000-0000-0000-0000-000000000000', 0, NEW.cost_amount, 'Cash paid to supplier');
        END IF;

    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create the trigger
DROP TRIGGER IF EXISTS tr_currency_order_completion ON currency_orders;
CREATE TRIGGER tr_currency_order_completion
    AFTER UPDATE ON currency_orders
    FOR EACH ROW EXECUTE FUNCTION create_journal_entry_on_currency_order_completion();

-- 2. Function to handle employee fund allocation from purchase order completion (FIXED)
CREATE OR REPLACE FUNCTION handle_employee_fund_on_purchase_completion()
RETURNS TRIGGER AS $$
DECLARE
    v_employee_id UUID;
    v_allocation_amount DECIMAL(20,4);
    v_result JSON;
BEGIN
    -- Only process when purchase order is completed and assigned to employee
    IF TG_OP = 'UPDATE'
       AND OLD.status != 'completed'
       AND NEW.status = 'completed'
       AND NEW.order_type = 'PURCHASE'
       AND NEW.assigned_to IS NOT NULL THEN

        v_employee_id := NEW.assigned_to;
        v_allocation_amount := NEW.cost_amount;

        -- Allocate funds to employee if amount > 0
        IF v_allocation_amount > 0 THEN
            v_result := allocate_employee_fund(
                v_employee_id,
                v_allocation_amount,
                NEW.cost_currency_code,
                'Purchase Order #' || NEW.order_number || ' completion',
                'purchase_order',
                NEW.id,
                false -- Don't auto-approve for large amounts
            );

            -- If allocation requires approval, create approval request
            IF NOT (v_result->>'success')::BOOLEAN THEN
                DECLARE
                    v_approval_request_id UUID;
                BEGIN
                    v_approval_request_id := create_approval_request(
                        'employee_fund',
                        (v_result->>'approval_request_id')::UUID,
                        'Employee Fund Allocation - Purchase #' || NEW.order_number,
                        'Fund allocation for completing purchase order: ' || NEW.order_number,
                        v_allocation_amount,
                        NEW.cost_currency_code,
                        json_build_object(
                            'currency_order_id', NEW.id,
                            'employee_id', v_employee_id,
                            'allocation_result', v_result
                        ),
                        'NORMAL',
                        72
                    );
                END;
            END IF;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create the trigger
DROP TRIGGER IF EXISTS tr_employee_fund_purchase_completion ON currency_orders;
CREATE TRIGGER tr_employee_fund_purchase_completion
    AFTER UPDATE ON currency_orders
    FOR EACH ROW EXECUTE FUNCTION handle_employee_fund_on_purchase_completion();

-- 3. Function to handle employee fund return on sales order completion
CREATE OR REPLACE FUNCTION handle_employee_fund_return_on_sale_completion()
RETURNS TRIGGER AS $$
DECLARE
    v_employee_id UUID;
    v_return_amount DECIMAL(20,4);
    v_result JSON;
BEGIN
    -- Only process when sale order is completed and assigned to employee
    IF TG_OP = 'UPDATE'
       AND OLD.status != 'completed'
       AND NEW.status = 'completed'
       AND NEW.order_type = 'SALE'
       AND NEW.assigned_to IS NOT NULL THEN

        v_employee_id := NEW.assigned_to;
        v_return_amount := NEW.sale_amount;

        -- Return funds from employee if amount > 0
        IF v_return_amount > 0 THEN
            v_result := return_employee_fund(
                v_employee_id,
                v_return_amount,
                NEW.sale_currency_code,
                'Sales Order #' || NEW.order_number || ' completion',
                'sales_order',
                NEW.id
            );
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create the trigger
DROP TRIGGER IF EXISTS tr_employee_fund_sale_completion ON currency_orders;
CREATE TRIGGER tr_employee_fund_sale_completion
    AFTER UPDATE ON currency_orders
    FOR EACH ROW EXECUTE FUNCTION handle_employee_fund_return_on_sale_completion();

-- 4. Create reconciliation view between employee funds and accounting
CREATE OR REPLACE VIEW employee_fund_reconciliation AS
SELECT
    efa.employee_id,
    efa.currency_code,
    efa.current_balance as employee_fund_balance,
    COALESCE(ab.current_balance, 0) as accounting_balance,
    COALESCE(eft.total_allocated, 0) as total_allocated,
    COALESCE(eft.total_returned, 0) as total_returned,
    efa.current_balance - COALESCE(ab.current_balance, 0) as variance,
    CASE
        WHEN efa.current_balance = COALESCE(ab.current_balance, 0) THEN 'BALANCED'
        WHEN efa.current_balance > COALESCE(ab.current_balance, 0) THEN 'EMPLOYEE_HIGHER'
        ELSE 'ACCOUNTING_HIGHER'
    END as reconciliation_status,
    p.display_name as employee_name,
    efa.updated_at as last_updated
FROM employee_fund_accounts efa
JOIN profiles p ON efa.employee_id = p.id
LEFT JOIN account_balances ab ON efa.employee_id = ab.entity_id
    AND ab.account_id = (SELECT id FROM chart_of_accounts WHERE account_code = CASE
        WHEN efa.currency_code = 'USD' THEN '202'
        ELSE '201'
    END)
    AND ab.currency_code = efa.currency_code
LEFT JOIN (
    SELECT
        employee_id,
        currency_code,
        SUM(CASE WHEN transaction_type = 'ALLOCATION' THEN amount ELSE 0 END) as total_allocated,
        SUM(CASE WHEN transaction_type = 'RETURN' THEN amount ELSE 0 END) as total_returned
    FROM employee_fund_transactions
    WHERE status = 'COMPLETED'
    GROUP BY employee_id, currency_code
) eft ON efa.employee_id = eft.employee_id AND efa.currency_code = eft.currency_code
WHERE efa.is_active = true;

-- 5. Create comprehensive financial dashboard view
CREATE OR REPLACE VIEW financial_dashboard AS
SELECT
    -- Cash balances
    (SELECT COALESCE(SUM(current_balance), 0)
     FROM account_balances ab
     JOIN chart_of_accounts ca ON ab.account_id = ca.id
     WHERE ca.account_code IN ('101', '102')
       AND ab.currency_code = 'VND') as cash_vnd_balance,

    (SELECT COALESCE(SUM(current_balance), 0)
     FROM account_balances ab
     JOIN chart_of_accounts ca ON ab.account_id = ca.id
     WHERE ca.account_code IN ('101', '102')
       AND ab.currency_code = 'USD') as cash_usd_balance,

    -- Employee funds
    (SELECT COALESCE(SUM(current_balance), 0)
     FROM employee_fund_accounts
     WHERE currency_code = 'VND') as employee_funds_vnd,

    (SELECT COALESCE(SUM(current_balance), 0)
     FROM employee_fund_accounts
     WHERE currency_code = 'USD') as employee_funds_usd,

    -- Today's summaries
    (SELECT COUNT(*) FROM currency_orders WHERE DATE(created_at) = CURRENT_DATE) as orders_today,
    (SELECT COUNT(*) FROM currency_orders WHERE status = 'completed' AND DATE(completed_at) = CURRENT_DATE) as completed_today,
    (SELECT COALESCE(SUM(sale_amount), 0) FROM currency_orders WHERE status = 'completed' AND DATE(completed_at) = CURRENT_DATE) as sales_today,

    -- Pending approvals
    (SELECT COUNT(*) FROM approval_requests WHERE status = 'PENDING') as pending_approvals,
    (SELECT COUNT(*) FROM approval_requests WHERE status = 'PENDING' AND expires_at < now() + interval '24 hours') as urgent_approvals,

    -- Employee fund metrics
    (SELECT COUNT(*) FROM employee_fund_accounts WHERE current_balance > credit_limit * 0.8) as employees_near_limit,
    (SELECT COUNT(*) FROM employee_fund_accounts WHERE current_balance > 0) as active_employee_accounts;

-- 6. Create function to get financial summary for date range
CREATE OR REPLACE FUNCTION get_financial_summary(
    p_start_date DATE DEFAULT CURRENT_DATE - INTERVAL '30 days',
    p_end_date DATE DEFAULT CURRENT_DATE
)
RETURNS JSON AS $$
DECLARE
    v_result JSON;
BEGIN
    SELECT json_build_object(
        'period', json_build_object('start_date', p_start_date, 'end_date', p_end_date),
        'cash_balances', json_build_object(
            'vnd', (SELECT COALESCE(SUM(current_balance), 0) FROM account_balances ab JOIN chart_of_accounts ca ON ab.account_id = ca.id WHERE ca.account_code IN ('101', '102') AND ab.currency_code = 'VND'),
            'usd', (SELECT COALESCE(SUM(current_balance), 0) FROM account_balances ab JOIN chart_of_accounts ca ON ab.account_id = ca.id WHERE ca.account_code IN ('101', '102') AND ab.currency_code = 'USD')
        ),
        'employee_funds', json_build_object(
            'vnd', (SELECT COALESCE(SUM(current_balance), 0) FROM employee_fund_accounts WHERE currency_code = 'VND'),
            'usd', (SELECT COALESCE(SUM(current_balance), 0) FROM employee_fund_accounts WHERE currency_code = 'USD'),
            'active_accounts', (SELECT COUNT(*) FROM employee_fund_accounts WHERE current_balance > 0)
        ),
        'orders_summary', json_build_object(
            'total_orders', (SELECT COUNT(*) FROM currency_orders WHERE DATE(created_at) BETWEEN p_start_date AND p_end_date),
            'completed_orders', (SELECT COUNT(*) FROM currency_orders WHERE status = 'completed' AND DATE(completed_at) BETWEEN p_start_date AND p_end_date),
            'total_sales', (SELECT COALESCE(SUM(sale_amount), 0) FROM currency_orders WHERE status = 'completed' AND DATE(completed_at) BETWEEN p_start_date AND p_end_date),
            'total_costs', (SELECT COALESCE(SUM(cost_amount), 0) FROM currency_orders WHERE status = 'completed' AND DATE(completed_at) BETWEEN p_start_date AND p_end_date)
        ),
        'pending_approvals', (SELECT COUNT(*) FROM approval_requests WHERE status = 'PENDING')
    ) INTO v_result;

    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

SELECT 'Integration triggers migration completed successfully!' as success_message;