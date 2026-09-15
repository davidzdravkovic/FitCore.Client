import 'package:fitcore_client/core/api/api_exception.dart';
import 'package:fitcore_client/features/tenant/members/models/members_models.dart';
import 'package:fitcore_client/features/tenant/memberships/api/memberships_api.dart';
import 'package:fitcore_client/features/tenant/memberships/models/memberships_models.dart';
import 'package:fitcore_client/features/tenant/plans/models/plans_models.dart';
import 'package:flutter/material.dart';

class AssignMembershipForm extends StatefulWidget {
  const AssignMembershipForm({
    super.key,
    required this.members,
    required this.activePlans,
    this.membershipsApi,
    this.onAssigned,
  });

  final List<MemberResponse> members;
  final List<PlanResponse> activePlans;
  final MembershipsApi? membershipsApi;
  final ValueChanged<MembershipResponse>? onAssigned;

  @override
  State<AssignMembershipForm> createState() => _AssignMembershipFormState();
}

class _AssignMembershipFormState extends State<AssignMembershipForm> {
  final _formKey = GlobalKey<FormState>();
  late final MembershipsApi _membershipsApi =
      widget.membershipsApi ?? MembershipsApi();

  late final List<MemberResponse> _assignableMembers;
  late final List<PlanResponse> _activePlans;

  String? _memberId;
  String? _planId;
  DateTime? _startAt;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _assignableMembers = widget.members
        .where((m) => m.status.canAssignMembership)
        .toList();
    _activePlans = widget.activePlans;

    if (_assignableMembers.isNotEmpty) {
      _memberId = _assignableMembers.first.id;
    }
    if (_activePlans.isNotEmpty) {
      _planId = _activePlans.first.id;
    }
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startAt ?? now,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      _startAt = DateTime.utc(picked.year, picked.month, picked.day);
    });
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_memberId == null || _planId == null) return;

    setState(() => _isSubmitting = true);

    try {
      final response = await _membershipsApi.assign(
        AssignMembershipRequest(
          memberId: _memberId!,
          planId: _planId!,
          startAt: _startAt,
        ),
      );

      if (!mounted) return;
      widget.onAssigned?.call(response);
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

    if (_assignableMembers.isEmpty || _activePlans.isEmpty) {
      return Text(
        _assignableMembers.isEmpty
            ? 'Add a Lead, Active, or Paused member first, then assign a membership.'
            : 'Create an active plan first, then assign a membership.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    final startLabel = _startAt == null
        ? 'Starts now (default)'
        : 'Start: ${_startAt!.toLocal().toString().split(' ').first}';

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownMenu<String>(
            initialSelection: _memberId,
            label: const Text('Member'),
            expandedInsets: EdgeInsets.zero,
            enableSearch: true,
            requestFocusOnTap: true,
            dropdownMenuEntries: [
              for (final member in _assignableMembers)
                DropdownMenuEntry(
                  value: member.id,
                  label: '${member.firstName} ${member.lastName}'.trim(),
                ),
            ],
            onSelected: _isSubmitting
                ? null
                : (value) {
                    if (value == null) return;
                    setState(() => _memberId = value);
                  },
          ),
          const SizedBox(height: 16),
          DropdownMenu<String>(
            initialSelection: _planId,
            label: const Text('Plan'),
            expandedInsets: EdgeInsets.zero,
            enableSearch: true,
            requestFocusOnTap: true,
            dropdownMenuEntries: [
              for (final plan in _activePlans)
                DropdownMenuEntry(
                  value: plan.id,
                  label: '${plan.name} · ${plan.entitlementSummary}',
                ),
            ],
            onSelected: _isSubmitting
                ? null
                : (value) {
                    if (value == null) return;
                    setState(() => _planId = value);
                  },
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _isSubmitting ? null : _pickStartDate,
            icon: const Icon(Icons.event_outlined),
            label: Text(startLabel),
          ),
          if (_startAt != null) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: _isSubmitting
                  ? null
                  : () => setState(() => _startAt = null),
              child: const Text('Clear start date (use now)'),
            ),
          ],
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
                : const Text('Assign membership'),
          ),
        ],
      ),
    );
  }
}
