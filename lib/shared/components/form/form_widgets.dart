import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum VerificationStatus { verified, unverified, unknown, waiting }

class FormWidgets {
  final BuildContext context;
  const FormWidgets._(this.context);
  static FormWidgets of(BuildContext context) =>
      FormWidgets._(context);

  Widget verificationIndicatorBuilder({
        required ValueNotifier<VerificationStatus> stateListener,
        required String hintText,
        required VoidCallback onPressed,
      }) {
    return ValueListenableBuilder(
      valueListenable: stateListener,
      builder: (context, state, _) {
        final colorScheme = Theme.of(context).colorScheme;
        Widget icon;
        String? message;

        switch (state) {
          case VerificationStatus.verified:
            icon =
            const Icon(Icons.check_circle, color: Colors.green, size: 24);
            message = 'Your $hintText is confirmed';
            break;
          case VerificationStatus.unverified:
            icon = Text('Verify', style: TextStyle(color: colorScheme.error));
            // icon = Icon(Icons.info, color: colorScheme.error, size: 24);
            message = 'Your $hintText must be verified first.';
            break;
          case VerificationStatus.unknown:
            icon = Text('Verify', style: TextStyle(color: colorScheme.primary));
            message = ''; //'Please verify your $hintText to proceed.';
            break;
          case VerificationStatus.waiting:
            icon = CupertinoActivityIndicator();
            message = 'Verifying...!';
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Tooltip(
              message: message,
              child: TextButton(
                onPressed: onPressed,
                style: TextButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.all(8),
                    minimumSize: Size.zero
                ),
                child: icon,
              )),
        );
      },
    );
  }

  Widget titleBuilder({String? title, String? hint, EdgeInsetsGeometry? padding}) {

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return title != null
        ? Padding(
      padding: padding ?? const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
            text: title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, color: isDark ? Colors.grey : Colors.black54),
            children: [
              TextSpan(text: hint, style: TextStyle(fontWeight: FontWeight.w400, color: Colors.grey.shade500))
            ]),
      ),
    )
        : const SizedBox.shrink();
  }

  Widget suffixActionBuilder({
    required TextEditingController controller,
    required VoidCallback onClear,
    bool showClearButton = false,
    List<Widget> actions = const [],
  }){
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if(showClearButton)
          ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, value, child) {
              if(controller.text.isEmpty) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: EdgeInsets.only(right: actions.isEmpty ? 8 : 0),
                child: IconButton(
                  onPressed: onClear,
                  icon: Icon(Icons.cancel),
                  style: IconButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.all(8),
                      minimumSize: Size.zero
                  ),
                ),
              );
            },
          ),
        ...actions
      ],
    );
  }

  Widget clearButtonBuilder({
    bool visibility = false,
    required TextEditingController controller,
    required Function() onPressed,
    bool hasSuffix = false,
  }){
    return visibility
        ? ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, value, child) {
        if(value.text.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: EdgeInsets.only(right: hasSuffix ? 0 : 12), // 0:8
          child: IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: onPressed,
            icon: Icon(Icons.cancel),
          ),
        );
      },
    )
        : const SizedBox.shrink();
  }

  Widget clearButtonBuilderOld({
    bool visibility = false,
    required ValueNotifier<bool> valueListenable,
    required Function() onPressed,
    bool hasSuffix = false,
  }){
    return visibility
        ? ValueListenableBuilder(
      valueListenable: valueListenable,
      builder: (context, value, child) {
        if(!value) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: EdgeInsets.only(right: hasSuffix ? 0 : 12), // 0:8
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(Icons.cancel),
          ),
        );
      },
    )
        : const SizedBox.shrink();
  }
}
