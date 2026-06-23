// lib/features/search/search_controller.dart
// Law Briefly — Search Controller

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'search_models.dart';
import 'search_service.dart';

// ─────────────────────────────────────────────
// MARK: — SEARCH STATE
// ─────────────────────────────────────────────

class SearchState {
  final List<SearchResult> results;
  final String             query;
  final bool               isLoading;
  final bool               hasSearched;
  final String?            error;

  const SearchState({
    this.results    = const [],
    this.query      = '',
    this.isLoading  = false,
    this.hasSearched = false,
    this.error,
  });

  bool get isEmpty         => results.isEmpty;
  bool get isNotEmpty      => results.isNotEmpty;
  bool get isIdle          => !hasSearched && !isLoading;
  bool get showEmpty       => hasSearched && results.isEmpty && !isLoading;

  SearchState copyWith({
    List<SearchResult>? results,
    String?             query,
    bool?               isLoading,
    bool?               hasSearched,
    Object?             error = _sentinel,
  }) =>
      SearchState(
        results:     results     ?? this.results,
        query:       query       ?? this.query,
        isLoading:   isLoading   ?? this.isLoading,
        hasSearched: hasSearched ?? this.hasSearched,
        error:       error == _sentinel ? this.error : error as String?,
      );
}

const Object _sentinel = Object();

// ─────────────────────────────────────────────
// MARK: — SEARCH CONTROLLER
// ─────────────────────────────────────────────

class SearchController extends ChangeNotifier {
  // ── Dependencies ──────────────────────────────
  final SearchService _service;

  // ── State ─────────────────────────────────────
  SearchState _state = const SearchState();
  SearchState get state => _state;

  // ── Debounce ──────────────────────────────────
  Timer?                          _debounce;
  static const Duration           _debounceDuration = Duration(milliseconds: 280);

  // ─────────────────────────────────────────────
  // MARK: — CONSTRUCTOR
  // ─────────────────────────────────────────────

  SearchController({SearchService? service})
      : _service = service ?? SearchService(_defaultRepository);

  // ─────────────────────────────────────────────
  // MARK: — SEARCH
  // ─────────────────────────────────────────────

  /// Debounced search — safe to call on every keystroke.
  void search(String query) {
    final q = query.trim();

    _debounce?.cancel();

    if (q.isEmpty) {
      clearSearch();
      return;
    }

    _setState(_state.copyWith(query: query, isLoading: true, error: null));

    _debounce = Timer(_debounceDuration, () => _performSearch(q));
  }

  /// Immediate search — bypasses debounce (use for submit actions).
  Future<void> searchNow(String query) async {
    _debounce?.cancel();
    final q = query.trim();
    if (q.isEmpty) { clearSearch(); return; }
    _setState(_state.copyWith(query: query, isLoading: true, error: null));
    await _performSearch(q);
  }

  // ─────────────────────────────────────────────
  // MARK: — CLEAR
  // ─────────────────────────────────────────────

  /// Clears results and resets state.
  void clearSearch() {
    _debounce?.cancel();
    _setState(const SearchState());
    debugPrint('[SearchController] Cleared.');
  }

  // ─────────────────────────────────────────────
  // MARK: — ACCESSORS
  // ─────────────────────────────────────────────

  List<SearchResult> currentResults() => List.unmodifiable(_state.results);
  String             currentQuery()   => _state.query;
  bool               get isLoading    => _state.isLoading;
  bool               get hasResults   => _state.isNotEmpty;
  bool               get hasError     => _state.error != null;
  String?            get error        => _state.error;

  // ─────────────────────────────────────────────
  // MARK: — PRIVATE
  // ─────────────────────────────────────────────

  Future<void> _performSearch(String query) async {
    try {
      final results = await _service.searchActs(query);
      _setState(_state.copyWith(
        results:     results,
        isLoading:   false,
        hasSearched: true,
        error:       null,
      ));
      debugPrint('[SearchController] "$query" → ${results.length} results.');
    } catch (e) {
      debugPrint('[SearchController] Error: $e');
      _setState(_state.copyWith(
        results:     const [],
        isLoading:   false,
        hasSearched: true,
        error:       'Search failed. Please try again.',
      ));
    }
  }

  void _setState(SearchState s) { _state = s; notifyListeners(); }

  @override
  void dispose() { _debounce?.cancel(); super.dispose(); }
}

// ignore: avoid_relative_lib_imports
import '../../data/repositories/legal_repository.dart';
final _defaultRepository = LocalLegalRepository();