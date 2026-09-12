import 'package:fitcore_client/core/api/api_exception.dart';
import 'package:fitcore_client/features/tenant/members/api/members_api.dart';
import 'package:fitcore_client/features/tenant/members/api/members_models.dart';
import 'package:flutter/foundation.dart';

/// Feature orchestration: widgets stay thin; HTTP stays in [MembersApi].
class MembersController extends ChangeNotifier {
  MembersController({MembersApi? membersApi})
      : _membersApi = membersApi ?? MembersApi();

  final MembersApi _membersApi;

  MembersApi get membersApi => _membersApi;

  List<Member> members = const [];
  bool isLoading = false;
  String? error;

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      members = await _membersApi.list();
      error = null;
    } on ApiException catch (e) {
      error = e.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> invite(Member member) async {
    try {
      await _membersApi.invite(member.id);
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  Future<String?> delete(Member member) async {
    try {
      await _membersApi.delete(member.id);
      await load();
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }
}
