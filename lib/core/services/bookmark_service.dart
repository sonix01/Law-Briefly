// lib/core/services/bookmark_service.dart
// Law Briefly — Bookmark Service
// In-Memory | Async | Reactive | Future DB-Ready

import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../data/models/legal_models.dart';

// ─────────────────────────────────────────────
// MARK: — BOOKMARK TYPE (Service Layer)
// ─────────────────────────────────────────────

enum BookmarkType {
  section,
  article;

  BookmarkContentType toContentType() => switch (this) {
        BookmarkType.section => BookmarkContentType.section,
        BookmarkType.article => BookmarkContentType.article,
      };

  static BookmarkType fromContentType(BookmarkContentType type) =>
      switch (type) {
        BookmarkContentType.section => BookmarkType.section,
        BookmarkContentType.article => BookmarkType.article,
        _ => BookmarkType.section,
      };
}

// ─────────────────────────────────────────────
// MARK: — BOOKMARK SERVICE INTERFACE
// (Swap implementation for Isar / Hive without touching callers)
// ─────────────────────────────────────────────

abstract class BookmarkRepository {
  Future<List<Bookmark>>  getBookmarks();
  Future<Bookmark?>       getBookmarkByContentId(String contentId);
  Future<void>            saveBookmark(Bookmark bookmark);
  Future<void>            deleteBookmark(String bookmarkId);
  Future<bool>            existsByContentId(String contentId);
  Stream<List<Bookmark>>  watchBookmarks();
  Future<void>            clear();
}

// ─────────────────────────────────────────────
// MARK: — IN-MEMORY BOOKMARK REPOSITORY
// (Replace with IsarBookmarkRepository in production)
// ─────────────────────────────────────────────

class _InMemoryBookmarkRepository implements BookmarkRepository {
  final List<Bookmark> _store = [];
  final StreamController<List<Bookmark>> _streamCtrl =
      StreamController<List<Bookmark>>.broadcast();

  void _notify() => _streamCtrl.add(List.unmodifiable(_store));

  @override
  Future<List<Bookmark>> getBookmarks() async {
    await _delay();
    return List.unmodifiable(_store);
  }

  @override
  Future<Bookmark?> getBookmarkByContentId(String contentId) async {
    await _delay();
    try {
      return _store.firstWhere((b) => b.linkedContentId == contentId);
    } on StateError {
      return null;
    }
  }

  @override
  Future<void> saveBookmark(Bookmark bookmark) async {
    await _delay();
    final index = _store.indexWhere((b) => b.id == bookmark.id);
    if (index >= 0) {
      _store[index] = bookmark;
    } else {
      _store.add(bookmark);
    }
    _notify();
  }

  @override
  Future<void> deleteBookmark(String bookmarkId) async {
    await _delay();
    _store.removeWhere((b) => b.id == bookmarkId);
    _notify();
  }

  @override
  Future<bool> existsByContentId(String contentId) async {
    await _delay();
    return _store.any((b) => b.linkedContentId == contentId);
  }

  @override
  Stream<List<Bookmark>> watchBookmarks() => _streamCtrl.stream;

  @override
  Future<void> clear() async {
    _store.clear();
    _notify();
  }

  Future<void> _delay() => Future.delayed(Duration.zero);

  void dispose() => _streamCtrl.close();
}

// ─────────────────────────────────────────────
// MARK: — BOOKMARK SERVICE
// ─────────────────────────────────────────────

class BookmarkService {
  // ── Singleton ─────────────────────────────────
  static final BookmarkService _instance = BookmarkService._internal();
  factory BookmarkService() => _instance;
  factory BookmarkService.withRepository(BookmarkRepository repository) {
    _instance._repository = repository;
    return _instance;
  }
  BookmarkService._internal();

  // ── Repository (swap-able) ────────────────────
  BookmarkRepository _repository = _InMemoryBookmarkRepository();

  // ── ID generation ─────────────────────────────
  String _generateId(String contentId, BookmarkType type) =>
      '${type.name}_${contentId}_${DateTime.now().millisecondsSinceEpoch}';

  // ─────────────────────────────────────────────
  // MARK: — PUBLIC API
  // ─────────────────────────────────────────────

  /// Returns all saved bookmarks sorted newest first.
  Future<List<Bookmark>> getBookmarks() async {
    final bookmarks = await _repository.getBookmarks();
    return bookmarks.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Returns a live stream of all bookmarks.
  Stream<List<Bookmark>> watchBookmarks() =>
      _repository.watchBookmarks();

  /// Adds a new bookmark. Does nothing if already bookmarked.
  Future<Bookmark?> addBookmark({
    required String      contentId,
    required BookmarkType type,
    String?              displayTitle,
    String?              displaySubtitle,
    String?              sourceActId,
    String?              sourcePartId,
  }) async {
    final alreadyExists = await _repository.existsByContentId(contentId);
    if (alreadyExists) {
      debugPrint('[BookmarkService] Already bookmarked: $contentId');
      return await _repository.getBookmarkByContentId(contentId);
    }

    final bookmark = Bookmark(
      id:              _generateId(contentId, type),
      linkedContentId: contentId,
      contentType:     type.toContentType(),
      createdAt:       DateTime.now(),
      displayTitle:    displayTitle,
      displaySubtitle: displaySubtitle,
      sourceActId:     sourceActId,
      sourcePartId:    sourcePartId,
    );

    await _repository.saveBookmark(bookmark);
    debugPrint('[BookmarkService] Added bookmark: $contentId (${type.name})');
    return bookmark;
  }

  /// Removes a bookmark by its ID.
  Future<void> removeBookmark(String bookmarkId) async {
    await _repository.deleteBookmark(bookmarkId);
    debugPrint('[BookmarkService] Removed bookmark: $bookmarkId');
  }

  /// Removes a bookmark by its linked content ID.
  Future<void> removeBookmarkByContentId(String contentId) async {
    final bookmark = await _repository.getBookmarkByContentId(contentId);
    if (bookmark != null) {
      await _repository.deleteBookmark(bookmark.id);
      debugPrint('[BookmarkService] Removed bookmark for content: $contentId');
    }
  }

  /// Returns true if the content is bookmarked.
  Future<bool> isBookmarked(String contentId) async =>
      _repository.existsByContentId(contentId);

  /// Toggles bookmark for the given content.
  /// Returns true if bookmark was added, false if removed.
  Future<bool> toggleBookmark({
    required String       contentId,
    required BookmarkType type,
    String?               displayTitle,
    String?               displaySubtitle,
    String?               sourceActId,
    String?               sourcePartId,
  }) async {
    final bookmarked = await isBookmarked(contentId);

    if (bookmarked) {
      await removeBookmarkByContentId(contentId);
      return false;
    } else {
      await addBookmark(
        contentId:       contentId,
        type:            type,
        displayTitle:    displayTitle,
        displaySubtitle: displaySubtitle,
        sourceActId:     sourceActId,
        sourcePartId:    sourcePartId,
      );
      return true;
    }
  }

  /// Returns the bookmark object for a content ID, or null.
  Future<Bookmark?> getBookmarkForContent(String contentId) async =>
      _repository.getBookmarkByContentId(contentId);

  /// Returns bookmarks filtered by type.
  Future<List<Bookmark>> getBookmarksByType(BookmarkType type) async {
    final all = await getBookmarks();
    return all
        .where((b) => b.contentType == type.toContentType())
        .toList();
  }

  /// Returns total bookmark count.
  Future<int> getBookmarkCount() async {
    final bookmarks = await _repository.getBookmarks();
    return bookmarks.length;
  }

  /// Clears all bookmarks.
  Future<void> clearAll() async {
    await _repository.clear();
    debugPrint('[BookmarkService] Cleared all bookmarks.');
  }

  /// Replaces the underlying repository (e.g., swap to Isar).
  // ignore: use_setters_to_change_properties
  void setRepository(BookmarkRepository repository) {
    _repository = repository;
  }
}