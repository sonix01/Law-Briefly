// lib/core/providers/app_providers.dart
// Law Briefly — Riverpod Providers
// Service Layer | Repository Layer | Controller Layer
//
// SETUP: Wrap MaterialApp.router with ProviderScope in main.dart:
//
//   void main() async {
//     ...
//     runApp(const ProviderScope(child: LawBrieflyApp()));
//   }
//
// ADD TO pubspec.yaml:
//   dependencies:
//     flutter_riverpod: ^2.5.0

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database_service.dart';
import '../services/bookmark_service.dart';
import '../services/personal_notes_service.dart';
import '../services/reader_progress_service.dart';
import '../services/pdf_progress_service.dart';
import '../services/reading_session_manager.dart';
import '../../data/repositories/legal_repository.dart';
import '../../data/repositories/json_content_loader.dart';
import '../../features/bookmarks/personal_notes_controller.dart';

// ═════════════════════════════════════════════
// MARK: — INFRASTRUCTURE PROVIDERS
// ═════════════════════════════════════════════

/// Isar database service.
/// NOTE: DatabaseService.instance.initialize() MUST be called in main()
/// before ProviderScope is mounted.
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService.instance;
});

// ═════════════════════════════════════════════
// MARK: — CONTENT PROVIDERS
// ═════════════════════════════════════════════

/// JSON asset content loader.
final jsonContentLoaderProvider = Provider<JsonContentLoader>((ref) {
  return JsonContentLoader();
});

/// Legal repository (source of truth for all legal content).
/// Returns LocalLegalRepository backed by mock data.
/// Future: switch to JsonLegalRepository using JsonContentLoader.
final legalRepositoryProvider = Provider<LegalRepository>((ref) {
  return LocalLegalRepository();
});

/// Future provider that loads all acts on first access.
final actsProvider = FutureProvider((ref) async {
  final repository = ref.watch(legalRepositoryProvider);
  return repository.getActs();
});

/// Future provider that loads all constitution parts.
final constitutionProvider = FutureProvider((ref) async {
  final repository = ref.watch(legalRepositoryProvider);
  return repository.getConstitutionParts();
});

/// Future provider that loads all case laws.
final caseLawsProvider = FutureProvider((ref) async {
  final repository = ref.watch(legalRepositoryProvider);
  return repository.getCaseLaws();
});

/// Future provider that loads academic years.
final academicYearsProvider = FutureProvider((ref) async {
  final repository = ref.watch(legalRepositoryProvider);
  return repository.getAcademicYears();
});

// ═════════════════════════════════════════════
// MARK: — SERVICE PROVIDERS
// ═════════════════════════════════════════════

/// Bookmark service — manages saved sections and articles.
final bookmarkServiceProvider = Provider<BookmarkService>((ref) {
  return BookmarkService.instance;
});

/// Personal notes service — manages user-written notes.
final personalNotesServiceProvider = Provider<PersonalNotesService>((ref) {
  return PersonalNotesService();
});

/// Reader progress service — remembers position in sections/articles.
final readerProgressServiceProvider = Provider<ReaderProgressService>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return ReaderProgressService(db: db);
});

/// PDF progress service — remembers position in academic PDFs.
final pdfProgressServiceProvider = Provider<PdfProgressService>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return PdfProgressService(db: db);
});

/// Reading session manager — coordinates all reading progress tracking.
final readingSessionManagerProvider = Provider<ReadingSessionManager>((ref) {
  final readerProgress = ref.watch(readerProgressServiceProvider);
  final pdfProgress    = ref.watch(pdfProgressServiceProvider);

  final manager = ReadingSessionManager(
    readerProgress: readerProgress,
    pdfProgress:    pdfProgress,
  );

  // Auto-dispose on provider teardown
  ref.onDispose(() => manager.dispose());

  return manager;
});

// ═════════════════════════════════════════════
// MARK: — CONTROLLER PROVIDERS
// ═════════════════════════════════════════════

/// Personal notes controller — reactive state for My Notes & Bookmarks screen.
final personalNotesControllerProvider =
    ChangeNotifierProvider<PersonalNotesController>((ref) {
  final service = ref.watch(personalNotesServiceProvider);
  final controller = PersonalNotesController(service: service);

  // Load notes immediately on first access
  controller.loadNotes();

  ref.onDispose(controller.dispose);

  return controller;
});

// ═════════════════════════════════════════════
// MARK: — BOOKMARK STATE PROVIDERS
// ═════════════════════════════════════════════

/// Stream provider for live bookmark updates.
final bookmarksStreamProvider = StreamProvider((ref) {
  final service = ref.watch(bookmarkServiceProvider);
  return service.watchBookmarks();
});

/// Future provider for the current bookmark list.
final bookmarksProvider = FutureProvider((ref) async {
  final service = ref.watch(bookmarkServiceProvider);
  return service.getBookmarks();
});

/// Family provider: checks if a specific content ID is bookmarked.
/// Usage: ref.watch(isBookmarkedProvider('section_123'))
final isBookmarkedProvider = FutureProvider.family<bool, String>(
  (ref, contentId) async {
    final service = ref.watch(bookmarkServiceProvider);
    return service.isBookmarked(contentId);
  },
);

// ═════════════════════════════════════════════
// MARK: — PROGRESS PROVIDERS
// ═════════════════════════════════════════════

/// Family provider: reading progress for a content ID.
/// Usage: ref.watch(readerProgressProvider('section_318'))
final readerProgressProvider =
    FutureProvider.family<ReaderProgressSnapshot?, String>(
  (ref, contentId) async {
    final service = ref.watch(readerProgressServiceProvider);
    return service.getProgress(contentId);
  },
);

/// Family provider: PDF progress for a PDF ID.
/// Usage: ref.watch(pdfProgressProvider('y1_s1'))
final pdfProgressProvider =
    FutureProvider.family<PdfProgressSnapshot?, String>(
  (ref, pdfId) async {
    final service = ref.watch(pdfProgressServiceProvider);
    return service.getProgress(pdfId);
  },
);

/// All recently read content (sorted by lastOpened descending).
final recentlyReadProvider = FutureProvider((ref) async {
  final service = ref.watch(readerProgressServiceProvider);
  return service.getAllProgress();
});

/// All recently opened PDFs.
final recentlyReadPdfsProvider = FutureProvider((ref) async {
  final service = ref.watch(pdfProgressServiceProvider);
  return service.getAllProgress();
});