import 'package:fitcore_client/core/routing/member_paths.dart';
import 'package:fitcore_client/features/member/auth/activate/member_activate_page.dart';
import 'package:fitcore_client/features/member/auth/login/member_login_page.dart';
import 'package:fitcore_client/features/member/workspace/member_dashboard_page.dart';
import 'package:go_router/go_router.dart';

final List<RouteBase> memberRoutes = [
  GoRoute(
    path: MemberPaths.login,
    builder: (context, state) => const MemberLoginPage(),
  ),
  GoRoute(
    path: MemberPaths.activate,
    builder: (context, state) {
      final token = state.uri.queryParameters['token'];
      return MemberActivatePage(token: token);
    },
  ),
  GoRoute(
    path: MemberPaths.home,
    builder: (context, state) => const MemberDashboardPage(),
  ),
];
