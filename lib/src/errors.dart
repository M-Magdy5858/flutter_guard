import 'package:flutter/services.dart';

/// Thrown when a flutter_secure_guard platform call fails.
class FlutterGuardException implements Exception {
  FlutterGuardException(this.code, this.message);

  /// Error code, e.g. `NO_ACTIVITY` or `NO_WINDOW`.
  final String code;

  /// Human-readable description of the error.
  final String message;

  factory FlutterGuardException.fromPlatform(PlatformException ex) =>
      FlutterGuardException(ex.code, ex.message ?? 'Unknown error');

  @override
  String toString() => 'FlutterGuardException ($code): $message';
}
