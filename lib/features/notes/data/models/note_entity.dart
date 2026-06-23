// lib/features/notes/data/models/note_entity.dart
import 'package:isar/isar.dart';

part 'note_entity.g.dart';

// ─────────────────────────────────────────────
// MARK: — NOTE ENTITY
// ─────────────────────────────────────────────

@collection
@Name('notes_v2')
class NoteEntity {
  Id id = Isar.autoIncrement;

  @Index()
  late String title;

  late String content;

  late DateTime createdAt;

  @Index()
  late DateTime updatedAt;

  // ── Factory ──────────────────────────────────

  static NoteEntity create({
    required String title,
    required String content,
  }) {
    final now = DateTime.now();
    return NoteEntity()
      ..title     = title.trim()
      ..content   = content
      ..createdAt = now
      ..updatedAt = now;
  }

  static NoteEntity update({
    required NoteEntity existing,
    required String     title,
    required String     content,
  }) =>
      NoteEntity()
        ..id        = existing.id
        ..title     = title.trim()
        ..content   = content
        ..createdAt = existing.createdAt
        ..updatedAt = DateTime.now();

  // ── Computed ─────────────────────────────────

  int get wordCount {
    final text = content.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).length;
  }

  int get charCount => content.length;

  bool get isEmpty => title.trim().isEmpty && content.trim().isEmpty;

  // ── JSON ─────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'id':         id,
        'title':      title,
        'content':    content,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  @override
  String toString() => 'NoteEntity(id: $id, title: $title)';
}