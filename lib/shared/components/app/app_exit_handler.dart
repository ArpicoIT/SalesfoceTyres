import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppExitHandler extends StatefulWidget {
  const AppExitHandler({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 2),
    this.message = 'Click exit again',
    this.snackBarDuration = const Duration(seconds: 2),
    this.displayDuration = const Duration(seconds: 2),
  });

  final Widget child;
  final Duration duration;
  final String message;
  final Duration snackBarDuration;
  final Duration displayDuration;

  @override
  State<AppExitHandler> createState() => _AppExitHandlerState();
}

class _AppExitHandlerState extends State<AppExitHandler> {
  DateTime? _lastBackPressed;
  OverlayEntry? _overlayEntry;

  Future<void> _handleBackPressed() async {
    final now = DateTime.now();

    final shouldExit =
        _lastBackPressed != null &&
        now.difference(_lastBackPressed!) <= widget.duration;

    if (shouldExit) {
      await SystemNavigator.pop();
      return;
    }

    _lastBackPressed = now;

    if (!mounted) return;

    final screenHeight = MediaQuery.sizeOf(context).height;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: Colors.transparent,
          content: Center(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(widget.message, textAlign: TextAlign.center),
            ),
          ),
          duration: widget.snackBarDuration,
          behavior: SnackBarBehavior.floating,

          // margin: EdgeInsets.only(
          //   left: 40,
          //   right: 40,
          //   bottom: screenHeight / 2 - 24,
          // ),
          // padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          // shape: RoundedRectangleBorder(
          //   borderRadius: BorderRadius.circular(24),
          // ),
        ),
      );
  }

  Future<void> _handleBackPressed2() async {
    final now = DateTime.now();

    final shouldExit =
        _lastBackPressed != null &&
        now.difference(_lastBackPressed!) <= widget.duration;

    if (shouldExit) {
      _removeOverlay();
      await SystemNavigator.pop();
      return;
    }

    _lastBackPressed = now;
    _showMessage();
  }

  void _showMessage() {
    _removeOverlay();
    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) {
        bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return Positioned.fill(
          child: IgnorePointer(
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: AnimatedOpacity(
                  opacity: 1,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.message,
                      style: TextStyle(color: isDarkMode ? Colors.black : Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    overlay.insert(_overlayEntry!);
    Future.delayed(widget.displayDuration, () {
      if (mounted) {
        _removeOverlay();
      }
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        _handleBackPressed2();
      },
      child: widget.child,
    );
  }
}
