enum PlanEntitlementType {
  sessionPack;

  String get apiValue => 'SessionPack';

  String get label => 'Session pack';

  static PlanEntitlementType? tryParse(String? value) {
    final normalized = value?.trim().toLowerCase();
    return switch (normalized) {
      'sessionpack' => PlanEntitlementType.sessionPack,
      _ => null,
    };
  }
}
