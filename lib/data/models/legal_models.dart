// lib/data/models/legal_models.dart
// Law Briefly — Canonical Legal Data Models
// Offline-First | JSON-Driven | Content/UI Separation | Enterprise Architecture
//
// ARCHITECTURE RULES:
// 1. Case Laws are NEVER embedded — always stored and linked by ID
// 2. UI layers NEVER contain legal content directly
// 3. All content flows through JSON → these models → UI
// 4. Models are immutable — use copyWith() for modifications
// 5. Ready for ISAR, Hive, or any offline database

// ─────────────────────────────────────────────
// MARK: — ENUMS
// ─────────────────────────────────────────────

enum TextBlockType { main, explanation, proviso, subSection }

enum BookmarkContentType { section, article, caseLaw, note, pdf }

enum ActCategory {
  criminal,
  civil,
  constitutional,
  commercial,
  evidence,
  digital,
  consumer,
  property,
  labour,
  taxation,
  general,
}

// ─────────────────────────────────────────────
// MARK: — SECTION TEXT BLOCK
// (Rich legal text unit — main / explanation / proviso)
// ─────────────────────────────────────────────

class SectionTextBlock {
  final TextBlockType type;
  final String?       label; // "Explanation 1.—", "Proviso.—"
  final String        text;

  const SectionTextBlock({
    required this.type,
    this.label,
    required this.text,
  });

  factory SectionTextBlock.fromJson(Map<String, dynamic> json) =>
      SectionTextBlock(
        type: TextBlockType.values.firstWhere(
          (t) => t.name == (json['type'] as String? ?? 'main'),
          orElse: () => TextBlockType.main,
        ),
        label: json['label'] as String?,
        text:  json['text']  as String,
      );

  Map<String, dynamic> toJson() => {
        'type':             type.name,
        if (label != null) 'label': label,
        'text':             text,
      };

  SectionTextBlock copyWith({
    TextBlockType? type,
    Object?        label = _sentinel,
    String?        text,
  }) =>
      SectionTextBlock(
        type:  type  ?? this.type,
        label: label == _sentinel ? this.label : label as String?,
        text:  text  ?? this.text,
      );
}

// ─────────────────────────────────────────────
// MARK: — CASE LAW
// (Stored separately — never embedded in Section or Article)
// ─────────────────────────────────────────────

class CaseLaw {
  final String  id;
  final String  title;
  final String? citation;           // "(2003) 5 SCC 257"
  final String? court;
  final String? year;
  final String? facts;
  final String? issues;
  final String? judgment;
  final String? reasoning;
  final String? significance;

  // Future: AI indexing / cross-linking
  final List<String> relatedSectionIds;
  final List<String> relatedArticleIds;
  final List<String> relatedActIds;

  const CaseLaw({
    required this.id,
    required this.title,
    this.citation,
    this.court,
    this.year,
    this.facts,
    this.issues,
    this.judgment,
    this.reasoning,
    this.significance,
    this.relatedSectionIds  = const [],
    this.relatedArticleIds  = const [],
    this.relatedActIds      = const [],
  });

  String get courtAndYear {
    final parts = <String>[];
    if (court != null) parts.add(court!);
    if (year  != null) parts.add(year!);
    return parts.join(' · ');
  }

  factory CaseLaw.fromJson(Map<String, dynamic> json) => CaseLaw(
        id:           json['id']           as String,
        title:        json['title']        as String,
        citation:     json['citation']     as String?,
        court:        json['court']        as String?,
        year:         json['year']         as String?,
        facts:        json['facts']        as String?,
        issues:       json['issues']       as String?,
        judgment:     json['judgment']     as String?,
        reasoning:    json['reasoning']    as String?,
        significance: json['significance'] as String?,
        relatedSectionIds: List<String>.from(
          json['related_section_ids']  as List? ?? [],
        ),
        relatedArticleIds: List<String>.from(
          json['related_article_ids']  as List? ?? [],
        ),
        relatedActIds: List<String>.from(
          json['related_act_ids']      as List? ?? [],
        ),
      );

  Map<String, dynamic> toJson() => {
        'id':                   id,
        'title':                title,
        if (citation     != null) 'citation':     citation,
        if (court        != null) 'court':        court,
        if (year         != null) 'year':         year,
        if (facts        != null) 'facts':        facts,
        if (issues       != null) 'issues':       issues,
        if (judgment     != null) 'judgment':     judgment,
        if (reasoning    != null) 'reasoning':    reasoning,
        if (significance != null) 'significance': significance,
        'related_section_ids':  relatedSectionIds,
        'related_article_ids':  relatedArticleIds,
        'related_act_ids':      relatedActIds,
      };

  CaseLaw copyWith({
    String?       id,
    String?       title,
    Object?       citation     = _sentinel,
    Object?       court        = _sentinel,
    Object?       year         = _sentinel,
    Object?       facts        = _sentinel,
    Object?       issues       = _sentinel,
    Object?       judgment     = _sentinel,
    Object?       reasoning    = _sentinel,
    Object?       significance = _sentinel,
    List<String>? relatedSectionIds,
    List<String>? relatedArticleIds,
    List<String>? relatedActIds,
  }) =>
      CaseLaw(
        id:           id           ?? this.id,
        title:        title        ?? this.title,
        citation:     citation     == _sentinel ? this.citation     : citation     as String?,
        court:        court        == _sentinel ? this.court        : court        as String?,
        year:         year         == _sentinel ? this.year         : year         as String?,
        facts:        facts        == _sentinel ? this.facts        : facts        as String?,
        issues:       issues       == _sentinel ? this.issues       : issues       as String?,
        judgment:     judgment     == _sentinel ? this.judgment     : judgment     as String?,
        reasoning:    reasoning    == _sentinel ? this.reasoning    : reasoning    as String?,
        significance: significance == _sentinel ? this.significance : significance as String?,
        relatedSectionIds:  relatedSectionIds  ?? this.relatedSectionIds,
        relatedArticleIds:  relatedArticleIds  ?? this.relatedArticleIds,
        relatedActIds:      relatedActIds      ?? this.relatedActIds,
      );
}

// ─────────────────────────────────────────────
// MARK: — SECTION
// (caseLawIds only — Case Law is NOT embedded)
// ─────────────────────────────────────────────

class Section {
  final String              id;
  final String              sectionNumber; // "1", "21A", "69"
  final String              title;
  final List<SectionTextBlock> content;
  final List<String>        caseLawIds;    // References only
  final bool                isRepealed;
  final bool                isOmitted;
  final String?             statusNote;   // "Omitted by Act X of Y"

  const Section({
    required this.id,
    required this.sectionNumber,
    required this.title,
    this.content         = const [],
    this.caseLawIds      = const [],
    this.isRepealed      = false,
    this.isOmitted       = false,
    this.statusNote,
  });

  bool get hasContent   => content.isNotEmpty;
  bool get hasCaseLaws  => caseLawIds.isNotEmpty;
  bool get isActive     => !isRepealed && !isOmitted;

  String get displayNumber => sectionNumber;
  String get displayLabel  => 'Section $sectionNumber';

  factory Section.fromJson(Map<String, dynamic> json) => Section(
        id:            json['id']             as String,
        sectionNumber: json['section_number'] as String,
        title:         json['title']          as String,
        content: (json['content'] as List<dynamic>?)
                ?.map((b) => SectionTextBlock.fromJson(
                      b as Map<String, dynamic>,
                    ))
                .toList() ??
            const [],
        caseLawIds: List<String>.from(
          json['case_law_ids'] as List? ?? [],
        ),
        isRepealed:  json['is_repealed']  as bool? ?? false,
        isOmitted:   json['is_omitted']   as bool? ?? false,
        statusNote:  json['status_note']  as String?,
      );

  Map<String, dynamic> toJson() => {
        'id':             id,
        'section_number': sectionNumber,
        'title':          title,
        'content':        content.map((b) => b.toJson()).toList(),
        'case_law_ids':   caseLawIds,
        'is_repealed':    isRepealed,
        'is_omitted':     isOmitted,
        if (statusNote != null) 'status_note': statusNote,
      };

  Section copyWith({
    String?              id,
    String?              sectionNumber,
    String?              title,
    List<SectionTextBlock>? content,
    List<String>?        caseLawIds,
    bool?                isRepealed,
    bool?                isOmitted,
    Object?              statusNote = _sentinel,
  }) =>
      Section(
        id:            id            ?? this.id,
        sectionNumber: sectionNumber ?? this.sectionNumber,
        title:         title         ?? this.title,
        content:       content       ?? this.content,
        caseLawIds:    caseLawIds    ?? this.caseLawIds,
        isRepealed:    isRepealed    ?? this.isRepealed,
        isOmitted:     isOmitted     ?? this.isOmitted,
        statusNote:    statusNote    == _sentinel ? this.statusNote : statusNote as String?,
      );
}

// ─────────────────────────────────────────────
// MARK: — CHAPTER
// ─────────────────────────────────────────────

class Chapter {
  final String        id;
  final String        chapterNumber; // "I", "II", "1", "1A"
  final String        title;
  final List<Section> sections;

  const Chapter({
    required this.id,
    required this.chapterNumber,
    required this.title,
    this.sections = const [],
  });

  String get displayTitle  => 'Chapter $chapterNumber \u2013 $title';
  int    get sectionCount  => sections.length;
  int    get activeSections =>
      sections.where((s) => s.isActive).length;

  String? get sectionRange {
    final active = sections.where((s) => s.isActive).toList();
    if (active.isEmpty) return null;
    if (active.length == 1) return 'Sec.\u00A0${active.first.sectionNumber}';
    return 'Sec.\u00A0${active.first.sectionNumber}\u2013${active.last.sectionNumber}';
  }

  factory Chapter.fromJson(Map<String, dynamic> json) => Chapter(
        id:            json['id']             as String,
        chapterNumber: json['chapter_number'] as String,
        title:         json['title']          as String,
        sections: (json['sections'] as List<dynamic>?)
                ?.map((s) => Section.fromJson(s as Map<String, dynamic>))
                .toList() ??
            const [],
      );

  Map<String, dynamic> toJson() => {
        'id':             id,
        'chapter_number': chapterNumber,
        'title':          title,
        'sections':       sections.map((s) => s.toJson()).toList(),
      };

  Chapter copyWith({
    String?        id,
    String?        chapterNumber,
    String?        title,
    List<Section>? sections,
  }) =>
      Chapter(
        id:            id            ?? this.id,
        chapterNumber: chapterNumber ?? this.chapterNumber,
        title:         title         ?? this.title,
        sections:      sections      ?? this.sections,
      );
}

// ─────────────────────────────────────────────
// MARK: — ACT
// ─────────────────────────────────────────────

class Act {
  final String        id;
  final String        title;
  final String?       shortTitle;
  final int           year;
  final String?       description;
  final List<Chapter> chapters;
  final ActCategory   category;
  final bool          isActive;     // False if repealed/superseded
  final String?       supersededBy; // ID of newer Act that replaced this

  const Act({
    required this.id,
    required this.title,
    this.shortTitle,
    required this.year,
    this.description,
    this.chapters    = const [],
    this.category    = ActCategory.general,
    this.isActive    = true,
    this.supersededBy,
  });

  String get displayTitle  => '$title, $year';
  int    get chapterCount  => chapters.length;
  int    get totalSections =>
      chapters.fold(0, (sum, c) => sum + c.sectionCount);
  int    get activeSections =>
      chapters.fold(0, (sum, c) => sum + c.activeSections);

  factory Act.fromJson(Map<String, dynamic> json) => Act(
        id:          json['id']          as String,
        title:       json['title']       as String,
        shortTitle:  json['short_title'] as String?,
        year:        json['year']        as int,
        description: json['description'] as String?,
        chapters: (json['chapters'] as List<dynamic>?)
                ?.map((c) => Chapter.fromJson(c as Map<String, dynamic>))
                .toList() ??
            const [],
        category: ActCategory.values.firstWhere(
          (c) => c.name == (json['category'] as String? ?? 'general'),
          orElse: () => ActCategory.general,
        ),
        isActive:     json['is_active']      as bool? ?? true,
        supersededBy: json['superseded_by']  as String?,
      );

  Map<String, dynamic> toJson() => {
        'id':          id,
        'title':       title,
        if (shortTitle  != null) 'short_title':   shortTitle,
        'year':        year,
        if (description != null) 'description':   description,
        'chapters':    chapters.map((c) => c.toJson()).toList(),
        'category':    category.name,
        'is_active':   isActive,
        if (supersededBy != null) 'superseded_by': supersededBy,
      };

  Act copyWith({
    String?        id,
    String?        title,
    Object?        shortTitle   = _sentinel,
    int?           year,
    Object?        description  = _sentinel,
    List<Chapter>? chapters,
    ActCategory?   category,
    bool?          isActive,
    Object?        supersededBy = _sentinel,
  }) =>
      Act(
        id:           id           ?? this.id,
        title:        title        ?? this.title,
        shortTitle:   shortTitle   == _sentinel ? this.shortTitle   : shortTitle   as String?,
        year:         year         ?? this.year,
        description:  description  == _sentinel ? this.description  : description  as String?,
        chapters:     chapters     ?? this.chapters,
        category:     category     ?? this.category,
        isActive:     isActive     ?? this.isActive,
        supersededBy: supersededBy == _sentinel ? this.supersededBy : supersededBy as String?,
      );
}

// ─────────────────────────────────────────────
// MARK: — ARTICLE
// (caseLawIds only — Case Law is NOT embedded)
// ─────────────────────────────────────────────

class Article {
  final String                 id;
  final String                 articleNumber; // "1", "21A", "51A", "Preamble"
  final String                 title;
  final List<SectionTextBlock> content;
  final List<String>           caseLawIds;    // References only
  final bool                   isPreamble;
  final bool                   isRepealed;
  final bool                   isOmitted;
  final String?                statusNote;

  const Article({
    required this.id,
    required this.articleNumber,
    required this.title,
    this.content      = const [],
    this.caseLawIds   = const [],
    this.isPreamble   = false,
    this.isRepealed   = false,
    this.isOmitted    = false,
    this.statusNote,
  });

  bool   get isActive      => !isRepealed && !isOmitted;
  bool   get hasCaseLaws   => caseLawIds.isNotEmpty;
  bool   get hasContent    => content.isNotEmpty;
  String get displayNumber => isPreamble ? 'Preamble' : articleNumber;
  String get displayLabel  => isPreamble ? 'Preamble' : 'Article $articleNumber';

  factory Article.fromJson(Map<String, dynamic> json) => Article(
        id:            json['id']             as String,
        articleNumber: json['article_number'] as String,
        title:         json['title']          as String,
        content: (json['content'] as List<dynamic>?)
                ?.map((b) => SectionTextBlock.fromJson(
                      b as Map<String, dynamic>,
                    ))
                .toList() ??
            const [],
        caseLawIds: List<String>.from(
          json['case_law_ids'] as List? ?? [],
        ),
        isPreamble:  json['is_preamble']  as bool? ?? false,
        isRepealed:  json['is_repealed']  as bool? ?? false,
        isOmitted:   json['is_omitted']   as bool? ?? false,
        statusNote:  json['status_note']  as String?,
      );

  Map<String, dynamic> toJson() => {
        'id':             id,
        'article_number': articleNumber,
        'title':          title,
        'content':        content.map((b) => b.toJson()).toList(),
        'case_law_ids':   caseLawIds,
        'is_preamble':    isPreamble,
        'is_repealed':    isRepealed,
        'is_omitted':     isOmitted,
        if (statusNote != null) 'status_note': statusNote,
      };

  Article copyWith({
    String?                  id,
    String?                  articleNumber,
    String?                  title,
    List<SectionTextBlock>?  content,
    List<String>?            caseLawIds,
    bool?                    isPreamble,
    bool?                    isRepealed,
    bool?                    isOmitted,
    Object?                  statusNote = _sentinel,
  }) =>
      Article(
        id:            id            ?? this.id,
        articleNumber: articleNumber ?? this.articleNumber,
        title:         title         ?? this.title,
        content:       content       ?? this.content,
        caseLawIds:    caseLawIds    ?? this.caseLawIds,
        isPreamble:    isPreamble    ?? this.isPreamble,
        isRepealed:    isRepealed    ?? this.isRepealed,
        isOmitted:     isOmitted     ?? this.isOmitted,
        statusNote:    statusNote    == _sentinel ? this.statusNote : statusNote as String?,
      );
}

// ─────────────────────────────────────────────
// MARK: — CONSTITUTION PART
// ─────────────────────────────────────────────

class ConstitutionPart {
  final String        id;
  final String        partNumber; // "I", "IVA", "XIVA"
  final String        title;
  final List<Article> articles;

  const ConstitutionPart({
    required this.id,
    required this.partNumber,
    required this.title,
    this.articles = const [],
  });

  String get displayTitle  => 'Part $partNumber \u2013 $title';
  int    get articleCount  => articles.length;
  int    get activeArticles =>
      articles.where((a) => a.isActive).length;

  String get articleRange {
    final active      = articles.where((a) => !a.isPreamble).toList();
    final hasPreamble = articles.any((a) => a.isPreamble);
    final pre         = hasPreamble ? 'Preamble\u2002' : '';
    if (active.isEmpty) return hasPreamble ? 'Preamble' : '\u2014';
    if (active.length == 1) return '${pre}Art.\u00A0${active.first.articleNumber}';
    return '${pre}Arts.\u00A0${active.first.articleNumber}\u2013${active.last.articleNumber}';
  }

  factory ConstitutionPart.fromJson(Map<String, dynamic> json) =>
      ConstitutionPart(
        id:         json['id']          as String,
        partNumber: json['part_number'] as String,
        title:      json['title']       as String,
        articles: (json['articles'] as List<dynamic>?)
                ?.map((a) => Article.fromJson(a as Map<String, dynamic>))
                .toList() ??
            const [],
      );

  Map<String, dynamic> toJson() => {
        'id':          id,
        'part_number': partNumber,
        'title':       title,
        'articles':    articles.map((a) => a.toJson()).toList(),
      };

  ConstitutionPart copyWith({
    String?        id,
    String?        partNumber,
    String?        title,
    List<Article>? articles,
  }) =>
      ConstitutionPart(
        id:         id         ?? this.id,
        partNumber: partNumber ?? this.partNumber,
        title:      title      ?? this.title,
        articles:   articles   ?? this.articles,
      );
}

// ─────────────────────────────────────────────
// MARK: — ACADEMIC SUBJECT
// ─────────────────────────────────────────────

class AcademicSubject {
  final String    id;
  final String    title;
  final String?   description;
  final String?   pdfPath;
  final int       semester;
  final bool      isPremium;
  final int?      totalPages;
  final String?   uploadedBy;     // Future: admin CMS
  final DateTime? uploadedAt;
  final bool      isDownloaded;   // Future: offline cache

  const AcademicSubject({
    required this.id,
    required this.title,
    this.description,
    this.pdfPath,
    required this.semester,
    this.isPremium    = false,
    this.totalPages,
    this.uploadedBy,
    this.uploadedAt,
    this.isDownloaded = false,
  });

  bool get hasPdf       => pdfPath != null && pdfPath!.isNotEmpty;
  bool get isAvailable  => hasPdf && isDownloaded;
  bool get isLocked     => isPremium;

  factory AcademicSubject.fromJson(Map<String, dynamic> json) =>
      AcademicSubject(
        id:           json['id']          as String,
        title:        json['title']       as String,
        description:  json['description'] as String?,
        pdfPath:      json['pdf_path']    as String?,
        semester:     json['semester']    as int,
        isPremium:    json['is_premium']  as bool? ?? false,
        totalPages:   json['total_pages'] as int?,
        uploadedBy:   json['uploaded_by'] as String?,
        uploadedAt:   json['uploaded_at'] != null
            ? DateTime.parse(json['uploaded_at'] as String)
            : null,
        isDownloaded: json['is_downloaded'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id':           id,
        'title':        title,
        if (description != null) 'description': description,
        if (pdfPath     != null) 'pdf_path':    pdfPath,
        'semester':     semester,
        'is_premium':   isPremium,
        if (totalPages  != null) 'total_pages': totalPages,
        if (uploadedBy  != null) 'uploaded_by': uploadedBy,
        if (uploadedAt  != null) 'uploaded_at': uploadedAt!.toIso8601String(),
        'is_downloaded': isDownloaded,
      };

  AcademicSubject copyWith({
    String?    id,
    String?    title,
    Object?    description  = _sentinel,
    Object?    pdfPath      = _sentinel,
    int?       semester,
    bool?      isPremium,
    Object?    totalPages   = _sentinel,
    Object?    uploadedBy   = _sentinel,
    Object?    uploadedAt   = _sentinel,
    bool?      isDownloaded,
  }) =>
      AcademicSubject(
        id:           id           ?? this.id,
        title:        title        ?? this.title,
        description:  description  == _sentinel ? this.description  : description  as String?,
        pdfPath:      pdfPath      == _sentinel ? this.pdfPath      : pdfPath      as String?,
        semester:     semester     ?? this.semester,
        isPremium:    isPremium    ?? this.isPremium,
        totalPages:   totalPages   == _sentinel ? this.totalPages   : totalPages   as int?,
        uploadedBy:   uploadedBy   == _sentinel ? this.uploadedBy   : uploadedBy   as String?,
        uploadedAt:   uploadedAt   == _sentinel ? this.uploadedAt   : uploadedAt   as DateTime?,
        isDownloaded: isDownloaded ?? this.isDownloaded,
      );
}

// ─────────────────────────────────────────────
// MARK: — ACADEMIC YEAR
// ─────────────────────────────────────────────

class AcademicYear {
  final String              id;
  final String              title;         // "BALLB 1st Year"
  final int                 yearNumber;    // 1–5
  final String              program;       // "BALLB"
  final int                 firstSemester;
  final int                 lastSemester;
  final List<AcademicSubject> subjects;

  const AcademicYear({
    required this.id,
    required this.title,
    required this.yearNumber,
    required this.program,
    required this.firstSemester,
    required this.lastSemester,
    this.subjects = const [],
  });

  String get semesterRange => 'Sem $firstSemester\u2013$lastSemester';
  int    get subjectCount  => subjects.length;
  int    get premiumCount  => subjects.where((s) => s.isPremium).length;

  factory AcademicYear.fromJson(Map<String, dynamic> json) => AcademicYear(
        id:             json['id']             as String,
        title:          json['title']          as String,
        yearNumber:     json['year_number']    as int,
        program:        json['program']        as String,
        firstSemester:  json['first_semester'] as int,
        lastSemester:   json['last_semester']  as int,
        subjects: (json['subjects'] as List<dynamic>?)
                ?.map((s) => AcademicSubject.fromJson(
                      s as Map<String, dynamic>,
                    ))
                .toList() ??
            const [],
      );

  Map<String, dynamic> toJson() => {
        'id':             id,
        'title':          title,
        'year_number':    yearNumber,
        'program':        program,
        'first_semester': firstSemester,
        'last_semester':  lastSemester,
        'subjects':       subjects.map((s) => s.toJson()).toList(),
      };

  AcademicYear copyWith({
    String?                id,
    String?                title,
    int?                   yearNumber,
    String?                program,
    int?                   firstSemester,
    int?                   lastSemester,
    List<AcademicSubject>? subjects,
  }) =>
      AcademicYear(
        id:             id             ?? this.id,
        title:          title          ?? this.title,
        yearNumber:     yearNumber     ?? this.yearNumber,
        program:        program        ?? this.program,
        firstSemester:  firstSemester  ?? this.firstSemester,
        lastSemester:   lastSemester   ?? this.lastSemester,
        subjects:       subjects       ?? this.subjects,
      );
}

// ─────────────────────────────────────────────
// MARK: — BOOKMARK
// ─────────────────────────────────────────────

class Bookmark {
  final String              id;
  final String              linkedContentId;
  final BookmarkContentType contentType;
  final DateTime            createdAt;

  // Display cache (avoids loading full content for list view)
  final String?             displayTitle;
  final String?             displaySubtitle;
  final String?             sourceActId;
  final String?             sourcePartId;

  const Bookmark({
    required this.id,
    required this.linkedContentId,
    required this.contentType,
    required this.createdAt,
    this.displayTitle,
    this.displaySubtitle,
    this.sourceActId,
    this.sourcePartId,
  });

  factory Bookmark.fromJson(Map<String, dynamic> json) => Bookmark(
        id:              json['id']               as String,
        linkedContentId: json['linked_content_id'] as String,
        contentType: BookmarkContentType.values.firstWhere(
          (t) => t.name == (json['content_type'] as String),
          orElse: () => BookmarkContentType.section,
        ),
        createdAt:       DateTime.parse(json['created_at'] as String),
        displayTitle:    json['display_title']    as String?,
        displaySubtitle: json['display_subtitle'] as String?,
        sourceActId:     json['source_act_id']    as String?,
        sourcePartId:    json['source_part_id']   as String?,
      );

  Map<String, dynamic> toJson() => {
        'id':                id,
        'linked_content_id': linkedContentId,
        'content_type':      contentType.name,
        'created_at':        createdAt.toIso8601String(),
        if (displayTitle    != null) 'display_title':    displayTitle,
        if (displaySubtitle != null) 'display_subtitle': displaySubtitle,
        if (sourceActId     != null) 'source_act_id':    sourceActId,
        if (sourcePartId    != null) 'source_part_id':   sourcePartId,
      };

  Bookmark copyWith({
    String?               id,
    String?               linkedContentId,
    BookmarkContentType?  contentType,
    DateTime?             createdAt,
    Object?               displayTitle    = _sentinel,
    Object?               displaySubtitle = _sentinel,
    Object?               sourceActId     = _sentinel,
    Object?               sourcePartId    = _sentinel,
  }) =>
      Bookmark(
        id:              id              ?? this.id,
        linkedContentId: linkedContentId ?? this.linkedContentId,
        contentType:     contentType     ?? this.contentType,
        createdAt:       createdAt       ?? this.createdAt,
        displayTitle:    displayTitle    == _sentinel ? this.displayTitle    : displayTitle    as String?,
        displaySubtitle: displaySubtitle == _sentinel ? this.displaySubtitle : displaySubtitle as String?,
        sourceActId:     sourceActId     == _sentinel ? this.sourceActId     : sourceActId     as String?,
        sourcePartId:    sourcePartId    == _sentinel ? this.sourcePartId    : sourcePartId    as String?,
      );
}

// ─────────────────────────────────────────────
// MARK: — PERSONAL NOTE
// ─────────────────────────────────────────────

class PersonalNote {
  final String    id;
  final String    title;
  final String    content;
  final DateTime  lastModified;
  final DateTime  createdAt;

  // Future: tagging, linking, marketplace
  final List<String>          tags;
  final bool                  isPinned;
  final String?               linkedContentId;
  final BookmarkContentType?  linkedContentType;

  const PersonalNote({
    required this.id,
    required this.title,
    required this.content,
    required this.lastModified,
    required this.createdAt,
    this.tags              = const [],
    this.isPinned          = false,
    this.linkedContentId,
    this.linkedContentType,
  });

  String get preview {
    final clean = content.replaceAll('\n', ' ').trim();
    return clean.length > 130
        ? '${clean.substring(0, 130)}\u2026'
        : clean;
  }

  bool get hasLinkedContent => linkedContentId != null;

  factory PersonalNote.fromJson(Map<String, dynamic> json) => PersonalNote(
        id:           json['id']            as String,
        title:        json['title']         as String,
        content:      json['content']       as String,
        lastModified: DateTime.parse(json['last_modified'] as String),
        createdAt:    DateTime.parse(json['created_at']    as String),
        tags:         List<String>.from(json['tags'] as List? ?? []),
        isPinned:     json['is_pinned']     as bool? ?? false,
        linkedContentId: json['linked_content_id'] as String?,
        linkedContentType: json['linked_content_type'] != null
            ? BookmarkContentType.values.firstWhere(
                (t) => t.name == (json['linked_content_type'] as String),
                orElse: () => BookmarkContentType.section,
              )
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id':            id,
        'title':         title,
        'content':       content,
        'last_modified': lastModified.toIso8601String(),
        'created_at':    createdAt.toIso8601String(),
        'tags':          tags,
        'is_pinned':     isPinned,
        if (linkedContentId   != null) 'linked_content_id':   linkedContentId,
        if (linkedContentType != null) 'linked_content_type': linkedContentType!.name,
      };

  PersonalNote copyWith({
    String?                id,
    String?                title,
    String?                content,
    DateTime?              lastModified,
    DateTime?              createdAt,
    List<String>?          tags,
    bool?                  isPinned,
    Object?                linkedContentId   = _sentinel,
    Object?                linkedContentType = _sentinel,
  }) =>
      PersonalNote(
        id:                id           ?? this.id,
        title:             title        ?? this.title,
        content:           content      ?? this.content,
        lastModified:      lastModified ?? this.lastModified,
        createdAt:         createdAt    ?? this.createdAt,
        tags:              tags         ?? this.tags,
        isPinned:          isPinned     ?? this.isPinned,
        linkedContentId:   linkedContentId   == _sentinel ? this.linkedContentId   : linkedContentId   as String?,
        linkedContentType: linkedContentType == _sentinel ? this.linkedContentType : linkedContentType as BookmarkContentType?,
      );
}

// ─────────────────────────────────────────────
// MARK: — SENTINEL (for copyWith nullable support)
// ─────────────────────────────────────────────

const Object _sentinel = Object();