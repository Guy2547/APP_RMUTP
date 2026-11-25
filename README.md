# rmutp_campus_app

RMUTP Campus App — UI Prototype (Android + iOS)

แอปต้นแบบสำหรับมหาวิทยาลัยเทคโนโลยีราชมงคลพระนคร (RMUTP) เขียนด้วย Flutter / Dart ออกแบบ UI ให้ตรงกับหน้าจอ RMUTP Student Portal จริง (สไตล์ iPhone 17 Pro) รองรับสลับบทบาท **นักศึกษา / อาจารย์** และเชื่อมต่อฐานข้อมูล Dual-Database (Supabase Cloud + University SQL Server)

## เทคโนโลยีที่ใช้

- **Flutter** (Dart) — SDK: `>=3.0.0 <4.0.0`
- **google_fonts: 8.2.1** (ล็อกเวอร์ชันไว้ ห้าม `flutter pub upgrade google_fonts` เพราะเวอร์ชัน 9.x จะเกิด error `TextTheme`)
- **provider: ^6.1.2** — จัดการสถานะสลับบทบาท (`RoleProvider`) + ฐานข้อมูล (`AppDatabaseProvider`)
- **http: ^1.0.0** — เรียก REST API ฐานข้อมูลมหาวิทยาลัย
- **Material 3** + ฟอนต์ **Kanit** (ตามแบรนด์ rmutp.ac.th)

## โครงสร้างไฟล์ (`lib/`)

```
lib/
├── main.dart                 # App, ThemeData, Routes, MultiProvider(RoleProvider + AppDatabaseProvider)
├── providers/
│   ├── role_provider.dart    # AppRole (student / teacher) + notifyListeners
│   └── app_database_provider.dart # เชื่อมต่อ DatabaseService, จัดการข้อมูลนศ./อาจารย์
├── models/
│   ├── subject.dart          # รายวิชา, เวลา, ห้อง, ความคืบหน้า
│   ├── grade.dart            # เกรดนักศึกษา, แถวคะแนนอาจารย์
│   ├── news_item.dart        # ข่าว / ทุน / ฝึกงาน
│   ├── notification_item.dart# แจ้งเตือน
│   └── request_item.dart     # คำขอแจ้งซ่อม / ขอเอกสาร
├── screens/
│   ├── login_screen.dart         # เข้าสู่ระบบ, โลโก้ RMUTP, ฟอร์มอีเมล/รหัสผ่าน
│   ├── forgot_password_screen.dart # ลืมรหัสผ่าน, ส่งลิงก์รีเซ็ต
│   ├── home_screen.dart          # Dashboard: โปรไฟล์ + GPA + เมนูลัด + ตารางเรียน + แจ้งเตือน
│   ├── timetable_screen.dart     # ตารางเรียน / ตารางสอน สลับวันจันทร์–เสาร์ได้
│   ├── courses_screen.dart       # รายวิชาพร้อมแถบความคืบหน้าและงานค้าง
│   ├── course_detail_screen.dart # รายละเอียดวิชา, เอกสารดาวน์โหลด, ส่งงาน
│   ├── grades_screen.dart        # ผลการเรียน: การ์ด GPA + รายวิชาแยกเกรดตัวอักษร
│   ├── grade_submit_screen.dart  # อาจารย์กรอกคะแนนกลางภาค/ปลายภาค/เก็บ
│   ├── attendance_screen.dart    # เช็คชื่อ/QR (นศ.) / เปิดห้องเช็คชื่อ (อาจารย์)
│   ├── news_screen.dart          # ข่าว / ทุน / ฝึกงาน ตัวกรองประเภท
│   ├── news_detail_screen.dart   # รายละเอียดข่าว, สมัครทุน
│   ├── notif_screen.dart         # แจ้งเตือน + ปฏิทินการศึกษา
│   ├── requests_screen.dart      # แจ้งซ่อม / ขอเอกสาร / ร้องเรียน (แท็บหมวดหมู่)
│   ├── help_screen.dart          # เบอร์โทรทะเบียน/IT, คำถามพบบ่อย
│   └── profile_screen.dart       # โปรไฟล์แยกบทบาท, เกรดสะสม, การตั้งค่า, ออกจากระบบ
├── widgets/
│   ├── app_theme.dart       # สี, ฟอนต์, ปุ่มหลัก/ผี, Card, Chip, Toast
│   ├── role_pill.dart       # ปุ่มสลับบทบาท
│   ├── subject_card.dart    # การ์ดรายวิชา
│   ├── grade_card.dart      # แถวคะแนนสำหรับอาจารย์
│   ├── app_toast.dart       # Toast notification
│   └── custom_bottom_nav.dart # แถบนำทางด้านล่าง (5 แท็บหลัก)
└── services/
    ├── database_config.dart   # การตั้งค่าฐานข้อมูล 2 ระบบ (Supabase + University SQL)
    ├── database_service.dart  # บริการเรียก API, ตรวจสอบการเข้าสู่ระบบ, คำร้อง, เกรด
    └── mock_data.dart       # ข้อมูลจำลองสำหรับทดสอบเมื่อยังไม่ต่อ API
```

## สีแบรนด์ RMUTP

| ตัวแปร | สี | Hex |
|--------|-----|-----|
| `kDark` | ม่วงเข้ม | `#420671` |
| `kMain` | ม่วง | `#4D287B` |
| `kMid` | ม่วงกลาง | `#652D91` |
| `kLight` | ม่วงอ่อน | `#7632AB` |
| `kGold` | ทอง | `#F6DC04` |
| `kCream` | ครีม | `#F7E7BB` |
| `kBg` | พื้นจอ | `#F5F3FA` |

## คำสั่งที่ใช้ (รันในโฟลเดอร์โปรเจกต์)

```powershell
# ดึง dependencies (ต้องรันหลังแก้ pubspec.yaml ครั้งแรก)
flutter pub get

# ตรวจว่าโค้ดไม่มี error
flutter analyze

# รันลง Edge browser (เว็บ)
flutter run -d edge

# รันลง Android emulator / มือถือ
flutter run

# บิลด์เว็บสำหรับ deploy
flutter build web
```

## ผลการทดสอบ (ล่าสุด)

| การทดสอบ | ผล |
|-----------|-----|
| `flutter analyze` | ✅ ผ่าน (ไม่มี error, ไม่มี warning เหลือแค่ info ที่ไม่บล็อก build) |
| `flutter build web` | ✅ สำเร็จ สร้างไฟล์ที่ `build/web` แล้ว |
| `flutter run -d edge` | ✅ รันบน Edge browser สำเร็จ แอปเปิดหน้า login ใช้งานได้ |

## หน้าจอทั้งหมด (15 เส้นทาง)

| เส้นทาง | หน้าจอ | รายละเอียด |
|---------|---------|-------------|
| `/login` | เข้าสู่ระบบ | โลโก้ RMUTP, ฟอร์มอีเมล/รหัสผ่าน, สลับโหมดฐานข้อมูล |
| `/forgot-password` | ลืมรหัสผ่าน | ฟอร์มอีเมล, ปุ่มส่งลิงก์รีเซ็ต |
| `/home` | หน้าแรก | โปรไฟล์นักศึกษา + การ์ด GPA + เมนูลัดกริด + ตารางเรียน + แจ้งเตือนล่าสุด |
| `/timetable` | ตารางเรียน | แท็บสลับวัน (จันทร์–เสาร์) + การ์ดวิชาพร้อมความคืบหน้า |
| `/grades` | เกรดสะสม | การ์ด GPA สะสม + รายวิชาแยกเกรดตัวอักษร (A, B+, B, ฯลฯ) |
| `/courses` | รายวิชา | รายวิชาพร้อมแถบความคืบหน้าและงานค้าง |
| `/course-detail` | รายละเอียดวิชา | เอกสารดาวน์โหลด, ส่งงาน, คะแนนย่อย |
| `/grade-submit` | ส่งเกรด (อาจารย์) | กรอกคะแนนกลางภาค/ปลายภาค/เก็บ, คำนวณเกรดอัตโนมัติ |
| `/attendance` | เช็คชื่อ | เช็คชื่อ/สแกน QR (นศ.) / เปิดห้องเช็คชื่อ (อาจารย์) |
| `/news` | ข่าว / ทุน / ฝึกงาน | รายการข่าว ตัวกรองประเภท |
| `/news-detail` | รายละเอียดข่าว | เนื้อหาข่าว, ปุ่มสมัครทุน |
| `/notif` | แจ้งเตือน + ปฏิทิน | รายการแจ้งเตือน, ปฏิทินการศึกษา |
| `/requests` | แจ้งเรื่อง / ขอเอกสาร | แท็บหมวดหมู่ (ทั้งหมด/แจ้งซ่อม/ขอเอกสาร/ร้องเรียน) + รายการคำร้อง |
| `/help` | ช่วยเหลือ | เบอร์โทรทะเบียน/IT, คำถามพบบ่อย |
| `/profile` | โปรไฟล์ | ข้อมูลส่วนตัว, เกรดสะสม, การตั้งค่า, ออกจากระบบ |

## แถบนำทางด้านล่าง (Bottom Navigation)

5 แท็บหลัก: หน้าแรก / ตาราง / เกรด / คำร้อง / โปรไฟล์

## ปัญหาที่พบและวิธีแก้ไข

| ปัญหาที่เจอ | สาเหตุ | วิธีแก้ไข |
|-------------|--------|-----------|
| `google_fonts 9.x` ทำให้ error `TextTheme` | google_fonts เวอร์ชันใหม่ใช้ TextTheme คนละคลาสกับที่โค้ดอ้างอิง | ล็อกเวอร์ชันไว้ที่ `google_fonts: 8.2.1` ใน `pubspec.yaml` **ห้าม upgrade** |
| ไม่มีไฟล์หน้าจอ / โครงสร้างกระจัดกระจาย | โปรเจกต์เริ่มต้นมีแค่ `main.dart` ไฟล์เดียว | สร้างโครงสร้างใหม่: `providers/`, `models/`, `screens/`, `widgets/`, `services/` แยกตามหน้าจอ |
| ไม่มีระบบจัดการสถานะบทบาท | ยังไม่มี provider | เพิ่ม `provider: ^6.1.2` สร้าง `RoleProvider` (student/teacher) และ `AppDatabaseProvider` |
| ไม่มีข้อมูลสำหรับทดสอบ | ต้องต่อ API จริงก่อนถึงจะเห็นข้อมูล | สร้าง `lib/services/mock_data.dart` ย้ายข้อมูลจาก `index.html` มาใช้เป็น mock data |
| **`RenderFlex overflowed by 10 pixels on the bottom`** | เนื้อหาใน `SingleChildScrollView` ชนกับแถบนำทางด้านล่าง เนื่องจากใช้ `padding` ค่าคงที่ไม่ครอบคลุม safe area ของมือถือ (เช่น home indicator ของ iPhone) | สร้างฟังก์ชัน `bottomPadding(context)` ที่อ่านจาก `MediaQuery.of(context).padding.bottom` แทนค่าคงที่ แล้วใส่ใน `SingleChildScrollView` และ `ListView.builder` ทุกหน้าจอ |
| **โครงสร้าง `home_screen.dart` ทำให้ layout พัง** | ใช้ `GridView.count(shrinkWrap: true)` และ `Row(children: [Expanded, Expanded])` ภายใน `Column` ภายใน `SingleChildScrollView` ทำให้ Flutter คำนวณความสูงผิดพลาด | เปลี่ยน `GridView` เป็น `Column` + สอง `Row` (การ์ด 4 ตัวแบ่ง 2 แถว) และเปลี่ยน `Row+Expanded` เป็น `Column` ซ้อนแนวตั้ง |
| **กดปุ่มนำทางด้านล่างซ้ำๆ ได้หลายครั้ง** | Debounce state ถูกเก็บใน `State` ของ `CustomBottomNav` ซึ่งถูกสร้างใหม่ทุกครั้งที่เปลี่ยน route ทำให้ตัวจับเวลารีเซ็ตตลอด | ย้าย state debounce ไว้เป็น `static` (`_lastRoute`, `_lastTapTime`) จำเวลากดข้ามหน้าได้ เช็กว่ากด route ปัจจุบันซ้ำหรือไม่ก่อนนำทาง หน่วงเวลา 500ms ก่อนอนุญาตให้กด route เดิมอีกครั้ง |

## หมายเหตุสำคัญ

- **ห้าม `flutter pub upgrade google_fonts`** เด็ดขาด เพราะเวอร์ชัน 9.x จะเกิด error `TextTheme` ซ้ำ ต้องล็อกไว้ที่ `google_fonts: 8.2.1` เท่านั้น
- หน้าทั้งหมดใช้ **ข้อมูลจำลอง (mock data)** จาก `lib/services/mock_data.dart` ถ้าจะเชื่อมระบบจริง (Supabase / University SQL API) ให้ตั้งค่า URL และ Key ในหน้า Login หรือผ่านไฟล์ `.env`
- สำหรับ iOS ต้องใช้ Mac กับ Xcode ถ้าอยู่บน Windows จะรันได้แค่ Android (หรือทดสอบบน web ก่อนได้)
- โปรเจกต์อยู่ที่ path ภาษาอังกฤษไม่มีช่องว่างแล้ว (`C:\data\My data\dev\APP`) จึงไม่มีปัญหา flutter analyze เรื่อง path ภาษาไทย

## 🔒 การแก้ไขความปลอดภัยและ UI (ล่าสุด)

### ปรับหน้า Login ตามดีไซน์ใหม่
- เปลี่ยนพื้นหลังเป็นสีเทาอ่อน `#F5F3FA` เต็มจอ ไม่มี AppBar
- โลโก้ RMUTP ใช้รูปภาพจาก `lib/assets/images/rmutp_logo.jpg` (ไฟล์จริงจากโฟลเดอร์ Logo App)
- หัวข้อเป็น "Log in" ขนาดใหญ่ + คำอธิบาย "เข้าสู่มหาวิทยาลัยเทคโนโลยีราชมงคลพระนคร RMUTP"
- ฟอร์มอีเมลและรหัสผ่านเป็นพื้นหลังขาว โค้งมน 16px มีไอคอนจดหมายและกุญแจ
- ปุ่ม "ลืมรหัสผ่าน?" วางอยู่ขวาบนของฟิลด์รหัสผ่าน (overlay)
- ปุ่ม "เข้าสู่ระบบ" สีม่วงเข้ม สูง 56px โค้งมน 16px
- แถวล่างแสดง "ลืมรหัสผ่าน?" + "เข้าสู่บัญชี RMUTP" ในแถวเดียว
- **ลบ** ส่วนตั้งค่าฐานข้อมูล (Supabase/University SQL) ออกจากหน้า Login
- **ลบ** รายชื่อบัญชีทดสอบและรหัสผ่านที่แสดงใน UI ออกทั้งหมด

### ลบแถบนำทางด้านล่างออกจากทุกหน้า
- ลบ `CustomBottomNav` ออกจากทุกหน้าจอ (home, grades, timetable, courses, course-detail, grade-submit, attendance, news, news-detail, notif, requests, profile, help)
- เหลือเฉพาะ `bottomPadding` สำหรับรองรับ safe area ของมือถือ

### แก้ไขช่องโหว่ความปลอดภัย (Security Fixes)

| ลำดับ | ช่องโหว่ | ระดับ | การแก้ไข |
|-------|----------|-------|----------|
| 1 | รหัสผ่านทดสอบ `password123` ฮาร์ดโค้ดใน `_localAccounts` | Critical | ลบ map `_localAccounts` ทั้งหมด ต้องยืนยันตัวตนผ่าน API จริงเท่านั้น |
| 2 | ข้อมูลส่วนตัวจริง (เลขบัตรประชาชน, ที่อยู่, เบอร์โทร, ข้อมูลธนาคาร) ฝังในโค้ด | Critical | ลบ `_defaultDeepProfile()` และ `_defaultFinancialRecords()` ที่มีข้อมูลจริง แทนที่ด้วย dummy data ว่างเปล่า |
| 3 | `teacherId = 'T-1024'` ค่าเริ่มต้นใน `saveTeacherGrades()` | High | เอาค่าเริ่มต้นออก บังคับต้องระบุ `teacherId` จาก session จริงเท่านั้น |
| 4 | โทเค็นเข้าสู่ระบบเก็บใน static variable | High | ใช้ `flutter_secure_storage` เก็บใน Keystore/Keychain แทน ล้างเมื่อออกจากระบบ |
| 5 | URL เขียนผิด `https:https://...` | Low | แก้เป็น `https://qnsdreorzllhpxsuilpa.supabase.co` |
| 6 | รหัสระบุตัวตนเดาได้ (`7777...`, `6666...`, `#RQ-${second}`) | Medium | ใช้ `_generateUuid()` สร้าง UUID แบบสุ่มแทน |
| 7 | เพิ่ม dependencies | — | `dio: ^5.7.0`, `flutter_secure_storage: ^9.0.0` |

### ไฟล์ที่แก้ไขทั้งหมด (21 ไฟล์)
- `pubspec.yaml` — เพิ่ม `dio`, `flutter_secure_storage`, assets รูปโลโก้
- `pubspec.lock` — อัปเดตตาม dependencies ใหม่
- `lib/services/database_service.dart` — ลบรหัสผ่านฮาร์ดโค้ด, ลบข้อมูลส่วนตัวจริง, ใช้ `FlutterSecureStorage`, สร้าง UUID สุ่ม, แก้ `teacherId` เป็น required parameter
- `lib/providers/app_database_provider.dart` — ตรวจสอบ `teacherId` ก่อนส่งเกรด
- `lib/screens/login_screen.dart` — เขียน UI ใหม่ทั้งหมด, ลบรหัสผ่าน grอกล่วงหน้า, ลบบัตรบัญชีทดสอบ
- `lib/screens/home_screen.dart` — เขียนใหม่เป็นกริดเมนู 3×2 + แจ้งเตือน, ลบ bottom nav
- `lib/screens/grades_screen.dart`, `course_detail_screen.dart`, `attendance_screen.dart`, `courses_screen.dart`, `grade_submit_screen.dart`, `help_screen.dart`, `news_detail_screen.dart`, `news_screen.dart`, `notif_screen.dart`, `profile_screen.dart`, `timetable_screen.dart`, `requests_screen.dart` — ลบ `CustomBottomNav` ออกทั้งหมด

## เอกสารอ้างอิง

- `SESSION_SUMMARY.md` — บันทึกเซสชันแก้ไขก่อนหน้า (ปัญหา Gradle, java_home, google_fonts เวอร์ชัน ฯลฯ)
- `index.html` (ใน `C:\data\My data\dev\`) — ต้นฉบับ UI ที่พอร์ตมาสร้างแอปนี้
