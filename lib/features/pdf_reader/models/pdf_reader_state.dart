// lib/features/pdf_reader/models/pdf_reader_state.dart

class PdfReaderState {
  final bool    isLoading;
  final String  pdfPath;
  final int     currentPage;
  final int     totalPages;
  final double  zoomLevel;
  final String? error;

  const PdfReaderState({
    this.isLoading   = false,
    this.pdfPath     = '',
    this.currentPage = 1,
    this.totalPages  = 0,
    this.zoomLevel   = 1.0,
    this.error,
  });

  // ── Named constructors ────────────────────────

  const PdfReaderState.initial()
      : isLoading   = false,
        pdfPath     = '',
        currentPage = 1,
        totalPages  = 0,
        zoomLevel   = 1.0,
        error       = null;

  const PdfReaderState.loading()
      : isLoading   = true,
        pdfPath     = '',
        currentPage = 1,
        totalPages  = 0,
        zoomLevel   = 1.0,
        error       = null;

  factory PdfReaderState.success({
    required String pdfPath,
    required int    totalPages,
    int             currentPage = 1,
    double          zoomLevel   = 1.0,
  }) =>
      PdfReaderState(
        isLoading:   false,
        pdfPath:     pdfPath,
        currentPage: currentPage,
        totalPages:  totalPages,
        zoomLevel:   zoomLevel,
      );

  factory PdfReaderState.failure(String error) => PdfReaderState(
        isLoading: false,
        error:     error,
      );

  // ── Computed ─────────────────────────────────

  bool   get hasError      => error      != null;
  bool   get isSuccess     => !isLoading && pdfPath.isNotEmpty && !hasError;
  bool   get hasDocument   => pdfPath.isNotEmpty;
  bool   get canGoNext     => currentPage < totalPages;
  bool   get canGoPrevious => currentPage > 1;
  bool   get isFirst       => currentPage == 1;
  bool   get isLast        => currentPage == totalPages;
  bool   get isZoomed      => zoomLevel > 1.05;
  double get progressFraction => totalPages > 0 ? currentPage / totalPages : 0.0;
  double get progressPercent  => progressFraction * 100;

  // ── Copy with ─────────────────────────────────

  PdfReaderState copyWith({
    bool?   isLoading,
    String? pdfPath,
    int?    currentPage,
    int?    totalPages,
    double? zoomLevel,
    Object? error = _sentinel,
  }) =>
      PdfReaderState(
        isLoading:   isLoading   ?? this.isLoading,
        pdfPath:     pdfPath     ?? this.pdfPath,
        currentPage: currentPage ?? this.currentPage,
        totalPages:  totalPages  ?? this.totalPages,
        zoomLevel:   zoomLevel   ?? this.zoomLevel,
        error:       error == _sentinel ? this.error : error as String?,
      );

  // ── Equality ─────────────────────────────────

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PdfReaderState &&
          isLoading   == other.isLoading   &&
          pdfPath     == other.pdfPath     &&
          currentPage == other.currentPage &&
          totalPages  == other.totalPages  &&
          zoomLevel   == other.zoomLevel   &&
          error       == other.error;

  @override
  int get hashCode => Object.hash(
      isLoading, pdfPath, currentPage, totalPages, zoomLevel, error);

  @override
  String toString() =>
      'PdfReaderState(loading: $isLoading, page: $currentPage/$totalPages, '
      'zoom: $zoomLevel, error: $error)';
}

const Object _sentinel = Object();