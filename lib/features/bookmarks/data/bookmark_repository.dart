// lib/features/bookmarks/data/bookmark_repository.dart
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import '../../../../core/database/isar_database_service.dart';
import 'models/bookmark_model.dart';

// ─────────────────────────────────────────────
// MARK: — EXCEPTION
// ─────────────────────────────────────────────

class BookmarkRepositoryException implements Exception {
  final String  message;
  final Object? cause;
  const BookmarkRepositoryException({required this.message, this.cause});
  @override
  String toString() => 'BookmarkRepositoryException: $message'
      '${cause != null ? " — $cause" : ""}';
}

// ─────────────────────────────────────────────
// MARK: — ABSTRACT CONTRACT
// ─────────────────────────────────────────────

abstract class BookmarkRepository {
  Future<void>               addBookmark(BookmarkModel bookmark);
  Future<void>               removeBookmark(String contentId);
  Future<bool>               isBookmarked(String contentId);
  Future<BookmarkModel?>     getBookmark(String contentId);
  Future<List<BookmarkModel>> getAllBookmarks();
  Future<List<BookmarkModel>> getFavoriteBookmarks();
  Future<void>               clearBookmarks();
}

// ─────────────────────────────────────────────
// MARK: — IMPLEMENTATION
// ─────────────────────────────────────────────

class BookmarkRepositoryImpl implements BookmarkRepository {
  final IsarDatabaseService _dbService;

  static const String _tag = 'BookmarkRepositoryImpl';

  BookmarkRepositoryImpl({IsarDatabaseService? dbService})
      : _dbService = dbService ?? IsarDatabaseService.instance;

  Future<Isar> get _db => _dbService.getDatabase();

  // ── ADD ──────────────────────────────────────

  @override
  Future<void> addBookmark(BookmarkModel bookmark) async {
    try {
      final db = await _db;
      await db.writeTxn(() => db.bookmarkModels.put(bookmark));
      debugPrint('[$_tag] Added bookmark: ${bookmark.contentId}');
    } catch (e) {
      debugPrint('[$_tag] addBookmark error: $e');
      throw BookmarkRepositoryException(message: 'Failed to add bookmark.', cause: e);
    }
  }

  // ── REMOVE ───────────────────────────────────

  @override
  Future<void> removeBookmark(String contentId) async {
    try {
      final db       = await _db;
      final existing = await db.bookmarkModels
          .where()
          .contentIdEqualTo(contentId)
          .findFirst();

      if (existing == null) {
        debugPrint('[$_tag] removeBookmark: not found ($contentId)');
        return;
      }

      await db.writeTxn(() => db.bookmarkModels.delete(existing.id));
      debugPrint('[$_tag] Removed bookmark: $contentId');
    } catch (e) {
      debugPrint('[$_tag] removeBookmark error: $e');
      throw BookmarkRepositoryException(message: 'Failed to remove bookmark.', cause: e);
    }
  }

  // ── IS BOOKMARKED ─────────────────────────────

  @override
  Future<bool> isBookmarked(String contentId) async {
    try {
      final db = await _db;
      return await db.bookmarkModels
          .where()
          .contentIdEqualTo(contentId)
          .count() > 0;
    } catch (e) {
      debugPrint('[$_tag] isBookmarked error: $e');
      return false;
    }
  }

  // ── GET ───────────────────────────────────────

  @override
  Future<BookmarkModel?> getBookmark(String contentId) async {
    try {
      final db = await _db;
      return await db.bookmarkModels
          .where()
          .contentIdEqualTo(contentId)
          .findFirst();
    } catch (e) {
      debugPrint('[$_tag] getBookmark error: $e');
      return null;
    }
  }

  // ── GET ALL ───────────────────────────────────

  @override
  Future<List<BookmarkModel>> getAllBookmarks() async {
    try {
      final db = await _db;
      return await db.bookmarkModels
          .where()
          .sortByCreatedAtDesc()
          .findAll();
    } catch (e) {
      debugPrint('[$_tag] getAllBookmarks error: $e');
      throw BookmarkRepositoryException(message: 'Failed to fetch bookmarks.', cause: e);
    }
  }

  // ── GET FAVORITES ─────────────────────────────

  @override
  Future<List<BookmarkModel>> getFavoriteBookmarks() async {
    try {
      final db = await _db;
      return await db.bookmarkModels
          .filter()
          .isFavoriteEqualTo(true)
          .sortByCreatedAtDesc()
          .findAll();
    } catch (e) {
      debugPrint('[$_tag] getFavoriteBookmarks error: $e');
      throw BookmarkRepositoryException(message: 'Failed to fetch favourites.', cause: e);
    }
  }

  // ── CLEAR ────────────────────────────────────

  @override
  Future<void> clearBookmarks() async {
    try {
      final db = await _db;
      await db.writeTxn(() => db.bookmarkModels.clear());
      debugPrint('[$_tag] All bookmarks cleared.');
    } catch (e) {
      debugPrint('[$_tag] clearBookmarks error: $e');
      throw BookmarkRepositoryException(message: 'Failed to clear bookmarks.', cause: e);
    }
  }
}