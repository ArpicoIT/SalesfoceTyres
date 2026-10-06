import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class BankingAmountField extends StatefulWidget {
  const BankingAmountField({
    super.key,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.maxLength,
    this.maxAmount,
    this.filled = true,
    this.label,
    this.hint,
    this.prefixIcon,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<double>? onChanged;
  final int? maxLength;
  final double? maxAmount;
  final bool filled;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;

  @override
  State<BankingAmountField> createState() => _BankingAmountFieldState();
}

class _BankingAmountFieldState extends State<BankingAmountField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  Widget? _clearButton;


  @override
  void initState() {
    super.initState();

    _controller = widget.controller ?? TextEditingController(text: '0.00');
    _focusNode = widget.focusNode ?? FocusNode();

    if (_controller.text.isEmpty) {
      _controller.text = '0.00';
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _setSelectionBeforeDot();

      _controller.addListener(() {
        final value = _controller.text;
        if (value.isNotEmpty && double.tryParse(value) != 0.00) {
          _clearButton = IconButton(
            onPressed: _clear,
            icon: Icon(Icons.cancel),
            style: IconButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              foregroundColor: Colors.grey.shade700,
            ),
          );
        } else {
          _clearButton = null;
        }
        if (mounted) setState(() {});
      });
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _setSelectionToEnd() {
    _controller.selection = TextSelection.collapsed(
      offset: _controller.text.length,
    );
  }

  void _setSelectionBeforeDot() {
    final text = _controller.text;
    final dotIndex = text.indexOf('.');

    // Position cursor before '.' if present, otherwise at the end
    final targetOffset = dotIndex != -1 ? dotIndex : text.length;

    _controller.selection = TextSelection.collapsed(offset: targetOffset);
  }

  void _handleChanged(String value) {
    // Clean out commas before converting to double
    final cleanValue = value.replaceAll(',', '');
    widget.onChanged?.call(double.tryParse(cleanValue) ?? 0.0);
  }

  void _clear() {
    _controller.clear();
    widget.onChanged?.call(0.0);
  }

  InputDecoration get _decoration {
    final cs = Theme.of(context).colorScheme;
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: c, width: w),
    );
    return InputDecoration(
        labelText: widget.label,
        hintText: widget.hint ?? '0.00',
        hintStyle: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.6)),
        prefixIcon: widget.prefixIcon == null ? null : Icon(widget.prefixIcon, size: 20),
        filled: true,
        fillColor: widget.filled ? cs.surfaceContainerLow : cs.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: border(Colors.transparent),
        enabledBorder: border(cs.outlineVariant.withValues(alpha: 0.6)),
        focusedBorder: border(cs.primary, 1.8),
        errorBorder: border(cs.error),
        focusedErrorBorder: border(cs.error, 1.8),
        counterText: '',
        suffixIcon: _clearButton
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: false,
      ),
      inputFormatters: <TextInputFormatter>[BankingAmountFormatter(maxValue: widget.maxAmount)],
      showCursor: true,
      enableInteractiveSelection: false,
      textAlign: TextAlign.right,
      onTap: _setSelectionBeforeDot,
      onChanged: _handleChanged,
      decoration: _decoration,
      // decorations: InputDecoration(
      //   // isDense: true,
      //   filled: true,
      //   fillColor: widget.filled ? cs.surfaceContainer : cs.surface,
      //   hintText: '0.00',
      //   hintStyle: tt.bodyLarge?.copyWith(color: Colors.grey),
      //   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      //   enabledBorder: OutlineInputBorder(
      //     borderRadius: BorderRadius.circular(12),
      //     borderSide: BorderSide.none,
      //   ),
      //   counterText: '',
      //   suffixIcon: _clearButton, // buildClearIcon(_controller, _clear),
      // ),
      maxLength: widget.maxLength,
    );
  }
}
class BankingAmountFormatter extends TextInputFormatter {
  BankingAmountFormatter({this.maxValue});

  final double? maxValue;

  /// Formats raw integer digits with commas (e.g., "1245458" -> "1,245,458")
  String _formatWithCommas(String rawDigits) {
    if (rawDigits.isEmpty) return '0';

    final regExp = RegExp(r'\B(?=(\d{3})+(?!\d))');

    return rawDigits.replaceAll(regExp, ',');
  }

  /// Extracts pure digits from an integer substring
  String _cleanDigits(String text) {
    return text.replaceAll(RegExp(r'[^\d]'), '');
  }

  bool _isWithinMaxValue(String value) {
    if (maxValue == null) {
      return true;
    }

    final numericValue = double.tryParse(
      value.replaceAll(',', ''),
    );

    if (numericValue == null) {
      return true;
    }

    return numericValue <= maxValue!;
  }

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    if (newValue.text.isEmpty) {
      return const TextEditingValue(
        text: '0.00',
        selection: TextSelection.collapsed(offset: 1),
      );
    }

    // 1. Handle Deletion
    if (newValue.text.length < oldValue.text.length) {
      return _handleDeletion(oldValue);
    }

    // Extract inserted character
    final String inserted = newValue.text.substring(
      oldValue.selection.start < 0 ? 0 : oldValue.selection.start,
      newValue.selection.end < 0 ? 0 : newValue.selection.end,
    );

    final text = oldValue.text;
    final dotIndex = text.indexOf('.');

    // 2. Handle Decimal Point input
    if (inserted == '.') {
      if (dotIndex != -1) {
        return TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(
            offset: dotIndex + 1,
          ),
        );
      }
    }

    // Reject non-numeric input
    if (RegExp(r'[^\d]').hasMatch(inserted)) {
      return oldValue;
    }

    final cursorPosition = oldValue.selection.baseOffset;

    String rawInteger = _cleanDigits(
      dotIndex != -1 ? text.substring(0, dotIndex) : text,
    );

    String decimalPart =
    dotIndex != -1 ? text.substring(dotIndex + 1) : '00';

    // 3. Typing in Integer Section
    if (cursorPosition <= dotIndex || dotIndex == -1) {
      if (rawInteger == '0') {
        rawInteger = inserted;
      } else {
        rawInteger += inserted;
      }

      final formattedInteger = _formatWithCommas(rawInteger);
      final newText = '$formattedInteger.$decimalPart';

      // MAX VALUE BLOCKER
      if (!_isWithinMaxValue(newText)) {
        return oldValue;
      }

      return TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: formattedInteger.length,
        ),
      );
    }

    // 4. Typing in Decimal Section
    final decimalOffset = cursorPosition - (dotIndex + 1);

    if (decimalOffset == 0) {
      decimalPart =
      '$inserted${decimalPart.length > 1 ? decimalPart[1] : "0"}';
    } else if (decimalOffset == 1) {
      decimalPart = '${decimalPart[0]}$inserted';
    } else {
      return oldValue;
    }

    final formattedInteger = _formatWithCommas(rawInteger);
    final newText = '$formattedInteger.$decimalPart';

    // 5. Check maximum value
    if (!_isWithinMaxValue(newText)) {
      return oldValue;
    }

    final newDotIndex = newText.indexOf('.');
    final newCursorOffset = (newDotIndex + 1 + decimalOffset + 1).clamp(
      0,
      newText.length,
    );

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: newCursorOffset,
      ),
    );
  }

  TextEditingValue _handleDeletion(TextEditingValue oldValue) {
    final text = oldValue.text;
    final cursorPosition = oldValue.selection.baseOffset;
    final dotIndex = text.indexOf('.');

    String rawInteger = _cleanDigits(
      dotIndex != -1 ? text.substring(0, dotIndex) : text,
    );

    String decimalPart =
    dotIndex != -1 ? text.substring(dotIndex + 1) : '00';

    // Deleting in integer part
    if (cursorPosition <= dotIndex) {
      if (rawInteger.length <= 1) {
        rawInteger = '0';
      } else {
        rawInteger = rawInteger.substring(0, rawInteger.length - 1);
      }

      final formattedInteger = _formatWithCommas(rawInteger);
      final newText = '$formattedInteger.$decimalPart';

      return TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: formattedInteger.length,
        ),
      );
    }

    // Deleting in decimal part
    else {
      final decimalOffset = cursorPosition - (dotIndex + 1);

      if (decimalOffset == 2) {
        decimalPart = '${decimalPart[0]}0';
      } else if (decimalOffset == 1) {
        decimalPart = '00';
      }

      final formattedInteger = _formatWithCommas(rawInteger);
      final newText = '$formattedInteger.$decimalPart';
      final newCursorOffset = (cursorPosition - 1).clamp(
        0,
        newText.length,
      );

      return TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: newCursorOffset,
        ),
      );
    }
  }
}

/*class BankingAmountFormatter extends TextInputFormatter {
  BankingAmountFormatter({this.maxValue});
  final double? maxValue;

  /// Formats raw integer digits with commas (e.g., "1245458" -> "1,245,458")
  String _formatWithCommas(String rawDigits) {
    if (rawDigits.isEmpty) return '0';
    final regExp = RegExp(r'\B(?=(\d{3})+(?!\d))');
    return rawDigits.replaceAll(regExp, ',');
  }

  /// Extracts pure digits from an integer substring
  String _cleanDigits(String text) {
    return text.replaceAll(RegExp(r'[^\d]'), '');
  }


  bool _isWithinMaxValue(String value) {
    if (maxValue == null) {
      return true;
    }

    final numericValue = double.tryParse(
      value.replaceAll(',', ''),
    );

    if (numericValue == null) {
      return true;
    }

    return numericValue <= maxValue!;
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return const TextEditingValue(
        text: '0.00',
        selection: TextSelection.collapsed(offset: 1),
      );
    }

    // 1. Handle Deletion
    if (newValue.text.length < oldValue.text.length) {
      return _handleDeletion(oldValue);
    }

    // Extract inserted character
    final String inserted = newValue.text.substring(
      oldValue.selection.start < 0 ? 0 : oldValue.selection.start,
      newValue.selection.end < 0 ? 0 : newValue.selection.end,
    );

    final text = oldValue.text;
    final dotIndex = text.indexOf('.');

    // 2. Handle Decimal Point input
    if (inserted == '.') {
      if (dotIndex != -1) {
        return TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: dotIndex + 1),
        );
      }
    }

    // Reject non-numeric input
    if (RegExp(r'[^\d]').hasMatch(inserted)) {
      return oldValue;
    }

    final cursorPosition = oldValue.selection.baseOffset;
    String rawInteger = _cleanDigits(
      dotIndex != -1 ? text.substring(0, dotIndex) : text,
    );
    String decimalPart = dotIndex != -1 ? text.substring(dotIndex + 1) : '00';

    // 3. Typing in Integer Section
    if (cursorPosition <= dotIndex || dotIndex == -1) {
      if (rawInteger == '0') {
        rawInteger = inserted;
      } else {
        rawInteger += inserted;
      }

      final formattedInteger = _formatWithCommas(rawInteger);
      final newText = '$formattedInteger.$decimalPart';

      return TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: formattedInteger.length),
      );
    }

    // 4. Typing in Decimal Section
    final decimalOffset = cursorPosition - (dotIndex + 1);

    if (decimalOffset == 0) {
      decimalPart = '$inserted${decimalPart.length > 1 ? decimalPart[1] : "0"}';
    } else if (decimalOffset == 1) {
      decimalPart = '${decimalPart[0]}$inserted';
    } else {
      return oldValue;
    }

    final formattedInteger = _formatWithCommas(rawInteger);
    final newText = '$formattedInteger.$decimalPart';

    // 5. Check maximum value
    if (!_isWithinMaxValue(newText)) {
      return oldValue;
    }

    final newDotIndex = newText.indexOf('.');
    final newCursorOffset = (newDotIndex + 1 + decimalOffset + 1).clamp(
      0,
      newText.length,
    );

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursorOffset),
    );
  }

  TextEditingValue _handleDeletion(TextEditingValue oldValue) {
    final text = oldValue.text;
    final cursorPosition = oldValue.selection.baseOffset;
    final dotIndex = text.indexOf('.');

    String rawInteger = _cleanDigits(
      dotIndex != -1 ? text.substring(0, dotIndex) : text,
    );
    String decimalPart = dotIndex != -1 ? text.substring(dotIndex + 1) : '00';

    // Deleting in integer part
    if (cursorPosition <= dotIndex) {
      if (rawInteger.length <= 1) {
        rawInteger = '0';
      } else {
        rawInteger = rawInteger.substring(0, rawInteger.length - 1);
      }

      final formattedInteger = _formatWithCommas(rawInteger);
      final newText = '$formattedInteger.$decimalPart';

      return TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: formattedInteger.length),
      );
    }
    // Deleting in decimal part
    else {
      final decimalOffset = cursorPosition - (dotIndex + 1);
      if (decimalOffset == 2) {
        decimalPart = '${decimalPart[0]}0';
      } else if (decimalOffset == 1) {
        decimalPart = '00';
      }

      final formattedInteger = _formatWithCommas(rawInteger);
      final newText = '$formattedInteger.$decimalPart';
      final newCursorOffset = (cursorPosition - 1).clamp(0, newText.length);

      return TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newCursorOffset),
      );
    }
  }
}*/

// class BankingAmountFormatterOld extends TextInputFormatter {
//   @override
//   TextEditingValue formatEditUpdate(
//       TextEditingValue oldValue,
//       TextEditingValue newValue,
//       ) {
//     // Prevent empty state
//     if (newValue.text.isEmpty) {
//       return const TextEditingValue(
//         text: '0.00',
//         selection: TextSelection.collapsed(offset: 4),
//       );
//     }
//
//     // 1. Handle Deletion
//     if (newValue.text.length < oldValue.text.length) {
//       return _handleDeletion(oldValue);
//     }
//
//     // Extract inserted character
//     final String inserted = newValue.text.substring(
//       oldValue.selection.start < 0 ? 0 : oldValue.selection.start,
//       newValue.selection.end < 0 ? 0 : newValue.selection.end,
//     );
//
//     // 2. Handle Decimal Point input
//     if (inserted == '.') {
//       final dotIndex = oldValue.text.indexOf('.');
//       if (dotIndex != -1) {
//         // Jump cursor right after the decimal point
//         return TextEditingValue(
//           text: oldValue.text,
//           selection: TextSelection.collapsed(offset: dotIndex + 1),
//         );
//       }
//     }
//
//     // Only allow numeric insertions past this point
//     if (RegExp(r'[^\d]').hasMatch(inserted)) {
//       return oldValue;
//     }
//
//     // 3. Handle Digit Insertion based on cursor position
//     final text = oldValue.text;
//     final cursorPosition = oldValue.selection.baseOffset;
//     final dotIndex = text.indexOf('.');
//
//     String integerPart = dotIndex != -1 ? text.substring(0, dotIndex) : text;
//     String decimalPart = dotIndex != -1 ? text.substring(dotIndex + 1) : '00';
//
//     // Typing in the integer section (before or at the dot)
//     if (cursorPosition <= dotIndex || dotIndex == -1) {
//       if (integerPart == '0') {
//         integerPart = inserted;
//       } else {
//         integerPart += inserted;
//       }
//       final newText = '$integerPart.$decimalPart';
//       return TextEditingValue(
//         text: newText,
//         selection: TextSelection.collapsed(offset: integerPart.length),
//       );
//     }
//     // Typing in the decimal section (after the dot)
//     else {
//       final decimalOffset = cursorPosition - (dotIndex + 1);
//
//       if (decimalOffset == 0) {
//         // Replace first decimal digit
//         decimalPart = '$inserted${decimalPart.length > 1 ? decimalPart[1] : "0"}';
//       } else if (decimalOffset == 1) {
//         // Replace second decimal digit
//         decimalPart = '${decimalPart[0]}$inserted';
//       } else {
//         return oldValue; // Reached max 2 decimal places
//       }
//
//       final newText = '$integerPart.$decimalPart';
//       final newCursorOffset = (dotIndex + 1 + decimalOffset + 1).clamp(0, newText.length);
//
//       return TextEditingValue(
//         text: newText,
//         selection: TextSelection.collapsed(offset: newCursorOffset),
//       );
//     }
//   }
//
//   TextEditingValue _handleDeletion(TextEditingValue oldValue) {
//     final text = oldValue.text;
//     final cursorPosition = oldValue.selection.baseOffset;
//     final dotIndex = text.indexOf('.');
//
//     String integerPart = dotIndex != -1 ? text.substring(0, dotIndex) : text;
//     String decimalPart = dotIndex != -1 ? text.substring(dotIndex + 1) : '00';
//
//     // Deleting in integer part
//     if (cursorPosition <= dotIndex) {
//       if (integerPart.length <= 1) {
//         integerPart = '0';
//       } else {
//         integerPart = integerPart.substring(0, integerPart.length - 1);
//       }
//       final newText = '$integerPart.$decimalPart';
//       return TextEditingValue(
//         text: newText,
//         selection: TextSelection.collapsed(offset: integerPart.length),
//       );
//     }
//     // Deleting in decimal part
//     else {
//       final decimalOffset = cursorPosition - (dotIndex + 1);
//       if (decimalOffset == 2) {
//         decimalPart = '${decimalPart[0]}0';
//       } else if (decimalOffset == 1) {
//         decimalPart = '00';
//       }
//
//       final newText = '$integerPart.$decimalPart';
//       final newCursorOffset = (cursorPosition - 1).clamp(0, newText.length);
//       return TextEditingValue(
//         text: newText,
//         selection: TextSelection.collapsed(offset: newCursorOffset),
//       );
//     }
//   }
// }
