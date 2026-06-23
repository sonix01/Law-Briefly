// lib/core/services/personal_notes_service.dart
// Law Briefly — Personal Notes Service
// In-Memory | Async | Reactive Stream | Future Isar-Ready

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/models/legal_models.dart';

// ─────────────────────────────────────────────
// MARK: — NOTES REPOSITORY INTERFACE
// ─────────────────────────────────────────────

abstract class NotesRepository {
  Future<List<PersonalNote>>  fetchAll();
  Future<PersonalNote?>       fetchById(String id);
  Future<PersonalNote>        upsert(PersonalNote note);
  Future<void>                remove(String id);
  Future<List<PersonalNote>>  search(String query);
  Stream<List<PersonalNote>>  watch();
  Future<void>                clear();
}

// ─────────────────────────────────────────────
// MARK: — IN-MEMORY NOTES REPOSITORY
// ─────────────────────────────────────────────

class _InMemoryNotesRepository implements NotesRepository {
  final List<PersonalNote> _store = List.from(_seedNotes);
  final StreamController<List<PersonalNote>> _ctrl =
      StreamController<List<PersonalNote>>.broadcast();

  void _emit() => _ctrl.add(List.unmodifiable(_store));

  @override
  Future<List<PersonalNote>> fetchAll() async {
    await _delay();
    return _sorted();
  }

  @override
  Future<PersonalNote?> fetchById(String id) async {
    await _delay();
    try { return _store.firstWhere((n) => n.id == id); }
    on StateError { return null; }
  }

  @override
  Future<PersonalNote> upsert(PersonalNote note) async {
    await _delay();
    final i = _store.indexWhere((n) => n.id == note.id);
    if (i >= 0) { _store[i] = note; } else { _store.add(note); }
    _emit();
    return note;
  }

  @override
  Future<void> remove(String id) async {
    await _delay();
    _store.removeWhere((n) => n.id == id);
    _emit();
  }

  @override
  Future<List<PersonalNote>> search(String query) async {
    await _delay();
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return _sorted();
    return _store
        .where((n) =>
            n.title.toLowerCase().contains(q) ||
            n.content.toLowerCase().contains(q) ||
            n.tags.any((t) => t.toLowerCase().contains(q)))
        .toList()
      ..sort((a, b) => b.lastModified.compareTo(a.lastModified));
  }

  @override
  Stream<List<PersonalNote>> watch() => _ctrl.stream;

  @override
  Future<void> clear() async {
    _store.clear();
    _emit();
  }

  List<PersonalNote> _sorted() => List<PersonalNote>.from(_store)
    ..sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.lastModified.compareTo(a.lastModified);
    });

  Future<void> _delay() => Future.delayed(Duration.zero);

  void dispose() => _ctrl.close();
}

// ─────────────────────────────────────────────
// MARK: — SEED NOTES (replace with JSON or Isar)
// ─────────────────────────────────────────────

final List<PersonalNote> _seedNotes = [
  PersonalNote(
    id:           'note_seed_1',
    title:        'Fundamental Rights Summary',
    content:      'Articles 12–35 of the Constitution guarantee Fundamental Rights.\n\n'
                  '• Right to Equality (Arts. 14–18)\n'
                  '• Right to Freedom (Art. 19)\n'
                  '• Right against Exploitation (Arts. 23–24)\n'
                  '• Right to Freedom of Religion (Arts. 25–28)\n'
                  '• Cultural and Educational Rights (Arts. 29–30)\n'
                  '• Right to Constitutional Remedies (Art. 32)\n\n'
                  'Article 21 is the most expansive fundamental right.',
    lastModified: DateTime.now().subtract(const Duration(hours: 3)),
    createdAt:    DateTime.now().subtract(const Duration(days: 14)),
    isPinned:     true,
    tags:         ['Constitution', 'Fundamental Rights', 'Revision'],
  ),
  PersonalNote(
    id:           'note_seed_2',
    title:        'Mens Rea Revision Notes',
    content:      'Mens rea (guilty mind) is essential for most offences.\n\n'
                  '1. Intention — specific intent to commit the act\n'
                  '2. Knowledge — awareness of the result\n'
                  '3. Recklessness — conscious disregard of substantial risk\n'
                  '4. Negligence — failure to meet reasonable person standard',
    lastModified: DateTime.now().subtract(const Duration(days: 2)),
    createdAt:    DateTime.now().subtract(const Duration(days: 10)),
    tags:         ['Criminal Law', 'BNS', 'Revision'],
  ),
  PersonalNote(
    id:           'note_seed_3',
    title:        'Contract Law — Key Points',
    content:      'Essential elements of a valid contract:\n\n'
                  '1. Offer and Acceptance (S. 2(a), 2(b))\n'
                  '2. Lawful Consideration (S. 2(d))\n'
                  '3. Capacity to Contract (S. 11)\n'
                  '4. Free Consent (S. 13-22)\n'
                  '5. Lawful Object (S. 23)',
    lastModified: DateTime.now().subtract(const Duration(days: 5)),
    createdAt:    DateTime.now().subtract(const Duration(days: 7)),
    tags:         ['Contract Law', 'ICA 1872'],
  ),
];

// ─────────────────────────────────────────────
// MARK: — PERSONAL NOTES SERVICE
// ─────────────────────────────────────────────

class PersonalNotesService {
  // ── Singleton ─────────────────────────────────
  static final PersonalNotesService _instance =
      PersonalNotesService._internal();
  factory PersonalNotesService() => _instance;
  PersonalNotesService._internal();

  // ── Repository (swap-able) ────────────────────
  NotesRepository _repo = _InMemoryNotesRepository();

  // ── ID generation ─────────────────────────────
  String _generateId() =>
      'note_${DateTime.now().millisecondsSinceEpoch}';

  // ─────────────────────────────────────────────
  // MARK: — PUBLIC API
  // ─────────────────────────────────────────────

  /// All notes sorted: pinned first, then newest first.
  Future<List<PersonalNote>> getNotes() => _repo.fetchAll();

  /// Live stream of all notes.
  Stream<List<PersonalNote>> watchNotes() => _repo.watch();

  /// Single note by ID, or null if not found.
  Future<PersonalNote?> getNoteById(String id) => _repo.fetchById(id);

  /// Creates a new note and returns it.
  Future<PersonalNote> createNote({
    required String       title,
    required String       content,
    List<String>          tags              = const [],
    bool                  isPinned          = false,
    String?               linkedContentId,
    BookmarkContentType?  linkedContentType,
  }) async {
    final now  = DateTime.now();
    final note = PersonalNote(
      id:                id:               _generateId(),
      title:             title.trim(),
      content:           content,
      lastModified:      now,
      createdAt:         now,
      tags:              List.unmodifiable(tags),
      isPinned:          isPinned,
      linkedContentId:   linkedContentId,
      linkedContentType: linkedContentType,
    );
    final saved = await _repo.upsert(note);
    debugPrint('[PersonalNotesService] Created: ${saved.id}');
    return saved;
  }

  /// Updates an existing note and returns the updated version.
  Future<PersonalNote> updateNote(PersonalNote note) async {
    final updated = note.copyWith(lastModified: DateTime.now());
    final saved   = await _repo.upsert(updated);
    debugPrint('[PersonalNotesService] Updated: ${saved.id}');
    return saved;
  }

  /// Convenience method for patching specific fields.
  Future<PersonalNote?> patchNote({
    required String   id,
    String?           title,
    String?           content,
    List<String>?     tags,
    bool?             isPinned,
  }) async {
    final existing = await getNoteById(id);
    if (existing == null) {
      debugPrint('[PersonalNotesService] Note not found: $id');
      return null;
    }
    return updateNote(existing.copyWith(
      title:    title,
      content:  content,
      tags:     tags,
      isPinned: isPinned,
    ));
  }

  /// Deletes a note by ID.
  Future<void> deleteNote(String id) async {
    await _repo.remove(id);
    debugPrint('[PersonalNotesService] Deleted: $id');
  }

  /// Searches notes by title, content, and tags.
  Future<List<PersonalNote>> searchNotes(String query) =>
      _repo.search(query);

  /// Returns total note count.
  Future<int> getNoteCount() async {
    final notes = await getNotes();
    return notes.length;
  }

  /// Toggles the pinned state of a note.
  Future<PersonalNote?> togglePin(String id) async {
    final note = await getNoteById(id);
    if (note == null) return null;
    return updateNote(note.copyWith(isPinned: !note.isPinned));
  }

  /// Clears all notes (use for logout / data reset).
  Future<void> clearAll() async {
    await _repo.clear();
    debugPrint('[PersonalNotesService] Cleared all notes.');
  }

  /// Swaps the underlying repository (e.g., to IsarNotesRepository).
  // ignore: use_setters_to_change_properties
  void setRepository(NotesRepository repository) =>
      _repo = repository;
}