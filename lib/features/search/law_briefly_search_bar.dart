// lib/features/search/law_briefly_search_bar.dart
// Law Briefly — iOS 18 Liquid Glass Search Bar Widget

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';

// ─────────────────────────────────────────────
// MARK: — LAW BRIEFLY SEARCH BAR
// ─────────────────────────────────────────────

class LawBrieflySearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode?             focusNode;
  final String                 placeholder;
  final ValueChanged<String>?  onChanged;
  final ValueChanged<String>?  onSubmitted;
  final VoidCallback?          onClear;
  final VoidCallback?          onTap;
  final bool                   autofocus;
  final bool                   readOnly;

  const LawBrieflySearchBar({
    super.key,
    this.controller,
    this.focusNode,
    this.placeholder  = 'Search acts…',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.onTap,
    this.autofocus    = false,
    this.readOnly     = false,
  });

  @override
  State<LawBrieflySearchBar> createState() => _LawBrieflySearchBarState();
}

class _LawBrieflySearchBarState extends State<LawBrieflySearchBar>
    with SingleTickerProviderStateMixin {

  late TextEditingController _controller;
  late FocusNode             _focusNode;
  late AnimationController   _clearBtnAnim;
  late Animation<double>     _clearBtnScale;
  late Animation<double>     _clearBtnFade;

  bool _isFocused  = false;
  bool _hasText    = false;

  bool get _isControllerOwned => widget.controller == null;
  bool get _isFocusOwned      => widget.focusNode  == null;

  // ─────────────────────────────────────────────
  // MARK: — LIFECYCLE
  // ─────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode  = widget.focusNode  ?? FocusNode();

    _clearBtnAnim = AnimationController(
      vsync: this,
      duration:        const Duration(milliseconds: 200),
      reverseDuration: const Duration(milliseconds: 150),
    );
    _clearBtnScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _clearBtnAnim, curve: Curves.easeOutBack,
          reverseCurve: Curves.easeIn),
    );
    _clearBtnFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _clearBtnAnim, curve: Curves.easeOut),
    );

    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);

    _hasText = _controller.text.isNotEmpty;
    if (_hasText) _clearBtnAnim.value = 1.0;
  }

  @override
  void dispose() {
    _clearBtnAnim.dispose();
    if (_isControllerOwned) _controller.dispose();
    if (_isFocusOwned)      _focusNode.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // MARK: — LISTENERS
  // ─────────────────────────────────────────────

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
      if (hasText) { _clearBtnAnim.forward(); }
      else          { _clearBtnAnim.reverse(); }
    }
    widget.onChanged?.call(_controller.text);
  }

  void _onFocusChanged() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  // ─────────────────────────────────────────────
  // MARK: — ACTIONS
  // ─────────────────────────────────────────────

  void _handleClear() {
    HapticFeedback.lightImpact();
    _controller.clear();
    widget.onClear?.call();
    _focusNode.requestFocus();
  }

  // ─────────────────────────────────────────────
  // MARK: — BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final dark    = Theme.of(context).brightness == Brightness.dark;
    final accent  = dark ? AppColors.accentLight : AppColors.accent;
    final iconCol = _isFocused
        ? accent
        : (dark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText);

    final bgColor   = dark
        ? const Color(0x1AFFFFFF)
        : const Color(0x0C000000);
    final borderCol = _isFocused
        ? accent.withOpacity(0.35)
        : (dark ? const Color(0x16FFFFFF) : const Color(0x0E000000));

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: AppAnimation.standard,
        height:   48,
        decoration: BoxDecoration(
          borderRadius: AppRadius.pillAll,
          border:       Border.all(color: borderCol, width: _isFocused ? 1.0 : 0.5),
          boxShadow:    _isFocused
              ? [BoxShadow(color: accent.withOpacity(0.12),
                           blurRadius: 12, offset: const Offset(0, 3))]
              : null,
        ),
        child: ClipRRect(
          borderRadius: AppRadius.pillAll,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: AppBlur.md, sigmaY: AppBlur.md),
            child: Container(
              color: bgColor,
              child: Row(
                children: [
                  // ── Search icon ─────────────────
                  const SizedBox(width: AppSpacing.base),
                  AnimatedContainer(
                    duration: AppAnimation.standard,
                    child: Icon(
                      Icons.search_rounded,
                      size:  20,
                      color: iconCol,
                    ),
                  ),

                  const SizedBox(width: AppSpacing.sm),

                  // ── Text field ──────────────────
                  Expanded(
                    child: TextField(
                      controller:          _controller,
                      focusNode:           _focusNode,
                      autofocus:           widget.autofocus,
                      readOnly:            widget.readOnly,
                      textInputAction:     TextInputAction.search,
                      keyboardType:        TextInputType.text,
                      textCapitalization:  TextCapitalization.none,
                      onSubmitted:         widget.onSubmitted,
                      style: AppTypography.bodyMedium.copyWith(
                        fontFamily: null,
                        color:      dark
                            ? AppColors.darkPrimaryText
                            : AppColors.lightPrimaryText,
                        height:     1.0,
                      ),
                      decoration: InputDecoration(
                        hintText:  widget.placeholder,
                        hintStyle: AppTypography.bodyMedium.copyWith(
                          fontFamily: null,
                          color:      dark
                              ? AppColors.darkTertiaryText
                              : AppColors.lightTertiaryText,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),

                  // ── Clear button ────────────────
                  FadeTransition(
                    opacity: _clearBtnFade,
                    child: ScaleTransition(
                      scale: _clearBtnScale,
                      child: GestureDetector(
                        onTap: _handleClear,
                        child: Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: Container(
                            width:  26, height: 26,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: (dark
                                  ? AppColors.darkSecondaryText
                                  : AppColors.lightSecondaryText)
                                  .withOpacity(0.25),
                            ),
                            child: Icon(
                              Icons.close_rounded, size: 15,
                              color: dark
                                  ? AppColors.darkSecondaryText
                                  : AppColors.lightSecondaryText,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  if (!_hasText) const SizedBox(width: AppSpacing.base),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}