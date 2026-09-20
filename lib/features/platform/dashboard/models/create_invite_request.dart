class CreateInviteRequest {
  const CreateInviteRequest({required this.email});

  final String email;

  Map<String, dynamic> toJson() => {
        'email': email,
      };
}
