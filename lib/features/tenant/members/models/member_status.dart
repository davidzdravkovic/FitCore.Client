enum MemberStatus {
  lead,
  trial,
  active,
  paused,
  cancelled;

  String get label => switch (this) {
        MemberStatus.lead => 'Lead',
        MemberStatus.trial => 'Trial',
        MemberStatus.active => 'Active',
        MemberStatus.paused => 'Paused',
        MemberStatus.cancelled => 'Cancelled',
      };

  bool get canAssignMembership =>
      this == MemberStatus.lead ||
      this == MemberStatus.active ||
      this == MemberStatus.paused;

  static MemberStatus? tryParse(String? value) {
    final normalized = value?.trim().toLowerCase();
    return switch (normalized) {
      'lead' => MemberStatus.lead,
      'trial' => MemberStatus.trial,
      'active' => MemberStatus.active,
      'paused' => MemberStatus.paused,
      'cancelled' => MemberStatus.cancelled,
      _ => null,
    };
  }
}
