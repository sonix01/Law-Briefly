// lib/features/reader/reader_navigation_controller.dart
// Law Briefly — Reader Navigation Controller
// Sequential navigation through sections and articles.

import 'package:flutter/foundation.dart';
import 'reader_content.dart';

// ─────────────────────────────────────────────
// MARK: — NAVIGATION STATE
// ─────────────────────────────────────────────

class NavigationState {
  final int            currentIndex;
  final int            totalCount;
  final bool           hasNext;
  final bool           hasPrevious;
  final ReaderContent? currentContent;
  final ReaderContent? nextContent;
  final ReaderContent? previousContent;
  final double         progress;      // 0.0 – 1.0

  const NavigationState({
    required this.currentIndex,
    required this.totalCount,
    required this.hasNext,
    required this.hasPrevious,
    required this.progress,
    this.currentContent,
    this.nextContent,
    this.previousContent,
  });

  bool get isEmpty    => totalCount == 0;
  bool get isSingle   => totalCount == 1;
  bool get isFirst    => currentIndex == 0;
  bool get isLast     => currentIndex == totalCount - 1;

  @override
  String toString() =>
      'NavigationState(index: $currentIndex/$totalCount, '
      'hasNext: $hasNext, hasPrevious: $hasPrevious)';
}

// ─────────────────────────────────────────────
// MARK: — READER NAVIGATION CONTROLLER
// ─────────────────────────────────────────────

class ReaderNavigationController extends ChangeNotifier {
  // ── Data ──────────────────────────────────────
  List<ReaderContent> _items;
  int                 _currentIndex;

  // ─────────────────────────────────────────────
  // MARK: — CONSTRUCTOR
  // ─────────────────────────────────────────────

  ReaderNavigationController({
    required List<ReaderContent> items,
    int                          initialIndex = 0,
    String?                      initialId,
  }) : _items = List.unmodifiable(items),
       _currentIndex = 0 {
    if (initialId != null) {
      final found = items.indexWhere((c) => c.id == initialId);
      _currentIndex = found >= 0 ? found : 0;
    } else {
      _currentIndex = _clamp(initialIndex, items.length);
    }
  }

  // ─────────────────────────────────────────────
  // MARK: — CORE GETTERS
  // ─────────────────────────────────────────────

  int    get currentIndex  => _currentIndex;
  int    get totalCount    => _items.length;
  bool   get isEmpty       => _items.isEmpty;
  bool   get isNotEmpty    => _items.isNotEmpty;
  bool   get hasNext       => _currentIndex < _items.length - 1;
  bool   get hasPrevious   => _currentIndex > 0;
  bool   get isFirst       => _currentIndex == 0;
  bool   get isLast        => _currentIndex == _items.length - 1;
  double get progress =>
      _items.isEmpty ? 0.0 : (_currentIndex + 1) / _items.length;

  // ─────────────────────────────────────────────
  // MARK: — CONTENT ACCESS
  // ─────────────────────────────────────────────

  ReaderContent? currentContent() =>
      _items.isEmpty ? null : _items[_currentIndex];

  ReaderContent? contentAt(int index) =>
      (index >= 0 && index < _items.length) ? _items[index] : null;

  ReaderContent? get nextContent =>
      hasNext ? _items[_currentIndex + 1] : null;

  ReaderContent? get previousContent =>
      hasPrevious ? _items[_currentIndex - 1] : null;

  List<ReaderContent> get allItems => List.unmodifiable(_items);

  int indexOfId(String id) => _items.indexWhere((c) => c.id == id);

  // ─────────────────────────────────────────────
  // MARK: — NAVIGATION STATE SNAPSHOT
  // ─────────────────────────────────────────────

  NavigationState get navigationState => NavigationState(
        currentIndex:    _currentIndex,
        totalCount:      _items.length,
        hasNext:         hasNext,
        hasPrevious:     hasPrevious,
        progress:        progress,
        currentContent:  currentContent(),
        nextContent:     nextContent,
        previousContent: previousContent,
      );

  // ─────────────────────────────────────────────
  // MARK: — NAVIGATION METHODS
  // ─────────────────────────────────────────────

  /// Moves to the next item. Returns true if navigation succeeded.
  bool goNext() {
    if (!hasNext) {
      debugPrint('[ReaderNavigationController] Already at last item.');
      return false;
    }
    _currentIndex++;
    notifyListeners();
    debugPrint('[ReaderNavigationController] → Next ($currentIndex/$totalCount)');
    return true;
  }

  /// Moves to the previous item. Returns true if navigation succeeded.
  bool goPrevious() {
    if (!hasPrevious) {
      debugPrint('[ReaderNavigationController] Already at first item.');
      return false;
    }
    _currentIndex--;
    notifyListeners();
    debugPrint('[ReaderNavigationController] ← Previous ($currentIndex/$totalCount)');
    return true;
  }

  /// Jumps to a specific index. Returns true if the index was valid.
  bool goToIndex(int index) {
    if (index < 0 || index >= _items.length) {
      debugPrint('[ReaderNavigationController] Invalid index: $index');
      return false;
    }
    if (index == _currentIndex) return true;
    _currentIndex = index;
    notifyListeners();
    debugPrint('[ReaderNavigationController] ↗ To index $index');
    return true;
  }

  /// Jumps to the item with the given content ID. Returns true if found.
  bool goToId(String id) {
    final index = indexOfId(id);
    if (index < 0) {
      debugPrint('[ReaderNavigationController] Content not found: $id');
      return false;
    }
    return goToIndex(index);
  }

  /// Jumps to the first item.
  void goToFirst() => goToIndex(0);

  /// Jumps to the last item.
  void goToLast() => goToIndex(_items.isEmpty ? 0 : _items.length - 1);

  // ─────────────────────────────────────────────
  // MARK: — UPDATE ITEMS
  // Call when the content list changes (e.g., different chapter loaded).
  // ─────────────────────────────────────────────

  void updateItems(
    List<ReaderContent> items, {
    int?    initialIndex,
    String? initialId,
  }) {
    _items = List.unmodifiable(items);

    if (initialId != null) {
      final found = items.indexWhere((c) => c.id == initialId);
      _currentIndex = found >= 0 ? found : 0;
    } else if (initialIndex != null) {
      _currentIndex = _clamp(initialIndex, items.length);
    } else {
      _currentIndex = _clamp(_currentIndex, items.length);
    }

    notifyListeners();
    debugPrint(
      '[ReaderNavigationController] Items updated: '
      '${_items.length} items, index: $_currentIndex',
    );
  }

  /// Resets navigation to the first item.
  void reset() {
    _currentIndex = 0;
    notifyListeners();
  }

  // ─────────────────────────────────────────────
  // MARK: — HELPERS
  // ─────────────────────────────────────────────

  int _clamp(int index, int length) {
    if (length == 0) return 0;
    return index.clamp(0, length - 1);
  }

  @override
  void dispose() {
    debugPrint('[ReaderNavigationController] Disposed.');
    super.dispose();
  }
}