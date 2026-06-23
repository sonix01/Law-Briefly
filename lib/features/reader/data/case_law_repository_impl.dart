import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/case_law.dart';
import 'case_law_repository.dart';

// ─────────────────────────────────────────────
// MARK: — EXCEPTION
// ─────────────────────────────────────────────

class CaseLawRepositoryException implements Exception {
  final String  message;
  final String? path;
  final Object? cause;

  const CaseLawRepositoryException({
    required this.message,
    this.path,
    this.cause,
  });

  @override
  String toString() =>
      'CaseLawRepositoryException: $message'
      '${path  != null ? " [path: $path]"     : ""}'
      '${cause != null ? " — cause: $cause"   : ""}';
}

// ─────────────────────────────────────────────
// MARK: — IMPLEMENTATION
// ─────────────────────────────────────────────

class CaseLawRepositoryImpl implements CaseLawRepository {
  static const String _tag = 'CaseLawRepositoryImpl';

  // ── Known case law file paths ──────────────────
  // Future: drive this from manifest.json
  static const List<String> _defaultPaths = [
    'assets/data/case_laws/sample_case_laws.json',
    'assets/data/case_laws/criminal_law_cases.json',
    'assets/data/case_laws/constitutional_cases.json',
    'assets/data/case_laws/contract_law_cases.json',
    'assets/data/case_laws/evidence_law_cases.json',
    'assets/data/case_laws/property_law_cases.json',
  ];

  // ── In-memory index: id → CaseLaw ─────────────
  Map<String, CaseLaw>? _index;
  bool                  _loaded = false;

  // ─────────────────────────────────────────────
  // MARK: — PUBLIC API
  // ─────────────────────────────────────────────

  @override
  Future<List<CaseLaw>> getCaseLawsByIds(List<String> ids) async {
    if (ids.isEmpty) return const [];

    await _ensureLoaded();

    final results = <CaseLaw>[];
    for (final id in ids) {
      final caseLaw = _index?[id];
      if (caseLaw != null) {
        results.add(caseLaw);
      } else {
        debugPrint('[$_tag] Case law not found: $id');
      }
    }

    // Preserve original ID order
    final order = {for (var i = 0; i < ids.length; i++) ids[i]: i};
    results.sort((a, b) =>
        (order[a.id] ?? 999).compareTo(order[b.id] ?? 999));

    debugPrint('[$_tag] getCaseLawsByIds: returned ${results.length}/${ids.length}');
    return results;
  }

  @override
  Future<CaseLaw?> getCaseLawById(String id) async {
    await _ensureLoaded();
    final caseLaw = _index?[id];
    if (caseLaw == null) {
      debugPrint('[$_tag] getCaseLawById: not found — $id');
    }
    return caseLaw;
  }

  // ─────────────────────────────────────────────
  // MARK: — PRIVATE: LOAD & INDEX
  // ─────────────────────────────────────────────

  Future<void> _ensureLoaded() async {
    if (_loaded) return;

    final index = <String, CaseLaw>{};

    await Future.wait(
      _defaultPaths.map((path) async {
        try {
          final caseLaws = await _loadCaseLawJson(path);
          for (final cl in caseLaws) {
            index[cl.id] = cl;
          }
        } catch (e) {
          // Log but continue — allow partial loading
          debugPrint('[$_tag] Skipping $path: $e');
        }
      }),
    );

    _index  = index;
    _loaded = true;
    debugPrint('[$_tag] Indexed ${index.length} case laws from ${_defaultPaths.length} files.');
  }

  // ─────────────────────────────────────────────
  // MARK: — PRIVATE: LOAD JSON FILE
  // ─────────────────────────────────────────────

  Future<List<CaseLaw>> _loadCaseLawJson(String path) async {
    try {
      final raw = await rootBundle.loadString(path);

      if (raw.trim().isEmpty) {
        debugPrint('[$_tag] Empty file: $path');
        return const [];
      }

      final dynamic decoded = jsonDecode(raw);

      if (decoded is! List) {
        throw FormatException(
          'Case law JSON must be a root-level array: $path',
        );
      }

      return _parseCaseLaws(decoded as List<dynamic>, path: path);
    } on FlutterError catch (e) {
      // File doesn't exist in asset bundle — silently skip
      debugPrint('[$_tag] Asset not found (skipping): $path');
      return const [];
    } on FormatException catch (e) {
      debugPrint('[$_tag] JSON parse error in $path: $e');
      throw CaseLawRepositoryException(
        message: 'Invalid JSON in case law file.',
        path:    path,
        cause:   e,
      );
    }
  }

  // ─────────────────────────────────────────────
  // MARK: — PRIVATE: PARSE
  // ─────────────────────────────────────────────

  List<CaseLaw> _parseCaseLaws(List<dynamic> raw, {required String path}) {
    final results = <CaseLaw>[];
    for (var i = 0; i < raw.length; i++) {
      final item = raw[i];
      try {
        if (item is Map<String, dynamic>) {
          results.add(CaseLaw.fromJson(item));
        } else {
          debugPrint('[$_tag] Skipping non-object at index $i in $path');
        }
      } catch (e) {
        debugPrint('[$_tag] Failed to parse case law at index $i in $path: $e');
      }
    }
    return results;
  }

  // ── CACHE MANAGEMENT ─────────────────────────

  void clearCache() {
    _index  = null;
    _loaded = false;
    debugPrint('[$_tag] Cache cleared.');
  }
}