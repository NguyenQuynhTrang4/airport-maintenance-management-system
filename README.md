# Airport Maintenance Management System

Ứng dụng quản lý bảo trì thiết bị nội bộ dành cho môi trường sân bay. Hệ thống hỗ trợ quản lý thiết bị, quét mã QR, tạo phiếu bảo trì, phân quyền người dùng, gán người phụ trách, cập nhật trạng thái xử lý, ghi chú xử lý và theo dõi lịch sử bảo trì.

---

## 1. Tổng quan hệ thống

Hệ thống gồm 2 phần chính:

```text
Flutter Mobile App  →  FastAPI Backend  →  SQLite Database
```

### Backend

Backend được xây dựng bằng:

```text
Python
FastAPI
SQLite
Uvicorn
```

Backend cung cấp API cho:

```text
Đăng nhập người dùng
Quản lý tài khoản
Quản lý thiết bị
Tạo và xử lý phiếu bảo trì
Gán người phụ trách
Ghi chú xử lý phiếu
Dashboard thống kê
Lịch sử bảo trì theo thiết bị
Upload ảnh hiện trường
```

### Mobile App

Mobile app được xây dựng bằng:

```text
Flutter
Dart
HTTP API
Camera / Image Picker
QR Scanner
QR Generator
```

Ứng dụng hỗ trợ chạy trên thiết bị Android thật.

---

## 2. Chức năng chính đã hoàn thành

```text
[✓] Đăng nhập tài khoản
[✓] Phân quyền admin / supervisor / technician
[✓] Dashboard theo vai trò
[✓] Quản lý thiết bị
[✓] Thêm thiết bị
[✓] Sửa thiết bị
[✓] Xem chi tiết thiết bị
[✓] Xem mã QR thiết bị
[✓] Quét QR để mở chi tiết thiết bị
[✓] Tạo phiếu bảo trì
[✓] Tạo phiếu bảo trì từ màn hình chi tiết thiết bị
[✓] Danh sách phiếu bảo trì
[✓] Lọc phiếu theo trạng thái
[✓] Lọc phiếu theo hệ thống
[✓] Lọc phiếu theo người phụ trách
[✓] Technician chỉ thấy phiếu được giao cho mình
[✓] Admin/Supervisor thấy toàn bộ phiếu
[✓] Gán người phụ trách từ danh sách user
[✓] Cập nhật trạng thái phiếu
[✓] Hủy phiếu
[✓] Thêm ghi chú xử lý
[✓] Hiển thị lịch sử xử lý của phiếu
[✓] Tự ghi lịch sử khi gán người phụ trách
[✓] Tự ghi lịch sử khi cập nhật trạng thái
[✓] Xem lịch sử phiếu bảo trì theo từng thiết bị
[✓] Quản lý tài khoản
[✓] Tạo tài khoản
[✓] Sửa tài khoản
[✓] Khóa / mở tài khoản
```

---

## 3. Phân quyền người dùng

Hệ thống hỗ trợ 3 vai trò:

```text
admin
supervisor
technician
```

### Admin

```text
- Xem toàn bộ thiết bị
- Thêm thiết bị
- Sửa thiết bị
- Xem toàn bộ phiếu bảo trì
- Tạo phiếu bảo trì
- Gán người phụ trách
- Cập nhật trạng thái phiếu
- Hủy phiếu
- Thêm ghi chú xử lý
- Xem toàn bộ lịch sử xử lý
- Xem dashboard toàn hệ thống
- Quản lý tài khoản
- Khóa / mở tài khoản
```

### Supervisor

```text
- Xem toàn bộ thiết bị
- Xem toàn bộ phiếu bảo trì
- Tạo phiếu bảo trì
- Gán người phụ trách
- Cập nhật trạng thái phiếu
- Hủy phiếu
- Thêm ghi chú xử lý
- Xem toàn bộ lịch sử xử lý
- Xem dashboard toàn hệ thống
```

### Technician

```text
- Xem thiết bị
- Quét QR thiết bị
- Tạo phiếu bảo trì
- Chỉ xem phiếu được giao cho mình
- Chỉ cập nhật phiếu được giao cho mình
- Không được gán người phụ trách
- Không được hủy phiếu
- Được thêm ghi chú xử lý
- Dashboard chỉ thống kê phiếu được giao cho mình
```

---

## 4. Cấu trúc thư mục

```text
airport_maintenance/
│
├── maintenance_backend/
│   ├── main.py
│   ├── airport.db
│   ├── uploads/
│   ├── venv/
│   ├── add_users.py
│   ├── add_maintenance_notes.py
│   ├── fix_db.py
│   ├── fix_users_active.py
│   ├── fix_assigned_to.py
│   └── ...
│
└── maintenance_app/
    ├── lib/
    │   ├── main.dart
    │   ├── config/
    │   │   └── api_config.dart
    │   ├── models/
    │   │   ├── equipment.dart
    │   │   ├── maintenance_ticket.dart
    │   │   ├── maintenance_note.dart
    │   │   └── app_user.dart
    │   ├── services/
    │   │   └── api_service.dart
    │   └── screens/
    │       ├── login_screen.dart
    │       ├── home_screen.dart
    │       ├── dashboard_screen.dart
    │       ├── equipment_list_screen.dart
    │       ├── equipment_detail_screen.dart
    │       ├── create_equipment_screen.dart
    │       ├── edit_equipment_screen.dart
    │       ├── equipment_qr_screen.dart
    │       ├── qr_scan_screen.dart
    │       ├── create_maintenance_screen.dart
    │       ├── maintenance_list_screen.dart
    │       ├── maintenance_detail_screen.dart
    │       ├── user_list_screen.dart
    │       ├── create_user_screen.dart
    │       └── edit_user_screen.dart
    │
    ├── pubspec.yaml
    └── android/
```

---

## 5. Cài đặt và chạy Backend

### 5.1. Di chuyển vào thư mục backend

```powershell
cd C:\Users\PC\airport_maintenance\maintenance_backend
```

### 5.2. Kích hoạt môi trường ảo

```powershell
.\venv\Scripts\Activate.ps1
```

### 5.3. Cài thư viện cần thiết

```powershell
pip install fastapi uvicorn python-multipart
```

### 5.4. Chạy backend

```powershell
python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

Khi chạy thành công sẽ thấy:

```text
Uvicorn running on http://0.0.0.0:8000
```

Swagger API:

```text
http://127.0.0.1:8000/docs
```

Nếu test từ điện thoại, dùng IP máy tính, ví dụ:

```text
http://192.168.10.188:8000/docs
```

---

## 6. Cài đặt và chạy Flutter App

### 6.1. Di chuyển vào thư mục app

```powershell
cd C:\Users\PC\airport_maintenance\maintenance_app
```

### 6.2. Cài dependencies

```powershell
flutter pub get
```

### 6.3. Kiểm tra thiết bị

```powershell
flutter devices
```

### 6.4. Chạy app

```powershell
flutter run
```

### 6.5. Chạy sạch lại app

```powershell
flutter clean
flutter pub get
flutter run
```

---

## 7. Cấu hình API cho Flutter

Mở file:

```text
lib/config/api_config.dart
```

Cấu hình `baseUrl` theo IP máy tính đang chạy backend:

```dart
class ApiConfig {
  static const String baseUrl = 'http://192.168.10.188:8000';
}
```

Lưu ý:

```text
Không dùng http://127.0.0.1:8000 trên điện thoại thật.
Vì 127.0.0.1 trên điện thoại là chính điện thoại, không phải máy tính.
```

Điện thoại và máy tính cần cùng mạng Wi-Fi.

---

## 8. Tài khoản demo

| Username | Password | Role |
|---|---|---|
| admin | 123456 | admin |
| supervisor | 123456 | supervisor |
| Trang | 123456 | technician |
| tech01 | 123456 | technician |
| user01 | 123456 | technician |
| user02 | 123456 | technician |

Có thể tạo thêm tài khoản trong màn hình quản lý tài khoản.

---

## 9. API chính

### 9.1. Authentication

```text
POST /api/login
```

### 9.2. Users

```text
GET  /api/users
POST /api/users
PUT  /api/users/{user_id}
PUT  /api/users/{user_id}/active
```

### 9.3. Equipment

```text
GET  /api/equipment
GET  /api/equipment/{code}
POST /api/equipment
PUT  /api/equipment/{code}
GET  /api/equipment/{code}/maintenance
```

### 9.4. Maintenance Tickets

```text
GET  /api/maintenance
GET  /api/maintenance/{ticket_id}
POST /api/maintenance
PUT  /api/maintenance/{ticket_id}/status
PUT  /api/maintenance/{ticket_id}/assign
```

### 9.5. Maintenance Notes

```text
GET  /api/maintenance/{ticket_id}/notes
POST /api/maintenance/{ticket_id}/notes
```

### 9.6. Dashboard

```text
GET /api/dashboard
```

---

## 10. Quản lý thiết bị

Các chức năng thiết bị:

```text
- Xem danh sách thiết bị
- Tìm kiếm thiết bị theo mã, tên, vị trí, tầng, khu vực
- Lọc thiết bị theo hệ thống
- Xem chi tiết thiết bị
- Thêm thiết bị mới
- Chỉnh sửa thiết bị
- Xem mã QR của thiết bị
- Quét QR để mở nhanh chi tiết thiết bị
- Tạo phiếu bảo trì trực tiếp từ thiết bị
- Xem lịch sử phiếu bảo trì của từng thiết bị
```

Thông tin thiết bị gồm:

```text
Mã thiết bị
Tên thiết bị
Hệ thống
Tầng
Khu vực
Vị trí
Trạng thái
Loại thiết bị
IP Address
Serial Number
Model
Hãng sản xuất
```

Ví dụ mã thiết bị:

```text
LTIA-CCTV-CAM-001
LTIA-ACS-DOOR-001
LTIA-FAS-SENSOR-001
```

---

## 11. QR thiết bị

Ứng dụng hỗ trợ tạo và quét QR thiết bị.

Nội dung QR nên là mã thiết bị, ví dụ:

```text
LTIA-CCTV-CAM-001
```

Khi quét QR hợp lệ, ứng dụng sẽ mở màn hình chi tiết thiết bị.

Luồng QR:

```text
1. Mở chức năng quét QR
2. Quét mã QR thiết bị
3. App mở chi tiết thiết bị
4. Xem thông tin thiết bị
5. Tạo phiếu bảo trì nếu cần
```

---

## 12. Phiếu bảo trì

Các chức năng phiếu bảo trì:

```text
- Tạo phiếu bảo trì
- Tạo phiếu nhanh từ màn hình chi tiết thiết bị
- Tự điền mã thiết bị khi tạo phiếu từ thiết bị
- Xem danh sách phiếu
- Lọc phiếu theo trạng thái
- Lọc phiếu theo hệ thống
- Lọc phiếu theo người phụ trách
- Xem chi tiết phiếu
- Gán người phụ trách
- Cập nhật trạng thái phiếu
- Hủy phiếu
- Thêm ghi chú xử lý
- Xem lịch sử xử lý của phiếu
```

Trạng thái phiếu:

```text
open         → Mới tạo
in_progress  → Đang xử lý
done         → Hoàn thành
cancelled    → Đã hủy
```

Thông tin phiếu gồm:

```text
Mã thiết bị
Tiêu đề công việc
Loại công việc
Mức độ ưu tiên
Mô tả hiện trạng
Ảnh hiện trường
Người tạo phiếu
Người phụ trách
Trạng thái
Ngày tạo
Ngày cập nhật
```

---

## 13. Gán người phụ trách

Admin và supervisor có thể gán người phụ trách cho phiếu bảo trì.

Ứng dụng hiển thị danh sách tài khoản kỹ thuật viên đang hoạt động để chọn, tránh nhập sai username thủ công.

Ví dụ:

```text
Nguyễn Văn A (tech01)
Nhân viên kỹ thuật 02 (user02)
```

Database vẫn lưu `assigned_to` theo username để đảm bảo phân quyền chính xác.

Giao diện có thể hiển thị:

```text
Người phụ trách: Nhân viên kỹ thuật 02 (user02)
```

---

## 14. Ghi chú và lịch sử xử lý

Mỗi phiếu bảo trì có lịch sử xử lý riêng.

Lịch sử xử lý bao gồm:

```text
- Ghi chú thủ công của kỹ thuật viên/admin/supervisor
- Lịch sử tự động khi gán người phụ trách
- Lịch sử tự động khi cập nhật trạng thái phiếu
```

Ví dụ:

```text
tech01: Đã kiểm tra nguồn cấp, thiết bị hoạt động không ổn định.
admin: Gán người phụ trách từ Chưa gán sang tech01.
Trang: Cập nhật trạng thái từ Đang xử lý sang Hoàn thành.
```

Lưu ý:

```text
Lịch sử xử lý thuộc về phiếu bảo trì, không thuộc riêng tài khoản nào.
Người có quyền xem phiếu sẽ xem được toàn bộ lịch sử xử lý của phiếu đó.
```

---

## 15. Dashboard theo vai trò

Dashboard hiển thị thống kê theo quyền người dùng.

### Admin và Supervisor

```text
- Tổng số thiết bị
- Tổng số phiếu bảo trì
- Số phiếu theo trạng thái
- Thống kê thiết bị theo hệ thống
```

### Technician

```text
- Chỉ thống kê phiếu được giao cho chính tài khoản đó
- Số phiếu mới tạo
- Số phiếu đang xử lý
- Số phiếu hoàn thành
```

---

## 16. Quản lý tài khoản

Admin có thể quản lý tài khoản người dùng:

```text
- Xem danh sách tài khoản
- Tạo tài khoản mới
- Chỉnh sửa tài khoản
- Phân quyền tài khoản
- Khóa tài khoản
- Mở khóa tài khoản
```

Thông tin tài khoản gồm:

```text
Username
Full name
Role
Active status
```

---

## 17. Luồng sử dụng demo

### 17.1. Luồng Admin / Supervisor

```text
1. Đăng nhập admin hoặc supervisor
2. Vào Dashboard để xem tổng quan
3. Vào Danh sách thiết bị
4. Chọn thiết bị
5. Tạo phiếu bảo trì cho thiết bị
6. Vào danh sách phiếu bảo trì
7. Gán người phụ trách
8. Theo dõi trạng thái xử lý
9. Xem lịch sử ghi chú
10. Xem lịch sử phiếu theo từng thiết bị
```

### 17.2. Luồng Technician

```text
1. Đăng nhập technician
2. Vào Phiếu của tôi
3. Xem phiếu được giao
4. Mở chi tiết phiếu
5. Chuyển trạng thái sang Đang xử lý
6. Thêm ghi chú xử lý
7. Đánh dấu hoàn thành
```

### 17.3. Luồng QR

```text
1. Mở chức năng quét QR
2. Quét mã QR thiết bị
3. App mở chi tiết thiết bị
4. Xem thông tin thiết bị
5. Tạo phiếu bảo trì nếu cần
```

---

## 18. Ảnh giao diện ứng dụng

### 18.1. Màn hình đăng nhập

```
screenshots/01_login.jpg
```

### 18.2. Màn hình trang chủ theo vai trò

```
screenshots/02_home_admin.jpg
```

### 18.3. Dashboard thống kê

```
screenshots/03_dashboard.jpg
```

### 18.4. Danh sách thiết bị

```
screenshots/04_equipment_list.jpg
```

### 18.5. Chi tiết thiết bị

```
screenshots/05_equipment_detail.jpg
```

### 18.6. Mã QR thiết bị

```
screenshots/06_equipment_qr.jpg
```

### 18.7. Quét QR thiết bị

```
screenshots/07_qr_scan.jpg
```

### 18.8. Tạo phiếu bảo trì

```
screenshots/08_create_maintenance.jpg
```

### 18.9. Danh sách phiếu bảo trì

```
screenshots/09_maintenance_list.jpg
```

### 18.10. Chi tiết phiếu bảo trì

```
screenshots/10_maintenance_detail.jpg
```

### 18.11. Ghi chú và lịch sử xử lý

```
screenshots/11_maintenance_notes.jpg
```

### 18.12. Quản lý tài khoản

```
screenshots/12_user_management.jpg
```

### 18.13. Phân quyền theo vai trò

```
screenshots/13_role_permission.jpg
```
---

## 19. Các lệnh thường dùng

### Chạy backend

```powershell
cd C:\Users\PC\airport_maintenance\maintenance_backend
.\venv\Scripts\Activate.ps1
python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

### Chạy Flutter app

```powershell
cd C:\Users\PC\airport_maintenance\maintenance_app
flutter run
```

### Chạy sạch Flutter

```powershell
cd C:\Users\PC\airport_maintenance\maintenance_app
flutter clean
flutter pub get
flutter run
```

### Kiểm tra Git status

```powershell
cd C:\Users\PC\airport_maintenance
git status
```

### Commit code

```powershell
git add .
git commit -m "Complete airport maintenance MVP"
```

---

## 20. Một số lỗi thường gặp

### 20.1. Flutter không kết nối được backend

Kiểm tra:

```text
- Backend đã chạy chưa
- Điện thoại và máy tính có cùng Wi-Fi không
- api_config.dart đã dùng đúng IP máy tính chưa
- Windows Firewall có chặn port 8000 không
```

### 20.2. Không được dùng 127.0.0.1 trên điện thoại

Sai:

```dart
static const String baseUrl = 'http://127.0.0.1:8000';
```

Đúng:

```dart
static const String baseUrl = 'http://192.168.10.188:8000';
```

### 20.3. Lỗi thiếu cột trong SQLite

Nếu backend báo thiếu cột như:

```text
no such column: assigned_to
no such column: active
no such column: updated_at
```

Cần chạy các file fix database tương ứng trong thư mục backend.

Ví dụ:

```powershell
python fix_assigned_to.py
python fix_users_active.py
python fix_db.py
```

### 20.4. Lỗi quyền camera

Đảm bảo Android đã có quyền camera trong:

```text
android/app/src/main/AndroidManifest.xml
```

Cần có:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

Trong thẻ `<application>` cần có:

```xml
android:usesCleartextTraffic="true"
```

### 20.5. Lỗi dùng localhost trên điện thoại

Nếu app chạy trên điện thoại thật, không dùng:

```text
localhost
127.0.0.1
```

Phải dùng IP LAN của máy tính đang chạy backend.

Ví dụ:

```text
192.168.10.188
```

---

## 21. Trạng thái project

Project hiện tại đã hoàn thành ở mức MVP.

```text
Project: Airport Maintenance Management System
Platform: Flutter Mobile App + FastAPI Backend
Database: SQLite
Status: MVP Completed
```

Các chức năng đã hoàn tất:

```text
[✓] Đăng nhập
[✓] Phân quyền
[✓] Dashboard theo role
[✓] Quản lý thiết bị
[✓] QR thiết bị
[✓] Quét QR
[✓] Tạo phiếu bảo trì
[✓] Tạo phiếu từ thiết bị
[✓] Danh sách phiếu
[✓] Lọc phiếu
[✓] Gán người phụ trách
[✓] Cập nhật trạng thái
[✓] Ghi chú xử lý
[✓] Lịch sử xử lý
[✓] Lịch sử phiếu theo thiết bị
[✓] Quản lý tài khoản
[✓] Khóa/mở tài khoản
```

---

## 22. Hướng phát triển tiếp theo

Một số hướng có thể phát triển trong tương lai:

```text
- JWT authentication
- Mã hóa mật khẩu
- Phân quyền backend chặt chẽ hơn
- Push notification khi được giao phiếu
- Xuất báo cáo Excel/PDF
- Upload nhiều ảnh cho một phiếu
- Lọc phiếu theo ngày
- Dashboard biểu đồ
- Đồng bộ dữ liệu với hệ thống CMMS thật
- Triển khai backend lên server nội bộ
- Sao lưu database tự động
```

---

## 23. Ghi chú bảo mật

Phiên bản hiện tại dùng cho demo nội bộ/MVP.

Một số điểm cần cải thiện trước khi triển khai thật:

```text
- Không lưu password dạng plain text
- Nên dùng password hashing
- Nên dùng JWT token
- Nên kiểm tra quyền ở backend, không chỉ ở Flutter
- Nên cấu hình HTTPS khi triển khai server thật
- Nên backup database định kỳ
```

---

## 24. Tác giả

```text
Project: Airport Maintenance Management System
Purpose: Demo hệ thống quản lý bảo trì thiết bị nội bộ sân bay
Platform: Flutter Mobile App + FastAPI Backend
Database: SQLite
Status: MVP Completed
```