// lib/features/reader/services/reader_content_service.dart
import 'package:flutter/foundation.dart';
import '../../../data/models/legal_models.dart';
import '../../acts/data/acts_repository_impl.dart';
import '../../constitution/data/constitution_repository_impl.dart';
import '../data/case_law_repository_impl.dart';

// ─────────────────────────────────────────────
// MARK: — READER SOURCE TYPE
// ─────────────────────────────────────────────

enum ReaderSourceType {
  actSection,
  constitutionArticle;

  String get label => switch (this) {
        ReaderSourceType.actSection         => 'Section',
        ReaderSourceType.constitutionArticle => 'Article',
      };
}

// ─────────────────────────────────────────────
// MARK: — READER CONTENT DATA
// ─────────────────────────────────────────────

class ReaderContentData {
  final String                 id;
  final String                 number;
  final String                 title;
  final List<SectionTextBlock> content;
  final ReaderSourceType       sourceType;
  final List<String>           caseLawIds;
  final String?                previousItemId;
  final String?                nextItemId;
  final String?                sourceId;    // actId or partId
  final String?                sourceName;  // "BNS 2023" or "Constitution of India"
  final bool                   isRepealed;
  final bool                   isOmitted;

  const ReaderContentData({
    required this.id,
    required this.number,
    required this.title,
    required this.content,
    required this.sourceType,
    required this.caseLawIds,
    this.previousItemId,
    this.nextItemId,
    this.sourceId,
    this.sourceName,
    this.isRepealed = false,
    this.isOmitted  = false,
  });

  bool get hasCaseLaws  => caseLawIds.isNotEmpty;
  bool get hasNext      => nextItemId != null;
  bool get hasPrevious  => previousItemId != null;
  bool get isActive     => !isRepealed && !isOmitted;

  String get displayLabel {
    if (sourceType == ReaderSourceType.constitutionArticle &&
        number.toLowerCase() == 'preamble') {
      return 'Preamble';
    }
    return '${sourceType.label} $number';
  }

  ReaderContentData copyWith({
    String?                 previousItemId,
    String?                 nextItemId,
    List<SectionTextBlock>? content,
  }) =>
      ReaderContentData(
        id:             id,
        number:         number,
        title:          title,
        content:        content     ?? this.content,
        sourceType:     sourceType,
        caseLawIds:     caseLawIds,
        previousItemId: previousItemId ?? this.previousItemId,
        nextItemId:     nextItemId     ?? this.nextItemId,
        sourceId:       sourceId,
        sourceName:     sourceName,
        isRepealed:     isRepealed,
        isOmitted:      isOmitted,
      );
}

// ─────────────────────────────────────────────
// MARK: — READER CONTENT SERVICE
// ─────────────────────────────────────────────

class ReaderContentService {
  final ActsRepository          _actsRepo;
  final ConstitutionRepository  _constitutionRepo;
  final CaseLawRepository       _caseLawRepo;

  static const String _tag = 'ReaderContentService';

  ReaderContentService({
    ActsRepository?         actsRepository,
    ConstitutionRepository? constitutionRepository,
    CaseLawRepository?      caseLawRepository,
  })  : _actsRepo         = actsRepository         ?? ActsRepositoryImpl(),
        _constitutionRepo = constitutionRepository  ?? ConstitutionRepositoryImpl(),
        _caseLawRepo      = caseLawRepository       ?? CaseLawRepositoryImpl();

  // ─────────────────────────────────────────────
  // MARK: — ACT SECTION CONTENT
  // ─────────────────────────────────────────────

  Future<ReaderContentData?> getActSectionContent({
    required String actId,
    required String sectionId,
    String?         chapterId,
  }) async {
    try {
      final act = await _actsRepo.getActById(actId);
      if (act == null) {
        debugPrint('[$_tag] Act not found: $actId');
        return null;
      }

      Section? targetSection;
      Chapter? targetChapter;
      int      sectionIndexInChapter = -1;

      for (final chapter in act.chapters) {
        if (chapterId != null && chapter.id != chapterId) continue;
        for (var i = 0; i < chapter.sections.length; i++) {
          if (chapter.sections[i].id == sectionId) {
            targetSection          = chapter.sections[i];
            targetChapter          = chapter;
            sectionIndexInChapter  = i;
            break;
          }
        }
        if (targetSection != null) break;
      }

      if (targetSection == null || targetChapter == null) {
        debugPrint('[$_tag] Section not found: $sectionId in act $actId');
        return null;
      }

      final sections   = targetChapter.sections;
      final prevId     = sectionIndexInChapter > 0
          ? sections[sectionIndexInChapter - 1].id : null;
      final nextId     = sectionIndexInChapter < sections.length - 1
          ? sections[sectionIndexInChapter + 1].id : null;

      return ReaderContentData(
        id:             targetSection.id,
        number:         targetSection.sectionNumber,
        title:          targetSection.title,
        content:        targetSection.content,
        sourceType:     ReaderSourceType.actSection,
        caseLawIds:     targetSection.caseLawIds,
        previousItemId: prevId,
        nextItemId:     nextId,
        sourceId:       actId,
        sourceName:     act.displayTitle,
        isRepealed:     targetSection.isRepealed,
        isOmitted:      targetSection.isOmitted,
      );
    } catch (e) {
      debugPrint('[$_tag] getActSectionContent error: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // MARK: — CONSTITUTION ARTICLE CONTENT
  // ─────────────────────────────────────────────

  Future<ReaderContentData?> getConstitutionArticleContent({
    required String articleId,
    String?         partId,
  }) async {
    try {
      Article?          targetArticle;
      ConstitutionPart? targetPart;
      int               articleIndex = -1;

      if (partId != null) {
        final part = await _constitutionRepo.getPartById(partId);
        if (part != null) {
          for (var i = 0; i < part.articles.length; i++) {
            if (part.articles[i].id == articleId) {
              targetArticle = part.articles[i];
              targetPart    = part;
              articleIndex  = i;
              break;
            }
          }
        }
      }

      if (targetArticle == null) {
        // Search across all parts
        final allParts = await _constitutionRepo.getAllParts();
        outer:
        for (final part in allParts) {
          for (var i = 0; i < part.articles.length; i++) {
            if (part.articles[i].id == articleId) {
              targetArticle = part.articles[i];
              targetPart    = part;
              articleIndex  = i;
              break outer;
            }
          }
        }
      }

      if (targetArticle == null || targetPart == null) {
        debugPrint('[$_tag] Article not found: $articleId');
        return null;
      }

      final articles = targetPart.articles;
      final prevId   = articleIndex > 0
          ? articles[articleIndex - 1].id : null;
      final nextId   = articleIndex < articles.length - 1
          ? articles[articleIndex + 1].id : null;

      return ReaderContentData(
        id:             targetArticle.id,
        number:         targetArticle.articleNumber,
        title:          targetArticle.title,
        content:        targetArticle.content,
        sourceType:     ReaderSourceType.constitutionArticle,
        caseLawIds:     targetArticle.caseLawIds,
        previousItemId: prevId,
        nextItemId:     nextId,
        sourceId:       targetPart.id,
        sourceName:     'Constitution of India',
        isRepealed:     targetArticle.isRepealed,
        isOmitted:      targetArticle.isOmitted,
      );
    } catch (e) {
      debugPrint('[$_tag] getConstitutionArticleContent error: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // MARK: — LINKED CASE LAWS
  // ─────────────────────────────────────────────

  Future<List<CaseLawModel>> getLinkedCaseLaws(
      List<String> caseLawIds) async {
    if (caseLawIds.isEmpty) return const [];
    try {
      return await _caseLawRepo.getCaseLawsByIds(caseLawIds);
    } catch (e) {
      debugPrint('[$_tag] getLinkedCaseLaws error: $e');
      return const [];
    }
  }

  // ─────────────────────────────────────────────
  // MARK: — NAVIGATION
  // ─────────────────────────────────────────────

  Future<ReaderContentData?> getPreviousContent(
      ReaderContentData current) async {
    final prevId = current.previousItemId;
    if (prevId == null) return null;

    return switch (current.sourceType) {
      ReaderSourceType.actSection => getActSectionContent(
          actId: current.sourceId!, sectionId: prevId),
      ReaderSourceType.constitutionArticle => getConstitutionArticleContent(
          articleId: prevId, partId: current.sourceId),
    };
  }

  Future<ReaderContentData?> getNextContent(
      ReaderContentData current) async {
    final nextId = current.nextItemId;
    if (nextId == null) return null;

    return switch (current.sourceType) {
      ReaderSourceType.actSection => getActSectionContent(
          actId: current.sourceId!, sectionId: nextId),
      ReaderSourceType.constitutionArticle => getConstitutionArticleContent(
          articleId: nextId, partId: current.sourceId),
    };
  }

  // ─────────────────────────────────────────────
  // MARK: — WARMUP
  // ─────────────────────────────────────────────

  Future<void> warmupCaseLawCache() async {
    try { await _caseLawRepo.getAllCaseLaws(); }
    catch (e) { debugPrint('[$_tag] warmupCaseLawCache error: $e'); }
  }
}