import 'package:fitcore_client/core/api/api_client.dart';
import 'package:fitcore_client/features/tenant/members/models/members_models.dart';

class MembersApi {
  MembersApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<List<MemberResponse>> list() {
    return _client.request<List<MemberResponse>>(
      '/api/members',
      parse: (json) {
        final items = json as List<dynamic>? ?? const [];
        return items.map(MemberResponse.fromJson).toList();
      },
    );
  }

  Future<MemberResponse> create(CreateMemberRequest request) {
    return _client.request<MemberResponse>(
      '/api/members',
      method: 'POST',
      data: request.toJson(),
      parse: MemberResponse.fromJson,
    );
  }

  Future<InviteMemberResponse> invite(String id) {
    return _client.request<InviteMemberResponse>(
      '/api/members/$id/invite',
      method: 'POST',
      parse: InviteMemberResponse.fromJson,
    );
  }

  Future<void> delete(String id) {
    return _client.request<void>(
      '/api/members/$id',
      method: 'DELETE',
      parse: (_) {},
    );
  }
}
