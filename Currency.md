# Kế hoạch Triển khai Tính năng Giao dịch Currency (Phiên bản Hoàn chỉnh)

**Version:** 3.0
**Ngày:** 2025-10-08
**Trạng thái:** Finalized & Integrated

---

## **Phần 1: Tổng quan & Mục tiêu**

### **1.1. Mục tiêu tổng quan**

Xây dựng một hệ thống con (sub-system) hoàn chỉnh để quản lý việc kinh doanh tiền tệ (currency) cho nhiều game:

- **POE 1 & 2**: Support multiple leagues (Standard, Mercenaries, EA, Rise of the Abyssal)
- **Diablo 4**: Support seasons và eternal modes
- **Mở rộng**: Framework linh hoạt để thêm game mới

Hệ thống phải hỗ trợ:

- Quản lý tài khoản game theo mục đích (Farm, Inventory, Trade)
- Theo dõi tồn kho chi tiết với giá vốn trung bình (VND & USD)
- Tính toán lợi nhuận chính xác với chuỗi phí thực tế
- Quy trình vận hành rõ ràng cho Trader 1 (Bán hàng) và Trader 2 (Vận hành)

### **1.2. Kiến trúc hệ thống**

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Frontend      │    │    Backend       │    │   Database      │
│   (Vue 3)       │◄──►│  (RPCs & Edge)   │◄──►│ (PostgreSQL)    │
│                 │    │                  │    │                 │
│ - PoeSell.vue   │    │ - RPC Functions  │    │ - Core Tables   │
│ - PoeOps.vue    │    │ - Edge Functions │    │ - Triggers      │
│ - Inventory     │    │ - Cron Jobs      │    │ - Functions     │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

---

## **Phần 2: Database Design**

### **2.1. Hệ thống Attributes (Metadata Dictionary)**

Sử dụng bảng `attributes` hiện có với các type:

- **GAME**: POE1, POE2, D4
- **POE1_LEAGUE**: Standard, Mercenaries Standard, Hardcore, Mercenaries Hardcore
- **POE2_LEAGUE**: EA Standard/HC, Rise of the Abyssal Standard/HC
- **D4_SEASON**: Eternal, Season 10
- **POE1_CURRENCY**: Divine Orb, Exalted Orb, Chaos Orb, etc.
- **POE2_CURRENCY**: Divine Orb, Exalted Orb, Lesser Jeweller's Orb, etc.
- **D4_CURRENCY**: Gold

### **2.2. Core Tables**

```sql
-- Game Accounts Management
CREATE TABLE public.game_accounts (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    game_code text NOT NULL,
    league_attribute_id uuid NOT NULL REFERENCES public.attributes(id),
    account_name text NOT NULL,
    purpose public.game_account_purpose NOT NULL, -- 'FARM', 'INVENTORY', 'TRADE'
    manager_profile_id uuid REFERENCES public.profiles(id),
    is_active boolean NOT NULL DEFAULT true,
    UNIQUE (game_code, league_attribute_id, account_name)
);

-- Inventory Management
CREATE TABLE public.currency_inventory (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    game_account_id uuid NOT NULL REFERENCES public.game_accounts(id) ON DELETE RESTRICT,
    currency_attribute_id uuid NOT NULL REFERENCES public.attributes(id),
    quantity numeric NOT NULL DEFAULT 0,
    reserved_quantity numeric NOT NULL DEFAULT 0,
    avg_buy_price_vnd numeric NOT NULL DEFAULT 0,
    avg_buy_price_usd numeric NOT NULL DEFAULT 0,
    UNIQUE (game_account_id, currency_attribute_id)
);

-- Transaction Ledger
CREATE TABLE public.currency_transactions (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    game_account_id uuid NOT NULL REFERENCES public.game_accounts(id),
    game_code text NOT NULL,
    league_attribute_id uuid NOT NULL REFERENCES public.attributes(id),
    transaction_type public.currency_transaction_type NOT NULL,
    currency_attribute_id uuid NOT NULL REFERENCES public.attributes(id),
    quantity numeric NOT NULL,
    unit_price_vnd numeric NOT NULL,
    unit_price_usd numeric NOT NULL,
    exchange_rate_vnd_per_usd numeric,
    order_line_id uuid REFERENCES public.order_lines(id),
    partner_id uuid REFERENCES public.parties(id),
    farmer_profile_id uuid REFERENCES public.profiles(id),
    proof_urls text[],
    notes text,
    created_by uuid NOT NULL REFERENCES public.profiles(id),
    created_at timestamptz NOT NULL DEFAULT now()
);
```

### **2.3. Trading Fee Chains System (Tích hợp với Channels)**

```sql
-- Fee Chain Definitions
CREATE TABLE public.trading_fee_chains (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    name text NOT NULL UNIQUE,
    description text,
    chain_steps JSONB NOT NULL, -- Array of fee calculation steps
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- Exchange Rates
CREATE TABLE public.exchange_rates (
    source_currency text NOT NULL,
    target_currency text NOT NULL,
    rate numeric NOT NULL,
    last_updated_at timestamptz NOT NULL,
    PRIMARY KEY (source_currency, target_currency)
);

-- KEY DESIGN: Link channels to fee chains
ALTER TABLE public.channels
ADD COLUMN trading_fee_chain_id UUID REFERENCES public.trading_fee_chains(id);
```

**⚡ Design Improvement: Channel-Integrated Fee Chains**

**Trước:** User phải chọn Fee Chain thủ công
**Sau:** Channel tự động áp dụng Fee Chain phù hợp

**Luồng hoạt động tối ưu:**

```
Trader 1: "Chọn Nguồn bán"
    ↓
Hệ thống: Tự động lấy trading_fee_chain_id từ channels
    ↓
Hệ thống: Tính profit với correct fee chain
    ↓
Kết quả: Chính xác, không lỗi người dùng
```

**Ví dụ thực tế:**

- Channel "G2G Marketplace" → Fee Chain "Facebook to G2G to Payoneer"
- Channel "Direct Bank" → Fee Chain "Direct Customer to Bank"
- Channel "PayPal" → Fee Chain "PayPal to Bank"

### **2.4. Sample Fee Chain Data**

```sql
INSERT INTO public.trading_fee_chains (name, description, chain_steps) VALUES
(
    'Facebook to G2G to Payoneer',
    'Mua từ Facebook, bán qua G2G, rút về Payoneer',
    '[
        {
            "step": 1,
            "from_currency": "VND",
            "to_currency": "USD",
            "fee_type": "SALE_FEE",
            "fee_percent": 5.0,
            "fee_fixed": 0,
            "fee_currency": "USD",
            "description": "G2G platform fee 5%"
        },
        {
            "step": 2,
            "from_currency": "USD",
            "to_currency": "USD",
            "fee_type": "WITHDRAWAL_FEE",
            "fee_percent": 1.0,
            "fee_fixed": 0,
            "fee_currency": "USD",
            "description": "G2G to Payoneer fee 1%"
        },
        {
            "step": 3,
            "from_currency": "USD",
            "to_currency": "VND",
            "fee_type": "CONVERSION_FEE",
            "fee_percent": 0,
            "fee_fixed": 0,
            "fee_currency": "USD",
            "description": "Payoneer to VND (thường miễn phí)"
        }
    ]'
),
(
    'Direct Customer to Bank',
    'Bán trực tiếp cho khách, nhận về ngân hàng Việt Nam',
    '[
        {
            "step": 1,
            "from_currency": "VND",
            "to_currency": "VND",
            "fee_type": "CONVERSION_FEE",
            "fee_percent": 0,
            "fee_fixed": 0,
            "fee_currency": "VND",
            "description": "Không phí, nhận thẳng VND"
        }
    ]'
);
```

### **2.5. Core Functions**

```sql
-- Calculate chain costs with real-world example
CREATE OR REPLACE FUNCTION public.calculate_chain_costs(
    p_chain_id UUID,
    p_from_amount NUMERIC,
    p_from_currency TEXT,
    p_to_currency TEXT,
    p_exchange_rates JSONB DEFAULT '{}'
) RETURNS TABLE(
    step_number INTEGER,
    from_amount NUMERIC,
    to_amount NUMERIC,
    from_currency TEXT,
    to_currency TEXT,
    fee_type TEXT,
    fee_amount NUMERIC,
    fee_currency TEXT,
    description TEXT,
    cumulative_amount NUMERIC
) AS $$
-- [Implementation from trading_chain_design.sql]
$$ LANGUAGE plpgsql;

-- Calculate profit/loss for a trade
CREATE OR REPLACE FUNCTION public.calculate_simple_profit_loss(
    p_purchase_amount NUMERIC,
    p_purchase_currency TEXT,
    p_sale_amount NUMERIC,
    p_sale_currency TEXT,
    p_chain_id UUID,
    p_exchange_rates JSONB DEFAULT '{}'
) RETURNS TABLE(
    purchase_amount NUMERIC,
    purchase_currency TEXT,
    sale_amount NUMERIC,
    sale_currency TEXT,
    total_fees NUMERIC,
    net_profit NUMERIC,
    profit_margin_percent NUMERIC
) AS $$
-- [Implementation from trading_chain_design.sql]
$$ LANGUAGE plpgsql;

-- ⭐ NEW: Calculate profit for an order (auto gets fee chain from channel)
CREATE OR REPLACE FUNCTION public.calculate_order_profit(p_order_line_id UUID)
RETURNS TABLE(
    order_line_id UUID,
    purchase_amount NUMERIC,
    sale_amount NUMERIC,
    channel_name TEXT,
    fee_chain_name TEXT,
    total_fees NUMERIC,
    net_profit NUMERIC,
    profit_margin_percent NUMERIC
) AS $$
-- Automatically gets fee chain from order's channel
-- No manual fee chain selection needed!
$$ LANGUAGE plpgsql;
```

---

## **Phần 3: Implementation Plan**

### **3.1. Database Migration Steps**

1. **Step 1**: Create ENUM types
2. **Step 2**: Create core tables (game_accounts, currency_inventory, currency_transactions)
3. **Step 3**: Create fee chain system (trading_fee_chains, exchange_rates)
4. **Step 4**: Implement triggers for inventory management
5. **Step 5**: Load attributes data from CSV (122 items)
6. **Step 6**: Create sample fee chains
7. **Step 7**: Create indexes and constraints

### **3.2. Backend Implementation**

#### **RPC Functions Checklist:**

- [ ] `create_currency_sell_order_v1` - Create sell orders
- [ ] `record_currency_purchase_v1` - Record purchases
- [ ] `fulfill_currency_order_v1` - Fulfill orders
- [ ] `get_currency_inventory_summary_v1` - Inventory dashboard
- [ ] `calculate_profit_for_order_v1` - Profit calculation
- [ ] `exchange_currency_v1` - Currency exchange
- [ ] `payout_farmer_v1` - Farmer payments
- [ ] `archive_league_currency_v1` - League end transactions

#### **Edge Functions:**

- [ ] `update-exchange-rate` - Auto update rates (Cron job)
- [ ] `sync-inventory` - Inventory synchronization

### **3.3. Frontend Implementation**

#### **Multi-game Universal Pages Architecture**

Sử dụng 2 trang chính duy nhất cho tất cả games và seasons:

```
src/
├── pages/
│   ├── CurrencySell.vue              # Universal sell page (Tất cả games)
│   └── CurrencyOps.vue               # Universal operations page (Tất cả games)
├── components/
│   └── currency/
│       ├── CurrencyInventoryPanel.vue # Dynamic inventory panel
│       ├── GameLeagueSelector.vue     # Game & League selector component
│       ├── CurrencyForm.vue           # Dynamic currency form
│       ├── ProfitCalculator.vue       # Profit calculation component
│       └── TransactionHistory.vue     # Transaction history component
└── composables/
    ├── useCurrency.js                 # Currency utilities
    ├── usePermissions.js             # Permission-based access
    └── useGameContext.js             # Game context management
```

#### **Dynamic Game & League Integration**

**1. Permission-based Access Control:**

```javascript
// Sử dụng hệ thống phân quyền hiện có
const userPermissions = await getUserPermissions()
const accessibleGames = getAccessibleGames(userPermissions, userBusinessArea)

// Filter games based on:
// - User permissions (admin, trader, farmer)
// - Business area assignment
// - Game access rights
```

**2. Smart Game Detection:**

```javascript
// Component tự động detect game từ URL hoặc user selection
const route = useRoute()
const gameCode = route.params.game || getDefaultGame(userBusinessArea)
const businessArea = getUserBusinessArea()

// Dynamic loading based on context
const { currencies, leagues, feeChains } = await loadGameData(gameCode, businessArea)
```

**3. Universal Form Implementation:**

**CurrencySell.vue - Features:**

- **Header**: Game selector dropdown (POE1, POE2, D4) + Season/League selector
- **Dynamic Currency List**: Load currencies based on selected game & league
- **Permission-based Channels**: Hiển thị channels phù hợp với user business area
- **Auto Fee Chain**: Áp dụng chuỗi phí theo channel đã chọn
- **Real-time Inventory**: Hiển thị tồn kho theo game/league đang chọn

**CurrencyOps.vue - Features:**

- **Multi-game Dashboard**: Toggle giữa các games mà user có quyền truy cập
- **League-specific Operations**: Hiển thị data theo league/season đang active
- **Farmer Management**: Filter farmers theo game và business area
- **Cross-game Transfers**: Hỗ trợ chuyển currency giữa các game accounts
- **Business Area Filtering**: Chỉ hiển thị data của area user được phân công

#### **4. Permission & Business Area Integration**

```sql
-- Query để filter data theo quyền user
SELECT
    ga.*,
    a.name as league_name,
    p.display_name as manager_name
FROM game_accounts ga
JOIN attributes a ON ga.league_attribute_id = a.id
LEFT JOIN profiles p ON ga.manager_profile_id = p.id
WHERE
    ga.game_code = ANY(:accessible_games)  -- Games user có quyền
    AND (
        :is_admin = true
        OR ga.manager_profile_id = :user_id
        OR ga.purpose = 'INVENTORY'  -- Chỉ xem inventory accounts
    )
    AND (
        :business_area = 'ALL'
        OR EXISTS (
            SELECT 1 FROM user_business_areas uba
            WHERE uba.profile_id = :user_id
            AND uba.game_code = ga.game_code
        )
    );
```

#### **5. Inventory Panel Enhancement**

**CurrencyInventoryPanel.vue Features:**

- **Game Context Bar**: Hiển thị game & league hiện tại
- **Permission-based View**:
  - Traders: Xem inventory của area mình quản lý
  - Admin: Xem tất cả inventory
  - Farmers: Chỉ xem inventory accounts được giao
- **Multi-game Summary**: Toggle view giữa games khác nhau
- **Real-time Updates**: WebSocket updates cho game đang active
- **Business Area Filters**: Filter theo area assignments

#### **6. Dynamic State Management**

```javascript
// Pinia store cho game context
export const useGameStore = defineStore('game', {
  state: () => ({
    currentGame: null,
    currentLeague: null,
    businessArea: null,
    accessibleGames: [],
    permissions: [],
  }),

  actions: {
    async switchGame(gameCode) {
      // Load game-specific data
      // Update currency list
      // Refresh inventory
      // Apply permissions
    },

    async switchLeague(leagueId) {
      // Filter data by league
      // Update inventory view
      // Refresh transactions
    },
  },
})
```

#### **7. Implementation Benefits**

1. **Single Source of Truth**: Một component handle tất cả games
2. **Permission Driven**: UI tự động adjust theo quyền user
3. **Business Area Aware**: Data được filter theo area assignments
4. **Maintainable**: Dễ maintain hơn vì không duplicate code
5. **Scalable**: Dễ thêm game mới chỉ bằng config
6. **Context Smart**: Form tự động adjust theo game/league context

---

## **Phần 4: Real-world Examples**

### **4.1. Sample Trade Scenario**

**Case**: Mua Divine Orb 20k VND từ Facebook, bán 1.5 USD trên G2G

```sql
-- Step 1: Setup exchange rates
INSERT INTO exchange_rates VALUES
('USD', 'VND', 25700, NOW()),
('VND', 'USD', 0.00003891, NOW());

-- Step 2: Calculate profit
SELECT * FROM calculate_simple_profit_loss(
    20000,        -- Purchase: 20k VND
    'VND',         -- Purchase currency
    1.5,           -- Sale: $1.5
    'USD',         -- Sale currency
    (SELECT id FROM trading_fee_chains WHERE name = 'Facebook to G2G to Payoneer'),
    '{"USD_VND": 25700, "VND_USD": 0.00003891}'
);
```

**Result:**

- Sale amount: $1.5 = 38,550 VND
- G2G fee: 5% = $0.075 = 1,927 VND
- Payoneer fee: 1% = $0.01425 = 366 VND
- Total fees: 2,293 VND
- Net amount: 36,257 VND
- Net profit: 16,257 VND (81.3% margin)

### **4.2. Multi-game Support**

```sql
-- POE1 Divine Orb in Standard League
SELECT attr.name, inv.quantity, inv.avg_buy_price_vnd
FROM currency_inventory inv
JOIN attributes attr ON inv.currency_attribute_id = attr.id
JOIN game_accounts acc ON inv.game_account_id = acc.id
WHERE acc.game_code = 'POE1'
  AND attr.name = 'Divine Orb';

-- D4 Gold in Season 10
SELECT attr.name, inv.quantity, inv.avg_buy_price_vnd
FROM currency_inventory inv
JOIN attributes attr ON inv.currency_attribute_id = attr.id
JOIN game_accounts acc ON inv.game_account_id = acc.id
WHERE acc.game_code = 'D4'
  AND attr.name = 'Gold';
```

---

## **Phần 5: Testing & Deployment**

### **5.1. Testing Strategy**

1. **Unit Tests**: All RPC functions
2. **Integration Tests**: Fee calculation accuracy
3. **E2E Tests**: Complete trade workflows
4. **Performance Tests**: Large transaction volumes

### **5.2. Deployment Checklist**

- [ ] Database migration scripts
- [ ] RPC functions deployment
- [ ] Edge functions setup
- [ ] Frontend components update
- [ ] Realtime subscriptions configuration
- [ ] Cron job scheduling
- [ ] Initial data import
- [ ] User training documentation

---

## **Phần 6: Future Enhancements**

### **6.1. Phase 2 Features**

- Advanced analytics dashboard
- Automated pricing suggestions
- Multi-currency accounting
- API integrations with trading platforms

### **6.2. Phase 3 Features**

- Mobile app support
- AI-powered market predictions
- Automated trading bots
- Advanced reporting suite

---

## **Appendix**

### **A. Currency Types Reference**

**POE1 Currencies (45 types)**: Divine Orb, Exalted Orb, Chaos Orb, Mirror of Kalandra, etc.

**POE2 Currencies (44 types)**: Divine Orb, Exalted Orb, Lesser Jeweller's Orb, etc.

**D4 Currencies (1 type)**: Gold

**Total**: 90 unique currency items across all games

### **B. Transaction Types Reference**

- `purchase`: Mua vào từ đối tác
- `sale_delivery`: Giao cho khách hàng
- `exchange_out/in`: Đổi currency
- `transfer`: Chuyển nội bộ
- `manual_adjustment`: Điều chỉnh thủ công
- `farm_in/payout`: Giao dịch với farmer
- `league_archive`: Kết chuyển mùa giải

### **C. Database Schema Diagram**

```
attributes (1) ←→ (N) game_accounts (1) ←→ (N) currency_inventory
    ↑                        ↑                      ↑
    └── attribute_relationships    └── currency_transactions
```
