import 'package:fitcore_client/core/api/api_exception.dart';
import 'package:fitcore_client/core/time/tenant_clock.dart';
import 'package:fitcore_client/features/tenant/memberships/api/memberships_api.dart';
import 'package:fitcore_client/features/tenant/memberships/models/membership_response.dart';
import 'package:fitcore_client/features/tenant/staff/api/staff_api.dart';
import 'package:fitcore_client/features/tenant/staff/models/staff_response.dart';
import 'package:fitcore_client/features/tenant/visits/api/visits_api.dart';
import 'package:fitcore_client/features/tenant/visits/models/resolve_visit_request.dart';
import 'package:fitcore_client/features/tenant/visits/models/visit_resolve_outcome.dart';
import 'package:fitcore_client/features/tenant/visits/models/visit_response.dart';
import 'package:fitcore_client/features/tenant/visits/models/void_visit_request.dart';
import 'package:fitcore_client/features/tenant/visits/visit_calendar_range.dart';
import 'package:flutter/foundation.dart';

class VisitsController extends ChangeNotifier {
  VisitsController({
    VisitsApi? visitsApi,
    MembershipsApi? membershipsApi,
    StaffApi? staffApi,
  })  : _visitsApi = visitsApi ?? VisitsApi(),
        _membershipsApi = membershipsApi ?? MembershipsApi(),
        _staffApi = staffApi ?? StaffApi();

  final VisitsApi _visitsApi;
  final MembershipsApi _membershipsApi;
  final StaffApi _staffApi;
  int _epoch = 0;

  DateTime? _rangeFrom;
  DateTime? _rangeTo;

  VisitsApi get visitsApi => _visitsApi;

  List<VisitResponse> visits = const [];
  List<MembershipResponse> memberships = const [];
  List<StaffResponse> staff = const [];
  bool isLoading = false;
  String? error;

  List<MembershipResponse> get schedulableMemberships => memberships
      .where((m) => m.status.trim().toLowerCase() == 'active')
      .toList();

  /// Loads roster data and visits for [day] (local calendar day → UTC query).
  Future<void> load({DateTime? day}) async {
    final gen = ++_epoch;
    isLoading = true;
    error = null;
    notifyListeners();

    final range = VisitCalendarRange.day(day ?? TenantClock.now());
    _rangeFrom = range.from;
    _rangeTo = range.to;

    try {
      final results = await Future.wait([
        _visitsApi.list(from: range.from, to: range.to),
        _membershipsApi.list(),
        _staffApi.list(),
      ]);
      if (gen != _epoch) return;
      visits = results[0] as List<VisitResponse>;
      memberships = results[1] as List<MembershipResponse>;
      staff = results[2] as List<StaffResponse>;
    } on ApiException catch (e) {
      if (gen != _epoch) return;
      error = e.message;
    } finally {
      if (gen == _epoch) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  /// Reloads visits for an arbitrary local `[from, to)` window (API sends UTC).
  Future<void> loadVisitsForRange(DateTime from, DateTime to) async {
    final gen = ++_epoch;
    error = null;
    _rangeFrom = from;
    _rangeTo = to;
    notifyListeners();

    try {
      final listed = await _visitsApi.list(from: from, to: to);
      if (gen != _epoch) return;
      visits = listed;
    } on ApiException catch (e) {
      if (gen != _epoch) return;
      error = e.message;
    } finally {
      if (gen == _epoch) notifyListeners();
    }
  }

  /// Reloads only visits for a local calendar day.
  Future<void> loadVisitsForDay(DateTime day) {
    final range = VisitCalendarRange.day(day);
    return loadVisitsForRange(range.from, range.to);
  }

  /// Reloads the last successful visits window (fallback: today).
  Future<void> reloadCurrentVisits() {
    final from = _rangeFrom;
    final to = _rangeTo;
    if (from != null && to != null) {
      return loadVisitsForRange(from, to);
    }
    return loadVisitsForDay(TenantClock.now());
  }

  /// Burns the reserved credit and closes the visit as Completed or NoShow.
  Future<String?> resolveVisit(
    VisitResponse visit,
    VisitResolveOutcome outcome,
  ) async {
    try {
      await _visitsApi.resolve(
        visit.id,
        ResolveVisitRequest(
          outcome: outcome,
          occurredAt: DateTime.now().toUtc(),
        ),
      );
      await reloadCurrentVisits();
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  Future<String?> voidVisit(VisitResponse visit, VoidVisitRequest request) async {
    try {
      await _visitsApi.voidVisit(visit.id, request);
      await reloadCurrentVisits();
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }
}
