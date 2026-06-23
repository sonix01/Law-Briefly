// lib/core/router/navigation_registry.dart

// ─────────────────────────────────────────────
// MARK: — NAVIGATION REGISTRY
// ─────────────────────────────────────────────

abstract final class NavigationRegistry {

  // ── ROUTE NAMES ───────────────────────────────
  static const String login          = 'login';
  static const String home           = 'home';
  static const String acts           = 'acts';
  static const String actDetail      = 'act-detail';
  static const String constitution   = 'constitution';
  static const String reader         = 'reader';
  static const String academicNotes  = 'academic-notes';
  static const String pdfReader      = 'pdf-reader';
  static const String myNotes        = 'my-notes';
  static const String noteEditor     = 'note-editor';
  static const String settings       = 'settings';
  static const String profile        = 'profile';
  static const String about          = 'about';

  // ── ROUTE PATHS ───────────────────────────────
  static const String loginPath         = '/';
  static const String homePath          = '/home';
  static const String actsPath          = '/acts';
  static const String actDetailPath     = '/acts/:actId';
  static const String constitutionPath  = '/constitution';
  static const String readerPath        = '/reader';
  static const String academicNotesPath = '/academic-notes';
  static const String pdfReaderPath     = '/pdf-reader';
  static const String myNotesPath       = '/my-notes';
  static const String noteEditorPath    = '/note-editor';
  static const String settingsPath      = '/settings';
  static const String profilePath       = '/profile';
  static const String aboutPath         = '/about';

  // ── DYNAMIC PATH BUILDERS ─────────────────────

  static String actDetailRoute(String actId) => '/acts/$actId';

  static String readerActRoute({
    required String actId,
    required String sectionId,
  }) =>
      '/reader?actId=$actId&sectionId=$sectionId';

  static String readerConstitutionRoute({
    required String partId,
    required String articleId,
  }) =>
      '/reader?partId=$partId&articleId=$articleId';

  static String pdfReaderRoute({
    required String pdfId,
    required String pdfPath,
    required String title,
  }) =>
      '/pdf-reader?pdfId=${Uri.encodeComponent(pdfId)}'
      '&pdfPath=${Uri.encodeComponent(pdfPath)}'
      '&title=${Uri.encodeComponent(title)}';

  static String noteEditorRoute({String? noteId}) =>
      noteId != null ? '/note-editor?noteId=$noteId' : '/note-editor';

  // ── QUERY PARAM KEYS ──────────────────────────

  static const String paramActId     = 'actId';
  static const String paramSectionId = 'sectionId';
  static const String paramPartId    = 'partId';
  static const String paramArticleId = 'articleId';
  static const String paramPdfId     = 'pdfId';
  static const String paramPdfPath   = 'pdfPath';
  static const String paramTitle     = 'title';
  static const String paramNoteId    = 'noteId';

  // ── ORDERED BOTTOM NAV ROUTES ─────────────────
  static const List<String> bottomNavRoutes = [
    homePath,
    actsPath,
    constitutionPath,
    myNotesPath,
  ];

  // ── AUTH ROUTES (do not require session) ──────
  static const Set<String> publicRoutes = {loginPath};

  // ── IS PUBLIC ─────────────────────────────────
  static bool isPublic(String path) => publicRoutes.contains(path);
}