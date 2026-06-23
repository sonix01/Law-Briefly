import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/case_law_repository.dart';
import '../models/case_law_state.dart';
import 'case_law_controller.dart';

// ─────────────────────────────────────────────
// MARK: — CASE LAW POPUP CONTROLLER
// ─────────────────────────────────────────────

class CaseLawPopupController extends StateNotifier<CaseLawState> {
  final CaseLawRepository _repository;

  static const String _tag = 'CaseLawPopupController';

  CaseLawPopupController(this._repository)
      : super(const CaseLawState.initial());

  // ─────────────────────────────────────────────
  // MARK: — LOAD CASE LAW
  // ─────────────────────────────────────────────

  Future<void> loadCaseLaw(String caseLawId) async {
    if (!mounted) return;

    if (caseLawId.trim().isEmpty) {
      state = CaseLawState.failure('Invalid case law ID.');
      return;
    }

    state = const CaseLawState.loading();

    try {
      final caseLaw = await _repository.getCaseLawById(caseLawId.trim());

      if (!mounted) return;

      if (caseLaw == null) {
        state = CaseLawState.failure('Case law not found.');
        debugPrint('[$_tag] Not found: $caseLawId');
        return;
      }

      state = CaseLawState.success(caseLaw);
      debugPrint('[$_tag] Loaded: ${caseLaw.title}');
    } catch (e) {
      if (!mounted) return;
      final message = _parseError(e);
      state = CaseLawState.failure(message);
      debugPrint('[$_tag] Error loading $caseLawId: $e');
    }
  }

  // ─────────────────────────────────────────────
  // MARK: — RETRY
  // ─────────────────────────────────────────────

  Future<void> retry(String caseLawId) async => loadCaseLaw(caseLawId);

  void reset() {
    if (!mounted) return;
    state = const CaseLawState.initial();
  }

  // ─────────────────────────────────────────────
  // MARK: — PRIVATE
  // ─────────────────────────────────────────────

  String _parseError(Object e) {
    final raw = e.toString();
    if (raw.contains(':')) return raw.split(':').last.trim();
    return 'Failed to load case law.';
  }
}

// ─────────────────────────────────────────────
// MARK: — PROVIDER
// ─────────────────────────────────────────────

final caseLawPopupControllerProvider = StateNotifierProvider.autoDispose
    .family<CaseLawPopupController, CaseLawState, String>(
  (ref, caseLawId) {
    final repository = ref.watch(caseLawRepositoryProvider);
    final controller = CaseLawPopupController(repository);
    // Auto-load when provider is created
    Future.microtask(() => controller.loadCaseLaw(caseLawId));
    return controller;
  },
);