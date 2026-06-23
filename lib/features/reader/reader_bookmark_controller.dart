// lib/features/reader/reader_bookmark_controller.dart
// Law Briefly — Reader Bookmark Controller
// In-Memory Implementation | Future-Ready for Isar/Hive/SQLite

import 'package:flutter/foundation.dart';

// ─────────────────────────────────────────────
// MARK: — BOOKMARK TYPE
// ─────────────────────────────────────────────

/// Identifies the kind of legal content a bookmark points to.
enum BookmarkType {
  /// A Constitution of India article (e.g. Article 21).
  article,

  /// An Act section (e.g. Section 318 of BNS).
  section;

  /// Human-readable label for display purposes.
  String get label => switch (this) {
        BookmarkType.article => 'Article',
        BookmarkType.section => 'Section',
      };
}

// ─────────────────────────────────────────────
// MARK: — BOOKMARK ITEM (Domain Model)
// ─────────────────────────────────────────────

/// Immutable representation of a single bookmarked piece of
/// legal content. This is a pure domain model — it carries no
/// persistence-layer annotations, so it can be mapped to/from
/// Isar, Hive, or SQLite entities without modification.
@immutable
class BookmarkItem {
  /// Unique identifier of the bookmarked content.
  /// Convention: matches the ReaderContent.id of the
  /// underlying article or section.
  final String id;

  /// Display title of the bookmarked content
  /// (e.g. "Right to Equality", "Cheating").
  final String title;

  /// Title of the parent source
  /// (e.g. "Constitution of India", "Bharatiya Nyaya Sanhita, 2023").
  final String parentTitle;

  /// Whether this bookmark refers to a Constitution article
  /// or an Act section.
  final BookmarkType type;

  /// Timestamp when the bookmark was created.
  final DateTime createdAt;

  const BookmarkItem({
    required this.id,
    required this.title,
    required this.parentTitle,
    required this.type,
    required this.createdAt,
  });

  // ── Factory ──────────────────────────────────

  /// Creates a new [BookmarkItem] with [createdAt] set to now.
  factory BookmarkItem.create({
    required String id,
    required String title,
    required String parentTitle,
    required BookmarkType type,
  }) =>
      BookmarkItem(
        id:          id,
        title:       title,
        parentTitle: parentTitle,
        type:        type,
        createdAt:   DateTime.now(),
      );

  // ── Copy With ────────────────────────────────

  BookmarkItem copyWith({
    String?       id,
    String?       title,
    String?       parentTitle,
    BookmarkType? type,
    DateTime?     createdAt,
  }) =>
      BookmarkItem(
        id:          id          ?? this.id,
        title:       title       ?? this.title,
        parentTitle: parentTitle ?? this.parentTitle,
        type:        type        ?? this.type,
        createdAt:   createdAt   ?? this.createdAt,
      );

  // ── Serialization (future Isar/Hive/SQLite mapping) ──

  /// Converts this domain model to a plain map.
  /// Persistence layers can use this as a bridge when
  /// mapping to their own entity types.
  Map<String, dynamic> toMap() => {
        'id':           id,
        'title':        title,
        'parent_title': parentTitle,
        'type':         type.name,
        'created_at':   createdAt.toIso8601String(),
      };

  /// Reconstructs a [BookmarkItem] from a plain map.
  factory BookmarkItem.fromMap(Map<String, dynamic> map) => BookmarkItem(
        id:          map['id']           as String,
        title:       map['title']        as String,
        parentTitle: map['parent_title'] as String,
        type: BookmarkType.values.firstWhere(
          (t) => t.name == map['type'],
          orElse: () => BookmarkType.section,
        ),
        createdAt: DateTime.parse(map['created_at'] as String),
      );

  // ── Equality ─────────────────────────────────

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookmarkItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type;

  @override
  int get hashCode => Object.hash(id, type);

  @override
  String toString() =>
      'BookmarkItem(id: $id, title: $title, type: ${type.name})';
}

// ─────────────────────────────────────────────
// MARK: — READER BOOKMARK CONTROLLER
// ─────────────────────────────────────────────

/// Manages bookmarks for legal reading content (Constitution
/// Articles and Act Sections) within the Reader feature.
///
/// ## Architecture Notes
/// This controller currently stores bookmarks **in-memory** only.
/// It is intentionally designed so that the storage mechanism can
/// be swapped out later (Isar / Hive / SQLite) without requiring
/// any change to the public API surface used by the UI layer.
///
/// To migrate to a persistent store in the future:
/// 1. Replace the internal `Map<String, BookmarkItem> _bookmarks`
///    with calls to the chosen persistence layer.
/// 2. Keep every public method signature identical.
/// 3. Make each method `async` if the storage layer requires it,
///    and update call sites accordingly (UI already expects
///    Future-returning bookmark actions where relevant).
///
/// This class extends [ChangeNotifier] so that UI widgets can
/// listen for bookmark state changes without needing a full
/// state-management framework wired in at this stage.
class ReaderBookmarkController extends ChangeNotifier {
  static const String _tag = 'ReaderBookmarkController';

  // ── In-memory store ───────────────────────────
  // Key: BookmarkItem.id → BookmarkItem
  // NOTE: Replace this map with an injected repository
  // (e.g. IsarBookmarkRepository) when persistence is added.
  final Map<String, BookmarkItem> _bookmarks = {};

  // ─────────────────────────────────────────────
  // MARK: — QUERY
  // ─────────────────────────────────────────────

  /// Returns `true` if content with the given [id] is bookmarked.
  bool isBookmarked(String id) => _bookmarks.containsKey(id);

  /// Returns the [BookmarkItem] for [id], or `null` if not bookmarked.
  BookmarkItem? getBookmark(String id) => _bookmarks[id];

  /// Returns all bookmarks, most recently created first.
  List<BookmarkItem> getAllBookmarks() {
    final items = _bookmarks.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(items);
  }

  /// Returns all bookmarks of a specific [type]
  /// (e.g. only Constitution articles).
  List<BookmarkItem> getBookmarksByType(BookmarkType type) =>
      getAllBookmarks().where((b) => b.type == type).toList();

  /// Total number of bookmarks currently stored.
  int get bookmarkCount => _bookmarks.length;

  /// Whether there are no bookmarks at all.
  bool get isEmpty => _bookmarks.isEmpty;

  // ─────────────────────────────────────────────
  // MARK: — MUTATIONS
  // ─────────────────────────────────────────────

  /// Adds a bookmark for the given content.
  /// If a bookmark with the same [id] already exists, it is
  /// overwritten (idempotent add).
  void addBookmark({
    required String id,
    required String title,
    required String parentTitle,
    required BookmarkType type,
  }) {
    final item = BookmarkItem.create(
      id:          id,
      title:       title,
      parentTitle: parentTitle,
      type:        type,
    );

    _bookmarks[id] = item;
    debugPrint('[$_tag] Added bookmark: $item');
    notifyListeners();
  }

  /// Removes the bookmark with the given [id].
  /// Does nothing if no such bookmark exists.
  void removeBookmark(String id) {
    final removed = _bookmarks.remove(id);
    if (removed != null) {
      debugPrint('[$_tag] Removed bookmark: $id');
      notifyListeners();
    } else {
      debugPrint('[$_tag] removeBookmark: no bookmark found for $id');
    }
  }

  /// Toggles the bookmark state for the given content.
  ///
  /// - If currently bookmarked → removes it.
  /// - If not currently bookmarked → adds it using the
  ///   provided [title], [parentTitle], and [type].
  ///
  /// Returns the new bookmark state (`true` if now bookmarked,
  /// `false` if now removed).
  bool toggleBookmark({
    required String id,
    required String title,
    required String parentTitle,
    required BookmarkType type,
  }) {
    if (isBookmarked(id)) {
      removeBookmark(id);
      return false;
    } else {
      addBookmark(
        id:          id,
        title:       title,
        parentTitle: parentTitle,
        type:        type,
      );
      return true;
    }
  }

  /// Removes all bookmarks.
  void clearBookmarks() {
    final count = _bookmarks.length;
    _bookmarks.clear();
    debugPrint('[$_tag] Cleared $count bookmark(s).');
    notifyListeners();
  }

  // ─────────────────────────────────────────────
  // MARK: — DISPOSE
  // ─────────────────────────────────────────────

  @override
  void dispose() {
    debugPrint('[$_tag] Disposed with ${_bookmarks.length} bookmark(s) in memory.');
    super.dispose();
  }
}