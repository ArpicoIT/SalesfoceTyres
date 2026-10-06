
import 'package:flutter/material.dart';

typedef ModelListItemBuilder<T> = Widget Function(
    BuildContext context,
    T item,
    bool selected,
    );

typedef ModelListSearchMatcher<T> = bool Function(
    T item,
    String query,
    );

class ModelListView<T> extends StatefulWidget {
  /// The complete list loaded by the parent.
  final List<T> items;

  final ModelListItemBuilder<T> itemBuilder;

  final Widget Function(
      BuildContext context,
      int index,
      ) separatorBuilder;

  /// Used to preserve multi-selection when the visible list changes.
  final dynamic Function(T item)? uniqueKey;

  /// Determines whether an item can be selected.
  final bool Function(T item)? canSelect;

  final void Function(T item, bool selected)? onTap;

  final void Function(T item, bool selected)? onDoubleTap;

  final void Function(T item, bool selected)? onLongPress;

  final void Function(List<T> items)? onMultiSelectChanged;

  final void Function(T? item)? onSingleSelectChanged;

  final bool singleSelect;
  final bool multiSelect;
  final bool useSelectionOrder;

  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final Widget? emptyWidget;
  final ScrollController? controller;
  final bool isExpanded;

  // ─────────────────────────────────────────────────────────────────────────
  // HEADER
  // ─────────────────────────────────────────────────────────────────────────

  final String? title;
  final String? subtitle;
  final Widget? titleWidget;

  // ─────────────────────────────────────────────────────────────────────────
  // SEARCH
  // ─────────────────────────────────────────────────────────────────────────

  final bool enableSearch;

  final String searchHint;

  /// Required when [enableSearch] is true.
  final ModelListSearchMatcher<T>? searchMatcher;

  final ValueChanged<String>? onSearchChanged;

  // ─────────────────────────────────────────────────────────────────────────
  // PAGINATION
  // ─────────────────────────────────────────────────────────────────────────

  final bool enablePagination;

  final int initialPageSize;

  final List<int> pageSizeOptions;

  final bool clearSelection;

  const ModelListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.separatorBuilder,
    this.uniqueKey,
    this.canSelect,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onMultiSelectChanged,
    this.onSingleSelectChanged,
    this.singleSelect = false,
    this.multiSelect = false,
    this.useSelectionOrder = true,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
    this.emptyWidget,
    this.controller,
    this.isExpanded = false,

    // Header
    this.title,
    this.subtitle,
    this.titleWidget,

    // Search
    this.enableSearch = false,
    this.searchHint = 'Search...',
    this.searchMatcher,
    this.onSearchChanged,

    // Pagination
    this.enablePagination = true,
    this.initialPageSize = 5,
    this.pageSizeOptions = const [5, 10, 25, 50, 100],

    // Selection
    this.clearSelection = false,
  })  : assert(
  !(singleSelect && multiSelect),
  'singleSelect and multiSelect cannot both be true.',
  ),
        assert(
        !enableSearch || searchMatcher != null,
        'searchMatcher must be provided when enableSearch is true.',
        ),
        assert(
        initialPageSize > 0,
        'initialPageSize must be greater than zero.',
        );

  @override
  State<ModelListView<T>> createState() => ModelListViewState<T>();
}

class ModelListViewState<T> extends State<ModelListView<T>> {
  // ─────────────────────────────────────────────────────────────────────────
  // ORIGINAL / FILTERED DATA
  // ─────────────────────────────────────────────────────────────────────────

  late List<T> _filteredItems;

  // ─────────────────────────────────────────────────────────────────────────
  // SEARCH
  // ─────────────────────────────────────────────────────────────────────────

  late final TextEditingController _searchController;
  late final FocusNode _searchFocus;
  late final FocusNode _dropdownFocus;

  String _searchQuery = '';

  // ─────────────────────────────────────────────────────────────────────────
  // PAGINATION
  // ─────────────────────────────────────────────────────────────────────────

  late int _currentPage;

  late int _pageSize;

  // ─────────────────────────────────────────────────────────────────────────
  // SELECTION
  // ─────────────────────────────────────────────────────────────────────────

  final Set<dynamic> _selectedKeys = {};

  dynamic _selectedSingleKey;

  // ─────────────────────────────────────────────────────────────────────────
  // GETTERS
  // ─────────────────────────────────────────────────────────────────────────

  bool get isSingleSelect => widget.singleSelect;

  bool get isMultiSelect => widget.multiSelect;

  bool get hasSelection => isSingleSelect || isMultiSelect;

  int get totalItems => _filteredItems.length;

  int get totalPages {
    if (!widget.enablePagination) {
      return 1;
    }

    if (_filteredItems.isEmpty) {
      return 1;
    }

    return (_filteredItems.length / _pageSize).ceil();
  }

  List<T> get _visibleItems {
    if (!widget.enablePagination) {
      return _filteredItems;
    }

    if (_filteredItems.isEmpty) {
      return [];
    }

    final startIndex = (_currentPage - 1) * _pageSize;

    if (startIndex >= _filteredItems.length) {
      return [];
    }

    final endIndex = (startIndex + _pageSize)
        .clamp(0, _filteredItems.length);

    return _filteredItems.sublist(
      startIndex,
      endIndex,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // INIT
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    _filteredItems = [];
    // _filteredItems = List<T>.from(widget.items);

    _currentPage = 1;

    _pageSize = widget.initialPageSize;

    _searchController = TextEditingController();

    _searchFocus = FocusNode();
    _dropdownFocus = FocusNode();

    _refreshItems(
      resetPage: true,
      clearSelection: false,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // UPDATE
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void didUpdateWidget(
      covariant ModelListView<T> oldWidget,
      ) {
    super.didUpdateWidget(oldWidget);

    if (!identical(oldWidget.items, widget.items)) {
      _refreshItems(
        resetPage: false,
        clearSelection: false,
      );
    }

    if (oldWidget.initialPageSize != widget.initialPageSize) {
      _pageSize = widget.initialPageSize;
      _syncSelection();
      _ensureValidPage();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DISPOSE
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DISPOSE
  // ─────────────────────────────────────────────────────────────────────────

  void unfocus() {
    if(context.mounted) {
      _searchFocus.unfocus();
      _dropdownFocus.unfocus();
      FocusScope.of(context).unfocus();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // REFRESH
  // ─────────────────────────────────────────────────────────────────────────

  void refresh() {
    _refreshItems(
      resetPage: false,
      clearSelection: false,
    );
    debugPrint('Model List View: Refresh items');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // UPDATE
  // ─────────────────────────────────────────────────────────────────────────

  // ─────────────────────────────────────────────────────────────────────────
  // KEY
  // ─────────────────────────────────────────────────────────────────────────

  dynamic _getKey(
      T item,
      int originalIndex,
      ) {
    return widget.uniqueKey?.call(item) ?? originalIndex;
  }

  int _getOriginalIndex(T item) {
    return widget.items.indexOf(item);
  }

  dynamic _getItemKey(T item) {
    final index = _getOriginalIndex(item);

    return _getKey(item, index);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SELECTABLE
  // ─────────────────────────────────────────────────────────────────────────

  bool _canSelect(T item) {
    return widget.canSelect?.call(item) ?? true;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SELECTED
  // ─────────────────────────────────────────────────────────────────────────

  bool _isSelected(T item) {
    if (!_canSelect(item)) {
      return false;
    }

    final key = _getItemKey(item);

    if (isSingleSelect) {
      return _selectedSingleKey == key;
    }

    if (isMultiSelect) {
      return _selectedKeys.contains(key);
    }

    return false;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TOGGLE
  // ─────────────────────────────────────────────────────────────────────────

  void _toggleSelection(T item) {
    if (!_canSelect(item)) {
      return;
    }

    if (isMultiSelect) {
      _toggleMultiSelection(item);
    } else if (isSingleSelect) {
      _toggleSingleSelection(item);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MULTI SELECT
  // ─────────────────────────────────────────────────────────────────────────

  void _toggleMultiSelection(T item) {
    final key = _getItemKey(item);

    setState(() {
      if (_selectedKeys.contains(key)) {
        _selectedKeys.remove(key);
      } else {
        _selectedKeys.add(key);
      }
    });

    _notifyMultiSelection();
  }

  void _notifyMultiSelection() {
    final selectedItems = <T>[];

    if (widget.useSelectionOrder) {
      for (final key in _selectedKeys) {
        for (final item in widget.items) {
          if (_getItemKey(item) == key && _canSelect(item)) {
            selectedItems.add(item);
            break;
          }
        }
      }
    } else {
      for (final item in widget.items) {
        if (!_canSelect(item)) {
          continue;
        }

        if (_selectedKeys.contains(_getItemKey(item))) {
          selectedItems.add(item);
        }
      }
    }

    widget.onMultiSelectChanged?.call(selectedItems);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SINGLE SELECT
  // ─────────────────────────────────────────────────────────────────────────

  void _toggleSingleSelection(T item) {
    final key = _getItemKey(item);

    final wasSelected = _selectedSingleKey == key;

    setState(() {
      _selectedSingleKey = wasSelected ? null : key;
    });

    widget.onSingleSelectChanged?.call(
      wasSelected ? null : item,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TAP
  // ─────────────────────────────────────────────────────────────────────────

  void _handleTap(T item) {
    final selectedBeforeTap = _isSelected(item);

    if (hasSelection) {
      _toggleSelection(item);
    }

    widget.onTap?.call(
      item,
      selectedBeforeTap,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DOUBLE TAP
  // ─────────────────────────────────────────────────────────────────────────

  void _handleDoubleTap(T item) {
    widget.onDoubleTap?.call(
      item,
      _isSelected(item),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // LONG PRESS
  // ─────────────────────────────────────────────────────────────────────────

  void _handleLongPress(T item) {
    widget.onLongPress?.call(
      item,
      _isSelected(item),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CLEAR SELECTION
  // ─────────────────────────────────────────────────────────────────────────

  void clearSelection() {
    final hadMultiSelection = _selectedKeys.isNotEmpty;

    final hadSingleSelection =
        _selectedSingleKey != null;

    setState(() {
      _selectedKeys.clear();
      _selectedSingleKey = null;
    });

    if (hadMultiSelection && isMultiSelect) {
      widget.onMultiSelectChanged?.call([]);
    }

    if (hadSingleSelection && isSingleSelect) {
      widget.onSingleSelectChanged?.call(null);
    }

    debugPrint('Model List View: Clear items');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SELECT ALL
  // ─────────────────────────────────────────────────────────────────────────

  void selectAll() {
    if (!isMultiSelect) {
      return;
    }

    setState(() {
      _selectedKeys.clear();

      for (final item in _filteredItems) {
        if (_canSelect(item)) {
          _selectedKeys.add(
            _getItemKey(item),
          );
        }
      }
    });

    _notifyMultiSelection();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SELECT ITEM
  // ─────────────────────────────────────────────────────────────────────────

  void selectItem(T item) {
    if (!isSingleSelect) {
      return;
    }

    if (!_canSelect(item)) {
      return;
    }

    final key = _getItemKey(item);

    setState(() {
      _selectedSingleKey = key;
    });

    widget.onSingleSelectChanged?.call(item);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SEARCH
  // ─────────────────────────────────────────────────────────────────────────

  void _handleSearchChanged(String value) {
    _applySearch(
      value,
      clearSelection: widget.clearSelection,
    );

    widget.onSearchChanged?.call(value);
  }

  void _applySearch(
      String value, {
        required bool clearSelection,
      }) {
    final query = value.trim();

    final newFilteredItems = query.isEmpty
        ? List<T>.from(widget.items)
        : widget.items
        .where(
          (item) => widget.searchMatcher!(
        item,
        query,
      ),
    )
        .toList();

    setState(() {
      _searchQuery = value;

      _filteredItems = newFilteredItems;

      _currentPage = 1;

      if (clearSelection) {
        _selectedKeys.clear();
        _selectedSingleKey = null;
      }
    });

    if (clearSelection) {
      if (isMultiSelect) {
        widget.onMultiSelectChanged?.call([]);
      }

      if (isSingleSelect) {
        widget.onSingleSelectChanged?.call(null);
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PAGE
  // ─────────────────────────────────────────────────────────────────────────

  void _changePage(int page) {
    final safePage = page.clamp(
      1,
      totalPages,
    );

    if (safePage == _currentPage) {
      return;
    }

    setState(() {
      _currentPage = safePage;
    });
  }

  void _changePageSize(int pageSize, {
    required bool clearSelection,
  }) {
    if (pageSize <= 0 || pageSize == _pageSize) {
      return;
    }

    setState(() {
      _pageSize = pageSize;
      _currentPage = 1;

      if (clearSelection) {
        _selectedKeys.clear();
        _selectedSingleKey = null;
      }
    });

    if(clearSelection) {
      if (isMultiSelect) {
        widget.onMultiSelectChanged?.call([]);
      }

      if (isSingleSelect) {
        widget.onSingleSelectChanged?.call(null);
      }
    }
  }

  void _ensureValidPage() {
    if (_currentPage > totalPages) {
      _currentPage = totalPages;
    }

    if (_currentPage < 1) {
      _currentPage = 1;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SYNC SELECTION
  // ─────────────────────────────────────────────────────────────────────────

  void _syncSelection() {
    final validKeys = widget.items
        .map(_getItemKey)
        .toSet();

    _selectedKeys.removeWhere(
          (key) => !validKeys.contains(key),
    );

    if (_selectedSingleKey != null &&
        !validKeys.contains(_selectedSingleKey)) {
      _selectedSingleKey = null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // REFRESH ITEMS
  // ─────────────────────────────────────────────────────────────────────────

  void _refreshItems({
    required bool resetPage,
    required bool clearSelection,
  }) {
    final query = _searchQuery.trim();

    final latestItems = query.isEmpty
        ? List<T>.from(widget.items)
        : widget.items.where(
          (item) => widget.searchMatcher!(
        item,
        query,
      ),
    ).toList();

    setState(() {
      _filteredItems = latestItems;

      if (resetPage) {
        _currentPage = 1;
      }

      _ensureValidPage();

      if (clearSelection) {
        _selectedKeys.clear();
        _selectedSingleKey = null;
      }
    });

    if (clearSelection) {
      if (isMultiSelect) {
        widget.onMultiSelectChanged?.call([]);
      }

      if (isSingleSelect) {
        widget.onSingleSelectChanged?.call(null);
      }
    }
  }


  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.title != null ||
            widget.subtitle != null ||
            widget.titleWidget != null ||
            widget.enableSearch)
          _buildHeader(),

        if (widget.enablePagination)
          _buildPagination(),

        if(widget.isExpanded)
          Expanded(child: _buildListView())
        else
          _buildListView(),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HEADER
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact =
              constraints.maxWidth < 600;

          if (isCompact) {
            return Column(
              crossAxisAlignment:
              CrossAxisAlignment.stretch,
              children: [
                _buildTitle(),

                if (widget.enableSearch) ...[
                  const SizedBox(height: 12),
                  _buildSearch(),
                ],
              ],
            );
          }

          return Row(
            crossAxisAlignment: .start,
            children: [
              Expanded(
                child: _buildTitle(),
              ),

              if (widget.enableSearch) ...[
                const SizedBox(width: 16),
                SizedBox(
                  width: 320,
                  child: _buildSearch(),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TITLE
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildTitle() {
    if (widget.titleWidget != null) {
      return widget.titleWidget!;
    }

    if (widget.title == null &&
        widget.subtitle == null) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        if (widget.title != null)
          Text(
            widget.title!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .titleMedium?.copyWith(fontWeight: .w600),
          ),

        if (widget.subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.subtitle!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .bodyMedium,
          ),
        ],
      ],
    );
  }


  // ─────────────────────────────────────────────────────────────────────────
  // SEARCH
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildSearch() {
    final cs = Theme.of(context).colorScheme;

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _searchController,
      builder: (
          context,
          value,
          _,
          ) {
        return TextField(
          controller: _searchController,
          focusNode: _searchFocus,
          onChanged: _handleSearchChanged,
          textInputAction:
          TextInputAction.search,
          onTapOutside: (e) {
            _searchFocus.unfocus();
            _dropdownFocus.unfocus();
          },
          decoration: InputDecoration(
            hintText: widget.searchHint,
            prefixIcon:
            const Icon(Icons.search),
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
              tooltip: 'Clear search',
              icon:
              const Icon(Icons.cancel),
              onPressed: () {
                _searchController.clear();
                _handleSearchChanged('');
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: cs.outline,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: cs.outlineVariant,
              ),
            ),
            isDense: true,
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PAGINATION
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildPagination() {
    final canGoPrevious =
        _currentPage > 1;

    final canGoNext =
        _currentPage < totalPages;

    final startRecord = totalItems == 0
        ? 0
        : ((_currentPage - 1) *
        _pageSize) +
        1;

    final endRecord = totalItems == 0
        ? 0
        : (_currentPage * _pageSize)
        .clamp(0, totalItems);

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Wrap(
        alignment: WrapAlignment.end,
        crossAxisAlignment:
        WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 8,
        children: [
          Text(
            '$startRecord-$endRecord of $totalItems',
            style: Theme.of(context)
                .textTheme
                .bodySmall,
          ),

          Container(
            decoration: BoxDecoration(
                border: .all(color: Theme.of(context).colorScheme.outlineVariant),
                borderRadius: .circular(8)
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                focusNode: _dropdownFocus,
                value: _pageSize,
                isDense: true,
                padding: .symmetric(vertical: 4, horizontal: 8),
                items: widget.pageSizeOptions
                    .map(
                      (size) =>
                      DropdownMenuItem<int>(
                        value: size,
                        child:
                        Text('$size'),
                      ),
                )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    _changePageSize(value, clearSelection: widget.clearSelection);
                  }
                },
              ),
            ),
          ),

          IconButton(
            tooltip: 'Previous page',
            icon: const Icon(
              Icons.chevron_left,
            ),
            onPressed: canGoPrevious
                ? () {
              _changePage(
                _currentPage - 1,
              );
            }
                : null,
          ),

          Text(
            '$_currentPage / $totalPages',
            style: Theme.of(context)
                .textTheme
                .bodyMedium,
          ),

          IconButton(
            tooltip: 'Next page',
            icon: const Icon(
              Icons.chevron_right,
            ),
            onPressed: canGoNext
                ? () {
              _changePage(
                _currentPage + 1,
              );
            }
                : null,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // LIST
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildListView() {
    final visibleItems = _visibleItems;

    if (visibleItems.isEmpty) {
      return widget.emptyWidget ??
          const Center(
            child: Text(
              'No records found',
            ),
          );
    }

    return ListView.separated(
      controller: widget.controller,
      padding: widget.padding,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      itemCount: visibleItems.length,
      itemBuilder: (context, index) {
        final item = visibleItems[index];

        final selected = _isSelected(item);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _handleTap(item),
          onDoubleTap: () =>
              _handleDoubleTap(item),
          onLongPress: () =>
              _handleLongPress(item),
          child: widget.itemBuilder(
            context,
            item,
            selected,
          ),
        );
      },
      separatorBuilder:
      widget.separatorBuilder,
    );
  }
}

/// v1.0
// typedef ModelListItemBuilder<T> = Widget Function(
//     BuildContext context,
//     T item,
//     bool selected,
//     );
//
// typedef ModelListSearchPredicate<T> = bool Function(
//     T item,
//     String searchKey,
//     );
//
// class ModelListView<T> extends StatefulWidget {
//   final List<T> items;
//
//   final ModelListItemBuilder<T> itemBuilder;
//
//   final Widget Function(BuildContext, int) separatorBuilder;
//
//   /// Used to preserve selection when the list changes.
//   final dynamic Function(T item)? uniqueKey;
//
//   /// Determines whether an item can be selected.
//   ///
//   /// Return false when the item should not be selectable.
//   final bool Function(T item)? canSelect;
//
//   final void Function(T item, bool selected)? onTap;
//
//   final void Function(T item, bool selected)? onDoubleTap;
//
//   final void Function(T item, bool selected)? onLongPress;
//
//   final void Function(List<T> items)? onMultiSelectChanged;
//
//   final void Function(T? item)? onSingleSelectChanged;
//
//   final bool singleSelect;
//   final bool multiSelect;
//   final bool useSelectionOrder;
//
//   final EdgeInsetsGeometry? padding;
//   final ScrollPhysics? physics;
//   final bool shrinkWrap;
//   final Widget? emptyWidget;
//   final ScrollController? scrollController;
//
//   /// Search
//   final TextEditingController? searchController;
//   final ModelListSearchPredicate<T>? searchPredicate;
//
//   const ModelListView({
//     super.key,
//     required this.items,
//     required this.itemBuilder,
//     required this.separatorBuilder,
//     this.uniqueKey,
//     this.canSelect,
//     this.onTap,
//     this.onDoubleTap,
//     this.onLongPress,
//     this.onMultiSelectChanged,
//     this.onSingleSelectChanged,
//     this.singleSelect = false,
//     this.multiSelect = false,
//     this.useSelectionOrder = true,
//     this.padding,
//     this.physics,
//     this.shrinkWrap = false,
//     this.emptyWidget,
//     this.scrollController,
//     this.searchController,
//     this.searchPredicate,
//   }) : assert(
//   !(singleSelect && multiSelect),
//   'singleSelect and multiSelect cannot both be true.',
//   );
//
//   @override
//   State<ModelListView<T>> createState() => ModelListViewState<T>();
// }
//
// class ModelListViewState<T> extends State<ModelListView<T>> {
//   final Set<dynamic> _selectedKeys = {};
//
//   int? _selectedIndex;
//
//   bool get isSingleSelect => widget.singleSelect;
//
//   bool get isMultiSelect => widget.multiSelect;
//
//   late final TextEditingController _searchController;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _searchController =
//         widget.searchController ?? TextEditingController();
//   }
//
//   // ─────────────────────────────────────────────────────────────────────────
//   // SELECTABLE
//   // ─────────────────────────────────────────────────────────────────────────
//
//   bool _canSelect(T item) {
//     return widget.canSelect?.call(item) ?? true;
//   }
//
//   // ─────────────────────────────────────────────────────────────────────────
//   // KEY
//   // ─────────────────────────────────────────────────────────────────────────
//
//   dynamic _getKey(T item, int index) {
//     return widget.uniqueKey?.call(item) ?? index;
//   }
//
//   // ─────────────────────────────────────────────────────────────────────────
//   // SELECTED
//   // ─────────────────────────────────────────────────────────────────────────
//
//   bool _isSelected(T item, int index) {
//     if (!_canSelect(item)) {
//       return false;
//     }
//
//     if (isSingleSelect) {
//       return _selectedIndex == index;
//     }
//
//     if (widget.uniqueKey != null) {
//       return _selectedKeys.contains(
//         widget.uniqueKey!.call(item),
//       );
//     }
//
//     return _selectedKeys.contains(index);
//   }
//
//   // ─────────────────────────────────────────────────────────────────────────
//   // TOGGLE
//   // ─────────────────────────────────────────────────────────────────────────
//
//   void _toggleSelection(T item, int index) {
//     if (!_canSelect(item)) {
//       return;
//     }
//
//     if (isMultiSelect) {
//       _toggleMultiSelection(item, index);
//     } else if (isSingleSelect) {
//       _toggleSingleSelection(item, index);
//     }
//   }
//
//   // ─────────────────────────────────────────────────────────────────────────
//   // MULTI SELECT
//   // ─────────────────────────────────────────────────────────────────────────
//
//   void _toggleMultiSelection(T item, int index) {
//     final key = _getKey(item, index);
//
//     setState(() {
//       if (_selectedKeys.contains(key)) {
//         _selectedKeys.remove(key);
//       } else {
//         _selectedKeys.add(key);
//       }
//     });
//
//     _notifyMultiSelection();
//   }
//
//   void _notifyMultiSelection() {
//     final selectedItems = <T>[];
//
//     if(widget.useSelectionOrder) {
//       /// With selected order
//       for (final key in _selectedKeys) {
//         final index = widget.items.indexWhere(
//               (item) => _getKey(item, widget.items.indexOf(item)) == key,
//         );
//
//         if (index == -1) continue;
//
//         final item = widget.items[index];
//
//         if (_canSelect(item)) {
//           selectedItems.add(item);
//         }
//       }
//     }
//     else {
//       /// With original list order
//       for (int i = 0; i < widget.items.length; i++) {
//         final item = widget.items[i];
//
//         if (!_canSelect(item)) {
//           continue;
//         }
//
//         final key = _getKey(item, i);
//
//         if (_selectedKeys.contains(key)) {
//           selectedItems.add(item);
//         }
//       }
//     }
//
//     widget.onMultiSelectChanged?.call(selectedItems);
//   }
//
//   // ─────────────────────────────────────────────────────────────────────────
//   // SINGLE SELECT
//   // ─────────────────────────────────────────────────────────────────────────
//
//   void _toggleSingleSelection(T item, int index) {
//     if (!_canSelect(item)) {
//       return;
//     }
//
//     final wasSelected = _isSelected(item, index);
//
//     setState(() {
//       _selectedIndex = wasSelected ? null : index;
//     });
//
//     widget.onSingleSelectChanged?.call(
//       wasSelected ? null : item,
//     );
//   }
//
//   // ─────────────────────────────────────────────────────────────────────────
//   // TAP
//   // ─────────────────────────────────────────────────────────────────────────
//
//   void _handleTap(T item, int index) {
//     final selected = _isSelected(item, index);
//
//     // Selection only happens if item is selectable.
//     if (isSingleSelect || isMultiSelect) {
//       _toggleSelection(item, index);
//     }
//
//     // onTap still works even when item cannot be selected.
//     widget.onTap?.call(item, selected);
//   }
//
//   // ─────────────────────────────────────────────────────────────────────────
//   // DOUBLE TAP
//   // ─────────────────────────────────────────────────────────────────────────
//
//   void _handleDoubleTap(T item, int index) {
//     widget.onDoubleTap?.call(
//       item,
//       _isSelected(item, index),
//     );
//   }
//
//   // ─────────────────────────────────────────────────────────────────────────
//   // LONG PRESS
//   // ─────────────────────────────────────────────────────────────────────────
//
//   void _handleLongPress(T item, int index) {
//     widget.onLongPress?.call(item, _isSelected(item, index));
//   }
//
//   // ─────────────────────────────────────────────────────────────────────────
//   // CLEAR
//   // ─────────────────────────────────────────────────────────────────────────
//
//   void clearSelection() {
//     setState(() {
//       _selectedKeys.clear();
//       _selectedIndex = null;
//     });
//
//     if (isMultiSelect) {
//       widget.onMultiSelectChanged?.call([]);
//     }
//
//     if (isSingleSelect) {
//       widget.onSingleSelectChanged?.call(null);
//     }
//   }
//
//   // ─────────────────────────────────────────────────────────────────────────
//   // SELECT ALL
//   // ─────────────────────────────────────────────────────────────────────────
//
//   void selectAll() {
//     if (!isMultiSelect) return;
//
//     setState(() {
//       _selectedKeys.clear();
//
//       for (int i = 0; i < widget.items.length; i++) {
//         final item = widget.items[i];
//
//         if (!_canSelect(item)) {
//           continue;
//         }
//
//         _selectedKeys.add(
//           _getKey(item, i),
//         );
//       }
//     });
//
//     _notifyMultiSelection();
//   }
//
//   // ─────────────────────────────────────────────────────────────────────────
//   // SELECT ITEM
//   // ─────────────────────────────────────────────────────────────────────────
//
//   void selectItem(T item) {
//     if (!isSingleSelect) return;
//
//     if (!_canSelect(item)) return;
//
//     final index = widget.items.indexOf(item);
//
//     if (index == -1) return;
//
//     setState(() {
//       _selectedIndex = index;
//     });
//
//     widget.onSingleSelectChanged?.call(item);
//   }
//
//   // ─────────────────────────────────────────────────────────────────────────
//   // UPDATE
//   // ─────────────────────────────────────────────────────────────────────────
//
//   @override
//   void didUpdateWidget(
//       covariant ModelListView<T> oldWidget,
//       ) {
//     super.didUpdateWidget(oldWidget);
//
//     if (oldWidget.items != widget.items) {
//       _syncSelection();
//     }
//   }
//
//   void _syncSelection() {
//     if (widget.uniqueKey == null) {
//       if (_selectedIndex != null &&
//           _selectedIndex! >= widget.items.length) {
//         _selectedIndex = null;
//       }
//
//       _selectedKeys.removeWhere(
//             (key) =>
//         key is int &&
//             (key < 0 || key >= widget.items.length),
//       );
//
//       return;
//     }
//
//     final validKeys = widget.items
//         .map(widget.uniqueKey!)
//         .toSet();
//
//     _selectedKeys.removeWhere(
//           (key) => !validKeys.contains(key),
//     );
//   }
//
//   List<T> _filteredItems(String searchKey) {
//     // final searchKey = widget.searchKey.trim();
//
//     if (searchKey.isEmpty || widget.searchPredicate == null) {
//       return widget.items;
//     }
//
//     return widget.items.where(
//           (item) => widget.searchPredicate!.call(
//         item,
//         searchKey,
//       ),
//     ).toList();
//   }
//
//   // ─────────────────────────────────────────────────────────────────────────
//   // BUILD
//   // ─────────────────────────────────────────────────────────────────────────
//
//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder(
//         valueListenable: _searchController,
//         builder: (context, value, child){
//
//           final filteredItems = _filteredItems(value.text);
//
//           if (filteredItems.isEmpty) {
//             return widget.emptyWidget ??
//                 const Center(
//                   child: Text('No records found'),
//                 );
//           }
//
//           return ListView.separated(
//             controller: widget.scrollController,
//             padding: widget.padding,
//             physics: widget.physics,
//             shrinkWrap: widget.shrinkWrap,
//             itemCount: filteredItems.length,
//             itemBuilder: (context, index) {
//               final item = filteredItems[index];
//
//               final selected = _isSelected(
//                 item,
//                 index,
//               );
//
//               return GestureDetector(
//                 behavior: HitTestBehavior.opaque,
//                 onTap: () => _handleTap(item, index),
//                 onDoubleTap: () => _handleDoubleTap(item, index),
//                 onLongPress: () => _handleLongPress(item, index),
//                 child: widget.itemBuilder(
//                   context,
//                   item,
//                   selected,
//                 ),
//               );
//             },
//             separatorBuilder: widget.separatorBuilder,
//           );
//         }
//     );
//   }
//
//   @override
//   void dispose() {
//     if (widget.searchController == null) {
//       _searchController.dispose();
//     }
//
//     super.dispose();
//   }
// }