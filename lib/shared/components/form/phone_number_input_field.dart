import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'form_widgets.dart';

class PhoneNumberInputField extends StatelessWidget {
  final dynamic fieldKey;
  final TextEditingController? controller;
  final String countryCode;
  final String? hintText;
  final bool required;
  final int maxLength;
  final Function(String fullNumber)? onChanged;
  final FocusNode focusNode;
  final IconData? prefixIcon;
  final TextInputAction? textInputAction;
  final String? title;
  final String? titleHint;
  final bool filled;

  const PhoneNumberInputField({
    super.key,
    this.fieldKey,
    this.countryCode = "+94",
    this.controller,
    this.hintText,
    this.required = true,
    this.maxLength = 9,
    this.onChanged,
    required this.focusNode,
    this.prefixIcon,
    this.textInputAction,
    this.title,
    this.titleHint,
    this.filled = true,
  });

  String _getFullNumber(String value) {
    final number = value.replaceAll(RegExp(r'[^0-9]'), '');

    return '$countryCode$number';
  }

  String? _validator(String? value) {
    value ??= '';

    final number = value.replaceAll(RegExp(r'[^0-9]'), '');

    // Empty handling
    if (number.isEmpty) {
      if (required) {
        return 'Phone number is required';
      }

      return null;
    }

    // Length validation
    if (number.length < maxLength) {
      return 'Enter valid phone number';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: .start,
      children: [
        FormWidgets.of(context).titleBuilder(title: title, hint: titleHint),
        TextFormField(
          key: fieldKey,
          focusNode: focusNode,
          textInputAction: textInputAction,
          controller: controller,
          keyboardType: TextInputType.phone,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(maxLength),
          ],
          validator: _validator,
          onChanged: (value) {
            final number = value.replaceAll(RegExp(r'[^0-9]'), '');
            // Return empty when cleared
            if (number.isEmpty) {
              onChanged?.call('');
              return;
            }
            final fullNumber = _getFullNumber(value);
            onChanged?.call(fullNumber);
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: filled ? cs.surfaceContainer : cs.surface,
            hintText: hintText ?? '712345678',
            hintStyle: tt.bodyLarge?.copyWith(color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              // borderSide: BorderSide(color: colorScheme.primaryFixed),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
              // borderSide: BorderSide(color: colorScheme.primaryFixed),
            ),

            prefixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (prefixIcon != null)
                  Container(
                    margin: const EdgeInsets.only(left: 12),
                    child: Icon(prefixIcon),
                  ),
                Container(
                  // width: 70,
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(
                    left: prefixIcon == null ? 18 : 8,
                    right: 8,
                  ),
                  padding: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: cs.outlineVariant),
                    ),
                  ),
                  child: Text(
                    countryCode,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            counterText: '',
          ),
        ),
      ],
    );
  }
}
