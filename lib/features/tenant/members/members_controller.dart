import 'package:fitcore_client/core/api/api_exception.dart';
import 'package:fitcore_client/features/tenant/members/api/members_api.dart';
import 'package:fitcore_client/features/tenant/members/models/members_models.dart';
import 'package:flutter/foundation.dart';

/// Feature orchestration: widgets stay thin; HTTP stays in [MembersApi].
class MembersController extends ChangeNotifier {
  MembersController({MembersApi? membersApi})
      : _membersApi = membersApi ?? MembersApi();

  final MembersApi _membersApi;
  int _epoch = 0;


  MembersApi get membersApi => _membersApi;

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

  Future<String?> invite(MemberResponse member) async {
    try {
      await _membersApi.invite(member.id);
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  Future<String?> delete(MemberResponse member) async {
    try {
      await _membersApi.delete(member.id);
      await load();
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }
}
