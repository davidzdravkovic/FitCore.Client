class CreateServiceRequest {
  const CreateServiceRequest({
    required this.name,
    this.description = '',
  });

  final String name;
  final String description;

  Map<String, dynamic> toJson() => {
        'name': name,
        if (description.trim().isNotEmpty) 'description': description.trim(),
      };
}
