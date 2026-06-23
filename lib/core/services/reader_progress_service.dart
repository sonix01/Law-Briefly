// lib/core/services/reader_progress_service.dart
// Law Briefly — Reader Progress Service
// Persists reading position for Act Sections and Constitution Articles.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';

import '../database/database_models.dart';
import '../database/database_service.dart';

// ─────────────────────────────────────────────
// MARK: — READER PROGRESS SNAPSHOT
// ─────────────────────────────────────────────

class ReaderProgressSnapshot {
  final String    contentId;
  final int       lastReadPosition;
  final double    scrollOffset;
  final DateTime  lastOpened;
  final DateTime? firstOpened;
  final bool      isCompleted;
  final int       totalReadTimeSeconds;

  const ReaderProgressSnapshot({
    required this.contentId,
    required this.lastReadPosition,
    required this.scrollOffset,
    required this.lastOpened,
    required this.isCompleted,
    required this.totalReadTimeSeconds,
    this.firstOpened,
  });

  double progressFraction(int totalItems) =>
      totalItems > 0 ? (lastReadPosition + 1) / totalItems : 0.0;

  factory ReaderProgressSnapshot.fromEntity(ReaderProgressEntity e) =>
      ReaderProgressSnapshot(
        contentId:           e.contentId,
        lastReadPosition:    e.lastReadPosition,
        scrollOffset:        e.scrollOffset,
        lastOpened:          e.lastOpened,
        firstOpened:         e.firstOpened,
        isCompleted:         e.isCompleted,
        totalReadTimeSeconds: e.totalReadTimeSeconds,
      );
}

// ─────────────────────────────────────────────
// MARK: — READER PROGRESS SERVICE
// ─────────────────────────────────────────────

class ReaderProgressService {
  // ── Dependencies ──────────────────────────────
  final DatabaseService _db;

  // ── In-memory fallback ────────────────────────
  // Active when database is unavailable.
  final Map<String, ReaderProgressSnapshot> _memoryFallback = {};

  // ─────────────────────────────────────────────
  // MARK: — CONSTRUCTOR
  // ─────────────────────────────────────────────

  ReaderProgressService({DatabaseService? db})
      : _db = db ?? DatabaseService.instance;

  // ─────────────────────────────────────────────
  // MARK: — SAVE PROGRESS
  // ─────────────────────────────────────────────

  /// Persists the current reading position for a section or article.
  Future<void> saveProgress({
    required String contentId,
    required int    lastReadPosition,
    double          scrollOffset = 0.0,
    bool            isCompleted  = false,
  }) async {
    if (!_db.isOpen) {
      _memoryFallback[contentId] = ReaderProgressSnapshot(
        contentId:           contentId,
        lastReadPosition:    lastReadPosition,
        scrollOffset:        scrollOffset,
        lastOpened:          DateTime.now(),
        isCompleted:         isCompleted,
        totalReadTimeSeconds: 0,
      );
      debugPrint('[ReaderProgressService] Saved to memory (DB unavailable): $contentId');
      return;
    }

    try {
      await _db.isar.writeTxn(() async {
        final existing = await _db.isar.readerProgressEntitys
            .where()
            .contentIdEqualTo(contentId)
            .findFirst();

        if (existing != null) {
          existing
            ..lastReadPosition = lastReadPosition
            ..scrollOffset     = scrollOffset
            ..lastOpened       = DateTime.now()
            ..isCompleted      = isCompleted || existing.isCompleted;
          await _db.isar.readerProgressEntitys.put(existing);
        } else {
          final entity = ReaderProgressEntity()
            ..contentId        = contentId
            ..lastReadPosition = lastReadPosition
            ..scrollOffset     = scrollOffset
            ..lastOpened       = DateTime.now()
            ..firstOpened      = DateTime.now()
            ..isCompleted      = isCompleted;
          await _db.isar.readerProgressEntitys.put(entity);
        }
      });
      debugPrint('[ReaderProgressService] Saved: $contentId @ $lastReadPosition');
    } catch (e) {
      debugPrint('[ReaderProgressService] saveProgress error: $e');
    }
  }

  // ─────────────────────────────────────────────
  // MARK: — GET PROGRESS
  // ─────────────────────────────────────────────

  /// Returns the last reading position for the given content ID.
  /// Returns null if no progress has been recorded.
  Future<ReaderProgressSnapshot?> getProgress(String contentId) async {
    if (!_db.isOpen) {
      return _memoryFallback[contentId];
    }

    try {
      final entity = await _db.isar.readerProgressEntitys
          .where()
          .contentIdEqualTo(contentId)
          .findFirst();

      return entity != null
          ? ReaderProgressSnapshot.fromEntity(entity)
          : null;
    } catch (e) {
      debugPrint('[ReaderProgressService] getProgress error: $e');
      return _memoryFallback[contentId];
    }
  }

  // ─────────────────────────────────────────────
  // MARK: — UPDATE LAST POSITION
  // ─────────────────────────────────────────────

  /// Lightweight update — only updates position and timestamp.
  /// Avoids a full read-modify-write cycle.
  Future<void> updateLastPosition({
    required String contentId,
    required int    position,
    double          scrollOffset = 0.0,
  }) async {
    await saveProgress(
      contentId:        contentId,
      lastReadPosition: position,
      scrollOffset:     scrollOffset,
    );
  }

  // ─────────────────────────────────────────────
  // MARK: — ADD READ TIME
  // ─────────────────────────────────────────────

  /// Adds elapsed seconds to the total read time for a content ID.
  Future<void> addReadTime({
    required String contentId,
    required int    seconds,
  }) async {
    if (!_db.isOpen || seconds <= 0) return;

    try {
      await _db.isar.writeTxn(() async {
        final entity = await _db.isar.readerProgressEntitys
            .where()
            .contentIdEqualTo(contentId)
            .findFirst();

        if (entity != null) {
          entity.totalReadTimeSeconds += seconds;
          await _db.isar.readerProgressEntitys.put(entity);
        }
      });
    } catch (e) {
      debugPrint('[ReaderProgressService] addReadTime error: $e');
    }
  }

  // ─────────────────────────────────────────────
  // MARK: — MARK COMPLETED
  // ─────────────────────────────────────────────

  Future<void> markCompleted(String contentId) async {
    await saveProgress(
      contentId:        contentId,
      lastReadPosition: await _getLastPosition(contentId),
      isCompleted:      true,
    );
  }

  // ─────────────────────────────────────────────
  // MARK: — CLEAR PROGRESS
  // ─────────────────────────────────────────────

  /// Removes progress record for the given content ID.
  Future<void> clearProgress(String contentId) async {
    _memoryFallback.remove(contentId);

    if (!_db.isOpen) return;

    try {
      await _db.isar.writeTxn(() async {
        final entity = await _db.isar.readerProgressEntitys
            .where()
            .contentIdEqualTo(contentId)
            .findFirst();

        if (entity != null) {
          await _db.isar.readerProgressEntitys.delete(entity.id);
        }
      });
      debugPrint('[ReaderProgressService] Cleared progress: $contentId');
    } catch (e) {
      debugPrint('[ReaderProgressService] clearProgress error: $e');
    }
  }

  /// Clears all reader progress records.
  Future<void> clearAll() async {
    _memoryFallback.clear();
    if (!_db.isOpen) return;
    try {
      await _db.isar.writeTxn(
        () => _db.isar.readerProgressEntitys.clear(),
      );
      debugPrint('[ReaderProgressService] All progress cleared.');
    } catch (e) {
      debugPrint('[ReaderProgressService] clearAll error: $e');
    }
  }

  // ─────────────────────────────────────────────
  // MARK: — GET ALL PROGRESS
  // ─────────────────────────────────────────────

  Future<List<ReaderProgressSnapshot>> getAllProgress() async {
    if (!_db.isOpen) return _memoryFallback.values.toList();

    try {
      final entities = await _db.isar.readerProgressEntitys.where().findAll();
      return entities.map(ReaderProgressSnapshot.fromEntity).toList()
        ..sort((a, b) => b.lastOpened.compareTo(a.lastOpened));
    } catch (e) {
      debugPrint('[ReaderProgressService] getAllProgress error: $e');
      return [];
    }
  }

  // ─────────────────────────────────────────────
  // MARK: — PRIVATE HELPERS
  // ─────────────────────────────────────────────

  Future<int> _getLastPosition(String contentId) async {
    final snap = await getProgress(contentId);
    return snap?.lastReadPosition ?? 0;
  }
}