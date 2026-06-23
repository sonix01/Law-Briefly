// lib/features/notes/providers/note_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/note_local_datasource.dart';
import '../data/models/note_entity.dart';

// ─────────────────────────────────────────────
// MARK: — NOTE STATE
// ─────────────────────────────────────────────

class NoteState {
  final List<NoteEntity> notes;
  final bool             isLoading;
  final String?          error;
  final String           searchQuery;

  const NoteState({
    this.notes       = const [],
    this.isLoading   = false,
    this.error,
    this.searchQuery = '',
  });

  bool get hasError     => error != null;
  bool get isEmpty      => notes.isEmpty;
  bool get isSearching  => searchQuery.isNotEmpty;

  NoteState copyWith({
    List<NoteEntity>? notes,
    bool?             isLoading,
    Object?           error       = _sentinel,
    String?           searchQuery,
  }) =>
      NoteState(
        notes:       notes       ?? this.notes,
        isLoading:   isLoading   ?? this.isLoading,
        error:       error == _sentinel ? this.error : error as String?,
        searchQuery: searchQuery ?? this.searchQuery,
      );
}

const Object _sentinel = Object();

// ─────────────────────────────────────────────
// MARK: — DATA SOURCE PROVIDER
// ─────────────────────────────────────────────

final noteDataSourceProvider = Provider<NoteLocalDataSource>((ref) {
  return NoteLocalDataSource();
});

// ─────────────────────────────────────────────
// MARK: — NOTE CONTROLLER
// ─────────────────────────────────────────────

class NoteController extends StateNotifier<NoteState> {
  final NoteLocalDataSource _dataSource;

  static const String _tag = 'NoteController';

  NoteController(this._dataSource) : super(const NoteState()) {
    loadNotes();
  }

  // ── CREATE ────────────────────────────────────

  Future<void> createNote({
    required String title,
    required String content,
  }) async {
    if (!mounted) return;
    if (title.trim().isEmpty) {
      state = state.copyWith(error: 'Title cannot be empty.');
      return;
    }
    try {
      final entity = NoteEntity.create(title: title, content: content);
      await _dataSource.createNote(entity);
      await loadNotes();
      debugPrint('[$_tag] Created: "${entity.title}"');
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(error: 'Failed to create note.');
      debugPrint('[$_tag] createNote error: $e');
    }
  }

  // ── UPDATE ────────────────────────────────────

  Future<void> updateNote({
    required NoteEntity existing,
    required String     title,
    required String     content,
  }) async {
    if (!mounted) return;
    if (title.trim().isEmpty) {
      state = state.copyWith(error: 'Title cannot be empty.');
      return;
    }
    try {
      final updated = NoteEntity.update(
          existing: existing, title: title, content: content);
      await _dataSource.updateNote(updated);
      await loadNotes();
      debugPrint('[$_tag] Updated id: ${existing.id}');
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(error: 'Failed to update note.');
      debugPrint('[$_tag] updateNote error: $e');
    }
  }

  // ── DELETE ────────────────────────────────────

  Future<void> deleteNote(int id) async {
    if (!mounted) return;
    try {
      await _dataSource.deleteNote(id);
      await loadNotes();
      debugPrint('[$_tag] Deleted id: $id');
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(error: 'Failed to delete note.');
      debugPrint('[$_tag] deleteNote error: $e');
    }
  }

  // ── LOAD ─────────────────────────────────────

  Future<List<NoteEntity>> loadNotes() async {
    if (!mounted) return const [];
    state = state.copyWith(isLoading: true, error: null);
    try {
      final notes = await _dataSource.getAllNotes();
      if (!mounted) return notes;
      state = state.copyWith(notes: notes, isLoading: false);
      debugPrint('[$_tag] Loaded ${notes.length} notes.');
      return notes;
    } catch (e) {
      if (!mounted) return const [];
      state = state.copyWith(isLoading: false, error: 'Failed to load notes.');
      debugPrint('[$_tag] loadNotes error: $e');
      return const [];
    }
  }

  // ── SEARCH ───────────────────────────────────

  Future<List<NoteEntity>> searchNotes(String query) async {
    if (!mounted) return const [];
    state = state.copyWith(isLoading: true, searchQuery: query, error: null);
    try {
      final results = await _dataSource.searchNotes(query);
      if (!mounted) return results;
      state = state.copyWith(notes: results, isLoading: false);
      debugPrint('[$_tag] Search "$query": ${results.length} results.');
      return results;
    } catch (e) {
      if (!mounted) return const [];
      state = state.copyWith(isLoading: false, error: 'Search failed.');
      debugPrint('[$_tag] searchNotes error: $e');
      return const [];
    }
  }

  void clearSearch() => loadNotes();
  void clearError()  => state = state.copyWith(error: null);
}

// ─────────────────────────────────────────────
// MARK: — PROVIDER
// ─────────────────────────────────────────────

final noteControllerProvider =
    StateNotifierProvider<NoteController, NoteState>((ref) {
  final dataSource = ref.watch(noteDataSourceProvider);
  return NoteController(dataSource);
});