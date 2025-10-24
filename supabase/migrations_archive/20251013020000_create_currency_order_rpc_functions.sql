-- ===================================
-- CURRENCY ORDERS RPC FUNCTIONS
-- Part 1: Create Orders (SELL & PURCHASE)
-- ===================================
-- Purpose: RPC functions for creating SELL and PURCHASE orders
-- Version: 1.0
-- Date: 2025-01-13

-- Helper function to get current profile ID
CREATE OR REPLACE FUNCTION get_current_profile_id()
RETURNS uuid AS $$
BEGIN
    RETURN (SELECT id FROM profiles WHERE auth_id = auth.uid() LIMIT 1);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 1. CREATE_CURRENCY_SELL_ORDER_V1
-- ============================================
-- Purpose: Sales creates a SELL order (customer buys currency from us)
-- Workflow: Creates order with status='pending', waits for OPS to process

CREATE OR REPLACE FUNCTION create_currency_sell_order_v1(
    -- Currency & Quantity
    p_currency_attribute_id UUID,
    p_quantity NUMERIC,
    p_unit_price_vnd NUMERIC,
    p_unit_price_usd NUMERIC,
    p_game_code TEXT,
    p_league_attribute_id UUID,

    -- Customer Information (REQUIRED)
    p_customer_name TEXT,
    p_customer_game_tag TEXT,
    p_delivery_info TEXT,
    p_channel_id UUID,

    -- Exchange Information (OPTIONAL)
    p_exchange_type TEXT DEFAULT NULL,           -- 'items', 'service', 'farmer', NULL
    p_exchange_details JSONB DEFAULT NULL,       -- Details về exchange
    p_exchange_images TEXT[] DEFAULT NULL,       -- Proof images URLs

    -- Notes
    p_sales_notes TEXT DEFAULT NULL
) RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_profile_id uuid;
    v_order_id uuid;
    v_order_number text;
    v_exchange_type_enum currency_exchange_type_enum;
BEGIN
    -- Get current profile ID
    v_profile_id := get_current_profile_id();

    IF v_profile_id IS NULL THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'User profile not found'
        );
    END IF;

    -- Check permission (user must have currency role)
    IF NOT EXISTS (
        SELECT 1 FROM user_role_assignments ura
        JOIN attributes ba ON ura.business_area_attribute_id = ba.id
        WHERE ura.user_id = v_profile_id
        AND ba.code IN ('CURRENCY', 'DIABLO_4')
    ) THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'Permission denied: User does not have currency role'
        );
    END IF;

    -- Validate required parameters
    IF p_currency_attribute_id IS NULL THEN
        RETURN jsonb_build_object('success', false, 'error', 'Currency attribute ID is required');
    END IF;

    IF p_quantity IS NULL OR p_quantity <= 0 THEN
        RETURN jsonb_build_object('success', false, 'error', 'Quantity must be greater than 0');
    END IF;

    IF p_unit_price_vnd IS NULL OR p_unit_price_vnd < 0 THEN
        RETURN jsonb_build_object('success', false, 'error', 'Unit price VND must be >= 0');
    END IF;

    IF p_customer_name IS NULL OR p_customer_name = '' THEN
        RETURN jsonb_build_object('success', false, 'error', 'Customer name is required for SELL orders');
    END IF;

    IF p_customer_game_tag IS NULL OR p_customer_game_tag = '' THEN
        RETURN jsonb_build_object('success', false, 'error', 'Customer game tag is required for SELL orders');
    END IF;

    -- Validate currency exists and is active
    IF NOT EXISTS (
        SELECT 1 FROM attributes
        WHERE id = p_currency_attribute_id
        AND is_active = true
    ) THEN
        RETURN jsonb_build_object('success', false, 'error', 'Currency not found or inactive');
    END IF;

    -- Validate league exists and is active
    IF NOT EXISTS (
        SELECT 1 FROM attributes
        WHERE id = p_league_attribute_id
        AND is_active = true
    ) THEN
        RETURN jsonb_build_object('success', false, 'error', 'League not found or inactive');
    END IF;

    -- Convert exchange_type to enum (default to 'none')
    v_exchange_type_enum := COALESCE(p_exchange_type::currency_exchange_type_enum, 'none');

    -- Generate order number
    v_order_number := generate_currency_order_number('SELL');

    -- Insert order
    INSERT INTO currency_orders (
        order_number,
        order_type,
        status,
        currency_attribute_id,
        quantity,
        unit_price_vnd,
        unit_price_usd,
        game_code,
        league_attribute_id,
        customer_name,
        customer_game_tag,
        delivery_info,
        channel_id,
        exchange_type,
        exchange_details,
        exchange_images,
        notes,
        created_by,
        created_at
    ) VALUES (
        v_order_number,
        'SELL',
        'pending',  -- Starts in pending status
        p_currency_attribute_id,
        p_quantity,
        p_unit_price_vnd,
        p_unit_price_usd,
        p_game_code,
        p_league_attribute_id,
        p_customer_name,
        p_customer_game_tag,
        p_delivery_info,
        p_channel_id,
        v_exchange_type_enum,
        p_exchange_details,
        p_exchange_images,
        p_sales_notes,
        v_profile_id,
        now()
    )
    RETURNING id INTO v_order_id;

    -- Return success
    RETURN jsonb_build_object(
        'success', true,
        'order_id', v_order_id,
        'order_number', v_order_number,
        'status', 'pending'
    );

EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', SQLERRM
        );
END;
$$;

-- ============================================
-- 2. CREATE_CURRENCY_PURCHASE_ORDER_V1
-- ============================================
-- Purpose: Trader2 buys currency from supplier
-- Workflow: ONE-SHOT - Creates with proof, auto-completes, updates inventory immediately

CREATE OR REPLACE FUNCTION create_currency_purchase_order_v1(
    -- Currency & Quantity
    p_currency_attribute_id UUID,
    p_quantity NUMERIC,
    p_unit_price_vnd NUMERIC,
    p_unit_price_usd NUMERIC DEFAULT 0,
    p_game_code TEXT,
    p_league_attribute_id UUID,
    p_game_account_id UUID,                      -- Account nhận currency (REQUIRED)

    -- Supplier info (simple text fields, NO FK)
    p_supplier_name TEXT,                        -- Tên người bán (REQUIRED)
    p_supplier_contact TEXT DEFAULT NULL,        -- Discord/Telegram (optional)

    -- Proof (REQUIRED for PURCHASE)
    p_proof_urls TEXT[],                         -- Screenshots giao dịch (REQUIRED)

    -- Notes
    p_notes TEXT DEFAULT NULL
) RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_profile_id uuid;
    v_order_id uuid;
    v_order_number text;
    v_transaction_id uuid;
    v_current_inventory_qty numeric;
    v_current_avg_price_vnd numeric;
    v_new_avg_price_vnd numeric;
    v_new_balance numeric;
BEGIN
    -- Get current profile ID
    v_profile_id := get_current_profile_id();

    IF v_profile_id IS NULL THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'User profile not found'
        );
    END IF;

    -- Check permission (user must have currency role, preferably trader2/ops/admin)
    IF NOT EXISTS (
        SELECT 1 FROM user_role_assignments ura
        JOIN attributes ba ON ura.business_area_attribute_id = ba.id
        WHERE ura.user_id = v_profile_id
        AND ba.code IN ('CURRENCY', 'DIABLO_4')
        AND ura.role_name IN ('admin', 'manager', 'trader2', 'ops')
    ) THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'Permission denied: User must have trader2/ops/admin role'
        );
    END IF;

    -- Validate REQUIRED parameters
    IF p_currency_attribute_id IS NULL THEN
        RETURN jsonb_build_object('success', false, 'error', 'Currency attribute ID is required');
    END IF;

    IF p_quantity IS NULL OR p_quantity <= 0 THEN
        RETURN jsonb_build_object('success', false, 'error', 'Quantity must be greater than 0');
    END IF;

    IF p_unit_price_vnd IS NULL OR p_unit_price_vnd < 0 THEN
        RETURN jsonb_build_object('success', false, 'error', 'Unit price VND must be >= 0');
    END IF;

    IF p_game_account_id IS NULL THEN
        RETURN jsonb_build_object('success', false, 'error', 'Game account ID is required for PURCHASE orders');
    END IF;

    IF p_supplier_name IS NULL OR p_supplier_name = '' THEN
        RETURN jsonb_build_object('success', false, 'error', 'Supplier name is required for PURCHASE orders');
    END IF;

    IF p_proof_urls IS NULL OR array_length(p_proof_urls, 1) IS NULL THEN
        RETURN jsonb_build_object('success', false, 'error', 'Proof URLs are required for PURCHASE orders');
    END IF;

    -- Validate currency exists and is active
    IF NOT EXISTS (
        SELECT 1 FROM attributes
        WHERE id = p_currency_attribute_id
        AND is_active = true
    ) THEN
        RETURN jsonb_build_object('success', false, 'error', 'Currency not found or inactive');
    END IF;

    -- Validate league exists and is active
    IF NOT EXISTS (
        SELECT 1 FROM attributes
        WHERE id = p_league_attribute_id
        AND is_active = true
    ) THEN
        RETURN jsonb_build_object('success', false, 'error', 'League not found or inactive');
    END IF;

    -- Validate game account exists and is active
    IF NOT EXISTS (
        SELECT 1 FROM game_accounts
        WHERE id = p_game_account_id
        AND is_active = true
    ) THEN
        RETURN jsonb_build_object('success', false, 'error', 'Game account not found or inactive');
    END IF;

    -- Generate order number
    v_order_number := generate_currency_order_number('PURCHASE');

    -- ONE-SHOT: Insert order with status='completed' immediately
    INSERT INTO currency_orders (
        order_number,
        order_type,
        status,
        currency_attribute_id,
        quantity,
        unit_price_vnd,
        unit_price_usd,
        game_code,
        league_attribute_id,
        customer_name,      -- Store supplier_name here
        delivery_info,      -- Store supplier_contact here
        assigned_account_id,
        proof_urls,
        notes,
        created_by,
        created_at,
        assigned_at,
        started_at,
        completed_at,
        completed_by
    ) VALUES (
        v_order_number,
        'PURCHASE',
        'completed',  -- ONE-SHOT: Skip all intermediate states
        p_currency_attribute_id,
        p_quantity,
        p_unit_price_vnd,
        p_unit_price_usd,
        p_game_code,
        p_league_attribute_id,
        p_supplier_name,
        p_supplier_contact,
        p_game_account_id,
        p_proof_urls,
        p_notes,
        v_profile_id,
        now(),
        now(),  -- Auto-assign
        now(),  -- Auto-start
        now(),  -- Auto-complete
        v_profile_id  -- Auto-complete by creator
    )
    RETURNING id INTO v_order_id;

    -- Create currency transaction (add to inventory)
    INSERT INTO currency_transactions (
        transaction_type,
        game_account_id,
        currency_attribute_id,
        quantity,
        unit_price_vnd,
        unit_price_usd,
        game_code,
        league_attribute_id,
        order_id,
        proof_urls,
        notes,
        created_by,
        created_at
    ) VALUES (
        'purchase',
        p_game_account_id,
        p_currency_attribute_id,
        p_quantity,  -- Positive = add to inventory
        p_unit_price_vnd,
        p_unit_price_usd,
        p_game_code,
        p_league_attribute_id,
        v_order_id,
        p_proof_urls,
        COALESCE(p_notes, 'Purchase from supplier: ' || p_supplier_name),
        v_profile_id,
        now()
    )
    RETURNING id INTO v_transaction_id;

    -- Update inventory: Calculate new weighted average price
    -- Get current inventory
    SELECT
        COALESCE(quantity, 0),
        COALESCE(avg_buy_price_vnd, 0)
    INTO
        v_current_inventory_qty,
        v_current_avg_price_vnd
    FROM currency_inventory
    WHERE game_account_id = p_game_account_id
    AND currency_attribute_id = p_currency_attribute_id
    AND league_attribute_id = p_league_attribute_id
    AND game_code = p_game_code;

    -- Calculate new weighted average
    IF v_current_inventory_qty > 0 THEN
        v_new_avg_price_vnd := (
            (v_current_inventory_qty * v_current_avg_price_vnd) +
            (p_quantity * p_unit_price_vnd)
        ) / (v_current_inventory_qty + p_quantity);
    ELSE
        v_new_avg_price_vnd := p_unit_price_vnd;
    END IF;

    -- Upsert inventory
    INSERT INTO currency_inventory (
        game_account_id,
        currency_attribute_id,
        league_attribute_id,
        game_code,
        quantity,
        avg_buy_price_vnd,
        avg_buy_price_usd,
        last_updated_at
    ) VALUES (
        p_game_account_id,
        p_currency_attribute_id,
        p_league_attribute_id,
        p_game_code,
        p_quantity,
        p_unit_price_vnd,
        p_unit_price_usd,
        now()
    )
    ON CONFLICT (game_account_id, currency_attribute_id, league_attribute_id, game_code)
    DO UPDATE SET
        quantity = currency_inventory.quantity + p_quantity,
        avg_buy_price_vnd = v_new_avg_price_vnd,
        avg_buy_price_usd = CASE
            WHEN p_unit_price_usd > 0 THEN (
                (currency_inventory.quantity * currency_inventory.avg_buy_price_usd) +
                (p_quantity * p_unit_price_usd)
            ) / (currency_inventory.quantity + p_quantity)
            ELSE currency_inventory.avg_buy_price_usd
        END,
        last_updated_at = now()
    RETURNING quantity INTO v_new_balance;

    -- Return success with inventory info
    RETURN jsonb_build_object(
        'success', true,
        'order_id', v_order_id,
        'order_number', v_order_number,
        'status', 'completed',
        'transaction_id', v_transaction_id,
        'inventory_updated', true,
        'new_balance', v_new_balance
    );

EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', SQLERRM
        );
END;
$$;

-- Grant permissions
GRANT EXECUTE ON FUNCTION get_current_profile_id() TO authenticated;
GRANT EXECUTE ON FUNCTION create_currency_sell_order_v1 TO authenticated;
GRANT EXECUTE ON FUNCTION create_currency_purchase_order_v1 TO authenticated;

-- Add comments
COMMENT ON FUNCTION create_currency_sell_order_v1 IS 'Creates a SELL order (customer buys from us). Status starts as pending, waits for OPS to assign/process/complete.';
COMMENT ON FUNCTION create_currency_purchase_order_v1 IS 'Creates a PURCHASE order (we buy from supplier). ONE-SHOT workflow: creates with proof, auto-completes, updates inventory immediately in same transaction.';
