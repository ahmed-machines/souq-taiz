/// Splits titles/keywords into normalized search tokens (Arabic aware).
abstract final class KeywordTokenizer {
  static final RegExp _tashkeel = RegExp(r'[\u064B-\u065F\u0670\u0640]');
  static final RegExp _separators = RegExp(
    r'[\s,.;:!?\-_/\\()\[\]{}"'
    "'"
    r'،؛؟]+',
  );

  /// Lowercases, strips diacritics and unifies Arabic letter variants.
  static String normalize(String input) => input
      .toLowerCase()
      .replaceAll(_tashkeel, '')
      .replaceAll(RegExp('[أإآ]'), 'ا')
      .replaceAll('ى', 'ي')
      .replaceAll('ة', 'ه')
      .trim();

  static List<String> tokens(String input, {int maxTokens = 10}) {
    final seen = <String>{};
    for (final t in normalize(input).split(_separators)) {
      if (t.length >= 2) seen.add(t);
      if (seen.length >= maxTokens) break;
    }
    return seen.toList();
  }
}
