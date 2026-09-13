class ServiceResponse {
  const ServiceResponse({
    required this.id,
    required this.name,
    required this.isActive,
    required this.createdAt,
    this.description,
  });

  final String id;
  final String name;
  final String? description;
  final bool isActive;
  final DateTime createdAt;

  factory ServiceResponse.fromJson(dynamic json) {
    final map = json as Map<String, dynamic>? ?? {};
    return ServiceResponse(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      description: map['description'] as String?,
      isActive: map['isActive'] as bool? ?? false,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }
}

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
