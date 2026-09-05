import 'package:fitcore_client/core/api/api_client.dart';
import 'package:fitcore_client/features/platform_auth/api/platform_login_models.dart';
import 'package:fitcore_client/features/platform_auth/api/platform_verify_models.dart';

class PlatformAuthApi {
  PlatformAuthApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<PlatformLoginResponse> login(PlatformLoginRequest request) {
    return _client.request<PlatformLoginResponse>(
      '/api/platform-auth/login',
      method: 'POST',
      data: request.toJson(),
      useAuth: false,
      parse: PlatformLoginResponse.fromJson,
    );
  }

  Future<PlatformVerifyResponse> verify(PlatformVerifyRequest request) {
    return _client.request<PlatformVerifyResponse>(
      '/api/platform-auth/verify',
      method: 'POST',
      data: request.toJson(),
      useAuth: false,
      parse: PlatformVerifyResponse.fromJson,
    );
  }
}
