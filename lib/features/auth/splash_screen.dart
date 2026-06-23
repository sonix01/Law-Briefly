// lib/features/auth/splash_screen.dart
// Law Briefly — Splash Screen
// iOS 18 Liquid Glass | Session Check | Auto-Navigate

import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/router/navigation_registry.dart';
import '../auth/services/session_service.dart';

// ─────────────────────────────────────────────
// MARK: — SPLASH SCREEN
// ─────────────────────────────────────────────

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  // ── Animation controller ──────────────────────
  late AnimationController _ctrl;

  // ── Animations ────────────────────────────────
  late Animation<double>  _bgFade;
  late Animation<double>  _orbFade;
  late Animation<double>  _logoScale;
  late Animation<double>  _logoFade;
  late Animation<double>  _glowOpacity;
  late Animation<double>  _nameFade;
  late Animation<Offset>  _nameSlide;
  late Animation<double>  _taglineFade;
  late Animation<Offset>  _taglineSlide;
  late Animation<double>  _exitFade;

  // ── State ─────────────────────────────────────
  bool _navigating = false;

  // ─────────────────────────────────────────────
  // MARK: — LIFECYCLE
  // ─────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startSequence();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // MARK: — ANIMATION SETUP
  // ─────────────────────────────────────────────

  void _setupAnimations() {
    _ctrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 2400),
    );

    // Background
    _bgFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl,
          curve: const Interval(0.00, 0.25, curve: Curves.easeOut)));

    _orbFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl,
          curve: const Interval(0.05, 0.40, curve: Curves.easeOut)));

    // Logo
    _logoScale = Tween<double>(begin: 0.42, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl,
          curve: const Interval(0.08, 0.52, curve: _SpringCurve())));

    _logoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl,
          curve: const Interval(0.08, 0.36, curve: Curves.easeOut)));

    _glowOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl,
          curve: const Interval(0.28, 0.58, curve: Curves.easeOut)));

    // App name
    _nameFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl,
          curve: const Interval(0.38, 0.62, curve: Curves.easeOut)));

    _nameSlide = Tween<Offset>(
        begin: const Offset(0, 0.18), end: Offset.zero).animate(
      CurvedAnimation(parent: _ctrl,
          curve: const Interval(0.38, 0.62, curve: Curves.easeOutCubic)));

    // Tagline
    _taglineFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl,
          curve: const Interval(0.55, 0.80, curve: Curves.easeOut)));

    _taglineSlide = Tween<Offset>(
        begin: const Offset(0, 0.14), end: Offset.zero).animate(
      CurvedAnimation(parent: _ctrl,
          curve: const Interval(0.55, 0.80, curve: Curves.easeOutCubic)));

    // Exit
    _exitFade = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _ctrl,
          curve: const Interval(0.88, 1.0, curve: Curves.easeIn)));
  }

  // ─────────────────────────────────────────────
  // MARK: — SEQUENCE
  // ─────────────────────────────────────────────

  void _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 80));
    if (!mounted) return;

    _ctrl.forward();

    // Wait for entrance to complete before checking session
    await Future.delayed(const Duration(milliseconds: 2100));
    if (!mounted) return;

    await _checkSessionAndNavigate();
  }

  Future<void> _checkSessionAndNavigate() async {
    if (!mounted || _navigating) return;
    _navigating = true;

    try {
      final session = await SessionService().getSession();
      if (!mounted) return;

      await Future.delayed(const Duration(milliseconds: 150));
      if (!mounted) return;

      if (session != null && session.isActive) {
        context.go(NavigationRegistry.homePath);
      } else {
        context.go(NavigationRegistry.loginPath);
      }
    } catch (e) {
      debugPrint('[SplashScreen] Session check error: $e');
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 100));
        context.go(NavigationRegistry.loginPath);
      }
    }
  }

  // ─────────────────────────────────────────────
  // MARK: — BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(
      dark
          ? const SystemUiOverlayStyle(
              statusBarColor:                    Colors.transparent,
              statusBarIconBrightness:           Brightness.light,
              systemNavigationBarColor:          Colors.transparent,
              systemNavigationBarIconBrightness: Brightness.light,
            )
          : const SystemUiOverlayStyle(
              statusBarColor:                    Colors.transparent,
              statusBarIconBrightness:           Brightness.dark,
              systemNavigationBarColor:          Colors.transparent,
              systemNavigationBarIconBrightness: Brightness.dark,
            ),
    );

    return Scaffold(
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return FadeTransition(
            opacity: _exitFade,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // ── Background ────────────────────
                FadeTransition(
                  opacity: _bgFade,
                  child:   _SplashBackground(isDark: dark),
                ),

                // ── Decorative orbs ───────────────
                FadeTransition(
                  opacity: _orbFade,
                  child:   _DecorativeOrbs(isDark: dark),
                ),

                // ── Content ───────────────────────
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      ScaleTransition(
                        scale: _logoScale,
                        child: FadeTransition(
                          opacity: _logoFade,
                          child:   _AnimatedLogo(
                            isDark:       dark,
                            glowOpacity:  _glowOpacity,
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xxl),

                      // App name
                      FadeTransition(
                        opacity: _nameFade,
                        child: SlideTransition(
                          position: _nameSlide,
                          child:    _AppName(isDark: dark),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      // Tagline
                      FadeTransition(
                        opacity: _taglineFade,
                        child: SlideTransition(
                          position: _taglineSlide,
                          child:    _Tagline(isDark: dark),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Bottom branding ───────────────
                FadeTransition(
                  opacity: _taglineFade,
                  child: Positioned(
                    bottom: MediaQuery.of(context).padding.bottom + AppSpacing.xl,
                    left: 0, right: 0,
                    child: _BottomBranding(isDark: dark),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ═════════════════════════════════════════════
// MARK: — ANIMATED LOGO
// ═════════════════════════════════════════════

class _AnimatedLogo extends StatelessWidget {
  final bool             isDark;
  final Animation<double> glowOpacity;

  const _AnimatedLogo({required this.isDark, required this.glowOpacity});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: glowOpacity,
        builder: (_, __) => Container(
          width:  100, height: 100,
          decoration: BoxDecoration(
            shape:     BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color:      AppColors.accent.withOpacity(0.38 * glowOpacity.value),
                blurRadius: 48,
                spreadRadius: 6,
              ),
              BoxShadow(
                color:      AppColors.accentLight.withOpacity(0.22 * glowOpacity.value),
                blurRadius: 24,
              ),
            ],
          ),
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: AppBlur.md, sigmaY: AppBlur.md),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end:   Alignment.bottomRight,
                    colors: [
                      AppColors.accent.withOpacity(isDark ? 0.80 : 0.90),
                      const Color(0xFF7C3AED).withOpacity(isDark ? 0.75 : 0.85),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(isDark ? 0.18 : 0.30),
                    width: 0.75,
                  ),
                ),
                child: Stack(children: [
                  // Inner glow
                  Center(
                    child: Container(
                      width: 60, height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.06),
                      ),
                    ),
                  ),
                  // Icon
                  const Center(
                    child: Icon(
                      Icons.balance_rounded,
                      size:  48,
                      color: Colors.white,
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      );
}

// ═════════════════════════════════════════════
// MARK: — APP NAME
// ═════════════════════════════════════════════

class _AppName extends StatelessWidget {
  final bool isDark;
  const _AppName({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textColor = isDark
        ? AppColors.darkPrimaryText
        : AppColors.lightPrimaryText;

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text:  'Law ',
            style: TextStyle(
              fontFamily:    'Georgia',
              fontSize:      38,
              fontWeight:    FontWeight.w700,
              height:        1.0,
              letterSpacing: -0.8,
              color:         textColor,
            ),
          ),
          TextSpan(
            text:  'Briefly',
            style: TextStyle(
              fontFamily:    'Georgia',
              fontSize:      38,
              fontWeight:    FontWeight.w300,
              height:        1.0,
              letterSpacing: -0.8,
              color: isDark ? AppColors.accentLight : AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════
// MARK: — TAGLINE
// ═════════════════════════════════════════════

class _Tagline extends StatelessWidget {
  final bool isDark;
  const _Tagline({required this.isDark});

  @override
  Widget build(BuildContext context) => Text(
        'Read Law. Briefly.',
        style: TextStyle(
          fontFamily:    'Georgia',
          fontSize:      15.5,
          fontStyle:     FontStyle.italic,
          fontWeight:    FontWeight.w400,
          height:        1.4,
          letterSpacing: 0.3,
          color: isDark
              ? AppColors.darkSecondaryText
              : AppColors.lightSecondaryText,
        ),
      );
}

// ═════════════════════════════════════════════
// MARK: — BOTTOM BRANDING
// ═════════════════════════════════════════════

class _BottomBranding extends StatelessWidget {
  final bool isDark;
  const _BottomBranding({required this.isDark});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          // Loading indicator
          SizedBox(
            width: 24, height: 24,
            child: CircularProgressIndicator(
              strokeWidth:    1.5,
              color:          (isDark ? AppColors.accentLight : AppColors.accent)
                  .withOpacity(0.50),
              backgroundColor: (isDark ? AppColors.accentLight : AppColors.accent)
                  .withOpacity(0.12),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          Text(
            'Offline · Private · India',
            style: AppTypography.caption.copyWith(
              color: (isDark
                  ? AppColors.darkTertiaryText
                  : AppColors.lightTertiaryText)
                  .withOpacity(0.60),
              letterSpacing: 1.0,
              fontSize: 10,
            ),
          ),
        ],
      );
}

// ═════════════════════════════════════════════
// MARK: — SPLASH BACKGROUND
// ═════════════════════════════════════════════

class _SplashBackground extends StatelessWidget {
  final bool isDark;
  const _SplashBackground({required this.isDark});

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin:  Alignment.topLeft,
                  end:    Alignment.bottomRight,
                  stops:  [0.0, 0.45, 0.80, 1.0],
                  colors: [
                    Color(0xFF080C14),
                    Color(0xFF0D1117),
                    Color(0xFF0F1218),
                    Color(0xFF080C14),
                  ],
                )
              : const LinearGradient(
                  begin:  Alignment.topCenter,
                  end:    Alignment.bottomCenter,
                  stops:  [0.0, 0.50, 1.0],
                  colors: [
                    Color(0xFFF8F5FF),
                    Color(0xFFFFFFFF),
                    Color(0xFFF0F8FF),
                  ],
                ),
        ),
      );
}

// ═════════════════════════════════════════════
// MARK: — DECORATIVE ORBS
// ═════════════════════════════════════════════

class _DecorativeOrbs extends StatelessWidget {
  final bool isDark;
  const _DecorativeOrbs({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Top-right orb (accent blue)
        Positioned(
          top:   -size.width * 0.25,
          right: -size.width * 0.20,
          child: Container(
            width: size.width * 0.75,
            height: size.width * 0.75,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.accent.withOpacity(isDark ? 0.18 : 0.10),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Bottom-left orb (purple/violet)
        Positioned(
          bottom: -size.width * 0.30,
          left:   -size.width * 0.18,
          child: Container(
            width: size.width * 0.80,
            height: size.width * 0.80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF7C3AED).withOpacity(isDark ? 0.14 : 0.07),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Center ambient glow
        Center(
          child: Container(
            width: size.width * 0.60,
            height: size.width * 0.60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.accent.withOpacity(isDark ? 0.05 : 0.03),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Gold accent — bottom-right small orb
        Positioned(
          bottom: size.height * 0.18,
          right:  size.width  * 0.08,
          child: Container(
            width: size.width * 0.40,
            height: size.width * 0.40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.gold.withOpacity(isDark ? 0.08 : 0.04),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════
// MARK: — SPRING CURVE (Custom elastic animation)
// ═════════════════════════════════════════════

class _SpringCurve extends Curve {
  const _SpringCurve();

  @override
  double transformInternal(double t) {
    const damping   = 0.65;
    const frequency = 4.2;
    return 1 -
        (math.pow(math.e, -damping * frequency * t) as double) *
            math.cos(frequency * math.sqrt(1 - damping * damping) * t * math.pi);
  }
}