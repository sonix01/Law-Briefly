// lib/features/reader/providers/reader_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../../data/models/legal_models.dart';
import '../services/reader_content_service.dart';
import '../data/case_law_repository_impl.dart';
import '../../acts/data/acts_repository_impl.dart';
import '../../constitution/data/constitution_repository_impl.dart';

// ─────────────────────────────────────────────
// MARK: — READER STATE
// ─────────────────────────────────────────────

class ReaderState {
  final bool               isLoading;
  final String?            errorMessage;
  final ReaderContentData? currentContent;
  final List<CaseLaw>      linkedCaseLaws;

  const ReaderState({
    this.isLoading      = false,
    this.errorMessage   = null,
    this.currentContent = null,
    this.linkedCaseLaws = const [],
  });

  bool get hasContent  => currentContent != null;
  bool get hasError    => errorMessage != null;
  bool get hasCaseLaws => linkedCaseLaws.isNotEmpty;
  bool get canGoNext   => currentContent?.hasNext     ?? false;
  bool get canGoPrev   => currentContent?.hasPrevious ?? false;
  bool get isIdle      => !isLoading && currentContent == null && errorMessage == null;

  ReaderState copyWith({
    bool?               isLoading,
    Object?             errorMessage   = _sentinel,
    Object?             currentContent = _sentinel,
    List<CaseLaw>?      linkedCaseLaws,
  }) =>
      ReaderState(
        isLoading:      isLoading      ?? this.isLoading,
        errorMessage:   errorMessage   == _sentinel
            ? this.errorMessage   : errorMessage as String?,
        currentContent: currentContent == _sentinel
            ? this.currentContent : currentContent as ReaderContentData?,
        linkedCaseLaws: linkedCaseLaws ?? this.linkedCaseLaws,
      );

  @override
  String toString() =>
      'ReaderState(loading: $isLoading, hasContent: $hasContent, '
      'caseLaws: ${linkedCaseLaws.length}, error: $errorMessage)';
}

const Object _sentinel = Object();

// ─────────────────────────────────────────────
// MARK: — SERVICE PROVIDER
// ─────────────────────────────────────────────

final readerContentServiceProvider = Provider<ReaderContentService>((ref) {
  return ReaderContentService(
    actsRepository:         ActsRepositoryImpl(),
    constitutionRepository: ConstitutionRepositoryImpl(),
    caseLawRepository:      CaseLawRepositoryImpl(),
  );
});

// ─────────────────────────────────────────────
// MARK: — READER NOTIFIER
// ─────────────────────────────────────────────

class ReaderNotifier extends StateNotifier<ReaderState> {
  final ReaderContentService _service;

  static const String _tag = 'ReaderNotifier';

  ReaderNotifier(this._service) : super(const ReaderState());

  // ── LOAD ACT SECTION ─────────────────────────

  Future<void> loadActSection({
    required String actId,
    required String sectionId,
    String?         chapterId,
  }) async {
    _setLoading();
    try {
      final content = await _service.getActSectionContent(
        actId:     actId,
        sectionId: sectionId,
        chapterId: chapterId,
      );

      if (content == null) {
        _setError('Section not found.');
        return;
      }

      await _applyContent(content);
      debugPrint('[$_tag] Loaded act section: ${content.displayLabel}');
    } catch (e) {
      debugPrint('[$_tag] loadActSection error: $e');
      _setError('Failed to load section.');
    }
  }

  // ── LOAD CONSTITUTION ARTICLE ─────────────────

  Future<void> loadConstitutionArticle({
    required String articleId,
    String?         partId,
  }) async {
    _setLoading();
    try {
      final content = await _service.getConstitutionArticleContent(
        articleId: articleId,
        partId:    partId,
      );

      if (content == null) {
        _setError('Article not found.');
        return;
      }

      await _applyContent(content);
      debugPrint('[$_tag] Loaded constitution article: ${content.displayLabel}');
    } catch (e) {
      debugPrint('[$_tag] loadConstitutionArticle error: $e');
      _setError('Failed to load article.');
    }
  }

  // ── NAVIGATION ───────────────────────────────

  Future<void> loadPrevious() async {
    final current = state.currentContent;
    if (current == null || !current.hasPrevious) return;

    _setLoading();
    try {
      final previous = await _service.getPreviousContent(current);
      if (previous == null) { _setError('Previous content not found.'); return; }
      await _applyContent(previous);
      debugPrint('[$_tag] Navigated to previous: ${previous.displayLabel}');
    } catch (e) {
      debugPrint('[$_tag] loadPrevious error: $e');
      _setError('Failed to load previous content.');
    }
  }

  Future<void> loadNext() async {
    final current = state.currentContent;
    if (current == null || !current.hasNext) return;

    _setLoading();
    try {
      final next = await _service.getNextContent(current);
      if (next == null) { _setError('Next content not found.'); return; }
      await _applyContent(next);
      debugPrint('[$_tag] Navigated to next: ${next.displayLabel}');
    } catch (e) {
      debugPrint('[$_tag] loadNext error: $e');
      _setError('Failed to load next content.');
    }
  }

  // ── REFRESH ──────────────────────────────────

  Future<void> refresh() async {
    final current = state.currentContent;
    if (current == null) return;

    switch (current.sourceType) {
      case ReaderSourceType.actSection:
        await loadActSection(
          actId:     current.sourceId ?? '',
          sectionId: current.id,
        );
      case ReaderSourceType.constitutionArticle:
        await loadConstitutionArticle(
          articleId: current.id,
          partId:    current.sourceId,
        );
    }
  }

  // ── RESET ─────────────────────────────────────

  void reset() {
    state = const ReaderState();
    debugPrint('[$_tag] State reset.');
  }

  // ─────────────────────────────────────────────
  // MARK: — PRIVATE
  // ─────────────────────────────────────────────

  Future<void> _applyContent(ReaderContentData content) async {
    List<CaseLaw> caseLaws = const [];

    if (content.hasCaseLaws) {
      try {
        caseLaws = await _service.getLinkedCaseLaws(content.caseLawIds);
      } catch (e) {
        debugPrint('[$_tag] Case law load warning: $e');
      }
    }

    state = state.copyWith(
      isLoading:      false,
      currentContent: content,
      linkedCaseLaws: caseLaws,
      errorMessage:   null,
    );
  }

  void _setLoading() {
    state = state.copyWith(
      isLoading:      true,
      errorMessage:   null,
      linkedCaseLaws: const [],
    );
  }

  void _setError(String message) {
    state = state.copyWith(
      isLoading:    false,
      errorMessage: message,
    );
    debugPrint('[$_tag] Error: $message');
  }
}

// ─────────────────────────────────────────────
// MARK: — PROVIDER DECLARATIONS
// ─────────────────────────────────────────────

/// Primary reader state provider.
/// Use ref.watch(readerProvider) in reader screens.
final readerProvider =
    StateNotifierProvider.autoDispose<ReaderNotifier, ReaderState>((ref) {
  final service = ref.watch(readerContentServiceProvider);
  return ReaderNotifier(service);
});

/// Convenience: currently displayed content data.
final currentReaderContentProvider =
    Provider.autoDispose<ReaderContentData?>((ref) {
  return ref.watch(readerProvider).currentContent;
});

/// Convenience: case laws for current content.
final readerCaseLawsProvider =
    Provider.autoDispose<List<CaseLaw>>((ref) {
  return ref.watch(readerProvider).linkedCaseLaws;
});

/// Convenience: reader loading state.
final readerLoadingProvider =
    Provider.autoDispose<bool>((ref) {
  return ref.watch(readerProvider).isLoading;
});

/// Convenience: reader error state.
final readerErrorProvider =
    Provider.autoDispose<String?>((ref) {
  return ref.watch(readerProvider).errorMessage;
});

/// True when navigation to next is possible.
final readerCanGoNextProvider =
    Provider.autoDispose<bool>((ref) {
  return ref.watch(readerProvider).canGoNext;
});

/// True when navigation to previous is possible.
final readerCanGoPrevProvider =
    Provider.autoDispose<bool>((ref) {
  return ref.watch(readerProvider).canGoPrev;
});