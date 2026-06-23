// lib/core/services/json_validator_service.dart
import 'package:flutter/foundation.dart';

// ─────────────────────────────────────────────
// MARK: — JSON VALIDATOR SERVICE
// ─────────────────────────────────────────────

class JsonValidatorService {
  static const String _tag = 'JsonValidatorService';

  // ─────────────────────────────────────────────
  // MARK: — VALIDATE ACT JSON
  // ─────────────────────────────────────────────

  bool validateActJson(Map<String, dynamic>? json) {
    if (json == null) {
      debugPrint('[$_tag] Act JSON is null.');
      return false;
    }
    if (!_hasString(json, 'id')) {
      debugPrint('[$_tag] Act missing required key: "id"');
      return false;
    }
    if (!_hasString(json, 'title')) {
      debugPrint('[$_tag] Act missing required key: "title"');
      return false;
    }
    if (!_hasList(json, 'chapters')) {
      debugPrint('[$_tag] Act missing required key: "chapters" (must be array)');
      return false;
    }

    final chapters = json['chapters'] as List<dynamic>;
    for (var i = 0; i < chapters.length; i++) {
      if (!_validateChapter(chapters[i], index: i)) return false;
    }

    debugPrint('[$_tag] Act JSON valid: ${json['id']}');
    return true;
  }

  bool _validateChapter(dynamic chapter, {required int index}) {
    if (chapter is! Map<String, dynamic>) {
      debugPrint('[$_tag] Chapter[$index] is not an object.');
      return false;
    }
    if (!_hasString(chapter, 'id')) {
      debugPrint('[$_tag] Chapter[$index] missing "id"');
      return false;
    }
    if (!_hasList(chapter, 'sections')) {
      debugPrint('[$_tag] Chapter[$index] missing "sections"');
      return false;
    }

    final sections = chapter['sections'] as List<dynamic>;
    for (var i = 0; i < sections.length; i++) {
      final section = sections[i];
      if (section is! Map<String, dynamic>) {
        debugPrint('[$_tag] Section[$i] in chapter "${chapter['id']}" is not an object.');
        return false;
      }
      if (!_hasString(section, 'id')) {
        debugPrint('[$_tag] Section[$i] missing "id"');
        return false;
      }
    }
    return true;
  }

  // ─────────────────────────────────────────────
  // MARK: — VALIDATE CONSTITUTION JSON
  // ─────────────────────────────────────────────

  bool validateConstitutionJson(Map<String, dynamic>? json) {
    if (json == null) {
      debugPrint('[$_tag] Constitution JSON is null.');
      return false;
    }
    if (!_hasString(json, 'id')) {
      debugPrint('[$_tag] Constitution Part missing "id"');
      return false;
    }
    if (!_hasString(json, 'title')) {
      debugPrint('[$_tag] Constitution Part missing "title"');
      return false;
    }
    if (!_hasList(json, 'articles')) {
      debugPrint('[$_tag] Constitution Part missing "articles" (must be array)');
      return false;
    }

    final articles = json['articles'] as List<dynamic>;
    for (var i = 0; i < articles.length; i++) {
      final article = articles[i];
      if (article is! Map<String, dynamic>) {
        debugPrint('[$_tag] Article[$i] is not an object.');
        return false;
      }
      if (!_hasString(article, 'id')) {
        debugPrint('[$_tag] Article[$i] missing "id"');
        return false;
      }
      if (!_hasString(article, 'title')) {
        debugPrint('[$_tag] Article[$i] missing "title"');
        return false;
      }
    }

    debugPrint('[$_tag] Constitution JSON valid: ${json['id']} '
        '(${articles.length} articles)');
    return true;
  }

  // ─────────────────────────────────────────────
  // MARK: — VALIDATE CASE LAW JSON
  // ─────────────────────────────────────────────

  bool validateCaseLawJson(List<dynamic>? json) {
    if (json == null) {
      debugPrint('[$_tag] Case law JSON is null.');
      return false;
    }
    if (json.isEmpty) {
      debugPrint('[$_tag] Case law JSON array is empty.');
      return true; // Empty is technically valid
    }

    for (var i = 0; i < json.length; i++) {
      final item = json[i];
      if (item is! Map<String, dynamic>) {
        debugPrint('[$_tag] Case law[$i] is not an object.');
        return false;
      }
      if (!_hasString(item, 'id')) {
        debugPrint('[$_tag] Case law[$i] missing "id"');
        return false;
      }
      if (!_hasString(item, 'title')) {
        debugPrint('[$_tag] Case law[$i] missing "title"');
        return false;
      }
      if (!_hasString(item, 'facts')) {
        debugPrint('[$_tag] Case law[$i] (${item['id']}) missing "facts"');
        return false;
      }
      if (!_hasString(item, 'judgment')) {
        debugPrint('[$_tag] Case law[$i] (${item['id']}) missing "judgment"');
        return false;
      }
    }

    debugPrint('[$_tag] Case law JSON valid: ${json.length} records.');
    return true;
  }

  // ─────────────────────────────────────────────
  // MARK: — PRIVATE HELPERS
  // ─────────────────────────────────────────────

  bool _hasString(Map<String, dynamic> json, String key) {
    if (!json.containsKey(key)) return false;
    final val = json[key];
    return val is String && val.isNotEmpty;
  }

  bool _hasList(Map<String, dynamic> json, String key) {
    if (!json.containsKey(key)) return false;
    return json[key] is List;
  }
}