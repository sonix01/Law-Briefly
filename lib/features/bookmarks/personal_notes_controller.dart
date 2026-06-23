// lib/features/bookmarks/personal_notes_controller.dart
// Law Briefly — Personal Notes Controller
// Wraps PersonalNotesService with reactive ChangeNotifier state.

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/services/personal_notes_service.dart';
import '../../data/models/legal_models.dart';

// ─────────────────────────────────────────────
// MARK: — NOTES STATE
// ─────────────────────────────────────────────

class NotesState {
  final List<PersonalNote> notes;
  final List<PersonalNote> filteredNotes;
  final bool               isLoading;
  final String?            error;
  final String             searchQuery;
  final bool               isSearching;

  const NotesState({
    this.notes         = const [],
    this.filteredNotes = const [],
    this.isLoading     = false,
    this.error,
    this.searchQuery   = '',
    this.isSearching   = false,
  });

  bool get isEmpty   => notes.isEmpty;
  bool get hasError  => error != null;
  int  get totalCount => notes.length;

  List<PersonalNote> get pinnedNotes =>
      notes.where((n) => n.isPinned).toList();
  List<PersonalNote> get unpinnedNotes =>
      notes.where((n) => !n.isPinned).toList();

  NotesState copyWith({
    List<PersonalNote>? notes,
    List<PersonalNote>? filteredNotes,
    bool?               isLoading,
    String?             error,
    bool                clearError = false,
    String?             searchQuery,
    bool?               isSearching,
  }) =>
      NotesState(
        notes:         notes         ?? this.notes,
        filteredNotes: filteredNotes ?? this.filteredNotes,
        isLoading:     isLoading     ?? this.isLoading,
        error:         clearError    ? null : (error ?? this.error),
        searchQuery:   searchQuery   ?? this.searchQuery,
        isSearching:   isSearching   ?? this.isSearching,
      );
}

// ─────────────────────────────────────────────
// MARK: — PERSONAL NOTES CONTROLLER
// ─────────────────────────────────────────────

class PersonalNotesController extends ChangeNotifier {
  // ── Dependencies ──────────────────────────────
  final PersonalNotesService _service;

  // ── State ─────────────────────────────────────
  NotesState _state = const NotesState();
  NotesState get state => _state;

  // ── Stream subscription ───────────────────────
  StreamSubscription<List<PersonalNote>>? _subscription;

  // ─────────────────────────────────────────────
  // MARK: — CONSTRUCTOR
  // ─────────────────────────────────────────────

  PersonalNotesController({PersonalNotesService? service})
      : _service = service ?? PersonalNotesService() {
    _subscribeToStream();
  }

  // ─────────────────────────────────────────────
  // MARK: — STREAM SUBSCRIPTION
  // ─────────────────────────────────────────────

  void _subscribeToStream() {
    _subscription = _service.watchNotes().listen(
      (notes) {
        _setState(_state.copyWith(
          notes:         notes,
          filteredNotes: _state.searchQuery.isEmpty
              ? notes
              : notes
                  .where((n) =>
                      n.title.toLowerCase().contains(_state.searchQuery) ||
                      n.content.toLowerCase().contains(_state.searchQuery))
                  .toList(),
          clearError: true,
        ));
      },
      onError: (e) {
        debugPrint('[PersonalNotesController] Stream error: $e');
        _setState(_state.copyWith(error: '$e'));
      },
    );
  }

  // ─────────────────────────────────────────────
  // MARK: — LOAD NOTES
  // ─────────────────────────────────────────────

  Future<void> loadNotes() async {
    _setState(_state.copyWith(isLoading: true, clearError: true));
    try {
      final notes = await _service.getNotes();
      _setState(_state.copyWith(
        notes:         notes,
        filteredNotes: notes,
        isLoading:     false,
      ));
    } catch (e) {
      debugPrint('[PersonalNotesController] loadNotes error: $e');
      _setState(_state.copyWith(
        isLoading: false,
        error:     'Failed to load notes.',
      ));
    }
  }

  // ─────────────────────────────────────────────
  // MARK: — CREATE NOTE
  // ─────────────────────────────────────────────

  Future<PersonalNote?> createNote({
    required String   title,
    required String   content,
    List<String>      tags     = const [],
    bool              isPinned = false,
    String?           linkedContentId,
    BookmarkContentType? linkedContentType,
  }) async {
    if (title.trim().isEmpty) {
      _setState(_state.copyWith(error: 'Title cannot be empty.'));
      return null;
    }

    _setState(_state.copyWith(isLoading: true, clearError: true));
    try {
      final note = await _service.createNote(
        title:             title,
        content:           content,
        tags:              tags,
        isPinned:          isPinned,
        linkedContentId:   linkedContentId,
        linkedContentType: linkedContentType,
      );
      _setState(_state.copyWith(isLoading: false));
      debugPrint('[PersonalNotesController] Created: ${note.id}');
      return note;
    } catch (e) {
      debugPrint('[PersonalNotesController] createNote error: $e');
      _setState(_state.copyWith(isLoading: false, error: 'Failed to create note.'));
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // MARK: — UPDATE NOTE
  // ─────────────────────────────────────────────

  Future<PersonalNote?> updateNote(PersonalNote note) async {
    if (note.title.trim().isEmpty) {
      _setState(_state.copyWith(error: 'Title cannot be empty.'));
      return null;
    }

    try {
      final updated = await _service.updateNote(note);
      debugPrint('[PersonalNotesController] Updated: ${updated.id}');
      return updated;
    } catch (e) {
      debugPrint('[PersonalNotesController] updateNote error: $e');
      _setState(_state.copyWith(error: 'Failed to update note.'));
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // MARK: — DELETE NOTE
  // ─────────────────────────────────────────────

  Future<bool> deleteNote(String id) async {
    final backup = _state.notes.firstWhere(
      (n) => n.id == id,
      orElse: () => PersonalNote(
        id: '', title: '', content: '',
        lastModified: DateTime.now(), createdAt: DateTime.now(),
      ),
    );

    try {
      await _service.deleteNote(id);
      debugPrint('[PersonalNotesController] Deleted: $id');
      return true;
    } catch (e) {
      debugPrint('[PersonalNotesController] deleteNote error: $e');
      // Restore backup on error
      if (backup.id.isNotEmpty) {
        await _service.updateNote(backup);
      }
      _setState(_state.copyWith(error: 'Failed to delete note.'));
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // MARK: — SEARCH NOTES
  // ─────────────────────────────────────────────

  Future<void> searchNotes(String query) async {
    final q = query.toLowerCase().trim();
    _setState(_state.copyWith(
      searchQuery: q,
      isSearching: q.isNotEmpty,
    ));

    if (q.isEmpty) {
      _setState(_state.copyWith(filteredNotes: _state.notes));
      return;
    }

    try {
      final results = await _service.searchNotes(q);
      _setState(_state.copyWith(filteredNotes: results));
    } catch (e) {
      debugPrint('[PersonalNotesController] searchNotes error: $e');
    }
  }

  /// Clears the current search and shows all notes.
  void clearSearch() {
    _setState(_state.copyWith(
      searchQuery:   '',
      isSearching:   false,
      filteredNotes: _state.notes,
    ));
  }

  // ─────────────────────────────────────────────
  // MARK: — TOGGLE PIN
  // ─────────────────────────────────────────────

  Future<void> togglePin(String id) async {
    try {
      await _service.togglePin(id);
    } catch (e) {
      debugPrint('[PersonalNotesController] togglePin error: $e');
    }
  }

  // ─────────────────────────────────────────────
  // MARK: — CLEAR ERROR
  // ─────────────────────────────────────────────

  void clearError() => _setState(_state.copyWith(clearError: true));

  // ─────────────────────────────────────────────
  // MARK: — PRIVATE HELPERS
  // ─────────────────────────────────────────────

  void _setState(NotesState newState) {
    _state = newState;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    debugPrint('[PersonalNotesController] Disposed.');
    super.dispose();
  }
}