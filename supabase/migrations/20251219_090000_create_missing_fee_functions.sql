-- Create missing fee management functions
-- These functions are called by FeesManagement.vue component

-- 1. Create fee function
CREATE OR REPLACE FUNCTION create_fee_direct(
    p_code TEXT,
    p_name TEXT,
    p_direction TEXT,
    p_fee_type TEXT,
    p_amount NUMERIC,
    p_currency TEXT DEFAULT 'VND',
    p_is_active BOOLEAN DEFAULT true,
    p_created_by UUID DEFAULT NULL -- profiles.id from frontend (who is creating) - following memory.md pattern
)
RETURNS JSON SECURITY DEFINER SET search_path = 'public'
AS $$
DECLARE
    v_fee_id UUID;
    v_code_exists BOOLEAN;
    v_name_exists BOOLEAN;
BEGIN
    -- Validate input fields
    IF p_code IS NULL OR p_code = '' THEN
        RETURN json_build_object('success', false, 'message', 'Fee code is required');
    END IF;

    IF p_name IS NULL OR p_name = '' THEN
        RETURN json_build_object('success', false, 'message', 'Fee name is required');
    END IF;

    IF p_amount IS NULL OR p_amount <= 0 THEN
        RETURN json_build_object('success', false, 'message', 'Fee amount must be greater than 0');
    END IF;

    -- Validate direction
    IF p_direction NOT IN ('BUY', 'SELL', 'BOTH') THEN
        RETURN json_build_object('success', false, 'message', 'Invalid direction. Must be: BUY, SELL, or BOTH');
    END IF;

    -- Check if fee code already exists
    SELECT EXISTS(SELECT 1 FROM fees WHERE code = p_code AND is_active = true) INTO v_code_exists;

    IF v_code_exists THEN
        RETURN json_build_object('success', false, 'message', 'Fee code already exists');
    END IF;

    -- Check if fee name already exists
    SELECT EXISTS(SELECT 1 FROM fees WHERE name = p_name AND is_active = true) INTO v_name_exists;

    IF v_name_exists THEN
        RETURN json_build_object('success', false, 'message', 'Fee name already exists');
    END IF;

    -- Create new fee
    INSERT INTO fees (
        code, name, direction, fee_type, amount, currency, is_active,
        created_at
    ) VALUES (
        p_code, p_name, p_direction, p_fee_type, p_amount, p_currency, p_is_active,
        now()
    ) RETURNING id INTO v_fee_id;

    RETURN json_build_object(
        'success', true,
        'message', 'Fee created successfully',
        'fee_id', v_fee_id
    );
END;
$$ LANGUAGE plpgsql;

-- 2. Update fee function
CREATE OR REPLACE FUNCTION update_fee_direct(
    p_fee_id UUID,
    p_code TEXT,
    p_name TEXT,
    p_direction TEXT,
    p_fee_type TEXT,
    p_amount NUMERIC,
    p_currency TEXT,
    p_is_active BOOLEAN
)
RETURNS JSON SECURITY DEFINER SET search_path = 'public'
AS $$
DECLARE
    v_fee fees%ROWTYPE;
    v_code_exists BOOLEAN;
    v_name_exists BOOLEAN;
BEGIN
    -- Validate fee exists
    SELECT * INTO v_fee
    FROM fees
    WHERE id = p_fee_id;

    IF v_fee.id IS NULL THEN
        RETURN json_build_object('success', false, 'message', 'Fee not found');
    END IF;

    -- Validate input fields
    IF p_amount IS NULL OR p_amount <= 0 THEN
        RETURN json_build_object('success', false, 'message', 'Fee amount must be greater than 0');
    END IF;

    -- Validate direction
    IF p_direction NOT IN ('BUY', 'SELL', 'BOTH') THEN
        RETURN json_build_object('success', false, 'message', 'Invalid direction. Must be: BUY, SELL, or BOTH');
    END IF;

    -- Check if fee code already exists for another fee
    SELECT EXISTS(SELECT 1 FROM fees WHERE code = p_code AND id != p_fee_id AND is_active = true) INTO v_code_exists;

    IF v_code_exists THEN
        RETURN json_build_object('success', false, 'message', 'Fee code already exists');
    END IF;

    -- Check if fee name already exists for another fee
    SELECT EXISTS(SELECT 1 FROM fees WHERE name = p_name AND id != p_fee_id AND is_active = true) INTO v_name_exists;

    IF v_name_exists THEN
        RETURN json_build_object('success', false, 'message', 'Fee name already exists');
    END IF;

    -- Update fee
    UPDATE fees
    SET
        code = p_code,
        name = p_name,
        direction = p_direction,
        fee_type = p_fee_type,
        amount = p_amount,
        currency = p_currency,
        is_active = p_is_active
    WHERE id = p_fee_id;

    RETURN json_build_object(
        'success', true,
        'message', 'Fee updated successfully',
        'fee_id', p_fee_id
    );
END;
$$ LANGUAGE plpgsql;

-- 3. Delete fee function
CREATE OR REPLACE FUNCTION delete_fee_direct(
    p_fee_id UUID
)
RETURNS JSON SECURITY DEFINER SET search_path = 'public'
AS $$
DECLARE
    v_fee fees%ROWTYPE;
BEGIN
    -- Validate fee exists
    SELECT * INTO v_fee
    FROM fees
    WHERE id = p_fee_id;

    IF v_fee.id IS NULL THEN
        RETURN json_build_object('success', false, 'message', 'Fee not found');
    END IF;

    -- Soft delete (set inactive) instead of hard delete to maintain audit trail
    UPDATE fees
    SET
        is_active = false
    WHERE id = p_fee_id;

    RETURN json_build_object(
        'success', true,
        'message', 'Fee deleted successfully',
        'fee_id', p_fee_id
    );
END;
$$ LANGUAGE plpgsql;

-- Grant permissions to all functions
GRANT EXECUTE ON FUNCTION create_fee_direct(TEXT, TEXT, TEXT, TEXT, NUMERIC, TEXT, BOOLEAN, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION update_fee_direct(UUID, TEXT, TEXT, TEXT, TEXT, NUMERIC, TEXT, BOOLEAN) TO authenticated;
GRANT EXECUTE ON FUNCTION delete_fee_direct(UUID) TO authenticated;

-- Verify function creation
SELECT
    proname as function_name,
    pg_get_function_arguments(oid) as parameters,
    'CREATED' as status
FROM pg_proc
WHERE proname IN ('create_fee_direct', 'update_fee_direct', 'delete_fee_direct')
ORDER BY proname;