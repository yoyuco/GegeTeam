# 🗄️ Currency Orders - Database Migrations Summary

**Status:** ✅ Ready for Testing
**Date:** 2025-01-13
**Version:** 1.0

---

## 📋 Migration Files Created

### 1. `20251013010000_create_currency_orders_table.sql`
**Purpose:** Creates the main `currency_orders` table with all necessary structure

**Contents:**
- ✅ 3 ENUMs: `currency_order_type_enum`, `currency_order_status_enum`, `currency_exchange_type_enum`
- ✅ Main `currency_orders` table with 30+ columns
- ✅ 8 indexes for performance optimization
- ✅ Trigger for `updated_at` timestamp management
- ✅ Helper function `generate_currency_order_number()` for order number generation
- ✅ Link to `currency_transactions` table (adds `order_id` column if missing)
- ✅ 3 RLS policies for SELECT, INSERT, UPDATE
- ✅ Comments for documentation

**Key Features:**
- Supports both SELL and PURCHASE order types
- Simplified status flow: `pending → assigned → in_progress → completed` (SELL) or `completed` (PURCHASE)
- Auto-generated order numbers: `SO-YYYYMMDD-###` (SELL) or `PO-YYYYMMDD-###` (PURCHASE)
- Audit trail with timestamps and user tracking
- Proof URLs storage for verification

---

### 2. `20251013020000_create_currency_order_rpc_functions.sql`
**Purpose:** Creates RPC functions for creating SELL and PURCHASE orders

**Functions Included:**

#### `get_current_profile_id()`
- Helper function to get profile ID from auth.uid()
- Used by all other functions

#### `create_currency_sell_order_v1(...)`
- Creates SELL order (customer buys from us)
- Status: `pending` (waits for OPS)
- **Parameters:** 14 parameters including customer info, exchange details
- **Returns:** `{ success, order_id, order_number, status }`
- **Validations:** Currency exists, league exists, customer info required

#### `create_currency_purchase_order_v1(...)`
- Creates PURCHASE order (we buy from supplier)
- **ONE-SHOT workflow:** Auto-completes and updates inventory immediately
- **Parameters:** 11 parameters including supplier info, proof URLs (required)
- **Returns:** `{ success, order_id, order_number, status, transaction_id, inventory_updated, new_balance }`
- **Key Features:**
  - Requires `p_game_account_id` (account to receive currency)
  - Requires `p_supplier_name` (plain text, no FK)
  - Requires `p_proof_urls` (array of screenshot URLs)
  - Creates order with status='completed'
  - Creates `currency_transaction` record
  - Updates `currency_inventory` with weighted average cost
  - All in ONE database transaction (atomic)

**Key Differences:**
| Feature | SELL | PURCHASE |
|---------|------|----------|
| Workflow | Multi-step (pending → completed) | One-shot (created → completed) |
| Status | `pending` | `completed` |
| Account | Optional (assigned later by OPS) | **Required** at creation |
| Supplier/Customer | Customer info required | Supplier name required |
| Proof | Optional until completion | **Required** at creation |
| Inventory | Updated at completion | Updated immediately |

---

### 3. `20251013030000_create_sell_order_workflow_functions.sql`
**Purpose:** Creates RPC functions for SELL order multi-step workflow

**Functions Included:**

#### `assign_currency_order_v1(order_id, game_account_id, notes)`
- Status transition: `pending → assigned`
- OPS assigns order to a specific game account
- Requires ops/trader2/admin role
- **Returns:** `{ success, order_id, new_status, assigned_account, assigned_at }`

#### `start_currency_order_v1(order_id, notes)`
- Status transition: `assigned → in_progress`
- OPS starts processing/delivering the order
- Requires ops/trader2/admin role
- **Returns:** `{ success, order_id, new_status, started_at }`

#### `complete_currency_order_v1(order_id, notes, proof_urls, actual_quantity, actual_unit_price)`
- Status transition: `in_progress → completed`
- OPS completes delivery with proof
- Creates `currency_transaction` (type: `sale_delivery`)
- Updates `currency_inventory` (deducts quantity)
- **Allows negative inventory** (business rule: can pre-sell)
- Requires ops/trader2/admin role
- **Returns:** `{ success, order_id, new_status, transaction_id, inventory_updated, new_balance }`

**Workflow Summary:**
```
SELL Order Flow:
1. Sales creates order → status: pending
2. OPS assigns to account → status: assigned
3. OPS starts delivery → status: in_progress
4. OPS completes with proof → status: completed (inventory updated)
```

---

### 4. `20251013040000_create_cancel_and_query_functions.sql`
**Purpose:** Creates RPC functions for cancelling orders and querying orders

**Functions Included:**

#### `cancel_currency_order_v1(order_id, cancel_reason)`
- Cancels order at any stage (before completion)
- Applicable to both SELL and PURCHASE orders
- **Special handling for PURCHASE:**
  - Creates reversal transaction (type: `manual_adjustment`)
  - Rollbacks inventory (deducts quantity)
- Permission: Owner can cancel own orders, admin/manager can cancel any
- **Returns:** `{ success, order_id, new_status, previous_status, reversal_transaction_id }`

#### `get_currency_sell_orders_v1(...)`
- Query SELL orders with filters
- **Parameters:** status, game_code, customer_name, date_from, date_to, limit, offset
- **Returns:** Table with 23 columns including order details, currency info, customer info, timestamps
- **Sorting:** Status priority (pending first) + created_at DESC

#### `get_currency_purchase_orders_v1(...)`
- Query PURCHASE orders with filters
- **Parameters:** status, game_code, supplier_name, date_from, date_to, limit, offset
- **Returns:** Table with 18 columns including order details, currency info, supplier info, timestamps
- **Note:** Supplier info stored in `customer_name` and `delivery_info` fields

---

## 🎯 Implementation Status

### ✅ Completed (100%)
- [x] Database schema design
- [x] ENUM types creation
- [x] Main `currency_orders` table
- [x] Indexes and constraints
- [x] Triggers for timestamp management
- [x] Helper functions (order number generation, profile ID)
- [x] RPC function: `create_currency_sell_order_v1`
- [x] RPC function: `create_currency_purchase_order_v1` (ONE-SHOT)
- [x] RPC function: `assign_currency_order_v1`
- [x] RPC function: `start_currency_order_v1`
- [x] RPC function: `complete_currency_order_v1`
- [x] RPC function: `cancel_currency_order_v1`
- [x] RPC function: `get_currency_sell_orders_v1`
- [x] RPC function: `get_currency_purchase_orders_v1`
- [x] RLS policies
- [x] Permission grants
- [x] Documentation comments

### 🔜 Next Steps
1. **Test migrations on local database**
   - Run migrations in sequence
   - Test each RPC function with sample data
   - Verify inventory updates work correctly
   - Test permission checks

2. **Update frontend integration**
   - Create/update `useCurrencyOrders.js` composable
   - Integrate with `CurrencySell.vue` (replace TODO at line 543)
   - Create `CurrencyPurchase.vue` page
   - Create `CurrencyOps.vue` page

3. **Deploy to staging**
   - Follow `CURRENCY-DEPLOYMENT-GUIDE.md`
   - Test with real data
   - Verify business workflows

---

## 🔧 Testing Checklist

### Database Tests
- [ ] Run all 4 migration files in sequence
- [ ] Verify table structure: `\d currency_orders`
- [ ] Verify indexes: `\di currency_orders*`
- [ ] Verify ENUMs: `\dT currency_*`
- [ ] Verify RLS policies: `\dp currency_orders`

### Function Tests

#### SELL Order Workflow:
```sql
-- 1. Create SELL order
SELECT * FROM create_currency_sell_order_v1(
    '<currency_id>', 100, 1500, 0.058,
    'POE_2', '<league_id>',
    'Test Customer', 'TestGamerTag',
    'discord.com/test', '<channel_id>',
    'items', '{"item": "Ring of Power"}'::jsonb, NULL,
    'Test order'
);

-- 2. Assign to account
SELECT * FROM assign_currency_order_v1('<order_id>', '<account_id>', 'Assigning to test account');

-- 3. Start processing
SELECT * FROM start_currency_order_v1('<order_id>', 'Starting delivery');

-- 4. Complete order
SELECT * FROM complete_currency_order_v1(
    '<order_id>',
    'Delivery completed successfully',
    ARRAY['https://example.com/proof1.jpg'],
    100, 1500
);

-- 5. Query SELL orders
SELECT * FROM get_currency_sell_orders_v1(NULL, 'POE_2', NULL, NULL, NULL, 10, 0);
```

#### PURCHASE Order Workflow (ONE-SHOT):
```sql
-- 1. Create PURCHASE order (auto-completes & updates inventory)
SELECT * FROM create_currency_purchase_order_v1(
    '<currency_id>', 50, 1200, 0,
    'POE_2', '<league_id>', '<account_id>',
    'Test Supplier', 'discord.com/supplier',
    ARRAY['https://example.com/proof.jpg'],
    'Test purchase'
);

-- 2. Query PURCHASE orders
SELECT * FROM get_currency_purchase_orders_v1(NULL, 'POE_2', NULL, NULL, NULL, 10, 0);

-- 3. Verify inventory updated
SELECT * FROM currency_inventory
WHERE game_account_id = '<account_id>'
AND currency_attribute_id = '<currency_id>';
```

#### Cancel Workflow:
```sql
-- Cancel SELL order
SELECT * FROM cancel_currency_order_v1('<order_id>', 'Customer requested cancellation');

-- Cancel PURCHASE order (with inventory rollback)
SELECT * FROM cancel_currency_order_v1('<order_id>', 'Wrong supplier, need to reverse');
```

### Permission Tests
- [ ] Test with `trader1` role (should create SELL orders only)
- [ ] Test with `trader2` role (should create/process both types)
- [ ] Test with `ops` role (should assign/start/complete SELL orders)
- [ ] Test with `admin` role (should have full access)
- [ ] Test with user without currency role (should fail)

### Inventory Tests
- [ ] PURCHASE order increases inventory ✅
- [ ] SELL order completion decreases inventory ✅
- [ ] Weighted average cost calculation works ✅
- [ ] Negative inventory allowed for SELL orders ✅
- [ ] Cancel PURCHASE order rollbacks inventory ✅

---

## 📊 RPC Functions Summary Table

| # | Function Name | Purpose | Workflow Type | Permission Required |
|---|--------------|---------|---------------|---------------------|
| 1 | `create_currency_sell_order_v1` | Create SELL order | Multi-step | Any currency role |
| 2 | `create_currency_purchase_order_v1` | Create PURCHASE order | **ONE-SHOT** | trader2/ops/admin |
| 3 | `assign_currency_order_v1` | Assign SELL order to account | SELL only | ops/trader2/admin |
| 4 | `start_currency_order_v1` | Start SELL order processing | SELL only | ops/trader2/admin |
| 5 | `complete_currency_order_v1` | Complete SELL order | SELL only | ops/trader2/admin |
| 6 | `cancel_currency_order_v1` | Cancel order | Both | Owner or admin/manager |
| 7 | `get_currency_sell_orders_v1` | Query SELL orders | Query | Any currency role |
| 8 | `get_currency_purchase_orders_v1` | Query PURCHASE orders | Query | Any currency role |

---

## 🚀 Deployment Instructions

### Local Testing
```bash
# 1. Navigate to project directory
cd D:\Web\GegeTeam

# 2. Run migrations (if using Supabase CLI)
supabase db push

# Or manually via psql:
psql -h localhost -U postgres -d postgres < supabase/migrations/20251013010000_create_currency_orders_table.sql
psql -h localhost -U postgres -d postgres < supabase/migrations/20251013020000_create_currency_order_rpc_functions.sql
psql -h localhost -U postgres -d postgres < supabase/migrations/20251013030000_create_sell_order_workflow_functions.sql
psql -h localhost -U postgres -d postgres < supabase/migrations/20251013040000_create_cancel_and_query_functions.sql
```

### Staging Deployment
```bash
# Follow CURRENCY-DEPLOYMENT-GUIDE.md
# Ensure all tests pass before deploying to production
```

---

## 📝 Notes

### Design Decisions
1. **ONE-SHOT PURCHASE Workflow**
   - Simplifies trader2 workflow (no multi-step process)
   - Reduces errors (fewer state transitions)
   - Immediate inventory availability
   - Proof required upfront (quality control)

2. **Supplier as Plain Text (No FK)**
   - More flexible (don't need to create party records)
   - Faster order creation
   - Suitable for one-time suppliers

3. **Allow Negative Inventory**
   - Business requirement: Can sell before buying
   - System tracks negative balance
   - Can be restricted later via business logic

4. **Weighted Average Cost**
   - Standard inventory costing method
   - Calculates cost basis automatically
   - Foundation for future profit calculation

### Known Limitations
- Profit calculation not yet implemented (Phase 2)
- No batch operations for league transitions (Phase 2)
- No advanced reporting/analytics (Phase 2)
- No email/notification system (Phase 2)

---

**🎯 All 8 RPC Functions Implemented and Ready for Testing!**
