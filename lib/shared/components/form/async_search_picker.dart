import 'package:flutter/material.dart';
import 'form_widgets.dart';

typedef AsyncItemsLoader<T> = Future<List<T>> Function();
typedef SearchKey<T> = String Function(T item);
typedef DisplayText<T> = String Function(T item);

class AsyncSearchPicker<T> extends StatefulWidget {
  final AsyncItemsLoader<T> loadItems;
  final SearchKey<T> searchKey;
  final DisplayText<T> displayText;
  final ValueChanged<T?> onChanged;
  final T? selectedItem;
  final FocusNode? focusNode;

  final String? title;
  final String? titleHint;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;

  final String emptyText;
  final bool enabled;
  final bool filled;
  final bool searchAutoFocus;

  final String? Function(String?)? validator;
  final AutovalidateMode? autoValidateMode;

  const AsyncSearchPicker({
    super.key,
    required this.loadItems,
    required this.searchKey,
    required this.displayText,
    required this.onChanged,
    this.selectedItem,
    this.focusNode,

    this.title,
    this.titleHint,
    this.label,
    this.hint = 'Search',
    this.prefixIcon,

    this.emptyText = 'No records found',
    this.enabled = true,
    this.filled = true,
    this.searchAutoFocus = false,
    this.validator,
    this.autoValidateMode,
  });

  @override
  State<AsyncSearchPicker<T>> createState() => _AsyncSearchPickerState<T>();
}

class _AsyncSearchPickerState<T> extends State<AsyncSearchPicker<T>> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(
      text: widget.selectedItem != null
          ? widget.displayText(widget.selectedItem as T)
          : '',
    );

    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void didUpdateWidget(covariant AsyncSearchPicker<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedItem != oldWidget.selectedItem) {

      _controller.text = widget.selectedItem != null
          ? widget.displayText(widget.selectedItem as T)
          : '';
    }
  }

  Future<void> _openBottomSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _AsyncSearchBottomSheet<T>(
        loadItems: widget.loadItems,
        searchKey: widget.searchKey,
        displayText: widget.displayText,
        emptyText: widget.emptyText,
        searchAutoFocus: widget.searchAutoFocus,
        onSelected: (item) {
          widget.onChanged(item);
          _controller.text = widget.displayText(item);
          Navigator.pop(context);
        },
      ),
    );

    _focusNode.unfocus();
  }

  Widget get _clearButton => IconButton(
    onPressed: () {
      widget.onChanged(null);
      _controller.clear();
    },
    icon: Icon(Icons.cancel),
    style: IconButton.styleFrom(
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      foregroundColor: Colors.grey.shade700,
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
      prefixIcon: widget.prefixIcon == null
          ? null
          : Icon(widget.prefixIcon, size: 20),
      filled: true,
      fillColor: widget.filled ? cs.surfaceContainerLow : cs.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: border(Colors.transparent),
      enabledBorder: border(cs.outlineVariant.withValues(alpha: 0.6)),
      focusedBorder: border(cs.primary, 1.8),
      errorBorder: border(cs.error),
      focusedErrorBorder: border(cs.error, 1.8),
      counterText: '',
      suffixIcon: widget.selectedItem != null
          ? _clearButton
          : Icon(Icons.select_all_outlined),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        FormWidgets.of(
          context,
        ).titleBuilder(title: widget.title, hint: widget.titleHint),
        TextFormField(
          controller: _controller,
          readOnly: true,
          enabled: widget.enabled,
          focusNode: _focusNode,
          onTap: _openBottomSheet,
          decoration: _decoration,
          validator: widget.validator,
          autovalidateMode: widget.autoValidateMode,
          // decoration: InputDecoration(
          //   filled: true,
          //   fillColor: widget.filled
          //       ? colorScheme.surfaceContainer
          //       : colorScheme.surface,
          //   hintText: widget.hint,
          //   hintStyle: textTheme.bodyLarge?.copyWith(color: Colors.grey),
          //   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          //   enabledBorder: OutlineInputBorder(
          //     borderRadius: BorderRadius.circular(12),
          //     borderSide: BorderSide.none,
          //   ),
          //   // prefixIcon: const Icon(Icons.search),
          //   suffixIcon: widget.selectedItem == null
          //       ? const Icon(Icons.arrow_drop_down)
          //       : IconButton(
          //           icon: const Icon(Icons.cancel),
          //           onPressed: () {
          //             widget.onChanged(null);
          //             _controller.clear();
          //           },
          //           style: IconButton.styleFrom(
          //             tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          //             visualDensity: VisualDensity.compact,
          //             foregroundColor: Colors.grey.shade700,
          //           ),
          //         ),
          // ),
        ),
      ],
    );
  }
}

class _AsyncSearchBottomSheet<T> extends StatefulWidget {
  final AsyncItemsLoader<T> loadItems;
  final SearchKey<T> searchKey;
  final DisplayText<T> displayText;
  final ValueChanged<T> onSelected;
  final String emptyText;
  final bool searchAutoFocus;

  const _AsyncSearchBottomSheet({
    required this.loadItems,
    required this.searchKey,
    required this.displayText,
    required this.onSelected,
    required this.emptyText,
    this.searchAutoFocus = true,
  });

  @override
  State<_AsyncSearchBottomSheet<T>> createState() =>
      _AsyncSearchBottomSheetState<T>();
}

class _AsyncSearchBottomSheetState<T>
    extends State<_AsyncSearchBottomSheet<T>> {
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<T> _items = [];
  List<T> _filtered = [];

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.searchAutoFocus) {
        _focusNode.requestFocus();
      }
    });

    _searchCtrl.addListener(_filter);

    _load();
  }

  Future<void> _load() async {
    try {
      final items = await widget.loadItems();

      if (!mounted) return;

      setState(() {
        _items = items;
        _filtered = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  void _filter() {
    final q = _searchCtrl.text.toLowerCase();

    setState(() {
      _filtered = _items.where((e) {
        return widget.searchKey(e).toLowerCase().contains(q);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (_loading) {
      body = const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    } else if (_error != null) {
      body = Center(
        child: Padding(padding: const EdgeInsets.all(24), child: Text(_error!)),
      );
    } else if (_filtered.isEmpty) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(widget.emptyText),
        ),
      );
    } else {
      body = ListView.builder(
        itemCount: _filtered.length,
        itemBuilder: (_, i) {
          final item = _filtered[i];

          return ListTile(
            title: Text(widget.displayText(item)),
            onTap: () => widget.onSelected(item),
          );
        },
      );
    }

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _searchCtrl,
                  focusNode: _focusNode,
                  decoration: const InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              Expanded(child: body),
            ],
          ),
        ),
      ),
    );
  }
}
