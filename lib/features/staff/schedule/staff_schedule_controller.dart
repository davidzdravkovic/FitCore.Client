import 'package:fitcore_client/core/api/api_exception.dart';
import 'package:fitcore_client/core/time/tenant_clock.dart';
import 'package:fitcore_client/features/staff/schedule/api/staff_me_api.dart';
import 'package:fitcore_client/features/tenant/memberships/api/memberships_api.dart';
import 'package:fitcore_client/features/tenant/memberships/models/membership_response.dart';
import 'package:fitcore_client/features/tenant/staff/models/staff_response.dart';
import 'package:fitcore_client/features/tenant/visits/api/visits_api.dart';
import 'package:fitcore_client/features/tenant/visits/models/resolve_visit_request.dart';
import 'package:fitcore_client/features/tenant/visits/models/visit_resolve_outcome.dart';
import 'package:fitcore_client/features/tenant/visits/models/visit_response.dart';
import 'package:fitcore_client/features/tenant/visits/models/void_visit_request.dart';
import 'package:fitcore_client/features/tenant/visits/visit_calendar_range.dart';
import 'package:flutter/foundation.dart';

class StaffScheduleController extends ChangeNotifier {
  StaffScheduleController({
    StaffMeApi? staffMeApi,
    VisitsApi? visitsApi,
    MembershipsApi? membershipsApi,
  })  : _staffMeApi = staffMeApi ?? StaffMeApi(),
        _visitsApi = visitsApi ??
            VisitsApi(basePath: '/api/staff/me/visits'),
        _membershipsApi = membershipsApi ??
            MembershipsApi(basePath: '/api/staff/me/memberships');

  final StaffMeApi _staffMeApi;
  final VisitsApi _visitsApi;
  final MembershipsApi _membershipsApi;
  int _epoch = 0;

  DateTime? _rangeFrom;
  DateTime? _rangeTo;

  VisitsApi get visitsApi => _visitsApi;

  StaffResponse? me;
  List<VisitResponse> visits = const [];
  List<MembershipResponse> memberships = const [];
  bool isLoading = false;
  String? error;

  List<MembershipResponse> get schedulableMemberships => memberships
      .where((m) => m.status.trim().toLowerCase() == 'active')
      .toList();

  List<StaffResponse> get staff => me == null ? const [] : [me!];

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
        _staffMeApi.get(),
        _visitsApi.list(from: range.from, to: range.to),
        _membershipsApi.list(),
      ]);
      if (gen != _epoch) return;
      me = results[0] as StaffResponse;
      visits = results[1] as List<VisitResponse>;
      memberships = results[2] as List<MembershipResponse>;
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

  Future<void> loadVisitsForDay(DateTime day) {
    final range = VisitCalendarRange.day(day);
    return loadVisitsForRange(range.from, range.to);
  }

  Future<void> reloadCurrentVisits() {
    final from = _rangeFrom;
    final to = _rangeTo;
    if (from != null && to != null) {
      return loadVisitsForRange(from, to);
    }
    return loadVisitsForDay(TenantClock.now());
  }

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
