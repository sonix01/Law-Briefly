// lib/features/bookmarks/data/models/bookmark_model.dart
import 'package:isar/isar.dart';

part 'bookmark_model.g.dart';

// ─────────────────────────────────────────────
// MARK: — ENUM
// ─────────────────────────────────────────────

enum BookmarkType {
  actSection,
  constitutionArticle;

  String get displayLabel => switch (this) {
        BookmarkType.actSection          => 'Act Section',
        BookmarkType.constitutionArticle => 'Constitution Article',
      };
}

// ─────────────────────────────────────────────
// MARK: — BOOKMARK MODEL (Isar Collection)
// ─────────────────────────────────────────────

@collection
@Name('bookmarks')
class BookmarkModel {
  // ── Isar primary key ─────────────────────────
  Id id = Isar.autoIncrement;

  // ── Content reference ─────────────────────────
  /// Section ID or Article ID — unique per bookmark.
  @Index(unique: true, replace: true)
  late String contentId;

  /// Display title of the bookmarked section or article.
  late String title;

  /// Section number ("318") or Article number ("21A").
  late String number;

  /// Act name or "Constitution of India".
  @Index()
  late String sourceName;

  // ── Classification ────────────────────────────
  @Enumerated(EnumType.name)
  late BookmarkType bookmarkType;

  // ── Timestamps ───────────────────────────────
  @Index()
  late DateTime createdAt;

  // ── User preference ───────────────────────────
  /// Future: allow users to mark key bookmarks as favourites.
  bool isFavorite = false;

  // ── Factory ──────────────────────────────────

  static BookmarkModel create({
    required String       contentId,
    required String       title,
    required String       number,
    required String       sourceName,
    required BookmarkType bookmarkType,
    bool                  isFavorite = false,
  }) {
    return BookmarkModel()
      ..contentId    = contentId
      ..title        = title
      ..number       = number
      ..sourceName   = sourceName
      ..bookmarkType = bookmarkType
      ..createdAt    = DateTime.now()
      ..isFavorite   = isFavorite;
  }

  // ── JSON support ─────────────────────────────

  Map<String, dynamic> toJson() => {
        'id':            id,
        'content_id':    contentId,
        'title':         title,
        'number':        number,
        'source_name':   sourceName,
        'bookmark_type': bookmarkType.name,
        'created_at':    createdAt.toIso8601String(),
        'is_favorite':   isFavorite,
      };

  factory BookmarkModel.fromJson(Map<String, dynamic> json) =>
      BookmarkModel()
        ..contentId    = json['content_id']    as String
        ..title        = json['title']         as String
        ..number       = json['number']        as String
        ..sourceName   = json['source_name']   as String
        ..bookmarkType = BookmarkType.values.byName(
            json['bookmark_type'] as String)
        ..createdAt    = DateTime.parse(json['created_at'] as String)
        ..isFavorite   = json['is_favorite']   as bool? ?? false;

  @override
  String toString() =>
      'BookmarkModel(contentId: $contentId, type: ${bookmarkType.name})';
}