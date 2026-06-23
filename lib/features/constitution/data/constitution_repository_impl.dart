import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

import '../../../data/models/legal_models.dart';

// ─────────────────────────────────────────────
// MARK: — EXCEPTIONS
// ─────────────────────────────────────────────

class ConstitutionRepositoryException implements Exception {
  final String  message;
  final String? path;
  final Object? cause;

  const ConstitutionRepositoryException({
    required this.message,
    this.path,
    this.cause,
  });

  @override
  String toString() =>
      'ConstitutionRepositoryException: $message'
      '${path  != null ? ' [path: $path]'      : ''}'
      '${cause != null ? ' caused by: $cause' : ''}';
}

class ConstitutionNotFoundException extends ConstitutionRepositoryException {
  const ConstitutionNotFoundException(String id)
      : super(message: 'Constitution part not found: $id');
}

class ConstitutionParseException extends ConstitutionRepositoryException {
  const ConstitutionParseException({required String path, required Object cause})
      : super(message: 'Failed to parse constitution JSON', path: path, cause: cause);
}

class ConstitutionLoadException extends ConstitutionRepositoryException {
  const ConstitutionLoadException({required String path, required Object cause})
      : super(message: 'Failed to load constitution asset', path: path, cause: cause);
}

// ─────────────────────────────────────────────
// MARK: — TYPE ALIASES (assumed models)
// ─────────────────────────────────────────────

typedef ConstitutionPartModel = ConstitutionPart;
typedef ArticleModel          = Article;

// ─────────────────────────────────────────────
// MARK: — MANIFEST
// ─────────────────────────────────────────────

class _ConstitutionManifest {
  final List<String> partPaths;
  const _ConstitutionManifest({required this.partPaths});

  factory _ConstitutionManifest.fromJson(Map<String, dynamic> json) =>
      _ConstitutionManifest(
        partPaths: List<String>.from(json['constitution_parts'] as List? ?? []),
      );

  factory _ConstitutionManifest.defaults() => const _ConstitutionManifest(
        partPaths: [
          'assets/data/constitution/constitution_part_1.json',
          'assets/data/constitution/constitution_part_2.json',
          'assets/data/constitution/constitution_part_3.json',
          'assets/data/constitution/constitution_part_4.json',
          'assets/data/constitution/constitution_part_4a.json',
          'assets/data/constitution/constitution_part_5.json',
          'assets/data/constitution/constitution_part_6.json',
          'assets/data/constitution/constitution_part_7.json',
          'assets/data/constitution/constitution_part_8.json',
          'assets/data/constitution/constitution_part_9.json',
          'assets/data/constitution/constitution_part_9a.json',
          'assets/data/constitution/constitution_part_9b.json',
          'assets/data/constitution/constitution_part_10.json',
          'assets/data/constitution/constitution_part_11.json',
          'assets/data/constitution/constitution_part_12.json',
          'assets/data/constitution/constitution_part_13.json',
          'assets/data/constitution/constitution_part_14.json',
          'assets/data/constitution/constitution_part_14a.json',
          'assets/data/constitution/constitution_part_15.json',
          'assets/data/constitution/constitution_part_16.json',
          'assets/data/constitution/constitution_part_17.json',
          'assets/data/constitution/constitution_part_18.json',
          'assets/data/constitution/constitution_part_19.json',
          'assets/data/constitution/constitution_part_20.json',
          'assets/data/constitution/constitution_part_21.json',
          'assets/data/constitution/constitution_part_22.json',
        ],
      );
}

// ─────────────────────────────────────────────
// MARK: — ABSTRACT CONTRACT
// ─────────────────────────────────────────────

abstract class ConstitutionRepository {
  Future<List<ConstitutionPartModel>> getAllParts();
  Future<ConstitutionPartModel?>      getPartById(String partId);
  Future<List<ArticleModel>>          getArticles(String partId);
  Future<ArticleModel?>               getArticle(String articleId);
  Future<void>                        clearCache();
}

// ─────────────────────────────────────────────
// MARK: — IMPLEMENTATION
// ─────────────────────────────────────────────

class ConstitutionRepositoryImpl implements ConstitutionRepository {
  static const String _manifestPath = 'assets/data/manifest.json';
  static const String _tag          = 'ConstitutionRepositoryImpl';

  // ── In-memory cache ───────────────────────────
  _ConstitutionManifest?                  _manifest;
  final Map<String, ConstitutionPartModel> _partCache  = {};
  List<ConstitutionPartModel>?             _allPartsCache;

  // ─────────────────────────────────────────────
  // MARK: — MANIFEST
  // ─────────────────────────────────────────────

  Future<_ConstitutionManifest> _getManifest() async {
    if (_manifest != null) return _manifest!;

    try {
      final raw  = await rootBundle.loadString(_manifestPath);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      _manifest  = _ConstitutionManifest.fromJson(json);
      debugPrint(
        '[$_tag] Manifest loaded: ${_manifest!.partPaths.length} constitution parts.',
      );
    } catch (_) {
      debugPrint('[$_tag] No manifest. Using default part paths.');
      _manifest = _ConstitutionManifest.defaults();
    }

    return _manifest!;
  }

  // ─────────────────────────────────────────────
  // MARK: — LOAD SINGLE PART FROM ASSET
  // ─────────────────────────────────────────────

  Future<ConstitutionPartModel?> _loadPartFromPath(String path) async {
    try {
      final raw = await rootBundle.loadString(path);

      if (raw.trim().isEmpty) {
        debugPrint('[$_tag] Empty file: $path');
        return null;
      }

      final dynamic decoded = jsonDecode(raw);

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException(
          'Constitution part JSON must be a root-level object.',
        );
      }

      final part = ConstitutionPartModel.fromJson(decoded);
      debugPrint(
        '[$_tag] Loaded: Part ${part.partNumber} (${part.articles.length} articles)',
      );
      return part;
    } on FlutterError catch (e) {
      debugPrint('[$_tag] Asset not found: $path');
      throw ConstitutionLoadException(path: path, cause: e);
    } on FormatException catch (e) {
      debugPrint('[$_tag] JSON parse error in $path: $e');
      throw ConstitutionParseException(path: path, cause: e);
    } catch (e) {
      if (e is ConstitutionRepositoryException) rethrow;
      debugPrint('[$_tag] Unexpected error loading $path: $e');
      throw ConstitutionLoadException(path: path, cause: e);
    }
  }

  // ─────────────────────────────────────────────
  // MARK: — GET ALL PARTS
  // ─────────────────────────────────────────────

  @override
  Future<List<ConstitutionPartModel>> getAllParts() async {
    if (_allPartsCache != null) return List.unmodifiable(_allPartsCache!);

    final manifest = await _getManifest();
    final parts    = <ConstitutionPartModel>[];

    await Future.wait(
      manifest.partPaths.map((path) async {
        try {
          final part = await _loadPartFromPath(path);
          if (part != null) {
            parts.add(part);
            _partCache[part.id] = part;
          }
        } on ConstitutionRepositoryException catch (e) {
          debugPrint('[$_tag] Skipping $path: $e');
        }
      }),
    );

    // Sort by Roman numeral part number
    parts.sort((a, b) => _comparePartNumbers(a.partNumber, b.partNumber));
    _allPartsCache = parts;

    debugPrint('[$_tag] getAllParts: ${parts.length} parts loaded.');
    return List.unmodifiable(parts);
  }

  // ─────────────────────────────────────────────
  // MARK: — GET PART BY ID
  // ─────────────────────────────────────────────

  @override
  Future<ConstitutionPartModel?> getPartById(String partId) async {
    if (_partCache.containsKey(partId)) return _partCache[partId];

    final parts = await getAllParts();

    try {
      final part = parts.firstWhere((p) => p.id == partId);
      _partCache[part.id] = part;
      return part;
    } on StateError {
      debugPrint('[$_tag] Part not found: $partId');
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // MARK: — GET ARTICLES
  // ─────────────────────────────────────────────

  @override
  Future<List<ArticleModel>> getArticles(String partId) async {
    final part = await getPartById(partId);

    if (part == null) {
      throw ConstitutionNotFoundException(partId);
    }

    debugPrint('[$_tag] getArticles($partId): ${part.articles.length} articles.');
    return List.unmodifiable(part.articles);
  }

  // ─────────────────────────────────────────────
  // MARK: — GET ARTICLE BY ID
  // ─────────────────────────────────────────────

  @override
  Future<ArticleModel?> getArticle(String articleId) async {
    // Check cache first
    for (final part in _partCache.values) {
      try {
        final article = part.articles.firstWhere((a) => a.id == articleId);
        debugPrint('[$_tag] getArticle($articleId): found in Part ${part.partNumber}');
        return article;
      } on StateError {
        continue;
      }
    }

    // Full load if not in cache
    final allParts = await getAllParts();
    for (final part in allParts) {
      try {
        final article = part.articles.firstWhere((a) => a.id == articleId);
        debugPrint('[$_tag] getArticle($articleId): found in Part ${part.partNumber}');
        return article;
      } on StateError {
        continue;
      }
    }

    debugPrint('[$_tag] Article not found: $articleId');
    return null;
  }

  // ─────────────────────────────────────────────
  // MARK: — CLEAR CACHE
  // ─────────────────────────────────────────────

  @override
  Future<void> clearCache() async {
    _manifest      = null;
    _allPartsCache = null;
    _partCache.clear();
    debugPrint('[$_tag] Cache cleared.');
  }

  // ─────────────────────────────────────────────
  // MARK: — HELPERS
  // ─────────────────────────────────────────────

  static const Map<String, int> _romanValues = {
    'I': 1, 'II': 2, 'III': 3, 'IV': 4, 'V': 5,
    'VI': 6, 'VII': 7, 'VIII': 8, 'IX': 9, 'X': 10,
    'XI': 11, 'XII': 12, 'XIII': 13, 'XIV': 14, 'XV': 15,
    'XVI': 16, 'XVII': 17, 'XVIII': 18, 'XIX': 19, 'XX': 20,
    'XXI': 21, 'XXII': 22,
  };

  int _comparePartNumbers(String a, String b) {
    // Strip suffixes for comparison (IVA → IV)
    final aBase = a.replaceAll(RegExp(r'[A-Z]$'), '');
    final bBase = b.replaceAll(RegExp(r'[A-Z]$'), '');
    final aVal  = _romanValues[aBase] ?? 99;
    final bVal  = _romanValues[bBase] ?? 99;

    if (aVal != bVal) return aVal.compareTo(bVal);
    // Same base: compare suffix (no suffix < A < B)
    final aSuffix = a.length > aBase.length ? a.substring(aBase.length) : '';
    final bSuffix = b.length > bBase.length ? b.substring(bBase.length) : '';
    return aSuffix.compareTo(bSuffix);
  }
}