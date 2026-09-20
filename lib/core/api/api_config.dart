import 'package:flutter/foundation.dart';

class ApiConfig {
  /// Local debug: FitCore.Api launchSettings http profile.
  /// Release/profile web: same origin as the SPA (nginx `/api` → fitcore-api).
  static String get baseUrl {
    if (kIsWeb && !kDebugMode) return Uri.base.origin;
    return 'http://localhost:5145';
  }
}
