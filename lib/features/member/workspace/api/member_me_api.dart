import 'package:fitcore_client/core/api/api_client.dart';
import 'package:fitcore_client/features/member/workspace/models/member_profile_response.dart';

class MemberMeApi {
  MemberMeApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<MemberProfileResponse> get() {
    return _client.request<MemberProfileResponse>(
      '/api/members/me',
      parse: MemberProfileResponse.fromJson,
    );
  }
}
