import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/reader_content.dart';
import 'reader_repository.dart';

// ─────────────────────────────────────────────
// MARK: — READER REPOSITORY EXCEPTION
// ─────────────────────────────────────────────

class ReaderRepositoryException implements Exception {
  final String  message;
  final String? path;
  final Object? cause;

  const ReaderRepositoryException({
    required this.message,
    this.path,
    this.cause,
  });

  @override
  String toString() =>
      'ReaderRepositoryException: $message'
      '${path  != null ? " [path: $path]"     : ""}'
      '${cause != null ? " — cause: $cause"   : ""}';
}

// ─────────────────────────────────────────────
// MARK: — READER REPOSITORY IMPL
// ─────────────────────────────────────────────

class ReaderRepositoryImpl implements ReaderRepository {
  static const String _tag = 'ReaderRepositoryImpl';

  // ── Path builders ─────────────────────────────
  static String _actPath(String actId) =>
      'assets/data/acts/$actId.json';

  static String _constitutionPartPath(String partId) =>
      'assets/data/constitution/constitution_$partId.json';

  // ── Simple in-memory cache ────────────────────
  final Map<String, dynamic> _actCache         = {};
  final Map<String, dynamic> _constitutionCache = {};

  // ─────────────────────────────────────────────
  // MARK: — GET ACT SECTION
  // ─────────────────────────────────────────────

  @override
  Future<ReaderContent?> getActSection({
    required String actId,
    required String sectionId,
  }) async {
    try {
      final actJson = await _loadActJson(actId);
      if (actJson == null) {
        debugPrint('[$_tag] Act not found: $actId');
        return null;
      }

      final actTitle   = actJson['title']      as String? ?? '';
      final chapters   = actJson['chapters']   as List<dynamic>? ?? [];

      for (final chapterRaw in chapters) {
        if (chapterRaw is! Map<String, dynamic>) continue;
        final sections = chapterRaw['sections'] as List<dynamic>? ?? [];

        final sectionIndex = sections.indexWhere(
            (s) => s is Map && (s as Map)['id'] == sectionId);

        if (sectionIndex < 0) continue;

        final section = sections[sectionIndex] as Map<String, dynamic>;

        // Build previous/next IDs within the chapter
        final previousId = sectionIndex > 0
            ? (sections[sectionIndex - 1] as Map)['id'] as String?
            : null;
        final nextId = sectionIndex < sections.length - 1
            ? (sections[sectionIndex + 1] as Map)['id'] as String?
            : null;

        return _parseActSectionContent(
          section:        section,
          actId:          actId,
          actTitle:       actTitle,
          chapterId:      chapterRaw['id']    as String?,
          chapterTitle:   chapterRaw['title'] as String?,
          previousId:     previousId,
          nextId:         nextId,
        );
      }

      debugPrint('[$_tag] Section "$sectionId" not found in act "$actId"');
      return null;
    } on ReaderRepositoryException {
      rethrow;
    } catch (e) {
      debugPrint('[$_tag] getActSection error: $e');
      throw ReaderRepositoryException(
        message: 'Failed to load act section.',
        cause:   e,
      );
    }
  }

  // ─────────────────────────────────────────────
  // MARK: — GET CONSTITUTION ARTICLE
  // ─────────────────────────────────────────────

  @override
  Future<ReaderContent?> getConstitutionArticle({
    required String partId,
    required String articleId,
  }) async {
    try {
      final partJson = await _loadConstitutionJson(partId);
      if (partJson == null) {
        debugPrint('[$_tag] Constitution part not found: $partId');
        return null;
      }

      final partTitle = partJson['title']    as String? ?? '';
      final articles  = partJson['articles'] as List<dynamic>? ?? [];

      final articleIndex = articles.indexWhere(
          (a) => a is Map && (a as Map)['id'] == articleId);

      if (articleIndex < 0) {
        debugPrint('[$_tag] Article "$articleId" not found in part "$partId"');
        return null;
      }

      final article    = articles[articleIndex]    as Map<String, dynamic>;
      final previousId = articleIndex > 0
          ? (articles[articleIndex - 1] as Map)['id'] as String?
          : null;
      final nextId     = articleIndex < articles.length - 1
          ? (articles[articleIndex + 1] as Map)['id'] as String?
          : null;

      return _parseConstitutionArticleContent(
        article:    article,
        partId:     partId,
        partTitle:  partTitle,
        previousId: previousId,
        nextId:     nextId,
      );
    } on ReaderRepositoryException {
      rethrow;
    } catch (e) {
      debugPrint('[$_tag] getConstitutionArticle error: $e');
      throw ReaderRepositoryException(
        message: 'Failed to load constitution article.',
        cause:   e,
      );
    }
  }

  // ─────────────────────────────────────────────
  // MARK: — NAVIGATION (placeholder architecture)
  // ─────────────────────────────────────────────

  @override
  Future<ReaderContent?> getNextContent({
    required ReaderContent currentContent,
  }) async {
    final nextId = currentContent.nextId;
    if (nextId == null) return null;

    if (currentContent.isActSection && currentContent.actId != null) {
      return getActSection(
        actId:     currentContent.actId!,
        sectionId: nextId,
      );
    }

    if (currentContent.isArticle && currentContent.partId != null) {
      return getConstitutionArticle(
        partId:    currentContent.partId!,
        articleId: nextId,
      );
    }

    return null;
  }

  @override
  Future<ReaderContent?> getPreviousContent({
    required ReaderContent currentContent,
  }) async {
    final prevId = currentContent.previousId;
    if (prevId == null) return null;

    if (currentContent.isActSection && currentContent.actId != null) {
      return getActSection(
        actId:     currentContent.actId!,
        sectionId: prevId,
      );
    }

    if (currentContent.isArticle && currentContent.partId != null) {
      return getConstitutionArticle(
        partId:    currentContent.partId!,
        articleId: prevId,
      );
    }

    return null;
  }

  // ─────────────────────────────────────────────
  // MARK: — PRIVATE: LOAD HELPERS
  // ─────────────────────────────────────────────

  Future<Map<String, dynamic>?> _loadActJson(String actId) async {
    if (_actCache.containsKey(actId)) {
      return _actCache[actId] as Map<String, dynamic>;
    }
    return _loadJson(
      path:  _actPath(actId),
      cache: _actCache,
      key:   actId,
    );
  }

  Future<Map<String, dynamic>?> _loadConstitutionJson(String partId) async {
    if (_constitutionCache.containsKey(partId)) {
      return _constitutionCache[partId] as Map<String, dynamic>;
    }
    return _loadJson(
      path:  _constitutionPartPath(partId),
      cache: _constitutionCache,
      key:   partId,
    );
  }

  Future<Map<String, dynamic>?> _loadJson({
    required String                     path,
    required Map<String, dynamic>       cache,
    required String                     key,
  }) async {
    try {
      final raw = await rootBundle.loadString(path);
      if (raw.trim().isEmpty) {
        debugPrint('[$_tag] Empty JSON file: $path');
        return null;
      }
      final dynamic decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Root JSON element must be an object.');
      }
      cache[key] = decoded;
      return decoded;
    } on FlutterError catch (e) {
      debugPrint('[$_tag] Asset not found: $path');
      throw ReaderRepositoryException(
        message: 'Asset file not found.',
        path:    path,
        cause:   e,
      );
    } on FormatException catch (e) {
      debugPrint('[$_tag] JSON parse error in $path: $e');
      throw ReaderRepositoryException(
        message: 'Invalid JSON structure.',
        path:    path,
        cause:   e,
      );
    }
  }

  // ─────────────────────────────────────────────
  // MARK: — PRIVATE: PARSE HELPERS
  // ─────────────────────────────────────────────

  ReaderContent _parseActSectionContent({
    required Map<String, dynamic> section,
    required String               actId,
    required String               actTitle,
    String?                       chapterId,
    String?                       chapterTitle,
    String?                       previousId,
    String?                       nextId,
  }) {
    return ReaderContent(
      id:           section['id']             as String,
      number:       section['section_number'] as String? ?? '',
      title:        section['title']          as String? ?? '',
      content:      _parseContentBlocks(section['content']),
      caseLawIds:   List<String>.from(section['case_law_ids'] as List? ?? []),
      actId:        actId,
      actTitle:     actTitle,
      chapterId:    chapterId,
      chapterTitle: chapterTitle,
      previousId:   previousId,
      nextId:       nextId,
    );
  }

  ReaderContent _parseConstitutionArticleContent({
    required Map<String, dynamic> article,
    required String               partId,
    required String               partTitle,
    String?                       previousId,
    String?                       nextId,
  }) {
    final number = article['article_number'] as String? ?? '';

    return ReaderContent(
      id:         article['id'] as String,
      number:     number,
      title:      article['title'] as String? ?? '',
      content:    _parseContentBlocks(article['content']),
      caseLawIds: List<String>.from(article['case_law_ids'] as List? ?? []),
      partId:     partId,
      partTitle:  partTitle,
      previousId: previousId,
      nextId:     nextId,
    );
  }

  List<ContentBlock> _parseContentBlocks(dynamic raw) {
    if (raw == null) return const [];
    if (raw is! List) return const [];

    final result = <ContentBlock>[];
    for (final item in raw) {
      try {
        if (item is Map<String, dynamic>) {
          result.add(ContentBlock.fromJson(item));
        }
      } catch (e) {
        debugPrint('[$_tag] Skipping malformed content block: $e');
      }
    }
    return result;
  }

  // ── CACHE MANAGEMENT ─────────────────────────

  void clearCache() {
    _actCache.clear();
    _constitutionCache.clear();
    debugPrint('[$_tag] Cache cleared.');
  }
}