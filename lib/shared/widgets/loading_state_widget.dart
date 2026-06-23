// lib/shared/widgets/loading_state_widget.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class LoadingStateWidget extends StatefulWidget {
  final String? message;
  final bool    showMessage;

  const LoadingStateWidget({
    super.key,
    this.message,
    this.showMessage = true,
  });

  @override
  State<LoadingStateWidget> createState() => _LoadingStateWidgetState();
}

class _LoadingStateWidgetState extends State<LoadingStateWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Animation<double>   _opacity;
  late Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.30, end: 0.85)
        .animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
    _scale = Tween<double>(begin: 0.97, end: 1.03)
        .animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
  }

  @override void dispose() { _pulse.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final dark     = Theme.of(context).brightness == Brightness.dark;
    final secColor = dark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final baseColor = dark
        ? const Color(0xFF2C2C2E)
        : const Color(0xFFE5E5EA);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated logo/indicator
          ScaleTransition(
            scale: _scale,
            child: Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color:        (dark ? AppColors.accentLight : AppColors.accent)
                    .withOpacity(0.12),
                borderRadius: AppRadius.xxlAll,
                border: Border.all(
                  color: (dark ? AppColors.accentLight : AppColors.accent)
                      .withOpacity(0.25),
                  width: 0.5,
                ),
              ),
              child: Center(
                child: SizedBox(
                  width: 26, height: 26,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: dark ? AppColors.accentLight : AppColors.accent,
                    backgroundColor: (dark ? AppColors.accentLight : AppColors.accent)
                        .withOpacity(0.15),
                  ),
                ),
              ),
            ),
          ),

          if (widget.showMessage) ...[
            const SizedBox(height: AppSpacing.xl),

            // Skeleton lines
            _SkeletonLine(width: 120, height: 12, baseColor: baseColor),
            const SizedBox(height: AppSpacing.sm),
            _SkeletonLine(width: 80, height: 10, baseColor: baseColor,
                opacity: _opacity),

            if (widget.message != null) ...[
              const SizedBox(height: AppSpacing.xl),
              FadeTransition(
                opacity: _opacity,
                child: Text(widget.message!,
                  style: const TextStyle(
                    fontFamily:  'Georgia',
                    fontSize:    14,
                    fontStyle:   FontStyle.italic,
                    height:      1.5,
                  ).merge(TextStyle(color: secColor)),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _SkeletonLine extends StatefulWidget {
  final double width, height; final Color baseColor;
  final Animation<double>? opacity;
  const _SkeletonLine({required this.width, required this.height,
      required this.baseColor, this.opacity});
  @override State<_SkeletonLine> createState() => _SkeletonLineState();
}
class _SkeletonLineState extends State<_SkeletonLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _p;
  late Animation<double>   _o;
  @override
  void initState() {
    super.initState();
    if (widget.opacity == null) {
      _p = AnimationController(vsync: this,
          duration: const Duration(milliseconds: 1400))..repeat(reverse: true);
      _o = Tween<double>(begin: 0.25, end: 0.75)
          .animate(CurvedAnimation(parent: _p, curve: Curves.easeInOut));
    }
  }
  @override void dispose() { if (widget.opacity == null) _p.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final anim = widget.opacity;
    final child = Container(
      width: widget.width, height: widget.height,
      decoration: BoxDecoration(
        color:        widget.baseColor,
        borderRadius: AppRadius.smAll,
      ),
    );
    if (anim != null) return FadeTransition(opacity: anim, child: child);
    return FadeTransition(opacity: _o, child: child);
  }
}