import 'package:flutter/foundation.dart';
import 'package:ansicolor/ansicolor.dart';

/// Generic colour-coded debug logger.
///
/// Usage:
/// ```dart
/// BlocManagerLogger.logBasic('User loaded', tag: 'Auth');
/// BlocManagerLogger.logError('Login failed', tag: 'Auth');
/// ```
abstract class BlocManagerLogger {
  static String _formatTag(String? tag) => tag != null ? '[$tag]' : '[BlocManager]';

  static void logBasic(String message, {String? tag}) {
    if (kDebugMode) {
      _ColorPen.blue.log('📌 ${_formatTag(tag)} $message');
    }
  }

  static void logError(String message, {String? tag}) {
    if (kDebugMode) {
      _ColorPen.red.log('🚨 ${_formatTag(tag)} $message');
    }
  }

  static void logSuccess(String message, {String? tag}) {
    if (kDebugMode) {
      _ColorPen.green.log('✅ ${_formatTag(tag)} $message');
    }
  }

  static void logWarning(String message, {String? tag}) {
    if (kDebugMode) {
      _ColorPen.yellow.log('⚡ ${_formatTag(tag)} $message');
    }
  }
}

enum _ColorPen { blue, red, green, yellow }

extension on _ColorPen {
  AnsiPen get _pen {
    switch (this) {
      case _ColorPen.blue:
        return AnsiPen()..blue();
      case _ColorPen.red:
        return AnsiPen()..red();
      case _ColorPen.green:
        return AnsiPen()..green();
      case _ColorPen.yellow:
        return AnsiPen()..yellow();
    }
  }

  // ignore: avoid_print
  void log(dynamic text) => print(_pen(text));
}
