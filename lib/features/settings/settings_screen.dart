// lib/features/settings/settings_screen.dart
// Law Briefly — Settings Screen
// iOS 18 Liquid Glass | Full Settings | Logout Flow

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../main.dart' show themeModeNotifier;
import '../../auth/services/session_service.dart';
import '../../../core/router/navigation_registry.dart';
import '../../../core/theme/app_theme.dart';
import 'settings_controller.dart';

// ─────────────────────────────────────────────
// MARK: — SETTINGS SCREEN
// ─────────────────────────────────────────────

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {

  late SettingsController _controller;
  late AnimationController _entranceCtrl;
  late Animation<double>   _appBarFade;
  late Animation<double>   _contentFade;
  late Animation<Offset>   _contentSlide;

  bool _isDarkMode     = false;
  bool _isLoggingOut   = false;
  bool _suggestionSent = false;

  // ─────────────────────────────────────────────
  // MARK: — LIFECYCLE
  // ─────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    _controller = SettingsController(
      themeNotifier:    themeModeNotifier,
      onLogoutRequested: _onLogoutComplete,
    );

    _entranceCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _appBarFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceCtrl,
          curve: const Interval(0.0, 0.45, curve: Curves.easeOut)));
    _contentFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceCtrl,
          curve: const Interval(0.20, 0.80, curve: Curves.easeOut)));
    _contentSlide = Tween<Offset>(
        begin: const Offset(0, 0.04), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceCtrl,
          curve: const Interval(0.20, 0.85, curve: Curves.easeOutCubic)));

    _controller.addListener(_onControllerUpdate);
    _controller.loadSettings();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _isDarkMode = _controller.isDarkMode(context);
        _entranceCtrl.forward();
      }
    });

    themeModeNotifier.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    themeModeNotifier.removeListener(_onThemeChanged);
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    _entranceCtrl.dispose();
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) {
      setState(() => _isDarkMode = _controller.isDarkMode(context));
    }
  }

  void _onControllerUpdate() {
    if (!mounted) return;
    setState(() {
      _isDarkMode     = _controller.isDarkMode(context);
      _isLoggingOut   = _controller.state.isLoggingOut;
      _suggestionSent = _controller.state.suggestionSent;
    });
  }

  // ─────────────────────────────────────────────
  // MARK: — ACTIONS
  // ─────────────────────────────────────────────

  void _handleThemeToggle(bool value) {
    HapticFeedback.lightImpact();
    _controller.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  void _handleProfile() {
    HapticFeedback.selectionClick();
    context.go(NavigationRegistry.profilePath);
  }

  void _handleAbout() {
    HapticFeedback.selectionClick();
    context.go(NavigationRegistry.aboutPath);
  }

  void _handleSendSuggestion() async {
    HapticFeedback.lightImpact();
    final dark   = Theme.of(context).brightness == Brightness.dark;
    final result = await _showSuggestionSheet(dark);
    if (result != null && result.isNotEmpty) {
      await _controller.sendSuggestion(result);
    }
  }

  Future<void> _handleLogoutTap() async {
    HapticFeedback.mediumImpact();
    final confirmed = await _showLogoutConfirmDialog();
    if (!confirmed) return;
    await _performLogout();
  }

  Future<void> _performLogout() async {
    if (!mounted) return;
    setState(() => _isLoggingOut = true);

    try {
      // 1. Clear session
      await SessionService().clearSession();

      // 2. Reset theme to system default
      themeModeNotifier.value = ThemeMode.system;

      // 3. Navigate to login
      if (mounted) {
        context.go(NavigationRegistry.loginPath);
      }
    } catch (e) {
      debugPrint('[SettingsScreen] Logout error: $e');
      if (mounted) {
        setState(() => _isLoggingOut = false);
        _showErrorSnackbar('Logout failed. Please try again.');
      }
    }
  }

  void _onLogoutComplete() {
    // Called by SettingsController when controller-level logout finishes.
    // Navigation handled in _performLogout directly.
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  // ─────────────────────────────────────────────
  // MARK: — BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final dark    = Theme.of(context).brightness == Brightness.dark;
    final topPad  = MediaQuery.of(context).padding.top;
    final botPad  = MediaQuery.of(context).padding.bottom;

    SystemChrome.setSystemUIOverlayStyle(
      dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor:
          dark ? AppColors.darkBackground : AppColors.lightGroupedBackground,
      appBar: _buildAppBar(dark),
      body: Stack(
        fit: StackFit.expand,
        children: [
          _SettingsBackground(isDark: dark),
          FadeTransition(
            opacity: _contentFade,
            child: SlideTransition(
              position: _contentSlide,
              child: _buildBody(dark, topPad, botPad),
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
            'Settings',
            style: AppTypography.titleLarge.copyWith(
              color:      dark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        leading: FadeTransition(
          opacity: _appBarFade,
          child: _BackButton(isDark: dark),
        ),
      );

  // ─────────────────────────────────────────────
  // MARK: — BODY
  // ─────────────────────────────────────────────

  Widget _buildBody(bool dark, double topPad, double botPad) =>
      SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.base,
          topPad + kToolbarHeight + AppSpacing.xl,
          AppSpacing.base,
          botPad + AppSpacing.xxxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── SECTION: Account ──────────────────
            _SectionLabel(label: 'Account', isDark: dark),
            const SizedBox(height: AppSpacing.sm),
            _SettingsCard(
              isDark: dark,
              children: [
                GlassSettingsTile(
                  icon:        Icons.person_outline_rounded,
                  title:       'Profile',
                  subtitle:    'Edit your name, college and details',
                  iconColor:   dark ? AppColors.accentLight : AppColors.accent,
                  showDivider: false,
                  onTap:       _handleProfile,
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),

            // ── SECTION: Preferences ──────────────
            _SectionLabel(label: 'Preferences', isDark: dark),
            const SizedBox(height: AppSpacing.sm),
            _SettingsCard(
              isDark: dark,
              children: [
                GlassSettingsTile(
                  icon:     Icons.dark_mode_outlined,
                  title:    'Dark Mode',
                  subtitle: _isDarkMode ? 'Dark theme active' : 'Light theme active',
                  iconColor: dark
                      ? const Color(0xFF8B5CF6)
                      : const Color(0xFF7C3AED),
                  showDivider: false,
                  trailing: Switch.adaptive(
                    value:          _isDarkMode,
                    onChanged:      _handleThemeToggle,
                    activeColor:    AppColors.accent,
                    activeTrackColor: AppColors.accent.withOpacity(0.30),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),

            // ── SECTION: App ──────────────────────
            _SectionLabel(label: 'App', isDark: dark),
            const SizedBox(height: AppSpacing.sm),
            _SettingsCard(
              isDark: dark,
              children: [
                GlassSettingsTile(
                  icon:      Icons.lightbulb_outline_rounded,
                  title:     'Send Suggestion',
                  subtitle:  _suggestionSent
                      ? 'Thanks! Suggestion sent.'
                      : 'Help us improve Law Briefly',
                  iconColor: const Color(0xFFF59E0B),
                  onTap:     _handleSendSuggestion,
                ),
                GlassSettingsTile(
                  icon:        Icons.info_outline_rounded,
                  title:       'About Law Briefly',
                  subtitle:    'Version · Mission · Roadmap',
                  iconColor:   dark ? AppColors.accentLight : AppColors.accent,
                  showDivider: false,
                  onTap:       _handleAbout,
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),

            // ── SECTION: Legal ────────────────────
            _SectionLabel(label: 'Legal', isDark: dark),
            const SizedBox(height: AppSpacing.sm),
            _SettingsCard(
              isDark: dark,
              children: [
                GlassSettingsTile(
                  icon:      Icons.privacy_tip_outlined,
                  title:     'Privacy Policy',
                  subtitle:  'How we handle your data',
                  iconColor: const Color(0xFF10B981),
                  onTap:     () {},
                ),
                GlassSettingsTile(
                  icon:        Icons.description_outlined,
                  title:       'Terms of Use',
                  subtitle:    'User agreement and conditions',
                  iconColor:   const Color(0xFF10B981),
                  showDivider: false,
                  onTap:       () {},
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),

            // ── SECTION: Account Actions ──────────
            _SectionLabel(label: 'Account Actions', isDark: dark),
            const SizedBox(height: AppSpacing.sm),
            _SettingsCard(
              isDark: dark,
              children: [
                GlassSettingsTile(
                  icon:          Icons.logout_rounded,
                  title:         _isLoggingOut ? 'Signing out…' : 'Sign Out',
                  subtitle:      'Clear session and return to login',
                  iconColor:     AppColors.error,
                  isDestructive: true,
                  showDivider:   false,
                  trailing: _isLoggingOut
                      ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.error))
                      : null,
                  onTap: _isLoggingOut ? null : _handleLogoutTap,
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),

            // ── App version footer ────────────────
            _VersionFooter(isDark: dark),
          ],
        ),
      );

  // ─────────────────────────────────────────────
  // MARK: — LOGOUT CONFIRM DIALOG
  // ─────────────────────────────────────────────

  Future<bool> _showLogoutConfirmDialog() async {
    final dark = Theme.of(context).brightness == Brightness.dark;

    final result = await showDialog<bool>(
      context:      context,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (ctx) => _LogoutConfirmDialog(isDark: dark),
    );

    return result ?? false;
  }

  // ─────────────────────────────────────────────
  // MARK: — SUGGESTION SHEET
  // ─────────────────────────────────────────────

  Future<String?> _showSuggestionSheet(bool dark) async {
    final ctrl = TextEditingController();
    String? result;

    await GlassBottomSheet.show(
      context,
      initialChildSize: 0.60,
      maxChildSize:     0.85,
      child: _SuggestionSheetContent(
        isDark:     dark,
        controller: ctrl,
        onSend:     (text) {
          result = text;
          Navigator.of(context).pop();
        },
      ),
    );

    ctrl.dispose();
    return result;
  }
}

// ═════════════════════════════════════════════
// MARK: — SECTION LABEL
// ═════════════════════════════════════════════

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool   isDark;
  const _SectionLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        child: Text(
          label.toUpperCase(),
          style: AppTypography.labelSmall.copyWith(
            color:         isDark
                ? AppColors.darkSecondaryText
                : AppColors.lightSecondaryText,
            letterSpacing: 0.8,
            fontSize:      11,
            fontWeight:    FontWeight.w600,
          ),
        ),
      );
}

// ═════════════════════════════════════════════
// MARK: — SETTINGS CARD CONTAINER
// ═════════════════════════════════════════════

class _SettingsCard extends StatelessWidget {
  final bool         isDark;
  final List<Widget> children;
  const _SettingsCard({required this.isDark, required this.children});

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: AppRadius.card,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: AppBlur.md, sigmaY: AppBlur.md),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xCC1C1C1E)
                  : const Color(0xE6FFFFFF),
              borderRadius: AppRadius.card,
              border: Border.all(
                color: isDark
                    ? const Color(0x1AFFFFFF)
                    : const Color(0x1A000000),
                width: 0.5,
              ),
              boxShadow: isDark ? AppShadows.darkGlass : AppShadows.lightGlass,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: children,
            ),
          ),
        ),
      );
}

// ═════════════════════════════════════════════
// MARK: — VERSION FOOTER
// ═════════════════════════════════════════════

class _VersionFooter extends StatelessWidget {
  final bool isDark;
  const _VersionFooter({required this.isDark});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin:  Alignment.topLeft,
                end:    Alignment.bottomRight,
                colors: [AppColors.accent, Color(0xFF7C3AED)],
              ),
            ),
            child: const Icon(Icons.balance_rounded,
                size: 16, color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text('Law Briefly',
            style: AppTypography.labelMedium.copyWith(
              color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
              fontFamily:  'Georgia',
              fontStyle:   FontStyle.italic,
            )),
          const SizedBox(height: 3),
          Text('Version 1.0.0  ·  Offline · Private · India',
            style: AppTypography.caption.copyWith(
              color: (isDark
                  ? AppColors.darkTertiaryText
                  : AppColors.lightTertiaryText)
                  .withOpacity(0.70),
              fontSize:  10.5,
              letterSpacing: 0.3,
            )),
        ]),
      );
}

// ═════════════════════════════════════════════
// MARK: — LOGOUT CONFIRM DIALOG
// ═════════════════════════════════════════════

class _LogoutConfirmDialog extends StatelessWidget {
  final bool isDark;
  const _LogoutConfirmDialog({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? AppColors.darkPrimaryText   : AppColors.lightPrimaryText;
    final secColor  = isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation:       0,
      child: ClipRRect(
        borderRadius: AppRadius.dialog,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: AppBlur.xl, sigmaY: AppBlur.xl),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xF01C1C1E)
                  : const Color(0xF0FFFFFF),
              borderRadius: AppRadius.dialog,
              border: Border.all(
                color: isDark
                    ? const Color(0x26FFFFFF)
                    : const Color(0x26000000),
                width: 0.5,
              ),
              boxShadow: isDark ? AppShadows.darkLg : AppShadows.lightLg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                // Icon
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color:        AppColors.error.withOpacity(isDark ? 0.14 : 0.08),
                    borderRadius: AppRadius.lgAll,
                  ),
                  child: const Icon(Icons.logout_rounded,
                      size: 24, color: AppColors.error),
                ),

                const SizedBox(height: AppSpacing.base),

                // Title
                Text('Sign Out?',
                  style: AppTypography.titleMedium.copyWith(
                    color:      textColor,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center),

                const SizedBox(height: AppSpacing.sm),

                // Message
                Text(
                  "Your bookmarks and notes are saved locally.\nYou'll need to sign in again to continue.",
                  style: AppTypography.bodySmall.copyWith(
                    fontFamily: null,
                    color:      secColor,
                    height:     1.55,
                  ),
                  textAlign: TextAlign.center),

                const SizedBox(height: AppSpacing.xl),

                // Buttons
                Row(children: [
                  Expanded(
                    child: _DialogButton(
                      label:    'Cancel',
                      isPrimary: false,
                      isError:   false,
                      isDark:    isDark,
                      onTap:     () => Navigator.pop(context, false),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _DialogButton(
                      label:    'Sign Out',
                      isPrimary: true,
                      isError:   true,
                      isDark:    isDark,
                      onTap:     () {
                        HapticFeedback.mediumImpact();
                        Navigator.pop(context, true);
                      },
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════
// MARK: — SUGGESTION SHEET CONTENT
// ═════════════════════════════════════════════

class _SuggestionSheetContent extends StatefulWidget {
  final bool                   isDark;
  final TextEditingController  controller;
  final ValueChanged<String>   onSend;

  const _SuggestionSheetContent({
    required this.isDark,
    required this.controller,
    required this.onSend,
  });

  @override
  State<_SuggestionSheetContent> createState() =>
      _SuggestionSheetContentState();
}

class _SuggestionSheetContentState
    extends State<_SuggestionSheetContent> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      setState(() => _hasText = widget.controller.text.trim().isNotEmpty);
    });
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDark
        ? AppColors.darkPrimaryText   : AppColors.lightPrimaryText;
    final secColor  = widget.isDark
        ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final accent    = widget.isDark
        ? AppColors.accentLight       : AppColors.accent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(children: [
          Icon(Icons.lightbulb_outline_rounded, size: 18, color: accent),
          const SizedBox(width: AppSpacing.sm),
          Text('Send a Suggestion',
            style: AppTypography.titleMedium.copyWith(
              color:      textColor,
              fontWeight: FontWeight.w700,
            )),
        ]),

        const SizedBox(height: AppSpacing.sm),

        Text('Share ideas for new features, content, or improvements.',
          style: AppTypography.bodySmall.copyWith(
              fontFamily: null, color: secColor)),

        const SizedBox(height: AppSpacing.xl),

        // Text field
        Container(
          decoration: BoxDecoration(
            color: widget.isDark
                ? const Color(0x1AFFFFFF)
                : const Color(0x08000000),
            borderRadius: AppRadius.mdAll,
            border: Border.all(
              color: widget.isDark
                  ? const Color(0x1AFFFFFF)
                  : const Color(0x10000000),
              width: 0.5,
            ),
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: TextField(
            controller:         widget.controller,
            autofocus:          true,
            maxLines:           6,
            textCapitalization: TextCapitalization.sentences,
            style: AppTypography.bodySmall.copyWith(
                fontFamily: null, color: textColor),
            decoration: InputDecoration(
              hintText:  'What would make Law Briefly better?',
              hintStyle: AppTypography.bodySmall.copyWith(
                  fontFamily: null,
                  color:      secColor.withOpacity(0.45),
                  fontStyle:  FontStyle.italic),
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        // Send button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: AnimatedOpacity(
            duration: AppAnimation.standard,
            opacity:  _hasText ? 1.0 : 0.45,
            child: GestureDetector(
              onTap: _hasText
                  ? () => widget.onSend(widget.controller.text.trim())
                  : null,
              child: Container(
                decoration: BoxDecoration(
                  color:        accent,
                  borderRadius: AppRadius.button,
                  boxShadow:    _hasText ? AppShadows.accentGlow : null,
                ),
                child: Center(
                  child: Text('Send Suggestion',
                    style: AppTypography.labelLarge.copyWith(
                        color: Colors.white)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════
// MARK: — DIALOG BUTTON
// ═════════════════════════════════════════════

class _DialogButton extends StatefulWidget {
  final String     label;
  final bool       isPrimary, isError, isDark;
  final VoidCallback onTap;

  const _DialogButton({
    required this.label,
    required this.isPrimary,
    required this.isError,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_DialogButton> createState() => _DialogButtonState();
}

class _DialogButtonState extends State<_DialogButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final color  = widget.isError ? AppColors.error : AppColors.accent;
    final bgColor = widget.isPrimary
        ? color
        : color.withOpacity(widget.isDark ? 0.12 : 0.08);
    final textColor = widget.isPrimary
        ? Colors.white
        : color;

    return GestureDetector(
      onTapDown:   (_) => setState(() => _pressed = true),
      onTapUp:     (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 80),
        opacity:  _pressed ? 0.60 : 1.0,
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            color:        bgColor,
            borderRadius: AppRadius.mdAll,
          ),
          child: Center(
            child: Text(widget.label,
              style: AppTypography.labelMedium.copyWith(
                color:      textColor,
                fontWeight: FontWeight.w600,
              )),
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════
// MARK: — BACK BUTTON
// ═════════════════════════════════════════════

class _BackButton extends StatefulWidget {
  final bool isDark;
  const _BackButton({required this.isDark});
  @override State<_BackButton> createState() => _BackButtonState();
}

class _BackButtonState extends State<_BackButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _press;
  late Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 110),
        reverseDuration: const Duration(milliseconds: 200));
    _scale = Tween<double>(begin: 1.0, end: 0.88)
        .animate(CurvedAnimation(parent: _press, curve: Curves.easeInOut));
  }

  @override void dispose() { _press.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => ScaleTransition(
        scale: _scale,
        child: GestureDetector(
          onTapDown:   (_) => _press.forward(),
          onTapUp:     (_) {
            _press.reverse();
            HapticFeedback.lightImpact();
            Navigator.maybePop(context);
          },
          onTapCancel: () => _press.reverse(),
          child: Container(
            width:  34, height: 34,
            margin: const EdgeInsets.only(left: AppSpacing.sm),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.isDark
                  ? const Color(0x33FFFFFF)
                  : const Color(0x1A000000),
            ),
            child: Icon(
              Icons.arrow_back_ios_rounded, size: 15,
              color: widget.isDark
                  ? AppColors.darkPrimaryText
                  : AppColors.lightPrimaryText,
            ),
          ),
        ),
      );
}

// ═════════════════════════════════════════════
// MARK: — BACKGROUND
// ═════════════════════════════════════════════

class _SettingsBackground extends StatelessWidget {
  final bool isDark;
  const _SettingsBackground({required this.isDark});

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin:  Alignment.topCenter,
            end:    Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF0D1117), const Color(0xFF121212)]
                : [AppColors.lightGroupedBackground, AppColors.lightBackground],
          ),
        ),
        child: Stack(children: [
          // Top-right subtle accent orb
          Positioned(
            top:   -80, right: -60,
            child: Container(
              width: 260, height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.accent.withOpacity(isDark ? 0.06 : 0.04),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
        ]),
      );
}