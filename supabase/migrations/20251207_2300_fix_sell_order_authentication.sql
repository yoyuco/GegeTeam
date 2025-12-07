-- Fix: Update SELL ORDER creation functions to follow proper authentication pattern
-- Following rule: Frontend calls get_current_profile_id(), Backend receives profiles.id as parameter
-- This migration complements 20251207_1330_fix_currency_order_authentication.sql which only fixed purchase orders

-- =====================================================
-- SAFE DROPS - Handle all possible function versions
-- =====================================================

-- Drop ALL versions of create_currency_sell_order using CASCADE
DROP FUNCTION IF EXISTS create_currency_sell_order() CASCADE;

-- Drop ALL versions of create_currency_sell_order_draft using CASCADE
DROP FUNCTION IF EXISTS create_currency_sell_order_draft() CASCADE;

-- =====================================================
-- RECREATE FUNCTIONS WITH PROPER AUTHENTICATION
-- =====================================================

-- Recreate create_currency_sell_order with proper authentication pattern
CREATE OR REPLACE FUNCTION create_currency_sell_order(
    p_currency_attribute_id UUID,
    p_quantity NUMERIC,
    p_game_code TEXT,
    p_delivery_info TEXT,
    p_channel_id UUID,
    p_user_id UUID,  -- Required parameter: profiles.id from frontend - moved before default parameters
    p_server_attribute_code TEXT DEFAULT NULL,
    p_character_id TEXT DEFAULT NULL,
    p_character_name TEXT DEFAULT NULL,
    p_exchange_type TEXT DEFAULT 'none',
    p_exchange_details JSONB DEFAULT NULL,
    p_party_id UUID DEFAULT NULL,
    p_priority_level TEXT DEFAULT 'normal',
    p_deadline_at TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    p_notes TEXT DEFAULT NULL,
    p_sale_amount NUMERIC DEFAULT NULL,
    p_sale_currency_code TEXT DEFAULT 'USD'
)
RETURNS TABLE(
    success BOOLEAN,
    order_id UUID,
    order_number TEXT,
    message TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO public
AS $$
DECLARE
    v_order_id UUID;
    v_order_number TEXT;
    v_currency_record RECORD;
    v_channel_record RECORD;
    v_customer_party_id UUID;
    v_existing_customer RECORD;
    v_inventory_pool_id UUID;
    v_game_account_id UUID;
    v_assigned_to UUID;
    v_has_assignment BOOLEAN := false;
    v_order_status currency_order_status_enum := 'pending';
    v_employee RECORD;
    v_contact_info_json JSONB;
    v_delivery_info_final TEXT;      -- Game tag only
    v_notes_final TEXT;              -- Combined: delivery_contact_info | user_notes
    v_game_tag TEXT;
    v_customer_name TEXT;
    v_exchange_type_cast currency_exchange_type_enum; -- Cast variable
    v_delivery_contact_info TEXT;    -- Extracted delivery contact info
    v_priority_level_num INTEGER;    -- Convert priority level to integer
BEGIN
    -- Validate user_id parameter (following authentication rule)
    IF p_user_id IS NULL THEN
        RETURN QUERY SELECT FALSE, NULL::UUID, NULL::TEXT, 'Authentication required: user_id cannot be null';
        RETURN;
    END IF;

    -- Cast the exchange_type text to enum, handling NULL values
    IF p_exchange_type IS NOT NULL AND p_exchange_type != '' THEN
        v_exchange_type_cast := p_exchange_type::currency_exchange_type_enum;
    ELSE
        v_exchange_type_cast := 'none'::currency_exchange_type_enum;
    END IF;

    -- Convert text priority level to integer
    v_priority_level_num := CASE
        WHEN p_priority_level = 'high' OR p_priority_level = 'urgent' THEN 1
        WHEN p_priority_level = 'normal' OR p_priority_level = 'medium' THEN 2
        WHEN p_priority_level = 'low' THEN 3
        ELSE 2  -- Default to normal
    END;

    -- Validate currency exists and is active
    SELECT * INTO v_currency_record
    FROM public.attributes
    WHERE id = p_currency_attribute_id
      AND type = 'GAME_CURRENCY'
      AND is_active = true;

    IF NOT FOUND THEN
        RETURN QUERY
        SELECT false, NULL::UUID, NULL::TEXT,
               'Invalid or inactive currency';
        RETURN;
    END IF;

    -- Validate channel exists and is active
    SELECT * INTO v_channel_record
    FROM public.channels
    WHERE id = p_channel_id
      AND is_active = true;

    IF NOT FOUND THEN
        RETURN QUERY
        SELECT false, NULL::UUID, NULL::TEXT,
               'Invalid or inactive channel';
        RETURN;
    END IF;

    -- *** CRITICAL: Validate stock and assignment availability BEFORE creating order ***
    -- Step 1: Check if any inventory pool has sufficient quantity
    IF NOT EXISTS (
        SELECT 1 FROM inventory_pools ip
        WHERE ip.game_code = p_game_code
          AND COALESCE(ip.server_attribute_code, '') = COALESCE(p_server_attribute_code, '')
          AND ip.currency_attribute_id = p_currency_attribute_id
          AND ip.quantity >= p_quantity
          AND ip.game_account_id IN (
              SELECT ga.id FROM game_accounts ga
              WHERE ga.is_active = true
          )
    ) THEN
        RETURN QUERY
        SELECT false, NULL::UUID, NULL::TEXT,
               format('Insufficient stock: No inventory pool has %s %s available', p_quantity, v_currency_record.name);
        RETURN;
    END IF;

    -- Step 2: Try to find inventory pool and employee assignment BEFORE creating order
    SELECT inventory_pool_id, game_account_id
    INTO v_inventory_pool_id, v_game_account_id
    FROM get_best_inventory_pool_for_sell_order(
        p_game_code,
        p_server_attribute_code,
        p_currency_attribute_id,
        p_quantity
    )
    WHERE get_best_inventory_pool_for_sell_order.success = true
    LIMIT 1;

    -- If no suitable inventory pool found, reject order creation
    IF v_inventory_pool_id IS NULL THEN
        RETURN QUERY
        SELECT false, NULL::UUID, NULL::TEXT,
               format('Cannot create sell order: No suitable inventory pool found for %s %s', p_quantity, v_currency_record.name);
        RETURN;
    END IF;

    -- Step 3: Try to find employee assignment (optional - if no assignment, order stays pending)
    -- FIXED: Use single parameter function call (get_employee_for_account_in_shift only needs game_account_id)
    SELECT * INTO v_employee
    FROM get_employee_for_account_in_shift(v_game_account_id)
    WHERE get_employee_for_account_in_shift.success = true
    LIMIT 1;

    IF v_employee.employee_profile_id IS NOT NULL THEN
        v_assigned_to := v_employee.employee_profile_id;
        v_has_assignment := true;
        v_order_status := 'assigned';
    END IF;

    -- CORRECTED LOGIC: Use character_id as game tag, character_name as customer name
    v_game_tag := COALESCE(p_character_id, '');  -- p_character_id is the game tag
    v_customer_name := COALESCE(p_character_name, 'Customer');  -- p_character_name is customer name

    -- UPDATED LOGIC: delivery_info for order contains game tag only
    v_delivery_info_final := v_game_tag;

    -- UPDATED LOGIC: Parse delivery info from p_delivery_info (combined format from frontend)
    -- Expected format: "gameTag | deliveryInfo" or just "gameTag" or just "deliveryInfo"
    v_delivery_contact_info := '';
    IF p_delivery_info IS NOT NULL AND p_delivery_info != '' THEN
        IF POSITION('|' IN p_delivery_info) > 0 THEN
            -- Split "gameTag | deliveryInfo"
            DECLARE
                v_temp_game_tag TEXT;
                v_temp_delivery_info TEXT;
            BEGIN
                v_temp_game_tag := TRIM(SUBSTRING(p_delivery_info FROM 1 FOR POSITION('|' IN p_delivery_info) - 1));
                v_temp_delivery_info := TRIM(SUBSTRING(p_delivery_info FROM POSITION('|' IN p_delivery_info) + 1));

                -- Use gameTag from p_character_id, but deliveryInfo from p_delivery_info
                v_delivery_contact_info := v_temp_delivery_info;
            END;
        ELSE
            -- Check if it's just delivery info (no gameTag separator)
            -- If p_delivery_info doesn't match p_character_id, treat it as delivery info
            IF TRIM(p_delivery_info) != TRIM(v_game_tag) THEN
                v_delivery_contact_info := TRIM(p_delivery_info);
            END IF;
        END IF;
    END IF;

    -- UPDATED LOGIC: Build combined notes (delivery_contact_info | user_notes)
    -- For sell orders, we need to get delivery info from the customer party if exists
    v_notes_final := COALESCE(p_notes, '');

    -- Try to get customer's delivery info from existing party
    IF p_party_id IS NOT NULL THEN
        SELECT contact_info INTO v_contact_info_json
        FROM parties
        WHERE id = p_party_id;

        IF v_contact_info_json IS NOT NULL THEN
            DECLARE
                v_existing_delivery_info TEXT;
            BEGIN
                v_existing_delivery_info := COALESCE(v_contact_info_json->>'deliveryInfo', '');

                -- Use existing delivery info if no new delivery info provided
                IF v_delivery_contact_info IS NULL OR v_delivery_contact_info = '' THEN
                    v_delivery_contact_info := v_existing_delivery_info;
                END IF;
            END;
        END IF;
    END IF;

    -- Combine delivery contact info with user notes for order notes
    IF v_delivery_contact_info IS NOT NULL AND v_delivery_contact_info != '' THEN
        IF v_notes_final IS NOT NULL AND v_notes_final != '' THEN
            v_notes_final := v_delivery_contact_info || ' | ' || v_notes_final;
        ELSE
            v_notes_final := v_delivery_contact_info;
        END IF;
    END IF;

    -- NEW LOGIC: Build contact_info JSON for customer party with separate fields
    v_contact_info_json := jsonb_build_object(
        'gameTag', v_game_tag,                    -- From p_character_id
        'deliveryInfo', v_delivery_contact_info   -- From parsed p_delivery_info
    );

    -- Handle customer party - use existing if available, create new if not
    IF p_party_id IS NOT NULL THEN
        v_customer_party_id := p_party_id;
        -- Update existing party with new contact info
        UPDATE parties SET
            contact_info = v_contact_info_json,
            updated_at = NOW()
        WHERE id = p_party_id;
    ELSIF p_character_name IS NOT NULL THEN
        -- Try to find existing customer by name and type
        SELECT id, contact_info INTO v_existing_customer
        FROM parties
        WHERE name = p_character_name
          AND type = 'customer'
        LIMIT 1;

        IF v_existing_customer.id IS NOT NULL THEN
            -- Use existing customer and update contact info
            v_customer_party_id := v_existing_customer.id;
            UPDATE parties SET
                contact_info = v_contact_info_json,
                updated_at = NOW()
            WHERE id = v_existing_customer.id;
        ELSE
            -- Create new customer party
            INSERT INTO public.parties (
                name,
                type,
                game_code,
                channel_id,
                contact_info,
                notes,
                created_at,
                updated_at
            ) VALUES (
                p_character_name,
                'customer',
                p_game_code,
                p_channel_id,
                v_contact_info_json,
                'Auto-created for sell order',
                NOW(),
                NOW()
            ) RETURNING id INTO v_customer_party_id;
        END IF;
    ELSE
        v_customer_party_id := NULL;
    END IF;

    -- Generate order number using correct format
    v_order_number := public.generate_sell_order_number();

    -- Create the sell order with validated inventory pool and assignment
    INSERT INTO public.currency_orders (
        order_type,
        currency_attribute_id,
        quantity,
        game_code,
        delivery_info,                   -- Game tag only
        channel_id,
        server_attribute_code,
        created_by,                      -- FIXED: Use p_user_id instead of auth.uid()
        game_account_id,
        exchange_type,                   -- Use the properly cast enum value
        exchange_details,
        party_id,
        priority_level,                   -- INTEGER column
        deadline_at,
        notes,                            -- delivery_contact_info | user_notes
        proofs,
        sale_amount,
        sale_currency_code,
        order_number,
        status,                          -- validated status
        assigned_to,
        assigned_at,
        inventory_pool_id,
        created_at,
        updated_at
    ) VALUES (
        'SALE',
        p_currency_attribute_id,
        p_quantity,
        p_game_code,
        v_delivery_info_final,            -- Game tag only
        p_channel_id,
        p_server_attribute_code,
        p_user_id,                       -- FIXED: Use profiles.id from frontend
        v_game_account_id,
        v_exchange_type_cast,             -- Use the properly cast enum value
        p_exchange_details,
        v_customer_party_id,
        v_priority_level_num,             -- FIXED: Use converted integer value
        p_deadline_at,
        v_notes_final,                     -- delivery_contact_info | user_notes
        '{}'::jsonb, -- Will be updated with proof uploads
        p_sale_amount,
        p_sale_currency_code,
        v_order_number,
        v_order_status,                   -- Use validated status
        v_assigned_to,
        CASE WHEN v_has_assignment THEN NOW() ELSE NULL END,
        v_inventory_pool_id,
        NOW(),
        NOW()
    ) RETURNING id INTO v_order_id;

    -- Return success with assignment info
    RETURN QUERY
    SELECT true, v_order_id, v_order_number,
           CASE
               WHEN v_has_assignment
               THEN format('Sell order created and auto-assigned to employee ID %s (account: %s)',
                          v_assigned_to,
                          (SELECT account_name FROM public.game_accounts WHERE id = v_game_account_id))
               ELSE 'Sell order created successfully, pending assignment'
           END;

END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION create_currency_sell_order TO authenticated;

-- Recreate create_currency_sell_order_draft with proper authentication pattern
CREATE OR REPLACE FUNCTION create_currency_sell_order_draft(
    p_currency_attribute_id UUID,
    p_quantity NUMERIC,
    p_game_code TEXT,
    p_delivery_info TEXT,
    p_channel_id UUID,
    p_user_id UUID,  -- Required parameter: profiles.id from frontend - moved before default parameters
    p_server_attribute_code TEXT DEFAULT NULL,
    p_character_id TEXT DEFAULT NULL,
    p_character_name TEXT DEFAULT NULL,
    p_exchange_type TEXT DEFAULT 'none',
    p_exchange_details JSONB DEFAULT NULL,
    p_party_id UUID DEFAULT NULL,
    p_priority_level TEXT DEFAULT 'normal',
    p_deadline_at TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    p_notes TEXT DEFAULT NULL,
    p_sale_amount NUMERIC DEFAULT NULL,
    p_sale_currency_code TEXT DEFAULT 'USD'
)
RETURNS TABLE(
    success BOOLEAN,
    order_id UUID,
    order_number TEXT,
    message TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO public
AS $$
DECLARE
    v_order_id UUID;
    v_order_number TEXT;
    v_currency_record RECORD;
    v_channel_record RECORD;
    v_customer_party_id UUID;
    v_existing_customer RECORD;
    v_inventory_pool_id UUID;
    v_game_account_id UUID;
    v_assigned_to UUID;
    v_has_assignment BOOLEAN := false;
    v_order_status currency_order_status_enum := 'draft';
    v_contact_info_json JSONB;
    v_delivery_info_final TEXT;      -- Game tag only
    v_notes_final TEXT;              -- Combined: delivery_contact_info | user_notes
    v_game_tag TEXT;
    v_customer_name TEXT;
    v_exchange_type_cast currency_exchange_type_enum; -- Cast variable
    v_delivery_contact_info TEXT;    -- Extracted delivery contact info
    v_priority_level_num INTEGER;    -- Convert priority level to integer
BEGIN
    -- Validate user_id parameter (following authentication rule)
    IF p_user_id IS NULL THEN
        RETURN QUERY SELECT FALSE, NULL::UUID, NULL::TEXT, 'Authentication required: user_id cannot be null';
        RETURN;
    END IF;

    -- Cast the exchange_type text to enum, handling NULL values
    IF p_exchange_type IS NOT NULL AND p_exchange_type != '' THEN
        v_exchange_type_cast := p_exchange_type::currency_exchange_type_enum;
    ELSE
        v_exchange_type_cast := 'none'::currency_exchange_type_enum;
    END IF;

    -- Convert text priority level to integer
    v_priority_level_num := CASE
        WHEN p_priority_level = 'high' OR p_priority_level = 'urgent' THEN 1
        WHEN p_priority_level = 'normal' OR p_priority_level = 'medium' THEN 2
        WHEN p_priority_level = 'low' THEN 3
        ELSE 2  -- Default to normal
    END;

    -- Validate currency exists and is active
    SELECT * INTO v_currency_record
    FROM public.attributes
    WHERE id = p_currency_attribute_id
      AND type = 'GAME_CURRENCY'
      AND is_active = true;

    IF NOT FOUND THEN
        RETURN QUERY
        SELECT false, NULL::UUID, NULL::TEXT,
               'Invalid or inactive currency';
        RETURN;
    END IF;

    -- Validate channel exists and is active
    SELECT * INTO v_channel_record
    FROM public.channels
    WHERE id = p_channel_id
      AND is_active = true;

    IF NOT FOUND THEN
        RETURN QUERY
        SELECT false, NULL::UUID, NULL::TEXT,
               'Invalid or inactive channel';
        RETURN;
    END IF;

    -- CORRECTED LOGIC: Use character_id as game tag, character_name as customer name
    v_game_tag := COALESCE(p_character_id, '');  -- p_character_id is the game tag
    v_customer_name := COALESCE(p_character_name, 'Customer');  -- p_character_name is customer name

    -- UPDATED LOGIC: delivery_info for order contains game tag only
    v_delivery_info_final := v_game_tag;

    -- UPDATED LOGIC: Parse delivery info from p_delivery_info (combined format from frontend)
    -- Expected format: "gameTag | deliveryInfo" or just "gameTag" or just "deliveryInfo"
    v_delivery_contact_info := '';
    IF p_delivery_info IS NOT NULL AND p_delivery_info != '' THEN
        IF POSITION('|' IN p_delivery_info) > 0 THEN
            -- Split "gameTag | deliveryInfo"
            DECLARE
                v_temp_game_tag TEXT;
                v_temp_delivery_info TEXT;
            BEGIN
                v_temp_game_tag := TRIM(SUBSTRING(p_delivery_info FROM 1 FOR POSITION('|' IN p_delivery_info) - 1));
                v_temp_delivery_info := TRIM(SUBSTRING(p_delivery_info FROM POSITION('|' IN p_delivery_info) + 1));

                -- Use gameTag from p_character_id, but deliveryInfo from p_delivery_info
                v_delivery_contact_info := v_temp_delivery_info;
            END;
        ELSE
            -- Check if it's just delivery info (no gameTag separator)
            -- If p_delivery_info doesn't match p_character_id, treat it as delivery info
            IF TRIM(p_delivery_info) != TRIM(v_game_tag) THEN
                v_delivery_contact_info := TRIM(p_delivery_info);
            END IF;
        END IF;
    END IF;

    -- UPDATED LOGIC: Build combined notes (delivery_contact_info | user_notes)
    -- For sell orders, we need to get delivery info from the customer party if exists
    v_notes_final := COALESCE(p_notes, '');

    -- Try to get customer's delivery info from existing party
    IF p_party_id IS NOT NULL THEN
        SELECT contact_info INTO v_contact_info_json
        FROM parties
        WHERE id = p_party_id;

        IF v_contact_info_json IS NOT NULL THEN
            DECLARE
                v_existing_delivery_info TEXT;
            BEGIN
                v_existing_delivery_info := COALESCE(v_contact_info_json->>'deliveryInfo', '');

                -- Use existing delivery info if no new delivery info provided
                IF v_delivery_contact_info IS NULL OR v_delivery_contact_info = '' THEN
                    v_delivery_contact_info := v_existing_delivery_info;
                END IF;
            END;
        END IF;
    END IF;

    -- Combine delivery contact info with user notes for order notes
    IF v_delivery_contact_info IS NOT NULL AND v_delivery_contact_info != '' THEN
        IF v_notes_final IS NOT NULL AND v_notes_final != '' THEN
            v_notes_final := v_delivery_contact_info || ' | ' || v_notes_final;
        ELSE
            v_notes_final := v_delivery_contact_info;
        END IF;
    END IF;

    -- NEW LOGIC: Build contact_info JSON for customer party with separate fields
    v_contact_info_json := jsonb_build_object(
        'gameTag', v_game_tag,                    -- From p_character_id
        'deliveryInfo', v_delivery_contact_info   -- From parsed p_delivery_info
    );

    -- Handle customer party - use existing if available, create new if not
    IF p_party_id IS NOT NULL THEN
        v_customer_party_id := p_party_id;
        -- Update existing party with new contact info
        UPDATE parties SET
            contact_info = v_contact_info_json,
            updated_at = NOW()
        WHERE id = p_party_id;
    ELSIF p_character_name IS NOT NULL THEN
        -- Try to find existing customer by name and type
        SELECT id, contact_info INTO v_existing_customer
        FROM parties
        WHERE name = p_character_name
          AND type = 'customer'
        LIMIT 1;

        IF v_existing_customer.id IS NOT NULL THEN
            -- Use existing customer and update contact info
            v_customer_party_id := v_existing_customer.id;
            UPDATE parties SET
                contact_info = v_contact_info_json,
                updated_at = NOW()
            WHERE id = v_existing_customer.id;
        ELSE
            -- Create new customer party
            INSERT INTO public.parties (
                name,
                type,
                game_code,
                channel_id,
                contact_info,
                notes,
                created_at,
                updated_at
            ) VALUES (
                p_character_name,
                'customer',
                p_game_code,
                p_channel_id,
                v_contact_info_json,
                'Auto-created for sell order draft',
                NOW(),
                NOW()
            ) RETURNING id INTO v_customer_party_id;
        END IF;
    ELSE
        v_customer_party_id := NULL;
    END IF;

    -- Generate order number using correct format
    v_order_number := public.generate_sell_order_number();

    -- Create the sell order draft (no inventory assignment for drafts)
    INSERT INTO public.currency_orders (
        order_type,
        currency_attribute_id,
        quantity,
        game_code,
        delivery_info,                   -- Game tag only
        channel_id,
        server_attribute_code,
        created_by,                      -- FIXED: Use p_user_id instead of auth.uid()
        exchange_type,                   -- Use the properly cast enum value
        exchange_details,
        party_id,
        priority_level,                   -- INTEGER column
        deadline_at,
        notes,                            -- delivery_contact_info | user_notes
        proofs,
        sale_amount,
        sale_currency_code,
        order_number,
        status,                          -- draft status
        created_at,
        updated_at
    ) VALUES (
        'SALE',
        p_currency_attribute_id,
        p_quantity,
        p_game_code,
        v_delivery_info_final,            -- Game tag only
        p_channel_id,
        p_server_attribute_code,
        p_user_id,                       -- FIXED: Use profiles.id from frontend
        v_exchange_type_cast,             -- Use the properly cast enum value
        p_exchange_details,
        v_customer_party_id,
        v_priority_level_num,             -- FIXED: Use converted integer value
        p_deadline_at,
        v_notes_final,                     -- delivery_contact_info | user_notes
        '{}'::jsonb, -- Will be updated with proof uploads
        p_sale_amount,
        p_sale_currency_code,
        v_order_number,
        'draft',                          -- Draft status
        NOW(),
        NOW()
    ) RETURNING id INTO v_order_id;

    -- Return success
    RETURN QUERY
    SELECT true, v_order_id, v_order_number,
           'Sell order draft created successfully';

END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION create_currency_sell_order_draft TO authenticated;

-- =====================================================
-- VERIFICATION
-- =====================================================

-- Verify functions were created correctly
-- This query should return the two functions with their new signatures
DO $$
BEGIN
    RAISE NOTICE 'Migration completed: SELL ORDER functions updated with proper authentication pattern';
    RAISE NOTICE 'create_currency_sell_order now requires p_user_id parameter';
    RAISE NOTICE 'create_currency_sell_order_draft now requires p_user_id parameter';
    RAISE NOTICE 'Both functions follow the rule: Frontend calls get_current_profile_id(), Backend receives profiles.id as parameter';
    RAISE NOTICE 'Functions now use get_employee_for_account_in_shift with single parameter (game_account_id)';
END $$;