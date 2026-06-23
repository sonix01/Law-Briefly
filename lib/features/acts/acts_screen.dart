// lib/features/acts/acts_screen.dart
// Law Briefly — Acts Screen
// iOS 18 Liquid Glass | Offline-First | GoRouter Navigation

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../app/app_router.dart' show RouteNames, RouteParams;

// ─────────────────────────────────────────────
// MARK: — ACT DETAIL NAV ARGS
// Lightweight payload passed via GoRouter `extra`
// so ActDetailScreen receives actTitle/year alongside
// the actId path parameter.
// ─────────────────────────────────────────────

class ActDetailNavArgs {
  final String actTitle;
  final int    year;

  const ActDetailNavArgs({
    required this.actTitle,
    required this.year,
  });
}

// ─────────────────────────────────────────────
// MARK: — ACT CATEGORY
// ─────────────────────────────────────────────

enum ActCategory {
  criminal('Criminal Law',    Color(0xFFEF4444)),
  civil('Civil Law',          Color(0xFF3B82F6)),
  constitutional('Constitutional', Color(0xFF7C3AED)),
  commercial('Commercial',    Color(0xFFF59E0B)),
  evidence('Evidence',        Color(0xFF6366F1)),
  digital('Digital & IT',     Color(0xFF10B981)),
  consumer('Consumer',        Color(0xFFEC4899)),
  property('Property Law',    Color(0xFF8B5CF6)),
  general('General',          Color(0xFF6B7280));

  final String label;
  final Color color;
  const ActCategory(this.label, this.color);
}

// ─────────────────────────────────────────────
// MARK: — ACT MODEL (JSON-ready / ISAR-ready)
// ─────────────────────────────────────────────

class ActModel {
  final String id;
  final String name;
  final int year;
  final String? shortName;
  final ActCategory category;
  final int chapterCount;
  final int sectionCount;

  const ActModel({
    required this.id,
    required this.name,
    required this.year,
    this.shortName,
    required this.category,
    required this.chapterCount,
    required this.sectionCount,
  });

  factory ActModel.fromJson(Map<String, dynamic> json) => ActModel(
        id: json['id'] as String,
        name: json['name'] as String,
        year: json['year'] as int,
        shortName: json['short_name'] as String?,
        category: ActCategory.values.firstWhere(
          (c) => c.name == (json['category'] as String? ?? 'general'),
          orElse: () => ActCategory.general,
        ),
        chapterCount: json['chapter_count'] as int? ?? 0,
        sectionCount: json['section_count'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'year': year,
        'short_name': shortName,
        'category': category.name,
        'chapter_count': chapterCount,
        'section_count': sectionCount,
      };

  bool matchesQuery(String query) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return true;
    return name.toLowerCase().contains(q) ||
        (shortName?.toLowerCase().contains(q) ?? false) ||
        year.toString().contains(q) ||
        category.label.toLowerCase().contains(q);
  }
}

// ─────────────────────────────────────────────
// MARK: — MOCK DATA (Replace with ISAR / JSON)
// ─────────────────────────────────────────────

abstract final class MockActsData {
  static const List<ActModel> all = [
    ActModel(
      id: 'bns_2023',
      name: 'Bharatiya Nyaya Sanhita',
      year: 2023,
      shortName: 'BNS',
      category: ActCategory.criminal,
      chapterCount: 20,
      sectionCount: 358,
    ),
    ActModel(
      id: 'bsa_2023',
      name: 'Bharatiya Sakshya Adhiniyam',
      year: 2023,
      shortName: 'BSA',
      category: ActCategory.evidence,
      chapterCount: 12,
      sectionCount: 170,
    ),
    ActModel(
      id: 'bnss_2023',
      name: 'Bharatiya Nagarik Suraksha Sanhita',
      year: 2023,
      shortName: 'BNSS',
      category: ActCategory.criminal,
      chapterCount: 37,
      sectionCount: 531,
    ),
    ActModel(
      id: 'ica_1872',
      name: 'Indian Contract Act',
      year: 1872,
      shortName: 'ICA',
      category: ActCategory.commercial,
      chapterCount: 10,
      sectionCount: 238,
    ),
    ActModel(
      id: 'iea_1872',
      name: 'Indian Evidence Act',
      year: 1872,
      shortName: 'IEA',
      category: ActCategory.evidence,
      chapterCount: 11,
      sectionCount: 167,
    ),
    ActModel(
      id: 'cpc_1908',
      name: 'Code of Civil Procedure',
      year: 1908,
      shortName: 'CPC',
      category: ActCategory.civil,
      chapterCount: 47,
      sectionCount: 158,
    ),
    ActModel(
      id: 'crpc_1973',
      name: 'Code of Criminal Procedure',
      year: 1973,
      shortName: 'CrPC',
      category: ActCategory.criminal,
      chapterCount: 37,
      sectionCount: 484,
    ),
    ActModel(
      id: 'tpa_1882',
      name: 'Transfer of Property Act',
      year: 1882,
      shortName: 'TPA',
      category: ActCategory.property,
      chapterCount: 8,
      sectionCount: 137,
    ),
    ActModel(
      id: 'sra_1963',
      name: 'Specific Relief Act',
      year: 1963,
      shortName: 'SRA',
      category: ActCategory.civil,
      chapterCount: 6,
      sectionCount: 44,
    ),
    ActModel(
      id: 'la_1963',
      name: 'Limitation Act',
      year: 1963,
      shortName: 'LA',
      category: ActCategory.civil,
      chapterCount: 4,
      sectionCount: 32,
    ),
    ActModel(
      id: 'companies_2013',
      name: 'Companies Act',
      year: 2013,
      shortName: 'CA',
      category: ActCategory.commercial,
      chapterCount: 29,
      sectionCount: 470,
    ),
    ActModel(
      id: 'it_2000',
      name: 'Information Technology Act',
      year: 2000,
      shortName: 'IT Act',
      category: ActCategory.digital,
      chapterCount: 14,
      sectionCount: 90,
    ),
    ActModel(
      id: 'consumer_2019',
      name: 'Consumer Protection Act',
      year: 2019,
      shortName: 'CPA',
      category: ActCategory.consumer,
      chapterCount: 8,
      sectionCount: 107,
    ),
    ActModel(
      id: 'rti_2005',
      name: 'Right to Information Act',
      year: 2005,
      shortName: 'RTI',
      category: ActCategory.constitutional,
      chapterCount: 6,
      sectionCount: 31,
    ),
    ActModel(
      id: 'pocso_2012',
      name: 'Protection of Children from Sexual Offences Act',
      year: 2012,
      shortName: 'POCSO',
      category: ActCategory.criminal,
      chapterCount: 6,
      sectionCount: 46,
    ),
    ActModel(
      id: 'ipc_1860',
      name: 'Indian Penal Code',
      year: 1860,
      shortName: 'IPC',
      category: ActCategory.criminal,
      chapterCount: 23,
      sectionCount: 511,
    ),
    ActModel(
      id: 'arbitration_1996',
      name: 'Arbitration and Conciliation Act',
      year: 1996,
      shortName: 'ACA',
      category: ActCategory.civil,
      chapterCount: 10,
      sectionCount: 86,
    ),
    ActModel(
      id: 'ndps_1985',
      name: 'Narcotic Drugs and Psychotropic Substances Act',
      year: 1985,
      shortName: 'NDPS',
      category: ActCategory.criminal,
      chapterCount: 6,
      sectionCount: 82,
    ),
    ActModel(
      id: 'negotiable_1881',
      name: 'Negotiable Instruments Act',
      year: 1881,
      shortName: 'NI Act',
      category: ActCategory.commercial,
      chapterCount: 17,
      sectionCount: 147,
    ),
    ActModel(
      id: 'registration_1908',
      name: 'Registration Act',
      year: 1908,
      shortName: 'RA',
      category: ActCategory.property,
      chapterCount: 12,
      sectionCount: 93,
    ),
  ];
}

// ─────────────────────────────────────────────
// MARK: — ACTS SCREEN
// ─────────────────────────────────────────────

class ActsScreen extends StatefulWidget {
  final ValueChanged<ActModel>? onActTap;

  const ActsScreen({super.key, this.onActTap});

  @override
  State<ActsScreen> createState() => _ActsScreenState();
}

class _ActsScreenState extends State<ActsScreen> with TickerProviderStateMixin {

  // ── Controllers ───────────────────────────────
  final TextEditingController _searchController = TextEditingController();
  final FocusNode             _searchFocus      = FocusNode();
  final ScrollController      _scrollController = ScrollController();
  late  AnimationController   _entranceController;

  // ── State ─────────────────────────────────────
  String _searchQuery       = '';
  bool   _searchFocused     = false;
  bool   _entranceDone      = false;

  // ── Stagger config ────────────────────────────
  static const int _maxStagger = 14;

  // ── Animations ────────────────────────────────
  late Animation<double> _appBarFade;
  late Animation<double> _searchFade;
  late Animation<Offset>  _searchSlide;
  late Animation<double> _headerFade;
  late List<Animation<double>> _itemFades;
  late List<Animation<Offset>>  _itemSlides;

  // ── Derived ───────────────────────────────────
  List<ActModel> get _filteredActs {
    if (_searchQuery.isEmpty) return MockActsData.all;
    return MockActsData.all.where((a) => a.matchesQuery(_searchQuery)).toList();
  }

  bool get _isSearchActive => _searchQuery.isNotEmpty;

  // ─────────────────────────────────────────────
  // MARK: — LIFECYCLE
  // ─────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupListeners();
    _startEntrance();
  }

  void _setupAnimations() {
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _appBarFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.00, 0.38, curve: Curves.easeOut),
      ),
    );

    _searchFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.10, 0.45, curve: Curves.easeOut),
      ),
    );
    _searchSlide = Tween<Offset>(
      begin: const Offset(0, -0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.10, 0.50, curve: Curves.easeOutCubic),
      ),
    );

    _headerFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.20, 0.52, curve: Curves.easeOut),
      ),
    );

    _itemFades = List.generate(_maxStagger, (i) {
      final s = (0.24 + i * 0.05).clamp(0.0, 0.88);
      final e = (s + 0.26).clamp(0.0, 1.0);
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _entranceController,
          curve: Interval(s, e, curve: Curves.easeOut),
        ),
      );
    });

    _itemSlides = List.generate(_maxStagger, (i) {
      final s = (0.24 + i * 0.05).clamp(0.0, 0.88);
      final e = (s + 0.30).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 0.07),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _entranceController,
          curve: Interval(s, e, curve: Curves.easeOutCubic),
        ),
      );
    });
  }

  void _setupListeners() {
    _searchController.addListener(() {
      final q = _searchController.text;
      if (q != _searchQuery) setState(() => _searchQuery = q);
    });

    _searchFocus.addListener(() {
      setState(() => _searchFocused = _searchFocus.hasFocus);
    });
  }

  void _startEntrance() {
    Future.delayed(const Duration(milliseconds: 60), () {
      if (!mounted) return;
      _entranceController.forward().then((_) {
        if (mounted) setState(() => _entranceDone = true);
      });
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // MARK: — HELPERS
  // ─────────────────────────────────────────────

  void _clearSearch() {
    HapticFeedback.selectionClick();
    _searchController.clear();
    _searchFocus.unfocus();
  }

  // ─────────────────────────────────────────────
  // MARK: — ACT TAP → NAVIGATE TO ACT DETAIL
  // ─────────────────────────────────────────────

  void _handleActTap(ActModel act) {
    HapticFeedback.lightImpact();

    // Notify external listener if provided (e.g. analytics)
    widget.onActTap?.call(act);

    // Navigate to ActDetailScreen via GoRouter.
    // actId travels as a path parameter; actTitle (and year)
    // travel as typed `extra` payload.
    context.pushNamed(
      RouteNames.actDetail,
      pathParameters: {RouteParams.actId: act.id},
      extra: ActDetailNavArgs(
        actTitle: act.name,
        year:     act.year,
      ),
    );
  }

  Animation<double> _itemFadeAt(int i) {
    if (_isSearchActive || _entranceDone) {
      return const AlwaysStoppedAnimation<double>(1.0);
    }
    return _itemFades[i.clamp(0, _maxStagger - 1)];
  }

  Animation<Offset> _itemSlideAt(int i) {
    if (_isSearchActive || _entranceDone) {
      return const AlwaysStoppedAnimation<Offset>(Offset.zero);
    }
    return _itemSlides[i.clamp(0, _maxStagger - 1)];
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
      backgroundColor:
          dark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: _buildAppBar(dark),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background ──────────────────────────
          _ActsBackground(isDark: dark),

          // ── Foreground content ──────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AppBar spacer
              SizedBox(
                height: MediaQuery.of(context).padding.top + kToolbarHeight,
              ),

              // Search bar
              FadeTransition(
                opacity: _searchFade,
                child: SlideTransition(
                  position: _searchSlide,
                  child: _GlassSearchBar(
                    controller: _searchController,
                    focusNode: _searchFocus,
                    isFocused: _searchFocused,
                    isDark: dark,
                    onClear: _clearSearch,
                  ),
                ),
              ),

              // List header
              FadeTransition(
                opacity: _headerFade,
                child: _ListHeader(
                  acts: _filteredActs,
                  query: _searchQuery,
                  isDark: dark,
                ),
              ),

              const SizedBox(height: AppSpacing.xs),

              // Acts list
              Expanded(child: _buildList(dark)),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // MARK: — APP BAR
  // ─────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(bool dark) {
    final acts = _filteredActs;
    return GlassAppBar(
      title: 'Acts',
      leading: FadeTransition(
        opacity: _appBarFade,
        child: _GlassBackButton(isDark: dark),
      ),
      actions: [
        FadeTransition(
          opacity: _appBarFade,
          child: Padding(
            padding: const EdgeInsets.only(right: AppSpacing.base),
            child: Center(
              child: _CountBadge(count: acts.length, isDark: dark),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // MARK: — LIST
  // ─────────────────────────────────────────────

  Widget _buildList(bool dark) {
    final acts = _filteredActs;

    if (acts.isEmpty) {
      return _EmptyState(query: _searchQuery, isDark: dark);
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.sm,
        AppSpacing.xl,
        AppSpacing.max,
      ),
      itemCount: acts.length,
      itemBuilder: (context, i) {
        final act = acts[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: FadeTransition(
            opacity: _itemFadeAt(i),
            child: SlideTransition(
              position: _itemSlideAt(i),
              child: _ActCard(
                act: act,
                isDark: dark,
                onTap: () => _handleActTap(act),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// MARK: — GLASS SEARCH BAR
// ─────────────────────────────────────────────

class _GlassSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFocused;
  final bool isDark;
  final VoidCallback onClear;

  const _GlassSearchBar({
    required this.controller,
    required this.focusNode,
    required this.isFocused,
    required this.isDark,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor =
        isDark ? AppColors.accentLight : AppColors.accent;
    final borderColor = isFocused
        ? accentColor
        : (isDark
            ? const Color(0x26FFFFFF)
            : const Color(0x1A000000));

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl, AppSpacing.base, AppSpacing.xl, AppSpacing.xs,
      ),
      child: ClipRRect(
        borderRadius: AppRadius.pillAll,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: AppBlur.md, sigmaY: AppBlur.md),
          child: AnimatedContainer(
            duration: AppAnimation.standard,
            curve: AppAnimation.easeInOut,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0x261C1C1E)
                  : const Color(0x26F2F2F7),
              borderRadius: AppRadius.pillAll,
              border: Border.all(
                color: borderColor,
                width: isFocused ? 1.0 : 0.5,
              ),
              boxShadow: isFocused
                  ? [
                      BoxShadow(
                        color: AppColors.accent.withOpacity(0.10),
                        blurRadius: 14,
                      ),
                    ]
                  : null,
            ),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              textInputAction: TextInputAction.search,
              keyboardType: TextInputType.text,
              style: AppTypography.bodySmall.copyWith(
                fontFamily: null,
                color: isDark
                    ? AppColors.darkPrimaryText
                    : AppColors.lightPrimaryText,
                height: 1.4,
              ),
              decoration: InputDecoration(
                hintText: 'Search Acts...',
                hintStyle: AppTypography.bodySmall.copyWith(
                  fontFamily: null,
                  color: isDark
                      ? AppColors.darkTertiaryText
                      : AppColors.lightTertiaryText,
                ),
                prefixIcon: AnimatedContainer(
                  duration: AppAnimation.standard,
                  child: Icon(
                    Icons.search_rounded,
                    size: 18,
                    color: isFocused
                        ? accentColor
                        : (isDark
                            ? AppColors.darkSecondaryText
                            : AppColors.lightSecondaryText),
                  ),
                ),
                suffixIcon: controller.text.isNotEmpty
                    ? GestureDetector(
                        onTap: onClear,
                        child: Icon(
                          Icons.cancel_rounded,
                          size: 18,
                          color: isDark
                              ? AppColors.darkTertiaryText
                              : AppColors.lightTertiaryText,
                        ),
                      )
                    : null,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.md,
                  horizontal: 4,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MARK: — LIST HEADER
// ─────────────────────────────────────────────

class _ListHeader extends StatelessWidget {
  final List<ActModel> acts;
  final String query;
  final bool isDark;

  const _ListHeader({
    required this.acts,
    required this.query,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.xs,
        ),
        child: AnimatedSwitcher(
          duration: AppAnimation.fast,
          child: Row(
            key: ValueKey(query.isEmpty ? 'all' : query),
            children: [
              Text(
                query.isEmpty
                    ? '${acts.length} Acts'
                    : '${acts.length} result${acts.length != 1 ? 's' : ''}'
                        ' for "$query"',
                style: AppTypography.labelSmall.copyWith(
                  color: isDark
                      ? AppColors.darkSecondaryText
                      : AppColors.lightSecondaryText,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      );
}

// ─────────────────────────────────────────────
// MARK: — ACT CARD
// ─────────────────────────────────────────────

class _ActCard extends StatefulWidget {
  final ActModel act;
  final bool isDark;
  final VoidCallback onTap;

  const _ActCard({
    required this.act,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_ActCard> createState() => _ActCardState();
}

class _ActCardState extends State<_ActCard>
    with SingleTickerProviderStateMixin {

  late AnimationController _press;
  late Animation<double> _scale;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 130),
      reverseDuration: const Duration(milliseconds: 240),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.974).animate(
      CurvedAnimation(parent: _press, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    _press.forward();
    setState(() => _isPressed = true);
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails _) {
    _press.reverse();
    setState(() => _isPressed = false);
    widget.onTap();
  }

  void _onTapCancel() {
    _press.reverse();
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final dark = widget.isDark;
    final act  = widget.act;
    final cat  = act.category;

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: ClipRRect(
          borderRadius: AppRadius.card,
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: AppBlur.md,
              sigmaY: AppBlur.md,
              tileMode: TileMode.mirror,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 130),
              decoration: BoxDecoration(
                color: _isPressed
                    ? (dark
                        ? const Color(0xBF252525)
                        : const Color(0xBFFAFAFA))
                    : (dark
                        ? const Color(0x991C1C1E)
                        : const Color(0xCCFFFFFF)),
                borderRadius: AppRadius.card,
                border: Border.all(
                  color: dark
                      ? const Color(0x1AFFFFFF)
                      : const Color(0x33FFFFFF),
                  width: 0.5,
                ),
                boxShadow:
                    dark ? AppShadows.darkGlass : AppShadows.lightGlass,
              ),
              child: Stack(
                children: [
                  // ── Left category strip ──────────
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: 3.5,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: cat.color.withOpacity(0.75),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(AppRadius.xxl),
                          bottomLeft: Radius.circular(AppRadius.xxl),
                        ),
                      ),
                    ),
                  ),

                  // ── Top highlight ────────────────
                  Positioned(
                    top: 0,
                    left: AppRadius.xxl,
                    right: AppRadius.xxl,
                    child: Container(
                      height: 0.5,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.white.withOpacity(dark ? 0.12 : 0.60),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── Card content ─────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.base,
                      AppSpacing.base,
                      AppSpacing.base,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // ── Text area ──────────────
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Name
                              Text(
                                act.name,
                                style: AppTypography.titleMedium.copyWith(
                                  color: dark
                                      ? AppColors.darkPrimaryText
                                      : AppColors.lightPrimaryText,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.15,
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),

                              const SizedBox(height: 7),

                              // Meta row
                              Row(
                                children: [
                                  _CategoryChip(
                                    label: cat.label,
                                    color: cat.color,
                                    isDark: dark,
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  _MetaDot(isDark: dark),
                                  const SizedBox(width: AppSpacing.sm),
                                  Text(
                                    '${act.sectionCount} sections',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: dark
                                          ? AppColors.darkTertiaryText
                                          : AppColors.lightTertiaryText,
                                      fontSize: 10.5,
                                    ),
                                  ),
                                  if (act.shortName != null) ...[
                                    const SizedBox(width: AppSpacing.sm),
                                    _MetaDot(isDark: dark),
                                    const SizedBox(width: AppSpacing.sm),
                                    Text(
                                      act.shortName!,
                                      style:
                                          AppTypography.labelSmall.copyWith(
                                        color: dark
                                            ? AppColors.darkTertiaryText
                                            : AppColors.lightTertiaryText,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: AppSpacing.sm),

                        // ── Right: Year + Chevron ──
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              act.year.toString(),
                              style: AppTypography.labelSmall.copyWith(
                                color: dark
                                    ? AppColors.darkSecondaryText
                                    : AppColors.lightSecondaryText,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.3,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: cat.color.withOpacity(
                                  dark ? 0.14 : 0.10,
                                ),
                              ),
                              child: Icon(
                                Icons.chevron_right_rounded,
                                size: 15,
                                color: cat.color.withOpacity(0.80),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MARK: — CATEGORY CHIP
// ─────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isDark;

  const _CategoryChip({
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(isDark ? 0.16 : 0.10),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: color.withOpacity(isDark ? 0.28 : 0.18),
            width: 0.5,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      );
}

// ─────────────────────────────────────────────
// MARK: — META DOT
// ─────────────────────────────────────────────

class _MetaDot extends StatelessWidget {
  final bool isDark;
  const _MetaDot({required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
        width: 3,
        height: 3,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark
              ? AppColors.darkTertiaryText
              : AppColors.lightTertiaryText,
        ),
      );
}

// ─────────────────────────────────────────────
// MARK: — COUNT BADGE
// ─────────────────────────────────────────────

class _CountBadge extends StatelessWidget {
  final int count;
  final bool isDark;

  const _CountBadge({required this.count, required this.isDark});

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
        duration: AppAnimation.fast,
        child: Container(
          key: ValueKey(count),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: AppColors.accentMuted,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            count.toString(),
            style: AppTypography.labelSmall.copyWith(
              color: isDark ? AppColors.accentLight : AppColors.accent,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      );
}

// ─────────────────────────────────────────────
// MARK: — GLASS BACK BUTTON
// ─────────────────────────────────────────────

class _GlassBackButton extends StatefulWidget {
  final bool isDark;
  const _GlassBackButton({required this.isDark});

  @override
  State<_GlassBackButton> createState() => _GlassBackButtonState();
}

class _GlassBackButtonState extends State<_GlassBackButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _press;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.90).animate(
      CurvedAnimation(parent: _press, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ScaleTransition(
        scale: _scale,
        child: GestureDetector(
          onTapDown: (_) => _press.forward(),
          onTapUp: (_) {
            _press.reverse();
            HapticFeedback.lightImpact();
            Navigator.of(context).maybePop();
          },
          onTapCancel: () => _press.reverse(),
          child: Container(
            width: 34,
            height: 34,
            margin: const EdgeInsets.only(left: AppSpacing.sm),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.isDark
                  ? const Color(0x33FFFFFF)
                  : const Color(0x1A000000),
            ),
            child: Icon(
              Icons.arrow_back_ios_rounded,
              size: 15,
              color: widget.isDark
                  ? AppColors.darkPrimaryText
                  : AppColors.lightPrimaryText,
            ),
          ),
        ),
      );
}

// ─────────────────────────────────────────────
// MARK: — EMPTY STATE
// ─────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String query;
  final bool isDark;

  const _EmptyState({required this.query, required this.isDark});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0x1AFFFFFF)
                      : const Color(0x0D000000),
                  borderRadius: AppRadius.lgAll,
                ),
                child: Icon(
                  Icons.search_off_rounded,
                  size: 28,
                  color: isDark
                      ? AppColors.darkTertiaryText
                      : AppColors.lightTertiaryText,
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              Text(
                'No Acts Found',
                style: AppTypography.headlineSmall.copyWith(
                  color: isDark
                      ? AppColors.darkPrimaryText
                      : AppColors.lightPrimaryText,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              Text(
                'No results for "$query".\nTry searching by act name,\nshort name, or year.',
                style: AppTypography.bodySmall.copyWith(
                  fontFamily: 'Georgia',
                  color: isDark
                      ? AppColors.darkSecondaryText
                      : AppColors.lightSecondaryText,
                  height: 1.65,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
}

// ─────────────────────────────────────────────
// MARK: — BACKGROUND
// ─────────────────────────────────────────────

class _ActsBackground extends StatelessWidget {
  final bool isDark;
  const _ActsBackground({required this.isDark});

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF0D1117),
                    const Color(0xFF121212),
                    const Color(0xFF0A0E1A),
                  ]
                : [
                    const Color(0xFFF5F6FF),
                    const Color(0xFFFFFFFF),
                    const Color(0xFFF0F2FF),
                  ],
          ),
        ),
        child: Stack(
          children: [
            // Top-right orb
            Positioned(
              top: -80,
              right: -60,
              child: _Orb(
                size: 260,
                color: isDark
                    ? AppColors.accent.withOpacity(0.08)
                    : AppColors.accent.withOpacity(0.04),
              ),
            ),
            // Bottom-left orb
            Positioned(
              bottom: -100,
              left: -40,
              child: _Orb(
                size: 240,
                color: isDark
                    ? const Color(0xFF7C3AED).withOpacity(0.06)
                    : const Color(0xFF7C3AED).withOpacity(0.03),
              ),
            ),
          ],
        ),
      );
}

class _Orb extends StatelessWidget {
  final double size;
  final Color color;
  const _Orb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color, Colors.transparent],
            ),
          ),
        ),
      );
}