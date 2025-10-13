# 🏗️ CURRENCY ORDERS TABLE & RPC DESIGN
**Version:** 2.0 - Updated for Business Requirements
**Ngày:** 2025-01-11
**Status:** Ready for Implementation

---

## 📋 PHÂN TÍCH YÊU CẦU NGHIỆP VỤ THỰC TẾ

### 👥 Role-Based Business Process:
```
🎯 TRADER1 (Sales):
- Tạo đơn bán currency tại CurrencySell.vue
- Không cần chọn account/warehouse
- Có thể bán khi inventory chưa đủ (quantity có thể âm)
- Thống kê các hình thức chuyển đổi (items/service/farmer) cho báo cáo

🔧 TRADER2 (Operations):
- Xử lý đơn bán trong CurrencyOps.vue
- Giao hàng với bằng chứng đầy đủ
- Tạo đơn mua currency từ suppliers
- Thực hiện exchange currency (swap A → B)
- Quản lý inventory, stock di dời, điều chỉnh thủ công

👨‍💼 MANAGEMENT (Manager/Mod/Admin):
- Báo cáo và phân tích doanh thu, lợi nhuận
- Điều chỉnh stock thủ công khi cần
- Xử lý báo cáo sai sót từ Trader2
- Phê duyệt giao dịch lớn
```

### 🔄 Three Core Business Operations:

#### 1. **BÁN CURRENCY (SELL)** - Trader1 creates, Trader2 fulfills
```
📝 Business Flow:
Trader1 (CurrencySell.vue):
- Tạo đơn bán với customer info (bắt buộc)
- Include exchange info cho thống kê (items/service/farmer)
- Exchange types:
  • items: Khách dùng item để đổi currency
  • service: Trader làm service cho khách để lấy currency
  • farmer: Mua currency từ farmer trong team (thống kê riêng)
- Không chọn account (Trader2 sẽ chọn sau)
- Status: draft → pending → chờ Trader2

🔧 Processing Flow:
Trader2 (CurrencyOps.vue - "Đơn Bán" tab):
- Xem danh sách đơn pending
- Nhận đơn → Chọn account để giao hàng
- Cho phép bán âm (trừ qty âm trên inventory) khi chưa có hàng
- Mua hàng nếu cần để đủ lượng cho đơn
- Giao hàng với bằng chứng (screenshots, chat logs)

📊 Completion Flow:
- Giao hàng thành công → Profit được tính dựa trên avg cost tại thời điểm giao
- Cost basis: ((old_stock * old_avg) + (new_stock * new_price)) / total_stock
- Lưu vào currency_transactions với full details
- Update inventory: quantity--, reserved--
- Customer: Khách hàng, Game: Game tag, Channel: Kênh bán
- **QUAN TRỌNG**: Profit chỉ tính khi giao thành công, đơn bị cancel/fail không tính profit
```

#### 2. **MUA CURRENCY (PURCHASE)** - Trader2 creates & processes
```
📝 Business Flow:
Trader2 (CurrencyOps.vue - "Đơn Mua" tab):
- Tạo đơn mua từ suppliers/farmers
- Chọn account để nhận currency
- Nhập giá mua và thông tin supplier

🔧 Processing Flow:
- Tự động tính giá vốn trung bình (weighted average)
- Cập nhật inventory: quantity++
- Lưu vào currency_transactions
- Supplier: Nhà cung cấp, Account: Account nhận hàng
```

#### 3. **EXCHANGE CURRENCY** - Trader2 creates buy+sell orders
```
🔧 Business Flow:
Trader2 (CurrencyOps.vue - "Exchange" tab):
- Tạo 2 orders đường hoàng: 1 order MUA + 1 order BÁN
- Order MUA: Mua Currency A từ customer với giá X
- Order BÁN: Bán Currency B cho customer với giá Y
- Profit = (Y * quantity_B) - (X * quantity_A)
- Cập nhật inventory cho cả hai currency
- **KHÔNG có bước giao hàng** - orders chỉ để thống kê
- Cost calculation: Tự động tính avg VND và avg USD cho cả 2 currency

📊 Transaction Flow:
- Order MUA: Cập nhật inventory với giá mua X
- Order BÁN: Tính profit dựa trên avg cost của currency B
- Profit được ghi nhận ngay khi hoàn thành
- Example: MUA 100 Chaos Orb @1500 VND, BÁN 5 Divine Orb @30000 VND → Profit spread
```

### 🎯 Key Business Rules:
1. **Sell với âm quantity**: Cho phép bán khi inventory chưa đủ, profit tính khi giao hàng
2. **Profit timing**: Chỉ tính khi đơn giao thành công, cancel/fail không tính profit
3. **Cost basis**: Weighted average: ((old_stock * old_avg) + (new_stock * new_price)) / total_stock
4. **Exchange tạo 2 orders**: 1 MUA + 1 BÁN, không cần giao hàng, chỉ để thống kê
5. **Trader1 chỉ tạo sell**: Trader2 xử lý tất cả operations (mua, exchange, giao hàng)
6. **Multi-game support**: POE1, POE2, D4 trong cùng system với cost basis riêng biệt
7. **Exchange types statistics**: items/service/farmer chỉ để báo cáo, không ảnh hưởng profit
8. **Order cancellation**: Có thể cancel từ Sales với bằng chứng và lý do
9. **Ops không reject**: Chỉ có thể hủy từ Sales, không reject từ Ops

### 🔄 Additional Operations (Trader2 Responsibilities)

#### 4. **DI DỜI STOCK CURRENCY** - Giao ca
```
📝 Business Flow:
Trader2 (CurrencyOps.vue - "Di dời Stock" tab):
- Khi giao ca: Trader2 A → Trader2 B
- Chọn currency type, số lượng, source account, target account
- Cập nhật currency_inventory với transaction type 'transfer'
- Generate audit trail cho việc di dời

🔧 Technical Implementation:
- Transaction type: 'transfer' trong currency_transactions
- Both accounts: game_account_id (source), target_account_id (destination)
- No profit calculation (internal transfer)
```

#### 5. **KẾT THÚC LEAGUE** - Season transition
```
📝 Business Flow:
Trader2 (CurrencyOps.vue - "Kết thúc League" tab):
- Khi season kết thúc: Move từ current league → standard/eternal
- Choose source accounts, target league (standard/eternal)
- Batch process nhiều currency types
- Preserve cost basis calculations

🔧 Technical Implementation:
- Transaction type: 'league_archive'
- From: old league_attribute_id, To: new league_attribute_id
- Keep same game_account_id, change league context
- Calculate new average costs if needed
```

#### 6. **ĐIỀU CHỈNH STOCK THỦ CÔNG** - Management only
```
📝 Business Flow:
Manager/Mod/Admin (CurrencyOps.vue - "Điều chỉnh Stock" tab):
- Khi phát sai sót hoặc cần điều chỉnh
- Xử lý báo cáo sai sót từ Trader2
- Manual adjustment với lý do rõ ràng
- Requires admin approval for large adjustments

🔧 Technical Implementation:
- Transaction type: 'manual_adjustment'
- Requires approval workflow for amounts > threshold
- Full audit trail with approver information
- Update inventory directly with reason tracking
```

#### 7. **BÁO CÁO SAI LỆCH TỀN KHO** - Discrepancy Management
```
📝 Detection Triggers:
- Daily inventory check (cuối mỗi ngày)
- Per transaction check (sau mỗi giao hàng)
- Customer complaint (khi khách báo thiếu hàng)
- System auto-alert khi có bất thường:
  • Quantity/avg price tăng giảm đột ngột 20% so với 10 đơn gần nhất
  • Quantity < 0 quá 1 giờ
  • Discrepancy >10% total value
  • Trader có 5+ discrepancies liên tiếp về avg price
  • Inventory không reconcile sau 1 ngày

📝 Business Flow:
Trader2 (CurrencyOps.vue - "Báo Cáo Lệch Lạc" tab):
- Báo cáo khi phát hiện discrepancy (bắt buộc)
- Upload evidence (screenshots, chat logs, witness info)
- System auto-create report template
- Submit for approval

🔧 Approval Workflow:
- Threshold <1M VND: Manager approval (12h response time)
- Threshold ≥1M VND: Admin/Manager approval (12h response time)
- Cần lý do chi tiết và bằng chứng đầy đủ
- **KHÔNG có auto-approval**

📊 Financial Recording:
- Shortage (thiếu hàng): Inventory Write-off (Expense) hoặc không ghi nhận
- Excess (thừa hàng): Inventory Gain (Revenue)
- Loss/Mất hàng: Expense (Loss on Inventory) hoặc không ghi nhận
- **Priority**: Tránh sai sót dữ liệu, profit được đảm bảo

🛡️ Security & Control:
- Chỉ Manager/Mod/Admin mới có thể:
  • Approve discrepancy reports
  • Create adjustment transactions
  • Update inventory corrections
- Rollback capability cho mọi adjustments
- Full audit trail: Who + When + Reason + Evidence
```

### 🎛️ CURRENCYOPS MULTI-TAB DESIGN (Updated)

```javascript
// CurrencyOps.vue Structure - 3 Tabs cho Trader2
<template>
  <div class="currency-ops-container">
    <!-- Header -->
    <div class="ops-header">
      <h1>Currency Operations Center</h1>
      <div class="tabs-navigation">
        <n-tabs v-model:value="activeTab" type="card" size="large">
          <!-- Tab 1: Mua hàng & Exchange -->
          <n-tab-pane name="purchase-exchange" tab="💰 Mua hàng & Exchange">
            <CurrencyPurchaseExchangeTab
              :suppliers="suppliers"
              :inventory="inventoryByCurrency"
              @purchase-created="onPurchaseCreated"
              @exchange-completed="onExchangeCompleted"
            />
          </n-tab-pane>

          <!-- Tab 2: Xử lý đơn bán -->
          <n-tab-pane name="sell-orders" tab="📋 Xử lý Đơn Bán">
            <CurrencySellOrdersTab
              :orders="sellOrders"
              :loading="sellOrdersLoading"
              @order-selected="onSellOrderSelected"
              @order-processed="onSellOrderProcessed"
              @order-completed="onSellOrderCompleted"
            />
          </n-tab-pane>

          <!-- Tab 3: Di dời Stock & League Transition -->
          <n-tab-pane name="stock-league" tab="📦 Di dời Stock & League">
            <CurrencyStockLeagueTab
              :game-accounts="gameAccounts"
              :inventory="inventoryByAccount"
              :leagues="activeLeagues"
              @transfer-created="onTransferCreated"
              @transfer-completed="onTransferCompleted"
              @league-transition-completed="onLeagueTransitionCompleted"
            />
          </n-tab-pane>
        </n-tabs>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useUserPermissions } from '@/composables/useUserPermissions'

const activeTab = ref('purchase-exchange')
const { hasRole } = useUserPermissions()

// Data loading
const sellOrders = ref([])
const suppliers = ref([])
const gameAccounts = ref([])
const activeLeagues = ref([])
const inventoryByCurrency = ref({})
const inventoryByAccount = ref({})

// Computed properties
const hasManagementRole = computed(() =>
  hasRole('manager') || hasRole('mod') || hasRole('admin')
)

// Tab components
const CurrencyPurchaseExchangeTab = defineAsyncComponent(() =>
  import('@/components/currency/tabs/CurrencyPurchaseExchangeTab.vue')
)
const CurrencySellOrdersTab = defineAsyncComponent(() =>
  import('@/components/currency/tabs/CurrencySellOrdersTab.vue')
)
const CurrencyStockLeagueTab = defineAsyncComponent(() =>
  import('@/components/currency/tabs/CurrencyStockLeagueTab.vue')
)
</script>
```

### 📋 Tab Structure Details:

#### **Tab 1: 💰 Mua hàng & Exchange**
```vue
<!-- CurrencyPurchaseExchangeTab.vue -->
<template>
  <div class="purchase-exchange-tab">
    <n-tabs type="segment">
      <n-tab-pane name="purchase" tab="🛒 Mua hàng">
        <!-- Purchase form để mua từ suppliers/farmers -->
        <CurrencyPurchaseForm
          :suppliers="suppliers"
          :inventory="inventory"
          @purchase-created="handlePurchase"
        />
      </n-tab-pane>

      <n-tab-pane name="exchange" tab="🔄 Exchange">
        <!-- Exchange form để swap A → B -->
        <CurrencyExchangeForm
          :inventory="inventory"
          @exchange-completed="handleExchange"
        />
      </n-tab-pane>
    </n-tabs>
  </div>
</template>
```

#### **Tab 2: 📋 Xử lý Đơn Bán**
```vue
<!-- CurrencySellOrdersTab.vue -->
<template>
  <div class="sell-orders-tab">
    <!-- Orders List từ Trader1 -->
    <div class="orders-section">
      <n-data-table
        :columns="orderColumns"
        :data="orders"
        :loading="loading"
        :pagination="{ pageSize: 20 }"
      />
    </div>

    <!-- Order Details Panel -->
    <div v-if="selectedOrder" class="order-details">
      <CurrencyOrderDetails
        :order="selectedOrder"
        @process-order="onProcessOrder"
        @complete-order="onCompleteOrder"
      />
    </div>
  </div>
</template>
```

#### **Tab 3: 📦 Di dời Stock & League Transition**
```vue
<!-- CurrencyStockLeagueTab.vue -->
<template>
  <div class="stock-league-tab">
    <n-tabs type="segment">
      <n-tab-pane name="stock-transfer" tab="🔄 Di dời Stock">
        <!-- Stock transfer khi giao ca -->
        <CurrencyStockTransferForm
          :game-accounts="gameAccounts"
          :inventory="inventoryByAccount"
          @transfer-created="handleStockTransfer"
        />
      </n-tab-pane>

      <n-tab-pane name="league-transition" tab="🏆 League Transition">
        <!-- Chuyển currency từ seasonal → standard/eternal -->
        <CurrencyLeagueTransitionForm
          :game-accounts="gameAccounts"
          :leagues="activeLeagues"
          @transition-completed="handleLeagueTransition"
        />
      </n-tab-pane>
    </n-tabs>
  </div>
</template>
```

### 📊 **Tab Functionality Summary (Updated):**

| Tab | Primary User | Key Function | Business Impact |
|-----|--------------|--------------|-----------------|
| **Mua hàng & Exchange** | Trader2 | Mua từ suppliers + Swap currency | Nhập hàng & Arbitrage |
| **Xử lý Đơn Bán** | Trader2 | Xử lý orders từ Trader1 | Giao hàng cho khách |
| **Di dời Stock & League** | Trader2 | Giao ca + Season transition | Quản lý kho & Season |

### 📈 **Inventory Form (Chung cho Trader1 & Trader2)**

```vue
<!-- CurrencyInventoryPanel.vue (Enhanced) -->
<template>
  <div class="inventory-panel">
    <!-- View Inventory -->
    <div class="inventory-view">
      <n-data-table
        :columns="inventoryColumns"
        :data="inventoryData"
        :filters="inventoryFilters"
        :pagination="{ pageSize: 50 }"
      />
    </div>

    <!-- Integrated Reports -->
    <div class="inventory-reports">
      <n-tabs type="card">
        <n-tab-pane name="stock-summary" tab="📊 Tóm tắt Tồn kho">
          <StockSummaryReport :data="inventoryData" />
        </n-tab-pane>

        <n-tab-pane name="stock-movements" tab="📈 Di chuyển Stock">
          <StockMovementsReport :transactions="stockTransactions" />
        </n-tab-pane>

        <n-tab-pane name="discrepancy-alerts" tab="⚠️ Cảnh báo Lệch Lạc">
          <DiscrepancyAlerts :alerts="discrepancyAlerts" />
        </n-tab-pane>
      </n-tabs>
    </div>
  </div>
</template>
```

---

## 🗄️ PHẦN 1: CURRENCY_ORDERS TABLE DESIGN

### 1.1 Table Schema

```sql
-- ===================================
-- CURRENCY ORDERS TABLE DESIGN
-- ===================================

-- 1. Enums cho type safety
CREATE TYPE currency_order_type_enum AS ENUM (
    'PURCHASE',           -- Mua currency (từ supplier/farmer)
    'SALE',              -- Bán currency (cho khách hàng)
    'EXCHANGE'           -- Exchange currency (chuyển đổi)
);

CREATE TYPE currency_order_status_enum AS ENUM (
    'draft',             -- Nháp (chưa submit)
    'pending',           -- Chờ xử lý (Sales tạo, chờ Ops)
    'assigned',          -- Đã phân công (Ops nhận đơn)
    'preparing',         -- Đang chuẩn bị (Ops chuẩn bị currency)
    'ready',             -- Sẵn sàng giao hàng
    'delivering',        -- Đang giao hàng
    'completed',         -- Hoàn thành
    'cancelled',         -- Hủy
    'failed'             -- Thất bại
);

CREATE TYPE currency_exchange_type_enum AS ENUM (
    'none',
    'items',
    'service',
    'farmer'
);

-- 2. Main table
CREATE TABLE public.currency_orders (
    -- Primary Keys & Identification
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    order_number text UNIQUE NOT NULL GENERATED ALWAYS AS (
        'CUR-' ||
        CASE order_type
            WHEN 'PURCHASE' THEN 'BUY-'
            WHEN 'SALE' THEN 'SELL-'
            WHEN 'EXCHANGE' THEN 'EX-'
            ELSE 'XX-'
        END ||
        LPAD(EXTRACT(epoch FROM created_at)::bigint::text, 8, '0')
    ) STORED,

    -- Order Classification
    order_type currency_order_type_enum NOT NULL,
    status currency_order_status_enum DEFAULT 'draft'::currency_order_status_enum,

    -- Currency Information
    currency_attribute_id uuid NOT NULL REFERENCES public.attributes(id),
    quantity numeric NOT NULL CHECK (quantity > 0),
    unit_price_vnd numeric NOT NULL CHECK (unit_price_vnd >= 0),
    unit_price_usd numeric NOT NULL CHECK (unit_price_usd >= 0),

    -- Calculated Fields
    total_price_vnd numeric GENERATED ALWAYS AS (quantity * unit_price_vnd) STORED,
    total_price_usd numeric GENERATED ALWAYS AS (quantity * unit_price_usd) STORED,

    -- Game Context
    game_code text NOT NULL,
    league_attribute_id uuid NOT NULL REFERENCES public.attributes(id),

    -- Customer Information (FOR SALE ORDERS)
    customer_name text,
    customer_game_tag text,
    delivery_info text,
    channel_id uuid REFERENCES public.channels(id),

    -- Supplier/Partner Information (FOR PURCHASE ORDERS)
    supplier_party_id uuid REFERENCES public.parties(id),
    supplier_notes text,

    -- Account/Warehouse Information
    game_account_id uuid REFERENCES public.game_accounts(id),

    -- Exchange Information (OPTIONAL)
    exchange_type currency_exchange_type_enum DEFAULT 'none'::currency_exchange_type_enum,
    exchange_details text,
    exchange_images text[],

    -- Notes & Additional Information
    sales_notes text,
    ops_notes text,
    completion_notes text,

    -- Financial Tracking (Foundation cho profit calculation)
    cost_per_unit_vnd numeric,
    total_cost_vnd numeric GENERATED ALWAYS AS (quantity * COALESCE(cost_per_unit_vnd, 0)) STORED,
    profit_per_unit_vnd numeric GENERATED ALWAYS AS (unit_price_vnd - COALESCE(cost_per_unit_vnd, 0)) STORED,
    total_profit_vnd numeric GENERATED ALWAYS AS (total_price_vnd - COALESCE(total_cost_vnd, 0)) STORED,

    -- Timestamps & Workflow
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    submitted_at timestamptz,
    assigned_at timestamptz,
    started_preparation_at timestamptz,
    ready_at timestamptz,
    started_delivery_at timestamptz,
    completed_at timestamptz,
    cancelled_at timestamptz,

    -- User Assignment & Audit
    created_by uuid NOT NULL REFERENCES public.profiles(id),
    updated_by uuid REFERENCES public.profiles(id),
    submitted_by uuid REFERENCES public.profiles(id),
    assigned_to uuid REFERENCES public.profiles(id), -- Ops assigned
    delivered_by uuid REFERENCES public.profiles(id),

    -- Proof & Verification
    proof_urls text[],
    verification_status text DEFAULT 'pending' CHECK (verification_status IN ('pending', 'verified', 'rejected')),
    verified_by uuid REFERENCES public.profiles(id),
    verified_at timestamptz,

    -- Priority & SLA
    priority_level integer DEFAULT 3 CHECK (priority_level BETWEEN 1 AND 5), -- 1=highest, 5=lowest
    deadline_at timestamptz, -- Deadline cho completion
    sla_hours integer DEFAULT 0.167, -- SLA trong giờ (10 phút = 0.167 giờ)
    sla_breach_notified boolean DEFAULT false, -- Đã báo cáo SLA breach chưa
    sla_status text DEFAULT 'normal' CHECK (sla_status IN ('normal', 'warning', 'breached'))

    -- System Fields
    source_system text DEFAULT 'web' CHECK (source_system IN ('web', 'api', 'mobile', 'import')),
    version integer DEFAULT 1,
    metadata jsonb DEFAULT '{}'::jsonb
);

-- 3. Indexes for performance
CREATE INDEX idx_currency_orders_type_status ON public.currency_orders(order_type, status);
CREATE INDEX idx_currency_orders_game_league ON public.currency_orders(game_code, league_attribute_id);
CREATE INDEX idx_currency_orders_customer ON public.currency_orders(customer_name, customer_game_tag);
CREATE INDEX idx_currency_orders_created_at ON public.currency_orders(created_at DESC);
CREATE INDEX idx_currency_orders_assigned_to ON public.currency_orders(assigned_to, status);
CREATE INDEX idx_currency_orders_deadline ON public.currency_orders(deadline_at) WHERE deadline_at IS NOT NULL;
CREATE INDEX idx_currency_orders_currency ON public.currency_orders(currency_attribute_id, game_code);

-- 4. Triggers for timestamp management
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
```

### 1.2 Table Relationships

```sql
-- Additional relationships với các tables hiện có:

-- Với currency_transactions (đã có)
ALTER TABLE public.currency_transactions
ADD COLUMN currency_order_id uuid REFERENCES public.currency_orders(id);

-- Thêm fields cho exchange và transfer transactions
ALTER TABLE public.currency_transactions
ADD COLUMN target_game_account_id uuid REFERENCES public.game_accounts(id),
ADD COLUMN target_league_attribute_id uuid REFERENCES public.attributes(id),
ADD COLUMN exchange_rate numeric,
ADD COLUMN original_currency_id uuid REFERENCES public.attributes(id),
ADD COLUMN target_currency_id uuid REFERENCES public.attributes(id);

-- Với game_accounts (đã có)
-- game_account_id -> REFERENCES public.game_accounts(id)

-- Với attributes (đã có)
-- currency_attribute_id -> REFERENCES public.attributes(id) (currency types)
-- league_attribute_id -> REFERENCES public.attributes(id) (leagues)

-- Với channels (đã có)
-- channel_id -> REFERENCES public.channels(id)

-- Với parties (đã có)
-- supplier_party_id -> REFERENCES public.parties(id)
```

### 1.3 Enhanced Currency Transactions Table (Simplified)

```sql
-- Only discrepancy reports table needed for workflow
CREATE TABLE public.currency_discrepancy_reports (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    reporter_profile_id uuid NOT NULL REFERENCES public.profiles(id),
    game_account_id uuid NOT NULL REFERENCES public.game_accounts(id),
    currency_attribute_id uuid NOT NULL REFERENCES public.attributes(id),

    -- Discrepancy details
    expected_quantity numeric NOT NULL,
    actual_quantity numeric NOT NULL,
    discrepancy_amount numeric GENERATED ALWAYS AS (expected_quantity - actual_quantity) STORED,
    discrepancy_value_vnd numeric GENERATED ALWAYS AS (
        (expected_quantity - actual_quantity) *
        COALESCE((
            SELECT avg_buy_price_vnd
            FROM currency_inventory
            WHERE game_account_id = currency_discrepancy_reports.game_account_id
              AND currency_attribute_id = currency_discrepancy_reports.currency_attribute_id
        ), 0)
    ) STORED,

    -- Report information
    title text NOT NULL,
    description text NOT NULL,
    category text NOT NULL CHECK (category IN ('shortage', 'excess', 'corruption', 'other')),
    priority_level integer DEFAULT 3 CHECK (priority_level BETWEEN 1 AND 5),

    -- Workflow fields
    status text DEFAULT 'pending' CHECK (status IN ('pending', 'investigating', 'resolved', 'rejected', 'closed')),
    resolution_notes text,
    resolved_by uuid REFERENCES public.profiles(id),
    resolved_at timestamptz,

    -- Adjustment transaction link
    adjustment_transaction_id uuid REFERENCES public.currency_transactions(id),

    -- Audit fields
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),

    -- Evidence
    evidence_urls text[],
    internal_notes text
);

-- Indexes for discrepancy reports
CREATE INDEX idx_currency_discrepancy_reports_account ON public.currency_discrepancy_reports(game_account_id);
CREATE INDEX idx_currency_discrepancy_reports_status ON public.currency_discrepancy_reports(status);
CREATE INDEX idx_currency_discrepancy_reports_reporter ON public.currency_discrepancy_reports(reporter_profile_id);
```

### 1.4 Enhanced Currency Transactions (No Separate Tables)

**Note**: Stock transfers và league archives chỉ ghi vào `currency_transactions` với các `transaction_type` khác nhau:

```sql
-- Transaction Types cho currency_transactions:
-- 'purchase' - Mua từ suppliers
-- 'sale_delivery' - Giao hàng bán
-- 'exchange_in' - Nhận từ exchange
-- 'exchange_out' - Đưa ra exchange
-- 'transfer' - Di dời stock giữa accounts
-- 'league_archive_in' - Nhận từ league transition
-- 'league_archive_out' - Đưa ra league transition
-- 'manual_adjustment' - Điều chỉnh thủ công (Management only)

-- Example stock transfer transaction:
INSERT INTO currency_transactions (
    game_account_id, game_code, league_attribute_id,
    transaction_type, currency_attribute_id, quantity,
    unit_price_vnd, target_game_account_id,
    notes, created_by
) VALUES (
    'account-a-uuid', 'POE_2', 'ea-standard-uuid',
    'transfer', 'chaos-orb-uuid', -100,
    1500, 'account-b-uuid',
    'Stock transfer: A → B (giao ca)',
    'user-uuid'
);

-- Example league transition transaction:
INSERT INTO currency_transactions (
    game_account_id, game_code, league_attribute_id,
    transaction_type, currency_attribute_id, quantity,
    unit_price_vnd, original_league_attribute_id,
    notes, created_by
) VALUES (
    'account-uuid', 'POE_2', 'standard-uuid',
    'league_archive_in', 'divine-orb-uuid', 20,
    50000, 'ritual-league-uuid',
    'League transition: Ritual → Standard',
    'user-uuid'
);
```

### 1.3 Constraints & Business Rules

```sql
-- Business Rules Constraints
ALTER TABLE public.currency_orders
ADD CONSTRAINT check_sale_has_customer
    CHECK (order_type != 'SALE' OR (customer_name IS NOT NULL AND customer_game_tag IS NOT NULL));

ALTER TABLE public.currency_orders
ADD CONSTRAINT check_purchase_has_supplier
    CHECK (order_type != 'PURCHASE' OR supplier_party_id IS NOT NULL);

ALTER TABLE public.currency_orders
ADD CONSTRAINT check_exchange_has_account
    CHECK (order_type != 'EXCHANGE' OR game_account_id IS NOT NULL);

ALTER TABLE public.currency_orders
ADD CONSTRAINT check_profit_calculation
    CHECK (total_profit_vnd IS NULL OR total_cost_vnd IS NOT NULL);

-- Additional constraints cho workflow
ALTER TABLE public.currency_orders
ADD CONSTRAINT check_status_flow
    CHECK (
        (status = 'draft' AND submitted_at IS NULL) OR
        (status = 'pending' AND submitted_at IS NOT NULL AND assigned_at IS NULL) OR
        (status = 'assigned' AND assigned_at IS NOT NULL AND started_preparation_at IS NULL) OR
        (status = 'preparing' AND started_preparation_at IS NOT NULL AND ready_at IS NULL) OR
        (status = 'ready' AND ready_at IS NOT NULL AND started_delivery_at IS NULL) OR
        (status = 'delivering' AND started_delivery_at IS NOT NULL AND completed_at IS NULL) OR
        (status = 'completed' AND completed_at IS NOT NULL) OR
        (status IN ('cancelled', 'failed'))
    );
```

---

## 🔧 PHẦN 2: RPC FUNCTIONS DESIGN

### 2.1 Core Functions cho Sales Workflow

#### Function 1: Create Currency Order (Multi-type)

```sql
CREATE OR REPLACE FUNCTION public.create_currency_order_v1(
    -- Core Order Information
    p_order_type currency_order_type_enum,
    p_currency_attribute_id uuid,
    p_quantity numeric,
    p_unit_price_vnd numeric,
    p_unit_price_usd numeric DEFAULT 0,
    p_game_code text,
    p_league_attribute_id uuid,

    -- Customer Information (FOR SALE)
    p_customer_name text DEFAULT NULL,
    p_customer_game_tag text DEFAULT NULL,
    p_delivery_info text DEFAULT NULL,
    p_channel_id uuid DEFAULT NULL,

    -- Supplier Information (FOR PURCHASE)
    p_supplier_party_id uuid DEFAULT NULL,
    p_supplier_notes text DEFAULT NULL,

    -- Account Information (CONDITIONAL)
    p_game_account_id uuid DEFAULT NULL,

    -- Exchange Information (OPTIONAL)
    p_exchange_type currency_exchange_type_enum DEFAULT 'none',
    p_exchange_details text DEFAULT NULL,
    p_exchange_images text[] DEFAULT NULL,

    -- Additional Information
    p_sales_notes text DEFAULT NULL,
    p_priority_level integer DEFAULT 3,
    p_deadline_hours integer DEFAULT 24,
    p_metadata jsonb DEFAULT '{}'
) RETURNS TABLE(
    success boolean,
    order_id uuid,
    order_number text,
    message text,
    requires_approval boolean
) LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
    v_user_id uuid := auth.uid();
    v_new_order_id uuid;
    v_can_create boolean := false;
    v_requires_approval boolean := false;
    v_game_account_purpose text;
BEGIN
    -- Permission Check
    SELECT EXISTS(
        SELECT 1 FROM user_role_assignments ura
        JOIN attributes ba ON ura.business_area_attribute_id = ba.id
        WHERE ura.user_id = v_user_id
        AND ba.code = 'CURRENCY'
        AND ura.role_name IN ('admin', 'manager', 'sales', 'ops')
    ) INTO v_can_create;

    IF NOT v_can_create THEN
        RETURN QUERY SELECT FALSE, NULL::UUID, NULL::TEXT, 'Permission denied: Cannot create currency order', FALSE;
        RETURN;
    END IF;

    -- Validate Business Rules
    IF p_order_type = 'SALE' AND (p_customer_name IS NULL OR p_customer_game_tag IS NULL) THEN
        RETURN QUERY SELECT FALSE, NULL::UUID, NULL::TEXT, 'Sale orders require customer information', FALSE;
        RETURN;
    END IF;

    IF p_order_type = 'PURCHASE' AND p_supplier_party_id IS NULL THEN
        RETURN QUERY SELECT FALSE, NULL::UUID, NULL::TEXT, 'Purchase orders require supplier information', FALSE;
        RETURN;
    END IF;

    -- Check if game account is required and valid
    IF p_game_account_id IS NOT NULL THEN
        SELECT purpose INTO v_game_account_purpose
        FROM game_accounts
        WHERE id = p_game_account_id;

        IF v_game_account_purpose IS NULL THEN
            RETURN QUERY SELECT FALSE, NULL::UUID, NULL::TEXT, 'Invalid game account', FALSE;
            RETURN;
        END IF;
    END IF;

    -- Determine if approval is required (based on amount, customer, etc.)
    IF p_order_type = 'PURCHASE' AND (p_quantity * p_unit_price_vnd) > 10000000 THEN -- > 10M VND
        v_requires_approval := TRUE;
    END IF;

    -- Create the order
    INSERT INTO public.currency_orders (
        order_type, currency_attribute_id, quantity, unit_price_vnd, unit_price_usd,
        game_code, league_attribute_id,
        customer_name, customer_game_tag, delivery_info, channel_id,
        supplier_party_id, supplier_notes,
        game_account_id,
        exchange_type, exchange_details, exchange_images,
        sales_notes, priority_level, deadline_at,
        created_by, metadata
    ) VALUES (
        p_order_type, p_currency_attribute_id, p_quantity, p_unit_price_vnd, p_unit_price_usd,
        p_game_code, p_league_attribute_id,
        p_customer_name, p_customer_game_tag, p_delivery_info, p_channel_id,
        p_supplier_party_id, p_supplier_notes,
        p_game_account_id,
        p_exchange_type, p_exchange_details, p_exchange_images,
        p_sales_notes, p_priority_level, now() + (p_deadline_hours || ' hours')::interval,
        v_user_id, p_metadata
    ) RETURNING id INTO v_new_order_id;

    RETURN QUERY SELECT
        TRUE,
        v_new_order_id,
        (SELECT order_number FROM currency_orders WHERE id = v_new_order_id),
        'Currency order created successfully',
        v_requires_approval;
END;
$$;
```

#### Function 2: Submit Order (Draft → Pending)

```sql
CREATE OR REPLACE FUNCTION public.submit_currency_order_v1(
    p_order_id uuid,
    p_submit_notes text DEFAULT NULL
) RETURNS TABLE(
    success boolean,
    message text,
    next_status currency_order_status_enum
) LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
    v_user_id uuid := auth.uid();
    v_order RECORD;
    v_can_submit boolean := false;
BEGIN
    -- Permission Check
    SELECT EXISTS(
        SELECT 1 FROM user_role_assignments ura
        JOIN attributes ba ON ura.business_area_attribute_id = ba.id
        WHERE ura.user_id = v_user_id
        AND ba.code = 'CURRENCY'
        AND ura.role_name IN ('admin', 'manager', 'sales')
    ) INTO v_can_submit;

    IF NOT v_can_submit THEN
        RETURN QUERY SELECT FALSE, 'Permission denied: Cannot submit order', NULL::currency_order_status_enum;
        RETURN;
    END IF;

    -- Get and validate order
    SELECT * INTO v_order FROM currency_orders
    WHERE id = p_order_id AND status = 'draft' AND created_by = v_user_id;

    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'Order not found or not in draft status', NULL::currency_order_status_enum;
        RETURN;
    END IF;

    -- Update order status
    UPDATE currency_orders
    SET status = 'pending',
        submitted_at = now(),
        submitted_by = v_user_id,
        sales_notes = COALESCE(sales_notes, '') || COALESCE(E'\nSubmitted notes: ' || p_submit_notes, ''),
        updated_at = now(),
        updated_by = v_user_id
    WHERE id = p_order_id;

    RETURN QUERY SELECT TRUE, 'Order submitted successfully', 'pending'::currency_order_status_enum;
END;
$$;
```

#### Function 3: Process Order (Ops nhận và xử lý)

```sql
CREATE OR REPLACE FUNCTION public.process_currency_order_v1(
    p_order_id uuid,
    p_processing_notes text DEFAULT NULL,
    p_game_account_id uuid DEFAULT NULL -- Cho phép Ops chọn account khác
) RETURNS TABLE(
    success boolean,
    message text,
    transaction_id uuid,
    inventory_available boolean
) LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
    v_user_id uuid := auth.uid();
    v_order RECORD;
    v_can_process boolean := false;
    v_available_quantity numeric := 0;
    v_transaction_id uuid;
    v_use_account_id uuid;
BEGIN
    -- Permission Check (Ops role)
    SELECT EXISTS(
        SELECT 1 FROM user_role_assignments ura
        JOIN attributes ba ON ura.business_area_attribute_id = ba.id
        WHERE ura.user_id = v_user_id
        AND ba.code = 'CURRENCY'
        AND ura.role_name IN ('admin', 'manager', 'ops')
    ) INTO v_can_process;

    IF NOT v_can_process THEN
        RETURN QUERY SELECT FALSE, 'Permission denied: Cannot process order', NULL::UUID, FALSE;
        RETURN;
    END IF;

    -- Get order
    SELECT * INTO v_order FROM currency_orders
    WHERE id = p_order_id AND status = 'pending';

    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'Order not found or not ready for processing', NULL::UUID, FALSE;
        RETURN;
    END IF;

    -- Determine which account to use
    v_use_account_id := COALESCE(p_game_account_id, v_order.game_account_id);

    -- For SALE orders, check inventory availability
    IF v_order.order_type = 'SALE' AND v_use_account_id IS NOT NULL THEN
        SELECT COALESCE(SUM(quantity - reserved_quantity), 0)
        INTO v_available_quantity
        FROM currency_inventory
        WHERE game_account_id = v_use_account_id
        AND currency_attribute_id = v_order.currency_attribute_id;

        IF v_available_quantity < v_order.quantity THEN
            RETURN QUERY SELECT FALSE,
                format('Insufficient inventory: Available %s, Required %s', v_available_quantity, v_order.quantity),
                NULL::UUID, FALSE;
            RETURN;
        END IF;
    END IF;

    -- Update order status
    UPDATE currency_orders
    SET status = 'assigned',
        assigned_to = v_user_id,
        assigned_at = now(),
        game_account_id = v_use_account_id,
        ops_notes = p_processing_notes,
        updated_at = now(),
        updated_by = v_user_id
    WHERE id = p_order_id;

    -- Reserve inventory for SALE orders
    IF v_order.order_type = 'SALE' AND v_use_account_id IS NOT NULL THEN
        UPDATE currency_inventory
        SET reserved_quantity = reserved_quantity + v_order.quantity,
            last_updated_at = now()
        WHERE game_account_id = v_use_account_id
        AND currency_attribute_id = v_order.currency_attribute_id;
    END IF;

    RETURN QUERY SELECT TRUE, 'Order assigned successfully', NULL::UUID, TRUE;
END;
$$;
```

### 2.2 Functions cho Completion Workflow

#### Function 4: Complete Order (Hoàn thành giao dịch)

```sql
CREATE OR REPLACE FUNCTION public.complete_currency_order_v1(
    p_order_id uuid,
    p_completion_notes text DEFAULT NULL,
    p_proof_urls text[] DEFAULT NULL,
    p_actual_quantity numeric DEFAULT NULL, -- Cho phép adjust số lượng thực tế
    p_actual_unit_price_vnd numeric DEFAULT NULL -- Cho phép adjust giá thực tế
) RETURNS TABLE(
    success boolean,
    message text,
    transaction_id uuid,
    profit_vnd numeric
) LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
    v_user_id uuid := auth.uid();
    v_order RECORD;
    v_can_complete boolean := false;
    v_transaction_id uuid;
    v_final_quantity numeric;
    v_final_unit_price numeric;
    v_final_total_cost numeric;
    v_final_total_revenue numeric;
    v_calculated_profit numeric;
BEGIN
    -- Permission Check
    SELECT EXISTS(
        SELECT 1 FROM user_role_assignments ura
        JOIN attributes ba ON ura.business_area_attribute_id = ba.id
        WHERE ura.user_id = v_user_id
        AND ba.code = 'CURRENCY'
        AND ura.role_name IN ('admin', 'manager', 'ops')
    ) INTO v_can_complete;

    IF NOT v_can_complete THEN
        RETURN QUERY SELECT FALSE, 'Permission denied: Cannot complete order', NULL::UUID, NULL;
        RETURN;
    END IF;

    -- Get order
    SELECT * INTO v_order FROM currency_orders
    WHERE id = p_order_id AND status IN ('assigned', 'preparing', 'ready', 'delivering');

    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'Order not found or not ready for completion', NULL::UUID, NULL;
        RETURN;
    END IF;

    -- Use actual values if provided, otherwise use original
    v_final_quantity := COALESCE(p_actual_quantity, v_order.quantity);
    v_final_unit_price := COALESCE(p_actual_unit_price_vnd, v_order.unit_price_vnd);

    -- Calculate totals
    v_final_total_revenue := v_final_quantity * v_final_unit_price;
    v_final_total_cost := v_final_quantity * COALESCE(v_order.cost_per_unit_vnd, 0);
    v_calculated_profit := v_final_total_revenue - v_final_total_cost;

    -- Create transaction record
    INSERT INTO currency_transactions (
        game_account_id,
        game_code,
        league_attribute_id,
        transaction_type,
        currency_attribute_id,
        quantity,
        unit_price_vnd,
        unit_price_usd,
        currency_order_id,
        proof_urls,
        notes,
        created_by
    ) VALUES (
        v_order.game_account_id,
        v_order.game_code,
        v_order.league_attribute_id,
        CASE v_order.order_type
            WHEN 'SALE' THEN 'sale_delivery'
            WHEN 'PURCHASE' THEN 'purchase'
            WHEN 'EXCHANGE' THEN 'exchange'
        END,
        v_order.currency_attribute_id,
        CASE v_order.order_type
            WHEN 'SALE' THEN -v_final_quantity -- Negative for outgoing
            ELSE v_final_quantity -- Positive for incoming
        END,
        v_final_unit_price,
        CASE WHEN v_order.unit_price_usd > 0
            THEN (v_final_unit_price / v_order.unit_price_vnd) * v_order.unit_price_usd
            ELSE 0
        END,
        p_order_id,
        p_proof_urls,
        COALESCE(p_completion_notes, 'Currency order completed'),
        v_user_id
    ) RETURNING id INTO v_transaction_id;

    -- Update inventory for SALE orders
    IF v_order.order_type = 'SALE' AND v_order.game_account_id IS NOT NULL THEN
        UPDATE currency_inventory
        SET quantity = quantity - v_final_quantity,
            reserved_quantity = reserved_quantity - v_final_quantity,
            last_updated_at = now()
        WHERE game_account_id = v_order.game_account_id
        AND currency_attribute_id = v_order.currency_attribute_id;
    END IF;

    -- Update inventory for PURCHASE orders (add to stock)
    IF v_order.order_type = 'PURCHASE' AND v_order.game_account_id IS NOT NULL THEN
        INSERT INTO currency_inventory (game_account_id, currency_attribute_id, quantity, avg_buy_price_vnd, avg_buy_price_usd)
        VALUES (v_order.game_account_id, v_order.currency_attribute_id, v_final_quantity, v_final_unit_price, 0)
        ON CONFLICT (game_account_id, currency_attribute_id)
        DO UPDATE SET
            quantity = currency_inventory.quantity + v_final_quantity,
            avg_buy_price_vnd = (
                (currency_inventory.quantity * currency_inventory.avg_buy_price_vnd) +
                (v_final_quantity * v_final_unit_price)
            ) / (currency_inventory.quantity + v_final_quantity),
            last_updated_at = now();
    END IF;

    -- Update order status and financials
    UPDATE currency_orders
    SET status = 'completed',
        completed_at = now(),
        delivered_by = v_user_id,
        completion_notes = p_completion_notes,
        proof_urls = p_proof_urls,
        -- Update with actual values
        quantity = v_final_quantity,
        unit_price_vnd = v_final_unit_price,
        total_price_vnd = v_final_total_revenue,
        total_profit_vnd = v_calculated_profit,
        updated_at = now(),
        updated_by = v_user_id
    WHERE id = p_order_id;

    RETURN QUERY SELECT TRUE, 'Currency order completed successfully', v_transaction_id, v_calculated_profit;
END;
$$;
```

### 2.3 Functions cho Exchange & Transfer Operations

#### Function 5: Perform Currency Exchange (Direct Swap)

```sql
CREATE OR REPLACE FUNCTION public.perform_currency_exchange_v1(
    p_from_game_account_id uuid,
    p_to_game_account_id uuid,
    p_from_currency_id uuid,
    p_to_currency_id uuid,
    p_from_quantity numeric,
    p_to_quantity numeric,
    p_exchange_rate numeric,
    p_game_code text,
    p_league_attribute_id uuid,
    p_notes text DEFAULT NULL
) RETURNS TABLE(
    success boolean,
    message text,
    from_transaction_id uuid,
    to_transaction_id uuid,
    profit_vnd numeric
) LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
    v_user_id uuid := auth.uid();
    v_can_exchange boolean := false;
    v_from_transaction_id uuid;
    v_to_transaction_id uuid;
    v_from_avg_cost numeric;
    v_to_avg_cost numeric;
    v_profit_vnd numeric;
BEGIN
    -- Permission Check (Ops role)
    SELECT EXISTS(
        SELECT 1 FROM user_role_assignments ura
        JOIN attributes ba ON ura.business_area_attribute_id = ba.id
        WHERE ura.user_id = v_user_id
        AND ba.code = 'CURRENCY'
        AND ura.role_name IN ('admin', 'manager', 'ops')
    ) INTO v_can_exchange;

    IF NOT v_can_exchange THEN
        RETURN QUERY SELECT FALSE, 'Permission denied: Cannot perform currency exchange', NULL::UUID, NULL::UUID, NULL;
        RETURN;
    END IF;

    -- Get average costs
    SELECT COALESCE(avg_buy_price_vnd, 0)
    INTO v_from_avg_cost
    FROM currency_inventory
    WHERE game_account_id = p_from_game_account_id
      AND currency_attribute_id = p_from_currency_id;

    SELECT COALESCE(avg_buy_price_vnd, 0)
    INTO v_to_avg_cost
    FROM currency_inventory
    WHERE game_account_id = p_to_game_account_id
      AND currency_attribute_id = p_to_currency_id;

    -- Calculate profit
    v_profit_vnd := (p_to_quantity * v_to_avg_cost) - (p_from_quantity * v_from_avg_cost);

    -- Create outbound transaction
    INSERT INTO currency_transactions (
        game_account_id, game_code, league_attribute_id,
        transaction_type, currency_attribute_id, quantity,
        unit_price_vnd, unit_price_usd,
        target_game_account_id, original_currency_id, target_currency_id,
        exchange_rate, notes, created_by
    ) VALUES (
        p_from_game_account_id, p_game_code, p_league_attribute_id,
        'exchange_out', p_from_currency_id, -p_from_quantity,
        v_from_avg_cost, 0,
        p_to_game_account_id, p_from_currency_id, p_to_currency_id,
        p_exchange_rate,
        COALESCE(p_notes, 'Currency exchange: outbound'),
        v_user_id
    ) RETURNING id INTO v_from_transaction_id;

    -- Create inbound transaction
    INSERT INTO currency_transactions (
        game_account_id, game_code, league_attribute_id,
        transaction_type, currency_attribute_id, quantity,
        unit_price_vnd, unit_price_usd,
        target_game_account_id, original_currency_id, target_currency_id,
        exchange_rate, notes, created_by
    ) VALUES (
        p_to_game_account_id, p_game_code, p_league_attribute_id,
        'exchange_in', p_to_currency_id, p_to_quantity,
        v_to_avg_cost, 0,
        p_from_game_account_id, p_from_currency_id, p_to_currency_id,
        p_exchange_rate,
        COALESCE(p_notes, 'Currency exchange: inbound'),
        v_user_id
    ) RETURNING id INTO v_to_transaction_id;

    -- Update inventory (deduct from source)
    UPDATE currency_inventory
    SET quantity = quantity - p_from_quantity,
        last_updated_at = now()
    WHERE game_account_id = p_from_game_account_id
      AND currency_attribute_id = p_from_currency_id;

    -- Update inventory (add to destination)
    INSERT INTO currency_inventory (game_account_id, currency_attribute_id, quantity, avg_buy_price_vnd)
    VALUES (p_to_game_account_id, p_to_currency_id, p_to_quantity, v_to_avg_cost)
    ON CONFLICT (game_account_id, currency_attribute_id)
    DO UPDATE SET
        quantity = currency_inventory.quantity + p_to_quantity,
        last_updated_at = now();

    RETURN QUERY SELECT TRUE, 'Currency exchange completed successfully', v_from_transaction_id, v_to_transaction_id, v_profit_vnd;
END;
$$;
```

#### Function 6: Transfer Stock Between Accounts (Simplified)

```sql
CREATE OR REPLACE FUNCTION public.transfer_currency_stock_v1(
    p_from_game_account_id uuid,
    p_to_game_account_id uuid,
    p_currency_id uuid,
    p_quantity numeric,
    p_reason text,
    p_description text DEFAULT NULL
) RETURNS TABLE(
    success boolean,
    message text,
    transaction_id uuid
) LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
    v_user_id uuid := auth.uid();
    v_can_transfer boolean := false;
    v_transaction_id uuid;
    v_available_quantity numeric;
    v_transfer_reason text;
BEGIN
    -- Permission Check
    SELECT EXISTS(
        SELECT 1 FROM user_role_assignments ura
        JOIN attributes ba ON ura.business_area_attribute_id = ba.id
        WHERE ura.user_id = v_user_id
        AND ba.code = 'CURRENCY'
        AND ura.role_name IN ('admin', 'manager', 'ops')
    ) INTO v_can_transfer;

    IF NOT v_can_transfer THEN
        RETURN QUERY SELECT FALSE, 'Permission denied: Cannot transfer stock', NULL::UUID;
        RETURN;
    END IF;

    -- Check availability
    SELECT COALESCE(SUM(quantity - reserved_quantity), 0)
    INTO v_available_quantity
    FROM currency_inventory
    WHERE game_account_id = p_from_game_account_id
      AND currency_attribute_id = p_currency_id;

    IF v_available_quantity < p_quantity THEN
        RETURN QUERY SELECT FALSE,
            format('Insufficient stock: Available %s, Required %s', v_available_quantity, p_quantity),
            NULL::UUID;
        RETURN;
    END IF;

    -- Build transfer reason
    v_transfer_reason := COALESCE(p_description, 'Stock transfer between accounts') ||
                       ' (' || p_reason || ')';

    -- Create outbound transaction
    INSERT INTO currency_transactions (
        game_account_id, game_code, league_attribute_id,
        transaction_type, currency_attribute_id, quantity,
        unit_price_vnd, target_game_account_id, notes, created_by
    ) VALUES (
        p_from_game_account_id,
        (SELECT game_code FROM game_accounts WHERE id = p_from_game_account_id),
        (SELECT league_attribute_id FROM game_accounts WHERE id = p_from_game_account_id),
        'transfer', p_currency_id, -p_quantity,
        COALESCE((SELECT avg_buy_price_vnd FROM currency_inventory
                   WHERE game_account_id = p_from_game_account_id
                     AND currency_attribute_id = p_currency_id), 0),
        p_to_game_account_id,
        v_transfer_reason,
        v_user_id
    ) RETURNING id INTO v_transaction_id;

    -- Create inbound transaction
    INSERT INTO currency_transactions (
        game_account_id, game_code, league_attribute_id,
        transaction_type, currency_attribute_id, quantity,
        unit_price_vnd, target_game_account_id, notes, created_by
    ) VALUES (
        p_to_game_account_id,
        (SELECT game_code FROM game_accounts WHERE id = p_to_game_account_id),
        (SELECT league_attribute_id FROM game_accounts WHERE id = p_to_game_account_id),
        'transfer', p_currency_id, p_quantity,
        COALESCE((SELECT avg_buy_price_vnd FROM currency_inventory
                   WHERE game_account_id = p_from_game_account_id
                     AND currency_attribute_id = p_currency_id), 0),
        p_from_game_account_id,
        v_transfer_reason,
        v_user_id
    );

    -- Update source inventory
    UPDATE currency_inventory
    SET quantity = quantity - p_quantity,
        last_updated_at = now()
    WHERE game_account_id = p_from_game_account_id
      AND currency_attribute_id = p_currency_id;

    -- Update destination inventory
    INSERT INTO currency_inventory (game_account_id, currency_attribute_id, quantity, avg_buy_price_vnd)
    SELECT p_to_game_account_id, p_currency_id, p_quantity, avg_buy_price_vnd
    FROM currency_inventory
    WHERE game_account_id = p_from_game_account_id
      AND currency_attribute_id = p_currency_id
    ON CONFLICT (game_account_id, currency_attribute_id)
    DO UPDATE SET
        quantity = currency_inventory.quantity + p_quantity,
        last_updated_at = now();

    RETURN QUERY SELECT TRUE, 'Stock transfer completed successfully', v_transaction_id;
END;
$$;
```

#### Function 7: League Transition (Simplified)

```sql
CREATE OR REPLACE FUNCTION public.transition_currency_league_v1(
    p_game_account_id uuid,
    p_from_league_id uuid,
    p_to_league_id uuid,
    p_reason text
) RETURNS TABLE(
    success boolean,
    message text,
    transitioned_currency_count integer,
    total_value_vnd numeric
) LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
    v_user_id uuid := auth.uid();
    v_can_transition boolean := false;
    v_transitioned_count integer := 0;
    v_total_value numeric := 0;
    currency_to_transition RECORD;
BEGIN
    -- Permission Check
    SELECT EXISTS(
        SELECT 1 FROM user_role_assignments ura
        JOIN attributes ba ON ura.business_area_attribute_id = ba.id
        WHERE ura.user_id = v_user_id
        AND ba.code = 'CURRENCY'
        AND ura.role_name IN ('admin', 'manager', 'ops')
    ) INTO v_can_transition;

    IF NOT v_can_transition THEN
        RETURN QUERY SELECT FALSE, 'Permission denied: Cannot transition league currency', NULL, NULL;
        RETURN;
    END IF;

    -- Process each currency type
    FOR currency_to_transition IN
        SELECT ci.currency_attribute_id, ci.quantity, ci.avg_buy_price_vnd, ci.avg_buy_price_usd
        FROM currency_inventory ci
        WHERE ci.game_account_id = p_game_account_id
          AND ci.league_attribute_id = p_from_league_id
        LOOP
            -- Create outbound transaction from old league
            INSERT INTO currency_transactions (
                game_account_id, game_code, league_attribute_id,
                transaction_type, currency_attribute_id, quantity,
                unit_price_vnd, unit_price_usd,
                original_league_attribute_id, notes, created_by
            ) VALUES (
                p_game_account_id,
                (SELECT game_code FROM game_accounts WHERE id = p_game_account_id),
                p_from_league_id,
                'league_archive_out', currency_to_transition.currency_attribute_id,
                -currency_to_transition.quantity, currency_to_transition.avg_buy_price_vnd,
                currency_to_transition.avg_buy_price_usd,
                p_from_league_id,
                'League transition: from ' || (SELECT name FROM attributes WHERE id = p_from_league_id) ||
                ' to ' || (SELECT name FROM attributes WHERE id = p_to_league_id),
                v_user_id
            );

            -- Create inbound transaction to new league
            INSERT INTO currency_transactions (
                game_account_id, game_code, league_attribute_id,
                transaction_type, currency_attribute_id, quantity,
                unit_price_vnd, unit_price_usd,
                original_league_attribute_id, notes, created_by
            ) VALUES (
                p_game_account_id,
                (SELECT game_code FROM game_accounts WHERE id = p_game_account_id),
                p_to_league_id,
                'league_archive_in', currency_to_transition.currency_attribute_id,
                currency_to_transition.quantity, currency_to_transition.avg_buy_price_vnd,
                currency_to_transition.avg_buy_price_usd,
                p_from_league_id,
                'League transition: from ' || (SELECT name FROM attributes WHERE id = p_from_league_id) ||
                ' to ' || (SELECT name FROM attributes WHERE id = p_to_league_id),
                v_user_id
            );

            -- Update inventory: remove from old league
            DELETE FROM currency_inventory
            WHERE game_account_id = p_game_account_id
              AND currency_attribute_id = currency_to_transition.currency_attribute_id
              AND league_attribute_id = p_from_league_id;

            -- Update inventory: add to new league
            INSERT INTO currency_inventory (
                game_account_id, currency_attribute_id, league_attribute_id,
                quantity, avg_buy_price_vnd, avg_buy_price_usd
            ) VALUES (
                p_game_account_id, currency_to_transition.currency_attribute_id,
                p_to_league_id, currency_to_transition.quantity,
                currency_to_transition.avg_buy_price_vnd, currency_to_transition.avg_buy_price_usd
            )
            ON CONFLICT (game_account_id, currency_attribute_id, league_attribute_id)
            DO UPDATE SET
                quantity = currency_inventory.quantity + currency_to_transition.quantity,
                avg_buy_price_vnd = (
                    (currency_inventory.quantity * currency_inventory.avg_buy_price_vnd) +
                    (currency_to_transition.quantity * currency_to_transition.avg_buy_price_vnd)
                ) / (currency_inventory.quantity + currency_to_transition.quantity),
                avg_buy_price_usd = CASE
                    WHEN currency_to_transition.avg_buy_price_usd > 0 THEN (
                        (currency_inventory.quantity * currency_inventory.avg_buy_price_usd) +
                        (currency_to_transition.quantity * currency_to_transition.avg_buy_price_usd)
                    ) / (currency_inventory.quantity + currency_to_transition.quantity)
                    ELSE currency_inventory.avg_buy_price_usd
                END,
                last_updated_at = now();

            -- Count and total value
            v_transitioned_count := v_transitioned_count + 1;
            v_total_value := v_total_value + (currency_to_transition.quantity * currency_to_transition.avg_buy_price_vnd);
        END LOOP;

    RETURN QUERY SELECT TRUE, 'League transition completed successfully', v_transitioned_count, v_total_value;
END;
$$;
```

### 2.4 Functions cho Query & Reporting

#### Function 8: Get Orders List (Multi-type)

```sql
CREATE OR REPLACE FUNCTION public.get_currency_orders_v1(
    p_order_type currency_order_type_enum DEFAULT NULL,
    p_status currency_order_status_enum DEFAULT NULL,
    p_game_code text DEFAULT NULL,
    p_customer_name text DEFAULT NULL,
    p_date_from date DEFAULT NULL,
    p_date_to date DEFAULT NULL,
    p_limit integer DEFAULT 50,
    p_offset integer DEFAULT 0
) RETURNS TABLE(
    id uuid,
    order_number text,
    order_type currency_order_type_enum,
    status currency_order_status_enum,
    customer_name text,
    currency_name text,
    quantity numeric,
    unit_price_vnd numeric,
    total_price_vnd numeric,
    total_profit_vnd numeric,
    created_at timestamptz,
    completed_at timestamptz,
    assigned_to_name text
) LANGUAGE sql SECURITY DEFINER AS $$
SELECT
    co.id,
    co.order_number,
    co.order_type,
    co.status,
    co.customer_name,
    attr.name as currency_name,
    co.quantity,
    co.unit_price_vnd,
    co.total_price_vnd,
    co.total_profit_vnd,
    co.created_at,
    co.completed_at,
    p.display_name as assigned_to_name
FROM currency_orders co
JOIN attributes attr ON co.currency_attribute_id = attr.id
LEFT JOIN profiles p ON co.assigned_to = p.id
WHERE
    (p_order_type IS NULL OR co.order_type = p_order_type)
    AND (p_status IS NULL OR co.status = p_status)
    AND (p_game_code IS NULL OR co.game_code = p_game_code)
    AND (p_customer_name IS NULL OR co.customer_name ILIKE '%' || p_customer_name || '%')
    AND (p_date_from IS NULL OR DATE(co.created_at) >= p_date_from)
    AND (p_date_to IS NULL OR DATE(co.created_at) <= p_date_to)
    -- Add permission-based filtering here
ORDER BY co.created_at DESC
LIMIT p_limit OFFSET p_offset;
$$;
```

#### Function 9: Create Discrepancy Report

```sql
CREATE OR REPLACE FUNCTION public.create_discrepancy_report_v1(
    p_game_account_id uuid,
    p_currency_id uuid,
    p_expected_quantity numeric,
    p_actual_quantity numeric,
    p_title text,
    p_description text,
    p_category text DEFAULT 'shortage',
    p_priority_level integer DEFAULT 3,
    p_evidence_urls text[] DEFAULT NULL,
    p_internal_notes text DEFAULT NULL
) RETURNS TABLE(
    success boolean,
    message text,
    report_id uuid,
    discrepancy_amount numeric,
    discrepancy_value_vnd numeric
) LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
    v_user_id uuid := auth.uid();
    v_report_id uuid;
    v_can_report boolean := false;
BEGIN
    -- Permission Check (any currency role can report)
    SELECT EXISTS(
        SELECT 1 FROM user_role_assignments ura
        JOIN attributes ba ON ura.business_area_attribute_id = ba.id
        WHERE ura.user_id = v_user_id
        AND ba.code = 'CURRENCY'
    ) INTO v_can_report;

    IF NOT v_can_report THEN
        RETURN QUERY SELECT FALSE, 'Permission denied: Cannot create discrepancy report', NULL::UUID, NULL, NULL;
        RETURN;
    END IF;

    -- Create report
    INSERT INTO currency_discrepancy_reports (
        reporter_profile_id, game_account_id, currency_attribute_id,
        expected_quantity, actual_quantity,
        title, description, category, priority_level,
        evidence_urls, internal_notes, created_by
    ) VALUES (
        v_user_id, p_game_account_id, p_currency_id,
        p_expected_quantity, p_actual_quantity,
        p_title, p_description, p_category, p_priority_level,
        p_evidence_urls, p_internal_notes, v_user_id
    ) RETURNING id INTO v_report_id;

    RETURN QUERY SELECT
        TRUE,
        'Discrepancy report created successfully',
        v_report_id,
        p_expected_quantity - p_actual_quantity,
        (p_expected_quantity - p_actual_quantity) * COALESCE((
            SELECT avg_buy_price_vnd FROM currency_inventory
            WHERE game_account_id = p_game_account_id
              AND currency_attribute_id = p_currency_id
        ), 0);
END;
$$;
```

### 1.4 SLA Monitoring & Alert System

```sql
-- System Auto-Alert Configuration
-- 1. SLA Breach Alerts
CREATE OR REPLACE FUNCTION check_currency_order_sla_breach()
RETURNS void AS $$
DECLARE
    order_record RECORD;
BEGIN
    -- Check for SLA breaches (> 1 hour from deadline)
    FOR order_record IN
        SELECT id, order_number, assigned_to, created_at, deadline_at
        FROM currency_orders
        WHERE status IN ('pending', 'assigned', 'preparing', 'ready', 'delivering')
        AND deadline_at < now() - interval '1 hour'
        AND sla_breach_notified = false
    LOOP
        -- Update SLA status
        UPDATE currency_orders
        SET sla_status = 'breached',
            sla_breach_notified = true,
            updated_at = now()
        WHERE id = order_record.id;

        -- TODO: Send notification to management
        -- (Implementation depends on notification system)

        -- Log SLA breach
        INSERT INTO audit_logs (
            table_name, record_id, action, details, created_by
        ) VALUES (
            'currency_orders', order_record.id, 'sla_breach',
            format('Order %s breached SLA. Assigned to: %s',
                   order_record.order_number, order_record.assigned_to),
            'system'
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- 2. Inventory Anomaly Detection Alerts
CREATE OR REPLACE FUNCTION detect_inventory_anomalies()
RETURNS TABLE(
    game_account_id uuid,
    currency_id uuid,
    alert_type text,
    details jsonb
) AS $$
BEGIN
    RETURN QUERY
    -- Alert 1: Negative quantity > 1 hour
    SELECT
        ci.game_account_id,
        ci.currency_attribute_id,
        'negative_quantity' as alert_type,
        jsonb_build_object(
            'quantity', ci.quantity,
            'duration_hours', EXTRACT(epoch FROM (now() - ci.last_updated_at))/3600,
            'avg_price', ci.avg_buy_price_vnd
        ) as details
    FROM currency_inventory ci
    WHERE ci.quantity < 0
    AND ci.last_updated_at < now() - interval '1 hour';

    -- Alert 2: Price fluctuation > 20% from last 10 transactions
    SELECT
        ct.game_account_id,
        ct.currency_attribute_id,
        'price_volatility' as alert_type,
        jsonb_build_object(
            'current_price', ct.unit_price_vnd,
            'avg_last_10', avg_price.last_10_avg,
            'volatility_percent', ABS((ct.unit_price_vnd - avg_price.last_10_avg) / avg_price.last_10_avg * 100)
        ) as details
    FROM currency_transactions ct
    JOIN (
        SELECT
            currency_attribute_id,
            game_account_id,
            AVG(unit_price_vnd) as last_10_avg
        FROM currency_transactions
        WHERE created_at >= now() - interval '7 days'
        AND unit_price_vnd > 0
        GROUP BY currency_attribute_id, game_account_id
        HAVING COUNT(*) >= 10
    ) avg_price ON ct.currency_attribute_id = avg_price.currency_attribute_id
                  AND ct.game_account_id = avg_price.game_account_id
    WHERE ct.created_at >= now() - interval '1 hour'
    AND ABS((ct.unit_price_vnd - avg_price.last_10_avg) / avg_price.last_10_avg) > 0.2;

    -- Alert 3: High discrepancy rate (>5 discrepancies per trader)
    SELECT DISTINCT
        cdr.game_account_id,
        cdr.currency_attribute_id,
        'high_discrepancy_rate' as alert_type,
        jsonb_build_object(
            'discrepancy_count', discrepancy_count.count,
            'trader', p.display_name
        ) as details
    FROM currency_discrepancy_reports cdr
    JOIN profiles p ON cdr.reporter_profile_id = p.id
    JOIN (
        SELECT reporter_profile_id, COUNT(*) as count
        FROM currency_discrepancy_reports
        WHERE created_at >= now() - interval '24 hours'
        GROUP BY reporter_profile_id
        HAVING COUNT(*) >= 5
    ) discrepancy_count ON cdr.reporter_profile_id = discrepancy_count.reporter_profile_id;
END;
$$ LANGUAGE plpgsql;

-- 3. Inventory Reconciliation Alert
CREATE OR REPLACE FUNCTION detect_inventory_reconciliation_issues()
RETURNS TABLE(
    game_account_id uuid,
    currency_id uuid,
    alert_type text,
    details jsonb
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        ci.game_account_id,
        ci.currency_attribute_id,
        'reconciliation_needed' as alert_type,
        jsonb_build_object(
            'last_transaction', last_tx.last_transaction_date,
            'days_since_last', EXTRACT(days FROM (now() - last_tx.last_transaction_date)),
            'current_quantity', ci.quantity
        ) as details
    FROM currency_inventory ci
    JOIN (
        SELECT
            game_account_id,
            currency_attribute_id,
            MAX(created_at) as last_transaction_date
        FROM currency_transactions
        GROUP BY game_account_id, currency_attribute_id
    ) last_tx ON ci.game_account_id = last_tx.game_account_id
               AND ci.currency_attribute_id = last_tx.currency_attribute_id
    WHERE last_tx.last_transaction_date < now() - interval '1 day';
END;
$$ LANGUAGE plpgsql;

-- 4. Schedule alerts (run every 5 minutes)
-- This would be implemented via cron jobs or Supabase Edge Functions
```

---

## 🔄 PHẦN 3: WORKFLOW IMPLEMENTATION

### 3.1 Sales Workflow (CREATE SELL ORDER)

```sql
-- Step 1: Create order (draft)
SELECT * FROM create_currency_order_v1(
    'SALE', -- order_type
    'chaos-orb-uuid', -- currency_attribute_id
    100, -- quantity
    1500, -- unit_price_vnd
    0.058, -- unit_price_usd
    'POE_2', -- game_code
    'ea-standard-uuid', -- league_attribute_id
    'TuanAnh', -- customer_name
    'ZizCharacter', -- customer_game_tag
    'discord.com/...', -- delivery_info
    'g2g-channel-uuid', -- channel_id
    NULL, -- supplier_party_id (N/A for sale)
    NULL, -- supplier_notes
    NULL, -- game_account_id (Ops sẽ chọn sau)
    'items', -- exchange_type
    'Ring name', -- exchange_details
    ARRAY['image1.jpg', 'image2.jpg'], -- exchange_images
    'Khách hàng quen, priority cao', -- sales_notes
    2, -- priority_level
    12 -- deadline_hours
);

-- Step 2: Submit order
SELECT * FROM submit_currency_order_v1('order-uuid-here', 'Submit notes here');
```

### 3.2 Ops Workflow (PROCESS & COMPLETE)

```sql
-- Step 3: Ops nhận đơn
SELECT * FROM process_currency_order_v1(
    'order-uuid-here',
    'Nhận đơn, chuẩn bị từ kho POE2-Account1',
    'poe2-account1-uuid' -- Ops chọn account
);

-- Step 4: Ops hoàn thành
SELECT * FROM complete_currency_order_v1(
    'order-uuid-here',
    'Giao hàng thành công, khách đã nhận',
    ARRAY['screenshot1.jpg', 'screenshot2.jpg'],
    100, -- actual_quantity (có thể khác)
    1500 -- actual_unit_price_vnd (có thể khác)
);
```

### 3.3 Purchase Workflow (CREATE BUY ORDER)

```sql
-- Tạo đơn mua từ supplier
SELECT * FROM create_currency_order_v1(
    'PURCHASE', -- order_type
    'divine-orb-uuid',
    20,
    50000, -- Giá mua
    1.94,
    'POE_2',
    'ea-standard-uuid',
    NULL, -- customer_info (N/A for purchase)
    NULL, NULL, NULL, NULL,
    'supplier-uuid', -- supplier_party_id
    'Supplier uy tín, deal tốt',
    'farm-account-uuid', -- Account để nhận currency
    'none',
    NULL, NULL,
    'Mua lúa để bán Tết',
    1, -- High priority
    48 -- 48 giờ deadline
);
```

---

## 🔐 PHẦN 4: SECURITY & PERMISSIONS

### 4.1 RLS Policies

```sql
-- Enable RLS
ALTER TABLE public.currency_orders ENABLE ROW LEVEL SECURITY;

-- Policy 1: Sales staff có thể tạo/view orders của mình
CREATE POLICY "Sales can manage their currency orders" ON public.currency_orders
    FOR ALL USING (
        auth.uid() = created_by OR
        EXISTS (
            SELECT 1 FROM user_role_assignments ura
            JOIN attributes ba ON ura.business_area_attribute_id = ba.id
            WHERE ura.user_id = auth.uid()
            AND ba.code = 'CURRENCY'
            AND ura.role_name IN ('admin', 'manager')
        )
    );

-- Policy 2: Ops staff có thể view và process orders
CREATE POLICY "Ops can view and process currency orders" ON public.currency_orders
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM user_role_assignments ura
            JOIN attributes ba ON ura.business_area_attribute_id = ba.id
            WHERE ura.user_id = auth.uid()
            AND ba.code = 'CURRENCY'
            AND ura.role_name IN ('admin', 'manager', 'ops')
        )
    );

-- Policy 3: Read-only cho reporting
CREATE POLICY "Read access for currency reports" ON public.currency_orders
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM user_role_assignments ura
            JOIN attributes ba ON ura.business_area_attribute_id = ba.id
            WHERE ura.user_id = auth.uid()
            AND ba.code = 'CURRENCY'
        )
    );
```

### 4.2 Function Permissions

```sql
-- Grant permissions
GRANT ALL ON FUNCTION public.create_currency_order_v1 TO authenticated;
GRANT ALL ON FUNCTION public.submit_currency_order_v1 TO authenticated;
GRANT ALL ON FUNCTION public.process_currency_order_v1 TO authenticated;
GRANT ALL ON FUNCTION public.complete_currency_order_v1 TO authenticated;
GRANT ALL ON FUNCTION public.get_currency_orders_v1 TO authenticated;
```

---

## 🎯 PHẦN 5: IMPLEMENTATION PLAN

### 5.1 Migration Steps

1. **Create Enums**
2. **Create currency_orders table**
3. **Add indexes and constraints**
4. **Create triggers**
5. **Create RPC functions**
6. **Setup RLS policies**
7. **Grant permissions**

### 5.2 Frontend Integration

#### CurrencyForm.vue Updates:
```javascript
// Add support for order_type prop
interface Props {
  orderType?: 'purchase' | 'sale' | 'exchange'
  // ... existing props
}

// Update validation based on order_type
const validateForm = () => {
  const errors = []

  if (props.orderType === 'sale') {
    if (!customerFormData.customerName) errors.push('Required customer name')
    if (!customerFormData.gameTag) errors.push('Required game tag')
    // Account field optional for sales
  } else if (props.orderType === 'purchase') {
    if (!formData.gameAccountId) errors.push('Required account for purchase')
    // Customer info optional for purchases
  }

  return errors
}
```

#### New Pages:
- `CurrencyPurchase.vue` - For buying from suppliers
- `CurrencyOps.vue` - For processing orders
- `CurrencyExchange.vue` - For currency exchanges

### 5.3 Testing Strategy

1. **Unit Tests**: Mỗi RPC function
2. **Integration Tests**: Workflow end-to-end
3. **Permission Tests**: Role-based access
4. **Performance Tests**: Large volume queries

---

## 📊 PHẦN 6: KEY BENEFITS

### 6.1 Business Benefits
- ✅ **Unified System**: Mua, bán, exchange trong cùng 1 table
- ✅ **Workflow Clarity**: Status tracking rõ ràng
- ✅ **Profit Foundation**: Sẵn sàng cho profit calculation
- ✅ **Audit Trail**: Full history và proof tracking

### 6.2 Technical Benefits
- ✅ **Scalable**: Dễ mở rộng thêm types
- ✅ **Performant**: Indexes tối ưu cho queries
- ✅ **Secure**: RLS policies chi tiết
- ✅ **Maintainable**: Clean architecture và business logic

### 6.3 Operational Benefits
- ✅ **Role Separation**: Sales vs Ops rõ ràng
- ✅ **Flexible Processing**: Ops có thể chọn account phù hợp
- ✅ **SLA Tracking**: Deadline và priority management
- ✅ **Quality Control**: Proof và verification

---

## 🚀 PHẦN 7: NEXT STEPS

1. **Review & Approve**: Team review design này
2. **Create Migration Files**: Tạo SQL migration scripts
3. **Implement Frontend**: Cập nhật components và pages
4. **Testing**: Test trên staging environment
5. **Documentation**: Update user guides
6. **Deploy**: Production deployment theo CURRENCY-DEPLOYMENT-GUIDE.md

---

**🎯 Design Ready for Implementation!**

**Status:** ✅ Complete
**Priority:** 🔥 High
**Dependencies:** Database migration completion