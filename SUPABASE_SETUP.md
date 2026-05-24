# Supabase Setup (Progressive Overload)

คู่มือนี้สรุปขั้นตอนเชื่อม Supabase กับโปรเจกต์ Flutter นี้แบบ end-to-end

## 1) เตรียมค่าใน Supabase Dashboard

ไปที่ Settings > API แล้วคัดลอกค่า:

- Project URL
- Project API key (publishable / anon)

หมายเหตุ:

- ใช้เฉพาะ publishable/anon key ในแอปมือถือ
- ห้ามใช้ service_role key ในแอป

## 2) ตั้งค่าไฟล์ .env

แก้ไฟล์ .env ให้มีค่าแบบนี้:

```env
SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co
SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
SUPABASE_REDIRECT_URL=com.thejak.progressive://auth-callback
ENABLE_FIREBASE_PUSH=true
```

## 3) ตั้งค่า Redirect URL ใน Supabase Auth

ไปที่ Authentication > URL Configuration แล้วเพิ่ม Redirect URL:

```text
com.thejak.progressive://auth-callback
```

## 4) Push migration ขึ้นฐานข้อมูล

โปรเจกต์นี้มี migration สำหรับตาราง push token อยู่ที่:

- supabase/migrations/20260523130000_create_device_push_tokens.sql

รันคำสั่ง:

```bash
supabase link --project-ref xcmwupieuzapuzheifno
supabase db push
```

ผลลัพธ์ที่คาดหวัง:

- มีตาราง public.device_push_tokens
- มี RLS policy สำหรับผู้ใช้แต่ละคน
- มี trigger อัปเดต updated_at อัตโนมัติ

## 5) รันแอปด้วยค่า env

### ผ่าน VS Code

ใช้ Run and Debug configuration:

- Flutter: Run with .env

(โปรเจกต์ตั้งค่าไว้แล้วใน .vscode/launch.json)

### ผ่าน command line

```bash
flutter run --dart-define-from-file=.env
```

## 6) ทดสอบว่าเชื่อมสำเร็จ

1. Login ในแอป
2. ไปหน้า Daily Workout
3. กดปุ่ม Sync Push Token
4. ตรวจใน Supabase Table Editor ว่ามีข้อมูลใน public.device_push_tokens

## 7) Troubleshooting

### Access token not provided

ให้ login CLI ก่อน:

```bash
supabase login
```

### Push token ไม่เข้า table

เช็กตามลำดับ:

1. รัน migration แล้วหรือยัง (supabase db push)
2. Login ในแอปแล้วหรือยัง
3. ค่า SUPABASE_URL / SUPABASE_ANON_KEY ถูกต้องหรือไม่
4. RLS policy ถูกสร้างครบหรือไม่

### OAuth/Reset Password เด้งกลับแอปไม่ได้

เช็กว่า:

- SUPABASE_REDIRECT_URL ใน .env ตรงกับ URL ที่เพิ่มใน Supabase Auth
- Android/iOS deep link ตั้งค่าแล้ว

## 8) คำสั่งที่ใช้บ่อย

```bash
# วิเคราะห์โค้ดและทดสอบ
flutter analyze && flutter test

# ดัน migration
supabase db push

# ดู migration ที่มี
ls supabase/migrations
```
