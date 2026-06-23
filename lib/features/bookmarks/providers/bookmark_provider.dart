// lib/features/bookmarks/providers/bookmark_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/bookmark_local_datasource.dart';
import '../data/models/bookmark_entity.dart';

// ─────────────────────────────────────────────
// MARK: — BOOKMARK STATE
// ─────────────────────────────────────────────

class BookmarkState {
  final List<BookmarkEntity> bookmarks;
  final bool                 isLoading;
  final String?              error;

  const BookmarkState({
    this.bookmarks = const [],
    this.isLoading = false,
    this.error,
  });

  bool get hasError    => error     != null;
  bool get isEmpty     => bookmarks.isEmpty;

  BookmarkState copyWith({
    List<BookmarkEntity>? bookmarks,
    bool?                 isLoading,
    Object?               error = _sentinel,
  }) =>
      BookmarkState(
        bookmarks: bookmarks ?? this.bookmarks,
        isLoading: isLoading ?? this.isLoading,
        error:     error == _sentinel ? this.error : error as String?,
      );
}

const Object _sentinel = Object();

// ─────────────────────────────────────────────
// MARK: — DATA SOURCE PROVIDER
// ─────────────────────────────────────────────

final bookmarkDataSourceProvider = Provider<BookmarkLocalDataSource>((ref) {
  return BookmarkLocalDataSource();
});

// ─────────────────────────────────────────────
// MARK: — BOOKMARK CONTROLLER
// ─────────────────────────────────────────────

class BookmarkController extends StateNotifier<BookmarkState> {
  final BookmarkLocalDataSource _dataSource;

  static const String _tag = 'BookmarkController';

  BookmarkController(this._dataSource) : super(const BookmarkState()) {
    loadBookmarks();
  }

  // ── ADD ──────────────────────────────────────

  Future<void> addBookmark({
    required String contentId,
    required String title,
    required String source,
    required String type,
  }) async {
    if (!mounted) return;
    try {
      final entity = BookmarkEntity.create(
        contentId: contentId,
        title:     title,
        source:    source,
        type:      type,
      );
      await _dataSource.saveBookmark(entity);
      await loadBookmarks();
      debugPrint('[$_tag] Added: $contentId');
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(error: 'Failed to add bookmark.');
      debugPrint('[$_tag] addBookmark error: $e');
    }
  }

  // ── REMOVE ───────────────────────────────────

  Future<void> removeBookmark(String contentId) async {
    if (!mounted) return;
    try {
      await _dataSource.removeBookmark(contentId);
      await loadBookmarks();
      debugPrint('[$_tag] Removed: $contentId');
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(error: 'Failed to remove bookmark.');
      debugPrint('[$_tag] removeBookmark error: $e');
    }
  }

  // ── CHECK ────────────────────────────────────

  Future<bool> checkBookmark(String contentId) async {
    try {
      return await _dataSource.isBookmarked(contentId);
    } catch (e) {
      debugPrint('[$_tag] checkBookmark error: $e');
      return false;
    }
  }

  // ── LOAD ─────────────────────────────────────

  Future<List<BookmarkEntity>> loadBookmarks() async {
    if (!mounted) return const [];
    state = state.copyWith(isLoading: true, error: null);
    try {
      final bookmarks = await _dataSource.getAllBookmarks();
      if (!mounted) return bookmarks;
      state = state.copyWith(bookmarks: bookmarks, isLoading: false);
      debugPrint('[$_tag] Loaded ${bookmarks.length} bookmarks.');
      return bookmarks;
    } catch (e) {
      if (!mounted) return const [];
      state = state.copyWith(isLoading: false, error: 'Failed to load bookmarks.');
      debugPrint('[$_tag] loadBookmarks error: $e');
      return const [];
    }
  }

  // ── TOGGLE ───────────────────────────────────

  Future<bool> toggleBookmark({
    required String contentId,
    required String title,
    required String source,
    required String type,
  }) async {
    final isAlreadyBookmarked = await checkBookmark(contentId);
    if (isAlreadyBookmarked) {
      await removeBookmark(contentId);
      return false;
    } else {
      await addBookmark(
        contentId: contentId,
        title:     title,
        source:    source,
        type:      type,
      );
      return true;
    }
  }

  void clearError() => state = state.copyWith(error: null);
}

// ─────────────────────────────────────────────
// MARK: — PROVIDER
// ─────────────────────────────────────────────

final bookmarkControllerProvider =
    StateNotifierProvider<BookmarkController, BookmarkState>((ref) {
  final dataSource = ref.watch(bookmarkDataSourceProvider);
  return BookmarkController(dataSource);
});

final isBookmarkedProvider =
    FutureProvider.autoDispose.family<bool, String>((ref, contentId) async {
  final dataSource = ref.watch(bookmarkDataSourceProvider);
  return dataSource.isBookmarked(contentId);
});