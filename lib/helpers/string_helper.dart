class StringHelper {
  static String formatLabel(String text) {
    if (text.isEmpty) return text;

    // Step 1: Replace underscores, hyphens, and other symbols with spaces
    String processed = text.replaceAll(RegExp(r'[_\-]'), ' ');

    // Step 2: Insert space before uppercase letters that follow lowercase letters
    // This handles camelCase and PascalCase
    processed = processed.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
          (match) => '${match.group(1)} ${match.group(2)}',
    );

    // Step 3: Split into words and capitalize each word
    List<String> words = processed.split(RegExp(r'\s+'));
    List<String> capitalizedWords = words.map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).toList();

    // Step 4: Join words with single space
    return capitalizedWords.join(' ');
  }
}