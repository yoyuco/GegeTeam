# Database Schema Documentation - GegeTeam

> Auto-generated from migration: `20251002052515_remote_schema.sql`
> Project: Staging (gpmllykxombndvseriph)

---

## 📊 Database Overview

### Custom Types (Enums)

1. **account_type_enum**: `btag`, `login`
2. **app_role**: `admin`, `mod`, `manager`, `trader_manager`, `farmer_manager`, `leader`, `trader_leader`, `farmer_leader`, `trader1`, `trader2`, `farmer`, `trial`, `accountant`
3. **order_side_enum**: `BUY`, `SELL`
4. **product_type_enum**: `SERVICE`, `ITEM`, `CURRENCY`

---

## 📋 Tables (28 tables)

### Core Tables

1. **profiles** - User profiles
2. **roles** - System roles
3. **permissions** - System permissions
4. **user_role_assignments** - User to role mapping
5. **role_permissions** - Role to permission mapping

### Order Management

6. **orders** - Main orders table
7. **order_lines** - Order line items
8. **order_service_items** - Service items per order
9. **order_reviews** - Customer reviews

### Product Catalog

10. **products** - Products catalog
11. **product_variants** - Product variants
12. **product_variant_attributes** - Variant attributes
13. **attributes** - Product attributes
14. **attribute_relationships** - Attribute relationships

### Customer & Party

15. **parties** - Customers/Parties
16. **customer_accounts** - Customer accounts (btag/login)

### Service Operations

17. **work_sessions** - Work sessions tracking
18. **work_session_outputs** - Session output items
19. **service_reports** - Service issue reports

### Reference Data

20. **channels** - Sales channels
21. **currencies** - Currency codes
22. **level_exp** - Game level/exp lookup

### System

23. **audit_logs** - Audit trail
24. **debug_log** - Debug logs

---

## 🔧 RPC Functions (36 functions)

### Admin Functions

- `admin_get_all_users()` - Get all users
- `admin_get_roles_and_permissions()` - Get roles & permissions
- `admin_update_permissions_for_role(role_id, permission_ids[])` - Update role permissions
- `admin_update_user_assignments(user_id, assignments)` - Update user roles
- `admin_update_user_status(user_id, new_status)` - Update user status
- `admin_rebase_item_progress_v1(item_id, done_qty, params, reason)` - Rebase item progress

### Order Management

- `create_service_order_v1(...)` - Create service order (main entry point)
- `get_boosting_orders_v2()` - Get all boosting orders
- `get_boosting_order_detail_v1(line_id)` - Get order detail
- `update_order_details_v1(line_id, ...)` - Update order details
- `update_order_line_machine_info_v1(line_id, machine_info)` - Update machine info
- `cancel_order_line_v1(line_id, proofs, reason)` - Cancel order
- `complete_order_line_v1(line_id, proofs, reason)` - Complete order
- `mark_order_as_delivered_v1(order_id, is_delivered)` - Mark as delivered
- `update_action_proofs_v1(line_id, urls)` - Update action proofs

### Work Session Management

- `start_work_session_v1(line_id, start_state, note)` - Start work session
- `finish_work_session_idem_v1(session_id, outputs, activities, ...)` - Finish session (idempotent)
- `cancel_work_session_v1(session_id)` - Cancel session
- `get_session_history_v1(line_id)` - Get session history (v1)
- `get_session_history_v2(line_id)` - Get session history (v2)
- `get_last_item_proof_v1(item_ids[])` - Get last proofs for items

### Reviews & Reports

- `submit_order_review_v1(line_id, rating, comment, proofs)` - Submit review
- `get_reviews_for_order_line_v1(line_id)` - Get reviews
- `create_service_report_v1(item_id, description, proofs)` - Create report
- `get_service_reports_v1(status)` - Get reports by status
- `resolve_service_report_v1(report_id, notes)` - Resolve report

### Authorization

- `get_user_auth_context_v1()` - Get user roles & permissions
- `has_permission(permission_code, context)` - Check permission
- `get_my_assignments()` - Get current user assignments
- `current_user_id()` - Get current user UUID
- `get_current_profile_id()` - Get current profile UUID

### Utilities

- `get_customers_by_channel_v1(channel_code)` - Get customers
- `try_uuid(text)` - Safe UUID conversion
- `audit_ctx_v1()` - Get audit context
- `audit_diff_v1(old_row, new_row)` - Calculate diff
- `add_vault_secret(name, secret)` - Add secret to vault

### Triggers

- `handle_new_user_with_trial_role()` - Auto-assign trial role
- `handle_orders_updated_at()` - Update timestamp
- `tr_audit_row_v1()` - Audit trigger
- `tr_check_all_items_completed_v1()` - Check completion

---

## 🔒 Row Level Security (RLS)

### Permission-Based Policies

- **Admin only**: `admin:manage_roles`, `system:view_audit_logs`
- **Report management**: `reports:view`, `reports:resolve`
- **Order reviews**: `orders:add_review`, `orders:view_reviews`

### Read Policies

Most tables allow authenticated read:

- ✅ `orders`, `order_lines`, `order_service_items`
- ✅ `products`, `product_variants`, `attributes`
- ✅ `channels`, `currencies`, `parties`
- ✅ `work_sessions`, `work_session_outputs`
- ✅ `roles`, `permissions`

### Write Protection

Most reference/operational tables **block direct writes**:

- ❌ Block inserts: `orders`, `products`, `channels`, etc.
- ❌ Block updates: Same tables
- ❌ Block deletes: Same tables
- ✅ **Use RPC functions instead** for safe operations

### User-Scoped Policies

- `user_role_assignments`: Users see their own + admins see all
- `service_reports`: Reporter sees own + managers see all
- `profiles`: All authenticated can read

---

## 🎯 Key Workflows

### 1. Create Order

```sql
SELECT create_service_order_v1(
  p_channel_code := 'DISCORD',
  p_service_type := 'Selfplay',
  p_customer_name := 'Customer Name',
  p_deadline := '2025-10-05'::timestamptz,
  p_price := 100,
  p_currency_code := 'USD',
  p_package_type := 'BASIC',
  p_package_note := 'Notes...',
  p_customer_account_id := NULL,
  p_new_account_details := '{"type":"btag", "btag":"Player#1234"}'::jsonb,
  p_game_code := 'DIABLO_4',
  p_service_items := '[{...}]'::jsonb
);
```

### 2. Start Work Session

```sql
SELECT start_work_session_v1(
  p_order_line_id := '...',
  p_start_state := '[{"item_id":"...", "start_value":1, "start_exp":0}]'::jsonb,
  p_initial_note := 'Starting work...'
);
```

### 3. Finish Work Session

```sql
CALL finish_work_session_idem_v1(
  p_session_id := '...',
  p_outputs := '[{...}]'::jsonb,
  p_activity_rows := '[{...}]'::jsonb,
  p_overrun_reason := NULL,
  p_idem_key := 'unique-key',
  p_overrun_type := NULL,
  p_overrun_proof_urls := NULL
);
```

### 4. Get User Context

```sql
SELECT get_user_auth_context_v1();
-- Returns: {"roles": [...], "permissions": [...]}
```

### 5. Check Permission

```sql
SELECT has_permission(
  'orders:create',
  '{"game_code":"DIABLO_4", "business_area_code":"SERVICE"}'::jsonb
);
```

---

## 🔍 Search Path

- Default: `public` schema
- Extensions: `extensions`, `graphql`, `vault`

---

## 📦 Extensions Installed

- `pg_graphql` - GraphQL support
- `pg_stat_statements` - Query stats
- `pgcrypto` - Crypto functions
- `supabase_vault` - Secrets vault
- `uuid-ossp` - UUID generation

---

## 💡 Best Practices

1. **Always use RPC functions** for writes - never direct INSERT/UPDATE
2. **Check permissions** before showing UI elements
3. **Use transactions** for multi-table operations
4. **Audit logs** are automatic via triggers
5. **Idempotency keys** prevent duplicate operations (e.g., finish_work_session_idem_v1)

---

## 🚀 Next Steps for Development

When adding new features:

1. **Add migration** in `supabase/migrations/`
2. **Create RPC function** for business logic
3. **Add RLS policy** for security
4. **Update this doc** with new functions
5. **Test locally** with `supabase db reset`
6. **Deploy** with `supabase db push`

---

_Last updated: 2025-10-02_
