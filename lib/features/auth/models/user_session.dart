// lib/features/auth/models/user_session.dart
import 'dart:convert';

// ─────────────────────────────────────────────
// MARK: — USER SESSION
// ─────────────────────────────────────────────

class UserSession {
  final bool    isLoggedIn;
  final bool    isGuest;
  final String? userId;
  final String? fullName;
  final String? email;

  const UserSession({
    required this.isLoggedIn,
    required this.isGuest,
    this.userId,
    this.fullName,
    this.email,
  });

  // ── Named constructors ────────────────────────

  const UserSession.empty()
      : isLoggedIn = false,
        isGuest    = false,
        userId     = null,
        fullName   = null,
        email      = null;

  factory UserSession.guest() => const UserSession(
        isLoggedIn: false,
        isGuest:    true,
      );

  factory UserSession.loggedIn({
    required String userId,
    required String email,
    String?         fullName,
  }) =>
      UserSession(
        isLoggedIn: true,
        isGuest:    false,
        userId:     userId,
        email:      email,
        fullName:   fullName,
      );

  // ── Computed ─────────────────────────────────

  bool get isActive          => isLoggedIn || isGuest;
  bool get hasProfile        => fullName != null && fullName!.isNotEmpty;
  bool get requiresAuth      => !isLoggedIn && !isGuest;
  String get displayName     => fullName ?? (isGuest ? 'Guest' : 'User');
  String get displayEmail    => email    ?? (isGuest ? 'Guest Session' : '');

  // ── COPY WITH ─────────────────────────────────

  UserSession copyWith({
    bool?    isLoggedIn,
    bool?    isGuest,
    Object?  userId   = _sentinel,
    Object?  fullName = _sentinel,
    Object?  email    = _sentinel,
  }) =>
      UserSession(
        isLoggedIn: isLoggedIn ?? this.isLoggedIn,
        isGuest:    isGuest    ?? this.isGuest,
        userId:     userId    == _sentinel ? this.userId    : userId    as String?,
        fullName:   fullName  == _sentinel ? this.fullName  : fullName  as String?,
        email:      email     == _sentinel ? this.email     : email     as String?,
      );

  // ── FROM JSON ─────────────────────────────────

  factory UserSession.fromJson(Map<String, dynamic> json) => UserSession(
        isLoggedIn: json['is_logged_in'] as bool?  ?? false,
        isGuest:    json['is_guest']     as bool?  ?? false,
        userId:     json['user_id']      as String?,
        fullName:   json['full_name']    as String?,
        email:      json['email']        as String?,
      );

  factory UserSession.fromJsonString(String jsonStr) {
    try {
      return UserSession.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
    } catch (_) {
      return const UserSession.empty();
    }
  }

  // ── TO JSON ───────────────────────────────────

  Map<String, dynamic> toJson() => {
        'is_logged_in': isLoggedIn,
        'is_guest':     isGuest,
        if (userId   != null) 'user_id':   userId,
        if (fullName != null) 'full_name': fullName,
        if (email    != null) 'email':     email,
      };

  String toJsonString() => jsonEncode(toJson());

  // ── EQUALITY ─────────────────────────────────

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSession &&
          isLoggedIn == other.isLoggedIn &&
          isGuest    == other.isGuest    &&
          userId     == other.userId     &&
          email      == other.email;

  @override
  int get hashCode => Object.hash(isLoggedIn, isGuest, userId, email);

  @override
  String toString() =>
      'UserSession(loggedIn: $isLoggedIn, guest: $isGuest, '
      'userId: $userId, email: $email)';
}

const Object _sentinel = Object();