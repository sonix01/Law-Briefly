// lib/features/bookmarks/data/models/bookmark_entity.dart
import 'package:isar/isar.dart';

part 'bookmark_entity.g.dart';

// ─────────────────────────────────────────────
// MARK: — BOOKMARK ENTITY
// ─────────────────────────────────────────────

@collection
@Name('bookmarks_v2')
class BookmarkEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String contentId;

  late String title;

  /// Source name: "Bharatiya Nyaya Sanhita" or "Constitution of India"
  late String source;

  /// "actSection" or "constitutionArticle"
  @Index()
  late String type;

  @Index()
  late DateTime createdAt;

  // ── Factory ──────────────────────────────────

  static BookmarkEntity create({
    required String contentId,
    required String title,
    required String source,
    required String type,
  }) =>
      BookmarkEntity()
        ..contentId = contentId
        ..title     = title
        ..source    = source
        ..type      = type
        ..createdAt = DateTime.now();

  // ── JSON ─────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'id':          id,
        'content_id':  contentId,
        'title':       title,
        'source':      source,
        'type':        type,
        'created_at':  createdAt.toIso8601String(),
      };

  @override
  String toString() =>
      'BookmarkEntity(contentId: $contentId, type: $type, title: $title)';
}