# RMUTP Campus App

แอปมือถือสำหรับนักศึกษาและอาจารย์ มหาวิทยาลัยเทคโนโลยีราชมงคลพระนคร (RMUTP)
สร้างด้วย **React Native + Expo + TypeScript** เขียนโค้ดชุดเดียว รองรับทั้ง **Android และ iOS**

---

## 1. บริบทและที่มาของโปรเจกต์

### ผู้พัฒนา
นักศึกษาวิศวกรรมคอมพิวเตอร์ มีพื้นฐาน **Node.js, Express, PostgreSQL, Docker** ใช้เครื่อง **Windows** (ไม่มี Mac)

### โปรเจกต์ต้นแบบเดิม (UI Prototype)
ก่อนหน้านี้มีไฟล์ `index.html` หนึ่งไฟล์จบ ใช้ Tailwind CDN + ฟอนต์ Kanit + Vanilla JS เป็นแอปต้นแบบสำหรับนำเสนอ มี 14 หน้าจอ (Login + 13 จอ) รองรับสลับบทบาท **นักศึกษา / อาจารย์**

รายละเอียดอยู่ในไฟล์ `MEMORY.md` (โฟลเดอร์ต้นทาง `C:\data\My data\จบชีวิต`)

### ระบบใหม่ที่เพิ่มเข้ามา (จากรูปภาพจริงของ มทร.พระนคร)
**Activity Transcript System (AT-Code)** ประกอบด้วย:
1. **หน้าเข้าสู่ระบบ** — กรอกรหัสนักศึกษา + AT-Code (รหัสตัวอย่าง: `056860405008-4`)
2. **แดชบอร์ด AT-Code** — พิมพ์เบื้ม AT-Code, ยืนยันใบแจ้งกิจกรรม, รายละเอียดกิจกรรม, พิมพ์สรุปผลกิจกรรม
3. **หน้าพิมพ์ใบรับรอง AT-Code** — กรอกรหัสนักศึกษาและ AT-Code แล้วกดพิมพ์เบื้ม
4. **รายงานสรุปการเข้าร่วมกิจกรรม** — ตารางสถิติกิจกรรมทั้งหมด / กิจกรรมปฐมนิเทศ / กิจกรรมพัฒนาศักยภาพ แบ่งเป็น จำนวนกิจกรรม, จำนวนครั้ง, ที่ยืนยันแล้ว, ที่ยังไม่ยืนยัน

---

## 2. ตัวเลือกเทคโนโลยีและสรุปการตัดสินใจ

| ตัวเลือก | รายละเอียด | ตัดสินใจ |
|---------|------------|----------|
| React Native + Expo + TypeScript | คุ้น JavaScript/Node.js อยู่แล้ว เขียนครั้งเดียวรันได้ทั้ง Android และ iOS | ✅ ใช้ |
| Flutter (Dart) | ต้องเรียนภาษาใหม่ | ❌ |
| Kotlin Multiplatform | ต้องเขียนแยกแพลตฟอร์มมากกว่า | ❌ |

### ข้อจำกัดบน Windows
- **iOS Simulator ใช้บน Windows ไม่ได้** — ต้องทดสอบด้วย iPhone จริงผ่าน Expo Go
- **Build iOS ต้องใช้ Mac** — แก้ไขโดยใช้ **EAS Build (คลาวด์)**, Codemagic, GitHub Actions (macOS runner), Bitrise หรือเช่า Mac บนคลาวด์ (MacinCloud)
- **ขึ้น App Store ต้องมี Apple Developer Account** (~$99/ปี)
- **ขึ้น Google Play ต้องมี Google Play Console** ($25 ครั้งเดียว)

---

## 3. ฟีเจอร์หลัก

| ฟีเจอร์ | นักศึกษา | อาจารย์ |
|---------|----------|----------|
| เข้าสู่ระบบ (รหัสนักศึกษา + AT-Code) | ✅ | ✅ |
| ตารางเรียน / ตารางสอน | ✅ | ✅ |
| รายวิชา + ส่งงาน | ✅ | ✅ (ตรวจงาน) |
| เกรด / GPA | ✅ | ✅ (ส่งเกรด) |
| เช็คชื่อเข้าเรียน (สแกน QR) | ✅ | ✅ (เปิดห้องเช็คชื่อ) |
| ข่าว / ทุน / ฝึกงาน | ✅ | ✅ (ลงประกาศ) |
| แจ้งซ่อม / ขอเอกสาร + ติดตาม | ✅ | ✅ (อนุมัติ) |
| ช่วยเหลือ / ติดต่อหน่วยงาน | ✅ | ✅ |
| โปรไฟล์ + ออกจากระบบ | ✅ | ✅ |
| **AT-Code กิจกรรม** | ✅ | — |
| **รายงานสรุปกิจกรรม** | ✅ | — |

---

## 4. โครงสร้างโปรเจกต์

```
APP/
├── package.json
├── tsconfig.json
├── app.json                  # ตั้งค่า Expo, bundle ID, สี, รูปภาพ
├── eas.json                  # ตั้งค่า EAS Build (Android + iOS)
├── .gitignore
├── README.md
│
├── app/                      # Expo Router (file-based routing)
│   ├── _layout.tsx           # Root layout + โหลดฟอนต์ Kanit
│   ├── index.tsx             # Splash / redirect ไป /login
│   ├── login.tsx             # หน้าเข้าสู่ระบบหลัก
│   │
│   ├── (auth)/               # กลุ่มหน้าที่ต้อง Auth
│   │   ├── _layout.tsx
│   │   └── at-login.tsx      # AT-Code login (ตามรูปภาพจริง)
│   │
│   ├── (app)/                # กลุ่มหน้าหลักแอป (ต้องล็อกอินแล้ว)
│   │   ├── _layout.tsx       # Tab Navigator
│   │   ├── index.tsx         # Home dashboard
│   │   ├── timetable.tsx     # ตารางเรียน
│   │   ├── courses.tsx       # รายวิชา + ความคืบหน้า
│   │   ├── grades.tsx        # เกรด / GPA
│   │   ├── attendance.tsx    # เช็คชื่อ / สแกน QR
│   │   ├── news.tsx          # ข่าว / ทุน / ฝึกงาน
│   │   ├── notif.tsx         # แจ้งเตือน + ปฏิทินวิชาการ
│   │   ├── requests.tsx      # แจ้งซ่อม / ขอเอกสาร + tracking
│   │   ├── help.tsx          # Q&A + เบอร์ติดต่อ
│   │   ├── profile.tsx       # โปรไฟล์ + ออกจากระบบ
│   │   └── at-report.tsx     # รายงานสรุปกิจกรรม (AT-Code)
│   │
│   └── (modal)/              # หน้าแสดงเป็น Modal
│       ├── _layout.tsx
│       └── print-at.tsx      # พิมพ์ใบรับรอง AT-Code
│
├── components/               # คอมโพเนนต์ใช้ซ้ำ
│   ├── ui/
│   │   ├── Button.tsx
│   │   ├── Card.tsx
│   │   └── Input.tsx
│   ├── RolePill.tsx          # ปุ่มสลับบทบาท นักศึกษา/อาจารย์
│   └── ATCodeCard.tsx        # การ์ดเมนู AT-Code
│
├── hooks/                    # Custom hooks
│   ├── useAuth.ts            # ตรวจสอบสถานะล็อกอิน (Zustand)
│   └── useRole.ts            # ตรวจสอบบทบาท user
│
├── services/                 # API Service layers
│   ├── api.ts                # Axios instance + interceptors
│   ├── auth.ts               # Login APIs (student / teacher / at-code)
│   ├── atcode.ts             # AT-Code APIs (print, summary, categories)
│   └── attendance.ts         # Check-in APIs
│
├── store/                    # State management (Zustand)
│   └── authStore.ts          # เก็บ token, studentId, role ใน localStorage
│
├── types/                    # TypeScript type definitions
│   └── index.ts              # User, Course, Grade, ActivityTranscript, ฯลฯ
│
├── utils/                    # Utility functions
│   ├── constants.ts          # สีแบรนด์ RMUTP, Endpoint API
│   ├── format.ts             # วันที่, สกุลเงิน, คำนวณ GPA
│   └── validation.ts         # Zod schemas สำหรับฟอร์ม
│
└── assets/                   # วางรูปภาพและฟอนต์ที่นี่
    ├── images/
    │   ├── icon.png
    │   ├── splash.png
    │   ├── adaptive-icon.png
    │   └── favicon.png
    └── fonts/
        ├── Kanit-Regular.ttf
        └── Kanit-Bold.ttf
```

---

## 5. สีและแบรนด์ (ดึงจากเว็บ rmutp.ac.th)

| ชื่อสี | Hex | การใช้งาน |
|--------|-----|------------|
| ม่วงเข้ม | `#420671` | ปุ่มหลัก, AppBar, footer |
| ม่วงหลัก | `#4D287B` | Widgets, โครงสร้างหลัก |
| ม่วง hover | `#652D91` | เมนู, ปุ่มรอง |
| ม่วงสว่าง | `#7632AB` | accent สว่าง |
| ทอง | `#F6DC04` | accent หลัก, ปุ่มสำคัญ |
| ครีมทอง | `#F7E7BB` | พื้นอ่อน, highlight |
| ส้มทอง | `#FFA242` | accent เสริม |
| พื้นแอป | `#F5F3FA` | Background หลัก |
| ฟอนต์ | **Kanit** | ฟอนต์หลักทั้งแอป |

---

## 6. ติดตั้งและรัน (บน Windows)

### ขั้นตอนที่ 1 — ติดตั้ง dependencies

```powershell
# เข้าโฟลเดอร์โปรเจกต์
Set-Location "C:\data\My data\จบชีวิต\APP"

# ติดตั้ง packages
npm install
```

### ขั้นตอนที่ 2 — รันแอป

```powershell
# รันบน Android (ผ่าน Expo Go หรือ Android Emulator)
npm run android

# หรือรันแล้วสแกน QR ด้วยแอป Expo Go บนมือถือ
npx expo start

# รันบนเว็บ (สำหรับทดสอบด่วน)
npm run web
```

> หมายเหตุ: iOS Simulator ใช้บน Windows ไม่ได้ ให้ทดสอบ iOS ด้วย iPhone จริงผ่านแอป **Expo Go** จาก App Store

---

## 6.1 การแก้ปัญหา `npm install` ล้มเหลว (Dependency Conflict)

### อาการที่พบ
รัน `npm install` แล้วขึ้น error เช่น:

```
npm error ERESOLVE unable to resolve dependency tree
npm error Could not resolve dependency:
npm error peer eslint@"^8.12.2" from eslint-config-expo@5.1.3
npm error code EARTARGET No matching version found for @types/react-native@^0.74.0
```

### สาเหตุ
1. `eslint-config-expo@5.1.3` ต้องการ `eslint@^8.12.2` เป็น peer dependency แต่เวอร์ชันในโปรเจกต์ชนกัน
2. `@types/react-native@^0.74.0` ไม่มีเวอร์ชันนี้ใน registry npm จึงติดตั้งไม่ได้

### วิธีแก้ไข (แก้ใน `package.json`)
ลบ dependency ที่ชนกันออก:

- ลบ `"@types/react-native": "^0.74.0"` (เวอร์ชันไม่มีจริง)
- ลบ `"eslint": "^8.57.0"` และ `"eslint-config-expo": "^5.0.0"` (ชนกัน)
- ลบ script `"lint": "eslint ."` (ไม่จำเป็นสำหรับโปรเจกต์นี้)

หลังแก้ไขแล้วรันใหม่:

```powershell
Set-Location "C:\data\My data\จบชีวิต\APP"
npm install
```

หรือถ้ายังติดปัญหา ให้ลองใช้ `--legacy-peer-deps`:

```powershell
npm install --legacy-peer-deps
```

---

## 7. Build และส่ง store ด้วย EAS Build

ติดตั้ง EAS CLI ก่อนครั้งแรก:

```powershell
npm install -g eas-cli
eas login
```

### Build Android

```powershell
npm run eas:android
# หรือพิมพ์เต็ม: eas build -p android --profile preview
```

### Build iOS (รันผ่านคลาวด์ EAS Build เนื่องจากอยู่บน Windows)

```powershell
npm run eas:ios
# หรือพิมพ์เต็ม: eas build -p ios --profile production
```

### Submit ไป store

```powershell
npm run eas:submit:android   # ส่ง Google Play
npm run eas:submit:ios       # ส่ง App Store
```

---

## 8. ไฟล์ตั้งค่าสำคัญ

### `eas.json`
กำหนดโปรไฟล์ build สำหรับ development, preview, production ทั้ง Android และ iOS

### `app.json`
กำหนดชื่อแอป, bundle identifier (`th.ac.rmutp.campus`), เวอร์ชัน, รูปภาพ splash/icon, สีพื้นหลัง, และ permissions ของกล้องสำหรับสแกน QR

### `tsconfig.json`
ตั้งค่า TypeScript strict mode และ path aliases (`@/*`, `@components/*`, `@services/*`, ฯลฯ)

---

## 9. ขั้นตอนต่อไปที่แนะนำ

1. **ใส่รูปภาพและฟอนต์** — วางไฟล์ใน `assets/images/` และ `assets/fonts/` ตามที่ระบุใน `app.json`
2. **เชื่อมต่อ API จริง** — แก้ไข `services/api.ts` ให้ชี้ไปยัง backend Node.js + Express + PostgreSQL ของคุณ
3. **ทดสอบบน Android** — รัน `npm run android` และตรวจสอบทุกหน้าจอ
4. **สร้าง iOS build** — ใช้ `eas build -p ios` ผ่านคลาวด์
5. **สมัคร Developer Account** — Apple Developer (~$99/ปี) และ Google Play Console ($25 ครั้งเดียว) ก่อนส่งแอปไป store

---

## 10. หมายเหตุเพิ่มเติม

- โปรเจกต์นี้ใช้ **Expo Router** สำหรับการนำทางแบบไฟล์ (file-based routing)
- จัดการสถานะด้วย **Zustand** (เก็บ auth token ใน localStorage ผ่าน persist middleware)
- ตรวจสอบฟอร์มด้วย **Zod + React Hook Form**
- เรียก API ด้วย **Axios** พร้อม interceptors สำหรับการแนบ token และจัดการ 401 Unauthorized
- หากต้องการใช้กล้องสแกน QR จริง ให้ใช้ `expo-camera` (อยู่ใน dependencies แล้ว)

---

สร้างขึ้นสำหรับโปรเจกต์วิศวกรรมคอมพิวเตอร์ มทร.พระนคร | พร้อมนำไปพัฒนาต่อเป็นแอปจริงได้ทันที
