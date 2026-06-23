// lib/features/reader/data/models/reader_progress_model.dart
import 'package:isar/isar.dart';

part 'reader_progress_model.g.dart';

// ─────────────────────────────────────────────
// MARK: — ENUM
// ─────────────────────────────────────────────

enum ReaderContentType {
  actSection,
  constitutionArticle;

  String get displayLabel => switch (this) {
        ReaderContentType.actSection          => 'Act Section',
        ReaderContentType.constitutionArticle => 'Constitution Article',
      };
}

// ─────────────────────────────────────────────
// MARK: — READER PROGRESS MODEL (Isar Collection)
// ─────────────────────────────────────────────

@collection
@Name('reader_progress')
class ReaderProgressModel {
  // ── Isar primary key ─────────────────────────
  Id id = Isar.autoIncrement;

  // ── Content reference ─────────────────────────
  /// Section ID or Article ID — unique per progress record.
  @Index(unique: true, replace: true)
  late String contentId;

  /// Whether this is an act section or constitution article.
  @Enumerated(EnumType.name)
  late ReaderContentType contentType;

  // ── Display metadata ─────────────────────────
  late String title;
  late String number;

  /// Act name (e.g., "BNS 2023") or "Constitution of India".
  late String sourceName;

  // ── Reading position ─────────────────────────
  /// Pixel scroll offset for future scroll restoration.
  double scrollOffset = 0.0;

  // ── Timestamps ───────────────────────────────
  @Index()
  late DateTime lastOpenedAt;

  DateTime? firstOpenedAt;

  /// Total seconds spent reading this content.
  int totalReadSeconds = 0;

  // ── Factory ──────────────────────────────────

  static ReaderProgressModel create({
    required String            contentId,
    required ReaderContentType contentType,
    required String            title,
    required String            number,
    required String            sourceName,
    double                     scrollOffset = 0.0,
  }) {
    final now = DateTime.now();
    return ReaderProgressModel()
      ..contentId      = contentId
      ..contentType    = contentType
      ..title          = title
      ..number         = number
      ..sourceName     = sourceName
      ..scrollOffset   = scrollOffset
      ..lastOpenedAt   = now
      ..firstOpenedAt  = now
      ..totalReadSeconds = 0;
  }

  static ReaderProgressModel update({
    required ReaderProgressModel existing,
    double?                       scrollOffset,
    int?                          additionalSeconds,
  }) {
    return ReaderProgressModel()
      ..id              = existing.id
      ..contentId       = existing.contentId
      ..contentType     = existing.contentType
      ..title           = existing.title
      ..number          = existing.number
      ..sourceName      = existing.sourceName
      ..scrollOffset    = scrollOffset   ?? existing.scrollOffset
      ..lastOpenedAt    = DateTime.now()
      ..firstOpenedAt   = existing.firstOpenedAt
      ..totalReadSeconds = existing.totalReadSeconds + (additionalSeconds ?? 0);
  }

  // ── JSON ─────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'id':                id,
        'content_id':        contentId,
        'content_type':      contentType.name,
        'title':             title,
        'number':            number,
        'source_name':       sourceName,
        'scroll_offset':     scrollOffset,
        'last_opened_at':    lastOpenedAt.toIso8601String(),
        'first_opened_at':   firstOpenedAt?.toIso8601String(),
        'total_read_seconds': totalReadSeconds,
      };

  @override
  String toString() =>
      'ReaderProgressModel(contentId: $contentId, type: ${contentType.name}, '
      'lastOpened: $lastOpenedAt)';
}