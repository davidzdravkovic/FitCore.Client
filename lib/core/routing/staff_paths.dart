/// Route path catalog for the staff portal (keep with staff when splitting apps).
abstract final class StaffPaths {
  static const root = '/staff';
  static const login = '/staff/login';
  static const activate = '/staff/activate';
  static const home = '/staff';

  static bool matches(String path) =>
      path == root || path.startsWith('$root/');

  static bool isAuthRoute(String path) => path == login || path == activate;
}
