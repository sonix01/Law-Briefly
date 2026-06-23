// lib/features/auth/login/login_screen.dart
// Law Briefly — Login Screen (Updated: Session + Navigation)
// iOS 18 Liquid Glass | Premium Auth UI | Production-Ready

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/router/navigation_registry.dart';
import '../models/user_session.dart';
import '../services/session_service.dart';

// ─────────────────────────────────────────────
// MARK: — LOGIN SCREEN
// ─────────────────────────────────────────────

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {

  // ── Controllers ───────────────────────────────
  final TextEditingController _emailController    = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocus    = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  // ── State ─────────────────────────────────────
  bool _obscurePassword   = true;
  bool _isLoading         = false;
  bool _isGuestLoading    = false;
  bool _emailHasFocus     = false;
  bool _passwordHasFocus  = false;
  String? _errorMessage;

  // ── Entrance Animations ───────────────────────
  late AnimationController _entranceController;
  late AnimationController _bgController;

  late Animation<double>  _logoOpacity;
  late Animation<Offset>  _logoSlide;
  late Animation<double>  _titleOpacity;
  late Animation<Offset>  _titleSlide;
  late Animation<double>  _subtitleOpacity;
  late Animation<double>  _cardOpacity;
  late Animation<Offset>  _cardSlide;
  late Animation<double>  _buttonsOpacity;
  late Animation<Offset>  _buttonsSlide;
  late Animation<double>  _bgScale;

  // ─────────────────────────────────────────────
  // MARK: — LIFECYCLE
  // ─────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupFocusListeners();
    _startEntrance();
  }

  void _setupAnimations() {
    _entranceController = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 1200),
    );
    _bgController = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 8000),
    )..repeat(reverse: true);

    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceController,
          curve: const Interval(0.0, 0.4, curve: Curves.easeOut)));
    _logoSlide = Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entranceController,
          curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic)));

    _titleOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceController,
          curve: const Interval(0.15, 0.5, curve: Curves.easeOut)));
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entranceController,
          curve: const Interval(0.15, 0.55, curve: Curves.easeOutCubic)));

    _subtitleOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceController,
          curve: const Interval(0.25, 0.55, curve: Curves.easeOut)));

    _cardOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceController,
          curve: const Interval(0.35, 0.7, curve: Curves.easeOut)));
    _cardSlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entranceController,
          curve: const Interval(0.35, 0.75, curve: Curves.easeOutCubic)));

    _buttonsOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceController,
          curve: const Interval(0.55, 0.9, curve: Curves.easeOut)));
    _buttonsSlide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entranceController,
          curve: const Interval(0.55, 0.95, curve: Curves.easeOutCubic)));

    _bgScale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _bgController, curve: Curves.easeInOut));
  }

  void _setupFocusListeners() {
    _emailFocus.addListener(() =>
        setState(() => _emailHasFocus = _emailFocus.hasFocus));
    _passwordFocus.addListener(() =>
        setState(() => _passwordHasFocus = _passwordFocus.hasFocus));
  }

  void _startEntrance() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _bgController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // MARK: — ACTIONS
  // ─────────────────────────────────────────────

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email.');
      return;
    }

    HapticFeedback.lightImpact();
    FocusScope.of(context).unfocus();
    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      // Create a logged-in session (mock auth — swap with real API later)
      final session = UserSession.loggedIn(
        userId:   'user_${email.hashCode.abs()}',
        email:    email,
        fullName: null,
      );

      // Persist session
      await SessionService().saveSession(session);

      if (!mounted) return;

      // Navigate to home
      context.go(NavigationRegistry.homePath);
    } catch (e) {
      debugPrint('[LoginScreen] Login error: $e');
      if (!mounted) return;
      setState(() {
        _isLoading    = false;
        _errorMessage = 'Sign-in failed. Please try again.';
      });
    }
  }

  Future<void> _handleGuest() async {
    HapticFeedback.lightImpact();
    setState(() { _isGuestLoading = true; _errorMessage = null; });

    try {
      // Create and persist guest session
      await SessionService().saveGuestSession();

      if (!mounted) return;

      // Navigate to home
      context.go(NavigationRegistry.homePath);
    } catch (e) {
      debugPrint('[LoginScreen] Guest login error: $e');
      if (!mounted) return;
      setState(() {
        _isGuestLoading = false;
        _errorMessage   = 'Could not start guest session.';
      });
    }
  }

  void _handleRegister() {
    HapticFeedback.lightImpact();
    // Future: context.go(NavigationRegistry.registerPath)
    // For now, show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Registration coming soon.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ─────────────────────────────────────────────
  // MARK: — BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final dark    = Theme.of(context).brightness == Brightness.dark;
    final size    = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    SystemChrome.setSystemUIOverlayStyle(
        dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark);

    return Scaffold(
      backgroundColor: dark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            // ── Animated Background ───────────────
            _AnimatedBackground(isDark: dark, scaleAnimation: _bgScale),

            // ── Main Content ──────────────────────
            SafeArea(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base)
                    .copyWith(bottom: AppSpacing.xxl),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: size.height - padding.top - padding.bottom,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: size.height * 0.07),

                      // Logo
                      _buildLogo(dark),
                      const SizedBox(height: AppSpacing.xl),

                      // Title
                      _buildTitle(dark),
                      const SizedBox(height: AppSpacing.sm),

                      // Subtitle
                      _buildSubtitle(dark),
                      const SizedBox(height: AppSpacing.xxxl),

                      // Auth Card
                      _buildAuthCard(dark),
                      const SizedBox(height: AppSpacing.sm),

                      // Error message
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
                          child: Row(children: [
                            const Icon(Icons.error_outline_rounded,
                                size: 14, color: AppColors.error),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Text(_errorMessage!,
                                style: AppTypography.caption.copyWith(
                                    color: AppColors.error)),
                            ),
                          ]),
                        ),

                      const SizedBox(height: AppSpacing.xl),

                      // Bottom Buttons
                      _buildBottomButtons(dark),

                      SizedBox(height: size.height * 0.04),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // MARK: — LOGO
  // ─────────────────────────────────────────────

  Widget _buildLogo(bool dark) => FadeTransition(
        opacity: _logoOpacity,
        child: SlideTransition(
          position: _logoSlide,
          child: Center(child: _GlassLogoMark(isDark: dark)),
        ),
      );

  // ─────────────────────────────────────────────
  // MARK: — TITLE
  // ─────────────────────────────────────────────

  Widget _buildTitle(bool dark) => FadeTransition(
        opacity: _titleOpacity,
        child: SlideTransition(
          position: _titleSlide,
          child: Center(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(children: [
                TextSpan(
                  text: 'Law ',
                  style: TextStyle(
                    fontFamily:    'Georgia',
                    fontSize:      34,
                    fontWeight:    FontWeight.w700,
                    letterSpacing: -0.6,
                    color: dark
                        ? AppColors.darkPrimaryText
                        : AppColors.lightPrimaryText,
                  ),
                ),
                TextSpan(
                  text: 'Briefly',
                  style: TextStyle(
                    fontFamily:    'Georgia',
                    fontSize:      34,
                    fontWeight:    FontWeight.w300,
                    letterSpacing: -0.6,
                    color: dark ? AppColors.accentLight : AppColors.accent,
                  ),
                ),
              ]),
            ),
          ),
        ),
      );

  // ─────────────────────────────────────────────
  // MARK: — SUBTITLE
  // ─────────────────────────────────────────────

  Widget _buildSubtitle(bool dark) => FadeTransition(
        opacity: _subtitleOpacity,
        child: Center(
          child: Text(
            'Read Law. Briefly.',
            style: AppTypography.bodyMedium.copyWith(
              color:      dark
                  ? AppColors.darkSecondaryText
                  : AppColors.lightSecondaryText,
              fontFamily: 'Georgia',
              fontStyle:  FontStyle.italic,
              letterSpacing: 0.2,
            ),
          ),
        ),
      );

  // ─────────────────────────────────────────────
  // MARK: — AUTH CARD
  // ─────────────────────────────────────────────

  Widget _buildAuthCard(bool dark) => FadeTransition(
        opacity: _cardOpacity,
        child: SlideTransition(
          position: _cardSlide,
          child: ClipRRect(
            borderRadius: AppRadius.card,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: AppBlur.md, sigmaY: AppBlur.md),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: dark
                      ? const Color(0xCC1C1C1E)
                      : const Color(0xE6FFFFFF),
                  borderRadius: AppRadius.card,
                  border: Border.all(
                    color: dark
                        ? const Color(0x26FFFFFF)
                        : const Color(0x26000000),
                    width: 0.5,
                  ),
                  boxShadow: dark
                      ? AppShadows.darkGlass
                      : AppShadows.lightGlass,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildEmailField(dark),
                    const SizedBox(height: AppSpacing.md),
                    _buildPasswordField(dark),
                    const SizedBox(height: AppSpacing.xl),
                    _buildLoginButton(dark),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  // ─────────────────────────────────────────────
  // MARK: — EMAIL FIELD
  // ─────────────────────────────────────────────

  Widget _buildEmailField(bool dark) => _GlassTextField(
        controller:      _emailController,
        focusNode:       _emailFocus,
        hasFocus:        _emailHasFocus,
        isDark:          dark,
        label:           'Email',
        hint:            'your@email.com',
        icon:            Icons.mail_outline_rounded,
        keyboardType:    TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        onSubmitted:     (_) => _passwordFocus.requestFocus(),
        autofillHints:   const [AutofillHints.email],
      );

  // ─────────────────────────────────────────────
  // MARK: — PASSWORD FIELD
  // ─────────────────────────────────────────────

  Widget _buildPasswordField(bool dark) => _GlassTextField(
        controller:      _passwordController,
        focusNode:       _passwordFocus,
        hasFocus:        _passwordHasFocus,
        isDark:          dark,
        label:           'Password',
        hint:            '••••••••',
        icon:            Icons.lock_outline_rounded,
        obscureText:     _obscurePassword,
        textInputAction: TextInputAction.done,
        onSubmitted:     (_) => _handleLogin(),
        autofillHints:   const [AutofillHints.password],
        suffixIcon: GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _obscurePassword = !_obscurePassword);
          },
          child: AnimatedSwitcher(
            duration: AppAnimation.fast,
            child: Icon(
              _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              key:   ValueKey(_obscurePassword),
              size:  18,
              color: dark
                  ? AppColors.darkSecondaryText
                  : AppColors.lightSecondaryText,
            ),
          ),
        ),
      );

  // ─────────────────────────────────────────────
  // MARK: — LOGIN BUTTON
  // ─────────────────────────────────────────────

  Widget _buildLoginButton(bool dark) => _GlassPrimaryButton(
        label:     'Sign In',
        isDark:    dark,
        isLoading: _isLoading,
        onTap:     _handleLogin,
      );

  // ─────────────────────────────────────────────
  // MARK: — BOTTOM BUTTONS
  // ─────────────────────────────────────────────

  Widget _buildBottomButtons(bool dark) => FadeTransition(
        opacity: _buttonsOpacity,
        child: SlideTransition(
          position: _buttonsSlide,
          child: Column(children: [
            _GlassSecondaryButton(
              label:  'Create Account',
              isDark: dark,
              onTap:  _handleRegister,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildDivider(dark),
            const SizedBox(height: AppSpacing.md),
            _GlassGhostButton(
              label:     'Continue as Guest',
              isDark:    dark,
              isLoading: _isGuestLoading,
              onTap:     _handleGuest,
            ),
          ]),
        ),
      );

  Widget _buildDivider(bool dark) => Row(children: [
        Expanded(child: Divider(
          color:     dark ? AppColors.darkSeparator : AppColors.lightSeparator,
          thickness: 0.5)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text('or', style: AppTypography.caption.copyWith(
            color: dark ? AppColors.darkTertiaryText : AppColors.lightTertiaryText)),
        ),
        Expanded(child: Divider(
          color:     dark ? AppColors.darkSeparator : AppColors.lightSeparator,
          thickness: 0.5)),
      ]);
}

// ═════════════════════════════════════════════
// MARK: — ANIMATED BACKGROUND
// ═════════════════════════════════════════════

class _AnimatedBackground extends StatelessWidget {
  final bool isDark;
  final Animation<double> scaleAnimation;
  const _AnimatedBackground({required this.isDark, required this.scaleAnimation});

  @override
  Widget build(BuildContext context) => Positioned.fill(
        child: ScaleTransition(
          scale: scaleAnimation,
          child: Stack(children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end:   Alignment.bottomRight,
                  colors: isDark
                      ? [const Color(0xFF0D1117), const Color(0xFF121212),
                         const Color(0xFF0A0E1A)]
                      : [const Color(0xFFF8F9FF), const Color(0xFFFFFFFF),
                         const Color(0xFFF0F4FF)],
                ),
              ),
            ),
            Positioned(
              top: -100, left: -80,
              child: _GlowOrb(size: 340,
                color: isDark
                    ? AppColors.accent.withOpacity(0.18)
                    : AppColors.accent.withOpacity(0.08)),
            ),
            Positioned(
              bottom: -120, right: -60,
              child: _GlowOrb(size: 300,
                color: isDark
                    ? AppColors.gold.withOpacity(0.10)
                    : AppColors.gold.withOpacity(0.06)),
            ),
            Positioned(
              top:  MediaQuery.of(context).size.height * 0.4,
              left: MediaQuery.of(context).size.width  * 0.2,
              child: _GlowOrb(size: 200,
                color: isDark
                    ? AppColors.accentLight.withOpacity(0.07)
                    : AppColors.accentLight.withOpacity(0.04)),
            ),
          ]),
        ),
      );
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color  color;
  const _GlowOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        width:  size, height: size,
        decoration: BoxDecoration(
          shape:    BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, Colors.transparent],
          ),
        ),
      );
}

// ═════════════════════════════════════════════
// MARK: — GLASS LOGO MARK
// ═════════════════════════════════════════════

class _GlassLogoMark extends StatelessWidget {
  final bool isDark;
  const _GlassLogoMark({required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
        width: 84, height: 84,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(
              color:      AppColors.accent.withOpacity(isDark ? 0.35 : 0.22),
              blurRadius: 32,
              offset:     const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: AppBlur.md, sigmaY: AppBlur.md),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin:  Alignment.topLeft,
                  end:    Alignment.bottomRight,
                  colors: [
                    AppColors.accent.withOpacity(isDark ? 0.80 : 0.88),
                    const Color(0xFF7C3AED).withOpacity(isDark ? 0.72 : 0.80),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(
                  color:  Colors.white.withOpacity(isDark ? 0.18 : 0.28),
                  width:  0.75,
                ),
              ),
              child: Stack(children: [
                Center(
                  child: Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.07),
                    ),
                  ),
                ),
                Center(
                  child: CustomPaint(
                    size:    const Size(42, 42),
                    painter: _ScaleOfJusticePainter(color: Colors.white),
                  ),
                ),
              ]),
            ),
          ),
        ),
      );
}

class _ScaleOfJusticePainter extends CustomPainter {
  final Color color;
  const _ScaleOfJusticePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color       = color
      ..strokeWidth = 2.0
      ..strokeCap   = StrokeCap.round
      ..style       = PaintingStyle.stroke;
    final fillPaint = Paint()
      ..color = color.withOpacity(0.18)
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;

    canvas.drawLine(Offset(cx, 4), Offset(cx, size.height - 6), paint);
    canvas.drawLine(Offset(cx - 10, size.height - 6),
        Offset(cx + 10, size.height - 6), paint);
    canvas.drawLine(Offset(cx - 16, 10), Offset(cx + 16, 10), paint);
    canvas.drawCircle(Offset(cx, 4), 2, paint..style = PaintingStyle.fill);
    paint.style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx - 16, 10), Offset(cx - 14, 22), paint);
    canvas.drawLine(Offset(cx + 16, 10), Offset(cx + 14, 22), paint);

    final leftPan = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx - 14, 26), width: 18, height: 7),
      const Radius.circular(4));
    canvas.drawRRect(leftPan, fillPaint);
    canvas.drawRRect(leftPan, paint);

    final rightPan = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx + 14, 26), width: 18, height: 7),
      const Radius.circular(4));
    canvas.drawRRect(rightPan, fillPaint);
    canvas.drawRRect(rightPan, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ═════════════════════════════════════════════
// MARK: — GLASS TEXT FIELD
// ═════════════════════════════════════════════

class _GlassTextField extends StatelessWidget {
  final TextEditingController  controller;
  final FocusNode              focusNode;
  final bool                   hasFocus;
  final bool                   isDark;
  final String                 label;
  final String                 hint;
  final IconData               icon;
  final bool                   obscureText;
  final TextInputType          keyboardType;
  final TextInputAction        textInputAction;
  final ValueChanged<String>?  onSubmitted;
  final Iterable<String>?      autofillHints;
  final Widget?                suffixIcon;

  const _GlassTextField({
    required this.controller,
    required this.focusNode,
    required this.hasFocus,
    required this.isDark,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText     = false,
    this.keyboardType    = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.autofillHints,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = hasFocus
        ? (isDark ? AppColors.accentLight : AppColors.accent)
        : (isDark ? AppColors.darkSeparator : AppColors.lightSeparator);
    final bgColor = isDark
        ? const Color(0x1AFFFFFF)
        : const Color(0x0D000000);

    return AnimatedContainer(
      duration: AppAnimation.standard,
      decoration: BoxDecoration(
        color:        bgColor,
        borderRadius: AppRadius.mdAll,
        border:       Border.all(color: borderColor, width: hasFocus ? 1.5 : 0.5),
        boxShadow: hasFocus
            ? [BoxShadow(
                color:      (isDark ? AppColors.accentLight : AppColors.accent)
                    .withOpacity(0.12),
                blurRadius: 12)]
            : null,
      ),
      child: TextFormField(
        controller:      controller,
        focusNode:       focusNode,
        obscureText:     obscureText,
        keyboardType:    keyboardType,
        textInputAction: textInputAction,
        onFieldSubmitted: onSubmitted,
        autofillHints:   autofillHints,
        style: AppTypography.bodySmall.copyWith(
          fontFamily: null,
          color:      isDark
              ? AppColors.darkPrimaryText
              : AppColors.lightPrimaryText,
          height:     1.4,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText:  hint,
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Icon(icon, size: 18,
              color: hasFocus
                  ? (isDark ? AppColors.accentLight : AppColors.accent)
                  : (isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText)),
          ),
          suffixIcon: suffixIcon != null
              ? Padding(padding: const EdgeInsets.only(right: 12), child: suffixIcon)
              : null,
          prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          suffixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          border:        InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled:        false,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.base, vertical: AppSpacing.md),
          labelStyle: AppTypography.caption.copyWith(
            color: hasFocus
                ? (isDark ? AppColors.accentLight : AppColors.accent)
                : (isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText)),
          hintStyle: AppTypography.bodySmall.copyWith(
            fontFamily: null,
            color:      isDark ? AppColors.darkTertiaryText : AppColors.lightTertiaryText),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════
// MARK: — PRIMARY BUTTON
// ═════════════════════════════════════════════

class _GlassPrimaryButton extends StatefulWidget {
  final String   label;
  final bool     isDark;
  final bool     isLoading;
  final AsyncCallback onTap;

  const _GlassPrimaryButton({
    required this.label,
    required this.isDark,
    required this.isLoading,
    required this.onTap,
  });

  @override
  State<_GlassPrimaryButton> createState() => _GlassPrimaryButtonState();
}

class _GlassPrimaryButtonState extends State<_GlassPrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _press;
  late Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(vsync: this,
        duration: AppAnimation.fast, reverseDuration: AppAnimation.standard);
    _scale = Tween<double>(begin: 1.0, end: AppAnimation.pressScale)
        .animate(CurvedAnimation(parent: _press, curve: Curves.easeInOut));
  }

  @override void dispose() { _press.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => ScaleTransition(
        scale: _scale,
        child: GestureDetector(
          onTapDown:   (_) => _press.forward(),
          onTapUp:     (_) { _press.reverse(); if (!widget.isLoading) widget.onTap(); },
          onTapCancel: () => _press.reverse(),
          child: AnimatedContainer(
            duration: AppAnimation.standard,
            height:   52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin:  Alignment.topLeft,
                end:    Alignment.bottomRight,
                colors: [AppColors.accentLight, AppColors.accent],
              ),
              borderRadius: AppRadius.button,
              boxShadow: [BoxShadow(
                color:      AppColors.accent.withOpacity(0.38),
                blurRadius: 16, offset: const Offset(0, 6))],
            ),
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                  : Text(widget.label,
                      style: AppTypography.labelLarge.copyWith(
                          color: Colors.white, fontWeight: FontWeight.w600,
                          letterSpacing: 0.2)),
            ),
          ),
        ),
      );
}

// ═════════════════════════════════════════════
// MARK: — SECONDARY BUTTON
// ═════════════════════════════════════════════

class _GlassSecondaryButton extends StatefulWidget {
  final String label; final bool isDark; final VoidCallback onTap;
  const _GlassSecondaryButton({required this.label, required this.isDark, required this.onTap});
  @override State<_GlassSecondaryButton> createState() => _GlassSecondaryButtonState();
}
class _GlassSecondaryButtonState extends State<_GlassSecondaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _press; late Animation<double> _scale;
  @override
  void initState() {
    super.initState();
    _press = AnimationController(vsync: this,
        duration: AppAnimation.fast, reverseDuration: AppAnimation.standard);
    _scale = Tween<double>(begin: 1.0, end: AppAnimation.pressScale)
        .animate(CurvedAnimation(parent: _press, curve: Curves.easeInOut));
  }
  @override void dispose() { _press.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => ScaleTransition(
        scale: _scale,
        child: GestureDetector(
          onTapDown:   (_) => _press.forward(),
          onTapUp:     (_) { _press.reverse(); HapticFeedback.lightImpact(); widget.onTap(); },
          onTapCancel: () => _press.reverse(),
          child: ClipRRect(
            borderRadius: AppRadius.button,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: AppBlur.md, sigmaY: AppBlur.md),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? const Color(0x1AFFFFFF)
                      : const Color(0x14000000),
                  borderRadius: AppRadius.button,
                  border: Border.all(
                    color: widget.isDark
                        ? const Color(0x33FFFFFF)
                        : const Color(0x26000000),
                    width: 0.5,
                  ),
                ),
                child: Center(
                  child: Text(widget.label,
                    style: AppTypography.labelLarge.copyWith(
                      color: widget.isDark
                          ? AppColors.darkPrimaryText
                          : AppColors.lightPrimaryText,
                      fontWeight: FontWeight.w500,
                    )),
                ),
              ),
            ),
          ),
        ),
      );
}

// ═════════════════════════════════════════════
// MARK: — GHOST BUTTON (Continue as Guest)
// ═════════════════════════════════════════════

class _GlassGhostButton extends StatefulWidget {
  final String   label;
  final bool     isDark;
  final bool     isLoading;
  final AsyncCallback onTap;
  const _GlassGhostButton({
    required this.label,
    required this.isDark,
    required this.isLoading,
    required this.onTap,
  });
  @override State<_GlassGhostButton> createState() => _GlassGhostButtonState();
}
class _GlassGhostButtonState extends State<_GlassGhostButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _press; late Animation<double> _scale;
  bool _isPressed = false;
  @override
  void initState() {
    super.initState();
    _press = AnimationController(vsync: this,
        duration: AppAnimation.fast, reverseDuration: AppAnimation.standard);
    _scale = Tween<double>(begin: 1.0, end: 0.96)
        .animate(CurvedAnimation(parent: _press, curve: Curves.easeInOut));
  }
  @override void dispose() { _press.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => ScaleTransition(
        scale: _scale,
        child: GestureDetector(
          onTapDown:   (_) { _press.forward(); setState(() => _isPressed = true); },
          onTapUp:     (_) {
            _press.reverse(); setState(() => _isPressed = false);
            HapticFeedback.lightImpact();
            if (!widget.isLoading) widget.onTap();
          },
          onTapCancel: () { _press.reverse(); setState(() => _isPressed = false); },
          child: SizedBox(
            height: 48,
            child: Center(
              child: widget.isLoading
                  ? SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: widget.isDark
                              ? AppColors.darkSecondaryText
                              : AppColors.lightSecondaryText))
                  : Row(mainAxisSize: MainAxisSize.min, children: [
                      AnimatedOpacity(
                        duration: AppAnimation.fast,
                        opacity:  _isPressed ? 0.6 : 1.0,
                        child: Text(widget.label,
                          style: AppTypography.labelLarge.copyWith(
                            color:      widget.isDark
                                ? AppColors.darkSecondaryText
                                : AppColors.lightSecondaryText,
                            fontWeight: FontWeight.w400,
                          )),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios_rounded, size: 12,
                        color: widget.isDark
                            ? AppColors.darkTertiaryText
                            : AppColors.lightTertiaryText),
                    ]),
            ),
          ),
        ),
      );
}