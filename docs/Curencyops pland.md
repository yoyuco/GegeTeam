# 🧭 Đặc tả Hoàn chỉnh: Hệ thống Quản lý Dòng tiền & Tồn kho Tiền tệ Game
# (Phiên bản 2.0: Bình quân Gia quyền theo Pool)

Đây là tài liệu đặc tả kỹ thuật chính thức và cuối cùng, mô tả kiến trúc và luồng vận hành của hệ thống. Mô hình này sử dụng phương pháp **Bình quân Gia quyền (Weighted Average Cost)** để quản lý tồn kho, thay vì theo dõi từng lô (FIFO).

---

## 1. 🏗️ Cấu trúc Dữ liệu (Database Schema)

Hệ thống bao gồm 3 nhóm bảng chính.

### Nhóm 1: Vận hành & Nhân sự (Tổ chức)

**`Shifts` (Ca làm việc)**
* `ShiftID` (PK): Mã ca (vd: "CA_SANG")
* `ShiftName`: Tên ca (vd: "Ca Sáng 8h-20h")
* `StartTime`, `EndTime`: Giờ bắt đầu, kết thúc.

**`GameAccounts` (Tài khoản Game/Kho)**
* `AccountID` (PK): Mã tài khoản (vd: "Acc1")
* `AccountName`: Tên tài khoản.

**`Employees` (Nhân viên)**
* `EmployeeID` (PK): Mã nhân viên (vd: "A")
* `EmployeeName`: Tên nhân viên.
* `AssignedShiftID` (FK - `Shifts`): Gán nhân viên vào ca làm việc cố định.
* `AssignedAccountID` (FK - `GameAccounts`): Gán NV phụ trách bàn giao 1 Account cố định.

---

### Nhóm 2: Cấu hình Tài chính (Quy tắc & Chi phí)

**`Fees` (Phí Chi tiết)**
* `FeeID` (PK): Mã phí.
* `FeeName`: Tên phí (vd: "Phí Sàn A", "Phí Rút Bank", "Thuế 10%")
* `Direction`: Loại nghiệp vụ (`BUY`, `SELL`, `WITHDRAW`, `TAX`, `OTHER`...)
* `FeeType`: Loại phí (`RATE` - %, `FIXED` - Cố định).
* `Amount`: Giá trị (vd: 0.05 hoặc 10000).
* `Currency`: Đơn vị tiền tệ của phí (VND, USD...).

**`Channels` (Kênh Mua/Bán)**
* `ChannelID` (PK): Mã kênh (vd: "KENH_MUA_A")
* `ChannelName`: Tên kênh.
* `Direction`: Chức năng (`BUY` hoặc `SELL`).
* `TransactionFeeID` (FK - `Fees`): Phí giao dịch *trực tiếp* khi dùng kênh này.

**`BusinessProcesses` (Quy trình Kinh doanh / Stock Pool)**
* `ProcessID` (PK): Mã quy trình (vd: "P_A_B"). Đây chính là **"Stock Pool"**.
* `ProcessName`: Tên quy trình (vd: "Mua Sàn A - Bán Sàn B").
* `Description`: Mô tả chi tiết về quy trình kinh doanh.
* `IsActive`: Trạng thái hoạt động của quy trình.

**`Process_OtherFees_Map` (Phí Bổ sung của Quy trình)**
* `ProcessID` (FK - `BusinessProcesses`): Mã quy trình.
* `FeeID` (FK - `Fees`): Mã các phí bổ sung (`WITHDRAW`, `TAX`, `OTHER`...).

---

### Nhóm 3: Vận hành Nghiệp vụ & Kho hàng

**`GameItems` (Hàng hóa Game)**
* `GameItemID` (PK): Mã hàng hóa nội bộ (Được ánh xạ từ `attributes` table).
* `GameCode`: Mã game.
* `GameServer`: Máy chủ (Được ánh xạ từ `attributes` table).
* `GameCurrency`: Loại tiền tệ trong game (Được ánh xạ từ `attributes` table).
* `ItemName`: Tên hiển thị (vd: "Vàng - Server A - US").
* *Ghi chú: Hệ thống sử dụng `attributes` table với type `GAME_CURRENCY` và `attribute_relationships` để quản lý game items.*

**`ShiftRoleAssignments` (Phân công Vai trò Mua)**
* `EmployeeID` (FK - `Employees`): Nhân viên nào.
* `ChannelID` (FK - `Channels`): Được phép mua/bán ở kênh nào.
* `ShiftName`: Tên ca làm việc.

**`AssignmentTrackers` (Bộ nhớ Phân công Tuần tự)**
* `TrackerType` (PK): Loại nghiệp vụ (vd: "BUY_KENH_A", "SELL_GAME_POE2").
* `LastAssignedID`: ID cuối cùng được gán (có thể là `EmployeeID` hoặc `AccountID`).

**`inventory_pools` (Kho Tổng hợp theo Pool - CỐT LÕI)**
Bảng này được implement với cấu trúc chính xác.

| Tên cột | Kiểu dữ liệu | Khóa | Mô tả |
| :--- | :--- | :--- | :--- |
| `game_account_id` | FK | PK, FK (`GameAccounts`) | Hàng đang nằm ở Account nào |
| `currency_attribute_id` | FK | PK, FK (`Attributes`) | Hàng này là *hàng gì* (game currency) |
| `process_id` | FK | PK, FK (`BusinessProcesses`) | Hàng này thuộc **"Stock Pool"** nào |
| `quantity` | Decimal | | **Tổng số lượng** còn lại |
| `average_cost` | Decimal | | **Giá vốn trung bình** (bình quân gia quyền) |
| `cost_currency` | String | | Đơn vị tiền tệ của giá vốn (VND, USD...) |
| `reserved_quantity` | Decimal | | Số lượng đang được giữ reserve |
| `last_updated_at` | Timestamp | | Thời gian cập nhật cuối |
| `last_updated_by` | FK | Người cập nhật cuối |

*Ghi chú: Khóa chính (PK) của bảng này là bộ 3 (`game_account_id`, `currency_attribute_id`, `process_id`). Mỗi dòng là một "kho" duy nhất.*

---

## 2. ⚙️ Luồng Vận hành (Phương pháp Bình quân)

### 2.1. Luồng Mua hàng (PHÂN TÁCH BIỆT - FE + BE + FE + BE)

Đây là nghiệp vụ phức tạp nhất, được chia thành 4 bước riêng biệt:

#### **Bước 1: Frontend Tạo Đơn** (CurrencyCreateOrders.vue)
1. **User tạo đơn purchase**:
   - Chọn currency, quantity, cost amount, supplier, channel
   - Upload bằng chứng đàm phán + thanh toán
   - System gọi `create_currency_purchase_order_draft()`
   - Order được tạo trong `currency_orders` với status = 'draft' → 'pending'

#### **Bước 2: Backend Tự Động Phân Công** (Auto-Assignment Trigger)
2. **Auto-assignment khi order status = 'pending':**
   - **Backend trigger** tự động chạy khi order chuyển sang 'pending'
   - **Round-robin assignment:**
     * Kiểm tra ca làm việc hiện tại
     * Tìm nhân viên có quyền với purchase channel đó
     * Dùng `assignment_trackers` để chọn nhân viên tiếp theo (fair rotation)
     * Gán game account phù hợp cho nhân viên
   - **Cập nhật:**
     * `assigned_to` = employee_id
     * `assigned_game_account_id` = game_account_id
     * `assigned_at` = current_time
     * `status` = 'assigned'

#### **Bước 3: Frontend Nhận Hàng** (CurrencyOps.vue - Delivery Tab)
3. **Employee xử lý đơn đã được phân công:**
   - **Tab "Giao nhận Currency"** load orders với status = 'assigned'
   - Employee xem thông tin: supplier, currency, game account được phân công
   - Employee **nhận hàng hóa** từ game account
   - Click "Xác nhận nhận hàng" → status = 'in_progress'

#### **Bước 4: Backend Hoàn Thành Đơn** (Backend Functions)
4. **Employee hoàn thành xử lý:**
   - Employee click "Hoàn thành" trong frontend
   - Frontend gọi `complete_purchase_order()` RPC
   - **Backend tính WAC:**
     * Lấy current inventory từ `inventory_pools`
     * Tính new WAC: (OldQty × OldWAC + NewQty × NewUnitCost) / (Old + New)
   - **Update inventory_pools** với quantity và average_cost mới
   - **Update currency_orders** status = 'completed'

*Ví dụ thực tế với WAC calculation:*
- **Old inventory:** 500 units @ 0.048 = $24
- **New purchase:** 1000 units @ 0.050 = $50
- **New WAC:** ($24 + $50) / (500 + 1000) = $0.0493/unit
- **Total inventory:** 1500 units @ $0.0493 = $74

### 2.2. Luồng Bán hàng (Luân phiên Pool & Đảm bảo Số lượng)

Luồng này đảm bảo luân phiên đúng `ProcessID` (Pool).

1.  **Khởi tạo:** Bán **50** "Vàng-Server-A" (`GameItemID`=123), giá bán 15M, qua "Kênh Bán B".

2.  **Bước 1: Chọn "Pool" để Luân phiên (Round-Robin)**
    * Hệ thống kiểm tra `InventoryPools` thấy `GameItemID` 123 đang tồn ở 2 `ProcessID` ("P_A_B" và "P_C_D").
    * Tra `AssignmentTrackers` (TrackerType="SELL_POOL_GAMEITEM_123") -> `LastAssignedID` là "P_C_D".
    * Hệ thống chọn luân phiên -> Quyết định lần này bán từ pool **"P_A_B"**.

3.  **Bước 2.1: Tìm Kho (Account) có đủ hàng**
    * Hệ thống tìm trong `currency_inventory` một `GameAccountID` thỏa mãn ĐỒNG THỜI:
        * `ProcessID` = "P_A_B"
        * `CurrencyAttributeID` = 123
        * `Quantity - ReservedQuantity` >= **50** (Đủ số lượng bán)
    * **Giả sử:** `Acc2` (`Quantity`=400) và `Acc3` (`Quantity`=100) đều đủ.
    * (Hệ thống có thể dùng 1 tracker phụ để luân phiên giữa `Acc2` và `Acc3`. Giả sử chọn **`Acc2`**).

    **Bước 2.2: Phân công Nhân viên**
    * Hệ thống xác định hàng hóa nằm trên `Acc2`.
    * Kiểm tra giờ -> "Ca Sáng".
    * Tìm nhân viên (vd: `Nhân viên B`) quản lý `Acc2` trong "Ca Sáng".
    * Giao task cho `Nhân viên B` bán 50 sản phẩm từ `Acc2`.

4.  **Bước 3: Xử lý Nếu Pool 1 Không đủ**
    * **Nếu KHÔNG TÌM THẤY** `Account` nào trong `Pool "P_A_B"` có đủ 50:
    * Hệ thống sẽ tự động chuyển sang Pool tiếp theo trong danh sách, ví dụ: **Pool "P_C_D"**.
    * Hệ thống lặp lại Bước 2 với `ProcessID` = "P_C_D".
    * (Nếu tất cả các Pool đều không đủ. Đơn hàng sẽ chọn poll và account đến lượt và sẽ trừ âm quanty của stock này - cần 1 bước xử lý ưu tiên nhập đủ cho pool và account này khi nhập hàng, sau đó lại tuần tự)

5.  **Bước 4: Phân công & Cập nhật Kho**
    * Giả sử Bước 2 thành công (chọn `Acc2` từ `Pool "P_A_B"`).
    * `AvgBuyPrice` của kho này là **101,250 VND**.
    * Tìm nhân viên (vd: `Nhân viên B`) quản lý `Acc2` trong ca.
    * Giao task cho `Nhân viên B` bán 50 sản phẩm.
    * `UPDATE currency_inventory SET Quantity = Quantity - 50 WHERE GameAccountID = 'Acc2' AND CurrencyAttributeID = 123 AND ProcessID = 'P_A_B'`.
    * (Lưu ý: `AvgBuyPrice` **không đổi** khi bán).

6.  **Bước 5: Tính Lợi nhuận**
    * `Doanh thu` = 15,000,000 VND.
    * **(A) Giá Vốn (COGS):** Lấy từ kho đã xuất:
        * = 50 * `AvgBuyPrice` (101,250) = **5,062,500 VND**.
    * **(B) Phí Bán (Sale Fee):** Lấy từ kênh bán (vd: 750,000 VND).
    * **(C) Phí Bổ sung (Other Fees):** Lấy từ quy trình và các loại phí khác.
    * **Lợi nhuận** = `Doanh thu` - (A) - (B) - (C).

7.  **Bước 6: Cập nhật Tracker**
    * Cập nhật `AssignmentTrackers` ("SELL_GAME_POE2" hoặc "SELL_PROCESS_P_A_B") -> `LastAssignedID` = "P_A_B".

---

## 3. Tổng kết

Mô hình này giữ được toàn bộ logic nghiệp vụ (Ca, Kênh, Phí, Quy trình) nhưng đơn giản hóa triệt để khâu quản lý kho bằng phương pháp bình quân gia quyền, đúng theo yêu cầu tinh giản hóa.

## 4. Cập nhật Database Structure

### **Bảng chính đã implement:**
- **`currency_inventory`** - Thay thế `InventoryPools` với PK: (game_account_id, currency_attribute_id, process_id)
- **`business_processes`** - Quản lý các Stock Pool/Process
- **`fees`** - Quản lý chi phí chi tiết
- **`channels`** - Kênh mua/bán với `transaction_fee_id`
- **`currency_orders`** - Đơn hàng (tích hợp cả purchase và sale)
- **`attributes`** + **`attribute_relationships`** - Game items và currency definitions
- **`game_accounts`** - Tài khoản game/kho
- **`assignment_trackers`** - Round-robin assignment logic
- **`shift_role_assignments`** - Phân công vai trò theo ca

### **Bảng đã dọn dẹp:**
- **`sale_orders`** → Merge vào `currency_orders`
- **`purchase_orders`** → Merge vào `currency_orders`
- **`inventory_pools`** → Merge vào `currency_inventory`

### **Cấu trúc mới:**
- Hệ thống sử dụng `attributes` table với `type = 'GAME_CURRENCY'` thay vì `GameItems` table riêng biệt
- Process mapping được xử lý qua business logic thay vì default channels
- Inventory pools được quản lý qua `currency_inventory` với đúng PK composite