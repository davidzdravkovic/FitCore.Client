import 'package:fitcore_client/features/staff/auth/activate/staff_activate_page.dart';
import 'package:fitcore_client/features/staff/auth/login/staff_login_page.dart';
import 'package:fitcore_client/features/staff/workspace/staff_dashboard_page.dart';
import 'package:go_router/go_router.dart';

final List<RouteBase> staffRoutes = [
  GoRoute(
    path: '/staff/login',
    builder: (context, state) => const StaffLoginPage(),
  ),
  GoRoute(
    path: '/staff/activate',
    builder: (context, state) {
      final token = state.uri.queryParameters['token'];
      return StaffActivatePage(token: token);
    },
  ),
  GoRoute(
    path: '/staff',
    builder: (context, state) => const StaffDashboardPage(),
  ),
];
