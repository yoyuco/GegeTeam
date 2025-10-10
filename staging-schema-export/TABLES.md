# Database Tables Overview

This document lists all tables exported from the staging database with descriptions based on their names and likely purpose.

## Public Schema Tables (30 tables total)

### Currency & Trading System

1. **`attributes`** - Game attributes and currency definitions
2. **`currencies`** - Currency types and configurations
3. **`currency_inventory`** - Currency inventory tracking per account
4. **`currency_transactions`** - Transaction records for currency exchanges
5. **`exchange_rates`** - Currency exchange rate configurations
6. **`trading_fee_chains`** - Trading fee calculation chains

### User Management & Authentication

7. **`profiles`** - User profile information
8. **`parties`** - Party/user relationship management
9. **`customer_accounts`** - Customer account details
10. **`user_role_assignments`** - User role assignments
11. **`roles`** - Role definitions
12. **`role_permissions`** - Permission assignments to roles
13. **`permissions`** - System permissions

### Game Management

14. **`game_accounts`** - Game account management
15. **`level_exp`** - Level and experience data

### Product & Order Management

16. **`products`** - Product catalog
17. **`product_variants`** - Product variant information
18. **`product_variant_attributes`** - Attributes for product variants
19. **`orders`** - Order management
20. **`order_lines`** - Order line items
21. **`order_service_items`** - Service items in orders
22. **`order_reviews`** - Order reviews and ratings

### System & Operations

23. **`channels`** - Sales channels configuration
24. **`audit_logs`** - System audit trail
25. **`debug_log`** - Debug logging
26. **`system_logs`** - System event logs
27. **`service_reports`** - Service reports
28. **`work_sessions`** - Work session tracking
29. **`work_session_outputs`** - Outputs from work sessions

### Data Relationships

30. **`attribute_relationships`** - Relationships between attributes

## Key Relationships

### Currency System Flow

- `attributes` → `currency_inventory` → `currency_transactions`
- Supported by `exchange_rates` and `trading_fee_chains`

### User Management Flow

- `profiles` → `parties` → `customer_accounts`
- Role-based access through `roles`, `permissions`, `user_role_assignments`

### Order Management Flow

- `products` → `product_variants` → `orders` → `order_lines`
- Enhanced with `order_service_items` and `order_reviews`

### Game Integration

- `game_accounts` links to `currency_inventory`
- `level_exp` provides progression data

## Important Notes

1. **Data Volume:** Some tables like `currency_inventory`, `currency_transactions`, and `audit_logs` may contain large amounts of data
2. **Relationships:** All tables have proper foreign key constraints defined in the schema
3. **Security:** All tables have Row Level Security (RLS) policies
4. **Indexes:** Proper indexes are defined for performance optimization

## Recommended Data Export Priority

For manual data export, prioritize these tables:

### High Priority (Core Business Data)

1. `attributes` - Reference data
2. `currencies` - Reference data
3. `channels` - Configuration data
4. `roles` - Reference data
5. `permissions` - Reference data
6. `profiles` - User data
7. `game_accounts` - Game account data

### Medium Priority (Transactional Data)

8. `currency_inventory` - Current inventory state
9. `exchange_rates` - Current rates
10. `trading_fee_chains` - Fee configuration

### Low Priority (Historical Data)

11. `currency_transactions` - Transaction history
12. `audit_logs` - Audit trail
13. `system_logs` - System logs

### Optional (Large Volume)

14. `debug_log` - Debug data (can be excluded)
15. `work_session_outputs` - Session outputs (can be excluded)

---

_This overview is based on the schema exported from staging environment fvgjmfytzdnrdlluktdx_
