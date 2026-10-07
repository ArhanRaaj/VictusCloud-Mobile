# VictusCloud Mobile App — Production Documentation & Setup Guide

A production-quality Flutter mobile companion application for **VictusCloud** (`victuscloud.com`, `control.victuscloud.com`, `billing.victuscloud.com`).

---

## 1. Architecture & Design System

### Strict Monochrome Aesthetic
* **Colors**: Pure Pitch Black (`#000000`), Near-Black Surfaces (`#0A0A0A`, `#111111`, `#1A1A1A`), Borders (`#262626`), Muted Secondary Text (`#8A8A8A`), Primary Text & Accents (`#FFFFFF`). Zero saturated accent colors in the UI chrome.
* **Status Representations**: Rendered without color — filled white dots for *Running*, hollow circular rings for *Offline*, pulsing animated dots for *Starting*, and monochrome icons for *Error* / *Installing* / *Suspended*.
* **Typography**: Clean modern sans-serif (`Inter`) with `JetBrains Mono` for console output, IP:ports, paths, and numeric badges.
* **Theme Support**: Default pure dark mode with an optional monochrome light mode persisted via `SharedPreferences`.

---

## 2. Completed Feature Matrix (Phases 1 – 5)

| Phase | Feature Module | Details |
|---|---|---|
| **Phase 1** | **Foundation, Design & Auth** | Full Material 3 monochrome theme, 13 reusable core widgets, Riverpod state management, GoRouter, Supabase authentication (Email/Password, Google & Discord OAuth), Biometric unlock (`local_auth`), secure credential storage (`flutter_secure_storage`). |
| **Phase 2** | **Dashboard & Live Console** | Greeting header, summary strip, server cards with monochrome resource progress bars, real-time WebSocket console stream (`/api/client/servers/{id}/websocket`), power controls (Start, Stop, Restart, Kill with safety dialog), command input buffer, and `fl_chart` CPU/RAM/Network live graphs. |
| **Phase 3** | **Server Management Tabs** | All 8 sub-tabs implemented: Files (directory browser, in-app file editor, compress/decompress), Databases, Schedules (cron viewer & manual trigger), Users (subuser invite & permissions), Backups (create, lock, restore, download), Network (allocations & primary toggle), Startup (environment variables), Settings (SFTP credentials & reinstall). |
| **Phase 4** | **Billing (Paymenter)** | Services management, unpaid & paid invoices list, native checkout payment sheet/URL launcher, support ticket threads with customer/agent chat replies and file attachments, server catalog store and ordering flow. |
| **Phase 5** | **Account & Push Notifications** | Account profile summary, biometric toggle, theme picker, Discord/Status/ToS external links, multi-device logout, Firebase Cloud Messaging (FCM) & local notifications service, in-app Notification Center with badge filters. |

---

## 3. Environment & Local Configuration

Copy the template environment file:
```bash
cd "victus_app"
cp .env.example .env
```

Populate `.env` with your project variables:
```env
SUPABASE_URL=https://your-supabase-project.supabase.co
SUPABASE_ANON_KEY=your-supabase-anon-key
PTERODACTYL_URL=https://control.victuscloud.com
PAYMENTER_URL=https://billing.victuscloud.com
FCM_SENDER_ID=your-fcm-sender-id
```

### Install Dependencies & Run Code Generation
```bash
# 1. Fetch Flutter dependencies
flutter pub get

# 2. Run code generator for JSON models and Envied secrets
dart run build_runner build --delete-conflicting-outputs
```

---

## 4. Required Supabase Edge Functions

To protect administrative credentials, the client mobile app **never** embeds Pterodactyl Application (admin) keys or Paymenter admin secrets. Deploy the following 5 serverless functions to your Supabase project:

### 1. `POST /functions/v1/link-panel-account`
* **Triggered**: When an existing user signs up or logs into the app who does not yet have a linked Pterodactyl account.
* **Logic**: Calls Pterodactyl Application API (`POST /api/application/users`) using the secret server-side key to provision the user account and return the initial client key.

### 2. `POST /functions/v1/get-panel-token`
* **Triggered**: Authenticated client session request.
* **Logic**: Verifies the caller's Supabase JWT and retrieves/exchanges the user's encrypted Pterodactyl Client API key from the database.

### 3. `POST /functions/v1/get-billing-token`
* **Triggered**: Authenticated client session request.
* **Logic**: Exchanges Supabase JWT for the user's corresponding Paymenter API token.

### 4. `POST /functions/v1/register-push`
* **Triggered**: App start after granting push notification permissions.
* **Logic**: Maps user ID to their FCM/APNs device registration token in `public.user_push_tokens`.

### 5. `POST /functions/v1/webhook-receiver`
* **Triggered**: Inbound webhooks from Pterodactyl or Paymenter.
* **Logic**: Sends push alerts to registered devices when:
  - Server state transitions to crash / offline
  - Backup creation finishes or fails
  - Invoices become overdue
  - Support ticket receives a staff response

---

## 5. Build & Deployment Instructions

### Android Release Build

1. Configure signing in `android/app/build.gradle`:
```groovy
signingConfigs {
    release {
        storeFile file(System.getenv("KEYSTORE_PATH") ?: "keystore.jks")
        storePassword System.getenv("KEYSTORE_PASSWORD")
        keyAlias System.getenv("KEY_ALIAS")
        keyPassword System.getenv("KEY_PASSWORD")
    }
}
```

2. Generate Android Release App Bundle (Google Play) or APK:
```bash
# Standalone universal APK:
flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols

# App Bundle for Google Play Console:
flutter build appbundle --release --obfuscate --split-debug-info=build/app/outputs/symbols
```
The output file will be located at:
`build/app/outputs/flutter-apk/app-release.apk`

---

### iOS Release Build

1. Ensure CocoaPods are installed and Pods are up-to-date:
```bash
cd ios
pod install
cd ..
```

2. Build iOS Archive:
```bash
flutter build ipa --release --obfuscate --split-debug-info=build/ios/symbols
```

3. Open Xcode (`ios/Runner.xcworkspace`), select your Apple Developer Team under **Signing & Capabilities**, and export to App Store Connect / TestFlight.
