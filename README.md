# rmutp_campus_app

RMUTP Campus App — UI Prototype (Android + iOS)

แอปต้นแบบสำหรับมหาวิทยาลัยเทคโนโลยีราชมงคลพระนคร (RMUTP) เขียนด้วย Flutter / Dart พอร์ต UI จาก `index.html` (Tailwind + HTML เดียว) มาเป็นแอปมือถือจริง รองรับสลับบทบาท **นักศึกษา / อาจารย์**

## เทคโนโลยีที่ใช้

- **Flutter** (Dart) — SDK: `>=3.0.0 <4.0.0`
- **google_fonts: 8.2.1** (ล็อกเวอร์ชันไว้ ห้าม `flutter pub upgrade google_fonts` เพราะเวอร์ชัน 9.x จะเกิด error `TextTheme`)
- **provider: ^6.1.2** — จัดการสถานะสลับบทบาท (`RoleProvider`)
- **Material 3** + ฟอนต์ **Kanit** (ตามแบรนด์ rmutp.ac.th)

## โครงสร้างไฟล์ (`lib/`)

```
lib/
├── main.dart                 # App, ThemeData, Routes (ทั้งหมด 12 เส้นทาง), ChangeNotifierProvider(RoleProvider)
├── providers/
│   └── role_provider.dart    # AppRole (student / teacher) + notifyListeners
├── models/
│   ├── subject.dart          # รายวิชา, เวลา, ห้อง, ความคืบหน้า
│   ├── grade.dart            # เกรดนักศึกษา, แถวคะแนนอาจารย์
│   ├── news_item.dart        # ข่าว / ทุน / ฝึกงาน
│   ├── notification_item.dart# แจ้งเตือน
│   └── request_item.dart     # คำขอแจ้งซ่อม / ขอเอกสาร
├── screens/
│   ├── login_screen.dart         # เข้าสู่ระบบ, เลือกบทบาท
│   ├── home_screen.dart          # Dashboard แยกเนื้อหานศ. / อาจารย์
│   ├── timetable_screen.dart     # ตารางเรียน / ตารางสอน (สลับวันได้)
│   ├── courses_screen.dart       # รายวิชาพร้อมแถบความคืบหน้า
│   ├── course_detail_screen.dart # รายละเอียดวิชา, เอกสาร, ส่งงาน
│   ├── grades_screen.dart        # ผลการเรียน (นศ.) / ส่งเกรด (อาจารย์)
│   ├── grade_submit_screen.dart  # อาจารย์กรอกคะแนนกลางภาค/ปลายภาค/เก็บ
│   ├── attendance_screen.dart    # เช็คชื่อ (นศ.) / เปิดห้องเช็คชื่อ (อาจารย์)
│   ├── news_screen.dart          # ข่าว / ทุน / ฝึกงาน
│   ├── news_detail_screen.dart   # รายละเอียดข่าว, สมัครทุน
│   ├── notif_screen.dart         # แจ้งเตือน + ปฏิทินการศึกษา
│   ├── requests_screen.dart      # แจ้งซ่อม / ขอเอกสาร / อนุมัติ
│   ├── help_screen.dart          # เบอร์โทร, คำถามพบบ่อย
│   └── profile_screen.dart       # โปรไฟล์แยกบทบาท, ออกจากระบบ
├── widgets/
│   ├── app_theme.dart       # สี, ฟอนต์, ปุ่มหลัก/ผี, Card, Chip, Toast
│   ├── role_pill.dart       # ปุ่มสลับบทบาท
│   ├── subject_card.dart    # การ์ดรายวิชา
│   ├── grade_card.dart      # แถวคะแนนสำหรับอาจารย์
│   ├── app_toast.dart       # Toast notification
│   └── custom_bottom_nav.dart # แถบนำทางด้านล่าง
└── services/
    └── mock_data.dart       # ข้อมูลจำลอง (ย้ายมาจาก index.html)
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
```

## ผลการทดสอบ (ล่าสุด)

| การทดสอบ | ผล |
|-----------|-----|
| `flutter analyze` | ✅ ผ่าน (ไม่มี error, ไม่มี warning เหลือแค่ info ที่ไม่บล็อก build) |
| `flutter run -d edge` | ✅ รันบน Edge browser สำเร็จ แอปเปิดหน้า login ใช้งานได้ |
| `flutter run` (Android) | รอทดสอบบน emulator (ต้องมี Android emulator หรือมือถือต่ออยู่) |

## หน้าจอทั้งหมด (14 เส้นทาง)

1. `/login` — เข้าสู่ระบบ, เลือกบทบาท นักศึกษา / อาจารย์
2. `/home` — Dashboard แยกเนื้อหาตามบทบาท
3. `/timetable` — ตารางเรียน / ตารางสอน สลับวันจันทร์–ศุกร์ได้
4. `/courses` — รายวิชาพร้อมแถบความคืบหน้าและงานค้าง
5. `/course-detail` — รายละเอียดวิชา, เอกสารดาวน์โหลด, ส่งงาน
6. `/grades` — ผลการเรียน (นศ.) / ตารางส่งเกรด (อาจารย์)
7. `/grade-submit` — อาจารย์กรอกคะแนนกลางภาค/ปลายภาค/เก็บ, คำนวณเกรดอัตโนมัติ
8. `/attendance` — เช็คชื่อ/QR (นศ.) / เปิดห้องเช็คชื่อ (อาจารย์)
9. `/news` — ข่าว / ทุน / ฝึกงาน ตัวกรองประเภท
10. `/news-detail` — รายละเอียดข่าว, สมัครทุน
11. `/notif` — แจ้งเตือน + ปฏิทินการศึกษา
12. `/requests` — แจ้งซ่อม / ขอเอกสาร / อนุมัติ-ตีกลับ
13. `/help` — เบอร์โทรทะเบียน/IT, คำถามพบบ่อย (expandable)
14. `/profile` — โปรไฟล์แยกบทบาท, ภาษา, แจ้งเตือน, ออกจากระบบ

## หมายเหตุสำคัญ

- **ห้าม `flutter pub upgrade google_fonts`** เด็ดขาด เพราะเวอร์ชัน 9.x จะเกิด error `TextTheme` ซ้ำ ต้องล็อกไว้ที่ `google_fonts: 8.2.1` เท่านั้น
- หน้าทั้งหมดใช้ **ข้อมูลจำลอง (mock data)** จาก `lib/services/mock_data.dart` ถ้าจะเชื่อมระบบจริง (Firebase / Supabase / REST API) ให้เพิ่ม repository layer ต่อจาก mock data
- สำหรับ iOS ต้องใช้ Mac กับ Xcode ถ้าอยู่บน Windows จะรันได้แค่ Android (หรือทดสอบบน web ก่อนได้)
- โปรเจกต์อยู่ที่ path ภาษาอังกฤษไม่มีช่องว่างแล้ว (`C:\data\My data\dev\APP`) จึงไม่มีปัญหา flutter analyze เรื่อง path ภาษาไทย

## เอกสารอ้างอิง

- `SESSION_SUMMARY.md` — บันทึกเซสชันแก้ไขก่อนหน้า (ปัญหา Gradle, java_home, google_fonts เวอร์ชัน ฯลฯ)
- `index.html` (ใน `C:\data\My data\dev\`) — ต้นฉบับ UI ที่พอร์ตมาสร้างแอปนี้
