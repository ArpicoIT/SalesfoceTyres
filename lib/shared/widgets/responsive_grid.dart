import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../helpers/responsive.dart';

class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 12,
    this.runSpacing,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.singleItemFullWidth = true,
    this.itemFlex,
  });

  final List<Widget> children;

  final double spacing;
  final double? runSpacing;

  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;

  /// When a row contains only one item, make it occupy the
  /// complete available width.
  final bool singleItemFullWidth;

  /// Optional flex override for individual items.
  ///
  /// Example:
  /// {
  ///   0: 2,
  ///   1: 1,
  /// }
  final Map<int, int>? itemFlex;

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);

    if (responsive.isPhone) {
      return _buildMobile();
    }

    final columns = responsive.isTablet
        ? tabletColumns
        : desktopColumns;

    return _buildGrid(columns);
  }

  Widget _buildMobile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      spacing: runSpacing ?? spacing,
      children: children,
    );
  }

  Widget _buildGrid(int columns) {
    final rows = <Widget>[];

    for (int start = 0; start < children.length; start += columns) {
      final end = math.min(
        start + columns,
        children.length,
      );

      final count = end - start;

      rows.add(
        _buildRow(
          start: start,
          end: end,
          count: count,
          columns: columns,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: runSpacing ?? spacing,
      children: rows,
    );
  }

  Widget _buildRow({
    required int start,
    required int end,
    required int count,
    required int columns,
  }) {
    // Last row contains only one item and the flag is enabled.
    if (singleItemFullWidth && count == 1) {
      return children[start];
    }

    final rowChildren = <Widget>[];

    for (int index = start; index < end; index++) {
      if (rowChildren.isNotEmpty) {
        rowChildren.add(
          SizedBox(width: spacing),
        );
      }

      rowChildren.add(
        Expanded(
          flex: itemFlex?[index] ?? 1,
          child: children[index],
        ),
      );
    }

    // Keep the remaining space empty when the final row
    // contains fewer items than the configured columns.
    if (count < columns) {
      rowChildren.add(
        SizedBox(width: spacing),
      );

      rowChildren.add(
        const Spacer(),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rowChildren,
    );
  }
}

/// v 1.0
// class ResponsiveWrap extends StatelessWidget {
//   const ResponsiveWrap({
//     super.key,
//     required this.children,
//     this.spacing = 12,
//     this.runSpacing,
//     this.mobileColumns = 1,
//     this.tabletColumns = 2,
//     this.desktopColumns = 3,
//     this.mobileFlex = 1,
//     this.tabletFlex = 1,
//     this.desktopFlex = 1,
//     this.itemFlex,
//   });
//
//   final List<Widget> children;
//
//   /// Horizontal spacing between items.
//   final double spacing;
//
//   /// Vertical spacing between rows.
//   ///
//   /// If null, [spacing] is used.
//   final double? runSpacing;
//
//   /// Number of items per row on mobile.
//   final int mobileColumns;
//
//   /// Number of items per row on tablet.
//   final int tabletColumns;
//
//   /// Number of items per row on desktop.
//   final int desktopColumns;
//
//   /// Default flex for mobile items.
//   final int mobileFlex;
//
//   /// Default flex for tablet items.
//   final int tabletFlex;
//
//   /// Default flex for desktop items.
//   final int desktopFlex;
//
//   /// Optional per-item flex overrides.
//   ///
//   /// Example:
//   /// ```dart
//   /// itemFlex: {
//   ///   0: 2,
//   ///   1: 1,
//   /// }
//   /// ```
//   final Map<int, int>? itemFlex;
//
//   @override
//   Widget build(BuildContext context) {
//     final responsive = Responsive.of(context);
//
//     if (responsive.isPhone) {
//       return _buildColumn(
//         flex: mobileFlex,
//       );
//     }
//
//     final columns = responsive.isTablet
//         ? tabletColumns
//         : desktopColumns;
//
//     final defaultFlex = responsive.isTablet
//         ? tabletFlex
//         : desktopFlex;
//
//     return _buildGrid(
//       columns: columns,
//       defaultFlex: defaultFlex,
//     );
//   }
//
//   Widget _buildColumn({
//     required int flex,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       spacing: runSpacing ?? spacing,
//       children: [
//         for (int index = 0; index < children.length; index++)
//           _buildItem(
//             children[index],
//             flex: itemFlex?[index] ?? flex,
//           ),
//       ],
//     );
//   }
//
//   Widget _buildGrid({
//     required int columns,
//     required int defaultFlex,
//   }) {
//     final rows = <Widget>[];
//
//     for (int start = 0; start < children.length; start += columns) {
//       final end = math.min(
//         start + columns,
//         children.length,
//       );
//
//       final rowChildren = <Widget>[];
//
//       for (int index = start; index < end; index++) {
//         rowChildren.add(
//           Expanded(
//             flex: itemFlex?[index] ?? defaultFlex,
//             child: children[index],
//           ),
//         );
//
//         if (index < end - 1) {
//           rowChildren.add(
//             SizedBox(width: spacing),
//           );
//         }
//       }
//
//       // Fill the remaining space when the final row
//       // has fewer items than the configured column count.
//       final remaining = columns - (end - start);
//
//       if (remaining > 0) {
//         rowChildren.add(
//           SizedBox(
//             width: spacing,
//           ),
//         );
//
//         rowChildren.add(
//           Expanded(
//             flex: remaining * defaultFlex,
//             child: const SizedBox(),
//           ),
//         );
//       }
//
//       rows.add(
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: rowChildren,
//         ),
//       );
//     }
//
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       spacing: runSpacing ?? spacing,
//       children: rows,
//     );
//   }
//
//   Widget _buildItem(
//       Widget child, {
//         required int flex,
//       }) {
//     return child;
//   }
// }