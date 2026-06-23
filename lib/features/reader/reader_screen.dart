// lib/features/reader/reader_screen.dart
// Law Briefly — Reader Screen (Riverpod | iOS 18 Liquid Glass)

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../bookmarks/providers/bookmark_provider.dart'
    show bookmarkControllerProvider, isBookmarkedProvider;
import 'case_law_popup.dart' show showCaseLawPopup;
import 'models/reader_content.dart';
import 'models/reader_state.dart';
import 'providers/reader_controller.dart';

// ─────────────────────────────────────────────
// MARK: — READER SCREEN
// ─────────────────────────────────────────────

class ReaderScreen extends ConsumerStatefulWidget {
  // ── Act section parameters ────────────────────
  final String? actId;
  final String? sectionId;

  // ── Constitution article parameters ───────────
  final String? partId;
  final String? articleId;

  // ── Display ───────────────────────────────────
  final String? sourceTitle;

  const ReaderScreen._({
    this.actId,
    this.sectionId,
    this.partId,
    this.articleId,
    this.sourceTitle,
  });

  factory ReaderScreen.actSection({
    required String actId,
    required String sectionId,
    String?         sourceTitle,
  }) =>
      ReaderScreen._(
        actId:       actId,
        sectionId:   sectionId,
        sourceTitle: sourceTitle,
      );

  factory ReaderScreen.constitutionArticle({
    required String partId,
    required String articleId,
    String?         sourceTitle,
  }) =>
      ReaderScreen._(
        partId:      partId,
        articleId:   articleId,
        sourceTitle: sourceTitle,
      );

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen>
    with SingleTickerProviderStateMixin {

  // ── Animations ────────────────────────────────
  late AnimationController _entranceCtrl;
  late Animation<double>   _appBarFade;
  late Animation<Offset>   _appBarSlide;
  late Animation<double>   _contentFade;
  late Animation<Offset>   _contentSlide;
  late Animation<double>   _bottomNavFade;
  late Animation<Offset>   _bottomNavSlide;

  final ScrollController _scrollCtrl = ScrollController();

  // ─────────────────────────────────────────────
  // MARK: — LIFECYCLE
  // ─────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _setupAnimations();

    // Load content on first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerLoad();
    });
  }

  void _setupAnimations() {
    _entranceCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));

    _appBarFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceCtrl,
          curve: const Interval(0.0, 0.45, curve: Curves.easeOut)));
    _appBarSlide = Tween<Offset>(
        begin: const Offset(0, -0.25), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceCtrl,
          curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic)));
    _contentFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceCtrl,
          curve: const Interval(0.20, 0.75, curve: Curves.easeOut)));
    _contentSlide = Tween<Offset>(
        begin: const Offset(0, 0.06), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceCtrl,
          curve: const Interval(0.20, 0.80, curve: Curves.easeOutCubic)));
    _bottomNavFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceCtrl,
          curve: const Interval(0.55, 0.95, curve: Curves.easeOut)));
    _bottomNavSlide = Tween<Offset>(
        begin: const Offset(0, 1.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceCtrl,
          curve: const Interval(0.55, 1.0, curve: Curves.easeOutCubic)));
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // MARK: — LOAD
  // ─────────────────────────────────────────────

  void _triggerLoad() {
    final notifier = ref.read(readerControllerProvider.notifier);
    if (widget.actId != null && widget.sectionId != null) {
      notifier.loadActSection(
          actId: widget.actId!, sectionId: widget.sectionId!);
    } else if (widget.partId != null && widget.articleId != null) {
      notifier.loadConstitutionArticle(
          partId: widget.partId!, articleId: widget.articleId!);
    }
  }

  void _onRetry() => _triggerLoad();

  void _onScrollToTop() =>
      _scrollCtrl.animateTo(0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic);

  // ─────────────────────────────────────────────
  // MARK: — BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final dark  = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(readerControllerProvider);

    SystemChrome.setSystemUIOverlayStyle(
      dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor:
          dark ? AppColors.darkBackground : const Color(0xFFFFFEFA),
      appBar: _buildAppBar(dark, state),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        switchInCurve:  Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: switch (true) {
          _ when state.isLoading   => _LoadingView(key: const ValueKey('loading'), isDark: dark),
          _ when state.hasError    => _ErrorView(
              key:     const ValueKey('error'),
              message: state.error ?? 'Something went wrong.',
              isDark:  dark,
              onRetry: _onRetry,
            ),
          _ when state.hasContent  => _buildSuccessView(dark, state.content!),
          _                        => _IdleView(key: const ValueKey('idle'), isDark: dark),
        },
      ),
    );
  }

  // ─────────────────────────────────────────────
  // MARK: — APP BAR
  // ─────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(bool dark, ReaderState state) {
    final accent     = dark ? AppColors.accentLight : AppColors.accent;
    final textColor  = dark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;
    final secColor   = dark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;

    final label  = state.content?.displayLabel;
    final source = widget.sourceTitle ?? state.content?.sourceName;

    return GlassAppBar(
      titleWidget: FadeTransition(
        opacity: _appBarFade,
        child: SlideTransition(
          position: _appBarSlide,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label ?? 'Reader',
                style: AppTypography.titleMedium.copyWith(
                  color:      label != null ? accent : textColor,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.1,
                ),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
              if (source != null)
                Text(source,
                  style: AppTypography.caption.copyWith(
                    color: secColor, fontSize: 10,
                  )),
            ],
          ),
        ),
      ),
      leading: FadeTransition(
        opacity: _appBarFade,
        child:   _GlassBackButton(isDark: dark),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // MARK: — SUCCESS VIEW
  // ─────────────────────────────────────────────

  Widget _buildSuccessView(bool dark, ReaderContent content) {
    // Trigger entrance on first successful load
    if (!_entranceCtrl.isAnimating && _entranceCtrl.value == 0) {
      Future.microtask(() {
        if (mounted) _entranceCtrl.forward();
      });
    }

    final topPad = MediaQuery.of(context).padding.top;
    final botPad = MediaQuery.of(context).padding.bottom;

    return Stack(
      key:       const ValueKey('success'),
      fit:       StackFit.expand,
      children: [
        _ReaderBackground(isDark: dark),

        // ── Scrollable content ─────────────────
        FadeTransition(
          opacity: _contentFade,
          child: SlideTransition(
            position: _contentSlide,
            child: SelectionArea(
              child: SingleChildScrollView(
                controller: _scrollCtrl,
                physics:    const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  AppReader.sideMargin,
                  topPad + kToolbarHeight + AppSpacing.xl,
                  AppReader.sideMargin,
                  botPad + 96,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Number badge
                    _NumberBadge(number: content.number, isDark: dark,
                        isArticle: content.isArticle),
                    const SizedBox(height: AppSpacing.base),

                    // Title
                    Text(content.title,
                      style: const TextStyle(
                        fontFamily: 'Georgia', fontSize: AppReader.titleFontSize,
                        fontWeight: FontWeight.w700, height: 1.35, letterSpacing: -0.2,
                      ).merge(TextStyle(
                        color: dark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                      ))),
                    const SizedBox(height: AppSpacing.xl),

                    // Content blocks
                    if (content.content.isEmpty)
                      _EmptyContent(isDark: dark)
                    else
                      ...content.content.map((block) => Padding(
                        padding: const EdgeInsets.only(bottom: AppReader.paragraphSpacing),
                        child: _ContentBlockWidget(block: block, isDark: dark),
                      )),

                    // Case laws section
                    if (content.hasCaseLaws) ...[
                      const SizedBox(height: AppSpacing.xxxl),
                      _CaseLawsSection(
                          caseLawIds: content.caseLawIds, isDark: dark),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Bottom navigation ──────────────────
        Positioned(
          left:   AppSpacing.xl,
          right:  AppSpacing.xl,
          bottom: botPad + AppSpacing.xl,
          child: FadeTransition(
            opacity:  _bottomNavFade,
            child: SlideTransition(
              position: _bottomNavSlide,
              child: _BottomNavBar(isDark: dark, content: content),
            ),
          ),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════
// MARK: — LOADING VIEW
// ═════════════════════════════════════════════

class _LoadingView extends StatefulWidget {
  final bool isDark;
  const _LoadingView({super.key, required this.isDark});

  @override
  State<_LoadingView> createState() => _LoadingViewState();
}

class _LoadingViewState extends State<_LoadingView>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Animation<double>   _opacity;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.35, end: 0.85)
        .animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _pulse.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final secColor = widget.isDark
        ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;

    return Padding(
      padding: EdgeInsets.fromLTRB(
          AppSpacing.xl, topPad + kToolbarHeight + 40,
          AppSpacing.xl, AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Simulated number badge
          FadeTransition(
            opacity: _opacity,
            child: Container(width: 80, height: 24,
              decoration: BoxDecoration(
                color:        secColor.withOpacity(0.15),
                borderRadius: AppRadius.chip,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          // Title skeleton
          ...List.generate(2, (i) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FadeTransition(
              opacity: _opacity,
              child: Container(
                width:  i == 0 ? double.infinity : 240,
                height: 20,
                decoration: BoxDecoration(
                  color:        secColor.withOpacity(0.12),
                  borderRadius: AppRadius.smAll,
                ),
              ),
            ),
          )),
          const SizedBox(height: AppSpacing.xl),
          // Content skeletons
          ...List.generate(8, (i) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: FadeTransition(
              opacity: _opacity,
              child: Container(
                width:  i % 3 == 2 ? 200 : double.infinity,
                height: 14,
                decoration: BoxDecoration(
                  color:        secColor.withOpacity(0.10),
                  borderRadius: AppRadius.smAll,
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════
// MARK: — ERROR VIEW
// ═════════════════════════════════════════════

class _ErrorView extends StatelessWidget {
  final String     message;
  final bool       isDark;
  final VoidCallback onRetry;

  const _ErrorView({
    super.key,
    required this.message,
    required this.isDark,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final topPad   = MediaQuery.of(context).padding.top;
    final textColor = isDark ? AppColors.darkPrimaryText   : AppColors.lightPrimaryText;
    final secColor  = isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;

    return Center(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            AppSpacing.xxxl, topPad + kToolbarHeight + 40, AppSpacing.xxxl, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color:        AppColors.error.withOpacity(isDark ? 0.14 : 0.08),
                borderRadius: AppRadius.lgAll,
              ),
              child: const Icon(Icons.error_outline_rounded,
                  size: 32, color: AppColors.error),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Content Unavailable',
              style: AppTypography.titleMedium.copyWith(
                color:      textColor, fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(message,
              style: AppTypography.bodySmall.copyWith(
                fontFamily: null, color: secColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 3, overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xxxl),
            _RetryButton(onTap: onRetry, isDark: isDark),
          ],
        ),
      ),
    );
  }
}

class _RetryButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool isDark;
  const _RetryButton({required this.onTap, required this.isDark});

  @override
  State<_RetryButton> createState() => _RetryButtonState();
}

class _RetryButtonState extends State<_RetryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _press; late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 120),
        reverseDuration: const Duration(milliseconds: 200));
    _scale = Tween<double>(begin: 1.0, end: 0.94)
        .animate(CurvedAnimation(parent: _press, curve: Curves.easeInOut));
  }

  @override void dispose() { _press.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => ScaleTransition(scale: _scale,
    child: GestureDetector(
      onTapDown:   (_) => _press.forward(),
      onTapUp:     (_) { _press.reverse(); HapticFeedback.lightImpact(); widget.onTap(); },
      onTapCancel: () => _press.reverse(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        decoration: BoxDecoration(
          color:        AppColors.accent,
          borderRadius: AppRadius.button,
          boxShadow:    AppShadows.accentGlow,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.refresh_rounded, size: 17, color: Colors.white),
          const SizedBox(width: 8),
          Text('Try Again', style: AppTypography.labelLarge.copyWith(
              color: Colors.white)),
        ]),
      ),
    ));
}

// ═════════════════════════════════════════════
// MARK: — IDLE VIEW
// ═════════════════════════════════════════════

class _IdleView extends StatelessWidget {
  final bool isDark;
  const _IdleView({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.article_outlined, size: 56,
            color: (isDark ? AppColors.darkTertiaryText : AppColors.lightTertiaryText)
                .withOpacity(0.5)),
          const SizedBox(height: AppSpacing.xl),
          Text('Open a section or article to begin reading.',
            style: AppTypography.bodySmall.copyWith(
              fontFamily: 'Georgia', fontStyle: FontStyle.italic,
              color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
            ),
            textAlign: TextAlign.center),
        ]),
      );
}

// ═════════════════════════════════════════════
// MARK: — CONTENT BLOCK WIDGET
// ═════════════════════════════════════════════

class _ContentBlockWidget extends StatelessWidget {
  final ContentBlock block;
  final bool         isDark;
  const _ContentBlockWidget({required this.block, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textColor  = isDark ? AppColors.darkPrimaryText  : AppColors.lightPrimaryText;
    final accent     = isDark ? AppColors.accentLight : AppColors.accent;

    return switch (block.type) {
      ContentBlockType.main       => _mainText(textColor),
      ContentBlockType.explanation => _explanationText(textColor, accent),
      ContentBlockType.proviso    => _provisoText(textColor),
      ContentBlockType.subSection => _subSectionText(textColor),
    };
  }

  Widget _mainText(Color color) => Text(block.text,
    style: TextStyle(fontFamily: 'Georgia', fontSize: AppReader.baseFontSize,
        height: AppReader.lineHeight, letterSpacing: 0.10, color: color));

  Widget _explanationText(Color color, Color accent) => Container(
    margin:  const EdgeInsets.only(left: AppSpacing.lg),
    padding: const EdgeInsets.only(left: AppSpacing.md),
    decoration: BoxDecoration(
      border: Border(left: BorderSide(color: accent.withOpacity(0.45), width: 3))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (block.label != null)
        Text(block.label!, style: TextStyle(fontFamily: 'Georgia',
            fontSize: 14, fontStyle: FontStyle.italic, fontWeight: FontWeight.w700,
            color: accent, height: 1.5)),
      Text(block.text, style: TextStyle(fontFamily: 'Georgia',
          fontSize: 14.5, height: AppReader.lineHeight, letterSpacing: 0.08,
          fontStyle: FontStyle.italic, color: color.withOpacity(0.88))),
    ]));

  Widget _provisoText(Color color) => Container(
    margin:  const EdgeInsets.only(left: AppSpacing.lg),
    padding: const EdgeInsets.only(left: AppSpacing.md),
    decoration: BoxDecoration(
      border: Border(left: BorderSide(
          color: AppColors.gold.withOpacity(0.55), width: 3))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (block.label != null)
        Text(block.label!, style: const TextStyle(fontFamily: 'Georgia',
            fontSize: 14, fontStyle: FontStyle.italic, fontWeight: FontWeight.w700,
            color: AppColors.gold, height: 1.5)),
      Text(block.text, style: TextStyle(fontFamily: 'Georgia',
          fontSize: 14.5, height: AppReader.lineHeight, letterSpacing: 0.08,
          fontStyle: FontStyle.italic, color: color.withOpacity(0.85))),
    ]));

  Widget _subSectionText(Color color) => Padding(
    padding: const EdgeInsets.only(left: AppSpacing.base),
    child: Text(block.text, style: TextStyle(fontFamily: 'Georgia',
        fontSize: AppReader.baseFontSize, height: AppReader.lineHeight,
        letterSpacing: 0.10, color: color.withOpacity(0.90))));
}

// ═════════════════════════════════════════════
// MARK: — NUMBER BADGE
// ═════════════════════════════════════════════

class _NumberBadge extends StatelessWidget {
  final String number;
  final bool   isDark, isArticle;
  const _NumberBadge({required this.number, required this.isDark,
      required this.isArticle});

  @override
  Widget build(BuildContext context) {
    final accent = isDark ? AppColors.accentLight : AppColors.accent;
    final label  = number.toLowerCase() == 'preamble'
        ? 'Preamble'
        : '${isArticle ? "Article" : "Section"} $number';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color:        accent.withOpacity(isDark ? 0.14 : 0.09),
        borderRadius: AppRadius.chip,
        border:       Border.all(color: accent.withOpacity(0.28), width: 0.5),
      ),
      child: Text(label, style: AppTypography.labelSmall.copyWith(
        color: accent, fontWeight: FontWeight.w700, fontSize: 11.5,
        letterSpacing: 0.2,
      )),
    );
  }
}

// ═════════════════════════════════════════════
// MARK: — CASE LAWS SECTION
// ═════════════════════════════════════════════

class _CaseLawsSection extends StatelessWidget {
  final List<String> caseLawIds;
  final bool         isDark;
  const _CaseLawsSection({required this.caseLawIds, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final secColor = isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final textColor = isDark ? AppColors.darkPrimaryText  : AppColors.lightPrimaryText;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(height: 0.5, decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          Colors.transparent,
          (isDark ? AppColors.darkSeparator : AppColors.lightSeparator).withOpacity(0.6),
          Colors.transparent,
        ]))),
      const SizedBox(height: AppSpacing.xl),
      Row(children: [
        Icon(Icons.gavel_rounded, size: 14, color: secColor),
        const SizedBox(width: 6),
        Text('Linked Case Laws', style: AppTypography.labelMedium.copyWith(
          color: secColor, fontSize: 12, letterSpacing: 0.5,
        )),
        const SizedBox(width: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color:        secColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text('${caseLawIds.length}', style: AppTypography.labelSmall.copyWith(
            color: secColor, fontSize: 10, fontWeight: FontWeight.w700,
          )),
        ),
      ]),
      const SizedBox(height: AppSpacing.base),
      ...caseLawIds.map((id) => _CaseLawRow(
        id:         id,
        isDark:     isDark,
        textColor:  textColor,
        secColor:   secColor,
        onTap:      () => showCaseLawPopup(context, id),
      )),
    ]);
  }
}

class _CaseLawRow extends StatefulWidget {
  final String id, textColor;
  final bool isDark;
  final Color secColor;
  final VoidCallback onTap;

  // Ignore: textColor should be Color not String
  const _CaseLawRow({
    required this.id,
    required this.isDark,
    required this.textColor,
    required this.secColor,
    required this.onTap,
  });

  @override
  State<_CaseLawRow> createState() => _CaseLawRowState();
}

class _CaseLawRowState extends State<_CaseLawRow> {
  bool _pressed = false;
  final accent = AppColors.accent;

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.isDark ? AppColors.accentLight : AppColors.accent;
    return GestureDetector(
      behavior:    HitTestBehavior.opaque,
      onTapDown:   (_) { setState(() => _pressed = true); HapticFeedback.selectionClick(); },
      onTapUp:     (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        padding:  const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: _pressed ? accentColor.withOpacity(0.06) : Colors.transparent,
          borderRadius: AppRadius.smAll,
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.arrow_right_rounded, size: 18,
              color: accentColor.withOpacity(0.60)),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(widget.id, style: const TextStyle(
              fontFamily: 'Georgia', fontSize: 14, fontStyle: FontStyle.italic, height: 1.4,
            ).merge(TextStyle(color: widget.secColor))),
          ),
          Icon(Icons.chevron_right_rounded, size: 14,
              color: widget.secColor.withOpacity(0.40)),
        ]),
      ),
    );
  }
}

// ═════════════════════════════════════════════
// MARK: — BOTTOM NAV BAR
// ═════════════════════════════════════════════

class _BottomNavBar extends ConsumerWidget {
  final bool          isDark;
  final ReaderContent content;

  const _BottomNavBar({required this.isDark, required this.content});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = isDark ? AppColors.accentLight : AppColors.accent;

    return ClipRRect(
      borderRadius: AppRadius.xxlAll,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: AppBlur.xl, sigmaY: AppBlur.xl),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xD91C1C1E) : const Color(0xE0FFFFFF),
            borderRadius: AppRadius.xxlAll,
            border: Border.all(
              color: isDark ? const Color(0x26FFFFFF) : const Color(0x33FFFFFF),
              width: 0.5,
            ),
            boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.38 : 0.10),
              blurRadius: 28, offset: const Offset(0, 10),
            )],
          ),
          child: Row(children: [
            // ← Previous
            _NavButton(
              label:   'Previous',
              icon:    Icons.arrow_back_ios_rounded,
              enabled: content.hasPrevious,
              isDark:  isDark,
              align:   MainAxisAlignment.start,
              onTap:   () => ref.read(readerControllerProvider.notifier).loadPrevious(),
            ),

            // Bookmark (center)
            Expanded(
              child: _BookmarkButton(isDark: isDark, content: content),
            ),

            // Next →
            _NavButton(
              label:        'Next',
              icon:         Icons.arrow_forward_ios_rounded,
              enabled:      content.hasNext,
              isDark:       isDark,
              align:        MainAxisAlignment.end,
              iconTrailing: true,
              onTap:        () => ref.read(readerControllerProvider.notifier).loadNext(),
            ),
          ]),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════
// MARK: — BOOKMARK BUTTON (Riverpod-connected)
// ═════════════════════════════════════════════

class _BookmarkButton extends ConsumerStatefulWidget {
  final bool          isDark;
  final ReaderContent content;

  const _BookmarkButton({required this.isDark, required this.content});

  @override
  ConsumerState<_BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends ConsumerState<_BookmarkButton> {
  bool _isToggling = false;

  // ── Source id: act or constitution part ───────
  String get _sourceId =>
      widget.content.actId ?? widget.content.partId ?? '';

  String get _bookmarkType =>
      widget.content.isActSection ? 'actSection' : 'constitutionArticle';

  Future<void> _handleToggle(bool currentlyBookmarked) async {
    if (_isToggling) return;
    setState(() => _isToggling = true);
    HapticFeedback.mediumImpact();

    try {
      final controller = ref.read(bookmarkControllerProvider.notifier);

      if (currentlyBookmarked) {
        await controller.removeBookmark(widget.content.id);
      } else {
        await controller.addBookmark(
          contentId: widget.content.id,
          title:     widget.content.title,
          source:    _sourceId,
          type:      _bookmarkType,
        );
      }

      // Refresh the bookmark-status check for this content id
      ref.invalidate(isBookmarkedProvider(widget.content.id));
    } finally {
      if (mounted) setState(() => _isToggling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = widget.isDark;
    final bookmarkAsync = ref.watch(isBookmarkedProvider(widget.content.id));

    final isBookmarked = bookmarkAsync.maybeWhen(
      data:    (value) => value,
      orElse:  () => false,
    );

    final accent   = dark ? AppColors.accentLight : AppColors.accent;
    final secColor = dark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final tertColor = dark ? AppColors.darkTertiaryText : AppColors.lightTertiaryText;

    return GestureDetector(
      onTap:     _isToggling ? null : () => _handleToggle(isBookmarked),
      behavior:  HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, anim) => ScaleTransition(
              scale: anim, child: FadeTransition(opacity: anim, child: child)),
            child: _isToggling
                ? SizedBox(
                    key: const ValueKey('loading'),
                    width: 20, height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: accent,
                    ),
                  )
                : Icon(
                    isBookmarked
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    key:   ValueKey(isBookmarked),
                    size:  24,
                    color: isBookmarked ? accent : secColor,
                  ),
          ),
          const SizedBox(height: 3),
          Text(
            isBookmarked ? 'Saved' : 'Bookmark',
            style: AppTypography.caption.copyWith(
              color: isBookmarked ? accent : tertColor,
              fontSize: 10, fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatefulWidget {
  final String            label;
  final IconData          icon;
  final bool              enabled, isDark, iconTrailing;
  final MainAxisAlignment align;
  final VoidCallback      onTap;

  const _NavButton({
    required this.label,   required this.icon,
    required this.enabled, required this.isDark,
    required this.align,   required this.onTap,
    this.iconTrailing = false,
  });

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  bool _p = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.enabled
        ? (widget.isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText)
        : (widget.isDark ? AppColors.darkTertiaryText : AppColors.lightTertiaryText);

    return IgnorePointer(ignoring: !widget.enabled,
      child: GestureDetector(
        onTapDown:   (_) => setState(() => _p = true),
        onTapUp:     (_) { setState(() => _p = false); HapticFeedback.lightImpact(); widget.onTap(); },
        onTapCancel: () => setState(() => _p = false),
        child: AnimatedOpacity(duration: const Duration(milliseconds: 80),
          opacity: _p ? 0.42 : (widget.enabled ? 1.0 : 0.28),
          child: SizedBox(width: 94, height: 64,
            child: Row(mainAxisAlignment: widget.align, children: [
              if (!widget.iconTrailing) ...[
                const SizedBox(width: AppSpacing.lg),
                Icon(widget.icon, size: 16, color: color),
                const SizedBox(width: 4),
              ],
              Text(widget.label, style: AppTypography.labelSmall.copyWith(
                color: color, fontWeight: FontWeight.w600, fontSize: 12,
              )),
              if (widget.iconTrailing) ...[
                const SizedBox(width: 4),
                Icon(widget.icon, size: 16, color: color),
                const SizedBox(width: AppSpacing.lg),
              ],
            ]),
          ),
        ),
      ));
  }
}

// ═════════════════════════════════════════════
// MARK: — SHARED SMALL WIDGETS
// ═════════════════════════════════════════════

class _GlassBackButton extends StatefulWidget {
  final bool isDark;
  const _GlassBackButton({required this.isDark});
  @override State<_GlassBackButton> createState() => _GlassBackButtonState();
}

class _GlassBackButtonState extends State<_GlassBackButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _p; late Animation<double> _s;
  @override
  void initState() {
    super.initState();
    _p = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 110),
        reverseDuration: const Duration(milliseconds: 200));
    _s = Tween<double>(begin: 1.0, end: 0.88)
        .animate(CurvedAnimation(parent: _p, curve: Curves.easeInOut));
  }
  @override void dispose() { _p.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => ScaleTransition(scale: _s,
    child: GestureDetector(
      onTapDown:   (_) => _p.forward(),
      onTapUp:     (_) { _p.reverse(); HapticFeedback.lightImpact(); Navigator.maybePop(context); },
      onTapCancel: () => _p.reverse(),
      child: Container(width: 34, height: 34,
        margin: const EdgeInsets.only(left: AppSpacing.sm),
        decoration: BoxDecoration(shape: BoxShape.circle,
          color: widget.isDark ? const Color(0x33FFFFFF) : const Color(0x1A000000)),
        child: Icon(Icons.arrow_back_ios_rounded, size: 15,
          color: widget.isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText))));
}

class _EmptyContent extends StatelessWidget {
  final bool isDark;
  const _EmptyContent({required this.isDark});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
    child: Text('Content coming soon.', style: AppTypography.legalCaption.copyWith(
      color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
    )));
}

class _ReaderBackground extends StatelessWidget {
  final bool isDark;
  const _ReaderBackground({required this.isDark});
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(gradient: LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: isDark
          ? [const Color(0xFF0D1117), const Color(0xFF121212)]
          : [const Color(0xFFFFFEFA), const Color(0xFFFFFEFD)],
    )));
}