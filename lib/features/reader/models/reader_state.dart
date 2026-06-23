import 'reader_content.dart';

// ─────────────────────────────────────────────
// MARK: — READER STATE
// ─────────────────────────────────────────────

class ReaderState {
  final bool           isLoading;
  final ReaderContent? content;
  final String?        error;

  const ReaderState({
    this.isLoading = false,
    this.content,
    this.error,
  });

  // ── Named constructors ────────────────────────

  const ReaderState.initial()
      : isLoading = false,
        content   = null,
        error     = null;

  const ReaderState.loading()
      : isLoading = true,
        content   = null,
        error     = null;

  factory ReaderState.success(ReaderContent content) => ReaderState(
        isLoading: false,
        content:   content,
        error:     null,
      );

  factory ReaderState.failure(String error) => ReaderState(
        isLoading: false,
        content:   null,
        error:     error,
      );

  // ── Computed ─────────────────────────────────

  bool get hasContent   => content != null;
  bool get hasError     => error   != null;
  bool get isIdle       => !isLoading && !hasContent && !hasError;
  bool get isSuccess    => !isLoading &&  hasContent && !hasError;
  bool get canGoNext    => content?.hasNext     ?? false;
  bool get canGoPrev    => content?.hasPrevious ?? false;
  bool get hasCaseLaws  => content?.hasCaseLaws ?? false;

  // ── Copy with ─────────────────────────────────

  ReaderState copyWith({
    bool?           isLoading,
    Object?         content = _sentinel,
    Object?         error   = _sentinel,
  }) =>
      ReaderState(
        isLoading: isLoading ?? this.isLoading,
        content:   content   == _sentinel ? this.content : content as ReaderContent?,
        error:     error     == _sentinel ? this.error   : error   as String?,
      );

  // ── Equality ─────────────────────────────────

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReaderState &&
          isLoading == other.isLoading &&
          content   == other.content   &&
          error     == other.error;

  @override
  int get hashCode => Object.hash(isLoading, content, error);

  @override
  String toString() =>
      'ReaderState(loading: $isLoading, hasContent: $hasContent, '
      'error: $error)';
}

const Object _sentinel = Object();