// lib/features/reader/reader_ui_controller.dart
// Law Briefly — Reader UI State Controller

import 'package:flutter/foundation.dart';

import '../../data/models/legal_models.dart';
import 'reader_content.dart';

// ─────────────────────────────────────────────
// MARK: — READER UI STATE
// ─────────────────────────────────────────────

class ReaderUiState {
  final bool      isBookmarked;
  final CaseLaw?  selectedCaseLaw;
  final bool      showCaseLawModal;
  final bool      isScrolled;       // True after user scrolls past header
  final bool      showScrollTop;    // True when scrolled deep

  const ReaderUiState({
    this.isBookmarked      = false,
    this.selectedCaseLaw   = null,
    this.showCaseLawModal  = false,
    this.isScrolled        = false,
    this.showScrollTop     = false,
  });

  bool get hasCaseLaw => selectedCaseLaw != null;

  ReaderUiState copyWith({
    bool?     isBookmarked,
    Object?   selectedCaseLaw  = _sentinel,
    bool?     showCaseLawModal,
    bool?     isScrolled,
    bool?     showScrollTop,
  }) =>
      ReaderUiState(
        isBookmarked:     isBookmarked     ?? this.isBookmarked,
        selectedCaseLaw:  selectedCaseLaw  == _sentinel
            ? this.selectedCaseLaw
            : selectedCaseLaw as CaseLaw?,
        showCaseLawModal: showCaseLawModal ?? this.showCaseLawModal,
        isScrolled:       isScrolled       ?? this.isScrolled,
        showScrollTop:    showScrollTop    ?? this.showScrollTop,
      );
}

const Object _sentinel = Object();

// ─────────────────────────────────────────────
// MARK: — READER UI CONTROLLER
// ─────────────────────────────────────────────

class ReaderUiController extends ChangeNotifier {
  // ── State ─────────────────────────────────────
  ReaderUiState _state = const ReaderUiState();
  ReaderUiState get state => _state;

  // ── Convenience getters ───────────────────────
  bool     get isBookmarked       => _state.isBookmarked;
  CaseLaw? get selectedCaseLaw    => _state.selectedCaseLaw;
  bool     get showCaseLawModal   => _state.showCaseLawModal;
  bool     get isScrolled         => _state.isScrolled;
  bool     get showScrollTop      => _state.showScrollTop;

  // ─────────────────────────────────────────────
  // MARK: — BOOKMARK
  // ─────────────────────────────────────────────

  /// Toggles the bookmark state for the current content.
  void toggleBookmark() {
    _setState(_state.copyWith(isBookmarked: !_state.isBookmarked));
    debugPrint('[ReaderUiController] Bookmark: ${_state.isBookmarked}');
  }

  /// Sets bookmark to a specific state (for restoring persisted state).
  void setBookmarked(bool value) {
    if (_state.isBookmarked == value) return;
    _setState(_state.copyWith(isBookmarked: value));
  }

  // ─────────────────────────────────────────────
  // MARK: — CASE LAW MODAL
  // ─────────────────────────────────────────────

  /// Opens the case law modal for the given [caseLaw].
  void openCaseLaw(CaseLaw caseLaw) {
    _setState(_state.copyWith(
      selectedCaseLaw:  caseLaw,
      showCaseLawModal: true,
    ));
    debugPrint('[ReaderUiController] Case law opened: ${caseLaw.id}');
  }

  /// Closes the case law modal.
  void closeCaseLaw() {
    _setState(_state.copyWith(
      showCaseLawModal: false,
      selectedCaseLaw:  null,
    ));
    debugPrint('[ReaderUiController] Case law closed.');
  }

  // ─────────────────────────────────────────────
  // MARK: — SCROLL STATE
  // ─────────────────────────────────────────────

  /// Updates scroll-based UI state (for collapsing header, scroll-to-top button, etc.).
  void onScrollUpdate({required double offset}) {
    final isScrolled  = offset > 80;
    final showScrollTop = offset > 800;

    if (isScrolled != _state.isScrolled || showScrollTop != _state.showScrollTop) {
      _setState(_state.copyWith(
        isScrolled:    isScrolled,
        showScrollTop: showScrollTop,
      ));
    }
  }

  // ─────────────────────────────────────────────
  // MARK: — RESET
  // Call when loading a new content item.
  // ─────────────────────────────────────────────

  /// Resets UI state when the reader content changes.
  /// Preserves any persisted bookmark state passed in.
  void reset({bool isBookmarked = false}) {
    _setState(ReaderUiState(isBookmarked: isBookmarked));
    debugPrint('[ReaderUiController] Reset (bookmarked: $isBookmarked).');
  }

  // ─────────────────────────────────────────────
  // MARK: — PRIVATE
  // ─────────────────────────────────────────────

  void _setState(ReaderUiState s) { _state = s; notifyListeners(); }

  @override
  void dispose() {
    debugPrint('[ReaderUiController] Disposed.');
    super.dispose();
  }
}