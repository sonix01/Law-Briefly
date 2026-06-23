// lib/features/pdf_reader/pdf_bookmark.dart
// Law Briefly — PDF Page Bookmark Model

// ─────────────────────────────────────────────
// MARK: — PDF BOOKMARK
// ─────────────────────────────────────────────

class PdfBookmark {
  final String   id;          // Stable: '{pdfId}_p{pageNumber}'
  final String   pdfId;       // References AcademicSubject.id
  final int      pageNumber;
  final DateTime createdAt;
  final String?  note;        // Optional annotation (future)

  const PdfBookmark({
    required this.id,
    required this.pdfId,
    required this.pageNumber,
    required this.createdAt,
    this.note,
  });

  // ─────────────────────────────────────────────
  // MARK: — FACTORY
  // ─────────────────────────────────────────────

  factory PdfBookmark.create({
    required String pdfId,
    required int    pageNumber,
    String?         note,
  }) =>
      PdfBookmark(
        id:         '${pdfId}_p$pageNumber',
        pdfId:      pdfId,
        pageNumber: pageNumber,
        createdAt:  DateTime.now(),
        note:       note,
      );

  // ─────────────────────────────────────────────
  // MARK: — FROM JSON
  // ─────────────────────────────────────────────

  factory PdfBookmark.fromJson(Map<String, dynamic> json) => PdfBookmark(
        id:         json['id']          as String,
        pdfId:      json['pdf_id']      as String,
        pageNumber: json['page_number'] as int,
        createdAt:  DateTime.parse(json['created_at'] as String),
        note:       json['note']        as String?,
      );

  // ─────────────────────────────────────────────
  // MARK: — TO JSON
  // ─────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'id':           id,
        'pdf_id':       pdfId,
        'page_number':  pageNumber,
        'created_at':   createdAt.toIso8601String(),
        if (note != null) 'note': note,
      };

  // ─────────────────────────────────────────────
  // MARK: — COPY WITH
  // ─────────────────────────────────────────────

  PdfBookmark copyWith({
    String?   id,
    String?   pdfId,
    int?      pageNumber,
    DateTime? createdAt,
    Object?   note = _sentinel,
  }) =>
      PdfBookmark(
        id:         id         ?? this.id,
        pdfId:      pdfId      ?? this.pdfId,
        pageNumber: pageNumber ?? this.pageNumber,
        createdAt:  createdAt  ?? this.createdAt,
        note:       note == _sentinel ? this.note : note as String?,
      );

  // ─────────────────────────────────────────────
  // MARK: — EQUALITY
  // ─────────────────────────────────────────────

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PdfBookmark &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'PdfBookmark(pdfId: $pdfId, page: $pageNumber)';
}

const Object _sentinel = Object();