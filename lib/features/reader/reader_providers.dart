// lib/features/reader/reader_providers.dart
// Law Briefly — Reader Feature Riverpod Providers
// Navigation | Bookmarks | Case Laws | Progress

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';
import '../../core/services/bookmark_service.dart';
import '../../data/models/legal_models.dart';
import 'reader_content.dart';
import 'reader_navigation_controller.dart';
import 'reader_bookmark_controller.dart';
import 'case_law_resolver.dart';

// ─────────────────────────────────────────────
// MARK: — READER SESSION STATE
// Holds the list of content items for the current reading session.
// Set before navigating to the reader screen.
// ─────────────────────────────────────────────

/// Current items loaded in the reader (chapter's sections or part's articles).
final readerItemsProvider =
    StateProvider<List<ReaderContent>>((ref) => const []);

/// Initial content ID to open when the reader loads.
final readerInitialContentIdProvider =
    StateProvider<String?>((ref) => null);

/// Source identifier (e.g., actId or partId) for the current session.
final readerSourceIdProvider =
    StateProvider<String?>((ref) => null);

// ─────────────────────────────────────────────
// MARK: — READER NAVIGATION
// Auto-disposed when no longer in use.
// ─────────────────────────────────────────────

/// Navigation controller for the current reader session.
/// Responds to readerItemsProvider changes.
final readerNavigationProvider =
    ChangeNotifierProvider.autoDispose<ReaderNavigationController>((ref) {
  final items     = ref.watch(readerItemsProvider);
  final initialId = ref.read(readerInitialContentIdProvider);

  final controller = ReaderNavigationController(
    items:     items,
    initialId: initialId,
  );

  ref.onDispose(controller.dispose);
  return controller;
});

/// The currently visible ReaderContent (null when list is empty).
final currentReaderContentProvider = Provider.autoDispose<ReaderContent?>(
  (ref) {
    final nav = ref.watch(readerNavigationProvider);
    return nav.currentContent();
  },
);

/// Navigation progress (0.0 – 1.0) through the current section list.
final readerProgressFractionProvider = Provider.autoDispose<double>((ref) {
  final nav = ref.watch(readerNavigationProvider);
  return nav.progress;
});

// ─────────────────────────────────────────────
// MARK: — READER BOOKMARK CONTROLLER
// ─────────────────────────────────────────────

/// Bookmark controller for the reader screen.
final readerBookmarkControllerProvider =
    ChangeNotifierProvider.autoDispose<ReaderBookmarkController>((ref) {
  final bookmarkService = ref.watch(bookmarkServiceProvider);
  final controller = ReaderBookmarkController(service: bookmarkService);
  ref.onDispose(controller.dispose);
  return controller;
});

/// Convenience: whether the current content is bookmarked.
final currentContentBookmarkedProvider =
    Provider.autoDispose<bool>((ref) {
  final ctrl = ref.watch(readerBookmarkControllerProvider);
  return ctrl.isBookmarked;
});

// ─────────────────────────────────────────────
// MARK: — CASE LAW RESOLVER
// ─────────────────────────────────────────────

/// Resolver that maps caseLawIds → CaseLaw objects.
/// Auto-disposed; each reader session gets a fresh cache.
final caseLawResolverProvider =
    Provider.autoDispose<CaseLawResolver>((ref) {
  final repository = ref.watch(legalRepositoryProvider);
  final resolver   = CaseLawResolver(repository);
  ref.onDispose(resolver.clearCache);
  return resolver;
});

/// Resolves case laws for a list of IDs.
/// Family key: comma-joined IDs (stable string).
final resolvedCaseLawsProvider =
    FutureProvider.autoDispose.family<List<CaseLaw>, List<String>>(
  (ref, ids) async {
    if (ids.isEmpty) return const [];
    final resolver = ref.watch(caseLawResolverProvider);
    return resolver.resolveCaseLaws(ids);
  },
);

/// Resolves case laws for the CURRENT content in the reader.
final currentContentCaseLawsProvider =
    FutureProvider.autoDispose<List<CaseLaw>>((ref) async {
  final content  = ref.watch(currentReaderContentProvider);
  if (content == null || content.caseLawIds.isEmpty) return const [];
  final resolver = ref.watch(caseLawResolverProvider);
  return resolver.resolveCaseLaws(content.caseLawIds);
});

// ─────────────────────────────────────────────
// MARK: — READER PROGRESS (Future integration)
// ─────────────────────────────────────────────

/// Saved progress snapshot for the currently loaded content.
final currentContentProgressProvider =
    FutureProvider.autoDispose((ref) async {
  final content  = ref.watch(currentReaderContentProvider);
  if (content == null) return null;
  final service  = ref.watch(readerProgressServiceProvider);
  return service.getProgress(content.id);
});

// ─────────────────────────────────────────────
// MARK: — SEARCH WITHIN READER
// ─────────────────────────────────────────────

/// Search query within the reader's content list.
final readerSearchQueryProvider =
    StateProvider.autoDispose<String>((ref) => '');

/// Items filtered by the reader search query.
final readerFilteredItemsProvider =
    Provider.autoDispose<List<ReaderContent>>((ref) {
  final items = ref.watch(readerItemsProvider);
  final query = ref.watch(readerSearchQueryProvider).trim().toLowerCase();

  if (query.isEmpty) return items;
  return items.where((c) =>
      c.title.toLowerCase().contains(query) ||
      c.number.toLowerCase().contains(query) ||
      c.content.any((b) => b.text.toLowerCase().contains(query))).toList();
});