// lib/features/notes/note_editor_screen.dart
// Law Briefly — Note Editor Screen (iOS 18 Liquid Glass | UI Only)

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import 'data/models/note_entity.dart';

// ─────────────────────────────────────────────
// MARK: — NOTE EDITOR MODE
// ─────────────────────────────────────────────

enum NoteEditorMode { create, edit }

// ─────────────────────────────────────────────
// MARK: — NOTE EDITOR SCREEN
// ─────────────────────────────────────────────

class NoteEditorScreen extends StatefulWidget {
  final NoteEntity?                  existingNote;
  final void Function(String title, String content)? onSave;
  final VoidCallback?                onCancel;

  const NoteEditorScreen({
    super.key,
    this.existingNote,
    this.onSave,
    this.onCancel,
  });

  NoteEditorMode get mode =>
      existingNote == null ? NoteEditorMode.create : NoteEditorMode.edit;

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen>
    with SingleTickerProviderStateMixin {

  late TextEditingController _titleCtrl;
  late TextEditingController _contentCtrl;
  late FocusNode             _titleFocus;
  late FocusNode             _contentFocus;
  late AnimationController   _entranceCtrl;
  late Animation<double>     _appBarFade;
  late Animation<double>     _contentFade;
  late Animation<Offset>     _contentSlide;

  bool _titleFocused   = false;
  bool _contentFocused = false;
  bool _isSaving       = false;

  // ─────────────────────────────────────────────
  // MARK: — COMPUTED
  // ─────────────────────────────────────────────

  bool get _canSave      => _titleCtrl.text.trim().isNotEmpty;
  bool get _isCreateMode => widget.mode == NoteEditorMode.create;
  int  get _wordCount    {
    final t = _contentCtrl.text.trim();
    if (t.isEmpty) return 0;
    return t.split(RegExp(r'\s+')).length;
  }
  int  get _charCount    => _contentCtrl.text.length;

  bool get _hasChanges {
    if (_isCreateMode) {
      return _titleCtrl.text.isNotEmpty || _contentCtrl.text.isNotEmpty;
    }
    return _titleCtrl.text   != (widget.existingNote?.title   ?? '') ||
           _contentCtrl.text != (widget.existingNote?.content ?? '');
  }

  // ─────────────────────────────────────────────
  // MARK: — LIFECYCLE
  // ─────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    _titleCtrl   = TextEditingController(
        text: widget.existingNote?.title   ?? '');
    _contentCtrl = TextEditingController(
        text: widget.existingNote?.content ?? '');
    _titleFocus   = FocusNode()
      ..addListener(() => setState(() => _titleFocused   = _titleFocus.hasFocus));
    _contentFocus = FocusNode()
      ..addListener(() => setState(() => _contentFocused = _contentFocus.hasFocus));

    _entranceCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _appBarFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceCtrl,
          curve: const Interval(0.0, 0.50, curve: Curves.easeOut)));
    _contentFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceCtrl,
          curve: const Interval(0.25, 0.85, curve: Curves.easeOut)));
    _contentSlide = Tween<Offset>(
        begin: const Offset(0, 0.06), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceCtrl,
          curve: const Interval(0.25, 0.90, curve: Curves.easeOutCubic)));

    Future.delayed(const Duration(milliseconds: 60), () {
      if (mounted) {
        _entranceCtrl.forward();
        if (_isCreateMode) {
          Future.delayed(const Duration(milliseconds: 260),
              () { if (mounted) _titleFocus.requestFocus(); });
        }
      }
    });

    _titleCtrl.addListener(() => setState(() {}));
    _contentCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _titleFocus.dispose();
    _contentFocus.dispose();
    _entranceCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // MARK: — ACTIONS
  // ─────────────────────────────────────────────

  Future<void> _handleSave() async {
    if (!_canSave || _isSaving) return;

    FocusScope.of(context).unfocus();
    HapticFeedback.mediumImpact();
    setState(() => _isSaving = true);

    await Future.delayed(const Duration(milliseconds: 200));

    if (mounted) {
      widget.onSave?.call(
        _titleCtrl.text.trim(),
        _contentCtrl.text,
      );
      setState(() => _isSaving = false);
    }
  }

  Future<void> _handleCancel() async {
    if (_hasChanges) {
      final confirmed = await _showDiscardDialog();
      if (!confirmed) return;
    }
    FocusScope.of(context).unfocus();
    HapticFeedback.lightImpact();
    widget.onCancel?.call();
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  Future<bool> _showDiscardDialog() async {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final result = await showDialog<bool>(
      context:      context,
      barrierColor: Colors.black.withOpacity(0.40),
      builder:      (ctx) => _DiscardDialog(isDark: dark),
    );
    return result ?? false;
  }

  // ─────────────────────────────────────────────
  // MARK: — BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final dark   = Theme.of(context).brightness == Brightness.dark;
    final topPad = MediaQuery.of(context).padding.top;
    final botPad = MediaQuery.of(context).padding.bottom;
    final accent = dark ? AppColors.accentLight : AppColors.accent;

    SystemChrome.setSystemUIOverlayStyle(
        dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: dark ? AppColors.darkBackground : const Color(0xFFFFFEFA),
      resizeToAvoidBottomInset: true,
      appBar: _buildAppBar(dark, accent),
      body: Stack(children: [
        _EditorBackground(isDark: dark),
        FadeTransition(
          opacity: _contentFade,
          child: SlideTransition(
            position: _contentSlide,
            child: _buildBody(dark, topPad, botPad, accent),
          ),
        ),
      ]),
    );
  }

  // ─────────────────────────────────────────────
  // MARK: — APP BAR
  // ─────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(bool dark, Color accent) =>
      GlassAppBar(
        titleWidget: FadeTransition(
          opacity: _appBarFade,
          child: Text(
            _isCreateMode ? 'New Note' : 'Edit Note',
            style: AppTypography.titleMedium.copyWith(
              color:      dark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        leading: FadeTransition(
          opacity: _appBarFade,
          child: _CancelBtn(isDark: dark, onTap: _handleCancel),
        ),
        actions: [
          FadeTransition(
            opacity: _appBarFade,
            child: Padding(
              padding: const EdgeInsets.only(right: AppSpacing.base),
              child: _SaveBtn(
                canSave:   _canSave,
                isLoading: _isSaving,
                accent:    accent,
                onTap:     _handleSave,
              ),
            ),
          ),
        ],
      );

  // ─────────────────────────────────────────────
  // MARK: — BODY
  // ─────────────────────────────────────────────

  Widget _buildBody(bool dark, double topPad, double botPad, Color accent) {
    final textColor = dark ? AppColors.darkPrimaryText   : AppColors.lightPrimaryText;
    final secColor  = dark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;

    return Column(children: [
      SizedBox(height: topPad + kToolbarHeight + AppSpacing.base),

      // ── Title field ────────────────────────────
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: TextField(
          controller:         _titleCtrl,
          focusNode:          _titleFocus,
          textInputAction:    TextInputAction.next,
          textCapitalization: TextCapitalization.sentences,
          onSubmitted:        (_) => _contentFocus.requestFocus(),
          maxLines:           null,
          style: AppTypography.headlineLarge.copyWith(
            color: textColor, fontWeight: FontWeight.w700,
            letterSpacing: -0.4, height: 1.25,
          ),
          decoration: InputDecoration(
            hintText:  'Title',
            hintStyle: AppTypography.headlineLarge.copyWith(
              color:      secColor.withOpacity(0.40),
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
        ),
      ),

      const SizedBox(height: AppSpacing.md),

      // ── Animated separator ─────────────────────
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: AnimatedContainer(
          duration: AppAnimation.standard,
          height:   0.5,
          color: _titleFocused
              ? accent.withOpacity(0.45)
              : (dark ? AppColors.darkSeparator : AppColors.lightSeparator),
        ),
      ),

      const SizedBox(height: AppSpacing.md),

      // ── Content field ──────────────────────────
      Expanded(
        child: GestureDetector(
          onTap: () => _contentFocus.requestFocus(),
          behavior: HitTestBehavior.translucent,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              AppSpacing.xl, 0, AppSpacing.xl,
              botPad + AppSpacing.xxxl + 56,
            ),
            child: TextField(
              controller:         _contentCtrl,
              focusNode:          _contentFocus,
              maxLines:           null,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(
                fontFamily: 'Georgia',
                fontSize:   AppReader.baseFontSize,
                height:     AppReader.lineHeight,
                letterSpacing: 0.10,
              ).merge(TextStyle(color: textColor)),
              decoration: InputDecoration(
                hintText:  'Start writing your note…',
                hintStyle: const TextStyle(
                  fontFamily: 'Georgia',
                  fontSize:   AppReader.baseFontSize,
                  height:     AppReader.lineHeight,
                  fontStyle:  FontStyle.italic,
                ).merge(TextStyle(
                  color: secColor.withOpacity(0.38),
                )),
              ),
            ),
          ),
        ),
      ),

      // ── Footer: stats ──────────────────────────
      _buildFooter(dark, secColor, botPad),
    ]);
  }

  // ─────────────────────────────────────────────
  // MARK: — FOOTER
  // ─────────────────────────────────────────────

  Widget _buildFooter(bool dark, Color secColor, double botPad) =>
      AnimatedOpacity(
        duration: AppAnimation.standard,
        opacity:  _contentFocused ? 1.0 : 0.50,
        child: Container(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, botPad + AppSpacing.sm,
          ),
          child: Row(children: [
            Text('$_wordCount word${_wordCount != 1 ? "s" : ""}',
              style: AppTypography.caption.copyWith(color: secColor)),
            const SizedBox(width: AppSpacing.md),
            Container(width: 3, height: 3,
              decoration: BoxDecoration(shape: BoxShape.circle,
                  color: secColor.withOpacity(0.35))),
            const SizedBox(width: AppSpacing.md),
            Text('$_charCount chars',
              style: AppTypography.caption.copyWith(color: secColor)),
            const Spacer(),
            if (widget.existingNote != null)
              Text('Last edited ${_relativeDate(widget.existingNote!.updatedAt)}',
                style: AppTypography.caption.copyWith(
                    color: secColor, fontSize: 10.5)),
          ]),
        ),
      );
}

// ═════════════════════════════════════════════
// MARK: — CANCEL BUTTON
// ═════════════════════════════════════════════

class _CancelBtn extends StatefulWidget {
  final bool isDark; final AsyncCallback onTap;
  const _CancelBtn({required this.isDark, required this.onTap});
  @override State<_CancelBtn> createState() => _CancelBtnState();
}
class _CancelBtnState extends State<_CancelBtn>
    with SingleTickerProviderStateMixin {
  late AnimationController _p; late Animation<double> _s;
  @override
  void initState() {
    super.initState();
    _p = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 110),
        reverseDuration: const Duration(milliseconds: 200));
    _s = Tween<double>(begin: 1.0, end: 0.90)
        .animate(CurvedAnimation(parent: _p, curve: Curves.easeInOut));
  }
  @override void dispose() { _p.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => ScaleTransition(scale: _s,
    child: GestureDetector(
      onTapDown:   (_) => _p.forward(),
      onTapUp:     (_) { _p.reverse(); widget.onTap(); },
      onTapCancel: () => _p.reverse(),
      child: Padding(
        padding: const EdgeInsets.only(left: AppSpacing.base),
        child: Text('Cancel', style: AppTypography.bodyMedium.copyWith(
          fontFamily: null, color: AppColors.error, fontWeight: FontWeight.w400,
        )))));
}

// ═════════════════════════════════════════════
// MARK: — SAVE BUTTON
// ═════════════════════════════════════════════

class _SaveBtn extends StatefulWidget {
  final bool canSave, isLoading; final Color accent; final VoidCallback onTap;
  const _SaveBtn({required this.canSave, required this.isLoading,
      required this.accent, required this.onTap});
  @override State<_SaveBtn> createState() => _SaveBtnState();
}
class _SaveBtnState extends State<_SaveBtn>
    with SingleTickerProviderStateMixin {
  late AnimationController _p; late Animation<double> _s;
  @override
  void initState() {
    super.initState();
    _p = AnimationController(vsync: this, duration: const Duration(milliseconds: 110),
        reverseDuration: const Duration(milliseconds: 200));
    _s = Tween<double>(begin: 1.0, end: 0.90)
        .animate(CurvedAnimation(parent: _p, curve: Curves.easeInOut));
  }
  @override void dispose() { _p.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final color = widget.canSave ? widget.accent : widget.accent.withOpacity(0.35);
    return IgnorePointer(ignoring: !widget.canSave || widget.isLoading,
      child: ScaleTransition(scale: _s,
        child: GestureDetector(
          onTapDown:   (_) => _p.forward(),
          onTapUp:     (_) { _p.reverse(); HapticFeedback.lightImpact(); widget.onTap(); },
          onTapCancel: () => _p.reverse(),
          child: widget.isLoading
              ? SizedBox(width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: color))
              : Text('Save', style: AppTypography.bodyMedium.copyWith(
                  fontFamily: null, color: color, fontWeight: FontWeight.w700)))));
  }
}

// ═════════════════════════════════════════════
// MARK: — DISCARD DIALOG
// ═════════════════════════════════════════════

class _DiscardDialog extends StatelessWidget {
  final bool isDark;
  const _DiscardDialog({required this.isDark});

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: Colors.transparent, elevation: 0,
    child: ClipRRect(
      borderRadius: AppRadius.dialog,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: AppBlur.xl, sigmaY: AppBlur.xl),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xF01C1C1E) : const Color(0xF0FFFFFF),
            borderRadius: AppRadius.dialog,
            border: Border.all(color: isDark
                ? const Color(0x26FFFFFF) : const Color(0x26000000), width: 0.5),
            boxShadow: isDark ? AppShadows.darkLg : AppShadows.lightLg,
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Discard Changes?',
              style: AppTypography.titleMedium.copyWith(
                color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.sm),
            Text('Your unsaved changes will be lost.',
              style: AppTypography.bodySmall.copyWith(
                fontFamily: null,
                color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText),
              textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xl),
            Row(children: [
              Expanded(child: _DlgBtn(label: 'Keep Editing', isDestructive: false,
                  isDark: isDark, onTap: () => Navigator.pop(context, false))),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: _DlgBtn(label: 'Discard', isDestructive: true,
                  isDark: isDark, onTap: () => Navigator.pop(context, true))),
            ]),
          ]),
        ),
      ),
    ));
}

class _DlgBtn extends StatefulWidget {
  final String label; final bool isDestructive, isDark; final VoidCallback onTap;
  const _DlgBtn({required this.label, required this.isDestructive,
      required this.isDark, required this.onTap});
  @override State<_DlgBtn> createState() => _DlgBtnState();
}
class _DlgBtnState extends State<_DlgBtn> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    final color = widget.isDestructive ? AppColors.error : AppColors.accent;
    return GestureDetector(
      onTapDown:   (_) => setState(() => _pressed = true),
      onTapUp:     (_) { setState(() => _pressed = false); HapticFeedback.lightImpact(); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedOpacity(duration: const Duration(milliseconds: 80),
        opacity: _pressed ? 0.60 : 1.0,
        child: Container(height: 44,
          decoration: BoxDecoration(
            color: widget.isDestructive ? color : color.withOpacity(widget.isDark ? 0.12 : 0.08),
            borderRadius: AppRadius.mdAll,
          ),
          child: Center(child: Text(widget.label,
            style: AppTypography.labelMedium.copyWith(
              color: widget.isDestructive ? Colors.white : color,
              fontWeight: FontWeight.w600))))));
  }
}

// ═════════════════════════════════════════════
// MARK: — BACKGROUND + HELPERS
// ═════════════════════════════════════════════

class _EditorBackground extends StatelessWidget {
  final bool isDark;
  const _EditorBackground({required this.isDark});
  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: DecoratedBox(decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: isDark
            ? [const Color(0xFF0D1117), const Color(0xFF121212)]
            : [const Color(0xFFFFFEFA), const Color(0xFFFFFFFF)],
      ))));
}

String _relativeDate(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1)  return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours   < 24) return '${diff.inHours}h ago';
  if (diff.inDays    == 1) return 'yesterday';
  return '${date.day}/${date.month}/${date.year}';
}