// lib/features/reader/data/reader_progress_repository.dart
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import '../../../core/database/isar_database_service.dart';
import 'models/reader_progress_model.dart';

// ─────────────────────────────────────────────
// MARK: — EXCEPTION
// ─────────────────────────────────────────────

class ReaderProgressRepositoryException implements Exception {
  final String  message;
  final Object? cause;
  const ReaderProgressRepositoryException({required this.message, this.cause});
  @override
  String toString() => 'ReaderProgressRepositoryException: $message'
      '${cause != null ? " — $cause" : ""}';
}

// ─────────────────────────────────────────────
// MARK: — ABSTRACT CONTRACT
// ─────────────────────────────────────────────

abstract class ReaderProgressRepository {
  Future<void>                      saveProgress(ReaderProgressModel progress);
  Future<void>                      updateProgress(ReaderProgressModel progress);
  Future<ReaderProgressModel?>      getProgress(String contentId);
  Future<List<ReaderProgressModel>> getRecentContent({int limit});
  Future<ReaderProgressModel?>      getLastOpenedContent();
  Future<void>                      deleteProgress(String contentId);
  Future<void>                      clearProgress();
}

// ─────────────────────────────────────────────
// MARK: — IMPLEMENTATION
// ─────────────────────────────────────────────

class ReaderProgressRepositoryImpl implements ReaderProgressRepository {
  final IsarDatabaseService _dbService;

  static const int    _defaultRecentLimit = 20;
  static const String _tag               = 'ReaderProgressRepositoryImpl';

  ReaderProgressRepositoryImpl({IsarDatabaseService? dbService})
      : _dbService = dbService ?? IsarDatabaseService.instance;

  Future<Isar> get _db => _dbService.getDatabase();

  // ── SAVE ─────────────────────────────────────

  @override
  Future<void> saveProgress(ReaderProgressModel progress) async {
    try {
      final db       = await _db;
      // Check for existing record with same contentId
      final existing = await db.readerProgressModels
          .where()
          .contentIdEqualTo(progress.contentId)
          .findFirst();

      if (existing != null) {
        // Merge: preserve firstOpenedAt and accumulate reading time
        progress
          ..id             = existing.id
          ..firstOpenedAt  = existing.firstOpenedAt ?? progress.firstOpenedAt
          ..totalReadSeconds = existing.totalReadSeconds + progress.totalReadSeconds;
      }

      await db.writeTxn(() => db.readerProgressModels.put(progress));
      debugPrint('[$_tag] Saved progress: ${progress.contentId}');
    } catch (e) {
      debugPrint('[$_tag] saveProgress error: $e');
      throw ReaderProgressRepositoryException(
          message: 'Failed to save progress.', cause: e);
    }
  }

  // ── UPDATE ────────────────────────────────────

  @override
  Future<void> updateProgress(ReaderProgressModel progress) async {
    try {
      final db       = await _db;
      final existing = await db.readerProgressModels
          .where()
          .contentIdEqualTo(progress.contentId)
          .findFirst();

      if (existing == null) {
        debugPrint('[$_tag] updateProgress: no record found for '
            '${progress.contentId}. Saving instead.');
        await saveProgress(progress);
        return;
      }

      progress.id = existing.id;
      await db.writeTxn(() => db.readerProgressModels.put(progress));
      debugPrint('[$_tag] Updated progress: ${progress.contentId}');
    } catch (e) {
      debugPrint('[$_tag] updateProgress error: $e');
      throw ReaderProgressRepositoryException(
          message: 'Failed to update progress.', cause: e);
    }
  }

  // ── GET ───────────────────────────────────────

  @override
  Future<ReaderProgressModel?> getProgress(String contentId) async {
    try {
      final db = await _db;
      return await db.readerProgressModels
          .where()
          .contentIdEqualTo(contentId)
          .findFirst();
    } catch (e) {
      debugPrint('[$_tag] getProgress error: $e');
      return null;
    }
  }

  // ── RECENT ───────────────────────────────────

  @override
  Future<List<ReaderProgressModel>> getRecentContent({
    int limit = _defaultRecentLimit,
  }) async {
    try {
      final db = await _db;
      return await db.readerProgressModels
          .where()
          .sortByLastOpenedAtDesc()
          .limit(limit)
          .findAll();
    } catch (e) {
      debugPrint('[$_tag] getRecentContent error: $e');
      throw ReaderProgressRepositoryException(
          message: 'Failed to fetch recent content.', cause: e);
    }
  }

  // ── LAST OPENED ───────────────────────────────

  @override
  Future<ReaderProgressModel?> getLastOpenedContent() async {
    try {
      final db = await _db;
      return await db.readerProgressModels
          .where()
          .sortByLastOpenedAtDesc()
          .findFirst();
    } catch (e) {
      debugPrint('[$_tag] getLastOpenedContent error: $e');
      return null;
    }
  }

  // ── DELETE ────────────────────────────────────

  @override
  Future<void> deleteProgress(String contentId) async {
    try {
      final db       = await _db;
      final existing = await db.readerProgressModels
          .where()
          .contentIdEqualTo(contentId)
          .findFirst();

      if (existing == null) return;

      await db.writeTxn(() => db.readerProgressModels.delete(existing.id));
      debugPrint('[$_tag] Deleted progress: $contentId');
    } catch (e) {
      debugPrint('[$_tag] deleteProgress error: $e');
      throw ReaderProgressRepositoryException(
          message: 'Failed to delete progress.', cause: e);
    }
  }

  // ── CLEAR ────────────────────────────────────

  @override
  Future<void> clearProgress() async {
    try {
      final db = await _db;
      await db.writeTxn(() => db.readerProgressModels.clear());
      debugPrint('[$_tag] All reader progress cleared.');
    } catch (e) {
      debugPrint('[$_tag] clearProgress error: $e');
      throw ReaderProgressRepositoryException(
          message: 'Failed to clear progress.', cause: e);
    }
  }
}