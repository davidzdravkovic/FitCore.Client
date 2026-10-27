import 'package:fitcore_client/core/api/api_exception.dart';
import 'package:fitcore_client/core/time/tenant_clock.dart';
import 'package:fitcore_client/features/member/workspace/api/member_me_api.dart';
import 'package:fitcore_client/features/member/workspace/models/member_profile_response.dart';
import 'package:fitcore_client/features/tenant/visits/api/visits_api.dart';
import 'package:fitcore_client/features/tenant/visits/models/visit_response.dart';
import 'package:fitcore_client/features/tenant/visits/visit_calendar_range.dart';
import 'package:flutter/foundation.dart';

class MemberHomeController extends ChangeNotifier {
  MemberHomeController({
    MemberMeApi? memberMeApi,
    VisitsApi? visitsApi,
  })  : _memberMeApi = memberMeApi ?? MemberMeApi(),
        _visitsApi =
            visitsApi ?? VisitsApi(basePath: '/api/members/me/visits');

  final MemberMeApi _memberMeApi;
  final VisitsApi _visitsApi;
  int _epoch = 0;

  MemberProfileResponse? profile;
  List<VisitResponse> visits = const [];
  bool isLoading = false;
  String? error;

  Future<void> load({DateTime? day}) async {
    final gen = ++_epoch;
    isLoading = true;
    error = null;
    notifyListeners();

    final range = VisitCalendarRange.week(day ?? TenantClock.now());

    try {
      final results = await Future.wait([
        _memberMeApi.get(),
        _visitsApi.list(from: range.from, to: range.to),
      ]);
      if (gen != _epoch) return;
      profile = results[0] as MemberProfileResponse;
      visits = results[1] as List<VisitResponse>;
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
}
