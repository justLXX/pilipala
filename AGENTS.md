# AGENTS.md

Quick reference for agents working in this Flutter codebase.

## Critical Commands

```bash
flutter pub get                              # Install dependencies
flutter packages pub run build_runner build  # Regenerate Hive adapters (required after @HiveType changes)
flutter analyze                              # Lint check
flutter test                                 # Run all tests
flutter test test/unit/repository/video_repository_test.dart  # Single test file
```

## Build Commands

```bash
flutter build apk --release --split-per-abi   # Android (CI pattern)
flutter build ios --release --no-codesign     # iOS
```

## Architecture

All modules use `lib/features/<name>/` with `data/`, `domain/`, `presentation/` subdirs. The old `lib/pages/` has been fully removed.

## Non-Obvious Conventions

1. **Toast messages**: Use `flutter_smart_dialog` (e.g., `SmartDialog.showToast()`), NOT `ScaffoldMessenger`
2. **Two DI systems coexist**:
   - **Route-level**: `Bindings` classes in `lib/router/bindings.dart` register Repository/UseCase/Controller via `Get.lazyPut()` per route
   - **App-level**: `DependencyInjection.init()` in `lib/core/di/dependency_injection.dart` registers singletons at startup (called in `main.dart`)
3. **API responses**: Bilibili format `{'code': 0, 'data': ..., 'message': '0'}` — check `code == 0` for success
4. **Chinese-only**: All UI strings and comments are in Chinese (zh_CN)
5. **Hand-parsed models**: No JSON code generation — models are manually parsed in `lib/models/`
6. **Hive adapters**: After adding `@HiveType` annotations, you MUST run `build_runner` to regenerate
7. **Storage class name**: `GStrorage` (note: typo is intentional, do not rename)

## Migration Status (2026-06-19)

| Status | Modules | Notes |
|--------|---------|-------|
| ✅ 100% complete | home, video, search, user, media, dynamics, rank, login, about, blacklist, bangumi, html, opus, read, webview, live, message, setting, main | Full 3-layer architecture (data/domain/presentation), routes registered, bindings configured |
| ✅ Deleted (2026-06-19) | bangumi, home, hot, live, rcmd, search, search_panel, search_result, video, webview | `lib/pages/` fully deleted. All references were only in comments. |

### Verification Notes

- **19/19 modules** have complete 3-layer architecture with route bindings
- **0 modules** only have presentation layer (migration complete!)
- **0 active references** to `lib/pages/` in codebase (only in doc comments)
- `lib/router/app_pages.dart` fully migrated to `lib/features/` imports
- `lib/pages/` directory confirmed deleted

### Analyze Status (2026-06-19)

- **0 errors**
- **0 warnings** ✅ (all 25 fixed)
- **~289 info** items (deprecation warnings from Flutter SDK updates, e.g. `withOpacity` → `withValues`)

### Next Steps

1. **Upgrade deprecated APIs** — `withOpacity` → `withValues`, `MaterialStateProperty` → `WidgetStateProperty` (~289 info)
2. **Add unit tests** for completed modules
3. **Clean up `avoid_print`** — replace `print()` with proper logging (~10 info)

## Key Entry Points

| Area | Path |
|------|------|
| App entry | `lib/main.dart` |
| HTTP client | `lib/http/init.dart` (Request singleton) |
| API endpoints | `lib/http/api.dart` |
| Router | `lib/router/app_pages.dart` |
| Bindings (route DI) | `lib/router/bindings.dart` |
| DI (app-level) | `lib/core/di/dependency_injection.dart` |
| Storage | `lib/utils/storage.dart` (GStrorage class) |
| WBI signing | `lib/utils/wbi_sign.dart` |
| Video player | `lib/plugin/pl_player/` |
| Main navigation | `lib/features/main/presentation/main_page.dart` |

## Testing

- Tests live in `test/unit/repository/` and `test/helpers/`
- Use `TestApiClient` pattern (manual mock, not mockito) — see `test/helpers/test_data_factory.dart`
- Integration tests require a running emulator/device

## Git Workflow

- Beta CI triggers on pushes to `x-main` branch
- Version format: `X.Y.Z+N` in `pubspec.yaml` (e.g., `1.0.28+1028`)
- Beta builds append `-beta.N` suffix automatically
