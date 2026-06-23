// lib/features/notes/data/models/note_model.dart
import 'package:isar/isar.dart';

part 'note_model.g.dart';

// ─────────────────────────────────────────────
// MARK: — ENUM
// ─────────────────────────────────────────────

enum NoteType {
  general,
  actSection,
  constitutionArticle;

  String get displayLabel => switch (this) {
        NoteType.general              => 'General',
        NoteType.actSection           => 'Act Section',
        NoteType.constitutionArticle  => 'Constitution Article',
      };

  bool get isLinked => this != NoteType.general;
}

// ─────────────────────────────────────────────
// MARK: — NOTE MODEL (Isar Collection)
// ─────────────────────────────────────────────

@collection
@Name('notes')
class NoteModel {
  // ── Isar primary key ─────────────────────────
  Id id = Isar.autoIncrement;

  // ── Content ──────────────────────────────────
  late String title;

  late String content;

  // ── Classification ────────────────────────────
  @Enumerated(EnumType.name)
  late NoteType noteType;

  // ── Optional link to legal content ───────────
  @Index()
  String? linkedContentId;

  String? linkedContentTitle;

  // ── Timestamps ───────────────────────────────
  late DateTime createdAt;

  @Index()
  late DateTime updatedAt;

  // ── User preferences ─────────────────────────
  bool isPinned   = false;
  bool isFavorite = false;

  // ── Computed ─────────────────────────────────

  bool get isEmpty   => title.trim().isEmpty && content.trim().isEmpty;
  bool get isLinked  => linkedContentId != null;

  int  get wordCount {
    final text = content.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).length;
  }

  // ── Factory ──────────────────────────────────

  static NoteModel create({
    required String title,
    required String content,
    NoteType        noteType           = NoteType.general,
    String?         linkedContentId,
    String?         linkedContentTitle,
    bool            isPinned           = false,
    bool            isFavorite         = false,
  }) {
    final now = DateTime.now();
    return NoteModel()
      ..title              = title.trim()
      ..content            = content
      ..noteType           = noteType
      ..linkedContentId    = linkedContentId
      ..linkedContentTitle = linkedContentTitle
      ..createdAt          = now
      ..updatedAt          = now
      ..isPinned           = isPinned
      ..isFavorite         = isFavorite;
  }

  // ── JSON ─────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'id':                   id,
        'title':                title,
        'content':              content,
        'note_type':            noteType.name,
        'linked_content_id':    linkedContentId,
        'linked_content_title': linkedContentTitle,
        'created_at':           createdAt.toIso8601String(),
        'updated_at':           updatedAt.toIso8601String(),
        'is_pinned':            isPinned,
        'is_favorite':          isFavorite,
      };

  @override
  String toString() => 'NoteModel(id: $id, title: $title)';
}