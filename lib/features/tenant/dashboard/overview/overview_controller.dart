import 'package:fitcore_client/core/api/api_exception.dart';
import 'package:fitcore_client/core/time/tenant_clock.dart';
import 'package:fitcore_client/features/tenant/members/api/members_api.dart';
import 'package:fitcore_client/features/tenant/members/models/member_response.dart';
import 'package:fitcore_client/features/tenant/members/models/member_status.dart';
import 'package:fitcore_client/features/tenant/memberships/api/memberships_api.dart';
import 'package:fitcore_client/features/tenant/memberships/models/membership_response.dart';
import 'package:fitcore_client/features/tenant/visits/api/visits_api.dart';
import 'package:fitcore_client/features/tenant/visits/models/visit_response.dart';
import 'package:fitcore_client/features/tenant/visits/visit_calendar_range.dart';
import 'package:flutter/foundation.dart';

class OverviewSnapshot {
  const OverviewSnapshot({
    required this.activeMembers,
    required this.activeMemberships,
    required this.visitsToday,
  });

  final int activeMembers;
  final int activeMemberships;
  final int visitsToday;
}

class OverviewController extends ChangeNotifier {
  OverviewController({
    MembersApi? membersApi,
    MembershipsApi? membershipsApi,
    VisitsApi? visitsApi,
  })  : _membersApi = membersApi ?? MembersApi(),
        _membershipsApi = membershipsApi ?? MembershipsApi(),
        _visitsApi = visitsApi ?? VisitsApi();

  final MembersApi _membersApi;
  final MembershipsApi _membershipsApi;
  final VisitsApi _visitsApi;

  OverviewSnapshot? snapshot;
  bool isLoading = false;
  String? error;

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final day = VisitCalendarRange.day(TenantClock.now());
      final results = await Future.wait([
        _membersApi.list(),
        _membershipsApi.list(),
        _visitsApi.list(from: day.from, to: day.to),
      ]);

      final members = results[0] as List<MemberResponse>;
      final memberships = results[1] as List<MembershipResponse>;
      final visits = results[2] as List<VisitResponse>;

      snapshot = OverviewSnapshot(
        activeMembers:
            members.where((m) => m.status == MemberStatus.active).length,
        activeMemberships: memberships
            .where((m) => m.status.trim().toLowerCase() == 'active')
            .length,
        visitsToday: visits.length,
      );
    } on ApiException catch (e) {
      error = e.message;
      snapshot = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
