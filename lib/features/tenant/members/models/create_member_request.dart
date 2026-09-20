class CreateMemberRequest {
  const CreateMemberRequest({
    required this.firstName,
    required this.lastName,
    this.email = '',
    this.phone = '',
  });

  final String firstName;
  final String lastName;
  final String email;
  final String phone;

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
      };
}
