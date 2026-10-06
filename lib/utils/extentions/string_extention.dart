
extension StringExtension on String {
  bool get isBlank => trim().isEmpty;

  bool get isNotBlank => trim().isNotEmpty;

  String get capitalizeFirst {
    if (isEmpty) return this;

    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String get capitalizeWords {
    if (trim().isEmpty) return this;

    return trim()
        .split(RegExp(r'\s+'))
        .map((word) => word.capitalizeFirst)
        .join(' ');
  }

  String get capitalizeSentences {
    if (trim().isEmpty) return this;

    return replaceAllMapped(
      RegExp(r'(^\s*[a-zA-Z])|([.!?]\s+[a-zA-Z])'),
          (match) {
        final value = match.group(0)!;
        final index = value.lastIndexOf(
          RegExp(r'[a-zA-Z]'),
        );

        return '${value.substring(0, index)}'
            '${value[index].toUpperCase()}'
            '${value.substring(index + 1)}';
      },
    );
  }

  String get replaceSlash => replaceAll('/', '_');

  String get replaceBackslash => replaceAll(r'\', '_');

  String get replaceSlashes => replaceAll(RegExp(r'[/\\]'), '_');

  String get removeWhitespace => replaceAll(RegExp(r'\s+'), '');

  String get normalizeWhitespace =>
      trim().replaceAll(RegExp(r'\s+'), ' ');

  String get removeSpecialCharacters =>
      replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '');

  String get removeNonNumeric =>
      replaceAll(RegExp(r'[^0-9]'), '');

  bool get isNumeric => double.tryParse(trim()) != null;

  double? get toDouble => double.tryParse(trim());

  int? get toInt => int.tryParse(trim());

  String get nullIfBlank => isBlank ? '' : this;
}