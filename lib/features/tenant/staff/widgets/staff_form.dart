import 'package:fitcore_client/core/api/api_exception.dart';
import 'package:fitcore_client/core/validation/validators.dart';
import 'package:fitcore_client/features/tenant/staff/api/staff_api.dart';
import 'package:fitcore_client/features/tenant/staff/models/staff_models.dart';
import 'package:flutter/material.dart';

class StaffForm extends StatefulWidget {
  const StaffForm({
    super.key,
    this.staffApi,
    this.onCreated,
  });

  final StaffApi? staffApi;
  final ValueChanged<StaffResponse>? onCreated;

  @override
  State<StaffForm> createState() => _StaffFormState();
}

class _StaffFormState extends State<StaffForm> {
  final _formKey = GlobalKey<FormState>();
  late final StaffApi _staffApi = widget.staffApi ?? StaffApi();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    try {
      final response = await _staffApi.create(
        CreateStaffRequest(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Creates a new staff member with no past history. '
            'Use Import to bring staff from another system.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            controller: _firstNameController,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'First name',
              border: OutlineInputBorder(),
            ),
            validator: (value) => Validators.required(value, 'First name'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            controller: _lastNameController,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Last name',
              border: OutlineInputBorder(),
            ),
            validator: (value) => Validators.required(value, 'Last name'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.email],
            onFieldSubmitted: (_) => _submit(),
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
            validator: Validators.email,
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
                : const Text('Create staff'),
          ),
        ],
      ),
    );
  }
}
