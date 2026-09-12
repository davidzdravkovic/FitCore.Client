import 'package:flutter/foundation.dart';

/// Notifies [GoRouter] to re-run redirects when auth token changes (e.g. 401 logout).
class AuthRefresh extends ChangeNotifier {
  AuthRefresh._();

  static final AuthRefresh instance = AuthRefresh._();

  void notifyAuthChanged() => notifyListeners();
}
