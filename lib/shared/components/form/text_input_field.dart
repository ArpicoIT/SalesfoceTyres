
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'form_widgets.dart';

class TextInputField extends StatefulWidget {
  final dynamic fieldKey;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? hint;
  final IconData? prefixIcon;
  final TextInputType textInputType;
  final TextInputAction? textInputAction;

  final String? Function(String?)? validator;
  final AutovalidateMode? autoValidateMode;
  final Function()? onCompleted;
  final Function(String)? onSubmitted;
  final bool filled;

  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final int? minLines;
  final int? maxLines;
  final bool isNumeric;
  final Function()? onTap;

  /// remove
  final String? title;
  final String? titleHint;

  /// new
  final String? label;

  const TextInputField({
    super.key,
    this.fieldKey,
    required this.controller,
    required this.focusNode,
    this.hint,
    this.prefixIcon,
    this.textInputType = TextInputType.text,
    this.textInputAction,
    this.title,
    this.titleHint,
    this.validator,
    this.autoValidateMode,
    this.onCompleted,
    this.onSubmitted,
    this.filled = true,
    this.inputFormatters,
    this.maxLength,
    this.minLines,
    this.maxLines,
    this.isNumeric = false,
    this.onTap,
    this.label,
  });


  @override
  State<TextInputField> createState() => _TextInputFieldState();
}

class _TextInputFieldState extends State<TextInputField> {
  Widget? _clearButton;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      widget.controller.addListener((){
        final value = widget.controller.text;
        if(value.isNotEmpty && double.tryParse(value) != 0.00){
          _clearButton = IconButton(
            onPressed: widget.controller.clear,
            icon: Icon(Icons.cancel),
            style: IconButton.styleFrom(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                foregroundColor: Colors.grey.shade700
            ),
          );
        } else {
          _clearButton = null;
        }
        if(mounted) setState(() {});
      });
    });
  }

  InputDecoration get _decoration {
    final cs = Theme.of(context).colorScheme;
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: c, width: w),
    );
    return InputDecoration(
      labelText: widget.label,
      hintText: widget.hint,
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
          textInputAction: widget.textInputAction,
          keyboardType: widget.isNumeric ? TextInputType.number : widget.textInputType,
          validator: widget.validator,
          onTap: widget.onTap,
          autovalidateMode: widget.autoValidateMode,
          onEditingComplete: widget.onCompleted,
          onFieldSubmitted: widget.onSubmitted,
          inputFormatters: widget.inputFormatters,
          maxLength: widget.maxLength,
          maxLines: widget.maxLines,
          minLines: widget.minLines,

          decoration: _decoration,
          // style: tt.bodyLarge,
          // textAlign: widget.isNumeric ? .end : .start,
          // decoration: InputDecoration(
          //   // isDense: true,
          //   filled: true,
          //   fillColor: widget.filled ? cs.surfaceContainer : cs.surface,
          //   labelText: widget.label,
          //   hintText: widget.hintText,
          //   prefixIcon: widget.prefixIcon != null
          //       ? Icon(widget.prefixIcon)
          //       : null,
          //   hintStyle: tt.bodyLarge?.copyWith(color: Colors.grey),
          //   // labelText: widget.title,
          //   border: OutlineInputBorder(
          //     borderRadius: BorderRadius.circular(12),
          //     // borderSide: BorderSide(color: colorScheme.primaryFixed),
          //   ),
          //   enabledBorder: OutlineInputBorder(
          //     borderRadius: BorderRadius.circular(12),
          //     borderSide: BorderSide.none,
          //     // borderSide: BorderSide(color: colorScheme.primaryFixed),
          //   ),
          //   // counterText: widget.isNumeric ? '' : null,
          //   counterText: '',
          //   suffixIcon: _clearButton
          // ),
        ),
      ],
    );
  }
}

