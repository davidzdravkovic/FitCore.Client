import 'package:fitcore_client/features/tenant/members/models/member_response.dart';
import 'package:fitcore_client/features/tenant/memberships/models/membership_response.dart';

class MemberProfileResponse {
  const MemberProfileResponse({
    required this.member,
    required this.memberships,
  });

  final MemberResponse member;
  final List<MembershipResponse> memberships;

  factory MemberProfileResponse.fromJson(dynamic json) {
    final map = json as Map<String, dynamic>? ?? {};
    final membershipItems = map['memberships'] as List<dynamic>? ?? const [];
    return MemberProfileResponse(
      member: MemberResponse.fromJson(map['member']),
      memberships: membershipItems.map(MembershipResponse.fromJson).toList(),
    );
  }
}
