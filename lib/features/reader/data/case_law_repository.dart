import '../models/case_law.dart';

// ─────────────────────────────────────────────
// MARK: — CASE LAW REPOSITORY CONTRACT
// ─────────────────────────────────────────────

abstract class CaseLawRepository {
  /// Returns all case laws matching the given list of IDs.
  /// Preserves the original order of [ids].
  /// Returns an empty list if none are found.
  Future<List<CaseLaw>> getCaseLawsByIds(List<String> ids);

  /// Returns the case law for the given [id].
  /// Returns null if not found.
  Future<CaseLaw?> getCaseLawById(String id);
}