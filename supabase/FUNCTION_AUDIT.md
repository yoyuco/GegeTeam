# Supabase Functions Audit Report

> Generated: 2025-10-02
> Project: GegeTeam - Staging

---

## 📊 Summary

- **Total RPC Functions**: 36
- **Functions Used in Frontend**: 22
- **Unused Functions**: 14
- **Auth Functions**: 3 (complete ✅)

---

## ✅ Functions USED in Frontend (22)

### Auth & User Management (5)
1. ✅ `get_user_auth_context_v1()` - auth.ts:84
2. ✅ `admin_get_all_users()` - Employees.vue:335
3. ✅ `admin_update_user_status(user_id, status)` - Employees.vue:380
4. ✅ `admin_update_user_assignments(user_id, assignments)` - Employees.vue:450
5. ✅ `admin_get_roles_and_permissions()` - RoleManagement.vue:132

### Role & Permission Management (1)
6. ✅ `admin_update_permissions_for_role(role_id, permission_ids)` - RoleManagement.vue:159

### Order Management (6)
7. ✅ `create_service_order_v1(...)` - Sales.vue:1665, orders.ts:76
8. ✅ `get_boosting_orders_v2()` - ServiceBoosting.vue:2108
9. ✅ `get_boosting_order_detail_v1(line_id)` - ServiceBoosting.vue:2280
10. ✅ `update_order_details_v1(...)` - ServiceBoosting.vue:2476
11. ✅ `complete_order_line_v1(...)` - ServiceBoosting.vue:3110
12. ✅ `cancel_order_line_v1(...)` - ServiceBoosting.vue:3162

### Work Session Management (5)
13. ✅ `start_work_session_v1(...)` - progress.ts:66
14. ✅ `finish_work_session_idem_v1(...)` - progress.ts:88
15. ✅ `cancel_work_session_v1(session_id)` - ServiceBoosting.vue:2864
16. ✅ `get_session_history_v2(line_id)` - ServiceBoosting.vue:2675
17. ✅ `get_last_item_proof_v1(item_ids)` - progress.ts:43

### Reports & Reviews (4)
18. ✅ `get_service_reports_v1(status)` - ReportManagement.vue:299
19. ✅ `create_service_report_v1(...)` - ServiceBoosting.vue:2419
20. ✅ `resolve_service_report_v1(report_id, notes)` - ReportManagement.vue:446
21. ✅ `admin_rebase_item_progress_v1(...)` - ReportManagement.vue:416

### Review System (2)
22. ✅ `get_reviews_for_order_line_v1(line_id)` - ServiceBoosting.vue:3197
23. ✅ `submit_order_review_v1(...)` - ServiceBoosting.vue:3237

### Delivery & Machine Info (2)
24. ✅ `mark_order_as_delivered_v1(order_id, is_delivered)` - ServiceBoosting.vue:2248
25. ✅ `update_order_line_machine_info_v1(line_id, machine_info)` - ServiceBoosting.vue:2559

### Action Proofs (1)
26. ✅ `update_action_proofs_v1(line_id, urls)` - ServiceBoosting.vue:3301

### Utilities (2)
27. ✅ `get_customers_by_channel_v1(channel_code)` - Sales.vue:1004
28. ✅ `dashboard_kpis(_year, _month)` - Dashboard.vue:51 (⚠️ disabled)

### Helper Functions (1)
29. ✅ `is_privileged_v1()` - progress.ts:33 (⚠️ NOT IN SCHEMA!)

---

## ⚠️ Functions UNUSED in Frontend (14)

### Auth Context (2)
1. ❌ `get_my_assignments()` - **Duplicate of get_user_auth_context_v1**
   - **Recommendation**: ✅ Keep - useful helper, may use later

2. ❌ `current_user_id()` - Get current user UUID
   - **Recommendation**: ✅ Keep - utility function

3. ❌ `get_current_profile_id()` - Get profile UUID
   - **Recommendation**: ⚠️ Consider removing if not needed

### Session History (1)
4. ❌ `get_session_history_v1(line_id)` - Old version
   - **Recommendation**: 🗑️ **DELETE** - replaced by v2

### Vault & Audit (2)
5. ❌ `add_vault_secret(name, secret)` - Add secret
   - **Recommendation**: ✅ Keep - admin utility

6. ❌ `audit_ctx_v1()` - Get audit context
   - **Recommendation**: ✅ Keep - used internally by triggers

7. ❌ `audit_diff_v1(old_row, new_row)` - Calculate diff
   - **Recommendation**: ✅ Keep - used internally by triggers

### Utilities (1)
8. ❌ `try_uuid(text)` - Safe UUID conversion
   - **Recommendation**: ✅ Keep - utility function

### Triggers (3)
9. ❌ `handle_new_user_with_trial_role()` - Trigger function
   - **Recommendation**: ✅ Keep - REQUIRED (trigger)

10. ❌ `handle_orders_updated_at()` - Trigger function
    - **Recommendation**: ✅ Keep - REQUIRED (trigger)

11. ❌ `tr_audit_row_v1()` - Audit trigger
    - **Recommendation**: ✅ Keep - REQUIRED (trigger)

12. ❌ `tr_check_all_items_completed_v1()` - Check completion trigger
    - **Recommendation**: ✅ Keep - REQUIRED (trigger)

### Permission Check (1)
13. ❌ `has_permission(permission_code, context)` - Check permission
    - **Recommendation**: ✅ Keep - CRITICAL (used in RLS policies)

---

## 🔍 Auth Context Analysis

### Current Auth Functions: ✅ COMPLETE

```typescript
// 1. Main auth context (USED)
get_user_auth_context_v1() → {
  roles: [{role_code, role_name, game_code, business_area_code}],
  permissions: [{permission_code, game_code, business_area_code}]
}

// 2. Helper for assignments (UNUSED but useful)
get_my_assignments() → jsonb

// 3. Permission checker (CRITICAL - used in RLS)
has_permission(code, context) → boolean

// 4. User ID helpers
current_user_id() → uuid
get_current_profile_id() → uuid
```

### Frontend Auth Store Coverage: ✅ COMPLETE

```typescript
// stores/auth.ts
{
  user: User | null,
  profile: UserProfile | null,
  userPermissions: Set<string>,
  assignments: RoleForUI[],

  // Methods
  init(),
  fetchUserContext(),  // ← calls get_user_auth_context_v1
  signIn(email, password),
  signOut(),
  hasPermission(code, context)  // ← matches DB function
}
```

**Assessment**: Auth context is COMPLETE and well-designed ✅

---

## 🐛 Issues Found

### 1. Missing Function in Schema
```typescript
// progress.ts:33
supabase.rpc('is_privileged_v1')
```
❌ **This function does NOT exist in schema!**

**Fix Options**:
- Option A: Remove the call (seems unused anyway)
- Option B: Create the function if needed
- Option C: Replace with `has_permission()` check

### 2. Disabled Dashboard KPIs
```typescript
// Dashboard.vue:49
async function _loadKPIs() {
  const { data, error } = await supabase.rpc('dashboard_kpis', ...)
```
⚠️ Function exists but is disabled (prefix `_`)

**Recommendation**: Either enable or remove

---

## 📋 Recommendations

### DELETE (1 function)
1. 🗑️ `get_session_history_v1` - Replaced by v2

### CREATE/FIX (1 issue)
1. ⚠️ Fix `is_privileged_v1()` call in progress.ts

### KEEP ALL OTHERS (34 functions)
- 22 actively used
- 12 infrastructure (triggers, utilities, RLS helpers)

---

## 🎯 Action Items

### High Priority
- [ ] Fix `is_privileged_v1()` call in progress.ts:33
- [ ] Delete `get_session_history_v1` (old version)
- [ ] Enable or remove dashboard_kpis usage

### Low Priority
- [ ] Consider removing `get_current_profile_id()` if truly not needed
- [ ] Document which functions are for internal use only

---

## ✅ Final Verdict

**Auth Context**: ✅ **COMPLETE and well-designed**
- Comprehensive role & permission system
- Context-aware permissions (game, business area)
- Proper frontend integration
- No missing functionality

**Database Functions**: ✅ **Healthy with minor cleanup needed**
- 94% utilization (34/36 functions are necessary)
- Only 1 true unused function (get_session_history_v1)
- 1 bug to fix (is_privileged_v1)

---

*Generated by analyzing:*
- `supabase/migrations/20251002052515_remote_schema.sql`
- `src/**/*.{ts,vue}` (grep for `supabase.rpc(`)
