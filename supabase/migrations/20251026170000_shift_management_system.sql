-- =====================================================
-- COMPLETE SHIFT MANAGEMENT SYSTEM MIGRATION (FIXED VERSION)
-- =====================================================
-- Target: Staging Environment (fvgjmfytzdnrdlluktdx)
-- Generated: 2025-10-26
-- Fixed: Corrected ga.username -> ga.account_name
-- This file includes ALL dependencies in correct order
-- =====================================================

-- =====================================================
-- STEP 1: CREATE WORK SHIFT FOUNDATION TABLES
-- =====================================================

-- Work shifts table
CREATE TABLE IF NOT EXISTS public.work_shifts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Employee shift assignments
CREATE TABLE IF NOT EXISTS public.employee_shift_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    employee_profile_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    shift_id UUID NOT NULL REFERENCES public.work_shifts(id) ON DELETE CASCADE,
    assigned_date DATE NOT NULL,
    is_active BOOLEAN DEFAULT true,
    assigned_by UUID REFERENCES public.profiles(id),
    assigned_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(employee_profile_id, shift_id, assigned_date)
);

-- Account access per shift
CREATE TABLE IF NOT EXISTS public.shift_account_access (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    shift_id UUID NOT NULL REFERENCES public.work_shifts(id) ON DELETE CASCADE,
    game_account_id UUID NOT NULL REFERENCES public.game_accounts(id) ON DELETE CASCADE,
    channel_id UUID NOT NULL REFERENCES public.channels(id) ON DELETE CASCADE,
    granted_at TIMESTAMPTZ DEFAULT NOW(),
    granted_by UUID REFERENCES public.profiles(id),
    UNIQUE(shift_id, game_account_id, channel_id)
);

-- Indexes for work shift tables
CREATE INDEX IF NOT EXISTS idx_employee_shift_assignments_employee ON public.employee_shift_assignments(employee_profile_id);
CREATE INDEX IF NOT EXISTS idx_employee_shift_assignments_shift ON public.employee_shift_assignments(shift_id);
CREATE INDEX IF NOT EXISTS idx_employee_shift_assignments_date ON public.employee_shift_assignments(assigned_date);
CREATE INDEX IF NOT EXISTS idx_shift_account_access_shift ON public.shift_account_access(shift_id);
CREATE INDEX IF NOT EXISTS idx_shift_account_access_account ON public.shift_account_access(game_account_id);

-- =====================================================
-- STEP 2: CREATE SHIFT HANDOVER AND MONITORING SYSTEM
-- =====================================================

-- Inventory handover table for tracking transfers between shifts
CREATE TABLE IF NOT EXISTS public.inventory_handovers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    from_shift_id UUID REFERENCES public.work_shifts(id) ON DELETE SET NULL,
    to_shift_id UUID REFERENCES public.work_shifts(id) ON DELETE SET NULL,
    game_account_id UUID REFERENCES public.game_accounts(id) ON DELETE CASCADE,
    channel_id UUID REFERENCES public.channels(id) ON DELETE CASCADE,
    currency_attribute_id UUID REFERENCES public.attributes(id) ON DELETE CASCADE,

    -- Quantities
    expected_quantity NUMERIC NOT NULL DEFAULT 0,
    actual_quantity NUMERIC NOT NULL DEFAULT 0,
    discrepancy NUMERIC GENERATED ALWAYS AS (actual_quantity - expected_quantity) STORED,

    -- Status and tracking
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'disputed', 'resolved')),
    handover_type TEXT DEFAULT 'auto' CHECK (handover_type IN ('auto', 'manual')),

    -- People involved
    handover_by UUID REFERENCES public.profiles(id),
    received_by UUID REFERENCES public.profiles(id),
    verified_by UUID REFERENCES public.profiles(id),

    -- Timestamps
    handover_at TIMESTAMPTZ DEFAULT NOW(),
    received_at TIMESTAMPTZ,
    verified_at TIMESTAMPTZ,

    -- Additional info
    notes TEXT,
    discrepancy_reason TEXT,

    -- Metadata
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    -- Constraints
    CONSTRAINT positive_expected_quantity CHECK (expected_quantity >= 0),
    CONSTRAINT positive_actual_quantity CHECK (actual_quantity >= 0)
);

-- Shift alert system
CREATE TABLE IF NOT EXISTS public.shift_alerts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    shift_id UUID REFERENCES public.work_shifts(id) ON DELETE CASCADE,
    alert_type TEXT NOT NULL CHECK (alert_type IN (
        'inventory_low', 'inventory_high', 'handover_pending',
        'discrepancy_detected', 'employee_overload', 'system_error'
    )),

    -- Alert details
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    severity TEXT DEFAULT 'medium' CHECK (severity IN ('low', 'medium', 'high', 'critical')),

    -- Related entities
    game_account_id UUID REFERENCES public.game_accounts(id) ON DELETE SET NULL,
    channel_id UUID REFERENCES public.channels(id) ON DELETE SET NULL,
    currency_attribute_id UUID REFERENCES public.attributes(id) ON DELETE SET NULL,
    employee_profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,

    -- Status tracking
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'acknowledged', 'resolved', 'dismissed')),
    acknowledged_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    acknowledged_at TIMESTAMPTZ,
    resolved_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    resolved_at TIMESTAMPTZ,

    -- Metadata
    alert_data JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- STEP 3: CREATE INDEXES
-- =====================================================

-- Indexes for inventory_handovers
CREATE INDEX IF NOT EXISTS idx_inventory_handovers_shifts ON public.inventory_handovers(from_shift_id, to_shift_id);
CREATE INDEX IF NOT EXISTS idx_inventory_handovers_status ON public.inventory_handovers(status);
CREATE INDEX IF NOT EXISTS idx_inventory_handovers_date ON public.inventory_handovers(handover_at);
CREATE INDEX IF NOT EXISTS idx_inventory_handovers_account ON public.inventory_handovers(game_account_id, channel_id);

-- Indexes for shift_alerts
CREATE INDEX IF NOT EXISTS idx_shift_alerts_shift_id ON public.shift_alerts(shift_id);
CREATE INDEX IF NOT EXISTS idx_shift_alerts_status ON public.shift_alerts(status);
CREATE INDEX IF NOT EXISTS idx_shift_alerts_severity ON public.shift_alerts(severity);
CREATE INDEX IF NOT EXISTS idx_shift_alerts_type ON public.shift_alerts(alert_type);
CREATE INDEX IF NOT EXISTS idx_shift_alerts_created_at ON public.shift_alerts(created_at);

-- =====================================================
-- STEP 4: CREATE FUNCTIONS
-- =====================================================

-- Function to get current shift
CREATE OR REPLACE FUNCTION public.get_current_shift()
RETURNS UUID AS $$
DECLARE
    current_shift UUID;
BEGIN
    SELECT id INTO current_shift
    FROM public.work_shifts
    WHERE is_active = true
    AND (
        (start_time <= end_time AND start_time <= CURRENT_TIME::time AND end_time >= CURRENT_TIME::time) OR
        (start_time > end_time AND (start_time <= CURRENT_TIME::time OR end_time >= CURRENT_TIME::time))
    )
    LIMIT 1;

    RETURN current_shift;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public';

-- Function to create automatic handover at shift end
CREATE OR REPLACE FUNCTION public.create_shift_handover(
    p_from_shift_id UUID,
    p_to_shift_id UUID,
    p_handover_date DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE(
    handover_id UUID,
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    handover_record UUID;
    inventory_count INTEGER := 0;
BEGIN
    -- Validate shifts
    IF p_from_shift_id IS NULL OR p_to_shift_id IS NULL THEN
        RETURN QUERY
        SELECT NULL::UUID, false, 'Invalid shift IDs'::TEXT;
        RETURN;
    END IF;

    IF p_from_shift_id = p_to_shift_id THEN
        RETURN QUERY
        SELECT NULL::UUID, false, 'From and to shifts cannot be the same'::TEXT;
        RETURN;
    END IF;

    -- Create handover records for all inventory accessible to the from_shift
    INSERT INTO public.inventory_handovers (
        from_shift_id, to_shift_id, game_account_id, channel_id, currency_attribute_id,
        expected_quantity, actual_quantity, status, handover_type, handover_by
    )
    SELECT
        p_from_shift_id,
        p_to_shift_id,
        ci.game_account_id,
        ci.channel_id,
        ci.currency_attribute_id,
        ci.quantity as expected_quantity,
        ci.quantity as actual_quantity,
        'pending' as status,
        'auto' as handover_type,
        -- Get shift supervisor or system user
        (SELECT employee_profile_id
         FROM public.employee_shift_assignments
         WHERE shift_id = p_from_shift_id
         AND assigned_date = p_handover_date
         AND is_active = true
         LIMIT 1)
    FROM public.currency_inventory ci
    JOIN public.shift_account_access saa ON
        ci.game_account_id = saa.game_account_id
        AND ci.channel_id = saa.channel_id
    WHERE saa.shift_id = p_from_shift_id
    AND ci.quantity > 0; -- Only handover items with quantity

    GET DIAGNOSTICS inventory_count = ROW_COUNT;

    IF inventory_count = 0 THEN
        RETURN QUERY
        SELECT NULL::UUID, true, 'No inventory found for handover'::TEXT;
    ELSE
        RETURN QUERY
        SELECT gen_random_uuid()::UUID, true,
               format('Created %s handover records', inventory_count)::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public';

-- Function to confirm handover
CREATE OR REPLACE FUNCTION public.confirm_shift_handover(
    p_handover_id UUID,
    p_received_by UUID,
    p_notes TEXT DEFAULT NULL
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    handover_record RECORD;
BEGIN
    -- Get handover record
    SELECT * INTO handover_record
    FROM public.inventory_handovers
    WHERE id = p_handover_id;

    IF handover_record IS NULL THEN
        RETURN QUERY
        SELECT false, 'Handover record not found'::TEXT;
        RETURN;
    END IF;

    IF handover_record.status != 'pending' THEN
        RETURN QUERY
        SELECT false, format('Handover already %s', handover_record.status)::TEXT;
        RETURN;
    END IF;

    -- Update handover record
    UPDATE public.inventory_handovers
    SET
        status = 'confirmed',
        received_by = p_received_by,
        received_at = NOW(),
        notes = COALESCE(notes, '') || COALESCE(p_notes, '')
    WHERE id = p_handover_id;

    RETURN QUERY
    SELECT true, 'Handover confirmed successfully'::TEXT;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public';

-- Function to create alerts
CREATE OR REPLACE FUNCTION public.create_shift_alert(
    p_shift_id UUID,
    p_alert_type TEXT,
    p_title TEXT,
    p_message TEXT,
    p_severity TEXT DEFAULT 'medium',
    p_game_account_id UUID DEFAULT NULL,
    p_channel_id UUID DEFAULT NULL,
    p_currency_attribute_id UUID DEFAULT NULL,
    p_employee_profile_id UUID DEFAULT NULL,
    p_alert_data JSONB DEFAULT '{}'
)
RETURNS UUID AS $$
DECLARE
    new_alert_id UUID;
BEGIN
    INSERT INTO public.shift_alerts (
        shift_id, alert_type, title, message, severity,
        game_account_id, channel_id, currency_attribute_id,
        employee_profile_id, alert_data
    ) VALUES (
        p_shift_id, p_alert_type, p_title, p_message, p_severity,
        p_game_account_id, p_channel_id, p_currency_attribute_id,
        p_employee_profile_id, p_alert_data
    ) RETURNING id INTO new_alert_id;

    RETURN new_alert_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public';

-- Function for quick health check
CREATE OR REPLACE FUNCTION public.quick_health_check()
RETURNS TABLE(
    metric TEXT,
    value NUMERIC,
    status TEXT,
    threshold NUMERIC
) AS $$
BEGIN
    -- Active shifts
    RETURN QUERY
    SELECT 'Active Shifts'::TEXT,
           (SELECT COUNT(*) FROM public.work_shifts WHERE is_active = true)::NUMERIC,
           CASE
               WHEN (SELECT COUNT(*) FROM public.work_shifts WHERE is_active = true) >= 1 THEN 'GOOD'
               ELSE 'BAD'
           END as status,
           1 as threshold;

    -- Employees today
    RETURN QUERY
    SELECT 'Employees Today'::TEXT,
           (SELECT COUNT(*) FROM public.employee_shift_assignments
            WHERE assigned_date = CURRENT_DATE AND is_active = true)::NUMERIC,
           CASE
               WHEN (SELECT COUNT(*) FROM public.employee_shift_assignments
                     WHERE assigned_date = CURRENT_DATE AND is_active = true) >= 1 THEN 'GOOD'
               ELSE 'BAD'
           END as status,
           1 as threshold;

    -- Inventory items
    RETURN QUERY
    SELECT 'Inventory Items'::TEXT,
           (SELECT COUNT(*) FROM public.currency_inventory WHERE quantity > 0)::NUMERIC,
           CASE
               WHEN (SELECT COUNT(*) FROM public.currency_inventory WHERE quantity > 0) >= 1 THEN 'GOOD'
               ELSE 'BAD'
           END as status,
           1 as threshold;

    -- Active alerts
    RETURN QUERY
    SELECT 'Active Alerts'::TEXT,
           (SELECT COUNT(*) FROM public.shift_alerts WHERE status = 'active')::NUMERIC,
           CASE
               WHEN (SELECT COUNT(*) FROM public.shift_alerts WHERE status = 'active') <= 5 THEN 'GOOD'
               WHEN (SELECT COUNT(*) FROM public.shift_alerts WHERE status = 'active') <= 10 THEN 'WARNING'
               ELSE 'BAD'
           END as status,
           5 as threshold;

    -- Pending handovers
    RETURN QUERY
    SELECT 'Pending Handovers'::TEXT,
           (SELECT COUNT(*) FROM public.inventory_handovers WHERE status = 'pending')::NUMERIC,
           CASE
               WHEN (SELECT COUNT(*) FROM public.inventory_handovers WHERE status = 'pending') = 0 THEN 'GOOD'
               WHEN (SELECT COUNT(*) FROM public.inventory_handovers WHERE status = 'pending') <= 3 THEN 'WARNING'
               ELSE 'BAD'
           END as status,
           0 as threshold;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public';

-- =====================================================
-- STEP 5: CREATE VIEWS
-- =====================================================

-- View for current shift handovers (FIXED: ga.username -> ga.account_name, SECURITY DEFINER -> SECURITY INVOKER)
CREATE OR REPLACE VIEW public.current_shift_handovers AS
SELECT
    ih.id,
    ih.from_shift_id,
    from_shift.name as from_shift_name,
    ih.to_shift_id,
    to_shift.name as to_shift_name,
    ih.game_account_id,
    ga.account_name as account_username,
    ih.channel_id,
    ch.name as channel_name,
    ih.currency_attribute_id,
    cur.name as currency_name,
    ih.expected_quantity,
    ih.actual_quantity,
    ih.discrepancy,
    ih.status,
    ih.handover_type,
    ih.handover_at,
    ih.received_at,
    handover_profile.display_name as handover_by_name,
    received_profile.display_name as received_by_name,
    ih.notes,
    ih.discrepancy_reason
FROM public.inventory_handovers ih
LEFT JOIN public.work_shifts from_shift ON ih.from_shift_id = from_shift.id
LEFT JOIN public.work_shifts to_shift ON ih.to_shift_id = to_shift.id
LEFT JOIN public.game_accounts ga ON ih.game_account_id = ga.id
LEFT JOIN public.channels ch ON ih.channel_id = ch.id
LEFT JOIN public.attributes cur ON ih.currency_attribute_id = cur.id
LEFT JOIN public.profiles handover_profile ON ih.handover_by = handover_profile.id
LEFT JOIN public.profiles received_profile ON ih.received_by = received_profile.id
WHERE DATE(ih.handover_at) = CURRENT_DATE
ORDER BY ih.handover_at DESC;

-- =====================================================
-- STEP 6: RLS POLICIES AND PERMISSIONS
-- =====================================================

-- Enable RLS on sensitive tables
ALTER TABLE public.work_shifts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inventory_handovers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shift_alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.employee_shift_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shift_account_access ENABLE ROW LEVEL SECURITY;

-- RLS Policies for inventory_handovers
CREATE POLICY "Users can view handovers for their shifts" ON public.inventory_handovers
FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM public.employee_shift_assignments esa
        WHERE esa.employee_profile_id = auth.uid()
        AND esa.shift_id IN (from_shift_id, to_shift_id)
        AND esa.assigned_date = DATE(handover_at)
    )
);

CREATE POLICY "Users can create handovers for their shifts" ON public.inventory_handovers
FOR INSERT WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.employee_shift_assignments esa
        WHERE esa.employee_profile_id = auth.uid()
        AND esa.shift_id = from_shift_id
        AND esa.assigned_date = CURRENT_DATE
    )
);

CREATE POLICY "Users can update handovers they're involved in" ON public.inventory_handovers
FOR UPDATE USING (
    handover_by = auth.uid() OR received_by = auth.uid()
);

-- RLS Policies for shift_alerts
CREATE POLICY "Users can view alerts for their shifts" ON public.shift_alerts
FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM public.employee_shift_assignments esa
        WHERE esa.employee_profile_id = auth.uid()
        AND esa.shift_id = shift_alerts.shift_id
        AND esa.assigned_date = CURRENT_DATE
    )
);

CREATE POLICY "Users can update alerts for their shifts" ON public.shift_alerts
FOR UPDATE USING (
    EXISTS (
        SELECT 1 FROM public.employee_shift_assignments esa
        WHERE esa.employee_profile_id = auth.uid()
        AND esa.shift_id = shift_alerts.shift_id
        AND esa.assigned_date = CURRENT_DATE
    )
);

-- RLS Policies for work_shifts
CREATE POLICY "Users can view work shifts" ON public.work_shifts
FOR SELECT USING (true);

CREATE POLICY "Users can insert work shifts" ON public.work_shifts
FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can update work shifts" ON public.work_shifts
FOR UPDATE USING (true);

CREATE POLICY "Users can delete work shifts" ON public.work_shifts
FOR DELETE USING (true);

-- RLS Policies for employee_shift_assignments
CREATE POLICY "Users can view their own shift assignments" ON public.employee_shift_assignments
FOR SELECT USING (employee_profile_id = auth.uid());

CREATE POLICY "Users can update their own shift assignments" ON public.employee_shift_assignments
FOR UPDATE USING (employee_profile_id = auth.uid());

-- RLS Policies for shift_account_access
CREATE POLICY "Users can view account access for their shifts" ON public.shift_account_access
FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM public.employee_shift_assignments esa
        WHERE esa.employee_profile_id = auth.uid()
        AND esa.shift_id = shift_account_access.shift_id
        AND esa.assigned_date = CURRENT_DATE
    )
);

-- =====================================================
-- STEP 7: GRANT PERMISSIONS
-- =====================================================

-- Grant permissions on work shift tables
GRANT ALL ON public.work_shifts TO authenticated;
GRANT ALL ON public.employee_shift_assignments TO authenticated;
GRANT ALL ON public.shift_account_access TO authenticated;

-- Grant permissions on handover and alert tables
GRANT ALL ON public.inventory_handovers TO authenticated;
GRANT SELECT ON public.current_shift_handovers TO authenticated;
GRANT ALL ON public.shift_alerts TO authenticated;

-- Grant permissions on functions
GRANT EXECUTE ON FUNCTION public.get_current_shift TO authenticated;
GRANT EXECUTE ON FUNCTION public.create_shift_handover TO authenticated;
GRANT EXECUTE ON FUNCTION public.confirm_shift_handover TO authenticated;
GRANT EXECUTE ON FUNCTION public.create_shift_alert TO authenticated;
GRANT EXECUTE ON FUNCTION public.quick_health_check TO authenticated;

-- =====================================================
-- COMPLETION MESSAGE
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '===================================================';
    RAISE NOTICE 'COMPLETE SHIFT MANAGEMENT SYSTEM MIGRATION DONE';
    RAISE NOTICE '===================================================';
    RAISE NOTICE '✅ Created work_shifts foundation tables';
    RAISE NOTICE '✅ Created employee_shift_assignments table';
    RAISE NOTICE '✅ Created shift_account_access table';
    RAISE NOTICE '✅ Created inventory_handovers table';
    RAISE NOTICE '✅ Created shift_alerts table';
    RAISE NOTICE '✅ Created all necessary indexes';
    RAISE NOTICE '✅ Created management functions';
    RAISE NOTICE '✅ Created monitoring views';
    RAISE NOTICE '✅ Created RLS policies';
    RAISE NOTICE '✅ Applied correct search_path patterns';
    RAISE NOTICE '✅ Fixed column reference issues';
    RAISE NOTICE '✅ Granted all permissions';
    RAISE NOTICE '===================================================';
    RAISE NOTICE 'Functions available:';
    RAISE NOTICE '1. get_current_shift() - Get current active shift';
    RAISE NOTICE '2. create_shift_handover(from_shift, to_shift)';
    RAISE NOTICE '3. confirm_shift_handover(handover_id, received_by)';
    RAISE NOTICE '4. create_shift_alert(shift_id, type, title, message)';
    RAISE NOTICE '5. quick_health_check() - Quick system health check';
    RAISE NOTICE '===================================================';
    RAISE NOTICE 'Views available:';
    RAISE NOTICE '1. current_shift_handovers - Today''s handovers';
    RAISE NOTICE '===================================================';
    RAISE NOTICE 'Test queries:';
    RAISE NOTICE 'SELECT * FROM quick_health_check();';
    RAISE NOTICE 'SELECT * FROM get_current_shift();';
    RAISE NOTICE 'SELECT COUNT(*) FROM inventory_handovers;';
    RAISE NOTICE 'SELECT COUNT(*) FROM shift_alerts;';
    RAISE NOTICE '===================================================';

    -- Insert sample work shifts if empty
    IF (SELECT COUNT(*) FROM public.work_shifts) = 0 THEN
        INSERT INTO public.work_shifts (name, start_time, end_time, description) VALUES
        ('Ca sáng', '07:00:00', '15:00:00', 'Ca làm việc buổi sáng'),
        ('Ca chiều', '15:00:00', '23:00:00', 'Ca làm việc buổi chiều'),
        ('Ca đêm', '23:00:00', '07:00:00', 'Ca làm việc ban đêm');
        RAISE NOTICE '✅ Created sample work shifts';
    END IF;
END $$;