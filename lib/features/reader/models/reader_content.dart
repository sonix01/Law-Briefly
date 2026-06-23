import 'dart:convert';

// ─────────────────────────────────────────────
// MARK: — CONTENT BLOCK TYPE
// ─────────────────────────────────────────────

enum ContentBlockType {
  main,
  explanation,
  proviso,
  subSection;

  static ContentBlockType fromString(String value) =>
      ContentBlockType.values.firstWhere(
        (t) => t.name == value,
        orElse: () => ContentBlockType.main,
      );
}

// ─────────────────────────────────────────────
// MARK: — CONTENT BLOCK (domain model)
// ─────────────────────────────────────────────

class ContentBlock {
  final ContentBlockType type;
  final String?          label;
  final String           text;

  const ContentBlock({
    required this.type,
    required this.text,
    this.label,
  });

  factory ContentBlock.fromJson(Map<String, dynamic> json) => ContentBlock(
        type:  ContentBlockType.fromString(json['type'] as String? ?? 'main'),
        label: json['label'] as String?,
        text:  json['text']  as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'type':              type.name,
        if (label != null) 'label': label,
        'text':              text,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentBlock &&
          type  == other.type  &&
          label == other.label &&
          text  == other.text;

  @override
  int get hashCode => Object.hash(type, label, text);
}

// ─────────────────────────────────────────────
// MARK: — READER CONTENT (domain model)
// ─────────────────────────────────────────────

class ReaderContent {
  // ── Required ──────────────────────────────────
  final String             id;
  final String             number;
  final String             title;
  final List<ContentBlock> content;

  // ── Act context ───────────────────────────────
  final String? chapterId;
  final String? chapterTitle;
  final String? actId;
  final String? actTitle;

  // ── Constitution context ─────────────────────
  final String? partId;
  final String? partTitle;

  // ── Case law support ─────────────────────────
  final List<String> caseLawIds;

  // ── Navigation ───────────────────────────────
  final String? previousId;
  final String? nextId;

  // ── Metadata ─────────────────────────────────
  final DateTime? lastUpdated;

  const ReaderContent({
    required this.id,
    required this.number,
    required this.title,
    required this.content,
    this.chapterId,
    this.chapterTitle,
    this.actId,
    this.actTitle,
    this.partId,
    this.partTitle,
    this.caseLawIds   = const [],
    this.previousId,
    this.nextId,
    this.lastUpdated,
  });

  // ── Computed ─────────────────────────────────

  bool get hasCaseLaws  => caseLawIds.isNotEmpty;
  bool get hasNext      => nextId     != null;
  bool get hasPrevious  => previousId != null;
  bool get isActSection => actId      != null;
  bool get isArticle    => partId     != null;

  String get sourceName {
    if (actTitle  != null) return actTitle!;
    if (partTitle != null) return partTitle!;
    return 'Law Briefly';
  }

  String get displayLabel {
    if (number.toLowerCase() == 'preamble') return 'Preamble';
    if (isActSection) return 'Section $number';
    return 'Article $number';
  }

  // ── FROM JSON ─────────────────────────────────

  factory ReaderContent.fromJson(Map<String, dynamic> json) {
    List<ContentBlock> parseContent() {
      final raw = json['content'];
      if (raw == null)         return const [];
      if (raw is String)       {
        try {
          final decoded = jsonDecode(raw) as List<dynamic>;
          return decoded
              .whereType<Map<String, dynamic>>()
              .map(ContentBlock.fromJson)
              .toList();
        } catch (_) {
          return [ContentBlock(type: ContentBlockType.main, text: raw)];
        }
      }
      if (raw is List) {
        return raw
            .whereType<Map<String, dynamic>>()
            .map(ContentBlock.fromJson)
            .toList();
      }
      return const [];
    }

    return ReaderContent(
      id:           json['id']           as String,
      number:       json['number']       as String,
      title:        json['title']        as String,
      content:      parseContent(),
      chapterId:    json['chapter_id']   as String?,
      chapterTitle: json['chapter_title'] as String?,
      actId:        json['act_id']       as String?,
      actTitle:     json['act_title']    as String?,
      partId:       json['part_id']      as String?,
      partTitle:    json['part_title']   as String?,
      caseLawIds:   List<String>.from(json['case_law_ids'] as List? ?? []),
      previousId:   json['previous_id']  as String?,
      nextId:       json['next_id']      as String?,
      lastUpdated:  json['last_updated'] != null
          ? DateTime.tryParse(json['last_updated'] as String)
          : null,
    );
  }

  // ── TO JSON ───────────────────────────────────

  Map<String, dynamic> toJson() => {
        'id':            id,
        'number':        number,
        'title':         title,
        'content':       content.map((b) => b.toJson()).toList(),
        if (chapterId    != null) 'chapter_id':    chapterId,
        if (chapterTitle != null) 'chapter_title': chapterTitle,
        if (actId        != null) 'act_id':        actId,
        if (actTitle     != null) 'act_title':     actTitle,
        if (partId       != null) 'part_id':       partId,
        if (partTitle    != null) 'part_title':    partTitle,
        'case_law_ids':  caseLawIds,
        if (previousId   != null) 'previous_id':   previousId,
        if (nextId       != null) 'next_id':       nextId,
        if (lastUpdated  != null)
          'last_updated': lastUpdated!.toIso8601String(),
      };

  // ── COPY WITH ─────────────────────────────────

  ReaderContent copyWith({
    String?             id,
    String?             number,
    String?             title,
    List<ContentBlock>? content,
    Object?             chapterId    = _sentinel,
    Object?             chapterTitle = _sentinel,
    Object?             actId        = _sentinel,
    Object?             actTitle     = _sentinel,
    Object?             partId       = _sentinel,
    Object?             partTitle    = _sentinel,
    List<String>?       caseLawIds,
    Object?             previousId   = _sentinel,
    Object?             nextId       = _sentinel,
    Object?             lastUpdated  = _sentinel,
  }) =>
      ReaderContent(
        id:           id           ?? this.id,
        number:       number       ?? this.number,
        title:        title        ?? this.title,
        content:      content      ?? this.content,
        chapterId:    chapterId    == _sentinel ? this.chapterId    : chapterId    as String?,
        chapterTitle: chapterTitle == _sentinel ? this.chapterTitle : chapterTitle as String?,
        actId:        actId        == _sentinel ? this.actId        : actId        as String?,
        actTitle:     actTitle     == _sentinel ? this.actTitle     : actTitle     as String?,
        partId:       partId       == _sentinel ? this.partId       : partId       as String?,
        partTitle:    partTitle    == _sentinel ? this.partTitle    : partTitle    as String?,
        caseLawIds:   caseLawIds   ?? this.caseLawIds,
        previousId:   previousId   == _sentinel ? this.previousId   : previousId   as String?,
        nextId:       nextId       == _sentinel ? this.nextId       : nextId       as String?,
        lastUpdated:  lastUpdated  == _sentinel ? this.lastUpdated  : lastUpdated  as DateTime?,
      );

  // ── EQUALITY ─────────────────────────────────

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReaderContent &&
          id     == other.id    &&
          actId  == other.actId &&
          partId == other.partId;

  @override
  int get hashCode => Object.hash(id, actId, partId);

  @override
  String toString() =>
      'ReaderContent(id: $id, number: $number, title: $title, '
      'caseLaws: ${caseLawIds.length})';
}

const Object _sentinel = Object();