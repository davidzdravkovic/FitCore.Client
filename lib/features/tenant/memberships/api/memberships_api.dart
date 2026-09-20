import 'package:fitcore_client/core/api/api_client.dart';
import 'package:fitcore_client/features/tenant/memberships/models/assign_membership_request.dart';
import 'package:fitcore_client/features/tenant/memberships/models/cancel_membership_request.dart';
import 'package:fitcore_client/features/tenant/memberships/models/membership_response.dart';

class MembershipsApi {
  MembershipsApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<List<MembershipResponse>> list() {
    return _client.request<List<MembershipResponse>>(
      '/api/memberships',
      parse: (json) {
        final items = json as List<dynamic>? ?? const [];
        return items.map(MembershipResponse.fromJson).toList();
      },
    );
  }

  Future<MembershipResponse> assign(AssignMembershipRequest request) {
    return _client.request<MembershipResponse>(
      '/api/memberships',
      method: 'POST',
      data: request.toJson(),
      parse: MembershipResponse.fromJson,
    );
  }

  Future<MembershipResponse> cancel(String id, CancelMembershipRequest request) {
    return _client.request<MembershipResponse>(
      '/api/memberships/$id/cancel',
      method: 'POST',
      data: request.toJson(),
      parse: MembershipResponse.fromJson,
    );
  }
}
