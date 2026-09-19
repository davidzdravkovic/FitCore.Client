import 'package:fitcore_client/core/api/api_exception.dart';
import 'package:fitcore_client/core/time/tenant_clock.dart';
import 'package:fitcore_client/features/tenant/memberships/models/memberships_models.dart';
import 'package:fitcore_client/features/tenant/staff/models/staff_models.dart';
import 'package:fitcore_client/features/tenant/visits/api/visits_api.dart';
import 'package:fitcore_client/features/tenant/visits/models/visits_models.dart';
import 'package:fitcore_client/features/tenant/visits/widgets/visit_display.dart';
import 'package:flutter/material.dart';

/// Backfills a visit that happened but was never scheduled. Start must be past.
class RecordVisitForm extends StatefulWidget {
  const RecordVisitForm({
    super.key,
    required this.memberships,
    required this.staff,
    this.visitsApi,
    this.onRecorded,
    this.initialCoachStaffId,
    this.initialStart,
  });

  final List<MembershipResponse> memberships;
  final List<StaffResponse> staff;
  final VisitsApi? visitsApi;
  final ValueChanged<VisitResponse>? onRecorded;

  /// Prefill when opened from an empty past slot on the day board.
  final String? initialCoachStaffId;
  final DateTime? initialStart;

  @override
  State<RecordVisitForm> createState() => _RecordVisitFormState();
}

class _RecordVisitFormState extends State<RecordVisitForm> {
  late final VisitsApi _visitsApi = widget.visitsApi ?? VisitsApi();

  String? _membershipId;
  String? _coachStaffId;
  late DateTime _startLocal;
  late DateTime _endLocal;
  VisitResolveOutcome _outcome = VisitResolveOutcome.completed;
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
    final fallback = DateTime(now.year, now.month, now.day, now.hour)
        .subtract(const Duration(hours: 1));
    final start = widget.initialStart ?? fallback;
    // Record requires a past start; clamp "now" slots back one hour.
    _startLocal =
        TenantClock.toUtc(start).isBefore(DateTime.now().toUtc())
            ? start
            : fallback;
    _endLocal = _startLocal.add(const Duration(hours: 1));
  }

  String _membershipLabel(MembershipResponse membership) {
    final entitlement = '${membership.sessionsAvailable} left';
    return '${membership.memberName} · ${membership.planName} ($entitlement)';
  }

  String _staffLabel(StaffResponse staff) =>
      '${staff.firstName} ${staff.lastName}'.trim();

  Future<void> _pickStart() async {
    final now = TenantClock.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _startLocal,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now,
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
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 1)),
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
    if (_membershipId == null || _coachStaffId == null) return;

    if (!_endLocal.isAfter(_startLocal)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End must be after start.')),
      );
      return;
    }

    if (!TenantClock.toUtc(_startLocal).isBefore(DateTime.now().toUtc())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recorded visits must start in the past.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final response = await _visitsApi.record(
        RecordVisitRequest(
          membershipId: _membershipId!,
          coachStaffId: _coachStaffId!,
          startAt: TenantClock.toUtc(_startLocal),
          endAt: TenantClock.toUtc(_endLocal),
          outcome: _outcome,
        ),
      );

      if (!mounted) return;
      widget.onRecorded?.call(response);
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
            ? 'Assign an active membership before recording a visit.'
            : 'Add staff before assigning a coach to a visit.',
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
          'Backfills a past visit and burns one credit.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
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
        SegmentedButton<VisitResolveOutcome>(
          segments: [
            for (final outcome in VisitResolveOutcome.values)
              ButtonSegment(value: outcome, label: Text(outcome.label)),
          ],
          selected: {_outcome},
          onSelectionChanged: _isSubmitting
              ? null
              : (selection) => setState(() => _outcome = selection.first),
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
              : const Text('Record visit'),
        ),
      ],
    );
  }
}
