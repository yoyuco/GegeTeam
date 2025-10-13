# 📋 Currency Orders - RPC Functions Specification

**Version:** 1.0
**Date:** 2025-01-12
**Purpose:** Complete specification of all RPC functions for Currency Orders System

---

## 🎯 Naming Convention

**Pattern:** `{action}_currency_{type}_order_v1`

- ✅ **GOOD**: `create_currency_sell_order_v1`, `get_currency_purchase_orders_v1`
- ❌ **BAD**: `create_currency_order_v1` (too generic), `createSellOrder` (no version)

**Rationale:**
- **Specific & Clear**: Immediately know if it's SELL or PURCHASE
- **Searchable**: Easy to find related functions with `grep currency_sell`
- **Versioned**: `_v1` suffix allows future updates without breaking changes
- **Consistent**: Follows existing pattern in codebase (e.g., `create_service_order_v1`)

---

## 📊 Functions Overview

| # | Function Name | Type | Purpose | Status Flow | Workflow |
|---|--------------|------|---------|-------------|----------|
| 1 | `create_currency_sell_order_v1` | SELL | Create sell order | → `pending` | Multi-step |
| 2 | `create_currency_purchase_order_v1` | PURCHASE | Create + auto-complete | → `completed` | **One-shot** |
| 3 | `get_currency_sell_orders_v1` | SELL | Query sell orders | - | - |
| 4 | `get_currency_purchase_orders_v1` | PURCHASE | Query purchase orders | - | - |
| 5 | `assign_currency_order_v1` | OPS (SELL only) | Assign to account | `pending` → `assigned` | SELL |
| 6 | `start_currency_order_v1` | OPS (SELL only) | Start processing | `assigned` → `in_progress` | SELL |
| 7 | `complete_currency_order_v1` | OPS (SELL only) | Complete order | `in_progress` → `completed` | SELL |
| 8 | `cancel_currency_order_v1` | BOTH | Cancel order | `*` → `cancelled` | Both |

---

## 1️⃣ `create_currency_sell_order_v1`

**Purpose:** Sales creates a SELL order (customer buys currency from us)

**Parameters:**
```sql
CREATE OR REPLACE FUNCTION create_currency_sell_order_v1(
    p_currency_attribute_id UUID,
    p_quantity NUMERIC,
    p_unit_price_vnd NUMERIC,
    p_unit_price_usd NUMERIC,
    p_game_code TEXT,
    p_league_attribute_id UUID,
    p_customer_name TEXT,
    p_customer_game_tag TEXT,
    p_delivery_info TEXT,
    p_channel_id UUID,
    p_exchange_type TEXT DEFAULT NULL,           -- 'items', 'service', 'farmer', NULL
    p_exchange_details JSONB DEFAULT NULL,       -- Details về exchange
    p_exchange_images TEXT[] DEFAULT NULL,       -- Proof images URLs
    p_sales_notes TEXT DEFAULT NULL
) RETURNS JSONB
```

**Returns:**
```json
{
  "success": true,
  "order_id": "uuid",
  "order_number": "SO-20250112-001"
}
```

**Business Logic:**
1. Insert into `currency_orders` table with `order_type = 'SELL'`
2. Set `status = 'pending'`
3. Generate unique `order_number` with prefix `SO-`
4. Calculate `total_price_vnd` = quantity × unit_price_vnd
5. Set `created_by` = current user profile ID
6. Create audit log entry

**Error Handling:**
- Currency not found: Raise exception
- League not found: Raise exception
- Invalid quantity (≤ 0): Raise exception
- Price validation: At least one price (VND or USD) required

---

## 2️⃣ `create_currency_purchase_order_v1`

**Purpose:** Trader2 buys currency from customer → Create with proof → Auto-complete → Inventory updated immediately

**🚀 SIMPLIFIED "ONE-SHOT" WORKFLOW:**
```
Nhập đầy đủ thông tin + proof → Create → Auto-complete → Inventory ✅
(All in ONE database transaction)
```

**Parameters:**
```sql
CREATE OR REPLACE FUNCTION create_currency_purchase_order_v1(
    -- Basic info
    p_currency_attribute_id UUID,
    p_quantity NUMERIC,
    p_unit_price_vnd NUMERIC,
    p_unit_price_usd NUMERIC DEFAULT 0,
    p_game_code TEXT,
    p_league_attribute_id UUID,
    p_game_account_id UUID,                      -- Account nhận currency (REQUIRED)

    -- Supplier info (simple text fields)
    p_supplier_name TEXT,                        -- Tên người bán (REQUIRED)
    p_supplier_contact TEXT DEFAULT NULL,        -- Discord/Telegram (optional)

    -- Proof (REQUIRED for PURCHASE)
    p_proof_urls TEXT[],                         -- Screenshots giao dịch (REQUIRED)

    -- Notes
    p_notes TEXT DEFAULT NULL
) RETURNS JSONB
```

**Returns:**
```json
{
  "success": true,
  "order_id": "uuid",
  "order_number": "PO-20250112-001",
  "status": "completed",
  "transaction_id": "uuid",
  "inventory_updated": true,
  "new_balance": 1500.50
}
```

**Business Logic (ALL IN ONE TRANSACTION 🔥):**

1. **Validate inputs**:
   - Currency exists & active
   - League exists & active
   - Account exists & active
   - Quantity > 0
   - At least one price (VND or USD) > 0
   - **proof_urls REQUIRED** (không empty)

2. **Create order record** (status = 'completed' ngay):
   ```sql
   INSERT INTO currency_orders (
       order_type, status, order_number,
       currency_attribute_id, quantity,
       unit_price_vnd, unit_price_usd, total_price_vnd,
       game_code, league_attribute_id,
       customer_name,  -- Store supplier_name here
       delivery_info,  -- Store supplier_contact here
       assigned_account_id,
       proof_urls,
       created_by, created_at,
       assigned_at, started_at, completed_at  -- All = NOW()
   ) VALUES (
       'PURCHASE', 'completed', generate_po_number(),
       p_currency_attribute_id, p_quantity,
       p_unit_price_vnd, p_unit_price_usd, p_quantity * p_unit_price_vnd,
       p_game_code, p_league_attribute_id,
       p_supplier_name,
       p_supplier_contact,
       p_game_account_id,
       p_proof_urls,
       get_current_profile_id(), NOW(),
       NOW(), NOW(), NOW()  -- Skip intermediate states
   )
   ```

3. **Create currency transaction & update inventory** (same transaction):
   ```sql
   INSERT INTO currency_transactions (
       transaction_type,
       game_account_id,
       currency_attribute_id,
       quantity,
       unit_price_vnd,
       game_code,
       league_attribute_id,
       order_id,  -- Link to purchase order
       proof_urls,
       created_by
   ) VALUES (
       'purchase',
       p_game_account_id,
       p_currency_attribute_id,
       p_quantity,  -- Positive = add to inventory
       p_unit_price_vnd,
       p_game_code,
       p_league_attribute_id,
       <new_order_id>,
       p_proof_urls,
       get_current_profile_id()
   )
   ```

4. **Update inventory view** (via trigger or materialized view refresh)

5. **Return success with new balance**:
   ```sql
   SELECT
       SUM(quantity) as new_balance
   FROM currency_transactions
   WHERE game_account_id = p_game_account_id
     AND currency_attribute_id = p_currency_attribute_id
     AND league_attribute_id = p_league_attribute_id
   ```

**Key Differences from SELL:**
| Feature | SELL (Multi-step) | PURCHASE (One-shot) |
|---------|------------------|---------------------|
| Workflow | pending → assigned → in_progress → completed | Create → completed (skip all) |
| Proof | Optional (at completion) | **REQUIRED** (at creation) |
| Supplier/Customer | Customer (FK to parties optional) | Supplier (plain text, no FK) |
| Account | Optional (assigned later by OPS) | **REQUIRED** (must specify upfront) |
| Exchange info | Yes (items/service/farmer) | No (simple buy) |
| Status transitions | 4 steps (manual) | 0 steps (auto) |
| Inventory update | At complete step | At creation (same transaction) |
| Cancel | Yes (common) | Rare (but still possible) |

**Why One-Shot?**
- ✅ **Simple workflow**: Trader2 đã có đầy đủ info khi tạo
- ✅ **No coordination**: Không cần OPS assign/start/complete
- ✅ **Immediate inventory**: Currency available ngay lập tức
- ✅ **Less bugs**: Fewer state transitions = fewer edge cases
- ⚠️ **Can still cancel**: Nếu cần rollback (edge case)

---

## 3️⃣ `get_currency_sell_orders_v1`

**Purpose:** Query SELL orders with filters

**Parameters:**
```sql
CREATE OR REPLACE FUNCTION get_currency_sell_orders_v1(
    p_status TEXT DEFAULT NULL,                  -- Filter by status
    p_game_code TEXT DEFAULT NULL,               -- Filter by game
    p_customer_name TEXT DEFAULT NULL,           -- Search by customer
    p_date_from TIMESTAMPTZ DEFAULT NULL,        -- Date range start
    p_date_to TIMESTAMPTZ DEFAULT NULL,          -- Date range end
    p_limit INT DEFAULT 50,
    p_offset INT DEFAULT 0
) RETURNS TABLE(...)
```

**Returns:** Array of orders with full details:
```json
[
  {
    "order_id": "uuid",
    "order_number": "SO-20250112-001",
    "order_type": "SELL",
    "status": "pending",
    "currency_name": "Chaos Orb",
    "quantity": 100,
    "unit_price_vnd": 1500,
    "total_price_vnd": 150000,
    "customer_name": "John Doe",
    "customer_game_tag": "JohnGamer",
    "delivery_info": "Discord: john#1234",
    "channel_code": "G2G_CURRENCY",
    "exchange_type": "items",
    "exchange_details": { "item": "Ring of Power" },
    "assigned_account_name": "Account #1",
    "created_at": "2025-01-12T10:00:00Z",
    "created_by_name": "Sales Agent",
    "completed_at": null
  }
]
```

**Sorting:**
- Default: `created_at DESC` (newest first)
- Status priority: `pending` > `assigned` > `in_progress` > `completed`

---

## 4️⃣ `get_currency_purchase_orders_v1`

**Purpose:** Query PURCHASE orders with filters

**Parameters:**
```sql
CREATE OR REPLACE FUNCTION get_currency_purchase_orders_v1(
    p_status TEXT DEFAULT NULL,
    p_game_code TEXT DEFAULT NULL,
    p_supplier_name TEXT DEFAULT NULL,           -- Search by supplier
    p_date_from TIMESTAMPTZ DEFAULT NULL,
    p_date_to TIMESTAMPTZ DEFAULT NULL,
    p_limit INT DEFAULT 50,
    p_offset INT DEFAULT 0
) RETURNS TABLE(...)
```

**Returns:** Similar to `get_currency_sell_orders_v1` but with supplier info instead of customer

**Differences from SELL query:**
- Has `supplier_name` instead of `customer_name`
- No exchange info
- Always has `assigned_account_id`

---

## 5️⃣ `assign_currency_order_v1`

**Purpose:** OPS assigns order to a game account (for SELL orders mainly)

**Parameters:**
```sql
CREATE OR REPLACE FUNCTION assign_currency_order_v1(
    p_order_id UUID,
    p_game_account_id UUID,
    p_assignment_notes TEXT DEFAULT NULL
) RETURNS JSONB
```

**Returns:**
```json
{
  "success": true,
  "order_id": "uuid",
  "new_status": "assigned",
  "assigned_account": "Account #1"
}
```

**Business Logic:**
1. Validate order exists and status = `pending`
2. Validate game account exists and is active
3. Check inventory availability on that account (optional)
4. Update `assigned_account_id = p_game_account_id`
5. Update `status = 'assigned'`
6. Update `assigned_at = NOW()`
7. Update `assigned_by = current_user_profile_id()`
8. Append to `history_log` JSONB

**Permissions:**
- Required: `currency_orders:assign` permission
- Context: Must match `game_code`

---

## 6️⃣ `start_currency_order_v1`

**Purpose:** OPS starts processing the order (begins trade/delivery)

**Parameters:**
```sql
CREATE OR REPLACE FUNCTION start_currency_order_v1(
    p_order_id UUID,
    p_start_notes TEXT DEFAULT NULL
) RETURNS JSONB
```

**Returns:**
```json
{
  "success": true,
  "order_id": "uuid",
  "new_status": "in_progress",
  "started_at": "2025-01-12T10:30:00Z"
}
```

**Business Logic:**
1. Validate status = `assigned`
2. Update `status = 'in_progress'`
3. Update `started_at = NOW()`
4. Update `started_by = current_user_profile_id()`

**Use Case:**
- OPS clicks "Start Order" when ready to trade
- Inventory is reserved at this point (optional)

---

## 7️⃣ `complete_currency_order_v1`

**Purpose:** OPS marks order as completed after successful delivery

**Parameters:**
```sql
CREATE OR REPLACE FUNCTION complete_currency_order_v1(
    p_order_id UUID,
    p_completion_notes TEXT DEFAULT NULL,
    p_proof_urls TEXT[] DEFAULT NULL,            -- Screenshot URLs
    p_actual_quantity NUMERIC DEFAULT NULL,      -- If different from planned
    p_actual_unit_price_vnd NUMERIC DEFAULT NULL -- If price changed
) RETURNS JSONB
```

**Returns:**
```json
{
  "success": true,
  "order_id": "uuid",
  "new_status": "completed",
  "transaction_id": "uuid",
  "inventory_updated": true
}
```

**Business Logic:**
1. Validate status = `in_progress`
2. Update `status = 'completed'`
3. Update `completed_at = NOW()`
4. Update `completed_by = current_user_profile_id()`
5. Store `proof_urls` array
6. **Create currency transaction** in `currency_transactions` table:
   - Type: `sale_delivery` (SELL) or `purchase` (PURCHASE)
   - Update inventory accordingly
7. Calculate actual profit/loss
8. Update `actual_quantity` and `actual_unit_price_vnd` if provided

**Inventory Impact:**
- **SELL order**: Deduct from inventory (`-quantity`)
- **PURCHASE order**: Add to inventory (`+quantity`)

---

## 8️⃣ `cancel_currency_order_v1`

**Purpose:** Cancel order at any stage

**Parameters:**
```sql
CREATE OR REPLACE FUNCTION cancel_currency_order_v1(
    p_order_id UUID,
    p_cancel_reason TEXT
) RETURNS JSONB
```

**Returns:**
```json
{
  "success": true,
  "order_id": "uuid",
  "new_status": "cancelled",
  "previous_status": "pending"
}
```

**Business Logic:**
1. Validate order exists
2. Validate status NOT IN (`completed`, `cancelled`)
3. Store previous status
4. Update `status = 'cancelled'`
5. Update `cancelled_at = NOW()`
6. Update `cancelled_by = current_user_profile_id()`
7. Store `cancel_reason`
8. If inventory was reserved, release it

**Permissions:**
- Can cancel own orders: Any creator
- Can cancel any order: `currency_orders:cancel_any`

---

## 🔐 Permissions Matrix

| Function | Permission Required | Context Check |
|----------|-------------------|---------------|
| `create_currency_sell_order_v1` | `currency_orders:create_sell` | game_code |
| `create_currency_purchase_order_v1` | `currency_orders:create_purchase` | game_code |
| `get_currency_sell_orders_v1` | `currency_orders:view` | game_code |
| `get_currency_purchase_orders_v1` | `currency_orders:view` | game_code |
| `assign_currency_order_v1` | `currency_orders:assign` | game_code |
| `start_currency_order_v1` | `currency_orders:process` | game_code |
| `complete_currency_order_v1` | `currency_orders:complete` | game_code |
| `cancel_currency_order_v1` | `currency_orders:cancel` OR is creator | game_code |

---

## 🎬 Status Flow Diagram

```
SELL Order (Multi-step workflow):
pending → [assign] → assigned → [start] → in_progress → [complete] → completed
   ↓                    ↓              ↓                       ↓
   └────────────────────┴──────────────┴───────────────────────→ cancelled

PURCHASE Order (One-shot workflow):
[create with proof] → completed ✅
         ↓
         └──→ cancelled (rare)

(All intermediate states auto-passed in same transaction)
```

**Comparison:**
| Workflow | SELL | PURCHASE |
|----------|------|----------|
| States | 5 (pending → assigned → in_progress → completed → cancelled) | 2 (completed, cancelled) |
| User actions | 4 (create, assign, start, complete) | 1 (create) |
| Time to inventory | ~hours/days (manual steps) | ~seconds (immediate) |

---

## 📝 Testing Checklist

Use the test queries from [CURRENCY-IMPLEMENTATION-PLAN.md Section 1.3](./CURRENCY-IMPLEMENTATION-PLAN.md#13-database-testing-checklist)

**Test Coverage:**
- [ ] Create SELL order (Test 1)
- [ ] Get SELL orders list (Test 2)
- [ ] Assign order (Test 3)
- [ ] Start order (Test 4)
- [ ] Complete order (Test 5)
- [ ] Create PURCHASE order (Test 6)
- [ ] Get PURCHASE orders list (Test 7)
- [ ] Cancel order (Test 8)
- [ ] Permission checks (all functions)
- [ ] Inventory updates (complete function)
- [ ] Audit logs (all functions)

---

## 🚀 Implementation Priority

**Phase 1 (MVP - Week 1)**:
1. ✅ `create_currency_sell_order_v1` (CRITICAL)
2. ✅ `get_currency_sell_orders_v1` (CRITICAL)
3. ✅ `assign_currency_order_v1` (HIGH)
4. ✅ `complete_currency_order_v1` (HIGH)

**Phase 2 (Full - Week 2)**:
5. ✅ `start_currency_order_v1` (MEDIUM)
6. ✅ `cancel_currency_order_v1` (MEDIUM)
7. ✅ `create_currency_purchase_order_v1` (LOW)
8. ✅ `get_currency_purchase_orders_v1` (LOW)

---

**Last Updated:** 2025-01-12
**Next Review:** After Phase 1 implementation
