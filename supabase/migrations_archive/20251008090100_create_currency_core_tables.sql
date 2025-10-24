-- Migration: Create Currency System Core Tables
-- Version: 1.0
-- Date: 2025-10-08
-- Dependencies: 20251008090000_create_currency_enums.sql

-- ===========================================
-- CORE TABLES FOR CURRENCY SYSTEM
-- ===========================================

-- Game Accounts Management
CREATE TABLE public.game_accounts (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    game_code public.game_code NOT NULL,
    league_attribute_id uuid NOT NULL REFERENCES public.attributes(id) ON DELETE CASCADE,
    account_name text NOT NULL,
    purpose public.game_account_purpose NOT NULL DEFAULT 'INVENTORY',
    manager_profile_id uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (game_code, league_attribute_id, account_name)
);

-- Currency Inventory Management
CREATE TABLE public.currency_inventory (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    game_account_id uuid NOT NULL REFERENCES public.game_accounts(id) ON DELETE CASCADE,
    currency_attribute_id uuid NOT NULL REFERENCES public.attributes(id) ON DELETE CASCADE,
    quantity numeric NOT NULL DEFAULT 0 CHECK (quantity >= 0),
    reserved_quantity numeric NOT NULL DEFAULT 0 CHECK (reserved_quantity >= 0),
    avg_buy_price_vnd numeric NOT NULL DEFAULT 0 CHECK (avg_buy_price_vnd >= 0),
    avg_buy_price_usd numeric NOT NULL DEFAULT 0 CHECK (avg_buy_price_usd >= 0),
    last_updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (game_account_id, currency_attribute_id)
);

-- Currency Transaction Ledger
CREATE TABLE public.currency_transactions (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    game_account_id uuid NOT NULL REFERENCES public.game_accounts(id) ON DELETE CASCADE,
    game_code public.game_code NOT NULL,
    league_attribute_id uuid NOT NULL REFERENCES public.attributes(id) ON DELETE CASCADE,
    transaction_type public.currency_transaction_type NOT NULL,
    currency_attribute_id uuid NOT NULL REFERENCES public.attributes(id) ON DELETE CASCADE,
    quantity numeric NOT NULL,
    unit_price_vnd numeric NOT NULL CHECK (unit_price_vnd >= 0),
    unit_price_usd numeric NOT NULL CHECK (unit_price_usd >= 0),
    exchange_rate_vnd_per_usd numeric CHECK (exchange_rate_vnd_per_usd > 0),
    order_line_id uuid REFERENCES public.order_lines(id) ON DELETE SET NULL,
    partner_id uuid REFERENCES public.parties(id) ON DELETE SET NULL,
    farmer_profile_id uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
    proof_urls text[],
    notes text,
    created_by uuid NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
    created_at timestamptz NOT NULL DEFAULT now()
);

-- ===========================================
-- INDEXES FOR PERFORMANCE
-- ===========================================

-- Game Accounts indexes
CREATE INDEX idx_game_accounts_game_code ON public.game_accounts(game_code);
CREATE INDEX idx_game_accounts_league ON public.game_accounts(league_attribute_id);
CREATE INDEX idx_game_accounts_manager ON public.game_accounts(manager_profile_id);
CREATE INDEX idx_game_accounts_purpose ON public.game_accounts(purpose);
CREATE INDEX idx_game_accounts_active ON public.game_accounts(is_active);

-- Currency Inventory indexes
CREATE INDEX idx_currency_inventory_account ON public.currency_inventory(game_account_id);
CREATE INDEX idx_currency_inventory_currency ON public.currency_inventory(currency_attribute_id);
CREATE INDEX idx_currency_inventory_quantity ON public.currency_inventory(quantity) WHERE quantity > 0;

-- Currency Transactions indexes
CREATE INDEX idx_currency_transactions_account ON public.currency_transactions(game_account_id);
CREATE INDEX idx_currency_transactions_game ON public.currency_transactions(game_code);
CREATE INDEX idx_currency_transactions_league ON public.currency_transactions(league_attribute_id);
CREATE INDEX idx_currency_transactions_type ON public.currency_transactions(transaction_type);
CREATE INDEX idx_currency_transactions_currency ON public.currency_transactions(currency_attribute_id);
CREATE INDEX idx_currency_transactions_order ON public.currency_transactions(order_line_id);
CREATE INDEX idx_currency_transactions_created_at ON public.currency_transactions(created_at);
CREATE INDEX idx_currency_transactions_created_by ON public.currency_transactions(created_by);

-- ===========================================
-- COMMENTS
-- ===========================================

COMMENT ON TABLE public.game_accounts IS 'Quản lý tập trung các tài khoản game theo từng game, mùa giải và mục đích sử dụng';
COMMENT ON COLUMN public.game_accounts.game_code IS 'Mã game (POE1, POE2, D4)';
COMMENT ON COLUMN public.game_accounts.league_attribute_id IS 'League/season thuộc game';
COMMENT ON COLUMN public.game_accounts.account_name IS 'Tên tài khoản trong game';
COMMENT ON COLUMN public.game_accounts.purpose IS 'Mục đích: FARM (farm currency), INVENTORY (lưu trữ), TRADE (giao dịch)';
COMMENT ON COLUMN public.game_accounts.manager_profile_id IS 'Người quản lý tài khoản này';

COMMENT ON TABLE public.currency_inventory IS 'Tồn kho hiện tại của các loại currency theo từng tài khoản game';
COMMENT ON COLUMN public.currency_inventory.quantity IS 'Số lượng hiện có trong kho';
COMMENT ON COLUMN public.currency_inventory.reserved_quantity IS 'Số lượng đã được reserve cho đơn hàng';
COMMENT ON COLUMN public.currency_inventory.avg_buy_price_vnd IS 'Giá vốn trung bình theo VND';
COMMENT ON COLUMN public.currency_inventory.avg_buy_price_usd IS 'Giá vốn trung bình theo USD';

COMMENT ON TABLE public.currency_transactions IS 'Sổ cái ghi lại mọi giao dịch làm thay đổi tồn kho currency';
COMMENT ON COLUMN public.currency_transactions.transaction_type IS 'Loại giao dịch (purchase, sale_delivery, farm_in, etc.)';
COMMENT ON COLUMN public.currency_transactions.quantity IS 'Số lượng giao dịch (dương cho vào, âm cho ra)';
COMMENT ON COLUMN public.currency_transactions.exchange_rate_vnd_per_usd IS 'Tỷ giá VND/USD tại thời điểm giao dịch';
COMMENT ON COLUMN public.currency_transactions.proof_urls IS 'URLs của bằng chứng giao dịch (screenshots, etc.)';