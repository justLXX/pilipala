import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pilipala/core/di/dependency_injection.dart';
import 'package:pilipala/router/app_pages.dart';
import 'package:pilipala/utils/storage.dart';
import 'package:pilipala/utils/global_data_cache.dart';
import 'package:media_kit/media_kit.dart';

/// Application entry point with dependency injection initialization.
///
/// This file replaces the original main.dart with a cleaner structure
/// that initializes the dependency injection before running the app.
///
/// Usage:
/// ```dart
/// void main() {
///   runApp(const PilipalaApp());
/// }
/// ```
class PilipalaApp extends StatelessWidget {
  const PilipalaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'PiliPala',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 92, 182, 123),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 92, 182, 123),
          brightness: Brightness.dark,
        ),
      ),
      getPages: Routes.getPages,
      home: const Placeholder(), // TODO: Replace with actual home page
    );
  }
}

/// Initialize application dependencies.
///
/// This should be called before running the app.
Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  // Initialize storage
  await GStrorage.init();

  // Initialize dependency injection
  DependencyInjection.init();

  // Initialize global data cache
  await GlobalDataCache().initialize();
}
