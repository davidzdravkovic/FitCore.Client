class RegisterOrganizationRequest {
  const RegisterOrganizationRequest({
    required this.invitationToken,
    required this.organizationName,
    required this.businessEmail,
    required this.country,
    required this.city,
    required this.timeZone,
    required this.currency,
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
  final String currency;
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
        'currency': currency,
        'ownerFirstName': ownerFirstName,
        'ownerLastName': ownerLastName,
        'ownerEmail': ownerEmail,
        'ownerPassword': ownerPassword,
      };
}
