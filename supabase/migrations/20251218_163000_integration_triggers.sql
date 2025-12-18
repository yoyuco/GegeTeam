-- Migration: Integration Triggers with Existing System
-- Description: Create triggers to integrate accounting system with currency orders and transactions
-- Created: 2025-12-18 15:30:00
-- Author: Claude Code

-- Function to create journal entry for completed currency order
CREATE OR REPLACE FUNCTION create_journal_entry_for_currency_order()
RETURNS TRIGGER AS $$
DECLARE
    v_journal_entry_id uuid;
    v_entry_number text;
    v_cash_account_id uuid;
    v_revenue_account_id uuid;
    v_cogs_account_id uuid;
    v_inventory_account_id uuid;
    v_receivable_account_id uuid;
    v_je_lines JSONB;
BEGIN
    -- Only create journal entry when order is completed and not already posted
    IF NEW.status != 'completed' OR (OLD.status = 'completed' AND NEW.is_posted_to_gl = true) THEN
        RETURN NEW;
    END IF;

    -- Generate journal entry number
    v_entry_number := 'JE-' || EXTRACT(YEAR FROM NEW.created_at) || '-' ||
                    LPAD(nextval('journal_entry_seq')::text, 5, '0');

    -- Get appropriate accounts
    SELECT id INTO v_cash_account_id
    FROM chart_of_accounts
    WHERE account_code = CASE NEW.cost_currency_code
        WHEN 'VND' THEN '101'
        WHEN 'USD' THEN '102'
        WHEN 'CNY' THEN '103'
        ELSE '101'
    END;

    SELECT id INTO v_revenue_account_id
    FROM chart_of_accounts
    WHERE account_code = '400' -- Sales Revenue
    LIMIT 1;

    SELECT id INTO v_cogs_account_id
    FROM chart_of_accounts
    WHERE account_code = '500' -- Cost of Goods Sold
    LIMIT 1;

    SELECT id INTO v_inventory_account_id
    FROM chart_of_accounts
    WHERE account_code = '110' -- Inventory
    LIMIT 1;

    SELECT id INTO v_receivable_account_id
    FROM chart_of_accounts
    WHERE account_code = '130' -- Accounts Receivable
    LIMIT 1;

    -- Create journal entry
    INSERT INTO journal_entries (
        entry_number, entry_date, description, reference_type, reference_id,
        total_amount, currency_code, status, created_by
    ) VALUES (
        v_entry_number, NEW.created_at::date,
        'Currency Order: ' || NEW.order_number || ' - ' || NEW.order_type,
        'currency_order', NEW.id,
        COALESCE(NEW.sale_amount, NEW.cost_amount), -- Use sale amount if available, else cost
        NEW.cost_currency_code, 'posted', NEW.created_by
    ) RETURNING id INTO v_journal_entry_id;

    -- Create journal lines based on order type
    IF NEW.order_type = 'SALE' THEN
        -- SALE ORDER: Customer buys from company

        -- Debit: Accounts Receivable (if not cash sale) or Cash
        INSERT INTO journal_entry_lines (
            journal_entry_id, line_number, account_id, entity_type, entity_id,
            debit_amount, description
        ) VALUES (
            v_journal_entry_id, 1, v_receivable_account_id, 'customer', NEW.party_id,
            NEW.sale_amount, 'Sale to customer: ' || NEW.order_number
        );

        -- Credit: Sales Revenue
        INSERT INTO journal_entry_lines (
            journal_entry_id, line_number, account_id,
            credit_amount, description
        ) VALUES (
            v_journal_entry_id, 2, v_revenue_account_id, NEW.sale_amount,
            'Sales revenue: ' || NEW.order_number
        );

        -- Debit: Cost of Goods Sold
        INSERT INTO journal_entry_lines (
            journal_entry_id, line_number, account_id,
            debit_amount, description
        ) VALUES (
            v_journal_entry_id, 3, v_cogs_account_id, NEW.cost_amount,
            'Cost of goods sold: ' || NEW.order_number
        );

        -- Credit: Inventory
        INSERT INTO journal_entry_lines (
            journal_entry_id, line_number, account_id,
            credit_amount, description
        ) VALUES (
            v_journal_entry_id, 4, v_inventory_account_id, NEW.cost_amount,
            'Inventory reduction: ' || NEW.order_number
        );

    ELSIF NEW.order_type = 'PURCHASE' THEN
        -- PURCHASE ORDER: Company buys from supplier

        -- Debit: Inventory
        INSERT INTO journal_entry_lines (
            journal_entry_id, line_number, account_id,
            debit_amount, description
        ) VALUES (
            v_journal_entry_id, 1, v_inventory_account_id, NEW.cost_amount,
            'Inventory purchase: ' || NEW.order_number
        );

        -- Credit: Cash or Accounts Payable
        INSERT INTO journal_entry_lines (
            journal_entry_id, line_number, account_id, entity_type, entity_id,
            credit_amount, description
        ) VALUES (
            v_journal_entry_id, 2, v_cash_account_id, 'supplier', NEW.party_id,
            NEW.cost_amount, 'Payment to supplier: ' || NEW.order_number
        );

    ELSIF NEW.order_type = 'EXCHANGE' THEN
        -- EXCHANGE ORDER: Currency exchange

        -- This is more complex - simplified version for now
        -- Debit: Cash (new currency)
        INSERT INTO journal_entry_lines (
            journal_entry_id, line_number, account_id,
            debit_amount, description
        ) SELECT v_journal_entry_id, 1, id, NEW.sale_amount,
               'Exchange - Received: ' || NEW.order_number
        FROM chart_of_accounts
        WHERE account_code = CASE NEW.cost_currency_code
            WHEN 'VND' THEN '101'
            WHEN 'USD' THEN '102'
            WHEN 'CNY' THEN '103'
            ELSE '101'
        END;

        -- Credit: Cash (old currency)
        INSERT INTO journal_entry_lines (
            journal_entry_id, line_number, account_id,
            credit_amount, description
        ) SELECT v_journal_entry_id, 2, id, NEW.cost_amount,
               'Exchange - Given: ' || NEW.order_number
        FROM chart_of_accounts
        WHERE account_code = CASE NEW.foreign_currency_code
            WHEN 'VND' THEN '101'
            WHEN 'USD' THEN '102'
            WHEN 'CNY' THEN '103'
            ELSE '101'
        END;

        -- Record gain/loss if any
        IF NEW.profit_amount != 0 THEN
            INSERT INTO journal_entry_lines (
                journal_entry_id, line_number, account_id,
                CASE WHEN NEW.profit_amount > 0 THEN credit_amount ELSE debit_amount END,
                description
            ) SELECT v_journal_entry_id, 3, id, ABS(NEW.profit_amount),
                   CASE WHEN NEW.profit_amount > 0 THEN 'Exchange Gain' ELSE 'Exchange Loss' END || ': ' || NEW.order_number
            FROM chart_of_accounts
            WHERE account_code = '420'; -- Exchange Gain/Loss
        END IF;
    END IF;

    -- Update currency order with journal entry reference
    UPDATE currency_orders
    SET is_posted_to_gl = true,
        journal_entry_id = v_journal_entry_id
    WHERE id = NEW.id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to automatically create journal entries for completed currency orders
CREATE TRIGGER tr_currency_order_gl_integration
    AFTER UPDATE ON currency_orders
    FOR EACH ROW EXECUTE FUNCTION create_journal_entry_for_currency_order();

-- Function to track inventory transactions with before/after quantities
CREATE OR REPLACE FUNCTION track_inventory_transaction_quantities()
RETURNS TRIGGER AS $$
DECLARE
    v_before_quantity numeric(20,4);
    v_after_quantity numeric(20,4);
    v_pool_quantity numeric(20,4);
BEGIN
    -- Get current quantity from inventory pool
    SELECT COALESCE(quantity, 0) INTO v_pool_quantity
    FROM inventory_pools
    WHERE id = NEW.inventory_pool_id;

    -- Calculate before and after based on transaction type
    IF NEW.transaction_type IN ('sale_delivery', 'exchange_out', 'transfer_out', 'payout') THEN
        -- Outgoing transaction
        v_before_quantity := v_pool_quantity;
        v_after_quantity := v_pool_quantity - NEW.quantity;
    ELSIF NEW.transaction_type IN ('purchase', 'exchange_in', 'transfer_in', 'farm_in') THEN
        -- Incoming transaction
        v_before_quantity := v_pool_quantity;
        v_after_quantity := v_pool_quantity + NEW.quantity;
    ELSE
        -- Manual adjustment or other
        v_before_quantity := v_pool_quantity;
        v_after_quantity := v_pool_quantity; -- Will be calculated based on actual impact
    END IF;

    -- Update transaction with quantities
    UPDATE currency_transactions
    SET before_quantity = v_before_quantity,
        after_quantity = v_after_quantity
    WHERE id = NEW.id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to track inventory quantities
CREATE TRIGGER tr_track_inventory_quantities
    AFTER INSERT ON currency_transactions
    FOR EACH ROW EXECUTE FUNCTION track_inventory_transaction_quantities();

-- Function to create accounting entry for large employee fund transactions
CREATE OR REPLACE FUNCTION check_employee_fund_approval()
RETURNS TRIGGER AS $$
DECLARE
    v_needs_approval boolean;
    v_approval_request_id uuid;
    v_message text;
BEGIN
    -- Check if transaction needs approval
    SELECT requires_approval, approval_request_id, message
    INTO v_needs_approval, v_approval_request_id, v_message
    FROM create_approval_if_needed(
        'employee_fund',
        NEW.id,
        NEW.amount,
        NEW.currency_code,
        NEW.description,
        NEW.created_by,
        jsonb_build_object(
            'transaction_number', NEW.transaction_number,
            'employee_id', NEW.employee_id,
            'balance_before', NEW.balance_before,
            'balance_after', NEW.balance_after
        )
    );

    -- Update transaction status based on approval needs
    IF v_needs_approval THEN
        -- Mark as pending approval
        UPDATE employee_fund_transactions
        SET approval_status = 'pending'
        WHERE id = NEW.id;

        -- Set the balance back to before amount since not yet approved
        UPDATE employee_fund_accounts
        SET current_balance = NEW.balance_before
        WHERE employee_id = NEW.employee_id
          AND currency_code = NEW.currency_code;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to check approval for employee fund transactions
CREATE TRIGGER tr_employee_fund_approval_check
    AFTER INSERT ON employee_fund_transactions
    FOR EACH ROW EXECUTE FUNCTION check_employee_fund_approval();

-- Function to update average cost when inventory changes
CREATE OR REPLACE FUNCTION update_inventory_average_cost()
RETURNS TRIGGER AS $$
DECLARE
    v_total_cost numeric(20,4);
    v_total_quantity numeric(20,4);
    v_new_average_cost numeric(20,4);
BEGIN
    -- Only update for incoming transactions (purchase, farm_in)
    IF NEW.transaction_type NOT IN ('purchase', 'farm_in', 'transfer_in') THEN
        RETURN NEW;
    END IF;

    -- Calculate new average cost
    SELECT
        SUM(quantity * unit_price),
        SUM(quantity)
    INTO v_total_cost, v_total_quantity
    FROM currency_transactions ct
    JOIN inventory_pools ip ON ct.inventory_pool_id = ip.id
    WHERE ct.transaction_type IN ('purchase', 'farm_in', 'transfer_in')
      AND ct.inventory_pool_id = NEW.inventory_pool_id
      AND ct.id <= NEW.id;

    -- Update inventory pool average cost
    IF v_total_quantity > 0 THEN
        v_new_average_cost := v_total_cost / v_total_quantity;

        UPDATE inventory_pools
        SET average_cost = v_new_average_cost,
            last_updated_at = now()
        WHERE id = NEW.inventory_pool_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update inventory average cost
CREATE TRIGGER tr_update_inventory_average_cost
    AFTER INSERT ON currency_transactions
    FOR EACH ROW EXECUTE FUNCTION update_inventory_average_cost();

-- View for financial transaction summary
CREATE OR REPLACE VIEW financial_transaction_summary AS
SELECT
    -- Currency Orders
    co.order_type,
    COUNT(*) as order_count,
    COALESCE(SUM(co.cost_amount), 0) as total_cost,
    COALESCE(SUM(co.sale_amount), 0) as total_sale,
    COALESCE(SUM(co.profit_amount), 0) as total_profit,

    -- Currency Transactions
    COUNT(ct.id) as transaction_count,
    COALESCE(SUM(ct.quantity), 0) as total_quantity_transacted,

    -- Employee Funds
    COALESCE(SUM(CASE WHEN eft.transaction_type = 'FUND_ALLOCATION' THEN eft.amount ELSE 0 END), 0) as total_allocated,
    COALESCE(SUM(CASE WHEN eft.transaction_type = 'FUND_RETURN' THEN eft.amount ELSE 0 END), 0) as total_returned,

    -- Journal Entries
    COUNT(DISTINCT je.id) as journal_entry_count,
    COUNT(jel.id) as journal_line_count

FROM currency_orders co
FULL OUTER JOIN currency_transactions ct ON 1=1  -- Cross join for summary
FULL OUTER JOIN employee_fund_transactions eft ON 1=1
FULL OUTER JOIN journal_entries je ON 1=1
FULL OUTER JOIN journal_entry_lines jel ON 1=1
GROUP BY co.order_type;

-- View for reconciliation between employee funds and accounting
CREATE OR REPLACE VIEW employee_funds_reconciliation AS
SELECT
    p.display_name as employee_name,
    efa.currency_code,
    efa.current_balance as accounting_balance,
    SUM(CASE WHEN eft.approval_status = 'approved' THEN eft.amount ELSE 0 END) as approved_balance,
    efa.total_allocated as total_allocated_from_company,
    efa.total_returned as total_returned_to_company,
    (efa.total_allocated - efa.total_returned) as net_amount_with_company,
    COUNT(eft.id) as total_transactions,
    MAX(eft.created_at) as last_transaction_date
FROM employee_fund_accounts efa
JOIN profiles p ON efa.employee_id = p.id
LEFT JOIN employee_fund_transactions eft ON efa.employee_id = eft.employee_id
                                    AND efa.currency_code = eft.currency_code
WHERE efa.is_active = true
GROUP BY efa.id, p.display_name, efa.currency_code, efa.current_balance,
         efa.total_allocated, efa.total_returned
ORDER BY p.display_name, efa.currency_code;

-- Add comments for documentation
COMMENT ON FUNCTION create_journal_entry_for_currency_order() IS 'Creates journal entries when currency orders are completed';
COMMENT ON FUNCTION track_inventory_transaction_quantities() IS 'Tracks before/after quantities for inventory transactions';
COMMENT ON FUNCTION check_employee_fund_approval() IS 'Checks if employee fund transactions require approval';
COMMENT ON FUNCTION update_inventory_average_cost() IS 'Updates inventory average cost for new purchases';
COMMENT ON VIEW financial_transaction_summary IS 'Summary view of all financial transactions';
COMMENT ON VIEW employee_funds_reconciliation IS 'Reconciliation view between employee fund accounts and transactions';