import 'dart:async';

import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';

class AppUpdateService {
  AppUpdateService._();

  static final AppUpdateService instance = AppUpdateService._();

  bool _started = false;
  bool _checking = false;
  bool _dialogVisible = false;
  bool _updateRequired = false;
  bool _updateInProgress = false;

  BuildContext? _context;

  /// Call once when the first application route is ready.
  void start(BuildContext context) {
    if (_started) return;

    _started = true;
    _context = context;

    // Don't delay app startup or first frame.
    unawaited(checkForUpdate());
  }

  Future<void> checkForUpdate() async {
    if (_checking || _updateInProgress) return;

    _checking = true;

    try {
      final info = await InAppUpdate.checkForUpdate();

      final available =
          info.updateAvailability == UpdateAvailability.updateAvailable;

      final inProgress =
          info.updateAvailability ==
          UpdateAvailability.developerTriggeredUpdateInProgress;

      if (available || inProgress) {
        _updateRequired = true;

        if (info.immediateUpdateAllowed || inProgress) {
          await _showUpdateDialog();
        } else {
          // Google Play cannot currently start an immediate update.
          await _showUnavailableDialog();
        }
      }
    } catch (error, stackTrace) {
      debugPrint('App update check failed: $error');
      debugPrintStack(stackTrace: stackTrace);

      // A transient Play Store error should not show a fake
      // "Update required" message when availability is unknown.
      // Retry on the next app launch/resume according to policy.
    } finally {
      _checking = false;
    }
  }

  Future<void> _showUpdateDialog() async {
    final context = _context;

    if (context == null || !context.mounted || _dialogVisible) {
      return;
    }

    _dialogVisible = true;

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return PopScope(
            canPop: false,
            child: AlertDialog(
              title: const Text('Update Required'),
              content: const Text(
                'A new version is available. '
                'You must update the app to continue.',
              ),
              actions: [
                FilledButton(
                  onPressed: () async {
                    if (_updateInProgress) return;

                    _updateInProgress = true;

                    try {
                      final result = await InAppUpdate.performImmediateUpdate();

                      if (result == AppUpdateResult.success) {
                        // Play Store normally installs and restarts
                        // the application. If this process remains
                        // alive, verify update availability again.
                        _updateRequired = false;

                        if (dialogContext.mounted) {
                          Navigator.of(dialogContext).pop();
                        }
                      }
                    } catch (error) {
                      debugPrint('Immediate update failed: $error');

                      // Keep the mandatory dialog open so the
                      // user can retry.
                    } finally {
                      _updateInProgress = false;
                    }
                  },
                  child: const Text('Update Now'),
                ),
              ],
            ),
          );
        },
      );
    } finally {
      _dialogVisible = false;
    }
  }

  Future<void> _showUnavailableDialog() async {
    final context = _context;

    if (context == null || !context.mounted || _dialogVisible) {
      return;
    }

    _dialogVisible = true;

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return PopScope(
            canPop: false,
            child: AlertDialog(
              title: const Text('Update Required'),
              content: const Text(
                'An update is available, but Google Play '
                'cannot start the immediate update right now. '
                'Please try again later.',
              ),
              actions: [
                FilledButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    unawaited(checkForUpdate());
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        },
      );
    } finally {
      _dialogVisible = false;
    }
  }
}


class AppUpdateObserver extends NavigatorObserver {
  bool _started = false;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);

    // if (_started) return;
    //
    // final nav = navigator;
    // final overlayContext = nav?.overlay?.context;
    //
    // if (overlayContext == null) return;
    //
    // _started = true;
    //
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (overlayContext.mounted) {
    //     AppUpdateService.instance.start(overlayContext);
    //   }
    // });
  }
}

