import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';

class AboutLawBrieflyScreen extends StatefulWidget {
  const AboutLawBrieflyScreen({super.key});

  @override
  State<AboutLawBrieflyScreen> createState() => _AboutLawBrieflyScreenState();
}

class _AboutLawBrieflyScreenState extends State<AboutLawBrieflyScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _entranceCtrl;
  late Animation<double>   _appBarFade;
  late Animation<double>   _heroFade;
  late Animation<Offset>   _heroSlide;
  late Animation<double>   _contentFade;
  late Animation<Offset>   _contentSlide;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 900));

    _appBarFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceCtrl,
          curve: const Interval(0.0, 0.4, curve: Curves.easeOut)));
    _heroFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceCtrl,
          curve: const Interval(0.10, 0.55, curve: Curves.easeOut)));
    _heroSlide = Tween<Offset>(begin: const Offset(0, -0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entranceCtrl,
          curve: const Interval(0.10, 0.60, curve: Curves.easeOutCubic)));
    _contentFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceCtrl,
          curve: const Interval(0.30, 0.80, curve: Curves.easeOut)));
    _contentSlide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entranceCtrl,
          curve: const Interval(0.30, 0.85, curve: Curves.easeOutCubic)));

    Future.delayed(const Duration(milliseconds: 60), () {
      if (mounted) _entranceCtrl.forward();
    });
  }

  @override
  void dispose() { _entranceCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final dark    = Theme.of(context).brightness == Brightness.dark;
    final topPad  = MediaQuery.of(context).padding.top;
    final botPad  = MediaQuery.of(context).padding.bottom;

    SystemChrome.setSystemUIOverlayStyle(
      dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: dark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: GlassAppBar(
        titleWidget: FadeTransition(
          opacity: _appBarFade,
          child: Text('About Law Briefly',
            style: AppTypography.titleMedium.copyWith(
              color: dark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
              fontWeight: FontWeight.w700,
            )),
        ),
        leading: FadeTransition(
          opacity: _appBarFade,
          child: _BackButton(isDark: dark),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          _AboutBackground(isDark: dark),
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              AppSpacing.xl,
              topPad + kToolbarHeight + AppSpacing.xl,
              AppSpacing.xl,
              botPad + AppSpacing.xxxl,
            ),
            child: Column(
              children: [
                // ── Hero ─────────────────────────────
                FadeTransition(
                  opacity: _heroFade,
                  child: SlideTransition(
                    position: _heroSlide,
                    child: _HeroSection(isDark: dark),
                  ),
                ),

                const SizedBox(height: AppSpacing.xxxl),

                // ── Content cards ─────────────────────
                FadeTransition(
                  opacity: _contentFade,
                  child: SlideTransition(
                    position: _contentSlide,
                    child: Column(
                      children: [
                        _AboutCard(
                          title:   'Our Mission',
                          icon:    Icons.flag_outlined,
                          isDark:  dark,
                          accent:  dark ? AppColors.accentLight : AppColors.accent,
                          content: 'Law Briefly exists to make legal education accessible to every law student in India. '
                              'We believe that understanding the law should not be limited by the lack of affordable, high-quality resources. '
                              'Our offline-first platform ensures you can study the Constitution, Acts, and Case Laws wherever you are — '
                              'no internet required.',
                        ),

                        const SizedBox(height: AppSpacing.base),

                        _AboutCard(
                          title:   'Our Vision',
                          icon:    Icons.visibility_outlined,
                          isDark:  dark,
                          accent:  AppColors.gold,
                          content: 'We envision a future where every BALLB student in India has a premium legal companion in their pocket. '
                              'A platform that grows with them from first year to bar exams — enriched with AI-powered search, '
                              'personalised notes, smart case law indexing, and a community-driven content marketplace.',
                        ),

                        const SizedBox(height: AppSpacing.base),

                        _FeatureGrid(isDark: dark),

                        const SizedBox(height: AppSpacing.base),

                        _AboutCard(
                          title:   'Developer',
                          icon:    Icons.code_rounded,
                          isDark:  dark,
                          accent:  const Color(0xFF059669),
                          content: 'Law Briefly is an independent project built by a Flutter developer passionate about legal education and offline-first technology. '
                              'Designed with love for law students across India.\n\n'
                              'Built with Flutter · Dart · Isar · Riverpod',
                        ),

                        const SizedBox(height: AppSpacing.base),

                        _RoadmapCard(isDark: dark),

                        const SizedBox(height: AppSpacing.xxxl),

                        _Footer(isDark: dark),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MARK: — HERO SECTION
// ─────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  final bool isDark;
  const _HeroSection({required this.isDark});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          // App icon
          Container(
            width: 84, height: 84,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end:   Alignment.bottomRight,
                colors: [Color(0xFF1C4ED8), Color(0xFF7C3AED)],
              ),
              boxShadow: [
                BoxShadow(
                  color:      const Color(0xFF1C4ED8).withOpacity(0.40),
                  blurRadius: 24, offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.balance_rounded, color: Colors.white, size: 44),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          Text('Law Briefly',
            style: const TextStyle(
              fontFamily:    'Georgia',
              fontSize:      30,
              fontWeight:    FontWeight.w800,
              letterSpacing: -0.5,
              height:        1.2,
            ).merge(TextStyle(
              color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
            ))),

          const SizedBox(height: AppSpacing.sm),

          Text('Offline-First Legal Reading Platform',
            style: AppTypography.bodySmall.copyWith(
              fontFamily: 'Georgia',
              fontStyle:  FontStyle.italic,
              color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.base),

          // Version badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color:        const Color(0xFF1C4ED8).withOpacity(isDark ? 0.14 : 0.08),
              borderRadius: AppRadius.pillAll,
              border:       Border.all(
                  color: const Color(0xFF1C4ED8).withOpacity(0.25), width: 0.5),
            ),
            child: Text('Version 1.0.0',
              style: AppTypography.labelSmall.copyWith(
                color:      isDark ? AppColors.accentLight : AppColors.accent,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              )),
          ),
        ],
      );
}

// ─────────────────────────────────────────────
// MARK: — ABOUT CARD
// ─────────────────────────────────────────────

class _AboutCard extends StatelessWidget {
  final String   title;
  final IconData icon;
  final bool     isDark;
  final Color    accent;
  final String   content;

  const _AboutCard({
    required this.title,
    required this.icon,
    required this.isDark,
    required this.accent,
    required this.content,
  });

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: AppRadius.card,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: AppBlur.md, sigmaY: AppBlur.md),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? AppColors.glassDarkTint : AppColors.glassLightTint,
              borderRadius: AppRadius.card,
              border: Border.all(
                color: isDark ? AppColors.glassDarkBorder : AppColors.glassLightBorder,
                width: 0.5,
              ),
              boxShadow: isDark ? AppShadows.darkGlass : AppShadows.lightGlass,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header strip
                Container(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.base, AppSpacing.base, AppSpacing.base, AppSpacing.sm),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isDark ? AppColors.darkSeparator : AppColors.lightSeparator,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color:        accent.withOpacity(isDark ? 0.14 : 0.09),
                          borderRadius: AppRadius.smAll,
                          border: Border.all(
                              color: accent.withOpacity(0.22), width: 0.5),
                        ),
                        child: Icon(icon, size: 17, color: accent),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text(title,
                        style: AppTypography.titleSmall.copyWith(
                          color:      isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                          fontWeight: FontWeight.w700,
                        )),
                    ],
                  ),
                ),

                // Body
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.base),
                  child: Text(content,
                    style: const TextStyle(
                      fontFamily:    'Georgia',
                      fontSize:      14.5,
                      height:        1.72,
                      letterSpacing: 0.06,
                    ).merge(TextStyle(
                      color: (isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText)
                          .withOpacity(0.88),
                    ))),
                ),
              ],
            ),
          ),
        ),
      );
}

// ─────────────────────────────────────────────
// MARK: — FEATURE GRID
// ─────────────────────────────────────────────

class _FeatureGrid extends StatelessWidget {
  final bool isDark;
  const _FeatureGrid({required this.isDark});

  static const features = [
    (Icons.download_done_rounded,    'Fully Offline',     '100% offline\nno internet needed'),
    (Icons.menu_book_outlined,       '22+ Parts',         'Constitution\nfully indexed'),
    (Icons.balance_rounded,          'Acts & Laws',       'Multiple acts\nwith sections'),
    (Icons.bookmark_border_rounded,  'Smart Bookmarks',   'Save sections\n& articles'),
    (Icons.edit_note_rounded,        'Personal Notes',    'Write & organise\nyour notes'),
    (Icons.search_rounded,           'Fast Search',       'Find acts\ninstantly'),
  ];

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: AppRadius.card,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: AppBlur.md, sigmaY: AppBlur.md),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.glassDarkTint : AppColors.glassLightTint,
              borderRadius: AppRadius.card,
              border: Border.all(
                color: isDark ? AppColors.glassDarkBorder : AppColors.glassLightBorder,
                width: 0.5,
              ),
              boxShadow: isDark ? AppShadows.darkGlass : AppShadows.lightGlass,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.base, AppSpacing.base, AppSpacing.base, AppSpacing.sm),
                  child: Row(children: [
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.gold.withOpacity(isDark ? 0.14 : 0.09),
                        borderRadius: AppRadius.smAll,
                        border: Border.all(color: AppColors.gold.withOpacity(0.22), width: 0.5),
                      ),
                      child: const Icon(Icons.star_outline_rounded, size: 17, color: AppColors.gold),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text('Key Features', style: AppTypography.titleSmall.copyWith(
                      color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                      fontWeight: FontWeight.w700,
                    )),
                  ]),
                ),
                Divider(height: 0.5, thickness: 0.5,
                    color: isDark ? AppColors.darkSeparator : AppColors.lightSeparator),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.base),
                  child: GridView.count(
                    crossAxisCount:    3,
                    shrinkWrap:        true,
                    physics:           const NeverScrollableScrollPhysics(),
                    crossAxisSpacing:  AppSpacing.sm,
                    mainAxisSpacing:   AppSpacing.sm,
                    childAspectRatio:  1.0,
                    children: features.map((f) => _FeatureCell(
                      icon:    f.$1,
                      title:   f.$2,
                      desc:    f.$3,
                      isDark:  isDark,
                    )).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _FeatureCell extends StatelessWidget {
  final IconData icon; final String title, desc; final bool isDark;
  const _FeatureCell({required this.icon, required this.title,
      required this.desc, required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: isDark ? const Color(0x0DFFFFFF) : const Color(0x06000000),
          borderRadius: AppRadius.mdAll,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22,
                color: isDark ? AppColors.accentLight : AppColors.accent),
            const SizedBox(height: 5),
            Text(title, style: AppTypography.labelSmall.copyWith(
              color:      isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
              fontWeight: FontWeight.w700, fontSize: 10.5,
            ), textAlign: TextAlign.center, maxLines: 1),
            Text(desc, style: AppTypography.caption.copyWith(
              color:    isDark ? AppColors.darkTertiaryText : AppColors.lightTertiaryText,
              fontSize: 9,
            ), textAlign: TextAlign.center, maxLines: 2),
          ],
        ),
      );
}

// ─────────────────────────────────────────────
// MARK: — ROADMAP CARD
// ─────────────────────────────────────────────

class _RoadmapCard extends StatelessWidget {
  final bool isDark;
  const _RoadmapCard({required this.isDark});

  static const roadmap = [
    ('AI-Powered Legal Search',           '🔜'),
    ('Full Constitution (All 22+ Parts)', '🔜'),
    ('50+ Acts & Codes',                  '🔜'),
    ('Moot Court AI Practice',            '🔮'),
    ('Peer Notes Marketplace',            '🔮'),
    ('Bar Exam Preparation Module',       '🔮'),
  ];

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: AppRadius.card,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: AppBlur.md, sigmaY: AppBlur.md),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.glassDarkTint : AppColors.glassLightTint,
              borderRadius: AppRadius.card,
              border: Border.all(
                color: isDark ? AppColors.glassDarkBorder : AppColors.glassLightBorder,
                width: 0.5,
              ),
              boxShadow: isDark ? AppShadows.darkGlass : AppShadows.lightGlass,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.base, AppSpacing.base, AppSpacing.base, AppSpacing.sm),
                  child: Row(children: [
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE11D48).withOpacity(isDark ? 0.14 : 0.09),
                        borderRadius: AppRadius.smAll,
                      ),
                      child: const Icon(Icons.rocket_launch_outlined, size: 17,
                          color: Color(0xFFE11D48)),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text('Future Roadmap', style: AppTypography.titleSmall.copyWith(
                      color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                      fontWeight: FontWeight.w700,
                    )),
                  ]),
                ),
                Divider(height: 0.5, thickness: 0.5,
                    color: isDark ? AppColors.darkSeparator : AppColors.lightSeparator),
                ...roadmap.map((item) => Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.base, AppSpacing.md, AppSpacing.base, 0),
                  child: Row(children: [
                    Text(item.$2, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(item.$1, style: AppTypography.bodySmall.copyWith(
                        fontFamily: null,
                        color: (isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText)
                            .withOpacity(0.75),
                      )),
                    ),
                  ]),
                )),
                const SizedBox(height: AppSpacing.base),
              ],
            ),
          ),
        ),
      );
}

// ─────────────────────────────────────────────
// MARK: — FOOTER
// ─────────────────────────────────────────────

class _Footer extends StatelessWidget {
  final bool isDark;
  const _Footer({required this.isDark});

  @override
  Widget build(BuildContext context) => Column(children: [
        Container(
          width: 36, height: 0.5,
          color: isDark ? AppColors.darkSeparator : AppColors.lightSeparator,
        ),
        const SizedBox(height: AppSpacing.base),
        Text('© 2024 Law Briefly. Made for law students.',
          style: AppTypography.caption.copyWith(
            color:    isDark ? AppColors.darkTertiaryText : AppColors.lightTertiaryText,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text('Offline · Private · India',
          style: AppTypography.caption.copyWith(
            color:    isDark ? AppColors.darkTertiaryText : AppColors.lightTertiaryText,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      ]);
}

// ─────────────────────────────────────────────
// MARK: — BACK BUTTON
// ─────────────────────────────────────────────

class _BackButton extends StatefulWidget {
  final bool isDark;
  const _BackButton({required this.isDark});
  @override State<_BackButton> createState() => _BackButtonState();
}
class _BackButtonState extends State<_BackButton>
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
      onTapUp:     (_) { _p.reverse(); HapticFeedback.lightImpact(); Navigator.of(context).maybePop(); },
      onTapCancel: () => _p.reverse(),
      child: Container(
        width: 34, height: 34,
        margin: const EdgeInsets.only(left: AppSpacing.sm),
        decoration: BoxDecoration(shape: BoxShape.circle,
          color: widget.isDark ? const Color(0x33FFFFFF) : const Color(0x1A000000)),
        child: Icon(Icons.arrow_back_ios_rounded, size: 15,
          color: widget.isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText))));
}

class _AboutBackground extends StatelessWidget {
  final bool isDark;
  const _AboutBackground({required this.isDark});
  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF0D1117), const Color(0xFF121212), const Color(0xFF0C0D14)]
                : [const Color(0xFFF8F5FF), const Color(0xFFFFFFFF), const Color(0xFFF0F8FF)],
          ),
        ),
        child: Stack(children: [
          Positioned(top: -90, right: -60,
            child: Container(width: 260, height: 260,
              decoration: BoxDecoration(shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  const Color(0xFF1C4ED8).withOpacity(isDark ? 0.07 : 0.04),
                  Colors.transparent])))),
          Positioned(bottom: -80, left: -40,
            child: Container(width: 220, height: 220,
              decoration: BoxDecoration(shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.gold.withOpacity(isDark ? 0.06 : 0.04),
                  Colors.transparent])))),
        ]),
      );
}