-- Fix account deletion security to prevent deletion with any non-zero stock
-- This includes negative quantities, reserved quantities, and total stock

-- First, let's check if there's an existing deletion protection trigger/function
-- We need to enhance it to check total stock including negative values

-- Create or replace function to check stock before deletion
CREATE OR REPLACE FUNCTION public.prevent_account_deletion_with_stock()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_inventory_count INTEGER;
    v_total_quantity BIGINT;
    v_total_reserved BIGINT;
    v_stock_summary TEXT;
BEGIN
    -- Count inventory records for this account
    SELECT COUNT(*),
           COALESCE(SUM(quantity), 0),
           COALESCE(SUM(reserved_quantity), 0)
    INTO v_inventory_count, v_total_quantity, v_total_reserved
    FROM public.currency_inventory
    WHERE game_account_id = OLD.id;

    -- Build summary for error message
    v_stock_summary := format('Total quantity: %s, Total reserved: %s', v_total_quantity, v_total_reserved);

    -- Prevent deletion if ANY inventory exists with non-zero total stock
    -- This includes positive, negative, and reserved quantities
    IF v_inventory_count > 0 AND (v_total_quantity != 0 OR v_total_reserved != 0) THEN
        RAISE EXCEPTION 'Cannot delete game account with existing inventory. %', v_stock_summary;
    END IF;

    -- Also prevent deletion if there are any inventory records (even with zero values)
    -- This ensures data integrity
    IF v_inventory_count > 0 THEN
        RAISE EXCEPTION 'Cannot delete game account with inventory records. Clean up inventory first. %', v_stock_summary;
    END IF;

    RETURN OLD;
EXCEPTION
    WHEN OTHERS THEN
        -- Log the attempt for security monitoring
        RAISE LOG 'Attempted deletion of game account % with stock: %', OLD.id, v_stock_summary;
        -- Re-raise the exception
        RAISE;
END;
$$;

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS prevent_game_account_deletion ON public.game_accounts;

-- Create the enhanced trigger
CREATE TRIGGER prevent_game_account_deletion
BEFORE DELETE ON public.game_accounts
FOR EACH ROW
EXECUTE FUNCTION public.prevent_account_deletion_with_stock();

-- Add comments for documentation
COMMENT ON FUNCTION public.prevent_account_deletion_with_stock() IS 'Prevents deletion of game accounts that have any inventory records, regardless of stock values (positive, negative, or zero). This protects against data loss and ensures inventory integrity.';

COMMENT ON TRIGGER prevent_game_account_deletion ON public.game_accounts IS 'Security trigger that prevents deletion of game accounts with existing inventory to protect against accidental data loss.';