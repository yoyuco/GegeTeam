-- Fix enum case issues for purchase order completion
-- This migration fixes trigger functions and check constraints

-- ============================================
-- FIX TRIGGER FUNCTIONS (lowercase 'completed', correct order_type)
-- ============================================

-- Fix credit_sales_account_on_sale_completion
CREATE OR REPLACE FUNCTION credit_sales_account_on_sale_completion()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    IF NEW.status <> 'completed' OR OLD.status = 'completed' THEN
        RETURN NEW;
    END IF;

    IF NEW.order_type <> 'SALE' THEN
        RETURN NEW;
    END IF;

    -- TODO: Add sales credit logic
    RETURN NEW;
END;
$$;

-- Fix debit_purchase_account_on_purchase_completion
CREATE OR REPLACE FUNCTION debit_purchase_account_on_purchase_completion()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    IF NEW.status <> 'completed' OR OLD.status = 'completed' THEN
        RETURN NEW;
    END IF;

    IF NEW.order_type <> 'PURCHASE' THEN
        RETURN NEW;
    END IF;

    -- TODO: Add debit logic
    RETURN NEW;
END;
$$;

-- Fix deduct_purchase_account_on_order_completion (use uppercase COMPLETED for transactions)
CREATE OR REPLACE FUNCTION deduct_purchase_account_on_order_completion()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_employee_id UUID;
    v_account_id UUID;
    v_current_balance NUMERIC;
    v_new_balance NUMERIC;
    v_cost_amount NUMERIC;
    v_currency_code TEXT;
BEGIN
    IF NEW.status <> 'completed' OR OLD.status = 'completed' THEN
        RETURN NEW;
    END IF;

    IF NEW.order_type <> 'PURCHASE' THEN
        RETURN NEW;
    END IF;

    v_employee_id := NEW.completed_by;
    IF v_employee_id IS NULL THEN
        v_employee_id := NEW.assigned_to;
    END IF;

    v_cost_amount := COALESCE(NEW.cost_amount, 0);
    v_currency_code := NEW.cost_currency_code;

    SELECT id, current_balance INTO v_account_id, v_current_balance
    FROM employee_fund_accounts
    WHERE employee_id = v_employee_id
      AND account_type = 'purchase'
      AND currency_code = v_currency_code
      AND is_active = true
    FOR UPDATE;

    IF v_account_id IS NULL THEN
        INSERT INTO employee_fund_accounts (
            employee_id, account_type, currency_code,
            current_balance, credit_limit, is_active, created_by
        ) VALUES (
            v_employee_id, 'purchase', v_currency_code,
            0, 0, true, v_employee_id
        ) RETURNING id, current_balance INTO v_account_id, v_current_balance;
    END IF;

    v_new_balance := v_current_balance - v_cost_amount;

    UPDATE employee_fund_accounts
    SET current_balance = v_new_balance, updated_at = NOW()
    WHERE id = v_account_id;

    INSERT INTO employee_fund_transactions (
        employee_id, transaction_type, amount, currency_code,
        balance_before, balance_after, description,
        reference_type, reference_id, status, account_type, created_by
    ) VALUES (
        v_employee_id, 'PURCHASE_ORDER', v_cost_amount, v_currency_code,
        v_current_balance, v_new_balance,
        'Thanh toán đơn mua: ' || COALESCE(NEW.order_number, NEW.id::TEXT),
        'currency_order', NEW.id, 'COMPLETED',
        'purchase', v_employee_id
    );

    RETURN NEW;
END;
$$;

-- ============================================
-- FIX CHECK CONSTRAINTS (add lowercase and new transaction types)
-- ============================================

-- Add lowercase 'completed' to status check
ALTER TABLE employee_fund_transactions
DROP CONSTRAINT IF EXISTS employee_fund_transactions_status_check,
ADD CONSTRAINT employee_fund_transactions_status_check
CHECK (status::text = ANY(ARRAY['PENDING', 'APPROVED', 'REJECTED', 'COMPLETED', 'completed']::text[]));

-- Add PURCHASE_ORDER to transaction types
ALTER TABLE employee_fund_transactions
DROP CONSTRAINT IF EXISTS employee_fund_transactions_transaction_type_check,
ADD CONSTRAINT employee_fund_transactions_transaction_type_check
CHECK (transaction_type::text = ANY(ARRAY['ALLOCATION', 'RETURN', 'ADJUSTMENT', 'PURCHASE_ORDER', 'SALES_CREDIT']::text[]));

-- ============================================
-- FIX RPC FUNCTION (lowercase 'completed')
-- ============================================

DROP FUNCTION IF EXISTS complete_purchase_order_wac(UUID, UUID, TEXT[], UUID);

CREATE OR REPLACE FUNCTION complete_purchase_order_wac(
    p_order_id UUID,
    p_completed_by UUID DEFAULT NULL,
    p_proofs TEXT[] DEFAULT NULL,
    p_channel_id UUID DEFAULT NULL
)
RETURNS TABLE(success BOOLEAN, message TEXT, details JSONB)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_order RECORD;
    v_user_id UUID;
    v_existing_proofs JSONB;
    v_new_payment_proofs JSONB;
    v_final_proofs JSONB;
BEGIN
    IF p_completed_by IS NOT NULL THEN
        v_user_id := p_completed_by;
    ELSE
        v_user_id := get_current_profile_id();
    END IF;

    SELECT * INTO v_order FROM currency_orders
    WHERE id = p_order_id AND order_type = 'PURCHASE' AND status = 'delivered';

    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'Purchase order not found or not delivered yet.', NULL::JSONB;
        RETURN;
    END IF;

    v_existing_proofs := COALESCE(v_order.proofs, '{}'::jsonb);
    v_new_payment_proofs := '[]'::jsonb;

    IF p_proofs IS NOT NULL THEN
        FOR i IN 1..array_length(p_proofs, 1) LOOP
            v_new_payment_proofs := v_new_payment_proofs ||
                jsonb_build_object(
                    'type', 'payment',
                    'url', p_proofs[i],
                    'uploaded_at', NOW()::text
                );
        END LOOP;
    END IF;

    v_final_proofs := v_existing_proofs || v_new_payment_proofs;

    UPDATE currency_orders SET
        status = 'completed',
        completed_at = NOW(),
        completed_by = v_user_id,
        proofs = v_final_proofs,
        updated_at = NOW(),
        updated_by = v_user_id
    WHERE id = p_order_id;

    RETURN QUERY SELECT TRUE,
        format('Purchase order completed! %s proof(s). Order: %s',
               jsonb_array_length(v_new_payment_proofs),
               COALESCE(v_order.order_number, p_order_id::TEXT)
        ),
        jsonb_build_object(
            'order_id', p_order_id,
            'order_number', v_order.order_number,
            'status', 'completed',
            'completed_at', NOW(),
            'proofs_count', jsonb_array_length(v_final_proofs)
        );

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, 'Error: ' || SQLERRM, NULL::JSONB;
END;
$$;
