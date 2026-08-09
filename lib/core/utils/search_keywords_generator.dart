abstract class SearchKeywordsGenerator {
  static List<String> generate({
    required String name,
    String? category,
  }) {
    final Set<String> keywords = {};

    void addPrefixes(String text) {
      final cleaned = text.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '').trim();
      final words = cleaned.split(RegExp(r'\s+'));

      for (final word in words) {
        if (word.length < 2) continue; // Skip single letters like "a", "I"
        
        // Generate prefixes for title & category only
        String prefix = '';
        for (int i = 0; i < word.length; i++) {
          prefix += word[i];
          keywords.add(prefix);
        }
      }
    }

    addPrefixes(name);
    if (category != null) addPrefixes(category);

    return keywords.toList();
  }
}