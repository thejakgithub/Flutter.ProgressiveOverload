# Flutter.ProgressiveOverload

Progressive Overload Tracker

A new Flutter project.

## Push Notifications Setup

This project supports:

- Local notifications via flutter_local_notifications
- Push token registration via Firebase Cloud Messaging (FCM)
- Token persistence in Supabase table public.device_push_tokens

### 1) Firebase Native Config

These files should exist:

- android/app/google-services.json
- ios/Runner/GoogleService-Info.plist

Current package/bundle id is configured as:

- com.thejak.progressive

### 2) Supabase Migration

Apply the migration:

- supabase/migrations/20260523130000_create_device_push_tokens.sql

With Supabase CLI, run:

```bash
supabase db push
```

If you do not use Supabase CLI, run the SQL file in the Supabase SQL editor.

### 3) Run App With Dart Defines

Create a local env file first:

```bash
cp .env.example .env
```

Edit `.env` with your project values.

Use this format:

```env
SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co
SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
SUPABASE_REDIRECT_URL=com.thejak.progressive://auth-callback
ENABLE_FIREBASE_PUSH=true
```

Run with values loaded from `.env`:

```bash
flutter run --dart-define-from-file=.env
```

You can still run by passing values directly:

```bash
flutter run \
  --dart-define=SUPABASE_URL=YOUR_SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY \
  --dart-define=SUPABASE_REDIRECT_URL=com.thejak.progressive://auth-callback \
  --dart-define=ENABLE_FIREBASE_PUSH=true
```

In Supabase Dashboard, add this exact URL in Authentication > URL Configuration > Redirect URLs:

```text
com.thejak.progressive://auth-callback
```

### 4) Verify End-to-End Token Sync

1. Log in with a user account.
2. Open Daily Workout screen.
3. Tap Sync Push Token.
4. Confirm a row appears in public.device_push_tokens for that user.

### 5) iOS Required Console Steps

1. In Xcode Runner target, enable capabilities:
   Push Notifications, Background Modes (remote-notification).
2. In Firebase Console, upload APNs auth key/certificate for the iOS app.

Without APNs setup, iOS push delivery will not work in production.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
