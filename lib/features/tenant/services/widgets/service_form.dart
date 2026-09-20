import 'package:fitcore_client/core/api/api_exception.dart';
import 'package:fitcore_client/core/validation/validators.dart';
import 'package:fitcore_client/features/tenant/services/api/services_api.dart';
import 'package:fitcore_client/features/tenant/services/models/create_service_request.dart';
import 'package:fitcore_client/features/tenant/services/models/service_response.dart';
import 'package:flutter/material.dart';

class ServiceForm extends StatefulWidget {
  const ServiceForm({
    super.key,
    this.servicesApi,
    this.onCreated,
  });

  final ServicesApi? servicesApi;
  final ValueChanged<ServiceResponse>? onCreated;

  @override
  State<ServiceForm> createState() => _ServiceFormState();
}

class _ServiceFormState extends State<ServiceForm> {
  final _formKey = GlobalKey<FormState>();
  late final ServicesApi _servicesApi = widget.servicesApi ?? ServicesApi();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    try {
      final response = await _servicesApi.create(
        CreateServiceRequest(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
        ),
      );

      if (!mounted) return;
      widget.onCreated?.call(response);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            controller: _nameController,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) => Validators.required(value, 'Name'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            textInputAction: TextInputAction.done,
            textCapitalization: TextCapitalization.sentences,
            maxLines: 3,
            onFieldSubmitted: (_) => _submit(),
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _isSubmitting ? null : _submit,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Create service'),
          ),
        ],
      ),
    );
  }
}
