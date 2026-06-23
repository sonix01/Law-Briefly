// lib/core/database/database_service.dart
// Law Briefly — Isar Database Service
// Singleton | Initialisation | Thread-safe | Future-ready

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'database_models.dart';

// ─────────────────────────────────────────────
// MARK: — DATABASE EXCEPTION
// ─────────────────────────────────────────────

class DatabaseException implements Exception {
  final String  message;
  final Object? cause;

  const DatabaseException({required this.message, this.cause});

  @override
  String toString() =>
      'DatabaseException: $message${cause != null ? ' — $cause' : ''}';
}

// ─────────────────────────────────────────────
// MARK: — DATABASE SERVICE
// ─────────────────────────────────────────────

class DatabaseService {
  // ── Singleton ─────────────────────────────────
  static final DatabaseService _instance = DatabaseService._internal();

  factory DatabaseService()               => _instance;
  static DatabaseService get instance     => _instance;
  DatabaseService._internal();

  // ── Isar instance ─────────────────────────────
  Isar? _isar;

  // ── Initialisation guard ──────────────────────
  bool              _isInitialized = false;
  Completer<void>?  _initCompleter;

  // ─────────────────────────────────────────────
  // MARK: — STATE GETTERS
  // ─────────────────────────────────────────────

  bool get isInitialized => _isInitialized;
  bool get isOpen        => _isar?.isOpen ?? false;

  /// Returns the Isar instance.
  /// Throws [DatabaseException] if not yet initialised.
  Isar get isar {
    if (_isar == null || !_isar!.isOpen) {
      throw const DatabaseException(
        message: 'DatabaseService is not initialised. '
            'Call DatabaseService.instance.initialize() in main().',
      );
    }
    return _isar!;
  }

  /// Returns the Isar instance or null if not initialised.
  Isar? get isarOrNull => (_isar?.isOpen ?? false) ? _isar : null;

  // ─────────────────────────────────────────────
  // MARK: — INITIALIZE
  // ─────────────────────────────────────────────

  /// Opens the Isar database.
  ///
  /// Safe to call multiple times — subsequent calls wait for the first
  /// to complete without opening a second instance.
  Future<void> initialize({
    String  dbName  = 'law_briefly',
    bool    inspector = false,  // Isar Inspector for debug (macOS/Windows only)
  }) async {
    // Already open
    if (_isInitialized && (_isar?.isOpen ?? false)) {
      debugPrint('[DatabaseService] Already initialised.');
      return;
    }

    // Another initialisation in flight — await it
    if (_initCompleter != null) {
      debugPrint('[DatabaseService] Waiting for in-flight initialisation…');
      return _initCompleter!.future;
    }

    _initCompleter = Completer<void>();

    try {
      final dir = await _resolveDirectory();

      _isar = await Isar.open(
        isarSchemas,
        directory: dir.path,
        name:      dbName,
        inspector: inspector && !kReleaseMode,
      );

      _isInitialized = true;
      _initCompleter!.complete();

      debugPrint(
        '[DatabaseService] Opened at ${dir.path}/$dbName.isar '
        '(${isarSchemas.length} collections).',
      );
    } catch (e, st) {
      _initCompleter!.completeError(e, st);
      _initCompleter  = null;
      _isInitialized  = false;
      debugPrint('[DatabaseService] Initialisation failed: $e');
      throw DatabaseException(message: 'Failed to open Isar database.', cause: e);
    } finally {
      if (_initCompleter?.isCompleted ?? false) {
        _initCompleter = null;
      }
    }
  }

  // ─────────────────────────────────────────────
  // MARK: — CLOSE
  // ─────────────────────────────────────────────

  /// Closes the Isar instance cleanly.
  Future<void> close() async {
    if (_isar == null || !(_isar?.isOpen ?? false)) {
      debugPrint('[DatabaseService] Not open. Nothing to close.');
      return;
    }
    try {
      await _isar!.close();
      _isar          = null;
      _isInitialized = false;
      debugPrint('[DatabaseService] Closed successfully.');
    } catch (e) {
      debugPrint('[DatabaseService] Close error: $e');
      throw DatabaseException(message: 'Failed to close database.', cause: e);
    }
  }

  // ─────────────────────────────────────────────
  // MARK: — CLEAR ALL DATA
  // ─────────────────────────────────────────────

  /// Clears all data from all collections.
  /// Use only for logout / test teardown.
  Future<void> clearAll() async {
    if (!isOpen) return;
    await isar.writeTxn(() => isar.clear());
    debugPrint('[DatabaseService] All collections cleared.');
  }

  // ─────────────────────────────────────────────
  // MARK: — PRIVATE HELPERS
  // ─────────────────────────────────────────────

  Future<Directory> _resolveDirectory() async {
    if (Platform.isAndroid || Platform.isIOS) {
      return getApplicationDocumentsDirectory();
    }
    // Desktop / test fallback
    final base = await getApplicationSupportDirectory();
    final dir  = Directory('${base.path}/law_briefly_db');
    if (!dir.existsSync()) await dir.create(recursive: true);
    return dir;
  }
}