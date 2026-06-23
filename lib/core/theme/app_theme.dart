// lib/core/theme/app_theme.dart
// Law Briefly — iOS 18 Liquid Glass Design System
// Production-ready | Material 3 | Light + Dark | Reader-First

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────
// MARK: — COLOR CONSTANTS
// ─────────────────────────────────────────────

abstract final class AppColors {
  // ── Light Theme ──────────────────────────────
  static const Color lightBackground       = Color(0xFFFFFFFF);
  static const Color lightSecondaryBg      = Color(0xFFF8F9FA);
  static const Color lightTertiaryBg       = Color(0xFFEFF0F1);
  static const Color lightPrimaryText      = Color(0xFF1A1A1A);
  static const Color lightSecondaryText    = Color(0xFF8E8E93);
  static const Color lightTertiaryText     = Color(0xFFAEAEB2);
  static const Color lightSeparator       = Color(0x33C6C6C8);
  static const Color lightGroupedBg       = Color(0xFFF2F2F7);

  // ── Dark Theme ───────────────────────────────
  static const Color darkBackground        = Color(0xFF121212);
  static const Color darkSecondaryBg       = Color(0xFF1E1E1E);
  static const Color darkTertiaryBg        = Color(0xFF2C2C2E);
  static const Color darkPrimaryText       = Color(0xFFF5F5F5);
  static const Color darkSecondaryText     = Color(0xFFA0A0A0);
  static const Color darkTertiaryText      = Color(0xFF636366);
  static const Color darkSeparator        = Color(0x33545458);
  static const Color darkGroupedBg        = Color(0xFF1C1C1E);

  // ── Brand / Accent ───────────────────────────
  static const Color accent               = Color(0xFF1C4ED8);   // Royal blue — law & authority
  static const Color accentLight          = Color(0xFF3B82F6);
  static const Color accentMuted          = Color(0x261C4ED8);
  static const Color accentDark           = Color(0xFF1E3A8A);
  static const Color gold                 = Color(0xFFD4AF37);   // Legal gold accent
  static const Color goldMuted            = Color(0x26D4AF37);

  // ── Semantic ─────────────────────────────────
  static const Color success              = Color(0xFF34C759);
  static const Color warning              = Color(0xFFFF9F0A);
  static const Color error               = Color(0xFFFF3B30);
  static const Color info                = Color(0xFF0A84FF);

  // ── Glass Surfaces — Light ───────────────────
  static const Color glassLightBase       = Color(0xB3FFFFFF);   // 70% white
  static const Color glassLightTint       = Color(0x1AFFFFFF);   // 10% white
  static const Color glassLightBorder     = Color(0x33FFFFFF);   // 20% white
  static const Color glassLightHighlight  = Color(0x40FFFFFF);   // 25% white
  static const Color glassLightShadow     = Color(0x1A000000);   // 10% black

  // ── Glass Surfaces — Dark ────────────────────
  static const Color glassDarkBase        = Color(0x99000000);   // 60% black
  static const Color glassDarkTint        = Color(0x0DFFFFFF);   // 5% white
  static const Color glassDarkBorder      = Color(0x1AFFFFFF);   // 10% white
  static const Color glassDarkHighlight   = Color(0x26FFFFFF);   // 15% white
  static const Color glassDarkShadow      = Color(0x40000000);   // 25% black

  // ── Reader Specific ──────────────────────────
  static const Color readerPaperLight     = Color(0xFFFFFDF8);   // warm off-white
  static const Color readerPaperDark      = Color(0xFF161614);   // warm dark
  static const Color readerInkLight       = Color(0xFF1C1917);   // rich ink
  static const Color readerInkDark        = Color(0xFFE7E5E4);   // soft paper white
  static const Color readerDropCapLight   = Color(0xFF1C4ED8);
  static const Color readerDropCapDark    = Color(0xFF60A5FA);
}

// ─────────────────────────────────────────────
// MARK: — SPACING CONSTANTS
// ─────────────────────────────────────────────

abstract final class AppSpacing {
  static const double xxs  = 2.0;
  static const double xs   = 4.0;
  static const double sm   = 8.0;
  static const double md   = 12.0;
  static const double base = 16.0;
  static const double lg   = 20.0;
  static const double xl   = 24.0;
  static const double xxl  = 32.0;
  static const double xxxl = 40.0;
  static const double huge = 48.0;
  static const double max  = 64.0;

  // ── Reader Specific ──────────────────────────
  static const double readerHorizontal    = 20.0;
  static const double readerVertical      = 24.0;
  static const double readerParagraphGap  = 16.0;
  static const double readerLineHeight    = 1.75;
  static const double readerSectionGap    = 32.0;

  // ── Component Specific ───────────────────────
  static const double cardPaddingH        = 16.0;
  static const double cardPaddingV        = 14.0;
  static const double listItemH           = 16.0;
  static const double listItemV           = 12.0;
  static const double bottomBarH          = 24.0;
  static const double bottomBarV          = 12.0;
  static const double modalHandleW        = 36.0;
  static const double modalHandleH        = 4.0;
  static const double modalHandleTopGap   = 12.0;
}

// ─────────────────────────────────────────────
// MARK: — RADIUS CONSTANTS
// ─────────────────────────────────────────────

abstract final class AppRadius {
  static const double xs    = 6.0;
  static const double sm    = 10.0;
  static const double md    = 14.0;
  static const double base  = 16.0;
  static const double lg    = 20.0;
  static const double xl    = 24.0;
  static const double xxl   = 28.0;
  static const double xxxl  = 32.0;
  static const double pill  = 100.0;

  // ── Radii Objects ────────────────────────────
  static BorderRadius get xsAll    => BorderRadius.circular(xs);
  static BorderRadius get smAll    => BorderRadius.circular(sm);
  static BorderRadius get mdAll    => BorderRadius.circular(md);
  static BorderRadius get baseAll  => BorderRadius.circular(base);
  static BorderRadius get lgAll    => BorderRadius.circular(lg);
  static BorderRadius get xlAll    => BorderRadius.circular(xl);
  static BorderRadius get xxlAll   => BorderRadius.circular(xxl);
  static BorderRadius get xxxlAll  => BorderRadius.circular(xxxl);
  static BorderRadius get pillAll  => BorderRadius.circular(pill);

  // ── Component Specific ───────────────────────
  static BorderRadius get card     => BorderRadius.circular(xxl);
  static BorderRadius get button   => BorderRadius.circular(xl);
  static BorderRadius get chip     => BorderRadius.circular(pill);
  static BorderRadius get modal    => BorderRadius.only(
    topLeft: Radius.circular(xxxl),
    topRight: Radius.circular(xxxl),
  );
  static BorderRadius get textField => BorderRadius.circular(md);
  static BorderRadius get appBar    => BorderRadius.zero;
}

// ─────────────────────────────────────────────
// MARK: — BLUR CONSTANTS (Glass Hierarchy)
// ─────────────────────────────────────────────

abstract final class AppBlur {
  static const double none    = 0.0;
  static const double xs      = 4.0;    // subtle background hint
  static const double sm      = 10.0;   // light overlay
  static const double md      = 20.0;   // standard glass
  static const double lg      = 30.0;   // deep glass (navigation bars)
  static const double xl      = 40.0;   // heavy modals
  static const double xxl     = 60.0;   // full screen overlays
}

// ─────────────────────────────────────────────
// MARK: — TYPOGRAPHY CONSTANTS
// ─────────────────────────────────────────────

abstract final class AppTypography {
  // ── Display ──────────────────────────────────
  static const TextStyle displayLarge = TextStyle(
    fontFamily: 'Georgia',
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: 'Georgia',
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.25,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: 'Georgia',
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.3,
  );

  // ── Headline ─────────────────────────────────
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    height: 1.3,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.35,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.4,
  );

  // ── Title ─────────────────────────────────────
  static const TextStyle titleLarge = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.35,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.0,
    height: 1.4,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.05,
    height: 1.45,
  );

  // ── Body (READER-FIRST — legal content) ──────
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Georgia',
    fontSize: 17,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.75,                        // generous for legal reading
    wordSpacing: 0.2,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Georgia',
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.7,
    wordSpacing: 0.1,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.6,
  );

  // ── Label ─────────────────────────────────────
  static const TextStyle labelLarge = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.0,
    height: 1.4,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.05,
    height: 1.45,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.5,
  );

  // ── Caption / Footnote ───────────────────────
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.5,
  );

  static const TextStyle footnote = TextStyle(
    fontFamily: 'Georgia',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    letterSpacing: 0.05,
    height: 1.55,
  );

  // ── Legal Specific ───────────────────────────
  static const TextStyle sectionNumber = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    height: 1.3,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontFamily: 'Georgia',
    fontSize: 19,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    height: 1.3,
  );

  static const TextStyle legalBody = TextStyle(
    fontFamily: 'Georgia',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    height: 1.8,
    wordSpacing: 0.3,
  );

  static const TextStyle caseLawTitle = TextStyle(
    fontFamily: 'Georgia',
    fontSize: 15,
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.italic,
    letterSpacing: 0.05,
    height: 1.45,
  );

  static const TextStyle caseLawBody = TextStyle(
    fontFamily: 'Georgia',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.7,
  );
}

// ─────────────────────────────────────────────
// MARK: — ANIMATION CONSTANTS
// ─────────────────────────────────────────────

abstract final class AppAnimation {
  // ── Durations ────────────────────────────────
  static const Duration instant   = Duration(milliseconds: 100);
  static const Duration fast      = Duration(milliseconds: 180);
  static const Duration standard  = Duration(milliseconds: 280);
  static const Duration medium    = Duration(milliseconds: 380);
  static const Duration slow      = Duration(milliseconds: 500);
  static const Duration verySlow  = Duration(milliseconds: 700);
  static const Duration spring    = Duration(milliseconds: 600);

  // ── Curves ───────────────────────────────────
  static const Curve easeIn       = Curves.easeIn;
  static const Curve easeOut      = Curves.easeOut;
  static const Curve easeInOut    = Curves.easeInOutCubic;
  static const Curve decelerate   = Curves.decelerate;
  static const Curve elasticOut   = Curves.elasticOut;
  static const Curve bounceOut    = Curves.bounceOut;

  // ── iOS-style spring ─────────────────────────
  static const Curve springCurve  = Curves.easeOutCubic;
  static const Curve modalCurve   = Curves.easeOutQuint;

  // ── Scale values (press interactions) ────────
  static const double pressScale  = 0.97;
  static const double tapScale    = 0.95;
  static const double bounceScale = 1.03;
}

// ─────────────────────────────────────────────
// MARK: — ELEVATION & SHADOW SYSTEM
// ─────────────────────────────────────────────

abstract final class AppShadows {
  // ── Light Theme Shadows ───────────────────────
  static List<BoxShadow> get lightSm => [
    BoxShadow(
      color: const Color(0x0D000000),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get lightMd => [
    BoxShadow(
      color: const Color(0x14000000),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: const Color(0x08000000),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get lightLg => [
    BoxShadow(
      color: const Color(0x1A000000),
      blurRadius: 32,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: const Color(0x0A000000),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get lightGlass => [
    BoxShadow(
      color: const Color(0x14000000),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: const Color(0x40FFFFFF),
      blurRadius: 1,
      offset: const Offset(0, 1),
      spreadRadius: -1,
    ),
  ];

  // ── Dark Theme Shadows ────────────────────────
  static List<BoxShadow> get darkSm => [
    BoxShadow(
      color: const Color(0x33000000),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get darkMd => [
    BoxShadow(
      color: const Color(0x4D000000),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: const Color(0x26000000),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get darkLg => [
    BoxShadow(
      color: const Color(0x66000000),
      blurRadius: 32,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: const Color(0x33000000),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get darkGlass => [
    BoxShadow(
      color: const Color(0x59000000),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: const Color(0x26FFFFFF),
      blurRadius: 1,
      offset: const Offset(0, 1),
      spreadRadius: -1,
    ),
  ];
}

// ─────────────────────────────────────────────
// MARK: — GLASS CONFIG
// ─────────────────────────────────────────────

class GlassConfig {
  final double blurSigmaX;
  final double blurSigmaY;
  final Color tintColor;
  final Color borderColor;
  final double borderWidth;
  final BorderRadius borderRadius;
  final List<BoxShadow> shadows;
  final Gradient? highlightGradient;

  const GlassConfig({
    required this.blurSigmaX,
    required this.blurSigmaY,
    required this.tintColor,
    required this.borderColor,
    this.borderWidth = 0.5,
    required this.borderRadius,
    required this.shadows,
    this.highlightGradient,
  });

  // ── Light presets ─────────────────────────────
  static GlassConfig lightCard({BorderRadius? radius}) => GlassConfig(
    blurSigmaX: AppBlur.md,
    blurSigmaY: AppBlur.md,
    tintColor: AppColors.glassLightBase,
    borderColor: AppColors.glassLightBorder,
    borderWidth: 0.5,
    borderRadius: radius ?? AppRadius.card,
    shadows: AppShadows.lightGlass,
    highlightGradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0x40FFFFFF), Color(0x00FFFFFF)],
    ),
  );

  static GlassConfig lightNavBar() => GlassConfig(
    blurSigmaX: AppBlur.lg,
    blurSigmaY: AppBlur.lg,
    tintColor: const Color(0xE6FFFFFF),
    borderColor: const Color(0x1AC6C6C8),
    borderWidth: 0.5,
    borderRadius: BorderRadius.zero,
    shadows: [
      BoxShadow(
        color: const Color(0x0A000000),
        blurRadius: 1,
        offset: const Offset(0, 1),
      ),
    ],
  );

  static GlassConfig lightModal() => GlassConfig(
    blurSigmaX: AppBlur.xl,
    blurSigmaY: AppBlur.xl,
    tintColor: const Color(0xF0FFFFFF),
    borderColor: AppColors.glassLightBorder,
    borderWidth: 0.5,
    borderRadius: AppRadius.modal,
    shadows: AppShadows.lightLg,
    highlightGradient: const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0x33FFFFFF), Color(0x00FFFFFF)],
    ),
  );

  static GlassConfig lightButton({BorderRadius? radius}) => GlassConfig(
    blurSigmaX: AppBlur.sm,
    blurSigmaY: AppBlur.sm,
    tintColor: const Color(0xCCFFFFFF),
    borderColor: const Color(0x40FFFFFF),
    borderWidth: 0.5,
    borderRadius: radius ?? AppRadius.button,
    shadows: AppShadows.lightSm,
  );

  // ── Dark presets ──────────────────────────────
  static GlassConfig darkCard({BorderRadius? radius}) => GlassConfig(
    blurSigmaX: AppBlur.md,
    blurSigmaY: AppBlur.md,
    tintColor: AppColors.glassDarkBase,
    borderColor: AppColors.glassDarkBorder,
    borderWidth: 0.5,
    borderRadius: radius ?? AppRadius.card,
    shadows: AppShadows.darkGlass,
    highlightGradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0x1AFFFFFF), Color(0x00FFFFFF)],
    ),
  );

  static GlassConfig darkNavBar() => GlassConfig(
    blurSigmaX: AppBlur.lg,
    blurSigmaY: AppBlur.lg,
    tintColor: const Color(0xCC1C1C1E),
    borderColor: const Color(0x1AFFFFFF),
    borderWidth: 0.5,
    borderRadius: BorderRadius.zero,
    shadows: [
      BoxShadow(
        color: const Color(0x40000000),
        blurRadius: 1,
        offset: const Offset(0, -1),
      ),
    ],
  );

  static GlassConfig darkModal() => GlassConfig(
    blurSigmaX: AppBlur.xl,
    blurSigmaY: AppBlur.xl,
    tintColor: const Color(0xF01C1C1E),
    borderColor: AppColors.glassDarkBorder,
    borderWidth: 0.5,
    borderRadius: AppRadius.modal,
    shadows: AppShadows.darkLg,
    highlightGradient: const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0x1AFFFFFF), Color(0x00FFFFFF)],
    ),
  );

  static GlassConfig darkButton({BorderRadius? radius}) => GlassConfig(
    blurSigmaX: AppBlur.sm,
    blurSigmaY: AppBlur.sm,
    tintColor: const Color(0x4DFFFFFF),
    borderColor: const Color(0x26FFFFFF),
    borderWidth: 0.5,
    borderRadius: radius ?? AppRadius.button,
    shadows: AppShadows.darkSm,
  );
}

// ─────────────────────────────────────────────
// MARK: — GLASS CONTAINER WIDGET
// ─────────────────────────────────────────────

class GlassContainer extends StatelessWidget {
  final Widget child;
  final GlassConfig? config;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool isDark;
  final bool clipContent;

  const GlassContainer({
    super.key,
    required this.child,
    this.config,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.onTap,
    this.isDark = false,
    this.clipContent = true,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final dark = isDark || brightness == Brightness.dark;
    final cfg = config ?? (dark ? GlassConfig.darkCard() : GlassConfig.lightCard());

    Widget glass = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: cfg.borderRadius,
        boxShadow: cfg.shadows,
      ),
      child: ClipRRect(
        borderRadius: cfg.borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: cfg.blurSigmaX,
            sigmaY: cfg.blurSigmaY,
            tileMode: TileMode.mirror,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: cfg.tintColor,
              borderRadius: cfg.borderRadius,
              border: Border.all(
                color: cfg.borderColor,
                width: cfg.borderWidth,
              ),
              gradient: cfg.highlightGradient,
            ),
            padding: padding,
            child: clipContent
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(
                      cfg.borderRadius.topLeft.x - cfg.borderWidth,
                    ),
                    child: child,
                  )
                : child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      glass = _GlassTapEffect(onTap: onTap!, child: glass);
    }

    return glass;
  }
}

// ─────────────────────────────────────────────
// MARK: — GLASS TAP EFFECT
// ─────────────────────────────────────────────

class _GlassTapEffect extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _GlassTapEffect({required this.child, required this.onTap});

  @override
  State<_GlassTapEffect> createState() => _GlassTapEffectState();
}

class _GlassTapEffectState extends State<_GlassTapEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimation.fast,
      reverseDuration: AppAnimation.standard,
    );
    _scale = Tween<double>(begin: 1.0, end: AppAnimation.pressScale).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimation.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _controller.forward();

  void _onTapUp(TapUpDetails _) {
    _controller.reverse();
    widget.onTap();
    HapticFeedback.lightImpact();
  }

  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: ScaleTransition(scale: _scale, child: widget.child),
      );
}

// ─────────────────────────────────────────────
// MARK: — GLASS APP BAR
// ─────────────────────────────────────────────

class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final double? elevation;
  final double blurSigma;
  final bool showBorder;
  final Color? backgroundColor;

  const GlassAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.elevation,
    this.blurSigma = AppBlur.lg,
    this.showBorder = true,
    this.backgroundColor,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final dark = brightness == Brightness.dark;

    final tint = backgroundColor ??
        (dark ? const Color(0xCC1C1C1E) : const Color(0xE6FFFFFF));
    final border = dark
        ? const Color(0x1AFFFFFF)
        : const Color(0x1AC6C6C8);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          decoration: BoxDecoration(
            color: tint,
            border: showBorder
                ? Border(
                    bottom: BorderSide(color: border, width: 0.5),
                  )
                : null,
          ),
          child: AppBar(
            title: titleWidget ??
                (title != null
                    ? Text(title!, style: AppTypography.titleLarge)
                    : null),
            actions: actions,
            leading: leading,
            centerTitle: centerTitle,
            elevation: 0,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            systemOverlayStyle: dark
                ? SystemUiOverlayStyle.light
                : SystemUiOverlayStyle.dark,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MARK: — GLASS NAVIGATION BAR
// ─────────────────────────────────────────────

class GlassNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationDestination> destinations;
  final double blurSigma;

  const GlassNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.blurSigma = AppBlur.lg,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final dark = brightness == Brightness.dark;

    final tint = dark ? const Color(0xCC1C1C1E) : const Color(0xE6FFFFFF);
    final borderColor = dark
        ? const Color(0x1AFFFFFF)
        : const Color(0x1AC6C6C8);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          decoration: BoxDecoration(
            color: tint,
            border: Border(
              top: BorderSide(color: borderColor, width: 0.5),
            ),
          ),
          child: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            destinations: destinations,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            shadowColor: Colors.transparent,
            indicatorColor: dark
                ? AppColors.accentMuted
                : AppColors.accentMuted,
            labelBehavior:
                NavigationDestinationLabelBehavior.alwaysShow,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MARK: — GLASS NOTIFICATION BANNER
// ─────────────────────────────────────────────

class GlassNotificationBanner extends StatefulWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final Duration duration;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const GlassNotificationBanner({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.duration = const Duration(seconds: 4),
    this.onTap,
    this.onDismiss,
  });

  @override
  State<GlassNotificationBanner> createState() =>
      _GlassNotificationBannerState();

  static void show(
    BuildContext context, {
    required String title,
    String? subtitle,
    IconData? icon,
    Color? iconColor,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onTap,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => Positioned(
        top: MediaQuery.of(context).padding.top + AppSpacing.sm,
        left: AppSpacing.base,
        right: AppSpacing.base,
        child: GlassNotificationBanner(
          title: title,
          subtitle: subtitle,
          icon: icon,
          iconColor: iconColor,
          duration: duration,
          onTap: onTap,
          onDismiss: () => entry.remove(),
        ),
      ),
    );
    overlay.insert(entry);
  }
}

class _GlassNotificationBannerState extends State<GlassNotificationBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slide;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimation.medium,
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppAnimation.modalCurve,
    ));
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _controller.forward();

    Future.delayed(widget.duration, () {
      if (mounted) _dismiss();
    });
  }

  void _dismiss() async {
    await _controller.reverse();
    widget.onDismiss?.call();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final dark = brightness == Brightness.dark;

    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _opacity,
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: widget.onTap,
            onVerticalDragUpdate: (d) {
              if (d.delta.dy < -5) _dismiss();
            },
            child: GlassContainer(
              isDark: dark,
              config: dark ? GlassConfig.darkCard() : GlassConfig.lightCard(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  if (widget.icon != null) ...[
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: (widget.iconColor ?? AppColors.accent)
                            .withOpacity(0.15),
                        borderRadius: AppRadius.smAll,
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.iconColor ?? AppColors.accent,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
                          style: AppTypography.titleMedium.copyWith(
                            color: dark
                                ? AppColors.darkPrimaryText
                                : AppColors.lightPrimaryText,
                          ),
                        ),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.subtitle!,
                            style: AppTypography.caption.copyWith(
                              color: dark
                                  ? AppColors.darkSecondaryText
                                  : AppColors.lightSecondaryText,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  GestureDetector(
                    onTap: _dismiss,
                    child: Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: dark
                          ? AppColors.darkTertiaryText
                          : AppColors.lightTertiaryText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MARK: — GLASS SETTINGS TILE
// ─────────────────────────────────────────────

class GlassSettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? iconBackground;
  final bool isFirst;
  final bool isLast;
  final bool showDivider;

  const GlassSettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.iconBackground,
    this.isFirst = false,
    this.isLast = false,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final dark = brightness == Brightness.dark;

    final borderRadius = BorderRadius.only(
      topLeft: isFirst ? Radius.circular(AppRadius.lg) : Radius.zero,
      topRight: isFirst ? Radius.circular(AppRadius.lg) : Radius.zero,
      bottomLeft: isLast ? Radius.circular(AppRadius.lg) : Radius.zero,
      bottomRight: isLast ? Radius.circular(AppRadius.lg) : Radius.zero,
    );

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: AppBlur.md, sigmaY: AppBlur.md),
        child: Container(
          decoration: BoxDecoration(
            color: dark
                ? const Color(0x991E1E1E)
                : const Color(0xCCFFFFFF),
            borderRadius: borderRadius,
          ),
          child: _GlassTapEffect(
            onTap: onTap ?? () {},
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.base,
                    vertical: AppSpacing.listItemV,
                  ),
                  child: Row(
                    children: [
                      // Icon badge
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: iconBackground ??
                              (iconColor ?? AppColors.accent).withOpacity(0.15),
                          borderRadius: AppRadius.smAll,
                        ),
                        child: Icon(
                          icon,
                          size: 16,
                          color: iconColor ?? AppColors.accent,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),

                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              style: AppTypography.bodySmall.copyWith(
                                fontFamily: null,
                                color: dark
                                    ? AppColors.darkPrimaryText
                                    : AppColors.lightPrimaryText,
                                height: 1.3,
                              ),
                            ),
                            if (subtitle != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                subtitle!,
                                style: AppTypography.caption.copyWith(
                                  color: dark
                                      ? AppColors.darkSecondaryText
                                      : AppColors.lightSecondaryText,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Trailing
                      trailing ??
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 18,
                            color: dark
                                ? AppColors.darkTertiaryText
                                : AppColors.lightTertiaryText,
                          ),
                    ],
                  ),
                ),

                // Divider (not on last)
                if (showDivider && !isLast)
                  Padding(
                    padding: const EdgeInsets.only(left: 58),
                    child: Divider(
                      height: 0.5,
                      thickness: 0.5,
                      color: dark
                          ? AppColors.darkSeparator
                          : AppColors.lightSeparator,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MARK: — GLASS BOTTOM SHEET
// ─────────────────────────────────────────────

class GlassBottomSheet extends StatelessWidget {
  final Widget child;
  final double? initialChildSize;
  final double? minChildSize;
  final double? maxChildSize;
  final bool showHandle;
  final EdgeInsetsGeometry? padding;
  final bool isDismissible;

  const GlassBottomSheet({
    super.key,
    required this.child,
    this.initialChildSize = 0.5,
    this.minChildSize = 0.25,
    this.maxChildSize = 0.92,
    this.showHandle = true,
    this.padding,
    this.isDismissible = true,
  });

  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    double initialChildSize = 0.5,
    double minChildSize = 0.25,
    double maxChildSize = 0.92,
    bool showHandle = true,
    bool isDismissible = true,
    EdgeInsetsGeometry? padding,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (_) => GlassBottomSheet(
        initialChildSize: initialChildSize,
        minChildSize: minChildSize,
        maxChildSize: maxChildSize,
        showHandle: showHandle,
        padding: padding,
        isDismissible: isDismissible,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final dark = brightness == Brightness.dark;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return DraggableScrollableSheet(
      initialChildSize: initialChildSize!,
      minChildSize: minChildSize!,
      maxChildSize: maxChildSize!,
      expand: false,
      builder: (context, scrollController) => ClipRRect(
        borderRadius: AppRadius.modal,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: AppBlur.xl, sigmaY: AppBlur.xl),
          child: Container(
            decoration: BoxDecoration(
              color: dark
                  ? const Color(0xF01C1C1E)
                  : const Color(0xF0FFFFFF),
              borderRadius: AppRadius.modal,
              border: Border.all(
                color: dark
                    ? AppColors.glassDarkBorder
                    : AppColors.glassLightBorder,
                width: 0.5,
              ),
            ),
            child: Column(
              children: [
                // Handle
                if (showHandle) ...[
                  const SizedBox(height: AppSpacing.modalHandleTopGap),
                  Container(
                    width: AppSpacing.modalHandleW,
                    height: AppSpacing.modalHandleH,
                    decoration: BoxDecoration(
                      color: dark
                          ? const Color(0x4DFFFFFF)
                          : const Color(0x4D000000),
                      borderRadius: AppRadius.pillAll,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: padding ??
                        EdgeInsets.fromLTRB(
                          AppSpacing.base,
                          0,
                          AppSpacing.base,
                          bottomPad + AppSpacing.base,
                        ),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MARK: — APP THEME
// ─────────────────────────────────────────────

abstract final class AppTheme {
  // ── Light Theme ───────────────────────────────
  static ThemeData get light {
    const colorScheme = ColorScheme.light(
      primary:          AppColors.accent,
      onPrimary:        Color(0xFFFFFFFF),
      primaryContainer: AppColors.accentMuted,
      onPrimaryContainer: AppColors.accentDark,
      secondary:        AppColors.gold,
      onSecondary:      Color(0xFFFFFFFF),
      secondaryContainer: AppColors.goldMuted,
      onSecondaryContainer: Color(0xFF6B4800),
      surface:          AppColors.lightBackground,
      onSurface:        AppColors.lightPrimaryText,
      surfaceContainerHighest: AppColors.lightSecondaryBg,
      onSurfaceVariant: AppColors.lightSecondaryText,
      outline:          AppColors.lightSeparator,
      outlineVariant:   Color(0x1AC6C6C8),
      error:            AppColors.error,
      onError:          Color(0xFFFFFFFF),
      background:       AppColors.lightBackground,
      onBackground:     AppColors.lightPrimaryText,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,

      // Typography
      fontFamily: 'SF Pro Text',
      textTheme: _buildTextTheme(
        primary: AppColors.lightPrimaryText,
        secondary: AppColors.lightSecondaryText,
      ),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: AppColors.lightPrimaryText,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.accent,
          size: 22,
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: AppColors.lightSecondaryBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
          side: BorderSide(
            color: AppColors.lightSeparator,
            width: 0.5,
          ),
        ),
        margin: EdgeInsets.zero,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.lightSeparator,
        thickness: 0.5,
        space: 0,
      ),

      // List Tile
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdAll,
        ),
        tileColor: Colors.transparent,
        selectedTileColor: AppColors.accentMuted,
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.button,
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accent,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: AppSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.mdAll,
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accent,
          side: const BorderSide(color: AppColors.accent, width: 1),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.button,
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSecondaryBg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.textField,
          borderSide: BorderSide(
            color: AppColors.lightSeparator,
            width: 0.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.textField,
          borderSide: BorderSide(
            color: AppColors.lightSeparator,
            width: 0.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.textField,
          borderSide: const BorderSide(
            color: AppColors.accent,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.textField,
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1,
          ),
        ),
        labelStyle: AppTypography.bodySmall.copyWith(
          fontFamily: null,
          color: AppColors.lightSecondaryText,
        ),
        hintStyle: AppTypography.bodySmall.copyWith(
          fontFamily: null,
          color: AppColors.lightTertiaryText,
        ),
      ),

      // Bottom Sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        modalBackgroundColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppRadius.xxxl),
            topRight: Radius.circular(AppRadius.xxxl),
          ),
        ),
      ),

      // Navigation Bar
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        indicatorColor: AppColors.accentMuted,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.labelSmall.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w600,
            );
          }
          return AppTypography.labelSmall.copyWith(
            color: AppColors.lightSecondaryText,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.accent, size: 22);
          }
          return IconThemeData(color: AppColors.lightSecondaryText, size: 22);
        }),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightSecondaryBg,
        selectedColor: AppColors.accentMuted,
        labelStyle: AppTypography.labelSmall,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.pillAll,
          side: BorderSide(color: AppColors.lightSeparator, width: 0.5),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.accent;
          }
          return AppColors.lightTertiaryText;
        }),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.lightPrimaryText,
        contentTextStyle: AppTypography.bodySmall.copyWith(
          fontFamily: null,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdAll,
        ),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.lightSecondaryBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.xlAll,
        ),
        titleTextStyle: AppTypography.headlineMedium.copyWith(
          color: AppColors.lightPrimaryText,
        ),
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.lightSecondaryText,
        ),
      ),

      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accent,
        linearTrackColor: AppColors.accentMuted,
        circularTrackColor: AppColors.accentMuted,
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.pillAll,
        ),
      ),

      // Icon
      iconTheme: const IconThemeData(
        color: AppColors.lightPrimaryText,
        size: 22,
      ),

      // Page transitions
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  // ── Dark Theme ────────────────────────────────
  static ThemeData get dark {
    const colorScheme = ColorScheme.dark(
      primary:          AppColors.accentLight,
      onPrimary:        Color(0xFFFFFFFF),
      primaryContainer: AppColors.accentMuted,
      onPrimaryContainer: AppColors.accentLight,
      secondary:        AppColors.gold,
      onSecondary:      Color(0xFF000000),
      secondaryContainer: AppColors.goldMuted,
      onSecondaryContainer: AppColors.gold,
      surface:          AppColors.darkBackground,
      onSurface:        AppColors.darkPrimaryText,
      surfaceContainerHighest: AppColors.darkSecondaryBg,
      onSurfaceVariant: AppColors.darkSecondaryText,
      outline:          AppColors.darkSeparator,
      outlineVariant:   Color(0x33545458),
      error:            AppColors.error,
      onError:          Color(0xFFFFFFFF),
      background:       AppColors.darkBackground,
      onBackground:     AppColors.darkPrimaryText,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,

      // Typography
      fontFamily: 'SF Pro Text',
      textTheme: _buildTextTheme(
        primary: AppColors.darkPrimaryText,
        secondary: AppColors.darkSecondaryText,
      ),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: AppColors.darkPrimaryText,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.accentLight,
          size: 22,
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: AppColors.darkSecondaryBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
          side: BorderSide(
            color: AppColors.darkSeparator,
            width: 0.5,
          ),
        ),
        margin: EdgeInsets.zero,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.darkSeparator,
        thickness: 0.5,
        space: 0,
      ),

      // List Tile
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdAll,
        ),
        tileColor: Colors.transparent,
        selectedTileColor: AppColors.accentMuted,
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentLight,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.button,
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentLight,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: AppSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.mdAll,
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accentLight,
          side: const BorderSide(color: AppColors.accentLight, width: 1),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.button,
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSecondaryBg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.textField,
          borderSide: BorderSide(
            color: AppColors.darkSeparator,
            width: 0.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.textField,
          borderSide: BorderSide(
            color: AppColors.darkSeparator,
            width: 0.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.textField,
          borderSide: const BorderSide(
            color: AppColors.accentLight,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.textField,
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1,
          ),
        ),
        labelStyle: AppTypography.bodySmall.copyWith(
          fontFamily: null,
          color: AppColors.darkSecondaryText,
        ),
        hintStyle: AppTypography.bodySmall.copyWith(
          fontFamily: null,
          color: AppColors.darkTertiaryText,
        ),
      ),

      // Bottom Sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        modalBackgroundColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppRadius.xxxl),
            topRight: Radius.circular(AppRadius.xxxl),
          ),
        ),
      ),

      // Navigation Bar
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        indicatorColor: AppColors.accentMuted,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.labelSmall.copyWith(
              color: AppColors.accentLight,
              fontWeight: FontWeight.w600,
            );
          }
          return AppTypography.labelSmall.copyWith(
            color: AppColors.darkSecondaryText,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.accentLight, size: 22);
          }
          return IconThemeData(color: AppColors.darkSecondaryText, size: 22);
        }),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSecondaryBg,
        selectedColor: AppColors.accentMuted,
        labelStyle: AppTypography.labelSmall.copyWith(
          color: AppColors.darkPrimaryText,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.pillAll,
          side: BorderSide(color: AppColors.darkSeparator, width: 0.5),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.accentLight;
          }
          return AppColors.darkTertiaryText;
        }),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.darkSecondaryBg,
        contentTextStyle: AppTypography.bodySmall.copyWith(
          fontFamily: null,
          color: AppColors.darkPrimaryText,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdAll,
        ),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSecondaryBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.xlAll,
        ),
        titleTextStyle: AppTypography.headlineMedium.copyWith(
          color: AppColors.darkPrimaryText,
        ),
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.darkSecondaryText,
        ),
      ),

      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accentLight,
        linearTrackColor: AppColors.accentMuted,
        circularTrackColor: AppColors.accentMuted,
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.accentLight,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.pillAll,
        ),
      ),

      // Icon
      iconTheme: const IconThemeData(
        color: AppColors.darkPrimaryText,
        size: 22,
      ),

      // Page transitions
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  // ── Shared Text Theme Builder ─────────────────
  static TextTheme _buildTextTheme({
    required Color primary,
    required Color secondary,
  }) =>
      TextTheme(
        displayLarge:   AppTypography.displayLarge.copyWith(color: primary),
        displayMedium:  AppTypography.displayMedium.copyWith(color: primary),
        displaySmall:   AppTypography.displaySmall.copyWith(color: primary),
        headlineLarge:  AppTypography.headlineLarge.copyWith(color: primary),
        headlineMedium: AppTypography.headlineMedium.copyWith(color: primary),
        headlineSmall:  AppTypography.headlineSmall.copyWith(color: primary),
        titleLarge:     AppTypography.titleLarge.copyWith(color: primary),
        titleMedium:    AppTypography.titleMedium.copyWith(color: primary),
        titleSmall:     AppTypography.titleSmall.copyWith(color: secondary),
        bodyLarge:      AppTypography.bodyLarge.copyWith(color: primary),
        bodyMedium:     AppTypography.bodyMedium.copyWith(color: primary),
        bodySmall:      AppTypography.bodySmall.copyWith(color: secondary),
        labelLarge:     AppTypography.labelLarge.copyWith(color: primary),
        labelMedium:    AppTypography.labelMedium.copyWith(color: secondary),
        labelSmall:     AppTypography.labelSmall.copyWith(color: secondary),
      );
}
