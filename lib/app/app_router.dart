// lib/app/app_router.dart
// Law Briefly — Navigation Architecture (Production)
// GoRouter | All Real Screens | Session-Aware Redirect

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/splash_screen.dart';
import '../features/auth/login/login_screen.dart';
import '../features/auth/services/session_service.dart';
import '../features/home/home_screen.dart';
import '../features/acts/acts_screen.dart' show ActsScreen, ActDetailNavArgs;
import '../features/acts/act_detail_screen.dart';
import '../features/constitution/constitution_screen.dart';
import '../features/reader/reader_screen.dart';
import '../features/notes/academic_notes_screen.dart';
import '../features/pdf_reader/pdf_reader_screen.dart';
import '../features/bookmarks/my_notes_bookmarks_screen.dart';
import '../features/notes/note_editor_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/settings/about_law_briefly_screen.dart';

// ─────────────────────────────────────────────
// MARK: — TOP-LEVEL EXPORT (for MaterialApp.router)
// ─────────────────────────────────────────────

final GoRouter appRouter = AppRouter.router;

// ─────────────────────────────────────────────
// MARK: — ROUTE NAMES
// ─────────────────────────────────────────────

abstract final class RouteNames {
  static const String splash             = 'splash';
  static const String login              = 'login';
  static const String register           = 'register';
  static const String home               = 'home';

  static const String acts               = 'acts';
  static const String actDetail          = 'act-detail';
  static const String actReader          = 'act-reader';

  static const String constitution       = 'constitution';
  static const String constitutionPart   = 'constitution-part';
  static const String constitutionReader = 'constitution-reader';

  static const String reader             = 'reader';

  static const String academicNotes      = 'academic-notes';
  static const String academicYear       = 'academic-year';
  static const String academicSubject    = 'academic-subject';
  static const String pdfReader          = 'pdf-reader';

  static const String myNotes            = 'my-notes';
  static const String noteEditor         = 'note-editor';
  static const String bookmarks          = 'bookmarks';

  static const String settings           = 'settings';
  static const String profile            = 'profile';
  static const String about              = 'about';
  static const String privacy            = 'privacy';
}

// ─────────────────────────────────────────────
// MARK: — ROUTE PATHS
// ─────────────────────────────────────────────

abstract final class RoutePaths {
  static const String splash             = '/';
  static const String login              = '/login';
  static const String register           = '/register';
  static const String home               = '/home';

  static const String acts               = '/home/acts';
  static const String actDetail          = '/home/acts/:actId';
  static const String actReader          = '/home/acts/:actId/read/:sectionId';

  static const String constitution       = '/home/constitution';
  static const String constitutionPart   = '/home/constitution/:partId';
  static const String constitutionReader = '/home/constitution/:partId/read/:articleId';

  static const String reader             = '/reader';

  static const String academicNotes      = '/home/academic-notes';
  static const String academicYear       = '/home/academic-notes/:yearId';
  static const String academicSubject    = '/home/academic-notes/:yearId/:subjectId';
  static const String pdfReader          = '/home/academic-notes/:yearId/:subjectId/pdf/:pdfId';

  static const String myNotes            = '/home/my-notes';
  static const String noteEditor         = '/home/my-notes/editor';
  static const String bookmarks          = '/home/bookmarks';

  static const String settings           = '/home/settings';
  static const String profile            = '/home/settings/profile';
  static const String about              = '/home/settings/about';
  static const String privacy            = '/home/settings/privacy';
}

// ─────────────────────────────────────────────
// MARK: — ROUTE PARAMS
// ─────────────────────────────────────────────

abstract final class RouteParams {
  static const String actId     = 'actId';
  static const String sectionId = 'sectionId';
  static const String partId    = 'partId';
  static const String articleId = 'articleId';
  static const String yearId    = 'yearId';
  static const String subjectId = 'subjectId';
  static const String pdfId     = 'pdfId';
  static const String noteId    = 'noteId';
}

// ─────────────────────────────────────────────
// MARK: — TYPED EXTRA PAYLOADS
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
  final int    lastPage;

  const PdfReaderArgs({
    required this.pdfId,
    required this.title,
    required this.assetPath,
    this.lastPage = 0,
  });
}

class NoteEditorArgs {
  final String? noteId;
  final String? initialTitle;
  final String? initialContent;

  const NoteEditorArgs({
    this.noteId,
    this.initialTitle,
    this.initialContent,
  });
}

// ─────────────────────────────────────────────
// MARK: — PROFILE SCREEN PLACEHOLDER
// Remove once lib/features/settings/profile_screen.dart is created.
// ─────────────────────────────────────────────

class _ProfileScreenPlaceholder extends StatelessWidget {
  const _ProfileScreenPlaceholder();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(
          child: Text('Profile screen coming soon.',
              style: TextStyle(fontStyle: FontStyle.italic)),
        ),
      );
}

// ─────────────────────────────────────────────
// MARK: — TRANSITION BUILDERS
// ─────────────────────────────────────────────

abstract final class _Tx {
  static CustomTransitionPage<T> slide<T>({
    required BuildContext context,
    required GoRouterState state,
    required Widget        child,
  }) =>
      CustomTransitionPage<T>(
        key:                         state.pageKey,
        child:                       child,
        transitionDuration:          const Duration(milliseconds: 340),
        reverseTransitionDuration:   const Duration(milliseconds: 290),
        transitionsBuilder: (ctx, anim, secAnim, child) {
          final slide = Tween(
            begin: const Offset(1.0, 0.0), end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutCubic));
          return SlideTransition(
            position: anim.drive(slide), child: child);
        },
      );

  static CustomTransitionPage<T> fade<T>({
    required BuildContext context,
    required GoRouterState state,
    required Widget        child,
  }) =>
      CustomTransitionPage<T>(
        key:                       state.pageKey,
        child:                     child,
        transitionDuration:        const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 240),
        transitionsBuilder: (ctx, anim, _, child) => FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
          child: child,
        ),
      );

  static CustomTransitionPage<T> scaleUp<T>({
    required BuildContext context,
    required GoRouterState state,
    required Widget        child,
  }) =>
      CustomTransitionPage<T>(
        key:               state.pageKey,
        child:             child,
        transitionDuration: const Duration(milliseconds: 420),
        transitionsBuilder: (ctx, anim, _, child) {
          final scale = Tween<double>(begin: 0.92, end: 1.0)
              .chain(CurveTween(curve: Curves.easeOutCubic));
          return ScaleTransition(
            scale:   anim.drive(scale),
            child: FadeTransition(
              opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
              child:   child),
          );
        },
      );

  static CustomTransitionPage<T> slideUp<T>({
    required BuildContext context,
    required GoRouterState state,
    required Widget        child,
  }) =>
      CustomTransitionPage<T>(
        key:                       state.pageKey,
        child:                     child,
        transitionDuration:        const Duration(milliseconds: 380),
        reverseTransitionDuration: const Duration(milliseconds: 320),
        transitionsBuilder: (ctx, anim, _, child) {
          final slide = Tween(
            begin: const Offset(0, 1.0), end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutCubic));
          return SlideTransition(position: anim.drive(slide), child: child);
        },
      );
}

// ─────────────────────────────────────────────
// MARK: — AUTH NOTIFIER
// ─────────────────────────────────────────────

class _AuthNotifier extends ChangeNotifier {
  bool _initialized    = false;
  bool _isAuthenticated = false;
  bool _isGuest        = false;

  bool get isInitialized    => _initialized;
  bool get isAuthenticated  => _isAuthenticated;
  bool get isGuest          => _isGuest;
  bool get hasAccess        => _isAuthenticated || _isGuest;

  _AuthNotifier() { _init(); }

  Future<void> _init() async {
    try {
      final session = await SessionService().getSession();
      if (session?.isLoggedIn == true) {
        _isAuthenticated = true;
        _isGuest        = false;
      } else if (session?.isGuest == true) {
        _isGuest        = true;
        _isAuthenticated = false;
      }
    } catch (_) {}
    _initialized = true;
    notifyListeners();
  }

  void authenticate() {
    _isAuthenticated = true;
    _isGuest        = false;
    _initialized    = true;
    notifyListeners();
  }

  void setGuest() {
    _isGuest        = true;
    _isAuthenticated = false;
    _initialized    = true;
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    _isGuest        = false;
    notifyListeners();
  }
}

// ─────────────────────────────────────────────
// MARK: — APP ROUTER
// ─────────────────────────────────────────────

abstract final class AppRouter {
  static final _AuthNotifier authNotifier = _AuthNotifier();

  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static final GoRouter router = GoRouter(
    navigatorKey:     rootNavigatorKey,
    initialLocation:  RoutePaths.splash,
    debugLogDiagnostics: true,             // set false in release
    refreshListenable: authNotifier,

    // ── Redirect ────────────────────────────
    redirect: (BuildContext context, GoRouterState state) {
      final loc        = state.matchedLocation;
      final isSplash   = loc == RoutePaths.splash;
      final isLogin    = loc == RoutePaths.login;
      final isRegister = loc == RoutePaths.register;
      final isAuthRoute = isLogin || isRegister;

      if (isSplash) return null;
      if (!authNotifier.isInitialized) return RoutePaths.splash;
      if (!authNotifier.hasAccess && !isAuthRoute) return RoutePaths.login;
      if (authNotifier.hasAccess && isAuthRoute) return RoutePaths.home;

      return null;
    },

    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text(
        'Route error: ${state.error?.message ?? "Not found"}',
        style: const TextStyle(fontStyle: FontStyle.italic))),
    ),

    // ── Routes ──────────────────────────────
    routes: [

      // ─────────────────────────────────────
      // SPLASH
      // ─────────────────────────────────────
      GoRoute(
        name:  RouteNames.splash,
        path:  RoutePaths.splash,
        pageBuilder: (context, state) => _Tx.fade(
          context: context, state: state,
          child:   const SplashScreen(),
        ),
      ),

      // ─────────────────────────────────────
      // AUTH ROUTES
      // ─────────────────────────────────────
      GoRoute(
        name:  RouteNames.login,
        path:  RoutePaths.login,
        pageBuilder: (context, state) => _Tx.fade(
          context: context, state: state,
          child:   const LoginScreen(),
        ),
        routes: [
          GoRoute(
            name:  RouteNames.register,
            path:  'register',
            pageBuilder: (context, state) => _Tx.slide(
              context: context, state: state,
              child: const Scaffold(
                body: Center(child: Text('Registration coming soon.',
                    style: TextStyle(fontStyle: FontStyle.italic)))),
            ),
          ),
        ],
      ),

      // ─────────────────────────────────────
      // HOME
      // ─────────────────────────────────────
      GoRoute(
        name:  RouteNames.home,
        path:  RoutePaths.home,
        pageBuilder: (context, state) => _Tx.scaleUp(
          context: context, state: state,
          child:   const HomeScreen(),
        ),

        routes: [

          // ─────────────────────────────────
          // ACTS MODULE
          // ─────────────────────────────────
          GoRoute(
            name:  RouteNames.acts,
            path:  'acts',
            pageBuilder: (context, state) => _Tx.slide(
              context: context, state: state,
              child: const ActsScreen(),
            ),
            routes: [
              GoRoute(
                name: RouteNames.actDetail,
                path: ':${RouteParams.actId}',
                pageBuilder: (context, state) {
                  final actId = state.pathParameters[RouteParams.actId]!;

                  // Read actName + year sent via context.pushNamed(extra: ...)
                  final args = state.extra as ActDetailNavArgs?;

                  return _Tx.slide(
                    context: context, state: state,
                    child: ActDetailScreen(
                      actId:   actId,
                      actName: args?.actTitle ?? actId,
                      year:    args?.year ?? DateTime.now().year,
                    ),
                  );
                },
                routes: [
                  GoRoute(
                    name: RouteNames.actReader,
                    path: 'read/:${RouteParams.sectionId}',
                    pageBuilder: (context, state) {
                      final actId     = state.pathParameters[RouteParams.actId]!;
                      final sectionId = state.pathParameters[RouteParams.sectionId]!;
                      final args      = state.extra as ActReaderArgs?;
                      return _Tx.slide(
                        context: context, state: state,
                        child: ReaderScreen.actSection(
                          actId:       actId,
                          sectionId:   sectionId,
                          sourceTitle: args?.actName,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          // ─────────────────────────────────
          // CONSTITUTION MODULE
          // ─────────────────────────────────
          GoRoute(
            name:  RouteNames.constitution,
            path:  'constitution',
            pageBuilder: (context, state) => _Tx.slide(
              context: context, state: state,
              child: const ConstitutionScreen(),
            ),
            routes: [
              GoRoute(
                name: RouteNames.constitutionPart,
                path: ':${RouteParams.partId}',
                pageBuilder: (context, state) {
                  final partId = state.pathParameters[RouteParams.partId]!;
                  return _Tx.slide(
                    context: context, state: state,
                    child: ConstitutionScreen(initialPartId: partId),
                  );
                },
                routes: [
                  GoRoute(
                    name: RouteNames.constitutionReader,
                    path: 'read/:${RouteParams.articleId}',
                    pageBuilder: (context, state) {
                      final partId    = state.pathParameters[RouteParams.partId]!;
                      final articleId = state.pathParameters[RouteParams.articleId]!;
                      final args      = state.extra as ConstitutionReaderArgs?;
                      return _Tx.slide(
                        context: context, state: state,
                        child: ReaderScreen.constitutionArticle(
                          partId:      partId,
                          articleId:   articleId,
                          sourceTitle: args?.partName,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          // ─────────────────────────────────
          // ACADEMIC NOTES MODULE
          // ─────────────────────────────────
          GoRoute(
            name:  RouteNames.academicNotes,
            path:  'academic-notes',
            pageBuilder: (context, state) => _Tx.slide(
              context: context, state: state,
              child: const AcademicNotesScreen(),
            ),
            routes: [
              GoRoute(
                name: RouteNames.academicYear,
                path: ':${RouteParams.yearId}',
                redirect: (_, __) => RoutePaths.academicNotes,
                routes: [
                  GoRoute(
                    name: RouteNames.academicSubject,
                    path: ':${RouteParams.subjectId}',
                    redirect: (_, __) => RoutePaths.academicNotes,
                    routes: [
                      GoRoute(
                        name: RouteNames.pdfReader,
                        path: 'pdf/:${RouteParams.pdfId}',
                        pageBuilder: (context, state) {
                          final args = state.extra as PdfReaderArgs?;
                          final pdfId = state.pathParameters[RouteParams.pdfId]!;
                          return _Tx.slide(
                            context: context, state: state,
                            child: PdfReaderScreen(
                              pdfId:   args?.pdfId   ?? pdfId,
                              pdfPath: args?.assetPath ?? '',
                              title:   args?.title    ?? pdfId,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // ─────────────────────────────────
          // MY NOTES & BOOKMARKS MODULE
          // ─────────────────────────────────
          GoRoute(
            name:  RouteNames.myNotes,
            path:  'my-notes',
            pageBuilder: (context, state) => _Tx.slide(
              context: context, state: state,
              child: const MyNotesBookmarksScreen(),
            ),
            routes: [
              GoRoute(
                name: RouteNames.noteEditor,
                path: 'editor',
                pageBuilder: (context, state) {
                  final args = state.extra as NoteEditorArgs?;
                  return _Tx.slideUp(
                    context: context, state: state,
                    child: NoteEditorScreen(
                      existingNote: null,
                      onSave: (_, __) {
                        if (context.canPop()) context.pop();
                      },
                    ),
                  );
                },
              ),
            ],
          ),

          // ─────────────────────────────────
          // SETTINGS MODULE
          // ─────────────────────────────────
          GoRoute(
            name:  RouteNames.settings,
            path:  'settings',
            pageBuilder: (context, state) => _Tx.slide(
              context: context, state: state,
              child: const SettingsScreen(),
            ),
            routes: [
              GoRoute(
                name: RouteNames.profile,
                path: 'profile',
                pageBuilder: (context, state) => _Tx.slide(
                  context: context, state: state,
                  child: const _ProfileScreenPlaceholder(),
                ),
              ),
              GoRoute(
                name: RouteNames.about,
                path: 'about',
                pageBuilder: (context, state) => _Tx.slide(
                  context: context, state: state,
                  child: const AboutLawBrieflyScreen(),
                ),
              ),
              GoRoute(
                name: RouteNames.privacy,
                path: 'privacy',
                pageBuilder: (context, state) => _Tx.slide(
                  context: context, state: state,
                  child: const Scaffold(
                    body: Center(child: Text('Privacy Policy coming soon.',
                        style: TextStyle(fontStyle: FontStyle.italic)))),
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
// MARK: — NAVIGATION EXTENSIONS
// ─────────────────────────────────────────────

extension AppNavigation on BuildContext {

  void goLogin()     => goNamed(RouteNames.login);
  void goHome()      => goNamed(RouteNames.home);
  void goRegister()  => goNamed(RouteNames.register);

  void goActs()                      => goNamed(RouteNames.acts);
  void goActDetail(String actId)     => goNamed(RouteNames.actDetail,
      pathParameters: {RouteParams.actId: actId});
  void goActReader({
    required String actId,
    required String sectionId,
    ActReaderArgs?  args,
  }) =>
      goNamed(RouteNames.actReader,
        pathParameters: {
          RouteParams.actId:     actId,
          RouteParams.sectionId: sectionId,
        },
        extra: args);

  void goConstitution()              => goNamed(RouteNames.constitution);
  void goConstitutionPart(String partId) => goNamed(RouteNames.constitutionPart,
      pathParameters: {RouteParams.partId: partId});
  void goConstitutionReader({
    required String              partId,
    required String              articleId,
    ConstitutionReaderArgs?      args,
  }) =>
      goNamed(RouteNames.constitutionReader,
        pathParameters: {
          RouteParams.partId:    partId,
          RouteParams.articleId: articleId,
        },
        extra: args);

  void goAcademicNotes()             => goNamed(RouteNames.academicNotes);
  void goPdfReader({
    required String yearId,
    required String subjectId,
    required String pdfId,
    required PdfReaderArgs args,
  }) =>
      goNamed(RouteNames.pdfReader,
        pathParameters: {
          RouteParams.yearId:    yearId,
          RouteParams.subjectId: subjectId,
          RouteParams.pdfId:     pdfId,
        },
        extra: args);

  void goMyNotes()                   => goNamed(RouteNames.myNotes);
  void goNoteEditor({NoteEditorArgs? args}) =>
      goNamed(RouteNames.noteEditor, extra: args);

  void goSettings()  => goNamed(RouteNames.settings);
  void goProfile()   => goNamed(RouteNames.profile);
  void goAbout()     => goNamed(RouteNames.about);
  void goPrivacy()   => goNamed(RouteNames.privacy);
}