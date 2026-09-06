import 'package:fitcore_client/core/api/api_client.dart';
import 'package:fitcore_client/core/api/api_exception.dart';
import 'package:fitcore_client/core/time/time_zones.dart';
import 'package:fitcore_client/core/validation/validators.dart';
import 'package:fitcore_client/features/tenant_dashboard/tenant_session.dart';
import 'package:fitcore_client/features/tenant_registry/api/organizations_api.dart';
import 'package:fitcore_client/features/tenant_registry/api/organizations_models.dart';
import 'package:fitcore_client/features/tenant_registry/helpers/registry_input_decoration.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegistryForm extends StatefulWidget {
  const RegistryForm({super.key, this.invitationToken});

  final String? invitationToken;

  @override
  State<RegistryForm> createState() => _RegistryFormState();
}

class _RegistryFormState extends State<RegistryForm> {
  final _formKey = GlobalKey<FormState>();
  final _organizationsApi = OrganizationsApi();

  final _organizationNameController = TextEditingController();
  final _businessEmailController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  final _timeZoneController = TextEditingController();
  final _ownerFirstNameController = TextEditingController();
  final _ownerLastNameController = TextEditingController();
  final _ownerEmailController = TextEditingController();
  final _ownerPasswordController = TextEditingController();

  final _timeZoneFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _isSubmitting = false;

  bool get _hasInvitationToken =>
      widget.invitationToken != null && widget.invitationToken!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _prefillTimeZone();
  }

  Future<void> _prefillTimeZone() async {
    final local = await TimeZones.detectLocal();
    if (!mounted || local == null) return;
    if (_timeZoneController.text == local) return;
    setState(() => _timeZoneController.text = local);
  }

  @override
  void dispose() {
    _organizationNameController.dispose();
    _businessEmailController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _timeZoneController.dispose();
    _timeZoneFocusNode.dispose();
    _ownerFirstNameController.dispose();
    _ownerLastNameController.dispose();
    _ownerEmailController.dispose();
    _ownerPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (!_hasInvitationToken) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Open this page from your invitation email link.'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final response = await _organizationsApi.register(
        RegisterOrganizationRequest(
          invitationToken: widget.invitationToken!,
          organizationName: _organizationNameController.text.trim(),
          businessEmail: _businessEmailController.text.trim(),
          country: _countryController.text.trim(),
          city: _cityController.text.trim(),
          timeZone: _timeZoneController.text.trim(),
          ownerFirstName: _ownerFirstNameController.text.trim(),
          ownerLastName: _ownerLastNameController.text.trim(),
          ownerEmail: _ownerEmailController.text.trim(),
          ownerPassword: _ownerPasswordController.text,
        ),
      );

      if (!mounted) return;

      if (response.accessToken.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.message.isEmpty
                  ? 'Organization created'
                  : response.message,
            ),
          ),
        );
        return;
      }

      ApiClient.instance.setAccessToken(response.accessToken);
      TenantSession.set(
        organizationName: response.organizationName,
        ownerFirstName: response.ownerFirstName,
      );
      context.go('/tenant');
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionHeader(
            title: 'Organization',
            subtitle: 'Where your members will train.',
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: _organizationNameController,
            textInputAction: TextInputAction.next,
            decoration: registryInputDecoration(label: 'Organization name'),
            validator: (v) => Validators.required(v, 'Organization name'),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _businessEmailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: registryInputDecoration(label: 'Business email'),
            validator: Validators.email,
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _countryController,
                  textInputAction: TextInputAction.next,
                  decoration: registryInputDecoration(label: 'Country'),
                  validator: (v) => Validators.required(v, 'Country'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _cityController,
                  textInputAction: TextInputAction.next,
                  decoration: registryInputDecoration(label: 'City'),
                  validator: (v) => Validators.required(v, 'City'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          RawAutocomplete<String>(
            textEditingController: _timeZoneController,
            focusNode: _timeZoneFocusNode,
            optionsBuilder: (textEditingValue) {
              final query = textEditingValue.text.trim().toLowerCase();
              if (query.isEmpty) return TimeZones.all.take(40);
              return TimeZones.all
                  .where((id) => id.toLowerCase().contains(query))
                  .take(40);
            },
            onSelected: (selected) {
              _timeZoneController.text = selected;
            },
            fieldViewBuilder:
                (context, controller, focusNode, onFieldSubmitted) {
              return TextFormField(
                controller: controller,
                focusNode: focusNode,
                textInputAction: TextInputAction.next,
                decoration: registryInputDecoration(
                  label: 'Time zone',
                  hint: 'Search time zones',
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) return 'Time zone is required';
                  if (!TimeZones.contains(text)) {
                    return 'Select a time zone from the list';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => onFieldSubmitted(),
              );
            },
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(8),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: 280,
                      maxWidth: 460,
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final option = options.elementAt(index);
                        return ListTile(
                          dense: true,
                          title: Text(option),
                          onTap: () => onSelected(option),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.55)),
          const SizedBox(height: 28),
          const _SectionHeader(
            title: 'Owner account',
            subtitle: 'You will use this to manage the gym.',
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _ownerFirstNameController,
                  textInputAction: TextInputAction.next,
                  decoration: registryInputDecoration(label: 'First name'),
                  validator: (v) => Validators.required(v, 'First name'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _ownerLastNameController,
                  textInputAction: TextInputAction.next,
                  decoration: registryInputDecoration(label: 'Last name'),
                  validator: (v) => Validators.required(v, 'Last name'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _ownerEmailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: registryInputDecoration(label: 'Owner email'),
            validator: Validators.email,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _ownerPasswordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            decoration: registryInputDecoration(
              label: 'Password',
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
            validator: Validators.password,
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: _isSubmitting ? null : _submit,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              textStyle: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.1,
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Create organization'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
