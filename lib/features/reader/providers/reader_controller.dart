import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../data/reader_repository.dart';
import '../data/reader_repository_impl.dart';
import '../models/reader_content.dart';
import '../models/reader_state.dart';

// ─────────────────────────────────────────────
// MARK: — REPOSITORY PROVIDER
// ─────────────────────────────────────────────

final readerRepositoryProvider = Provider<ReaderRepository>((ref) {
  final impl = ReaderRepositoryImpl();
  ref.onDispose(impl.clearCache);
  return impl;
});

// ─────────────────────────────────────────────
// MARK: — READER CONTROLLER
// ─────────────────────────────────────────────

class ReaderController extends StateNotifier<ReaderState> {
  final ReaderRepository _repository;

  static const String _tag = 'ReaderController';

  ReaderController(this._repository) : super(const ReaderState.initial());

  // ─────────────────────────────────────────────
  // MARK: — LOAD ACT SECTION
  // ─────────────────────────────────────────────

  Future<void> loadActSection({
    required String actId,
    required String sectionId,
  }) async {
    if (!mounted) return;
    state = const ReaderState.loading();

    try {
      final content = await _repository.getActSection(
        actId:     actId,
        sectionId: sectionId,
      );

      if (!mounted) return;

      if (content == null) {
        state = ReaderState.failure('Section not found.');
        debugPrint('[$_tag] Section not found: $sectionId in $actId');
        return;
      }

      state = ReaderState.success(content);
      debugPrint('[$_tag] Loaded act section: ${content.displayLabel}');
    } catch (e) {
      if (!mounted) return;
      final message = _extractMessage(e);
      state = ReaderState.failure(message);
      debugPrint('[$_tag] loadActSection error: $e');
    }
  }

  // ─────────────────────────────────────────────
  // MARK: — LOAD CONSTITUTION ARTICLE
  // ─────────────────────────────────────────────

  Future<void> loadConstitutionArticle({
    required String partId,
    required String articleId,
  }) async {
    if (!mounted) return;
    state = const ReaderState.loading();

    try {
      final content = await _repository.getConstitutionArticle(
        partId:    partId,
        articleId: articleId,
      );

      if (!mounted) return;

      if (content == null) {
        state = ReaderState.failure('Article not found.');
        debugPrint('[$_tag] Article not found: $articleId in part $partId');
        return;
      }

      state = ReaderState.success(content);
      debugPrint('[$_tag] Loaded constitution article: ${content.displayLabel}');
    } catch (e) {
      if (!mounted) return;
      final message = _extractMessage(e);
      state = ReaderState.failure(message);
      debugPrint('[$_tag] loadConstitutionArticle error: $e');
    }
  }

  // ─────────────────────────────────────────────
  // MARK: — NAVIGATION
  // ─────────────────────────────────────────────

  Future<void> loadNext() async {
    final current = state.content;
    if (current == null || !current.hasNext) return;
    if (!mounted) return;

    state = state.copyWith(isLoading: true);

    try {
      final next = await _repository.getNextContent(currentContent: current);
      if (!mounted) return;

      if (next == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      state = ReaderState.success(next);
      debugPrint('[$_tag] Navigated next → ${next.displayLabel}');
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false);
      debugPrint('[$_tag] loadNext error: $e');
    }
  }

  Future<void> loadPrevious() async {
    final current = state.content;
    if (current == null || !current.hasPrevious) return;
    if (!mounted) return;

    state = state.copyWith(isLoading: true);

    try {
      final previous =
          await _repository.getPreviousContent(currentContent: current);
      if (!mounted) return;

      if (previous == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      state = ReaderState.success(previous);
      debugPrint('[$_tag] Navigated previous → ${previous.displayLabel}');
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false);
      debugPrint('[$_tag] loadPrevious error: $e');
    }
  }

  // ─────────────────────────────────────────────
  // MARK: — RELOAD / RESET
  // ─────────────────────────────────────────────

  Future<void> reload() async {
    final content = state.content;
    if (content == null) return;

    if (content.isActSection && content.actId != null) {
      await loadActSection(actId: content.actId!, sectionId: content.id);
    } else if (content.isArticle && content.partId != null) {
      await loadConstitutionArticle(partId: content.partId!, articleId: content.id);
    }
  }

  void reset() {
    if (!mounted) return;
    state = const ReaderState.initial();
  }

  // ─────────────────────────────────────────────
  // MARK: — PRIVATE
  // ─────────────────────────────────────────────

  String _extractMessage(Object e) {
    if (e is Exception) {
      final msg = e.toString();
      return msg.contains(':') ? msg.split(':').last.trim() : msg;
    }
    return 'An unexpected error occurred.';
  }
}

// ─────────────────────────────────────────────
// MARK: — PROVIDER
// ─────────────────────────────────────────────

final readerControllerProvider =
    StateNotifierProvider.autoDispose<ReaderController, ReaderState>((ref) {
  final repository = ref.watch(readerRepositoryProvider);
  return ReaderController(repository);
});

// ── Convenience providers ─────────────────────

final readerContentProvider = Provider.autoDispose<ReaderContent?>(
  (ref) => ref.watch(readerControllerProvider).content,
);

final readerLoadingProvider = Provider.autoDispose<bool>(
  (ref) => ref.watch(readerControllerProvider).isLoading,
);

final readerErrorProvider = Provider.autoDispose<String?>(
  (ref) => ref.watch(readerControllerProvider).error,
);