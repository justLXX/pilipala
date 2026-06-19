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

## Architecture: Two Parallel Structures

The codebase is **actively migrating** from `lib/pages/` to `lib/features/`. Both exist simultaneously.

- **New modules** → `lib/features/<name>/` with `data/`, `domain/`, `presentation/` subdirs
- **Legacy modules** → `lib/pages/<name>/` with `controller.dart`, `view.dart`, `widgets/`
- Check `lib/features/` first for a module before falling back to `lib/pages/`

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

Updated based on actual code inspection.

| Status | Modules | Notes |
|--------|---------|-------|
| ✅ 100% complete | home, video, search, user, media, dynamics, rank, login, about, blacklist, bangumi, html, opus, read, webview, live, message, setting, main | Full 3-layer architecture (data/domain/presentation), routes registered, bindings configured |
| 🗑️ Ready for deletion | bangumi, home, hot, live, rcmd, search, search_panel, search_result, video, webview | Legacy modules in `lib/pages/` — zero code references remain (only mentioned in comments). Safe to delete. |

### Verification Notes

- **19/19 modules** have complete 3-layer architecture with route bindings
- **0 modules** only have presentation layer (migration complete!)
- **0 active references** to `lib/pages/` in codebase (only in doc comments)
- `lib/router/app_pages.dart` fully migrated to `lib/features/` imports

### Analyze Status (2026-06-19)

- **0 errors**
- **26 warnings** (all minor: unused variables/imports, wrong `@override` annotations)
- **~285 info** items (deprecation warnings from Flutter SDK updates, e.g. `withOpacity` → `withValues`)

### Next Steps

1. **Delete `lib/pages/`** — safe to remove, no active references
2. **Fix 26 warnings** — mostly unused imports/variables in video feature and intro_page.dart `@override` fixes
3. **Add unit tests** for completed modules
4. **Upgrade deprecated APIs** — `withOpacity` → `withValues`, `MaterialStateProperty` → `WidgetStateProperty`

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
