import 'package:fitcore_client/core/theme/fitcore_tokens.dart';
import 'package:fitcore_client/core/time/tenant_clock.dart';
import 'package:flutter/material.dart';

/// Shared presentation rules for visits so the board, the coach calendar and
/// the legend can never drift apart.
enum VisitTone { scheduled, completed, noShow, cancelled, voided, unknown }

const visitStatusOrder = <VisitTone>[
  VisitTone.scheduled,
  VisitTone.completed,
  VisitTone.noShow,
  VisitTone.cancelled,
  VisitTone.voided,
];

VisitTone visitToneOf(String status) {
  return switch (status.trim().toLowerCase()) {
    'scheduled' => VisitTone.scheduled,
    'completed' => VisitTone.completed,
    'noshow' => VisitTone.noShow,
    'cancelled' => VisitTone.cancelled,
    'voided' => VisitTone.voided,
    _ => VisitTone.unknown,
  };
}

extension VisitToneStyle on VisitTone {
  String get label => switch (this) {
    VisitTone.scheduled => 'Scheduled',
    VisitTone.completed => 'Completed',
    VisitTone.noShow => 'No-show',
    VisitTone.cancelled => 'Cancelled',
    VisitTone.voided => 'Voided',
    VisitTone.unknown => 'Other',
  };

  /// Status palette lives in the design tokens so the board, the coach
  /// calendar and the legend all read the same values.
  Color get color => switch (this) {
    VisitTone.scheduled => FitCoreTokens.dark.visitScheduled,
    VisitTone.completed => FitCoreTokens.dark.visitCompleted,
    VisitTone.noShow => FitCoreTokens.dark.visitNoShow,
    VisitTone.cancelled => FitCoreTokens.dark.visitCancelled,
    VisitTone.voided => FitCoreTokens.dark.visitVoided,
    VisitTone.unknown => FitCoreTokens.dark.stateNeutral,
  };

  /// Resolved-away visits stay readable but visibly retired.
  bool get isRetired => this == VisitTone.cancelled || this == VisitTone.voided;
}

Color visitStatusColor(String status) => visitToneOf(status).color;

String formatClock(DateTime value) {
  final local = TenantClock.toTenant(value);
  final hh = local.hour.toString().padLeft(2, '0');
  final mm = local.minute.toString().padLeft(2, '0');
  return '$hh:$mm';
}

/// Formats an instant in the tenant timezone (not device local).
String formatLocalDateTime(DateTime value) {
  final local = TenantClock.toTenant(value);
  final y = local.year.toString().padLeft(4, '0');
  final m = local.month.toString().padLeft(2, '0');
  final d = local.day.toString().padLeft(2, '0');
  final hh = local.hour.toString().padLeft(2, '0');
  final mm = local.minute.toString().padLeft(2, '0');
  return '$y-$m-$d $hh:$mm';
}

String formatHourLabel(int hour) {
  final suffix = hour < 12 ? 'AM' : 'PM';
  final display = hour % 12 == 0 ? 12 : hour % 12;
  return '$display $suffix';
}

String formatDayHeadline(DateTime day, {bool compact = false}) {
  const weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  const shortWeekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const shortMonths = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  if (compact) {
    return '${shortWeekdays[day.weekday - 1]} ${day.day} ${shortMonths[day.month - 1]}';
  }
  return '${weekdays[day.weekday - 1]}, ${day.day} ${months[day.month - 1]} ${day.year}';
}

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
