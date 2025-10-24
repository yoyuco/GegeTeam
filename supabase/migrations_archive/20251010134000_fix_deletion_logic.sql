-- Fix deletion logic to allow deletion of accounts with zero stock
-- Only prevent deletion when total stock (quantity + reserved_quantity) != 0

-- Drop trigger first, then function
DROP TRIGGER IF EXISTS prevent_game_account_deletion ON public.game_accounts;
DROP FUNCTION IF EXISTS public.prevent_account_deletion_with_stock();

CREATE OR REPLACE FUNCTION public.prevent_account_deletion_with_stock()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_total_quantity BIGINT;
    v_total_reserved BIGINT;
    v_grand_total BIGINT;
    v_stock_summary TEXT;
BEGIN
    -- Calculate total stock values
    SELECT COALESCE(SUM(quantity), 0),
           COALESCE(SUM(reserved_quantity), 0)
    INTO v_total_quantity, v_total_reserved
    FROM public.currency_inventory
    WHERE game_account_id = OLD.id;

    -- Calculate grand total (quantity + reserved)
    v_grand_total := v_total_quantity + v_total_reserved;

    -- Build summary for error message
    v_stock_summary := format('Total quantity: %s, Total reserved: %s, Grand total: %s',
                             v_total_quantity, v_total_reserved, v_grand_total);

    -- ONLY prevent deletion if grand total is not zero
    -- This allows deletion when stock is exactly zero (0,0)
    IF v_grand_total != 0 THEN
        RAISE EXCEPTION 'Cannot delete game account with non-zero inventory. %', v_stock_summary;
    END IF;

    -- Log successful deletion for auditing
    RAISE LOG 'Deleted game account % with zero stock: %', OLD.id, v_stock_summary;

    RETURN OLD;
EXCEPTION
    WHEN OTHERS THEN
        -- Log blocked deletion attempts for security monitoring
        RAISE LOG 'Blocked deletion of game account % with stock: %', OLD.id, v_stock_summary;
        -- Re-raise the exception
        RAISE;
END;
$$;

-- Recreate the trigger
DROP TRIGGER IF EXISTS prevent_game_account_deletion ON public.game_accounts;

CREATE TRIGGER prevent_game_account_deletion
BEFORE DELETE ON public.game_accounts
FOR EACH ROW
EXECUTE FUNCTION public.prevent_account_deletion_with_stock();

-- Update comments for documentation
COMMENT ON FUNCTION public.prevent_account_deletion_with_stock() IS 'Prevents deletion of game accounts that have non-zero inventory (quantity + reserved_quantity != 0). Allows deletion when total stock is exactly zero.';

COMMENT ON TRIGGER prevent_game_account_deletion ON public.game_accounts IS 'Security trigger that prevents deletion of game accounts with non-zero inventory to protect against accidental data loss. Zero-stock accounts can be safely deleted.';