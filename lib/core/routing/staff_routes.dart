import 'package:fitcore_client/core/routing/staff_paths.dart';
import 'package:fitcore_client/features/staff/auth/activate/staff_activate_page.dart';
import 'package:fitcore_client/features/staff/auth/login/staff_login_page.dart';
import 'package:fitcore_client/features/staff/workspace/staff_dashboard_page.dart';
import 'package:go_router/go_router.dart';

final List<RouteBase> staffRoutes = [
  GoRoute(
    path: StaffPaths.login,
    builder: (context, state) => const StaffLoginPage(),
  ),
  GoRoute(
    path: StaffPaths.activate,
    builder: (context, state) {
      final token = state.uri.queryParameters['token'];
      return StaffActivatePage(token: token);
    },
  ),
  GoRoute(
    path: StaffPaths.home,
    builder: (context, state) => const StaffDashboardPage(),
  ),
];
