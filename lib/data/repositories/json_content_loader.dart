// lib/data/repositories/json_content_loader.dart
// Law Briefly — JSON Asset Content Loader
// Offline-First | rootBundle | Error-Resilient | Future-Ready

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/legal_models.dart';

// ─────────────────────────────────────────────
// MARK: — CONTENT MANIFEST MODEL
// Drives which JSON files are loaded.
// Update manifest.json to add new Acts or Case Laws.
// ─────────────────────────────────────────────

class ContentManifest {
  final List<String> actPaths;
  final List<String> caseLawPaths;

  const ContentManifest({
    required this.actPaths,
    required this.caseLawPaths,
  });

  factory ContentManifest.fromJson(Map<String, dynamic> json) =>
      ContentManifest(
        actPaths:     List<String>.from(json['acts']       as List? ?? []),
        caseLawPaths: List<String>.from(json['case_laws']  as List? ?? []),
      );

  bool get isEmpty => actPaths.isEmpty && caseLawPaths.isEmpty;
}

// ─────────────────────────────────────────────
// MARK: — LOAD RESULT
// ─────────────────────────────────────────────

class LoadResult<T> {
  final List<T>   data;
  final List<String> errors;
  final int       filesAttempted;
  final int       filesLoaded;

  const LoadResult({
    required this.data,
    required this.errors,
    required this.filesAttempted,
    required this.filesLoaded,
  });

  bool get hasErrors => errors.isNotEmpty;
  bool get isEmpty   => data.isEmpty;
  bool get isPartial => filesLoaded < filesAttempted;
}

// ─────────────────────────────────────────────
// MARK: — JSON CONTENT LOADER
// ─────────────────────────────────────────────

class JsonContentLoader {
  static const String _tag = 'JsonContentLoader';

  // ── Asset paths ───────────────────────────────
  static const String _manifestPath      = 'assets/data/manifest.json';
  static const String _constitutionPath  =
      'assets/data/constitution/constitution_of_india.json';
  static const String _academicPath      =
      'assets/data/academic/academic_years.json';

  // ── Default fallback paths ────────────────────
  // Used when manifest.json is absent.
  static const List<String> _defaultActPaths = [
    'assets/data/acts/bharatiya_nyaya_sanhita_2023.json',
    'assets/data/acts/bharatiya_sakshya_adhiniyam_2023.json',
    'assets/data/acts/bharatiya_nagarik_suraksha_sanhita_2023.json',
    'assets/data/acts/indian_contract_act_1872.json',
    'assets/data/acts/code_of_civil_procedure_1908.json',
    'assets/data/acts/code_of_criminal_procedure_1973.json',
    'assets/data/acts/transfer_of_property_act_1882.json',
    'assets/data/acts/specific_relief_act_1963.json',
    'assets/data/acts/limitation_act_1963.json',
    'assets/data/acts/companies_act_2013.json',
    'assets/data/acts/information_technology_act_2000.json',
    'assets/data/acts/consumer_protection_act_2019.json',
    'assets/data/acts/right_to_information_act_2005.json',
  ];

  static const List<String> _defaultCaseLawPaths = [
    'assets/data/case_laws/criminal_law_cases.json',
    'assets/data/case_laws/constitutional_cases.json',
    'assets/data/case_laws/contract_law_cases.json',
    'assets/data/case_laws/evidence_law_cases.json',
    'assets/data/case_laws/property_law_cases.json',
    'assets/data/case_laws/labour_law_cases.json',
  ];

  // ── Cache ─────────────────────────────────────
  ContentManifest?         _manifest;
  List<Act>?               _cachedActs;
  List<ConstitutionPart>?  _cachedConstitution;
  List<CaseLaw>?           _cachedCaseLaws;
  List<AcademicYear>?      _cachedAcademicYears;

  // ─────────────────────────────────────────────
  // MARK: — MANIFEST
  // ─────────────────────────────────────────────

  Future<ContentManifest> _getManifest() async {
    if (_manifest != null) return _manifest!;

    try {
      final raw = await rootBundle.loadString(_manifestPath);
      if (raw.trim().isEmpty) {
        debugPrint('[$_tag] Manifest empty. Using defaults.');
        _manifest = const ContentManifest(
          actPaths: _defaultActPaths,
          caseLawPaths: _defaultCaseLawPaths,
        );
        return _manifest!;
      }
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Manifest must be a JSON object.');
      }
      _manifest = ContentManifest.fromJson(decoded);
      debugPrint(
        '[$_tag] Manifest loaded: ${_manifest!.actPaths.length} acts, '
        '${_manifest!.caseLawPaths.length} case law files.',
      );
    } on FlutterError {
      debugPrint('[$_tag] manifest.json not found. Using defaults.');
      _manifest = const ContentManifest(
        actPaths:     _defaultActPaths,
        caseLawPaths: _defaultCaseLawPaths,
      );
    } on FormatException catch (e) {
      debugPrint('[$_tag] Manifest JSON invalid: $e. Using defaults.');
      _manifest = const ContentManifest(
        actPaths:     _defaultActPaths,
        caseLawPaths: _defaultCaseLawPaths,
      );
    } catch (e) {
      debugPrint('[$_tag] Manifest load error: $e. Using defaults.');
      _manifest = const ContentManifest(
        actPaths:     _defaultActPaths,
        caseLawPaths: _defaultCaseLawPaths,
      );
    }

    return _manifest!;
  }

  // ─────────────────────────────────────────────
  // MARK: — LOAD ACTS
  // ─────────────────────────────────────────────

  Future<List<Act>> loadActs({bool forceRefresh = false}) async {
    if (_cachedActs != null && !forceRefresh) return _cachedActs!;

    final manifest = await _getManifest();
    final paths    = manifest.actPaths.isEmpty
        ? _defaultActPaths
        : manifest.actPaths;

    final result = await _loadList<Act>(
      paths:       paths,
      parser:      (data) {
        if (data is Map<String, dynamic>) {
          return Act.fromJson(data);
        }
        throw const FormatException('Act JSON must be an object.');
      },
      label: 'Act',
    );

    if (result.hasErrors) {
      debugPrint('[$_tag] Acts: ${result.errors.length} file(s) failed.');
    }
    debugPrint(
      '[$_tag] Loaded ${result.filesLoaded}/${result.filesAttempted} act files '
      '(${result.data.length} acts).',
    );

    _cachedActs = result.data;
    return _cachedActs!;
  }

  // ─────────────────────────────────────────────
  // MARK: — LOAD CONSTITUTION
  // ─────────────────────────────────────────────

  Future<List<ConstitutionPart>> loadConstitution({
    bool forceRefresh = false,
  }) async {
    if (_cachedConstitution != null && !forceRefresh) return _cachedConstitution!;

    try {
      final raw = await rootBundle.loadString(_constitutionPath);

      if (raw.trim().isEmpty) {
        debugPrint('[$_tag] Constitution JSON is empty.');
        _cachedConstitution = const [];
        return _cachedConstitution!;
      }

      final decoded = jsonDecode(raw);

      if (decoded is! List) {
        throw const FormatException(
          'Constitution JSON must be a root-level array of Parts.',
        );
      }

      final parts = (decoded as List<dynamic>)
          .map((item) {
            try {
              if (item is Map<String, dynamic>) {
                return ConstitutionPart.fromJson(item);
              }
              debugPrint('[$_tag] Skipping invalid Part entry: $item');
              return null;
            } catch (e) {
              debugPrint('[$_tag] Failed to parse ConstitutionPart: $e');
              return null;
            }
          })
          .whereType<ConstitutionPart>()
          .toList();

      debugPrint('[$_tag] Loaded ${parts.length} constitutional parts.');
      _cachedConstitution = parts;
      return _cachedConstitution!;
    } on FlutterError {
      debugPrint('[$_tag] Constitution file not found: $_constitutionPath');
      _cachedConstitution = const [];
    } on FormatException catch (e) {
      debugPrint('[$_tag] Constitution JSON invalid: $e');
      _cachedConstitution = const [];
    } catch (e) {
      debugPrint('[$_tag] Constitution load error: $e');
      _cachedConstitution = const [];
    }

    return _cachedConstitution!;
  }

  // ─────────────────────────────────────────────
  // MARK: — LOAD CASE LAWS
  // ─────────────────────────────────────────────

  Future<List<CaseLaw>> loadCaseLaws({bool forceRefresh = false}) async {
    if (_cachedCaseLaws != null && !forceRefresh) return _cachedCaseLaws!;

    final manifest = await _getManifest();
    final paths    = manifest.caseLawPaths.isEmpty
        ? _defaultCaseLawPaths
        : manifest.caseLawPaths;

    final result = await _loadList<CaseLaw>(
      paths:  paths,
      parser: (data) {
        if (data is Map<String, dynamic>) {
          return CaseLaw.fromJson(data);
        }
        throw const FormatException('CaseLaw JSON must be an object.');
      },
      label: 'CaseLaw',
      isArrayFile: true, // Each file is an array of CaseLaw objects
    );

    if (result.hasErrors) {
      debugPrint('[$_tag] Case laws: ${result.errors.length} file(s) failed.');
    }
    debugPrint(
      '[$_tag] Loaded ${result.filesLoaded}/${result.filesAttempted} case law files '
      '(${result.data.length} case laws).',
    );

    _cachedCaseLaws = result.data;
    return _cachedCaseLaws!;
  }

  // ─────────────────────────────────────────────
  // MARK: — LOAD ACADEMIC SUBJECTS (via Years)
  // ─────────────────────────────────────────────

  Future<List<AcademicYear>> loadAcademicYears({
    bool forceRefresh = false,
  }) async {
    if (_cachedAcademicYears != null && !forceRefresh) {
      return _cachedAcademicYears!;
    }

    try {
      final raw = await rootBundle.loadString(_academicPath);

      if (raw.trim().isEmpty) {
        debugPrint('[$_tag] Academic JSON is empty.');
        _cachedAcademicYears = const [];
        return _cachedAcademicYears!;
      }

      final decoded = jsonDecode(raw);

      if (decoded is! List) {
        throw const FormatException(
          'Academic JSON must be a root-level array of AcademicYear objects.',
        );
      }

      final years = (decoded as List<dynamic>)
          .map((item) {
            try {
              if (item is Map<String, dynamic>) {
                return AcademicYear.fromJson(item);
              }
              return null;
            } catch (e) {
              debugPrint('[$_tag] Failed to parse AcademicYear: $e');
              return null;
            }
          })
          .whereType<AcademicYear>()
          .toList();

      debugPrint(
        '[$_tag] Loaded ${years.length} academic years '
        '(${years.fold(0, (sum, y) => sum + y.subjectCount)} subjects).',
      );

      _cachedAcademicYears = years;
      return _cachedAcademicYears!;
    } on FlutterError {
      debugPrint('[$_tag] Academic file not found: $_academicPath');
      _cachedAcademicYears = const [];
    } on FormatException catch (e) {
      debugPrint('[$_tag] Academic JSON invalid: $e');
      _cachedAcademicYears = const [];
    } catch (e) {
      debugPrint('[$_tag] Academic load error: $e');
      _cachedAcademicYears = const [];
    }

    return _cachedAcademicYears!;
  }

  /// Flattened list of all academic subjects across all years.
  Future<List<AcademicSubject>> loadAcademicSubjects({
    bool forceRefresh = false,
  }) async {
    final years = await loadAcademicYears(forceRefresh: forceRefresh);
    return years.expand((y) => y.subjects).toList();
  }

  // ─────────────────────────────────────────────
  // MARK: — LOAD SPECIFIC ACT BY PATH
  // ─────────────────────────────────────────────

  Future<Act?> loadActFromPath(String path) async {
    try {
      final raw = await rootBundle.loadString(path);
      if (raw.trim().isEmpty) return null;
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      return Act.fromJson(decoded);
    } on FlutterError {
      debugPrint('[$_tag] Act file not found: $path');
      return null;
    } on FormatException catch (e) {
      debugPrint('[$_tag] Act JSON invalid at $path: $e');
      return null;
    } catch (e) {
      debugPrint('[$_tag] Act load error at $path: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // MARK: — CLEAR CACHE
  // ─────────────────────────────────────────────

  void clearCache() {
    _cachedActs          = null;
    _cachedConstitution  = null;
    _cachedCaseLaws      = null;
    _cachedAcademicYears = null;
    _manifest            = null;
    debugPrint('[$_tag] Cache cleared.');
  }

  // ─────────────────────────────────────────────
  // MARK: — PRIVATE: GENERIC LIST LOADER
  // ─────────────────────────────────────────────

  Future<LoadResult<T>> _loadList<T>({
    required List<String> paths,
    required T Function(dynamic data) parser,
    required String label,
    bool isArrayFile = false,
  }) async {
    final results     = <T>[];
    final errors      = <String>[];
    int filesLoaded   = 0;

    for (final path in paths) {
      try {
        final raw = await rootBundle.loadString(path);

        if (raw.trim().isEmpty) {
          debugPrint('[$_tag] Empty file skipped: $path');
          errors.add('$path: empty file');
          continue;
        }

        final dynamic decoded = jsonDecode(raw);

        if (isArrayFile) {
          // File contains an array of objects (e.g., case law files)
          if (decoded is! List) {
            throw FormatException(
              '$label array file must be a JSON array: $path',
            );
          }
          int count = 0;
          for (final item in decoded as List<dynamic>) {
            try {
              results.add(parser(item));
              count++;
            } catch (e) {
              debugPrint('[$_tag] Skipping invalid $label item in $path: $e');
            }
          }
          if (count > 0) filesLoaded++;
          debugPrint('[$_tag] Loaded $count ${label}s from $path.');
        } else {
          // File contains a single object
          results.add(parser(decoded));
          filesLoaded++;
          debugPrint('[$_tag] Loaded $label from $path.');
        }
      } on FlutterError {
        debugPrint('[$_tag] $label file not found: $path');
        errors.add('$path: file not found');
      } on FormatException catch (e) {
        debugPrint('[$_tag] $label JSON invalid at $path: $e');
        errors.add('$path: invalid JSON — $e');
      } catch (e) {
        debugPrint('[$_tag] $label load error at $path: $e');
        errors.add('$path: $e');
      }
    }

    return LoadResult<T>(
      data:           results,
      errors:         errors,
      filesAttempted: paths.length,
      filesLoaded:    filesLoaded,
    );
  }
}