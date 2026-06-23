// lib/features/bookmarks/my_notes_bookmarks_screen.dart
// Law Briefly — My Notes & Bookmarks Screen
// iOS 18 Liquid Glass | Riverpod | Real Isar Data | Full Navigation

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../bookmarks/data/models/bookmark_entity.dart';
import '../bookmarks/providers/bookmark_provider.dart';
import '../notes/data/models/note_entity.dart';
import '../notes/providers/note_provider.dart';
import '../notes/note_editor_screen.dart';
import '../reader/reader_screen.dart';

// ─────────────────────────────────────────────
// MARK: — BOOKMARK TYPE (UI)
// ─────────────────────────────────────────────

enum BookmarkType {
  article('Article',  Color(0xFF1C4ED8)),
  section('Section',  Color(0xFF7C3AED)),
  caseLaw('Case Law', Color(0xFFF59E0B));

  final String label;
  final Color  color;
  const BookmarkType(this.label, this.color);
}

// ─────────────────────────────────────────────
// MARK: — UI MODELS (display layer only)
// ─────────────────────────────────────────────

class BookmarkItem {
  final String       id;
  final String       title;
  final String       subtitle;
  final BookmarkType type;
  final String       sourceId;
  final String       sourceName;
  final String?      sectionRef;
  final DateTime     savedAt;

  const BookmarkItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.sourceId,
    required this.sourceName,
    this.sectionRef,
    required this.savedAt,
  });
}

class PersonalNote {
  final String   id;
  final String   title;
  final String   content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;
  final bool     isPinned;
  final String?  linkedSectionId;
  final String?  linkedActId;

  const PersonalNote({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.tags            = const [],
    this.isPinned        = false,
    this.linkedSectionId,
    this.linkedActId,
  });

  String get preview {
    final clean = content.replaceAll('\n', ' ').trim();
    return clean.length > 130 ? '${clean.substring(0, 130)}…' : clean;
  }
}

// ─────────────────────────────────────────────
// MARK: — ENTITY → UI MODEL MAPPERS
// ─────────────────────────────────────────────

BookmarkItem _entityToBookmarkItem(BookmarkEntity e) {
  final type = switch (e.type) {
    'actSection'          => BookmarkType.section,
    'constitutionArticle' => BookmarkType.article,
    _                     => BookmarkType.section,
  };
  return BookmarkItem(
    id:         e.contentId,
    title:      e.title,
    subtitle:   e.source,
    type:       type,
    sourceId:   e.contentId,
    sourceName: e.source,
    savedAt:    e.createdAt,
  );
}

PersonalNote _entityToPersonalNote(NoteEntity e) => PersonalNote(
      id:        e.id.toString(),
      title:     e.title,
      content:   e.content,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
    );

// ─────────────────────────────────────────────
// MARK: — DATE HELPER
// ─────────────────────────────────────────────

String _relativeDate(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1)  return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours   < 24) return '${diff.inHours}h ago';
  if (diff.inDays    == 1) return 'Yesterday';
  if (diff.inDays    <  7) return '${diff.inDays} days ago';
  if (diff.inDays    < 30) return '${(diff.inDays / 7).floor()}w ago';
  return '${date.day}/${date.month}/${date.year}';
}

// ─────────────────────────────────────────────
// MARK: — SCREEN
// ─────────────────────────────────────────────

class MyNotesBookmarksScreen extends ConsumerStatefulWidget {
  const MyNotesBookmarksScreen({super.key});

  @override
  ConsumerState<MyNotesBookmarksScreen> createState() =>
      _MyNotesBookmarksScreenState();
}

class _MyNotesBookmarksScreenState
    extends ConsumerState<MyNotesBookmarksScreen>
    with TickerProviderStateMixin {

  int _selectedTab = 0;

  late AnimationController _entranceController;
  late AnimationController _fabController;

  late Animation<double> _appBarFade;
  late Animation<double> _segmentFade;
  late Animation<Offset>  _segmentSlide;
  late Animation<double> _contentFade;
  late Animation<double> _fabScale;

  // ─────────────────────────────────────────────
  // MARK: — LIFECYCLE
  // ─────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startEntrance();
  }

  void _setupAnimations() {
    _entranceController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fabController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));

    _appBarFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceController,
          curve: const Interval(0.00, 0.38, curve: Curves.easeOut)));
    _segmentFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceController,
          curve: const Interval(0.12, 0.50, curve: Curves.easeOut)));
    _segmentSlide = Tween<Offset>(
        begin: const Offset(0, -0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceController,
          curve: const Interval(0.12, 0.52, curve: Curves.easeOutCubic)));
    _contentFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceController,
          curve: const Interval(0.30, 0.75, curve: Curves.easeOut)));
    _fabScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.elasticOut));
  }

  void _startEntrance() {
    Future.delayed(const Duration(milliseconds: 60), () {
      if (!mounted) return;
      _entranceController.forward();
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) _fabController.forward();
      });
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // MARK: — TAB SWITCH
  // ─────────────────────────────────────────────

  void _switchTab(int index) {
    if (_selectedTab == index) return;
    HapticFeedback.selectionClick();
    setState(() => _selectedTab = index);
    if (index == 1) _fabController.forward();
    else _fabController.reverse();
  }

  // ─────────────────────────────────────────────
  // MARK: — BOOKMARK NAVIGATION
  // ─────────────────────────────────────────────

  void _handleBookmarkTap(BookmarkEntity entity) {
    HapticFeedback.lightImpact();

    final route = PageRouteBuilder(
      pageBuilder: (ctx, anim, _) {
        if (entity.type == 'actSection') {
          return ReaderScreen.actSection(
            // source stores the actId (e.g. "bns_2023")
            actId:       entity.source,
            sectionId:   entity.contentId,
            sourceTitle: entity.title,
          );
        } else {
          return ReaderScreen.constitutionArticle(
            // source stores the partId (e.g. "part_1")
            partId:      entity.source,
            articleId:   entity.contentId,
            sourceTitle: entity.title,
          );
        }
      },
      transitionDuration: const Duration(milliseconds: 380),
      transitionsBuilder: (ctx, anim, _, child) => SlideTransition(
        position: Tween<Offset>(
                begin: const Offset(1, 0), end: Offset.zero)
            .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
        child: child,
      ),
    );

    Navigator.of(context, rootNavigator: true).push(route);
  }

  // ─────────────────────────────────────────────
  // MARK: — NOTE NAVIGATION
  // ─────────────────────────────────────────────

  void _openNoteEditor({NoteEntity? existingEntity}) {
    HapticFeedback.mediumImpact();

    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        pageBuilder: (ctx, anim, _) => NoteEditorScreen(
          existingNote: existingEntity,
          onSave: (title, content) async {
            if (existingEntity == null) {
              await ref.read(noteControllerProvider.notifier).createNote(
                  title: title, content: content);
            } else {
              await ref.read(noteControllerProvider.notifier).updateNote(
                  existing: existingEntity, title: title, content: content);
            }
            if (context.mounted) Navigator.of(context).pop();
          },
          onCancel: () {
            if (context.mounted) Navigator.of(context).pop();
          },
        ),
        transitionDuration: const Duration(milliseconds: 380),
        transitionsBuilder: (ctx, anim, _, child) => SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
              .animate(
                  CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // MARK: — DELETE NOTE
  // ─────────────────────────────────────────────

  void _deleteNote(int entityId) {
    HapticFeedback.lightImpact();
    ref.read(noteControllerProvider.notifier).deleteNote(entityId);
  }

  // ─────────────────────────────────────────────
  // MARK: — BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(
        dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor:
          dark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: _buildAppBar(dark),
      body: Stack(
        fit: StackFit.expand,
        children: [
          _NotesBackground(isDark: dark),
          Column(
            children: [
              SizedBox(
                  height: MediaQuery.of(context).padding.top + kToolbarHeight),

              // Segmented control
              FadeTransition(
                opacity: _segmentFade,
                child: SlideTransition(
                  position: _segmentSlide,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl, AppSpacing.base,
                        AppSpacing.xl, AppSpacing.sm),
                    child: _SegmentedControl(
                        selected: _selectedTab,
                        onChanged: _switchTab,
                        isDark: dark),
                  ),
                ),
              ),

              // Tab content
              Expanded(
                child: FadeTransition(
                  opacity: _contentFade,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    switchInCurve:  Curves.easeOutCubic,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                                begin: const Offset(0.04, 0), end: Offset.zero)
                            .animate(anim),
                        child: child,
                      ),
                    ),
                    child: KeyedSubtree(
                      key: ValueKey(_selectedTab),
                      child: _selectedTab == 0
                          ? _buildBookmarksTab(dark)
                          : _buildNotesTab(dark),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // FAB
          Positioned(
            right:  AppSpacing.xl,
            bottom: MediaQuery.of(context).padding.bottom + AppSpacing.xl,
            child: ScaleTransition(
              scale: _fabScale,
              child: _GlassFAB(
                  isDark: dark,
                  onTap:  () => _openNoteEditor()),
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
          child: Text('My Notes & Bookmarks',
            style: AppTypography.titleLarge.copyWith(
              color:      dark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
            maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        leading: FadeTransition(
          opacity: _appBarFade,
          child: _GlassBackButton(isDark: dark),
        ),
        actions: [
          FadeTransition(
            opacity: _appBarFade,
            child: Padding(
              padding: const EdgeInsets.only(right: AppSpacing.base),
              child: Center(child: _GlassSearchButton(isDark: dark)),
            ),
          ),
        ],
      );

  // ─────────────────────────────────────────────
  // MARK: — BOOKMARKS TAB (Real Isar Data)
  // ─────────────────────────────────────────────

  Widget _buildBookmarksTab(bool dark) {
    final state = ref.watch(bookmarkControllerProvider);

    // ── Loading ─────────────────────────────────
    if (state.isLoading) {
      return _TabLoadingState(isDark: dark);
    }

    // ── Error ────────────────────────────────────
    if (state.hasError) {
      return _TabErrorState(
        isDark:   dark,
        message:  state.error ?? 'Failed to load bookmarks.',
        onRetry:  () => ref.read(bookmarkControllerProvider.notifier).loadBookmarks(),
      );
    }

    // ── Empty ────────────────────────────────────
    if (state.bookmarks.isEmpty) {
      return _EmptyState(
        icon:   Icons.bookmark_border_rounded,
        title:  'No Bookmarks Yet',
        body:   'Bookmark sections and articles\nfrom the reader to find them here.',
        isDark: dark,
      );
    }

    // ── Success ───────────────────────────────────
    final entities = state.bookmarks;
    final items    = entities.map(_entityToBookmarkItem).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ListHeader(label: '${items.length} Saved', isDark: dark),
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl, AppSpacing.xs, AppSpacing.xl, AppSpacing.max),
            itemCount: items.length,
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _BookmarkCard(
                item:  items[i],
                isDark: dark,
                onTap: () => _handleBookmarkTap(entities[i]),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // MARK: — NOTES TAB (Real Isar Data)
  // ─────────────────────────────────────────────

  Widget _buildNotesTab(bool dark) {
    final state = ref.watch(noteControllerProvider);

    // ── Loading ─────────────────────────────────
    if (state.isLoading) {
      return _TabLoadingState(isDark: dark);
    }

    // ── Error ────────────────────────────────────
    if (state.hasError) {
      return _TabErrorState(
        isDark:  dark,
        message: state.error ?? 'Failed to load notes.',
        onRetry: () => ref.read(noteControllerProvider.notifier).loadNotes(),
      );
    }

    // ── Empty ────────────────────────────────────
    if (state.notes.isEmpty) {
      return _EmptyState(
        icon:   Icons.edit_note_rounded,
        title:  'No Notes Yet',
        body:   'Tap the + button below to\ncreate your first note.',
        isDark: dark,
      );
    }

    // ── Success ───────────────────────────────────
    final sorted = [...state.notes]
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final personalNotes = sorted.map(_entityToPersonalNote).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ListHeader(
          label: '${sorted.length} Note${sorted.length != 1 ? "s" : ""}',
          isDark: dark,
        ),
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl, AppSpacing.xs, AppSpacing.xl, 120),
            itemCount: sorted.length,
            itemBuilder: (context, i) {
              final entity = sorted[i];
              final note   = personalNotes[i];

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Dismissible(
                  key:       Key('note_${entity.id}'),
                  direction: DismissDirection.endToStart,
                  background: _SwipDeleteBackground(isDark: dark),
                  confirmDismiss: (_) async {
                    HapticFeedback.mediumImpact();
                    return true;
                  },
                  onDismissed: (_) => _deleteNote(entity.id),
                  child: _NoteCard(
                    note:     note,
                    isDark:   dark,
                    onEdit:   () => _openNoteEditor(existingEntity: entity),
                    onDelete: () => _deleteNote(entity.id),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════
// MARK: — TAB LOADING STATE
// ═════════════════════════════════════════════

class _TabLoadingState extends StatefulWidget {
  final bool isDark;
  const _TabLoadingState({required this.isDark});

  @override
  State<_TabLoadingState> createState() => _TabLoadingStateState();
}

class _TabLoadingStateState extends State<_TabLoadingState>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Animation<double>   _opacity;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 1400))..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.28, end: 0.78)
        .animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
  }

  @override void dispose() { _pulse.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: List.generate(4, (i) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: FadeTransition(
            opacity: _opacity,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color:        baseColor,
                borderRadius: AppRadius.card,
              ),
            ),
          ),
        )),
      ),
    );
  }
}

// ═════════════════════════════════════════════
// MARK: — TAB ERROR STATE
// ═════════════════════════════════════════════

class _TabErrorState extends StatelessWidget {
  final bool       isDark;
  final String     message;
  final VoidCallback onRetry;

  const _TabErrorState({
    required this.isDark,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final secColor = isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color:        AppColors.error.withOpacity(isDark ? 0.14 : 0.08),
                borderRadius: AppRadius.lgAll,
              ),
              child: const Icon(Icons.error_outline_rounded, size: 26, color: AppColors.error),
            ),
            const SizedBox(height: AppSpacing.base),
            Text(message,
              style: AppTypography.bodySmall.copyWith(
                  fontFamily: null, color: secColor, height: 1.5),
              textAlign: TextAlign.center,
              maxLines: 3),
            const SizedBox(height: AppSpacing.xl),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
                decoration: BoxDecoration(
                  color:        AppColors.error,
                  borderRadius: AppRadius.button,
                ),
                child: Text('Retry', style: AppTypography.labelMedium.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════
// MARK: — SEGMENTED CONTROL (unchanged)
// ═════════════════════════════════════════════

class _SegmentedControl extends StatelessWidget {
  final int selected; final ValueChanged<int> onChanged; final bool isDark;

  static const List<String> _labels = ['Bookmarks', 'Notes'];
  static const double _height       = 42.0;
  static const double _padding      = 4.0;

  const _SegmentedControl({required this.selected, required this.onChanged,
      required this.isDark});

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: AppRadius.pillAll,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: AppBlur.md, sigmaY: AppBlur.md),
          child: Container(
            height: _height,
            decoration: BoxDecoration(
              color: isDark ? const Color(0x331C1C1E) : const Color(0x26F2F2F7),
              borderRadius: AppRadius.pillAll,
              border: Border.all(
                color: isDark ? const Color(0x1AFFFFFF) : const Color(0x18000000),
                width: 0.5),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final segW = (constraints.maxWidth - _padding * 2) / _labels.length;
                return Stack(children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 240),
                    curve:    Curves.easeOutCubic,
                    left:     _padding + selected * segW,
                    top: _padding, bottom: _padding, width: segW,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0x50FFFFFF) : Colors.white,
                        borderRadius: BorderRadius.circular((_height - _padding * 2) / 2),
                        boxShadow: [BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.30 : 0.10),
                          blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                    ),
                  ),
                  Row(
                    children: List.generate(_labels.length, (i) => Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap:    () => onChanged(i),
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: AppTypography.labelMedium.copyWith(
                              color: i == selected
                                  ? (isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText)
                                  : (isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText),
                              fontWeight: i == selected ? FontWeight.w700 : FontWeight.w400,
                              fontSize: 14,
                            ),
                            child: Text(_labels[i]),
                          ),
                        ),
                      ),
                    )),
                  ),
                ]);
              },
            ),
          ),
        ),
      );
}

// ═════════════════════════════════════════════
// MARK: — LIST HEADER (unchanged)
// ═════════════════════════════════════════════

class _ListHeader extends StatelessWidget {
  final String label; final bool isDark;
  const _ListHeader({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.xs),
        child: Text(label, style: AppTypography.labelSmall.copyWith(
          color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
          letterSpacing: 0.1, fontSize: 11.5)));
}

// ═════════════════════════════════════════════
// MARK: — BOOKMARK CARD (unchanged)
// ═════════════════════════════════════════════

class _BookmarkCard extends StatefulWidget {
  final BookmarkItem item; final bool isDark; final VoidCallback onTap;
  const _BookmarkCard({required this.item, required this.isDark, required this.onTap});
  @override State<_BookmarkCard> createState() => _BookmarkCardState();
}

class _BookmarkCardState extends State<_BookmarkCard> {
  bool _pressed = false;

  IconData _iconForType(BookmarkType type) => switch (type) {
        BookmarkType.article => Icons.balance_rounded,
        BookmarkType.section => Icons.menu_book_outlined,
        BookmarkType.caseLaw => Icons.gavel_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final dark   = widget.isDark;
    final item   = widget.item;
    final accent = item.type.color;

    return GestureDetector(
      behavior:    HitTestBehavior.opaque,
      onTapDown:   (_) { setState(() => _pressed = true); HapticFeedback.selectionClick(); },
      onTapUp:     (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: ClipRRect(
        borderRadius: AppRadius.card,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: AppBlur.md, sigmaY: AppBlur.md),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 90),
            decoration: BoxDecoration(
              color: _pressed
                  ? (dark ? const Color(0xBF252525) : const Color(0xBFFAFAFA))
                  : (dark ? const Color(0x991C1C1E) : const Color(0xCCFFFFFF)),
              borderRadius: AppRadius.card,
              border:       Border.all(
                color: dark ? const Color(0x1AFFFFFF) : const Color(0x33FFFFFF), width: 0.5),
              boxShadow: dark ? AppShadows.darkGlass : AppShadows.lightGlass,
            ),
            child: Stack(children: [
              Positioned(left: 0, top: 0, bottom: 0, width: 3,
                child: Container(decoration: BoxDecoration(
                  color: accent.withOpacity(0.75),
                  borderRadius: const BorderRadius.only(
                    topLeft:    Radius.circular(AppRadius.xxl),
                    bottomLeft: Radius.circular(AppRadius.xxl))))),
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.base, AppSpacing.base, AppSpacing.base),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(width: 36, height: 36,
                    decoration: BoxDecoration(
                      color:        accent.withOpacity(dark ? 0.15 : 0.10),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border:       Border.all(color: accent.withOpacity(dark ? 0.25 : 0.18), width: 0.5)),
                    child: Icon(_iconForType(item.type), size: 18, color: accent)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                      Text(item.title,
                        style: AppTypography.titleSmall.copyWith(
                          color:      dark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                          fontWeight: FontWeight.w600, height: 1.3),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 5),
                      Text(item.subtitle,
                        style: AppTypography.caption.copyWith(
                          color:    dark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                          height:   1.4, fontSize: 11),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(_relativeDate(item.savedAt),
                        style: AppTypography.caption.copyWith(
                          color:    dark ? AppColors.darkTertiaryText : AppColors.lightTertiaryText,
                          fontSize: 10.5)),
                    ]),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.end, children: [
                    _TypeChip(type: item.type, isDark: dark),
                    const SizedBox(height: 8),
                    Icon(Icons.chevron_right_rounded, size: 16,
                      color: dark ? AppColors.darkTertiaryText : AppColors.lightTertiaryText),
                  ]),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final BookmarkType type; final bool isDark;
  const _TypeChip({required this.type, required this.isDark});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color:        type.color.withOpacity(isDark ? 0.15 : 0.10),
      borderRadius: BorderRadius.circular(5),
      border:       Border.all(color: type.color.withOpacity(isDark ? 0.25 : 0.18), width: 0.5)),
    child: Text(type.label, style: AppTypography.labelSmall.copyWith(
      color: type.color, fontSize: 9.5, fontWeight: FontWeight.w700, letterSpacing: 0.2)));
}

// ═════════════════════════════════════════════
// MARK: — NOTE CARD (unchanged)
// ═════════════════════════════════════════════

class _NoteCard extends StatefulWidget {
  final PersonalNote note; final bool isDark;
  final VoidCallback onEdit; final VoidCallback onDelete;
  const _NoteCard({required this.note, required this.isDark,
      required this.onEdit, required this.onDelete});
  @override State<_NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<_NoteCard> {
  bool _showDeleteConfirm = false;

  @override
  Widget build(BuildContext context) {
    final dark = widget.isDark;
    final note = widget.note;

    return ClipRRect(
      borderRadius: AppRadius.card,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: AppBlur.md, sigmaY: AppBlur.md),
        child: Container(
          decoration: BoxDecoration(
            color: dark ? const Color(0x991C1C1E) : const Color(0xCCFFFFFF),
            borderRadius: AppRadius.card,
            border:       Border.all(
              color: dark ? const Color(0x1AFFFFFF) : const Color(0x33FFFFFF), width: 0.5),
            boxShadow: dark ? AppShadows.darkGlass : AppShadows.lightGlass,
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.base, AppSpacing.base, AppSpacing.base, AppSpacing.sm),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (note.isPinned) ...[
                    Padding(padding: const EdgeInsets.only(top: 2),
                      child: Icon(Icons.push_pin_rounded, size: 13,
                        color: dark ? AppColors.accentLight : AppColors.accent)),
                    const SizedBox(width: 5),
                  ],
                  Expanded(
                    child: Text(note.title,
                      style: AppTypography.headlineSmall.copyWith(
                        color:      dark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                        fontWeight: FontWeight.w700, fontSize: 15, letterSpacing: -0.15, height: 1.25),
                      maxLines: 1, overflow: TextOverflow.ellipsis)),
                ]),
                const SizedBox(height: 7),
                Text(note.preview,
                  style: AppTypography.bodySmall.copyWith(
                    fontFamily: 'Georgia',
                    color:      dark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                    height:     1.55, fontSize: 13.5),
                  maxLines: 3, overflow: TextOverflow.ellipsis),
                if (note.tags.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(spacing: AppSpacing.xs,
                    children: note.tags.take(3)
                        .map((t) => _TagChip(label: t, isDark: dark)).toList()),
                ],
              ]),
            ),
            Divider(height: 0.5, thickness: 0.5,
              color: dark ? AppColors.darkSeparator : AppColors.lightSeparator),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.base, AppSpacing.sm, AppSpacing.sm, AppSpacing.sm),
              child: Row(children: [
                Text('Edited ${_relativeDate(note.updatedAt)}',
                  style: AppTypography.caption.copyWith(
                    color: dark ? AppColors.darkTertiaryText : AppColors.lightTertiaryText,
                    fontSize: 11)),
                const Spacer(),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _showDeleteConfirm
                      ? Row(key: const ValueKey('confirm'), children: [
                          _NoteActionButton(icon: Icons.close_rounded, label: 'Cancel',
                            color: dark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                            isDark: dark, onTap: () => setState(() => _showDeleteConfirm = false)),
                          const SizedBox(width: AppSpacing.xs),
                          _NoteActionButton(icon: Icons.delete_rounded, label: 'Delete',
                            color: AppColors.error, isDark: dark, onTap: widget.onDelete),
                        ])
                      : Row(key: const ValueKey('actions'), children: [
                          _NoteActionButton(icon: Icons.edit_outlined, label: 'Edit',
                            color: dark ? AppColors.accentLight : AppColors.accent,
                            isDark: dark, onTap: widget.onEdit),
                          const SizedBox(width: AppSpacing.xs),
                          _NoteActionButton(icon: Icons.delete_outline_rounded, label: 'Delete',
                            color: AppColors.error, isDark: dark,
                            onTap: () => setState(() => _showDeleteConfirm = true)),
                        ]),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class _NoteActionButton extends StatefulWidget {
  final IconData icon; final String label; final Color color; final bool isDark;
  final VoidCallback onTap;
  const _NoteActionButton({required this.icon, required this.label,
      required this.color, required this.isDark, required this.onTap});
  @override State<_NoteActionButton> createState() => _NoteActionButtonState();
}

class _NoteActionButtonState extends State<_NoteActionButton> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown:   (_) => setState(() => _pressed = true),
    onTapUp:     (_) { setState(() => _pressed = false); HapticFeedback.lightImpact(); widget.onTap(); },
    onTapCancel: () => setState(() => _pressed = false),
    child: AnimatedOpacity(duration: const Duration(milliseconds: 80),
      opacity: _pressed ? 0.55 : 1.0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color:        widget.color.withOpacity(widget.isDark ? 0.12 : 0.08),
          borderRadius: BorderRadius.circular(8)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(widget.icon, size: 12, color: widget.color),
          const SizedBox(width: 3),
          Text(widget.label, style: AppTypography.labelSmall.copyWith(
            color: widget.color, fontSize: 11, fontWeight: FontWeight.w600)),
        ]))));
}

class _TagChip extends StatelessWidget {
  final String label; final bool isDark;
  const _TagChip({required this.label, required this.isDark});
  @override
  Widget build(BuildContext context) => Container(
    margin:  const EdgeInsets.only(bottom: 4),
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color:        isDark ? const Color(0x1AFFFFFF) : const Color(0x0D000000),
      borderRadius: BorderRadius.circular(5)),
    child: Text(label, style: AppTypography.labelSmall.copyWith(
      fontSize: 10,
      color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText)));
}

// ═════════════════════════════════════════════
// MARK: — SWIPE DELETE BACKGROUND (unchanged)
// ═════════════════════════════════════════════

class _SwipDeleteBackground extends StatelessWidget {
  final bool isDark;
  const _SwipDeleteBackground({required this.isDark});
  @override
  Widget build(BuildContext context) => Container(
    alignment:  Alignment.centerRight,
    margin:     const EdgeInsets.only(bottom: AppSpacing.md),
    decoration: BoxDecoration(
      color:        AppColors.error.withOpacity(isDark ? 0.18 : 0.12),
      borderRadius: AppRadius.card),
    padding: const EdgeInsets.only(right: AppSpacing.xl),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 22),
      const SizedBox(height: 4),
      Text('Delete', style: AppTypography.labelSmall.copyWith(
        color: AppColors.error, fontWeight: FontWeight.w600, fontSize: 11)),
    ]));
}

// ═════════════════════════════════════════════
// MARK: — EMPTY STATE (unchanged)
// ═════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  final IconData icon; final String title, body; final bool isDark;
  const _EmptyState({required this.icon, required this.title,
      required this.body, required this.isDark});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(padding: const EdgeInsets.all(AppSpacing.xxxl),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 64, height: 64,
          decoration: BoxDecoration(
            color:        isDark ? const Color(0x1AFFFFFF) : const Color(0x0D000000),
            borderRadius: AppRadius.lgAll),
          child: Icon(icon, size: 28,
            color: isDark ? AppColors.darkTertiaryText : AppColors.lightTertiaryText)),
        const SizedBox(height: AppSpacing.xl),
        Text(title, style: AppTypography.headlineSmall.copyWith(
          color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
          fontWeight: FontWeight.w700)),
        const SizedBox(height: AppSpacing.sm),
        Text(body, style: AppTypography.bodySmall.copyWith(
          fontFamily: 'Georgia',
          color:      isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
          height:     1.6),
          textAlign: TextAlign.center),
      ])));
}

// ═════════════════════════════════════════════
// MARK: — GLASS FAB (unchanged)
// ═════════════════════════════════════════════

class _GlassFAB extends StatefulWidget {
  final bool isDark; final VoidCallback onTap;
  const _GlassFAB({required this.isDark, required this.onTap});
  @override State<_GlassFAB> createState() => _GlassFABState();
}

class _GlassFABState extends State<_GlassFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _press; late Animation<double> _scale;
  @override
  void initState() {
    super.initState();
    _press = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 130),
        reverseDuration: const Duration(milliseconds: 220));
    _scale = Tween<double>(begin: 1.0, end: 0.91)
        .animate(CurvedAnimation(parent: _press, curve: Curves.easeInOut));
  }
  @override void dispose() { _press.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => ScaleTransition(scale: _scale,
    child: GestureDetector(
      onTapDown:   (_) => _press.forward(),
      onTapUp:     (_) { _press.reverse(); widget.onTap(); },
      onTapCancel: () => _press.reverse(),
      child: ClipRRect(
        borderRadius: AppRadius.pillAll,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: AppBlur.lg, sigmaY: AppBlur.lg),
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [AppColors.accentLight, AppColors.accent]),
              borderRadius: AppRadius.pillAll,
              boxShadow: [BoxShadow(
                color: AppColors.accent.withOpacity(0.40),
                blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.add_rounded, size: 20, color: Colors.white),
              const SizedBox(width: 6),
              Text('New Note', style: AppTypography.labelMedium.copyWith(
                color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
            ])))));
}

// ═════════════════════════════════════════════
// MARK: — NAV BUTTONS (unchanged)
// ═════════════════════════════════════════════

class _GlassBackButton extends StatefulWidget {
  final bool isDark;
  const _GlassBackButton({required this.isDark});
  @override State<_GlassBackButton> createState() => _GlassBackButtonState();
}
class _GlassBackButtonState extends State<_GlassBackButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _press; late Animation<double> _scale;
  @override
  void initState() {
    super.initState();
    _press = AnimationController(vsync: this, duration: const Duration(milliseconds: 120),
        reverseDuration: const Duration(milliseconds: 200));
    _scale = Tween<double>(begin: 1.0, end: 0.90)
        .animate(CurvedAnimation(parent: _press, curve: Curves.easeInOut));
  }
  @override void dispose() { _press.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => ScaleTransition(scale: _scale,
    child: GestureDetector(
      onTapDown:   (_) => _press.forward(),
      onTapUp:     (_) { _press.reverse(); HapticFeedback.lightImpact(); Navigator.of(context).maybePop(); },
      onTapCancel: () => _press.reverse(),
      child: Container(width: 34, height: 34,
        margin: const EdgeInsets.only(left: AppSpacing.sm),
        decoration: BoxDecoration(shape: BoxShape.circle,
          color: widget.isDark ? const Color(0x33FFFFFF) : const Color(0x1A000000)),
        child: Icon(Icons.arrow_back_ios_rounded, size: 15,
          color: widget.isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText))));
}

class _GlassSearchButton extends StatefulWidget {
  final bool isDark;
  const _GlassSearchButton({required this.isDark});
  @override State<_GlassSearchButton> createState() => _GlassSearchButtonState();
}
class _GlassSearchButtonState extends State<_GlassSearchButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _press; late Animation<double> _scale;
  @override
  void initState() {
    super.initState();
    _press = AnimationController(vsync: this, duration: const Duration(milliseconds: 120),
        reverseDuration: const Duration(milliseconds: 200));
    _scale = Tween<double>(begin: 1.0, end: 0.90)
        .animate(CurvedAnimation(parent: _press, curve: Curves.easeInOut));
  }
  @override void dispose() { _press.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => ScaleTransition(scale: _scale,
    child: GestureDetector(
      onTapDown:   (_) => _press.forward(),
      onTapUp:     (_) { _press.reverse(); HapticFeedback.lightImpact(); },
      onTapCancel: () => _press.reverse(),
      child: Container(width: 34, height: 34,
        decoration: BoxDecoration(shape: BoxShape.circle,
          color: widget.isDark ? const Color(0x33FFFFFF) : const Color(0x1A000000)),
        child: Icon(Icons.search_rounded, size: 17,
          color: widget.isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText))));
}

// ═════════════════════════════════════════════
// MARK: — BACKGROUND (unchanged)
// ═════════════════════════════════════════════

class _NotesBackground extends StatelessWidget {
  final bool isDark;
  const _NotesBackground({required this.isDark});
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: isDark
            ? [const Color(0xFF0D1117), const Color(0xFF121212), const Color(0xFF0C0D14)]
            : [const Color(0xFFF8F5FF), const Color(0xFFFFFFFF), const Color(0xFFF5F8FF)],
      )),
    child: Stack(children: [
      Positioned(top: -80, right: -50,
        child: _Orb(size: 260, color: AppColors.accent.withOpacity(isDark ? 0.07 : 0.04))),
      Positioned(bottom: -100, left: -40,
        child: _Orb(size: 240, color: AppColors.gold.withOpacity(isDark ? 0.06 : 0.04))),
    ]));
}

class _Orb extends StatelessWidget {
  final double size; final Color color;
  const _Orb({required this.size, required this.color});
  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: Container(width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]))));
}