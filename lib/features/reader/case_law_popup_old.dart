// lib/features/reader/case_law_popup.dart
// Law Briefly — Case Law Popup
// Premium Apple-Style Modal | Glass Sheet | Legal Content | Production-Ready

import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';

// ─────────────────────────────────────────────
// MARK: — CASE LAW CONTENT MODEL
// ─────────────────────────────────────────────

class CaseLawContent {
  final String? facts;
  final String? issues;
  final String? judgment;
  final String? reasoning;
  final String? significance;

  const CaseLawContent({
    this.facts,
    this.issues,
    this.judgment,
    this.reasoning,
    this.significance,
  });

  factory CaseLawContent.fromJson(Map<String, dynamic> json) => CaseLawContent(
        facts:        json['facts']        as String?,
        issues:       json['issues']       as String?,
        judgment:     json['judgment']     as String?,
        reasoning:    json['reasoning']    as String?,
        significance: json['significance'] as String?,
      );
}

// ─────────────────────────────────────────────
// MARK: — CASE LAW DATA MODEL (JSON / ISAR ready)
// ─────────────────────────────────────────────

class CaseLawData {
  final String id;
  final String title;
  final String? citation;
  final String? court;
  final String? year;
  final String? relatedSectionRef; // e.g., "Section 318"
  final String? relatedActName;
  final CaseLawContent content;

  const CaseLawData({
    required this.id,
    required this.title,
    this.citation,
    this.court,
    this.year,
    this.relatedSectionRef,
    this.relatedActName,
    required this.content,
  });

  String get courtAndYear {
    final parts = <String>[];
    if (court != null) parts.add(court!);
    if (year  != null) parts.add(year!);
    return parts.join('\u2002\u00B7\u2002');
  }

  factory CaseLawData.fromJson(Map<String, dynamic> json) => CaseLawData(
        id:                 json['id']                   as String,
        title:              json['title']                as String,
        citation:           json['citation']             as String?,
        court:              json['court']                as String?,
        year:               json['year']                 as String?,
        relatedSectionRef:  json['related_section_ref']  as String?,
        relatedActName:     json['related_act_name']     as String?,
        content: CaseLawContent.fromJson(
          json['content'] as Map<String, dynamic>? ?? {},
        ),
      );

  Map<String, dynamic> toJson() => {
        'id':                  id,
        'title':               title,
        'citation':            citation,
        'court':               court,
        'year':                year,
        'related_section_ref': relatedSectionRef,
        'related_act_name':    relatedActName,
        'content': {
          'facts':        content.facts,
          'issues':       content.issues,
          'judgment':     content.judgment,
          'reasoning':    content.reasoning,
          'significance': content.significance,
        },
      };
}

// ─────────────────────────────────────────────
// MARK: — MOCK DATA (Replace with ISAR / JSON)
// ─────────────────────────────────────────────

abstract final class MockCaseLawData {
  // Lookup by case law ID — future: query ISAR
  static CaseLawData getById(String id) {
    return _all.firstWhere(
      (c) => c.id == id,
      orElse: () => _all.first,
    );
  }

  static final List<CaseLawData> _all = [_hiralalCase, _inderMohanCase, _dalipSinghCase];

  static const CaseLawData _hiralalCase = CaseLawData(
    id: 'cl_1',
    title: 'Hira Lal Hari Lal Bhagwati v. Central Bureau of Investigation, New Delhi',
    citation: '(2003) 5 SCC 257',
    court: 'Supreme Court of India',
    year: '2003',
    relatedSectionRef: 'Section 318',
    relatedActName: 'Bharatiya Nyaya Sanhita, 2023',
    content: CaseLawContent(
      facts: '''
The appellants were Directors of a company engaged in the import of chemicals. The Central Bureau of Investigation alleged that they had made false representations to the Ministry of Commerce, fraudulently claiming to be actual end-users of certain restricted chemicals. On the strength of these representations, import licences were issued in favour of their company.

The CBI contended that instead of using the chemicals for the industrial purpose stated in the licence application, the appellants sold them in the open market at a substantial profit, thereby defrauding the Government of India.

The appellants, on the other hand, contended that they were not involved in the day-to-day management of the company, had acted in good faith, and had relied entirely on their subordinates for the accuracy of representations made to the Ministry. They further contended that no dishonest intention existed at the time of making the representations.''',
      issues: '''
1. Whether the representations made by the company's Directors to the Ministry of Commerce constituted the offence of cheating within the meaning of the relevant provisions of law.

2. Whether the accused-Directors, as officers of the company, could be held vicariously liable for acts of the company's employees and agents in making false representations.

3. Whether the essential element of a dishonest or fraudulent inducement existed at the inception of the transaction, and whether subsequent misuse of the licence could, by itself, constitute the offence.

4. Whether a prima facie case had been made out to proceed to trial against the accused.''',
      judgment: '''
The Supreme Court upheld the order of discharge passed in favour of the accused, holding that no prima facie case had been established by the prosecution to proceed to trial.

The Court held that for constituting the offence of cheating, the prosecution must demonstrate that the accused had a dishonest or fraudulent intention at the very inception of the transaction — at the time of making the representation. A subsequent failure to perform a promise or a subsequent misuse of a licence, standing alone, would not elevate a civil wrong into a criminal offence.

The Court further held that the corporate veil could not be lifted mechanically to fasten criminal liability on Directors who were shown to have had no personal knowledge of or participation in the making of the impugned representations.''',
      reasoning: '''
The Court drew a clear line between a mere breach of contract, which gives rise to civil liability, and the offence of cheating under the criminal law, which additionally requires proof of a pre-existing fraudulent intent. Relying upon a long line of decisions, the Court reiterated that the mere fact that a person made a representation which turned out to be false does not, by itself, establish the element of fraud.

The Court observed that the essential ingredients of the offence are: (i) a deception; (ii) which is dishonest or fraudulent; and (iii) which induces the deceived person to deliver property or to do something he would not otherwise have done. All three elements must be simultaneously present and proved.

The Court further noted that the criminal law cannot be set in motion at the instance of persons who are merely seeking a civil remedy or using the criminal process as a tool of pressure.''',
      significance: '''
This decision is among the most frequently cited authorities for the principle that a pre-existing dishonest intent — existing at the time of the representation — is a sine qua non for the offence of cheating. It authoritatively distinguishes between contractual breach and criminal fraud.

The judgment has significantly influenced the interpretation of cheating provisions across successive statutory frameworks, including the present Section 318 of the Bharatiya Nyaya Sanhita, 2023 (formerly Section 420 of the Indian Penal Code, 1860).

The case also contributes to the body of law on the liability of Directors and corporate officers in criminal proceedings, establishing that individual criminal liability cannot be presumed from mere directorship.''',
    ),
  );

  static const CaseLawData _inderMohanCase = CaseLawData(
    id: 'cl_2',
    title: 'Inder Mohan Goswami v. State of Uttaranchal',
    citation: '(2007) 12 SCC 1',
    court: 'Supreme Court of India',
    year: '2007',
    relatedSectionRef: 'Section 318',
    relatedActName: 'Bharatiya Nyaya Sanhita, 2023',
    content: CaseLawContent(
      facts: '''
The appellants were editors and publishers of a newspaper. A complaint was filed against them alleging that they had published false and defamatory material about the complainant. Subsequently, the complainant also alleged that the appellants had cheated him in a financial transaction and had made false promises with intent to deceive.

The appellants approached the High Court for quashing of the criminal proceedings, contending that no offence of cheating was disclosed on the face of the allegations. The High Court declined to quash the proceedings, leading to the present appeal before the Supreme Court.''',
      issues: '''
1. Whether the allegations in the complaint, read as a whole, disclosed the essential ingredients of the offence of cheating.

2. Whether the High Court was justified in declining to exercise its inherent jurisdiction to quash criminal proceedings where no prima facie case was made out.

3. What is the correct approach for examining the sufficiency of allegations at the threshold stage of a criminal complaint?''',
      judgment: '''
The Supreme Court allowed the appeal and quashed the criminal proceedings. The Court held that the complaint, even if its allegations were taken at face value and accepted in their entirety, failed to disclose the essential ingredients of cheating.

The Court reiterated that while exercising jurisdiction to quash criminal proceedings, the High Court must examine whether the allegations, taken as a whole, disclose the commission of an offence. If the ingredients of the offence are absent, the proceedings must be quashed to prevent abuse of process of court.''',
      reasoning: '''
The Court reviewed the legal ingredients of the offence of cheating and found that the complaint lacked the essential element of a dishonest inducement causing delivery of property. The allegations were, at best, consistent with a contractual dispute and could not be transformed into criminal liability without specific averments establishing fraudulent intent.

The Court cautioned that allowing vague and omnibus allegations to go to trial would amount to a serious misuse of criminal courts and would cause immense harassment to the accused. The law does not permit criminal courts to be used as instruments for enforcing civil obligations.''',
      significance: '''
This decision is significant for the principle that criminal courts must not be permitted to be used as instruments of harassment or as a substitute for civil remedies. It emphasises the supervisory role of the High Courts under inherent jurisdiction to quash proceedings where no offence is made out.

The case is widely cited for the proposition that the court should exercise caution and scrutinise the allegations at the threshold to prevent abuse of process of law.''',
    ),
  );

  static const CaseLawData _dalipSinghCase = CaseLawData(
    id: 'cl_4',
    title: 'Dalip Singh v. State of Punjab',
    citation: '(2010) 2 SCC 485',
    court: 'Supreme Court of India',
    year: '2010',
    relatedSectionRef: 'Section 318',
    relatedActName: 'Bharatiya Nyaya Sanhita, 2023',
    content: CaseLawContent(
      facts: '''
The appellant was alleged to have obtained a government post by submitting a forged caste certificate. The prosecution contended that the appellant had dishonestly induced the Government to issue him an appointment order by misrepresenting his caste status, and had thereby obtained a public office and consequential emoluments to which he was not entitled.

The Sessions Court convicted the appellant for cheating. On appeal, the High Court upheld the conviction. The appellant then appealed to the Supreme Court, contending that the essential ingredients of cheating were not established.''',
      issues: '''
1. Whether obtaining a government appointment by submission of a forged certificate amounts to cheating, given that the appointment itself is not "property" in the conventional sense.

2. Whether dishonest inducement to "do anything" which the deceived person would not otherwise have done satisfies the definition of cheating.

3. Whether there is a distinction between inducement to deliver property and inducement to do any act or omit any act within the definition of cheating.''',
      judgment: '''
The Supreme Court dismissed the appeal and upheld the conviction, holding that the scope of cheating is not limited to inducement for delivery of property. The definition expressly includes inducement to do or omit to do anything which the deceived person would not otherwise do or omit.

The Court held that by submitting a forged caste certificate, the appellant had fraudulently induced the Government to issue an appointment order — an act the Government would not have done had it known the true facts. This satisfied the definition of cheating in all its essential elements.''',
      reasoning: '''
The Court undertook a detailed analysis of the definition of cheating and emphasised that the word "anything" used in the latter part of the definition must be given a broad and purposive interpretation. Any act induced by deception and causing damage or harm to the deceived person — whether or not it involves transfer of property in the strict sense — falls within the mischief of cheating.

The Court rejected the narrow interpretation urged by the appellant and held that public employment obtained by fraud is squarely covered by the definition, as it deprives qualified and deserving candidates of their legitimate opportunity.''',
      significance: '''
This decision is significant for its expansive interpretation of the definition of cheating, extending its reach beyond mere property transactions to include inducement to perform any act or omission. It has important implications for cases involving fraud in government employment and public services.

The judgment is frequently cited in cases involving obtaining public benefits, licences, or positions by misrepresentation, and underscores the Court's commitment to protecting the integrity of public administration from fraudulent conduct.''',
    ),
  );
}

// ─────────────────────────────────────────────
// MARK: — GLOBAL HELPER FUNCTION
// ─────────────────────────────────────────────

Future<void> showCaseLawPopup({
  required BuildContext context,
  required CaseLawData data,
  bool dismissOnTapOutside = true,
}) =>
    CaseLawPopup.show(
      context: context,
      data: data,
      dismissOnTapOutside: dismissOnTapOutside,
    );

// ─────────────────────────────────────────────
// MARK: — CASE LAW POPUP WIDGET
// ─────────────────────────────────────────────

class CaseLawPopup extends StatefulWidget {
  final CaseLawData data;
  final bool dismissOnTapOutside;

  const CaseLawPopup({
    super.key,
    required this.data,
    this.dismissOnTapOutside = true,
  });

  // ── Static show() factory ─────────────────────
  static Future<void> show({
    required BuildContext context,
    required CaseLawData data,
    bool dismissOnTapOutside = true,
  }) {
    return showGeneralDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: false,
      transitionDuration: Duration.zero,
      pageBuilder: (ctx, _, __) => CaseLawPopup(
        data: data,
        dismissOnTapOutside: dismissOnTapOutside,
      ),
    );
  }

  @override
  State<CaseLawPopup> createState() => _CaseLawPopupState();
}

class _CaseLawPopupState extends State<CaseLawPopup>
    with TickerProviderStateMixin {

  // ── Controllers ───────────────────────────────
  late AnimationController _sheetController;
  late AnimationController _backdropController;
  final ScrollController _scrollController = ScrollController();

  // ── Animations ────────────────────────────────
  late Animation<Offset> _sheetSlide;

  // ── Drag state ────────────────────────────────
  double _dragOffset   = 0.0;
  bool   _isDismissing = false;

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
    _sheetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
      reverseDuration: const Duration(milliseconds: 300),
    );
    _backdropController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
      reverseDuration: const Duration(milliseconds: 220),
    );

    // Apple-like spring entrance
    _sheetSlide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _sheetController,
        curve: Curves.easeOutQuint,
        reverseCurve: Curves.easeInCubic,
      ),
    );
  }

  void _startEntrance() {
    HapticFeedback.lightImpact();
    _sheetController.forward();
    _backdropController.forward();
  }

  @override
  void dispose() {
    _sheetController.dispose();
    _backdropController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // MARK: — DISMISS LOGIC
  // ─────────────────────────────────────────────

  Future<void> _dismiss() async {
    if (_isDismissing) return;
    setState(() {
      _isDismissing = true;
      _dragOffset   = 0.0;
    });
    HapticFeedback.lightImpact();
    await Future.wait([
      _sheetController.reverse(),
      _backdropController.reverse(),
    ]);
    if (mounted) Navigator.of(context).pop();
  }

  // ─────────────────────────────────────────────
  // MARK: — DRAG GESTURE
  // ─────────────────────────────────────────────

  bool get _isAtScrollTop =>
      !_scrollController.hasClients ||
      _scrollController.offset <= 4.0;

  void _onDragUpdate(DragUpdateDetails d) {
    if (!_isAtScrollTop) return;
    if (d.delta.dy > 0) {
      setState(() => _dragOffset += d.delta.dy);
    }
  }

  void _onDragEnd(DragEndDetails d) {
    final shouldDismiss = _dragOffset > 110 ||
        d.velocity.pixelsPerSecond.dy > 550;
    if (shouldDismiss) {
      _dismiss();
    } else {
      setState(() => _dragOffset = 0.0);
    }
  }

  // ─────────────────────────────────────────────
  // MARK: — BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final brightness   = Theme.of(context).brightness;
    final dark         = brightness == Brightness.dark;
    final size         = MediaQuery.of(context).size;
    final bottomPad    = MediaQuery.of(context).padding.bottom;
    final sheetHeight  = size.height * 0.88;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) { if (!didPop) _dismiss(); },
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Animated backdrop ───────────────
            _buildBackdrop(dark),

            // ── Glass sheet ─────────────────────
            Align(
              alignment: Alignment.bottomCenter,
              child: Transform.translate(
                offset: Offset(0, max(0.0, _dragOffset)),
                child: SlideTransition(
                  position: _sheetSlide,
                  child: _buildSheet(
                    dark: dark,
                    sheetHeight: sheetHeight,
                    bottomPad: bottomPad,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // MARK: — BACKDROP
  // ─────────────────────────────────────────────

  Widget _buildBackdrop(bool dark) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.dismissOnTapOutside ? _dismiss : null,
        child: AnimatedBuilder(
          animation: _backdropController,
          builder: (_, __) {
            final v = Curves.easeOut
                .transform(_backdropController.value);
            return BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: v * AppBlur.xl,
                sigmaY: v * AppBlur.xl,
              ),
              child: Container(
                color:
                    Colors.black.withOpacity(v * 0.36),
              ),
            );
          },
        ),
      );

  // ─────────────────────────────────────────────
  // MARK: — SHEET
  // ─────────────────────────────────────────────

  Widget _buildSheet({
    required bool dark,
    required double sheetHeight,
    required double bottomPad,
  }) =>
      GestureDetector(
        onTap: () {}, // absorb taps → don't propagate to backdrop
        onVerticalDragUpdate: _onDragUpdate,
        onVerticalDragEnd: _onDragEnd,
        child: ClipRRect(
          borderRadius: AppRadius.modal,
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: AppBlur.lg,
              sigmaY: AppBlur.lg,
            ),
            child: Container(
              height: sheetHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                color: dark
                    ? const Color(0xF21C1C1E)
                    : const Color(0xF5FFFFFF),
                borderRadius: AppRadius.modal,
                border: Border.all(
                  color: dark
                      ? const Color(0x22FFFFFF)
                      : const Color(0x28000000),
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(
                      dark ? 0.55 : 0.14,
                    ),
                    blurRadius: 48,
                    offset: const Offset(0, -12),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle bar
                  _HandleBar(isDark: dark),

                  // Header
                  _buildHeader(dark),

                  // Divider
                  Divider(
                    height: 0.5,
                    thickness: 0.5,
                    color: dark
                        ? AppColors.darkSeparator
                        : AppColors.lightSeparator,
                  ),

                  // Scrollable content
                  Expanded(
                    child: _buildScrollableContent(
                      dark: dark,
                      bottomPad: bottomPad,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  // ─────────────────────────────────────────────
  // MARK: — HEADER
  // ─────────────────────────────────────────────

  Widget _buildHeader(bool dark) => Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.base,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Case info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Case name
                  Text(
                    widget.data.title,
                    style: AppTypography.caseLawTitle.copyWith(
                      color: dark
                          ? AppColors.darkPrimaryText
                          : AppColors.lightPrimaryText,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.normal,
                      height: 1.35,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                  if (widget.data.citation != null ||
                      widget.data.court != null) ...[
                    const SizedBox(height: 6),

                    // Citation
                    if (widget.data.citation != null)
                      Text(
                        widget.data.citation!,
                        style: AppTypography.labelMedium.copyWith(
                          color: dark
                              ? AppColors.accentLight
                              : AppColors.accent,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          letterSpacing: 0.1,
                        ),
                      ),

                    const SizedBox(height: 2),

                    // Court & year
                    if (widget.data.courtAndYear.isNotEmpty)
                      Text(
                        widget.data.courtAndYear,
                        style: AppTypography.caption.copyWith(
                          color: dark
                              ? AppColors.darkSecondaryText
                              : AppColors.lightSecondaryText,
                          fontSize: 11.5,
                        ),
                      ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: AppSpacing.sm),

            // Close button
            _CloseButton(isDark: dark, onTap: _dismiss),
          ],
        ),
      );

  // ─────────────────────────────────────────────
  // MARK: — SCROLLABLE CONTENT
  // ─────────────────────────────────────────────

  Widget _buildScrollableContent({
    required bool dark,
    required double bottomPad,
  }) {
    final d = widget.data.content;

    return SelectionArea(
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.xl,
          AppSpacing.xl,
          bottomPad + AppSpacing.xxxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Facts ──────────────────────────
            if (d.facts != null && d.facts!.trim().isNotEmpty)
              _ContentSection(
                label: 'FACTS',
                text: d.facts!,
                isDark: dark,
                accentColor:
                    dark ? AppColors.accentLight : AppColors.accent,
              ),

            // ── Issues ─────────────────────────
            if (d.issues != null && d.issues!.trim().isNotEmpty)
              _ContentSection(
                label: 'ISSUES',
                text: d.issues!,
                isDark: dark,
                accentColor: const Color(0xFF7C3AED),
              ),

            // ── Judgment ───────────────────────
            if (d.judgment != null && d.judgment!.trim().isNotEmpty)
              _ContentSection(
                label: 'JUDGMENT',
                text: d.judgment!,
                isDark: dark,
                accentColor: const Color(0xFF059669),
              ),

            // ── Reasoning ──────────────────────
            if (d.reasoning != null && d.reasoning!.trim().isNotEmpty)
              _ContentSection(
                label: 'REASONING',
                text: d.reasoning!,
                isDark: dark,
                accentColor: const Color(0xFFF59E0B),
              ),

            // ── Legal Significance ─────────────
            if (d.significance != null && d.significance!.trim().isNotEmpty)
              _ContentSection(
                label: 'LEGAL SIGNIFICANCE',
                text: d.significance!,
                isDark: dark,
                accentColor: AppColors.gold,
              ),

            // ── Related to ─────────────────────
            if (widget.data.relatedSectionRef != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _RelatedFooter(data: widget.data, isDark: dark),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MARK: — HANDLE BAR
// ─────────────────────────────────────────────

class _HandleBar extends StatelessWidget {
  final bool isDark;
  const _HandleBar({required this.isDark});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(
          top: AppSpacing.modalHandleTopGap,
          bottom: AppSpacing.xs,
        ),
        child: Center(
          child: Container(
            width: AppSpacing.modalHandleW,
            height: AppSpacing.modalHandleH,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0x4DFFFFFF)
                  : const Color(0x3D000000),
              borderRadius: AppRadius.pillAll,
            ),
          ),
        ),
      );
}

// ─────────────────────────────────────────────
// MARK: — CLOSE BUTTON
// ─────────────────────────────────────────────

class _CloseButton extends StatefulWidget {
  final bool isDark;
  final VoidCallback onTap;
  const _CloseButton({required this.isDark, required this.onTap});

  @override
  State<_CloseButton> createState() => _CloseButtonState();
}

class _CloseButtonState extends State<_CloseButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _press;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.88).animate(
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
            widget.onTap();
          },
          onTapCancel: () => _press.reverse(),
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.isDark
                  ? const Color(0x33FFFFFF)
                  : const Color(0x14000000),
            ),
            child: Icon(
              Icons.close_rounded,
              size: 15,
              color: widget.isDark
                  ? AppColors.darkSecondaryText
                  : AppColors.lightSecondaryText,
            ),
          ),
        ),
      );
}

// ─────────────────────────────────────────────
// MARK: — CONTENT SECTION
// ─────────────────────────────────────────────

class _ContentSection extends StatelessWidget {
  final String label;
  final String text;
  final bool isDark;
  final Color accentColor;

  const _ContentSection({
    required this.label,
    required this.text,
    required this.isDark,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final inkColor = isDark
        ? AppColors.readerInkDark
        : AppColors.readerInkLight;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section label + accent bar ────────
          Row(
            children: [
              // Left accent bar
              Container(
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: AppRadius.pillAll,
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              // Label
              Text(
                label,
                style: AppTypography.sectionNumber.copyWith(
                  color: accentColor,
                  fontSize: 10.5,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // ── Body text ─────────────────────────
          Text(
            text.trim(),
            style: AppTypography.caseLawBody.copyWith(
              color: inkColor,
              fontSize: 15.5,
              height: 1.78,
              letterSpacing: 0.12,
              fontStyle: FontStyle.normal,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MARK: — RELATED FOOTER
// ─────────────────────────────────────────────

class _RelatedFooter extends StatelessWidget {
  final CaseLawData data;
  final bool isDark;

  const _RelatedFooter({required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final secondaryColor = isDark
        ? AppColors.darkSecondaryText
        : AppColors.lightSecondaryText;
    final separatorColor = isDark
        ? AppColors.darkSeparator
        : AppColors.lightSeparator;

    return Column(
      children: [
        Divider(
          height: 0.5,
          thickness: 0.5,
          color: separatorColor,
        ),

        const SizedBox(height: AppSpacing.base),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.link_rounded,
              size: 12,
              color: secondaryColor.withOpacity(0.6),
            ),
            const SizedBox(width: 5),
            Text(
              _buildRelatedLabel(),
              style: AppTypography.caption.copyWith(
                color: secondaryColor,
                fontStyle: FontStyle.italic,
                letterSpacing: 0.1,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _buildRelatedLabel() {
    final parts = <String>[];
    if (data.relatedSectionRef != null) parts.add(data.relatedSectionRef!);
    if (data.relatedActName    != null) parts.add(data.relatedActName!);
    if (parts.isEmpty) return 'Related Case Law';
    return 'Related to ${parts.join(', ')}';
  }
}