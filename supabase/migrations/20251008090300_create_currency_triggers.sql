-- Migration: Create Currency System Triggers
-- Version: 1.0
-- Date: 2025-10-08
-- Dependencies:
--   - 20251008090000_create_currency_enums.sql
--   - 20251008090100_create_currency_core_tables.sql

-- ===========================================
-- TRIGGERS FOR INVENTORY MANAGEMENT
-- ===========================================

-- Enable row level security for currency tables
ALTER TABLE public.game_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.currency_inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.currency_transactions ENABLE ROW LEVEL SECURITY;

-- ===========================================
-- INVENTORY UPDATE TRIGGER
-- ===========================================

-- Function to update inventory when transaction occurs
CREATE OR REPLACE FUNCTION public.update_currency_inventory()
RETURNS TRIGGER AS $$
DECLARE
    v_inventory_record RECORD;
    v_new_quantity NUMERIC;
    v_new_reserved NUMERIC;
    v_total_value NUMERIC;
    v_total_quantity NUMERIC;
    v_new_avg_price_vnd NUMERIC;
    v_new_avg_price_usd NUMERIC;
BEGIN
    -- Check if inventory record exists
    SELECT * INTO v_inventory_record
    FROM public.currency_inventory
    WHERE game_account_id = NEW.game_account_id
      AND currency_attribute_id = NEW.currency_attribute_id
    FOR UPDATE;

    IF v_inventory_record IS NULL THEN
        -- Create new inventory record
        INSERT INTO public.currency_inventory (
            game_account_id,
            currency_attribute_id,
            quantity,
            reserved_quantity,
            avg_buy_price_vnd,
            avg_buy_price_usd,
            last_updated_at
        ) VALUES (
            NEW.game_account_id,
            NEW.currency_attribute_id,
            CASE
                WHEN NEW.transaction_type IN ('purchase', 'exchange_in', 'farm_in', 'transfer', 'manual_adjustment')
                THEN GREATEST(NEW.quantity, 0)
                ELSE 0
            END,
            0,
            CASE
                WHEN NEW.transaction_type IN ('purchase', 'exchange_in', 'farm_in')
                THEN NEW.unit_price_vnd
                ELSE 0
            END,
            CASE
                WHEN NEW.transaction_type IN ('purchase', 'exchange_in', 'farm_in')
                THEN NEW.unit_price_usd
                ELSE 0
            END,
            NOW()
        );

        RETURN NEW;
    END IF;

    -- Calculate new quantities based on transaction type
    CASE NEW.transaction_type
        WHEN 'purchase', 'exchange_in', 'farm_in', 'transfer', 'manual_adjustment' THEN
            -- Adding to inventory
            v_new_quantity := v_inventory_record.quantity + NEW.quantity;
            v_new_reserved := v_inventory_record.reserved_quantity;

            -- Update average price for purchase types
            IF NEW.transaction_type IN ('purchase', 'exchange_in', 'farm_in') AND NEW.quantity > 0 THEN
                v_total_value := (v_inventory_record.quantity * v_inventory_record.avg_buy_price_vnd) + (NEW.quantity * NEW.unit_price_vnd);
                v_total_quantity := v_inventory_record.quantity + NEW.quantity;
                v_new_avg_price_vnd := v_total_value / v_total_quantity;

                v_total_value := (v_inventory_record.quantity * v_inventory_record.avg_buy_price_usd) + (NEW.quantity * NEW.unit_price_usd);
                v_new_avg_price_usd := v_total_value / v_total_quantity;
            ELSE
                v_new_avg_price_vnd := v_inventory_record.avg_buy_price_vnd;
                v_new_avg_price_usd := v_inventory_record.avg_buy_price_usd;
            END IF;

        WHEN 'sale_delivery', 'exchange_out', 'farm_payout' THEN
            -- Removing from inventory
            v_new_quantity := v_inventory_record.quantity - NEW.quantity;
            v_new_reserved := v_inventory_record.reserved_quantity;
            v_new_avg_price_vnd := v_inventory_record.avg_buy_price_vnd;
            v_new_avg_price_usd := v_inventory_record.avg_buy_price_usd;

            -- Check if enough quantity
            IF v_new_quantity < 0 THEN
                RAISE EXCEPTION 'Insufficient inventory. Current: %, Attempted to remove: %',
                    v_inventory_record.quantity, NEW.quantity;
            END IF;

        ELSE
            -- For other transaction types, don't change quantity
            v_new_quantity := v_inventory_record.quantity;
            v_new_reserved := v_inventory_record.reserved_quantity;
            v_new_avg_price_vnd := v_inventory_record.avg_buy_price_vnd;
            v_new_avg_price_usd := v_inventory_record.avg_buy_price_usd;
    END CASE;

    -- Update inventory record
    UPDATE public.currency_inventory
    SET
        quantity = v_new_quantity,
        reserved_quantity = v_new_reserved,
        avg_buy_price_vnd = v_new_avg_price_vnd,
        avg_buy_price_usd = v_new_avg_price_usd,
        last_updated_at = NOW()
    WHERE id = v_inventory_record.id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for automatic inventory updates
CREATE TRIGGER trigger_update_currency_inventory
    AFTER INSERT ON public.currency_transactions
    FOR EACH ROW
    EXECUTE FUNCTION public.update_currency_inventory();

-- ===========================================
-- AUTO-CREATE INVENTORY TRIGGER
-- ===========================================

-- Function to auto-create inventory records for new game accounts
CREATE OR REPLACE FUNCTION public.auto_create_inventory_records()
RETURNS TRIGGER AS $$
DECLARE
    v_currency_record RECORD;
BEGIN
    -- For INVENTORY type accounts, create empty inventory records for all currencies
    IF NEW.purpose = 'INVENTORY' THEN
        -- Create inventory records for all currencies of this game
        FOR v_currency_record IN
            SELECT id
            FROM public.attributes
            WHERE type = NEW.game_code || '_CURRENCY'
        LOOP
            INSERT INTO public.currency_inventory (
                game_account_id,
                currency_attribute_id,
                quantity,
                reserved_quantity,
                avg_buy_price_vnd,
                avg_buy_price_usd,
                last_updated_at
            ) VALUES (
                NEW.id,
                v_currency_record.id,
                0,
                0,
                0,
                0,
                NOW()
            )
            ON CONFLICT (game_account_id, currency_attribute_id)
            DO NOTHING;
        END LOOP;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for auto-inventory creation
CREATE TRIGGER trigger_auto_create_inventory_records
    AFTER INSERT ON public.game_accounts
    FOR EACH ROW
    EXECUTE FUNCTION public.auto_create_inventory_records();

-- ===========================================
-- PROTECT ACCOUNT DELETION TRIGGER
-- ===========================================

-- Function to prevent deletion of accounts with currency
CREATE OR REPLACE FUNCTION public.protect_account_with_currency()
RETURNS TRIGGER AS $$
DECLARE
    v_currency_count INTEGER;
BEGIN
    -- Check if account has any currency
    SELECT COUNT(*) INTO v_currency_count
    FROM public.currency_inventory
    WHERE game_account_id = OLD.id
      AND quantity > 0;

    IF v_currency_count > 0 THEN
        RAISE EXCEPTION 'Cannot delete game account with existing currency. Found % currency types with quantity > 0', v_currency_count;
    END IF;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to protect account deletion
CREATE TRIGGER trigger_protect_account_with_currency
    BEFORE DELETE ON public.game_accounts
    FOR EACH ROW
    EXECUTE FUNCTION public.protect_account_with_currency();

-- ===========================================
-- TIMESTAMPS UPDATE TRIGGER
-- ===========================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for updated_at on game_accounts
CREATE TRIGGER trigger_update_game_accounts_updated_at
    BEFORE UPDATE ON public.game_accounts
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

-- Create trigger for updated_at on trading_fee_chains
CREATE TRIGGER trigger_update_trading_fee_chains_updated_at
    BEFORE UPDATE ON public.trading_fee_chains
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

-- SECURITY POLICIES will be added in a separate migration
-- to ensure we use the correct existing schema

-- ===========================================
-- COMMENTS
-- ===========================================

COMMENT ON FUNCTION public.update_currency_inventory IS 'Cập nhật tồn kho tự động khi có giao dịch mới';
COMMENT ON FUNCTION public.auto_create_inventory_records IS 'Tự động tạo record tồn kho cho tài khoản inventory mới';
COMMENT ON FUNCTION public.protect_account_with_currency IS 'Ngăn xóa tài khoản game còn currency';