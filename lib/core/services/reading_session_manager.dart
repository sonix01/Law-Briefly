// lib/core/services/reading_session_manager.dart
// Law Briefly — Reading Session Manager
// Coordinates ReaderProgressService + PdfProgressService.
// Tracks session durations. Ready for future analytics / recommendations.

import 'dart:async';

import 'package:flutter/foundation.dart';

import 'reader_progress_service.dart';
import 'pdf_progress_service.dart';

// ─────────────────────────────────────────────
// MARK: — SESSION TYPE
// ─────────────────────────────────────────────

enum ReadingSessionType {
  section,    // Act section
  article,    // Constitution article
  pdf,        // Academic Notes PDF
}

// ─────────────────────────────────────────────
// MARK: — ACTIVE SESSION
// ─────────────────────────────────────────────

class _ActiveSession {
  final String             contentId;
  final ReadingSessionType type;
  final DateTime           openedAt;
  int                      lastPosition;
  int                      lastPage;

  _ActiveSession({
    required this.contentId,
    required this.type,
    this.lastPosition = 0,
    this.lastPage     = 1,
  }) : openedAt = DateTime.now();

  int get elapsedSeconds =>
      DateTime.now().difference(openedAt).inSeconds;

  @override
  String toString() =>
      '_ActiveSession(contentId: $contentId, type: ${type.name}, '
      'elapsed: ${elapsedSeconds}s)';
}

// ─────────────────────────────────────────────
// MARK: — SESSION EVENT (Future analytics hook)
// ─────────────────────────────────────────────

class SessionEvent {
  final String             contentId;
  final ReadingSessionType type;
  final DateTime           timestamp;
  final int?               positionAtClose;
  final int                durationSeconds;
  final bool               wasCompleted;

  const SessionEvent({
    required this.contentId,
    required this.type,
    required this.timestamp,
    required this.durationSeconds,
    this.positionAtClose,
    this.wasCompleted = false,
  });
}

// ─────────────────────────────────────────────
// MARK: — READING SESSION MANAGER
// ─────────────────────────────────────────────

class ReadingSessionManager {
  // ── Dependencies ──────────────────────────────
  final ReaderProgressService _readerProgress;
  final PdfProgressService    _pdfProgress;

  // ── Active sessions ───────────────────────────
  // Keyed by contentId. Supports multiple simultaneous sessions
  // (e.g., reader + PDF side by side in future split-screen).
  final Map<String, _ActiveSession> _activeSessions = {};

  // ── Session event log (in-memory, future: send to analytics) ──
  final List<SessionEvent> _eventLog = [];

  // ── Auto-save timer ───────────────────────────
  // Periodically saves progress for long-running sessions.
  Timer? _autoSaveTimer;
  static const Duration _autoSaveInterval = Duration(seconds: 15);

  // ─────────────────────────────────────────────
  // MARK: — CONSTRUCTOR
  // ─────────────────────────────────────────────

  ReadingSessionManager({
    ReaderProgressService? readerProgress,
    PdfProgressService?    pdfProgress,
  }) : _readerProgress = readerProgress ?? ReaderProgressService(),
       _pdfProgress    = pdfProgress    ?? PdfProgressService() {
    _startAutoSave();
  }

  // ─────────────────────────────────────────────
  // MARK: — RECORD OPEN
  // Call when a section, article, or PDF is opened.
  // ─────────────────────────────────────────────

  Future<void> recordOpen({
    required String             contentId,
    required ReadingSessionType type,
    int                         initialPosition = 0,
    int                         initialPage     = 1,
    int                         totalPages      = 0,
  }) async {
    // End any existing session for this contentId
    if (_activeSessions.containsKey(contentId)) {
      await _endSession(contentId, silent: true);
    }

    _activeSessions[contentId] = _ActiveSession(
      contentId:    contentId,
      type:         type,
      lastPosition: initialPosition,
      lastPage:     initialPage,
    );

    debugPrint('[ReadingSessionManager] Open: $contentId (${type.name})');

    // Update lastOpened timestamp immediately
    if (type == ReadingSessionType.pdf) {
      await _pdfProgress.saveProgress(
        pdfId:      contentId,
        lastPage:   initialPage,
        totalPages: totalPages,
      );
    } else {
      await _readerProgress.saveProgress(
        contentId:        contentId,
        lastReadPosition: initialPosition,
      );
    }
  }

  // ─────────────────────────────────────────────
  // MARK: — RECORD PROGRESS
  // Call on scroll / page change.
  // ─────────────────────────────────────────────

  /// Records the current reading position for a content ID.
  ///
  /// For sections/articles: [position] is the item index in the list.
  /// For PDFs:              [page] is the current page number.
  Future<void> recordProgress({
    required String             contentId,
    required ReadingSessionType type,
    int                         position   = 0,
    int                         page       = 1,
    int                         totalPages = 0,
    double                      scrollOffset = 0.0,
  }) async {
    final session = _activeSessions[contentId];

    if (session != null) {
      session.lastPosition = position;
      session.lastPage     = page;
    }

    if (type == ReadingSessionType.pdf) {
      await _pdfProgress.updatePage(
        pdfId:      contentId,
        page:       page,
        totalPages: totalPages,
      );
    } else {
      await _readerProgress.updateLastPosition(
        contentId:    contentId,
        position:     position,
        scrollOffset: scrollOffset,
      );
    }
  }

  // ─────────────────────────────────────────────
  // MARK: — RECORD CLOSE
  // Call when the reader screen is disposed or navigated away.
  // ─────────────────────────────────────────────

  Future<void> recordClose({
    required String             contentId,
    required ReadingSessionType type,
    int                         finalPosition = 0,
    int                         finalPage     = 1,
    int                         totalPages    = 0,
    bool                        wasCompleted  = false,
  }) async {
    final session = _activeSessions[contentId];

    if (session != null) {
      final durationSeconds = session.elapsedSeconds;

      // Persist final position
      if (type == ReadingSessionType.pdf) {
        await _pdfProgress.saveProgress(
          pdfId:      contentId,
          lastPage:   finalPage,
          totalPages: totalPages,
          isCompleted: wasCompleted,
        );
      } else {
        await _readerProgress.saveProgress(
          contentId:        contentId,
          lastReadPosition: finalPosition,
          isCompleted:      wasCompleted,
        );
        await _readerProgress.addReadTime(
          contentId: contentId,
          seconds:   durationSeconds,
        );
      }

      // Log session event (future analytics hook)
      _logEvent(SessionEvent(
        contentId:       contentId,
        type:            type,
        timestamp:       DateTime.now(),
        durationSeconds: durationSeconds,
        positionAtClose: type == ReadingSessionType.pdf ? finalPage : finalPosition,
        wasCompleted:    wasCompleted,
      ));

      _activeSessions.remove(contentId);
      debugPrint(
        '[ReadingSessionManager] Close: $contentId '
        '(${type.name}, ${durationSeconds}s)',
      );
    } else {
      debugPrint('[ReadingSessionManager] No active session for $contentId');
    }
  }

  // ─────────────────────────────────────────────
  // MARK: — MARK COMPLETED
  // ─────────────────────────────────────────────

  Future<void> markCompleted({
    required String             contentId,
    required ReadingSessionType type,
    int                         totalPages = 0,
  }) async {
    if (type == ReadingSessionType.pdf) {
      await _pdfProgress.saveProgress(
        pdfId:       contentId,
        lastPage:    totalPages,
        totalPages:  totalPages,
        isCompleted: true,
      );
    } else {
      await _readerProgress.markCompleted(contentId);
    }
    debugPrint('[ReadingSessionManager] Completed: $contentId');
  }

  // ─────────────────────────────────────────────
  // MARK: — SESSION QUERIES
  // ─────────────────────────────────────────────

  bool isActive(String contentId) => _activeSessions.containsKey(contentId);

  int  activeCount          => _activeSessions.length;
  List<String> activeIds    => _activeSessions.keys.toList();

  int elapsedSeconds(String contentId) =>
      _activeSessions[contentId]?.elapsedSeconds ?? 0;

  // ─────────────────────────────────────────────
  // MARK: — CLOSE ALL ACTIVE SESSIONS
  // Call from AppLifecycleListener on app pause/background.
  // ─────────────────────────────────────────────

  Future<void> closeAllSessions() async {
    final ids = List<String>.from(_activeSessions.keys);
    for (final id in ids) {
      await _endSession(id, silent: false);
    }
    debugPrint('[ReadingSessionManager] Closed all ${ids.length} sessions.');
  }

  // ─────────────────────────────────────────────
  // MARK: — ANALYTICS / EVENT LOG
  // Future: forward events to analytics service.
  // ─────────────────────────────────────────────

  List<SessionEvent> get eventLog => List.unmodifiable(_eventLog);

  void _logEvent(SessionEvent event) {
    _eventLog.add(event);
    // Future: AnalyticsService.instance.track(event);
    if (kDebugMode) {
      debugPrint(
        '[ReadingSessionManager] Event: ${event.type.name} '
        '${event.contentId} — ${event.durationSeconds}s '
        '${event.wasCompleted ? "(completed)" : ""}',
      );
    }
  }

  // ─────────────────────────────────────────────
  // MARK: — PRIVATE HELPERS
  // ─────────────────────────────────────────────

  Future<void> _endSession(String contentId, {required bool silent}) async {
    final session = _activeSessions.remove(contentId);
    if (session == null) return;

    if (!silent) {
      if (session.type == ReadingSessionType.pdf) {
        await _pdfProgress.saveProgress(
          pdfId:      contentId,
          lastPage:   session.lastPage,
          totalPages: 0,
        );
      } else {
        await _readerProgress.saveProgress(
          contentId:        contentId,
          lastReadPosition: session.lastPosition,
        );
        await _readerProgress.addReadTime(
          contentId: contentId,
          seconds:   session.elapsedSeconds,
        );
      }
    }
  }

  void _startAutoSave() {
    _autoSaveTimer = Timer.periodic(_autoSaveInterval, (_) async {
      for (final entry in _activeSessions.entries) {
        final session = entry.value;
        debugPrint(
          '[ReadingSessionManager] Auto-save: ${session.contentId} '
          '(${session.elapsedSeconds}s)',
        );
        if (session.type == ReadingSessionType.pdf) {
          await _pdfProgress.updatePage(
            pdfId:      session.contentId,
            page:       session.lastPage,
            totalPages: 0,
          );
        } else {
          await _readerProgress.updateLastPosition(
            contentId: session.contentId,
            position:  session.lastPosition,
          );
        }
      }
    });
  }

  // ─────────────────────────────────────────────
  // MARK: — DISPOSE
  // ─────────────────────────────────────────────

  Future<void> dispose() async {
    _autoSaveTimer?.cancel();
    await closeAllSessions();
    debugPrint('[ReadingSessionManager] Disposed.');
  }
}