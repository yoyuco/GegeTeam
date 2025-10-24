-- Migration: Create Currency System Sample Data
-- Version: 1.0
-- Date: 2025-10-08
-- Dependencies: All previous currency migrations

-- ===========================================
-- SAMPLE GAME ACCOUNTS
-- ===========================================

-- POE1 Standard League Accounts
INSERT INTO public.game_accounts (game_code, league_attribute_id, account_name, purpose, manager_profile_id) VALUES
('POE1', (SELECT id FROM public.attributes WHERE code = 'STANDARD_STANDARD_POE1'), 'AccPoe1_Std_01', 'INVENTORY', NULL),
('POE1', (SELECT id FROM public.attributes WHERE code = 'STANDARD_STANDARD_POE1'), 'AccPoe1_Std_02', 'FARM', NULL),
('POE1', (SELECT id FROM public.attributes WHERE code = 'STANDARD_STANDARD_POE1'), 'AccPoe1_Std_Trade', 'TRADE', NULL),

-- POE1 Hardcore League Accounts
('POE1', (SELECT id FROM public.attributes WHERE code = 'HARDCORE_STANDARD_POE1'), 'AccPoe1_HC_01', 'INVENTORY', NULL),
('POE1', (SELECT id FROM public.attributes WHERE code = 'HARDCORE_STANDARD_POE1'), 'AccPoe1_HC_Farm', 'FARM', NULL),

-- POE2 EA Standard Accounts
('POE2', (SELECT id FROM public.attributes WHERE code = 'STANDARD_EA_POE2'), 'AccPoe2_EA_01', 'INVENTORY', NULL),
('POE2', (SELECT id FROM public.attributes WHERE code = 'STANDARD_EA_POE2'), 'AccPoe2_EA_Trade', 'TRADE', NULL),

-- D4 Season 10 Accounts
('D4', (SELECT id FROM public.attributes WHERE code = 'SEASON_10_SOFTCORE_D4'), 'AccD4_S10_01', 'INVENTORY', NULL),
('D4', (SELECT id FROM public.attributes WHERE code = 'SEASON_10_HARDCORE_D4'), 'AccD4_S10_HC', 'INVENTORY', NULL);

-- ===========================================
-- SAMPLE INVENTORY (will be auto-created by trigger for INVENTORY accounts)
-- ===========================================

-- Verify inventory records were created for INVENTORY accounts
-- The trigger should have automatically created these

-- ===========================================
-- SAMPLE TRANSACTIONS
-- ===========================================

-- Get some sample IDs
DO $$
DECLARE
    v_poe1_std_acc UUID;
    v_poe1_hc_acc UUID;
    v_poe2_ea_acc UUID;
    v_d4_s10_acc UUID;
    v_divine_poe1 UUID;
    v_chaos_poe1 UUID;
    v_exalted_poe1 UUID;
    v_divine_poe2 UUID;
    v_gold_d4 UUID;
    v_profile_id UUID;
BEGIN
    -- Get sample account IDs
    SELECT id INTO v_poe1_std_acc FROM public.game_accounts WHERE account_name = 'AccPoe1_Std_01' LIMIT 1;
    SELECT id INTO v_poe1_hc_acc FROM public.game_accounts WHERE account_name = 'AccPoe1_HC_01' LIMIT 1;
    SELECT id INTO v_poe2_ea_acc FROM public.game_accounts WHERE account_name = 'AccPoe2_EA_01' LIMIT 1;
    SELECT id INTO v_d4_s10_acc FROM public.game_accounts WHERE account_name = 'AccD4_S10_01' LIMIT 1;

    -- Get currency IDs
    SELECT id INTO v_divine_poe1 FROM public.attributes WHERE code = 'DIVINE_ORB_POE1';
    SELECT id INTO v_chaos_poe1 FROM public.attributes WHERE code = 'CHAOS_ORB_POE1';
    SELECT id INTO v_exalted_poe1 FROM public.attributes WHERE code = 'EXALTED_ORB_POE1';
    SELECT id INTO v_divine_poe2 FROM public.attributes WHERE code = 'DIVINE_ORB_POE2';
    SELECT id INTO v_gold_d4 FROM public.attributes WHERE code = 'GOLD_D4';

    -- Get a sample profile (use first available or create test one)
    SELECT id INTO v_profile_id FROM public.profiles LIMIT 1;

    IF v_profile_id IS NULL THEN
        -- Create a test profile if none exists
        INSERT INTO public.profiles (id, email) VALUES (gen_random_uuid(), 'test@currency.com') RETURNING id INTO v_profile_id;
    END IF;

    -- Insert sample transactions for POE1 Standard League
    IF v_poe1_std_acc IS NOT NULL AND v_divine_poe1 IS NOT NULL AND v_profile_id IS NOT NULL THEN
        -- Purchase Divine Orbs
        INSERT INTO public.currency_transactions (
            game_account_id, game_code, league_attribute_id, transaction_type,
            currency_attribute_id, quantity, unit_price_vnd, unit_price_usd,
            exchange_rate_vnd_per_usd, created_by, notes
        ) VALUES
        (v_poe1_std_acc, 'POE1', (SELECT id FROM public.attributes WHERE code = 'STANDARD_STANDARD_POE1'),
         'purchase', v_divine_poe1, 50, 20000, 0.78, 25641, v_profile_id, 'Mua Divine Orb 20k/c từ Facebook'),

        (v_poe1_std_acc, 'POE1', (SELECT id FROM public.attributes WHERE code = 'STANDARD_STANDARD_POE1'),
         'purchase', v_chaos_poe1, 1000, 200, 0.0078, 25641, v_profile_id, 'Mua Chaos Orb 200/c'),

        (v_poe1_std_acc, 'POE1', (SELECT id FROM public.attributes WHERE code = 'STANDARD_STANDARD_POE1'),
         'purchase', v_exalted_poe1, 10, 180000, 7.02, 25641, v_profile_id, 'Mua Exalted Orb 180k/c');

        -- Sale transactions
        INSERT INTO public.currency_transactions (
            game_account_id, game_code, league_attribute_id, transaction_type,
            currency_attribute_id, quantity, unit_price_vnd, unit_price_usd,
            exchange_rate_vnd_per_usd, created_by, notes
        ) VALUES
        (v_poe1_std_acc, 'POE1', (SELECT id FROM public.attributes WHERE code = 'STANDARD_STANDARD_POE1'),
         'sale_delivery', v_divine_poe1, -20, 20000, 0.78, 25641, v_profile_id, 'Bán 20 Divine cho khách'),

        (v_poe1_std_acc, 'POE1', (SELECT id FROM public.attributes WHERE code = 'STANDARD_STANDARD_POE1'),
         'sale_delivery', v_chaos_poe1, -300, 200, 0.0078, 25641, v_profile_id, 'Bán 300 Chaos cho khách');
    END IF;

    -- Insert sample transactions for POE1 Hardcore League
    IF v_poe1_hc_acc IS NOT NULL AND v_divine_poe1 IS NOT NULL THEN
        INSERT INTO public.currency_transactions (
            game_account_id, game_code, league_attribute_id, transaction_type,
            currency_attribute_id, quantity, unit_price_vnd, unit_price_usd,
            exchange_rate_vnd_per_usd, created_by, notes
        ) VALUES
        (v_poe1_hc_acc, 'POE1', (SELECT id FROM public.attributes WHERE code = 'HARDCORE_STANDARD_POE1'),
         'purchase', v_divine_poe1, 25, 22000, 0.86, 25581, v_profile_id, 'Mua Divine HC giá cao hơn');
    END IF;

    -- Insert sample transactions for POE2 EA
    IF v_poe2_ea_acc IS NOT NULL AND v_divine_poe2 IS NOT NULL THEN
        INSERT INTO public.currency_transactions (
            game_account_id, game_code, league_attribute_id, transaction_type,
            currency_attribute_id, quantity, unit_price_vnd, unit_price_usd,
            exchange_rate_vnd_per_usd, created_by, notes
        ) VALUES
        (v_poe2_ea_acc, 'POE2', (SELECT id FROM public.attributes WHERE code = 'STANDARD_EA_POE2'),
         'farm_in', v_divine_poe2, 15, 0, 0, 25700, v_profile_id, 'Farm được từ farmer'),

        (v_poe2_ea_acc, 'POE2', (SELECT id FROM public.attributes WHERE code = 'STANDARD_EA_POE2'),
         'purchase', v_divine_poe2, 30, 21000, 0.82, 25610, v_profile_id, 'Mua thêm Divine POE2');
    END IF;

    -- Insert sample transactions for D4
    IF v_d4_s10_acc IS NOT NULL AND v_gold_d4 IS NOT NULL THEN
        INSERT INTO public.currency_transactions (
            game_account_id, game_code, league_attribute_id, transaction_type,
            currency_attribute_id, quantity, unit_price_vnd, unit_price_usd,
            exchange_rate_vnd_per_usd, created_by, notes
        ) VALUES
        (v_d4_s10_acc, 'D4', (SELECT id FROM public.attributes WHERE code = 'SEASON_10_SOFTCORE_D4'),
         'farm_in', v_gold_d4, 10000000, 0, 0, 25700, v_profile_id, 'Farm được 10M gold'),

        (v_d4_s10_acc, 'D4', (SELECT id FROM public.attributes WHERE code = 'SEASON_10_SOFTCORE_D4'),
         'sale_delivery', v_gold_d4, -2000000, 0.000057, 0.0000000022, 25700, v_profile_id, 'Bán 2M gold cho khách');
    END IF;
END $$;

-- ===========================================
-- UPDATE EXCHANGE RATES WITH LATEST DATA
-- ===========================================

UPDATE public.exchange_rates
SET rate = 25700, last_updated_at = NOW()
WHERE source_currency = 'USD' AND target_currency = 'VND';

UPDATE public.exchange_rates
SET rate = 0.00003891, last_updated_at = NOW()
WHERE source_currency = 'VND' AND target_currency = 'USD';

-- Add more currency pairs
INSERT INTO public.exchange_rates (source_currency, target_currency, rate) VALUES
('USD', 'EUR', 0.93),
('EUR', 'USD', 1.08),
('GBP', 'USD', 1.27),
('USD', 'GBP', 0.79)
ON CONFLICT (source_currency, target_currency)
DO UPDATE SET rate = EXCLUDED.rate, last_updated_at = NOW();

-- ===========================================
-- SAMPLE QUERIES TO VERIFY DATA
-- ===========================================

-- View current inventory status
-- SELECT
--     ga.account_name,
--     ga.game_code,
--     a.name as league_name,
--     ac.name as currency_name,
--     ci.quantity,
--     ci.avg_buy_price_vnd,
--     ci.avg_buy_price_usd
-- FROM currency_inventory ci
-- JOIN game_accounts ga ON ci.game_account_id = ga.id
-- JOIN attributes a ON ga.league_attribute_id = a.id
-- JOIN attributes ac ON ci.currency_attribute_id = ac.id
-- WHERE ci.quantity > 0
-- ORDER BY ga.game_code, a.name, ac.name;

-- View recent transactions
-- SELECT
--     ct.transaction_type,
--     ct.quantity,
--     ct.unit_price_vnd,
--     a.name as currency_name,
--     ga.account_name,
--     ct.notes,
--     ct.created_at
-- FROM currency_transactions ct
-- JOIN attributes a ON ct.currency_attribute_id = a.id
-- JOIN game_accounts ga ON ct.game_account_id = ga.id
-- ORDER BY ct.created_at DESC
-- LIMIT 10;

-- ===========================================
-- COMMENTS
-- ===========================================

-- This migration creates sample data for testing the currency system across multiple games and leagues
-- It includes game accounts, transactions, and exchange rates to verify the system functionality