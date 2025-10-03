# Production Database Analysis

**Date:** 2025-10-03
**Database:** susuoambmzdmcygovkea (Production)

## 📊 Summary

- **Total Functions:** 42
- **Total Tables:** 24
- **Issues Found:** Duplicate function with different signatures

---

## ⚠️ CRITICAL: Duplicate Functions

### `create_service_order_v1` - 2 versions found!

#### Version 1 (Line 564) - OLD VERSION
```sql
CREATE OR REPLACE FUNCTION "public"."create_service_order_v1"(
  "p_channel_code" text,
  "p_customer_name" text,
  "p_package_type" text,
  "p_package_note" text,
  "p_deadline" timestamp with time zone,
  "p_service_type" text,
  "p_btag" text,
  "p_login_id" text,
  "p_login_pwd" text,
  "p_machine_info" text,
  "p_service_items" jsonb,
  "p_action_proof_urls" text[]
) RETURNS uuid
```

**Issues:**
- ❌ Old signature
- ❌ Missing important parameters (price, currency, game_code)
- ❌ Returns only UUID instead of order_id + line_id

#### Version 2 (Line 676) - NEW VERSION ✅
```sql
CREATE OR REPLACE FUNCTION "public"."create_service_order_v1"(
  "p_channel_code" text,
  "p_service_type" text,
  "p_customer_name" text,
  "p_deadline" timestamp with time zone,
  "p_price" numeric,
  "p_currency_code" text,
  "p_package_type" text,
  "p_package_note" text,
  "p_customer_account_id" uuid,
  "p_new_account_details" jsonb,
  "p_game_code" text,
  "p_service_items" jsonb
) RETURNS TABLE(order_id uuid, line_id uuid)
```

**Better because:**
- ✅ Has price & currency parameters
- ✅ Has customer_account_id for linking
- ✅ Returns both order_id AND line_id
- ✅ More flexible with new_account_details

---

## 🎯 Recommendation

**Action:** Keep Version 2 (newer), remove Version 1 (older)

**Reason:**
1. PostgreSQL allows function overloading, BUT these have similar parameters → confusing
2. Frontend should use one consistent version
3. Version 2 is more complete and flexible

---

## 📝 All Functions List

### Authentication & User Management
1. `admin_get_all_users()` - Get all users
2. `admin_get_roles_and_permissions()` - Get roles & permissions
3. `current_user_id()` - Get current user ID
4. `get_current_profile_id()` - Get current profile
5. `get_user_auth_context_v1()` - Get auth context
6. `handle_new_user_with_trial_role()` - Trigger for new users
7. `admin_update_user_assignments` - Update user assignments
8. `admin_update_user_status` - Update user status
9. `admin_update_permissions_for_role` - Update permissions

### Orders & Service Management
10. `create_service_order_v1` (x2) - **DUPLICATE!**
11. `get_boosting_orders_v2()` - Get boosting orders (old?)
12. `get_boosting_orders_v3` - Get boosting orders (newer)
13. `get_boosting_order_detail_v1` - Get order details
14. `update_order_details_v1` - Update order
15. `update_order_line_machine_info_v1` - Update machine info
16. `cancel_order_line_v1` - Cancel order line
17. `complete_order_line_v1` - Complete order line
18. `mark_order_as_delivered_v1` - Mark delivered
19. `handle_orders_updated_at()` - Trigger for update timestamp

### Work Sessions
20. `start_work_session_v1` - Start work session
21. `finish_work_session_idem_v1` - Finish work session
22. `cancel_work_session_v1` - Cancel work session
23. `get_session_history_v1` - Get session history (old?)
24. `get_session_history_v2` - Get session history (newer)

### Progress & Items
25. `get_last_item_proof_v1` - Get last proof
26. `admin_rebase_item_progress_v1` - Rebase progress
27. `tr_check_all_items_completed_v1()` - Trigger check completion

### Reviews & Reports
28. `create_service_report_v1` - Create report
29. `get_service_reports_v1` - Get reports
30. `resolve_service_report_v1` - Resolve report
31. `submit_order_review_v1` - Submit review
32. `get_reviews_for_order_line_v1` - Get reviews

### Customers
33. `get_customers_by_channel_v1` - Get customers by channel

### Proofs & Actions
34. `update_action_proofs_v1` - Update action proofs

### Permissions & Audit
35. `has_permission` - Check permission
36. `audit_ctx_v1()` - Get audit context
37. `audit_diff_v1` - Audit diff
38. `tr_audit_row_v1()` - Trigger for audit

### Utilities
39. `try_uuid` - Try parse UUID
40. `get_my_assignments` - Get user assignments
41. `add_vault_secret` - Add vault secret

---

## 🔍 Potentially Unused Functions

Need to check frontend code usage:

### Candidates for removal:
- ❓ `get_boosting_orders_v2()` - Replaced by v3?
- ❓ `get_session_history_v1` - Replaced by v2?
- ❓ `create_service_order_v1` (Version 1) - **Definitely remove**

---

## 🚀 Cleanup Plan

### Step 1: Verify Frontend Usage
Check which version of `create_service_order_v1` is used:
```bash
grep -r "create_service_order_v1" src/
```

### Step 2: Create Migration to Remove Old Version
```sql
-- Drop old version of create_service_order_v1
DROP FUNCTION IF EXISTS "public"."create_service_order_v1"(
  "text", "text", "text", "text",
  timestamp with time zone, "text", "text", "text", "text", "text",
  "jsonb", "text"[]
);
```

### Step 3: Check for v2 vs v3 functions
- `get_boosting_orders_v2` vs `get_boosting_orders_v3`
- `get_session_history_v1` vs `get_session_history_v2`

### Step 4: Apply Cleanup Migration
After confirming which functions are not used.

---

## 📋 Next Actions

- [ ] Search frontend code for function usage
- [ ] Identify which version of duplicates are used
- [ ] Create cleanup migration
- [ ] Test on staging first
- [ ] Apply to production
