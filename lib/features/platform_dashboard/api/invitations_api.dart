import 'package:fitcore_client/core/api/api_client.dart';
import 'package:fitcore_client/features/platform_dashboard/api/invitations_models.dart';

class InvitationsApi {
  InvitationsApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<CreateInviteResponse> create(CreateInviteRequest request) {
    return _client.request<CreateInviteResponse>(
      '/api/invitations',
      method: 'POST',
      data: request.toJson(),
      parse: CreateInviteResponse.fromJson,
    );
  }
}
