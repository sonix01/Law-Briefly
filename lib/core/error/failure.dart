// lib/core/error/failure.dart

// ─────────────────────────────────────────────
// MARK: — FAILURE (Result type for use cases)
// ─────────────────────────────────────────────

sealed class Failure {
  final String message;
  const Failure({required this.message});

  @override
  String toString() => '${runtimeType.toString()}: $message';
}

// ─────────────────────────────────────────────
// MARK: — DATABASE FAILURE
// ─────────────────────────────────────────────

final class DatabaseFailure extends Failure {
  final String? operation;

  const DatabaseFailure({
    required super.message,
    this.operation,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DatabaseFailure &&
          message   == other.message &&
          operation == other.operation;

  @override
  int get hashCode => Object.hash(message, operation);
}

// ─────────────────────────────────────────────
// MARK: — NETWORK FAILURE
// ─────────────────────────────────────────────

final class NetworkFailure extends Failure {
  final int? statusCode;

  const NetworkFailure({
    required super.message,
    this.statusCode,
  });

  bool get isUnauthorized => statusCode == 401;
  bool get isNotFound     => statusCode == 404;
  bool get isServerError  => (statusCode ?? 0) >= 500;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworkFailure &&
          message    == other.message &&
          statusCode == other.statusCode;

  @override
  int get hashCode => Object.hash(message, statusCode);
}

// ─────────────────────────────────────────────
// MARK: — CONTENT FAILURE
// ─────────────────────────────────────────────

final class ContentFailure extends Failure {
  final String? contentId;
  final String? contentType;

  const ContentFailure({
    required super.message,
    this.contentId,
    this.contentType,
  });

  bool get isNotFound => message.toLowerCase().contains('not found');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentFailure &&
          message     == other.message &&
          contentId   == other.contentId &&
          contentType == other.contentType;

  @override
  int get hashCode => Object.hash(message, contentId, contentType);
}

// ─────────────────────────────────────────────
// MARK: — UNKNOWN FAILURE
// ─────────────────────────────────────────────

final class UnknownFailure extends Failure {
  final Object? originalError;

  const UnknownFailure({
    super.message = 'An unexpected error occurred.',
    this.originalError,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownFailure && message == other.message;

  @override
  int get hashCode => message.hashCode;
}

// ─────────────────────────────────────────────
// MARK: — FAILURE EXTENSIONS
// ─────────────────────────────────────────────

extension FailureMapper on Exception {
  Failure toFailure() {
    final msg = toString();
    if (msg.contains('database') || msg.contains('isar')) {
      return DatabaseFailure(message: msg);
    }
    if (msg.contains('not found') || msg.contains('404')) {
      return ContentFailure(message: msg);
    }
    return UnknownFailure(message: msg, originalError: this);
  }
}