// lib/core/services/pdf_progress_service.dart
// Law Briefly — PDF Progress Service
// Tracks reading position and bookmarks in Academic Notes PDFs.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';

import '../database/database_models.dart';
import '../database/database_service.dart';

// ─────────────────────────────────────────────
// MARK: — PDF PROGRESS SNAPSHOT
// ─────────────────────────────────────────────

class PdfProgressSnapshot {
  final String    pdfId;
  final int       lastPage;
  final double    progressPercentage;
  final DateTime  lastOpened;
  final DateTime? firstOpened;
  final List<int> bookmarkedPages;
  final int       totalPages;
  final double    zoomLevel;
  final bool      isCompleted;

  const PdfProgressSnapshot({
    required this.pdfId,
    required this.lastPage,
    required this.progressPercentage,
    required this.lastOpened,
    required this.bookmarkedPages,
    required this.totalPages,
    required this.zoomLevel,
    required this.isCompleted,
    this.firstOpened,
  });

  bool isPageBookmarked(int page) => bookmarkedPages.contains(page);

  factory PdfProgressSnapshot.fromEntity(PdfProgressEntity e) =>
      PdfProgressSnapshot(
        pdfId:              e.pdfId,
        lastPage:           e.lastPage,
        progressPercentage: e.progressPercentage,
        lastOpened:         e.lastOpened,
        firstOpened:        e.firstOpened,
        bookmarkedPages:    List.unmodifiable(e.bookmarkedPages),
        totalPages:         e.totalPages,
        zoomLevel:          e.zoomLevel,
        isCompleted:        e.isCompleted,
      );
}

// ─────────────────────────────────────────────
// MARK: — PDF PROGRESS SERVICE
// ─────────────────────────────────────────────

class PdfProgressService {
  // ── Dependencies ──────────────────────────────
  final DatabaseService _db;

  // ── In-memory fallback ────────────────────────
  final Map<String, PdfProgressSnapshot> _memoryFallback = {};

  // ─────────────────────────────────────────────
  // MARK: — CONSTRUCTOR
  // ─────────────────────────────────────────────

  PdfProgressService({DatabaseService? db})
      : _db = db ?? DatabaseService.instance;

  // ─────────────────────────────────────────────
  // MARK: — SAVE PROGRESS
  // ─────────────────────────────────────────────

  /// Saves the full PDF reading state.
  Future<void> saveProgress({
    required String pdfId,
    required int    lastPage,
    required int    totalPages,
    double?         zoomLevel,
    bool            isCompleted = false,
  }) async {
    final percentage = totalPages > 0
        ? (lastPage / totalPages * 100.0).clamp(0.0, 100.0)
        : 0.0;

    if (!_db.isOpen) {
      _memoryFallback[pdfId] = PdfProgressSnapshot(
        pdfId:              pdfId,
        lastPage:           lastPage,
        progressPercentage: percentage,
        lastOpened:         DateTime.now(),
        bookmarkedPages:    [],
        totalPages:         totalPages,
        zoomLevel:          zoomLevel ?? 1.0,
        isCompleted:        isCompleted,
      );
      debugPrint('[PdfProgressService] Saved to memory: $pdfId page $lastPage');
      return;
    }

    try {
      await _db.isar.writeTxn(() async {
        final existing = await _db.isar.pdfProgressEntitys
            .where()
            .pdfIdEqualTo(pdfId)
            .findFirst();

        if (existing != null) {
          existing
            ..lastPage           = lastPage
            ..progressPercentage = percentage
            ..totalPages         = totalPages
            ..lastOpened         = DateTime.now()
            ..isCompleted        = isCompleted || existing.isCompleted;
          if (zoomLevel != null) existing.zoomLevel = zoomLevel;
          await _db.isar.pdfProgressEntitys.put(existing);
        } else {
          final entity = PdfProgressEntity()
            ..pdfId             = pdfId
            ..lastPage          = lastPage
            ..progressPercentage = percentage
            ..totalPages        = totalPages
            ..lastOpened        = DateTime.now()
            ..firstOpened       = DateTime.now()
            ..zoomLevel         = zoomLevel ?? 1.0
            ..isCompleted       = isCompleted;
          await _db.isar.pdfProgressEntitys.put(entity);
        }
      });
      debugPrint('[PdfProgressService] Saved: $pdfId @ page $lastPage (${percentage.toStringAsFixed(1)}%)');
    } catch (e) {
      debugPrint('[PdfProgressService] saveProgress error: $e');
    }
  }

  // ─────────────────────────────────────────────
  // MARK: — GET PROGRESS
  // ─────────────────────────────────────────────

  /// Returns the last reading state for the given PDF.
  /// Returns null if the PDF has never been opened.
  Future<PdfProgressSnapshot?> getProgress(String pdfId) async {
    if (!_db.isOpen) return _memoryFallback[pdfId];

    try {
      final entity = await _db.isar.pdfProgressEntitys
          .where()
          .pdfIdEqualTo(pdfId)
          .findFirst();
      return entity != null ? PdfProgressSnapshot.fromEntity(entity) : null;
    } catch (e) {
      debugPrint('[PdfProgressService] getProgress error: $e');
      return _memoryFallback[pdfId];
    }
  }

  // ─────────────────────────────────────────────
  // MARK: — UPDATE PAGE
  // ─────────────────────────────────────────────

  /// Lightweight page update — preferred during continuous scrolling.
  Future<void> updatePage({
    required String pdfId,
    required int    page,
    required int    totalPages,
  }) async {
    await saveProgress(
      pdfId:      pdfId,
      lastPage:   page,
      totalPages: totalPages,
    );
  }

  // ─────────────────────────────────────────────
  // MARK: — PAGE BOOKMARKS
  // ─────────────────────────────────────────────

  /// Toggles a page bookmark. Returns true if page was added, false if removed.
  Future<bool> togglePageBookmark({
    required String pdfId,
    required int    page,
  }) async {
    if (!_db.isOpen) return false;

    bool wasAdded = false;

    try {
      await _db.isar.writeTxn(() async {
        final entity = await _db.isar.pdfProgressEntitys
            .where()
            .pdfIdEqualTo(pdfId)
            .findFirst();

        if (entity != null) {
          if (entity.bookmarkedPages.contains(page)) {
            entity.bookmarkedPages.remove(page);
            wasAdded = false;
          } else {
            entity.bookmarkedPages.add(page);
            entity.bookmarkedPages.sort();
            wasAdded = true;
          }
          await _db.isar.pdfProgressEntitys.put(entity);
        }
      });
    } catch (e) {
      debugPrint('[PdfProgressService] togglePageBookmark error: $e');
    }

    return wasAdded;
  }

  /// Returns all bookmarked pages for a PDF.
  Future<List<int>> getBookmarkedPages(String pdfId) async {
    final snapshot = await getProgress(pdfId);
    return snapshot?.bookmarkedPages ?? [];
  }

  /// Returns true if the page is bookmarked.
  Future<bool> isPageBookmarked({
    required String pdfId,
    required int    page,
  }) async {
    final pages = await getBookmarkedPages(pdfId);
    return pages.contains(page);
  }

  // ─────────────────────────────────────────────
  // MARK: — CLEAR PROGRESS
  // ─────────────────────────────────────────────

  /// Removes all progress data for the given PDF.
  Future<void> clearProgress(String pdfId) async {
    _memoryFallback.remove(pdfId);

    if (!_db.isOpen) return;

    try {
      await _db.isar.writeTxn(() async {
        final entity = await _db.isar.pdfProgressEntitys
            .where()
            .pdfIdEqualTo(pdfId)
            .findFirst();
        if (entity != null) {
          await _db.isar.pdfProgressEntitys.delete(entity.id);
        }
      });
      debugPrint('[PdfProgressService] Cleared: $pdfId');
    } catch (e) {
      debugPrint('[PdfProgressService] clearProgress error: $e');
    }
  }

  /// Clears all PDF progress records.
  Future<void> clearAll() async {
    _memoryFallback.clear();
    if (!_db.isOpen) return;
    try {
      await _db.isar.writeTxn(
        () => _db.isar.pdfProgressEntitys.clear(),
      );
      debugPrint('[PdfProgressService] All PDF progress cleared.');
    } catch (e) {
      debugPrint('[PdfProgressService] clearAll error: $e');
    }
  }

  // ─────────────────────────────────────────────
  // MARK: — GET ALL (Recently Opened)
  // ─────────────────────────────────────────────

  Future<List<PdfProgressSnapshot>> getAllProgress() async {
    if (!_db.isOpen) return _memoryFallback.values.toList();

    try {
      final entities = await _db.isar.pdfProgressEntitys.where().findAll();
      return entities.map(PdfProgressSnapshot.fromEntity).toList()
        ..sort((a, b) => b.lastOpened.compareTo(a.lastOpened));
    } catch (e) {
      debugPrint('[PdfProgressService] getAllProgress error: $e');
      return [];
    }
  }
}