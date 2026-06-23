import 'case_law.dart';

// ─────────────────────────────────────────────
// MARK: — CASE LAW STATE
// ─────────────────────────────────────────────

class CaseLawState {
  final bool     isLoading;
  final CaseLaw? caseLaw;
  final String?  error;

  const CaseLawState({
    this.isLoading = false,
    this.caseLaw,
    this.error,
  });

  // ── Named constructors ────────────────────────

  const CaseLawState.initial()
      : isLoading = false,
        caseLaw   = null,
        error     = null;

  const CaseLawState.loading()
      : isLoading = true,
        caseLaw   = null,
        error     = null;

  factory CaseLawState.success(CaseLaw caseLaw) => CaseLawState(
        isLoading: false,
        caseLaw:   caseLaw,
        error:     null,
      );

  factory CaseLawState.failure(String error) => CaseLawState(
        isLoading: false,
        caseLaw:   null,
        error:     error,
      );

  // ── Computed ─────────────────────────────────

  bool get hasCaseLaw  => caseLaw != null;
  bool get hasError    => error   != null;
  bool get isSuccess   => !isLoading && hasCaseLaw && !hasError;
  bool get isIdle      => !isLoading && !hasCaseLaw && !hasError;

  // ── Copy with ─────────────────────────────────

  CaseLawState copyWith({
    bool?     isLoading,
    Object?   caseLaw = _sentinel,
    Object?   error   = _sentinel,
  }) =>
      CaseLawState(
        isLoading: isLoading ?? this.isLoading,
        caseLaw:   caseLaw   == _sentinel ? this.caseLaw : caseLaw as CaseLaw?,
        error:     error     == _sentinel ? this.error   : error   as String?,
      );

  // ── Equality ─────────────────────────────────

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CaseLawState &&
          isLoading == other.isLoading &&
          caseLaw   == other.caseLaw   &&
          error     == other.error;

  @override
  int get hashCode => Object.hash(isLoading, caseLaw, error);

  @override
  String toString() =>
      'CaseLawState(loading: $isLoading, '
      'hasLaw: $hasCaseLaw, error: $error)';
}

const Object _sentinel = Object();