# 🚀 KẾ HOẠCH TRIỂN KHAI COMPREHENSIVE
## Hệ thống Currency Management theo Weighted Average Cost

---

## 📋 PHÂN TÍCH YÊU CẦU CUỐI CÙNG

### ✅ Điều kiện lý tưởng cho triển khai
- **Không legacy data burden**: Có thể xây dựng từ zero
- **Flexibility cao**: Admin có thể config processes sau
- **Team size 1**: Focus vào single developer path
- **Parallel running**: Có thể test và refine gradually

### 🎯 Quyết định kiến trúc dựa trên input của bạn và investigation thực tế
1. **BusinessProcesses**: Flat structure, admin-configurable
2. **Channel simplification**: Channels table ĐÃ CÓ đủ fee structure (purchase_fee_rate, purchase_fee_fixed, sale_fee_rate, sale_fee_fixed)
3. **Assignment Logic**: Version 1.0 đơn giản (chỉ shift + channel permissions)
4. **Financial**: Unit cost = purchase cost only, other fees for profit calc

## 📊 **OVERALL PROGRESS: 60% COMPLETE**

### ✅ **Week 1-2: Foundation (100% Complete)**
- Database schema implementation ✅
- Initial data seeding ✅
- Documentation & planning ✅
- Database cleanup & structure optimization ✅

### 🔄 **Week 3-4: Core Logic (90% Complete)**
- Backend API development (90%) 🔄 **Purchase Order Flow ✅, Sale Order Flow ✅**
- Assignment engine (90%) 🔄 **Purchase assignment ✅, Sale assignment ✅, Game compatibility ✅**
- Financial calculations (90%) 🔄 **WAC calculation ✅, Profit calculation ✅, Game-Server validation ✅**
- Database structure optimization ✅ **currency_inventory restructure ✅, duplicate tables removed ✅**

### ❌ **Week 5-6: Integration (Not Started)**
- Frontend components (0%) ❌
- Testing & validation (0%) ❌

### ❌ **Week 7-8: Production (Not Started)**
- Parallel running (0%) ❌
- Optimization (0%) ❌
- Deployment (0%) ❌

---

## 🔄 TWO MAIN BUSINESS FLOWS (UPDATED)

### Flow 1: Purchase Order Process
**Mục tiêu**: Nhập hàng và tính lại giá vốn trung bình (WAC)

```
Step 1: Form Creation → Step 2: Employee Assignment → Step 3: Stock & WAC Update
```

1. **Form Creation**: User tạo đơn (currency, quantity, unit cost, channel) → Status: DRAFT
2. **Employee Assignment**: Hệ thống phân công nhân viên phù hợp → Status: ASSIGNED
3. **Stock & WAC Update**: Nhân viên hoàn thành → Hệ thống tính WAC → Status: COMPLETED

### Flow 2: Sale Order Process
**Mục tiêu**: Bán hàng và tính toán lợi nhuận

```
Step 1: Order Creation → Step 2: Delivery Assignment → Step 3: Stock Update → Step 4: Profit Calculation
```

1. **Order Creation**: User tạo đơn bán hàng (currency, quantity, sale price, channel) → Status: DRAFT
2. **Delivery Assignment**: Hệ thống tìm inventory và phân công nhân viên giao hàng → Status: ASSIGNED
3. **Stock Update**: Nhân viên hoàn thành giao hàng → Trừ tồn kho → Status: COMPLETED
4. **Profit Calculation**: Hệ thống tính lợi nhuận (Doanh thu - COGS - Phí)

## 🎉 **PURCHASE ORDER FLOW - FULLY IMPLEMENTED!**

### ✅ **Completed Features (November 1, 2025)**
- **Database Triggers**: Auto-create inventory pools when game accounts/currencies activated
- **3-Step Purchase Flow**:
  1. `create_purchase_order_draft()` - Creates PO with DRAFT status
  2. `assign_purchase_order()` - Round-robin employee assignment with game compatibility
  3. `complete_purchase_order()` - WAC calculation & inventory update with game-server mapping
- **WAC Calculation**: `(OldQty × OldWAC + NewQty × NewUnitCost) / (Old + New)`
- **Game-Server Relationships**: Complete hierarchical mapping validation
- **Test Results**:
  - PO20251031-0004: DIABLO_4 Gold @ SOFTCORE_ETERNAL_D4 server
  - PO20251031-0006: POE_1 Chaos Orb @ STANDARD_STANDARD_POE1 server
  - PO20251031-0007: NEW_WORLD Gold (no server concept)

### 🔧 **Technical Implementation**
- **Functions**: 4 core functions (create, assign, complete, get details)
- **Assignment Logic**: Shift + channel permissions + game compatibility + round-robin trackers
- **Inventory Management**: Real-time WAC updates with game-server context
- **Game-Server Validation**: Complete hierarchical relationship integrity
- **Audit Trail**: Complete transaction history with timestamps and game-server context

## 🎉 **SALE ORDER FLOW - FULLY IMPLEMENTED!**

### ✅ **Completed Features (November 1, 2025)**
- **4-Step Sale Flow**:
  1. `create_sale_order_draft()` - Creates sale order with DRAFT status (allows negative inventory)
  2. `assign_sale_order()` - Round-robin employee assignment with game compatibility
  3. `complete_sale_order_delivery()` - Inventory update and transaction creation (allows negative quantities)
  4. `calculate_sale_order_profit()` - Profit calculation using weighted average cost and order completion
- **Business Logic Compliance**: Supports negative inventory per business requirements - "business flow cho phép khi bán hàng có thể đưa qty về âm nếu không đủ hàng"
- **Profit Calculation**: `Profit = Sale Revenue - COGS - Channel Fees` using weighted average cost from inventory
- **Helper Function**: `check_sale_order_inventory_status()` - Check inventory availability across all accounts

### 🔧 **Technical Implementation**
- **Functions**: 5 core functions (create, assign, deliver, calculate profit, check inventory)
- **Assignment Logic**: Shift + channel permissions + game compatibility + round-robin trackers
- **Inventory Management**: Allows negative quantities per business flow requirements
- **Profit Calculation**: Uses weighted average cost from inventory pools
- **Audit Trail**: Complete transaction history with profit/loss tracking
- **Currency Orders Integration**: Works with existing `currency_orders` table structure

### 📋 **Sale Order Status Flow**
```
DRAFT → ASSIGNED → DELIVERING → COMPLETED
```

### 🚀 **NEXT PRIORITY: FRONTEND INTEGRATION**
Implement Vue.js components for both Purchase and Sale Order Flows

### 🚀 **PREVIOUS PRIORITY: SALE ORDER FLOW** ✅
✅ **COMPLETED** - Implemented 4-step sale process: Order Creation → Delivery Assignment → Stock Update → Profit Calculation

### 🔍 **PHÁT HIỆN QUAN TRỌNG TỪ INVESTIGATION SUPABASE**
#### **Database Structure Analysis:**
- **currency_inventory table**: Có UNIQUE constraint phức tạp → Sẽ tạo **inventory_pools** mới theo đúng bản thảo
- **channels table**: ĐÃ CÓ fee structure NHƯNG cần **transaction_fee_id** để fit business flow
- **attributes table**: ĐÃ CÓ GAME, GAME_CURRENCY, GAME_SERVER → Perfect mapping cho GameItems
- **account_shift_assignments**: ĐÃ CÓ nhưng cần **assigned_game_account_id** cho business flow

#### **QUYẾT ĐỊNH QUAN TRỌNG - ÁP DỤNG TRIỆT ĐỂ BẢN THẢO:**
1. **Áp dụng 100% business flow** từ bản thảo docs\Curencyops pland.md
2. **Tạo database schema FIT HOÀN HẢO** với 3 nhóm bảng theo bản thảo
3. **Không thay đổi existing logic** - Chỉ enhance để support flow mới
4. **Channels table**: Cần thêm **transaction_fee_id** để link với Fees table
5. **Fees table**: Bắt buộc tạo mới - CORE của financial system
6. **InventoryPools**: Bảng cốt lõi theo đúng bản thảo (AccountID + GameItemID + ProcessID)

---

## 🗓️ TIMELINE TRIỂN KHAI (6-8 WEEKS)

### 🔴 WEEK 1-2: FOUNDATION & DATABASE
**Mục tiêu**: Có schema database hoàn chỉnh và basic CRUD APIs

#### Phase 1.1: Database Schema (3-4 ngày)
```sql
-- NHÓM 1: Vận hành & Nhân sự (Theo bản thảo)
1. fees (Phí chi tiết) - TABLE MỚI - CỐT LÕI
2. business_processes (Quy trình kinh doanh/Stock Pool) - TABLE MỚI - CỐT LÕI
3. shift_role_assignments (Phân công vai trò mua) - TABLE MỚI
4. assignment_trackers (Bộ nhớ phân công tuần tự) - TABLE MỚI
5. inventory_pools (Kho tổng hợp theo Pool) - TABLE MỚI - CỐT LÕI

-- NHÓM 2: Enhancement tables hiện có
6. channels (thay thế 6 cột fee bằng 1 cột transaction_fee_id) - TABLE CŨ UPDATE
7. account_shift_assignments (thêm assigned_game_account_id) - TABLE CŨ UPDATE
8. process_fees_map (Phí bổ sung của quy trình) - TABLE MỚI
```

#### Phase 1.2: Basic APIs (3-4 ngày)
```typescript
// API endpoints cần implement theo business flow

// Management APIs
- POST/GET/PUT/DELETE /api/fees (QUẢN LÝ PHÍ)
- POST/GET/PUT/DELETE /api/business-processes (QUẢN LÝ QUY TRÌNH)
- POST/GET/PUT/DELETE /api/inventory-pools (QUẢN LÝ KHO THEO POOL)
- GET/POST /api/assignment-trackers (ROUND-ROBIN LOGIC)
- POST /api/shift-role-assignments (PHÂN CÔNG VAI TRÒ)

// Purchase Order Flow APIs
- POST /api/purchase-orders (Tạo đơn mua hàng)
- POST /api/purchase-orders/:id/assign (Phân công nhân viên)
- POST /api/purchase-orders/:id/complete (Hoàn thành & cập nhật WAC)

// Sale Order Flow APIs
- POST /api/sale-orders (Tạo đơn bán hàng)
- POST /api/sale-orders/:id/assign (Phân công giao hàng)
- POST /api/sale-orders/:id/complete-delivery (Hoàn thành giao hàng)
- POST /api/sale-orders/:id/calculate-profit (Tính toán lợi nhuận)
```

#### Phase 1.3: Management UI (remaining days)
```vue
// Components cần build theo business flow
- FeeManager.vue (Quản lý phí chi tiết) - CRITICAL
- BusinessProcessManager.vue (Quản lý quy trình kinh doanh) - CRITICAL
- ProcessFeeMapper.vue (Map phí bổ sung vào quy trình) - IMPORTANT
- InventoryPoolDashboard.vue (Hiển thị kho theo Pool + WAC) - CRITICAL
- AssignmentTracker.vue (Theo dõi phân công tuần tự) - IMPORTANT
```

---

### 🟡 WEEK 3-4: CORE LOGIC IMPLEMENTATION
**Mục tiêu**: Hoàn thiện assignment engine và financial calculations

#### Phase 2.1: Purchase Order Flow Engine (4-5 ngày)
```typescript
interface PurchaseOrderFlow {
  // Flow 1: Form 1: Tạo đơn -> Flow 2: Phân công nhân viên -> Flow 3: Cập nhật stock WAC

  // **Step 1: Form 1: Tạo đơn**
  // - User tạo đơn: currency, quantity, unit cost, channel
  // - System validate và tạo đơn draft

  // **Step 2: Phân công nhân viên thực hiện đơn hàng**
  // - Tìm nhân viên phù hợp: shift + channel permissions + round-robin
  // - Xác định game account của nhân viên
  // - Giao task cho nhân viên
  // - Status: DRAFT → ASSIGNED

  // **Step 3: Cập nhật stock giá vốn trung bình**
  // - Nhân viên hoàn thành đơn → nhập hàng vào game account
  // - Tính WAC: (Old Quantity × Old WAC + New Quantity × New Unit Cost) / (Old + New)
  // - UPDATE inventory_pools với quantity và average_cost mới
  // - Status: ASSIGNED → COMPLETED
}
```

#### Phase 2.2: WAC Calculation Service (3-4 ngày)
```typescript
interface WACService {
  calculateNewAverageCost(params: {
    oldQuantity: number;
    oldAverageCost: number;
    newQuantity: number;
    newUnitCost: number;
    purchaseFee: number;
  }): {
    newAverageCost: number;
    totalCost: number;
  };
}
```

#### Phase 2.3: Sale Order Flow Engine (4-5 ngày)
```typescript
interface SaleOrderFlow {
  // Flow 1: Tạo đơn -> Flow 2: Phân công giao hàng -> Flow 3: Cập nhật stock -> Flow 4: Tính toán lợi nhuận

  // **Step 1: Tạo đơn**
  // - User tạo đơn bán hàng: currency, quantity, sale price, channel
  // - System validate và tạo đơn draft

  // **Step 2: Phân công giao hàng**
  // - User chọn channel → System tìm inventory trong pools
  // - Round-robin chọn pool có đủ hàng
  // - Tìm account có đủ hàng trong selected pool
  // - Phân công nhân viên đang giữ account đó
  // - Status: DRAFT → ASSIGNED

  // **Step 3: Cập nhật stock**
  // - Nhân viên hoàn thành giao hàng
  // - UPDATE inventory_pools: Quantity -= quantity (AverageCost không đổi)
  // - Status: ASSIGNED → COMPLETED

  // **Step 4: Tính toán lợi nhuận**
  // - Tính COGS: Quantity × AverageCost
  // - Tính lợi nhuận: Doanh thu - COGS - Channel Fee - Process Fees
  // - Lưu lại profit calculation cho reporting
}
```

---

### 🟢 WEEK 5-6: FRONTEND & INTEGRATION
**Mục tiêu**: Hoàn thiện UI và kết hợp tất cả components

#### Phase 3.1: Enhanced Currency Forms (4-5 ngày)
```vue
// Upgrade existing components
- CurrencyForm.vue (thêm process selection)
- CurrencyInventoryPanel.vue (hiển thị WAC + process filtering)
- Enhanced transaction history với cost breakdown
```

#### Phase 3.2: Management Dashboard (3-4 ngày)
```vue
// New management components
- AssignmentDashboard.vue (real-time assignments)
- CurrencyAnalytics.vue (WAC visualization)
- ProcessPerformance.vue (profit analytics)
```

#### Phase 3.3: Integration Testing (remaining days)
- End-to-end order flow testing
- Assignment accuracy validation
- Financial calculation verification

---

### 🔵 WEEK 7-8: PARALLEL RUNNING & REFINEMENT
**Mục tiêu**: Chạy song song với system cũ và refine

#### Phase 4.1: Parallel Running Setup (3-4 ngày)
- Feature flags để toggle old/new logic
- Side-by-side comparison dashboard
- Data consistency checks

#### Phase 4.2: Bug Fixes & Optimization (3-4 ngày)
- Performance optimization
- UI/UX refinements
- Edge case handling

---

## 📝 DETAILED TASK BREAKDOWN THEO BẢN THẢO

### 🗄️ DATABASE SCHEMA TASKS

#### Task 1.1: Create Fees Table (PHÍ CHI TIẾT) - CỐT LÕI
```sql
-- Theo đúng bản thảo: Fees (Phí Chi tiết)
CREATE TABLE fees (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT UNIQUE NOT NULL, -- "PHI_SAN_A", "THUE_10", etc.
    name TEXT NOT NULL, -- "Phí Sàn A", "Thuế 10%"
    direction TEXT NOT NULL CHECK (direction IN ('BUY', 'SELL', 'WITHDRAW', 'TAX', 'OTHER')),
    fee_type TEXT NOT NULL CHECK (fee_type IN ('RATE', 'FIXED')),
    amount DECIMAL(18,8) NOT NULL CHECK (amount >= 0), -- 0.05 hoặc 10000
    currency TEXT DEFAULT 'VND' CHECK (currency IN ('VND', 'USD', 'EUR', 'GBP', 'JPY', 'CNY', 'KRW', 'SGD', 'AUD', 'CAD')),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT now(),
    created_by UUID REFERENCES profiles(id)
);
```

#### Task 1.2: Create BusinessProcesses Table (QUY TRÌNH KINH DOANH) - CỐT LÕI
```sql
-- Theo đúng bản thảo: BusinessProcesses (Stock Pool) - Simplified version
CREATE TABLE business_processes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT UNIQUE NOT NULL, -- "P_A_B", "P_C_D", etc.
    name TEXT NOT NULL, -- "Mua Sàn A - Bán Sàn B"
    description TEXT, -- Mô tả quy trình kinh doanh
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT now(),
    created_by UUID REFERENCES profiles(id)
);
```

#### Task 1.3: Create InventoryPools Table (KHO TỔNG HỢP) - CỐT LÕI
```sql
-- Theo đúng bản thảo: InventoryPools (Kho Tổng hợp theo Pool)
CREATE TABLE inventory_pools (
    game_account_id UUID REFERENCES game_accounts(id) NOT NULL,
    currency_attribute_id UUID REFERENCES attributes(id) NOT NULL, -- GameItem mapping
    process_id UUID REFERENCES business_processes(id) NOT NULL,
    quantity DECIMAL(18,8) DEFAULT 0 CHECK (quantity >= 0),
    average_cost DECIMAL(18,8) DEFAULT 0 CHECK (average_cost >= 0),
    cost_currency TEXT DEFAULT 'VND' CHECK (cost_currency IN ('VND', 'USD', 'EUR', 'GBP', 'JPY', 'CNY', 'KRW', 'SGD', 'AUD', 'CAD')),
    last_updated_at TIMESTAMP DEFAULT now(),
    last_updated_by UUID REFERENCES profiles(id),
    PRIMARY KEY (game_account_id, currency_attribute_id, process_id) -- Đúng theo bản thảo
);
```

#### Task 1.4: Create AssignmentTrackers Table (BỘ NHỚ PHÂN CÔNG)
```sql
-- Theo đúng bản thảo: AssignmentTrackers (Bộ nhớ Phân công Tuần tự)
CREATE TABLE assignment_trackers (
    tracker_type TEXT PRIMARY KEY, -- "BUY_KENH_A", "SELL_POOL_GAMEITEM_123"
    last_assigned_id UUID NOT NULL,
    updated_at TIMESTAMP DEFAULT now()
);
```

#### Task 1.5: Create ShiftRoleAssignments Table (PHÂN CÔNG VAI TRÒ MUA)
```sql
-- Theo đúng bản thảo: ShiftRoleAssignments (Phân công Vai trò Mua)
CREATE TABLE shift_role_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    employee_profile_id UUID REFERENCES profiles(id) NOT NULL,
    purchase_channel_id UUID REFERENCES channels(id) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT now(),
    UNIQUE(employee_profile_id, purchase_channel_id)
);
```

#### Task 1.6: Create ProcessFeesMap Table (PHÍ BỔ SUNG CỦA QUY TRÌNH)
```sql
-- Theo đúng bản thảo: Process_OtherFees_Map (Phí Bổ sung của Quy trình)
CREATE TABLE process_fees_map (
    process_id UUID REFERENCES business_processes(id) ON DELETE CASCADE,
    fee_id UUID REFERENCES fees(id) ON DELETE CASCADE,
    PRIMARY KEY (process_id, fee_id)
);
```

#### Task 1.7: Update Existing Tables
```sql
-- Thay thế 6 cột fee hiện tại bằng 1 cột transaction_fee_id
ALTER TABLE channels
DROP COLUMN IF EXISTS purchase_fee_rate,
DROP COLUMN IF EXISTS purchase_fee_fixed,
DROP COLUMN IF EXISTS purchase_fee_currency,
DROP COLUMN IF EXISTS sale_fee_rate,
DROP COLUMN IF EXISTS sale_fee_fixed,
DROP COLUMN IF EXISTS sale_fee_currency,
DROP COLUMN IF EXISTS fee_updated_at,
DROP COLUMN IF EXISTS fee_updated_by;

-- Thêm 1 cột mới cho fee mapping (direction xác định trong fees table)
ALTER TABLE channels
ADD COLUMN transaction_fee_id UUID REFERENCES fees(id);

-- Thêm assigned_game_account_id vào account_shift_assignments
ALTER TABLE account_shift_assignments ADD COLUMN assigned_game_account_id UUID REFERENCES game_accounts(id);
```

### ⚙️ BACKEND API TASKS THEO BUSINESS FLOW

#### Task 2.1: FeesService (QUẢN LÝ PHÍ) - CỐT LÕI
```typescript
class FeesService {
  async createFee(data: CreateFeeDTO): Promise<Fee>
  async updateFee(id: UUID, data: UpdateFeeDTO): Promise<Fee>
  async deleteFee(id: UUID): Promise<void>
  async getFees(filters?: FeeFilters): Promise<Fee[]>
  async getFeesByDirection(direction: 'BUY' | 'SELL' | 'WITHDRAW' | 'TAX' | 'OTHER'): Promise<Fee[]>
}
```

#### Task 2.2: BusinessProcessService (QUẢN LÝ QUY TRÌNH) - CỐT LÕI
```typescript
class BusinessProcessService {
  async createProcess(data: CreateProcessDTO): Promise<BusinessProcess>
  async updateProcess(id: UUID, data: UpdateProcessDTO): Promise<BusinessProcess>
  async deleteProcess(id: UUID): Promise<void>
  async getProcesses(filters?: ProcessFilters): Promise<BusinessProcess[]>
  async assignProcessFees(processId: UUID, feeIds: UUID[]): Promise<void>
  // Channels sẽ được selected động dựa trên logic business, không hardcoded
}
```

#### Task 2.3: PurchaseOrderFlowEngine (LUỒNG MUA HÀNG) - CỐT LÕI
```typescript
class PurchaseOrderFlowEngine {
  // Flow 1: Form Creation
  async createPurchaseOrder(params: {
    currencyAttributeId: UUID,
    quantity: number,
    unitCost: number,
    channelId: UUID,
    requestedBy: UUID
  }): Promise<PurchaseOrder>

  // Flow 2: Employee Assignment
  async assignPurchaseOrder(orderId: UUID): Promise<PurchaseOrderAssignment>
  private async assignEmployee(channelId: UUID): Promise<Assignment>
  private async updateOrderStatus(orderId: UUID, status: 'DRAFT' | 'ASSIGNED' | 'COMPLETED'): Promise<void>

  // Flow 3: Stock & WAC Update
  async completePurchaseOrder(orderId: UUID, actualQuantity?: number): Promise<void>
  private async calculateWAC(params: WACParams): Promise<WACResult>
  private async updateInventoryPool(params: UpdatePoolParams): Promise<void>
}
```

#### Task 2.4: SaleOrderFlowEngine (LUỒNG BÁN HÀNG) - CỐT LÕI
```typescript
class SaleOrderFlowEngine {
  // Flow 1: Order Creation
  async createSaleOrder(params: {
    currencyAttributeId: UUID,
    quantity: number,
    salePrice: number,
    channelId: UUID,
    requestedBy: UUID
  }): Promise<SaleOrder>

  // Flow 2: Delivery Assignment
  async assignSaleOrder(orderId: UUID): Promise<SaleOrderAssignment>
  private async findInventoryAcrossPools(params: {
    currencyAttributeId: UUID,
    quantity: number,
    channelId: UUID
  }): Promise<InventoryPool>
  private async selectPoolWithStock(pools: InventoryPool[], currencyAttributeId: UUID): Promise<BusinessProcess>
  private async findAccountWithStock(processId: UUID, currencyAttributeId: UUID, quantity: number): Promise<InventoryPool>

  // Flow 3: Stock Update
  async completeSaleOrderDelivery(orderId: UUID, actualQuantity?: number): Promise<void>
  private async updateInventoryPool(params: UpdatePoolParams): Promise<void>

  // Flow 4: Profit Calculation
  async calculateSaleOrderProfit(orderId: UUID): Promise<ProfitCalculation>
  private async calculateProfit(params: {
    salePrice: number,
    quantity: number,
    averageCost: number,
    channelId: UUID,
    processId: UUID
  }): Promise<ProfitCalculation>
}
```

#### Task 2.5: AssignmentTrackerService (ROUND-ROBIN LOGIC) - CỐT LÕI
```typescript
class AssignmentTrackerService {
  async getNextInRotation(trackerType: string): Promise<UUID>
  async updateTracker(trackerType: string, assignedId: UUID): Promise<void>
  async getTracker(trackerType: string): Promise<AssignmentTracker>
  async initializeTrackers(): Promise<void>
}
```

### 🎨 FRONTEND COMPONENT TASKS THEO BUSINESS FLOW

#### Task 3.1: FeeManager.vue (QUẢN LÝ PHÍ) - CỐT LÕI
```vue
<template>
  <div class="fee-manager">
    <!-- Fee List -->
    <n-data-table
      :columns="feeColumns"
      :data="fees"
      :loading="loading"
    />

    <!-- Create/Edit Fee Modal -->
    <n-modal v-model:show="showFeeModal">
      <FeeForm
        :fee="selectedFee"
        :direction-options="directionOptions"
        @save="handleSaveFee"
        @cancel="handleCancelFee"
      />
    </n-modal>

    <!-- Fee Categories -->
    <n-tabs v-model:value="activeDirection" type="card">
      <n-tab-pane name="BUY" tab="Phí Mua" />
      <n-tab-pane name="SELL" tab="Phí Bán" />
      <n-tab-pane name="WITHDRAW" tab="Phí Rút" />
      <n-tab-pane name="TAX" tab="Thuế" />
      <n-tab-pane name="OTHER" tab="Phí Khác" />
    </n-tabs>
  </div>
</template>
```

#### Task 3.2: BusinessProcessManager.vue (QUẢN LÝ QUY TRÌNH) - CỐT LÕI
```vue
<template>
  <div class="business-process-manager">
    <!-- Process List -->
    <n-data-table
      :columns="processColumns"
      :data="processes"
      :loading="loading"
    />

    <!-- Create/Edit Process Modal -->
    <n-modal v-model:show="showProcessModal">
      <BusinessProcessForm
        :process="selectedProcess"
        @save="handleSaveProcess"
        @cancel="handleCancelProcess"
      />
    </n-modal>

    <!-- Process Fee Mapping -->
    <ProcessFeeMapper
      :process-id="selectedProcessId"
      :available-fees="availableFees"
      @update="handleUpdateProcessFees"
    />

    <!-- Channel Selection Rules (nếu cần) -->
    <ChannelSelectionRules
      :process-id="selectedProcessId"
      @update="handleUpdateChannelRules"
    />
  </div>
</template>
```

#### Task 3.3: InventoryPoolDashboard.vue (KHO THEO POOL) - CỐT LÕI
```vue
<template>
  <div class="inventory-pool-dashboard">
    <!-- Pool Overview -->
    <n-card title="Tồn kho theo Pool">
      <n-data-table
        :columns="poolColumns"
        :data="inventoryPools"
        :loading="loading"
        :pagination="{pageSize: 20}"
      />
    </n-card>

    <!-- WAC Visualization -->
    <n-card title="Giá vốn trung bình (WAC)">
      <WACChart
        :pool-data="poolWACData"
        :currency-options="currencyOptions"
      />
    </n-card>

    <!-- Pool Performance -->
    <PoolPerformanceMetrics :pools="inventoryPools" />
  </div>
</template>
```

#### Task 3.4: AssignmentTracker.vue (THEO DÕI PHÂN CÔNG) - QUAN TRỌNG
```vue
<template>
  <div class="assignment-tracker">
    <!-- Real-time Assignments -->
    <n-card title="Phân công hiện tại">
      <AssignmentOverview
        :assignments="currentAssignments"
        :employee-workload="employeeWorkload"
      />
    </n-card>

    <!-- Assignment History -->
    <n-card title="Lịch sử phân công">
      <AssignmentHistory
        :history="assignmentHistory"
        :filters="historyFilters"
      />
    </n-card>

    <!-- Manual Override -->
    <ManualOverride
      :available-employees="availableEmployees"
      :pending-assignments="pendingAssignments"
      @override="handleManualOverride"
    />
  </div>
</template>
```

---

## 🛠️ TECHNICAL IMPLEMENTATION DETAILS

### Assignment Algorithm (Version 1.0)

#### Purchase Order Assignment
```typescript
async function assignPurchaseOrder(orderId: UUID): Promise<PurchaseOrderAssignment> {
  // 1. Get order details
  const order = await getPurchaseOrder(orderId);
  const channelId = order.channel_id;

  // 2. Get current shift
  const currentShift = await getCurrentShift();

  // 3. Get employees available for this channel in current shift
  const availableEmployees = await getEmployees({
    shiftId: currentShift.id,
    channelId: channelId,
    isActive: true
  });

  // 4. Get next employee in rotation for this channel
  const trackerType = `BUY_CHANNEL_${channelId}`;
  const tracker = await getAssignmentTracker(trackerType);
  const nextEmployee = getNextInRotation(availableEmployees, tracker.last_assigned_id);

  // 5. Update tracker and order status
  await updateAssignmentTracker(trackerType, nextEmployee.id);
  await updatePurchaseOrderStatus(orderId, 'ASSIGNED');

  // 6. Return assignment
  return {
    orderId: orderId,
    employeeId: nextEmployee.id,
    gameAccountId: nextEmployee.assigned_game_account_id,
    channelId: channelId,
    assignedAt: new Date()
  };
}
```

#### Sale Order Assignment
```typescript
async function assignSaleOrder(orderId: UUID): Promise<SaleOrderAssignment> {
  // 1. Get order details
  const order = await getSaleOrder(orderId);
  const { currencyAttributeId, quantity, channelId } = order;

  // 2. Find inventory across pools
  const availablePools = await findInventoryAcrossPools({
    currencyAttributeId,
    quantity,
    channelId
  });

  // 3. Round-robin pool selection
  const trackerType = `SELL_POOL_CURRENCY_${currencyAttributeId}`;
  const tracker = await getAssignmentTracker(trackerType);
  const selectedPool = getNextPoolInRotation(availablePools, tracker.last_assigned_id);

  // 4. Find account with stock in selected pool
  const inventoryPool = await findAccountWithStock(
    selectedPool.processId,
    currencyAttributeId,
    quantity
  );

  // 5. Get employee assigned to this account
  const employeeAssignment = await getEmployeeForGameAccount(inventoryPool.game_account_id);

  // 6. Update tracker and order status
  await updateAssignmentTracker(trackerType, selectedPool.processId);
  await updateSaleOrderStatus(orderId, 'ASSIGNED');

  // 7. Return assignment
  return {
    orderId: orderId,
    employeeId: employeeAssignment.employee_profile_id,
    gameAccountId: inventoryPool.game_account_id,
    processId: selectedPool.processId,
    channelId: channelId,
    assignedAt: new Date()
  };
}
```

### WAC Calculation Logic
```typescript
function calculateWeightedAverageCost(params: {
  oldQuantity: number;
  oldAverageCost: number;
  newQuantity: number;
  newUnitCost: number;
  purchaseFeeRate: number;
  purchaseFeeFixed: number;
}): WACResult {
  // Calculate total cost of new purchase
  const newBaseCost = newQuantity * newUnitCost;
  const newFeeCost = (newBaseCost * purchaseFeeRate) + purchaseFeeFixed;
  const newTotalCost = newBaseCost + newFeeCost;

  // Calculate new total values
  const totalQuantity = oldQuantity + newQuantity;
  const oldTotalValue = oldQuantity * oldAverageCost;
  const newTotalValue = oldTotalValue + newTotalCost;

  // Calculate new average cost
  const newAverageCost = newTotalValue / totalQuantity;

  return {
    newAverageCost: Math.round(newAverageCost * 100) / 100, // 2 decimal places
    totalCost: Math.round(newTotalCost),
    unitCost: Math.round((newTotalCost / newQuantity) * 100) / 100
  };
}
```

---

## 🚨 RISK MITIGATION FOR SINGLE DEVELOPER

### Technical Risks
1. **Complex WAC Calculations** → Build comprehensive unit tests first
2. **Assignment Race Conditions** → Use database transactions and locks
3. **Data Consistency** → Daily reconciliation scripts
4. **Performance Issues** → Implement proper database indexing

### Development Risks
1. **Scope Creep** → Stick to Version 1.0 features only
2. **Technical Debt** → Code review session mỗi cuối tuần
3. **Integration Issues** → Test each component independently

---

## 📊 SUCCESS METRICS & VALIDATION

### Technical Metrics
- ✅ Assignment success rate > 95%
- ✅ WAC calculation accuracy (4 decimal places)
- ✅ API response time < 200ms
- ✅ Zero data loss during migration

### Business Metrics
- ✅ Order processing time reduced by 50%
- ✅ Assignment accuracy > 90%
- ✅ Financial reporting accuracy 100%
- ✅ User adoption rate > 80%

---

## 🎯 WEEKLY DELIVERABLES

### Week 1-2 Deliverables
- [ ] Database schema với tất cả bảng mới (fees, business_processes, inventory_pools, assignment_trackers, etc.)
- [ ] Basic CRUD APIs cho business processes và fees
- [ ] Process management UI (FeeManager, BusinessProcessManager)
- [ ] Unit tests cho WAC calculations

### Week 3-4 Deliverables
- [x] Complete Purchase Order Flow Engine (3 steps: Form → Assignment → WAC Update) ✅
- [ ] Complete Sale Order Flow Engine (4 steps: Order → Assignment → Stock → Profit)
- [x] Assignment algorithms for purchase flows ✅
- [ ] Enhanced currency forms với process selection
- [x] Integration tests cho purchase assignment logic ✅

### Week 5-6 Deliverables
- [ ] Management dashboard với pool visualization
- [ ] Purchase và Sale order tracking interfaces
- [ ] Profit calculation và reporting
- [ ] End-to-end testing cho cả 2 flows
- [ ] Documentation

### Week 7-8 Deliverables
- [ ] Parallel running setup với feature flags
- [ ] Performance optimization cho WAC calculations
- [ ] User training materials cho 2 flows
- [ ] Production deployment
- [ ] Post-launch monitoring

---

## 📋 IMPLEMENTATION CHECKLIST

### Phase 1: Foundation (Week 1-2) - Theo đúng bản thảo
- [x] **Database Setup** - Theo đúng bản thảo ✅ **HOÀN THÀNH**
  - [x] **Nhóm 1: Core Tables**
    - [x] Create fees table (Phí chi tiết) - CỐT LÕI ✅
    - [x] Create business_processes table (Quy trình kinh doanh/Stock Pool) - CỐT LÕI ✅
    - [x] Create inventory_pools table (Kho tổng hợp theo Pool) - CỐT LÕI ✅
    - [x] Create assignment_trackers table (Bộ nhớ phân công tuần tự) - CỐT LÕI ✅
    - [x] Create shift_role_assignments table (Phân công vai trò mua) ✅
  - [x] **Nhóm 2: Enhancement & Mapping**
    - [x] Create process_fees_map table (Phí bổ sung của quy trình) ✅
    - [x] Update channels table (thay thế 6 cột fee bằng 1 cột transaction_fee_id) ✅
    - [x] Update account_shift_assignments table (thêm assigned_game_account_id) ✅
  - [x] **Setup & Constraints**
    - [x] Set up proper indexes và foreign keys ✅
    - [x] Create constraints theo business rules ✅
    - [x] Initialize default data cho hệ thống ✅

- [x] **Backend APIs** - Theo business flow 🔄 **ĐANG LÀM** - **40% Complete**
  - [x] **Core Services - Purchase Order Flow**
    - [x] create_purchase_order_draft() function ✅
    - [x] assign_purchase_order() function ✅
    - [x] complete_purchase_order() function ✅
    - [x] get_purchase_order_details() function ✅
    - [x] PurchaseOrderFlowEngine (Luồng mua hàng) - CỐT LÕI ✅
  - [ ] **Core Services - Sale Order Flow**
    - [ ] SaleOrderFlowEngine (Luồng bán hàng) - CỐT LÕI
  - [x] **Assignment Logic**
    - [x] AssignmentTrackerService (Round-robin logic) - CỐT LÕI ✅
    - [x] Shift-based filtering ✅
    - [x] Channel permission validation ✅
  - [ ] **Support Services**
    - [ ] InventoryPoolService với WAC calculation
    - [ ] FeeCalculationService (Complex fee structure)
    - [ ] ShiftManagementService (Employee assignments)
  - [ ] **API Infrastructure**
    - [ ] API endpoints với proper validation
    - [ ] Error handling và logging theo business rules
    - [ ] Database transactions cho WAC calculations

- [ ] **Frontend Components** - Theo business flow ❌ **CHƯA BẮT ĐẦU**
  - [ ] **Management Components**
    - [ ] FeeManager.vue (Quản lý phí chi tiết) - CRITICAL
    - [ ] BusinessProcessManager.vue (Quản lý quy trình) - CRITICAL
    - [ ] ProcessFeeMapper.vue (Map phí vào quy trình) - IMPORTANT
  - [ ] **Dashboard Components**
    - [ ] InventoryPoolDashboard.vue (Hiển thị kho + WAC) - CRITICAL
    - [ ] AssignmentTracker.vue (Theo dõi phân công) - IMPORTANT
  - [ ] **Form Components**
    - [ ] FeeForm.vue (Form tạo/sửa phí)
    - [ ] BusinessProcessForm.vue (Form tạo/sửa quy trình)
    - [ ] Enhanced CurrencyForm.vue (Thêm process selection)

### Phase 2: Core Logic (Week 3-4) 🔄 **ĐANG LÀM**
- [ ] **Assignment Engine**
  - [ ] Shift-based filtering logic
  - [ ] Channel permission validation
  - [ ] Round-robin selection algorithm
  - [ ] Tracker update mechanisms
  - [ ] Concurrent assignment handling

- [x] **Financial Calculations** - **60% Complete**
  - [x] WAC calculation service ✅ (Weighted Average Cost for purchase orders)
  - [x] Purchase fee calculations ✅ (Channel fees in unit cost)
  - [ ] Sale profit calculations
  - [ ] Currency conversion logic
  - [ ] Cost breakdown functions

- [x] **Order Processing** - **50% Complete**
  - [x] Purchase order flow với assignment ✅ (Complete 3-step flow tested)
  - [ ] Sale order flow với pool selection
  - [x] Inventory pool updates ✅ (WAC calculation and quantity updates)
  - [x] Transaction recording ✅ (Purchase orders table with full audit trail)
  - [x] Status management ✅ (DRAFT → ASSIGNED → COMPLETED)

### Phase 3: Integration (Week 5-6) ❌ **CHƯA BẮT ĐẦU**
- [ ] **Enhanced Forms**
  - [ ] Process selection trong CurrencyForm
  - [ ] Real-time cost calculation
  - [ ] Fee breakdown display
  - [ ] Pool availability indicators
  - [ ] Assignment preview

- [ ] **Management Dashboard**
  - [ ] Real-time assignment overview
  - [ ] Pool analytics visualization
  - [ ] Process performance metrics
  - [ ] Manual override interface
  - [ ] Historical assignment tracking

- [ ] **Testing & Validation**
  - [ ] Unit tests cho tất cả services
  - [ ] Integration tests cho order flows
  - [ ] Financial calculation validation
  - [ ] Assignment logic testing
  - [ ] Performance benchmarking

### Phase 4: Production Ready (Week 7-8) ❌ **CHƯA BẮT ĐẦU**
- [ ] **Parallel Running**
  - [ ] Feature flags implementation
  - [ ] Side-by-side comparison
  - [ ] Data consistency checks
  - [ ] Performance monitoring
  - [ ] Rollback procedures

- [ ] **Optimization**
  - [ ] Database query optimization
  - [ ] Frontend performance tuning
  - [ ] Memory usage optimization
  - [ ] Error handling improvements
  - [ ] UI/UX refinements

- [ ] **Documentation & Training**
  - [ ] API documentation
  - [ ] User training guides
  - [ ] Admin operation manual
  - [ ] Troubleshooting guide
  - [ ] System architecture documentation

---

## 🔧 DEVELOPMENT ENVIRONMENT SETUP

### Required Tools & Dependencies
```json
{
  "backend": {
    "node": ">=18.0.0",
    "typescript": "^5.0.0",
    "supabase": "^1.0.0",
    "express": "^4.18.0"
  },
  "frontend": {
    "vue": "^3.3.0",
    "typescript": "^5.0.0",
    "naive-ui": "^2.34.0",
    "chart.js": "^4.4.0"
  },
  "database": {
    "postgresql": ">=15.0",
    "supabase": "latest"
  }
}
```

### Environment Variables
```env
# Database
DATABASE_URL=your_supabase_db_url
SUPABASE_SERVICE_ROLE_KEY=your_service_key

# App Settings
NODE_ENV=development
API_BASE_URL=http://localhost:3000
FRONTEND_URL=http://localhost:5173

# Feature Flags
ENABLE_NEW_ASSIGNMENT_LOGIC=false
ENABLE_WAC_CALCULATIONS=false
PARALLEL_RUNNING_MODE=false
```

---

## 📞 SUPPORT & CONTACT

### Technical Support
- **Database Issues**: Check migration logs và constraints
- **API Problems**: Review service logs và error responses
- **Frontend Bugs**: Check console errors và network requests
- **Assignment Logic**: Verify tracker states và employee availability

### Emergency Contacts
- **System Administrator**: [Contact Information]
- **Database Administrator**: [Contact Information]
- **Product Manager**: [Contact Information]

---

**Kế hoạch này được thiết kế đặc biệt cho team 1 người với focus vào các core features trước, advanced features sau. Mỗi tuần có deliverables rõ ràng để tracking progress và đảm bảo hoàn thành đúng deadline.**

*Last Updated: October 31, 2025*
*Version: 1.0*
*Author: System Analysis Team*