import 'package:fitcore_client/core/api/api_client.dart';
import 'package:fitcore_client/features/member/auth/models/member_auth_models.dart';

class MemberAuthApi {
  MemberAuthApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<MemberSessionResponse> login(LoginMemberRequest request) {
    return _client.request<MemberSessionResponse>(
      '/api/members/login',
      method: 'POST',
      data: request.toJson(),
      useAuth: false,
      parse: MemberSessionResponse.fromJson,
    );
  }

  Future<MemberSessionResponse> activate(ActivateMemberRequest request) {
    return _client.request<MemberSessionResponse>(
      '/api/members/activate',
      method: 'POST',
      data: request.toJson(),
      useAuth: false,
      parse: MemberSessionResponse.fromJson,
    );
  }
}
