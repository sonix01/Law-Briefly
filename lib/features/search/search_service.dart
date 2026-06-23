// lib/features/search/search_service.dart
// Law Briefly — Search Service
// MVP: Acts Search | Future: Sections, Articles, Case Laws, AI

import 'package:flutter/foundation.dart';

import '../../data/models/legal_models.dart';
import '../../data/repositories/legal_repository.dart';
import 'search_models.dart';

// ─────────────────────────────────────────────
// MARK: — SEARCH SERVICE
// ─────────────────────────────────────────────

class SearchService {
  // ── Dependencies ──────────────────────────────
  final LegalRepository _repository;

  // ── Session cache ─────────────────────────────
  // Avoids redundant repository fetches during a typing session.
  List<Act>? _cachedActs;

  // ─────────────────────────────────────────────
  // MARK: — CONSTRUCTOR
  // ─────────────────────────────────────────────

  SearchService(this._repository);

  // ─────────────────────────────────────────────
  // MARK: — SEARCH ACTS  (MVP)
  // ─────────────────────────────────────────────

  /// Searches all acts by title, short title, year, and category.
  /// Returns an empty list if [query] is blank.
  Future<List<SearchResult>> searchActs(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];

    try {
      _cachedActs ??= await _repository.getActs();

      final results = <SearchResult>[];

      for (final act in _cachedActs!) {
        double score = 0.0;
        String? excerpt;

        final titleLower     = act.title.toLowerCase();
        final shortLower     = act.shortTitle?.toLowerCase() ?? '';
        final yearStr        = act.year.toString();
        final categoryLabel  = act.category.name.toLowerCase();

        // Exact match → highest score
        if (titleLower == q || shortLower == q) {
          score = 1.0;
        }
        // Starts with → high score
        else if (titleLower.startsWith(q) || shortLower.startsWith(q)) {
          score = 0.85;
        }
        // Contains in title → medium score
        else if (titleLower.contains(q)) {
          score = 0.70;
          excerpt = _buildExcerpt(act.title, query);
        }
        // Matches short title → medium score
        else if (shortLower.isNotEmpty && shortLower.contains(q)) {
          score = 0.65;
        }
        // Matches year → lower score
        else if (yearStr.contains(q)) {
          score = 0.40;
        }
        // Matches category → lowest score
        else if (categoryLabel.contains(q)) {
          score = 0.20;
        }
        // Description match (if available)
        else if (act.description?.toLowerCase().contains(q) ?? false) {
          score = 0.30;
          excerpt = _buildExcerpt(act.description!, query);
        } else {
          continue; // No match
        }

        results.add(SearchResult(
          id:             act.id,
          title:          act.displayTitle,
          subtitle:       _actSubtitle(act),
          searchType:     SearchType.act,
          excerpt:        excerpt,
          sourceId:       act.id,
          sourceName:     act.title,
          relevanceScore: score,
          metadata: {
            'year':            act.year,
            'category':        act.category.name,
            'chapter_count':   act.chapterCount,
            'section_count':   act.totalSections,
            'is_active':       act.isActive,
          },
        ));
      }

      // Sort by relevance score descending
      results.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));

      debugPrint(
        '[SearchService] searchActs("$q") → ${results.length} result(s)',
      );

      return results;
    } catch (e) {
      debugPrint('[SearchService] searchActs error: $e');
      return const [];
    }
  }

  // ─────────────────────────────────────────────
  // MARK: — SEARCH SECTIONS (Future)
  // ─────────────────────────────────────────────

  /// Future: full-text search across all sections in all acts.
  /// Currently returns an empty list.
  ///
  /// Implementation plan:
  /// 1. Load all acts (or use Isar full-text index).
  /// 2. Iterate chapters → sections.
  /// 3. Match sectionNumber, title, and content blocks.
  /// 4. Return ranked SearchResult(type: SearchType.section).
  Future<List<SearchResult>> searchSections(String query) async {
    if (query.trim().isEmpty) return const [];
    debugPrint('[SearchService] searchSections: not yet implemented.');
    return const [];
  }

  // ─────────────────────────────────────────────
  // MARK: — SEARCH ARTICLES (Future)
  // ─────────────────────────────────────────────

  /// Future: full-text search across all Constitution articles.
  /// Currently returns an empty list.
  ///
  /// Implementation plan:
  /// 1. Load all ConstitutionParts.
  /// 2. Iterate articles.
  /// 3. Match articleNumber, title, and content.
  /// 4. Return ranked SearchResult(type: SearchType.article).
  Future<List<SearchResult>> searchArticles(String query) async {
    if (query.trim().isEmpty) return const [];
    debugPrint('[SearchService] searchArticles: not yet implemented.');
    return const [];
  }

  // ─────────────────────────────────────────────
  // MARK: — SEARCH CASE LAWS (Future)
  // ─────────────────────────────────────────────

  /// Future: full-text search across all case laws.
  /// Currently returns an empty list.
  ///
  /// Implementation plan:
  /// 1. Load all CaseLaws.
  /// 2. Match title, citation, facts, significance.
  /// 3. Return ranked SearchResult(type: SearchType.caseLaw).
  Future<List<SearchResult>> searchCaseLaws(String query) async {
    if (query.trim().isEmpty) return const [];
    debugPrint('[SearchService] searchCaseLaws: not yet implemented.');
    return const [];
  }

  // ─────────────────────────────────────────────
  // MARK: — SEARCH ALL (Combined)
  // ─────────────────────────────────────────────

  /// Searches across all enabled content types.
  ///
  /// MVP: acts only.
  /// Future: pass [types] to include sections, articles, case laws.
  Future<SearchResponse> searchAll(
    String query, {
    Set<SearchType> types = const {SearchType.act},
    int             limit = 30,
  }) async {
    final q = query.trim();
    if (q.isEmpty) return SearchResponse.empty(q);

    final stopwatch = Stopwatch()..start();
    final allResults = <SearchResult>[];

    await Future.wait([
      if (types.contains(SearchType.act))
        searchActs(q).then(allResults.addAll),
      if (types.contains(SearchType.section))
        searchSections(q).then(allResults.addAll),
      if (types.contains(SearchType.article))
        searchArticles(q).then(allResults.addAll),
      if (types.contains(SearchType.caseLaw))
        searchCaseLaws(q).then(allResults.addAll),
    ]);

    allResults.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));

    stopwatch.stop();

    return SearchResponse(
      results:    allResults.take(limit).toList(),
      totalCount: allResults.length,
      query:      q,
      elapsed:    stopwatch.elapsed,
    );
  }

  // ─────────────────────────────────────────────
  // MARK: — CACHE MANAGEMENT
  // ─────────────────────────────────────────────

  /// Clears internal caches (call after content updates).
  void clearCache() {
    _cachedActs = null;
    debugPrint('[SearchService] Cache cleared.');
  }

  // ─────────────────────────────────────────────
  // MARK: — PRIVATE HELPERS
  // ─────────────────────────────────────────────

  String _actSubtitle(Act act) {
    final parts = <String>[
      act.year.toString(),
      _capitalise(act.category.name),
    ];
    if (!act.isActive) parts.add('Repealed');
    return parts.join(' · ');
  }

  String _capitalise(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  /// Extracts a short excerpt around the first query match.
  String? _buildExcerpt(String text, String query) {
    final lower = text.toLowerCase();
    final index = lower.indexOf(query.toLowerCase().trim());
    if (index < 0) return null;

    const window = 60;
    final start  = (index - window ~/ 2).clamp(0, text.length);
    final end    = (index + query.length + window ~/ 2).clamp(0, text.length);

    final excerpt = text.substring(start, end).trim();
    final prefix  = start > 0 ? '…' : '';
    final suffix  = end < text.length ? '…' : '';

    return '$prefix$excerpt$suffix';
  }
}