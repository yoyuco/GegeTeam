-- Migration: Approval Workflow System (Fixed)
-- Description: Approval rules and workflow management for financial transactions
-- Created: 2025-12-18 16:20:00
-- Author: Claude Code

-- 1. Approval Rules
CREATE TABLE IF NOT EXISTS approval_rules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rule_name VARCHAR(200) NOT NULL UNIQUE,
    entity_type VARCHAR(50) NOT NULL CHECK (entity_type IN ('employee_fund', 'expense', 'purchase')),
    condition_type VARCHAR(50) NOT NULL CHECK (condition_type IN ('amount_above', 'amount_below', 'amount_equals', 'custom')),
    condition_value JSONB NOT NULL, -- e.g., {"currency": "VND", "amount": 50000000}
    approval_limit DECIMAL(20,4) NOT NULL,
    description TEXT,
    approver_roles UUID[], -- Array of role IDs that can approve
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT now(),
    created_by UUID REFERENCES profiles(id),
    updated_at TIMESTAMPTZ DEFAULT now(),
    updated_by UUID REFERENCES profiles(id)
);

-- 2. Approval Requests
CREATE TABLE IF NOT EXISTS approval_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_type VARCHAR(50) NOT NULL CHECK (entity_type IN ('employee_fund', 'expense', 'purchase')),
    entity_id UUID NOT NULL, -- ID of the entity being approved
    request_data JSONB NOT NULL, -- Complete data about the request
    approval_rule_id UUID REFERENCES approval_rules(id),
    requested_by UUID NOT NULL REFERENCES profiles(id),
    current_approver UUID REFERENCES profiles(id),
    status VARCHAR(20) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED', 'CANCELLED', 'EXPIRED')),
    priority VARCHAR(20) DEFAULT 'NORMAL' CHECK (priority IN ('LOW', 'NORMAL', 'HIGH', 'URGENT')),
    amount DECIMAL(20,4),
    currency_code VARCHAR(10) DEFAULT 'VND',
    title VARCHAR(200) NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    expires_at TIMESTAMPTZ DEFAULT (now() + interval '72 hours'), -- 72-hour timeout
    approved_at TIMESTAMPTZ,
    approved_by UUID REFERENCES profiles(id),
    rejection_reason TEXT,
    approval_chain JSONB, -- Store the approval chain if multiple levels needed
    current_level INTEGER DEFAULT 1,
    total_levels INTEGER DEFAULT 1
);

-- 3. Approval Actions (Audit trail)
CREATE TABLE IF NOT EXISTS approval_actions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    approval_request_id UUID NOT NULL REFERENCES approval_requests(id),
    action VARCHAR(20) NOT NULL CHECK (action IN ('CREATED', 'APPROVED', 'REJECTED', 'CANCELLED', 'FORWARDED', 'ESCALATED')),
    actor_id UUID NOT NULL REFERENCES profiles(id),
    actor_role VARCHAR(50),
    notes TEXT,
    action_data JSONB, -- Additional data about the action
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_approval_rules_entity_type ON approval_rules(entity_type);
CREATE INDEX IF NOT EXISTS idx_approval_rules_is_active ON approval_rules(is_active);
CREATE INDEX IF NOT EXISTS idx_approval_requests_entity ON approval_requests(entity_type, entity_id);
CREATE INDEX IF NOT EXISTS idx_approval_requests_status ON approval_requests(status);
CREATE INDEX IF NOT EXISTS idx_approval_requests_requested_by ON approval_requests(requested_by);
CREATE INDEX IF NOT EXISTS idx_approval_requests_current_approver ON approval_requests(current_approver);
CREATE INDEX IF NOT EXISTS idx_approval_actions_request_id ON approval_actions(approval_request_id);

-- Insert default approval rules
INSERT INTO approval_rules (rule_name, entity_type, condition_type, condition_value, approval_limit, description, approver_roles) VALUES
('Employee Fund > 50M VND', 'employee_fund', 'amount_above', '{"currency": "VND", "amount": 50000000}', 1000000000, 'Auto-approve up to 1B VND, manager approval above', ARRAY((SELECT id FROM roles WHERE code = 'manager' LIMIT 1))),
('Employee Fund > 100M VND', 'employee_fund', 'amount_above', '{"currency": "VND", "amount": 100000000}', 1000000000, 'Manager approval required for amounts > 100M VND', ARRAY((SELECT id FROM roles WHERE code = 'manager' LIMIT 1))),
('Employee Fund > 500M VND', 'employee_fund', 'amount_above', '{"currency": "VND", "amount": 500000000}', 1000000000, 'Admin approval required for amounts > 500M VND', ARRAY((SELECT id FROM roles WHERE code = 'admin' LIMIT 1)))
ON CONFLICT (rule_name) DO NOTHING;

-- Function to check if approval is required
CREATE OR REPLACE FUNCTION check_approval_required(
    p_entity_type VARCHAR(50),
    p_amount DECIMAL(20,4),
    p_currency VARCHAR(10) DEFAULT 'VND',
    p_additional_conditions JSONB DEFAULT '{}'::jsonb
)
RETURNS JSON AS $$
DECLARE
    v_rule approval_rules%ROWTYPE;
    v_approval_required BOOLEAN := false;
    v_approver_roles UUID[];
BEGIN
    -- Find the most restrictive applicable rule
    SELECT * INTO v_rule
    FROM approval_rules
    WHERE entity_type = p_entity_type
      AND is_active = true
      AND (
        (condition_type = 'amount_above' AND p_amount > (condition_value->>'amount')::DECIMAL)
        OR (condition_type = 'amount_below' AND p_amount < (condition_value->>'amount')::DECIMAL)
        OR (condition_type = 'amount_equals' AND p_amount = (condition_value->>'amount')::DECIMAL)
        OR (condition_type = 'custom')
      )
      AND (condition_value->>'currency' = p_currency OR condition_value->>'currency' IS NULL)
    ORDER BY
        CASE condition_type
            WHEN 'amount_above' THEN (condition_value->>'amount')::DECIMAL
            ELSE 0
        END DESC
    LIMIT 1;

    IF v_rule.id IS NOT NULL THEN
        v_approval_required := true;
        v_approver_roles := v_rule.approver_roles;
    END IF;

    RETURN json_build_object(
        'approval_required', v_approval_required,
        'rule_id', COALESCE(v_rule.id, ''),
        'rule_name', COALESCE(v_rule.rule_name, ''),
        'approval_limit', COALESCE(v_rule.approval_limit, 0),
        'approver_roles', COALESCE(v_approver_roles, ARRAY[]::UUID[])
    );
END;
$$ LANGUAGE plpgsql;

-- Function to create approval request (FIXED)
CREATE OR REPLACE FUNCTION create_approval_request(
    p_entity_type VARCHAR(50),
    p_entity_id UUID,
    p_title VARCHAR(200),
    p_description TEXT,
    p_amount DECIMAL(20,4),
    p_currency VARCHAR(10) DEFAULT 'VND',
    p_request_data JSONB DEFAULT '{}'::jsonb,
    p_priority VARCHAR(20) DEFAULT 'NORMAL',
    p_expires_in_hours INTEGER DEFAULT 72
)
RETURNS UUID AS $$
DECLARE
    v_approval_request_id UUID;
    v_rule_info JSON;
    v_approver_id UUID;
    v_expires_at TIMESTAMPTZ;
BEGIN
    -- Check if approval is required
    v_rule_info := check_approval_required(p_entity_type, p_amount, p_currency);

    -- If no approval required, return null
    IF NOT (v_rule_info->>'approval_required')::BOOLEAN THEN
        RETURN NULL;
    END IF;

    -- Find first available approver
    SELECT p.id INTO v_approver_id
    FROM profiles p
    JOIN user_role_assignments ura ON p.id = ura.user_id
    JOIN roles r ON ura.role_id = r.id
    WHERE r.id = ANY((v_rule_info->'approver_roles')::UUID[])
      AND p.status = 'active'
    LIMIT 1;

    IF v_approver_id IS NULL THEN
        RAISE EXCEPTION 'No available approver found for the specified roles';
    END IF;

    -- Calculate expiration time
    v_expires_at := now() + (p_expires_in_hours || ' hours')::INTERVAL;

    -- Create approval request
    INSERT INTO approval_requests (
        entity_type, entity_id, title, description,
        amount, currency_code, request_data,
        approval_rule_id, requested_by, current_approver,
        priority, expires_at, status
    ) VALUES (
        p_entity_type, p_entity_id, p_title, p_description,
        p_amount, p_currency, p_request_data,
        (v_rule_info->>'rule_id')::UUID, auth.uid(), v_approver_id,
        p_priority, v_expires_at, 'PENDING'
    ) RETURNING id INTO v_approval_request_id;

    -- Create initial action record
    INSERT INTO approval_actions (approval_request_id, action, actor_id, notes)
    VALUES (v_approval_request_id, 'CREATED', auth.uid(), 'Approval request created');

    RETURN v_approval_request_id;
END;
$$ LANGUAGE plpgsql;

-- Function to approve request
CREATE OR REPLACE FUNCTION approve_request(
    p_approval_request_id UUID,
    p_notes TEXT DEFAULT ''
)
RETURNS JSON AS $$
DECLARE
    v_request approval_requests%ROWTYPE;
    v_can_approve BOOLEAN := false;
    v_next_approver UUID;
    v_result JSON;
BEGIN
    -- Get the request
    SELECT * INTO v_request
    FROM approval_requests
    WHERE id = p_approval_request_id;

    IF v_request.id IS NULL THEN
        RETURN json_build_object('success', false, 'message', 'Approval request not found');
    END IF;

    -- Check if request is still pending
    IF v_request.status != 'PENDING' THEN
        RETURN json_build_object('success', false, 'message', 'Request is not pending: ' || v_request.status);
    END IF;

    -- Check if expired
    IF v_request.expires_at < now() THEN
        UPDATE approval_requests
        SET status = 'EXPIRED', updated_at = now()
        WHERE id = p_approval_request_id;

        RETURN json_build_object('success', false, 'message', 'Approval request has expired');
    END IF;

    -- Check if current user can approve
    v_can_approve := (
        v_request.current_approver = auth.uid()
        OR EXISTS(
            SELECT 1 FROM roles r
            JOIN user_role_assignments ura ON r.id = ura.role_id
            WHERE ura.user_id = auth.uid()
              AND r.code IN ('admin', 'manager')
        )
    );

    IF NOT v_can_approve THEN
        RETURN json_build_object('success', false, 'message', 'You do not have permission to approve this request');
    END IF;

    -- Process approval
    IF v_request.current_level >= v_request.total_levels THEN
        -- Final approval
        UPDATE approval_requests
        SET status = 'APPROVED',
            approved_by = auth.uid(),
            approved_at = now(),
            updated_at = now()
        WHERE id = p_approval_request_id;

        -- Create approval action
        INSERT INTO approval_actions (approval_request_id, action, actor_id, notes)
        VALUES (p_approval_request_id, 'APPROVED', auth.uid(), p_notes);

        v_result := json_build_object(
            'success', true,
            'message', 'Request approved successfully',
            'status', 'APPROVED'
        );

    ELSE
        -- Move to next level (simplified for now)
        -- No more approvers, approve final
        UPDATE approval_requests
        SET status = 'APPROVED',
            approved_by = auth.uid(),
            approved_at = now(),
            updated_at = now()
        WHERE id = p_approval_request_id;

        v_result := json_build_object(
            'success', true,
            'message', 'Request approved (final approval)',
            'status', 'APPROVED'
        );

        -- Create approval action
        INSERT INTO approval_actions (approval_request_id, action, actor_id, notes)
        VALUES (p_approval_request_id, 'APPROVED', auth.uid(), p_notes);
    END IF;

    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

-- Function to reject request
CREATE OR REPLACE FUNCTION reject_request(
    p_approval_request_id UUID,
    p_rejection_reason TEXT
)
RETURNS JSON AS $$
DECLARE
    v_request approval_requests%ROWTYPE;
    v_can_reject BOOLEAN := false;
BEGIN
    -- Get the request
    SELECT * INTO v_request
    FROM approval_requests
    WHERE id = p_approval_request_id;

    IF v_request.id IS NULL THEN
        RETURN json_build_object('success', false, 'message', 'Approval request not found');
    END IF;

    -- Check if request is still pending
    IF v_request.status != 'PENDING' THEN
        RETURN json_build_object('success', false, 'message', 'Request is not pending: ' || v_request.status);
    END IF;

    -- Check if current user can reject
    v_can_reject := (
        v_request.current_approver = auth.uid()
        OR EXISTS(
            SELECT 1 FROM roles r
            JOIN user_role_assignments ura ON r.id = ura.role_id
            WHERE ura.user_id = auth.uid()
              AND r.code IN ('admin', 'manager')
        )
    );

    IF NOT v_can_reject THEN
        RETURN json_build_object('success', false, 'message', 'You do not have permission to reject this request');
    END IF;

    -- Reject the request
    UPDATE approval_requests
    SET status = 'REJECTED',
        rejection_reason = p_rejection_reason,
        updated_at = now()
    WHERE id = p_approval_request_id;

    -- Create rejection action
    INSERT INTO approval_actions (approval_request_id, action, actor_id, notes)
    VALUES (p_approval_request_id, 'REJECTED', auth.uid(), p_rejection_reason);

    RETURN json_build_object(
        'success', true,
        'message', 'Request rejected successfully',
        'status', 'REJECTED',
        'rejection_reason', p_rejection_reason
    );
END;
$$ LANGUAGE plpgsql;

-- View for pending approvals dashboard
CREATE OR REPLACE VIEW pending_approvals_dashboard AS
SELECT
    ar.id,
    ar.entity_type,
    ar.entity_id,
    ar.title,
    ar.description,
    ar.amount,
    ar.currency_code,
    ar.priority,
    ar.created_at,
    ar.expires_at,
    p_requester.display_name as requester_name,
    p_approver.display_name as current_approver_name,
    ar_rule.rule_name,
    EXTRACT(HOURS FROM (ar.expires_at - now())) as hours_remaining,
    CASE
        WHEN ar.expires_at < now() THEN 'EXPIRED'
        WHEN EXTRACT(HOURS FROM (ar.expires_at - now())) < 24 THEN 'URGENT'
        WHEN EXTRACT(HOURS FROM (ar.expires_at - now())) < 48 THEN 'HIGH'
        ELSE 'NORMAL'
    END as urgency_level
FROM approval_requests ar
JOIN profiles p_requester ON ar.requested_by = p_requester.id
JOIN profiles p_approver ON ar.current_approver = p_approver.id
LEFT JOIN approval_rules ar_rule ON ar.approval_rule_id = ar_rule.id
WHERE ar.status = 'PENDING'
ORDER BY
    CASE priority
        WHEN 'URGENT' THEN 1
        WHEN 'HIGH' THEN 2
        WHEN 'NORMAL' THEN 3
        ELSE 4
    END,
    ar.created_at ASC;

SELECT 'Approval workflows migration completed successfully!' as success_message;