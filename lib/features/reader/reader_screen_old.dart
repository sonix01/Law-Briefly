// lib/features/reader/reader_screen.dart
// Law Briefly — Reader Screen
// The Most Important Screen | Premium Legal Reading | iOS 18 Liquid Glass

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';

// ─────────────────────────────────────────────
// MARK: — CASE LAW REF MODEL
// ─────────────────────────────────────────────

class CaseLawRef {
  final String id;
  final String citation;
  final String? court;

  const CaseLawRef({
    required this.id,
    required this.citation,
    this.court,
  });

  factory CaseLawRef.fromJson(Map<String, dynamic> json) => CaseLawRef(
        id: json['id'] as String,
        citation: json['citation'] as String,
        court: json['court'] as String?,
      );
}

// ─────────────────────────────────────────────
// MARK: — TEXT BLOCK TYPE
// ─────────────────────────────────────────────

enum TextBlockType { main, explanation, proviso, subSection }

class SectionTextBlock {
  final String text;
  final TextBlockType type;
  final String? label; // e.g. "Explanation 1.—"

  const SectionTextBlock({
    required this.text,
    this.type = TextBlockType.main,
    this.label,
  });
}

// ─────────────────────────────────────────────
// MARK: — READER CONTENT MODEL (JSON-ready)
// ─────────────────────────────────────────────

class ReaderContent {
  final String actId;
  final String actName;
  final String chapterReference;
  final String chapterName;
  final int sectionNumber;
  final String sectionTitle;
  final List<SectionTextBlock> textBlocks;
  final List<CaseLawRef> caseLaws;
  final bool hasPrevious;
  final bool hasNext;

  const ReaderContent({
    required this.actId,
    required this.actName,
    required this.chapterReference,
    required this.chapterName,
    required this.sectionNumber,
    required this.sectionTitle,
    required this.textBlocks,
    required this.caseLaws,
    this.hasPrevious = true,
    this.hasNext = true,
  });

  String get sectionRef => 'Section $sectionNumber';

  factory ReaderContent.fromJson(Map<String, dynamic> json) => ReaderContent(
        actId: json['act_id'] as String,
        actName: json['act_name'] as String,
        chapterReference: json['chapter_reference'] as String,
        chapterName: json['chapter_name'] as String,
        sectionNumber: json['section_number'] as int,
        sectionTitle: json['section_title'] as String,
        textBlocks: (json['text_blocks'] as List<dynamic>)
            .map((b) => SectionTextBlock(
                  text: b['text'] as String,
                  type: TextBlockType.values.firstWhere(
                    (t) => t.name == (b['type'] as String? ?? 'main'),
                    orElse: () => TextBlockType.main,
                  ),
                  label: b['label'] as String?,
                ))
            .toList(),
        caseLaws: (json['case_laws'] as List<dynamic>)
            .map((c) => CaseLawRef.fromJson(c as Map<String, dynamic>))
            .toList(),
      );
}

// ─────────────────────────────────────────────
// MARK: — MOCK DATA (Replace with ISAR / JSON)
// ─────────────────────────────────────────────

abstract final class MockReaderData {
  static const ReaderContent section318 = ReaderContent(
    actId: 'bns_2023',
    actName: 'Bharatiya Nyaya Sanhita, 2023',
    chapterReference: 'Chapter XVII',
    chapterName: 'Offences Against Property',
    sectionNumber: 318,
    sectionTitle:
        'Cheating and dishonestly inducing delivery of property',
    textBlocks: [
      SectionTextBlock(
        text:
            'Whoever cheats and thereby dishonestly induces the person deceived to deliver any property or valuable security, or to alter or destroy the whole or any part of a valuable security, to any person, or to make, alter or destroy the whole or any part of a valuable security, or anything which is sealed or signed or is capable of being converted into a valuable security, shall be punished with imprisonment of either description for a term which may extend to seven years, and shall also be liable to fine.',
        type: TextBlockType.main,
      ),
      SectionTextBlock(
        text:
            'When the offence is committed by a person in the exercise of functions discharged by such person as a public servant, the punishment shall be imprisonment of either description for a term which may extend to ten years, and shall also be liable to fine.',
        type: TextBlockType.main,
      ),
      SectionTextBlock(
        label: 'Explanation 1.\u2014',
        text:
            'A person is said to "cheat" who, by deceiving another person, fraudulently or dishonestly induces the person so deceived to deliver any property to any person, or to consent that any person shall retain any property, or intentionally induces the person so deceived to do or omit to do anything which he would not do or omit if he were not so deceived, and which act or omission causes or is likely to cause damage or harm to that person in body, mind, reputation or property.',
        type: TextBlockType.explanation,
      ),
      SectionTextBlock(
        label: 'Explanation 2.\u2014',
        text:
            'A dishonest concealment of facts is a deception within the meaning of this section.',
        type: TextBlockType.explanation,
      ),
      SectionTextBlock(
        label: 'Proviso.\u2014',
        text:
            'Nothing in this section shall be deemed to make it an offence for a person to deceive another with regard to any matter that is not material to the contract or transaction; and that the person deceived would have agreed to the same contract or transaction even if he had not been deceived about that matter.',
        type: TextBlockType.proviso,
      ),
    ],
    caseLaws: [
      CaseLawRef(
        id: 'cl_1',
        citation: 'Hira Lal Hari Lal Bhagwati v. Central Bureau of Investigation, New Delhi',
        court: 'Supreme Court of India, 2003',
      ),
      CaseLawRef(
        id: 'cl_2',
        citation: 'Inder Mohan Goswami v. State of Uttaranchal',
        court: 'Supreme Court of India, 2007',
      ),
      CaseLawRef(
        id: 'cl_3',
        citation: 'Indian Bank v. M/s ABS Marine Products (P) Ltd.',
        court: 'Supreme Court of India, 2008',
      ),
      CaseLawRef(
        id: 'cl_4',
        citation: 'R. Venkatkrishnan v. Central Bureau of Investigation',
        court: 'Supreme Court of India, 2009',
      ),
      CaseLawRef(
        id: 'cl_5',
        citation: 'Dalip Singh v. State of Punjab',
        court: 'Supreme Court of India, 2010',
      ),
    ],
    hasPrevious: true,
    hasNext: true,
  );
}

// ─────────────────────────────────────────────
// MARK: — READER SCREEN
// ─────────────────────────────────────────────

class ReaderScreen extends StatefulWidget {
  final String? actId;
  final String? sectionId;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final ValueChanged<CaseLawRef>? onCaseLawTap;

  const ReaderScreen({
    super.key,
    this.actId,
    this.sectionId,
    this.onPrevious,
    this.onNext,
    this.onCaseLawTap,
  });

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen>
    with TickerProviderStateMixin {

  // ── Content ───────────────────────────────────
  late final ReaderContent _content;

  // ── State ─────────────────────────────────────
  bool _isBookmarked = false;
  final ScrollController _scrollController = ScrollController();

  // ── Animation Controllers ─────────────────────
  late AnimationController _entranceController;
  late AnimationController _bookmarkController;

  // ── Entrance Animations ───────────────────────
  late Animation<double> _appBarFade;
  late Animation<double> _contentFade;
  late Animation<Offset>  _contentSlide;
  late Animation<double> _navFade;
  late Animation<Offset>  _navSlide;

  // ── Bookmark Animation ────────────────────────
  late Animation<double> _bookmarkScale;

  // ── Constants ─────────────────────────────────
  static const double _navBarHeight    = 72.0;
  static const double _navBarMarginH   = AppSpacing.xl;
  static const double _navBarMarginB   = AppSpacing.base;

  // ─────────────────────────────────────────────
  // MARK: — LIFECYCLE
  // ─────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _content = MockReaderData.section318;
    _setupAnimations();
    _startEntrance();
  }

  void _setupAnimations() {
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _bookmarkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );

    // Entrance
    _appBarFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.00, 0.40, curve: Curves.easeOut),
      ),
    );

    _contentFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.15, 0.65, curve: Curves.easeOut),
      ),
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.15, 0.70, curve: Curves.easeOutCubic),
      ),
    );

    _navFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.50, 0.90, curve: Curves.easeOut),
      ),
    );
    _navSlide = Tween<Offset>(
      begin: const Offset(0, 0.6),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.50, 0.95, curve: Curves.easeOutCubic),
      ),
    );

    // Bookmark bounce
    _bookmarkScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.38)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.38, end: 0.92)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.92, end: 1.0)
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
    _entranceController.dispose();
    _bookmarkController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // MARK: — ACTIONS
  // ─────────────────────────────────────────────

  void _toggleBookmark() {
    HapticFeedback.mediumImpact();
    setState(() => _isBookmarked = !_isBookmarked);
    _bookmarkController.forward(from: 0.0);
  }

  void _handlePrevious() {
    if (!_content.hasPrevious) return;
    HapticFeedback.lightImpact();
    widget.onPrevious?.call();
  }

  void _handleNext() {
    if (!_content.hasNext) return;
    HapticFeedback.lightImpact();
    widget.onNext?.call();
  }

  void _handleCaseLawTap(CaseLawRef ref) {
    HapticFeedback.lightImpact();
    widget.onCaseLawTap?.call(ref);
  }

  // ─────────────────────────────────────────────
  // MARK: — BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final dark = brightness == Brightness.dark;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    SystemChrome.setSystemUIOverlayStyle(
      dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: dark
          ? AppColors.readerPaperDark
          : AppColors.readerPaperLight,
      appBar: _buildAppBar(dark),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          _ReaderBackground(isDark: dark),

          // Scrollable reading content
          FadeTransition(
            opacity: _contentFade,
            child: SlideTransition(
              position: _contentSlide,
              child: SelectionArea(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top +
                        kToolbarHeight +
                        AppSpacing.base,
                    left:  AppSpacing.readerHorizontal,
                    right: AppSpacing.readerHorizontal,
                    bottom: _navBarHeight +
                        bottomPad +
                        _navBarMarginB +
                        AppSpacing.xxxl,
                  ),
                  child: _buildReadingContent(dark),
                ),
              ),
            ),
          ),

          // Floating bottom nav
          Positioned(
            left: _navBarMarginH,
            right: _navBarMarginH,
            bottom: bottomPad + _navBarMarginB,
            child: FadeTransition(
              opacity: _navFade,
              child: SlideTransition(
                position: _navSlide,
                child: _buildBottomNav(dark),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // MARK: — APP BAR
  // ─────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(bool dark) => GlassAppBar(
        titleWidget: FadeTransition(
          opacity: _appBarFade,
          child: Text(
            _content.sectionRef,
            style: AppTypography.sectionNumber.copyWith(
              color: dark ? AppColors.accentLight : AppColors.accent,
              letterSpacing: 1.2,
            ),
          ),
        ),
        leading: FadeTransition(
          opacity: _appBarFade,
          child: _GlassBackButton(isDark: dark),
        ),
        actions: [
          FadeTransition(
            opacity: _appBarFade,
            child: Padding(
              padding: const EdgeInsets.only(right: AppSpacing.base),
              child: Center(
                child: ScaleTransition(
                  scale: _bookmarkScale,
                  child: GestureDetector(
                    onTap: _toggleBookmark,
                    child: AnimatedSwitcher(
                      duration: AppAnimation.standard,
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, anim) => ScaleTransition(
                        scale: anim,
                        child: child,
                      ),
                      child: Icon(
                        _isBookmarked
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        key: ValueKey(_isBookmarked),
                        size: 22,
                        color: _isBookmarked
                            ? (dark ? AppColors.accentLight : AppColors.accent)
                            : (dark
                                ? AppColors.darkSecondaryText
                                : AppColors.lightSecondaryText),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );

  // ─────────────────────────────────────────────
  // MARK: — READING CONTENT
  // ─────────────────────────────────────────────

  Widget _buildReadingContent(bool dark) {
    final c = _content;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Breadcrumb ──────────────────────────
        _buildBreadcrumb(dark),

        const SizedBox(height: AppSpacing.xl),

        // ── Section Reference Label ─────────────
        _buildSectionLabel(dark),

        const SizedBox(height: AppSpacing.sm),

        // ── Section Title ───────────────────────
        _buildSectionTitle(dark),

        const SizedBox(height: AppSpacing.xl + 4),

        // ── Decorative Divider ──────────────────
        _OrnamantedDivider(isDark: dark),

        const SizedBox(height: AppSpacing.xl + 4),

        // ── Text Blocks ─────────────────────────
        ...c.textBlocks.asMap().entries.map((entry) {
          final i = entry.key;
          final block = entry.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextBlock(block, dark),
              SizedBox(
                height: block.type == TextBlockType.main
                    ? AppSpacing.readerParagraphGap
                    : AppSpacing.readerParagraphGap + 4,
              ),
            ],
          );
        }),

        const SizedBox(height: AppSpacing.readerSectionGap - AppSpacing.readerParagraphGap),

        // ── Case Laws Section ───────────────────
        _buildCaseLawsSection(dark),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // MARK: — BREADCRUMB
  // ─────────────────────────────────────────────

  Widget _buildBreadcrumb(bool dark) {
    final secondary = dark
        ? AppColors.darkSecondaryText
        : AppColors.lightSecondaryText;
    final tertiary = dark
        ? AppColors.darkTertiaryText
        : AppColors.lightTertiaryText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _content.actName,
          style: AppTypography.labelSmall.copyWith(
            color: secondary,
            letterSpacing: 0.2,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          '${_content.chapterReference}\u2002\u00B7\u2002${_content.chapterName}',
          style: AppTypography.labelSmall.copyWith(
            color: tertiary,
            fontStyle: FontStyle.italic,
            fontFamily: 'Georgia',
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // MARK: — SECTION LABEL
  // ─────────────────────────────────────────────

  Widget _buildSectionLabel(bool dark) => Text(
        'SECTION ${_content.sectionNumber}',
        style: AppTypography.sectionNumber.copyWith(
          color: dark ? AppColors.accentLight : AppColors.accent,
          fontSize: 12,
          letterSpacing: 2.0,
          fontWeight: FontWeight.w800,
        ),
      );

  // ─────────────────────────────────────────────
  // MARK: — SECTION TITLE
  // ─────────────────────────────────────────────

  Widget _buildSectionTitle(bool dark) => Text(
        _content.sectionTitle,
        style: AppTypography.sectionTitle.copyWith(
          color: dark
              ? AppColors.readerInkDark
              : AppColors.readerInkLight,
          height: 1.3,
          fontSize: 22,
          letterSpacing: -0.3,
        ),
      );

  // ─────────────────────────────────────────────
  // MARK: — TEXT BLOCK DISPATCHER
  // ─────────────────────────────────────────────

  Widget _buildTextBlock(SectionTextBlock block, bool dark) {
    switch (block.type) {
      case TextBlockType.main:
        return _MainTextBlock(block: block, isDark: dark);
      case TextBlockType.explanation:
        return _MarginTextBlock(
          block: block,
          isDark: dark,
          accentColor: dark ? AppColors.accentLight : AppColors.accent,
          borderOpacity: 0.30,
        );
      case TextBlockType.proviso:
        return _MarginTextBlock(
          block: block,
          isDark: dark,
          accentColor: AppColors.gold,
          borderOpacity: 0.35,
        );
      case TextBlockType.subSection:
        return _SubSectionBlock(block: block, isDark: dark);
    }
  }

  // ─────────────────────────────────────────────
  // MARK: — CASE LAWS SECTION
  // ─────────────────────────────────────────────

  Widget _buildCaseLawsSection(bool dark) {
    if (_content.caseLaws.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Divider
        Divider(
          height: 0.5,
          thickness: 0.5,
          color: dark
              ? AppColors.darkSeparator
              : AppColors.lightSeparator,
        ),

        const SizedBox(height: AppSpacing.xl),

        // Heading
        Text(
          'IMPORTANT CASE LAWS',
          style: AppTypography.sectionNumber.copyWith(
            color: dark
                ? AppColors.darkSecondaryText
                : AppColors.lightSecondaryText,
            fontSize: 10.5,
            letterSpacing: 2.0,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: AppSpacing.base),

        // Case law items
        ...(_content.caseLaws.map(
          (ref) => _CaseLawItem(
            caseLaw: ref,
            isDark: dark,
            onTap: () => _handleCaseLawTap(ref),
          ),
        )),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // MARK: — BOTTOM NAV BAR
  // ─────────────────────────────────────────────

  Widget _buildBottomNav(bool dark) => ClipRRect(
        borderRadius: AppRadius.xxlAll,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppBlur.xl,
            sigmaY: AppBlur.xl,
          ),
          child: Container(
            height: _navBarHeight,
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
                  color: Colors.black.withOpacity(dark ? 0.40 : 0.12),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                // ── Previous ─────────────────────
                Expanded(
                  child: _NavBarButton(
                    label: 'Previous',
                    icon: Icons.arrow_back_ios_rounded,
                    iconOnLeft: true,
                    isDark: dark,
                    enabled: _content.hasPrevious,
                    onTap: _handlePrevious,
                  ),
                ),

                // ── Vertical divider ─────────────
                _VerticalNavDivider(isDark: dark),

                // ── Bookmark (center) ─────────────
                _BookmarkNavButton(
                  isDark: dark,
                  isBookmarked: _isBookmarked,
                  scaleAnim: _bookmarkScale,
                  onTap: _toggleBookmark,
                ),

                // ── Vertical divider ─────────────
                _VerticalNavDivider(isDark: dark),

                // ── Next ──────────────────────────
                Expanded(
                  child: _NavBarButton(
                    label: 'Next',
                    icon: Icons.arrow_forward_ios_rounded,
                    iconOnLeft: false,
                    isDark: dark,
                    enabled: _content.hasNext,
                    onTap: _handleNext,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

// ─────────────────────────────────────────────
// MARK: — MAIN TEXT BLOCK
// ─────────────────────────────────────────────

class _MainTextBlock extends StatelessWidget {
  final SectionTextBlock block;
  final bool isDark;

  const _MainTextBlock({required this.block, required this.isDark});

  @override
  Widget build(BuildContext context) => Text(
        block.text,
        style: AppTypography.legalBody.copyWith(
          color: isDark
              ? AppColors.readerInkDark
              : AppColors.readerInkLight,
        ),
        textAlign: TextAlign.justify,
      );
}

// ─────────────────────────────────────────────
// MARK: — MARGIN TEXT BLOCK (Explanation / Proviso)
// ─────────────────────────────────────────────

class _MarginTextBlock extends StatelessWidget {
  final SectionTextBlock block;
  final bool isDark;
  final Color accentColor;
  final double borderOpacity;

  const _MarginTextBlock({
    required this.block,
    required this.isDark,
    required this.accentColor,
    required this.borderOpacity,
  });

  @override
  Widget build(BuildContext context) {
    final inkColor =
        isDark ? AppColors.readerInkDark : AppColors.readerInkLight;

    return Container(
      padding: const EdgeInsets.only(left: AppSpacing.base),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: accentColor.withOpacity(borderOpacity),
            width: 2.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (block.label != null) ...[
            Text(
              block.label!,
              style: AppTypography.caseLawTitle.copyWith(
                color: accentColor,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
          ],
          Text(
            block.text,
            style: AppTypography.legalBody.copyWith(
              color: inkColor,
              fontSize: 15.5,
              height: 1.72,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MARK: — SUB-SECTION BLOCK
// ─────────────────────────────────────────────

class _SubSectionBlock extends StatelessWidget {
  final SectionTextBlock block;
  final bool isDark;

  const _SubSectionBlock({required this.block, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final inkColor =
        isDark ? AppColors.readerInkDark : AppColors.readerInkLight;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (block.label != null) ...[
          Text(
            block.label!,
            style: AppTypography.legalBody.copyWith(
              color: inkColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
        ],
        Expanded(
          child: Text(
            block.text,
            style: AppTypography.legalBody.copyWith(color: inkColor),
            textAlign: TextAlign.justify,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// MARK: — ORNAMENTED DIVIDER
// ─────────────────────────────────────────────

class _OrnamantedDivider extends StatelessWidget {
  final bool isDark;
  const _OrnamantedDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = isDark
        ? AppColors.darkSeparator
        : AppColors.lightSeparator;
    final accent = isDark ? AppColors.accentLight : AppColors.accent;

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 0.5,
            color: color,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Icon(
            Icons.balance_rounded,
            size: 12,
            color: accent.withOpacity(0.45),
          ),
        ),
        Expanded(
          child: Container(
            height: 0.5,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// MARK: — CASE LAW ITEM
// ─────────────────────────────────────────────

class _CaseLawItem extends StatefulWidget {
  final CaseLawRef caseLaw;
  final bool isDark;
  final VoidCallback onTap;

  const _CaseLawItem({
    required this.caseLaw,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_CaseLawItem> createState() => _CaseLawItemState();
}

class _CaseLawItemState extends State<_CaseLawItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final dark = widget.isDark;
    final accentColor = dark ? AppColors.accentLight : AppColors.accent;
    final courtColor  = dark
        ? AppColors.darkTertiaryText
        : AppColors.lightTertiaryText;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        setState(() => _pressed = true);
        HapticFeedback.selectionClick();
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        margin: const EdgeInsets.only(bottom: AppSpacing.base),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: _pressed
              ? accentColor.withOpacity(dark ? 0.10 : 0.06)
              : accentColor.withOpacity(dark ? 0.04 : 0.03),
          borderRadius: AppRadius.mdAll,
          border: Border.all(
            color: accentColor.withOpacity(_pressed ? 0.20 : 0.10),
            width: 0.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bullet dot
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withOpacity(0.65),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.caseLaw.citation,
                    style: AppTypography.caseLawTitle.copyWith(
                      color: accentColor,
                      fontSize: 13.5,
                    ),
                  ),
                  if (widget.caseLaw.court != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      widget.caseLaw.court!,
                      style: AppTypography.caseLawBody.copyWith(
                        color: courtColor,
                        fontSize: 11.5,
                        fontStyle: FontStyle.normal,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: AppSpacing.sm),

            // Chevron
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 14,
                color: accentColor.withOpacity(_pressed ? 0.65 : 0.35),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MARK: — NAV BAR BUTTON (Previous / Next)
// ─────────────────────────────────────────────

class _NavBarButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool iconOnLeft;
  final bool isDark;
  final bool enabled;
  final VoidCallback onTap;

  const _NavBarButton({
    required this.label,
    required this.icon,
    required this.iconOnLeft,
    required this.isDark,
    required this.enabled,
    required this.onTap,
  });

  @override
  State<_NavBarButton> createState() => _NavBarButtonState();
}

class _NavBarButtonState extends State<_NavBarButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final dark      = widget.isDark;
    final enabled   = widget.enabled;
    final textColor = enabled
        ? (dark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText)
        : (dark ? AppColors.darkTertiaryText : AppColors.lightTertiaryText);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled
          ? (_) {
              setState(() => _pressed = false);
              widget.onTap();
            }
          : null,
      onTapCancel:
          enabled ? () => setState(() => _pressed = false) : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 100),
        opacity: _pressed ? 0.55 : 1.0,
        child: SizedBox.expand(
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.iconOnLeft) ...[
                  Icon(widget.icon, size: 13, color: textColor),
                  const SizedBox(width: 4),
                ],
                Text(
                  widget.label,
                  style: AppTypography.labelMedium.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                if (!widget.iconOnLeft) ...[
                  const SizedBox(width: 4),
                  Icon(widget.icon, size: 13, color: textColor),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MARK: — BOOKMARK NAV BUTTON (Center)
// ─────────────────────────────────────────────

class _BookmarkNavButton extends StatelessWidget {
  final bool isDark;
  final bool isBookmarked;
  final Animation<double> scaleAnim;
  final VoidCallback onTap;

  const _BookmarkNavButton({
    required this.isDark,
    required this.isBookmarked,
    required this.scaleAnim,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor =
        isDark ? AppColors.accentLight : AppColors.accent;
    final mutedColor  =
        isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 64,
        child: Center(
          child: ScaleTransition(
            scale: scaleAnim,
            child: AnimatedContainer(
              duration: AppAnimation.standard,
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isBookmarked
                    ? accentColor.withOpacity(0.15)
                    : (isDark
                        ? const Color(0x1AFFFFFF)
                        : const Color(0x0A000000)),
                border: Border.all(
                  color: isBookmarked
                      ? accentColor.withOpacity(0.30)
                      : (isDark
                          ? const Color(0x26FFFFFF)
                          : const Color(0x14000000)),
                  width: 0.5,
                ),
              ),
              child: AnimatedSwitcher(
                duration: AppAnimation.standard,
                switchInCurve: Curves.easeOut,
                child: Icon(
                  isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  key: ValueKey(isBookmarked),
                  size: 19,
                  color: isBookmarked ? accentColor : mutedColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MARK: — VERTICAL NAV DIVIDER
// ─────────────────────────────────────────────

class _VerticalNavDivider extends StatelessWidget {
  final bool isDark;
  const _VerticalNavDivider({required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
        width: 0.5,
        height: 32,
        color: isDark
            ? const Color(0x26FFFFFF)
            : const Color(0x14000000),
      );
}

// ─────────────────────────────────────────────
// MARK: — GLASS BACK BUTTON
// ─────────────────────────────────────────────

class _GlassBackButton extends StatefulWidget {
  final bool isDark;
  const _GlassBackButton({required this.isDark});

  @override
  State<_GlassBackButton> createState() => _GlassBackButtonState();
}

class _GlassBackButtonState extends State<_GlassBackButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _press;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.90).animate(
      CurvedAnimation(parent: _press, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ScaleTransition(
        scale: _scale,
        child: GestureDetector(
          onTapDown: (_) => _press.forward(),
          onTapUp: (_) {
            _press.reverse();
            HapticFeedback.lightImpact();
            Navigator.of(context).maybePop();
          },
          onTapCancel: () => _press.reverse(),
          child: Container(
            width: 34,
            height: 34,
            margin: const EdgeInsets.only(left: AppSpacing.sm),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.isDark
                  ? const Color(0x33FFFFFF)
                  : const Color(0x1A000000),
            ),
            child: Icon(
              Icons.arrow_back_ios_rounded,
              size: 15,
              color: widget.isDark
                  ? AppColors.darkPrimaryText
                  : AppColors.lightPrimaryText,
            ),
          ),
        ),
      );
}

// ─────────────────────────────────────────────
// MARK: — READER BACKGROUND
// ─────────────────────────────────────────────

class _ReaderBackground extends StatelessWidget {
  final bool isDark;
  const _ReaderBackground({required this.isDark});

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.readerPaperDark
              : AppColors.readerPaperLight,
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF161614),
                    Color(0xFF121210),
                  ],
                )
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFFFDF8),
                    Color(0xFFFFFAF2),
                  ],
                ),
        ),
      );
}