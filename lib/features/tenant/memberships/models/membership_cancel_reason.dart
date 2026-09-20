enum MembershipCancelReason {
  memberRequest,
  adminDecision;

  String get apiValue => switch (this) {
        MembershipCancelReason.memberRequest => 'MemberRequest',
        MembershipCancelReason.adminDecision => 'AdminDecision',
      };

  String get label => switch (this) {
        MembershipCancelReason.memberRequest => 'Member requested',
        MembershipCancelReason.adminDecision => 'Admin decision',
      };
}
