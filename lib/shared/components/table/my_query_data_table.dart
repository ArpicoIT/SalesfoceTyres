import 'dart:math';
import 'package:flutter/material.dart';

import 'package:data_table_2/data_table_2.dart';

import '../../enum.dart';

// ─────────────────────────────────────────────────────────────────────────────
// COLUMN CONFIG
// ─────────────────────────────────────────────────────────────────────────────

class TableColumnConfig {
  final String key;
  final String title;
  final double? width;
  final bool sortable;
  final bool numeric;
  final String Function(dynamic value)? formatter;
  final AlignmentGeometry? alignment;
  final TextStyle? textStyle;

  const TableColumnConfig({
    required this.key,
    required this.title,
    this.width,
    this.sortable = true,
    this.numeric = false,
    this.formatter,
    this.alignment,
    this.textStyle,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// SELECTION WRAPPER
// ─────────────────────────────────────────────────────────────────────────────

class _Selection<T> {
  T model;
  Map<String, dynamic> data;
  bool selected;

  _Selection(this.model, this.data, {this.selected = false});
}

// ─────────────────────────────────────────────────────────────────────────────
// DATA SOURCE
// ─────────────────────────────────────────────────────────────────────────────

class _Source<T> extends DataTableSource {
  final String? uniqueKey;
  final BuildContext context;
  final List<TableColumnConfig> columns;
  final Map<String, dynamic> Function(T item) toMap;

  final void Function(T row, bool selected)? onTap;
  final void Function(T row, bool selected)? onDoubleTap;
  final void Function(T row, bool selected)? onLongPress;
  final void Function(List<T> rows)? onMultiSelectChanged;
  final void Function(T? row)? onSingleSelectChanged;
  final RowStatus Function(T row)? fnRowStatus;

  late List<_Selection<T>> _items;
  int _selectedCount = 0;
  late final bool _isMultiSelect;
  late final bool _isSingleSelect;
  final bool leadingColumn;

  _Source({
    required this.uniqueKey,
    required this.context,
    required List<T> items,
    required this.columns,
    required this.toMap,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onMultiSelectChanged,
    this.onSingleSelectChanged,
    this.fnRowStatus,
    this.leadingColumn = true
  }) {
    _items = items.map((e) => _Selection<T>(e, toMap(e))).toList();
    _isMultiSelect = onMultiSelectChanged != null;
    _isSingleSelect = onMultiSelectChanged == null && onSingleSelectChanged != null;
  }

  // ── Mutation helpers ──────────────────────────────────────────────────────

  void resetItems(List<T> items) {
    _items = items.map((e) => _Selection<T>(e, toMap(e))).toList();
    _selectedCount = 0;
    notifyListeners();
  }

  void updateItems(List<T> items) {
    final List<_Selection<T>> next = [];

    if (uniqueKey != null) {
      final Map<dynamic, _Selection<T>> oldMap = {
        for (final row in _items) row.data[uniqueKey]: row,
      };
      for (final item in items) {
        final mapped = toMap(item);
        final key = mapped[uniqueKey];
        if (oldMap.containsKey(key)) {
          final existing = oldMap[key]!
            ..model = item
            ..data = mapped;
          next.add(existing);
        } else {
          next.add(_Selection<T>(item, mapped));
        }
      }
    } else {
      for (int i = 0; i < items.length; i++) {
        final mapped = toMap(items[i]);
        if (i < _items.length) {
          _items[i]
            ..model = items[i]
            ..data = mapped;
          next.add(_items[i]);
        } else {
          next.add(_Selection<T>(items[i], mapped));
        }
      }
    }

    _items = next;
    _selectedCount = _items.where((e) => e.selected).length;
    notifyListeners();
  }

  void sort(String key, bool ascending) {
    _items.sort((a, b) {
      final av = a.data[key];
      final bv = b.data[key];
      if (av == null && bv == null) return 0;
      if (av == null) return 1;
      if (bv == null) return -1;
      return ascending
          ? Comparable.compare(av, bv)
          : Comparable.compare(bv, av);
    });
    notifyListeners();
  }

  void search(String query, List<T> originalItems) {
    final q = query.toLowerCase().trim();
    _items = (q.isEmpty ? originalItems : originalItems.where((item) {
      final mapped = toMap(item);
      return mapped.values.any((v) => v.toString().toLowerCase().contains(q));
    }))
        .map((e) => _Selection<T>(e, toMap(e)))
        .toList();
    _selectedCount = _items.where((e) => e.selected).length;
    notifyListeners();
  }

  // ── Selection helpers ─────────────────────────────────────────────────────

  void _toggleMultiSelect(_Selection<T> item) {
    item.selected = !item.selected;
    _selectedCount = _items.where((e) => e.selected).length;
    onMultiSelectChanged?.call(
      _items.where((e) => e.selected).map((e) => e.model).toList(),
    );
    notifyListeners();
  }

  void _toggleSingleSelect(_Selection<T> item) {
    final wasSelected = item.selected;
    for (final e in _items) {
      e.selected = false;
    }
    if (!wasSelected) {
      item.selected = true;
      onSingleSelectChanged?.call(item.model);
    } else {
      onSingleSelectChanged?.call(null);
    }
    notifyListeners();
  }

  // ── Cell colour resolution ────────────────────────────────────────────────

  Color _resolveCellColor(
      BuildContext context, {
        required bool isSelected,
        required bool isDisabled,
        required Color? defaultColor,
        required Color selectedColor,
      }) {
    final base = defaultColor ?? Theme.of(context).colorScheme.onSurface;
    if (isDisabled) return Color.lerp(base, Colors.grey, 0.6)!;
    if (isSelected) return Color.lerp(base, selectedColor, 0.35)!;
    return base;
  }

  // ── DataTableSource overrides ─────────────────────────────────────────────

  @override
  DataRow2 getRow(int index) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final selectedBg = cs.primaryContainer;

    final item = _items[index];
    final status = fnRowStatus?.call(item.model) ?? RowStatus.ENA;
    final isDisabled = status == RowStatus.DIS;
    final isLocked = status == RowStatus.LCK;

    List<DataCell> cells = [];

    if (leadingColumn) {
      cells.add(DataCell(_buildLeadingCell(item, status)));
    }

    cells.addAll(
        columns.map((col) {
          final rawValue = item.data[col.key];
          final text = col.formatter != null
              ? col.formatter!(rawValue)
              : rawValue?.toString() ?? '';

          return DataCell(
            Align(
              alignment: col.numeric
                  ? Alignment.centerRight
                  : col.alignment ?? Alignment.centerLeft,
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: (col.textStyle ?? const TextStyle()).copyWith(
                  color: _resolveCellColor(
                    context,
                    isSelected: item.selected,
                    isDisabled: isDisabled,
                    defaultColor: col.textStyle?.color,
                    selectedColor: selectedBg,
                  ),
                ),
              ),
            ),
          );
        }).toList()
    );

    // isLocked ? WidgetStateProperty.all(Colors.red.withRed(1)) :

    return DataRow2.byIndex(
      index: index,
      selected: item.selected,
      color: item.selected
          ? WidgetStateProperty.all(selectedBg)
          : WidgetStateColor.transparent,
      onLongPress: isDisabled ? null : () => onLongPress?.call(item.model, item.selected),
      onTap: isDisabled
          ? null
          : isLocked
          ? () => onTap?.call(item.model, item.selected)
          : _isMultiSelect
          ? () => _toggleMultiSelect(item)
          : _isSingleSelect
          ? () => _toggleSingleSelect(item)
          : () => onTap?.call(item.model, item.selected),
      onDoubleTap: isDisabled
          ? null
          : () => onDoubleTap?.call(item.model, item.selected),
      cells: cells,
    );
  }

  Widget _buildLeadingCell(_Selection<T> item, RowStatus status) {
    switch (status) {
      case RowStatus.LCK:
        return const Icon(Icons.lock_rounded, size: 16, color: Colors.redAccent);
      case RowStatus.DIS:
        return Icon(Icons.block_rounded, size: 16, color: Colors.grey.shade400);
      case RowStatus.UNL:
        return Icon(Icons.lock_open, size: 16, color: Colors.green);
      default:
        if (_isMultiSelect) {
          return GestureDetector(
            onTap: () => _toggleMultiSelect(item),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: Icon(
                item.selected
                    ? Icons.check_box_rounded
                    : Icons.check_box_outline_blank_rounded,
                key: ValueKey(item.selected),
                size: 18,
                color: item.selected ? Colors.blue : Colors.grey.shade400,
              ),
            ),
          );
        }
        if (_isSingleSelect && item.selected) {
          return const Icon(Icons.radio_button_checked_rounded,
              size: 18, color: Colors.blue);
        }
        return const SizedBox.shrink();
    }
  }

  @override
  int get rowCount => _items.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}

// ─────────────────────────────────────────────────────────────────────────────
// ComModelDataTable  (generic, key-based paginated data table)
// ─────────────────────────────────────────────────────────────────────────────

class ComModelDataTable<T> extends StatefulWidget {
  final String? uniqueKey;

  /// The list of model items to display.
  final List<T> items;

  /// Converts a model item to its map representation used for rendering.
  final Map<String, dynamic> Function(T item) toMap;

  final List<TableColumnConfig> columns;
  final BoxConstraints? constraints;
  final TextEditingController? searchController;
  final int initialRowsPerPage;
  final double? minWidth;

  final void Function(T row, bool selected)? onTap;
  final void Function(T row, bool selected)? onDoubleTap;
  final void Function(T row, bool selected)? onLongPress;
  final void Function(List<T> rows)? onMultiSelectChanged;
  final void Function(T? row)? onSingleSelectChanged;
  final RowStatus Function(T row)? fnRowStatus;

  final bool showSearchBar;
  final bool hidePaginator;
  final bool fixedHeight;
  final bool leadingColumn;

  const ComModelDataTable({
    super.key,
    required this.uniqueKey,
    required this.items,
    required this.toMap,
    required this.columns,
    this.constraints,
    this.searchController,
    this.initialRowsPerPage = 10,
    this.minWidth,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onMultiSelectChanged,
    this.onSingleSelectChanged,
    this.fnRowStatus,
    this.showSearchBar = true,
    this.hidePaginator = false,
    this.fixedHeight = false,
    this.leadingColumn = true,
  });

  @override
  State<ComModelDataTable<T>> createState() => ComModelDataTableState<T>();
}

class ComModelDataTableState<T> extends State<ComModelDataTable<T>>
    with AutomaticKeepAliveClientMixin {
  late _Source<T> _source;
  late TextEditingController _searchController;
  int _rowsPerPage = 10;
  int? _sortColumnIndex;
  bool _sortAscending = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _rowsPerPage = widget.initialRowsPerPage;
    _searchController = widget.searchController ?? TextEditingController();

    _source = _Source<T>(
      uniqueKey: widget.uniqueKey,
      context: context,
      items: widget.items,
      columns: widget.columns,
      toMap: widget.toMap,
      onTap: widget.onTap,
      onDoubleTap: widget.onDoubleTap,
      onLongPress: widget.onLongPress,
      onMultiSelectChanged: widget.onMultiSelectChanged,
      onSingleSelectChanged: widget.onSingleSelectChanged,
      fnRowStatus: widget.fnRowStatus,
      leadingColumn: widget.leadingColumn
    );

    _searchController.addListener(
          () => _source.search(_searchController.text, widget.items),
    );

    _searchController.addListener((){
      /// reset selected rows during searching
    });
  }

  @override
  void didUpdateWidget(covariant ComModelDataTable<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _source.updateItems(widget.items);
    }
  }

  // Public API
  void resetItems() => _source.resetItems(widget.items);

  // ── Column headers ────────────────────────────────────────────────────────

  List<DataColumn2> _buildColumns() {
    late List<DataColumn2> columns = [];

    if (widget.leadingColumn) {
      columns.add(DataColumn2(
        label: const SizedBox.shrink(),
        fixedWidth: 36,
        size: ColumnSize.S,
        minWidth: 0,
      ));
    }
    columns.addAll(widget.columns.asMap().entries.map((entry) {
      final index = entry.key;
      final col = entry.value;

      return DataColumn2(
        label: Align(
          alignment: col.numeric
              ? Alignment.centerRight
              : col.alignment ?? Alignment.centerLeft,
          child: Text(col.title),
        ),
        fixedWidth: col.width,
        numeric: col.numeric,
        isResizable: true,
        onSort: col.sortable
            ? (_, asc) {
          _source.sort(col.key, asc);
          setState(() {
            _sortColumnIndex = index;
            _sortAscending = asc;
          });
        }
            : null,
      );
    }).toList());

    return columns;
  }

  // ── Table body ────────────────────────────────────────────────────────────

  Widget _buildTable(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // final isDark = Theme.of(context).brightness == Brightness.dark;
    // final headerBg = isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade50;
    // final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    // final dividerColor = isDark ? Colors.white12 : Colors.black45;

    return LayoutBuilder(
      builder: (context, cns) => PaginatedDataTable2(
        datarowCheckboxTheme: CheckboxThemeData(),
        wrapInCard: false,
        source: _source,
        columns: _buildColumns(),
        rowsPerPage: _rowsPerPage,
        availableRowsPerPage: const [5, 10, 20, 50, 100],
        onRowsPerPageChanged: (v) => setState(() => _rowsPerPage = v ?? _rowsPerPage),
        sortColumnIndex: _sortColumnIndex,
        sortAscending: _sortAscending,
        showCheckboxColumn: false,
        empty: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.table_rows_outlined,
                    size: 36, color: Colors.grey.shade400),
                const SizedBox(height: 8),
                Text(
                  'No records found',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
        columnSpacing: 12,
        horizontalMargin: 12,
        minWidth: widget.minWidth ?? cns.maxWidth,
        renderEmptyRowsInTheEnd: false,
        headingRowDecoration: BoxDecoration(
          color: cs.primary,
          // border: Border(
          //   bottom: BorderSide(color: dividerColor, width: 1),
          // ),
        ),
        headingTextStyle: TextStyle(
          fontSize: 12,
          color: cs.onPrimary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
        dataTextStyle: TextStyle(
          fontSize: 12.5,
          // color: cs.onSurface,
          height: 1.4,
        ),
        dataRowHeight: 44,
        headingRowHeight: 48,
        hidePaginator: widget.hidePaginator,
      ),
    );
  }

  // ── Search bar ────────────────────────────────────────────────────────────

  Widget _buildSearchBar(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          isDense: true,
          hintText: 'Search…',
          hintStyle: TextStyle(
            fontSize: 13,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 18,
          ),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _searchController,
            builder: (_, val, _) => val.text.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.close_rounded, size: 16),
              splashRadius: 14,
              onPressed: _searchController.clear,
            )
                : const SizedBox.shrink(),
          ),
          contentPadding:
          const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          filled: true,
          fillColor: cs.surface
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    super.build(context);

    const headingRowHeight = 48.0;
    const rowHeight = 44.0;
    final effectiveHeight = max(
      ((widget.showSearchBar ? 60.0 : 0.0) +
          headingRowHeight +
          (widget.hidePaginator ? 0.0 : 56.0) +
          rowHeight * _rowsPerPage)
          .ceil()
          .toDouble(),
      320.0,
    );

    final child = widget.showSearchBar
        ? Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSearchBar(context),
        Expanded(child: _buildTable(context)),
      ],
    )
        : _buildTable(context);

    return Container(
      constraints: widget.fixedHeight
          ? BoxConstraints(
        minWidth: widget.constraints?.minWidth ?? 0,
        maxWidth: widget.constraints?.maxWidth ?? double.infinity,
        minHeight: min(widget.constraints?.minHeight ?? 320, effectiveHeight),
        maxHeight: effectiveHeight,
      )
          : widget.constraints,
      child: child,
    );
  }

  @override
  void dispose() {
    // Only dispose the controller if we created it ourselves
    if (widget.searchController == null) _searchController.dispose();
    _source.dispose();
    super.dispose();
  }
}