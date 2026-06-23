// lib/core/router/app_router.dart
// Law Briefly — Navigation Architecture
// GoRouter | Production-Ready | Deep-Link Ready

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ─────────────────────────────────────────────
// MARK: — ROUTE NAMES
// ─────────────────────────────────────────────

abstract final class RouteNames {
  static const String splash          = 'splash';
  static const String login           = 'login';
  static const String register        = 'register';
  static const String home            = 'home';

  // Acts
  static const String acts            = 'acts';
  static const String actDetail       = 'act-detail';
  static const String actReader       = 'act-reader';

  // Constitution
  static const String constitution    = 'constitution';
  static const String constitutionPart = 'constitution-part';
  static const String constitutionReader = 'constitution-reader';

  // Reader (generic)
  static const String reader          = 'reader';

  // Academic Notes
  static const String academicNotes   = 'academic-notes';
  static const String academicYear    = 'academic-year';
  static const String academicSubject = 'academic-subject';
  static const String pdfReader       = 'pdf-reader';

  // Notes & Bookmarks
  static const String myNotes         = 'my-notes';
  static const String noteEditor      = 'note-editor';
  static const String bookmarks       = 'bookmarks';

  // Settings
  static const String settings        = 'settings';
  static const String profile         = 'profile';
  static const String about           = 'about';
  static const String privacy         = 'privacy';
}

// ─────────────────────────────────────────────
// MARK: — ROUTE PATHS
// ─────────────────────────────────────────────

abstract final class RoutePaths {
  static const String splash          = '/';
  static const String login           = '/login';
  static const String register        = '/register';
  static const String home            = '/home';

  // Acts
  static const String acts            = '/home/acts';
  static const String actDetail       = '/home/acts/:actId';
  static const String actReader       = '/home/acts/:actId/read/:sectionId';

  // Constitution
  static const String constitution    = '/home/constitution';
  static const String constitutionPart = '/home/constitution/:partId';
  static const String constitutionReader = '/home/constitution/:partId/read/:articleId';

  // Reader (generic fallback)
  static const String reader          = '/reader';

  // Academic Notes
  static const String academicNotes   = '/home/academic-notes';
  static const String academicYear    = '/home/academic-notes/:yearId';
  static const String academicSubject = '/home/academic-notes/:yearId/:subjectId';
  static const String pdfReader       = '/home/academic-notes/:yearId/:subjectId/pdf/:pdfId';

  // Notes & Bookmarks
  static const String myNotes         = '/home/my-notes';
  static const String noteEditor      = '/home/my-notes/editor';
  static const String bookmarks       = '/home/bookmarks';

  // Settings
  static const String settings        = '/home/settings';
  static const String profile         = '/home/settings/profile';
  static const String about           = '/home/settings/about';
  static const String privacy         = '/home/settings/privacy';
}

// ─────────────────────────────────────────────
// MARK: — ROUTE PARAMS
// ─────────────────────────────────────────────

abstract final class RouteParams {
  static const String actId       = 'actId';
  static const String sectionId   = 'sectionId';
  static const String partId      = 'partId';
  static const String articleId   = 'articleId';
  static const String yearId      = 'yearId';
  static const String subjectId   = 'subjectId';
  static const String pdfId       = 'pdfId';
  static const String noteId      = 'noteId';
}

// ─────────────────────────────────────────────
// MARK: — ROUTE EXTRA (Typed Payloads)
// ─────────────────────────────────────────────

class ActReaderArgs {
  final String actId;
  final String actName;
  final String chapterId;
  final String chapterName;
  final String sectionId;
  final String sectionTitle;

  const ActReaderArgs({
    required this.actId,
    required this.actName,
    required this.chapterId,
    required this.chapterName,
    required this.sectionId,
    required this.sectionTitle,
  });
}

class ConstitutionReaderArgs {
  final String partId;
  final String partName;
  final String articleId;
  final String articleTitle;

  const ConstitutionReaderArgs({
    required this.partId,
    required this.partName,
    required this.articleId,
    required this.articleTitle,
  });
}

class PdfReaderArgs {
  final String pdfId;
  final String title;
  final String assetPath;
  final int lastPage;

  const PdfReaderArgs({
    required this.pdfId,
    required this.title,
    required this.assetPath,
    this.lastPage = 0,
  });
}

class NoteEditorArgs {
  final String? noteId;   // null = create new
  final String? initialTitle;
  final String? initialContent;

  const NoteEditorArgs({
    this.noteId,
    this.initialTitle,
    this.initialContent,
  });
}

// ─────────────────────────────────────────────
// MARK: — PLACEHOLDER SCREENS
// ─────────────────────────────────────────────

class _PlaceholderScreen extends StatelessWidget {
  final String name;
  const _PlaceholderScreen(this.name);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(name)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.construction_rounded, size: 48),
              const SizedBox(height: 12),
              Text(
                name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Screen placeholder',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      );
}

// ─────────────────────────────────────────────
// MARK: — TRANSITION BUILDERS
// ─────────────────────────────────────────────

abstract final class _RouteTransitions {
  /// iOS-style slide from right
  static CustomTransitionPage<T> slide<T>({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) =>
      CustomTransitionPage<T>(
        key: state.pageKey,
        child: child,
        transitionDuration: const Duration(milliseconds: 320),
        reverseTransitionDuration: const Duration(milliseconds: 280),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final tween = Tween(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutCubic));

          final fadeOut = Tween<double>(begin: 1.0, end: 0.85)
              .chain(CurveTween(curve: Curves.easeOut));

          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(
              opacity: secondaryAnimation.drive(fadeOut).drive(
                Tween<double>(begin: 1.0, end: 1.0),
              ),
              child: child,
            ),
          );
        },
      );

  /// Fade transition (for modal-like screens)
  static CustomTransitionPage<T> fade<T>({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) =>
      CustomTransitionPage<T>(
        key: state.pageKey,
        child: child,
        transitionDuration: const Duration(milliseconds: 280),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ),
          child: child,
        ),
      );

  /// Scale + fade (for splash → home)
  static CustomTransitionPage<T> scaleUp<T>({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) =>
      CustomTransitionPage<T>(
        key: state.pageKey,
        child: child,
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final scale = Tween<double>(begin: 0.92, end: 1.0)
              .chain(CurveTween(curve: Curves.easeOutCubic));
          final fade = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          );
          return ScaleTransition(
            scale: animation.drive(scale),
            child: FadeTransition(opacity: fade, child: child),
          );
        },
      );
}

// ─────────────────────────────────────────────
// MARK: — APP ROUTER
// ─────────────────────────────────────────────

abstract final class AppRouter {
  // ── Auth state notifier (replace with real Riverpod/Bloc notifier) ──
  static final _authNotifier = _AuthNotifier();

  // ── Navigator Keys ──────────────────────────
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static final GlobalKey<NavigatorState> shellNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shell');

  // ── Router Instance ─────────────────────────
  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: true,   // disable in production
    refreshListenable: _authNotifier,

    // ── Redirect Logic ─────────────────────────
    redirect: (BuildContext context, GoRouterState state) {
      final isLoggedIn  = _authNotifier.isAuthenticated;
      final isGuest     = _authNotifier.isGuest;
      final hasAccess   = isLoggedIn || isGuest;

      final isSplash    = state.matchedLocation == RoutePaths.splash;
      final isAuthRoute = state.matchedLocation == RoutePaths.login ||
          state.matchedLocation == RoutePaths.register;

      // Always allow splash
      if (isSplash) return null;

      // Redirect unauthenticated users to login
      if (!hasAccess && !isAuthRoute) return RoutePaths.login;

      // Redirect authenticated users away from auth screens
      if (hasAccess && isAuthRoute) return RoutePaths.home;

      return null;
    },

    // ── Error Handler ───────────────────────────
    errorBuilder: (context, state) => _PlaceholderScreen(
      'Error: ${state.error?.message ?? 'Page not found'}',
    ),

    // ── Routes ──────────────────────────────────
    routes: [
      // ────────────────────────────────────────
      // Splash
      // ────────────────────────────────────────
      GoRoute(
        name: RouteNames.splash,
        path: RoutePaths.splash,
        pageBuilder: (context, state) => _RouteTransitions.fade(
          context: context,
          state: state,
          child: const _PlaceholderScreen('Splash Screen'),
        ),
      ),

      // ────────────────────────────────────────
      // Auth Routes
      // ────────────────────────────────────────
      GoRoute(
        name: RouteNames.login,
        path: RoutePaths.login,
        pageBuilder: (context, state) => _RouteTransitions.fade(
          context: context,
          state: state,
          child: const _PlaceholderScreen('Login Screen'),
        ),
        routes: [
          GoRoute(
            name: RouteNames.register,
            path: 'register',
            pageBuilder: (context, state) => _RouteTransitions.slide(
              context: context,
              state: state,
              child: const _PlaceholderScreen('Register Screen'),
            ),
          ),
        ],
      ),

      // ────────────────────────────────────────
      // Home Shell
      // ────────────────────────────────────────
      GoRoute(
        name: RouteNames.home,
        path: RoutePaths.home,
        pageBuilder: (context, state) => _RouteTransitions.scaleUp(
          context: context,
          state: state,
          child: const _PlaceholderScreen('Home Screen'),
        ),
        routes: [
          // ──────────────────────────────────
          // Acts Module
          // ──────────────────────────────────
          GoRoute(
            name: RouteNames.acts,
            path: 'acts',
            pageBuilder: (context, state) => _RouteTransitions.slide(
              context: context,
              state: state,
              child: const _PlaceholderScreen('Acts Screen'),
            ),
            routes: [
              GoRoute(
                name: RouteNames.actDetail,
                path: ':${RouteParams.actId}',
                pageBuilder: (context, state) {
                  final actId   = state.pathParameters[RouteParams.actId]!;
                  return _RouteTransitions.slide(
                    context: context,
                    state: state,
                    child: _PlaceholderScreen('Act Detail — $actId'),
                  );
                },
                routes: [
                  GoRoute(
                    name: RouteNames.actReader,
                    path: 'read/:${RouteParams.sectionId}',
                    pageBuilder: (context, state) {
                      final args = state.extra as ActReaderArgs?;
                      final sectionId =
                          state.pathParameters[RouteParams.sectionId]!;
                      return _RouteTransitions.slide(
                        context: context,
                        state: state,
                        child: _PlaceholderScreen(
                          'Act Reader — Section $sectionId',
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          // ──────────────────────────────────
          // Constitution Module
          // ──────────────────────────────────
          GoRoute(
            name: RouteNames.constitution,
            path: 'constitution',
            pageBuilder: (context, state) => _RouteTransitions.slide(
              context: context,
              state: state,
              child: const _PlaceholderScreen('Constitution Screen'),
            ),
            routes: [
              GoRoute(
                name: RouteNames.constitutionPart,
                path: ':${RouteParams.partId}',
                pageBuilder: (context, state) {
                  final partId =
                      state.pathParameters[RouteParams.partId]!;
                  return _RouteTransitions.slide(
                    context: context,
                    state: state,
                    child: _PlaceholderScreen(
                      'Constitution Part — $partId',
                    ),
                  );
                },
                routes: [
                  GoRoute(
                    name: RouteNames.constitutionReader,
                    path: 'read/:${RouteParams.articleId}',
                    pageBuilder: (context, state) {
                      final args = state.extra as ConstitutionReaderArgs?;
                      final articleId =
                          state.pathParameters[RouteParams.articleId]!;
                      return _RouteTransitions.slide(
                        context: context,
                        state: state,
                        child: _PlaceholderScreen(
                          'Constitution Reader — Article $articleId',
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          // ──────────────────────────────────
          // Academic Notes Module
          // ──────────────────────────────────
          GoRoute(
            name: RouteNames.academicNotes,
            path: 'academic-notes',
            pageBuilder: (context, state) => _RouteTransitions.slide(
              context: context,
              state: state,
              child: const _PlaceholderScreen('Academic Notes Screen'),
            ),
            routes: [
              GoRoute(
                name: RouteNames.academicYear,
                path: ':${RouteParams.yearId}',
                pageBuilder: (context, state) {
                  final yearId =
                      state.pathParameters[RouteParams.yearId]!;
                  return _RouteTransitions.slide(
                    context: context,
                    state: state,
                    child: _PlaceholderScreen('Year — $yearId'),
                  );
                },
                routes: [
                  GoRoute(
                    name: RouteNames.academicSubject,
                    path: ':${RouteParams.subjectId}',
                    pageBuilder: (context, state) {
                      final subjectId =
                          state.pathParameters[RouteParams.subjectId]!;
                      return _RouteTransitions.slide(
                        context: context,
                        state: state,
                        child: _PlaceholderScreen('Subject — $subjectId'),
                      );
                    },
                    routes: [
                      GoRoute(
                        name: RouteNames.pdfReader,
                        path: 'pdf/:${RouteParams.pdfId}',
                        pageBuilder: (context, state) {
                          final args = state.extra as PdfReaderArgs?;
                          final pdfId =
                              state.pathParameters[RouteParams.pdfId]!;
                          return _RouteTransitions.slide(
                            context: context,
                            state: state,
                            child: _PlaceholderScreen('PDF Reader — $pdfId'),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // ──────────────────────────────────
          // My Notes Module
          // ──────────────────────────────────
          GoRoute(
            name: RouteNames.myNotes,
            path: 'my-notes',
            pageBuilder: (context, state) => _RouteTransitions.slide(
              context: context,
              state: state,
              child: const _PlaceholderScreen('My Notes Screen'),
            ),
            routes: [
              GoRoute(
                name: RouteNames.noteEditor,
                path: 'editor',
                pageBuilder: (context, state) {
                  final args = state.extra as NoteEditorArgs?;
                  return _RouteTransitions.slide(
                    context: context,
                    state: state,
                    child: _PlaceholderScreen(
                      args?.noteId != null ? 'Edit Note' : 'New Note',
                    ),
                  );
                },
              ),
            ],
          ),

          // ──────────────────────────────────
          // Bookmarks
          // ──────────────────────────────────
          GoRoute(
            name: RouteNames.bookmarks,
            path: 'bookmarks',
            pageBuilder: (context, state) => _RouteTransitions.slide(
              context: context,
              state: state,
              child: const _PlaceholderScreen('Bookmarks Screen'),
            ),
          ),

          // ──────────────────────────────────
          // Settings Module
          // ──────────────────────────────────
          GoRoute(
            name: RouteNames.settings,
            path: 'settings',
            pageBuilder: (context, state) => _RouteTransitions.slide(
              context: context,
              state: state,
              child: const _PlaceholderScreen('Settings Screen'),
            ),
            routes: [
              GoRoute(
                name: RouteNames.profile,
                path: 'profile',
                pageBuilder: (context, state) => _RouteTransitions.slide(
                  context: context,
                  state: state,
                  child: const _PlaceholderScreen('Profile Screen'),
                ),
              ),
              GoRoute(
                name: RouteNames.about,
                path: 'about',
                pageBuilder: (context, state) => _RouteTransitions.slide(
                  context: context,
                  state: state,
                  child: const _PlaceholderScreen('About Screen'),
                ),
              ),
              GoRoute(
                name: RouteNames.privacy,
                path: 'privacy',
                pageBuilder: (context, state) => _RouteTransitions.slide(
                  context: context,
                  state: state,
                  child: const _PlaceholderScreen('Privacy Policy Screen'),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

// ─────────────────────────────────────────────
// MARK: — AUTH NOTIFIER (Stub — replace with Riverpod/Bloc)
// ─────────────────────────────────────────────

class _AuthNotifier extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isGuest        = false;

  bool get isAuthenticated => _isAuthenticated;
  bool get isGuest        => _isGuest;

  void setAuthenticated(bool value) {
    _isAuthenticated = value;
    _isGuest = false;
    notifyListeners();
  }

  void setGuest(bool value) {
    _isGuest = value;
    _isAuthenticated = false;
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    _isGuest = false;
    notifyListeners();
  }
}

// ─────────────────────────────────────────────
// MARK: — NAVIGATION EXTENSIONS
// ─────────────────────────────────────────────

extension AppNavigation on BuildContext {
  // ── Auth ──────────────────────────────────────
  void goLogin()    => goNamed(RouteNames.login);
  void goRegister() => goNamed(RouteNames.register);
  void goHome()     => goNamed(RouteNames.home);

  // ── Acts ──────────────────────────────────────
  void goActs() => goNamed(RouteNames.acts);

  void goActDetail(String actId) => goNamed(
    RouteNames.actDetail,
    pathParameters: {RouteParams.actId: actId},
  );

  void goActReader({
    required String actId,
    required String sectionId,
    required ActReaderArgs args,
  }) =>
      goNamed(
        RouteNames.actReader,
        pathParameters: {
          RouteParams.actId: actId,
          RouteParams.sectionId: sectionId,
        },
        extra: args,
      );

  // ── Constitution ──────────────────────────────
  void goConstitution() => goNamed(RouteNames.constitution);

  void goConstitutionPart(String partId) => goNamed(
    RouteNames.constitutionPart,
    pathParameters: {RouteParams.partId: partId},
  );

  void goConstitutionReader({
    required String partId,
    required String articleId,
    required ConstitutionReaderArgs args,
  }) =>
      goNamed(
        RouteNames.constitutionReader,
        pathParameters: {
          RouteParams.partId: partId,
          RouteParams.articleId: articleId,
        },
        extra: args,
      );

  // ── Academic Notes ────────────────────────────
  void goAcademicNotes() => goNamed(RouteNames.academicNotes);

  void goAcademicYear(String yearId) => goNamed(
    RouteNames.academicYear,
    pathParameters: {RouteParams.yearId: yearId},
  );

  void goAcademicSubject({
    required String yearId,
    required String subjectId,
  }) =>
      goNamed(
        RouteNames.academicSubject,
        pathParameters: {
          RouteParams.yearId: yearId,
          RouteParams.subjectId: subjectId,
        },
      );

  void goPdfReader({
    required String yearId,
    required String subjectId,
    required String pdfId,
    required PdfReaderArgs args,
  }) =>
      goNamed(
        RouteNames.pdfReader,
        pathParameters: {
          RouteParams.yearId: yearId,
          RouteParams.subjectId: subjectId,
          RouteParams.pdfId: pdfId,
        },
        extra: args,
      );

  // ── Notes & Bookmarks ─────────────────────────
  void goMyNotes()    => goNamed(RouteNames.myNotes);
  void goBookmarks()  => goNamed(RouteNames.bookmarks);

  void goNoteEditor({NoteEditorArgs? args}) => goNamed(
    RouteNames.noteEditor,
    extra: args,
  );

  // ── Settings ──────────────────────────────────
  void goSettings() => goNamed(RouteNames.settings);
  void goProfile()  => goNamed(RouteNames.profile);
  void goAbout()    => goNamed(RouteNames.about);
  void goPrivacy()  => goNamed(RouteNames.privacy);
}