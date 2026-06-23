// lib/shared/widgets/error_state_widget.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class ErrorStateWidget extends StatefulWidget {
  final String       title;
  final String       message;
  final VoidCallback? onRetry;

  const ErrorStateWidget({
    super.key,
    this.title   = 'Something Went Wrong',
    required this.message,
    this.onRetry,
  });

  @override
  State<ErrorStateWidget> createState() => _ErrorStateWidgetState();
}

class _ErrorStateWidgetState extends State<ErrorStateWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _fade;
  late Animation<Offset>   _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 500));
    _fade  = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(const Duration(milliseconds: 60), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final dark      = Theme.of(context).brightness == Brightness.dark;
    final textColor = dark ? AppColors.darkPrimaryText   : AppColors.lightPrimaryText;
    final secColor  = dark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;

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
                // Error icon
                ClipRRect(
                  borderRadius: AppRadius.xxlAll,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: AppBlur.md, sigmaY: AppBlur.md),
                    child: Container(
                      width: 76, height: 76,
                      decoration: BoxDecoration(
                        color:        AppColors.error.withOpacity(dark ? 0.14 : 0.08),
                        borderRadius: AppRadius.xxlAll,
                        border: Border.all(
                            color: AppColors.error.withOpacity(0.25), width: 0.5),
                      ),
                      child: const Icon(Icons.error_outline_rounded,
                          size: 34, color: AppColors.error),
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

                // Message
                Text(widget.message,
                  style: AppTypography.bodySmall.copyWith(
                    fontFamily: null, color: secColor, height: 1.55,
                  ),
                  textAlign: TextAlign.center,
                  maxLines:  4, overflow: TextOverflow.ellipsis),

                // Retry button
                if (widget.onRetry != null) ...[
                  const SizedBox(height: AppSpacing.xxxl),
                  _RetryButton(onTap: widget.onRetry!),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RetryButton extends StatefulWidget {
  final VoidCallback onTap;
  const _RetryButton({required this.onTap});
  @override State<_RetryButton> createState() => _RetryButtonState();
}
class _RetryButtonState extends State<_RetryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _p; late Animation<double> _s;
  @override
  void initState() {
    super.initState();
    _p = AnimationController(vsync: this, duration: const Duration(milliseconds: 120),
        reverseDuration: const Duration(milliseconds: 200));
    _s = Tween<double>(begin: 1.0, end: 0.94)
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
          color:        AppColors.error,
          borderRadius: AppRadius.button,
          boxShadow: [BoxShadow(
            color:      AppColors.error.withOpacity(0.30),
            blurRadius: 14, offset: const Offset(0, 5),
          )],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.refresh_rounded, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text('Try Again', style: AppTypography.labelLarge.copyWith(
              color: Colors.white)),
        ]))));
}