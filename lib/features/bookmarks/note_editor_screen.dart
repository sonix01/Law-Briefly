// lib/features/bookmarks/note_editor_screen.dart
// Law Briefly — Note Editor Screen
// iOS 18 Liquid Glass | Create & Edit Notes | Reader-First UX

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/legal_models.dart';

// ─────────────────────────────────────────────
// MARK: — NOTE EDITOR MODE
// ─────────────────────────────────────────────

enum NoteEditorMode { create, edit }

// ─────────────────────────────────────────────
// MARK: — NOTE EDITOR SCREEN
// ─────────────────────────────────────────────

class NoteEditorScreen extends StatefulWidget {
  final PersonalNote?            note;         // null = create mode
  final ValueChanged<PersonalNote>? onSave;
  final VoidCallback?            onCancel;
  final String?                  linkedContentId;
  final String?                  linkedContentTitle;

  const NoteEditorScreen({
    super.key,
    this.note,
    this.onSave,
    this.onCancel,
    this.linkedContentId,
    this.linkedContentTitle,
  });

  NoteEditorMode get mode =>
      note == null ? NoteEditorMode.create : NoteEditorMode.edit;

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen>
    with SingleTickerProviderStateMixin {

  // ── Controllers ───────────────────────────────
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final FocusNode             _titleFocus;
  late final FocusNode             _contentFocus;
  late final AnimationController   _entranceController;

  // ── State ─────────────────────────────────────
  bool _isSaving  = false;
  bool _titleFocused   = false;
  bool _contentFocused = false;

  // ── Entrance animations ───────────────────────
  late Animation<double>  _appBarFade;
  late Animation<double>  _bodyFade;
  late Animation<Offset>  _bodySlide;

  // ─────────────────────────────────────────────
  // MARK: — COMPUTED
  // ─────────────────────────────────────────────

  bool get _canSave  => _titleController.text.trim().isNotEmpty;
  bool get _isCreate => widget.mode == NoteEditorMode.create;

  bool get _hasChanges {
    if (_isCreate) {
      return _titleController.text.isNotEmpty ||
             _contentController.text.isNotEmpty;
    }
    return _titleController.text   != widget.note!.title ||
           _contentController.text != widget.note!.content;
  }

  int get _wordCount {
    final text = _contentController.text.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).length;
  }

  int get _charCount => _contentController.text.length;

  // ─────────────────────────────────────────────
  // MARK: — LIFECYCLE
  // ─────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _titleController   = TextEditingController(text: widget.note?.title   ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _titleFocus        = FocusNode()
      ..addListener(() => setState(() => _titleFocused   = _titleFocus.hasFocus));
    _contentFocus      = FocusNode()
      ..addListener(() => setState(() => _contentFocused = _contentFocus.hasFocus));

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _appBarFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOut)),
    );
    _bodyFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceController,
        curve: const Interval(0.15, 0.75, curve: Curves.easeOut)),
    );
    _bodySlide = Tween<Offset>(
      begin: const Offset(0, 0.05), end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entranceController,
        curve: const Interval(0.15, 0.80, curve: Curves.easeOutCubic)));

    Future.delayed(const Duration(milliseconds: 60), () {
      if (mounted) {
        _entranceController.forward();
        if (_isCreate) {
          Future.delayed(const Duration(milliseconds: 250), () {
            if (mounted) _titleFocus.requestFocus();
          });
        }
      }
    });

    _titleController.addListener(() => setState(() {}));
    _contentController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _titleFocus.dispose();
    _contentFocus.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // MARK: — ACTIONS
  // ─────────────────────────────────────────────

  void _handleSave() async {
    if (!_canSave || _isSaving) return;
    FocusScope.of(context).unfocus();
    HapticFeedback.mediumImpact();

    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 180));

    final now = DateTime.now();
    final saved = widget.note?.copyWith(
          title:        _titleController.text.trim(),
          content:      _contentController.text,
          lastModified: now,
        ) ??
        PersonalNote(
          id:            'note_${now.millisecondsSinceEpoch}',
          title:         _titleController.text.trim(),
          content:       _contentController.text,
          lastModified:  now,
          createdAt:     now,
          linkedContentId: widget.linkedContentId,
        );

    if (mounted) setState(() => _isSaving = false);
    widget.onSave?.call(saved);
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
      context: context,
      barrierColor: Colors.black.withOpacity(0.40),
      builder: (ctx) => _DiscardDialog(isDark: dark),
    );
    return result ?? false;
  }

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
      extendBodyBehindAppBar: true,
      backgroundColor: dark
          ? AppColors.darkBackground
          : const Color(0xFFFFFEFA),
      resizeToAvoidBottomInset: true,
      appBar: _buildAppBar(dark),
      body: Stack(
        fit: StackFit.expand,
        children: [
          _EditorBackground(isDark: dark),
          FadeTransition(
            opacity: _bodyFade,
            child: SlideTransition(
              position: _bodySlide,
              child: _buildBody(dark),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // MARK: — APP BAR
  // ─────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(bool dark) {
    final accent = dark ? AppColors.accentLight : AppColors.accent;

    return GlassAppBar(
      titleWidget: FadeTransition(
        opacity: _appBarFade,
        child: Text(
          _isCreate ? 'New Note' : 'Edit Note',
          style: AppTypography.titleMedium.copyWith(
            color: dark
                ? AppColors.darkPrimaryText
                : AppColors.lightPrimaryText,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      leading: FadeTransition(
        opacity: _appBarFade,
        child: _CancelButton(isDark: dark, onTap: _handleCancel),
      ),
      actions: [
        FadeTransition(
          opacity: _appBarFade,
          child: Padding(
            padding: const EdgeInsets.only(right: AppSpacing.base),
            child: _SaveButton(
              isDark:    dark,
              canSave:   _canSave,
              isLoading: _isSaving,
              accent:    accent,
              onTap:     _handleSave,
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // MARK: — BODY
  // ─────────────────────────────────────────────

  Widget _buildBody(bool dark) {
    final textColor = dark
        ? AppColors.darkPrimaryText
        : AppColors.lightPrimaryText;
    final secondaryColor = dark
        ? AppColors.darkSecondaryText
        : AppColors.lightSecondaryText;
    final topPad = MediaQuery.of(context).padding.top + kToolbarHeight;

    return Column(
      children: [
        SizedBox(height: topPad + AppSpacing.base),

        // ── Linked content chip ───────────────────
        if (widget.linkedContentTitle != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.md,
            ),
            child: _LinkedContentChip(
              title:  widget.linkedContentTitle!,
              isDark: dark,
            ),
          ),

        // ── Title field ───────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: TextField(
            controller:      _titleController,
            focusNode:       _titleFocus,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.sentences,
            onSubmitted:     (_) => _contentFocus.requestFocus(),
            maxLines:        null,
            style: AppTypography.headlineLarge.copyWith(
              color:       textColor,
              fontWeight:  FontWeight.w700,
              letterSpacing: -0.4,
              height:      1.25,
            ),
            decoration: InputDecoration(
              hintText: 'Title',
              hintStyle: AppTypography.headlineLarge.copyWith(
                color:      secondaryColor.withOpacity(0.45),
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
              ),
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // ── Separator ─────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Divider(
            height: 0.5, thickness: 0.5,
            color: AnimatedContainer(
              duration: AppAnimation.standard,
              color: _titleFocused
                  ? (dark ? AppColors.accentLight : AppColors.accent)
                      .withOpacity(0.50)
                  : (dark ? AppColors.darkSeparator : AppColors.lightSeparator),
            ).decoration.toString() == '' ? AppColors.lightSeparator
                : (dark ? AppColors.darkSeparator : AppColors.lightSeparator),
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // ── Content field ─────────────────────────
        Expanded(
          child: GestureDetector(
            onTap: () => _contentFocus.requestFocus(),
            behavior: HitTestBehavior.translucent,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xl,
                0,
                AppSpacing.xl,
                MediaQuery.of(context).padding.bottom + AppSpacing.xxxl + 60,
              ),
              child: TextField(
                controller: _contentController,
                focusNode:  _contentFocus,
                maxLines:   null,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(
                  fontFamily:    'Georgia',
                  fontSize:      AppReader.baseFontSize,
                  height:        AppReader.lineHeight,
                  letterSpacing: 0.10,
                  fontWeight:    FontWeight.w400,
                ).merge(TextStyle(
                  color: textColor,
                )),
                decoration: InputDecoration(
                  hintText: 'Start writing your note…',
                  hintStyle: const TextStyle(
                    fontFamily: 'Georgia',
                    fontSize:   AppReader.baseFontSize,
                    height:     AppReader.lineHeight,
                    fontStyle:  FontStyle.italic,
                  ).merge(TextStyle(
                    color: secondaryColor.withOpacity(0.40),
                  )),
                ),
              ),
            ),
          ),
        ),

        // ── Footer: word count ────────────────────
        _buildFooter(dark, secondaryColor),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // MARK: — FOOTER
  // ─────────────────────────────────────────────

  Widget _buildFooter(bool dark, Color secondaryColor) {
    final botPad = MediaQuery.of(context).padding.bottom;

    return AnimatedOpacity(
      duration: AppAnimation.standard,
      opacity:  _contentFocused ? 1.0 : 0.55,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, botPad + AppSpacing.sm,
        ),
        child: Row(
          children: [
            Text(
              '$_wordCount word${_wordCount != 1 ? 's' : ''}',
              style: AppTypography.caption.copyWith(
                color: secondaryColor,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Container(
              width: 3, height: 3,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: secondaryColor.withOpacity(0.4),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              '$_charCount char${_charCount != 1 ? 's' : ''}',
              style: AppTypography.caption.copyWith(
                color: secondaryColor,
              ),
            ),
            const Spacer(),
            if (widget.note != null)
              Text(
                'Edited ${_relativeDate(widget.note!.lastModified)}',
                style: AppTypography.caption.copyWith(
                  color: secondaryColor,
                  fontSize: 10.5,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MARK: — CANCEL BUTTON
// ─────────────────────────────────────────────

class _CancelButton extends StatefulWidget {
  final bool isDark;
  final AsyncCallback onTap;
  const _CancelButton({required this.isDark, required this.onTap});

  @override
  State<_CancelButton> createState() => _CancelButtonState();
}

class _CancelButtonState extends State<_CancelButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _press;
  late Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 120),
        reverseDuration: const Duration(milliseconds: 200));
    _scale = Tween<double>(begin: 1.0, end: 0.90)
        .animate(CurvedAnimation(parent: _press, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _press.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => ScaleTransition(
        scale: _scale,
        child: GestureDetector(
          onTapDown:   (_) => _press.forward(),
          onTapUp:     (_) { _press.reverse(); widget.onTap(); },
          onTapCancel: () => _press.reverse(),
          child: Padding(
            padding: const EdgeInsets.only(left: AppSpacing.base),
            child: Text(
              'Cancel',
              style: AppTypography.bodyMedium.copyWith(
                fontFamily: null,
                color:      AppColors.error,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      );
}

// ─────────────────────────────────────────────
// MARK: — SAVE BUTTON
// ─────────────────────────────────────────────

class _SaveButton extends StatefulWidget {
  final bool       isDark;
  final bool       canSave;
  final bool       isLoading;
  final Color      accent;
  final VoidCallback onTap;

  const _SaveButton({
    required this.isDark,
    required this.canSave,
    required this.isLoading,
    required this.accent,
    required this.onTap,
  });

  @override
  State<_SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<_SaveButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _press;
  late Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 110),
        reverseDuration: const Duration(milliseconds: 200));
    _scale = Tween<double>(begin: 1.0, end: 0.90)
        .animate(CurvedAnimation(parent: _press, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _press.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final color = widget.canSave ? widget.accent : widget.accent.withOpacity(0.35);

    return IgnorePointer(
      ignoring: !widget.canSave || widget.isLoading,
      child: ScaleTransition(
        scale: _scale,
        child: GestureDetector(
          onTapDown:   (_) => _press.forward(),
          onTapUp:     (_) { _press.reverse(); widget.onTap(); HapticFeedback.lightImpact(); },
          onTapCancel: () => _press.reverse(),
          child: widget.isLoading
              ? SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: color),
                )
              : Text(
                  'Save',
                  style: AppTypography.bodyMedium.copyWith(
                    fontFamily: null,
                    color:      color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MARK: — LINKED CONTENT CHIP
// ─────────────────────────────────────────────

class _LinkedContentChip extends StatelessWidget {
  final String title;
  final bool isDark;

  const _LinkedContentChip({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final accent = isDark ? AppColors.accentLight : AppColors.accent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color:        accent.withOpacity(isDark ? 0.12 : 0.08),
        borderRadius: AppRadius.chip,
        border:       Border.all(color: accent.withOpacity(0.22), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.link_rounded, size: 12, color: accent),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              title,
              style: AppTypography.labelSmall.copyWith(
                color:      accent,
                fontWeight: FontWeight.w600,
                fontSize:   11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MARK: — DISCARD DIALOG
// ─────────────────────────────────────────────

class _DiscardDialog extends StatelessWidget {
  final bool isDark;
  const _DiscardDialog({required this.isDark});

  @override
  Widget build(BuildContext context) => Dialog(
        backgroundColor:  Colors.transparent,
        elevation:        0,
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
                  Text('Discard Changes?',
                    style: AppTypography.titleMedium.copyWith(
                      color: isDark
                          ? AppColors.darkPrimaryText
                          : AppColors.lightPrimaryText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Your unsaved changes will be lost.',
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.darkSecondaryText
                          : AppColors.lightSecondaryText,
                      fontFamily: null,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    children: [
                      Expanded(
                        child: _DialogButton(
                          label:     'Keep Editing',
                          isPrimary: false,
                          isDark:    isDark,
                          onTap:     () => Navigator.of(context).pop(false),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _DialogButton(
                          label:     'Discard',
                          isPrimary: true,
                          isDark:    isDark,
                          isError:   true,
                          onTap:     () => Navigator.of(context).pop(true),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

class _DialogButton extends StatefulWidget {
  final String label;
  final bool isPrimary;
  final bool isDark;
  final bool isError;
  final VoidCallback onTap;

  const _DialogButton({
    required this.label,
    required this.isPrimary,
    required this.isDark,
    required this.onTap,
    this.isError = false,
  });

  @override
  State<_DialogButton> createState() => _DialogButtonState();
}

class _DialogButtonState extends State<_DialogButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.isError ? AppColors.error : AppColors.accent;

    return GestureDetector(
      onTapDown:   (_) => setState(() => _pressed = true),
      onTapUp:     (_) { setState(() => _pressed = false); HapticFeedback.lightImpact(); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 80),
        opacity: _pressed ? 0.60 : 1.0,
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: widget.isPrimary
                ? color
                : color.withOpacity(widget.isDark ? 0.12 : 0.08),
            borderRadius: AppRadius.mdAll,
          ),
          child: Center(
            child: Text(
              widget.label,
              style: AppTypography.labelMedium.copyWith(
                color: widget.isPrimary
                    ? Colors.white
                    : color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MARK: — BACKGROUND
// ─────────────────────────────────────────────

class _EditorBackground extends StatelessWidget {
  final bool isDark;
  const _EditorBackground({required this.isDark});

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end:   Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF0D1117), const Color(0xFF121212)]
                : [const Color(0xFFFFFEFA), const Color(0xFFFFFFFF)],
          ),
        ),
      );
}

// ─────────────────────────────────────────────
// MARK: — DATE HELPER
// ─────────────────────────────────────────────

String _relativeDate(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1)  return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours   < 24) return '${diff.inHours}h ago';
  if (diff.inDays    == 1) return 'yesterday';
  if (diff.inDays    <  7) return '${diff.inDays} days ago';
  return '${date.day}/${date.month}/${date.year}';
}