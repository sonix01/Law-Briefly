// lib/features/reader/case_law_popup.dart
// Law Briefly — Case Law Popup (Riverpod | iOS 18 Liquid Glass)

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import 'models/case_law.dart';
import 'models/case_law_state.dart';
import 'providers/case_law_popup_controller.dart';

// ─────────────────────────────────────────────
// MARK: — SHOW HELPER
// ─────────────────────────────────────────────

Future<void> showCaseLawPopup(
  BuildContext context,
  String caseLawId,
) {
  return showModalBottomSheet<void>(
    context:            context,
    isScrollControlled: true,
    backgroundColor:    Colors.transparent,
    barrierColor:       Colors.black.withOpacity(0.40),
    useRootNavigator:   true,
    enableDrag:         true,
    builder: (_) => ProviderScope(
      child: CaseLawPopup(caseLawId: caseLawId),
    ),
  );
}

// ─────────────────────────────────────────────
// MARK: — CASE LAW POPUP
// ─────────────────────────────────────────────

class CaseLawPopup extends ConsumerStatefulWidget {
  final String caseLawId;

  const CaseLawPopup({super.key, required this.caseLawId});

  @override
  ConsumerState<CaseLawPopup> createState() => _CaseLawPopupState();
}

class _CaseLawPopupState extends ConsumerState<CaseLawPopup>
    with SingleTickerProviderStateMixin {

  late AnimationController _sheetCtrl;
  late Animation<double>   _sheetScale;
  late Animation<double>   _contentFade;

  @override
  void initState() {
    super.initState();
    _sheetCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 480),
    );
    _sheetScale = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(parent: _sheetCtrl, curve: Curves.easeOutCubic),
    );
    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sheetCtrl,
          curve: const Interval(0.25, 1.0, curve: Curves.easeOut)),
    );
    _sheetCtrl.forward();
  }

  @override
  void dispose() {
    _sheetCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark  = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(caseLawPopupControllerProvider(widget.caseLawId));

    return ScaleTransition(
      scale: _sheetScale,
      child: DraggableScrollableSheet(
        initialChildSize: 0.90,
        maxChildSize:     0.95,
        minChildSize:     0.40,
        expand:           false,
        snap:             true,
        snapSizes:        const [0.90, 0.95],
        builder: (context, scrollCtrl) => ClipRRect(
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.xxl)),
          child: BackdropFilter(
            filter: ImageFilter.blur(
                sigmaX: AppBlur.xl, sigmaY: AppBlur.xl),
            child: Container(
              decoration: BoxDecoration(
                color: dark
                    ? const Color(0xF21C1C1E)
                    : const Color(0xF2FFFFFF),
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.xxl)),
                border: Border.all(
                  color: dark
                      ? const Color(0x26FFFFFF)
                      : const Color(0x26000000),
                  width: 0.5,
                ),
                boxShadow: dark ? AppShadows.darkLg : AppShadows.lightLg,
              ),
              child: Column(children: [
                // Handle
                _PopupHandle(isDark: dark),

                // Header row
                _PopupHeader(
                  isDark: dark,
                  onClose: () => Navigator.of(context).maybePop(),
                ),

                // Body (state-driven)
                Expanded(
                  child: FadeTransition(
                    opacity: _contentFade,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _buildBody(
                          context, dark, state, scrollCtrl),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // MARK: — BODY SWITCHER
  // ─────────────────────────────────────────────

  Widget _buildBody(
    BuildContext context,
    bool dark,
    CaseLawState state,
    ScrollController scrollCtrl,
  ) {
    if (state.isLoading) {
      return _LoadingBody(key: const ValueKey('cl_loading'), isDark: dark);
    }
    if (state.hasError) {
      return _ErrorBody(
        key:        const ValueKey('cl_error'),
        isDark:     dark,
        message:    state.error!,
        onRetry:    () => ref
            .read(caseLawPopupControllerProvider(widget.caseLawId).notifier)
            .retry(widget.caseLawId),
      );
    }
    if (state.hasCaseLaw) {
      return _SuccessBody(
        key:          const ValueKey('cl_success'),
        isDark:       dark,
        caseLaw:      state.caseLaw!,
        scrollCtrl:   scrollCtrl,
      );
    }
    return const SizedBox.shrink(key: ValueKey('cl_idle'));
  }
}

// ═════════════════════════════════════════════
// MARK: — HANDLE
// ═════════════════════════════════════════════

class _PopupHandle extends StatelessWidget {
  final bool isDark;
  const _PopupHandle({required this.isDark});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 4),
        child: Container(
          width: 36, height: 4,
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0x40FFFFFF)
                : const Color(0x30000000),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );
}

// ═════════════════════════════════════════════
// MARK: — HEADER ROW
// ═════════════════════════════════════════════

class _PopupHeader extends StatelessWidget {
  final bool isDark;
  final VoidCallback onClose;

  const _PopupHeader({required this.isDark, required this.onClose});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl, 0, AppSpacing.base, AppSpacing.sm),
        child: Row(children: [
          Icon(Icons.gavel_rounded, size: 15,
              color: isDark ? AppColors.accentLight : AppColors.accent),
          const SizedBox(width: 6),
          Expanded(
            child: Text('Case Law',
              style: AppTypography.titleSmall.copyWith(
                color:      isDark ? AppColors.accentLight : AppColors.accent,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
                fontSize: 12,
              )),
          ),
          _CloseButton(isDark: isDark, onTap: onClose),
        ]),
      );
}

// ═════════════════════════════════════════════
// MARK: — LOADING BODY
// ═════════════════════════════════════════════

class _LoadingBody extends StatefulWidget {
  final bool isDark;
  const _LoadingBody({super.key, required this.isDark});

  @override
  State<_LoadingBody> createState() => _LoadingBodyState();
}

class _LoadingBodyState extends State<_LoadingBody>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Animation<double>   _opacity;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.3, end: 0.8)
        .animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _pulse.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final secColor = widget.isDark
        ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Title skeleton
        FadeTransition(opacity: _opacity,
          child: Container(width: 260, height: 20,
            decoration: BoxDecoration(color: secColor.withOpacity(0.15),
                borderRadius: AppRadius.smAll))),
        const SizedBox(height: 8),
        FadeTransition(opacity: _opacity,
          child: Container(width: 160, height: 14,
            decoration: BoxDecoration(color: secColor.withOpacity(0.10),
                borderRadius: AppRadius.smAll))),

        const SizedBox(height: AppSpacing.xl),

        // Section skeletons
        ...List.generate(5, (i) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xl),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            FadeTransition(opacity: _opacity,
              child: Container(width: 80, height: 10,
                decoration: BoxDecoration(
                  color: secColor.withOpacity(0.12),
                  borderRadius: AppRadius.smAll,
                ))),
            const SizedBox(height: AppSpacing.md),
            ...List.generate(3, (j) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: FadeTransition(opacity: _opacity,
                child: Container(
                  width:  j == 2 ? 200 : double.infinity, height: 12,
                  decoration: BoxDecoration(
                    color: secColor.withOpacity(0.09),
                    borderRadius: AppRadius.smAll,
                  )),
              ),
            )),
          ]),
        )),
      ]),
    );
  }
}

// ═════════════════════════════════════════════
// MARK: — ERROR BODY
// ═════════════════════════════════════════════

class _ErrorBody extends StatelessWidget {
  final bool     isDark;
  final String   message;
  final VoidCallback onRetry;

  const _ErrorBody({
    super.key,
    required this.isDark,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? AppColors.darkPrimaryText   : AppColors.lightPrimaryText;
    final secColor  = isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                color:        AppColors.error.withOpacity(isDark ? 0.14 : 0.08),
                borderRadius: AppRadius.lgAll,
              ),
              child: const Icon(Icons.gavel_rounded,
                  size: 28, color: AppColors.error),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Case Law Unavailable',
              style: AppTypography.titleMedium.copyWith(
                color: textColor, fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text(message,
              style: AppTypography.bodySmall.copyWith(
                fontFamily: null, color: secColor,
              ),
              textAlign: TextAlign.center,
              maxLines:  3, overflow: TextOverflow.ellipsis),
            const SizedBox(height: AppSpacing.xxxl),
            _RetryButton(isDark: isDark, onTap: onRetry),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════
// MARK: — SUCCESS BODY
// ═════════════════════════════════════════════

class _SuccessBody extends StatelessWidget {
  final bool           isDark;
  final CaseLaw        caseLaw;
  final ScrollController scrollCtrl;

  const _SuccessBody({
    super.key,
    required this.isDark,
    required this.caseLaw,
    required this.scrollCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final textColor  = isDark ? AppColors.darkPrimaryText   : AppColors.lightPrimaryText;
    final secColor   = isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final accent     = isDark ? AppColors.accentLight       : AppColors.accent;
    final botPad     = MediaQuery.of(context).padding.bottom;

    return SingleChildScrollView(
      controller: scrollCtrl,
      physics:    const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl, 0, AppSpacing.xl, botPad + AppSpacing.xxxl,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── TITLE ──────────────────────────────────
        Text(caseLaw.title,
          style: const TextStyle(
            fontFamily: 'Georgia', fontSize: 20,
            fontStyle: FontStyle.italic, fontWeight: FontWeight.w700,
            height: 1.30,
          ).merge(TextStyle(color: textColor))),

        const SizedBox(height: AppSpacing.md),

        // ── CITATION ──────────────────────────────
        if (caseLaw.hasCitation)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color:        accent.withOpacity(isDark ? 0.14 : 0.09),
              borderRadius: AppRadius.chip,
              border:       Border.all(color: accent.withOpacity(0.28), width: 0.5),
            ),
            child: Text(caseLaw.citation!,
              style: AppTypography.labelSmall.copyWith(
                color: accent, fontWeight: FontWeight.w700, fontSize: 11.5,
              )),
          ),

        // ── COURT & YEAR ──────────────────────────
        if (caseLaw.courtAndYear.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Row(children: [
            Icon(Icons.account_balance_outlined, size: 12, color: secColor),
            const SizedBox(width: 5),
            Text(caseLaw.courtAndYear,
              style: AppTypography.caption.copyWith(
                color: secColor, fontSize: 12,
              )),
          ]),
        ],

        const SizedBox(height: AppSpacing.xl),

        // ── SECTION DIVIDER ───────────────────────
        Container(height: 0.5, decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Colors.transparent,
            (isDark ? AppColors.darkSeparator : AppColors.lightSeparator)
                .withOpacity(0.60),
            Colors.transparent,
          ]))),

        const SizedBox(height: AppSpacing.xl),

        // ── SECTION CARDS ─────────────────────────
        _Section(
          title:   'FACTS',
          text:    caseLaw.facts,
          isDark:  isDark,
          color:   const Color(0xFF3B82F6),
        ),
        _Section(
          title:   'ISSUES',
          text:    caseLaw.issues,
          isDark:  isDark,
          color:   const Color(0xFFF59E0B),
        ),
        _Section(
          title:   'JUDGMENT',
          text:    caseLaw.judgment,
          isDark:  isDark,
          color:   const Color(0xFF10B981),
        ),
        _Section(
          title:   'REASONING',
          text:    caseLaw.reasoning,
          isDark:  isDark,
          color:   const Color(0xFF8B5CF6),
        ),
        _Section(
          title:   'LEGAL SIGNIFICANCE',
          text:    caseLaw.significance,
          isDark:  isDark,
          color:   AppColors.gold,
        ),

        // ── RELATED CONTENT ───────────────────────
        if (caseLaw.hasRelatedContent) ...[
          const SizedBox(height: AppSpacing.sm),
          _RelatedContentRow(caseLaw: caseLaw, isDark: isDark),
        ],
      ]),
    );
  }
}

// ═════════════════════════════════════════════
// MARK: — SECTION CARD
// ═════════════════════════════════════════════

class _Section extends StatelessWidget {
  final String title;
  final String text;
  final bool   isDark;
  final Color  color;

  const _Section({
    required this.title,
    required this.text,
    required this.isDark,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;

    if (text.trim().isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Colored left accent bar
        Container(
          width: 3,
          constraints: const BoxConstraints(minHeight: 40),
          margin: const EdgeInsets.only(right: AppSpacing.base, top: 2),
          decoration: BoxDecoration(
            color:        color.withOpacity(0.65),
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section label
              Text(title,
                style: AppTypography.labelSmall.copyWith(
                  color:        color,
                  fontWeight:   FontWeight.w800,
                  letterSpacing: 1.2,
                  fontSize:     10,
                )),
              const SizedBox(height: AppSpacing.sm),

              // Section text
              Text(text,
                style: const TextStyle(
                  fontFamily:    'Georgia',
                  fontSize:      14.5,
                  height:        1.72,
                  letterSpacing: 0.08,
                ).merge(TextStyle(
                  color: textColor.withOpacity(0.90),
                ))),
            ],
          ),
        ),
      ]),
    );
  }
}

// ═════════════════════════════════════════════
// MARK: — RELATED CONTENT ROW
// ═════════════════════════════════════════════

class _RelatedContentRow extends StatelessWidget {
  final CaseLaw caseLaw;
  final bool    isDark;

  const _RelatedContentRow({required this.caseLaw, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final secColor = isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final accent   = isDark ? AppColors.accentLight       : AppColors.accent;

    return Container(
      padding:     const EdgeInsets.all(AppSpacing.md),
      decoration:  BoxDecoration(
        color:        secColor.withOpacity(0.07),
        borderRadius: AppRadius.mdAll,
        border:       Border.all(color: secColor.withOpacity(0.15), width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Referenced In',
          style: AppTypography.labelSmall.copyWith(
            color: secColor, fontSize: 10, letterSpacing: 0.8,
            fontWeight: FontWeight.w700,
          )),
        const SizedBox(height: AppSpacing.sm),
        if (caseLaw.hasRelatedSection)
          Row(children: [
            Icon(Icons.menu_book_outlined, size: 12, color: accent),
            const SizedBox(width: 5),
            Expanded(child: Text('Section: ${caseLaw.relatedSection!}',
              style: AppTypography.caption.copyWith(
                color: accent, fontSize: 12, fontWeight: FontWeight.w500,
              ))),
          ]),
        if (caseLaw.hasRelatedSection && caseLaw.hasRelatedArticle)
          const SizedBox(height: 4),
        if (caseLaw.hasRelatedArticle)
          Row(children: [
            Icon(Icons.balance_rounded, size: 12, color: accent),
            const SizedBox(width: 5),
            Expanded(child: Text('Article: ${caseLaw.relatedArticle!}',
              style: AppTypography.caption.copyWith(
                color: accent, fontSize: 12, fontWeight: FontWeight.w500,
              ))),
          ]),
      ]),
    );
  }
}

// ═════════════════════════════════════════════
// MARK: — CLOSE BUTTON
// ═════════════════════════════════════════════

class _CloseButton extends StatefulWidget {
  final bool         isDark;
  final VoidCallback onTap;
  const _CloseButton({required this.isDark, required this.onTap});

  @override
  State<_CloseButton> createState() => _CloseButtonState();
}

class _CloseButtonState extends State<_CloseButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _press; late Animation<double> _scale;
  @override
  void initState() {
    super.initState();
    _press = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 100),
        reverseDuration: const Duration(milliseconds: 180));
    _scale = Tween<double>(begin: 1.0, end: 0.88)
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
        width: 32, height: 32, margin: const EdgeInsets.only(left: AppSpacing.sm),
        decoration: BoxDecoration(shape: BoxShape.circle,
          color: widget.isDark ? const Color(0x26FFFFFF) : const Color(0x10000000)),
        child: Icon(Icons.close_rounded, size: 16,
          color: widget.isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText))));
}

// ═════════════════════════════════════════════
// MARK: — RETRY BUTTON
// ═════════════════════════════════════════════

class _RetryButton extends StatefulWidget {
  final bool         isDark;
  final VoidCallback onTap;
  const _RetryButton({required this.isDark, required this.onTap});
  @override State<_RetryButton> createState() => _RetryButtonState();
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
    _scale = Tween<double>(begin: 1.0, end: 0.93)
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
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
        decoration: BoxDecoration(
          color:        AppColors.accent,
          borderRadius: AppRadius.button,
          boxShadow:    AppShadows.accentGlow,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.refresh_rounded, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text('Try Again', style: AppTypography.labelLarge.copyWith(
              color: Colors.white)),
        ]))));
}