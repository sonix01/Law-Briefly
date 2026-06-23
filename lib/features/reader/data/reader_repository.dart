import '../models/reader_content.dart';

// ─────────────────────────────────────────────
// MARK: — READER REPOSITORY CONTRACT
// ─────────────────────────────────────────────

abstract class ReaderRepository {
  /// Loads a specific Act section from local JSON assets.
  /// Returns null if the act or section is not found.
  Future<ReaderContent?> getActSection({
    required String actId,
    required String sectionId,
  });

  /// Loads a specific Constitution article from local JSON assets.
  /// Returns null if the part or article is not found.
  Future<ReaderContent?> getConstitutionArticle({
    required String partId,
    required String articleId,
  });

  /// Returns the next ReaderContent relative to [currentContent].
  /// Uses nextId from currentContent to resolve the next item.
  /// Returns null if no next item exists.
  Future<ReaderContent?> getNextContent({
    required ReaderContent currentContent,
  });

  /// Returns the previous ReaderContent relative to [currentContent].
  /// Uses previousId from currentContent to resolve the previous item.
  /// Returns null if no previous item exists.
  Future<ReaderContent?> getPreviousContent({
    required ReaderContent currentContent,
  });
}