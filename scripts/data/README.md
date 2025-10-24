# Data Management Scripts

This directory contains scripts for database data management and operations.

## Available Scripts

### Channel Management
- `add_purchase_channels_compatible.sql` - Add purchase channels using existing database structure
  - Uses `direction` column instead of `channel_type`
  - Sets appropriate fee structure for purchase channels
  - Updates existing channels to have proper direction (SELL/BOTH)

## Usage

### Adding Purchase Channels
```sql
-- Run the compatible version to add purchase channels
-- This will add 5 purchase channels (Discord Farmers, Facebook Groups, etc.)
-- and update existing channels to have proper direction settings
```

## Database Structure Compatibility

### ✅ Compatible With Current Structure
- Channels table has `direction` column ✅
- Channels table has fee structure columns ✅
- Supports `BUY`, `SELL`, `BOTH` directions ✅

### 📋 Channel Categories
- **BUY** - Channels where we purchase currencies from
- **SELL** - Channels where we sell currencies to
- **BOTH** - Channels supporting both buying and selling

## Schema Notes

Current channels table structure:
```sql
channels (
    id, code, name, description, direction,
    is_active, created_at, updated_at,
    purchase_fee_rate, purchase_fee_fixed, purchase_fee_currency,
    sale_fee_rate, sale_fee_fixed, sale_fee_currency,
    ...
)
```

## Memory Notes

See project memory for:
- Channel setup guidelines
- Fee structure recommendations
- Data migration history