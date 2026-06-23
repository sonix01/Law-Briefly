class CaseLaw {
  // ── Required ──────────────────────────────────
  final String id;
  final String title;
  final String facts;
  final String issues;
  final String judgment;
  final String reasoning;
  final String significance;

  // ── Optional ──────────────────────────────────
  final String? relatedSection;
  final String? relatedArticle;
  final String? citation;
  final String? court;
  final String? year;

  const CaseLaw({
    required this.id,
    required this.title,
    required this.facts,
    required this.issues,
    required this.judgment,
    required this.reasoning,
    required this.significance,
    this.relatedSection,
    this.relatedArticle,
    this.citation,
    this.court,
    this.year,
  });

  // ── Computed ─────────────────────────────────

  String get displayCitation => citation ?? 'Citation unavailable';

  String get courtAndYear {
    if (court != null && year != null) return '$court · $year';
    if (court != null) return court!;
    if (year  != null) return year!;
    return '';
  }

  bool get hasCitation       => citation       != null && citation!.isNotEmpty;
  bool get hasCourtInfo      => court          != null;
  bool get hasRelatedSection => relatedSection != null && relatedSection!.isNotEmpty;
  bool get hasRelatedArticle => relatedArticle != null && relatedArticle!.isNotEmpty;
  bool get hasRelatedContent => hasRelatedSection || hasRelatedArticle;

  // ── FROM JSON ─────────────────────────────────

  factory CaseLaw.fromJson(Map<String, dynamic> json) {
    // Handle relatedSection as either String or List
    String? _strOrFirstList(dynamic raw) {
      if (raw == null) return null;
      if (raw is String) return raw.isEmpty ? null : raw;
      if (raw is List  && raw.isNotEmpty) return raw.first?.toString();
      return null;
    }

    return CaseLaw(
      id:             json['id']           as String,
      title:          json['title']        as String,
      facts:          json['facts']        as String? ?? '',
      issues:         json['issues']       as String? ?? '',
      judgment:       json['judgment']     as String? ?? '',
      reasoning:      json['reasoning']    as String? ?? '',
      significance:   json['significance'] as String? ?? '',
      relatedSection: _strOrFirstList(json['related_section'] ?? json['related_section_ids']),
      relatedArticle: _strOrFirstList(json['related_article'] ?? json['related_article_ids']),
      citation:       json['citation']     as String?,
      court:          json['court']        as String?,
      year:           json['year']?.toString(),
    );
  }

  // ── TO JSON ───────────────────────────────────

  Map<String, dynamic> toJson() => {
        'id':           id,
        'title':        title,
        'facts':        facts,
        'issues':       issues,
        'judgment':     judgment,
        'reasoning':    reasoning,
        'significance': significance,
        if (relatedSection != null) 'related_section': relatedSection,
        if (relatedArticle != null) 'related_article': relatedArticle,
        if (citation       != null) 'citation':        citation,
        if (court          != null) 'court':           court,
        if (year           != null) 'year':            year,
      };

  // ── COPY WITH ─────────────────────────────────

  CaseLaw copyWith({
    String? id,
    String? title,
    String? facts,
    String? issues,
    String? judgment,
    String? reasoning,
    String? significance,
    Object? relatedSection = _sentinel,
    Object? relatedArticle = _sentinel,
    Object? citation       = _sentinel,
    Object? court          = _sentinel,
    Object? year           = _sentinel,
  }) =>
      CaseLaw(
        id:             id             ?? this.id,
        title:          title          ?? this.title,
        facts:          facts          ?? this.facts,
        issues:         issues         ?? this.issues,
        judgment:       judgment       ?? this.judgment,
        reasoning:      reasoning      ?? this.reasoning,
        significance:   significance   ?? this.significance,
        relatedSection: relatedSection == _sentinel ? this.relatedSection : relatedSection as String?,
        relatedArticle: relatedArticle == _sentinel ? this.relatedArticle : relatedArticle as String?,
        citation:       citation       == _sentinel ? this.citation       : citation       as String?,
        court:          court          == _sentinel ? this.court          : court          as String?,
        year:           year           == _sentinel ? this.year           : year           as String?,
      );

  // ── EQUALITY ─────────────────────────────────

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CaseLaw && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'CaseLaw(id: $id, title: $title)';
}

const Object _sentinel = Object();