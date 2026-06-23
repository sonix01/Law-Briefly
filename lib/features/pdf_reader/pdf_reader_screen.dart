// lib/features/pdf_reader/pdf_reader_screen.dart
// Law Briefly — PDF Reader Screen (pdfx | iOS 18 Liquid Glass)

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfx/pdfx.dart';

import '../../core/theme/app_theme.dart';
import 'data/pdf_progress_repository.dart';

// ─────────────────────────────────────────────
// MARK: — PDF READER SCREEN
// ─────────────────────────────────────────────

class PdfReaderScreen extends StatefulWidget {
  final String pdfPath;   // Asset path: 'assets/pdfs/y1/intro.pdf'
  final String title;
  final String pdfId;     // For bookmark/progress tracking

  const PdfReaderScreen({
    super.key,
    required this.pdfPath,
    required this.title,
    required this.pdfId,
  });

  @override
  State<PdfReaderScreen> createState() => _PdfReaderScreenState();
}

class _PdfReaderScreenState extends State<PdfReaderScreen>
    with SingleTickerProviderStateMixin {

  // ── PDF controller ────────────────────────────
  late PdfControllerPinch _pdfController;

  // ── State ─────────────────────────────────────
  int            _currentPage = 1;
  int            _totalPages  = 0;
  bool           _isLoading   = true;
  String?        _error;
  bool           _showControls = true;
  final Set<int> _bookmarkedPages = {};

  // ── Repository ────────────────────────────────
  final PdfProgressRepository _progressRepo = PdfProgressRepositoryImpl();

  // ── Toolbar auto-hide ─────────────────────────
  Timer?         _hideTimer;
  static const Duration _hideDuration = Duration(seconds: 4);

  // ── Entrance animation ────────────────────────
  late AnimationController _entranceCtrl;
  late Animation<double>   _appBarFade;
  late Animation<double>   _toolbarFade;
  late Animation<Offset>   _toolbarSlide;

  // ─────────────────────────────────────────────
  // MARK: — LIFECYCLE
  // ─────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initPdfController();
    _restoreProgress();
    _scheduleHide();
  }

  void _setupAnimations() {
    _entranceCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _appBarFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceCtrl,
          curve: const Interval(0.0, 0.55, curve: Curves.easeOut)));
    _toolbarFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceCtrl,
          curve: const Interval(0.30, 0.90, curve: Curves.easeOut)));
    _toolbarSlide = Tween<Offset>(
        begin: const Offset(0, 1.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceCtrl,
          curve: const Interval(0.30, 0.95, curve: Curves.easeOutCubic)));
  }

  void _initPdfController() {
    _pdfController = PdfControllerPinch(
      document: PdfDocument.openAsset(widget.pdfPath),
    );
  }

  Future<void> _restoreProgress() async {
    try {
      final lastPage = await _progressRepo.getLastPage(widget.pdfId);
      if (lastPage > 1 && mounted) {
        // Jump to restored page after document loads
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && lastPage <= _totalPages) {
            _pdfController.jumpToPage(lastPage);
          }
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _entranceCtrl.dispose();
    _pdfController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // MARK: — CONTROLS VISIBILITY
  // ─────────────────────────────────────────────

  void _toggleControls() {
    HapticFeedback.selectionClick();
    setState(() => _showControls = !_showControls);
    if (_showControls) _scheduleHide();
    else _hideTimer?.cancel();
  }

  void _showControlsTemporarily() {
    setState(() => _showControls = true);
    _scheduleHide();
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(_hideDuration, () {
      if (mounted) setState(() => _showControls = false);
    });
  }

  // ─────────────────────────────────────────────
  // MARK: — PAGE ACTIONS
  // ─────────────────────────────────────────────

  void _nextPage() {
    if (_currentPage < _totalPages) {
      HapticFeedback.lightImpact();
      _pdfController.nextPage(
        duration: const Duration(milliseconds: 280),
        curve:    Curves.easeOutCubic,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 1) {
      HapticFeedback.lightImpact();
      _pdfController.previousPage(
        duration: const Duration(milliseconds: 280),
        curve:    Curves.easeOutCubic,
      );
    }
  }

  void _toggleBookmark() {
    HapticFeedback.mediumImpact();
    setState(() {
      if (_bookmarkedPages.contains(_currentPage)) {
        _bookmarkedPages.remove(_currentPage);
      } else {
        _bookmarkedPages.add(_currentPage);
      }
    });
  }

  Future<void> _saveProgress() async {
    try {
      await _progressRepo.savePage(pdfId: widget.pdfId, page: _currentPage);
    } catch (_) {}
  }

  void _showJumpDialog() {
    final dark = Theme.of(context).brightness == Brightness.dark;
    _hideTimer?.cancel();
    showDialog<int>(
      context:      context,
      barrierColor: Colors.black.withOpacity(0.40),
      builder: (ctx) => _JumpToPageDialog(
        isDark:      dark,
        currentPage: _currentPage,
        totalPages:  _totalPages,
        onJump: (page) {
          Navigator.pop(ctx);
          _pdfController.jumpToPage(page);
          _scheduleHide();
        },
      ),
    ).then((_) => _scheduleHide());
  }

  // ─────────────────────────────────────────────
  // MARK: — BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final dark   = Theme.of(context).brightness == Brightness.dark;
    final topPad = MediaQuery.of(context).padding.top;
    final botPad = MediaQuery.of(context).padding.bottom;

    SystemChrome.setSystemUIOverlayStyle(
      dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );

    return Scaffold(
      backgroundColor: dark ? Colors.black : const Color(0xFF1A1A1A),
      body: GestureDetector(
        onTap:    _toggleControls,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── PDF View ──────────────────────────
            if (_error != null)
              _ErrorView(error: _error!, isDark: dark)
            else
              PdfViewPinch(
                controller:        _pdfController,
                onDocumentLoaded:  (doc) {
                  setState(() {
                    _totalPages = doc.pagesCount;
                    _isLoading  = false;
                  });
                  _entranceCtrl.forward();
                },
                onDocumentError: (error) {
                  setState(() {
                    _error     = error.toString();
                    _isLoading = false;
                  });
                },
                onPageChanged: (page) {
                  setState(() => _currentPage = page);
                  _saveProgress();
                  _showControlsTemporarily();
                },
                builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
                  options:        const DefaultBuilderOptions(),
                  errorBuilder:   (_, error) => Center(
                    child: Text('Page error: $error',
                        style: const TextStyle(color: Colors.white70))),
                  pageBuilder:    (_, loadingState, page) => switch (loadingState) {
                    PdfPageLoadingState.loading => Container(
                        color: dark ? Colors.black : const Color(0xFF1A1A1A),
                        child: const Center(child: CircularProgressIndicator(
                            color: AppColors.accent, strokeWidth: 2))),
                    PdfPageLoadingState.success => page,
                    PdfPageLoadingState.failed  => Container(
                        color: dark ? Colors.black : const Color(0xFF1A1A1A),
                        child: const Center(child: Icon(Icons.broken_image_outlined,
                            color: Colors.white30, size: 40))),
                  },
                ),
              ),

            // ── Loading overlay ───────────────────
            if (_isLoading) _LoadingOverlay(isDark: dark),

            // ── Reading progress bar ──────────────
            if (!_isLoading && _error == null)
              Positioned(
                top: topPad + kToolbarHeight - 2,
                left: 0, right: 0,
                child: AnimatedOpacity(
                  duration: AppAnimation.standard,
                  opacity:  _showControls ? 1.0 : 0.0,
                  child: _ProgressBar(
                    fraction: _totalPages > 0 ? _currentPage / _totalPages : 0.0,
                  ),
                ),
              ),

            // ── Glass AppBar ──────────────────────
            AnimatedPositioned(
              duration: AppAnimation.medium,
              curve:    Curves.easeOutCubic,
              top:      _showControls ? 0 : -(kToolbarHeight + topPad + 20),
              left: 0, right: 0,
              child: FadeTransition(
                opacity: _appBarFade,
                child: _buildGlassAppBar(dark, topPad),
              ),
            ),

            // ── Glass Bottom Toolbar ──────────────
            AnimatedPositioned(
              duration: AppAnimation.medium,
              curve:    Curves.easeOutCubic,
              bottom:   _showControls ? botPad + AppSpacing.lg : -(100 + botPad),
              left:     AppSpacing.xl, right: AppSpacing.xl,
              child: SlideTransition(
                position: _toolbarSlide,
                child: FadeTransition(
                  opacity: _toolbarFade,
                  child: _buildBottomToolbar(dark),
                ),
              ),
            ),

            // ── Floating Action Buttons ───────────
            AnimatedPositioned(
              duration: AppAnimation.medium,
              curve:    Curves.easeOutCubic,
              bottom:   _showControls
                  ? botPad + AppSpacing.lg + 76
                  : -(200 + botPad),
              right:    AppSpacing.xl,
              child: _buildFABs(dark),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // MARK: — GLASS APP BAR
  // ─────────────────────────────────────────────

  Widget _buildGlassAppBar(bool dark, double topPad) {
    final textColor = dark ? AppColors.darkPrimaryText : Colors.white;
    final secColor  = dark ? AppColors.darkSecondaryText : Colors.white70;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: AppBlur.lg, sigmaY: AppBlur.lg),
        child: Container(
          padding: EdgeInsets.only(top: topPad),
          height:  topPad + kToolbarHeight,
          decoration: BoxDecoration(
            color:  dark
                ? const Color(0xCC1C1C1E)
                : const Color(0xCC000000),
            border: Border(bottom: BorderSide(
              color: dark ? const Color(0x1AFFFFFF) : const Color(0x26FFFFFF),
              width: 0.5,
            )),
          ),
          child: NavigationToolbar(
            leading: _GlassCircleBtn(
              icon:  Icons.arrow_back_ios_rounded,
              isDark: dark, isLightBg: !dark,
              onTap:  () async {
                await _saveProgress();
                if (mounted) Navigator.maybePop(context);
              },
            ),
            middle: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.title,
                  style: AppTypography.titleSmall.copyWith(
                      color: textColor, fontWeight: FontWeight.w700),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
                if (_totalPages > 0)
                  Text('Page $_currentPage of $_totalPages',
                    style: AppTypography.caption.copyWith(
                        color: secColor, fontSize: 11)),
              ],
            ),
            trailing: Padding(
              padding: const EdgeInsets.only(right: AppSpacing.base),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                _GlassCircleBtn(
                  icon: _bookmarkedPages.contains(_currentPage)
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  isDark:    dark, isLightBg: !dark,
                  iconColor: _bookmarkedPages.contains(_currentPage)
                      ? AppColors.accentLight : null,
                  onTap: _toggleBookmark,
                ),
              ]),
            ),
            centerMiddle:  true,
            middleSpacing: AppSpacing.base,
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // MARK: — BOTTOM TOOLBAR
  // ─────────────────────────────────────────────

  Widget _buildBottomToolbar(bool dark) => ClipRRect(
        borderRadius: AppRadius.xxlAll,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: AppBlur.xl, sigmaY: AppBlur.xl),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: dark
                  ? const Color(0xD91C1C1E)
                  : const Color(0xD9000000),
              borderRadius: AppRadius.xxlAll,
              border: Border.all(
                  color: const Color(0x26FFFFFF), width: 0.5),
              boxShadow: [BoxShadow(
                  color:      Colors.black.withOpacity(0.35),
                  blurRadius: 28, offset: const Offset(0, 10))],
            ),
            child: Row(children: [
              // Previous
              _ToolbarNavBtn(
                icon:    Icons.chevron_left_rounded,
                enabled: _currentPage > 1,
                onTap:   _previousPage,
              ),

              _ToolbarDivider(),

              // Page indicator
              Expanded(
                child: GestureDetector(
                  onTap: _showJumpDialog,
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('$_currentPage',
                            style: AppTypography.labelLarge.copyWith(
                              color:      Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize:   17,
                            )),
                          Text(' / $_totalPages',
                            style: AppTypography.labelMedium.copyWith(
                              color: Colors.white60, fontSize: 13,
                            )),
                        ],
                      ),
                      Text(
                        '${_totalPages > 0 ? (_currentPage / _totalPages * 100).toStringAsFixed(0) : 0}% read',
                        style: AppTypography.caption.copyWith(
                            color: Colors.white38, fontSize: 9.5),
                      ),
                    ],
                  ),
                ),
              ),

              _ToolbarDivider(),

              // Next
              _ToolbarNavBtn(
                icon:    Icons.chevron_right_rounded,
                enabled: _currentPage < _totalPages,
                onTap:   _nextPage,
              ),
            ]),
          ),
        ),
      );

  // ─────────────────────────────────────────────
  // MARK: — FABs
  // ─────────────────────────────────────────────

  Widget _buildFABs(bool dark) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Jump to page
          _FABButton(
            icon:  Icons.my_location_rounded,
            isDark: dark,
            onTap: _showJumpDialog,
          ),
          const SizedBox(height: AppSpacing.sm),
          // Bookmark current page
          _FABButton(
            icon: _bookmarkedPages.contains(_currentPage)
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_rounded,
            isDark:    dark,
            iconColor: _bookmarkedPages.contains(_currentPage)
                ? AppColors.accentLight : null,
            onTap: _toggleBookmark,
          ),
        ],
      );
}

// ═════════════════════════════════════════════
// MARK: — SUPPORTING WIDGETS
// ═════════════════════════════════════════════

class _GlassCircleBtn extends StatefulWidget {
  final IconData  icon; final bool isDark, isLightBg;
  final Color?    iconColor;
  final AsyncCallback onTap;
  const _GlassCircleBtn({required this.icon, required this.isDark,
      required this.isLightBg, this.iconColor, required this.onTap});
  @override State<_GlassCircleBtn> createState() => _GlassCircleBtnState();
}
class _GlassCircleBtnState extends State<_GlassCircleBtn>
    with SingleTickerProviderStateMixin {
  late AnimationController _p; late Animation<double> _s;
  @override
  void initState() {
    super.initState();
    _p = AnimationController(vsync: this, duration: const Duration(milliseconds: 110),
        reverseDuration: const Duration(milliseconds: 200));
    _s = Tween<double>(begin: 1.0, end: 0.85)
        .animate(CurvedAnimation(parent: _p, curve: Curves.easeInOut));
  }
  @override void dispose() { _p.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => ScaleTransition(scale: _s,
    child: GestureDetector(
      onTapDown:   (_) => _p.forward(),
      onTapUp:     (_) { _p.reverse(); widget.onTap(); },
      onTapCancel: () => _p.reverse(),
      child: Container(width: 34, height: 34,
        decoration: BoxDecoration(shape: BoxShape.circle,
          color: const Color(0x33FFFFFF)),
        child: Icon(widget.icon, size: 16,
          color: widget.iconColor ?? (widget.isLightBg ? Colors.white : Colors.white)))));
}

class _ToolbarNavBtn extends StatefulWidget {
  final IconData icon; final bool enabled; final VoidCallback onTap;
  const _ToolbarNavBtn({required this.icon, required this.enabled, required this.onTap});
  @override State<_ToolbarNavBtn> createState() => _ToolbarNavBtnState();
}
class _ToolbarNavBtnState extends State<_ToolbarNavBtn> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) => IgnorePointer(ignoring: !widget.enabled,
    child: GestureDetector(
      onTapDown:   (_) => setState(() => _pressed = true),
      onTapUp:     (_) { setState(() => _pressed = false); HapticFeedback.lightImpact(); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedOpacity(duration: const Duration(milliseconds: 80),
        opacity: _pressed ? 0.40 : (widget.enabled ? 1.0 : 0.28),
        child: SizedBox(width: 52, height: 60,
          child: Center(child: Icon(widget.icon, size: 26, color: Colors.white))))));
}

class _ToolbarDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
      width: 0.5, height: 26, color: const Color(0x26FFFFFF));
}

class _FABButton extends StatefulWidget {
  final IconData icon; final bool isDark; final Color? iconColor;
  final VoidCallback onTap;
  const _FABButton({required this.icon, required this.isDark,
      this.iconColor, required this.onTap});
  @override State<_FABButton> createState() => _FABButtonState();
}
class _FABButtonState extends State<_FABButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _p; late Animation<double> _s;
  @override
  void initState() {
    super.initState();
    _p = AnimationController(vsync: this, duration: const Duration(milliseconds: 110),
        reverseDuration: const Duration(milliseconds: 200));
    _s = Tween<double>(begin: 1.0, end: 0.88)
        .animate(CurvedAnimation(parent: _p, curve: Curves.easeInOut));
  }
  @override void dispose() { _p.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => ScaleTransition(scale: _s,
    child: GestureDetector(
      onTapDown:   (_) => _p.forward(),
      onTapUp:     (_) { _p.reverse(); HapticFeedback.mediumImpact(); widget.onTap(); },
      onTapCancel: () => _p.reverse(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: AppBlur.md, sigmaY: AppBlur.md),
          child: Container(width: 44, height: 44,
            decoration: BoxDecoration(
              color:        const Color(0xD91C1C1E),
              borderRadius: BorderRadius.circular(20),
              border:       Border.all(color: const Color(0x26FFFFFF), width: 0.5),
            ),
            child: Icon(widget.icon, size: 20,
              color: widget.iconColor ?? Colors.white))))));
}

class _ProgressBar extends StatelessWidget {
  final double fraction;
  const _ProgressBar({required this.fraction});
  @override
  Widget build(BuildContext context) => SizedBox(height: 2.5,
    child: LayoutBuilder(builder: (context, constraints) => Stack(children: [
      Container(width: constraints.maxWidth, height: 2.5,
          color: Colors.white.withOpacity(0.08)),
      AnimatedContainer(
        duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic,
        width:  constraints.maxWidth * fraction.clamp(0.0, 1.0), height: 2.5,
        decoration: const BoxDecoration(gradient: LinearGradient(
            colors: [AppColors.accent, AppColors.gold]))),
    ])));
}

class _LoadingOverlay extends StatelessWidget {
  final bool isDark;
  const _LoadingOverlay({required this.isDark});
  @override
  Widget build(BuildContext context) => Container(
    color: Colors.black.withOpacity(0.6),
    child: const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2),
      SizedBox(height: AppSpacing.base),
      Text('Opening PDF…', style: TextStyle(color: Colors.white70,
          fontSize: 14, fontFamily: 'Georgia', fontStyle: FontStyle.italic)),
    ])));
}

class _ErrorView extends StatelessWidget {
  final String error; final bool isDark;
  const _ErrorView({required this.error, required this.isDark});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.picture_as_pdf_outlined, size: 56, color: AppColors.error),
      const SizedBox(height: AppSpacing.xl),
      const Text('Failed to open PDF', style: TextStyle(
          color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
      const SizedBox(height: AppSpacing.sm),
      Text(error, style: const TextStyle(color: Colors.white60, fontSize: 13),
          textAlign: TextAlign.center),
    ]));
}

class _JumpToPageDialog extends StatefulWidget {
  final bool isDark; final int currentPage, totalPages;
  final ValueChanged<int> onJump;
  const _JumpToPageDialog({required this.isDark, required this.currentPage,
      required this.totalPages, required this.onJump});
  @override State<_JumpToPageDialog> createState() => _JumpToPageDialogState();
}
class _JumpToPageDialogState extends State<_JumpToPageDialog> {
  late TextEditingController _ctrl;
  String _error = '';
  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.currentPage.toString());
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  void _submit() {
    final page = int.tryParse(_ctrl.text.trim());
    if (page == null || page < 1 || page > widget.totalPages) {
      setState(() => _error = 'Enter 1 to ${widget.totalPages}');
      HapticFeedback.heavyImpact(); return;
    }
    widget.onJump(page);
  }
  @override
  Widget build(BuildContext context) {
    final dark = widget.isDark;
    final textColor = dark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;
    return Dialog(backgroundColor: Colors.transparent, elevation: 0,
      child: ClipRRect(borderRadius: AppRadius.dialog,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: AppBlur.xl, sigmaY: AppBlur.xl),
          child: Container(width: 280,
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: dark ? const Color(0xF01C1C1E) : const Color(0xF0FFFFFF),
              borderRadius: AppRadius.dialog,
              border: Border.all(color: dark ? const Color(0x26FFFFFF) : const Color(0x26000000), width: 0.5),
              boxShadow: dark ? AppShadows.darkLg : AppShadows.lightLg,
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('Jump to Page', style: AppTypography.titleMedium.copyWith(
                  color: textColor, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('1 to ${widget.totalPages}', style: AppTypography.caption.copyWith(
                  color: dark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText)),
              const SizedBox(height: AppSpacing.base),
              Container(
                decoration: BoxDecoration(
                  color: dark ? const Color(0x1AFFFFFF) : const Color(0x0D000000),
                  borderRadius: AppRadius.mdAll,
                  border: Border.all(color: _error.isEmpty
                      ? (dark ? const Color(0x26FFFFFF) : const Color(0x1A000000))
                      : AppColors.error, width: _error.isEmpty ? 0.5 : 1.0)),
                child: TextField(controller: _ctrl, autofocus: true,
                  keyboardType: TextInputType.number, textAlign: TextAlign.center,
                  style: AppTypography.headlineSmall.copyWith(color: textColor, fontWeight: FontWeight.w700),
                  decoration: InputDecoration(hintText: '${widget.currentPage}',
                    hintStyle: AppTypography.headlineSmall.copyWith(
                      color: dark ? AppColors.darkTertiaryText : AppColors.lightTertiaryText)),
                  onSubmitted: (_) => _submit(),
                  onChanged:   (_) { if (_error.isNotEmpty) setState(() => _error = ''); }),
              ),
              if (_error.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(_error, style: AppTypography.caption.copyWith(
                    color: AppColors.error, fontSize: 11)),
              ],
              const SizedBox(height: AppSpacing.base),
              Row(children: [
                Expanded(child: _JDlgBtn(label: 'Cancel', isPrimary: false,
                    isDark: dark, onTap: () => Navigator.pop(context))),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: _JDlgBtn(label: 'Go', isPrimary: true,
                    isDark: dark, onTap: _submit)),
              ]),
            ]))));
  }
}
class _JDlgBtn extends StatefulWidget {
  final String label; final bool isPrimary, isDark; final VoidCallback onTap;
  const _JDlgBtn({required this.label, required this.isPrimary, required this.isDark, required this.onTap});
  @override State<_JDlgBtn> createState() => _JDlgBtnState();
}
class _JDlgBtnState extends State<_JDlgBtn> {
  bool _p = false;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown:   (_) => setState(() => _p = true),
    onTapUp:     (_) { setState(() => _p = false); HapticFeedback.lightImpact(); widget.onTap(); },
    onTapCancel: () => setState(() => _p = false),
    child: AnimatedOpacity(duration: const Duration(milliseconds: 80), opacity: _p ? 0.60 : 1.0,
      child: Container(height: 44,
        decoration: BoxDecoration(
          color: widget.isPrimary ? AppColors.accent
              : AppColors.accent.withOpacity(widget.isDark ? 0.12 : 0.08),
          borderRadius: AppRadius.mdAll),
        child: Center(child: Text(widget.label, style: AppTypography.labelMedium.copyWith(
          color: widget.isPrimary ? Colors.white : AppColors.accent, fontWeight: FontWeight.w600))))));
}