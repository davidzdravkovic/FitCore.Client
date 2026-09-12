import 'dart:convert';

class JwtClaims {
  const JwtClaims._(this._payload);

  final Map<String, dynamic> _payload;

// Valid token check
  static JwtClaims? tryParse(String? token) {
    if (token == null || token.isEmpty) return null;

    final parts = token.split('.');
    if (parts.length != 3) return null;

    try {
      final normalized = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payload = jsonDecode(decoded);
      if (payload is! Map<String, dynamic>) return null;
      return JwtClaims._(payload);
    } catch (_) {
      return null;
    }
  }

// On valid token expiration check
  bool get isExpired {
    final exp = _payload['exp'];
    if (exp is! num) return true;
    final expiresAt = DateTime.fromMillisecondsSinceEpoch(
      exp.toInt() * 1000,
      isUtc: true,
    );
    return DateTime.now().toUtc().isAfter(expiresAt);
  }

// On valid token Role check
  String? get role {
    const roleUri =
        'http://schemas.microsoft.com/ws/2008/06/identity/claims/role';

    final raw = _payload['role'] ?? _payload[roleUri];
    if (raw is String && raw.isNotEmpty) return raw;
    if (raw is List && raw.isNotEmpty) {
      final first = raw.first;
      if (first is String && first.isNotEmpty) return first;
    }
    return null;
  }

  bool hasRole(String expected) => role == expected;
}
