-- Create complete_sale_order_v2 as alias for complete_sell_order_with_profit_calculation
-- Migration Date: 2025-12-11
-- Purpose: Fix missing complete_sale_order_v2 function that frontend is calling

CREATE OR REPLACE FUNCTION complete_sale_order_v2(
    p_order_id UUID,
    p_user_id UUID
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    profit_amount NUMERIC,
    profit_currency TEXT,
    profit_margin_percentage NUMERIC
)
AS $$
BEGIN
    -- Simply delegate to the existing function
    RETURN QUERY SELECT * FROM complete_sell_order_with_profit_calculation(p_order_id, p_user_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Set search_path for security
ALTER FUNCTION complete_sale_order_v2 SET search_path = public;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION complete_sale_order_v2 TO authenticated;
GRANT EXECUTE ON FUNCTION complete_sale_order_v2 TO service_role;

-- Verification
DO $$
BEGIN
    RAISE NOTICE 'Migration completed: complete_sale_order_v2 function created as alias';
    RAISE NOTICE 'Frontend can now call complete_sale_order_v2 which delegates to complete_sell_order_with_profit_calculation';
END;
$$;