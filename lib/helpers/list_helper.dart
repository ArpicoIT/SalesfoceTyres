import 'package:flutter/foundation.dart';

class ListHelper {
  /// Sort list by date field (works for Map or any object via key selector)
  static void sortByDate<T>(
      List<T> list,
      DateTime? Function(T item) dateSelector, {
        bool ascending = true,
      }) {
    list.sort((a, b) {
      final dateA = dateSelector(a) ?? DateTime(1970);
      final dateB = dateSelector(b) ?? DateTime(1970);
      return ascending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
    });
  }

  /// Single row update using matcher
  static T? update<T>({
    required List<T> source,
    required bool Function(T item) matcher,
    required T Function(T item) updater,
    required void Function(List<T>) setListCallback,
    void Function(VoidCallback)? setStateCallback,
    String? logMessage,
  }) {
    if (source.isEmpty) {
      return null;
    }

    final index = source.indexWhere(matcher);

    if (index == -1) {
      return null;
    }

    final oldItem = source[index];
    final updatedItem = updater(oldItem);

    // Create only one new List instance.
    final updatedList = List<T>.from(source);

    // Replace only the matched row.
    updatedList[index] = updatedItem;

    if (setStateCallback != null) {
      setStateCallback(
            () => setListCallback(updatedList),
      );
    } else {
      setListCallback(updatedList);
    }

    debugPrint(
      logMessage ?? 'List item updated successfully',
    );

    return updatedItem;
  }

  /// Single row update use row index
  static T? updateAt<T>({
    required List<T> source,
    required int index,
    required T Function(T item) updater,
    required void Function(List<T>) setListCallback,
    void Function(VoidCallback)? setStateCallback,
    String? logMessage,
  }) {
    if (index < 0 || index >= source.length) {
      return null;
    }

    final updatedItem = updater(source[index]);

    final updatedList = List<T>.from(source);

    updatedList[index] = updatedItem;

    if (setStateCallback != null) {
      setStateCallback(
            () => setListCallback(updatedList),
      );
    } else {
      setListCallback(updatedList);
    }

    debugPrint(
      logMessage ?? 'List item updated successfully',
    );

    return updatedItem;
  }

  /// All rows update using transform
  static List<T> transformAll<T>({
    required List<T> source,
    required T Function(T item) updater,
    required void Function(List<T>) setListCallback,
    void Function(VoidCallback)? setStateCallback,
    String? logMessage,
  }) {
    if (source.isEmpty) {
      return source;
    }

    final updatedList = List<T>.generate(
      source.length,
          (index) => updater(source[index]),
      growable: false,
    );

    if (setStateCallback != null) {
      setStateCallback(
            () => setListCallback(updatedList),
      );
    } else {
      setListCallback(updatedList);
    }

    debugPrint(
      logMessage ?? 'List transformed successfully',
    );

    return updatedList;
  }
}

/// v 1.0
// class ListHelper {
//   /// Sort list by date field (works for Map or any object via key selector)
//   static void sortByDate<T>(
//       List<T> list,
//       DateTime? Function(T item) dateSelector, {
//         bool ascending = true,
//       }) {
//     list.sort((a, b) {
//       final dateA = dateSelector(a) ?? DateTime(1970);
//       final dateB = dateSelector(b) ?? DateTime(1970);
//       return ascending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
//     });
//   }
//
//   /// Update item in list (immutable update)
//   static T? updateLocalRow<T>({
//     required List<T> source,
//     required bool Function(T item) matcher,
//     required T Function(T item) updater,
//     required void Function(List<T>) setListCallback,
//     void Function(VoidCallback)? setStateCallback,
//     String? logMessage,
//   }) {
//     if (source.isEmpty) return null;
//
//     final updatedList = source.map((e) => e).toList();
//
//     T? updatedItem;
//
//     for (int i = 0; i < updatedList.length; i++) {
//       final item = updatedList[i];
//
//       if (matcher(item)) {
//         final newItem = updater(item);
//         updatedList[i] = newItem;
//         updatedItem = newItem;
//         break;
//       }
//     }
//
//     if (updatedItem == null) return null;
//
//     if (setStateCallback != null) {
//       setStateCallback(() => setListCallback(updatedList));
//     } else {
//       setListCallback(updatedList);
//     }
//
//     debugPrint(logMessage ?? 'List item updated successfully');
//
//     return updatedItem;
//   }
// }