// lib/features/home/home_screen.dart
// Law Briefly — Home Screen (Launchpad)
// iOS 18 Liquid Glass | GoRouter Navigation | Reader-First

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../app/app_router.dart' show AppNavigation;

// ─────────────────────────────────────────────
// MARK: — MODULE DATA MODEL
// ─────────────────────────────────────────────

class HomeModule {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final VoidCallback? onTap;

  const HomeModule({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    this.onTap,
  });
}

// ─────────────────────────────────────────────
// MARK: — HOME SCREEN
// ─────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  final String? userName;

  // Optional external listeners (analytics / overrides).
  // Navigation itself always happens via GoRouter regardless
  // of whether these are provided.
  final VoidCallback? onConstitutionTap;
  final VoidCallback? onActsTap;
  final VoidCallback? onAcademicNotesTap;
  final VoidCallback? onMyNotesTap;
  final VoidCallback? onSettingsTap;

  const HomeScreen({
    super.key,
    this.userName,
    this.onConstitutionTap,
    this.onActsTap,
    this.onAcademicNotesTap,
    this.onMyNotesTap,
    this.onSettingsTap,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {

  // ── Animation Controllers ─────────────────────
  late AnimationController _entranceController;

  // ── Entrance Animations ───────────────────────
  late Animation<double>  _greetingOpacity;
  late Animation<Offset>  _greetingSlide;
  late Animation<double>  _titleOpacity;
  late Animation<Offset>  _titleSlide;
  late Animation<double>  _dividerOpacity;
  late List<Animation<double>>  _cardOpacities;
  late List<Animation<Offset>>  _cardSlides;
  late Animation<double>  _settingsOpacity;
  late Animation<Offset>  _settingsSlide;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startEntrance();
  }

  void _setupAnimations() {
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // ── Greeting ─────────────────────────────────
    _greetingOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.00, 0.35, curve: Curves.easeOut),
      ),
    );
    _greetingSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.00, 0.42, curve: Curves.easeOutCubic),
      ),
    );

    // ── Title ─────────────────────────────────────
    _titleOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.07, 0.40, curve: Curves.easeOut),
      ),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.07, 0.45, curve: Curves.easeOutCubic),
      ),
    );

    // ── Divider ───────────────────────────────────
    _dividerOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.20, 0.48, curve: Curves.easeOut),
      ),
    );

    // ── Cards (staggered) ─────────────────────────
    _cardOpacities = List.generate(4, (i) {
      final start = 0.22 + i * 0.09;
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _entranceController,
          curve: Interval(
            start.clamp(0.0, 0.9),
            (start + 0.28).clamp(0.0, 1.0),
            curve: Curves.easeOut,
          ),
        ),
      );
    });

    _cardSlides = List.generate(4, (i) {
      final start = 0.22 + i * 0.09;
      return Tween<Offset>(
        begin: const Offset(0, 0.06),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _entranceController,
          curve: Interval(
            start.clamp(0.0, 0.9),
            (start + 0.34).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });

    // ── Settings ──────────────────────────────────
    _settingsOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.72, 1.0, curve: Curves.easeOut),
      ),
    );
    _settingsSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.72, 1.0, curve: Curves.easeOutCubic),
      ),
    );
  }

  void _startEntrance() {
    Future.delayed(const Duration(milliseconds: 60), () {
      if (mounted) _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  // ── Computed Properties ───────────────────────
  String get _greeting {
    final h = DateTime.now().hour;
    if (h >= 5  && h < 12) return 'Good morning';
    if (h >= 12 && h < 17) return 'Good afternoon';
    if (h >= 17 && h < 21) return 'Good evening';
    return 'Good night';
  }

  String get _greetingEmoji {
    final h = DateTime.now().hour;
    if (h >= 5  && h < 12) return '☀️';
    if (h >= 12 && h < 17) return '📖';
    if (h >= 17 && h < 21) return '🌆';
    return '🌙';
  }

  // ─────────────────────────────────────────────
  // MARK: — NAVIGATION (GoRouter)
  // ─────────────────────────────────────────────

  void _navigateToConstitution() {
    HapticFeedback.lightImpact();
    widget.onConstitutionTap?.call();
    context.goConstitution();
  }

  void _navigateToActs() {
    HapticFeedback.lightImpact();
    widget.onActsTap?.call();
    context.goActs();
  }

  void _navigateToAcademicNotes() {
    HapticFeedback.lightImpact();
    widget.onAcademicNotesTap?.call();
    context.goAcademicNotes();
  }

  void _navigateToMyNotes() {
    HapticFeedback.lightImpact();
    widget.onMyNotesTap?.call();
    context.goMyNotes();
  }

  void _navigateToSettings() {
    HapticFeedback.lightImpact();
    widget.onSettingsTap?.call();
    context.goSettings();
  }

  List<HomeModule> get _modules => [
    HomeModule(
      id: 'constitution',
      title: 'Constitution',
      subtitle: 'Articles, Parts and Constitutional Case Laws',
      icon: Icons.account_balance_outlined,
      accentColor: AppColors.accent,
      onTap: _navigateToConstitution,
    ),
    HomeModule(
      id: 'acts',
      title: 'Acts',
      subtitle: 'Read Acts section-wise with linked Case Laws',
      icon: Icons.menu_book_outlined,
      accentColor: const Color(0xFF7C3AED),
      onTap: _navigateToActs,
    ),
    HomeModule(
      id: 'academic_notes',
      title: 'Academic Notes',
      subtitle: 'Year-wise legal study material',
      icon: Icons.school_outlined,
      accentColor: const Color(0xFF059669),
      onTap: _navigateToAcademicNotes,
    ),
    HomeModule(
      id: 'my_notes',
      title: 'My Notes & Bookmarks',
      subtitle: 'Saved sections, articles and personal notes',
      icon: Icons.bookmark_border_rounded,
      accentColor: AppColors.gold,
      onTap: _navigateToMyNotes,
    ),
  ];

  // ─────────────────────────────────────────────
  // MARK: — BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final dark = brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(
      dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );

    return Scaffold(
      backgroundColor: dark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: Stack(
        children: [
          // Ambient background
          _HomeBackground(isDark: dark),

          // Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ─────────────────────────
                _buildHeader(dark),

                // ── Section divider ─────────────────
                FadeTransition(
                  opacity: _dividerOpacity,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl, 0, AppSpacing.xl, 0,
                    ),
                    child: _SectionDivider(isDark: dark),
                  ),
                ),

                const SizedBox(height: AppSpacing.base),

                // ── Module cards ────────────────────
                Expanded(child: _buildModuleCards(dark)),

                // ── Settings row ────────────────────
                _buildSettingsRow(dark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // MARK: — Header Section
  // ─────────────────────────────────────────────

  Widget _buildHeader(bool dark) => Padding(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.xl,
      AppSpacing.xl,
      AppSpacing.xl,
      AppSpacing.base,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Greeting
        FadeTransition(
          opacity: _greetingOpacity,
          child: SlideTransition(
            position: _greetingSlide,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.userName != null
                      ? '$_greeting, ${widget.userName}'
                      : _greeting,
                  style: AppTypography.labelMedium.copyWith(
                    color: dark
                        ? AppColors.darkSecondaryText
                        : AppColors.lightSecondaryText,
                    letterSpacing: 0.1,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  _greetingEmoji,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 4),

        // App name
        FadeTransition(
          opacity: _titleOpacity,
          child: SlideTransition(
            position: _titleSlide,
            child: Text(
              'Law Briefly',
              style: AppTypography.displayMedium.copyWith(
                color: dark
                    ? AppColors.darkPrimaryText
                    : AppColors.lightPrimaryText,
                fontFamily: 'Georgia',
                fontWeight: FontWeight.w700,
                letterSpacing: -0.8,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  // ─────────────────────────────────────────────
  // MARK: — Module Cards
  // ─────────────────────────────────────────────

  Widget _buildModuleCards(bool dark) {
    final modules = _modules;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        children: List.generate(modules.length, (i) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: i < modules.length - 1 ? AppSpacing.md : 0,
              ),
              child: FadeTransition(
                opacity: _cardOpacities[i],
                child: SlideTransition(
                  position: _cardSlides[i],
                  child: _ModuleCard(
                    module: modules[i],
                    isDark: dark,
                    index: i,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // MARK: — Settings Row
  // ─────────────────────────────────────────────

  Widget _buildSettingsRow(bool dark) => FadeTransition(
    opacity: _settingsOpacity,
    child: SlideTransition(
      position: _settingsSlide,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.base,
          AppSpacing.xl,
          AppSpacing.xl,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left: subtle version hint
            Text(
              'Law Briefly',
              style: AppTypography.labelSmall.copyWith(
                color: dark
                    ? AppColors.darkTertiaryText
                    : AppColors.lightTertiaryText,
                fontFamily: 'Georgia',
                fontStyle: FontStyle.italic,
                letterSpacing: 0.2,
              ),
            ),

            // Right: Settings button
            _SettingsButton(
              isDark: dark,
              onTap: _navigateToSettings,
            ),
          ],
        ),
      ),
    ),
  );
}

// ─────────────────────────────────────────────
// MARK: — SECTION DIVIDER
// ─────────────────────────────────────────────

class _SectionDivider extends StatelessWidget {
  final bool isDark;
  const _SectionDivider({required this.isDark});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Container(
          height: 0.5,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                isDark
                    ? const Color(0x00545458)
                    : const Color(0x00C6C6C8),
                isDark
                    ? const Color(0x66545458)
                    : const Color(0x66C6C6C8),
                isDark
                    ? const Color(0x00545458)
                    : const Color(0x00C6C6C8),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

// ─────────────────────────────────────────────
// MARK: — MODULE CARD
// ─────────────────────────────────────────────

class _ModuleCard extends StatefulWidget {
  final HomeModule module;
  final bool isDark;
  final int index;

  const _ModuleCard({
    required this.module,
    required this.isDark,
    required this.index,
  });

  @override
  State<_ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<_ModuleCard>
    with SingleTickerProviderStateMixin {

  late AnimationController _pressController;
  late Animation<double> _scale;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
      reverseDuration: const Duration(milliseconds: 260),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.972).animate(
      CurvedAnimation(
        parent: _pressController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    _pressController.forward();
    setState(() => _isPressed = true);
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails _) {
    _pressController.reverse();
    setState(() => _isPressed = false);
    widget.module.onTap?.call();
  }

  void _onTapCancel() {
    _pressController.reverse();
    setState(() => _isPressed = false);
  }

  // ── Card index label (01, 02 …) ───────────────
  String get _indexLabel =>
      (widget.index + 1).toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final dark = widget.isDark;
    final module = widget.module;

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: SizedBox.expand(
          child: ClipRRect(
            borderRadius: AppRadius.card,
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: AppBlur.md,
                sigmaY: AppBlur.md,
                tileMode: TileMode.mirror,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                decoration: BoxDecoration(
                  color: _isPressed
                      ? (dark
                          ? const Color(0xBF252525)
                          : const Color(0xBFFAFAFA))
                      : (dark
                          ? const Color(0x991C1C1E)
                          : const Color(0xCCFFFFFF)),
                  borderRadius: AppRadius.card,
                  border: Border.all(
                    color: dark
                        ? const Color(0x1AFFFFFF)
                        : const Color(0x40FFFFFF),
                    width: 0.5,
                  ),
                  boxShadow: dark
                      ? AppShadows.darkGlass
                      : AppShadows.lightGlass,
                ),
                child: Stack(
                  children: [
                    // ── Accent gradient (right edge) ──
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      width: 100,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.transparent,
                              module.accentColor.withOpacity(
                                dark ? 0.07 : 0.045,
                              ),
                            ],
                          ),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(AppRadius.xxl),
                            bottomRight: Radius.circular(AppRadius.xxl),
                          ),
                        ),
                      ),
                    ),

                    // ── Top highlight line ─────────────
                    Positioned(
                      top: 0,
                      left: AppRadius.xxl,
                      right: AppRadius.xxl,
                      child: Container(
                        height: 0.5,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.white.withOpacity(dark ? 0.14 : 0.65),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ── Card index label ───────────────
                    Positioned(
                      top: AppSpacing.md,
                      right: AppSpacing.base,
                      child: Text(
                        _indexLabel,
                        style: AppTypography.labelSmall.copyWith(
                          color: module.accentColor.withOpacity(
                            dark ? 0.25 : 0.18,
                          ),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),

                    // ── Main content ───────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                        vertical: AppSpacing.base,
                      ),
                      child: Row(
                        children: [
                          // Icon badge
                          _ModuleIconBadge(
                            icon: module.icon,
                            accentColor: module.accentColor,
                            isDark: dark,
                          ),

                          const SizedBox(width: AppSpacing.base),

                          // Title + Subtitle
                          Expanded(
                            child: _ModuleCardText(
                              title: module.title,
                              subtitle: module.subtitle,
                              isDark: dark,
                            ),
                          ),

                          const SizedBox(width: AppSpacing.sm),

                          // Arrow
                          _ModuleArrow(
                            accentColor: module.accentColor,
                            isDark: dark,
                          ),
                        ],
                      ),
                    ),
                  ],
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
// MARK: — MODULE ICON BADGE
// ─────────────────────────────────────────────

class _ModuleIconBadge extends StatelessWidget {
  final IconData icon;
  final Color accentColor;
  final bool isDark;

  const _ModuleIconBadge({
    required this.icon,
    required this.accentColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: 52,
    height: 52,
    decoration: BoxDecoration(
      color: accentColor.withOpacity(isDark ? 0.14 : 0.10),
      borderRadius: BorderRadius.circular(AppRadius.md),
      border: Border.all(
        color: accentColor.withOpacity(isDark ? 0.22 : 0.18),
        width: 0.5,
      ),
    ),
    child: Icon(
      icon,
      size: 24,
      color: accentColor,
    ),
  );
}

// ─────────────────────────────────────────────
// MARK: — MODULE CARD TEXT
// ─────────────────────────────────────────────

class _ModuleCardText extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isDark;

  const _ModuleCardText({
    required this.title,
    required this.subtitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: [
      // Title
      Text(
        title,
        style: AppTypography.headlineSmall.copyWith(
          color: isDark
              ? AppColors.darkPrimaryText
              : AppColors.lightPrimaryText,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
          height: 1.2,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),

      const SizedBox(height: 5),

      // Subtitle
      Text(
        subtitle,
        style: AppTypography.bodySmall.copyWith(
          fontFamily: 'Georgia',
          color: isDark
              ? AppColors.darkSecondaryText
              : AppColors.lightSecondaryText,
          height: 1.45,
          fontSize: 12.5,
          fontWeight: FontWeight.w400,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    ],
  );
}

// ─────────────────────────────────────────────
// MARK: — MODULE ARROW
// ─────────────────────────────────────────────

class _ModuleArrow extends StatelessWidget {
  final Color accentColor;
  final bool isDark;

  const _ModuleArrow({
    required this.accentColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: 26,
    height: 26,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: accentColor.withOpacity(isDark ? 0.12 : 0.09),
    ),
    child: Icon(
      Icons.arrow_forward_ios_rounded,
      size: 11,
      color: accentColor.withOpacity(0.85),
    ),
  );
}

// ─────────────────────────────────────────────
// MARK: — SETTINGS BUTTON
// ─────────────────────────────────────────────

class _SettingsButton extends StatefulWidget {
  final bool isDark;
  final VoidCallback? onTap;

  const _SettingsButton({required this.isDark, this.onTap});

  @override
  State<_SettingsButton> createState() => _SettingsButtonState();
}

class _SettingsButtonState extends State<_SettingsButton>
    with SingleTickerProviderStateMixin {

  late AnimationController _pressController;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
      reverseDuration: const Duration(milliseconds: 240),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(
        parent: _pressController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ScaleTransition(
    scale: _scale,
    child: GestureDetector(
      onTapDown: (_) => _pressController.forward(),
      onTapUp: (_) {
        _pressController.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _pressController.reverse(),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppBlur.md,
            sigmaY: AppBlur.md,
          ),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.isDark
                  ? const Color(0x661E1E1E)
                  : const Color(0x80FFFFFF),
              border: Border.all(
                color: widget.isDark
                    ? const Color(0x26FFFFFF)
                    : const Color(0x26000000),
                width: 0.5,
              ),
              boxShadow: widget.isDark
                  ? AppShadows.darkSm
                  : AppShadows.lightSm,
            ),
            child: Icon(
              Icons.settings_outlined,
              size: 19,
              color: widget.isDark
                  ? AppColors.darkSecondaryText
                  : AppColors.lightSecondaryText,
            ),
          ),
        ),
      ),
    ),
  );
}

// ─────────────────────────────────────────────
// MARK: — HOME BACKGROUND
// ─────────────────────────────────────────────

class _HomeBackground extends StatelessWidget {
  final bool isDark;
  const _HomeBackground({required this.isDark});

  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: Stack(
      children: [
        // Base gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF0D1018),
                      const Color(0xFF121212),
                      const Color(0xFF0C0F1A),
                    ]
                  : [
                      const Color(0xFFF5F6FF),
                      const Color(0xFFFFFFFF),
                      const Color(0xFFF0F2FF),
                    ],
            ),
          ),
        ),

        // Top-left ambient orb — Blue
        Positioned(
          top: -120,
          left: -90,
          child: _AmbientOrb(
            size: 380,
            color: isDark
                ? AppColors.accent.withOpacity(0.10)
                : AppColors.accent.withOpacity(0.055),
          ),
        ),

        // Bottom-right ambient orb — Purple
        Positioned(
          bottom: -130,
          right: -70,
          child: _AmbientOrb(
            size: 340,
            color: isDark
                ? const Color(0xFF7C3AED).withOpacity(0.07)
                : const Color(0xFF7C3AED).withOpacity(0.035),
          ),
        ),

        // Center ambient orb — Gold
        Positioned(
          top: MediaQuery.of(context).size.height * 0.42,
          left: -60,
          child: _AmbientOrb(
            size: 200,
            color: isDark
                ? AppColors.gold.withOpacity(0.05)
                : AppColors.gold.withOpacity(0.03),
          ),
        ),
      ],
    ),
  );
}

class _AmbientOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _AmbientOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, Colors.transparent],
          stops: const [0.0, 1.0],
        ),
      ),
    ),
  );
}