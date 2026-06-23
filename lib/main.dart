// lib/main.dart
// Law Briefly — Application Entry Point (Final Production Build)
// Material 3 | GoRouter | Riverpod | Isar | iOS 18 Liquid Glass

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app_router.dart';
import 'core/database/isar_database_service.dart';
import 'core/theme/app_theme.dart';

// ─────────────────────────────────────────────
// MARK: — THEME MODE NOTIFIER
// Global notifier for theme toggling.
// Usage from any file:
//   import 'package:law_briefly/main.dart' show themeModeNotifier;
//   themeModeNotifier.value = ThemeMode.dark;
// ─────────────────────────────────────────────

final ValueNotifier<ThemeMode> themeModeNotifier =
    ValueNotifier<ThemeMode>(ThemeMode.system);

// ─────────────────────────────────────────────
// MARK: — ENTRY POINT
// ─────────────────────────────────────────────

Future<void> main() async {
  // Ensure Flutter engine is ready
  WidgetsFlutterBinding.ensureInitialized();

  // ── Global Flutter error handler ─────────────
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    if (kDebugMode) {
      debugPrint('══════════════════════════════════════');
      debugPrint('[FlutterError] ${details.exceptionAsString()}');
      debugPrint('[FlutterError] Stack: ${details.stack}');
      debugPrint('══════════════════════════════════════');
    }
  };

  // ── Async zone error handler ─────────────────
  await runZonedGuarded(
    () async {
      // ── Orientation: portrait only ─────────────
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      // ── Edge-to-edge rendering ─────────────────
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

      // ── Transparent system overlays ────────────
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor:                    Colors.transparent,
          statusBarBrightness:               Brightness.light,
          statusBarIconBrightness:           Brightness.dark,
          systemNavigationBarColor:          Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
          systemNavigationBarDividerColor:   Colors.transparent,
        ),
      );

      // ── Service initialisation ─────────────────
      await _initServices();

      // ── Launch app with ProviderScope ──────────
      runApp(
        ProviderScope(
          observers: kDebugMode ? [_RiverpodLogger()] : const [],
          child:     const LawBrieflyApp(),
        ),
      );
    },
    (Object error, StackTrace stack) {
      if (kDebugMode) {
        debugPrint('══════════════════════════════════════');
        debugPrint('[ZoneError] $error');
        debugPrint('[ZoneError] Stack: $stack');
        debugPrint('══════════════════════════════════════');
      }
      // Future: Report to crash analytics (Sentry / Firebase Crashlytics)
    },
  );
}

// ─────────────────────────────────────────────
// MARK: — SERVICE INITIALISATION
// ─────────────────────────────────────────────

Future<void> _initServices() async {
  // ── Isar Database ──────────────────────────────
  // Required for: Bookmarks, Notes, Reader Progress
  try {
    await IsarDatabaseService.instance.initialize(
      dbName:    'law_briefly_v1',
      inspector: kDebugMode, // Enable Isar Inspector in debug
    );
    debugPrint('[main] ✅ IsarDatabaseService ready.');
  } catch (e) {
    // Non-fatal: services fall back to in-memory storage
    debugPrint('[main] ⚠️  IsarDatabaseService failed — using in-memory fallback: $e');
  }

  // ── Future services (uncomment when ready) ─────
  // await SessionService().preload();
  // await LocalLegalRepository().warmCache();
  // await AnalyticsService.instance.initialize();
  // await RemoteConfigService.instance.initialize();
}

// ─────────────────────────────────────────────
// MARK: — ROOT APPLICATION
// ─────────────────────────────────────────────

class LawBrieflyApp extends StatelessWidget {
  const LawBrieflyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp.router(
          // ── Identity ──────────────────────────────
          title:                      'Law Briefly',
          debugShowCheckedModeBanner: false,

          // ── Theme ─────────────────────────────────
          theme:      AppTheme.lightTheme,
          darkTheme:  AppTheme.darkTheme,
          themeMode:  themeMode,

          // ── Router (GoRouter) ─────────────────────
          routerConfig: appRouter,

          // ── Locale ────────────────────────────────
          locale:           const Locale('en', 'IN'),
          supportedLocales: const [
            Locale('en', 'IN'),
            Locale('en', 'US'),
          ],

          // ── Builder ───────────────────────────────
          // Clamps text scale for comfortable legal reading.
          // Prevents accessibility overrides from breaking
          // carefully tuned reader typography.
          builder: (context, child) {
            final media = MediaQuery.of(context);
            return MediaQuery(
              data: media.copyWith(
                textScaler: media.textScaler.clamp(
                  minScaleFactor: 0.85,
                  maxScaleFactor: 1.20,
                ),
              ),
              child: child!,
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// MARK: — RIVERPOD LOGGER
// Debug-only observer for provider lifecycle logging.
// Disabled in release builds via kDebugMode check.
// ─────────────────────────────────────────────

class _RiverpodLogger extends ProviderObserver {
  const _RiverpodLogger();

  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object               error,
    StackTrace           stackTrace,
    ProviderContainer    container,
  ) {
    debugPrint(
      '[Riverpod] ❌ Provider "${provider.name ?? provider.runtimeType}" failed:\n'
      '  Error: $error',
    );
  }

  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object?              previousValue,
    Object?              newValue,
    ProviderContainer    container,
  ) {
    // Uncomment for verbose provider state logging in development:
    // debugPrint(
    //   '[Riverpod] 🔄 "${provider.name ?? provider.runtimeType}" '
    //   'updated → $newValue',
    // );
  }

  @override
  void didDisposeProvider(
    ProviderBase<Object?> provider,
    ProviderContainer     container,
  ) {
    // Uncomment for dispose tracking in development:
    // debugPrint(
    //   '[Riverpod] 🗑  "${provider.name ?? provider.runtimeType}" disposed.',
    // );
  }
}