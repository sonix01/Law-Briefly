// lib/features/notes/data/note_repository.dart
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import '../../../../core/database/isar_database_service.dart';
import 'models/note_model.dart';

// ─────────────────────────────────────────────
// MARK: — EXCEPTION
// ─────────────────────────────────────────────

class NoteRepositoryException implements Exception {
  final String  message;
  final Object? cause;
  const NoteRepositoryException({required this.message, this.cause});
  @override
  String toString() => 'NoteRepositoryException: $message'
      '${cause != null ? " — $cause" : ""}';
}

// ─────────────────────────────────────────────
// MARK: — ABSTRACT CONTRACT
// ─────────────────────────────────────────────

abstract class NoteRepository {
  Future<void>            addNote(NoteModel note);
  Future<void>            updateNote(NoteModel note);
  Future<void>            deleteNote(int noteId);
  Future<NoteModel?>      getNote(int noteId);
  Future<List<NoteModel>> getAllNotes();
  Future<List<NoteModel>> searchNotes(String query);
  Future<List<NoteModel>> getPinnedNotes();
  Future<List<NoteModel>> getFavoriteNotes();
  Future<void>            clearAllNotes();
}

// ─────────────────────────────────────────────
// MARK: — IMPLEMENTATION
// ─────────────────────────────────────────────

class NoteRepositoryImpl implements NoteRepository {
  final IsarDatabaseService _dbService;

  static const String _tag = 'NoteRepositoryImpl';

  NoteRepositoryImpl({IsarDatabaseService? dbService})
      : _dbService = dbService ?? IsarDatabaseService.instance;

  Future<Isar> get _db => _dbService.getDatabase();

  // ── ADD ──────────────────────────────────────

  @override
  Future<void> addNote(NoteModel note) async {
    try {
      final db = await _db;
      await db.writeTxn(() => db.noteModels.put(note));
      debugPrint('[$_tag] Added note: "${note.title}" (id: ${note.id})');
    } catch (e) {
      debugPrint('[$_tag] addNote error: $e');
      throw NoteRepositoryException(message: 'Failed to add note.', cause: e);
    }
  }

  // ── UPDATE ────────────────────────────────────

  @override
  Future<void> updateNote(NoteModel note) async {
    try {
      final db = await _db;
      note.updatedAt = DateTime.now();
      await db.writeTxn(() => db.noteModels.put(note));
      debugPrint('[$_tag] Updated note id: ${note.id}');
    } catch (e) {
      debugPrint('[$_tag] updateNote error: $e');
      throw NoteRepositoryException(message: 'Failed to update note.', cause: e);
    }
  }

  // ── DELETE ────────────────────────────────────

  @override
  Future<void> deleteNote(int noteId) async {
    try {
      final db = await _db;
      await db.writeTxn(() => db.noteModels.delete(noteId));
      debugPrint('[$_tag] Deleted note id: $noteId');
    } catch (e) {
      debugPrint('[$_tag] deleteNote error: $e');
      throw NoteRepositoryException(message: 'Failed to delete note.', cause: e);
    }
  }

  // ── GET ───────────────────────────────────────

  @override
  Future<NoteModel?> getNote(int noteId) async {
    try {
      final db = await _db;
      return await db.noteModels.get(noteId);
    } catch (e) {
      debugPrint('[$_tag] getNote error: $e');
      return null;
    }
  }

  // ── GET ALL ───────────────────────────────────

  @override
  Future<List<NoteModel>> getAllNotes() async {
    try {
      final db = await _db;
      return await db.noteModels
          .where()
          .sortByIsPinnedDesc()
          .thenByUpdatedAtDesc()
          .findAll();
    } catch (e) {
      debugPrint('[$_tag] getAllNotes error: $e');
      throw NoteRepositoryException(message: 'Failed to fetch notes.', cause: e);
    }
  }

  // ── SEARCH ───────────────────────────────────

  @override
  Future<List<NoteModel>> searchNotes(String query) async {
    final q = query.trim();
    if (q.isEmpty) return getAllNotes();

    try {
      final db = await _db;
      return await db.noteModels
          .filter()
          .titleContains(q, caseSensitive: false)
          .or()
          .contentContains(q, caseSensitive: false)
          .sortByUpdatedAtDesc()
          .findAll();
    } catch (e) {
      debugPrint('[$_tag] searchNotes error: $e');
      throw NoteRepositoryException(message: 'Search failed.', cause: e);
    }
  }

  // ── PINNED ───────────────────────────────────

  @override
  Future<List<NoteModel>> getPinnedNotes() async {
    try {
      final db = await _db;
      return await db.noteModels
          .filter()
          .isPinnedEqualTo(true)
          .sortByUpdatedAtDesc()
          .findAll();
    } catch (e) {
      debugPrint('[$_tag] getPinnedNotes error: $e');
      throw NoteRepositoryException(message: 'Failed to fetch pinned notes.', cause: e);
    }
  }

  // ── FAVORITES ────────────────────────────────

  @override
  Future<List<NoteModel>> getFavoriteNotes() async {
    try {
      final db = await _db;
      return await db.noteModels
          .filter()
          .isFavoriteEqualTo(true)
          .sortByUpdatedAtDesc()
          .findAll();
    } catch (e) {
      debugPrint('[$_tag] getFavoriteNotes error: $e');
      throw NoteRepositoryException(message: 'Failed to fetch favourite notes.', cause: e);
    }
  }

  // ── CLEAR ────────────────────────────────────

  @override
  Future<void> clearAllNotes() async {
    try {
      final db = await _db;
      await db.writeTxn(() => db.noteModels.clear());
      debugPrint('[$_tag] All notes cleared.');
    } catch (e) {
      debugPrint('[$_tag] clearAllNotes error: $e');
      throw NoteRepositoryException(message: 'Failed to clear notes.', cause: e);
    }
  }
}