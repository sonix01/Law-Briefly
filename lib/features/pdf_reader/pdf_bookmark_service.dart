// lib/features/pdf_reader/pdf_bookmark_service.dart
// Law Briefly — PDF Page Bookmark Service
// In-Memory | Async | Reactive | Future Isar-Ready

import 'dart:async';

import 'package:flutter/foundation.dart';

import 'pdf_bookmark.dart';

// ─────────────────────────────────────────────
// MARK: — PDF BOOKMARK REPOSITORY INTERFACE
// Swap implementation for Isar without touching callers.
// ─────────────────────────────────────────────

abstract class PdfBookmarkRepository {
  Future<void>            save(PdfBookmark bookmark);
  Future<void>            remove(String id);
  Future<List<PdfBookmark>> getAllForPdf(String pdfId);
  Future<PdfBookmark?>    findById(String id);
  Future<bool>            exists(String id);
  Future<void>            clear(String pdfId);
  Stream<List<PdfBookmark>> watch(String pdfId);
}

// ─────────────────────────────────────────────
// MARK: — IN-MEMORY REPOSITORY
// ─────────────────────────────────────────────

class _InMemoryPdfBookmarkRepository implements PdfBookmarkRepository {
  final List<PdfBookmark>                        _store = [];
  final StreamController<Map<String, List<PdfBookmark>>> _ctrl =
      StreamController<Map<String, List<PdfBookmark>>>.broadcast();

  void _notify() {
    final grouped = <String, List<PdfBookmark>>{};
    for (final b in _store) {
      (grouped[b.pdfId] ??= []).add(b);
    }
    for (final list in grouped.values) {
      list.sort((a, b) => a.pageNumber.compareTo(b.pageNumber));
    }
    _ctrl.add(grouped);
  }

  @override
  Future<void> save(PdfBookmark bookmark) async {
    final i = _store.indexWhere((b) => b.id == bookmark.id);
    if (i >= 0) { _store[i] = bookmark; } else { _store.add(bookmark); }
    _notify();
  }

  @override
  Future<void> remove(String id) async {
    _store.removeWhere((b) => b.id == id);
    _notify();
  }

  @override
  Future<List<PdfBookmark>> getAllForPdf(String pdfId) async {
    return _store
        .where((b) => b.pdfId == pdfId)
        .toList()
      ..sort((a, b) => a.pageNumber.compareTo(b.pageNumber));
  }

  @override
  Future<PdfBookmark?> findById(String id) async {
    try { return _store.firstWhere((b) => b.id == id); }
    on StateError { return null; }
  }

  @override
  Future<bool> exists(String id) async =>
      _store.any((b) => b.id == id);

  @override
  Future<void> clear(String pdfId) async {
    _store.removeWhere((b) => b.pdfId == pdfId);
    _notify();
  }

  @override
  Stream<List<PdfBookmark>> watch(String pdfId) =>
      _ctrl.stream.map((grouped) =>
          List<PdfBookmark>.unmodifiable(grouped[pdfId] ?? []));

  void dispose() => _ctrl.close();
}

// ─────────────────────────────────────────────
// MARK: — PDF BOOKMARK SERVICE
// ─────────────────────────────────────────────

class PdfBookmarkService {
  // ── Singleton ─────────────────────────────────
  static final PdfBookmarkService _instance =
      PdfBookmarkService._internal();
  factory PdfBookmarkService() => _instance;
  PdfBookmarkService._internal();

  // ── Repository (swap-able) ────────────────────
  PdfBookmarkRepository _repo = _InMemoryPdfBookmarkRepository();

  // ── ID helper ─────────────────────────────────
  String _id(String pdfId, int page) => '${pdfId}_p$page';

  // ─────────────────────────────────────────────
  // MARK: — SAVE BOOKMARK
  // ─────────────────────────────────────────────

  /// Saves a page bookmark for the given PDF.
  /// Does nothing if the page is already bookmarked.
  Future<PdfBookmark> saveBookmark({
    required String pdfId,
    required int    pageNumber,
    String?         note,
  }) async {
    final id       = _id(pdfId, pageNumber);
    final existing = await _repo.findById(id);

    if (existing != null) {
      debugPrint('[PdfBookmarkService] Already bookmarked: $pdfId p$pageNumber');
      return existing;
    }

    final bookmark = PdfBookmark.create(
      pdfId:      pdfId,
      pageNumber: pageNumber,
      note:       note,
    );

    await _repo.save(bookmark);
    debugPrint('[PdfBookmarkService] Saved: $pdfId p$pageNumber');
    return bookmark;
  }

  // ─────────────────────────────────────────────
  // MARK: — REMOVE BOOKMARK
  // ─────────────────────────────────────────────

  /// Removes the bookmark for the given PDF page.
  Future<void> removeBookmark({
    required String pdfId,
    required int    pageNumber,
  }) async {
    final id = _id(pdfId, pageNumber);
    await _repo.remove(id);
    debugPrint('[PdfBookmarkService] Removed: $pdfId p$pageNumber');
  }

  // ─────────────────────────────────────────────
  // MARK: — GET BOOKMARKS
  // ─────────────────────────────────────────────

  /// Returns all bookmarks for the given PDF, sorted by page number.
  Future<List<PdfBookmark>> getBookmarks(String pdfId) =>
      _repo.getAllForPdf(pdfId);

  /// Live stream of bookmarks for a PDF.
  Stream<List<PdfBookmark>> watchBookmarks(String pdfId) =>
      _repo.watch(pdfId);

  // ─────────────────────────────────────────────
  // MARK: — IS BOOKMARKED
  // ─────────────────────────────────────────────

  /// Returns true if the given page is bookmarked.
  Future<bool> isBookmarked({
    required String pdfId,
    required int    pageNumber,
  }) =>
      _repo.exists(_id(pdfId, pageNumber));

  // ─────────────────────────────────────────────
  // MARK: — TOGGLE
  // ─────────────────────────────────────────────

  /// Toggles the bookmark for the given page.
  /// Returns true if bookmark was added, false if removed.
  Future<bool> toggleBookmark({
    required String pdfId,
    required int    pageNumber,
    String?         note,
  }) async {
    final bookmarked = await isBookmarked(pdfId: pdfId, pageNumber: pageNumber);
    if (bookmarked) {
      await removeBookmark(pdfId: pdfId, pageNumber: pageNumber);
      return false;
    } else {
      await saveBookmark(pdfId: pdfId, pageNumber: pageNumber, note: note);
      return true;
    }
  }

  // ─────────────────────────────────────────────
  // MARK: — ADD / UPDATE NOTE
  // ─────────────────────────────────────────────

  /// Adds or updates the annotation note on an existing bookmark.
  Future<void> updateNote({
    required String pdfId,
    required int    pageNumber,
    required String note,
  }) async {
    final existing = await _repo.findById(_id(pdfId, pageNumber));
    if (existing == null) return;
    await _repo.save(existing.copyWith(note: note));
  }

  // ─────────────────────────────────────────────
  // MARK: — GET BOOKMARK COUNT
  // ─────────────────────────────────────────────

  Future<int> getBookmarkCount(String pdfId) async {
    final bookmarks = await getBookmarks(pdfId);
    return bookmarks.length;
  }

  // ─────────────────────────────────────────────
  // MARK: — CLEAR ALL (for PDF)
  // ─────────────────────────────────────────────

  Future<void> clearAll(String pdfId) async {
    await _repo.clear(pdfId);
    debugPrint('[PdfBookmarkService] Cleared all bookmarks for: $pdfId');
  }

  // ─────────────────────────────────────────────
  // MARK: — SWAP REPOSITORY
  // ─────────────────────────────────────────────

  // ignore: use_setters_to_change_properties
  void setRepository(PdfBookmarkRepository repository) =>
      _repo = repository;
}