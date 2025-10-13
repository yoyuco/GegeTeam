# 🚀 CURRENCY ORDERS IMPLEMENTATION PLAN
**Version:** 2.0 (Updated based on existing code analysis)
**Ngày:** 2025-01-12
**Timeline:** 2-3 weeks
**Priority:** High

---

## 📋 EXECUTIVE SUMMARY

Bản kế hoạch này trình bày detailed implementation steps cho việc triển khai Currency Orders System dựa trên thiết kế trong `CURRENCY-ORDERS-DESIGN.md`.

### 🎯 Objectives:
1. ✅ **Unified System**: Mua, bán, exchange trong cùng 1 workflow
2. ✅ **Business Process Alignment**: Phù hợp với sales/ops workflow thực tế
3. ✅ **Production Ready**: Deployment an toàn lên production
4. ✅ **Scalable**: Foundation cho future enhancements

---

## 🔍 CURRENT STATUS ANALYSIS (2025-01-12)

### ✅ Frontend Foundation (Already Implemented)
- **Pages**: `CurrencySell.vue` (70% complete)
- **Components**: `CurrencyForm.vue`, `CustomerForm.vue`, `GameLeagueSelector.vue`, `CurrencyInventoryPanel.vue`
- **Composables**: `useCurrency.js` (has legacy RPC functions), `useGameContext.js`, `useInventory.js`, `usePoeCurrencies.js`

### ❌ Missing Components (Need to Build)
- **Database**: `currency_orders` table + RPC functions (BLOCKING)
- **Pages**: `CurrencyPurchase.vue`, `CurrencyOps.vue`
- **Components**: `CurrencyOrdersList.vue`, `CurrencyOrderDetails.vue`, `SupplierForm.vue`
- **Composables**: `useCurrencyOrders.js` (NEW - for unified workflow)

---

## 🗄️ PHẦN 1: DATABASE IMPLEMENTATION

### 1.1 Migration Files Creation

#### ✅ File 1: `20251013010000_create_currency_orders_table.sql`
**Status:** ✅ CREATED
**Timeline:** Day 1
**Priority:** Critical
**Dependencies:** None

**Contents:**
- 3 ENUMs: `currency_order_type_enum`, `currency_order_status_enum`, `currency_exchange_type_enum`
- Main `currency_orders` table (30+ columns)
- 8 performance indexes
- Trigger for `updated_at` timestamp
- Helper function: `generate_currency_order_number()`
- Links to `currency_transactions` table (adds `order_id` column)
- 3 RLS policies
- Documentation comments

**Location:** `supabase/migrations/20251013010000_create_currency_orders_table.sql`

---

#### ✅ File 2: `20251013020000_create_currency_order_rpc_functions.sql`
**Status:** ✅ CREATED
**Timeline:** Day 1
**Priority:** Critical
**Dependencies:** `20251013010000_create_currency_orders_table.sql`

**Contents:**
- Helper function: `get_current_profile_id()`
- RPC function: `create_currency_sell_order_v1()` (14 parameters)
- RPC function: `create_currency_purchase_order_v1()` (11 parameters, ONE-SHOT workflow)
- Permission grants
- Documentation comments

**Key Features:**
- **SELL workflow:** Creates order with status='pending', waits for OPS
- **PURCHASE workflow:** ONE-SHOT - creates with proof, auto-completes, updates inventory immediately

**Location:** `supabase/migrations/20251013020000_create_currency_order_rpc_functions.sql`

---

#### ✅ File 3: `20251013030000_create_sell_order_workflow_functions.sql`
**Status:** ✅ CREATED
**Timeline:** Day 2
**Priority:** Critical
**Dependencies:** `20251013020000_create_currency_order_rpc_functions.sql`

**Contents:**
- RPC function: `assign_currency_order_v1()` - pending → assigned
- RPC function: `start_currency_order_v1()` - assigned → in_progress
- RPC function: `complete_currency_order_v1()` - in_progress → completed (updates inventory)
- Permission grants
- Documentation comments

**Workflow Summary:**
```
SELL Order Flow:
1. Sales creates → pending
2. OPS assigns → assigned
3. OPS starts → in_progress
4. OPS completes → completed (inventory updated)
```

**Location:** `supabase/migrations/20251013030000_create_sell_order_workflow_functions.sql`

---

#### ✅ File 4: `20251013040000_create_cancel_and_query_functions.sql`
**Status:** ✅ CREATED
**Timeline:** Day 2
**Priority:** Critical
**Dependencies:** `20251013030000_create_sell_order_workflow_functions.sql`

**Contents:**
- RPC function: `cancel_currency_order_v1()` - Cancel with rollback for PURCHASE orders
- RPC function: `get_currency_sell_orders_v1()` - Query SELL orders with filters
- RPC function: `get_currency_purchase_orders_v1()` - Query PURCHASE orders with filters
- Permission grants
- Documentation comments

**Location:** `supabase/migrations/20251013040000_create_cancel_and_query_functions.sql`

---

### 📊 Migration Summary

| File | Purpose | RPC Functions | Status |
|------|---------|--------------|---------|
| `20251013010000_...` | Create table structure | 2 helpers | ✅ Ready |
| `20251013020000_...` | Create/Purchase orders | 2 main | ✅ Ready |
| `20251013030000_...` | SELL workflow | 3 workflow | ✅ Ready |
| `20251013040000_...` | Cancel & Query | 3 query | ✅ Ready |

**Total:** 4 migration files, 10 functions (8 RPC + 2 helpers), **100% complete**

**Next Step:** Test migrations on local database (see section 1.3)

### 1.2 Data Migration Strategy

#### 🔄 Current Data Handling:
```sql
-- Check for existing currency data
SELECT
    'orders' as table_name,
    COUNT(*) as record_count,
    MAX(created_at) as latest_date
FROM orders
WHERE currency_id IS NOT NULL;

-- Check for existing currency_transactions
SELECT
    'currency_transactions' as table_name,
    COUNT(*) as record_count,
    MAX(created_at) as latest_date
FROM currency_transactions;

-- Decision: NO migration needed (fresh implementation)
```

### 1.3 Database Testing Checklist

```sql
-- ============================================================
-- Test 1: Create SELL order (Sales workflow)
-- ============================================================
SELECT * FROM create_currency_sell_order_v1(
    p_currency_attribute_id := (SELECT id FROM attributes WHERE name = 'Chaos Orb' LIMIT 1),
    p_quantity := 100,
    p_unit_price_vnd := 1500,
    p_unit_price_usd := 0.058,
    p_game_code := 'POE_2',
    p_league_attribute_id := (SELECT id FROM attributes WHERE name = 'EA Standard' AND type = 'POE2_LEAGUE' LIMIT 1),
    p_customer_name := 'Test Customer',
    p_customer_game_tag := 'TestCharacter',
    p_delivery_info := 'Discord: test#1234',
    p_channel_id := (SELECT id FROM channels WHERE code = 'G2G_CURRENCY' LIMIT 1),
    p_exchange_type := NULL,
    p_exchange_details := NULL,
    p_exchange_images := NULL,
    p_sales_notes := 'Test sell order'
);
-- Expected: { success: true, order_id: <uuid>, order_number: 'SO-...' }

-- ============================================================
-- Test 2: Get SELL orders list
-- ============================================================
SELECT * FROM get_currency_sell_orders_v1(
    p_status := 'pending',
    p_game_code := 'POE_2',
    p_customer_name := NULL,
    p_date_from := CURRENT_DATE - INTERVAL '7 days',
    p_date_to := CURRENT_DATE,
    p_limit := 10,
    p_offset := 0
);
-- Expected: Array of sell orders with status 'pending'

-- ============================================================
-- Test 3: Assign order to account (OPS)
-- ============================================================
SELECT * FROM assign_currency_order_v1(
    p_order_id := '<order-id-from-test-1>',
    p_game_account_id := (SELECT id FROM game_accounts WHERE game_code = 'POE_2' AND purpose = 'CURRENCY_SALES' LIMIT 1),
    p_assignment_notes := 'Assigned to Account #1'
);
-- Expected: { success: true, new_status: 'assigned' }

-- ============================================================
-- Test 4: Start processing order
-- ============================================================
SELECT * FROM start_currency_order_v1(
    p_order_id := '<order-id-from-test-3>',
    p_start_notes := 'Started processing'
);
-- Expected: { success: true, new_status: 'in_progress' }

-- ============================================================
-- Test 5: Complete order
-- ============================================================
SELECT * FROM complete_currency_order_v1(
    p_order_id := '<order-id-from-test-4>',
    p_completion_notes := 'Trade completed successfully',
    p_proof_urls := ARRAY['https://imgur.com/proof1.jpg', 'https://imgur.com/proof2.jpg'],
    p_actual_quantity := 100,
    p_actual_unit_price_vnd := 1500
);
-- Expected: { success: true, new_status: 'completed', transaction_id: <uuid> }

-- ============================================================
-- Test 6: Create PURCHASE order
-- ============================================================
SELECT * FROM create_currency_purchase_order_v1(
    p_currency_attribute_id := (SELECT id FROM attributes WHERE name = 'Chaos Orb' LIMIT 1),
    p_quantity := 500,
    p_unit_price_vnd := 1200,
    p_unit_price_usd := 0.047,
    p_game_code := 'POE_2',
    p_league_attribute_id := (SELECT id FROM attributes WHERE name = 'EA Standard' AND type = 'POE2_LEAGUE' LIMIT 1),
    p_supplier_party_id := (SELECT id FROM parties WHERE type = 'supplier' LIMIT 1),
    p_game_account_id := (SELECT id FROM game_accounts WHERE game_code = 'POE_2' LIMIT 1),
    p_sales_notes := 'Bulk purchase from Supplier A'
);
-- Expected: { success: true, order_id: <uuid>, order_number: 'PO-...' }

-- ============================================================
-- Test 7: Get PURCHASE orders list
-- ============================================================
SELECT * FROM get_currency_purchase_orders_v1(
    p_status := NULL,  -- Get all statuses
    p_game_code := 'POE_2',
    p_supplier_name := NULL,
    p_date_from := CURRENT_DATE - INTERVAL '30 days',
    p_date_to := CURRENT_DATE,
    p_limit := 10,
    p_offset := 0
);
-- Expected: Array of purchase orders

-- ============================================================
-- Test 8: Cancel order
-- ============================================================
SELECT * FROM cancel_currency_order_v1(
    p_order_id := '<any-order-id>',
    p_cancel_reason := 'Customer cancelled the order'
);
-- Expected: { success: true, new_status: 'cancelled' }
```

---

## 💻 PHẦN 2: BACKEND IMPLEMENTATION

### 2.1 Create New Composable: `useCurrencyOrders.js`

**Status**: ❌ Chưa có (cần tạo mới)
**Timeline**: Day 3
**Priority**: 🔴 CRITICAL (blocking cho tất cả pages)

#### 📁 File: `src/composables/useCurrencyOrders.js`

**Mục đích**: Composable mới để handle toàn bộ Currency Orders workflow theo design mới.

```javascript
// New composable for unified currency orders workflow
// Replaces legacy createSellOrder/recordPurchase in useCurrency.js

import { ref } from 'vue'
import { supabase } from '@/lib/supabase'

export function useCurrencyOrders() {
  const loading = ref(false)
  const error = ref(null)
  const orders = ref([])

  // ============================================================
  // SALES WORKFLOW (CurrencySell.vue)
  // ============================================================

  /**
   * Create SALE order (draft mode)
   * Used in: CurrencySell.vue
   */
  const createSaleOrder = async (orderData) => {
    loading.value = true
    try {
      const { data, error } = await supabase.rpc('create_currency_sell_order_v1', {
        p_currency_attribute_id: orderData.currencyId,
        p_quantity: orderData.quantity,
        p_unit_price_vnd: orderData.unitPriceVnd,
        p_unit_price_usd: orderData.unitPriceUsd || 0,
        p_game_code: orderData.gameCode,
        p_league_attribute_id: orderData.leagueId,
        p_customer_name: orderData.customerName,
        p_customer_game_tag: orderData.gameTag,
        p_delivery_info: orderData.deliveryInfo,
        p_channel_id: orderData.channelId,
        p_exchange_type: orderData.exchangeType,       // 'items', 'service', 'farmer', null
        p_exchange_details: orderData.exchangeDetails,  // JSONB details
        p_exchange_images: orderData.exchangeImages,    // text[]
        p_sales_notes: orderData.notes
      })

      if (error) throw error
      return { success: true, order_id: data.order_id }
    } catch (err) {
      error.value = err.message
      throw err
    } finally {
      loading.value = false
    }
  }

  // ============================================================
  // PURCHASE WORKFLOW (CurrencyPurchase.vue)
  // ============================================================

  /**
   * Create PURCHASE order (ONE-SHOT: Auto-complete + Inventory update)
   * Used in: CurrencyPurchase.vue
   *
   * This is SIMPLIFIED workflow:
   * - Trader2 nhập đầy đủ info + proof
   * - Function auto-completes order & updates inventory
   * - No manual assign/start/complete steps needed
   */
  const createPurchaseOrder = async (orderData) => {
    loading.value = true
    try {
      const { data, error } = await supabase.rpc('create_currency_purchase_order_v1', {
        // Basic info
        p_currency_attribute_id: orderData.currencyId,
        p_quantity: orderData.quantity,
        p_unit_price_vnd: orderData.unitPriceVnd,
        p_unit_price_usd: orderData.unitPriceUsd || 0,
        p_game_code: orderData.gameCode,
        p_league_attribute_id: orderData.leagueId,
        p_game_account_id: orderData.gameAccountId,  // REQUIRED

        // Supplier info (simple text, no FK)
        p_supplier_name: orderData.supplierName,     // REQUIRED
        p_supplier_contact: orderData.supplierContact, // Optional (Discord/Telegram)

        // Proof (REQUIRED)
        p_proof_urls: orderData.proofUrls,           // REQUIRED

        // Notes
        p_notes: orderData.notes
      })

      if (error) throw error

      // Return includes inventory balance
      return {
        success: true,
        order_id: data.order_id,
        order_number: data.order_number,
        transaction_id: data.transaction_id,
        new_balance: data.new_balance  // New inventory balance
      }
    } catch (err) {
      error.value = err.message
      throw err
    } finally {
      loading.value = false
    }
  }

  // ============================================================
  // COMMON WORKFLOW ACTIONS
  // ============================================================

  /**
   * Assign order to OPS (pending -> assigned)
   * Used in: CurrencyOps.vue
   */
  const assignOrder = async (orderId, accountId, notes) => {
    const { data, error } = await supabase.rpc('assign_currency_order_v1', {
      p_order_id: orderId,
      p_game_account_id: accountId,
      p_assignment_notes: notes
    })

    if (error) throw error
    return data
  }

  /**
   * Mark order in progress (assigned -> in_progress)
   * Used in: CurrencyOps.vue
   */
  const startOrder = async (orderId, notes) => {
    const { data, error } = await supabase.rpc('start_currency_order_v1', {
      p_order_id: orderId,
      p_start_notes: notes
    })

    if (error) throw error
    return data
  }

  /**
   * Complete order (in_progress -> completed)
   * Used in: CurrencyOps.vue
   */
  const completeOrder = async (orderId, completionData) => {
    const { data, error } = await supabase.rpc('complete_currency_order_v1', {
      p_order_id: orderId,
      p_completion_notes: completionData.notes,
      p_proof_urls: completionData.proofUrls,
      p_actual_quantity: completionData.actualQuantity,
      p_actual_unit_price_vnd: completionData.actualUnitPriceVnd
    })

    if (error) throw error
    return data
  }

  /**
   * Cancel order (any status -> cancelled)
   * Used in: CurrencyOps.vue
   */
  const cancelOrder = async (orderId, reason) => {
    const { data, error } = await supabase.rpc('cancel_currency_order_v1', {
      p_order_id: orderId,
      p_cancel_reason: reason
    })

    if (error) throw error
    return data
  }

  /**
   * Get SELL orders list with filters
   * Used in: CurrencyOps.vue, CurrencySell.vue (history)
   */
  const getSellOrders = async (filters = {}) => {
    const { data, error } = await supabase.rpc('get_currency_sell_orders_v1', {
      p_status: filters.status,
      p_game_code: filters.gameCode,
      p_customer_name: filters.customerName,
      p_date_from: filters.dateFrom,
      p_date_to: filters.dateTo,
      p_limit: filters.limit || 50,
      p_offset: filters.offset || 0
    })

    if (error) throw error
    return data
  }

  /**
   * Get PURCHASE orders list with filters
   * Used in: CurrencyOps.vue, CurrencyPurchase.vue (history)
   */
  const getPurchaseOrders = async (filters = {}) => {
    const { data, error } = await supabase.rpc('get_currency_purchase_orders_v1', {
      p_status: filters.status,
      p_game_code: filters.gameCode,
      p_supplier_name: filters.supplierName,
      p_date_from: filters.dateFrom,
      p_date_to: filters.dateTo,
      p_limit: filters.limit || 50,
      p_offset: filters.offset || 0
    })

    if (error) throw error
    return data
  }

  return {
    // State
    loading,
    error,
    orders,

    // Sales workflow
    createSaleOrder,
    getSellOrders,

    // Purchase workflow
    createPurchaseOrder,
    getPurchaseOrders,

    // OPS workflow actions
    assignOrder,
    startOrder,
    completeOrder,
    cancelOrder
  }
}
```

---

### 📋 RPC Functions Summary Table

| Function Name | Purpose | Status Transition | Used In |
|--------------|---------|-------------------|---------|
| **SELL Orders** |
| `create_currency_sell_order_v1` | Tạo đơn bán | → `pending` | CurrencySell.vue |
| `get_currency_sell_orders_v1` | Lấy danh sách đơn bán | - | CurrencyOps.vue |
| **PURCHASE Orders** |
| `create_currency_purchase_order_v1` | Tạo đơn mua | → `pending` | CurrencyPurchase.vue |
| `get_currency_purchase_orders_v1` | Lấy danh sách đơn mua | - | CurrencyOps.vue |
| **OPS Actions** |
| `assign_currency_order_v1` | OPS nhận đơn & assign account | `pending` → `assigned` | CurrencyOps.vue |
| `start_currency_order_v1` | Bắt đầu xử lý | `assigned` → `in_progress` | CurrencyOps.vue |
| `complete_currency_order_v1` | Hoàn thành đơn hàng | `in_progress` → `completed` | CurrencyOps.vue |
| `cancel_currency_order_v1` | Hủy đơn hàng | `*` → `cancelled` | CurrencyOps.vue |

**Total**: 8 RPC functions (4 SELL + 4 PURCHASE/OPS)
```

### 2.2 Update Existing `useCurrency.js`

**Status**: ✅ Đã có, cần điều chỉnh nhỏ
**Timeline**: Day 3
**Priority**: 🟡 MEDIUM

**Approach**:
- ✅ **GIỮ NGUYÊN** tất cả methods hiện tại (không break existing code)
- ➕ **DEPRECATE** dần: `createSellOrder()`, `recordPurchase()` bằng cách thêm console warning
- 📝 **ADD COMMENT**: Hướng dẫn migrate sang `useCurrencyOrders.js`

```javascript
// In useCurrency.js - Add deprecation warnings

// @deprecated Use useCurrencyOrders.createSaleOrder() instead
const createSellOrder = async (orderData) => {
  console.warn('⚠️ createSellOrder() is deprecated. Use useCurrencyOrders.createSaleOrder()')
  // ... existing implementation
}

// @deprecated Use useCurrencyOrders.createPurchaseOrder() instead
const recordPurchase = async (purchaseData) => {
  console.warn('⚠️ recordPurchase() is deprecated. Use useCurrencyOrders.createPurchaseOrder()')
  // ... existing implementation
}
```

---

## 🎨 PHẦN 3: FRONTEND IMPLEMENTATION

### 3.1 Update `CurrencyForm.vue`

**Status**: ✅ Đã có 90%, cần minor updates
**Timeline**: Day 4
**Priority**: 🟢 LOW (component đã hoạt động tốt)

#### Changes Required:

**Hiện tại component đã có**:
- ✅ Props: `showAccountField`, `transactionType`, `currencies`, `gameAccounts`
- ✅ Validation logic hoàn chỉnh
- ✅ Emits: `currency-changed`, `price-changed`, `quantity-changed`
- ✅ Exposed methods: `resetForm()`, `validateForm()`, `handleSubmit()`, `formData`

**Cần thêm** (optional enhancements):
```javascript
// 1. Add orderType prop mapping (if needed)
interface Props {
  transactionType?: 'purchase' | 'sale' | 'exchange'  // ✅ Already has
  orderType?: 'PURCHASE' | 'SALE'  // ➕ Add alias for backend enum
  // ... existing props
}

// 2. Map transactionType to orderType
const effectiveOrderType = computed(() => {
  if (props.orderType) return props.orderType
  return props.transactionType === 'purchase' ? 'PURCHASE' : 'SALE'
})
```

**Kết luận**: Component này **không cần sửa nhiều**, chỉ cần map props khi dùng.

### 3.2 Update `CurrencySell.vue`

**Status**: ✅ Đã có 70%, cần fix logic
**Timeline**: Day 4-5
**Priority**: 🔴 HIGH

#### Changes Required:

**1. Fix TODO at line 543** (Replace with actual API call):

```javascript
// ❌ BEFORE (line 543):
// TODO: Call the actual API to create sell order
// await createSellOrder(payload)

// ✅ AFTER:
import { useCurrencyOrders } from '@/composables/useCurrencyOrders.js'

const { createSaleOrder, loading: orderLoading } = useCurrencyOrders()

const saveSale = async () => {
  // ... existing validation ...

  saving.value = true
  try {
    // Call the NEW unified API
    const result = await createSaleOrder({
      currencyId: formData.currencyId,
      quantity: formData.quantity,
      unitPriceVnd: formData.unitPriceVnd || 0,
      unitPriceUsd: formData.unitPriceUsd || 0,
      gameCode: currentGame.value,
      leagueId: currentLeague.value,
      customerName: customerFormData.customerName,
      gameTag: customerFormData.gameTag,
      deliveryInfo: customerFormData.deliveryInfo,
      channelId: customerFormData.channelId,
      exchangeType: exchangeData.type !== 'none' ? exchangeData.type : null,
      exchangeDetails: exchangeData.type !== 'none' ? { description: exchangeData.exchangeType } : null,
      exchangeImages: fileList.value.map(f => f.url),  // Get URLs from uploaded files
      notes: formData.notes
    })

    if (result.success) {
      message.success('Tạo đơn bán thành công!')
      handleCurrencyFormReset()
      // ... reset other forms
    }
  } catch (error) {
    console.error('Error saving sale:', error)
    message.error('Đã có lỗi xảy ra khi tạo đơn bán')
  } finally {
    saving.value = false
  }
}
```

**2. Integrate Exchange images with n-upload**:

```javascript
// Watch fileList to sync with exchangeData
watch(fileList, (newFiles) => {
  exchangeData.exchangeImages = newFiles.map(f => f.url || f.thumbUrl)
})
```

**3. Add Submit Order step** (optional - có thể để sau):

```vue
<template>
  <!-- Add after "Tạo Đơn Bán" button -->
  <n-button
    v-if="draftOrderId"
    type="success"
    size="large"
    @click="handleSubmitDraft"
  >
    Submit Đơn Hàng (Chuyển sang OPS)
  </n-button>
</template>
```

---

### 3.3 Create `CurrencyPurchase.vue`

**Status**: ❌ Chưa có (cần tạo mới)
**Timeline**: Day 5-6
**Priority**: 🟡 MEDIUM

**Approach**: **COPY** 80% từ `CurrencySell.vue` và modify

#### Structure (tương tự CurrencySell.vue):

```vue
<!-- src/pages/CurrencyPurchase.vue -->
<template>
  <div class="min-h-screen bg-gray-50 p-6">
    <!-- Header (màu GREEN thay vì BLUE) -->
    <div class="bg-gradient-to-r from-green-600 to-emerald-600 text-white p-6 rounded-xl">
      <h1>Tạo đơn MUA Currency</h1>
      <p>{{ contextString }}</p>
    </div>

    <!-- Game & League Selector (GIỐNG CurrencySell) -->
    <GameLeagueSelector ... />

    <!-- 2-Column Layout -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <!-- LEFT: Supplier Information (THAY THẾ CustomerForm) -->
      <div class="bg-white rounded-xl shadow-sm">
        <h2>Thông tin Nhà cung cấp</h2>
        <SupplierForm v-model="supplierData" />
      </div>

      <!-- RIGHT: Currency Information (GIỐNG CurrencySell) -->
      <div class="bg-white rounded-xl shadow-sm">
        <h2>Thông tin Currency</h2>
        <CurrencyForm
          ref="currencyFormRef"
          :show-account-field="true"  <!-- BẮT BUỘC chọn account -->
          :transaction-type="'purchase'"
          :currencies="filteredCurrencies"
          @currency-changed="onCurrencyChanged"
          @quantity-changed="onQuantityChanged"
          @price-changed="onPriceChanged"
        />
      </div>
    </div>

    <!-- NO Exchange Section (Purchase không cần) -->

    <!-- Action Buttons -->
    <div class="mt-6 flex justify-end gap-3">
      <n-button @click="handleReset">Làm mới</n-button>
      <n-button
        type="primary"
        :loading="saving"
        @click="handleCreatePurchase"
      >
        Tạo Đơn Mua
      </n-button>
    </div>
  </div>
</template>

<script setup>
import { useCurrencyOrders } from '@/composables/useCurrencyOrders.js'
import SupplierForm from '@/components/SupplierForm.vue'  // NEW component

const { createPurchaseOrder } = useCurrencyOrders()

const supplierData = reactive({
  supplierId: null,
  supplierName: '',
  contactInfo: ''
})

const handleCreatePurchase = async () => {
  // Validation
  if (!currencyFormRef.value || !supplierData.supplierId) {
    message.error('Vui lòng điền đầy đủ thông tin')
    return
  }

  saving.value = true
  try {
    const result = await createPurchaseOrder({
      currencyId: formData.currencyId,
      quantity: formData.quantity,
      unitPriceVnd: formData.unitPriceVnd,
      unitPriceUsd: formData.unitPriceUsd,
      gameCode: currentGame.value,
      leagueId: currentLeague.value,
      supplierPartyId: supplierData.supplierId,
      gameAccountId: formData.gameAccountId,  // REQUIRED for purchase
      notes: formData.notes
    })

    if (result.success) {
      message.success('Tạo đơn mua thành công!')
      handleReset()
    }
  } catch (error) {
    message.error('Không thể tạo đơn mua')
  } finally {
    saving.value = false
  }
}
</script>
```

**New Component Required**: `SupplierForm.vue`

```vue
<!-- src/components/SupplierForm.vue -->
<template>
  <div class="space-y-4">
    <!-- Supplier Select (autocomplete from parties table) -->
    <n-select
      v-model:value="formData.supplierId"
      :options="supplierOptions"
      filterable
      placeholder="Chọn nhà cung cấp"
      @update:value="handleSupplierChange"
    />

    <!-- Quick Add New Supplier -->
    <n-input
      v-if="!formData.supplierId"
      v-model:value="newSupplierName"
      placeholder="Hoặc nhập tên NCC mới"
    />

    <!-- Contact Info -->
    <n-input
      v-model:value="formData.contactInfo"
      placeholder="Thông tin liên hệ (optional)"
    />
  </div>
</template>

<script setup>
// Load suppliers from parties table (type = 'supplier')
</script>
```

#### 📁 File: `src/pages/CurrencyOps.vue`
```vue
<!-- New page for operations team -->
<!-- Timeline: Day 6 -->
<!-- Priority: High -->

<template>
  <div class="min-h-screen bg-gray-50 p-6">
    <!-- Header -->
    <div class="mb-6">
      <div class="bg-gradient-to-r from-purple-600 to-indigo-600 text-white p-6 rounded-xl">
        <h1 class="text-2xl font-bold">Currency Operations</h1>
        <p class="text-purple-100 mt-1">Xử lý đơn hàng currency</p>
      </div>
    </div>

    <!-- Filters -->
    <div class="mb-6 bg-white rounded-lg p-4">
      <CurrencyOrderFilters @filter-change="handleFilterChange" />
    </div>

    <!-- Orders List -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <!-- Orders List -->
      <div class="lg:col-span-2">
        <CurrencyOrdersList
          :orders="orders"
          :loading="loading"
          @order-selected="handleOrderSelected"
        />
      </div>

      <!-- Order Details -->
      <div>
        <CurrencyOrderDetails
          v-if="selectedOrder"
          :order="selectedOrder"
          @process="handleProcessOrder"
          @complete="handleCompleteOrder"
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import CurrencyOrdersList from '@/components/currency/CurrencyOrdersList.vue'
import CurrencyOrderDetails from '@/components/currency/CurrencyOrderDetails.vue'
import CurrencyOrderFilters from '@/components/currency/CurrencyOrderFilters.vue'
import { useCurrencyOrders } from '@/composables/useCurrencyOrders.js'

const { getOrders, processOrder, completeOrder } = useCurrencyOrders()
// ... implementation
</script>
```

### 3.3 New Components

#### 📁 File: `src/components/currency/CurrencyOrdersList.vue`
```vue
<!-- Component for displaying orders list -->
<!-- Timeline: Day 6 -->
<!-- Priority: Medium -->

<template>
  <div class="bg-white rounded-lg shadow">
    <div class="p-4 border-b">
      <h3 class="font-semibold">Danh sách đơn hàng</h3>
    </div>

    <div class="divide-y">
      <div
        v-for="order in orders"
        :key="order.id"
        class="p-4 hover:bg-gray-50 cursor-pointer"
        @click="$emit('order-selected', order)"
      >
        <div class="flex justify-between items-start">
          <div>
            <div class="font-medium">{{ order.order_number }}</div>
            <div class="text-sm text-gray-600">{{ order.customer_name }}</div>
            <div class="text-sm">{{ order.currency_name }} x{{ order.quantity }}</div>
          </div>
          <div class="text-right">
            <div class="font-medium">{{ formatCurrency(order.total_price_vnd) }} ₫</div>
            <div class="text-sm">
              <span :class="getStatusClass(order.status)">
                {{ getStatusText(order.status) }}
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
```

#### 📁 File: `src/components/currency/CurrencyOrderDetails.vue`
```vue
<!-- Component for order details and actions -->
<!-- Timeline: Day 6 -->
<!-- Priority: Medium -->

<template>
  <div class="bg-white rounded-lg shadow">
    <div class="p-4 border-b">
      <h3 class="font-semibold">Chi tiết đơn hàng</h3>
    </div>

    <div class="p-4">
      <!-- Order Information -->
      <div class="mb-4">
        <h4 class="font-medium mb-2">Thông tin đơn hàng</h4>
        <div class="text-sm space-y-1">
          <div>Mã đơn: {{ order.order_number }}</div>
          <div>Loại: {{ getOrderTypeText(order.order_type) }}</div>
          <div>Trạng thái: {{ getStatusText(order.status) }}</div>
          <div>Khách: {{ order.customer_name }}</div>
          <div>Currency: {{ order.currency_name }} x{{ order.quantity }}</div>
          <div>Tổng: {{ formatCurrency(order.total_price_vnd) }} ₫</div>
        </div>
      </div>

      <!-- Actions -->
      <div v-if="canProcess" class="space-y-2">
        <n-button @click="handleProcess" type="primary" block>
          Nhận đơn hàng
        </n-button>
      </div>

      <div v-if="canComplete" class="space-y-2">
        <n-button @click="handleComplete" type="success" block>
          Hoàn thành đơn hàng
        </n-button>
      </div>
    </div>
  </div>
</template>
```

### 3.4 Update CurrencySell.vue

#### 🔄 Fix the TODO issue:
```javascript
// Timeline: Day 7
// Priority: Critical

// In CurrencySell.vue, replace the TODO section:
const saveSale = async () => {
  // ... existing validation code ...

  saving.value = true
  try {
    // Call the actual API
    const result = await createSellOrder(payload)

    if (result.success) {
      message.success('Tạo đơn bán thành công!')

      // Reset forms
      handleCurrencyFormReset()
      Object.assign(customerFormData, {
        channelId: null,
        customerName: '',
        gameTag: '',
        deliveryInfo: '',
      })
      Object.assign(exchangeData, {
        type: 'none',
        exchangeType: '',
        exchangeImages: [],
      })
    } else {
      message.error(result.message || 'Không thể tạo đơn bán')
    }
  } catch (error) {
    console.error('Error saving sale:', error)
    message.error('Đã có lỗi xảy ra khi tạo đơn bán')
  } finally {
    saving.value = false
  }
}
```

---

## 🔄 PHẦN 4: ROUTING & NAVIGATION

### 4.1 Router Updates

#### 📁 File: `src/router/index.js`
```javascript
// Timeline: Day 7
// Priority: High

// Add new routes
{
  path: '/currency/sell',
  name: 'CurrencySell',
  component: () => import('@/pages/CurrencySell.vue'),
  meta: { requiresAuth: true, requiredPermission: 'CURRENCY_SALES' }
},
{
  path: '/currency/purchase',
  name: 'CurrencyPurchase',
  component: () => import('@/pages/CurrencyPurchase.vue'),
  meta: { requiresAuth: true, requiredPermission: 'CURRENCY_PURCHASE' }
},
{
  path: '/currency/ops',
  name: 'CurrencyOps',
  component: () => import('@/pages/CurrencyOps.vue'),
  meta: { requiresAuth: true, requiredPermission: 'CURRENCY_OPS' }
},
{
  path: '/currency/exchange',
  name: 'CurrencyExchange',
  component: () => import('@/pages/CurrencyExchange.vue'),
  meta: { requiresAuth: true, requiredPermission: 'CURRENCY_EXCHANGE' }
}
```

### 4.2 Navigation Updates

#### 📁 File: `src/components/Navigation.vue`
```vue
<!-- Timeline: Day 7 -->
<!-- Priority: Medium -->

<template>
  <nav>
    <!-- Existing navigation items -->

    <!-- Currency Management Section -->
    <div v-if="hasCurrencyPermission" class="currency-section">
      <h3 class="text-sm font-semibold text-gray-600 uppercase tracking-wider mb-2">
        Currency Management
      </h3>

      <router-link
        v-if="hasPermission('CURRENCY_SALES')"
        to="/currency/sell"
        class="nav-item"
        :class="{ active: $route.name === 'CurrencySell' }"
      >
        <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <!-- Sell icon -->
        </svg>
        Bán Currency
      </router-link>

      <router-link
        v-if="hasPermission('CURRENCY_PURCHASE')"
        to="/currency/purchase"
        class="nav-item"
        :class="{ active: $route.name === 'CurrencyPurchase' }"
      >
        <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <!-- Purchase icon -->
        </svg>
        Mua Currency
      </router-link>

      <router-link
        v-if="hasPermission('CURRENCY_OPS')"
        to="/currency/ops"
        class="nav-item"
        :class="{ active: $route.name === 'CurrencyOps' }"
      >
        <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <!-- Operations icon -->
        </svg>
        Operations
      </router-link>

      <router-link
        v-if="hasPermission('CURRENCY_EXCHANGE')"
        to="/currency/exchange"
        class="nav-item"
        :class="{ active: $route.name === 'CurrencyExchange' }"
      >
        <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <!-- Exchange icon -->
        </svg>
        Exchange
      </router-link>
    </div>
  </nav>
</template>
```

---

## 🧪 PHẦN 5: TESTING STRATEGY

### 5.1 Unit Tests

#### 📁 File: `tests/unit/useCurrencyOrders.test.js`
```javascript
// Timeline: Day 8
// Priority: High

import { useCurrencyOrders } from '@/composables/useCurrencyOrders.js'
import { describe, it, expect, vi, beforeEach } from 'vitest'

describe('useCurrencyOrders', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  it('should create sell order successfully', async () => {
    const { createOrder } = useCurrencyOrders()

    const orderData = {
      orderType: 'SALE',
      currencyId: 'test-currency-id',
      quantity: 100,
      unitPriceVnd: 1500,
      gameCode: 'POE_2',
      leagueId: 'test-league-id',
      customerName: 'Test Customer',
      gameTag: 'TestCharacter'
    }

    vi.mocked(supabase.rpc).mockResolvedValue({
      data: { success: true, order_id: 'test-order-id' },
      error: null
    })

    const result = await createOrder(orderData)

    expect(result.success).toBe(true)
    expect(result.order_id).toBe('test-order-id')
  })

  it('should handle create order error', async () => {
    const { createOrder } = useCurrencyOrders()

    vi.mocked(supabase.rpc).mockResolvedValue({
      data: null,
      error: { message: 'Database error' }
    })

    await expect(createOrder({})).rejects.toThrow('Database error')
  })
})
```

### 5.2 Integration Tests

#### 📁 File: `tests/integration/currency-workflow.test.js`
```javascript
// Timeline: Day 9
// Priority: High

import { describe, it, expect, beforeEach } from 'vitest'
import { setupDatabase, cleanupDatabase } from '../helpers/database.js'

describe('Currency Order Workflow', () => {
  beforeEach(async () => {
    await setupDatabase()
  })

  afterEach(async () => {
    await cleanupDatabase()
  })

  it('should complete full sell order workflow', async () => {
    // Step 1: Create order
    const createResult = await createSellOrder(validSellOrderData)
    expect(createResult.success).toBe(true)

    const orderId = createResult.order_id

    // Step 2: Submit order
    const submitResult = await submitOrder(orderId)
    expect(submitResult.success).toBe(true)
    expect(submitResult.next_status).toBe('pending')

    // Step 3: Process order
    const processResult = await processOrder(orderId, processingData)
    expect(processResult.success).toBe(true)
    expect(processResult.inventory_available).toBe(true)

    // Step 4: Complete order
    const completeResult = await completeOrder(orderId, completionData)
    expect(completeResult.success).toBe(true)
    expect(completeResult.transaction_id).toBeDefined()
  })

  it('should handle purchase order workflow', async () => {
    // Similar test for purchase workflow
  })
})
```

### 5.3 E2E Tests

#### 📁 File: `tests/e2e/currency-orders.spec.js`
```javascript
// Timeline: Day 10
// Priority: Medium

import { test, expect } from '@playwright/test'

test.describe('Currency Orders', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/currency/sell')
    await page.waitForLoadState('networkidle')
  })

  test('should create sell order', async ({ page }) => {
    // Fill customer form
    await page.fill('[data-testid="customer-name"]', 'Test Customer')
    await page.fill('[data-testid="game-tag"]', 'TestCharacter')

    // Fill currency form
    await page.selectOption('[data-testid="currency-select"]', 'Chaos Orb')
    await page.fill('[data-testid="quantity"]', '100')
    await page.fill('[data-testid="price-vnd"]', '1500')

    // Submit form
    await page.click('[data-testid="submit-button"]')

    // Verify success message
    await expect(page.locator('.success-message')).toBeVisible()
    await expect(page.locator('.success-message')).toContainText('Tạo đơn bán thành công')
  })

  test('should process order in ops page', async ({ page }) => {
    // Create order first (or use existing test data)

    // Go to ops page
    await page.goto('/currency/ops')

    // Find and process order
    await page.click('[data-testid="order-item"]:first-child')
    await page.click('[data-testid="process-order-button"]')

    // Verify order status changes
    await expect(page.locator('.order-status')).toContainText('assigned')
  })
})
```

---

## 🚀 PHẦN 6: DEPLOYMENT TIMELINE (UPDATED)

### ⚡ Week 1: Database & Core Backend (BLOCKING)
**Status**: ❌ Chưa bắt đầu
**Priority**: 🔴 CRITICAL

- **Day 1**:
  - ✅ Create database migration files
  - ✅ Create `currency_orders` table + enums
  - ✅ Test migrations on local

- **Day 2**:
  - ✅ Create ALL RPC functions (create, submit, process, complete, get)
  - ✅ Create RLS policies
  - ✅ Test RPC functions with Postman/psql

- **Day 3**:
  - ✅ Create `useCurrencyOrders.js` composable
  - ✅ Add deprecation warnings to `useCurrency.js`
  - ✅ Unit test composables

---

### 🎨 Week 2: Frontend Pages & Integration
**Status**: ⚠️ 40% done (CurrencySell.vue exists)
**Priority**: 🟡 HIGH

- **Day 4-5**:
  - ✅ Fix `CurrencySell.vue` TODO (line 543)
  - ✅ Integrate exchange images upload
  - ✅ Test create sale order flow

- **Day 6**:
  - ✅ Create `SupplierForm.vue` component
  - ✅ Create `CurrencyPurchase.vue` page
  - ✅ Test create purchase order flow

- **Day 7**:
  - ✅ Create `CurrencyOps.vue` page skeleton
  - ✅ Create `CurrencyOrdersList.vue` component
  - ✅ Create `CurrencyOrderDetails.vue` component
  - ✅ Integrate getOrders() API

---

### 🧪 Week 3: Testing, Polish & Deployment
**Status**: ❌ Chưa bắt đầu
**Priority**: 🟢 MEDIUM

- **Day 8-9**:
  - ✅ Complete CurrencyOps page (process, complete actions)
  - ✅ Add router entries
  - ✅ Update navigation menu
  - ✅ Integration testing (full workflow)

- **Day 10**:
  - ✅ E2E testing with real data
  - ✅ Fix bugs from testing
  - ✅ Performance optimization

- **Day 11-12**:
  - ✅ Staging deployment
  - ✅ UAT with stakeholders
  - ✅ Production deployment (if approved)

---

## 📊 IMPLEMENTATION PROGRESS TRACKER

### Database (80% complete) ✅
- [x] Migration files created (4 files, 100%)
- [x] `currency_orders` table schema ready
- [x] RPC functions implemented (8 functions)
- [x] RLS policies configured
- [ ] Migrations tested on local database
- [ ] Test data seeded
- [ ] Deployed to staging

### Backend/Composables (10% complete)
- [ ] `useCurrencyOrders.js` created
- [x] `useCurrency.js` exists (needs deprecation warnings)
- [x] `useGameContext.js` ready
- [x] `useInventory.js` ready

### Frontend Pages (30% complete)
- [x] `CurrencySell.vue` (70% done, needs API integration)
- [ ] `CurrencyPurchase.vue` (not started)
- [ ] `CurrencyOps.vue` (not started)

### Frontend Components (60% complete)
- [x] `CurrencyForm.vue` (90% done)
- [x] `CustomerForm.vue` (done)
- [x] `GameLeagueSelector.vue` (done)
- [ ] `SupplierForm.vue` (not started)
- [ ] `CurrencyOrdersList.vue` (not started)
- [ ] `CurrencyOrderDetails.vue` (not started)

### Integration (0% complete)
- [ ] Router configured
- [ ] Navigation menu updated
- [ ] Permissions configured
- [ ] End-to-end workflow tested

---

## 📊 PHẦN 7: SUCCESS METRICS

### 7.1 Technical Metrics
- ✅ All RPC functions working correctly
- ✅ Database performance < 200ms for queries
- ✅ Frontend build without errors
- ✅ 100% test coverage for critical paths

### 7.2 Business Metrics
- ✅ Orders created successfully
- ✅ Workflow completion rate > 95%
- ✅ Processing time < 5 minutes per order
- ✅ User satisfaction > 4.5/5

### 7.3 Operational Metrics
- ✅ Zero data loss during migration
- ✅ All roles can access appropriate functions
- ✅ Audit trail complete for all transactions
- ✅ Error rate < 1%

---

## 🔍 PHẦN 8: RISK MITIGATION

### 8.1 Technical Risks
- **Risk**: Database migration failures
  - **Mitigation**: Full backup, rollback scripts, staging testing

- **Risk**: Performance issues with large datasets
  - **Mitigation**: Proper indexing, query optimization, caching

- **Risk**: Permission conflicts
  - **Mitigation**: Detailed RLS testing, role-based access validation

### 8.2 Business Risks
- **Risk**: User adoption issues
  - **Mitigation**: Training materials, user guides, support

- **Risk**: Workflow disruption
  - **Mitigation**: Gradual rollout, parallel running, fallback procedures

### 8.3 Operational Risks
- **Risk**: Data inconsistency
  - **Mitigation**: Transaction handling, validation rules, audit logs

- **Risk**: System downtime
  - **Mitigation**: Blue-green deployment, monitoring, rollback procedures

---

## ✅ PHẦN 9: IMPLEMENTATION CHECKLIST

### Database
- [ ] Create migration files
- [ ] Test migrations on staging
- [ ] Validate data integrity
- [ ] Performance test queries

### Backend
- [ ] Implement RPC functions
- [ ] Create composables
- [ ] Add service layer
- [ ] Write unit tests

### Frontend
- [ ] Update CurrencyForm component
- [ ] Create new pages
- [ ] Update routing
- [ ] Add navigation items
- [ ] Write component tests

### Integration
- [ ] End-to-end workflow testing
- [ ] Permission validation
- [ ] Performance testing
- [ ] User acceptance testing

### Deployment
- [ ] Staging deployment
- [ ] UAT with stakeholders
- [ ] Production deployment
- [ ] Post-deployment monitoring

---

## 🎯 NEXT STEPS & PRIORITIES

### 🔴 IMMEDIATE (Week 1 - BLOCKING)
**Chủ đề**: Database & Backend Foundation

1. **Database Schema** (Day 1-2)
   ```bash
   # Create migration files in staging-schema-export/
   - 20250113_currency_orders_table.sql
   - 20250113_currency_orders_functions.sql
   - 20250113_currency_orders_policies.sql
   ```

2. **RPC Functions** (Day 2)
   - Implement 8 specific functions:
     - `create_currency_sell_order_v1`
     - `create_currency_purchase_order_v1`
     - `get_currency_sell_orders_v1`
     - `get_currency_purchase_orders_v1`
     - `assign_currency_order_v1`
     - `start_currency_order_v1`
     - `complete_currency_order_v1`
     - `cancel_currency_order_v1`
   - Test với Postman hoặc psql (use test queries from section 1.3)

3. **Composable** (Day 3)
   - Create `src/composables/useCurrencyOrders.js`
   - Add deprecation warnings to `useCurrency.js`

**Deliverable**: ✅ Backend API sẵn sàng để Frontend gọi

---

### 🟡 SECONDARY (Week 2 - Frontend Integration)
**Chủ đề**: Pages & Components

1. **Fix CurrencySell.vue** (Day 4-5)
   - Replace TODO at line 543 with actual API call
   - Test create sale order end-to-end

2. **Create CurrencyPurchase.vue** (Day 6)
   - Copy structure từ CurrencySell.vue
   - Create SupplierForm component
   - Test create purchase order

3. **Create CurrencyOps.vue** (Day 7)
   - Build orders list view
   - Add filters
   - Implement process/complete actions

**Deliverable**: ✅ 3 pages hoàn chỉnh cho Sales & Ops workflow

---

### 🟢 FINAL (Week 3 - Polish & Deploy)
**Chủ đề**: Testing & Production

1. **Integration & Testing** (Day 8-10)
   - End-to-end workflow testing
   - Bug fixes
   - Performance optimization

2. **Deployment** (Day 11-12)
   - Staging deployment
   - UAT with team
   - Production rollout

**Deliverable**: ✅ System live on production

---

## 📝 CONCLUSION & RECOMMENDATIONS

### ✅ What We Have (Good Foundation)
- **Frontend**: 60% complete với reusable components
- **Architecture**: Clean separation (composables, components, pages)
- **UI/UX**: Consistent design patterns

### ❌ What We Need (Critical Gap)
- **Database**: 0% - MUST implement first (BLOCKING)
- **Backend Logic**: RPC functions chưa có
- **Integration**: Pages có UI nhưng chưa connect API

### 🎯 Recommended Approach

**Option 1: Full Implementation (2-3 weeks)**
- Implement toàn bộ theo plan
- Suitable cho production-ready system

**Option 2: MVP First (1 week)**
- Day 1-2: Database + RPC functions
- Day 3-4: Fix CurrencySell.vue only
- Day 5-7: Basic CurrencyOps.vue
- **Skip**: CurrencyPurchase.vue, advanced features

**Option 3: Database Only (3 days)**
- Chỉ implement backend
- Frontend dùng legacy functions tạm
- Migrate dần sau

### 💡 My Recommendation: **Option 2 (MVP)**

**Lý do**:
1. ✅ **Fastest time to value**: Sale workflow working trong 1 week
2. ✅ **Risk reduction**: Test với real users trước khi build full system
3. ✅ **Flexibility**: Có thể adjust design dựa trên feedback
4. ✅ **Incremental**: Không break existing code

---

## ✅ CHECKLIST TO START

Before starting implementation, prepare:

### Environment
- [ ] Local database với Supabase CLI
- [ ] Access to staging/production databases
- [ ] Postman collection for API testing

### Documentation
- [x] CURRENCY-ORDERS-DESIGN.md reviewed
- [x] CURRENCY-IMPLEMENTATION-PLAN.md updated
- [ ] Create CHANGELOG.md to track progress

### Team Alignment
- [ ] Review plan with team lead
- [ ] Assign tasks to developers
- [ ] Setup daily standup for tracking

**Ready to start implementation! 🚀**

---

**Last Updated**: 2025-01-12
**Next Review**: After Week 1 completion