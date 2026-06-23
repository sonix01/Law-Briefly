// lib/features/pdf_reader/pdf_reader_controller.dart
// Law Briefly — PDF Reader Controller
// Page Navigation | Zoom | Progress | Bookmarks

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../core/services/pdf_progress_service.dart';
import '../../data/models/legal_models.dart';

// ─────────────────────────────────────────────
// MARK: — STATUS ENUM
// ─────────────────────────────────────────────

enum PdfReaderStatus { idle, loading, loaded, error }

// ─────────────────────────────────────────────
// MARK: — READER STATE
// ─────────────────────────────────────────────

class PdfReaderState {
  final PdfDocumentModel? document;
  final int               currentPage;
  final double            zoomLevel;
  final bool              isToolbarVisible;
  final bool              isDocumentBookmarked;
  final Set<int>          bookmarkedPages;
  final PdfReaderStatus   status;
  final String?           error;

  const PdfReaderState({
    this.document             = null,
    this.currentPage          = 1,
    this.zoomLevel            = 1.0,
    this.isToolbarVisible     = true,
    this.isDocumentBookmarked = false,
    this.bookmarkedPages      = const {},
    this.status               = PdfReaderStatus.idle,
    this.error                = null,
  });

  // ── Computed ──────────────────────────────────
  int    get totalPages       => document?.totalPages ?? 0;
  bool   get hasDocument      => document != null && status == PdfReaderStatus.loaded;
  bool   get isLoading        => status == PdfReaderStatus.loading;
  bool   get canGoNext        => currentPage < totalPages;
  bool   get canGoPrevious    => currentPage > 1;
  bool   get isFirst          => currentPage == 1;
  bool   get isLast           => currentPage == totalPages;
  bool   get isZoomed         => zoomLevel > 1.05;
  double get progressFraction => totalPages > 0 ? currentPage / totalPages : 0.0;
  double get progressPercent  => progressFraction * 100.0;

  bool isPageBookmarked(int page) => bookmarkedPages.contains(page);
  bool get isCurrentPageBookmarked => isPageBookmarked(currentPage);

  PdfReaderState copyWith({
    PdfDocumentModel? document,
    int?              currentPage,
    double?           zoomLevel,
    bool?             isToolbarVisible,
    bool?             isDocumentBookmarked,
    Set<int>?         bookmarkedPages,
    PdfReaderStatus?  status,
    Object?           error = _sentinel,
  }) =>
      PdfReaderState(
        document:             document             ?? this.document,
        currentPage:          currentPage          ?? this.currentPage,
        zoomLevel:            zoomLevel            ?? this.zoomLevel,
        isToolbarVisible:     isToolbarVisible     ?? this.isToolbarVisible,
        isDocumentBookmarked: isDocumentBookmarked ?? this.isDocumentBookmarked,
        bookmarkedPages:      bookmarkedPages      ?? this.bookmarkedPages,
        status:               status               ?? this.status,
        error:                error == _sentinel   ? this.error : error as String?,
      );
}

const Object _sentinel = Object();

// ─────────────────────────────────────────────
// MARK: — PDF READER CONTROLLER
// ─────────────────────────────────────────────

class PdfReaderController extends ChangeNotifier {
  // ── Dependencies ──────────────────────────────
  final PdfProgressService _progressService;

  // ── State ─────────────────────────────────────
  PdfReaderState _state = const PdfReaderState();
  PdfReaderState get state => _state;

  // ── Page controller ───────────────────────────
  PageController? _pageController;
  PageController? get pageController => _pageController;

  // ── Toolbar auto-hide timer ───────────────────
  Timer? _toolbarTimer;
  static const Duration _toolbarHideDuration = Duration(seconds: 4);

  // ─────────────────────────────────────────────
  // MARK: — CONSTRUCTOR
  // ─────────────────────────────────────────────

  PdfReaderController({PdfProgressService? progressService})
      : _progressService = progressService ?? PdfProgressService();

  // ─────────────────────────────────────────────
  // MARK: — LOAD PDF
  // ─────────────────────────────────────────────

  Future<void> loadPdf(PdfDocumentModel document) async {
    _setState(_state.copyWith(status: PdfReaderStatus.loading));

    try {
      // Restore progress
      final progress = await _progressService.getProgress(document.id);
      final lastPage = progress?.lastPage
          ?? document.lastReadPage.clamp(1, document.totalPages);

      _pageController?.dispose();
      _pageController = PageController(initialPage: lastPage - 1);
      _pageController!.addListener(_onPageControllerUpdate);

      _setState(_state.copyWith(
        document:             document,
        currentPage:          lastPage,
        bookmarkedPages:      {
          ...document.bookmarkedPages,
          ...(progress?.bookmarkedPages ?? []),
        },
        status: PdfReaderStatus.loaded,
        error:  null,
      ));

      _scheduleToolbarHide();

      debugPrint(
        '[PdfReaderController] Loaded: ${document.title} '
        '(${document.totalPages} pages, resuming at $lastPage)',
      );
    } catch (e) {
      debugPrint('[PdfReaderController] loadPdf error: $e');
      _setState(_state.copyWith(
        status: PdfReaderStatus.error,
        error:  'Failed to open PDF.',
      ));
    }
  }

  // ─────────────────────────────────────────────
  // MARK: — PAGE NAVIGATION
  // ─────────────────────────────────────────────

  /// Jumps to a specific page with animation.
  Future<void> jumpToPage(int page) async {
    if (!_state.hasDocument) return;
    final clamped = page.clamp(1, _state.totalPages);
    await _pageController?.animateToPage(
      clamped - 1,
      duration: const Duration(milliseconds: 380),
      curve:    Curves.easeOutCubic,
    );
    _setState(_state.copyWith(currentPage: clamped));
    await saveProgress();
    _showToolbar();
  }

  /// Moves to the next page. Returns true if navigation succeeded.
  bool nextPage() {
    if (!_state.canGoNext) return false;
    _pageController?.nextPage(
      duration: const Duration(milliseconds: 280),
      curve:    Curves.easeOutCubic,
    );
    _setState(_state.copyWith(currentPage: _state.currentPage + 1));
    _scheduleAutoSave();
    _showToolbar();
    return true;
  }

  /// Moves to the previous page. Returns true if navigation succeeded.
  bool previousPage() {
    if (!_state.canGoPrevious) return false;
    _pageController?.previousPage(
      duration: const Duration(milliseconds: 280),
      curve:    Curves.easeOutCubic,
    );
    _setState(_state.copyWith(currentPage: _state.currentPage - 1));
    _scheduleAutoSave();
    _showToolbar();
    return true;
  }

  /// Jumps to the first page.
  Future<void> goToFirstPage() => jumpToPage(1);

  /// Jumps to the last page.
  Future<void> goToLastPage() => jumpToPage(_state.totalPages);

  /// Called by PageView when the user swipes to a new page.
  void onPageChanged(int pageIndex) {
    final page = pageIndex + 1;
    if (page == _state.currentPage) return;
    _setState(_state.copyWith(currentPage: page));
    _scheduleAutoSave();
  }

  // ─────────────────────────────────────────────
  // MARK: — PROGRESS
  // ─────────────────────────────────────────────

  /// Saves current reading progress to storage.
  Future<void> saveProgress() async {
    if (!_state.hasDocument) return;
    try {
      await _progressService.saveProgress(
        pdfId:      _state.document!.id,
        lastPage:   _state.currentPage,
        totalPages: _state.totalPages,
      );
      debugPrint('[PdfReaderController] Progress saved: page ${_state.currentPage}');
    } catch (e) {
      debugPrint('[PdfReaderController] saveProgress error: $e');
    }
  }

  /// Restores saved progress from storage.
  Future<void> restoreProgress() async {
    if (!_state.hasDocument) return;
    final progress = await _progressService.getProgress(_state.document!.id);
    if (progress != null) {
      await jumpToPage(progress.lastPage);
    }
  }

  // ─────────────────────────────────────────────
  // MARK: — BOOKMARKS
  // ─────────────────────────────────────────────

  /// Toggles the bookmark on the current page.
  Future<bool> togglePageBookmark() async {
    if (!_state.hasDocument) return false;
    final page = _state.currentPage;
    final added = await _progressService.togglePageBookmark(
      pdfId: _state.document!.id,
      page:  page,
    );
    final updated = Set<int>.from(_state.bookmarkedPages);
    if (added) { updated.add(page); } else { updated.remove(page); }
    _setState(_state.copyWith(bookmarkedPages: updated));
    return added;
  }

  /// Toggles the document-level bookmark.
  void toggleDocumentBookmark() {
    _setState(_state.copyWith(
      isDocumentBookmarked: !_state.isDocumentBookmarked,
    ));
  }

  // ─────────────────────────────────────────────
  // MARK: — ZOOM
  // ─────────────────────────────────────────────

  void setZoomLevel(double zoom) {
    final clamped = zoom.clamp(1.0, 5.0);
    _setState(_state.copyWith(zoomLevel: clamped));
  }

  void resetZoom() => setZoomLevel(1.0);

  // ─────────────────────────────────────────────
  // MARK: — TOOLBAR
  // ─────────────────────────────────────────────

  void _showToolbar() {
    _setState(_state.copyWith(isToolbarVisible: true));
    _scheduleToolbarHide();
  }

  void toggleToolbar() {
    if (_state.isToolbarVisible) {
      _toolbarTimer?.cancel();
      _setState(_state.copyWith(isToolbarVisible: false));
    } else {
      _showToolbar();
    }
  }

  void _scheduleToolbarHide() {
    _toolbarTimer?.cancel();
    _toolbarTimer = Timer(_toolbarHideDuration, () {
      if (mounted) _setState(_state.copyWith(isToolbarVisible: false));
    });
  }

  bool get mounted => !_disposed;
  bool _disposed = false;

  // ─────────────────────────────────────────────
  // MARK: — GETTERS
  // ─────────────────────────────────────────────

  int    getCurrentPage()  => _state.currentPage;
  int    getTotalPages()   => _state.totalPages;
  double getZoomLevel()    => _state.zoomLevel;

  // ─────────────────────────────────────────────
  // MARK: — AUTO SAVE
  // ─────────────────────────────────────────────

  Timer? _autoSaveTimer;
  static const Duration _autoSaveDelay = Duration(seconds: 3);

  void _scheduleAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(_autoSaveDelay, saveProgress);
  }

  // ─────────────────────────────────────────────
  // MARK: — PRIVATE HELPERS
  // ─────────────────────────────────────────────

  void _onPageControllerUpdate() {
    if (_pageController == null) return;
    final page = (_pageController!.page?.round() ?? 0) + 1;
    if (page != _state.currentPage) {
      _setState(_state.copyWith(currentPage: page));
    }
  }

  void _setState(PdfReaderState newState) {
    _state = newState;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed    = true;
    _toolbarTimer?.cancel();
    _autoSaveTimer?.cancel();
    _pageController?.removeListener(_onPageControllerUpdate);
    _pageController?.dispose();
    saveProgress(); // Final save on dispose
    debugPrint('[PdfReaderController] Disposed.');
    super.dispose();
  }
}