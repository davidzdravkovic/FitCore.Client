import 'package:fitcore_client/core/api/api_exception.dart';
import 'package:fitcore_client/core/theme/fitcore_tokens.dart';
import 'package:fitcore_client/core/widgets/fit_status_chip.dart';
import 'package:fitcore_client/features/tenant/members/api/members_api.dart';
import 'package:fitcore_client/features/tenant/members/models/member_response.dart';
import 'package:fitcore_client/features/tenant/memberships/models/membership_response.dart';
import 'package:fitcore_client/features/tenant/visits/models/visit_response.dart';
import 'package:fitcore_client/features/tenant/visits/widgets/visit_display.dart';
import 'package:flutter/material.dart';

/// Opens visit member detail: bottom sheet on phone, dialog on desktop.
///
/// Returns an optional action key when the user picks a visit action
/// (`complete`, `noShow`, `reschedule`, `void`). Close / backdrop → null.
Future<String?> showVisitMemberSheet({
  required BuildContext context,
  required VisitResponse visit,
  required MembershipResponse? membership,
  required MembersApi membersApi,
  bool showVisitActions = true,
}) {
  final phone =
      MediaQuery.sizeOf(context).width < FitCoreBreakpoints.compact;

  Widget body({required bool sheetChrome}) {
    return _VisitMemberSheetBody(
      visit: visit,
      membership: membership,
      membersApi: membersApi,
      showVisitActions: showVisitActions,
      sheetChrome: sheetChrome,
    );
  }

  if (phone) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => body(sheetChrome: true),
    );
  }

  return showDialog<String>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        contentPadding: const EdgeInsets.fromLTRB(
          FitCoreSpace.x6,
          FitCoreSpace.x5,
          FitCoreSpace.x6,
          FitCoreSpace.x4,
        ),
        content: SizedBox(
          width: 440,
          child: body(sheetChrome: false),
        ),
      );
    },
  );
}

class _VisitMemberSheetBody extends StatefulWidget {
  const _VisitMemberSheetBody({
    required this.visit,
    required this.membership,
    required this.membersApi,
    required this.showVisitActions,
    this.sheetChrome = true,
  });

  final VisitResponse visit;
  final MembershipResponse? membership;
  final MembersApi membersApi;
  final bool showVisitActions;

  /// Phone bottom sheet padding / SafeArea. Off when embedded in a dialog.
  final bool sheetChrome;

  @override
  State<_VisitMemberSheetBody> createState() => _VisitMemberSheetBodyState();
}

class _VisitMemberSheetBodyState extends State<_VisitMemberSheetBody> {
  MemberResponse? _member;
  String? _loadError;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMember();
  }

  Future<void> _loadMember() async {
    try {
      final list = await widget.membersApi.list();
      if (!mounted) return;
      MemberResponse? found;
      for (final m in list) {
        if (m.id == widget.visit.memberId) {
          found = m;
          break;
        }
      }
      setState(() {
        _member = found;
        _loading = false;
        _loadError = found == null ? 'Member contact not found.' : null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.fc;
    final visit = widget.visit;
    final membership = widget.membership;
    final canResolve = visit.canResolveNow;
    const notStartedYet = 'Available once the visit has started';

    final name = _member == null
        ? visit.memberName
        : '${_member!.firstName} ${_member!.lastName}'.trim();

    final content = SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name.isEmpty ? 'Member' : name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (_member != null)
                    FitStatusChip(
                      label: _member!.status.label,
                      tone: FitTone.neutral,
                      dense: true,
                    ),
                ],
              ),
              const SizedBox(height: FitCoreSpace.x2),
              Text(
                '${visit.serviceName} · ${formatLocalDateTime(visit.startAt)} – '
                '${formatClock(visit.endAt)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: t.textSecondary,
                ),
              ),
              Text(
                'Coach ${visit.coachName} · ${visit.status}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: t.textMuted,
                ),
              ),
              if (widget.showVisitActions && visit.isVoidable) ...[
                const SizedBox(height: FitCoreSpace.x4),
                Text(
                  'Visit actions',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: t.textMuted,
                  ),
                ),
                const SizedBox(height: FitCoreSpace.x1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  enabled: canResolve,
                  leading: const Icon(Icons.check_circle_outline),
                  title: const Text('Complete'),
                  subtitle: Text(
                    canResolve
                        ? 'Burns the reserved credit'
                        : notStartedYet,
                  ),
                  onTap: canResolve
                      ? () => Navigator.of(context).pop('complete')
                      : null,
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  enabled: canResolve,
                  leading: const Icon(Icons.person_off_outlined),
                  title: const Text('No-show'),
                  subtitle: Text(
                    canResolve
                        ? 'Burns the reserved credit'
                        : notStartedYet,
                  ),
                  onTap: canResolve
                      ? () => Navigator.of(context).pop('noShow')
                      : null,
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event_repeat_outlined),
                  title: const Text('Reschedule'),
                  subtitle: const Text('Move to another slot or coach'),
                  onTap: () => Navigator.of(context).pop('reschedule'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.delete_outline),
                  title: const Text('Void'),
                  subtitle: const Text('Undo a scheduling mistake'),
                  onTap: () => Navigator.of(context).pop('void'),
                ),
              ],
              const SizedBox(height: FitCoreSpace.x4),
              Text(
                'Contact',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: t.textMuted,
                ),
              ),
              const SizedBox(height: FitCoreSpace.x2),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: FitCoreSpace.x3),
                  child: Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              else if (_loadError != null && _member == null)
                Text(
                  _loadError!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: t.stateNegative,
                  ),
                )
              else ...[
                _InfoRow(
                  icon: Icons.email_outlined,
                  label: _member?.email?.isNotEmpty == true
                      ? _member!.email!
                      : 'No email',
                ),
                const SizedBox(height: FitCoreSpace.x2),
                _InfoRow(
                  icon: Icons.phone_outlined,
                  label: _member?.phone?.isNotEmpty == true
                      ? _member!.phone!
                      : 'No phone',
                ),
              ],
              const SizedBox(height: FitCoreSpace.x4),
              Text(
                'Membership for this visit',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: t.textMuted,
                ),
              ),
              const SizedBox(height: FitCoreSpace.x2),
              if (membership == null)
                Text(
                  'Membership details unavailable.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: t.textSecondary,
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(FitCoreSpace.x3),
                  decoration: BoxDecoration(
                    color: t.elevated,
                    borderRadius: BorderRadius.circular(FitCoreRadius.md),
                    border: Border.all(color: t.borderSubtle),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              membership.planName,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          FitStatusChip(
                            label: membership.status,
                            tone: FitTone.neutral,
                            dense: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: FitCoreSpace.x3),
                      Text(
                        '${membership.sessionsAvailable} available',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: FitCoreSpace.x1),
                      Text(
                        '${membership.sessionsReserved} reserved · '
                        '${membership.sessionsBurned} used · '
                        '${membership.sessionTotal} total',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: t.textSecondary,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: FitCoreSpace.x2),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
        ],
      ),
    );

    if (!widget.sheetChrome) return content;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          FitCoreSpace.x4,
          0,
          FitCoreSpace.x4,
          FitCoreSpace.x4 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: content,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = context.fc;
    return Row(
      children: [
        Icon(icon, size: 18, color: t.textSecondary),
        const SizedBox(width: FitCoreSpace.x2),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
