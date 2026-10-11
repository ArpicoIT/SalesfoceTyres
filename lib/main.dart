import 'package:arpicoiam/iam.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:locafy/locafy.dart';
import 'package:provider/provider.dart';

import 'app/app_route_observer.dart';
import 'app/app_routes.dart';
import 'app/app_update_service.dart';
import 'app/route_paths.dart';
import 'app/theme/app_theme.dart';
import 'app/theme/app_theme_notifier.dart';
import 'config/app_config.dart';
import 'services/database/app_database.dart';
import 'services/storage/app_shared_prefs.dart';

void main() async {
  // Width: 600.9389348488247 , Height: 913.4271809702136

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
            ).pushNamedAndRemoveUntil(RoutePaths.dashboard, (route) => false),
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
          navigatorObservers: [
            ...AppRouteObserver.observers,
            AppUpdateObserver()
          ],

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

class MandatoryUpdateGate extends StatefulWidget {
  final Widget child;

  const MandatoryUpdateGate({
    super.key,
    required this.child,
  });

  @override
  State<MandatoryUpdateGate> createState() =>
      _MandatoryUpdateGateState();
}

class _MandatoryUpdateGateState
    extends State<MandatoryUpdateGate>
    with WidgetsBindingObserver {
  bool _checking = true;
  bool _updateRequired = false;
  bool _checkingAgain = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkForUpdate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Resume an interrupted immediate update when the app returns.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _updateRequired &&
        !_checkingAgain) {
      _checkForUpdate();
    }
  }

  Future<void> _checkForUpdate() async {
    if (_checkingAgain) return;

    _checkingAgain = true;

    if (mounted) {
      setState(() {
        _checking = true;
        _message = null;
      });
    }

    try {
      final info = await InAppUpdate.checkForUpdate();

      if (!mounted) return;

      final updateAvailable =
          info.updateAvailability ==
              UpdateAvailability.updateAvailable;

      final updateInProgress =
          info.updateAvailability ==
              UpdateAvailability.developerTriggeredUpdateInProgress;

      if (updateAvailable || updateInProgress) {
        setState(() {
          _updateRequired = true;
          _checking = false;
        });

        if (info.immediateUpdateAllowed || updateInProgress) {
          try {
            final result =
            await InAppUpdate.performImmediateUpdate();

            if (!mounted) return;

            if (result == AppUpdateResult.success) {
              // Play Store normally installs and restarts the app.
              // Recheck if this process remains alive.
              await _checkForUpdateAfterFlow();
            } else {
              setState(() {
                _updateRequired = true;
                _checking = false;
                _message =
                'Please complete the update to continue.';
              });
            }
          } catch (e) {
            if (!mounted) return;

            setState(() {
              _updateRequired = true;
              _checking = false;
              _message =
              'The update was not completed. Please try again.';
            });
          }
        } else {
          setState(() {
            _updateRequired = true;
            _checking = false;
            _message =
            'An update is available, but Google Play '
                'cannot start the immediate update right now. '
                'Please try again later.';
          });
        }
      } else {
        setState(() {
          _updateRequired = false;
          _checking = false;
        });
      }
    } on PlatformException catch (e) {
      if (!mounted) return;

      setState(() {
        _checking = false;
        // Fail open on Play Store/API errors.
        // Change this policy if your app must fail closed.
        _updateRequired = false;
        _message = 'Could not check for updates: ${e.message ?? e.code}';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _checking = false;
        _updateRequired = false;
        _message = 'Could not check for updates.';
      });
    } finally {
      _checkingAgain = false;
    }
  }

  Future<void> _checkForUpdateAfterFlow() async {
    if (!mounted) return;

    // Recheck when the immediate update flow returns.
    await _checkForUpdate();
  }

  @override
  Widget build(BuildContext context) {
    if (!_checking && !_updateRequired) {
      return widget.child;
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.system_update,
                    size: 72,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _checking
                        ? 'Checking for updates'
                        : 'Update Required',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _checking
                        ? 'Please wait while we check your app version.'
                        : 'Please update the app to continue using it.',
                    textAlign: TextAlign.center,
                  ),
                  if (_checking) ...[
                    const SizedBox(height: 24),
                    const CircularProgressIndicator(),
                  ],
                  if (!_checking && _message != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _message!,
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (!_checking) ...[
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _checkForUpdate,
                        child: const Text('Try Update Again'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
