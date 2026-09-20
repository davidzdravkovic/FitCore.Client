import 'package:fitcore_client/core/auth/local_session_store.dart';
import 'package:fitcore_client/core/routing/app_router.dart';
import 'package:fitcore_client/core/theme/fitcore_theme.dart';
import 'package:fitcore_client/core/time/time_zones.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:timezone/timezone.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  TimeZones.initialize();
  final deviceTz = await TimeZones.detectLocal();
  if (deviceTz != null) {
    tz.setLocalLocation(tz.getLocation(deviceTz));
  }
  await LocalSessionStore.hydrate();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FitCoreTheme.dark();

    return MaterialApp.router(
      title: 'FitCore',
      theme: theme,
      darkTheme: theme,
      themeMode: ThemeMode.dark,
      routerConfig: appRouter,
    );
  }
}
