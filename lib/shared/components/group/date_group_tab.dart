import 'package:flutter/material.dart';

enum DateGroupType { today, yesterday, thisWeek, thisMonth, thisYear, other }

class DateGroupItem<T> {
  final DateGroupType group;
  final List<T> items;

  DateGroupItem({required this.group, required this.items});
}

class DateGroupingHelper {
  static List<DateGroupItem<T>> groupByDate<T>({
    required List<T> items,
    required DateTime Function(T item) dateSelector,
  }) {
    final now = DateTime.now();

    final Map<DateGroupType, List<T>> map = {
      for (var g in DateGroupType.values) g: [],
    };

    for (final item in items) {
      final date = dateSelector(item);

      final group = _resolveGroup(date, now);
      map[group]!.add(item);
    }

    return DateGroupType.values
        .map((g) => DateGroupItem<T>(group: g, items: map[g]!))
        .where((e) => e.items.isNotEmpty)
        .toList();
  }

  static DateGroupType _resolveGroup(DateTime date, DateTime now) {
    final d1 = DateTime(date.year, date.month, date.day);
    final n1 = DateTime(now.year, now.month, now.day);

    if (d1 == n1) return DateGroupType.today;
    if (d1 == n1.subtract(const Duration(days: 1))) {
      return DateGroupType.yesterday;
    }

    final weekStart = n1.subtract(Duration(days: n1.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    if (d1.isAfter(weekStart.subtract(const Duration(days: 1))) &&
        d1.isBefore(weekEnd.add(const Duration(days: 1)))) {
      return DateGroupType.thisWeek;
    }

    if (date.year == now.year && date.month == now.month) {
      return DateGroupType.thisMonth;
    }

    if (date.year == now.year) {
      return DateGroupType.thisYear;
    }

    return DateGroupType.other;
  }

  static String label(DateGroupType type) {
    switch (type) {
      case DateGroupType.today:
        return "Today";
      case DateGroupType.yesterday:
        return "Yesterday";
      case DateGroupType.thisWeek:
        return "This Week";
      case DateGroupType.thisMonth:
        return "This Month";
      case DateGroupType.thisYear:
        return "This Year";
      case DateGroupType.other:
        return "Other";
    }
  }
}

class DateGroupTabs<T> extends StatefulWidget {
  final List<T> items;
  final DateTime Function(T item) dateSelector;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget Function(BuildContext context, int index)? separatorBuilder;
  final Future<void> Function() onRefresh;

  const DateGroupTabs({
    super.key,
    required this.items,
    required this.dateSelector,
    required this.itemBuilder,
    required this.onRefresh,
    this.separatorBuilder,
  });

  @override
  State<DateGroupTabs<T>> createState() => _DateGroupTabsState<T>();
}

class _DateGroupTabsState<T> extends State<DateGroupTabs<T>> {
  late List<DateGroupItem<T>> grouped;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    grouped = DateGroupingHelper.groupByDate(
      items: widget.items,
      dateSelector: widget.dateSelector,
    );
  }

  @override
  void didUpdateWidget(covariant DateGroupTabs<T> oldWidget) {
    grouped = DateGroupingHelper.groupByDate(
      items: widget.items,
      dateSelector: widget.dateSelector,
    );
    selectedIndex = grouped.length > selectedIndex ? selectedIndex : 0;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    if (grouped.isEmpty) return const SizedBox();

    final selected = grouped[selectedIndex];

    return Column(
      children: [
        SizedBox(
          height: kToolbarHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: grouped.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final g = grouped[index];

              final isSelected = index == selectedIndex;

              return Container(
                margin: .only(
                  left: index == 0 ? 16 : 0,
                  right: index == grouped.length - 1 ? 16 : 0,
                ),
                child: ChoiceChip(
                  label: Text(DateGroupingHelper.label(g.group)),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() => selectedIndex = index);
                  },
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        Expanded(
          child: RefreshIndicator(
            onRefresh: widget.onRefresh,
            child: ListView.separated(
              itemCount: selected.items.length,
              separatorBuilder:
                  widget.separatorBuilder ??
                  (context, index) => const SizedBox(),
              itemBuilder: (context, index) {
                return widget.itemBuilder(
                  context,
                  selected.items[index],
                  index,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    grouped.clear();
    selectedIndex = 0;
    super.dispose();
  }
}
