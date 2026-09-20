import 'package:fitcore_client/core/api/api_exception.dart';
import 'package:fitcore_client/core/time/tenant_clock.dart';
import 'package:fitcore_client/features/tenant/memberships/models/membership_response.dart';
import 'package:fitcore_client/features/tenant/staff/models/staff_response.dart';
import 'package:fitcore_client/features/tenant/visits/api/visits_api.dart';
import 'package:fitcore_client/features/tenant/visits/models/create_visit_request.dart';
import 'package:fitcore_client/features/tenant/visits/models/visit_response.dart';
import 'package:flutter/material.dart';

class CreateVisitForm extends StatefulWidget {
  const CreateVisitForm({
    super.key,
    required this.memberships,
    required this.staff,
    this.visitsApi,
    this.onCreated,
    this.initialCoachStaffId,
    this.initialStart,
  });

  final List<MembershipResponse> memberships;
  final List<StaffResponse> staff;
  final VisitsApi? visitsApi;
  final ValueChanged<VisitResponse>? onCreated;

  /// Prefilled when the form is opened from an empty slot on the day board.
  final String? initialCoachStaffId;
  final DateTime? initialStart;

  @override
  State<CreateVisitForm> createState() => _CreateVisitFormState();
}

class _CreateVisitFormState extends State<CreateVisitForm> {
  final _formKey = GlobalKey<FormState>();
  late final VisitsApi _visitsApi = widget.visitsApi ?? VisitsApi();

  String? _membershipId;
  String? _coachStaffId;
  DateTime? _startLocal;
  DateTime? _endLocal;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.memberships.isNotEmpty) {
      _membershipId = widget.memberships.first.id;
    }
    if (widget.staff.isNotEmpty) {
      final preselected = widget.staff
          .where((person) => person.id == widget.initialCoachStaffId)
          .toList();
      _coachStaffId =
          preselected.isEmpty ? widget.staff.first.id : preselected.first.id;
    }

    final now = TenantClock.now();
    final start = widget.initialStart ??
        DateTime(now.year, now.month, now.day, now.hour + 1);
    _startLocal = start;
    _endLocal = start.add(const Duration(hours: 1));
  }

  String _membershipLabel(MembershipResponse membership) {
    final entitlement = '${membership.sessionsAvailable} left';
    return '${membership.memberName} · ${membership.planName} ($entitlement)';
  }

  String _staffLabel(StaffResponse staff) =>
      '${staff.firstName} ${staff.lastName}'.trim();

  String _formatDateTime(DateTime value) {
    final y = value.year.toString().padLeft(4, '0');
    final m = value.month.toString().padLeft(2, '0');
    final d = value.day.toString().padLeft(2, '0');
    final hh = value.hour.toString().padLeft(2, '0');
    final mm = value.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $hh:$mm';
  }

  Future<void> _pickStart() async {
    final current = _startLocal ?? TenantClock.now();
    final now = TenantClock.now();
    final date = await showDatePicker(
      context: context,
      initialDate: current.isBefore(now) ? now : current,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (time == null || !mounted) return;

    final start =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      _startLocal = start;
      if (_endLocal == null || !_endLocal!.isAfter(start)) {
        _endLocal = start.add(const Duration(hours: 1));
      }
    });
  }

  Future<void> _pickEnd() async {
    final now = TenantClock.now();
    final current =
        _endLocal ?? (_startLocal ?? now).add(const Duration(hours: 1));
    final date = await showDatePicker(
      context: context,
      initialDate: current.isBefore(now) ? now : current,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (time == null || !mounted) return;

    setState(() {
      _endLocal =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_membershipId == null || _coachStaffId == null) return;
    if (_startLocal == null || _endLocal == null) return;
    if (!_endLocal!.isAfter(_startLocal!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End must be after start.')),
      );
      return;
    }

    if (!TenantClock.toUtc(_startLocal!).isAfter(DateTime.now().toUtc())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Use Record past visit for times that already started.'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final response = await _visitsApi.create(
        CreateVisitRequest(
          membershipId: _membershipId!,
          coachStaffId: _coachStaffId!,
          startAt: TenantClock.toUtc(_startLocal!),
          endAt: TenantClock.toUtc(_endLocal!),
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

    if (widget.memberships.isEmpty || widget.staff.isEmpty) {
      return Text(
        widget.memberships.isEmpty
            ? 'Assign an active membership before scheduling a visit.'
            : 'Add staff before assigning a coach to a visit.',
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
            initialSelection: _membershipId,
            label: const Text('Membership'),
            expandedInsets: EdgeInsets.zero,
            enableSearch: true,
            requestFocusOnTap: true,
            dropdownMenuEntries: [
              for (final membership in widget.memberships)
                DropdownMenuEntry(
                  value: membership.id,
                  label: _membershipLabel(membership),
                ),
            ],
            onSelected: _isSubmitting
                ? null
                : (value) {
                    if (value == null) return;
                    setState(() => _membershipId = value);
                  },
          ),
          const SizedBox(height: 16),
          DropdownMenu<String>(
            initialSelection: _coachStaffId,
            label: const Text('Coach'),
            expandedInsets: EdgeInsets.zero,
            enableSearch: true,
            requestFocusOnTap: true,
            dropdownMenuEntries: [
              for (final person in widget.staff)
                DropdownMenuEntry(
                  value: person.id,
                  label: _staffLabel(person),
                ),
            ],
            onSelected: _isSubmitting
                ? null
                : (value) {
                    if (value == null) return;
                    setState(() => _coachStaffId = value);
                  },
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: _isSubmitting ? null : _pickStart,
            child: Text(
              _startLocal == null
                  ? 'Pick start'
                  : 'Start: ${_formatDateTime(_startLocal!)}',
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _isSubmitting ? null : _pickEnd,
            child: Text(
              _endLocal == null
                  ? 'Pick end'
                  : 'End: ${_formatDateTime(_endLocal!)}',
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Schedule visit'),
          ),
        ],
      ),
    );
  }
}
