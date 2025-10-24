-- =====================================================
-- ADD PROOF COLUMN TO CURRENCY ORDERS
-- JSON-based proof storage for all order stages
-- =====================================================

-- Add proof column to currency_orders table
ALTER TABLE currency_orders
ADD COLUMN IF NOT EXISTS proofs JSONB DEFAULT '{}';

-- Add index for better query performance on proof data
CREATE INDEX IF NOT EXISTS idx_currency_orders_proofs_gin
ON currency_orders USING gin(proofs);

-- Add helpful function to extract proof files by stage
CREATE OR REPLACE FUNCTION get_proofs_by_stage(
    order_proofs JSONB,
    stage TEXT,
    order_type TEXT DEFAULT NULL
) RETURNS JSONB AS $$
BEGIN
    -- Extract proofs for specific stage and optional order type
    IF order_type IS NOT NULL THEN
        RETURN order_proofs->stage->order_type;
    ELSE
        -- Return all proofs for the stage (across all order types)
        RETURN order_proofs->stage;
    END IF;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Add function to get all proof files for an order
CREATE OR REPLACE FUNCTION get_all_proof_files(
    order_proofs JSONB
) RETURNS JSONB AS $$
DECLARE
    result JSONB := '[]'::JSONB;
    stage JSONB;
    order_type JSONB;
    category JSONB;
    files JSONB;
BEGIN
    -- Loop through all stages
    FOR stage IN SELECT jsonb_array_elements(order_proofs) LOOP
        -- Loop through all order types in this stage
        FOR order_type IN SELECT jsonb_array_elements(stage) LOOP
            -- Loop through all categories in this order type
            FOR category IN SELECT jsonb_array_elements(order_type) LOOP
                -- Get files array
                files := category->'files';

                -- If files exist, merge into result
                IF jsonb_array_length(files) > 0 THEN
                    result := result || files;
                END IF;
            END LOOP;
        END LOOP;
    END LOOP;

    RETURN result;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Add function to count proof files by stage
CREATE OR REPLACE FUNCTION count_proofs_by_stage(
    order_proofs JSONB,
    stage TEXT
) RETURNS INTEGER AS $$
BEGIN
    RETURN (
        SELECT COALESCE(SUM(
            CASE
                WHEN jsonb_typeof(proof_data) = 'object'
                THEN jsonb_array_length(proof_data->'files')
                ELSE 0
            END
        ), 0)
        FROM (
            SELECT jsonb_array_elements(order_proofs->stage) AS proof_data
        ) AS stages
    );
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- =====================================================
-- MIGRATION NOTES
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '===================================================';
    RAISE NOTICE 'CURRENCY ORDER PROOFS COLUMN ADDED SUCCESSFULLY';
    RAISE NOTICE '===================================================';
    RAISE NOTICE '✅ Added proofs JSONB column to currency_orders';
    RAISE NOTICE '✅ Created GIN index for proof queries';
    RAISE NOTICE '✅ Created helper functions:';
    RAISE NOTICE '   - get_proofs_by_stage(order_proofs, stage, order_type)';
    RAISE NOTICE '   - get_all_proof_files(order_proofs)';
    RAISE NOTICE '   - count_proofs_by_stage(order_proofs, stage)';
    RAISE NOTICE '===================================================';
    RAISE NOTICE 'Usage Examples:';
    RAISE NOTICE 'SELECT get_proofs_by_stage(proofs, ''order_creation'', ''purchase'');';
    RAISE NOTICE 'SELECT get_all_proof_files(proofs);';
    RAISE NOTICE 'SELECT count_proofs_by_stage(proofs, ''order_completion'');';
    RAISE NOTICE '===================================================';
END $$;