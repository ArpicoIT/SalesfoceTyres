import 'package:flutter/material.dart';

typedef SearchKey<T> = String Function(T item);
typedef DisplayText<T> = String Function(T item);

class SearchPicker<T> extends StatefulWidget {
  final List<T> items;
  final T? selectedItem;
  final SearchKey<T> searchKey;
  final DisplayText<T> displayText;
  final ValueChanged<T?> onChanged;
  final String hintText;
  final bool enabled;
  final bool filled;


  const SearchPicker({
    super.key,
    required this.items,
    required this.searchKey,
    required this.displayText,
    required this.onChanged,
    this.selectedItem,
    this.hintText = 'Search',
    this.enabled = true,
    this.filled = true,
  });

  @override
  State<SearchPicker<T>> createState() => _SearchPickerState<T>();
}

class _SearchPickerState<T> extends State<SearchPicker<T>> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.selectedItem != null
          ? widget.displayText(widget.selectedItem as T)
          : '',
    );

    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant SearchPicker<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedItem != oldWidget.selectedItem) {
      _controller.text = widget.selectedItem == null
          ? ''
          : widget.displayText(widget.selectedItem as T);
    }
  }

  void _openBottomSheet({bool autoFocus = false}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _SearchBottomSheet<T>(
        items: widget.items,
        searchKey: widget.searchKey,
        displayText: widget.displayText,
        onSelected: (item) {
          widget.onChanged(item);
          Navigator.pop(context);
        },
        autoFocus: autoFocus,
      ),
    );

    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return TextField(
      controller: _controller,
      readOnly: true,
      enabled: widget.enabled,
      focusNode: _focusNode,
      onTap: () => _openBottomSheet(autoFocus: true),
      decoration: InputDecoration(
        // isDense: true,
        filled: true,
        fillColor: widget.filled ? cs.surfaceContainer : cs.surface,
        hintText: widget.hintText,
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
        prefixIcon: Icon(Icons.search),
        suffixIcon: widget.selectedItem == null
            ? const Icon(Icons.search)
            : IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            widget.onChanged(null);
            _controller.clear();

            /// reopen sheet & focus search
            // Future.delayed(const Duration(milliseconds: 150), () {
            //   _openBottomSheet(autoFocus: true);
            // });
          },
        ),
      ),
    );
  }
}

class _SearchBottomSheet<T> extends StatefulWidget {
  final List<T> items;
  final SearchKey<T> searchKey;
  final DisplayText<T> displayText;
  final ValueChanged<T> onSelected;
  final bool autoFocus;

  const _SearchBottomSheet({
    required this.items,
    required this.searchKey,
    required this.displayText,
    required this.onSelected,
    this.autoFocus = false,
  });

  @override
  State<_SearchBottomSheet<T>> createState() =>
      _SearchBottomSheetState<T>();
}

class _SearchBottomSheetState<T>
    extends State<_SearchBottomSheet<T>> {
  late List<T> _filtered;
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _filtered = widget.items;

    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }

    _searchCtrl.addListener(_filter);
  }

  void _filter() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = widget.items
          .where((e) =>
          widget.searchKey(e).toLowerCase().contains(q))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Search field
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

            /// List
            Flexible(
              child: ListView.builder(
                itemCount: _filtered.length,
                itemBuilder: (_, i) {
                  final item = _filtered[i];
                  return ListTile(
                    title: Text(widget.displayText(item)),
                    onTap: () => widget.onSelected(item),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}




