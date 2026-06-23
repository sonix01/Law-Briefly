// lib/features/bookmarks/notes_providers.dart
// Law Briefly — Personal Notes Riverpod Providers
// Stream | Search | Selected | Controller | Count

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';
import '../../core/services/personal_notes_service.dart';
import '../../data/models/legal_models.dart';
import 'personal_notes_controller.dart';

// ─────────────────────────────────────────────
// MARK: — NOTES STREAM
// ─────────────────────────────────────────────

/// Live stream of all personal notes sorted: pinned first, newest last.
final notesStreamProvider = StreamProvider.autoDispose<List<PersonalNote>>(
  (ref) => ref.watch(personalNotesServiceProvider).watchNotes(),
);

/// One-shot future for initial load (used for loading states).
final notesListProvider = FutureProvider.autoDispose<List<PersonalNote>>(
  (ref) => ref.watch(personalNotesServiceProvider).getNotes(),
);

// ─────────────────────────────────────────────
// MARK: — SEARCH STATE
// ─────────────────────────────────────────────

/// Current notes search query.
final notesSearchQueryProvider =
    StateProvider.autoDispose<String>((ref) => '');

/// Whether the search bar is currently active.
final notesSearchActiveProvider =
    StateProvider.autoDispose<bool>((ref) => false);

// ─────────────────────────────────────────────
// MARK: — FILTERED NOTES (Derived)
// ─────────────────────────────────────────────

/// Notes filtered by the current search query.
/// Returns AsyncValue so UI can show loading/error states.
final filteredNotesProvider =
    Provider.autoDispose<AsyncValue<List<PersonalNote>>>((ref) {
  final notesAsync = ref.watch(notesStreamProvider);
  final query      = ref.watch(notesSearchQueryProvider).trim().toLowerCase();

  return notesAsync.whenData((notes) {
    if (query.isEmpty) return notes;
    return notes.where((n) =>
        n.title.toLowerCase().contains(query)   ||
        n.content.toLowerCase().contains(query) ||
        n.tags.any((t) => t.toLowerCase().contains(query))).toList();
  });
});

/// Pinned notes only.
final pinnedNotesProvider = Provider.autoDispose<AsyncValue<List<PersonalNote>>>(
  (ref) => ref.watch(filteredNotesProvider).whenData(
    (notes) => notes.where((n) => n.isPinned).toList(),
  ),
);

/// Unpinned notes only.
final unpinnedNotesProvider =
    Provider.autoDispose<AsyncValue<List<PersonalNote>>>(
  (ref) => ref.watch(filteredNotesProvider).whenData(
    (notes) => notes.where((n) => !n.isPinned).toList(),
  ),
);

// ─────────────────────────────────────────────
// MARK: — SELECTED NOTE
// ─────────────────────────────────────────────

/// Currently selected / open note (for editor or detail view).
final selectedNoteProvider =
    StateProvider.autoDispose<PersonalNote?>((ref) => null);

/// Convenience: whether a note is currently selected.
final hasSelectedNoteProvider =
    Provider.autoDispose<bool>((ref) {
  return ref.watch(selectedNoteProvider) != null;
});

// ─────────────────────────────────────────────
// MARK: — NOTE BY ID
// ─────────────────────────────────────────────

/// Fetches a specific note by ID.
final noteByIdProvider =
    FutureProvider.autoDispose.family<PersonalNote?, String>(
  (ref, id) => ref.watch(personalNotesServiceProvider).getNoteById(id),
);

// ─────────────────────────────────────────────
// MARK: — COUNT & STATS
// ─────────────────────────────────────────────

/// Total note count.
final noteCountProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(notesStreamProvider).maybeWhen(
    data:    (notes) => notes.length,
    orElse:  () => 0,
  );
});

/// Pinned note count.
final pinnedNoteCountProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(notesStreamProvider).maybeWhen(
    data:    (notes) => notes.where((n) => n.isPinned).length,
    orElse:  () => 0,
  );
});

/// Returns true when the notes list is empty.
final notesEmptyProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(notesStreamProvider).maybeWhen(
    data:    (notes) => notes.isEmpty,
    orElse:  () => true,
  );
});

// ─────────────────────────────────────────────
// MARK: — NOTES CONTROLLER
// ─────────────────────────────────────────────

/// Full-featured personal notes controller with reactive state.
/// Persists across navigation while the ProviderScope is alive.
final personalNotesControllerProvider =
    ChangeNotifierProvider<PersonalNotesController>((ref) {
  final service    = ref.watch(personalNotesServiceProvider);
  final controller = PersonalNotesController(service: service);

  // Initial load
  controller.loadNotes();

  ref.onDispose(controller.dispose);
  return controller;
});