# Hệ thống Quản lý Tài chính Hiện đại - Double-Entry Accounting

## 📋 Mục lục
1. [Tổng quan](#tổng-quan)
2. [Nguyên lý Kế toán kép (Double-Entry)](#nguyên-lị-kế-toán-kếp-double-entry)
3. [Kiến trúc Database](#kiến-trúc-database)
4. [Luồng hoạt động](#luồng-hoạt-động)
5. [Ví dụ thực tế](#ví-dụ-thực-tế)
6. [Benefits & Advantages](#benefits--advantages)
7. [Implementation Guide](#implementation-guide)

## Tổng quan

Hệ thống được thiết kế dựa trên nguyên lý **Double-Entry Bookkeeping** (Kế toán kép) - tiêu chuẩn vàng trong quản lý tài chính đã được sử dụng hơn 500 năm. Đây là nền tảng mà mọi hệ thống ERP, tài chính ngân hàng hiện đại đều sử dụng.

### Tại sao cần Double-Entry?
- **Đảm bảo cân bằng**: Mọi giao dịch luôn cân bằng (Assets = Liabilities + Equity)
- **Ngăn lỗi sai**: Không thể có giao dịch mất mát hoặc thừa
- **Minh bạch**: Track được dòng tiền từ nguồn đến đích
- **Audit trail**: Lịch sử đầy đủ, không thể thay đổi

## Nguyên lý Kế toán kép (Double-Entry)

### Quy tắc cơ bản
Mỗi giao dịch tài chính phải được ghi nhận vào **TÍN CỐI** tài khoản:
1. **Debit (Nợ)** - Tang tài sản hoặc giảm nợ phải trả
2. **Credit (Có)** - Giảm tài sản hoặc tăng nợ phải trả

**Luôn luôn**: **Total Debit = Total Credit**

### Phân loại tài khoản (Chart of Accounts)

| Account Type | Normal Balance | Debit Effect | Credit Effect |
|--------------|----------------|--------------|---------------|
| **Assets (Tài sản)** | Debit | Tăng | Giảm |
| **Liabilities (Nợ phải trả)** | Credit | Giảm | Tăng |
| **Equity (Vốn chủ sở hữu)** | Credit | Giảm | Tăng |
| **Revenue (Doanh thu)** | Credit | Giảm | Tăng |
| **Expenses (Chi phí)** | Debit | Tăng | Giảm |

### Mã tài khoản chuẩn

```
1000-1999: ASSETS (Tài sản)
├── 1000-1099: Current Assets (Tài sản ngắn hạn)
│   ├── 1000: Cash & Cash Equivalents (Tiền mặt & tương đương)
│   ├── 1100: Accounts Receivable (Phải thu khách hàng)
│   ├── 1200: Inventory (Hàng tồn kho)
│   └── 1300: Prepaid Expenses (Chi phí trả trước)
└── 1500-1999: Fixed Assets (Tài sản dài hạn)

2000-2999: LIABILITIES (Nợ phải trả)
├── 2000-2099: Current Liabilities (Nợ ngắn hạn)
│   ├── 2000: Accounts Payable (Phải trả nhà cung cấp)
│   ├── 2100: Salaries Payable (Lương phải trả)
│   └── 2200: Loans Payable (Vay phải trả)
└── 2500-2999: Long-term Liabilities (Nợ dài hạn)

3000-3999: EQUITY (Vốn chủ sở hữu)
├── 3000: Owner's Equity (Vốn chủ sở hữu)
├── 3100: Retained Earnings (Lợi nhuận giữ lại)
└── 3200: Common Stock (Cổ phiếu phổ thông)

4000-4999: REVENUE (Doanh thu)
├── 4000: Sales Revenue (Doanh thu bán hàng)
├── 4100: Service Revenue (Doanh thu dịch vụ)
└── 4200: Commission Revenue (Doanh thu hoa hồng)

5000-5999: EXPENSES (Chi phí)
├── 5000: Cost of Goods Sold (Giá vốn hàng bán)
├── 5100: Salaries Expense (Chi phí lương)
├── 5200: Rent Expense (Chi phí thuê)
└── 5300: Marketing Expense (Chi phí marketing)
```

## Kiến trúc Database

### 1. Chart of Accounts (Danh mục tài khoản)

```sql
chart_of_accounts
├── id (UUID PK)
├── account_code (VARCHAR UNIQUE) -- 1000, 1100, 2000, etc.
├── account_name (VARCHAR) -- "Tiền mặt", "Phải thu khách"
├── account_type (ENUM) -- ASSET, LIABILITY, EQUITY, REVENUE, EXPENSE
├── parent_account_id (UUID FK) -- Cho tài khoản con
├── currency_code (VARCHAR) -- VND, USD, CNY
└── is_active (BOOLEAN)
```

**Ví dụ data:**
| id | account_code | account_name | account_type | parent_account_id |
|----|--------------|--------------|--------------|------------------|
| 1 | 1000 | Tiền mặt - VND | ASSET | NULL |
| 2 | 1001 | Tiền mặt - USD | ASSET | 1 |
| 3 | 1100 | Phải thu khách | ASSET | NULL |
| 4 | 2000 | Phải trả nhà cung cấp | LIABILITY | NULL |
| 5 | 4000 | Doanh thu bán hàng | REVENUE | NULL |

### 2. Account Balances (Số dư tài khoản)

```sql
account_balances
├── id (UUID PK)
├── account_id (UUID FK chart_of_accounts)
├── entity_type (ENUM) -- COMPANY, EMPLOYEE, CUSTOMER, SUPPLIER
├── entity_id (UUID) -- ID của entity (company_id, employee_id)
├── currency_code (VARCHAR) -- VND, USD, CNY
├── current_balance (DECIMAL 20,4) -- Số dư hiện tại
└── last_updated_at (TIMESTAMPTZ)
```

**Ví dụ data:**
| account_id | entity_type | entity_id | currency_code | current_balance |
|------------|-------------|-----------|---------------|-----------------|
| 1000 | COMPANY | comp-001 | VND | 1,000,000,000 |
| 1001 | COMPANY | comp-001 | USD | 50,000 |
| 1100 | COMPANY | comp-001 | VND | 500,000,000 |
| 2000 | COMPANY | comp-001 | VND | -200,000,000 |
| 4000 | COMPANY | comp-001 | VND | -300,000,000 |

### 3. General Ledger (Sổ cái)

#### Transaction Headers
```sql
general_ledger_headers
├── id (UUID PK)
├── transaction_number (VARCHAR UNIQUE) -- TRX-20251218-001
├── transaction_date (DATE)
├── description (TEXT) -- "Thanh toán lương nhân viên tháng 12"
├── reference_type (ENUM) -- SALARY_PAYMENT, PURCHASE_ORDER
├── reference_id (UUID) -- ID của entity liên quan
├── total_amount (DECIMAL 20,4)
├── status (ENUM) -- DRAFT, POSTED, VOID
└── created_at (TIMESTAMPTZ)
```

#### Transaction Lines (Double Entries)
```sql
general_ledger_lines
├── id (UUID PK)
├── header_id (UUID FK general_ledger_headers)
├── account_id (UUID FK chart_of_accounts)
├── entity_type (ENUM) -- COMPANY, EMPLOYEE
├── entity_id (UUID) -- ID của entity
├── debit_amount (DECIMAL 20,4) -- Số tiền bên Nợ
├── credit_amount (DECIMAL 20,4) -- Số tiền bên Có
└── line_number (INTEGER) -- Thứ tự dòng
```

### 4. Transaction Categories

```sql
transaction_categories
├── id (UUID PK)
├── category_code (VARCHAR UNIQUE) -- SALARY, PURCHASE, SALE
├── category_name (VARCHAR) -- "Lương nhân viên", "Mua hàng"
├── direction (ENUM) -- INFLOW, OUTFLOW
└── applies_to (ENUM) -- COMPANY, EMPLOYEE, BOTH
```

## Luồng hoạt động

### Scenario 1: Công ty trả lương cho nhân viên

**Transaction:**
- Công ty trả 10,000,000 VND lương cho nhân viên A
- Trừ từ quỹ tiền mặt công ty
- Cộng vào ví cá nhân nhân viên A

**Double Entries:**
1. **Debit**: Salaries Expense (5000) - 10,000,000 VND (Tăng chi phí)
2. **Credit**: Cash - Company (1000) - 10,000,000 VND (Giảm tiền mặt)

**Database Records:**
```sql
-- Header
INSERT INTO general_ledger_headers (
    transaction_number, transaction_date, description, total_amount
) VALUES ('TRX-20251218-001', '2025-12-18', 'Trả lương nhân viên A', 10000000);

-- Lines
INSERT INTO general_ledger_lines VALUES
    (uuid1, header_id, account_id_5000, 'COMPANY', comp_id, 10000000, 0, 1), -- Debit Salaries Expense
    (uuid2, header_id, account_id_1000, 'COMPANY', comp_id, 0, 10000000, 2); -- Credit Cash
```

### Scenario 2: Nhân viên nhận hoa hồng từ đơn hàng

**Transaction:**
- Đơn hàng trị giá 100,000,000 VND, hoa hồng 5% = 5,000,000 VND
- Cộng vào ví nhân viên
- Trừ vào doanh thu công ty

**Double Entries:**
1. **Debit**: Commission Expense (5100) - 5,000,000 VND (Tăng chi phí hoa hồng)
2. **Credit**: Employee Wallet - Employee (Personal Asset) - 5,000,000 VND (Tăng tài sản nhân viên)

### Scenario 3: Khách hàng mua game currency

**Transaction:**
- Khách hàng mua 1,000,000 VND game currency
- Công ty nhận tiền mặt
- Giảm inventory game currency

**Double Entries:**
1. **Debit**: Cash - Company (1000) - 1,000,000 VND (Tăng tiền mặt)
2. **Credit**: Sales Revenue (4000) - 1,000,000 VND (Tăng doanh thu)
3. **Debit**: Cost of Goods Sold (5000) - Giá vốn của game currency
4. **Credit**: Inventory (1200) - Giá trị game currency

## Ví dụ thực tế

### Balance Sheet Sample Query

```sql
-- Lấy Bảng cân đối kế toán tại thời điểm hiện tại
SELECT
    ca.account_type,
    ca.account_code,
    ca.account_name,
    ab.currency_code,
    SUM(CASE WHEN ca.account_type IN ('ASSET', 'EXPENSE')
            THEN ab.current_balance
            ELSE -ab.current_balance END) as balance
FROM account_balances ab
JOIN chart_of_accounts ca ON ab.account_id = ca.id
WHERE ab.entity_type = 'COMPANY'
GROUP BY ca.account_type, ca.account_code, ca.account_name, ab.currency_code
ORDER BY ca.account_type, ca.account_code;
```

### Income Statement Sample Query

```sql
-- Lấy Báo cáo kết quả kinh doanh
SELECT
    ca.account_code,
    ca.account_name,
    SUM(
        CASE
            WHEN ca.account_type = 'REVENUE' THEN -gll.credit_amount + gll.debit_amount
            WHEN ca.account_type = 'EXPENSE' THEN gll.debit_amount - gll.credit_amount
        END
    ) as amount
FROM general_ledger_lines gll
JOIN general_ledger_headers glh ON gll.header_id = glh.id
JOIN chart_of_accounts ca ON gll.account_id = ca.id
WHERE glh.transaction_date BETWEEN '2025-12-01' AND '2025-12-31'
  AND ca.account_type IN ('REVENUE', 'EXPENSE')
  AND glh.status = 'POSTED'
GROUP BY ca.account_code, ca.account_name
ORDER BY ca.account_code;
```

## Benefits & Advantages

### 1. **Đảm bảo tính chính xác**
- Mọi giao dịch được kiểm tra balance (Debit = Credit)
- Không thể có giao dịch thiếu hoặc thừa

### 2. **Minh bạch và Audit**
- Lịch sử đầy đủ mọi giao dịch
- Không thể sửa đổi giao dịch đã posted, chỉ có thể void và tạo giao dịch mới

### 3. **Real-time Reporting**
- Balance được tính real-time
- Có thể xem Báo cáo tài chính bất cứ lúc nào

### 4. **Scalability**
- Hỗ trợ multi-currency
- Hỗ trợ multi-entity (công ty, nhân viên, khách hàng)
- Partitioning và indexing cho performance lớn

### 5. **Integration**
- Dễ dàng integrate với các hệ thống khác (ERP, Banking, Tax)

## Implementation Guide

### Phase 1: Core Tables
1. `chart_of_accounts` - Thiết lập danh mục tài khoản
2. `account_balances` - Khởi tạo số dư ban đầu
3. `general_ledger_headers` + `general_ledger_lines` - Sổ cái
4. Basic transaction functions

### Phase 2: Business Logic
1. Transaction creation functions
2. Balance calculation views
3. Basic reporting functions
4. RLS policies

### Phase 3: Advanced Features
1. Multi-currency exchange rates
2. Automated journal entries
3. Advanced reporting
4. Integration với existing systems

### Migration Strategy
1. **Backup** existing data
2. **Create** new financial tables
3. **Migrate** existing transactions to double-entry format
4. **Update** application logic
5. **Test** thoroughly before go-live
6. **Train** users on new system

---

**Note**: Hệ thống này tuân thủ chuẩn mực kế toán quốc tế (IFRS) và có thể mở rộng để đáp ứng các yêu cầu phức tạp của doanh nghiệp.