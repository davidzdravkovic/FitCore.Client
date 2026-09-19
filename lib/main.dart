import 'package:fitcore_client/core/auth/local_session_store.dart';
import 'package:fitcore_client/core/routing/app_router.dart';
import 'package:fitcore_client/core/time/time_zones.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final fontFamily = GoogleFonts.plusJakartaSans().fontFamily;

    return MaterialApp.router(
      title: 'FitCore',
      theme: FlexThemeData.light(
        scheme: FlexScheme.tealM3,
        fontFamily: fontFamily,
        subThemesData: const FlexSubThemesData(
          inputDecoratorBorderType: FlexInputBorderType.outline,
          inputDecoratorIsFilled: true,
          filledButtonRadius: 12,
          elevatedButtonRadius: 12,
          outlinedButtonRadius: 12,
          cardRadius: 16,
          defaultRadius: 12,
          thinBorderWidth: 1,
        ),
      ),
      darkTheme: FlexThemeData.dark(
        scheme: FlexScheme.tealM3,
        fontFamily: fontFamily,
        darkIsTrueBlack: false,
        subThemesData: const FlexSubThemesData(
          inputDecoratorBorderType: FlexInputBorderType.outline,
          inputDecoratorIsFilled: true,
          filledButtonRadius: 12,
          elevatedButtonRadius: 12,
          outlinedButtonRadius: 12,
          cardRadius: 16,
          defaultRadius: 12,
          thinBorderWidth: 1,
        ),
      ),
      themeMode: ThemeMode.dark,
      routerConfig: appRouter,
    );
  }
}
