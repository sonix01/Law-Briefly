// lib/features/reader/case_law_resolver.dart
// Law Briefly — Case Law Resolver
// Resolves case law IDs → CaseLaw objects via repository.

import 'package:flutter/foundation.dart';

import '../../data/models/legal_models.dart';
import '../../data/repositories/legal_repository.dart';

// ─────────────────────────────────────────────
// MARK: — RESOLVE RESULT
// ─────────────────────────────────────────────

class ResolveResult {
  final List<CaseLaw> caseLaws;
  final List<String>  unresolvedIds;
  final bool          isFromCache;

  const ResolveResult({
    required this.caseLaws,
    required this.unresolvedIds,
    required this.isFromCache,
  });

  bool get isComplete => unresolvedIds.isEmpty;
  bool get isEmpty    => caseLaws.isEmpty;
  int  get count      => caseLaws.length;
}

// ─────────────────────────────────────────────
// MARK: — CASE LAW RESOLVER
// ─────────────────────────────────────────────

class CaseLawResolver {
  // ── Dependencies ──────────────────────────────
  final LegalRepository _repository;

  // ── Session-level cache ───────────────────────
  // Avoids repeated repository calls for the same IDs within one session.
  final Map<String, CaseLaw> _cache = {};

  // ─────────────────────────────────────────────
  // MARK: — CONSTRUCTOR
  // ─────────────────────────────────────────────

  CaseLawResolver(this._repository);

  // ─────────────────────────────────────────────
  // MARK: — RESOLVE (Primary API)
  // ─────────────────────────────────────────────

  /// Resolves a list of case law IDs to their full CaseLaw objects.
  ///
  /// - Returns case laws in the same order as the input IDs.
  /// - Unresolvable IDs are silently skipped (logged via debugPrint).
  /// - Resolved results are cached for the session lifetime.
  Future<List<CaseLaw>> resolveCaseLaws(List<String> caseLawIds) async {
    if (caseLawIds.isEmpty) return const [];

    final result  = <CaseLaw>[];
    final missing = <String>[];

    // ── Step 1: Serve from cache ───────────────────
    for (final id in caseLawIds) {
      if (_cache.containsKey(id)) {
        result.add(_cache[id]!);
      } else {
        missing.add(id);
      }
    }

    // ── Step 2: Load uncached IDs from repository ──
    if (missing.isNotEmpty) {
      try {
        final loaded = await _repository.getCaseLawsByIds(missing);

        for (final caseLaw in loaded) {
          _cache[caseLaw.id] = caseLaw;
          result.add(caseLaw);
        }

        final loadedIds   = loaded.map((c) => c.id).toSet();
        final unresolved  = missing.where((id) => !loadedIds.contains(id)).toList();

        if (unresolved.isNotEmpty) {
          debugPrint(
            '[CaseLawResolver] Unresolved IDs: ${unresolved.join(', ')}',
          );
        }

        debugPrint(
          '[CaseLawResolver] Loaded ${loaded.length}/${missing.length} '
          'case laws from repository.',
        );
      } catch (e) {
        debugPrint('[CaseLawResolver] Repository error: $e');
      }
    } else {
      debugPrint(
        '[CaseLawResolver] Served ${result.length} case laws from cache.',
      );
    }

    // ── Step 3: Restore original order ────────────
    final orderMap = {
      for (var i = 0; i < caseLawIds.length; i++) caseLawIds[i]: i,
    };
    result.sort((a, b) =>
        (orderMap[a.id] ?? 999).compareTo(orderMap[b.id] ?? 999));

    return result;
  }

  // ─────────────────────────────────────────────
  // MARK: — RESOLVE SINGLE
  // ─────────────────────────────────────────────

  /// Resolves a single case law by ID. Returns null if not found.
  Future<CaseLaw?> resolveSingle(String caseLawId) async {
    if (caseLawId.isEmpty) return null;

    if (_cache.containsKey(caseLawId)) return _cache[caseLawId];

    try {
      final caseLaw = await _repository.getCaseLawById(caseLawId);
      if (caseLaw != null) _cache[caseLaw.id] = caseLaw;
      return caseLaw;
    } catch (e) {
      debugPrint('[CaseLawResolver] Failed to resolve $caseLawId: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // MARK: — RESOLVE WITH RESULT
  // Returns structured result including unresolved IDs.
  // ─────────────────────────────────────────────

  Future<ResolveResult> resolveWithResult(List<String> caseLawIds) async {
    if (caseLawIds.isEmpty) {
      return const ResolveResult(
        caseLaws:      [],
        unresolvedIds: [],
        isFromCache:   true,
      );
    }

    final cached   = <String>{};
    final missing  = <String>[];

    for (final id in caseLawIds) {
      if (_cache.containsKey(id)) {
        cached.add(id);
      } else {
        missing.add(id);
      }
    }

    final resolved   = <CaseLaw>[];
    final unresolved = <String>[];

    // From cache
    for (final id in cached) {
      resolved.add(_cache[id]!);
    }

    // From repository
    if (missing.isNotEmpty) {
      try {
        final loaded    = await _repository.getCaseLawsByIds(missing);
        final loadedIds = loaded.map((c) => c.id).toSet();

        for (final caseLaw in loaded) {
          _cache[caseLaw.id] = caseLaw;
          resolved.add(caseLaw);
        }

        unresolved.addAll(missing.where((id) => !loadedIds.contains(id)));
      } catch (e) {
        debugPrint('[CaseLawResolver] resolveWithResult error: $e');
        unresolved.addAll(missing);
      }
    }

    // Restore order
    final orderMap = {
      for (var i = 0; i < caseLawIds.length; i++) caseLawIds[i]: i,
    };
    resolved.sort((a, b) =>
        (orderMap[a.id] ?? 999).compareTo(orderMap[b.id] ?? 999));

    return ResolveResult(
      caseLaws:      resolved,
      unresolvedIds: unresolved,
      isFromCache:   missing.isEmpty,
    );
  }

  // ─────────────────────────────────────────────
  // MARK: — CACHE MANAGEMENT
  // ─────────────────────────────────────────────

  /// Pre-warms the cache with a known list of case laws.
  void warmCache(List<CaseLaw> caseLaws) {
    for (final c in caseLaws) {
      _cache[c.id] = c;
    }
    debugPrint('[CaseLawResolver] Cache warmed with ${caseLaws.length} entries.');
  }

  /// Returns true if the given ID is already cached.
  bool isCached(String id) => _cache.containsKey(id);

  /// Returns the current cache size.
  int get cacheSize => _cache.length;

  /// Clears the session cache.
  void clearCache() {
    _cache.clear();
    debugPrint('[CaseLawResolver] Cache cleared.');
  }
}