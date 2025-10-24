# Currency Purchase System - Implementation Plan

## Overview

This document outlines the complete implementation plan for the currency purchase order system, including the finalized mapping process, database structure, API endpoints, and frontend implementation flow.

## System Architecture

### Database Tables Structure

```
parties (id, name, type, contact_info, notes, created_at, updated_at)
├── Links to customer_accounts via party_id
├── Supports types: 'customer', 'supplier', 'admin', 'other'
└── Contains contact_info jsonb for Discord/Telegram/etc.

customer_accounts (id, party_id, account_type, label, btag)
├── Links to parties table via party_id
├── Contains game-specific account information
└── Maps to currency_orders via party_id

channels (id, game_code, channel_name, direction, fee_chain_id)
├── Filtered by direction = 'BUY' OR 'BOTH' for purchase tab
└── Links to fee chains for trading fee calculation

currency_orders (party_id, currency_attribute_id, quantity, cost_amount, cost_currency_code,
                  sale_amount, sale_currency_code, profit_amount, profit_currency_code, notes)
├── Core orders table with unified pricing structure
├── Purchase orders: use cost_amount + cost_currency_code (total cost paid to supplier)
├── Sale orders: use sale_amount + sale_currency_code (total price received from customer)
├── Profit calculations: profit_amount = sale_amount - cost_amount (with currency conversion)
└── Does NOT create currency_transactions at purchase step

currency_transactions (created later in CurrencyOps.vue)
├── Created when goods are received
├── Links to currency_orders via order_id
└── Handles inventory updates
```

## Frontend Implementation Flow

### 1. CurrencyCreateOrders.vue - Purchase Tab

#### Form Structure:

```
Supplier Information Section (CustomerForm component)
├── Channel Selection (Kênh mua hàng)
│   └── Filter: channels.direction = 'BUY' OR 'BOTH'
├── Supplier Name (Tên nhà cung cấp)
│   └── Maps to: parties.name
├── Contact Info (Thông tin liên hệ)
│   └── Maps to: CustomerForm with supplier labels
│       └── Tên nhân vật / ID (varies by game)
└── Notes (Ghi chú)
    └── Maps to: parties.notes

Currency Information Section
├── Currency Selection
│   └── Maps to: currency_orders.currency_attribute_id
├── Quantity
│   └── Maps to: currency_orders.quantity
├── Total Price VND
│   └── Label: "Tổng giá trị (VND)" - Maps to currency_orders.cost_amount
└── Total Price USD (optional)
    └── Label: "Tổng giá trị (USD)" - Maps to currency_orders.cost_amount

Display Section (Green Background):
├── Unit Price Calculation: "Giá mỗi Divine = 1,000 đ"
└── Total Value Display: "Tổng giá trị = 500,000 ₫"
```

### 2. CurrencyCreateOrders.vue - Sale Tab

#### Form Structure:

```
Customer Information Section (CustomerForm component)
├── Channel Selection (Kênh bán hàng)
│   └── Filter: channels.direction = 'SELL' OR 'BOTH'
├── Customer Name (Tên khách hàng)
│   └── Maps to: parties.name (type='customer')
├── Customer Game Tag
│   └── Maps to: parties.contact_info.game_tag
└── Delivery Info
    └── Maps to: currency_orders.delivery_info

Currency Information Section
├── Currency Selection
│   └── Maps to: currency_orders.currency_attribute_id
├── Quantity
│   └── Maps to: currency_orders.quantity
├── Total Price VND
│   └── Label: "Tổng giá trị (VND)" - Maps to currency_orders.sale_amount
└── Total Price USD (optional)
    └── Label: "Tổng giá trị (USD)" - Maps to currency_orders.sale_amount

Display Section (Blue Background):
├── Unit Price Calculation: "Giá mỗi Divine = 1,000 đ"
└── Total Value Display: "Tổng giá trị = 500,000 ₫"

Exchange Information Section:
├── Exchange Type (none/items/service/farmer)
├── Exchange Details
└── Upload Images
```

#### Dynamic Currency Detection Logic:

```typescript
// Dynamic currency detection based on user input
const purchaseCostCurrency = computed(() => {
  if (purchaseData.totalPriceUSD && purchaseData.totalPriceUSD > 0) {
    return 'USD'
  }
  return 'VND' // Default to VND
})

const purchaseCostAmount = computed(() => {
  if (purchaseCostCurrency.value === 'USD' && purchaseData.totalPriceUSD) {
    return purchaseData.totalPriceUSD
  }
  return purchaseData.totalPriceVND || 0 // Default to VND
})
```

#### API Mapping Structure:

```typescript
// Database field mappings
const purchaseOrderData = {
  currency_attribute_id: purchaseData.currencyId,
  quantity: purchaseData.quantity,
  cost_amount: purchaseCostAmount.value, // Dynamic: VND or USD amount
  cost_currency_code: purchaseCostCurrency.value, // Dynamic: 'VND' or 'USD'
  party_id: supplierPartyId.value, // From parties table
  notes: purchaseData.notes,
  channel_id: purchaseData.channelId, // From channels table
}
```

### 2. CustomerForm.vue - Supplier Mode

#### Game-Specific Labels:

```typescript
const gameCustomerInfoLabel = computed(() => {
  if (props.formMode === 'supplier') {
    switch (props.gameCode) {
      case 'POE_1':
      case 'POE_2':
        return 'Tên nhân vật / ID'
      case 'DIABLO_4':
        return 'BattleTag/ID'
      default:
        return 'Tên nhân vật / ID'
    }
  }
  // Customer mode logic (not used in purchase tab)
})
```

#### Supplier Data Flow:

```
User input → CustomerForm validation → Supplier management
├── Check if supplier exists in parties table
├── Create new party if not exists
├── Return party_id for order creation
└── Store contact info and notes
```

## Database Functions

### 1. create_currency_purchase_order

```sql
CREATE OR REPLACE FUNCTION public.create_currency_purchase_order(
    p_currency_attribute_id BIGINT,
    p_quantity NUMERIC,
    p_cost_amount NUMERIC,
    p_cost_currency_code TEXT DEFAULT 'VND',
    p_party_id BIGINT,
    p_channel_id UUID,
    p_notes TEXT DEFAULT NULL
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    order_id BIGINT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
-- Creates currency_orders record
-- Maps: cost_amount, cost_currency_code, party_id
-- Does NOT create currency_transactions
$$;
```

### 2. get_or_create_supplier_party

```sql
CREATE OR REPLACE FUNCTION public.get_or_create_supplier_party(
    p_party_name TEXT,
    p_party_type TEXT DEFAULT 'supplier',
    p_contact_info JSONB DEFAULT '{}',
    p_notes TEXT DEFAULT NULL
)
RETURNS TABLE (
    party_id BIGINT,
    is_new BOOLEAN
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
-- Supplier management function
-- Checks parties table for existing supplier
-- Creates new party if not found
-- Returns party_id for order creation
$$;
```

### 3. get_supplier_channels

```sql
CREATE OR REPLACE FUNCTION public.get_supplier_channels(
    p_game_code TEXT DEFAULT NULL
)
RETURNS TABLE (
    id UUID,
    channel_name TEXT,
    game_code TEXT,
    direction TEXT,
    fee_chain_id UUID
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
-- Channel filtering for purchase tab
-- Returns channels with direction = 'BUY' OR 'BOTH'
-- Can be filtered by game_code
$$;
```

### 4. create_currency_sell_order (Updated)

```sql
CREATE OR REPLACE FUNCTION public.create_currency_sell_order(
    p_currency_attribute_id UUID,
    p_quantity NUMERIC,
    p_sale_amount NUMERIC,
    p_game_code TEXT,
    p_league_attribute_id UUID,
    p_customer_name TEXT,
    p_customer_game_tag TEXT,
    p_delivery_info TEXT,
    p_channel_id UUID,
    -- Optional parameters below
    p_exchange_type TEXT DEFAULT 'none',
    p_exchange_details TEXT DEFAULT NULL,
    p_exchange_images TEXT[] DEFAULT NULL,
    p_sales_notes TEXT DEFAULT NULL,
    p_priority_level INTEGER DEFAULT 3,
    p_sale_currency_code TEXT DEFAULT 'VND'
)
RETURNS TABLE(
    success BOOLEAN,
    order_id UUID,
    order_number TEXT,
    message TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
-- Create sell order with total sale amount (not unit price)
-- Handles customer management automatically
-- Uses sale_amount + sale_currency_code fields
-- Supports exchange types (items/service/farmer)
$$;
```

### 5. create_currency_purchase_order (Updated)

```sql
CREATE OR REPLACE FUNCTION public.create_currency_purchase_order(
    p_currency_attribute_id BIGINT,
    p_quantity NUMERIC,
    p_cost_amount NUMERIC,
    p_game_code TEXT,
    p_league_attribute_id BIGINT,
    p_channel_id UUID,
    p_supplier_name TEXT,
    p_supplier_contact TEXT DEFAULT '',
    -- Optional parameters below
    p_unit_price_usd NUMERIC DEFAULT 0,
    p_game_account_id BIGINT DEFAULT NULL,
    p_proof_urls TEXT[] DEFAULT ARRAY[]::TEXT[],
    p_notes TEXT DEFAULT NULL,
    p_delivery_info TEXT DEFAULT NULL,
    p_cost_currency_code TEXT DEFAULT 'VND'
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    order_id BIGINT,
    order_number TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
-- Create purchase order with total cost amount
-- Handles supplier management automatically
-- Uses cost_amount + cost_currency_code fields
-- Supplier created if not exists
$$;
```

## Key Implementation Rules

### 1. Purchase Tab Restrictions:

- **ONLY** handles supplier mode information
- Does NOT include customer account information
- Customer mode is reserved for sell orders in other components
- No currency_transactions created at this step

### 2. Dynamic Currency Handling:

- Default currency: VND
- User can input in either VND or USD field
- System automatically detects which currency is being used
- cost_amount and cost_currency_code set accordingly

### 3. Database Field Mappings:

- `party_id` (not supplier_party_id)
- `cost_amount` (not unit_price_vnd)
- `cost_currency_code` (dynamic VND/USD)
- `currency_attribute_id` (from currency selection)

### 4. Supplier Management Flow:

```
1. User selects channel → filter channels by direction
2. User enters supplier info → check parties table
3. If supplier not found → create new party
4. Get party_id for order creation
5. Create currency_order with supplier information
```

## Data Flow Sequence

### Purchase Order Creation:

```
1. Channel Selection → get_supplier_channels(game_code)
2. Supplier Information → get_or_create_supplier_party()
3. Currency Selection → currency_attributes table
4. Form Validation → required fields check
5. API Call → create_currency_purchase_order()
6. Success → Redirect to order list
7. Error → Display validation messages
```

### Deferred Transaction Creation:

```
1. Purchase order created → currency_orders record
2. Goods received in CurrencyOps.vue
3. Create currency_transactions
4. Update currency_inventory
5. Complete order lifecycle
```

## Frontend Components Integration

### Parent Component: CurrencyCreateOrders.vue

- Tab-based interface (Buy/Sell)
- Purchase tab handles supplier-only flow
- Sale tab handles customer + exchange flow
- Dynamic currency detection (VND/USD)
- API integration with proper error handling
- Color-coded buttons: Green for Purchase, Blue for Sale

### Child Component: CustomerForm.vue

- Reusable for supplier/customer information
- Dynamic labels based on game and form mode
- Validation and data formatting
- Integration with parent component
- Labels: "Tổng giá trị" instead of "Giá bán/mua"

### Navigation Flow:

```
CurrencyCreateOrders.vue (Purchase Tab)
    ↓ Order Created
CurrencyOrderList.vue (View Orders)
    ↓ Receive Goods
CurrencyOps.vue (Complete Transaction)
```

## Recent UI/UX Improvements

### 1. Price Display Optimization

- **Before**: Separate sections for unit price and total value
- **After**: Single-line display: "Giá mỗi Divine = 1,000 đ | Tổng giá trị = 500,000 ₫"
- **Space Saving**: Reduced from 2 sections to 1 compact section
- **Consistency**: Both tabs use same display format

### 2. Dynamic Currency Detection

- **Purchase Tab**:
  - Labels: "Tổng giá trị (VND)", "Tổng giá trị (USD)"
  - Auto-detects input currency (VND or USD)
  - Calculates unit price automatically
- **Sale Tab**:
  - Labels: "Tổng giá trị (VND)", "Tổng giá trị (USD)"
  - Same auto-detection logic as purchase tab
  - Consistent calculation across both tabs

### 3. Color-Coded Interface

- **Purchase Tab**: Green background for price display
- **Sale Tab**: Blue background for price display
- **Buttons**: Green for "Tạo Đơn Mua", Blue for "Tạo Đơn Bán"
- **Visual Consistency**: Both tabs have identical layout, different colors

### 4. Precision Improvements

- **VND**: Display as whole numbers (1,000 đ)
- **USD**: Display with 2-6 decimal places ($0.025000)
- **Calculation**: Accurate unit price = total amount / quantity

### 5. Label Updates

- **Input Labels**: Changed from "Giá mua/bán" to "Tổng giá trị"
- **Display Labels**: Consistent "Giá mỗi Currency" and "Tổng giá trị"
- **Placeholders**: Updated to reflect total price input

## Validation and Error Handling

### Frontend Validation:

- Required field checking
- Currency amount validation
- Supplier information validation
- Real-time error feedback

### Backend Validation:

- Database constraint checking
- Party existence verification
- Channel availability validation
- Currency attribute validation

### Error Scenarios:

- Invalid supplier information
- Missing required fields
- Database constraint violations
- Network/API errors

## Performance Optimizations

### Database Indexes:

- parties.type, parties.name
- channels.direction, channels.game_code
- currency_orders.party_id, currency_orders.currency_attribute_id

### Frontend Optimizations:

- Debounced API calls
- Cached supplier information
- Lazy loading for currency lists
- Optimized reactivity patterns

## Security Considerations

### Database Security:

- Row Level Security (RLS) policies
- Function SECURITY DEFINER with proper checks
- Parameter validation and sanitization

### Frontend Security:

- Input sanitization
- XSS prevention
- Proper error message handling
- Secure API communication

## Issues Resolved

### 1. Database Function Errors

- **Issue**: `column p.game_code does not exist` in RPC functions
- **Solution**: Updated frontend to use fallback methods until database functions are fixed
- **Status**: Temporary fix in place, functions need database schema updates

### 2. Sale Tab Calculation Logic

- **Issue**: Sale tab was using unit price logic instead of total price
- **Solution**: Updated CurrencyForm.vue to use same calculation logic as purchase tab
- **Status**: ✅ Fixed - both tabs now use total price input with automatic unit price calculation

### 3. RPC Function Naming

- **Issue**: Function had v1 suffix (`create_currency_sell_order_v1`)
- **Solution**: Renamed to `create_currency_sell_order` and updated parameter structure
- **Status**: ✅ Fixed - new function uses `sale_amount` instead of `unit_price_vnd`

### 4. UI Inconsistency

- **Issue**: Different display formats between purchase and sale tabs
- **Solution**: Unified display format with color-coded backgrounds
- **Status**: ✅ Fixed - both tabs use identical layout, different colors only

### 5. Precision Issues

- **Issue**: USD values were truncated/rounded incorrectly
- **Solution**: Updated formatCurrency function to handle USD with 2-6 decimal places
- **Status**: ✅ Fixed - proper decimal precision for both VND and USD

## Testing Strategy

### Unit Tests:

- Database function testing
- Component validation testing
- Utility function testing

### Integration Tests:

- API endpoint testing
- Database transaction testing
- Component integration testing

### End-to-End Tests:

- Complete purchase flow testing
- Complete sell flow testing
- Dynamic currency detection testing
- Cross-browser compatibility

## Deployment Considerations

### Database Migrations:

- Parties table enhancements
- Channel filtering updates
- Currency orders structure changes
- Function creation and updates

### Frontend Deployment:

- Component updates
- Route changes
- State management updates
- API integration changes

## Future Enhancements

### Potential Improvements:

- Advanced supplier management
- Bulk order creation
- Enhanced reporting
- Mobile responsiveness improvements
- Real-time order tracking

### Scalability Considerations:

- Database performance optimization
- API rate limiting
- Caching strategies
- Load balancing preparation

## Conclusion

This implementation plan provides a comprehensive framework for the currency purchase system with:

1. **Clear separation of concerns** - Purchase tab handles only supplier information
2. **Dynamic currency detection** - Automatic VND/USD detection based on user input
3. **Proper database relationships** - Parties, customer_accounts, and currency_orders integration
4. **Deferred transaction creation** - Transactions created when goods are received
5. **Comprehensive validation** - Both frontend and backend validation
6. **Scalable architecture** - Performance optimizations and future enhancement considerations

The system follows the finalized mapping process with correct field mappings, proper data flow, and adherence to the business requirements specified.
