# Currency Operations Permission System

## Tổng quan

Tài liệu này mô tả hệ thống phân quyền cho các chức năng currency trading trong GegeTeam. Hệ thống sử dụng role-based permissions với kiểm tra quyền chi tiết cho từng tác vụ.

## 1. Database Permissions

### 1.1 Currency Permissions List

| Permission Code | Mô tả | Role được cấp quyền |
|--------------|---------|-------------------------|
| `currency:assign_orders` | Gán đơn currency cho users | admin, manager, mod, trader_manager, trader_leader, trader1 |
| `currency:cancel_orders` | Hủy đơn currency | admin, manager, mod, trader_manager, trader_leader, trader1 |
| `currency:complete_orders` | Hoàn thành đơn currency và cập nhật inventory | admin, manager, mod, trader_manager, trader_leader, trader1, trader2, farmer_manager |
| `currency:create_orders` | Tạo đơn currency mới | admin, manager, mod, trader_manager, trader_leader, trader1 |
| `currency:deliver_orders` | Đánh dấu đơn currency đã giao | admin, manager, mod, trader_manager, trader_leader, trader1, trader2, farmer_manager, farmer |
| `currency:edit_deadline` | Sửa deadline đơn currency | admin, manager, mod, trader_manager, trader_leader, trader1 |
| `currency:edit_notes` | Sửa ghi chú đơn currency | admin, manager, mod, trader_manager, trader_leader, trader1 |
| `currency:edit_orders` | Sửa thông tin chi tiết đơn currency | admin, manager, mod, trader_manager, trader_leader, trader1 |
| `currency:edit_price` | Sửa giá đơn currency | admin, manager, mod, trader_manager, trader_leader, trader1 |
| `currency:exchange_orders` | Đổi currency giữa các game | admin, manager, mod, trader_manager, trader_leader, trader1, trader2, farmer_manager |
| `currency:manage_all_orders` | Quản lý tất cả đơn currency (không phân công) | admin, manager, mod, trader_manager |
| `currency:manage_inventory` | Quản lý inventory currency | admin, manager, mod, trader_manager, trader_leader, trader1, trader2, farmer_manager |
| `currency:override_orders` | Ghi đè giới hạn đơn currency | admin, manager, mod, trader_manager |
| `currency:receive_orders` | Xác nhận nhận currency | admin, manager, mod, trader_manager, trader_leader, trader1, trader2, farmer_manager |
| `currency:start_orders` | Bắt đầu xử lý đơn currency | admin, manager, mod, trader_manager, trader_leader, trader1, trader2, farmer_manager |
| `currency:transfer_inventory` | Chuyển currency giữa các inventory pools | admin, manager, mod, trader_manager, trader_leader, trader1, trader2, farmer_manager |
| `currency:view_analytics` | Xem phân tích và báo cáo currency | admin, manager, mod, trader_manager, trader_leader |
| `currency:view_inventory` | Xem lượng tồn kho currency | admin, manager, mod, trader_manager, trader_leader, trader1, trader2, farmer_manager |
| `currency:view_order_details` | Xem chi tiết đơn currency | admin, manager, mod, trader_manager, trader_leader, trader1, trader2, farmer_manager |
| `currency:view_orders` | Xem danh sách đơn currency | **Tất cả roles** |

### 1.2 Role Permission Mapping

**Full Access Roles** (21/21 permissions):
- **admin** - Administrator
- **mod** - Moderator
- **manager** - Manager
- **trader_manager** - Trader Manager

**Partial Access Roles**:
- **trader_leader** - 19/21 permissions (thiếu: assign, manage_all, manage_inventory, override)
- **trader1** - 14/21 permissions (thiếu: assign, manage_all, deliver, receive, transfer, view_inventory, override)
- **trader2** - 11/21 permissions (thiếu: create, edit_all, edit_price, edit_deadline, start, view_details)
- **farmer_manager** - 14/21 permissions (operations focus)
- **farmer** - 6/21 permissions (chỉ basic operations)

## 2. Frontend Implementation

### 2.1 usePermissions Composable Methods

Các methods sau đã được implement trong `src/composables/usePermissions.js`:

```javascript
// Tab Navigation Methods
canCreateCurrencyOrders()     // currency:create_orders
canViewCurrencyOrders()       // currency:view_orders
canEditCurrencyOrders()       // currency:edit_orders
canAssignCurrencyOrders()     // currency:assign_orders
canCancelCurrencyOrders()     // currency:cancel_orders
canCompleteCurrencyOrders()   // currency:complete_orders
canDeliverCurrencyOrders()    // currency:deliver_orders
canReceiveCurrencyOrders()    // currency:receive_orders
canExchangeCurrencyOrders()   // currency:exchange_orders
canStartCurrencyOrders()      // currency:start_orders

// Other Operations
canEditPrice()           // currency:edit_price
canEditDeadline()        // currency:edit_deadline
canEditNotes()          // currency:edit_notes
canManageAllOrders()     // currency:manage_all_orders
canOverrideOrders()      // currency:override_orders
canTransferInventory()    // currency:transfer_inventory
canViewInventory()        // currency:view_inventory
canViewOrderDetails()    // currency:view_order_details
canViewAnalytics()        // currency:view_analytics
```

### 2.2 Permission Integration in CurrencyOps.vue

Các vị trí sau đã được bảo vệ:

#### **A. Navigation Tabs**
- **Tab "Đổi Currency"**: `v-if="permissions.canExchangeCurrencyOrders()"`
- **Tab "Giao nhận Currency"**: `v-if="permissions.canDeliverCurrencyOrders() || permissions.canReceiveCurrencyOrders() || permissions.canCompleteCurrencyOrders() || permissions.canCancelCurrencyOrders() || permissions.canEditCurrencyOrders()"`
  - **Chức năng bao gồm**: Giao hàng, Nhận hàng, Hoàn thành đơn, Hủy đơn, Sửa thông tin đơn
- **Tab "Lịch sử"**: `v-if="permissions.canViewCurrencyOrders()"`
- **Inventory Panel**: `v-if="permissions.canViewInventory()"`

#### **B. Tab Content Protection**
- **Tab Content**: Chỉ hiển thị nếu user có quyền truy cập tương ứng
- **No Access Message**: Hiển thị thông báo "Không có quyền truy cập" nếu user không có bất kỳ quyền nào

#### **C. Smart Tab Selection**
- **Auto-tab Selection**: Tự động chọn tab đầu tiên user có quyền truy cập
- **Fallback Logic**: Quay về tab mặc định nếu không có quyền nào

## 3. Security Features

### 3.1 Multi-layer Security

1. **Database Level**: Row Level Security (RLS) policies
2. **Function Level**: RPC functions với permission checks
3. **Frontend Level**: Vue.js conditional rendering
4. **UI Level**: Component visibility guards

### 3.2 Business Area Integration

- **Support cho Currency**: Tất cả permissions thuộc group "Currency"
- **Support cho NULL Areas**: Các roles admin/manager có quyền truy cập tất cả các khu vực
- **Game-based Access**: Permissions được kiểm tra theo game context khi cần thiết

### 3.3 User Experience

- **Progressive Enhancement**: UI chỉ hiển thị chức năng user có quyền
- **Clear Feedback Messages**: Thông báo rõ ràng khi không có quyền truy cập
- **Smart Defaults**: Tự động chọn tab phù hợp nhất user có quyền truy cập

## 4. Role-Based Access Matrix

| Role | Tạo Đơn | Xem Đơn | Sửa | Giao/Nhận | Lịch sử | Quản lý | Chuyển Kho |
|------|---------|---------|-----|------|-----------|-----------|--------------|
| **admin** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **manager** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **mod** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **trader_manager** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ | ✅ |
| **trader_leader** | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ | ✅ |
| **trader1** | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| **trader2** | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| **farmer_manager** | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| **farmer** | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |

**Legend**:
- ✅ = Có quyền truy cập
- ❌ = Không có quyền truy cập

## 5. Migration and Testing

### 5.1 Testing Scenarios

1. **Admin User**: Xem tất cả tabs, sử dụng tất cả chức năng
2. **Manager User**: Xem tất cả tabs, không có một số quản lý chức năng
3. **Trader User**: Chỉ thấy tabs được cấp quyền cho role cụ thể
4. **Farmer User**: Chỉ thấy tabs cơ bản và chức năng giao nhận

### 5.2 Database Verification

```sql
-- Verify permissions exist in database
SELECT r.name as role_name, p.code as permission_code, p."group" as permission_group
FROM roles r
JOIN role_permissions rp ON r.id = rp.role_id
JOIN permissions p ON rp.permission_id = p.id
WHERE p.code LIKE 'currency:%'
ORDER BY r.code, p.code;
```

### 5.3 Frontend Testing

```javascript
// Verify all permission methods work
console.log('Can create orders:', permissions.canCreateCurrencyOrders());
console.log('Can view orders:', permissions.canViewCurrencyOrders());
console.log('Can exchange orders:', permissions.canExchangeCurrencyOrders());
// ... etc
```

## 6. Troubleshooting

### 6.1 Common Issues

1. **Permission Not Granted**: Kiểm tra role-permission mappings trong database
2. **Caching Issues**: Refresh permissions hoặc logout/login lại
3. **Business Area Mismatch**: Đảm bảo user được gán vào business area chính xác

### 6.2 Debug Steps

1. **Check User Role**: Xác nhận role hiện tại của user
2. **Check Permissions**: Xác nhận permissions được gán cho role đó
3. **Verify Database**: Đảm bảo permissions tồn tại trong database
4. **Check Frontend**: Xác nhận usePermissions composable hoạt động đúng

### 6.3 Contact Support

Nếu vẫn gặp vấn đề:
- Kiểm tra logs trình duyệt cho error messages
- Liên hệ team admin để review permission assignments
- Kiểm tra database consistency issues

---

*Document last updated: 2024-11-28*
*Version: 1.0.0*