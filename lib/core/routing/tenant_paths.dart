/// Route path catalog for the tenant portal (keep with tenant when splitting apps).
abstract final class TenantPaths {
  static const root = '/tenant';
  static const login = '/tenant/login';
  static const registry = '/tenant/registry';
  static const home = '/tenant';
  static const members = '/tenant/members';
  static const memberships = '/tenant/memberships';
  static const schedule = '/tenant/schedule';
  static const checkIns = '/tenant/check-ins';
  static const staff = '/tenant/staff';
  static const billing = '/tenant/billing';
  static const settings = '/tenant/settings';

  static bool matches(String path) =>
      path == root || path.startsWith('$root/');

  static bool isAuthRoute(String path) => path == login || path == registry;
}
