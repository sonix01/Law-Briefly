// lib/features/bookmarks/data/bookmark_local_datasource.dart
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import '../../../core/database/isar_database_service.dart';
import 'models/bookmark_entity.dart';

// ─────────────────────────────────────────────
// MARK: — EXCEPTION
// ─────────────────────────────────────────────

class BookmarkDataSourceException implements Exception {
  final String  message;
  final Object? cause;
  const BookmarkDataSourceException({required this.message, this.cause});
  @override
  String toString() => 'BookmarkDataSourceException: $message'
      '${cause != null ? " — $cause" : ""}';
}

// ─────────────────────────────────────────────
// MARK: — BOOKMARK LOCAL DATA SOURCE
// ─────────────────────────────────────────────

class BookmarkLocalDataSource {
  final IsarDatabaseService _dbService;

  static const String _tag = 'BookmarkLocalDataSource';

  BookmarkLocalDataSource({IsarDatabaseService? dbService})
      : _dbService = dbService ?? IsarDatabaseService.instance;

  Future<Isar> get _db => _dbService.getDatabase();

  // ── SAVE ─────────────────────────────────────

  Future<void> saveBookmark(BookmarkEntity bookmark) async {
    try {
      final db = await _db;
      await db.writeTxn(() => db.bookmarkEntitys.put(bookmark));
      debugPrint('[$_tag] Saved: ${bookmark.contentId}');
    } catch (e) {
      debugPrint('[$_tag] saveBookmark error: $e');
      throw BookmarkDataSourceException(
          message: 'Failed to save bookmark.', cause: e);
    }
  }

  // ── REMOVE ───────────────────────────────────

  Future<void> removeBookmark(String contentId) async {
    try {
      final db       = await _db;
      final existing = await db.bookmarkEntitys
          .where()
          .contentIdEqualTo(contentId)
          .findFirst();

      if (existing == null) {
        debugPrint('[$_tag] removeBookmark: not found ($contentId)');
        return;
      }

      await db.writeTxn(() => db.bookmarkEntitys.delete(existing.id));
      debugPrint('[$_tag] Removed: $contentId');
    } catch (e) {
      debugPrint('[$_tag] removeBookmark error: $e');
      throw BookmarkDataSourceException(
          message: 'Failed to remove bookmark.', cause: e);
    }
  }

  // ── IS BOOKMARKED ─────────────────────────────

  Future<bool> isBookmarked(String contentId) async {
    try {
      final db = await _db;
      return await db.bookmarkEntitys
          .where()
          .contentIdEqualTo(contentId)
          .count() > 0;
    } catch (e) {
      debugPrint('[$_tag] isBookmarked error: $e');
      return false;
    }
  }

  // ── GET ALL ───────────────────────────────────

  Future<List<BookmarkEntity>> getAllBookmarks() async {
    try {
      final db = await _db;
      return await db.bookmarkEntitys
          .where()
          .sortByCreatedAtDesc()
          .findAll();
    } catch (e) {
      debugPrint('[$_tag] getAllBookmarks error: $e');
      throw BookmarkDataSourceException(
          message: 'Failed to fetch bookmarks.', cause: e);
    }
  }

  // ── GET BY CONTENT ID ─────────────────────────

  Future<BookmarkEntity?> getBookmark(String contentId) async {
    try {
      final db = await _db;
      return await db.bookmarkEntitys
          .where()
          .contentIdEqualTo(contentId)
          .findFirst();
    } catch (e) {
      debugPrint('[$_tag] getBookmark error: $e');
      return null;
    }
  }

  // ── CLEAR ────────────────────────────────────

  Future<void> clearAll() async {
    try {
      final db = await _db;
      await db.writeTxn(() => db.bookmarkEntitys.clear());
      debugPrint('[$_tag] All bookmarks cleared.');
    } catch (e) {
      debugPrint('[$_tag] clearAll error: $e');
      throw BookmarkDataSourceException(
          message: 'Failed to clear bookmarks.', cause: e);
    }
  }
}