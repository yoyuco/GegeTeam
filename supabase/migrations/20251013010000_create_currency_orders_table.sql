-- ===================================
-- CURRENCY ORDERS TABLE
-- ===================================
-- Purpose: Store currency buy/sell orders with simplified workflow
-- Version: 1.0 (Simplified from original design)
-- Date: 2025-01-13

-- 1. Create ENUMs for type safety
CREATE TYPE currency_order_type_enum AS ENUM (
    'PURCHASE',  -- Mua currency từ supplier/farmer
    'SELL'       -- Bán currency cho khách hàng
);

CREATE TYPE currency_order_status_enum AS ENUM (
    'pending',      -- Chờ xử lý (SELL only)
    'assigned',     -- Đã phân công account (SELL only)
    'in_progress',  -- Đang xử lý (SELL only)
    'completed',    -- Hoàn thành
    'cancelled'     -- Hủy
);

CREATE TYPE currency_exchange_type_enum AS ENUM (
    'none',     -- Không có exchange
    'items',    -- Đổi bằng items
    'service',  -- Đổi bằng service
    'farmer'    -- Mua từ farmer trong team
);

-- 2. Create main table
CREATE TABLE public.currency_orders (
    -- Primary Keys & Identification
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    order_number text UNIQUE NOT NULL,

    -- Order Classification
    order_type currency_order_type_enum NOT NULL,
    status currency_order_status_enum NOT NULL DEFAULT 'pending',

    -- Currency Information
    currency_attribute_id uuid NOT NULL REFERENCES public.attributes(id),
    quantity numeric NOT NULL CHECK (quantity > 0),
    unit_price_vnd numeric NOT NULL CHECK (unit_price_vnd >= 0),
    unit_price_usd numeric DEFAULT 0 CHECK (unit_price_usd >= 0),

    -- Calculated Fields
    total_price_vnd numeric GENERATED ALWAYS AS (quantity * unit_price_vnd) STORED,
    total_price_usd numeric GENERATED ALWAYS AS (quantity * unit_price_usd) STORED,

    -- Game Context
    game_code text NOT NULL,
    league_attribute_id uuid NOT NULL REFERENCES public.attributes(id),

    -- Customer Information (FOR SELL ORDERS)
    customer_name text,
    customer_game_tag text,
    delivery_info text,
    channel_id uuid REFERENCES public.channels(id),

    -- Account/Warehouse Information
    assigned_account_id uuid REFERENCES public.game_accounts(id),

    -- Exchange Information (FOR SELL ORDERS - OPTIONAL)
    exchange_type currency_exchange_type_enum DEFAULT 'none',
    exchange_details jsonb,
    exchange_images text[],

    -- Notes & Additional Information
    notes text,

    -- Proof & Verification (REQUIRED for PURCHASE, optional for SELL until completion)
    proof_urls text[],

    -- Timestamps & Workflow
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    assigned_at timestamptz,      -- When assigned to account (SELL workflow)
    started_at timestamptz,        -- When started processing (SELL workflow)
    completed_at timestamptz,      -- When completed
    cancelled_at timestamptz,      -- When cancelled

    -- User Assignment & Audit
    created_by uuid NOT NULL REFERENCES public.profiles(id),
    updated_by uuid REFERENCES public.profiles(id),
    assigned_by uuid REFERENCES public.profiles(id),
    completed_by uuid REFERENCES public.profiles(id),
    cancelled_by uuid REFERENCES public.profiles(id),
    cancel_reason text,

    -- System Fields
    metadata jsonb DEFAULT '{}'::jsonb
);

-- 3. Create indexes for performance
CREATE INDEX idx_currency_orders_type_status ON public.currency_orders(order_type, status);
CREATE INDEX idx_currency_orders_game_league ON public.currency_orders(game_code, league_attribute_id);
CREATE INDEX idx_currency_orders_customer ON public.currency_orders(customer_name) WHERE customer_name IS NOT NULL;
CREATE INDEX idx_currency_orders_created_at ON public.currency_orders(created_at DESC);
CREATE INDEX idx_currency_orders_assigned_account ON public.currency_orders(assigned_account_id) WHERE assigned_account_id IS NOT NULL;
CREATE INDEX idx_currency_orders_currency ON public.currency_orders(currency_attribute_id, game_code, league_attribute_id);
CREATE INDEX idx_currency_orders_created_by ON public.currency_orders(created_by);
CREATE INDEX idx_currency_orders_order_number ON public.currency_orders(order_number);

-- 4. Create trigger for updated_at timestamp
CREATE OR REPLACE FUNCTION update_currency_orders_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_currency_orders_updated_at
    BEFORE UPDATE ON public.currency_orders
    FOR EACH ROW
    EXECUTE FUNCTION update_currency_orders_timestamp();

-- 5. Create helper function for generating order numbers
CREATE OR REPLACE FUNCTION generate_currency_order_number(p_order_type currency_order_type_enum)
RETURNS text AS $$
DECLARE
    v_prefix text;
    v_sequence bigint;
    v_date_part text;
BEGIN
    -- Determine prefix based on order type
    v_prefix := CASE p_order_type
        WHEN 'SELL' THEN 'SO'
        WHEN 'PURCHASE' THEN 'PO'
        ELSE 'XX'
    END;

    -- Get date part (YYYYMMDD)
    v_date_part := to_char(now(), 'YYYYMMDD');

    -- Get sequence number for today
    SELECT COUNT(*) + 1 INTO v_sequence
    FROM currency_orders
    WHERE order_type = p_order_type
    AND DATE(created_at) = CURRENT_DATE;

    -- Format: SO-20251013-001 or PO-20251013-001
    RETURN v_prefix || '-' || v_date_part || '-' || LPAD(v_sequence::text, 3, '0');
END;
$$ LANGUAGE plpgsql;

-- 6. Add constraint to link order_id in currency_transactions (if column doesn't exist)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'currency_transactions'
        AND column_name = 'order_id'
    ) THEN
        ALTER TABLE public.currency_transactions
        ADD COLUMN order_id uuid REFERENCES public.currency_orders(id);

        CREATE INDEX idx_currency_transactions_order_id
        ON public.currency_transactions(order_id)
        WHERE order_id IS NOT NULL;
    END IF;
END $$;

-- 7. Enable RLS
ALTER TABLE public.currency_orders ENABLE ROW LEVEL SECURITY;

-- 8. Create RLS policies
-- Policy 1: Users with CURRENCY role can view orders
CREATE POLICY "Currency users can view orders"
ON public.currency_orders
FOR SELECT
USING (
    EXISTS (
        SELECT 1 FROM user_role_assignments ura
        JOIN attributes ba ON ura.business_area_attribute_id = ba.id
        WHERE ura.user_id = auth.uid()
        AND ba.code IN ('CURRENCY', 'DIABLO_4')  -- Support both POE and D4
    )
);

-- Policy 2: Users can create orders if they have currency role
CREATE POLICY "Currency users can create orders"
ON public.currency_orders
FOR INSERT
WITH CHECK (
    EXISTS (
        SELECT 1 FROM user_role_assignments ura
        JOIN attributes ba ON ura.business_area_attribute_id = ba.id
        WHERE ura.user_id = auth.uid()
        AND ba.code IN ('CURRENCY', 'DIABLO_4')
        AND created_by = auth.uid()
    )
);

-- Policy 3: Users can update their own orders or if they have ops/manager role
CREATE POLICY "Currency users can update orders"
ON public.currency_orders
FOR UPDATE
USING (
    created_by = auth.uid()
    OR EXISTS (
        SELECT 1 FROM user_role_assignments ura
        JOIN attributes ba ON ura.business_area_attribute_id = ba.id
        WHERE ura.user_id = auth.uid()
        AND ba.code IN ('CURRENCY', 'DIABLO_4')
        AND ura.role_name IN ('admin', 'manager', 'trader2', 'ops')
    )
);

-- 9. Add comments for documentation
COMMENT ON TABLE public.currency_orders IS 'Currency buy/sell orders with simplified workflow. SELL=multi-step (pending→assigned→in_progress→completed), PURCHASE=one-shot (created→completed immediately)';
COMMENT ON COLUMN public.currency_orders.order_type IS 'PURCHASE=buy from supplier, SELL=sell to customer';
COMMENT ON COLUMN public.currency_orders.status IS 'pending→assigned→in_progress→completed for SELL. completed for PURCHASE (one-shot)';
COMMENT ON COLUMN public.currency_orders.customer_name IS 'For SELL orders: customer name. For PURCHASE orders: supplier name (stored here as plain text)';
COMMENT ON COLUMN public.currency_orders.delivery_info IS 'For SELL orders: delivery contact. For PURCHASE orders: supplier contact (stored here as plain text)';
COMMENT ON COLUMN public.currency_orders.assigned_account_id IS 'For SELL orders: assigned later by OPS. For PURCHASE orders: specified at creation (required)';
COMMENT ON COLUMN public.currency_orders.proof_urls IS 'REQUIRED for PURCHASE orders at creation. Optional for SELL orders until completion';
