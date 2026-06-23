// lib/core/database/database_models.dart
// Law Briefly — Core Isar Database Entities
// Run: dart run build_runner build --delete-conflicting-outputs
//
// NOTE — BookmarkEntity was removed from this file.
// The active BookmarkEntity lives at:
//   lib/features/bookmarks/data/models/bookmark_entity.dart
//   collection: 'bookmarks_v2'
// It is registered in IsarDatabaseService and wired to the
// Riverpod bookmark provider. Do not redefine it here.

import 'package:isar/isar.dart';

part 'database_models.g.dart';

// ═════════════════════════════════════════════
// MARK: — PERSONAL NOTE ENTITY
// ═════════════════════════════════════════════

@collection
@Name('personal_notes')
class PersonalNoteEntity {
  // ── Isar primary key ──────────────────────────
  Id id = Isar.autoIncrement;

  /// App-level string ID (UUID or custom).
  @Index(unique: true)
  late String noteId;

  // ── Domain fields ─────────────────────────────
  @Index()
  late String title;

  late String content;

  @Index()
  late DateTime lastModified;

  late DateTime createdAt;

  // ── Extended fields ───────────────────────────
  bool isPinned = false;

  /// Comma-separated tags. e.g. "Constitution,Part III,Revision"
  /// Future: Replace with a proper tags collection.
  List<String> tags = [];

  /// Links this note to a specific section/article ID.
  @Index()
  String? linkedContentId;

  /// Serialised name of content type. e.g. "section"
  String? linkedContentType;
}

// ═════════════════════════════════════════════
// MARK: — READER PROGRESS ENTITY
// Tracks reading position in Acts and Constitution.
// ═════════════════════════════════════════════

@collection
@Name('reader_progress')
class ReaderProgressEntity {
  // ── Isar primary key ──────────────────────────
  Id id = Isar.autoIncrement;

  /// The section/article ID being tracked.
  @Index(unique: true)
  late String contentId;

  /// Index within the parent list (chapter's sections or part's articles).
  /// Used to resume at the correct position.
  int lastReadPosition = 0;

  /// Pixel scroll offset within the content, for smooth resume.
  double scrollOffset = 0.0;

  @Index()
  late DateTime lastOpened;

  DateTime? firstOpened;

  /// Total time spent reading this content in seconds.
  int totalReadTimeSeconds = 0;

  /// True if the user has read to the end of this content.
  bool isCompleted = false;
}

// ═════════════════════════════════════════════
// MARK: — PDF PROGRESS ENTITY
// Tracks reading position in Academic Notes PDFs.
// ═════════════════════════════════════════════

@collection
@Name('pdf_progress')
class PdfProgressEntity {
  // ── Isar primary key ──────────────────────────
  Id id = Isar.autoIncrement;

  /// Matches AcademicSubject.id.
  @Index(unique: true)
  late String pdfId;

  // ── Reading state ─────────────────────────────
  int lastPage = 1;

  /// 0.0 – 100.0
  double progressPercentage = 0.0;

  @Index()
  late DateTime lastOpened;

  DateTime? firstOpened;

  /// Individual bookmarked page numbers within the PDF.
  List<int> bookmarkedPages = [];

  /// Total pages in the document (cached for progress calculation).
  int totalPages = 0;

  /// Zoom level at last session. 1.0 = 100%.
  double zoomLevel = 1.0;

  /// True if the user has reached the final page.
  bool isCompleted = false;
}

// ═════════════════════════════════════════════
// MARK: — USER PROFILE ENTITY
// Single-row table. Always query with userId == 'current_user'.
// ═════════════════════════════════════════════

@collection
@Name('user_profiles')
class UserProfileEntity {
  // ── Isar primary key ──────────────────────────
  Id id = Isar.autoIncrement;

  /// Fixed value 'current_user' for single-user apps.
  /// Ready for multi-user: swap to real user ID.
  @Index(unique: true)
  String userId = 'current_user';

  // ── Core profile ──────────────────────────────
  String fullName     = '';
  String email        = '';
  String mobileNumber = '';
  String college      = '';
  String course       = '';
  String semester     = '';
  String city         = '';
  String state        = '';

  // ── Timestamps ────────────────────────────────
  DateTime? createdAt;
  DateTime? updatedAt;

  // ── Future: marketplace & sync fields ─────────
  String? avatarPath;
  bool    isPremium          = false;
  String? subscriptionExpiry;
  String? deviceId;
}

// ═════════════════════════════════════════════
// MARK: — CORE SCHEMA REFERENCE
// ═════════════════════════════════════════════

/// Schemas defined in THIS file only.
/// Do NOT use this list directly for Isar.open().
/// Use IsarDatabaseService.initialize() which also adds:
///   - BookmarkEntitySchema  (features/bookmarks — bookmarks_v2)
///   - NoteEntitySchema      (features/notes     — notes_v2)
final List<CollectionSchema<dynamic>> coreIsarSchemas = [
  PersonalNoteEntitySchema,
  ReaderProgressEntitySchema,
  PdfProgressEntitySchema,
  UserProfileEntitySchema,
];