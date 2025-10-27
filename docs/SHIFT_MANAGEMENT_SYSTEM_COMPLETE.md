# Hệ Thống Quản Lý Ca Làm Việc - Tài Liệu Hoàn Chỉnh

## Tổng Quan

Hệ thống quản lý ca làm việc được thiết kế để quản lý:
- ✅ **Ca làm việc** (Work Shifts) - Các khoảng thời gian làm việc
- ✅ **Phân công nhân viên theo ca** (Employee Shift Assignments) - Giao nhân viên vào ca cụ thể
- ✅ **Quyền truy cập account theo ca** (Shift Account Access) - Cấp quyền truy cập tài khoản game cho từng ca
- ✅ **Bàn giao inventory** (Inventory Handovers) - Theo dõi việc bàn giao hàng tồn kho giữa các ca

## 1. Cấu Trúc Database

### 1.1 Bảng Work Shifts (Ca làm việc)
```sql
CREATE TABLE public.work_shifts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,                    -- Tên ca (VD: "Ca Sáng", "Ca Chiều", "Ca Đêm")
    start_time TIME NOT NULL,              -- Giờ bắt đầu (VD: 06:00:00)
    end_time TIME NOT NULL,                -- Giờ kết thúc (VD: 14:00:00)
    description TEXT,                      -- Mô tả ca làm việc
    is_active BOOLEAN DEFAULT true,        -- Trạng thái hoạt động
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Chức năng:**
- Quản lý các ca làm việc trong ngày
- Cấu hình thời gian bắt đầu và kết thúc
- Bật/tắt ca làm việc

### 1.2 Bảng Employee Shift Assignments (Phân công nhân viên theo ca)
```sql
CREATE TABLE public.employee_shift_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    employee_profile_id UUID NOT NULL REFERENCES public.profiles(id),
    shift_id UUID NOT NULL REFERENCES public.work_shifts(id),
    assigned_date DATE NOT NULL,           -- Ngày được phân công
    is_active BOOLEAN DEFAULT true,        -- Trạng thái phân công
    assigned_by UUID REFERENCES public.profiles(id),  -- Người phân công
    assigned_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(employee_profile_id, shift_id, assigned_date)  -- Mỗi nhân viên chỉ 1 ca/ngày
);
```

**Chức năng:**
- Phân công nhân viên vào các ca làm việc cụ thể
- Theo dõi ngày làm việc của từng nhân viên
- Ngăn chặn phân công trùng lặp (một nhân viên không thể làm nhiều ca cùng ngày)

### 1.3 Bảng Shift Account Access (Quyền truy cập account theo ca)
```sql
CREATE TABLE public.shift_account_access (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    shift_id UUID NOT NULL REFERENCES public.work_shifts(id),
    game_account_id UUID NOT NULL REFERENCES public.game_accounts(id),
    channel_id UUID NOT NULL REFERENCES public.channels(id),
    granted_at TIMESTAMPTZ DEFAULT NOW(),
    granted_by UUID REFERENCES public.profiles(id),
    UNIQUE(shift_id, game_account_id, channel_id)
);
```

**Chức năng:**
- Cấp quyền truy cập tài khoản game cho từng ca làm việc
- Liên kết với kênh bán hàng cụ thể
- Theo dõi ai đã cấp quyền và khi nào

### 1.4 Bảng Inventory Handovers (Bàn giao inventory)
```sql
CREATE TABLE public.inventory_handovers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    from_shift_id UUID REFERENCES public.work_shifts(id),      -- Ca bàn giao
    to_shift_id UUID REFERENCES public.work_shifts(id),        -- Ca nhận bàn giao
    game_account_id UUID REFERENCES public.game_accounts(id),
    channel_id UUID REFERENCES public.channels(id),
    currency_attribute_id UUID REFERENCES public.attributes(id),

    -- Số liệu quantity
    expected_quantity NUMERIC NOT NULL DEFAULT 0,             -- Số lượng dự kiến
    actual_quantity NUMERIC NOT NULL DEFAULT 0,               -- Số lượng thực tế
    discrepancy NUMERIC GENERATED ALWAYS AS (actual_quantity - expected_quantity) STORED,  -- Chênh lệch

    -- Trạng thái
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'disputed', 'resolved')),
    handover_type TEXT DEFAULT 'auto' CHECK (handover_type IN ('auto', 'manual')),

    -- Người tham gia
    handover_by UUID REFERENCES public.profiles(id),          -- Người bàn giao
    received_by UUID REFERENCES public.profiles(id),          -- Người nhận
    verified_by UUID REFERENCES public.profiles(id),          -- Người xác nhận

    -- Timestamps
    handover_at TIMESTAMPTZ DEFAULT NOW(),                    -- Thời gian bàn giao
    received_at TIMESTAMPTZ,                                  -- Thời gian nhận
    verified_at TIMESTAMPTZ,                                  -- Thời gian xác nhận

    -- Ghi chú
    notes TEXT,
    discrepancy_reason TEXT,

    -- Metadata
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Chức năng:**
- Theo dõi bàn giao hàng tồn kho giữa các ca
- Ghi nhận số lượng dự kiến và thực tế
- Tự động tính chênh lệch
- Quản lý trạng thái bàn giao
- Ghi nhận người tham gia và thời gian

## 2. Các Function Hệ Thống

### 2.1 Lấy ca hiện tại
```sql
CREATE OR REPLACE FUNCTION public.get_current_shift()
RETURNS TABLE (
    shift_id UUID,
    shift_name TEXT,
    start_time TIME,
    end_time TIME,
    is_current_shift BOOLEAN
)
LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public';
```
**Chức năng:** Lấy thông tin ca làm việc hiện tại dựa trên thời gian thực.

### 2.2 Tạo bàn giao ca
```sql
CREATE OR REPLACE FUNCTION public.create_shift_handover(
    p_from_shift_id UUID,
    p_to_shift_id UUID,
    p_game_account_id UUID,
    p_channel_id UUID,
    p_currency_attribute_id UUID,
    p_expected_quantity NUMERIC,
    p_actual_quantity NUMERIC,
    p_notes TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public';
```
**Chức năng:** Tạo bản ghi bàn giao inventory giữa hai ca.

### 2.3 Xác nhận bàn giao
```sql
CREATE OR REPLACE FUNCTION public.confirm_shift_handover(
    p_handover_id UUID,
    p_received_by UUID,
    p_actual_quantity NUMERIC DEFAULT NULL,
    p_notes TEXT DEFAULT NULL
)
RETURNS BOOLEAN
LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public';
```
**Chức năng:** Xác nhận hoàn tất bàn giao, cập nhật số lượng thực tế.

### 2.4 Tạo cảnh báo ca
```sql
CREATE OR REPLACE FUNCTION public.create_shift_alert(
    p_shift_id UUID,
    p_alert_type TEXT,
    p_message TEXT,
    p_severity TEXT DEFAULT 'medium'
)
RETURNS UUID
LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public';
```
**Chức năng:** Tạo cảnh báo liên quan đến ca làm việc.

### 2.5 Health check hệ thống
```sql
CREATE OR REPLACE FUNCTION public.quick_health_check()
RETURNS TABLE (
    check_name TEXT,
    status TEXT,
    details TEXT
)
LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public';
```
**Chức năng:** Kiểm tra nhanh trạng thái hệ thống quản lý ca.

## 3. Views Hệ Thống

### 3.1 Current Shift Handovers
```sql
CREATE VIEW public.current_shift_handovers AS
SELECT
    ih.id,
    ih.from_shift_id,
    from_shift.name as from_shift_name,
    ih.to_shift_id,
    to_shift.name as to_shift_name,
    ih.game_account_id,
    ga.account_name as account_username,
    ga.game_code,
    ih.handover_at,
    ih.expected_quantity,
    ih.actual_quantity,
    ih.discrepancy,
    ih.notes,
    ih.status
FROM public.inventory_handovers ih
JOIN public.work_shifts from_shift ON ih.from_shift_id = from_shift.id
JOIN public.work_shifts to_shift ON ih.to_shift_id = to_shift.id
JOIN public.game_accounts ga ON ih.game_account_id = ga.id
WHERE ih.status = 'pending';
```
**Chức năng:** Hiển thị các bàn giao đang chờ xử lý.

## 4. Quy Trình Hoạt Động

### 4.1 Quy trình phân công nhân viên
1. **Tạo ca làm việc**: Admin tạo các ca (sáng, chiều, đêm)
2. **Phân công nhân viên**: Manager phân công nhân viên vào các ca theo ngày
3. **Cấp quyền truy cập**: Manager cấp quyền truy cập account cho từng ca
4. **Xác nhận phân công**: Nhân viên xác nhận đã nhận phân công

### 4.2 Quy trình bàn giao ca
1. **Bắt đầu bàn giao**: Nhân viên ca cũ tạo yêu cầu bàn giao
2. **Kiểm kê inventory**: Kiểm tra số lượng tồn kho hiện tại
3. **Tạo bản ghi bàn giao**: Nhập số lượng dự kiến và thực tế
4. **Ca mới nhận bàn giao**: Nhân viên ca mới xác nhận và kiểm tra lại
5. **Hoàn tất bàn giao**: Cả hai bên xác nhận hoàn tất

### 4.3 Quy trình xử lý sự cố
1. **Phát hiện chênh lệch**: Hệ thống phát hiện sai khác số lượng
2. **Báo cáo sự cố**: Tạo cảnh báo về chênh lệch
3. **Xác minh**: Manager kiểm tra và xác minh
4. **Xử lý**: Điều chỉnh và ghi nhận nguyên nhân
5. **Đóng sự cố**: Đánh dấu đã giải quyết

## 5. Security Features

### 5.1 Row Level Security (RLS)
- ✅ Tất cả tables có RLS được bật
- ✅ Policies cho SELECT, INSERT, UPDATE, DELETE
- ✅ Kiểm soát truy cập dựa trên user roles

### 5.2 Function Security
- ✅ `SECURITY DEFINER` với `SET search_path TO 'public'`
- ✅ Validation parameters trong functions
- ✅ Error handling và logging

### 5.3 Audit Trail
- ✅ Tracking ai đã tạo/sửa/thóa records
- ✅ Timestamps cho tất cả operations
- ✅ Logs cho các bàn giao và thay đổi

## 6. Integration Points

### 6.1 Với hệ thống hiện có
- **Profiles**: Liên kết với user profiles
- **Game Accounts**: Sử dụng existing game accounts
- **Channels**: Liên kết với selling channels
- **Attributes**: Liên kết với currency attributes

### 6.2 Real-time Features
- **Notifications**: Alerts khi có bàn giao mới
- **Dashboard**: Real-time status của shifts
- **Reports**: Báo cáo tự động

## 7. Use Cases

### 7.1 Quản lý ca làm việc
```
1. Admin tạo 3 ca: Sáng (6:00-14:00), Chiều (14:00-22:00), Đêm (22:00-6:00)
2. Manager phân công nhân viên A vào ca sáng, B vào ca chiều, C vào ca đêm
3. Hệ thống tự động nhận diện ca hiện tại dựa trên thời gian
```

### 7.2 Bàn giao inventory
```
1. Cuối ca sáng, nhân viên A kiểm kê có 1000 vàng
2. A tạo bàn giao cho ca chiều với expected_quantity = 1000
3. Nhân viên B ca chiều kiểm tra thực tế có 998 vàng
4. B xác nhận bàn giao với actual_quantity = 998
5. Hệ thống ghi nhận discrepancy = -2 và tạo alert
```

### 7.3 Quyền truy cập account
```
1. Manager cấp quyền cho ca sáng truy cập account "game_acc_01"
2. Manager cấp quyền cho ca chiều truy cập account "game_acc_02"
3. Nhân viên chỉ có thể truy cập các account được cấp cho ca của họ
```

## 8. Migration Files

- **Main Migration**: `20251026170000_shift_management_system.sql`
- **Security Fixes**: `scripts/security_fixes_for_shift_management.sql`

## 9. Monitoring & Maintenance

### 9.1 Health Checks
- Kiểm tra các bàn giao pending quá lâu
- Monitor chênh lệch lớn
- Track nhân viên không hoàn thành bàn giao

### 9.2 Reports
- Daily shift summary
- Weekly handover report
- Monthly discrepancy analysis
- Employee performance metrics

## 10. Future Enhancements

- **Mobile App**: Cho nhân viên confirm shifts on-the-go
- **Auto-assignment**: Tự động phân công dựa trên performance
- **Integration SMS**: Alerts cho bàn giao quan trọng
- **AI Analytics**: Predict inventory needs per shift

---

**Document Version**: 1.0
**Last Updated**: 2025-01-26
**Status**: Production Ready
**Migration Applied**: ✅ Complete