import 'package:arpicoiam/iam.dart';
import 'package:flutter/material.dart';
import 'package:locafy/locafy.dart';
import 'package:provider/provider.dart';

import 'app/app_route_observers.dart';
import 'app/app_routes.dart';
import 'app/route_paths.dart';
import 'app/theme/app_theme.dart';
import 'app/theme/app_theme_notifier.dart';
import 'config/app_config.dart';
import 'services/database/app_database.dart';
import 'services/storage/app_shared_prefs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Initialize IAM authentification
  await IAM.instance.initialize(
    authBaseUrl: AppConfig.authUrl,
    apiBaseUrl: AppConfig.serviceUrl,
    appInfo: AppConfig.info,
    developerInfo: AppConfig.developer,
  );

  /// Initialize Locafy
  await Locafy.instance.initialize();

  /// Initialize database
  await AppDatabase.instance.initialize();

  /// Initialize storage
  await AppSharedPrefs.instance.initialize();


  runApp(
    ChangeNotifierProvider.value(
      value: AppThemeNotifier()..initialize(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Consumer<AppThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return IAMApp(
          initialRoute: RoutePaths.landing,
          theme: AppTheme.of(context).light,
          darkTheme: AppTheme.of(context).dark,
          themeMode: themeNotifier.themeMode,
          controller: IAMController(
            whenProfileSelected: (context, profile) => Navigator.of(
              context,
            ).pushNamedAndRemoveUntil(RoutePaths.home, (route) => false),
            whenProfileChanged: (context, profile) {
              debugPrint("Profile changed: $profile");
            },
            whenLoggedOut: (context) {
              debugPrint("Log out completed");
            },
            whenSessionExpired: (context) {
              debugPrint("Session expired");
            },
          ),
          routes: AppRoutes.all,
          navigatorObservers: AppRouteObservers.all,
          // builder: (context, child) => Material(
          //   color: Colors.black,
          //   child: Align(
          //     alignment: Alignment.topLeft,
          //     child: SizedBox(width: 500, height: 800, child: child),
          //   ),
          // ),
        );
      },
    );
  }
}
