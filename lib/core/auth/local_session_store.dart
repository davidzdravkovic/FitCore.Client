import 'package:fitcore_client/core/api/api_client.dart';
import 'package:fitcore_client/core/auth/jwt_claims.dart';
import 'package:fitcore_client/features/tenant/auth/tenant_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Key/value persistence via [SharedPreferences]
/// (web localStorage / Android SharedPreferences / iOS NSUserDefaults).
class LocalSessionStore {
  LocalSessionStore._();

  static const _tokenKey = 'fitcore.accessToken';
  static const _orgNameKey = 'fitcore.tenant.organizationName';
  static const _ownerFirstNameKey = 'fitcore.tenant.ownerFirstName';
  static const _timeZoneKey = 'fitcore.tenant.timeZone';

  /// Restore token + tenant profile before [runApp]. Drops expired tokens.
  static Future<void> hydrate() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token != null && token.isNotEmpty) {
      final claims = JwtClaims.tryParse(token);
      if (claims == null || claims.isExpired) {
        await prefs.remove(_tokenKey);
      } else {
        ApiClient.instance.setAccessToken(token, persist: false);
      }
    }

    TenantSession.restore(
      organizationName: prefs.getString(_orgNameKey),
      ownerFirstName: prefs.getString(_ownerFirstNameKey),
      timeZone: prefs.getString(_timeZoneKey),
    );
  }

  static Future<void> saveAccessToken(String? token) async {
    final prefs = await SharedPreferences.getInstance();
    if (token == null || token.isEmpty) {
      await prefs.remove(_tokenKey);
    } else {
      await prefs.setString(_tokenKey, token);
    }
  }

  static Future<void> saveTenantProfile({
    required String? organizationName,
    required String? ownerFirstName,
    required String? timeZone,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    Future<void> write(String key, String? value) async {
      if (value == null || value.isEmpty) {
        await prefs.remove(key);
      } else {
        await prefs.setString(key, value);
      }
    }

    await write(_orgNameKey, organizationName);
    await write(_ownerFirstNameKey, ownerFirstName);
    await write(_timeZoneKey, timeZone);
  }

  static Future<void> clearTenantProfile() async {
    await saveTenantProfile(
      organizationName: null,
      ownerFirstName: null,
      timeZone: null,
    );
  }
}
