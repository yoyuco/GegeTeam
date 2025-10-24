-- Migration: Create Currency System ENUM Types
-- Version: 1.0
-- Date: 2025-10-08

-- ===========================================
-- ENUM TYPES FOR CURRENCY SYSTEM
-- ===========================================

-- Purpose for game accounts
CREATE TYPE public.game_account_purpose AS ENUM (
    'FARM',         -- Account used for farming currency
    'INVENTORY',    -- Account used to store currency
    'TRADE'         -- Account used for trading with customers
);

-- Types of currency transactions
CREATE TYPE public.currency_transaction_type AS ENUM (
    'purchase',            -- Mua vào từ đối tác bên ngoài
    'sale_delivery',       -- Giao currency cho khách hàng
    'exchange_out',        -- Chuyển đi để đổi loại currency khác
    'exchange_in',         -- Nhận về sau khi đổi currency
    'transfer',            -- Chuyển nội bộ giữa các tài khoản game
    'manual_adjustment',   -- Điều chỉnh kho thủ công (admin)
    'farm_in',             -- Ghi nhận currency nhận từ farmer nội bộ
    'farm_payout',         -- Ghi nhận currency trả cho farmer
    'league_archive'       -- Giao dịch kết chuyển khi hết mùa giải
);

-- Types of fees in trading chains
CREATE TYPE public.trading_fee_type AS ENUM (
    'PURCHASE_FEE',    -- Phí khi mua vào
    'SALE_FEE',        -- Phí khi bán ra (platform fee như G2G)
    'WITHDRAWAL_FEE',  -- Phí rút tiền (platform -> payment gateway)
    'CONVERSION_FEE',  -- Phí chuyển đổi currency (payment -> local bank)
    'TAX_FEE'          -- Thuế
);

-- Game codes supported
CREATE TYPE public.game_code AS ENUM (
    'POE1',   -- Path of Exile 1
    'POE2',   -- Path of Exile 2
    'D4'      -- Diablo 4
);

-- ===========================================
-- COMMENTS
-- ===========================================

COMMENT ON TYPE public.game_account_purpose IS 'Mục đích sử dụng của tài khoản game';
COMMENT ON TYPE public.currency_transaction_type IS 'Các loại giao dịch currency trong hệ thống';
COMMENT ON TYPE public.trading_fee_type IS 'Các loại phí trong chuỗi giao dịch';
COMMENT ON TYPE public.game_code IS 'Các game được hỗ trợ trong hệ thống';