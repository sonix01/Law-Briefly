// lib/features/search/search_models.dart
// Law Briefly — Search Models
// MVP: Act Search | Future: Sections, Articles, Case Laws, AI

// ─────────────────────────────────────────────
// MARK: — SEARCH TYPE
// ─────────────────────────────────────────────

enum SearchType {
  act,
  section,
  article,
  caseLaw;

  String get displayLabel => switch (this) {
        SearchType.act     => 'Act',
        SearchType.section => 'Section',
        SearchType.article => 'Article',
        SearchType.caseLaw => 'Case Law',
      };

  String get iconName => switch (this) {
        SearchType.act     => 'menu_book',
        SearchType.section => 'article',
        SearchType.article => 'balance',
        SearchType.caseLaw => 'gavel',
      };
}

// ─────────────────────────────────────────────
// MARK: — SEARCH RESULT
// ─────────────────────────────────────────────

class SearchResult {
  final String     id;
  final String     title;
  final String?    subtitle;      // "2023 · Criminal"
  final SearchType searchType;
  final String?    excerpt;       // Highlighted snippet (future: AI)
  final String?    sourceId;      // Parent id — actId, partId (for navigation)
  final String?    sourceName;    // Human-readable parent — "Bharatiya Nyaya Sanhita"
  final double     relevanceScore; // 0.0–1.0 (future: AI ranking)
  final Map<String, dynamic>? metadata; // Type-specific extra fields

  const SearchResult({
    required this.id,
    required this.title,
    required this.searchType,
    this.subtitle,
    this.excerpt,
    this.sourceId,
    this.sourceName,
    this.relevanceScore = 1.0,
    this.metadata,
  });

  // ─────────────────────────────────────────────
  // MARK: — COPY WITH
  // ─────────────────────────────────────────────

  SearchResult copyWith({
    String?     id,
    String?     title,
    SearchType? searchType,
    Object?     subtitle      = _sentinel,
    Object?     excerpt       = _sentinel,
    Object?     sourceId      = _sentinel,
    Object?     sourceName    = _sentinel,
    double?     relevanceScore,
    Object?     metadata      = _sentinel,
  }) =>
      SearchResult(
        id:             id             ?? this.id,
        title:          title          ?? this.title,
        searchType:     searchType     ?? this.searchType,
        subtitle:       subtitle       == _sentinel ? this.subtitle       : subtitle as String?,
        excerpt:        excerpt        == _sentinel ? this.excerpt        : excerpt  as String?,
        sourceId:       sourceId       == _sentinel ? this.sourceId       : sourceId as String?,
        sourceName:     sourceName     == _sentinel ? this.sourceName     : sourceName as String?,
        relevanceScore: relevanceScore ?? this.relevanceScore,
        metadata:       metadata       == _sentinel ? this.metadata       : metadata as Map<String, dynamic>?,
      );

  // ─────────────────────────────────────────────
  // MARK: — FROM JSON
  // ─────────────────────────────────────────────

  factory SearchResult.fromJson(Map<String, dynamic> json) => SearchResult(
        id:         json['id']          as String,
        title:      json['title']       as String,
        searchType: SearchType.values.firstWhere(
          (t) => t.name == (json['search_type'] as String? ?? 'act'),
          orElse: () => SearchType.act,
        ),
        subtitle:       json['subtitle']        as String?,
        excerpt:        json['excerpt']         as String?,
        sourceId:       json['source_id']       as String?,
        sourceName:     json['source_name']     as String?,
        relevanceScore: (json['relevance_score'] as num?)?.toDouble() ?? 1.0,
        metadata:       json['metadata']        as Map<String, dynamic>?,
      );

  // ─────────────────────────────────────────────
  // MARK: — TO JSON
  // ─────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'id':              id,
        'title':           title,
        'search_type':     searchType.name,
        if (subtitle      != null) 'subtitle':       subtitle,
        if (excerpt       != null) 'excerpt':        excerpt,
        if (sourceId      != null) 'source_id':      sourceId,
        if (sourceName    != null) 'source_name':    sourceName,
        'relevance_score': relevanceScore,
        if (metadata      != null) 'metadata':       metadata,
      };

  // ─────────────────────────────────────────────
  // MARK: — EQUALITY
  // ─────────────────────────────────────────────

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchResult &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          searchType == other.searchType;

  @override
  int get hashCode => Object.hash(id, searchType);

  @override
  String toString() =>
      'SearchResult(id: $id, type: ${searchType.name}, title: $title)';
}

// ─────────────────────────────────────────────
// MARK: — SEARCH QUERY (Future: structured queries)
// ─────────────────────────────────────────────

class SearchQuery {
  final String          text;
  final Set<SearchType> types;
  final int             limit;
  final String?         sourceFilter; // Filter by actId or partId

  const SearchQuery({
    required this.text,
    this.types        = const {SearchType.act},
    this.limit        = 30,
    this.sourceFilter,
  });

  bool get isEmpty  => text.trim().isEmpty;
  bool get isNotEmpty => !isEmpty;
  String get normalised => text.trim().toLowerCase();

  SearchQuery copyWith({
    String?          text,
    Set<SearchType>? types,
    int?             limit,
    Object?          sourceFilter = _sentinel,
  }) =>
      SearchQuery(
        text:         text         ?? this.text,
        types:        types        ?? this.types,
        limit:        limit        ?? this.limit,
        sourceFilter: sourceFilter == _sentinel
            ? this.sourceFilter
            : sourceFilter as String?,
      );
}

// ─────────────────────────────────────────────
// MARK: — SEARCH RESPONSE (Future: paginated)
// ─────────────────────────────────────────────

class SearchResponse {
  final List<SearchResult> results;
  final int                totalCount;
  final String             query;
  final Duration           elapsed;
  final bool               isAiEnhanced; // Future: AI results flag

  const SearchResponse({
    required this.results,
    required this.totalCount,
    required this.query,
    required this.elapsed,
    this.isAiEnhanced = false,
  });

  bool get isEmpty   => results.isEmpty;
  bool get isNotEmpty => results.isNotEmpty;

  static SearchResponse empty(String query) => SearchResponse(
        results:    const [],
        totalCount: 0,
        query:      query,
        elapsed:    Duration.zero,
      );
}

// ─────────────────────────────────────────────
// MARK: — SENTINEL
// ─────────────────────────────────────────────

const Object _sentinel = Object();