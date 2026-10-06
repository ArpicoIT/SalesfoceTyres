import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DiscountInputField extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool enabled;
  final double maxDiscount;
  final List<int> predefinedDiscounts;
  final ValueChanged<double>? onChanged;
  final bool filled;
  final bool hasPrefix;
  final IconData? prefixIcon;

  const DiscountInputField({
    super.key,
    this.controller,
    this.focusNode,
    this.enabled = true,
    this.maxDiscount = 100.0,
    this.predefinedDiscounts = const [5, 10, 15, 20, 25, 50],
    this.onChanged,
    this.filled = true,
    this.hasPrefix = true,
    this.prefixIcon,
  });

  @override
  State<DiscountInputField> createState() => _DiscountInputFieldState();
}

class _DiscountInputFieldState extends State<DiscountInputField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  Widget? _clearButton;

  @override
  void initState() {
    super.initState();

    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();

    // if (_controller.text.isEmpty) {
    //   _controller.text = '0.00';
    // }

    _controller.addListener(_handleControllerChanged);
  }

  double _parseDiscount(String value) {
    return double.tryParse(value) ??
        0.0;
  }

  void _handleControllerChanged() {
    final discount = _parseDiscount(_controller.text);

    final shouldShowClear = discount != 0.0;

    if ((shouldShowClear && _clearButton == null) ||
        (!shouldShowClear && _clearButton != null)) {
      setState(() {
        _clearButton = shouldShowClear
            ? IconButton(
          onPressed: _clear,
          icon: const Icon(Icons.cancel),
          style: IconButton.styleFrom(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            foregroundColor: Colors.grey.shade700,
          ),
        )
            : null;
      });
    }
  }

  void _handleChanged(String value) {
    widget.onChanged?.call(_parseDiscount(value));
  }

  void _selectPredefinedDiscount(int discount) {
    final textValue = discount.toStringAsFixed(2);

    _controller.value = TextEditingValue(
      text: textValue,
      selection: TextSelection.collapsed(
        offset: textValue.length,
      ),
    );

    _handleChanged(textValue);
    _focusNode.unfocus();
  }

  void _clear() {
    _controller.clear();
    widget.onChanged?.call(0.0);
  }

  // void _clear() {
  //   const textValue = '0.00';
  //
  //   _controller.value = const TextEditingValue(
  //     text: textValue,
  //     selection: TextSelection.collapsed(offset: 4),
  //   );
  //
  //   widget.onChanged?.call(0.0);
  // }

  @override
  Widget build(BuildContext context) {
    final availableDiscounts = widget.predefinedDiscounts
        .where((d) => d <= widget.maxDiscount)
        .toList();

    final cs = Theme.of(context).colorScheme;

    return TextField(
      enabled: widget.enabled,
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      enableInteractiveSelection: false,

      inputFormatters: [
        DiscountLimitFormatter(
          maxValue: widget.maxDiscount,
        ),
      ],

      onChanged: _handleChanged,
      textAlign: .end,
      clipBehavior: .antiAlias,
      decoration: InputDecoration(
        hintText: '0.00',
        filled: widget.filled,
        isDense: true,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(12),
        ),

        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(12),
        ),

        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (_clearButton != null && widget.enabled)
              _clearButton!
            else if (availableDiscounts.isNotEmpty)
              PopupMenuButton<int>(
                enabled: widget.enabled,
                icon: const Icon(Icons.arrow_drop_down),
                tooltip: 'Select discount',
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: _selectPredefinedDiscount,
                itemBuilder: (_) {
                  return availableDiscounts.map((discount) {
                    return PopupMenuItem<int>(
                      value: discount,
                      child: Text('$discount%'),
                    );
                  }).toList();
                },
                padding: EdgeInsets.zero,
                style: const ButtonStyle(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              )
            else
              const SizedBox.shrink(),
          ],
        ),

        prefixIcon: widget.hasPrefix ? Container(
            margin: .fromLTRB(2, 2, 0, 2),
            decoration: BoxDecoration(
              color: cs.surfaceContainer,
              borderRadius: .horizontal(left: Radius.circular(10))
            ),
            child: Icon(widget.prefixIcon ?? Icons.percent_rounded)) : null,
      ),

      onTapOutside: (_) => _focusNode.unfocus(),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChanged);

    if (widget.controller == null) {
      _controller.dispose();
    }

    if (widget.focusNode == null) {
      _focusNode.dispose();
    }

    super.dispose();
  }
}

class DiscountLimitFormatter extends TextInputFormatter {
  DiscountLimitFormatter({required this.maxValue});
  final double maxValue;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final text = newValue.text;

    // Allow empty input
    if (text.isEmpty) {
      return newValue;
    }

    // Allow max: 2 digits + optional decimal + 2 digits
    final regex = RegExp(r'^\d{0,2}(\.\d{0,2})?$');

    if (!regex.hasMatch(text)) {
      return oldValue;
    }

    // Allow intermediate input: 12.
    if (text.endsWith('.')) {
      return newValue;
    }

    final value = double.tryParse(text);

    if (value == null || value > maxValue) {
      return oldValue;
    }

    return newValue;
  }
}

/// v1.0
// class DiscountInputField extends StatefulWidget {
//   final TextEditingController? controller;
//   final FocusNode? focusNode;
//   final bool enabled;
//   final double maxDiscount;
//   final List<int> predefinedDiscounts;
//   final ValueChanged<double>? onChanged;
//   final bool filled;
//   final bool hasPrefix;
//   final IconData? prefixIcon;
//
//   const DiscountInputField({
//     super.key,
//     this.controller,
//     this.focusNode,
//     this.enabled = true,
//     this.maxDiscount = 100.0,
//     this.predefinedDiscounts = const [5, 10, 15, 20, 25, 50],
//     this.onChanged,
//     this.filled = true,
//     this.hasPrefix = true,
//     this.prefixIcon,
//   });
//
//   @override
//   State<DiscountInputField> createState() => _DiscountInputFieldState();
// }
//
// class _DiscountInputFieldState extends State<DiscountInputField> {
//   late final TextEditingController _controller;
//   late final FocusNode _focusNode;
//   Widget? _clearButton;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _controller = widget.controller ?? TextEditingController();
//     _focusNode = widget.focusNode ?? FocusNode();
//
//     if (_controller.text.isEmpty) {
//       _controller.text = '0.00%';
//     } else if (!_controller.text.endsWith('%')) {
//       _controller.text = '${_controller.text}%';
//     }
//
//     _controller.addListener(_handleControllerChanged);
//   }
//
//   double _parseDiscount(String value) {
//     return double.tryParse(
//       value.replaceAll('%', ''),
//     ) ??
//         0.0;
//   }
//
//   void _handleControllerChanged() {
//     final discount = _parseDiscount(_controller.text);
//
//     final shouldShowClear = discount != 0.0;
//
//     if ((shouldShowClear && _clearButton == null) ||
//         (!shouldShowClear && _clearButton != null)) {
//       setState(() {
//         _clearButton = shouldShowClear
//             ? IconButton(
//           onPressed: _clear,
//           icon: const Icon(Icons.cancel),
//           style: IconButton.styleFrom(
//             tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//             visualDensity: VisualDensity.compact,
//             foregroundColor: Colors.grey.shade700,
//           ),
//         )
//             : null;
//       });
//     }
//   }
//
//   void _handleChanged(String value) {
//     widget.onChanged?.call(_parseDiscount(value));
//   }
//
//   void _selectPredefinedDiscount(int discount) {
//     final textValue = '${discount.toStringAsFixed(2)}%';
//
//     _controller.value = TextEditingValue(
//       text: textValue,
//       selection: TextSelection.collapsed(
//         offset: textValue.length - 1,
//       ),
//     );
//
//     _handleChanged(textValue);
//     _focusNode.unfocus();
//   }
//
//   void _clear() {
//     const textValue = '0.00';
//
//     _controller.value = const TextEditingValue(
//       text: textValue,
//       selection: TextSelection.collapsed(offset: 4),
//     );
//
//     widget.onChanged?.call(0.0);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final availableDiscounts = widget.predefinedDiscounts
//         .where((d) => d <= widget.maxDiscount)
//         .toList();
//
//     return TextField(
//       enabled: widget.enabled,
//       controller: _controller,
//       focusNode: _focusNode,
//       keyboardType: const TextInputType.numberWithOptions(decimal: true),
//       enableInteractiveSelection: false,
//
//       inputFormatters: [
//         DiscountLimitFormatter(
//           maxValue: widget.maxDiscount,
//         ),
//       ],
//
//       onChanged: _handleChanged,
//       textAlign: .end,
//       clipBehavior: .antiAlias,
//       decoration: InputDecoration(
//         hintText: '0.00',
//         filled: widget.filled,
//         isDense: true,
//
//         border: OutlineInputBorder(
//             borderSide: BorderSide(color: Colors.grey.shade300)
//           // borderRadius: BorderRadius.circular(12),
//         ),
//
//         enabledBorder: OutlineInputBorder(
//             borderSide: BorderSide(color: Colors.grey.shade300)
//           // borderRadius: BorderRadius.circular(12),
//         ),
//
//         suffixIcon: Row(
//           mainAxisSize: MainAxisSize.min,
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: [
//             if (_clearButton != null && widget.enabled) _clearButton!,
//
//             if (availableDiscounts.isNotEmpty)
//               PopupMenuButton<int>(
//                 enabled: widget.enabled,
//                 icon: const Icon(Icons.arrow_drop_down),
//                 tooltip: 'Select discount',
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 onSelected: _selectPredefinedDiscount,
//                 itemBuilder: (_) {
//                   return availableDiscounts.map((discount) {
//                     return PopupMenuItem<int>(
//                       value: discount,
//                       child: Text('$discount%'),
//                     );
//                   }).toList();
//                 },
//                 padding: EdgeInsets.zero,
//                 style: const ButtonStyle(
//                   tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                   visualDensity: VisualDensity.compact,
//                 ),
//               ),
//           ],
//         ),
//
//         prefixIcon: widget.hasPrefix ? Container(
//             margin: .fromLTRB(1, 1, 0, 1),
//             decoration: BoxDecoration(
//                 color: Colors.grey.shade200,
//                 borderRadius: .horizontal(left: Radius.circular(2))
//             ),
//             child: Icon(widget.prefixIcon ?? Icons.percent_rounded)) : null,
//       ),
//
//       onTapOutside: (_) => _focusNode.unfocus(),
//     );
//   }
//
//   @override
//   void dispose() {
//     _controller.removeListener(_handleControllerChanged);
//
//     if (widget.controller == null) {
//       _controller.dispose();
//     }
//
//     if (widget.focusNode == null) {
//       _focusNode.dispose();
//     }
//
//     super.dispose();
//   }
// }
// class DiscountLimitFormatter extends TextInputFormatter {
//   DiscountLimitFormatter({required this.maxValue});
//
//   final double maxValue;
//
//   @override
//   TextEditingValue formatEditUpdate(
//       TextEditingValue oldValue,
//       TextEditingValue newValue,
//       ) {
//     final text = newValue.text.replaceAll('%', '');
//
//     // Allow empty input
//     if (text.isEmpty) {
//       return const TextEditingValue(
//         text: '%',
//         selection: TextSelection.collapsed(offset: 0),
//       );
//     }
//
//     // Allow max: 2 digits + optional decimal + 2 digits
//     final regex = RegExp(r'^\d{0,2}(\.\d{0,2})?$');
//
//     if (!regex.hasMatch(text)) {
//       return oldValue;
//     }
//
//     // Allow intermediate input: 12.
//     if (text.endsWith('.')) {
//       return TextEditingValue(
//         text: '$text%',
//         selection: TextSelection.collapsed(offset: text.length),
//       );
//     }
//
//     final value = double.tryParse(text);
//
//     if (value == null || value > maxValue) {
//       return oldValue;
//     }
//
//     return TextEditingValue(
//       text: '$text%',
//       selection: TextSelection.collapsed(offset: text.length),
//     );
//   }
// }

