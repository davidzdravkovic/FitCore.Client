import 'package:fitcore_client/core/api/api_exception.dart';
import 'package:fitcore_client/core/validation/validators.dart';
import 'package:fitcore_client/features/tenant/members/api/members_api.dart';
import 'package:fitcore_client/features/tenant/members/api/members_models.dart';
import 'package:flutter/material.dart';

class MemberForm extends StatefulWidget {
  const MemberForm({
    super.key,
    this.membersApi,
    this.onCreated,
  });

  final MembersApi? membersApi;
  final ValueChanged<Member>? onCreated;

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

  MemberStatus _status = MemberStatus.active;
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

    try {
      final response = await _membersApi.create(
        CreateMemberRequest(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          status: _status,
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
            'Creates a new member with no past history. '
            'Use Import to bring members from another system.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          DropdownMenu<MemberStatus>(
            initialSelection: _status,
            label: const Text('Status'),
            expandedInsets: EdgeInsets.zero,
            enableSearch: false,
            requestFocusOnTap: false,
            dropdownMenuEntries: [
              for (final status in MemberStatus.values)
                DropdownMenuEntry(
                  value: status,
                  label: status.label,
                ),
            ],
            onSelected: _isSubmitting
                ? null
                : (value) {
                    if (value == null) return;
                    setState(() => _status = value);
                  },
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
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            onChanged: (_) => _formKey.currentState?.validate(),
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'Email or phone required',
              border: OutlineInputBorder(),
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
              border: OutlineInputBorder(),
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
                : const Text('Create member'),
          ),
        ],
      ),
    );
  }
}
