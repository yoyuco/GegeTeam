-- Migration: Import Staging Channels Data
-- Version: 1.0
-- Date: 2025-10-10
-- Purpose: Import channels data from staging-schema-export/data/channels.json

-- ===========================================
-- CLEAR EXISTING CHANNELS DATA
-- ===========================================

-- Clear existing channels to avoid conflicts
DELETE FROM public.channels;

-- Reset sequence
ALTER SEQUENCE IF EXISTS public.channels_id_seq RESTART WITH 1;

-- ===========================================
-- IMPORT STAGING CHANNELS DATA
-- ===========================================

-- Insert channels from staging data
INSERT INTO public.channels (id, code, trading_fee_chain_id, name, description, channel_type, is_active, created_at, updated_at) VALUES
('25e63b01-8c37-4f1e-8dc1-dd3f26771b9b', 'G2G', '39ce6b93-f45b-467e-8316-e922ebc41911', 'G2G', 'G2G gaming marketplace platform', 'SALES', true, '2025-10-09T08:26:48.719815+00:00', '2025-10-10T02:15:27.659593+00:00'),
('305db40c-25cd-4797-85cc-5f30da3f3aa3', 'Eldorado', NULL, 'Eldorado', NULL, 'SALES', true, '2025-10-09T08:26:48.719815+00:00', '2025-10-09T08:26:48.719815+00:00'),
('815d1021-c0d0-4f26-a34f-1036f0a58092', 'Facebook', 'eb8ec2c7-919a-4be5-b1b9-097ea1e8ad81', 'Facebook', NULL, 'SALES', true, '2025-10-09T08:26:48.719815+00:00', '2025-10-10T02:15:54.918076+00:00'),
('8757fc30-4657-48d9-b58e-d9f8a0af3874', 'Discord', '41860638-471b-46ba-b0eb-5f49c925761c', 'Discord', NULL, 'SALES', true, '2025-10-09T08:26:48.719815+00:00', '2025-10-10T02:16:00.981657+00:00'),
('d99c8a14-decd-44fe-b91a-0eac3f362aa3', 'PlayerAuctions', NULL, 'PlayerAuctions', NULL, 'SALES', true, '2025-10-09T08:26:48.719815+00:00', '2025-10-09T08:26:48.719815+00:00');

-- ===========================================
-- VERIFICATION
-- ===========================================

-- Verify the channels were inserted correctly
DO $$
DECLARE
    total_count INTEGER;
    sales_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO total_count FROM public.channels;
    SELECT COUNT(*) INTO sales_count FROM public.channels WHERE channel_type = 'SALES' AND is_active = true;

    RAISE NOTICE 'Total channels: %', total_count;
    RAISE NOTICE 'Active SALES channels: %', sales_count;

    IF sales_count = 0 THEN
        RAISE EXCEPTION 'No SALES channels found - data import failed';
    END IF;
END $$;

-- ===========================================
-- STATISTICS UPDATE
-- ===========================================

ANALYZE public.channels;