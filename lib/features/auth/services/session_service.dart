// lib/features/auth/services/session_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_session.dart';

// ─────────────────────────────────────────────
// MARK: — SESSION SERVICE
// ─────────────────────────────────────────────

class SessionService {
  static const String _sessionKey   = 'law_briefly_session_v1';
  static const String _tag          = 'SessionService';

  // ── Singleton ─────────────────────────────────
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  // ── SAVE SESSION ──────────────────────────────

  Future<void> saveSession(UserSession session) async {
    try {
      final prefs     = await SharedPreferences.getInstance();
      final jsonStr   = jsonEncode(session.toJson());
      await prefs.setString(_sessionKey, jsonStr);
      debugPrint('[$_tag] Session saved: ${session.displayName}');
    } catch (e) {
      debugPrint('[$_tag] saveSession error: $e');
      rethrow;
    }
  }

  // ── GET SESSION ───────────────────────────────

  Future<UserSession?> getSession() async {
    try {
      final prefs   = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_sessionKey);

      if (jsonStr == null || jsonStr.isEmpty) {
        debugPrint('[$_tag] No session found.');
        return null;
      }

      final decoded = jsonDecode(jsonStr);
      if (decoded is! Map<String, dynamic>) {
        debugPrint('[$_tag] Invalid session JSON structure. Clearing.');
        await clearSession();
        return null;
      }

      final session = UserSession.fromJson(decoded);
      debugPrint('[$_tag] Session loaded: ${session.displayName}');
      return session;
    } catch (e) {
      debugPrint('[$_tag] getSession error: $e');
      return null;
    }
  }

  // ── CLEAR SESSION ─────────────────────────────

  Future<void> clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionKey);
      debugPrint('[$_tag] Session cleared.');
    } catch (e) {
      debugPrint('[$_tag] clearSession error: $e');
      rethrow;
    }
  }

  // ── HAS SESSION ───────────────────────────────

  Future<bool> hasSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_sessionKey) &&
             (prefs.getString(_sessionKey)?.isNotEmpty ?? false);
    } catch (e) {
      debugPrint('[$_tag] hasSession error: $e');
      return false;
    }
  }

  // ── UPDATE FIELDS ─────────────────────────────

  Future<UserSession?> updateSession({
    String? fullName,
    String? email,
  }) async {
    final current = await getSession();
    if (current == null) return null;

    final updated = current.copyWith(
      fullName: fullName,
      email:    email,
    );
    await saveSession(updated);
    return updated;
  }

  // ── SAVE GUEST ────────────────────────────────

  Future<void> saveGuestSession() async {
    await saveSession(UserSession.guest());
  }

  // ── IS ACTIVE ─────────────────────────────────

  Future<bool> isSessionActive() async {
    final session = await getSession();
    return session?.isActive ?? false;
  }
}