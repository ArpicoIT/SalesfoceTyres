import 'package:flutter/material.dart';

import 'form_widgets.dart';

class PasswordInputField extends StatefulWidget {
  final dynamic fieldKey;
  final TextEditingController? controller;
  final TextEditingController? compareController;
  final String? labelText;
  final String? hintText;
  final bool required;
  final bool showStrengthIndicator;
  final bool isConfirmPassword;
  final FocusNode focusNode;
  final IconData? prefixIcon;
  final TextInputType textInputType;
  final TextInputAction? textInputAction;
  final String? title;
  final String? titleHint;
  final Function(String value)? onChanged;
  final Function()? onCompleted;
  final Function(String)? onSubmitted;
  final bool enableRules;
  final bool filled;

  const PasswordInputField({
    super.key,
    this.fieldKey,
    this.controller,
    this.compareController,
    this.labelText,
    this.hintText,
    this.required = true,
    this.showStrengthIndicator = true,
    this.isConfirmPassword = false,
    this.onChanged,
    required this.focusNode,
    this.prefixIcon,
    this.textInputType = TextInputType.text,
    this.textInputAction,
    this.title,
    this.titleHint,
    this.onCompleted,
    this.onSubmitted,
    this.enableRules = false,
    this.filled = true,
  });

  @override
  State<PasswordInputField> createState() => _PasswordInputFieldState();
}

class _PasswordInputFieldState extends State<PasswordInputField> {
  bool _obscureText = true;
  final int _minLength = 6;

  bool _hasMinLength(String value) => value.length >= _minLength;

  bool _hasUppercase(String value) => RegExp(r'[A-Z]').hasMatch(value);

  bool _hasLowercase(String value) => RegExp(r'[a-z]').hasMatch(value);

  bool _hasNumber(String value) => RegExp(r'[0-9]').hasMatch(value);

  bool _hasSpecialChar(String value) =>
      RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value);

  String? _validator(String? value) {
    value ??= '';

    if (widget.required && value.isEmpty) {
      return widget.isConfirmPassword
          ? 'Confirm password is required'
          : 'Password is required';
    }

    // Confirm Password Validation
    if (widget.isConfirmPassword) {
      if (value != widget.compareController?.text) {
        return 'Passwords do not match';
      }

      return null;
    }

    if (!widget.enableRules) {
      return null;
    }

    // Password Validation
    if (!_hasMinLength(value)) {
      return 'Minimum $_minLength characters required';
    }

    if (!_hasUppercase(value)) {
      return 'Include at least one uppercase letter';
    }

    if (!_hasLowercase(value)) {
      return 'Include at least one lowercase letter';
    }

    if (!_hasNumber(value)) {
      return 'Include at least one number';
    }

    if (!_hasSpecialChar(value)) {
      return 'Include at least one special character';
    }

    return null;
  }

  double _passwordStrength(String value) {
    double strength = 0;

    if (_hasMinLength(value)) strength += 0.2;
    if (_hasUppercase(value)) strength += 0.2;
    if (_hasLowercase(value)) strength += 0.2;
    if (_hasNumber(value)) strength += 0.2;
    if (_hasSpecialChar(value)) strength += 0.2;

    return strength;
  }

  Color _strengthColor(double strength) {
    if (strength <= 0.2) return Colors.red;
    if (strength <= 0.4) return Colors.orange;
    if (strength <= 0.6) return Colors.yellow.shade700;
    if (strength <= 0.8) return Colors.lightGreen;
    return Colors.green;
  }

  String _strengthText(double strength) {
    if (strength <= 0.2) return 'Weak';
    if (strength <= 0.4) return 'Fair';
    if (strength <= 0.6) return 'Good';
    if (strength <= 0.8) return 'Strong';
    return 'Very Strong';
  }

  @override
  Widget build(BuildContext context) {
    final password = widget.controller?.text ?? '';
    final hasTyped = password.isNotEmpty;
    final strength = _passwordStrength(password);

    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: .start,
      children: [
        FormWidgets.of(context).titleBuilder(
          title: widget.title,
          hint: widget.titleHint,
        ),
        TextFormField(
          key: widget.fieldKey,
          controller: widget.controller,
          focusNode: widget.focusNode,

          obscureText: _obscureText,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: _validator,
          onChanged: (value) {
            setState(() {});
            widget.onChanged?.call(value);
          },
          onEditingComplete: widget.onCompleted,
          onFieldSubmitted: widget.onSubmitted,
          // obscuringCharacter: '*',
          textInputAction: widget.textInputAction,
          keyboardType: widget.textInputType,
          decoration: InputDecoration(
            filled: true,
            fillColor: widget.filled ? cs.surfaceContainer : cs.surface,
            hintStyle: tt.bodyLarge?.copyWith(color: Colors.grey),
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon)
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              // borderSide: BorderSide(color: colorScheme.primaryFixed),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
              // borderSide: BorderSide(color: colorScheme.primaryFixed),
            ),

            hintText:
                widget.hintText ??
                (widget.isConfirmPassword
                    ? 'Re-enter your password'
                    : 'Enter your password'),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
              icon: Icon(
                _obscureText ? Icons.visibility_off : Icons.visibility,
              ),
            ),
          ),
        ),

        // Show strength only for password field
        if (!widget.isConfirmPassword &&
            widget.showStrengthIndicator &&
            hasTyped) ...[
          const SizedBox(height: 12),

          LinearProgressIndicator(
            value: strength,
            minHeight: 6,
            borderRadius: BorderRadius.circular(10),
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation(_strengthColor(strength)),
          ),

          const SizedBox(height: 6),

          Text(
            _strengthText(strength),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: _strengthColor(strength),
            ),
          ),

          // const SizedBox(height: 10),
          //
          // Wrap(
          //   spacing: 8,
          //   runSpacing: 8,
          //   children: [
          //     _buildRule(
          //       '8+ Characters',
          //       _hasMinLength(password),
          //     ),
          //     _buildRule(
          //       'Uppercase',
          //       _hasUppercase(password),
          //     ),
          //     _buildRule(
          //       'Lowercase',
          //       _hasLowercase(password),
          //     ),
          //     _buildRule(
          //       'Number',
          //       _hasNumber(password),
          //     ),
          //     _buildRule(
          //       'Special Character',
          //       _hasSpecialChar(password),
          //     ),
          //   ],
          // ),
        ],
      ],
    );
  }

  // Widget _buildRule(String text, bool valid) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(
  //       horizontal: 10,
  //       vertical: 6,
  //     ),
  //     decoration: BoxDecoration(
  //       color: valid
  //           ? Colors.green.withValues(alpha: 0.1)
  //           : Colors.red.withValues(alpha: 0.1),
  //       borderRadius: BorderRadius.circular(20),
  //       border: Border.all(
  //         color: valid
  //             ? Colors.green
  //             : Colors.red,
  //       ),
  //     ),
  //     child: Row(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         Icon(
  //           valid
  //               ? Icons.check_circle
  //               : Icons.cancel,
  //           size: 16,
  //           color:
  //           valid ? Colors.green : Colors.red,
  //         ),
  //         const SizedBox(width: 5),
  //         Text(
  //           text,
  //           style: TextStyle(
  //             fontSize: 12,
  //             color: valid
  //                 ? Colors.green
  //                 : Colors.red,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
