# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

PiliPala is a third-party Bilibili client built with Flutter. It targets mobile platforms (Android/iOS) and uses Bilibili's web/app APIs (documented at [bilibili-API-collect](https://github.com/SocialSisterYi/bilibili-API-collect)). The app is Chinese-language only (locale: zh_CN).

## Build & Run Commands

```bash
# Install dependencies
flutter pub get

# Run the app (debug)
flutter run

# Build Android APK (split per ABI, as used in CI)
flutter build apk --target-platform android-arm64 --split-per-abi

# Build Android APK (universal)
flutter build apk --release

# Build iOS (no codesign, for archive)
flutter build ios --release --no-codesign

# Run code generation (Hive adapters)
flutter packages pub run build_runner build

# Analyze code
flutter analyze

# Run tests
flutter test

# Run a single test file
flutter test test/widget_test.dart
```

Flutter version pinned at **3.41.9** (via FVM). Dart SDK: `>=3.0.0 <4.0.0`.

## Architecture

### State Management: GetX

The app uses **GetX** for state management, routing, and dependency injection.

- **Controllers** extend `GetxController` (often with `GetTickerProviderStateMixin`). Reactive state uses `.obs` and `Rx` types.
- **Views** are in `view.dart` files, controllers in `controller.dart`. Each page directory exports both via `index.dart`.
- **Bindings**: Formal GetX `Bindings` classes in `lib/router/bindings.dart` register Repository/UseCase/Controller via `Get.lazyPut()`.
- Navigation uses `GetMaterialApp` with named routes defined in `lib/router/app_pages.dart` via `CustomGetPage`.

### Feature Module Convention

Every module under `lib/features/` follows this pattern:
```
features/<module>/
  <module>.dart              # barrel file (exports layer public interfaces)
  data/
    <module>_repository.dart # Repository (wraps ApiClient calls, returns ApiResponse<T>)
  domain/
    <module>_use_cases.dart  # UseCase (wraps business logic, calls Repository)
  presentation/
    <module>_controller.dart # GetxController (injects UseCase, manages reactive state)
    <module>_page.dart       # StatelessWidget/StatefulWidget (UI rendering)
    widgets/                 # page-level sub-widgets
```

### HTTP / API Layer

- **Singleton**: `Request` class in `lib/http/init.dart` — a Dio-based singleton (`Request._internal()` factory pattern).
- **API endpoints**: Static constants in `lib/http/api.dart`. Base URLs in `lib/http/constants.dart` (`HttpString`).
- **API modules**: Domain-specific HTTP classes in `lib/http/` (e.g., `video.dart`, `live.dart`, `search.dart`, `login.dart`). Each provides static methods returning `Future<Map>` with `{'status': bool, 'data': ...}`.
- **WBI signing**: `lib/utils/wbi_sign.dart` — signs API requests requiring `w_rid`/`wts` parameters. Keys are cached daily in Hive.
- **Interceptors**: `ApiInterceptor` handles 302 redirects (extracts `access_key`), error toast display, and network status checks.
- **Cookie management**: `PersistCookieJar` with `dio_cookie_manager`. CSRF token (`bili_jct`) extracted from cookies for POST requests.

### Features Architecture

All modules are in `lib/features/<module>/` with data/domain/presentation layers:
- **data/**: Repository (API calls, data sources)
- **domain/**: UseCase (business logic)
- **presentation/**: Controller + Page + widgets

Key modules: home, video, search, user, media, dynamics, rank, login, about, blacklist, bangumi, html, opus, read, webview, live, message, setting, main

### Local Storage: Hive

`lib/utils/storage.dart` defines `GStrorage` with these Hive boxes:
- `userInfo` — login user info (with `UserInfoData` adapter)
- `localCache` — WBI keys, danmaku settings, proxy config
- `setting` — all app settings (keys in `SettingBoxKey`, `LocalCacheKey`, `VideoBoxKey`)
- `historyWord` — search history
- `video` — video player preferences

Hive adapters are registered in `GStrorage.regAdapter()`. Run `build_runner` after modifying `@HiveType` annotations.

### Video Player: media_kit + Custom Plugin

- `lib/plugin/pl_player/` — custom player wrapper around `media_kit`, with its own controller, models, and widget set.
- `lib/services/audio_handler.dart` — background audio service via `audio_service` package.
- `lib/services/service_locator.dart` — initializes audio service and session handler at app startup.

### Other Key Patterns

- **Event bus**: `lib/utils/event_bus.dart` — simple pub/sub for cross-widget events (e.g., `loginEvent`).
- **Global data cache**: `lib/utils/global_data_cache.dart` — loads settings from Hive into memory at startup.
- **Recommend filter**: `lib/utils/recommend_filter.dart` — filters recommended videos by duration/like ratio based on user settings.
- **App scheme**: `lib/utils/app_scheme.dart` — handles deep links (`bilibili://` etc.).
- **Custom route page**: `CustomGetPage` in `lib/router/app_pages.dart` wraps `GetPage` with `Transition.native` and optional fullscreen dialog mode.

### Main Navigation

`lib/features/main/presentation/main_page.dart` — bottom navigation with 4 tabs: Home (推荐), Rank (排行榜), Dynamics (动态), Media (我的). Tab order is configurable via settings.

### Models

`lib/models/` — data classes for API responses. Common enum/config models in `lib/models/common/` (tab types, theme types, color types, etc.). No code generation for JSON serialization; models are hand-parsed.

### Other Key Patterns

- **Event bus**: `lib/utils/event_bus.dart` — simple pub/sub for cross-widget events (e.g., `loginEvent`).
- **Global data cache**: `lib/utils/global_data_cache.dart` — loads settings from Hive into memory at startup.
- **Recommend filter**: `lib/utils/recommend_filter.dart` — filters recommended videos by duration/like ratio based on user settings.
- **App scheme**: `lib/utils/app_scheme.dart` — handles deep links (`bilibili://` etc.).
- **Custom route page**: `CustomGetPage` in `lib/router/app_pages.dart` wraps `GetPage` with `Transition.native` and optional fullscreen dialog mode.

### Plugins

`lib/plugin/` contains reusable UI plugins:
- `pl_player/` — video player
- `pl_gallery/` — image gallery
- `pl_popup/` — popup menus
- `pl_socket/` — WebSocket (for live danmaku)

## Key Conventions

- Language: UI strings and comments are in **Chinese**.
- The app uses `flutter_smart_dialog` for toasts (not `ScaffoldMessenger`).
- Error handling in HTTP layer: DioException is caught and converted to a `Response` with `{'message': errorText}` — callers check `res.data['code'] == 0` for success.
- API responses follow Bilibili's convention: `{'code': 0, 'data': ..., 'message': '0'}`.
- The `Request` singleton's `dio` instance is shared globally; base URL can be switched between `apiBaseUrl` and `bangumiBaseUrl` (for 港澳台 mode).
