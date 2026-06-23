import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

enum AppThemeMode { light, dark, system }

class SettingsState {
  final ThemeMode themeMode;
  final bool      isSendingSuggestion;
  final bool      suggestionSent;
  final bool      isLoggingOut;
  final String    appVersion;
  final String?   error;

  const SettingsState({
    this.themeMode          = ThemeMode.system,
    this.isSendingSuggestion = false,
    this.suggestionSent      = false,
    this.isLoggingOut        = false,
    this.appVersion          = '1.0.0',
    this.error,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    bool?      isSendingSuggestion,
    bool?      suggestionSent,
    bool?      isLoggingOut,
    String?    appVersion,
    Object?    error = _sentinel,
  }) =>
      SettingsState(
        themeMode:           themeMode           ?? this.themeMode,
        isSendingSuggestion: isSendingSuggestion ?? this.isSendingSuggestion,
        suggestionSent:      suggestionSent      ?? this.suggestionSent,
        isLoggingOut:        isLoggingOut        ?? this.isLoggingOut,
        appVersion:          appVersion          ?? this.appVersion,
        error: error == _sentinel ? this.error : error as String?,
      );
}

const Object _sentinel = Object();

class SettingsController extends ChangeNotifier {
  final ValueNotifier<ThemeMode> _themeNotifier;
  final VoidCallback?            onLogoutRequested;

  SettingsState _state;
  SettingsState get state => _state;

  SettingsController({
    required ValueNotifier<ThemeMode> themeNotifier,
    this.onLogoutRequested,
  })  : _themeNotifier = themeNotifier,
        _state = SettingsState(themeMode: themeNotifier.value);

  // ── THEME ──────────────────────────────────────

  ThemeMode get themeMode => _themeNotifier.value;

  bool isDarkMode(BuildContext context) {
    final mode = _themeNotifier.value;
    if (mode == ThemeMode.system) {
      return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    }
    return mode == ThemeMode.dark;
  }

  void toggleTheme() {
    final current = _themeNotifier.value;
    final next = current == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    _themeNotifier.value = next;
    _setState(_state.copyWith(themeMode: next));
    debugPrint('[SettingsController] Theme → ${next.name}');
  }

  void setThemeMode(ThemeMode mode) {
    _themeNotifier.value = mode;
    _setState(_state.copyWith(themeMode: mode));
  }

  // ── SETTINGS PERSISTENCE ────────────────────────

  Future<void> loadSettings() async {
    // Future: load from SharedPreferences / Isar
    // final prefs = await SharedPreferences.getInstance();
    // final themeName = prefs.getString('theme_mode') ?? 'system';
    // final mode = ThemeMode.values.firstWhere((m) => m.name == themeName);
    // setThemeMode(mode);
    await Future.delayed(Duration.zero);
    _setState(_state.copyWith(
      themeMode:  _themeNotifier.value,
      appVersion: '1.0.0',
    ));
    debugPrint('[SettingsController] Settings loaded.');
  }

  Future<void> saveSettings() async {
    // Future: persist to SharedPreferences
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setString('theme_mode', _themeNotifier.value.name);
    await Future.delayed(Duration.zero);
    debugPrint('[SettingsController] Settings saved.');
  }

  // ── SUGGESTION ─────────────────────────────────

  Future<bool> sendSuggestion(String suggestion) async {
    final text = suggestion.trim();
    if (text.isEmpty) {
      _setState(_state.copyWith(error: 'Suggestion cannot be empty.'));
      return false;
    }

    _setState(_state.copyWith(isSendingSuggestion: true, error: null));

    try {
      // Future: POST to backend or send via email SDK
      await Future.delayed(const Duration(seconds: 1));
      _setState(_state.copyWith(
        isSendingSuggestion: false,
        suggestionSent:      true,
      ));
      debugPrint('[SettingsController] Suggestion sent: $text');
      return true;
    } catch (e) {
      _setState(_state.copyWith(
        isSendingSuggestion: false,
        error:               'Failed to send suggestion.',
      ));
      return false;
    }
  }

  void resetSuggestionState() =>
      _setState(_state.copyWith(suggestionSent: false, error: null));

  // ── LOGOUT ─────────────────────────────────────

  Future<void> logout() async {
    _setState(_state.copyWith(isLoggingOut: true));

    try {
      // Future: clear auth tokens, Isar data, cached assets
      await Future.delayed(const Duration(milliseconds: 400));
      _themeNotifier.value = ThemeMode.system;
      _setState(const SettingsState());
      onLogoutRequested?.call();
      debugPrint('[SettingsController] Logged out.');
    } catch (e) {
      _setState(_state.copyWith(isLoggingOut: false, error: 'Logout failed.'));
    }
  }

  // ── PRIVATE ────────────────────────────────────

  void _setState(SettingsState s) { _state = s; notifyListeners(); }

  @override
  void dispose() { debugPrint('[SettingsController] Disposed.'); super.dispose(); }
}