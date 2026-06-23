// lib/features/pdf_reader/data/pdf_progress_repository.dart
import 'package:flutter/foundation.dart';

// ─────────────────────────────────────────────
// MARK: — EXCEPTION
// ─────────────────────────────────────────────

class PdfProgressException implements Exception {
  final String  message;
  final Object? cause;
  const PdfProgressException({required this.message, this.cause});
  @override
  String toString() => 'PdfProgressException: $message'
      '${cause != null ? " — $cause" : ""}';
}

// ─────────────────────────────────────────────
// MARK: — ABSTRACT CONTRACT
// ─────────────────────────────────────────────

abstract class PdfProgressRepository {
  Future<void> savePage({required String pdfId, required int page});
  Future<int>  getLastPage(String pdfId);
  Future<void> clearProgress(String pdfId);
  Future<void> clearAll();
}

// ─────────────────────────────────────────────
// MARK: — IN-MEMORY IMPLEMENTATION
// Replace with IsarPdfProgressRepository when Isar is ready.
// ─────────────────────────────────────────────

class PdfProgressRepositoryImpl implements PdfProgressRepository {
  // ── In-memory store ─────────────────────────
  // Key: pdfId → last page number
  final Map<String, int> _progress = {};

  static const String _tag = 'PdfProgressRepositoryImpl';

  // ─────────────────────────────────────────────
  // MARK: — SAVE PAGE
  // ─────────────────────────────────────────────

  @override
  Future<void> savePage({required String pdfId, required int page}) async {
    try {
      await Future.delayed(Duration.zero); // Async boundary for Isar compatibility
      _progress[pdfId] = page.clamp(1, 99999);
      debugPrint('[$_tag] Saved progress: $pdfId → page $page');
    } catch (e) {
      debugPrint('[$_tag] savePage error: $e');
      throw PdfProgressException(message: 'Failed to save progress.', cause: e);
    }
  }

  // ─────────────────────────────────────────────
  // MARK: — GET LAST PAGE
  // ─────────────────────────────────────────────

  @override
  Future<int> getLastPage(String pdfId) async {
    try {
      await Future.delayed(Duration.zero);
      final page = _progress[pdfId] ?? 1;
      debugPrint('[$_tag] getLastPage: $pdfId → page $page');
      return page;
    } catch (e) {
      debugPrint('[$_tag] getLastPage error: $e');
      return 1; // Safe default
    }
  }

  // ─────────────────────────────────────────────
  // MARK: — CLEAR PROGRESS (single PDF)
  // ─────────────────────────────────────────────

  @override
  Future<void> clearProgress(String pdfId) async {
    await Future.delayed(Duration.zero);
    _progress.remove(pdfId);
    debugPrint('[$_tag] Cleared progress for: $pdfId');
  }

  // ─────────────────────────────────────────────
  // MARK: — CLEAR ALL
  // ─────────────────────────────────────────────

  @override
  Future<void> clearAll() async {
    await Future.delayed(Duration.zero);
    _progress.clear();
    debugPrint('[$_tag] All PDF progress cleared.');
  }

  // ─────────────────────────────────────────────
  // MARK: — FUTURE: ISAR MIGRATION NOTES
  // ─────────────────────────────────────────────

  // When replacing with Isar:
  //
  // 1. Create PdfProgressEntity @collection with fields:
  //    - Id id (Isar.autoIncrement)
  //    - @Index(unique: true) String pdfId
  //    - int lastPage
  //    - DateTime savedAt
  //
  // 2. Replace _progress map with Isar queries:
  //    savePage   → isar.writeTxn(() => isar.pdfProgressEntitys.put(entity))
  //    getLastPage → isar.pdfProgressEntitys.where().pdfIdEqualTo(id).findFirst()
  //
  // 3. Update PdfProgressRepositoryImpl to use IsarDatabaseService:
  //    final IsarDatabaseService _dbService;
  //    PdfProgressRepositoryImpl({IsarDatabaseService? dbService})
  //        : _dbService = dbService ?? IsarDatabaseService.instance;
}