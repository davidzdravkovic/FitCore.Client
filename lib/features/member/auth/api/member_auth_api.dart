import 'package:fitcore_client/core/api/api_client.dart';
import 'package:fitcore_client/core/auth/portal_auth_models.dart';

class MemberAuthApi {
  MemberAuthApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<PortalSessionResponse> login(EmailPasswordLoginRequest request) {
    return _client.request<PortalSessionResponse>(
      '/api/members/login',
      method: 'POST',
      data: request.toJson(),
      useAuth: false,
      parse: PortalSessionResponse.fromJson,
    );
  }

  Future<PortalSessionResponse> activate(InviteActivateRequest request) {
    return _client.request<PortalSessionResponse>(
      '/api/members/activate',
      method: 'POST',
      data: request.toJson(),
      useAuth: false,
      parse: PortalSessionResponse.fromJson,
    );
  }
}
