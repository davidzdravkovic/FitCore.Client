import 'package:fitcore_client/core/api/api_client.dart';
import 'package:fitcore_client/features/tenant/members/models/create_member_request.dart';
import 'package:fitcore_client/features/tenant/members/models/invite_member_response.dart';
import 'package:fitcore_client/features/tenant/members/models/member_response.dart';

class MembersApi {
  MembersApi({ApiClient? client, this.basePath = '/api/members'})
      : _client = client ?? ApiClient.instance;

  final ApiClient _client;
  final String basePath;

  Future<List<MemberResponse>> list() {
    return _client.request<List<MemberResponse>>(
      basePath,
      parse: (json) {
        final items = json as List<dynamic>? ?? const [];
        return items.map(MemberResponse.fromJson).toList();
      },
    );
  }

  Future<MemberResponse> create(CreateMemberRequest request) {
    return _client.request<MemberResponse>(
      basePath,
      method: 'POST',
      data: request.toJson(),
      parse: MemberResponse.fromJson,
    );
  }

  Future<MemberResponse> importMember(CreateMemberRequest request) {
    return _client.request<MemberResponse>(
      '$basePath/import',
      method: 'POST',
      data: request.toJson(),
      parse: MemberResponse.fromJson,
    );
  }

  Future<InviteMemberResponse> invite(String id) {
    return _client.request<InviteMemberResponse>(
      '$basePath/$id/invite',
      method: 'POST',
      parse: InviteMemberResponse.fromJson,
    );
  }

  Future<void> delete(String id) {
    return _client.request<void>(
      '$basePath/$id',
      method: 'DELETE',
      parse: (_) {},
    );
  }
}
