import 'package:fitcore_client/features/tenant/memberships/models/membership_cancel_reason.dart';

class CancelMembershipRequest {
  const CancelMembershipRequest({
    required this.reason,
    this.note = '',
  });

  final MembershipCancelReason reason;
  final String note;

  Map<String, dynamic> toJson() => {
        'reason': reason.apiValue,
        if (note.trim().isNotEmpty) 'note': note.trim(),
      };
}
