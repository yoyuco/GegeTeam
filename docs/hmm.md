# 🧭 Đặc tả Kỹ thuật Hoàn chỉnh: Hệ thống Quản lý Dòng tiền & Tồn kho Game (Bản 4.0)
# (Mô hình: Chi phí Thực tế theo Nguồn gốc & Phân công theo Ca)

## 1. 📖 Tổng quan Hệ thống

Mô hình này được thiết kế để giải quyết 3 bài toán nghiệp vụ cốt lõi, phản ánh chính xác các yêu cầu phức tạp đã đặt ra:

1.  **Quản lý Kho (Inventory):** Hàng tồn kho KHÔNG được quản lý theo "Vòng tròn Phí". Thay vào đó, kho được quản lý theo **"Nguồn gốc Mua"** (Kênh Mua + Tiền Mua) và sử dụng phương pháp **Bình quân Gia quyền (WAC)**. Mỗi "Pool" kho là một tổ hợp duy nhất của (`Account`, `Hàng hóa`, `Kênh Mua`, `Tiền Mua`).
2.  **Tính Lợi nhuận (Costing):** "Vòng tròn Phí" (`BusinessProcesses`) KHÔNG phải là một thuộc tính của kho. Nó là một **"Công thức Tính Lợi nhuận"** phức tạp, được hệ thống *tự động tra cứu* tại thời điểm Bán, dựa trên một tổ hợp 4 yếu tố: (Kênh Mua, Tiền Mua) -> (Kênh Bán, Tiền Bán).
3.  **Phân công (Assignment):** Giải quyết bài toán 2 Ca - 8 Nhân viên - 4 Account. Nhân viên được gán `Account` và `Role` (Vai trò) *theo ca* thông qua một bảng phân công ca (`Shift_Assignments`), đảm bảo logic "bàn giao" (handover) chính xác.
4.  **Tự động hóa (Automation):** Hệ thống tự động phân công Đơn Mua và Đơn Bán cho nhân viên đang trong ca. Hệ thống quản lý hàng chờ bán (`ReservedQuantity`).

---

## 2. 🏗️ Cấu trúc Dữ liệu (Database Schema)

### Nhóm 1: Vận hành & Phân công (Ai? Khi nào? Ở đâu?)

**`Shifts` (Ca làm việc)**
* `ShiftID` (PK): Mã ca (vd: "CA_SANG")
* `ShiftName`: Tên ca (vd: "Ca Sáng 8h-20h")
* `StartTime`, `EndTime`: Giờ bắt đầu, kết thúc.

**`Employees` (Nhân viên)**
* `EmployeeID` (PK): Mã nhân viên (vd: "A", "B", ... "H")
* `EmployeeName`: Tên nhân viên
* *(Bảng này không chứa bất kỳ thông tin gán việc nào)*

**`GameAccounts` (Tài khoản Game/Kho chứa)**
* `AccountID` (PK): Mã tài khoản (vd: "Acc1", "Acc2", "Acc3", "Acc4")
* `AccountName`: Tên tài khoản.

**`Shift_Assignments` (Bảng Phân công Ca - CỐT LÕI)**
Bảng này là trung tâm của toàn bộ hệ thống phân công, giải quyết logic 8-4-2.
| Tên cột | Kiểu dữ liệu | Khóa | Mô tả |
| :--- | :--- | :--- | :--- |
| `ShiftID` | FK | PK, FK (`Shifts`) | Ca làm việc (Sáng, Đêm) |
| `EmployeeID` | FK | PK, FK (`Employees`) | Nhân viên nào (A, B...) |
| `AssignedAccountID`| FK | FK (`GameAccounts`)| ...sẽ phụ trách Account nào (Acc1...) trong ca này |
| `AssignedRole` | String | | ...và đảm nhận vai trò Mua nào (vd: "VN", "China") |

*Dữ liệu mẫu:*
| ShiftID | EmployeeID | AssignedAccountID | AssignedRole |
|:---|:---|:---|:---|
| "Ca Sáng" | "A" | "Acc1" | "VN" |
| "Ca Sáng" | "B" | "Acc2" | "VN" |
| "Ca Sáng" | "C" | "Acc3" | "China" |
| "Ca Sáng" | "D" | "Acc4" | "China" |
| "Ca Đêm" | "E" | "Acc1" | "VN" |
| "Ca Đêm" | "F" | "Acc2" | "VN" |
| ... | ... | ... | ... |

**`AssignmentTrackers` (Bộ nhớ Luân phiên)**
* `TrackerType` (PK): Loại nghiệp vụ (vd: "BUY_ROLE_CHINA", "SELL_POOL_G1_S1_VANG_WECHAT_RMB")
* `LastAssignedID`: ID cuối cùng được gán (có thể là `EmployeeID` hoặc `AccountID`).

---

### Nhóm 2: Cấu hình Tài chính (Quy tắc & Chi phí)

**`Channels` (Kênh Mua/Bán)**
* `ChannelID` (PK): Mã kênh (vd: "Wechat", "Bank_VND", "EU_Market")
* `ChannelName`: Tên kênh
* `Direction`: Chức năng (`BUY`, `SELL`, `BOTH`)

**`Channel_Role_Map` (Bản đồ Vai trò Kênh)**
Bảng này giúp hệ thống biết gán đơn Mua cho vai trò nào.
* `PurchaseChannelID` (PK, FK - `Channels`): Kênh Mua nào (vd: "Wechat")
* `AssignedRole` (String): ...thì thuộc về Vai trò nào (vd: "China")

**`Currencies` (Tiền tệ Thanh toán)**
* `CurrencyCode` (PK): Mã tiền tệ (vd: "RMB", "USD", "VND", "EUR")
* `CurrencyName`: Tên (Nhân dân tệ, Đô la Mỹ...)

**`Fees` (Phí Chi tiết)**
* `FeeID` (PK): Mã phí.
* `FeeName`: Tên phí (vd: "Phí Mua Wechat 1%", "Phí Bán EU 3%", "Thuế 10%")
* `Direction`: Loại nghiệp vụ (`BUY`, `SELL`, `WITHDRAW`, `TAX`, `OTHER`...)
* `FeeType`: Loại phí (`RATE` - %, `FIXED` - Cố định).
* `Amount`: Giá trị (vd: 0.05 hoặc 10000).
* `Currency`: Đơn vị tiền tệ của phí (RMB, USD...).

**`Channel_Fees_Map` (Bản đồ Phí Kênh)**
* `ChannelID` (PK, FK - `Channels`): Kênh nào...
* `FeeID` (PK, FK - `Fees`): ...thì có các khoản phí nào.
* *(Giải quyết vấn đề 1 Kênh có nhiều Phí/Tiền tệ)*

**`ExchangeRates` (Tỷ giá Hối đoái)**
* `FromCurrency` (PK): (vd: "USD")
* `ToCurrency` (PK): (vd: "VND")
* `Rate`: Tỷ giá

**`BusinessProcesses` (Vòng tròn / Công thức Lợi nhuận)**
Bảng này là "bộ não" kế toán, định nghĩa công thức cho một luồng nghiệp vụ hoàn chỉnh.
| Tên cột | Kiểu dữ liệu | Khóa | Mô tả |
| :--- | :--- | :--- | :--- |
| `ProcessID` | PK | PK | Mã Vòng tròn (vd: "WEC_RMB_TO_EU_EUR") |
| `ProcessName` | String | | Tên Vòng tròn (Mua Wechat RMB, Bán EU EUR) |
| `PurchaseChannelID` | FK | FK (`Channels`) | **Điều kiện Mua: Kênh nào** |
| `PurchaseCurrency` | FK | FK (`Currencies`) | **Điều kiện Mua: Tiền gì** |
| `SaleChannelID` | FK | FK (`Channels`) | **Điều kiện Bán: Kênh nào** |
| `SaleCurrency` | FK | FK (`Currencies`) | **Điều kiện Bán: Tiền gì** |

**`Process_OtherFees_Map` (Phí Bổ sung của Vòng tròn)**
* `ProcessID` (FK - `BusinessProcesses`): Vòng tròn nào...
* `FeeID` (FK - `Fees`): ...thì có các Phí Bổ sung (Thuế, Rút...) nào.

---

### Nhóm 3: Kho hàng & Đơn hàng (CỐT LÕI)

**`InventoryPools` (Kho Tổng hợp theo Nguồn gốc)**
Bảng quan trọng nhất, đã tích hợp yêu cầu tự động hóa và quản lý `Game...` trực tiếp.

| Tên cột | Kiểu dữ liệu | Khóa | Mô tả |
| :--- | :--- | :--- | :--- |
| `AccountID` | FK | PK, FK (`GameAccounts`) | (Vị trí) Hàng đang nằm ở Account nào |
| `GameCode` | String | PK | **(Hàng hóa) Mã Game** |
| `GameServer` | String | PK | **(Hàng hóa) Máy chủ** |
| `GameCurrency` | String | PK | **(Hàng hóa) Tiền tệ trong Game** (vd: Vàng) |
| `PurchaseChannelID` | FK | PK, FK (`Channels`) | **(Nguồn gốc) Mua từ Kênh nào** |
| `PurchaseCurrency` | FK | PK, FK (`Currencies`) | **(Nguồn gốc) Mua bằng Tiền gì** (vd: RMB) |
| `TotalQuantity` | Decimal | | **Tổng số lượng** thực tế đang có |
| `ReservedQuantity` | Decimal | | **Số lượng đang chờ giao** ("revert qty") |
| `AverageCost` | Decimal | | **Giá vốn trung bình** (tính bằng `CostCurrency`) |
| `CostCurrency` | String | | (Chính là `PurchaseCurrency`) |

*Ghi chú: Số lượng Khả dụng (AvailableQty) = `TotalQuantity` - `ReservedQuantity`*

**`PurchaseOrders` (Đơn Mua hàng)**
* `PO_ID` (PK): Mã đơn mua
* `Status`: (vd: `PendingAssignment`, `Assigned`, `Completed`, `Cancelled`)
* `GameCode`, `GameServer`, `GameCurrency`: Hàng cần mua
* `PurchaseChannelID`, `PurchaseCurrency`: Mua ở đâu, bằng tiền gì
* `Quantity`: Số lượng
* `TotalCost`: Tổng chi phí (bằng `PurchaseCurrency`)
* `AssignedEmployeeID` (FK - `Employees`): Gán cho NV nào
* `AssignedAccountID` (FK - `GameAccounts`): Gán cho Kho nào

**`SaleOrders` (Đơn Bán hàng)**
* `SO_ID` (PK): Mã đơn bán
* `Status`: (vd: `PendingAssignment`, `Assigned`, `Completed`, `Cancelled`)
* `GameCode`, `GameServer`, `GameCurrency`: Hàng cần bán
* `Quantity`: Số lượng
* `SaleChannelID`, `SaleCurrency`: Bán ở đâu, thu tiền gì
* `TotalRevenue`: Tổng doanh thu (bằng `SaleCurrency`)
* `AssignedEmployeeID` (FK - `Employees`): Gán cho NV nào
* `AssignedAccountID` (FK - `GameAccounts`): Gán cho Kho nào
* `Source_PurchaseChannelID` (FK): (Lưu lại) Bán từ Pool có nguồn Kênh Mua nào
* `Source_PurchaseCurrency` (FK): (Lưu lại) Bán từ Pool có nguồn Tiền Mua nào
* `CalculatedProfit`: (Lợi nhuận sau khi hoàn thành)

---

## 3. ⚙️ Luồng Vận hành Tự động (Đã sửa lỗi)

### 3.1. Luồng Mua hàng Tự động (Đã sửa)

1.  **Tạo Đơn Mua (Admin/Quản lý):**
    * Tạo `curency_order` mới: (Mua 100 Vàng G1-S1, qua `PurchaseChannelID`="Wechat", bằng `PurchaseCurrency`="RMB", `TotalCost`=700 RMB).
    * `Status` = `PendingAssignment`.
2.  **Hệ thống (Tự động Phân công):**
    * **Kiểm tra Ca:** Xác định ca hiện tại ("Ca Sáng").
    * **Tìm Vai trò:** Tra `Shift_Assignments` -> `Channel` = "Wechat", `curency_code` = "CNY"
    * **Tìm Nhân viên (Luân phiên):**
        * Tra `Shift_Assignments` tìm *tất cả* `EmployeeID` (vd: `NV C`, `NV D`) thỏa mãn:
            * (A) `ShiftID` = "Ca Sáng".
            * (B) `Channel` = "Wechat", `curency_code` = "CNY"
        * Tra `AssignmentTrackers` (TrackerType="BUY_ROLE_CHINA") -> `LastAssignedID` là "C".
        * Hệ thống chọn **`NV D`**.
    * **Tìm Account:** Tra `Shift_Assignments` -> `NV D` (Ca Sáng) được gán `AssignedAccountID` = "Acc4".
    * **Gán việc:** Cập nhật `PurchaseOrder`: `AssignedEmployeeID`="D", `AssignedAccountID`="Acc4", `Status`=`Assigned`.
    * Cập nhật `AssignmentTrackers` ("BUY_ROLE_CHINA") -> `LastAssignedID` = "D".
3.  **Nhân viên (Nhận hàng):**
    * `NV D` thấy đơn hàng được gán cho mình trên `Acc4`.
    * `NV D` nhận 100 Vàng.
    * `NV D` bấm "Hoàn thành" đơn `PurchaseOrder`.
4.  **Hệ thống (Tự động Cập nhật Kho - WAC):**
    * Khi đơn `Completed`, hệ thống lấy Key từ đơn: (`Acc4`, "G1", "S1", "Vàng", "Wechat", "RMB").
    * Tra `InventoryPools` tìm Pool tương ứng.
    * **Giả sử Kho cũ:** (`TotalQuantity`=300, `AverageCost`=6.8).
    * **Giá trị Kho cũ:** 300 * 6.8 = 2040 RMB.
    * **Giá trị Lô Mới:** 700 RMB (từ Đơn Mua).
    * **Tính WAC mới:**
        * Tổng Giá trị Mới = 2040 + 700 = 2740 RMB.
        * Tổng Số lượng Mới = 300 + 100 = 400.
        * `AverageCost` Mới = 2740 / 400 = **6.85 RMB**.
    * **Hệ thống `UPDATE`:** `TotalQuantity`=400, `AverageCost`=6.85.

### 3.2. Luồng Bán hàng Tự động (Đã sửa)

1.  **Tạo Đơn Bán (Admin/Quản lý):**
    * Tạo `SaleOrder` mới: (Bán 50 Vàng G1-S1, qua `Channel`="EU_Market", bằng `Currency`="EUR", `TotalRevenue`=80 EUR).
    * `Status` = `PendingAssignment`.
2.  **Hệ thống (Tự động Chọn Pool & Phân công):**
    * **Chọn Pool (Luân phiên):**
        * Tìm các `InventoryPools` thỏa mãn:
            * (A) (`GameCode`="G1", `GameServer`="S1", `GameCurrency`="Vàng").
            * (B) (`TotalQuantity` - `ReservedQuantity`) >= 50.
        * (Giả sử tìm thấy Pool 1 [Nguồn: Wechat/RMB, Kho: `Acc1`] và Pool 2 [Nguồn: Bank/VND, Kho: `Acc2`]).
        * Tra `AssignmentTrackers` (TrackerType="SELL_POOL_G1_S1_VANG") -> Lần trước bán Pool 2.
        * Hệ thống chọn **Pool 1**.
    * **Tìm Nhân viên (Theo Account của Pool):**
        * Pool 1 nằm trên `AccountID` = **"Acc1"**.
        * Kiểm tra Ca ("Ca Sáng").
        * Tra `Shift_Assignments` tìm `EmployeeID` (vd: `NV A`) thỏa mãn:
            * (A) `AssignedAccountID` = "Acc1".
            * (B) Thuộc "Ca Sáng".
    * **Gán việc & Đặt hàng (Reserve):**
        * Cập nhật `SaleOrder`: `AssignedEmployeeID`="A", `AssignedAccountID`="Acc1", `Status`=`Assigned`.
        * **Lưu Nguồn gốc:** `Source_PurchaseChannelID`="Wechat", `Source_PurchaseCurrency`="RMB".
        * **Cập nhật Kho (Reserve):**
            * `UPDATE InventoryPools`
            * `SET ReservedQuantity = ReservedQuantity + 50`
            * `WHERE PK = (Acc1, G1, S1, Vàng, Wechat, RMB)`.
    * Cập nhật `AssignmentTrackers` ("SELL_POOL_G1_S1_VANG") -> `LastAssignedID` = "Pool 1".
3.  **Nhân viên (Giao hàng):**
    * `NV A` thấy đơn hàng được gán trên `Acc1`.
    * `NV A` giao 50 Vàng.
    * `NV A` bấm "Hoàn thành" đơn `SaleOrder`.
4.  **Hệ thống (Tự động Cập nhật & Tính Lợi nhuận):**
    * **Cập nhật Kho (Hoàn tất):**
        * `UPDATE InventoryPools`
        * `SET TotalQuantity = TotalQuantity - 50, ReservedQuantity = ReservedQuantity - 50`
        * `WHERE PK = (Acc1, G1, S1, Vàng, Wechat, RMB)`.
    * **Tính toán Lợi nhuận:**
        * Hệ thống lấy tất cả thông tin từ Đơn Bán (`SO_ID`):
            * Nguồn Mua: "Wechat", "RMB"
            * Nguồn Bán: "EU_Market", "EUR"
            * Doanh thu: 80 EUR
            * Số lượng: 50
        * **Tra cứu Vòng tròn:**
            * `SELECT ProcessID FROM BusinessProcesses WHERE PurchaseChannelID='Wechat' AND PurchaseCurrency='RMB' AND SaleChannelID='EU_Market' AND SaleCurrency='EUR'`
            * Kết quả: Tìm thấy `ProcessID` = "WEC_RMB_TO_EU_EUR".
        * **Tập hợp Chi phí:**
            * **[A] Giá Vốn (COGS):** Tra `InventoryPools` (PK của Pool 1) -> `AverageCost` = 6.85 RMB.
                * COGS = 50 * 6.85 = **342.5 RMB**.
            * **[B] Phí Bán (Sale Fee):** Tra `Channel_Fees_Map` (Kênh="EU_Market", Tiền tệ="EUR", Hướng="SELL") -> 3% EUR = 80 * 3% = **2.4 EUR**.
            * **[C] Phí Bổ sung (Other Fees):** Tra `Process_OtherFees_Map` với `ProcessID`="WEC_RMB_TO_EU_EUR" -> Lấy ra "Thuế 10%", "Phí Rút 1%".
        * **Tính Lợi nhuận:** Dùng `ExchangeRates` quy đổi Doanh thu (80 EUR - Phí [C]) và Tổng Chi phí (Phí [A] + [B]) về 1 đồng tiền chung (vd: VND) và tính lợi nhuận cuối cùng.
        * Cập nhật `SaleOrder`: `CalculatedProfit` = [Kết quả], `Status` = `Completed`.