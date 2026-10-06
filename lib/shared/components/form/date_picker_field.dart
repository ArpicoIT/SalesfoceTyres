import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'form_widgets.dart';


class DatePickerField extends StatefulWidget {
  final GlobalKey? fieldKey;
  final FocusNode focusNode;

  final String? title;
  final String? titleHint;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;

  final String? Function(String?)? validator;
  final AutovalidateMode? autoValidateMode;

  final bool filled;

  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTime?>? onChanged;
  final bool useSelectedDate;

  const DatePickerField({
    super.key,
    this.fieldKey,
    required this.focusNode,

    this.title,
    this.titleHint,
    this.label,
    this.hint,
    this.prefixIcon = Icons.calendar_month_rounded,

    this.validator,
    this.autoValidateMode,
    this.filled = true,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.onChanged,
    this.useSelectedDate = true,
  });

  @override
  State<DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
  DateTime? _selectedDate;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: widget.useSelectedDate ? _selectedDate : widget.initialDate ?? now,
      firstDate: widget.firstDate ?? DateTime(1900),
      lastDate: widget.lastDate ?? DateTime(2100),
    );

    if (selectedDate == null) return;

    // widget.controller.text = DateFormat('yyyy-MM-dd').format(selectedDate);
    _controller.text = DateFormat('MMM dd, yyyy').format(selectedDate);
    _selectedDate = selectedDate;
    if(mounted) setState(() {});
    widget.onChanged?.call(selectedDate);
  }

  Widget get clearButton => IconButton(
    onPressed: (){
      _controller.clear();
      _selectedDate = null;
      widget.onChanged?.call(null);
    },
    icon: Icon(Icons.cancel),
    style: IconButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        foregroundColor: Colors.grey.shade700
    ),
  );

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
        suffixIcon: _selectedDate != null ? clearButton : null
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        FormWidgets.of(context).titleBuilder(
          title: widget.title,
          hint: widget.titleHint,
        ),
        TextFormField(
          key: widget.fieldKey,
          controller: _controller,
          focusNode: widget.focusNode,
          readOnly: true,
          validator: widget.validator,
          autovalidateMode: widget.autoValidateMode,
          onTap: _selectDate,
          decoration: _decoration,
        ),
      ],
    );
  }
}