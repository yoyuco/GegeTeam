# GegeTeam — Bản giới thiệu dự án (Executive Brief)

> **Mục tiêu:** cung cấp một bảng quản trị nhẹ, dễ dùng cho đội nhỏ để **bán hàng (Items, Currency), cung cấp Dịch vụ (boss, leveling, pit)**, theo dõi kho, tiến độ, và **doanh thu/lợi nhuận** – xây dựng trên **Vue 3 + Supabase**.

---

## 1) Tóm tắt trong 1 phút
- **GegeTeam** là ứng dụng web quản trị, giao diện hiện đại, đăng nhập an toàn (Email/OAuth), hoạt động thời gian thực và có dashboard KPI.
- Phục vụ các vai trò **Admin/Manager/Trader/Farmer** với luồng công việc rõ ràng; mỗi vai trò thấy và làm đúng phần việc của mình.
- Dữ liệu lưu trong **PostgreSQL (Supabase)**, có **chính sách truy cập theo vai**; báo cáo chuẩn hóa về **một đơn vị tiền tệ gốc** để so sánh.
- Kết quả: **giảm thời gian xử lý đơn**, **tăng minh bạch**, **đo lường KPI** theo ngày/tháng/năm.

---

## 2) Giá trị nổi bật cho doanh nghiệp
- **Quản trị tập trung**: Đơn hàng, khách hàng, kho, dịch vụ – ở một nơi.
- **Theo dõi tiến độ & bằng chứng**: Giao việc, cập nhật % hoàn thành, đính kèm bằng chứng.
- **Đa kênh mua/bán**: Facebook, Discord, G2G, PlayerAuctions, Eldorado, eBay… (cấu hình được).
- **Báo cáo & KPI**: doanh thu, chi phí, lợi nhuận, năng suất theo vai trò/nhân sự/kênh.
- **Mở rộng dễ dàng**: dựa trên công nghệ phổ biến (Vue, Tailwind, Supabase).

---

## 3) Ứng dụng làm gì? (Không kỹ thuật)
- **Đăng nhập an toàn**: email/mật khẩu, hoặc Google/GitHub; ghi nhớ phiên, tự chuyển hướng về trang trước.
- **Dashboard**: ô KPI và biểu đồ doanh thu theo tháng; ví dụ thực tế “Realtime” cho danh sách tác vụ.
- **Quản lý Đơn hàng** (3 loại):
  - **Items** (Legendary/Unique theo slot; có thể có *GA* – dòng chỉ số quan trọng).
  - **Currency** (Gold).
  - **Dịch vụ** (boss, leveling, the pit, soul, obducite… kèm deadline, giữ tài khoản khi cần).
- **Khách hàng & Đối tác**: thông tin cơ bản, tài khoản game (khi khách yêu cầu “pilot”).
- **Kho/Tồn**: theo dõi hàng hóa **đồng nhất** (fungible, như Gold) và **mỗi món khác nhau** (non‑fungible, như Unique 4GA).
- **Nhiệm vụ (Kanban)**: giao việc nhanh cho Farmer/Trader, cập nhật trạng thái.
- **Báo cáo & Kế toán**: doanh thu, chi phí, giá vốn, lợi nhuận, theo ngày/tháng/năm và theo loại đơn.

---

## 4) Vai trò & trách nhiệm (ví dụ điển hình)
- **Admin/Mod/Manager**: cấu hình, phân quyền, xem toàn bộ báo cáo.
- **Trader 1**: tạo **đơn bán** (Items/Currency/Dịch vụ), theo dõi tiến độ, lấy bằng chứng.
- **Trader 2**: tạo **đơn mua/nhập**, theo dõi & hoàn tất giao hàng.
- **Farmer**: thực hiện **đơn dịch vụ**, cập nhật % tiến độ, hoàn tất đúng **deadline**.
> Mỗi người dùng có thể mang nhiều vai; quyền được hệ thống kiểm soát theo vai trò.

---

## 5) Quy trình mẫu
**Items/Currency**
1) Trader 2 nhập hàng → vào kho.
2) Trader 1 tạo đơn bán theo kênh (ví dụ G2G) → gán người thực hiện nếu cần.
3) Hoàn tất → ghi nhận doanh thu, chi phí, lợi nhuận.

**Dịch vụ**
1) Trader 1 tạo đơn (có thể nhiều dịch vụ trong 1 đơn) + **deadline** + thời gian giữ tài khoản (nếu “pilot”).  
2) **Farmer** cập nhật tiến độ, đính kèm bằng chứng, hoàn tất đúng hạn.  
3) Hệ thống tính KPI theo năng suất (ví dụ EXP/giờ, số run pit/boss).

---

## 6) Dữ liệu & bảo mật (dễ hiểu)
- **CSDL chuẩn hóa**: “Sản phẩm (SKU)” gồm **Item/Currency/Service**. “Đơn hàng” gồm nhiều dòng; mỗi dòng có giá, đơn vị tiền, phí/thuế/chiết khấu; hệ thống tự quy đổi về **đồng tiền gốc** để báo cáo.
- **Kho**:
  - **Đồng nhất (fungible)**: ví dụ Gold – theo dõi số lượng và giá vốn bình quân/FIFO.
  - **Mỗi món khác nhau (non‑fungible)**: ví dụ Unique 1–4GA – có thể “gộp” (stack) khi trùng đặc điểm.
- **Bảo mật theo vai trò**: chỉ xem và thao tác trên dữ liệu được phép (Role‑Based Access).
- **Tính sẵn sàng**: dùng dịch vụ đám mây Supabase; mở rộng tính năng bằng **Edge Function** khi cần (ví dụ tính KPI nâng cao).

---

## 7) Báo cáo & KPI
- **Doanh thu/Chi phí/Lợi nhuận** theo ngày, tháng, năm; theo loại đơn (Items/Currency/Dịch vụ); theo kênh bán/mua.
- **KPI theo vai trò/nhân sự**: số đơn hoàn thành, đúng hạn; năng suất (EXP/giờ, số run pit/boss/giờ); hiệu quả theo kênh.
- Có thể bổ sung **bảng tổng hợp ngày** (materialized view) để tăng tốc độ báo cáo.

---

## 8) Công nghệ & triển khai
- **Frontend**: Vue 3 + TypeScript, Pinia, Naive UI, Tailwind.
- **Backend**: Supabase (Auth, Postgres, Realtime, Storage, Edge Functions).
- **Triển khai**: chạy cục bộ bằng Vite; triển khai web tĩnh qua Vercel; CSDL & Functions trên Supabase Cloud.
- **Thiết lập nhanh** (cho đội kỹ thuật):
  1) Tạo file `.env.local` với URL & ANON KEY của Supabase.
  2) `pnpm install` → `pnpm dev` (chạy tại `http://localhost:5173`).
  3) Cấu hình OAuth callback `/auth/callback` (local & production).
  4) (Tùy chọn) CLI để đẩy **schema** và **edge functions**.

---

## 9) Lộ trình phát triển (đề xuất)
- Hoàn thiện CRUD **Đơn hàng/Khách hàng/Nhân viên** kết nối CSDL thật.
- **Đa tổ chức (multi‑tenant)**: chuyển đổi tổ chức trong giao diện.
- **KPI nâng cao**: thêm bộ lọc, nhiều chỉ số, tự động tính định kỳ.
- **Quyền chi tiết theo menu & API**, thêm kiểm thử & CI.

---

## 10) Phụ lục thuật ngữ (ngắn gọn)
- **Legendary/Unique**: nhóm Item trong game; Unique có **4 dòng GA** tối đa (GA = “Greater Affix” – chỉ số quan trọng).
- **Aspect**: hiệu ứng đặc biệt đi kèm Item (Legendary hoặc một số Unique).
- **Fungible/Non‑fungible**: loại hàng **đồng nhất** (ví dụ Gold) / **không đồng nhất** (mỗi món một đặc điểm, ví dụ Unique 3GA/4GA).
- **Pilot/Self‑play**: thực hiện dịch vụ bằng cách đăng nhập tài khoản khách (pilot) hoặc khách tự tham gia (self‑play).
- **Base currency**: đồng tiền chuẩn để quy đổi khi báo cáo.

---

### Kết luận
GegeTeam giúp **tổ chức vận hành trơn tru, giảm rủi ro, tăng tốc độ và minh bạch**, đồng thời cung cấp **bức tranh tài chính rõ ràng** để các lãnh đạo ra quyết định nhanh và chính xác.ss