import 'package:fitcore_client/core/api/api_exception.dart';
import 'package:fitcore_client/core/time/tenant_clock.dart';
import 'package:fitcore_client/features/tenant/staff/models/staff_response.dart';
import 'package:fitcore_client/features/tenant/visits/api/visits_api.dart';
import 'package:fitcore_client/features/tenant/visits/models/reschedule_visit_request.dart';
import 'package:fitcore_client/features/tenant/visits/models/visit_response.dart';
import 'package:fitcore_client/features/tenant/visits/widgets/visit_display.dart';
import 'package:flutter/material.dart';

/// Moves a scheduled visit to a new slot, optionally to a different coach.
class RescheduleVisitForm extends StatefulWidget {
  const RescheduleVisitForm({
    super.key,
    required this.visit,
    required this.staff,
    this.visitsApi,
    this.onRescheduled,
  });

  final VisitResponse visit;
  final List<StaffResponse> staff;
  final VisitsApi? visitsApi;
  final ValueChanged<VisitResponse>? onRescheduled;

  @override
  State<RescheduleVisitForm> createState() => _RescheduleVisitFormState();
}

class _RescheduleVisitFormState extends State<RescheduleVisitForm> {
  late final VisitsApi _visitsApi = widget.visitsApi ?? VisitsApi();

  late String? _coachStaffId;
  late DateTime _startLocal;
  late DateTime _endLocal;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final known = widget.staff
        .where((person) => person.id == widget.visit.coachStaffId)
        .toList();
    _coachStaffId = known.isNotEmpty
        ? known.first.id
        : (widget.staff.isEmpty ? null : widget.staff.first.id);

    final startTenant = TenantClock.toTenant(widget.visit.startAt);
    final endTenant = TenantClock.toTenant(widget.visit.endAt);
    _startLocal = DateTime(
      startTenant.year,
      startTenant.month,
      startTenant.day,
      startTenant.hour,
      startTenant.minute,
    );
    _endLocal = DateTime(
      endTenant.year,
      endTenant.month,
      endTenant.day,
      endTenant.hour,
      endTenant.minute,
    );
  }

  String _staffLabel(StaffResponse staff) =>
      '${staff.firstName} ${staff.lastName}'.trim();

  Future<void> _pickStart() async {
    final now = TenantClock.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _startLocal,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startLocal),
    );
    if (time == null || !mounted) return;

    final duration = _endLocal.difference(_startLocal);
    final start =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      _startLocal = start;
      _endLocal = start.add(
        duration.inMinutes > 0 ? duration : const Duration(hours: 1),
      );
    });
  }

  Future<void> _pickEnd() async {
    final now = TenantClock.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _endLocal,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_endLocal),
    );
    if (time == null || !mounted) return;

    setState(() {
      _endLocal =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _submit() async {
    if (_coachStaffId == null) return;

    if (!_endLocal.isAfter(_startLocal)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End must be after start.')),
      );
      return;
    }

    if (!TenantClock.toUtc(_startLocal).isAfter(DateTime.now().toUtc())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick a start in the future.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final response = await _visitsApi.reschedule(
        widget.visit.id,
        RescheduleVisitRequest(
          coachStaffId: _coachStaffId!,
          startAt: TenantClock.toUtc(_startLocal),
          endAt: TenantClock.toUtc(_endLocal),
        ),
      );

      if (!mounted) return;
      widget.onRescheduled?.call(response);
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

    if (widget.staff.isEmpty) {
      return Text(
        'Add staff before assigning a coach to a visit.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${widget.visit.memberName} · ${widget.visit.serviceName}\n'
          'Now: ${formatLocalDateTime(widget.visit.startAt)}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
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
          child: Text('Start: ${formatLocalDateTime(_startLocal)}'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: _isSubmitting ? null : _pickEnd,
          child: Text('End: ${formatLocalDateTime(_endLocal)}'),
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
              : const Text('Reschedule visit'),
        ),
      ],
    );
  }
}
