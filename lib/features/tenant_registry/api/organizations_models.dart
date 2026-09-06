class RegisterOrganizationRequest {
  const RegisterOrganizationRequest({
    required this.invitationToken,
    required this.organizationName,
    required this.businessEmail,
    required this.country,
    required this.city,
    required this.timeZone,
    required this.ownerFirstName,
    required this.ownerLastName,
    required this.ownerEmail,
    required this.ownerPassword,
  });

  final String invitationToken;
  final String organizationName;
  final String businessEmail;
  final String country;
  final String city;
  final String timeZone;
  final String ownerFirstName;
  final String ownerLastName;
  final String ownerEmail;
  final String ownerPassword;

  Map<String, dynamic> toJson() => {
        'invitationToken': invitationToken,
        'organizationName': organizationName,
        'businessEmail': businessEmail,
        'country': country,
        'city': city,
        'timeZone': timeZone,
        'ownerFirstName': ownerFirstName,
        'ownerLastName': ownerLastName,
        'ownerEmail': ownerEmail,
        'ownerPassword': ownerPassword,
      };
}

class RegisterOrganizationResponse {
  const RegisterOrganizationResponse({
    required this.message,
    required this.accessToken,
    required this.organizationName,
    required this.ownerFirstName,
  });

  final String message;
  final String accessToken;
  final String organizationName;
  final String ownerFirstName;

  factory RegisterOrganizationResponse.fromJson(dynamic json) {
    final map = json as Map<String, dynamic>? ?? {};
    return RegisterOrganizationResponse(
      message: map['message'] as String? ?? '',
      accessToken: map['accessToken'] as String? ?? '',
      organizationName: map['organizationName'] as String? ?? '',
      ownerFirstName: map['ownerFirstName'] as String? ?? '',
    );
  }
}
