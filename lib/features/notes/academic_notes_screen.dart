// lib/features/notes/academic_notes_screen.dart
// Law Briefly — Academic Notes Screen
// iOS 18 Liquid Glass | Accordion | PDF Navigation

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';
import '../pdf_reader/pdf_reader_screen.dart';

// ─────────────────────────────────────────────
// MARK: — SUBJECT MODEL
// ─────────────────────────────────────────────

class Subject {
  final String    id;
  final String    title;
  final String?   pdfPath;
  final String?   description;
  final int       semester;
  final bool      isPremium;
  final String?   thumbnailPath;
  final int?      totalPages;
  final DateTime? uploadedAt;
  final String?   uploadedBy;
  final bool      isDownloaded;

  const Subject({
    required this.id,
    required this.title,
    required this.semester,
    this.pdfPath,
    this.description,
    this.isPremium   = false,
    this.thumbnailPath,
    this.totalPages,
    this.uploadedAt,
    this.uploadedBy,
    this.isDownloaded = false,
  });

  bool get hasPdf   => pdfPath != null && pdfPath!.isNotEmpty;
  bool get isLocked => isPremium;

  factory Subject.fromJson(Map<String, dynamic> json) => Subject(
        id:           json['id']           as String,
        title:        json['title']        as String,
        semester:     json['semester']     as int,
        pdfPath:      json['pdf_path']     as String?,
        description:  json['description']  as String?,
        isPremium:    json['is_premium']   as bool? ?? false,
        thumbnailPath: json['thumbnail']   as String?,
        totalPages:   json['total_pages']  as int?,
        uploadedBy:   json['uploaded_by']  as String?,
        isDownloaded: json['is_downloaded'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id':           id,
        'title':        title,
        'semester':     semester,
        'pdf_path':     pdfPath,
        'description':  description,
        'is_premium':   isPremium,
        'thumbnail':    thumbnailPath,
        'total_pages':  totalPages,
        'uploaded_by':  uploadedBy,
        'is_downloaded': isDownloaded,
      };
}

// ─────────────────────────────────────────────
// MARK: — ACADEMIC YEAR MODEL
// ─────────────────────────────────────────────

class AcademicYear {
  final String       id;
  final String       title;
  final int          yearNumber;
  final String       program;
  final int          firstSemester;
  final int          lastSemester;
  final List<Subject> subjects;

  const AcademicYear({
    required this.id,
    required this.title,
    required this.yearNumber,
    required this.program,
    required this.firstSemester,
    required this.lastSemester,
    required this.subjects,
  });

  String get semesterRange => 'Sem $firstSemester\u2013$lastSemester';
  int    get subjectCount  => subjects.length;
  int    get premiumCount  => subjects.where((s) => s.isPremium).length;

  Color get accentColor => _accentForYear(yearNumber);

  static Color _accentForYear(int year) => switch (year) {
        1 => const Color(0xFF1C4ED8),
        2 => const Color(0xFF059669),
        3 => const Color(0xFF7C3AED),
        4 => const Color(0xFFF59E0B),
        5 => const Color(0xFFE11D48),
        _ => AppColors.accent,
      };

  factory AcademicYear.fromJson(Map<String, dynamic> json) => AcademicYear(
        id:            json['id']             as String,
        title:         json['title']          as String,
        yearNumber:    json['year_number']     as int,
        program:       json['program']         as String,
        firstSemester: json['first_semester']  as int,
        lastSemester:  json['last_semester']   as int,
        subjects: (json['subjects'] as List<dynamic>)
            .map((s) => Subject.fromJson(s as Map<String, dynamic>))
            .toList(),
      );

  int get totalSubjectCount => subjects.length;
}

// ─────────────────────────────────────────────
// MARK: — MOCK DATA
// ─────────────────────────────────────────────

abstract final class MockAcademicNotesData {
  static const List<AcademicYear> years = [

    AcademicYear(
      id: 'y1', title: 'BALLB 1st Year',
      yearNumber: 1, program: 'BALLB',
      firstSemester: 1, lastSemester: 2,
      subjects: [
        Subject(id: 'y1_s1', title: 'Constitutional Law I',
          description: 'Fundamental rights, directive principles, constitutional history.',
          pdfPath: 'assets/pdfs/y1/constitutional_law_1.pdf', semester: 1, totalPages: 248),
        Subject(id: 'y1_s2', title: 'Law of Contracts',
          description: 'Indian Contract Act 1872, offer, acceptance, consideration.',
          pdfPath: 'assets/pdfs/y1/law_of_contracts.pdf', semester: 1, totalPages: 312),
        Subject(id: 'y1_s3', title: 'Legal Methods and Research',
          description: 'Legal reasoning, case analysis, statutory interpretation.',
          pdfPath: 'assets/pdfs/y1/legal_methods.pdf', semester: 1, totalPages: 186),
        Subject(id: 'y1_s4', title: 'Family Law I',
          description: 'Hindu Marriage Act, Muslim personal law, succession.',
          pdfPath: 'assets/pdfs/y1/family_law_1.pdf', semester: 2, totalPages: 274),
        Subject(id: 'y1_s5', title: 'Political Science',
          description: 'Political thought, constitutional governance, state theory.',
          pdfPath: 'assets/pdfs/y1/political_science.pdf', semester: 2, totalPages: 220),
        Subject(id: 'y1_s6', title: 'Law of Torts',
          description: 'Tort liability, negligence, defamation, nuisance.',
          pdfPath: 'assets/pdfs/y1/law_of_torts.pdf', semester: 2, totalPages: 258),
      ],
    ),

    AcademicYear(
      id: 'y2', title: 'BALLB 2nd Year',
      yearNumber: 2, program: 'BALLB',
      firstSemester: 3, lastSemester: 4,
      subjects: [
        Subject(id: 'y2_s1', title: 'Constitutional Law II',
          description: 'Federal structure, emergency provisions, constitutional amendments.',
          pdfPath: 'assets/pdfs/y2/constitutional_law_2.pdf', semester: 3, totalPages: 290),
        Subject(id: 'y2_s2', title: 'Administrative Law',
          description: 'Delegated legislation, judicial review, natural justice.',
          pdfPath: 'assets/pdfs/y2/administrative_law.pdf', semester: 3, totalPages: 336),
        Subject(id: 'y2_s3', title: 'Criminal Law I (IPC / BNS)',
          description: 'General exceptions, offences against the state.',
          pdfPath: 'assets/pdfs/y2/criminal_law_1.pdf', semester: 3, totalPages: 368),
        Subject(id: 'y2_s4', title: 'Transfer of Property Law',
          description: 'Transfer of Property Act 1882, easements, mortgages, leases.',
          pdfPath: 'assets/pdfs/y2/property_law.pdf', semester: 4, totalPages: 296),
        Subject(id: 'y2_s5', title: 'Jurisprudence',
          description: 'Legal theory, schools of jurisprudence, concept of rights and duties.',
          pdfPath: 'assets/pdfs/y2/jurisprudence.pdf', semester: 4, totalPages: 312),
        Subject(id: 'y2_s6', title: 'Environmental Law',
          description: 'Environmental Protection Act, pollution control, green tribunals.',
          pdfPath: 'assets/pdfs/y2/environmental_law.pdf', semester: 4, totalPages: 242),
        Subject(id: 'y2_s7', title: 'Family Law II',
          description: 'Christian and Parsi personal law, adoption, guardianship.',
          pdfPath: 'assets/pdfs/y2/family_law_2.pdf', semester: 4, totalPages: 228),
      ],
    ),

    AcademicYear(
      id: 'y3', title: 'BALLB 3rd Year',
      yearNumber: 3, program: 'BALLB',
      firstSemester: 5, lastSemester: 6,
      subjects: [
        Subject(id: 'y3_s1', title: 'Criminal Law II (CrPC / BNSS)',
          description: 'Criminal procedure, investigation, trial, bail, appeals.',
          pdfPath: 'assets/pdfs/y3/criminal_law_2.pdf', semester: 5, totalPages: 420),
        Subject(id: 'y3_s2', title: 'Code of Civil Procedure',
          description: 'CPC 1908, suits, jurisdiction, appeals, execution of decrees.',
          pdfPath: 'assets/pdfs/y3/cpc.pdf', semester: 5, totalPages: 390),
        Subject(id: 'y3_s3', title: 'Law of Evidence (BSA)',
          description: 'Bharatiya Sakshya Adhiniyam, relevancy, admissibility, witnesses.',
          pdfPath: 'assets/pdfs/y3/evidence_law.pdf', semester: 5, totalPages: 344),
        Subject(id: 'y3_s4', title: 'Taxation Law',
          description: 'Income Tax Act, GST framework, corporate taxation basics.',
          pdfPath: 'assets/pdfs/y3/taxation_law.pdf', semester: 6, totalPages: 356),
        Subject(id: 'y3_s5', title: 'Labour and Industrial Law',
          description: 'Industrial Disputes Act, labour welfare legislation, trade unions.',
          pdfPath: 'assets/pdfs/y3/labour_law.pdf', semester: 6, totalPages: 328),
        Subject(id: 'y3_s6', title: 'Human Rights Law',
          description: 'International human rights instruments, NHRC, constitutional guarantees.',
          pdfPath: 'assets/pdfs/y3/human_rights.pdf', semester: 6, totalPages: 278),
      ],
    ),

    AcademicYear(
      id: 'y4', title: 'BALLB 4th Year',
      yearNumber: 4, program: 'BALLB',
      firstSemester: 7, lastSemester: 8,
      subjects: [
        Subject(id: 'y4_s1', title: 'Intellectual Property Rights',
          description: 'Patents, trademarks, copyrights, geographical indications.',
          pdfPath: 'assets/pdfs/y4/ipr.pdf', semester: 7, totalPages: 304),
        Subject(id: 'y4_s2', title: 'International Law',
          description: 'Public international law, treaties, sources, UN system.',
          pdfPath: 'assets/pdfs/y4/international_law.pdf', semester: 7, totalPages: 362),
        Subject(id: 'y4_s3', title: 'Company Law',
          description: 'Companies Act 2013, corporate governance, director liabilities.',
          pdfPath: 'assets/pdfs/y4/company_law.pdf', semester: 7, totalPages: 408),
        Subject(id: 'y4_s4', title: 'Alternative Dispute Resolution',
          description: 'Arbitration Act, mediation, conciliation, Lok Adalat.',
          pdfPath: 'assets/pdfs/y4/adr.pdf', semester: 8, totalPages: 262),
        Subject(id: 'y4_s5', title: 'Banking and Finance Law',
          description: 'RBI Act, Banking Regulation Act, SARFAESI, insolvency.',
          pdfPath: 'assets/pdfs/y4/banking_law.pdf', semester: 8,
          isPremium: true, totalPages: 316),
        Subject(id: 'y4_s6', title: 'Cyber Law',
          description: 'Information Technology Act, data protection, cyber offences.',
          pdfPath: 'assets/pdfs/y4/cyber_law.pdf', semester: 8, totalPages: 244),
        Subject(id: 'y4_s7', title: 'Consumer Protection Law',
          description: 'Consumer Protection Act 2019, district forums, consumer rights.',
          pdfPath: 'assets/pdfs/y4/consumer_law.pdf', semester: 8, totalPages: 218),
      ],
    ),

    AcademicYear(
      id: 'y5', title: 'BALLB 5th Year',
      yearNumber: 5, program: 'BALLB',
      firstSemester: 9, lastSemester: 10,
      subjects: [
        Subject(id: 'y5_s1', title: 'Constitutional Governance',
          description: 'Parliamentary democracy, federalism, judicial independence.',
          pdfPath: 'assets/pdfs/y5/constitutional_governance.pdf',
          semester: 9, isPremium: true, totalPages: 348),
        Subject(id: 'y5_s2', title: 'Comparative Law',
          description: 'Comparative constitutional systems, civil law vs common law.',
          pdfPath: 'assets/pdfs/y5/comparative_law.pdf', semester: 9, totalPages: 292),
        Subject(id: 'y5_s3', title: 'Professional Ethics and Legal Practice',
          description: 'Bar Council rules, professional conduct, client advocacy.',
          pdfPath: 'assets/pdfs/y5/professional_ethics.pdf', semester: 9, totalPages: 196),
        Subject(id: 'y5_s4', title: 'Moot Court Practice',
          description: 'Oral advocacy, case preparation, argument structuring.',
          pdfPath: 'assets/pdfs/y5/moot_court.pdf',
          semester: 10, isPremium: true, totalPages: 168),
        Subject(id: 'y5_s5', title: 'Clinical Legal Education',
          description: 'Legal aid clinics, client counselling, legal literacy camps.',
          pdfPath: 'assets/pdfs/y5/clinical_legal.pdf', semester: 10, totalPages: 152),
        Subject(id: 'y5_s6', title: 'Dissertation and Research',
          description: 'Legal research methodology, writing, citation standards.',
          pdfPath: 'assets/pdfs/y5/dissertation.pdf', semester: 10, totalPages: 124),
      ],
    ),
  ];

  static int get totalSubjects =>
      years.fold(0, (sum, y) => sum + y.subjectCount);
}

// ─────────────────────────────────────────────
// MARK: — ACADEMIC NOTES SCREEN
// ─────────────────────────────────────────────

class AcademicNotesScreen extends StatefulWidget {
  /// Optional external callback (for testing / parent override).
  final ValueChanged<Subject>? onSubjectTap;

  const AcademicNotesScreen({super.key, this.onSubjectTap});

  @override
  State<AcademicNotesScreen> createState() => _AcademicNotesScreenState();
}

class _AcademicNotesScreenState extends State<AcademicNotesScreen>
    with TickerProviderStateMixin {

  late final List<AnimationController> _yearControllers;
  late final AnimationController       _entranceController;
  final ScrollController               _scrollController = ScrollController();

  int?  _expandedIndex;
  bool  _entranceDone = false;

  late final Animation<double>        _appBarFade;
  late final Animation<double>        _infoFade;
  late final Animation<Offset>        _infoSlide;
  late final List<Animation<double>>  _yearFades;
  late final List<Animation<Offset>>  _yearSlides;

  static const int _maxStagger = 5;

  // ─────────────────────────────────────────────
  // MARK: — LIFECYCLE
  // ─────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _initControllers();
    _setupEntranceAnimations();
    _startEntrance();
  }

  void _initControllers() {
    _yearControllers = List.generate(
      MockAcademicNotesData.years.length,
      (_) => AnimationController(
          vsync: this, duration: const Duration(milliseconds: 340)),
    );
    _entranceController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
  }

  void _setupEntranceAnimations() {
    _appBarFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceController,
          curve: const Interval(0.00, 0.38, curve: Curves.easeOut)));

    _infoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceController,
          curve: const Interval(0.12, 0.48, curve: Curves.easeOut)));

    _infoSlide = Tween<Offset>(
        begin: const Offset(0, -0.4), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceController,
          curve: const Interval(0.12, 0.52, curve: Curves.easeOutCubic)));

    final n = MockAcademicNotesData.years.length;
    _yearFades = List.generate(n, (i) {
      final si = i.clamp(0, _maxStagger - 1);
      final s  = (0.22 + si * 0.12).clamp(0.0, 0.88);
      final e  = (s + 0.28).clamp(0.0, 1.0);
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _entranceController,
            curve: Interval(s, e, curve: Curves.easeOut)));
    });

    _yearSlides = List.generate(n, (i) {
      final si = i.clamp(0, _maxStagger - 1);
      final s  = (0.22 + si * 0.12).clamp(0.0, 0.88);
      final e  = (s + 0.34).clamp(0.0, 1.0);
      return Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
        CurvedAnimation(parent: _entranceController,
            curve: Interval(s, e, curve: Curves.easeOutCubic)));
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
    for (final c in _yearControllers) c.dispose();
    _entranceController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // MARK: — ACCORDION
  // ─────────────────────────────────────────────

  void _toggleYear(int index) {
    HapticFeedback.lightImpact();
    if (_expandedIndex == index) {
      _yearControllers[index].reverse();
      setState(() => _expandedIndex = null);
    } else {
      if (_expandedIndex != null) _yearControllers[_expandedIndex!].reverse();
      _yearControllers[index].forward();
      setState(() => _expandedIndex = index);
    }
  }

  // ─────────────────────────────────────────────
  // MARK: — SUBJECT TAP → PDF READER
  // ─────────────────────────────────────────────

  void _handleSubjectTap(Subject subject) {
    HapticFeedback.lightImpact();

    // Notify external listener if provided
    widget.onSubjectTap?.call(subject);

    // Premium gate (future)
    if (subject.isLocked) {
      _showPremiumSheet();
      return;
    }

    // PDF not yet available
    if (!subject.hasPdf) {
      _showComingSoonSnackbar(subject.title);
      return;
    }

    // Navigate to PDF Reader
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        pageBuilder: (ctx, anim, _) => PdfReaderScreen(
          pdfId:   subject.id,
          pdfPath: subject.pdfPath!,
          title:   subject.title,
        ),
        transitionDuration: const Duration(milliseconds: 380),
        transitionsBuilder: (ctx, anim, _, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end:   Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
    );
  }

  void _showComingSoonSnackbar(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.hourglass_empty_rounded, size: 16, color: Colors.white70),
          const SizedBox(width: 8),
          Expanded(child: Text(
            '$title — PDF coming soon.',
            style: const TextStyle(fontSize: 13),
          )),
        ]),
        behavior:         SnackBarBehavior.floating,
        backgroundColor:  const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showPremiumSheet() {
    final dark = Theme.of(context).brightness == Brightness.dark;
    GlassBottomSheet.show(
      context,
      initialChildSize: 0.38,
      maxChildSize:     0.50,
      child: _PremiumGateContent(isDark: dark),
    );
  }

  // ─────────────────────────────────────────────
  // MARK: — HELPERS
  // ─────────────────────────────────────────────

  Animation<double> _fadeAt(int i) =>
      _entranceDone ? const AlwaysStoppedAnimation<double>(1.0) : _yearFades[i];

  Animation<Offset> _slideAt(int i) =>
      _entranceDone
          ? const AlwaysStoppedAnimation<Offset>(Offset.zero)
          : _yearSlides[i];

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
          _AcademicBackground(isDark: dark),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: MediaQuery.of(context).padding.top + kToolbarHeight),
              FadeTransition(
                opacity: _infoFade,
                child: SlideTransition(
                  position: _infoSlide,
                  child: _NotesInfoStrip(isDark: dark),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(child: _buildYearList(dark)),
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
          child: Text('Academic Notes',
            style: AppTypography.titleLarge.copyWith(
              color:      dark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            )),
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
              child: Center(child: _GlassFilterButton(isDark: dark)),
            ),
          ),
        ],
      );

  // ─────────────────────────────────────────────
  // MARK: — YEAR LIST
  // ─────────────────────────────────────────────

  Widget _buildYearList(bool dark) {
    final years = MockAcademicNotesData.years;
    return ListView.builder(
      controller: _scrollController,
      physics:    const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.xs, AppSpacing.xl, AppSpacing.max),
      itemCount: years.length,
      itemBuilder: (context, i) {
        final year = years[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: FadeTransition(
            opacity: _fadeAt(i),
            child: SlideTransition(
              position: _slideAt(i),
              child: _YearCard(
                year:         year,
                isExpanded:   _expandedIndex == i,
                expansionAnim: _yearControllers[i],
                isDark:       dark,
                onHeaderTap:  () => _toggleYear(i),
                onSubjectTap: _handleSubjectTap,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ═════════════════════════════════════════════
// MARK: — PREMIUM GATE CONTENT
// ═════════════════════════════════════════════

class _PremiumGateContent extends StatelessWidget {
  final bool isDark;
  const _PremiumGateContent({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? AppColors.darkPrimaryText   : AppColors.lightPrimaryText;
    final secColor  = isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;

    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 52, height: 52,
        decoration: BoxDecoration(
          color:        AppColors.gold.withOpacity(isDark ? 0.16 : 0.10),
          borderRadius: AppRadius.lgAll,
          border:       Border.all(color: AppColors.gold.withOpacity(0.30), width: 0.5),
        ),
        child: const Icon(Icons.lock_outline_rounded, size: 26, color: AppColors.gold),
      ),
      const SizedBox(height: AppSpacing.base),
      Text('Premium Content', style: AppTypography.titleMedium.copyWith(
          color: textColor, fontWeight: FontWeight.w700)),
      const SizedBox(height: AppSpacing.sm),
      Text(
        'This subject is part of the Law Briefly PRO plan.\nUnlock all 5th year and advanced modules.',
        style: const TextStyle(
          fontFamily: 'Georgia', fontSize: 14, height: 1.65, fontStyle: FontStyle.italic,
        ).merge(TextStyle(color: secColor)),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: AppSpacing.xl),
      Container(
        width: double.infinity, height: 50,
        decoration: BoxDecoration(
          color:        AppColors.gold,
          borderRadius: AppRadius.button,
          boxShadow: [BoxShadow(
            color: AppColors.gold.withOpacity(0.30),
            blurRadius: 14, offset: const Offset(0, 5),
          )],
        ),
        child: Center(child: Text('Coming Soon',
          style: AppTypography.labelLarge.copyWith(color: Colors.white))),
      ),
    ]);
  }
}

// ═════════════════════════════════════════════
// MARK: — NOTES INFO STRIP
// ═════════════════════════════════════════════

class _NotesInfoStrip extends StatelessWidget {
  final bool isDark;
  const _NotesInfoStrip({required this.isDark});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xs, AppSpacing.xl, 0),
        child: Wrap(
          spacing: AppSpacing.sm, runSpacing: AppSpacing.xs,
          children: [
            _InfoPill(label: '${MockAcademicNotesData.years.length} Academic Years',
                icon: Icons.school_outlined, isDark: isDark),
            _InfoPill(label: '${MockAcademicNotesData.totalSubjects} Subjects',
                icon: Icons.menu_book_outlined, isDark: isDark),
            _InfoPill(label: 'Offline Access',
                icon: Icons.download_done_rounded, isDark: isDark, highlight: true),
          ],
        ),
      );
}

class _InfoPill extends StatelessWidget {
  final String   label;
  final IconData icon;
  final bool     isDark;
  final bool     highlight;

  const _InfoPill({required this.label, required this.icon,
      required this.isDark, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    final color = highlight
        ? const Color(0xFF059669)
        : (isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: highlight
            ? const Color(0xFF059669).withOpacity(isDark ? 0.14 : 0.08)
            : (isDark ? const Color(0x14FFFFFF) : const Color(0x0A000000)),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: highlight
              ? const Color(0xFF059669).withOpacity(0.25)
              : (isDark ? const Color(0x18FFFFFF) : const Color(0x0D000000)),
          width: 0.5,
        ),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 10, color: color),
        const SizedBox(width: 4),
        Text(label, style: AppTypography.labelSmall.copyWith(
          fontSize: 10.5, color: color,
          fontWeight: highlight ? FontWeight.w600 : FontWeight.w400)),
      ]),
    );
  }
}

// ═════════════════════════════════════════════
// MARK: — YEAR CARD
// ═════════════════════════════════════════════

class _YearCard extends StatelessWidget {
  final AcademicYear       year;
  final bool               isExpanded;
  final AnimationController expansionAnim;
  final bool               isDark;
  final VoidCallback       onHeaderTap;
  final ValueChanged<Subject> onSubjectTap;

  const _YearCard({
    required this.year,
    required this.isExpanded,
    required this.expansionAnim,
    required this.isDark,
    required this.onHeaderTap,
    required this.onSubjectTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent      = year.accentColor;
    final expandCurve = CurvedAnimation(parent: expansionAnim,
        curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);

    return ClipRRect(
      borderRadius: AppRadius.card,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: AppBlur.md, sigmaY: AppBlur.md,
            tileMode: TileMode.mirror),
        child: AnimatedBuilder(
          animation: expansionAnim,
          builder: (context, child) => Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Color.lerp(const Color(0x991C1C1E), const Color(0xBF222222), expansionAnim.value)
                  : Color.lerp(const Color(0xCCFFFFFF), const Color(0xE8FFFFFF), expansionAnim.value),
              borderRadius: AppRadius.card,
              border: Border.all(
                color: isDark
                    ? Color.lerp(const Color(0x1AFFFFFF), accent.withOpacity(0.28), expansionAnim.value)!
                    : Color.lerp(const Color(0x33FFFFFF), accent.withOpacity(0.22), expansionAnim.value)!,
                width: 0.5,
              ),
              boxShadow: isDark ? AppShadows.darkGlass : AppShadows.lightGlass,
            ),
            child: child,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(height: 0.5,
                decoration: BoxDecoration(gradient: LinearGradient(colors: [
                  Colors.transparent,
                  Colors.white.withOpacity(isDark ? 0.12 : 0.60),
                  Colors.transparent,
                ]))),
              Stack(children: [
                Positioned(left: 0, top: 0, bottom: 0, width: 3.5,
                  child: AnimatedBuilder(animation: expansionAnim,
                    builder: (_, __) => Container(
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.5 + expansionAnim.value * 0.4),
                        borderRadius: const BorderRadius.only(
                          topLeft:    Radius.circular(AppRadius.xxl),
                          bottomLeft: Radius.circular(AppRadius.xxl)),
                      )))),
                GestureDetector(
                  onTap:     onHeaderTap,
                  behavior:  HitTestBehavior.opaque,
                  child: _YearHeader(year: year, expansionAnim: expansionAnim,
                      expandCurve: expandCurve, isDark: isDark),
                ),
              ]),
              ClipRect(
                child: SizeTransition(
                  sizeFactor: expandCurve, axisAlignment: -1.0,
                  child: FadeTransition(
                    opacity: CurvedAnimation(parent: expansionAnim,
                        curve: const Interval(0.25, 1.0, curve: Curves.easeOut)),
                    child: _SubjectList(year: year, isDark: isDark,
                        onSubjectTap: onSubjectTap),
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

// ═════════════════════════════════════════════
// MARK: — YEAR HEADER
// ═════════════════════════════════════════════

class _YearHeader extends StatelessWidget {
  final AcademicYear        year;
  final AnimationController expansionAnim;
  final Animation<double>   expandCurve;
  final bool                isDark;

  const _YearHeader({required this.year, required this.expansionAnim,
      required this.expandCurve, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final accent         = year.accentColor;
    final baseArrowColor = isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.base, AppSpacing.md),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        RotationTransition(
          turns: Tween<double>(begin: 0.0, end: 0.25).animate(expandCurve),
          child: AnimatedBuilder(animation: expansionAnim,
            builder: (_, __) => Icon(Icons.chevron_right_rounded, size: 22,
              color: Color.lerp(baseArrowColor, accent, expansionAnim.value))),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: AnimatedBuilder(animation: expansionAnim,
            builder: (_, __) => Text(year.title,
              style: AppTypography.titleMedium.copyWith(
                color: Color.lerp(
                  isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                  accent, expansionAnim.value * 0.35),
                fontWeight: FontWeight.w700, letterSpacing: -0.15, height: 1.2),
              maxLines: 1, overflow: TextOverflow.ellipsis)),
        ),
        const SizedBox(width: AppSpacing.sm),
        _SemesterChip(range: year.semesterRange, isDark: isDark),
        const SizedBox(width: AppSpacing.xs),
        _SubjectCountBadge(count: year.subjectCount, accent: accent, isDark: isDark),
      ]),
    );
  }
}

// ═════════════════════════════════════════════
// MARK: — SUBJECT LIST
// ═════════════════════════════════════════════

class _SubjectList extends StatelessWidget {
  final AcademicYear       year;
  final bool               isDark;
  final ValueChanged<Subject> onSubjectTap;

  const _SubjectList({required this.year, required this.isDark, required this.onSubjectTap});

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Divider(height: 0.5, thickness: 0.5,
              color: isDark ? AppColors.darkSeparator : AppColors.lightSeparator),
          ...year.subjects.asMap().entries.map((e) {
            final index   = e.key;
            final subject = e.value;
            final isLast  = index == year.subjects.length - 1;
            return Column(children: [
              _SubjectItem(subject: subject, accentColor: year.accentColor,
                  isDark: isDark, onTap: () => onSubjectTap(subject)),
              if (!isLast)
                Padding(
                  padding: const EdgeInsets.only(left: 68),
                  child: Divider(height: 0.5, thickness: 0.5,
                    color: (isDark ? AppColors.darkSeparator : AppColors.lightSeparator)
                        .withOpacity(0.5)),
                ),
            ]);
          }),
          const SizedBox(height: AppSpacing.sm),
        ],
      );
}

// ═════════════════════════════════════════════
// MARK: — SUBJECT ITEM
// ═════════════════════════════════════════════

class _SubjectItem extends StatefulWidget {
  final Subject    subject;
  final Color      accentColor;
  final bool       isDark;
  final VoidCallback? onTap;

  const _SubjectItem({required this.subject, required this.accentColor,
      required this.isDark, this.onTap});

  @override
  State<_SubjectItem> createState() => _SubjectItemState();
}

class _SubjectItemState extends State<_SubjectItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final dark    = widget.isDark;
    final subject = widget.subject;
    final accent  = widget.accentColor;

    final titleColor = dark ? AppColors.darkPrimaryText   : AppColors.lightPrimaryText;
    final metaColor  = dark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;

    return GestureDetector(
      behavior:    HitTestBehavior.opaque,
      onTapDown:   (_) { setState(() => _pressed = true); HapticFeedback.selectionClick(); },
      onTapUp:     (_) { setState(() => _pressed = false); widget.onTap?.call(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        color:    _pressed ? accent.withOpacity(dark ? 0.10 : 0.06) : Colors.transparent,
        padding: const EdgeInsets.fromLTRB(AppSpacing.base, AppSpacing.md, AppSpacing.base, AppSpacing.md),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          _PdfIconBadge(accentColor: accent, hasPdf: subject.hasPdf,
              isDark: dark, isPressed: _pressed),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, children: [
              Text(subject.title,
                style: AppTypography.titleSmall.copyWith(
                  color:      titleColor,
                  fontWeight: FontWeight.w600,
                  height:     1.25, letterSpacing: -0.1),
                maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Row(children: [
                _MetaBadge(label: 'Semester ${subject.semester}',
                    color: accent, isDark: dark),
                if (subject.totalPages != null) ...[
                  const SizedBox(width: AppSpacing.xs),
                  _MetaDot(isDark: dark),
                  const SizedBox(width: AppSpacing.xs),
                  Text('${subject.totalPages} pages',
                    style: AppTypography.labelSmall.copyWith(
                        fontSize: 10.5, color: metaColor)),
                ],
              ]),
            ]),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.end, children: [
            if (subject.isPremium) ...[
              _PremiumBadge(isDark: dark),
              const SizedBox(height: 6),
            ],
            Icon(Icons.chevron_right_rounded, size: 16,
              color: _pressed
                  ? accent.withOpacity(0.65)
                  : (dark ? AppColors.darkTertiaryText : AppColors.lightTertiaryText)),
          ]),
        ]),
      ),
    );
  }
}

// ═════════════════════════════════════════════
// MARK: — SMALL WIDGETS (unchanged)
// ═════════════════════════════════════════════

class _PdfIconBadge extends StatelessWidget {
  final Color accentColor; final bool hasPdf, isDark, isPressed;
  const _PdfIconBadge({required this.accentColor, required this.hasPdf,
      required this.isDark, required this.isPressed});

  @override
  Widget build(BuildContext context) {
    final iconColor   = hasPdf ? accentColor : (isDark ? AppColors.darkTertiaryText : AppColors.lightTertiaryText);
    final bgColor     = hasPdf ? accentColor.withOpacity(isDark ? 0.15 : 0.10) : (isDark ? const Color(0x14FFFFFF) : const Color(0x08000000));
    final borderColor = hasPdf ? accentColor.withOpacity(isDark ? 0.25 : 0.18) : (isDark ? const Color(0x18FFFFFF) : const Color(0x0D000000));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 90),
      width: 44, height: 44,
      decoration: BoxDecoration(
        color:        isPressed ? accentColor.withOpacity(isDark ? 0.22 : 0.14) : bgColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border:       Border.all(color: borderColor, width: 0.5),
      ),
      child: Center(child: Icon(Icons.picture_as_pdf_outlined, size: 22, color: iconColor)));
  }
}

class _MetaBadge extends StatelessWidget {
  final String label; final Color color; final bool isDark;
  const _MetaBadge({required this.label, required this.color, required this.isDark});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color:        color.withOpacity(isDark ? 0.14 : 0.09),
      borderRadius: BorderRadius.circular(5),
      border:       Border.all(color: color.withOpacity(isDark ? 0.22 : 0.14), width: 0.5)),
    child: Text(label, style: AppTypography.labelSmall.copyWith(
      color: color, fontSize: 9.5, fontWeight: FontWeight.w600, letterSpacing: 0.1)));
}

class _MetaDot extends StatelessWidget {
  final bool isDark;
  const _MetaDot({required this.isDark});
  @override
  Widget build(BuildContext context) => Container(width: 3, height: 3,
    decoration: BoxDecoration(shape: BoxShape.circle,
      color: isDark ? AppColors.darkTertiaryText : AppColors.lightTertiaryText));
}

class _PremiumBadge extends StatelessWidget {
  final bool isDark;
  const _PremiumBadge({required this.isDark});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
    decoration: BoxDecoration(
      color:        AppColors.gold.withOpacity(isDark ? 0.18 : 0.12),
      borderRadius: BorderRadius.circular(5),
      border:       Border.all(color: AppColors.gold.withOpacity(0.30), width: 0.5)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.lock_outline_rounded, size: 8, color: AppColors.gold),
      const SizedBox(width: 2),
      Text('PRO', style: AppTypography.labelSmall.copyWith(
        color: AppColors.gold, fontSize: 8.5, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
    ]));
}

class _SemesterChip extends StatelessWidget {
  final String range; final bool isDark;
  const _SemesterChip({required this.range, required this.isDark});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color:        isDark ? const Color(0x14FFFFFF) : const Color(0x0A000000),
      borderRadius: BorderRadius.circular(6),
      border:       Border.all(color: isDark ? const Color(0x1FFFFFFF) : const Color(0x12000000), width: 0.5)),
    child: Text(range, style: AppTypography.labelSmall.copyWith(
      fontSize: 9.5, letterSpacing: 0.05,
      color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText)));
}

class _SubjectCountBadge extends StatelessWidget {
  final int count; final Color accent; final bool isDark;
  const _SubjectCountBadge({required this.count, required this.accent, required this.isDark});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color:        accent.withOpacity(isDark ? 0.16 : 0.10),
      borderRadius: BorderRadius.circular(20),
      border:       Border.all(color: accent.withOpacity(isDark ? 0.28 : 0.18), width: 0.5)),
    child: Text('$count', style: AppTypography.labelSmall.copyWith(
      color: accent, fontWeight: FontWeight.w700, fontSize: 11)));
}

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

class _GlassFilterButton extends StatefulWidget {
  final bool isDark;
  const _GlassFilterButton({required this.isDark});
  @override State<_GlassFilterButton> createState() => _GlassFilterButtonState();
}
class _GlassFilterButtonState extends State<_GlassFilterButton>
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
        child: Icon(Icons.tune_rounded, size: 17,
          color: widget.isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText))));
}

// ═════════════════════════════════════════════
// MARK: — BACKGROUND
// ═════════════════════════════════════════════

class _AcademicBackground extends StatelessWidget {
  final bool isDark;
  const _AcademicBackground({required this.isDark});

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF0D1117), const Color(0xFF121212), const Color(0xFF0C0E1A)]
                : [const Color(0xFFF5F9FF), const Color(0xFFFFFFFF), const Color(0xFFF0FAF5)],
          ),
        ),
        child: Stack(children: [
          Positioned(top: -100, right: -60,
            child: _Orb(size: 280,
              color: const Color(0xFF059669).withOpacity(isDark ? 0.07 : 0.04))),
          Positioned(bottom: -80, left: -40,
            child: _Orb(size: 240,
              color: AppColors.accent.withOpacity(isDark ? 0.06 : 0.04))),
        ]),
      );
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