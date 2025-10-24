-- Allow negative inventory values for business requirements
-- Some business scenarios require allowing negative inventory balances

-- First, let's check what constraints exist and drop them
ALTER TABLE public.currency_inventory DROP CONSTRAINT IF EXISTS currency_inventory_quantity_check;
ALTER TABLE public.currency_inventory DROP CONSTRAINT IF EXISTS currency_inventory_reserved_quantity_check;

-- Create new constraints that allow negative values if needed
-- Option 1: No constraints (allow any integer values)
-- This is the most flexible approach for business requirements

-- Option 2: Commented alternative - allow reasonable range only
-- ALTER TABLE public.currency_inventory ADD CONSTRAINT currency_inventory_quantity_check
--   CHECK (quantity >= -10000 AND quantity <= 10000);
-- ALTER TABLE public.currency_inventory ADD CONSTRAINT currency_inventory_reserved_quantity_check
--   CHECK (reserved_quantity >= -10000 AND reserved_quantity <= 10000);

-- Add comment to document the business decision
COMMENT ON TABLE public.currency_inventory IS 'Inventory records for game accounts. Negative values are allowed to support business scenarios like overdrafts, pending transactions, or accounting adjustments.';

COMMENT ON COLUMN public.currency_inventory.quantity IS 'Current available quantity. Can be negative for business scenarios like overdraft protection or pending sell orders.';
COMMENT ON COLUMN public.currency_inventory.reserved_quantity IS 'Reserved quantity for pending transactions. Can be negative for business scenarios like pending buy orders or adjustments.';

-- Create a trigger to optionally log significant negative values for monitoring
CREATE OR REPLACE FUNCTION public.log_negative_inventory_changes()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Log when inventory goes significantly negative (optional monitoring)
    IF NEW.quantity < -100 OR NEW.reserved_quantity < -100 THEN
        RAISE LOG 'Significant negative inventory: inventory_id=%, quantity=%, reserved_quantity%',
                   NEW.id, NEW.quantity, NEW.reserved_quantity;
    END IF;

    RETURN NEW;
END;
$$;

-- Create trigger for monitoring (optional - can be removed if not needed)
DROP TRIGGER IF EXISTS on_currency_inventory_update ON public.currency_inventory;

CREATE TRIGGER on_currency_inventory_update
BEFORE UPDATE ON public.currency_inventory
FOR EACH ROW
EXECUTE FUNCTION public.log_negative_inventory_changes();

-- Grant necessary permissions (if needed)
-- GRANT ALL ON public.currency_inventory TO authenticated;
-- GRANT ALL ON public.currency_inventory TO service_role;