import 'package:fitcore_client/core/api/api_exception.dart';
import 'package:fitcore_client/features/tenant/members/api/members_api.dart';
import 'package:fitcore_client/features/tenant/members/models/member_response.dart';
import 'package:fitcore_client/features/tenant/memberships/api/memberships_api.dart';
import 'package:fitcore_client/features/tenant/memberships/models/cancel_membership_request.dart';
import 'package:fitcore_client/features/tenant/memberships/models/membership_response.dart';
import 'package:fitcore_client/features/tenant/plans/api/plans_api.dart';
import 'package:fitcore_client/features/tenant/plans/models/plan_response.dart';
import 'package:flutter/foundation.dart';

class MembershipsController extends ChangeNotifier {
  MembershipsController({
    MembershipsApi? membershipsApi,
    MembersApi? membersApi,
    PlansApi? plansApi,
  })  : _membershipsApi = membershipsApi ?? MembershipsApi(),
        _membersApi = membersApi ?? MembersApi(),
        _plansApi = plansApi ?? PlansApi();

  final MembershipsApi _membershipsApi;
  final MembersApi _membersApi;
  final PlansApi _plansApi;
  int _epoch = 0;

  MembershipsApi get membershipsApi => _membershipsApi;

  List<MembershipResponse> memberships = const [];
  List<MemberResponse> members = const [];
  List<PlanResponse> plans = const [];
  bool isLoading = false;
  String? error;

  List<PlanResponse> get activePlans =>
      plans.where((p) => p.isActive).toList();

  Future<void> load() async {
    final gen = ++_epoch;
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _membershipsApi.list(),
        _membersApi.list(),
        _plansApi.list(),
      ]);
      if (gen != _epoch) return;
      memberships = results[0] as List<MembershipResponse>;
      members = results[1] as List<MemberResponse>;
      plans = results[2] as List<PlanResponse>;
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

  Future<String?> cancel(
    MembershipResponse membership,
    CancelMembershipRequest request,
  ) async {
    try {
      await _membershipsApi.cancel(membership.id, request);
      await load();
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }
}
