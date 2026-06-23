// lib/features/notes/pdf_reader_screen.dart
// Law Briefly — PDF Reader Screen (Academic Notes Only)
// iOS 18 Liquid Glass | Premium PDF Reading | Production-Ready

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';

// ─────────────────────────────────────────────
// MARK: — ENUMS
// ─────────────────────────────────────────────

enum ScrollMode  { singlePage, continuous }
enum NightMode   { light, dark, sepia }
enum ZoomPreset  { fit, width, custom }

// ─────────────────────────────────────────────
// MARK: — PDF DOCUMENT MODEL (ISAR-ready)
// ─────────────────────────────────────────────

class PdfDocumentModel {
  final String      id;
  final String      title;
  final String      pdfPath;        // asset or file path
  final int         totalPages;
  final int         lastReadPage;   // resume reading
  final List<int>   bookmarkedPages;
  final String?     subject;
  final String?     yearLabel;      // "BALLB 1st Year"
  final String?     description;
  final DateTime?   uploadedAt;
  final int?        fileSizeBytes;
  final bool        isDownloaded;   // Future: offline
  final bool        isPremium;      // Future: marketplace

  const PdfDocumentModel({
    required this.id,
    required this.title,
    required this.pdfPath,
    required this.totalPages,
    this.lastReadPage    = 1,
    this.bookmarkedPages = const [],
    this.subject,
    this.yearLabel,
    this.description,
    this.uploadedAt,
    this.fileSizeBytes,
    this.isDownloaded    = true,
    this.isPremium       = false,
  });

  double get readingProgress =>
      totalPages > 0 ? lastReadPage / totalPages : 0.0;

  bool isPageBookmarked(int page) => bookmarkedPages.contains(page);

  factory PdfDocumentModel.fromJson(Map<String, dynamic> json) =>
      PdfDocumentModel(
        id:           json['id']             as String,
        title:        json['title']          as String,
        pdfPath:      json['pdf_path']       as String,
        totalPages:   json['total_pages']    as int,
        lastReadPage: json['last_read_page'] as int? ?? 1,
        bookmarkedPages: List<int>.from(
          json['bookmarked_pages'] as List? ?? [],
        ),
        subject:       json['subject']    as String?,
        yearLabel:     json['year_label'] as String?,
        description:   json['description'] as String?,
        isDownloaded:  json['is_downloaded'] as bool? ?? true,
        isPremium:     json['is_premium']    as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id':              id,
        'title':           title,
        'pdf_path':        pdfPath,
        'total_pages':     totalPages,
        'last_read_page':  lastReadPage,
        'bookmarked_pages': bookmarkedPages,
        'subject':         subject,
        'year_label':      yearLabel,
        'description':     description,
        'is_downloaded':   isDownloaded,
        'is_premium':      isPremium,
      };
}

// ─────────────────────────────────────────────
// MARK: — READER STATE MODEL
// ─────────────────────────────────────────────

class ReaderState {
  final int        currentPage;
  final double     zoomLevel;         // 1.0 = 100%
  final bool       isDocumentBookmarked;
  final bool       isToolbarVisible;
  final bool       isAppBarVisible;
  final bool       isLoading;
  final bool       isFullScreen;
  final ScrollMode scrollMode;
  final NightMode  nightMode;

  const ReaderState({
    this.currentPage           = 1,
    this.zoomLevel             = 1.0,
    this.isDocumentBookmarked  = false,
    this.isToolbarVisible      = true,
    this.isAppBarVisible       = true,
    this.isLoading             = false,
    this.isFullScreen          = false,
    this.scrollMode            = ScrollMode.singlePage,
    this.nightMode             = NightMode.light,
  });

  ReaderState copyWith({
    int?        currentPage,
    double?     zoomLevel,
    bool?       isDocumentBookmarked,
    bool?       isToolbarVisible,
    bool?       isAppBarVisible,
    bool?       isLoading,
    bool?       isFullScreen,
    ScrollMode? scrollMode,
    NightMode?  nightMode,
  }) =>
      ReaderState(
        currentPage:          currentPage          ?? this.currentPage,
        zoomLevel:            zoomLevel            ?? this.zoomLevel,
        isDocumentBookmarked: isDocumentBookmarked ?? this.isDocumentBookmarked,
        isToolbarVisible:     isToolbarVisible     ?? this.isToolbarVisible,
        isAppBarVisible:      isAppBarVisible      ?? this.isAppBarVisible,
        isLoading:            isLoading            ?? this.isLoading,
        isFullScreen:         isFullScreen         ?? this.isFullScreen,
        scrollMode:           scrollMode           ?? this.scrollMode,
        nightMode:            nightMode            ?? this.nightMode,
      );
}

// ─────────────────────────────────────────────
// MARK: — MOCK DATA
// ─────────────────────────────────────────────

abstract final class MockPdfData {
  static const PdfDocumentModel constitutionalLaw = PdfDocumentModel(
    id:          'y1_s1',
    title:       'Constitutional Law I',
    pdfPath:     'assets/pdfs/y1/constitutional_law_1.pdf',
    totalPages:  248,
    lastReadPage: 42,
    bookmarkedPages: [12, 45, 89, 132, 178],
    subject:     'Constitutional Law I',
    yearLabel:   'BALLB 1st Year',
    description: 'Fundamental Rights, Directive Principles, constitutional history and amendment procedure.',
    fileSizeBytes: 8_452_096,
  );

  static const PdfDocumentModel contractLaw = PdfDocumentModel(
    id:          'y1_s2',
    title:       'Law of Contracts',
    pdfPath:     'assets/pdfs/y1/law_of_contracts.pdf',
    totalPages:  312,
    lastReadPage: 1,
    bookmarkedPages: [18, 67, 134],
    subject:     'Law of Contracts',
    yearLabel:   'BALLB 1st Year',
    description: 'Indian Contract Act 1872 — offer, acceptance, consideration and breach.',
    fileSizeBytes: 10_223_616,
  );
}

// ─────────────────────────────────────────────
// MARK: — PDF READER SCREEN
// ─────────────────────────────────────────────

class PdfReaderScreen extends StatefulWidget {
  final PdfDocumentModel      document;
  final ValueChanged<int>?    onPageChanged;    // Future: persist
  final VoidCallback?         onBookmarkToggled;

  const PdfReaderScreen({
    super.key,
    required this.document,
    this.onPageChanged,
    this.onBookmarkToggled,
  });

  @override
  State<PdfReaderScreen> createState() => _PdfReaderScreenState();
}

class _PdfReaderScreenState extends State<PdfReaderScreen>
    with TickerProviderStateMixin {

  // ── State ─────────────────────────────────────
  late ReaderState _state;
  late Set<int>    _bookmarkedPages;

  // ── Page controller ───────────────────────────
  late PageController _pageController;

  // ── Timer ─────────────────────────────────────
  Timer? _toolbarTimer;
  static const Duration _toolbarAutoHide = Duration(seconds: 4);

  // ── Animation controllers ─────────────────────
  late AnimationController _appBarController;
  late AnimationController _toolbarController;
  late AnimationController _entranceController;
  late AnimationController _bookmarkController;

  // ── Animations ────────────────────────────────
  late Animation<Offset>  _appBarSlide;
  late Animation<double>  _appBarFade;
  late Animation<Offset>  _toolbarSlide;
  late Animation<double>  _toolbarFade;
  late Animation<double>  _contentFade;
  late Animation<double>  _bookmarkScale;

  // ── Computed ──────────────────────────────────
  bool get _isCurrentPageBookmarked =>
      _bookmarkedPages.contains(_state.currentPage);

  bool get _isFirstPage => _state.currentPage <= 1;
  bool get _isLastPage  => _state.currentPage >= widget.document.totalPages;

  double get _readingProgress =>
      widget.document.totalPages > 0
          ? _state.currentPage / widget.document.totalPages
          : 0.0;

  // ─────────────────────────────────────────────
  // MARK: — LIFECYCLE
  // ─────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    final doc = widget.document;
    _state = ReaderState(currentPage: doc.lastReadPage.clamp(1, doc.totalPages));
    _bookmarkedPages = Set<int>.from(doc.bookmarkedPages);

    _pageController = PageController(
      initialPage: (_state.currentPage - 1).clamp(0, doc.totalPages - 1),
    );

    _setupAnimations();
    _startEntrance();
    _resetToolbarTimer();
  }

  void _setupAnimations() {
    _appBarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      reverseDuration: const Duration(milliseconds: 220),
    );
    _toolbarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 240),
    );
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _bookmarkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // AppBar: slides up when hidden
    _appBarSlide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1),
    ).animate(CurvedAnimation(
      parent: _appBarController,
      curve: Curves.easeInCubic,
      reverseCurve: Curves.easeOutCubic,
    ));
    _appBarFade = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _appBarController, curve: Curves.easeIn),
    );

    // Toolbar: slides down when hidden
    _toolbarSlide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 2.5),
    ).animate(CurvedAnimation(
      parent: _toolbarController,
      curve: Curves.easeInCubic,
      reverseCurve: Curves.easeOutCubic,
    ));
    _toolbarFade = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _toolbarController, curve: Curves.easeIn),
    );

    // Content entrance
    _contentFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.15, 0.75, curve: Curves.easeOut),
      ),
    );

    // Bookmark bounce
    _bookmarkScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.40)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.40, end: 0.90)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.90, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 35,
      ),
    ]).animate(_bookmarkController);
  }

  void _startEntrance() {
    Future.delayed(const Duration(milliseconds: 60), () {
      if (mounted) _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _toolbarTimer?.cancel();
    _appBarController.dispose();
    _toolbarController.dispose();
    _entranceController.dispose();
    _bookmarkController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // MARK: — TOOLBAR VISIBILITY
  // ─────────────────────────────────────────────

  void _showBars() {
    _appBarController.reverse();
    _toolbarController.reverse();
    _resetToolbarTimer();
  }

  void _hideBars() {
    _toolbarTimer?.cancel();
    _appBarController.forward();
    _toolbarController.forward();
  }

  void _toggleBars() {
    if (_appBarController.isAnimating) return;
    if (_appBarController.value > 0.3) {
      _showBars();
    } else {
      _hideBars();
    }
  }

  void _resetToolbarTimer() {
    _toolbarTimer?.cancel();
    _toolbarTimer = Timer(_toolbarAutoHide, () {
      if (mounted) _hideBars();
    });
  }

  // ─────────────────────────────────────────────
  // MARK: — PAGE NAVIGATION
  // ─────────────────────────────────────────────

  void _previousPage() {
    if (_isFirstPage) return;
    HapticFeedback.lightImpact();
    _goToPage(_state.currentPage - 1);
  }

  void _nextPage() {
    if (_isLastPage) return;
    HapticFeedback.lightImpact();
    _goToPage(_state.currentPage + 1);
  }

  void _goToPage(int page) {
    final clamped = page.clamp(1, widget.document.totalPages);
    setState(() => _state = _state.copyWith(currentPage: clamped));
    _pageController.animateToPage(
      clamped - 1,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
    widget.onPageChanged?.call(clamped);
    _showBars();
  }

  void _onPageViewChanged(int index) {
    final page = index + 1;
    if (page != _state.currentPage) {
      setState(() => _state = _state.copyWith(currentPage: page));
      widget.onPageChanged?.call(page);
      _showBars();
    }
  }

  // ─────────────────────────────────────────────
  // MARK: — BOOKMARKS
  // ─────────────────────────────────────────────

  void _toggleDocumentBookmark() {
    HapticFeedback.mediumImpact();
    setState(() => _state = _state.copyWith(
          isDocumentBookmarked: !_state.isDocumentBookmarked,
        ));
    _bookmarkController.forward(from: 0);
    widget.onBookmarkToggled?.call();
    _showBars();
  }

  void _togglePageBookmark() {
    HapticFeedback.mediumImpact();
    final page = _state.currentPage;
    setState(() {
      if (_bookmarkedPages.contains(page)) {
        _bookmarkedPages.remove(page);
      } else {
        _bookmarkedPages.add(page);
      }
    });
    _bookmarkController.forward(from: 0);
    _showBars();
  }

  // ─────────────────────────────────────────────
  // MARK: — JUMP TO PAGE
  // ─────────────────────────────────────────────

  void _showJumpToPage(BuildContext context, bool dark) {
    _toolbarTimer?.cancel();
    showDialog<int>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.40),
      builder: (ctx) => _JumpToPageDialog(
        currentPage: _state.currentPage,
        totalPages: widget.document.totalPages,
        isDark: dark,
        onJump: (page) {
          Navigator.of(ctx).pop();
          _goToPage(page);
          _resetToolbarTimer();
        },
      ),
    ).then((_) => _resetToolbarTimer());
  }

  // ─────────────────────────────────────────────
  // MARK: — MORE MENU
  // ─────────────────────────────────────────────

  void _showMoreMenu(BuildContext context, bool dark) {
    _toolbarTimer?.cancel();
    GlassBottomSheet.show(
      context,
      initialChildSize: 0.38,
      maxChildSize: 0.50,
      child: _MoreMenuSheet(isDark: dark),
    ).then((_) => _resetToolbarTimer());
  }

  // ─────────────────────────────────────────────
  // MARK: — BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final dark       = brightness == Brightness.dark;
    final topPad     = MediaQuery.of(context).padding.top;
    final botPad     = MediaQuery.of(context).padding.bottom;
    final appBarH    = kToolbarHeight;

    SystemChrome.setSystemUIOverlayStyle(
      dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );

    return Scaffold(
      backgroundColor:
          dark ? const Color(0xFF1A1A1A) : const Color(0xFFDDDDDD),
      body: GestureDetector(
        onTap: _toggleBars,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── PDF View ──────────────────────────
            FadeTransition(
              opacity: _contentFade,
              child: _PdfPlaceholderView(
                document: widget.document,
                currentPage: _state.currentPage,
                isDark: dark,
                pageController: _pageController,
                onPageChanged: _onPageViewChanged,
              ),
            ),

            // ── Progress bar ──────────────────────
            Positioned(
              top: topPad + appBarH - 2,
              left: 0, right: 0,
              child: SlideTransition(
                position: _appBarSlide,
                child: _ReadingProgressBar(
                  progress: _readingProgress,
                  isDark: dark,
                ),
              ),
            ),

            // ── Glass AppBar ──────────────────────
            Positioned(
              top: 0, left: 0, right: 0,
              child: SlideTransition(
                position: _appBarSlide,
                child: FadeTransition(
                  opacity: _appBarFade,
                  child: _buildPdfAppBar(dark, topPad),
                ),
              ),
            ),

            // ── Bottom Toolbar ────────────────────
            Positioned(
              left: AppSpacing.xl,
              right: AppSpacing.xl,
              bottom: botPad + AppSpacing.xl,
              child: SlideTransition(
                position: _toolbarSlide,
                child: FadeTransition(
                  opacity: _toolbarFade,
                  child: _buildBottomToolbar(dark, context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // MARK: — GLASS APP BAR
  // ─────────────────────────────────────────────

  Widget _buildPdfAppBar(bool dark, double topPad) {
    final tint = dark
        ? const Color(0xCC1C1C1E)
        : const Color(0xE6FFFFFF);
    final border = dark
        ? const Color(0x1AFFFFFF)
        : const Color(0x1AC6C6C8);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: AppBlur.lg, sigmaY: AppBlur.lg),
        child: Container(
          padding: EdgeInsets.only(top: topPad),
          height: topPad + kToolbarHeight,
          decoration: BoxDecoration(
            color: tint,
            border: Border(
              bottom: BorderSide(color: border, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: AppSpacing.sm),

              // Back button
              _GlassIconButton(
                icon: Icons.arrow_back_ios_rounded,
                isDark: dark,
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).maybePop();
                },
              ),

              const SizedBox(width: AppSpacing.sm),

              // Title + subtitle
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.document.title,
                      style: AppTypography.titleMedium.copyWith(
                        color: dark
                            ? AppColors.darkPrimaryText
                            : AppColors.lightPrimaryText,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        letterSpacing: -0.15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    if (widget.document.yearLabel != null) ...[
                      const SizedBox(height: 1),
                      Text(
                        widget.document.yearLabel!,
                        style: AppTypography.caption.copyWith(
                          color: dark
                              ? AppColors.darkSecondaryText
                              : AppColors.lightSecondaryText,
                          fontSize: 10.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              // Bookmark (document-level)
              ScaleTransition(
                scale: _bookmarkScale,
                child: _GlassIconButton(
                  isDark: dark,
                  icon: _state.isDocumentBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  iconColor: _state.isDocumentBookmarked
                      ? (dark ? AppColors.accentLight : AppColors.accent)
                      : null,
                  onTap: _toggleDocumentBookmark,
                ),
              ),

              // More menu
              _GlassIconButton(
                icon: Icons.more_horiz_rounded,
                isDark: dark,
                onTap: () => _showMoreMenu(context, dark),
              ),

              const SizedBox(width: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // MARK: — BOTTOM TOOLBAR
  // ─────────────────────────────────────────────

  Widget _buildBottomToolbar(bool dark, BuildContext context) =>
      ClipRRect(
        borderRadius: AppRadius.xxlAll,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: AppBlur.xl, sigmaY: AppBlur.xl),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: dark
                  ? const Color(0xD91C1C1E)
                  : const Color(0xDFFFFFFF),
              borderRadius: AppRadius.xxlAll,
              border: Border.all(
                color: dark
                    ? const Color(0x26FFFFFF)
                    : const Color(0x33FFFFFF),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(dark ? 0.45 : 0.12),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                // Previous
                _ToolbarNavButton(
                  icon: Icons.chevron_left_rounded,
                  enabled: !_isFirstPage,
                  isDark: dark,
                  onTap: _previousPage,
                ),

                // ── Divider ──────────────────────
                _ToolbarDivider(isDark: dark),

                // Page indicator (tappable)
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showJumpToPage(context, dark),
                    child: _PageIndicator(
                      currentPage: _state.currentPage,
                      totalPages: widget.document.totalPages,
                      isDark: dark,
                    ),
                  ),
                ),

                // ── Divider ──────────────────────
                _ToolbarDivider(isDark: dark),

                // Next
                _ToolbarNavButton(
                  icon: Icons.chevron_right_rounded,
                  enabled: !_isLastPage,
                  isDark: dark,
                  onTap: _nextPage,
                ),

                // ── Divider ──────────────────────
                _ToolbarDivider(isDark: dark),

                // Jump to page
                _ToolbarIconButton(
                  icon: Icons.my_location_rounded,
                  isDark: dark,
                  onTap: () => _showJumpToPage(context, dark),
                  tooltip: 'Jump to page',
                ),

                // Page bookmark
                _ToolbarIconButton(
                  icon: _isCurrentPageBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  isDark: dark,
                  iconColor: _isCurrentPageBookmarked
                      ? (dark ? AppColors.accentLight : AppColors.accent)
                      : null,
                  onTap: _togglePageBookmark,
                  tooltip: 'Bookmark page',
                ),

                const SizedBox(width: AppSpacing.xs),
              ],
            ),
          ),
        ),
      );
}

// ─────────────────────────────────────────────
// MARK: — PDF PLACEHOLDER VIEW
// ─────────────────────────────────────────────

class _PdfPlaceholderView extends StatelessWidget {
  final PdfDocumentModel document;
  final int              currentPage;
  final bool             isDark;
  final PageController   pageController;
  final ValueChanged<int> onPageChanged;

  const _PdfPlaceholderView({
    required this.document,
    required this.currentPage,
    required this.isDark,
    required this.pageController,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark
        ? const Color(0xFF1A1A1A)
        : const Color(0xFFD0D0D0);

    return Container(
      color: bgColor,
      // ── Future: Replace this block with PdfViewer ──
      // ── syncfusion_flutter_pdfviewer: ─────────────
      //    SfPdfViewer.asset(
      //      document.pdfPath,
      //      controller: _pdfController,
      //      onPageChanged: (details) => onPageChanged(details.newPageNumber),
      //    )
      // ── pdfx: ─────────────────────────────────────
      //    PdfView(
      //      controller: PdfController(
      //        document: PdfDocument.openAsset(document.pdfPath),
      //        initialPage: currentPage,
      //      ),
      //    )
      child: PageView.builder(
        controller: pageController,
        onPageChanged: onPageChanged,
        itemCount: document.totalPages,
        itemBuilder: (context, index) => _SimulatedPdfPage(
          pageNumber: index + 1,
          totalPages: document.totalPages,
          title: document.title,
          isDark: isDark,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MARK: — SIMULATED PDF PAGE
// ─────────────────────────────────────────────

class _SimulatedPdfPage extends StatelessWidget {
  final int    pageNumber;
  final int    totalPages;
  final String title;
  final bool   isDark;

  const _SimulatedPdfPage({
    required this.pageNumber,
    required this.totalPages,
    required this.title,
    required this.isDark,
  });

  bool get _isCoverPage      => pageNumber == 1;
  bool get _isTocPage        => pageNumber == 2 || pageNumber == 3;
  bool get _isChapterStart   => (pageNumber - 4) % 22 == 0 && pageNumber > 3;
  int  get _patternSeed      => pageNumber % 7;

  // Line width fractions per pattern
  static const List<List<double>> _patterns = [
    [1.0, 0.92, 0.96, 1.0, 0.72, 1.0, 0.88, 0.95, 0.43],
    [0.88, 1.0, 0.82, 0.94, 1.0, 0.61, 0.92, 1.0, 0.77],
    [1.0, 0.78, 1.0, 0.90, 0.84, 1.0, 0.67, 0.96, 0.51],
    [0.94, 0.88, 1.0, 0.72, 1.0, 0.85, 0.91, 0.80, 0.38],
    [1.0, 0.96, 0.84, 1.0, 0.76, 0.88, 1.0, 0.64, 0.55],
    [0.86, 1.0, 0.90, 0.78, 0.98, 1.0, 0.72, 0.84, 0.68],
    [1.0, 0.80, 0.94, 1.0, 0.88, 0.76, 0.92, 1.0, 0.45],
  ];

  @override
  Widget build(BuildContext context) {
    final pageColor = isDark
        ? const Color(0xFF1E1E1E)
        : const Color(0xFFFFFEFA);
    final textColor = isDark
        ? const Color(0xFFE0E0DE)
        : const Color(0xFF1A1A18);
    final lineColor =
        textColor.withOpacity(isDark ? 0.14 : 0.12);
    final accentColor =
        isDark ? AppColors.accentLight : AppColors.accent;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0, vertical: 20.0,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: pageColor,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.50 : 0.20),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.20 : 0.08),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;

              if (_isCoverPage) {
                return _buildCoverPage(w, textColor, accentColor, lineColor);
              }
              if (_isTocPage) {
                return _buildTocPage(w, textColor, accentColor, lineColor);
              }
              if (_isChapterStart) {
                return _buildChapterPage(w, textColor, accentColor, lineColor);
              }
              return _buildContentPage(w, textColor, accentColor, lineColor);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCoverPage(double w, Color text, Color accent, Color line) =>
      Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            const Spacer(flex: 2),
            Container(width: 48, height: 4, color: accent),
            const SizedBox(height: 24),
            Container(width: w * 0.75, height: 22,
                color: text.withOpacity(0.85),
                margin: const EdgeInsets.only(bottom: 12)),
            Container(width: w * 0.55, height: 16,
                color: text.withOpacity(0.65)),
            const SizedBox(height: 48),
            _lineDivider(w, line),
            const SizedBox(height: 24),
            Container(width: w * 0.40, height: 10,
                color: text.withOpacity(0.35)),
            const SizedBox(height: 8),
            Container(width: w * 0.30, height: 10,
                color: text.withOpacity(0.25)),
            const Spacer(flex: 3),
            _pageNumberBar(text),
          ],
        ),
      );

  Widget _buildTocPage(double w, Color text, Color accent, Color line) =>
      Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Container(width: w * 0.45, height: 16,
                color: accent.withOpacity(0.85)),
            const SizedBox(height: 24),
            _lineDivider(w, line),
            const SizedBox(height: 20),
            ...List.generate(12, (i) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(children: [
                Container(width: w * (0.50 + (i % 3) * 0.08), height: 9,
                    color: text.withOpacity(0.15)),
                const Spacer(),
                Container(width: 24, height: 9,
                    color: text.withOpacity(0.15)),
              ]),
            )),
            const Spacer(),
            _pageNumberBar(text),
          ],
        ),
      );

  Widget _buildChapterPage(double w, Color text, Color accent, Color line) =>
      Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            const Spacer(flex: 2),
            Container(
              width: 32, height: 3,
              color: accent.withOpacity(0.60),
            ),
            const SizedBox(height: 16),
            Container(width: w * 0.35, height: 11,
                color: text.withOpacity(0.35)),
            const SizedBox(height: 12),
            Container(width: w * 0.70, height: 20,
                color: text.withOpacity(0.85)),
            const SizedBox(height: 8),
            Container(width: w * 0.55, height: 20,
                color: text.withOpacity(0.70)),
            const SizedBox(height: 32),
            _lineDivider(w * 0.30, line),
            const Spacer(flex: 3),
            _pageNumberBar(text),
          ],
        ),
      );

  Widget _buildContentPage(double w, Color text, Color accent, Color line) {
    final pattern = _patterns[_patternSeed];
    return Padding(
      padding: const EdgeInsets.fromLTRB(36, 40, 36, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Running header
          Row(children: [
            Container(width: w * 0.30, height: 8,
                color: text.withOpacity(0.22)),
            const Spacer(),
            Container(width: 24, height: 8,
                color: text.withOpacity(0.18)),
          ]),
          const SizedBox(height: 12),
          _lineDivider(w, line),
          const SizedBox(height: 20),

          // Section heading (occasional)
          if (_patternSeed < 2) ...[
            Container(width: w * 0.50, height: 13,
                color: text.withOpacity(0.75)),
            const SizedBox(height: 16),
          ],

          // Body text lines
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...pattern.map((frac) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        width: w * frac,
                        height: 9,
                        decoration: BoxDecoration(
                          color: text.withOpacity(0.13),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    )),

                const SizedBox(height: 16),

                // Second paragraph
                ...pattern.reversed.map((frac) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        width: w * (frac * 0.92).clamp(0.3, 1.0),
                        height: 9,
                        decoration: BoxDecoration(
                          color: text.withOpacity(0.13),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    )),

                // Indented block (like a legal provision)
                if (_patternSeed > 3) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Container(
                      height: 1.5,
                      color: accent.withOpacity(0.30),
                      margin: const EdgeInsets.only(bottom: 12),
                    ),
                  ),
                  ...List.generate(3, (i) => Padding(
                    padding: const EdgeInsets.only(left: 20, bottom: 8),
                    child: Container(
                      width: w * [0.85, 0.92, 0.60][i],
                      height: 9,
                      decoration: BoxDecoration(
                        color: text.withOpacity(0.11),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  )),
                ],
              ],
            ),
          ),

          // Footer divider + page number
          _lineDivider(w, line),
          const SizedBox(height: 8),
          _pageNumberBar(text),
        ],
      ),
    );
  }

  Widget _lineDivider(double w, Color color) => Container(
        width: w, height: 0.5, color: color,
      );

  Widget _pageNumberBar(Color text) => Center(
        child: Text(
          '$pageNumber',
          style: TextStyle(
            fontSize: 10,
            color: text.withOpacity(0.35),
            letterSpacing: 0.5,
            fontFamily: 'Georgia',
          ),
        ),
      );
}

// ─────────────────────────────────────────────
// MARK: — READING PROGRESS BAR
// ─────────────────────────────────────────────

class _ReadingProgressBar extends StatelessWidget {
  final double progress;
  final bool isDark;

  const _ReadingProgressBar({required this.progress, required this.isDark});

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 2.5,
        child: LayoutBuilder(
          builder: (context, constraints) => Stack(
            children: [
              Container(
                width: constraints.maxWidth,
                height: 2.5,
                color: (isDark ? AppColors.darkSeparator : AppColors.lightSeparator)
                    .withOpacity(0.5),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                width: constraints.maxWidth * progress.clamp(0.0, 1.0),
                height: 2.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      isDark ? AppColors.accentLight : AppColors.accent,
                      AppColors.gold.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

// ─────────────────────────────────────────────
// MARK: — PAGE INDICATOR
// ─────────────────────────────────────────────

class _PageIndicator extends StatelessWidget {
  final int  currentPage;
  final int  totalPages;
  final bool isDark;

  const _PageIndicator({
    required this.currentPage,
    required this.totalPages,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$currentPage',
                style: AppTypography.labelLarge.copyWith(
                  color: isDark
                      ? AppColors.darkPrimaryText
                      : AppColors.lightPrimaryText,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              Text(
                ' / $totalPages',
                style: AppTypography.labelMedium.copyWith(
                  color: isDark
                      ? AppColors.darkSecondaryText
                      : AppColors.lightSecondaryText,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'Tap to jump',
            style: AppTypography.labelSmall.copyWith(
              color: isDark
                  ? AppColors.darkTertiaryText
                  : AppColors.lightTertiaryText,
              fontSize: 9.5,
            ),
          ),
        ],
      );
}

// ─────────────────────────────────────────────
// MARK: — TOOLBAR NAV BUTTON
// ─────────────────────────────────────────────

class _ToolbarNavButton extends StatefulWidget {
  final IconData icon;
  final bool     enabled;
  final bool     isDark;
  final VoidCallback onTap;

  const _ToolbarNavButton({
    required this.icon,
    required this.enabled,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_ToolbarNavButton> createState() => _ToolbarNavButtonState();
}

class _ToolbarNavButtonState extends State<_ToolbarNavButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.enabled
        ? (widget.isDark
            ? AppColors.darkPrimaryText
            : AppColors.lightPrimaryText)
        : (widget.isDark
            ? AppColors.darkTertiaryText
            : AppColors.lightTertiaryText);

    return IgnorePointer(
      ignoring: !widget.enabled,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 80),
          opacity: _pressed ? 0.45 : (widget.enabled ? 1.0 : 0.35),
          child: SizedBox(
            width: 52, height: 60,
            child: Center(
              child: Icon(widget.icon, size: 26, color: color),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MARK: — TOOLBAR ICON BUTTON
// ─────────────────────────────────────────────

class _ToolbarIconButton extends StatefulWidget {
  final IconData  icon;
  final bool      isDark;
  final Color?    iconColor;
  final String?   tooltip;
  final VoidCallback onTap;

  const _ToolbarIconButton({
    required this.icon,
    required this.isDark,
    this.iconColor,
    this.tooltip,
    required this.onTap,
  });

  @override
  State<_ToolbarIconButton> createState() => _ToolbarIconButtonState();
}

class _ToolbarIconButtonState extends State<_ToolbarIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.iconColor ??
        (widget.isDark
            ? AppColors.darkPrimaryText
            : AppColors.lightPrimaryText);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 80),
        opacity: _pressed ? 0.45 : 1.0,
        child: SizedBox(
          width: 48, height: 60,
          child: Center(
            child: Icon(widget.icon, size: 21, color: color),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MARK: — TOOLBAR DIVIDER
// ─────────────────────────────────────────────

class _ToolbarDivider extends StatelessWidget {
  final bool isDark;
  const _ToolbarDivider({required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
        width: 0.5, height: 28,
        color: isDark
            ? const Color(0x26FFFFFF)
            : const Color(0x20000000),
      );
}

// ─────────────────────────────────────────────
// MARK: — GLASS ICON BUTTON (AppBar)
// ─────────────────────────────────────────────

class _GlassIconButton extends StatefulWidget {
  final IconData  icon;
  final bool      isDark;
  final Color?    iconColor;
  final VoidCallback onTap;

  const _GlassIconButton({
    required this.icon,
    required this.isDark,
    this.iconColor,
    required this.onTap,
  });

  @override
  State<_GlassIconButton> createState() => _GlassIconButtonState();
}

class _GlassIconButtonState extends State<_GlassIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _press;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _press, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() { _press.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => ScaleTransition(
        scale: _scale,
        child: GestureDetector(
          onTapDown: (_) => _press.forward(),
          onTapUp: (_) { _press.reverse(); widget.onTap(); },
          onTapCancel: () => _press.reverse(),
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.isDark
                  ? const Color(0x26FFFFFF)
                  : const Color(0x18000000),
            ),
            child: Icon(
              widget.icon, size: 17,
              color: widget.iconColor ??
                  (widget.isDark
                      ? AppColors.darkPrimaryText
                      : AppColors.lightPrimaryText),
            ),
          ),
        ),
      );
}

// ─────────────────────────────────────────────
// MARK: — JUMP TO PAGE DIALOG
// ─────────────────────────────────────────────

class _JumpToPageDialog extends StatefulWidget {
  final int currentPage;
  final int totalPages;
  final bool isDark;
  final ValueChanged<int> onJump;

  const _JumpToPageDialog({
    required this.currentPage,
    required this.totalPages,
    required this.isDark,
    required this.onJump,
  });

  @override
  State<_JumpToPageDialog> createState() => _JumpToPageDialogState();
}

class _JumpToPageDialogState extends State<_JumpToPageDialog> {
  late TextEditingController _controller;
  String _errorText = '';

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: widget.currentPage.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    final page = int.tryParse(text);
    if (page == null || page < 1 || page > widget.totalPages) {
      setState(
          () => _errorText = 'Enter a page between 1 and ${widget.totalPages}');
      HapticFeedback.heavyImpact();
      return;
    }
    widget.onJump(page);
  }

  @override
  Widget build(BuildContext context) {
    final dark = widget.isDark;
    final textColor =
        dark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;
    final secondaryColor =
        dark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ClipRRect(
        borderRadius: AppRadius.xlAll,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: AppBlur.xl, sigmaY: AppBlur.xl),
          child: Container(
            width: 280,
            decoration: BoxDecoration(
              color: dark
                  ? const Color(0xF01C1C1E)
                  : const Color(0xF0FFFFFF),
              borderRadius: AppRadius.xlAll,
              border: Border.all(
                color: dark
                    ? const Color(0x26FFFFFF)
                    : const Color(0x26000000),
                width: 0.5,
              ),
              boxShadow: dark ? AppShadows.darkLg : AppShadows.lightLg,
            ),
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  'Jump to Page',
                  style: AppTypography.headlineSmall.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Enter a page number (1\u2013${widget.totalPages})',
                  style: AppTypography.caption.copyWith(
                    color: secondaryColor,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: AppSpacing.base),

                // Input field
                AnimatedContainer(
                  duration: AppAnimation.standard,
                  decoration: BoxDecoration(
                    color: dark
                        ? const Color(0x1AFFFFFF)
                        : const Color(0x0D000000),
                    borderRadius: AppRadius.mdAll,
                    border: Border.all(
                      color: _errorText.isEmpty
                          ? (dark
                              ? const Color(0x26FFFFFF)
                              : const Color(0x1A000000))
                          : AppColors.error,
                      width: _errorText.isEmpty ? 0.5 : 1.0,
                    ),
                  ),
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: AppTypography.headlineSmall.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      hintText: '${widget.currentPage}',
                      hintStyle: AppTypography.headlineSmall.copyWith(
                        color: dark
                            ? AppColors.darkTertiaryText
                            : AppColors.lightTertiaryText,
                      ),
                    ),
                    onSubmitted: (_) => _submit(),
                    onChanged: (_) {
                      if (_errorText.isNotEmpty) {
                        setState(() => _errorText = '');
                      }
                    },
                  ),
                ),

                if (_errorText.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    _errorText,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.error,
                      fontSize: 11,
                    ),
                  ),
                ],

                const SizedBox(height: AppSpacing.base),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: _DialogButton(
                        label: 'Cancel',
                        isPrimary: false,
                        isDark: dark,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _DialogButton(
                        label: 'Go',
                        isPrimary: true,
                        isDark: dark,
                        onTap: _submit,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogButton extends StatefulWidget {
  final String label;
  final bool isPrimary;
  final bool isDark;
  final VoidCallback onTap;

  const _DialogButton({
    required this.label,
    required this.isPrimary,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_DialogButton> createState() => _DialogButtonState();
}

class _DialogButtonState extends State<_DialogButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          HapticFeedback.lightImpact();
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 80),
          opacity: _pressed ? 0.65 : 1.0,
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: widget.isPrimary
                  ? (widget.isDark ? AppColors.accentLight : AppColors.accent)
                  : (widget.isDark
                      ? const Color(0x26FFFFFF)
                      : const Color(0x0D000000)),
              borderRadius: AppRadius.mdAll,
            ),
            child: Center(
              child: Text(
                widget.label,
                style: AppTypography.labelMedium.copyWith(
                  color: widget.isPrimary
                      ? Colors.white
                      : (widget.isDark
                          ? AppColors.darkPrimaryText
                          : AppColors.lightPrimaryText),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      );
}

// ─────────────────────────────────────────────
// MARK: — MORE MENU SHEET
// ─────────────────────────────────────────────

class _MoreMenuSheet extends StatelessWidget {
  final bool isDark;
  const _MoreMenuSheet({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.search_rounded,          'Search in Document',  false),
      (Icons.list_alt_rounded,        'Table of Contents',   false),
      (Icons.bookmark_border_rounded, 'All Bookmarked Pages', false),
      (Icons.zoom_in_rounded,         'Zoom In',             false),
      (Icons.zoom_out_rounded,        'Zoom Out',            false),
      (Icons.brightness_medium_rounded, 'Reading Mode',      false),
      (Icons.share_outlined,          'Share',               false),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Options',
          style: AppTypography.headlineSmall.copyWith(
            color: isDark
                ? AppColors.darkPrimaryText
                : AppColors.lightPrimaryText,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.base),
        ...items.map((item) => _MenuRow(
              icon: item.$1,
              label: item.$2,
              isDark: isDark,
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).pop();
              },
            )),
        const SizedBox(height: AppSpacing.base),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0x14FFFFFF)
                : const Color(0x08000000),
            borderRadius: AppRadius.mdAll,
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 14,
                color: isDark
                    ? AppColors.darkSecondaryText
                    : AppColors.lightSecondaryText),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'PDF integration ready for syncfusion_flutter_pdfviewer or pdfx',
                  style: AppTypography.caption.copyWith(
                    color: isDark
                        ? AppColors.darkSecondaryText
                        : AppColors.lightSecondaryText,
                    fontSize: 10.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MenuRow extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  const _MenuRow({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_MenuRow> createState() => _MenuRowState();
}

class _MenuRowState extends State<_MenuRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: _pressed
                ? (widget.isDark
                    ? const Color(0x14FFFFFF)
                    : const Color(0x08000000))
                : Colors.transparent,
            borderRadius: AppRadius.smAll,
          ),
          child: Row(
            children: [
              Icon(widget.icon, size: 18,
                color: widget.isDark
                    ? AppColors.darkSecondaryText
                    : AppColors.lightSecondaryText),
              const SizedBox(width: AppSpacing.md),
              Text(
                widget.label,
                style: AppTypography.titleSmall.copyWith(
                  color: widget.isDark
                      ? AppColors.darkPrimaryText
                      : AppColors.lightPrimaryText,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),
              Icon(Icons.chevron_right_rounded, size: 14,
                color: widget.isDark
                    ? AppColors.darkTertiaryText
                    : AppColors.lightTertiaryText),
            ],
          ),
        ),
      );
}