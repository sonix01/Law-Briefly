import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/case_law_repository.dart';
import '../data/case_law_repository_impl.dart';
import '../models/case_law.dart';

// ─────────────────────────────────────────────
// MARK: — REPOSITORY PROVIDER
// ─────────────────────────────────────────────

final caseLawRepositoryProvider = Provider<CaseLawRepository>((ref) {
  final impl = CaseLawRepositoryImpl();
  ref.onDispose(impl.clearCache);
  return impl;
});

// ─────────────────────────────────────────────
// MARK: — CASE LAW BY ID
// ─────────────────────────────────────────────

/// Loads a single case law by its ID.
/// Usage: ref.watch(caseLawByIdProvider('cl_sample_001'))
final caseLawByIdProvider =
    FutureProvider.autoDispose.family<CaseLaw?, String>((ref, id) async {
  if (id.isEmpty) return null;
  final repository = ref.watch(caseLawRepositoryProvider);
  return repository.getCaseLawById(id);
});

// ─────────────────────────────────────────────
// MARK: — CASE LAWS BY IDS
// ─────────────────────────────────────────────

/// Loads multiple case laws by their IDs.
/// Usage: ref.watch(caseLawsByIdsProvider(['id1', 'id2']))
final caseLawsByIdsProvider =
    FutureProvider.autoDispose.family<List<CaseLaw>, List<String>>(
  (ref, ids) async {
    if (ids.isEmpty) return const [];
    final repository = ref.watch(caseLawRepositoryProvider);
    return repository.getCaseLawsByIds(ids);
  },
);