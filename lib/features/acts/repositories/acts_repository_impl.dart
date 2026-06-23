import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

// ─────────────────────────────────────────────
// MARK: — REPOSITORY EXCEPTIONS
// ─────────────────────────────────────────────

class ActsRepositoryException implements Exception {
  final String  message;
  final String? path;
  final Object? cause;
  const ActsRepositoryException({required this.message, this.path, this.cause});

  @override
  String toString() =>
      'ActsRepositoryException: $message'
      '${path  != null ? ' [path: $path]'   : ''}'
      '${cause != null ? ' caused by: $cause' : ''}';
}

class ActsNotFoundException extends ActsRepositoryException {
  const ActsNotFoundException(String id)
      : super(message: 'Act not found: $id');
}

class ActsParseException extends ActsRepositoryException {
  const ActsParseException({required String path, required Object cause})
      : super(message: 'Failed to parse act JSON', path: path, cause: cause);
}

class ActsLoadException extends ActsRepositoryException {
  const ActsLoadException({required String path, required Object cause})
      : super(message: 'Failed to load act asset', path: path, cause: cause);
}

// ─────────────────────────────────────────────
// MARK: — ABSTRACT CONTRACT
// ─────────────────────────────────────────────

abstract class ActsRepository {
  Future<List<ActModel>>     getAllActs();
  Future<ActModel?>          getActById(String id);
  Future<List<ChapterModel>> getChapters(String actId);
  Future<List<SectionModel>> getSections(String actId, String chapterId);
  Future<SectionModel?>      getSection(String actId, String sectionId);
  Future<void>               clearCache();
}

// ─────────────────────────────────────────────
// MARK: — MANIFEST MODEL
// ─────────────────────────────────────────────

class _ActsManifest {
  final List<String> actPaths;
  const _ActsManifest({required this.actPaths});

  factory _ActsManifest.fromJson(Map<String, dynamic> json) => _ActsManifest(
        actPaths: List<String>.from(json['acts'] as List? ?? []),
      );

  factory _ActsManifest.defaults() => const _ActsManifest(
        actPaths: [
          'assets/data/acts/bns_2023.json',
          'assets/data/acts/bsa_2023.json',
          'assets/data/acts/bnss_2023.json',
          'assets/data/acts/indian_contract_act_1872.json',
          'assets/data/acts/code_of_civil_procedure_1908.json',
          'assets/data/acts/transfer_of_property_act_1882.json',
          'assets/data/acts/specific_relief_act_1963.json',
          'assets/data/acts/consumer_protection_act_2019.json',
          'assets/data/acts/information_technology_act_2000.json',
          'assets/data/acts/companies_act_2013.json',
        ],
      );
}

// ─────────────────────────────────────────────
// MARK: — IMPLEMENTATION
// ─────────────────────────────────────────────

class ActsRepositoryImpl implements ActsRepository {
  static const String _manifestPath = 'assets/data/manifest.json';
  static const String _tag          = 'ActsRepositoryImpl';

  // ── In-memory cache ───────────────────────────
  _ActsManifest?              _manifest;
  final Map<String, ActModel> _actCache = {};
  List<ActModel>?             _allActsCache;

  // ─────────────────────────────────────────────
  // MARK: — MANIFEST
  // ─────────────────────────────────────────────

  Future<_ActsManifest> _getManifest() async {
    if (_manifest != null) return _manifest!;

    try {
      final raw  = await rootBundle.loadString(_manifestPath);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      _manifest  = _ActsManifest.fromJson(json);
      debugPrint('[$_tag] Manifest loaded: ${_manifest!.actPaths.length} acts.');
    } catch (_) {
      debugPrint('[$_tag] No manifest found. Using default paths.');
      _manifest = _ActsManifest.defaults();
    }

    return _manifest!;
  }

  // ─────────────────────────────────────────────
  // MARK: — LOAD SINGLE ACT FROM ASSET
  // ─────────────────────────────────────────────

  Future<ActModel?> _loadActFromPath(String path) async {
    try {
      final raw = await rootBundle.loadString(path);

      if (raw.trim().isEmpty) {
        debugPrint('[$_tag] Empty file: $path');
        return null;
      }

      final dynamic decoded = jsonDecode(raw);

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Act JSON must be a root-level object.');
      }

      final act = ActModel.fromJson(decoded);
      debugPrint('[$_tag] Loaded: ${act.id} (${act.chapters.length} chapters)');
      return act;
    } on FlutterError catch (e) {
      debugPrint('[$_tag] Asset not found: $path');
      throw ActsLoadException(path: path, cause: e);
    } on FormatException catch (e) {
      debugPrint('[$_tag] JSON parse error in $path: $e');
      throw ActsParseException(path: path, cause: e);
    } catch (e) {
      if (e is ActsRepositoryException) rethrow;
      debugPrint('[$_tag] Unexpected error loading $path: $e');
      throw ActsLoadException(path: path, cause: e);
    }
  }

  // ─────────────────────────────────────────────
  // MARK: — GET ALL ACTS
  // ─────────────────────────────────────────────

  @override
  Future<List<ActModel>> getAllActs() async {
    if (_allActsCache != null) return List.unmodifiable(_allActsCache!);

    final manifest = await _getManifest();
    final acts     = <ActModel>[];

    await Future.wait(
      manifest.actPaths.map((path) async {
        try {
          final act = await _loadActFromPath(path);
          if (act != null) {
            acts.add(act);
            _actCache[act.id] = act;
          }
        } on ActsRepositoryException catch (e) {
          // Log but don't fail — allow partial loading
          debugPrint('[$_tag] Skipping $path: $e');
        }
      }),
    );

    // Sort by year descending (newest first)
    acts.sort((a, b) => b.year.compareTo(a.year));
    _allActsCache = acts;

    debugPrint('[$_tag] getAllActs: ${acts.length} acts loaded.');
    return List.unmodifiable(acts);
  }

  // ─────────────────────────────────────────────
  // MARK: — GET ACT BY ID
  // ─────────────────────────────────────────────

  @override
  Future<ActModel?> getActById(String id) async {
    // Serve from cache if available
    if (_actCache.containsKey(id)) return _actCache[id];

    // Ensure all acts are loaded
    final acts = await getAllActs();

    try {
      final act = acts.firstWhere((a) => a.id == id);
      _actCache[act.id] = act;
      return act;
    } on StateError {
      debugPrint('[$_tag] Act not found: $id');
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // MARK: — GET CHAPTERS
  // ─────────────────────────────────────────────

  @override
  Future<List<ChapterModel>> getChapters(String actId) async {
    final act = await getActById(actId);

    if (act == null) {
      throw ActsNotFoundException(actId);
    }

    debugPrint('[$_tag] getChapters($actId): ${act.chapters.length} chapters.');
    return List.unmodifiable(act.chapters);
  }

  // ─────────────────────────────────────────────
  // MARK: — GET SECTIONS
  // ─────────────────────────────────────────────

  @override
  Future<List<SectionModel>> getSections(
      String actId, String chapterId) async {
    final act = await getActById(actId);

    if (act == null) throw ActsNotFoundException(actId);

    try {
      final chapter = act.chapters.firstWhere((c) => c.id == chapterId);
      debugPrint('[$_tag] getSections($actId, $chapterId): ${chapter.sections.length} sections.');
      return List.unmodifiable(chapter.sections);
    } on StateError {
      debugPrint('[$_tag] Chapter not found: $chapterId in act $actId');
      return const [];
    }
  }

  // ─────────────────────────────────────────────
  // MARK: — GET SECTION
  // ─────────────────────────────────────────────

  @override
  Future<SectionModel?> getSection(String actId, String sectionId) async {
    final act = await getActById(actId);
    if (act == null) return null;

    for (final chapter in act.chapters) {
      try {
        final section = chapter.sections.firstWhere((s) => s.id == sectionId);
        debugPrint('[$_tag] getSection($sectionId): found in chapter ${chapter.id}');
        return section;
      } on StateError {
        continue;
      }
    }

    debugPrint('[$_tag] Section not found: $sectionId in act $actId');
    return null;
  }

  // ─────────────────────────────────────────────
  // MARK: — CLEAR CACHE
  // ─────────────────────────────────────────────

  @override
  Future<void> clearCache() async {
    _manifest     = null;
    _allActsCache = null;
    _actCache.clear();
    debugPrint('[$_tag] Cache cleared.');
  }
}

// ─────────────────────────────────────────────
// MARK: — MODEL STUBS (models assumed to exist)
// These type aliases clarify the expected interface.
// Replace with imports from your models file.
// ─────────────────────────────────────────────

// ignore: non_constant_identifier_names
// Assumed: import '../../../data/models/legal_models.dart';
// ActModel     = Act     from legal_models.dart
// ChapterModel = Chapter from legal_models.dart
// SectionModel = Section from legal_models.dart

typedef ActModel     = Act;
typedef ChapterModel = Chapter;
typedef SectionModel = Section;

// Import at top of file:
import '../../../data/models/legal_models.dart';