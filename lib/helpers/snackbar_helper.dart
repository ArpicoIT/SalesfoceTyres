import 'package:flutter/material.dart';

enum MessageType { info, success, error, warning }

void showSnackBarMessage(
    BuildContext context,
    String message, {
      MessageType type = MessageType.info,
      Duration duration = const Duration(seconds: 3),
    }) {
  Color backgroundColor;

  switch (type) {
    case MessageType.success:
      backgroundColor = Colors.green;
      break;
    case MessageType.error:
      backgroundColor = Colors.red;
      break;
    case MessageType.warning:
      backgroundColor = Colors.orange;
      break;
    case MessageType.info:
      backgroundColor = Theme.of(context).primaryColor;
      break;
  }

  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
      duration: duration,
      behavior: .floating,
    ),
  );
}
