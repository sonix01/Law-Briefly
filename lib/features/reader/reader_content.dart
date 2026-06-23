// lib/features/reader/reader_content.dart
// Law Briefly — Universal Reader Content Model
// Unifies Act Sections and Constitution Articles into a single reader-ready model.

import '../../data/models/legal_models.dart';

// ─────────────────────────────────────────────
// MARK: — READER CONTENT TYPE
// ─────────────────────────────────────────────

enum ReaderContentType {
  section,
  article;

  String get displayLabel => switch (this) {
        ReaderContentType.section => 'Section',
        ReaderContentType.article => 'Article',
      };
}

// ─────────────────────────────────────────────
// MARK: — READER CONTENT MODEL
// ─────────────────────────────────────────────

class ReaderContent {
  final String                 id;
  final String                 number;       // "318", "21A", "Preamble"
  final String                 title;
  final List<SectionTextBlock> content;
  final List<String>           caseLawIds;
  final ReaderContentType      type;
  final bool                   isPreamble;
  final bool                   isRepealed;
  final bool                   isOmitted;
  final String?                statusNote;

  const ReaderContent({
    required this.id,
    required this.number,
    required this.title,
    required this.content,
    required this.caseLawIds,
    required this.type,
    this.isPreamble = false,
    this.isRepealed = false,
    this.isOmitted  = false,
    this.statusNote,
  });

  // ─────────────────────────────────────────────
  // MARK: — COMPUTED GETTERS
  // ─────────────────────────────────────────────

  /// "Preamble" for preamble, raw number otherwise.
  String get displayNumber => isPreamble ? 'Preamble' : number;

  /// "Section 318", "Article 21", or "Preamble".
  String get displayLabel {
    if (isPreamble) return 'Preamble';
    return switch (type) {
      ReaderContentType.section => 'Section $number',
      ReaderContentType.article => 'Article $number',
    };
  }

  /// Short heading for AppBar or breadcrumb.
  String get shortLabel {
    if (isPreamble) return 'Preamble';
    return number;
  }

  bool get hasContent   => content.isNotEmpty;
  bool get hasCaseLaws  => caseLawIds.isNotEmpty;
  bool get isActive     => !isRepealed && !isOmitted;
  bool get isSpecial    => isRepealed || isOmitted || isPreamble;

  // ─────────────────────────────────────────────
  // MARK: — FACTORY: from Section (Act)
  // ─────────────────────────────────────────────

  factory ReaderContent.fromSection(Section section) => ReaderContent(
        id:         section.id,
        number:     section.sectionNumber,
        title:      section.title,
        content:    section.content,
        caseLawIds: section.caseLawIds,
        type:       ReaderContentType.section,
        isRepealed: section.isRepealed,
        isOmitted:  section.isOmitted,
        statusNote: section.statusNote,
      );

  // ─────────────────────────────────────────────
  // MARK: — FACTORY: from Article (Constitution)
  // ─────────────────────────────────────────────

  factory ReaderContent.fromArticle(Article article) => ReaderContent(
        id:         article.id,
        number:     article.articleNumber,
        title:      article.title,
        content:    article.content,
        caseLawIds: article.caseLawIds,
        type:       ReaderContentType.article,
        isPreamble: article.isPreamble,
        isRepealed: article.isRepealed,
        isOmitted:  article.isOmitted,
        statusNote: article.statusNote,
      );

  // ─────────────────────────────────────────────
  // MARK: — BATCH CONVERSIONS
  // ─────────────────────────────────────────────

  /// Converts all sections in a chapter into a flat ordered list.
  static List<ReaderContent> fromSections(List<Section> sections) =>
      sections.map(ReaderContent.fromSection).toList();

  /// Converts all articles in a constitutional part into a flat ordered list.
  static List<ReaderContent> fromArticles(List<Article> articles) =>
      articles.map(ReaderContent.fromArticle).toList();

  // ─────────────────────────────────────────────
  // MARK: — FROM JSON
  // ─────────────────────────────────────────────

  factory ReaderContent.fromJson(Map<String, dynamic> json) => ReaderContent(
        id:     json['id']     as String,
        number: json['number'] as String,
        title:  json['title']  as String,
        content: (json['content'] as List<dynamic>?)
                ?.map((b) =>
                    SectionTextBlock.fromJson(b as Map<String, dynamic>))
                .toList() ??
            const [],
        caseLawIds: List<String>.from(
          json['case_law_ids'] as List? ?? [],
        ),
        type: ReaderContentType.values.firstWhere(
          (t) => t.name == (json['type'] as String? ?? 'section'),
          orElse: () => ReaderContentType.section,
        ),
        isPreamble: json['is_preamble'] as bool? ?? false,
        isRepealed: json['is_repealed'] as bool? ?? false,
        isOmitted:  json['is_omitted']  as bool? ?? false,
        statusNote: json['status_note'] as String?,
      );

  // ─────────────────────────────────────────────
  // MARK: — TO JSON
  // ─────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'id':           id,
        'number':       number,
        'title':        title,
        'content':      content.map((b) => b.toJson()).toList(),
        'case_law_ids': caseLawIds,
        'type':         type.name,
        'is_preamble':  isPreamble,
        'is_repealed':  isRepealed,
        'is_omitted':   isOmitted,
        if (statusNote != null) 'status_note': statusNote,
      };

  // ─────────────────────────────────────────────
  // MARK: — COPY WITH
  // ─────────────────────────────────────────────

  ReaderContent copyWith({
    String?                  id,
    String?                  number,
    String?                  title,
    List<SectionTextBlock>?  content,
    List<String>?            caseLawIds,
    ReaderContentType?       type,
    bool?                    isPreamble,
    bool?                    isRepealed,
    bool?                    isOmitted,
    Object?                  statusNote = _sentinel,
  }) =>
      ReaderContent(
        id:         id         ?? this.id,
        number:     number     ?? this.number,
        title:      title      ?? this.title,
        content:    content    ?? this.content,
        caseLawIds: caseLawIds ?? this.caseLawIds,
        type:       type       ?? this.type,
        isPreamble: isPreamble ?? this.isPreamble,
        isRepealed: isRepealed ?? this.isRepealed,
        isOmitted:  isOmitted  ?? this.isOmitted,
        statusNote: statusNote == _sentinel
            ? this.statusNote
            : statusNote as String?,
      );

  // ─────────────────────────────────────────────
  // MARK: — EQUALITY
  // ─────────────────────────────────────────────

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReaderContent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type;

  @override
  int get hashCode => Object.hash(id, type);

  @override
  String toString() =>
      'ReaderContent(id: $id, type: ${type.name}, number: $number)';
}

// ─────────────────────────────────────────────
// MARK: — SENTINEL
// ─────────────────────────────────────────────

const Object _sentinel = Object();