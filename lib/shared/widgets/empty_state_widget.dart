// lib/shared/widgets/empty_state_widget.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class EmptyStateWidget extends StatefulWidget {
  final String       title;
  final String       subtitle;
  final IconData     icon;
  final String?      buttonText;
  final VoidCallback? onPressed;
  final Color?       iconColor;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.buttonText,
    this.onPressed,
    this.iconColor,
  });

  @override
  State<EmptyStateWidget> createState() => _EmptyStateWidgetState();
}

class _EmptyStateWidgetState extends State<EmptyStateWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _fade;
  late Animation<Offset>   _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 600));
    _fade  = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(const Duration(milliseconds: 80), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final dark      = Theme.of(context).brightness == Brightness.dark;
    final textColor = dark ? AppColors.darkPrimaryText   : AppColors.lightPrimaryText;
    final secColor  = dark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final iconColor = widget.iconColor
        ?? (dark ? AppColors.accentLight : AppColors.accent);

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon container
                ClipRRect(
                  borderRadius: AppRadius.xxlAll,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: AppBlur.md, sigmaY: AppBlur.md),
                    child: Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        color:        iconColor.withOpacity(dark ? 0.14 : 0.08),
                        borderRadius: AppRadius.xxlAll,
                        border: Border.all(
                            color: iconColor.withOpacity(0.25), width: 0.5),
                      ),
                      child: Icon(widget.icon, size: 36, color: iconColor),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Title
                Text(widget.title,
                  style: AppTypography.titleMedium.copyWith(
                    color: textColor, fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center),

                const SizedBox(height: AppSpacing.sm),

                // Subtitle
                Text(widget.subtitle,
                  style: const TextStyle(
                    fontFamily: 'Georgia', fontSize: 14.5,
                    height: 1.65, fontStyle: FontStyle.italic,
                  ).merge(TextStyle(color: secColor)),
                  textAlign: TextAlign.center,
                  maxLines: 4, overflow: TextOverflow.ellipsis),

                // Action button
                if (widget.buttonText != null && widget.onPressed != null) ...[
                  const SizedBox(height: AppSpacing.xxxl),
                  _EmptyActionButton(
                    label:   widget.buttonText!,
                    isDark:  dark,
                    accent:  iconColor,
                    onTap:   widget.onPressed!,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyActionButton extends StatefulWidget {
  final String label; final bool isDark; final Color accent;
  final VoidCallback onTap;
  const _EmptyActionButton({required this.label, required this.isDark,
      required this.accent, required this.onTap});
  @override State<_EmptyActionButton> createState() => _EmptyActionButtonState();
}
class _EmptyActionButtonState extends State<_EmptyActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _p; late Animation<double> _s;
  @override
  void initState() {
    super.initState();
    _p = AnimationController(vsync: this, duration: const Duration(milliseconds: 120),
        reverseDuration: const Duration(milliseconds: 200));
    _s = Tween<double>(begin: 1.0, end: 0.95)
        .animate(CurvedAnimation(parent: _p, curve: Curves.easeInOut));
  }
  @override void dispose() { _p.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => ScaleTransition(scale: _s,
    child: GestureDetector(
      onTapDown:   (_) => _p.forward(),
      onTapUp:     (_) { _p.reverse(); widget.onTap(); },
      onTapCancel: () => _p.reverse(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
        decoration: BoxDecoration(
          color:        widget.accent,
          borderRadius: AppRadius.button,
          boxShadow: [BoxShadow(
            color:      widget.accent.withOpacity(0.35),
            blurRadius: 16, offset: const Offset(0, 6),
          )],
        ),
        child: Text(widget.label, style: AppTypography.labelLarge.copyWith(
            color: Colors.white)))));
}