# สรุปเซสชัน — แก้ไข Flutter โปรเจกต์ RMUTP Campus App

## โปรเจกต์
- ชื่อ: `rmutp_campus_app`
- โฟลเดอร์: `C:\data\My data\จบชีวิต\APP`
- เป้าหมาย: แอปมหาลัย RMUTP รันได้ทั้ง Android + iOS (Flutter, ภาษา Dart)

## ไฟล์ที่แก้ไขในเซสชันนี้

### 1. `lib/main.dart` — เขียนใหม่ทั้งหมด
การแก้ไขที่ทำ:
- **ลบตัวแปรที่ประกาศแล้วไม่ได้ใช้** ใน `_themeData`: `light`, `gold`, `cream`
- **ลบ `background: bg`** จาก `ColorScheme.fromSeed` (deprecated ใน Flutter ใหม่ ให้ใช้ `surface` แทน)
- **ลบเมธอด `_login()`** ที่ประกาศไว้แต่ไม่ถูกเรียกใช้
- **เชื่อมปุ่ม login** ปุ่ม "เข้าใช้: นักศึกษา / อาจารย์" และป้าย role ให้เรียก `Navigator.pushNamed(context, '/home')` เมื่อกด
- `textTheme` ใช้ `GoogleFonts.kanitTextTheme()` (ตามฟอนต์ Kanit จากเว็บ RMUTP)
- สีแบรนด์คงเดิม: ม่วง `#420671` (dark), `#4D287B` (main), `#652D91` (mid), ทอง `#F6DC04`, พื้น `#F5F3FA`

### 2. `test/widget_test.dart` — ลบทิ้ง
เหตุผล: ไฟล์ถูกสร้างทับโดย `flutter create` แล้วอ้างอิงคลาส `MyApp` ซึ่งไม่มีอยู่ในโปรเจกต์ (จริงใช้ชื่อ `RMUTPApp`) ทำให้ analyzer error

## ปัญหาที่แก้ไขแล้ว (ก่อนหน้านี้)
- **Gradle Wrapper Main หาย**: แก้โดยรัน `flutter create .` เพื่อสร้างโฟลเดอร์ `android/` ใหม่พร้อม `gradle-wrapper.jar`, `gradlew`, `gradlew.bat`
- **Path โปรเจกต์มีภาษาไทยและช่องว่าง**: `C:\data\My data\จบชีวิต\APP` อาจทำให้ Gradle/Java อ่านไฟล์ไม่ได้ แนะนำให้ย้ายโปรเจกต์ไป `C:\dev\app` (ภาษาอังกฤษ ไม่มีช่องว่าง)

## คำสั่งตรวจสอบ (รันใน PowerShell ที่โฟลเดอร์โปรเจกต์)

```powershell
# ตรวจว่าโค้ดไม่มี error
flutter analyze

# รันแอปลง emulator / มือถือ
flutter devices
flutter run
```

ถ้า `flutter analyze` แสดง "No issues found!" แปลว่าโค้ดพร้อม build แล้ว

## หมายเหตุสำหรับการต่อยอด
- หน้า Home และ StubScreen อื่น ๆ ยังเป็นหน้าหมอๆ (กำลังพัฒนา) กดเข้าผ่านแถบด้านล่างได้แล้ว
- ถ้าจะเชื่อมระบบจริง (Firebase/Supabase, Auth, ฐานข้อมูล) ให้ทำภายหลังจาก UI เสร็จ
- สำหรับ iOS ต้องใช้ Mac กับ Xcode ถ้าอยู่บน Windows จะรันได้แค่ Android
สรุปการแก้ปัญหา Flutter บน Windows (โปรเจกต์ rmutp_campus_app)

สภาพแวดล้อม:
- Windows, Android Studio + PowerShell, Flutter/Dart
- โปรเจกต์: C:\data\My data\dev\APP
- Emulator: Android 17 (API 37), emulator-5554
- JDK 17 (JAVA_HOME = C:\Program Files\Microsoft\jdk-17.0.20.101-hotspot\)
- Flutter SDK: C:\src\flutter

ปัญหาที่เจอและแก้แล้ว:
1. Error: Could not find or load main class org.gradle.wrapper.GradleWrapperMain
   - สาเหตุ: โฟลเดอร์ android หายไป (ไม่มี gradle-wrapper.jar)
   - แก้: flutter create --platforms=android --org com.rmutp.campus .
   - ผล: ได้ gradle-wrapper.jar + gradle-wrapper.properties (Gradle 9.3.1) กลับมา

2. JAVA_HOME ชี้ไป C:\Program Files\Java\jdk-17 ซึ่งไม่มีจริง
   - แก้: ตั้ง JAVA_HOME ให้ชี้ JDK ที่มีจริง และ flutter config --jdk-dir

3. "Building with plugins requires symlink support"
   - แก้: เปิด Developer Mode (start ms-settings:developers)

4. flutter analyze ล่ม (FormatException: Unterminated string)
   - สาเหตุ: path โปรเจกต์มีภาษาไทย
   - แก้: ย้ายโปรเจกต์ไป path ภาษาอังกฤษ

5. lib\main.dart: "TextTheme can't be assigned to TextTheme?" (GoogleFonts.kanitTextTheme())
   - สาเหตุ: google_fonts 9.x ใช้ TextTheme จาก material_ui แต่โค้ดใช้ ThemeData จาก package:flutter/material.dart
   - แก้: ล็อก google_fonts: 8.2.1 (ไม่มี ^) ใน pubspec.yaml แล้ว flutter pub get

6. ลบ test\widget_test.dart (อ้าง MyApp ที่ไม่มี; แอปจริงคือ RMUTPApp)

สิ่งที่ไม่ใช่ปัญหา (ข้ามได้):
- Android license unknown, Chrome, Visual Studio ใน flutter doctor
- "Test directory does not contain any test files" (ไม่มีไฟล์เทส)

สถานะปัจจุบัน:
- flutter analyze: ไม่มี error เหลือ warning เดียว (ตัวแปร 'bg' ไม่ได้ใช้ ที่ lib\main.dart:95)
- ยังไม่ได้ยืนยันผล flutter run

สิ่งที่ต้องการให้ช่วย:
- ตรวจว่า flutter run บน emulator ผ่านและแอปเปิดได้ (ถ้ามี error ให้วิเคราะห์ต่อ)
- ลบหรือใช้ตัวแปร bg ที่ไม่ได้ใช้
- ข้อควรระวัง: ห้าม flutter pub upgrade google_fonts เพราะจะดึง 9.x กลับมาแล้วเกิด error ข้อ 5 ซ้ำ