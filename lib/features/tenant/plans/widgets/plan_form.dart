import 'package:fitcore_client/core/api/api_exception.dart';
import 'package:fitcore_client/core/validation/validators.dart';
import 'package:fitcore_client/features/tenant/plans/api/plans_api.dart';
import 'package:fitcore_client/features/tenant/plans/models/plans_models.dart';
import 'package:fitcore_client/features/tenant/services/models/services_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PlanForm extends StatefulWidget {
  const PlanForm({
    super.key,
    required this.activeServices,
    this.plansApi,
    this.onCreated,
  });

  final List<ServiceResponse> activeServices;
  final PlansApi? plansApi;
  final ValueChanged<PlanResponse>? onCreated;

  @override
  State<PlanForm> createState() => _PlanFormState();
}

class _PlanFormState extends State<PlanForm> {
  final _formKey = GlobalKey<FormState>();
  late final PlansApi _plansApi = widget.plansApi ?? PlansApi();

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _sessionCountController = TextEditingController();
  final _durationDaysController = TextEditingController();

  String? _serviceId;
  PlanEntitlementType _entitlementType = PlanEntitlementType.sessionPack;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.activeServices.isNotEmpty) {
      _serviceId = widget.activeServices.first.id;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _sessionCountController.dispose();
    _durationDaysController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_serviceId == null) return;

    final price = double.tryParse(_priceController.text.trim());
    if (price == null || price < 0) return;

    setState(() => _isSubmitting = true);

    try {
      final response = await _plansApi.create(
        CreatePlanRequest(
          serviceId: _serviceId!,
          name: _nameController.text.trim(),
          price: price,
          entitlementType: _entitlementType,
          sessionCount: _entitlementType == PlanEntitlementType.sessionPack
              ? int.tryParse(_sessionCountController.text.trim())
              : null,
          durationDays: _entitlementType == PlanEntitlementType.timePeriod
              ? int.tryParse(_durationDaysController.text.trim())
              : null,
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

    if (widget.activeServices.isEmpty) {
      return Text(
        'Create an active service first, then add a plan.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownMenu<String>(
            initialSelection: _serviceId,
            label: const Text('Service'),
            expandedInsets: EdgeInsets.zero,
            enableSearch: false,
            requestFocusOnTap: false,
            dropdownMenuEntries: [
              for (final service in widget.activeServices)
                DropdownMenuEntry(
                  value: service.id,
                  label: service.name,
                ),
            ],
            onSelected: _isSubmitting
                ? null
                : (value) {
                    if (value == null) return;
                    setState(() => _serviceId = value);
                  },
          ),
          const SizedBox(height: 16),
          TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            controller: _nameController,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Plan name',
              border: OutlineInputBorder(),
            ),
            validator: (value) => Validators.required(value, 'Plan name'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            controller: _priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            decoration: const InputDecoration(
              labelText: 'Price',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty) return 'Price is required';
              final parsed = double.tryParse(text);
              if (parsed == null || parsed < 0) {
                return 'Enter a valid price';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownMenu<PlanEntitlementType>(
            initialSelection: _entitlementType,
            label: const Text('Entitlement'),
            expandedInsets: EdgeInsets.zero,
            enableSearch: false,
            requestFocusOnTap: false,
            dropdownMenuEntries: [
              for (final type in PlanEntitlementType.values)
                DropdownMenuEntry(
                  value: type,
                  label: type.label,
                ),
            ],
            onSelected: _isSubmitting
                ? null
                : (value) {
                    if (value == null) return;
                    setState(() => _entitlementType = value);
                  },
          ),
          const SizedBox(height: 16),
          if (_entitlementType == PlanEntitlementType.sessionPack)
            TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              controller: _sessionCountController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onFieldSubmitted: (_) => _submit(),
              decoration: const InputDecoration(
                labelText: 'Session count',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final n = int.tryParse(value?.trim() ?? '');
                if (n == null || n <= 0) {
                  return 'Enter a session count greater than 0';
                }
                return null;
              },
            )
          else
            TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              controller: _durationDaysController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onFieldSubmitted: (_) => _submit(),
              decoration: const InputDecoration(
                labelText: 'Duration (days)',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final n = int.tryParse(value?.trim() ?? '');
                if (n == null || n <= 0) {
                  return 'Enter duration days greater than 0';
                }
                return null;
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
                : const Text('Create plan'),
          ),
        ],
      ),
    );
  }
}
