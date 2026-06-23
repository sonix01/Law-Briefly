// lib/core/error/app_exception.dart

// ─────────────────────────────────────────────
// MARK: — BASE EXCEPTION
// ─────────────────────────────────────────────

sealed class AppException implements Exception {
  final String  message;
  final Object? cause;
  final StackTrace? stackTrace;

  const AppException({
    required this.message,
    this.cause,
    this.stackTrace,
  });

  @override
  String toString() =>
      '${runtimeType.toString()}: $message'
      '${cause != null ? " — caused by: $cause" : ""}';
}

// ─────────────────────────────────────────────
// MARK: — JSON PARSING EXCEPTION
// ─────────────────────────────────────────────

final class JsonParsingException extends AppException {
  final String? filePath;
  final int?    lineNumber;

  const JsonParsingException({
    required super.message,
    this.filePath,
    this.lineNumber,
    super.cause,
    super.stackTrace,
  });
}

// ─────────────────────────────────────────────
// MARK: — DATABASE EXCEPTION
// ─────────────────────────────────────────────

final class DatabaseException extends AppException {
  final String? operation;  // 'read', 'write', 'delete', 'query'
  final String? entityName;

  const DatabaseException({
    required super.message,
    this.operation,
    this.entityName,
    super.cause,
    super.stackTrace,
  });
}

// ─────────────────────────────────────────────
// MARK: — CONTENT NOT FOUND EXCEPTION
// ─────────────────────────────────────────────

final class ContentNotFoundException extends AppException {
  final String  contentId;
  final String? contentType; // 'section', 'article', 'act', 'caseLaw'

  const ContentNotFoundException({
    required super.message,
    required this.contentId,
    this.contentType,
    super.cause,
    super.stackTrace,
  });
}

// ─────────────────────────────────────────────
// MARK: — NAVIGATION EXCEPTION
// ─────────────────────────────────────────────

final class NavigationException extends AppException {
  final String? route;
  final String? reason;

  const NavigationException({
    required super.message,
    this.route,
    this.reason,
    super.cause,
    super.stackTrace,
  });
}

// ─────────────────────────────────────────────
// MARK: — ASSET LOAD EXCEPTION
// ─────────────────────────────────────────────

final class AssetLoadException extends AppException {
  final String assetPath;

  const AssetLoadException({
    required super.message,
    required this.assetPath,
    super.cause,
    super.stackTrace,
  });
}