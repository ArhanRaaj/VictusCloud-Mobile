# MJL Launcher — Mobile Minecraft: Java Edition Launcher

A PojavLauncher-style Android launcher for Minecraft Java Edition, written in Kotlin.

## Features
- **Accounts**: Microsoft premium (OAuth device-code flow → XBL → XSTS → Minecraft services) and offline/cracked accounts, stored encrypted.
- **Version installer**: full vanilla pipeline — manifest, client jar, libraries, asset index + assets.
- **Content store**: Mods, Shaders, Resource packs and Modpacks via the Modrinth API, with automatic dependency resolution for mods and `.mrpack` modpack manifest support.
- **Skin wardrobe**: import 64x32/64x64 skins, preview renderer, upload to Mojang for premium accounts.
- **APK installer**: pick any APK and launch the system installer.
- **Native bridge**: JNI layer that spawns a JVM in-process via `libjvm.so` (OpenJDK mobile port), ready for Pojav-style prebuilt libraries.

## Native runtime (required to actually run the game)
Drop these into `app/src/main/cpp/libs/<abi>/` (arm64-v8a, armeabi-v7a, x86_64):
- `libjvm.so` — OpenJDK 17 mobile port (see PojavLauncher's `jre_libraries` builds)
- `libopenal.so` — audio
- `libgl4es_114.so` or `libvirglrenderer.so` — GL translation
- LWJGL 3 Android port natives

Until these are present, launching reports "libjvm.so not found" via logcat (tag `MJL_JVM`) and the game surface is a placeholder.

## Build
```bash
./gradlew :app:assembleDebug
```
Requires Android SDK 34, NDK r26+, CMake 3.22+.

## Setup notes
- Replace `AuthManager.CLIENT_ID` with your own Azure AD app client id for Microsoft sign-in.
- Microsoft sign-in only works for accounts that own Minecraft: Java Edition; offline accounts run the game locally without server authentication.
