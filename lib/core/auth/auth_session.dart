import 'package:fitcore_client/core/api/api_client.dart';
import 'package:fitcore_client/core/auth/jwt_claims.dart';

class AuthSession {
  AuthSession._();

  static JwtClaims? get _claims {
    final parsed = JwtClaims.tryParse(ApiClient.instance.accessToken);
    if (parsed == null || parsed.isExpired) return null;
    return parsed;
  }

  static bool hasRole(String role) => _claims?.hasRole(role) ?? false;

  static bool get isPlatformAdmin => hasRole('PlatformAdmin');

  static bool get isTenantOwner => hasRole('TenantOwner');

  static bool get isTenantStaff => hasRole('TenantStaff');

  static bool get isMember => hasRole('Member');
}
