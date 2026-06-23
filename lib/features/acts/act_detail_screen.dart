// lib/features/acts/act_detail_screen.dart
// Law Briefly — Act Detail Screen
// iOS 18 Liquid Glass | Accordion Chapters | GoRouter Navigation

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../app/app_router.dart' show AppNavigation, ActReaderArgs;

// ─────────────────────────────────────────────
// MARK: — SECTION MODEL (JSON / ISAR ready)
// ─────────────────────────────────────────────

class SectionModel {
  final String id;
  final int number;
  final String title;

  const SectionModel({
    required this.id,
    required this.number,
    required this.title,
  });

  factory SectionModel.fromJson(Map<String, dynamic> json) => SectionModel(
        id: json['id'] as String,
        number: json['number'] as int,
        title: json['title'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'number': number,
        'title': title,
      };
}

// ─────────────────────────────────────────────
// MARK: — CHAPTER MODEL
// ─────────────────────────────────────────────

class ChapterModel {
  final String id;
  final int number;
  final String romanNumeral;
  final String name;
  final int firstSection;
  final int lastSection;
  final List<SectionModel> sections;

  const ChapterModel({
    required this.id,
    required this.number,
    required this.romanNumeral,
    required this.name,
    required this.firstSection,
    required this.lastSection,
    required this.sections,
  });

  String get displayTitle => 'Chapter $romanNumeral \u2013 $name';

  String get sectionRange => firstSection == lastSection
      ? 'Sec. $firstSection'
      : 'Sec. $firstSection\u2013$lastSection';

  factory ChapterModel.fromJson(Map<String, dynamic> json) => ChapterModel(
        id: json['id'] as String,
        number: json['number'] as int,
        romanNumeral: json['roman_numeral'] as String,
        name: json['name'] as String,
        firstSection: json['first_section'] as int,
        lastSection: json['last_section'] as int,
        sections: (json['sections'] as List<dynamic>)
            .map((s) => SectionModel.fromJson(s as Map<String, dynamic>))
            .toList(),
      );
}

// ─────────────────────────────────────────────
// MARK: — ACT DETAIL MODEL
// ─────────────────────────────────────────────

class ActDetailModel {
  final String actId;
  final String actName;
  final int year;
  final List<ChapterModel> chapters;

  const ActDetailModel({
    required this.actId,
    required this.actName,
    required this.year,
    required this.chapters,
  });

  int get totalSections =>
      chapters.fold(0, (sum, c) => sum + c.sections.length);

  factory ActDetailModel.fromJson(Map<String, dynamic> json) => ActDetailModel(
        actId: json['act_id'] as String,
        actName: json['act_name'] as String,
        year: json['year'] as int,
        chapters: (json['chapters'] as List<dynamic>)
            .map((c) => ChapterModel.fromJson(c as Map<String, dynamic>))
            .toList(),
      );
}

// ─────────────────────────────────────────────
// MARK: — MOCK DATA (Replace with ISAR / JSON)
// ─────────────────────────────────────────────

abstract final class MockActDetailData {
  static ActDetailModel getForAct({
    required String actId,
    required String actName,
    required int year,
  }) =>
      ActDetailModel(
        actId: actId,
        actName: actName,
        year: year,
        chapters: _chapters,
      );

  static const List<ChapterModel> _chapters = [
    ChapterModel(
      id: 'ch_1', number: 1, romanNumeral: 'I',
      name: 'Preliminary',
      firstSection: 1, lastSection: 4,
      sections: [
        SectionModel(id: 's_1',  number: 1, title: 'Short title, extent and commencement'),
        SectionModel(id: 's_2',  number: 2, title: 'Definitions'),
        SectionModel(id: 's_3',  number: 3, title: 'Construction of references to enactments'),
        SectionModel(id: 's_4',  number: 4, title: 'Saving of certain laws and rights'),
      ],
    ),
    ChapterModel(
      id: 'ch_2', number: 2, romanNumeral: 'II',
      name: 'General Explanations',
      firstSection: 5, lastSection: 15,
      sections: [
        SectionModel(id: 's_5',  number: 5,  title: 'Act includes illegal omission'),
        SectionModel(id: 's_6',  number: 6,  title: 'Effect of this Act on persons bound by law'),
        SectionModel(id: 's_7',  number: 7,  title: 'Liability of several persons — common intention'),
        SectionModel(id: 's_8',  number: 8,  title: 'Liability where several persons have common object'),
        SectionModel(id: 's_9',  number: 9,  title: 'Intention to frighten or alarm public'),
        SectionModel(id: 's_10', number: 10, title: 'Man, Woman and Person'),
        SectionModel(id: 's_11', number: 11, title: 'Public and member of public'),
        SectionModel(id: 's_12', number: 12, title: 'Movable property'),
        SectionModel(id: 's_13', number: 13, title: 'Good faith and reason to believe'),
        SectionModel(id: 's_14', number: 14, title: 'Court of Justice'),
        SectionModel(id: 's_15', number: 15, title: 'Judge'),
      ],
    ),
    ChapterModel(
      id: 'ch_3', number: 3, romanNumeral: 'III',
      name: 'Punishments',
      firstSection: 16, lastSection: 28,
      sections: [
        SectionModel(id: 's_16', number: 16, title: 'Punishments'),
        SectionModel(id: 's_17', number: 17, title: 'Commutation of sentence of death'),
        SectionModel(id: 's_18', number: 18, title: 'Sentence of death not to be passed on certain persons'),
        SectionModel(id: 's_19', number: 19, title: 'Sentence of imprisonment for life'),
        SectionModel(id: 's_20', number: 20, title: 'Sentence of imprisonment — fine in default'),
        SectionModel(id: 's_21', number: 21, title: 'Amount of fine — liability of offender'),
        SectionModel(id: 's_22', number: 22, title: 'Limit of imprisonment for non-payment of fine'),
        SectionModel(id: 's_23', number: 23, title: 'Community service'),
        SectionModel(id: 's_24', number: 24, title: 'Fractions of terms of imprisonment'),
        SectionModel(id: 's_25', number: 25, title: 'Imprisonment when offender is already sentenced'),
        SectionModel(id: 's_26', number: 26, title: 'Solitary confinement'),
        SectionModel(id: 's_27', number: 27, title: 'Limit of solitary confinement'),
        SectionModel(id: 's_28', number: 28, title: 'Enhanced punishment for subsequent offences'),
      ],
    ),
    ChapterModel(
      id: 'ch_4', number: 4, romanNumeral: 'IV',
      name: 'General Exceptions',
      firstSection: 29, lastSection: 52,
      sections: [
        SectionModel(id: 's_29', number: 29, title: 'Act done by a person bound by law'),
        SectionModel(id: 's_30', number: 30, title: 'Act of Judge when acting judicially'),
        SectionModel(id: 's_31', number: 31, title: 'Act done pursuant to judgment or order of Court'),
        SectionModel(id: 's_32', number: 32, title: 'Act done by a person justified by law'),
        SectionModel(id: 's_33', number: 33, title: 'Accident in doing a lawful act'),
        SectionModel(id: 's_34', number: 34, title: 'Act likely to cause harm done without criminal intent'),
        SectionModel(id: 's_35', number: 35, title: 'Act of a child under seven years of age'),
        SectionModel(id: 's_36', number: 36, title: 'Act of a child above seven and under twelve'),
        SectionModel(id: 's_37', number: 37, title: 'Act of a person of unsound mind'),
        SectionModel(id: 's_38', number: 38, title: 'Act of intoxicated person'),
        SectionModel(id: 's_39', number: 39, title: 'Offence committed by person incapable of intent'),
        SectionModel(id: 's_40', number: 40, title: 'Mistake of fact'),
        SectionModel(id: 's_41', number: 41, title: 'Act not known to be likely to cause death or grievous hurt'),
        SectionModel(id: 's_42', number: 42, title: 'Consent of the sufferer'),
        SectionModel(id: 's_43', number: 43, title: 'Act not intended to cause death or grievous hurt'),
        SectionModel(id: 's_44', number: 44, title: 'Act done in good faith for benefit of a person without consent'),
        SectionModel(id: 's_45', number: 45, title: 'Act done in good faith for benefit of child or insane person'),
        SectionModel(id: 's_46', number: 46, title: 'Consent known to be given under fear or misconception'),
        SectionModel(id: 's_47', number: 47, title: 'Exclusion of acts which are offences independently'),
        SectionModel(id: 's_48', number: 48, title: 'Communication made in good faith'),
        SectionModel(id: 's_49', number: 49, title: 'Act to which a person is compelled by threats'),
        SectionModel(id: 's_50', number: 50, title: 'Act causing slight harm'),
        SectionModel(id: 's_51', number: 51, title: 'Right of private defence'),
        SectionModel(id: 's_52', number: 52, title: 'Right of private defence — extent'),
      ],
    ),
    ChapterModel(
      id: 'ch_5', number: 5, romanNumeral: 'V',
      name: 'Abetment, Criminal Conspiracy and Attempt',
      firstSection: 53, lastSection: 63,
      sections: [
        SectionModel(id: 's_53', number: 53, title: 'Abetment of a thing'),
        SectionModel(id: 's_54', number: 54, title: 'Abettor'),
        SectionModel(id: 's_55', number: 55, title: 'Abetment in India of offences outside India'),
        SectionModel(id: 's_56', number: 56, title: 'Abetment outside India for offence in India'),
        SectionModel(id: 's_57', number: 57, title: 'Punishment of abetment if act abetted is committed'),
        SectionModel(id: 's_58', number: 58, title: 'Punishment of abetment if person abetted does act with different intention'),
        SectionModel(id: 's_59', number: 59, title: 'Liability of abettor for an effect caused by abetted act'),
        SectionModel(id: 's_60', number: 60, title: 'Abettor present when offence is committed'),
        SectionModel(id: 's_61', number: 61, title: 'Criminal conspiracy'),
        SectionModel(id: 's_62', number: 62, title: 'Punishment of criminal conspiracy'),
        SectionModel(id: 's_63', number: 63, title: 'Attempt to commit offences'),
      ],
    ),
    ChapterModel(
      id: 'ch_6', number: 6, romanNumeral: 'VI',
      name: 'Offences Against the State',
      firstSection: 64, lastSection: 73,
      sections: [
        SectionModel(id: 's_64', number: 64, title: 'Waging or attempting to wage war against Government of India'),
        SectionModel(id: 's_65', number: 65, title: 'Conspiracy to commit offences punishable under section 64'),
        SectionModel(id: 's_66', number: 66, title: 'Collecting arms with intention of waging war'),
        SectionModel(id: 's_67', number: 67, title: 'Concealing with intent to facilitate design to wage war'),
        SectionModel(id: 's_68', number: 68, title: 'Assaulting President, Governor with intent to compel'),
        SectionModel(id: 's_69', number: 69, title: 'Sedition'),
        SectionModel(id: 's_70', number: 70, title: 'Waging war against any power in alliance with Government'),
        SectionModel(id: 's_71', number: 71, title: 'Committing depredation on territories of powers at peace'),
        SectionModel(id: 's_72', number: 72, title: 'Receiving property taken by war or depredation'),
        SectionModel(id: 's_73', number: 73, title: 'Public servant voluntarily allowing prisoner of State to escape'),
      ],
    ),
    ChapterModel(
      id: 'ch_7', number: 7, romanNumeral: 'VII',
      name: 'Offences Relating to Army, Navy and Air Force',
      firstSection: 74, lastSection: 79,
      sections: [
        SectionModel(id: 's_74', number: 74, title: 'Abetting mutiny or attempting to seduce a soldier'),
        SectionModel(id: 's_75', number: 75, title: 'Abetment of mutiny, if mutiny is committed in consequence'),
        SectionModel(id: 's_76', number: 76, title: 'Abetment of assault by soldier on superior officer'),
        SectionModel(id: 's_77', number: 77, title: 'Abetment of such assault if assault is committed'),
        SectionModel(id: 's_78', number: 78, title: 'Abetment of desertion of soldier'),
        SectionModel(id: 's_79', number: 79, title: 'Wearing garb or carrying token used by soldier'),
      ],
    ),
    ChapterModel(
      id: 'ch_8', number: 8, romanNumeral: 'VIII',
      name: 'Offences Against Public Tranquillity',
      firstSection: 80, lastSection: 93,
      sections: [
        SectionModel(id: 's_80', number: 80,  title: 'Unlawful assembly'),
        SectionModel(id: 's_81', number: 81,  title: 'Member of unlawful assembly — punishment'),
        SectionModel(id: 's_82', number: 82,  title: 'Being a member of unlawful assembly'),
        SectionModel(id: 's_83', number: 83,  title: 'Joining unlawful assembly armed with deadly weapon'),
        SectionModel(id: 's_84', number: 84,  title: 'Joining or continuing after command to disperse'),
        SectionModel(id: 's_85', number: 85,  title: 'Force used by one member in prosecution of common object'),
        SectionModel(id: 's_86', number: 86,  title: 'Rioting'),
        SectionModel(id: 's_87', number: 87,  title: 'Punishment for rioting'),
        SectionModel(id: 's_88', number: 88,  title: 'Rioting, armed with deadly weapon'),
        SectionModel(id: 's_89', number: 89,  title: 'Every member of unlawful assembly guilty of rioting'),
        SectionModel(id: 's_90', number: 90,  title: 'Wantonly giving provocation with intent to cause riot'),
        SectionModel(id: 's_91', number: 91,  title: 'Owner or occupier of land on which unlawful assembly held'),
        SectionModel(id: 's_92', number: 92,  title: 'Liability of person hiring land for unlawful assembly'),
        SectionModel(id: 's_93', number: 93,  title: 'Affray'),
      ],
    ),
  ];
}

// ─────────────────────────────────────────────
// MARK: — ACT DETAIL SCREEN
// ─────────────────────────────────────────────

class ActDetailScreen extends StatefulWidget {
  final String actId;
  final String actName;
  final int year;
  final ValueChanged<SectionModel>? onSectionTap;

  const ActDetailScreen({
    super.key,
    required this.actId,
    required this.actName,
    required this.year,
    this.onSectionTap,
  });

  @override
  State<ActDetailScreen> createState() => _ActDetailScreenState();
}

class _ActDetailScreenState extends State<ActDetailScreen>
    with TickerProviderStateMixin {

  // ── Data ──────────────────────────────────────
  late final ActDetailModel _detail;

  // ── Animation controllers ─────────────────────
  late final List<AnimationController> _chapControllers;
  late final AnimationController _entranceController;
  final ScrollController _scrollController = ScrollController();

  // ── Accordion state ───────────────────────────
  int? _expandedIndex;
  bool _entranceDone = false;

  // ── Entrance animations ───────────────────────
  late final Animation<double> _appBarFade;
  late final Animation<double> _infoFade;
  late final Animation<Offset>  _infoSlide;
  late final List<Animation<double>> _chapterFades;
  late final List<Animation<Offset>>  _chapterSlides;

  static const int _maxStagger = 8;

  // ─────────────────────────────────────────────
  // MARK: — LIFECYCLE
  // ─────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _detail = MockActDetailData.getForAct(
      actId: widget.actId,
      actName: widget.actName,
      year: widget.year,
    );
    _initControllers();
    _setupEntranceAnimations();
    _startEntrance();
  }

  void _initControllers() {
    _chapControllers = List.generate(
      _detail.chapters.length,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 340),
      ),
    );

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  void _setupEntranceAnimations() {
    _appBarFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.00, 0.35, curve: Curves.easeOut),
      ),
    );

    _infoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.12, 0.48, curve: Curves.easeOut),
      ),
    );
    _infoSlide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.12, 0.50, curve: Curves.easeOutCubic),
      ),
    );

    final n = _detail.chapters.length;
    _chapterFades = List.generate(n, (i) {
      final si = i.clamp(0, _maxStagger - 1);
      final s  = (0.22 + si * 0.08).clamp(0.0, 0.88);
      final e  = (s + 0.26).clamp(0.0, 1.0);
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _entranceController,
          curve: Interval(s, e, curve: Curves.easeOut),
        ),
      );
    });

    _chapterSlides = List.generate(n, (i) {
      final si = i.clamp(0, _maxStagger - 1);
      final s  = (0.22 + si * 0.08).clamp(0.0, 0.88);
      final e  = (s + 0.32).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 0.06),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _entranceController,
          curve: Interval(s, e, curve: Curves.easeOutCubic),
        ),
      );
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
    for (final c in _chapControllers) c.dispose();
    _entranceController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // MARK: — ACCORDION LOGIC
  // ─────────────────────────────────────────────

  void _toggleChapter(int index) {
    HapticFeedback.lightImpact();

    if (_expandedIndex == index) {
      _chapControllers[index].reverse();
      setState(() => _expandedIndex = null);
    } else {
      if (_expandedIndex != null) {
        _chapControllers[_expandedIndex!].reverse();
      }
      _chapControllers[index].forward();
      setState(() => _expandedIndex = index);
    }
  }

  // ─────────────────────────────────────────────
  // MARK: — SECTION TAP → READER SCREEN
  // ─────────────────────────────────────────────

  void _handleSectionTap(ChapterModel chapter, SectionModel section) {
    HapticFeedback.lightImpact();

    // Notify external listener if provided (e.g. analytics)
    widget.onSectionTap?.call(section);

    // Navigate to ReaderScreen via GoRouter, passing actId + sectionId
    context.goActReader(
      actId:     widget.actId,
      sectionId: section.id,
      args: ActReaderArgs(
        actId:        widget.actId,
        actName:      widget.actName,
        chapterId:    chapter.id,
        chapterName:  chapter.name,
        sectionId:    section.id,
        sectionTitle: section.title,
      ),
    );
  }

  // ─────────────────────────────────────────────
  // MARK: — HELPERS
  // ─────────────────────────────────────────────

  Animation<double> _fadeAt(int i) {
    if (_entranceDone) return const AlwaysStoppedAnimation<double>(1.0);
    return _chapterFades[i];
  }

  Animation<Offset> _slideAt(int i) {
    if (_entranceDone) return const AlwaysStoppedAnimation<Offset>(Offset.zero);
    return _chapterSlides[i];
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
          _ActDetailBackground(isDark: dark),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: MediaQuery.of(context).padding.top + kToolbarHeight,
              ),

              FadeTransition(
                opacity: _infoFade,
                child: SlideTransition(
                  position: _infoSlide,
                  child: _ActInfoStrip(detail: _detail, isDark: dark),
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              Expanded(child: _buildChapterList(dark)),
            ],
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
            widget.actName,
            style: AppTypography.titleLarge.copyWith(
              color: dark
                  ? AppColors.darkPrimaryText
                  : AppColors.lightPrimaryText,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
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
  // MARK: — CHAPTER LIST
  // ─────────────────────────────────────────────

  Widget _buildChapterList(bool dark) {
    final chapters = _detail.chapters;
    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xs,
        AppSpacing.xl,
        AppSpacing.max,
      ),
      itemCount: chapters.length,
      itemBuilder: (context, i) {
        final chapter = chapters[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: FadeTransition(
            opacity: _fadeAt(i),
            child: SlideTransition(
              position: _slideAt(i),
              child: _ChapterCard(
                chapter: chapter,
                isExpanded: _expandedIndex == i,
                expansionAnim: _chapControllers[i],
                isDark: dark,
                onHeaderTap: () => _toggleChapter(i),
                onSectionTap: (section) => _handleSectionTap(chapter, section),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// MARK: — ACT INFO STRIP
// ─────────────────────────────────────────────

class _ActInfoStrip extends StatelessWidget {
  final ActDetailModel detail;
  final bool isDark;

  const _ActInfoStrip({required this.detail, required this.isDark});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.xs, AppSpacing.xl, 0,
        ),
        child: Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: [
            _InfoChip(
              label: detail.year.toString(),
              icon: Icons.calendar_today_outlined,
              isDark: isDark,
            ),
            _InfoChip(
              label: '${detail.chapters.length} Chapters',
              icon: Icons.list_alt_rounded,
              isDark: isDark,
            ),
            _InfoChip(
              label: '${detail.totalSections} Sections',
              icon: Icons.article_outlined,
              isDark: isDark,
            ),
          ],
        ),
      );
}

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isDark;

  const _InfoChip({
    required this.label,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0x14FFFFFF)
              : const Color(0x0A000000),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: isDark
                ? const Color(0x1AFFFFFF)
                : const Color(0x0D000000),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 10,
              color: isDark
                  ? AppColors.darkSecondaryText
                  : AppColors.lightSecondaryText,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                fontSize: 10.5,
                color: isDark
                    ? AppColors.darkSecondaryText
                    : AppColors.lightSecondaryText,
              ),
            ),
          ],
        ),
      );
}

// ─────────────────────────────────────────────
// MARK: — CHAPTER CARD
// ─────────────────────────────────────────────

class _ChapterCard extends StatelessWidget {
  final ChapterModel chapter;
  final bool isExpanded;
  final AnimationController expansionAnim;
  final bool isDark;
  final VoidCallback onHeaderTap;
  final ValueChanged<SectionModel>? onSectionTap;

  const _ChapterCard({
    required this.chapter,
    required this.isExpanded,
    required this.expansionAnim,
    required this.isDark,
    required this.onHeaderTap,
    this.onSectionTap,
  });

  @override
  Widget build(BuildContext context) {
    final expandCurve = CurvedAnimation(
      parent: expansionAnim,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    return ClipRRect(
      borderRadius: AppRadius.card,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppBlur.md,
          sigmaY: AppBlur.md,
          tileMode: TileMode.mirror,
        ),
        child: AnimatedBuilder(
          animation: expansionAnim,
          builder: (context, child) => Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Color.lerp(
                      const Color(0x991C1C1E),
                      const Color(0xBF222222),
                      expansionAnim.value,
                    )
                  : Color.lerp(
                      const Color(0xCCFFFFFF),
                      const Color(0xE8FFFFFF),
                      expansionAnim.value,
                    ),
              borderRadius: AppRadius.card,
              border: Border.all(
                color: isDark
                    ? Color.lerp(
                        const Color(0x1AFFFFFF),
                        const Color(0x2EFFFFFF),
                        expansionAnim.value,
                      )!
                    : Color.lerp(
                        const Color(0x33FFFFFF),
                        const Color(0x4DFFFFFF),
                        expansionAnim.value,
                      )!,
                width: 0.5,
              ),
              boxShadow:
                  isDark ? AppShadows.darkGlass : AppShadows.lightGlass,
            ),
            child: child,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 0.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.white.withOpacity(isDark ? 0.12 : 0.60),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              GestureDetector(
                onTap: onHeaderTap,
                behavior: HitTestBehavior.opaque,
                child: _ChapterHeader(
                  chapter: chapter,
                  expansionAnim: expansionAnim,
                  expandCurve: expandCurve,
                  isDark: isDark,
                ),
              ),

              ClipRect(
                child: SizeTransition(
                  sizeFactor: expandCurve,
                  axisAlignment: -1.0,
                  child: FadeTransition(
                    opacity: CurvedAnimation(
                      parent: expansionAnim,
                      curve: const Interval(
                        0.25, 1.0,
                        curve: Curves.easeOut,
                      ),
                    ),
                    child: _SectionList(
                      sections: chapter.sections,
                      isDark: isDark,
                      onSectionTap: onSectionTap,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MARK: — CHAPTER HEADER
// ─────────────────────────────────────────────

class _ChapterHeader extends StatelessWidget {
  final ChapterModel chapter;
  final AnimationController expansionAnim;
  final Animation<double> expandCurve;
  final bool isDark;

  const _ChapterHeader({
    required this.chapter,
    required this.expansionAnim,
    required this.expandCurve,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final baseArrowColor = isDark
        ? AppColors.darkSecondaryText
        : AppColors.lightSecondaryText;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.md,
        AppSpacing.base,
        AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RotationTransition(
            turns: Tween<double>(begin: 0.0, end: 0.25).animate(expandCurve),
            child: AnimatedBuilder(
              animation: expansionAnim,
              builder: (_, __) => Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: Color.lerp(
                  baseArrowColor,
                  isDark ? AppColors.accentLight : AppColors.accent,
                  expansionAnim.value,
                ),
              ),
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          Expanded(
            child: AnimatedBuilder(
              animation: expansionAnim,
              builder: (_, child) => Text(
                chapter.displayTitle,
                style: AppTypography.titleMedium.copyWith(
                  color: Color.lerp(
                    isDark
                        ? AppColors.darkPrimaryText
                        : AppColors.lightPrimaryText,
                    isDark ? AppColors.accentLight : AppColors.accent,
                    expansionAnim.value * 0.4,
                  ),
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.15,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          _SectionRangeChip(
            range: chapter.sectionRange,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MARK: — SECTION LIST
// ─────────────────────────────────────────────

class _SectionList extends StatelessWidget {
  final List<SectionModel> sections;
  final bool isDark;
  final ValueChanged<SectionModel>? onSectionTap;

  const _SectionList({
    required this.sections,
    required this.isDark,
    this.onSectionTap,
  });

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Divider(
            height: 0.5,
            thickness: 0.5,
            color: isDark
                ? AppColors.darkSeparator
                : AppColors.lightSeparator,
          ),

          ...sections.map(
            (s) => _SectionItem(
              section: s,
              isDark: isDark,
              onTap: onSectionTap != null ? () => onSectionTap!(s) : null,
            ),
          ),

          const SizedBox(height: AppSpacing.sm),
        ],
      );
}

// ─────────────────────────────────────────────
// MARK: — SECTION ITEM
// ─────────────────────────────────────────────

class _SectionItem extends StatefulWidget {
  final SectionModel section;
  final bool isDark;
  final VoidCallback? onTap;

  const _SectionItem({
    required this.section,
    required this.isDark,
    this.onTap,
  });

  @override
  State<_SectionItem> createState() => _SectionItemState();
}

class _SectionItemState extends State<_SectionItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final dark = widget.isDark;
    final sec  = widget.section;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        setState(() => _pressed = true);
        HapticFeedback.selectionClick();
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        color: _pressed
            ? (dark
                ? const Color(0x14FFFFFF)
                : const Color(0x09000000))
            : Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: 44),

            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: SizedBox(
                width: 32,
                child: Text(
                  '${sec.number}.',
                  style: AppTypography.labelMedium.copyWith(
                    color: dark ? AppColors.accentLight : AppColors.accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.md,
                ),
                child: Text(
                  sec.title,
                  style: AppTypography.bodySmall.copyWith(
                    fontFamily: null,
                    color: dark
                        ? AppColors.darkPrimaryText
                        : AppColors.lightPrimaryText,
                    height: 1.45,
                    fontSize: 13.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sm, AppSpacing.md, AppSpacing.base, 0,
              ),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 14,
                color: _pressed
                    ? (dark ? AppColors.accentLight : AppColors.accent)
                    : (dark
                        ? AppColors.darkTertiaryText
                        : AppColors.lightTertiaryText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MARK: — SECTION RANGE CHIP
// ─────────────────────────────────────────────

class _SectionRangeChip extends StatelessWidget {
  final String range;
  final bool isDark;

  const _SectionRangeChip({required this.range, required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0x14FFFFFF)
              : const Color(0x0A000000),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isDark
                ? const Color(0x20FFFFFF)
                : const Color(0x14000000),
            width: 0.5,
          ),
        ),
        child: Text(
          range,
          style: AppTypography.labelSmall.copyWith(
            fontSize: 10,
            letterSpacing: 0.1,
            color: isDark
                ? AppColors.darkSecondaryText
                : AppColors.lightSecondaryText,
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
// MARK: — GLASS SEARCH BUTTON (Placeholder)
// ─────────────────────────────────────────────

class _GlassSearchButton extends StatefulWidget {
  final bool isDark;
  const _GlassSearchButton({required this.isDark});

  @override
  State<_GlassSearchButton> createState() => _GlassSearchButtonState();
}

class _GlassSearchButtonState extends State<_GlassSearchButton>
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
            // Placeholder — future: open section search
          },
          onTapCancel: () => _press.reverse(),
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.isDark
                  ? const Color(0x33FFFFFF)
                  : const Color(0x1A000000),
            ),
            child: Icon(
              Icons.search_rounded,
              size: 17,
              color: widget.isDark
                  ? AppColors.darkPrimaryText
                  : AppColors.lightPrimaryText,
            ),
          ),
        ),
      );
}

// ─────────────────────────────────────────────
// MARK: — BACKGROUND
// ─────────────────────────────────────────────

class _ActDetailBackground extends StatelessWidget {
  final bool isDark;
  const _ActDetailBackground({required this.isDark});

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
                    const Color(0xFF0C0F1A),
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
            Positioned(
              top: -80,
              right: -50,
              child: _Orb(
                size: 260,
                color: AppColors.accent
                    .withOpacity(isDark ? 0.07 : 0.04),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -40,
              child: _Orb(
                size: 220,
                color: const Color(0xFF7C3AED)
                    .withOpacity(isDark ? 0.05 : 0.025),
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