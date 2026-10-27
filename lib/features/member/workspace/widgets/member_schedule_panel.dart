import 'package:fitcore_client/core/theme/fitcore_tokens.dart';
import 'package:fitcore_client/core/time/tenant_clock.dart';
import 'package:fitcore_client/core/widgets/fit_panel_states.dart';
import 'package:fitcore_client/features/member/workspace/member_home_controller.dart';
import 'package:fitcore_client/features/tenant/dashboard/helpers/dashboard_layout.dart';
import 'package:fitcore_client/features/tenant/visits/visit_calendar_range.dart';
import 'package:fitcore_client/features/tenant/visits/widgets/coach_calendar.dart';
import 'package:fitcore_client/features/tenant/visits/widgets/visit_display.dart';
import 'package:flutter/material.dart';

class MemberSchedulePanel extends StatefulWidget {
  const MemberSchedulePanel({super.key, this.controller});

  final MemberHomeController? controller;

  @override
  State<MemberSchedulePanel> createState() => _MemberSchedulePanelState();
}

class _MemberSchedulePanelState extends State<MemberSchedulePanel> {
  late final MemberHomeController _controller =
      widget.controller ?? MemberHomeController();
  late final bool _ownsController = widget.controller == null;

  DateTime _day = _today();

  static DateTime _today() {
    final now = TenantClock.now();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  void initState() {
    super.initState();
    _controller.load(day: _day);
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  Future<void> _onCalendarRange(
    VisitCalendarRange range,
    DateTime focusDay,
  ) async {
    setState(() => _day = focusDay);
    await _controller.loadVisitsForRange(range.from, range.to);
  }

  @override
  Widget build(BuildContext context) {
    final phone =
        MediaQuery.sizeOf(context).width < FitCoreBreakpoints.compact;
    final pad = phone ? FitCoreSpace.x3 : DashboardLayout.pagePadding;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        if (_controller.isLoading && _controller.profile == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_controller.error != null &&
            _controller.visits.isEmpty &&
            _controller.profile == null) {
          return FitErrorState(
            message: _controller.error!,
            onRetry: () => _controller.load(day: _day),
          );
        }

        return Padding(
          padding: EdgeInsets.fromLTRB(pad, FitCoreSpace.x2, pad, pad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!phone)
                Padding(
                  padding: const EdgeInsets.only(bottom: FitCoreSpace.x3),
                  child: Text(
                    'My schedule',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              if (_controller.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: FitCoreSpace.x2),
                  child: FitErrorBanner(
                    message: _controller.error!,
                    onRetry: () => _controller.loadVisitsForRange(
                      VisitCalendarRange.week(_day).from,
                      VisitCalendarRange.week(_day).to,
                    ),
                  ),
                ),
              Expanded(
                child: CoachCalendar(
                  visits: _controller.visits,
                  initialDay: _day,
                  onVisitTap: (visit) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${visit.serviceName} · ${visit.coachName} · '
                          '${formatLocalDateTime(visit.startAt)} · ${visit.status}',
                        ),
                      ),
                    );
                  },
                  onRangeChanged: _onCalendarRange,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
