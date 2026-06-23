// lib/data/repositories/legal_repository.dart
// Law Briefly — Repository Layer
// Offline-First | Clean Architecture | UI Independent
// JSON → Repository → UI (UI never reads raw data)

import 'dart:async';

import '../models/legal_models.dart';

// ─────────────────────────────────────────────
// MARK: — REPOSITORY EXCEPTION
// ─────────────────────────────────────────────

class RepositoryException implements Exception {
  final String  message;
  final String? code;
  final Object? cause;

  const RepositoryException({
    required this.message,
    this.code,
    this.cause,
  });

  @override
  String toString() =>
      'RepositoryException[$code]: $message${cause != null ? ' — $cause' : ''}';
}

// ─────────────────────────────────────────────
// MARK: — ABSTRACT REPOSITORY CONTRACT
// ─────────────────────────────────────────────

abstract class LegalRepository {
  // ── Acts ─────────────────────────────────────
  Future<List<Act>>     getActs();
  Future<Act?>          getActById(String id);
  Future<Section?>      getSectionById(String sectionId);
  Future<List<Act>>     searchActs(String query);

  // ── Constitution ──────────────────────────────
  Future<List<ConstitutionPart>> getConstitutionParts();
  Future<ConstitutionPart?>      getConstitutionPartById(String id);
  Future<Article?>               getArticleById(String articleId);

  // ── Case Laws ─────────────────────────────────
  Future<List<CaseLaw>> getCaseLaws();
  Future<CaseLaw?>      getCaseLawById(String id);
  Future<List<CaseLaw>> getCaseLawsByIds(List<String> ids);

  // ── Academic Notes ────────────────────────────
  Future<List<AcademicYear>>    getAcademicYears();
  Future<List<AcademicSubject>> getSubjects();

  // ── Bookmarks ─────────────────────────────────
  Future<List<Bookmark>> getBookmarks();
  Future<void>           saveBookmark(Bookmark bookmark);
  Future<void>           removeBookmark(String bookmarkId);
  Future<bool>           isBookmarked(String contentId);

  // ── Personal Notes ────────────────────────────
  Future<List<PersonalNote>> getNotes();
  Future<PersonalNote?>      getNoteById(String id);
  Future<void>               saveNote(PersonalNote note);
  Future<void>               deleteNote(String noteId);

  // ── Cache ─────────────────────────────────────
  Future<void> clearCache();
}

// ─────────────────────────────────────────────
// MARK: — LOCAL REPOSITORY IMPLEMENTATION
// ─────────────────────────────────────────────

class LocalLegalRepository implements LegalRepository {
  // ── Singleton pattern (optional, swap for DI) ──
  static final LocalLegalRepository _instance =
      LocalLegalRepository._internal();
  factory LocalLegalRepository() => _instance;
  LocalLegalRepository._internal();

  // ── Cache ──────────────────────────────────────
  List<Act>?              _cachedActs;
  List<ConstitutionPart>? _cachedConstitution;
  List<CaseLaw>?          _cachedCaseLaws;
  List<AcademicYear>?     _cachedAcademicYears;

  // ── In-memory mutable storage ──────────────────
  // Future: Replace with Isar / Hive
  final List<Bookmark>     _bookmarks = [];
  final List<PersonalNote> _notes     = List.from(_mockNotes);

  // ─────────────────────────────────────────────
  // MARK: — ACTS
  // ─────────────────────────────────────────────

  @override
  Future<List<Act>> getActs() async {
    _cachedActs ??= await _loadActs();
    return List.unmodifiable(_cachedActs!);
  }

  @override
  Future<Act?> getActById(String id) async {
    final acts = await getActs();
    try {
      return acts.firstWhere((a) => a.id == id);
    } on StateError {
      return null;
    }
  }

  @override
  Future<Section?> getSectionById(String sectionId) async {
    final acts = await getActs();
    for (final act in acts) {
      for (final chapter in act.chapters) {
        for (final section in chapter.sections) {
          if (section.id == sectionId) return section;
        }
      }
    }
    return null;
  }

  @override
  Future<List<Act>> searchActs(String query) async {
    final acts = await getActs();
    if (query.trim().isEmpty) return List.unmodifiable(acts);
    final q = query.toLowerCase().trim();
    return acts
        .where((a) =>
            a.title.toLowerCase().contains(q) ||
            (a.shortTitle?.toLowerCase().contains(q) ?? false) ||
            a.year.toString().contains(q) ||
            a.category.name.toLowerCase().contains(q))
        .toList();
  }

  // ─────────────────────────────────────────────
  // MARK: — CONSTITUTION
  // ─────────────────────────────────────────────

  @override
  Future<List<ConstitutionPart>> getConstitutionParts() async {
    _cachedConstitution ??= await _loadConstitution();
    return List.unmodifiable(_cachedConstitution!);
  }

  @override
  Future<ConstitutionPart?> getConstitutionPartById(String id) async {
    final parts = await getConstitutionParts();
    try {
      return parts.firstWhere((p) => p.id == id);
    } on StateError {
      return null;
    }
  }

  @override
  Future<Article?> getArticleById(String articleId) async {
    final parts = await getConstitutionParts();
    for (final part in parts) {
      for (final article in part.articles) {
        if (article.id == articleId) return article;
      }
    }
    return null;
  }

  // ─────────────────────────────────────────────
  // MARK: — CASE LAWS
  // ─────────────────────────────────────────────

  @override
  Future<List<CaseLaw>> getCaseLaws() async {
    _cachedCaseLaws ??= await _loadCaseLaws();
    return List.unmodifiable(_cachedCaseLaws!);
  }

  @override
  Future<CaseLaw?> getCaseLawById(String id) async {
    final laws = await getCaseLaws();
    try {
      return laws.firstWhere((c) => c.id == id);
    } on StateError {
      return null;
    }
  }

  @override
  Future<List<CaseLaw>> getCaseLawsByIds(List<String> ids) async {
    if (ids.isEmpty) return const [];
    final laws = await getCaseLaws();
    final idSet = ids.toSet();
    return laws.where((c) => idSet.contains(c.id)).toList();
  }

  // ─────────────────────────────────────────────
  // MARK: — ACADEMIC NOTES
  // ─────────────────────────────────────────────

  @override
  Future<List<AcademicYear>> getAcademicYears() async {
    _cachedAcademicYears ??= await _loadAcademicYears();
    return List.unmodifiable(_cachedAcademicYears!);
  }

  @override
  Future<List<AcademicSubject>> getSubjects() async {
    final years = await getAcademicYears();
    return years.expand((y) => y.subjects).toList();
  }

  // ─────────────────────────────────────────────
  // MARK: — BOOKMARKS
  // ─────────────────────────────────────────────

  @override
  Future<List<Bookmark>> getBookmarks() async {
    // Future: await _isarService.getBookmarks()
    await _simulateIO();
    return List.unmodifiable(_bookmarks);
  }

  @override
  Future<void> saveBookmark(Bookmark bookmark) async {
    // Future: await _isarService.saveBookmark(bookmark)
    await _simulateIO(milliseconds: 80);
    final index = _bookmarks.indexWhere((b) => b.id == bookmark.id);
    if (index >= 0) {
      _bookmarks[index] = bookmark; // update
    } else {
      _bookmarks.add(bookmark);     // insert
    }
  }

  @override
  Future<void> removeBookmark(String bookmarkId) async {
    // Future: await _isarService.removeBookmark(bookmarkId)
    await _simulateIO(milliseconds: 80);
    _bookmarks.removeWhere((b) => b.id == bookmarkId);
  }

  @override
  Future<bool> isBookmarked(String contentId) async {
    await _simulateIO(milliseconds: 30);
    return _bookmarks.any((b) => b.linkedContentId == contentId);
  }

  // ─────────────────────────────────────────────
  // MARK: — PERSONAL NOTES
  // ─────────────────────────────────────────────

  @override
  Future<List<PersonalNote>> getNotes() async {
    // Future: await _isarService.getNotes()
    await _simulateIO();
    final sorted = List<PersonalNote>.from(_notes)
      ..sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return b.lastModified.compareTo(a.lastModified);
      });
    return List.unmodifiable(sorted);
  }

  @override
  Future<PersonalNote?> getNoteById(String id) async {
    await _simulateIO(milliseconds: 40);
    try {
      return _notes.firstWhere((n) => n.id == id);
    } on StateError {
      return null;
    }
  }

  @override
  Future<void> saveNote(PersonalNote note) async {
    // Future: await _isarService.saveNote(note)
    await _simulateIO(milliseconds: 100);
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index >= 0) {
      _notes[index] = note; // update
    } else {
      _notes.add(note);     // insert
    }
  }

  @override
  Future<void> deleteNote(String noteId) async {
    // Future: await _isarService.deleteNote(noteId)
    await _simulateIO(milliseconds: 80);
    _notes.removeWhere((n) => n.id == noteId);
  }

  // ─────────────────────────────────────────────
  // MARK: — CACHE
  // ─────────────────────────────────────────────

  @override
  Future<void> clearCache() async {
    _cachedActs          = null;
    _cachedConstitution  = null;
    _cachedCaseLaws      = null;
    _cachedAcademicYears = null;
  }

  // ─────────────────────────────────────────────
  // MARK: — PRIVATE: LOAD ACTS
  // Future: Read from assets/data/acts.json
  // ─────────────────────────────────────────────

  Future<List<Act>> _loadActs() async {
    // ── Future JSON implementation ────────────────
    // final jsonStr = await rootBundle.loadString('assets/data/acts.json');
    // final list    = jsonDecode(jsonStr) as List;
    // return list.map((j) => Act.fromJson(j as Map<String, dynamic>)).toList();

    await _simulateIO(milliseconds: 220);
    return _mockActs;
  }

  // ─────────────────────────────────────────────
  // MARK: — PRIVATE: LOAD CONSTITUTION
  // Future: Read from assets/data/constitution.json
  // ─────────────────────────────────────────────

  Future<List<ConstitutionPart>> _loadConstitution() async {
    // ── Future JSON implementation ────────────────
    // final jsonStr = await rootBundle.loadString('assets/data/constitution.json');
    // final list    = jsonDecode(jsonStr) as List;
    // return list.map((j) => ConstitutionPart.fromJson(j as Map<String, dynamic>)).toList();

    await _simulateIO(milliseconds: 200);
    return _mockConstitution;
  }

  // ─────────────────────────────────────────────
  // MARK: — PRIVATE: LOAD CASE LAWS
  // Future: Read from assets/data/case_laws.json
  // ─────────────────────────────────────────────

  Future<List<CaseLaw>> _loadCaseLaws() async {
    // ── Future JSON implementation ────────────────
    // final jsonStr = await rootBundle.loadString('assets/data/case_laws.json');
    // final list    = jsonDecode(jsonStr) as List;
    // return list.map((j) => CaseLaw.fromJson(j as Map<String, dynamic>)).toList();

    await _simulateIO(milliseconds: 150);
    return _mockCaseLaws;
  }

  // ─────────────────────────────────────────────
  // MARK: — PRIVATE: LOAD ACADEMIC YEARS
  // Future: Read from assets/data/academic.json
  // ─────────────────────────────────────────────

  Future<List<AcademicYear>> _loadAcademicYears() async {
    // ── Future JSON implementation ────────────────
    // final jsonStr = await rootBundle.loadString('assets/data/academic.json');
    // final list    = jsonDecode(jsonStr) as List;
    // return list.map((j) => AcademicYear.fromJson(j as Map<String, dynamic>)).toList();

    await _simulateIO(milliseconds: 180);
    return _mockAcademicYears;
  }

  // ─────────────────────────────────────────────
  // MARK: — PRIVATE: IO SIMULATOR
  // ─────────────────────────────────────────────

  Future<void> _simulateIO({int milliseconds = 120}) =>
      Future.delayed(Duration(milliseconds: milliseconds));
}

// ═════════════════════════════════════════════
// MARK: — MOCK DATA LAYER
// Replace entirely with JSON assets in production.
// ═════════════════════════════════════════════

// ─────────────────────────────────────────────
// MARK: — MOCK CASE LAWS
// ─────────────────────────────────────────────

const List<CaseLaw> _mockCaseLaws = [
  CaseLaw(
    id: 'cl_1',
    title: 'Hira Lal Hari Lal Bhagwati v. Central Bureau of Investigation',
    citation: '(2003) 5 SCC 257',
    court: 'Supreme Court of India',
    year: '2003',
    facts:
        'The appellants were Directors of a company engaged in the import of chemicals. The CBI alleged that they made false representations to the Ministry of Commerce, fraudulently claiming to be actual end-users of restricted chemicals. On the strength of these representations, import licences were issued. The chemicals were allegedly sold in the open market instead of being used for the industrial purpose stated.',
    issues:
        '1. Whether the representations made constituted cheating.\n2. Whether directors could be held vicariously liable.\n3. Whether dishonest intent existed at inception of the transaction.',
    judgment:
        'The Supreme Court upheld the order of discharge, holding that no prima facie case was established. The prosecution failed to show dishonest intent at the time of making the representations.',
    reasoning:
        'The Court drew a clear distinction between contractual breach and criminal cheating. Dishonest or fraudulent intent at the inception of the transaction is a sine qua non. Subsequent misuse of a licence alone does not establish the offence.',
    significance:
        'This is a leading authority on the principle that pre-existing dishonest intent is essential for cheating. It clearly delineates the boundary between civil wrong and criminal liability.',
    relatedSectionIds: ['sec_318'],
    relatedActIds: ['bns_2023'],
  ),
  CaseLaw(
    id: 'cl_2',
    title: 'Inder Mohan Goswami v. State of Uttaranchal',
    citation: '(2007) 12 SCC 1',
    court: 'Supreme Court of India',
    year: '2007',
    facts:
        'The appellants were editors and publishers of a newspaper. A complaint was filed alleging cheating in a financial transaction. The High Court declined to quash proceedings.',
    issues:
        '1. Whether the allegations disclosed the ingredients of cheating.\n2. Whether the High Court should have exercised inherent jurisdiction to quash.',
    judgment:
        'The Supreme Court quashed the criminal proceedings, holding that the allegations did not disclose the essential ingredients of cheating.',
    reasoning:
        'The Court emphasised that vague and omnibus allegations cannot be allowed to proceed to trial. Criminal law must not be used as an instrument of harassment.',
    significance:
        'Authority for the principle that courts must scrutinise complaints at the threshold to prevent misuse of criminal process.',
    relatedSectionIds: ['sec_318'],
    relatedActIds: ['bns_2023'],
  ),
  CaseLaw(
    id: 'cl_3',
    title: 'Maneka Gandhi v. Union of India',
    citation: 'AIR 1978 SC 597',
    court: 'Supreme Court of India',
    year: '1978',
    facts:
        'The petitioner\'s passport was impounded by the Government of India without giving any reason. She challenged the action as violating her fundamental right to personal liberty under Article 21.',
    issues:
        '1. Whether the right to travel abroad is part of personal liberty under Article 21.\n2. Whether Article 21 must be read in conjunction with Articles 14 and 19.\n3. What constitutes procedure established by law.',
    judgment:
        'The Supreme Court held that the procedure depriving a person of personal liberty must be fair, just and reasonable. The Government\'s action was struck down.',
    reasoning:
        'Article 21 is not to be read in isolation. The procedure prescribed by law must comply with Articles 14 and 19. Mere existence of a procedure is insufficient; it must be a fair and just procedure.',
    significance:
        'Landmark judgment that enormously expanded the scope of Article 21. Established that due process is implied in the Indian Constitution despite the absence of the American due process clause.',
    relatedArticleIds: ['art_21'],
  ),
  CaseLaw(
    id: 'cl_4',
    title: 'Vishaka v. State of Rajasthan',
    citation: 'AIR 1997 SC 3011',
    court: 'Supreme Court of India',
    year: '1997',
    facts:
        'A social worker was gang-raped in retaliation for her work preventing a child marriage. A Public Interest Litigation was filed highlighting the absence of legislation against sexual harassment at the workplace.',
    issues:
        '1. Whether sexual harassment at the workplace violates fundamental rights.\n2. Whether guidelines can be issued in the absence of legislation.',
    judgment:
        'The Supreme Court issued the Vishaka Guidelines binding on employers until legislation was enacted. These were later codified in the Sexual Harassment of Women at Workplace Act, 2013.',
    reasoning:
        'Sexual harassment violates Articles 14, 15, 19(1)(g) and 21. In the absence of domestic law, international conventions ratified by India can be used to fill the gap.',
    significance:
        'Pioneering judgment on sexual harassment at the workplace. Demonstrated the Supreme Court\'s power to issue binding guidelines as a legislative stopgap.',
    relatedArticleIds: ['art_14', 'art_21'],
  ),
  CaseLaw(
    id: 'cl_5',
    title: 'Kesavananda Bharati v. State of Kerala',
    citation: 'AIR 1973 SC 1461',
    court: 'Supreme Court of India',
    year: '1973',
    facts:
        'The petitioner, head of a religious order, challenged the Kerala Land Reforms Act which restricted the right to manage religious property. The case raised the question of Parliament\'s power to amend the Constitution.',
    issues:
        '1. Whether Parliament has unlimited power to amend the Constitution.\n2. Whether the basic structure of the Constitution can be abrogated.',
    judgment:
        'By a 7:6 majority, the Supreme Court held that Parliament can amend any part of the Constitution but cannot destroy its basic structure.',
    reasoning:
        'The word "amend" implies modification within the framework of the original document. Certain basic features — democracy, federalism, secularism, judicial review — form the inviolable core.',
    significance:
        'The most significant constitutional judgment in Indian legal history. The basic structure doctrine remains the most powerful limitation on parliamentary sovereignty.',
    relatedArticleIds: ['art_368'],
  ),
  CaseLaw(
    id: 'cl_6',
    title: 'Carlill v. Carbolic Smoke Ball Co.',
    citation: '[1893] 1 QB 256',
    court: 'Court of Appeal, England',
    year: '1893',
    facts:
        'The defendants advertised that their smoke ball would prevent influenza and offered £100 to anyone who contracted influenza after using it. The plaintiff used it as directed and caught influenza.',
    issues:
        '1. Whether the advertisement constituted an offer.\n2. Whether the plaintiff\'s use constituted acceptance.\n3. Whether there was valid consideration.',
    judgment:
        'The Court of Appeal held that there was a valid, binding contract. The plaintiff was entitled to £100.',
    reasoning:
        'A general offer can be accepted by any person who performs the required conditions. Communication of acceptance is not necessary where the offeror waives it.',
    significance:
        'Foundational contract law case establishing that advertisements can constitute binding offers and that conduct can constitute acceptance without explicit communication.',
    relatedSectionIds: ['sec_2_ica'],
    relatedActIds: ['ica_1872'],
  ),
];

// ─────────────────────────────────────────────
// MARK: — MOCK ACTS
// ─────────────────────────────────────────────

final List<Act> _mockActs = [
  // ── Bharatiya Nyaya Sanhita, 2023 ────────────
  Act(
    id: 'bns_2023',
    title: 'Bharatiya Nyaya Sanhita',
    shortTitle: 'BNS',
    year: 2023,
    category: ActCategory.criminal,
    description:
        'An Act to consolidate and amend the provisions of penal law. This Act replaces the Indian Penal Code, 1860.',
    chapters: [
      Chapter(
        id: 'bns_ch1',
        chapterNumber: 'I',
        title: 'Preliminary',
        sections: [
          Section(
            id: 'sec_1_bns',
            sectionNumber: '1',
            title: 'Short title, extent and commencement',
            content: [
              const SectionTextBlock(
                type: TextBlockType.main,
                text:
                    'This Act may be called the Bharatiya Nyaya Sanhita, 2023. It extends to the whole of India except the State of Jammu and Kashmir. It shall come into force on such date as the Central Government may, by notification in the Official Gazette, appoint.',
              ),
            ],
            caseLawIds: const [],
          ),
          Section(
            id: 'sec_2_bns',
            sectionNumber: '2',
            title: 'Definitions',
            content: [
              const SectionTextBlock(
                type: TextBlockType.main,
                text:
                    'In this Act, unless the context otherwise requires, the following expressions are used in the following senses:— (1) "Act" denotes a series of acts as well as a single act. (2) "Animal" denotes any living creature, other than a human being.',
              ),
            ],
            caseLawIds: const [],
          ),
        ],
      ),
      Chapter(
        id: 'bns_ch2',
        chapterNumber: 'II',
        title: 'General Explanations',
        sections: [
          Section(
            id: 'sec_3_bns',
            sectionNumber: '3',
            title: 'General explanations',
            content: [
              const SectionTextBlock(
                type: TextBlockType.main,
                text:
                    'Throughout this Act every definition of an offence, every penal provision, and every illustration of every such definition or penal provision, shall be understood subject to the exceptions contained in the Chapter entitled "General Exceptions".',
              ),
            ],
            caseLawIds: const [],
          ),
          Section(
            id: 'sec_4_bns',
            sectionNumber: '4',
            title: 'Act includes illegal omission',
            content: [
              const SectionTextBlock(
                type: TextBlockType.main,
                text:
                    'In this Act, the word "act" denotes as well a series of acts as a single act: the word "omission" denotes as well a series of omissions as a single omission.',
              ),
            ],
            caseLawIds: const [],
          ),
        ],
      ),
      Chapter(
        id: 'bns_ch17',
        chapterNumber: 'XVII',
        title: 'Offences Against Property',
        sections: [
          Section(
            id: 'sec_316_bns',
            sectionNumber: '316',
            title: 'Cheating',
            content: [
              const SectionTextBlock(
                type: TextBlockType.main,
                text:
                    'Whoever cheats shall be punished with imprisonment of either description for a term which may extend to three years, or with fine, or with both.',
              ),
            ],
            caseLawIds: const [],
          ),
          Section(
            id: 'sec_318',
            sectionNumber: '318',
            title:
                'Cheating and dishonestly inducing delivery of property',
            content: [
              const SectionTextBlock(
                type: TextBlockType.main,
                text:
                    'Whoever cheats and thereby dishonestly induces the person deceived to deliver any property or valuable security, or to alter or destroy the whole or any part of a valuable security, to any person, or to make, alter or destroy the whole or any part of a valuable security, or anything which is sealed or signed or is capable of being converted into a valuable security, shall be punished with imprisonment of either description for a term which may extend to seven years, and shall also be liable to fine.',
              ),
              const SectionTextBlock(
                type: TextBlockType.explanation,
                label: 'Explanation 1.\u2014',
                text:
                    'A person is said to "cheat" who, by deceiving another person, fraudulently or dishonestly induces the person so deceived to deliver any property to any person, or to consent that any person shall retain any property, or intentionally induces the person so deceived to do or omit to do anything which he would not do or omit if he were not so deceived, and which act or omission causes or is likely to cause damage or harm to that person in body, mind, reputation or property.',
              ),
              const SectionTextBlock(
                type: TextBlockType.explanation,
                label: 'Explanation 2.\u2014',
                text:
                    'A dishonest concealment of facts is a deception within the meaning of this section.',
              ),
            ],
            caseLawIds: ['cl_1', 'cl_2'],
          ),
        ],
      ),
    ],
  ),

  // ── Indian Contract Act, 1872 ─────────────────
  Act(
    id: 'ica_1872',
    title: 'Indian Contract Act',
    shortTitle: 'ICA',
    year: 1872,
    category: ActCategory.commercial,
    description:
        'An Act to define and amend the law relating to contracts. Governs formation, validity, and enforcement of contracts in India.',
    chapters: [
      Chapter(
        id: 'ica_ch1',
        chapterNumber: 'I',
        title: 'Of the Communication, Acceptance and Revocation of Proposals',
        sections: [
          Section(
            id: 'sec_1_ica',
            sectionNumber: '1',
            title: 'Short title',
            content: [
              const SectionTextBlock(
                type: TextBlockType.main,
                text:
                    'This Act may be called the Indian Contract Act, 1872.',
              ),
            ],
            caseLawIds: const [],
          ),
          Section(
            id: 'sec_2_ica',
            sectionNumber: '2',
            title: 'Interpretation clause',
            content: [
              const SectionTextBlock(
                type: TextBlockType.main,
                text:
                    'In this Act the following words and expressions are used in the following senses, unless a contrary intention appears from the context:— (a) When one person signifies to another his willingness to do or to abstain from doing anything, with a view to obtaining the assent of that other to such act or abstinence, he is said to make a proposal; (b) When the person to whom the proposal is made signifies his assent thereto, the proposal is said to be accepted.',
              ),
            ],
            caseLawIds: ['cl_6'],
          ),
          Section(
            id: 'sec_10_ica',
            sectionNumber: '10',
            title: 'What agreements are contracts',
            content: [
              const SectionTextBlock(
                type: TextBlockType.main,
                text:
                    'All agreements are contracts if they are made by the free consent of parties competent to contract, for a lawful consideration and with a lawful object, and are not hereby expressly declared to be void.',
              ),
              const SectionTextBlock(
                type: TextBlockType.explanation,
                label: 'Explanation.\u2014',
                text:
                    'Nothing herein contained shall affect any law in force in India, and not hereby expressly repealed, by which any contract is required to be made in writing or in the presence of witnesses, or any law relating to the registration of documents.',
              ),
            ],
            caseLawIds: const [],
          ),
        ],
      ),
      Chapter(
        id: 'ica_ch6',
        chapterNumber: 'VI',
        title: 'Of the Consequences of Breach of Contract',
        sections: [
          Section(
            id: 'sec_73_ica',
            sectionNumber: '73',
            title:
                'Compensation for loss or damage caused by breach of contract',
            content: [
              const SectionTextBlock(
                type: TextBlockType.main,
                text:
                    'When a contract has been broken, the party who suffers by such breach is entitled to receive, from the party who has broken it, compensation for any loss or damage caused to him thereby, which naturally arose in the usual course of things from such breach, or which the parties knew, when they made the contract, to be likely to result from the breach of it.',
              ),
              const SectionTextBlock(
                type: TextBlockType.proviso,
                label: 'Explanation.\u2014',
                text:
                    'In estimating the loss or damage arising from a breach of contract, the means which existed of remedying the inconvenience caused by the non-performance of the contract must be taken into account.',
              ),
            ],
            caseLawIds: const [],
          ),
        ],
      ),
    ],
  ),

  // ── Code of Civil Procedure, 1908 ────────────
  Act(
    id: 'cpc_1908',
    title: 'Code of Civil Procedure',
    shortTitle: 'CPC',
    year: 1908,
    category: ActCategory.civil,
    description:
        'An Act to consolidate and amend the laws relating to the procedure of the Courts of Civil Judicature.',
    chapters: [
      Chapter(
        id: 'cpc_ch1',
        chapterNumber: 'I',
        title: 'Preliminary',
        sections: [
          Section(
            id: 'sec_1_cpc',
            sectionNumber: '1',
            title: 'Short title, commencement and extent',
            content: [
              const SectionTextBlock(
                type: TextBlockType.main,
                text:
                    'This Act may be cited as the Code of Civil Procedure, 1908. It shall come into force on the first day of January, 1909. It extends to the whole of India except the State of Jammu and Kashmir.',
              ),
            ],
            caseLawIds: const [],
          ),
          Section(
            id: 'sec_9_cpc',
            sectionNumber: '9',
            title: 'Courts to try all civil suits unless barred',
            content: [
              const SectionTextBlock(
                type: TextBlockType.main,
                text:
                    'The Courts shall (subject to the provisions herein contained) have jurisdiction to try all Suits of a civil nature excepting suits of which their cognizance is either expressly or impliedly barred.',
              ),
              const SectionTextBlock(
                type: TextBlockType.explanation,
                label: 'Explanation I.\u2014',
                text:
                    'A suit in which the right to property or to an office is contested is a suit of a civil nature, notwithstanding that such right may depend entirely on the decision of questions as to religious rites or ceremonies.',
              ),
            ],
            caseLawIds: const [],
          ),
        ],
      ),
    ],
  ),
];

// ─────────────────────────────────────────────
// MARK: — MOCK CONSTITUTION
// ─────────────────────────────────────────────

const List<ConstitutionPart> _mockConstitution = [
  ConstitutionPart(
    id: 'part_1',
    partNumber: 'I',
    title: 'The Union and its Territory',
    articles: [
      Article(
        id: 'preamble',
        articleNumber: 'Preamble',
        title: 'Preamble of the Constitution of India',
        isPreamble: true,
        content: [
          SectionTextBlock(
            type: TextBlockType.main,
            text:
                'WE, THE PEOPLE OF INDIA, having solemnly resolved to constitute India into a SOVEREIGN SOCIALIST SECULAR DEMOCRATIC REPUBLIC and to secure to all its citizens: JUSTICE, social, economic and political; LIBERTY of thought, expression, belief, faith and worship; EQUALITY of status and of opportunity; and to promote among them all FRATERNITY assuring the dignity of the individual and the unity and integrity of the Nation; IN OUR CONSTITUENT ASSEMBLY this twenty-sixth day of November, 1949, do HEREBY ADOPT, ENACT AND GIVE TO OURSELVES THIS CONSTITUTION.',
          ),
        ],
        caseLawIds: [],
      ),
      Article(
        id: 'art_1',
        articleNumber: '1',
        title: 'Name and territory of the Union',
        content: [
          SectionTextBlock(
            type: TextBlockType.main,
            text:
                '(1) India, that is Bharat, shall be a Union of States. (2) The States and the territories thereof shall be as specified in the First Schedule. (3) The territory of India shall comprise— (a) the territories of the States; (b) the Union territories specified in the First Schedule; and (c) such other territories as may be acquired.',
          ),
        ],
        caseLawIds: [],
      ),
      Article(
        id: 'art_3',
        articleNumber: '3',
        title:
            'Formation of new States and alteration of areas, boundaries or names of existing States',
        content: [
          SectionTextBlock(
            type: TextBlockType.main,
            text:
                'Parliament may by law— (a) form a new State by separation of territory from any State or by uniting two or more States or parts of States or by uniting any territory to a part of any State; (b) increase the area of any State; (c) diminish the area of any State; (d) alter the boundaries of any State; (e) alter the name of any State.',
          ),
          SectionTextBlock(
            type: TextBlockType.proviso,
            label: 'Proviso.\u2014',
            text:
                'No Bill for the purpose shall be introduced in either House of Parliament except on the recommendation of the President and unless, where the proposal contained in the Bill affects the area, boundaries or name of any of the States, the Bill has been referred by the President to the Legislature of that State for expressing its views thereon.',
          ),
        ],
        caseLawIds: [],
      ),
    ],
  ),
  ConstitutionPart(
    id: 'part_3',
    partNumber: 'III',
    title: 'Fundamental Rights',
    articles: [
      Article(
        id: 'art_14',
        articleNumber: '14',
        title: 'Equality before law',
        content: [
          SectionTextBlock(
            type: TextBlockType.main,
            text:
                'The State shall not deny to any person equality before the law or the equal protection of the laws within the territory of India.',
          ),
        ],
        caseLawIds: ['cl_4'],
      ),
      Article(
        id: 'art_19',
        articleNumber: '19',
        title:
            'Protection of certain rights regarding freedom of speech, etc.',
        content: [
          SectionTextBlock(
            type: TextBlockType.main,
            text:
                '(1) All citizens shall have the right— (a) to freedom of speech and expression; (b) to assemble peaceably and without arms; (c) to form associations or unions or co-operative societies; (d) to move freely throughout the territory of India; (e) to reside and settle in any part of the territory of India; and (g) to practise any profession, or to carry on any occupation, trade or business.',
          ),
        ],
        caseLawIds: [],
      ),
      Article(
        id: 'art_21',
        articleNumber: '21',
        title: 'Protection of life and personal liberty',
        content: [
          SectionTextBlock(
            type: TextBlockType.main,
            text:
                'No person shall be deprived of his life or personal liberty except according to procedure established by law.',
          ),
        ],
        caseLawIds: ['cl_3', 'cl_4'],
      ),
      Article(
        id: 'art_21a',
        articleNumber: '21A',
        title: 'Right to education',
        content: [
          SectionTextBlock(
            type: TextBlockType.main,
            text:
                'The State shall provide free and compulsory education to all children of the age of six to fourteen years in such manner as the State may, by law, determine.',
          ),
        ],
        caseLawIds: [],
      ),
      Article(
        id: 'art_32',
        articleNumber: '32',
        title:
            'Remedies for enforcement of rights conferred by this Part',
        content: [
          SectionTextBlock(
            type: TextBlockType.main,
            text:
                '(1) The right to move the Supreme Court by appropriate proceedings for the enforcement of the rights conferred by this Part is guaranteed. (2) The Supreme Court shall have power to issue directions or orders or writs, including writs in the nature of habeas corpus, mandamus, prohibition, quo warranto and certiorari, whichever may be appropriate, for the enforcement of any of the rights conferred by this Part.',
          ),
        ],
        caseLawIds: [],
      ),
    ],
  ),
  ConstitutionPart(
    id: 'part_4',
    partNumber: 'IV',
    title: 'Directive Principles of State Policy',
    articles: [
      Article(
        id: 'art_37',
        articleNumber: '37',
        title: 'Application of the principles contained in this Part',
        content: [
          SectionTextBlock(
            type: TextBlockType.main,
            text:
                'The provisions contained in this Part shall not be enforceable by any court, but the principles therein laid down are nevertheless fundamental in the governance of the country and it shall be the duty of the State to apply these principles in making laws.',
          ),
        ],
        caseLawIds: [],
      ),
      Article(
        id: 'art_44',
        articleNumber: '44',
        title: 'Uniform civil code for the citizens',
        content: [
          SectionTextBlock(
            type: TextBlockType.main,
            text:
                'The State shall endeavour to secure for the citizens a uniform civil code throughout the territory of India.',
          ),
        ],
        caseLawIds: [],
      ),
    ],
  ),
  ConstitutionPart(
    id: 'part_4a',
    partNumber: 'IVA',
    title: 'Fundamental Duties',
    articles: [
      Article(
        id: 'art_51a',
        articleNumber: '51A',
        title: 'Fundamental duties',
        content: [
          SectionTextBlock(
            type: TextBlockType.main,
            text:
                'It shall be the duty of every citizen of India— (a) to abide by the Constitution and respect its ideals and institutions, the National Flag and the National Anthem; (b) to cherish and follow the noble ideals which inspired our national struggle for freedom; (c) to uphold and protect the sovereignty, unity and integrity of India; (d) to defend the country and render national service when called upon to do so.',
          ),
        ],
        caseLawIds: [],
      ),
    ],
  ),
  ConstitutionPart(
    id: 'part_20',
    partNumber: 'XX',
    title: 'Amendment of the Constitution',
    articles: [
      Article(
        id: 'art_368',
        articleNumber: '368',
        title:
            'Power of Parliament to amend the Constitution and procedure therefor',
        content: [
          SectionTextBlock(
            type: TextBlockType.main,
            text:
                '(1) Notwithstanding anything in this Constitution, Parliament may in exercise of its constituent power amend by way of addition, variation or repeal any provision of this Constitution in accordance with the procedure laid down in this article. (2) An amendment of this Constitution may be initiated only by the introduction of a Bill for the purpose in either House of Parliament.',
          ),
        ],
        caseLawIds: ['cl_5'],
      ),
    ],
  ),
];

// ─────────────────────────────────────────────
// MARK: — MOCK ACADEMIC YEARS
// ─────────────────────────────────────────────

final List<AcademicYear> _mockAcademicYears = [
  AcademicYear(
    id: 'y1',
    title: 'BALLB 1st Year',
    yearNumber: 1,
    program: 'BALLB',
    firstSemester: 1,
    lastSemester: 2,
    subjects: const [
      AcademicSubject(
        id: 'y1_s1',
        title: 'Constitutional Law I',
        description:
            'Fundamental rights, directive principles, constitutional history and amendment procedure.',
        pdfPath: 'assets/pdfs/y1/constitutional_law_1.pdf',
        semester: 1,
        totalPages: 248,
        isDownloaded: true,
      ),
      AcademicSubject(
        id: 'y1_s2',
        title: 'Law of Contracts',
        description:
            'Indian Contract Act 1872 — offer, acceptance, consideration and breach.',
        pdfPath: 'assets/pdfs/y1/law_of_contracts.pdf',
        semester: 1,
        totalPages: 312,
        isDownloaded: true,
      ),
      AcademicSubject(
        id: 'y1_s3',
        title: 'Legal Methods and Research',
        description:
            'Legal reasoning, case analysis and statutory interpretation.',
        pdfPath: 'assets/pdfs/y1/legal_methods.pdf',
        semester: 1,
        totalPages: 186,
        isDownloaded: false,
      ),
      AcademicSubject(
        id: 'y1_s4',
        title: 'Family Law I',
        description:
            'Hindu Marriage Act, Muslim personal law and succession.',
        pdfPath: 'assets/pdfs/y1/family_law_1.pdf',
        semester: 2,
        totalPages: 274,
        isDownloaded: true,
      ),
      AcademicSubject(
        id: 'y1_s5',
        title: 'Law of Torts',
        description: 'Tort liability, negligence, defamation and nuisance.',
        pdfPath: 'assets/pdfs/y1/law_of_torts.pdf',
        semester: 2,
        totalPages: 258,
        isDownloaded: false,
      ),
    ],
  ),
  AcademicYear(
    id: 'y2',
    title: 'BALLB 2nd Year',
    yearNumber: 2,
    program: 'BALLB',
    firstSemester: 3,
    lastSemester: 4,
    subjects: const [
      AcademicSubject(
        id: 'y2_s1',
        title: 'Constitutional Law II',
        description:
            'Federal structure, emergency provisions and constitutional amendments.',
        pdfPath: 'assets/pdfs/y2/constitutional_law_2.pdf',
        semester: 3,
        totalPages: 290,
        isDownloaded: true,
      ),
      AcademicSubject(
        id: 'y2_s2',
        title: 'Administrative Law',
        description:
            'Delegated legislation, judicial review and natural justice.',
        pdfPath: 'assets/pdfs/y2/administrative_law.pdf',
        semester: 3,
        totalPages: 336,
        isDownloaded: false,
      ),
      AcademicSubject(
        id: 'y2_s3',
        title: 'Criminal Law I (BNS)',
        description:
            'General exceptions, offences against the state and public tranquillity.',
        pdfPath: 'assets/pdfs/y2/criminal_law_1.pdf',
        semester: 3,
        totalPages: 368,
        isDownloaded: true,
      ),
      AcademicSubject(
        id: 'y2_s4',
        title: 'Jurisprudence',
        description:
            'Legal theory, schools of jurisprudence, rights and duties.',
        pdfPath: 'assets/pdfs/y2/jurisprudence.pdf',
        semester: 4,
        totalPages: 312,
        isPremium: true,
        isDownloaded: false,
      ),
    ],
  ),
  AcademicYear(
    id: 'y3',
    title: 'BALLB 3rd Year',
    yearNumber: 3,
    program: 'BALLB',
    firstSemester: 5,
    lastSemester: 6,
    subjects: const [
      AcademicSubject(
        id: 'y3_s1',
        title: 'Criminal Law II (BNSS)',
        description:
            'Criminal procedure, investigation, trial, bail and appeals.',
        pdfPath: 'assets/pdfs/y3/criminal_law_2.pdf',
        semester: 5,
        totalPages: 420,
        isDownloaded: false,
      ),
      AcademicSubject(
        id: 'y3_s2',
        title: 'Code of Civil Procedure',
        description:
            'CPC 1908 — suits, jurisdiction, appeals and execution of decrees.',
        pdfPath: 'assets/pdfs/y3/cpc.pdf',
        semester: 5,
        totalPages: 390,
        isDownloaded: false,
      ),
      AcademicSubject(
        id: 'y3_s3',
        title: 'Law of Evidence (BSA)',
        description:
            'Bharatiya Sakshya Adhiniyam — relevancy, admissibility and witnesses.',
        pdfPath: 'assets/pdfs/y3/evidence_law.pdf',
        semester: 5,
        totalPages: 344,
        isDownloaded: true,
      ),
    ],
  ),
];

// ─────────────────────────────────────────────
// MARK: — MOCK PERSONAL NOTES
// ─────────────────────────────────────────────

final List<PersonalNote> _mockNotes = [
  PersonalNote(
    id: 'note_1',
    title: 'Fundamental Rights Summary',
    content:
        'Articles 12–35 of the Constitution guarantee Fundamental Rights.\n\n'
        '• Right to Equality (Arts. 14–18)\n'
        '• Right to Freedom (Art. 19)\n'
        '• Right against Exploitation (Arts. 23–24)\n'
        '• Right to Freedom of Religion (Arts. 25–28)\n'
        '• Cultural and Educational Rights (Arts. 29–30)\n'
        '• Right to Constitutional Remedies (Art. 32)\n\n'
        'Art. 21 is the most expansive and has been interpreted broadly.',
    lastModified: DateTime.now().subtract(const Duration(hours: 3)),
    createdAt:    DateTime.now().subtract(const Duration(days: 14)),
    isPinned: true,
    tags: ['Constitution', 'Fundamental Rights', 'Part III'],
    linkedContentId: 'part_3',
    linkedContentType: BookmarkContentType.article,
  ),
  PersonalNote(
    id: 'note_2',
    title: 'Mens Rea Revision Notes',
    content:
        'Mens rea (guilty mind) is an essential ingredient of most criminal offences.\n\n'
        '1. Intention — specific intent to commit the act\n'
        '2. Knowledge — awareness that the act will cause a particular result\n'
        '3. Recklessness — conscious disregard of a substantial risk\n'
        '4. Negligence — failure to meet the standard of a reasonable person',
    lastModified: DateTime.now().subtract(const Duration(days: 2)),
    createdAt:    DateTime.now().subtract(const Duration(days: 10)),
    tags: ['Criminal Law', 'BNS', 'Revision'],
  ),
];