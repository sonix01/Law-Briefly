// lib/features/notes/data/note_local_datasource.dart
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import '../../../core/database/isar_database_service.dart';
import 'models/note_entity.dart';

// ─────────────────────────────────────────────
// MARK: — EXCEPTION
// ─────────────────────────────────────────────

class NoteDataSourceException implements Exception {
  final String  message;
  final Object? cause;
  const NoteDataSourceException({required this.message, this.cause});
  @override
  String toString() => 'NoteDataSourceException: $message'
      '${cause != null ? " — $cause" : ""}';
}

// ─────────────────────────────────────────────
// MARK: — NOTE LOCAL DATA SOURCE
// ─────────────────────────────────────────────

class NoteLocalDataSource {
  final IsarDatabaseService _dbService;

  static const String _tag = 'NoteLocalDataSource';

  NoteLocalDataSource({IsarDatabaseService? dbService})
      : _dbService = dbService ?? IsarDatabaseService.instance;

  Future<Isar> get _db => _dbService.getDatabase();

  // ── CREATE ────────────────────────────────────

  Future<void> createNote(NoteEntity note) async {
    try {
      final db = await _db;
      await db.writeTxn(() => db.noteEntitys.put(note));
      debugPrint('[$_tag] Created note: "${note.title}" (id: ${note.id})');
    } catch (e) {
      debugPrint('[$_tag] createNote error: $e');
      throw NoteDataSourceException(message: 'Failed to create note.', cause: e);
    }
  }

  // ── UPDATE ────────────────────────────────────

  Future<void> updateNote(NoteEntity note) async {
    try {
      final db = await _db;
      note.updatedAt = DateTime.now();
      await db.writeTxn(() => db.noteEntitys.put(note));
      debugPrint('[$_tag] Updated note id: ${note.id}');
    } catch (e) {
      debugPrint('[$_tag] updateNote error: $e');
      throw NoteDataSourceException(message: 'Failed to update note.', cause: e);
    }
  }

  // ── DELETE ────────────────────────────────────

  Future<void> deleteNote(int id) async {
    try {
      final db = await _db;
      await db.writeTxn(() => db.noteEntitys.delete(id));
      debugPrint('[$_tag] Deleted note id: $id');
    } catch (e) {
      debugPrint('[$_tag] deleteNote error: $e');
      throw NoteDataSourceException(message: 'Failed to delete note.', cause: e);
    }
  }

  // ── GET ───────────────────────────────────────

  Future<NoteEntity?> getNote(int id) async {
    try {
      final db = await _db;
      return await db.noteEntitys.get(id);
    } catch (e) {
      debugPrint('[$_tag] getNote error: $e');
      return null;
    }
  }

  // ── GET ALL ───────────────────────────────────

  Future<List<NoteEntity>> getAllNotes() async {
    try {
      final db = await _db;
      return await db.noteEntitys
          .where()
          .sortByUpdatedAtDesc()
          .findAll();
    } catch (e) {
      debugPrint('[$_tag] getAllNotes error: $e');
      throw NoteDataSourceException(message: 'Failed to fetch notes.', cause: e);
    }
  }

  // ── SEARCH ───────────────────────────────────

  Future<List<NoteEntity>> searchNotes(String query) async {
    final q = query.trim();
    if (q.isEmpty) return getAllNotes();
    try {
      final db = await _db;
      return await db.noteEntitys
          .filter()
          .titleContains(q, caseSensitive: false)
          .or()
          .contentContains(q, caseSensitive: false)
          .sortByUpdatedAtDesc()
          .findAll();
    } catch (e) {
      debugPrint('[$_tag] searchNotes error: $e');
      throw NoteDataSourceException(message: 'Search failed.', cause: e);
    }
  }

  // ── CLEAR ────────────────────────────────────

  Future<void> clearAll() async {
    try {
      final db = await _db;
      await db.writeTxn(() => db.noteEntitys.clear());
      debugPrint('[$_tag] All notes cleared.');
    } catch (e) {
      debugPrint('[$_tag] clearAll error: $e');
      throw NoteDataSourceException(message: 'Failed to clear notes.', cause: e);
    }
  }
}