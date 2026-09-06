import 'package:fitcore_client/core/router/app_router.dart';
import 'package:fitcore_client/core/time/time_zones.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  usePathUrlStrategy();
  TimeZones.initialize();
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
          filledButtonRadius: 10,
        ),
      ),
      darkTheme: FlexThemeData.dark(
        scheme: FlexScheme.tealM3,
        fontFamily: fontFamily,
        subThemesData: const FlexSubThemesData(
          inputDecoratorBorderType: FlexInputBorderType.outline,
          inputDecoratorIsFilled: true,
          filledButtonRadius: 10,
        ),
      ),
      themeMode: ThemeMode.dark,
      routerConfig: appRouter,
    );
  }
}
