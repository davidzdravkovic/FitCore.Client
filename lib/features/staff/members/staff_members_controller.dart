import 'package:fitcore_client/core/api/api_exception.dart';
import 'package:fitcore_client/features/tenant/members/api/members_api.dart';
import 'package:fitcore_client/features/tenant/members/models/member_response.dart';
import 'package:flutter/foundation.dart';

class StaffMembersController extends ChangeNotifier {
  StaffMembersController({MembersApi? membersApi})
      : _membersApi =
            membersApi ?? MembersApi(basePath: '/api/staff/me/members');

  final MembersApi _membersApi;
  int _epoch = 0;

  List<MemberResponse> members = const [];
  bool isLoading = false;
  String? error;

  Future<void> load() async {
    final gen = ++_epoch;
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final list = await _membersApi.list();
      if (gen != _epoch) return;
      members = list;
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
}
