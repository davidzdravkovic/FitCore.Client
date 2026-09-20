import 'package:fitcore_client/core/api/api_exception.dart';
import 'package:fitcore_client/core/validation/validators.dart';
import 'package:fitcore_client/features/tenant/members/api/members_api.dart';
import 'package:fitcore_client/features/tenant/members/models/create_member_request.dart';
import 'package:fitcore_client/features/tenant/members/models/member_response.dart';
import 'package:flutter/material.dart';

class MemberForm extends StatefulWidget {
  const MemberForm({
    super.key,
    this.membersApi,
    this.onCreated,
    this.isImport = false,
  });

  final MembersApi? membersApi;
  final ValueChanged<MemberResponse>? onCreated;
  final bool isImport;

  @override
  State<MemberForm> createState() => _MemberFormState();
}

class _MemberFormState extends State<MemberForm> {
  final _formKey = GlobalKey<FormState>();
  late final MembersApi _membersApi = widget.membersApi ?? MembersApi();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    final request = CreateMemberRequest(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    try {
      final response = widget.isImport
          ? await _membersApi.importMember(request)
          : await _membersApi.create(request);

      if (!mounted) return;

      widget.onCreated?.call(response);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final helpText = widget.isImport
        ? 'Brings in a member from another system as Paused. '
              'They become Active when you assign a membership.'
        : 'Creates a new lead with no past history. '
              'They become Active when you assign a membership. '
              'Use Import for members from another system.';

    final submitLabel = widget.isImport ? 'Import member' : 'Create member';

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            helpText,
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
            decoration: const InputDecoration(labelText: 'First name'),
            validator: (value) => Validators.required(value, 'First name'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            controller: _lastNameController,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Last name'),
            validator: (value) => Validators.required(value, 'Last name'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            onChanged: (_) => _formKey.currentState?.validate(),
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'Email or phone required',
            ),
            validator: (value) {
              final formatError = Validators.optionalEmail(value);
              if (formatError != null) return formatError;
              return Validators.emailOrPhone(
                email: value,
                phone: _phoneController.text,
              );
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.telephoneNumber],
            onChanged: (_) => _formKey.currentState?.validate(),
            onFieldSubmitted: (_) => _submit(),
            decoration: const InputDecoration(
              labelText: 'Phone',
              hintText: 'Email or phone required',
            ),
            validator: (value) {
              final formatError = Validators.optionalPhone(value);
              if (formatError != null) return formatError;
              return Validators.emailOrPhone(
                email: _emailController.text,
                phone: value,
              );
            },
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
                : Text(submitLabel),
          ),
        ],
      ),
    );
  }
}
