part of 'index.dart';

/// Extension on [String] providing text formatting,
/// validation, and parsing utilities.
extension StringExtension on String {
  /// Formats text to title case.
  ///
  /// Example:
  /// ```dart
  /// final text = "hello there, it's great";
  /// final formatted = text.toTitleCase();
  /// // returns: "Hello There, It's Great"
  /// ```
  String toTitleCase() {
    if (trim().isEmpty) return this;

    final regex = RegExp(r'\b\p{L}', unicode: true);
    return toLowerCase().replaceAllMapped(
      regex,
      (match) => match.group(0)!.toUpperCase(),
    );
  }

  /// Formats text to sentence case.
  ///
  /// Example:
  /// ```dart
  /// final text = "hello there. how are you?";
  /// final formatted = text.toSentenceCase();
  /// // returns: "Hello there. How are you?"
  /// ```
  String toSentenceCase() {
    if (trim().isEmpty) return this;

    final regex = RegExp(r'(^\s*|[.!?]\s+)(\p{L})', unicode: true);
    return toLowerCase().replaceAllMapped(regex, (match) {
      final prefix = match.group(1) ?? '';
      final char = match.group(2) ?? '';
      return '$prefix${char.toUpperCase()}';
    });
  }

  /// Normalizes currency symbol (e.g NGN -> ₦, USD -> $)
  ///
  /// Example:
  /// ```dart
  /// final text = 'USD';
  /// final normalized = text.normalizeCurrency;
  /// // returns: '$'
  /// ```
  String get normalizeCurrency => switch (toUpperCase()) {
    'NGN' || '₦' => r'₦',
    'USD' || '\$' => r'$',
    'EUR' || '€' => r'€',
    'GBP' || '£' => r'£',
    _ => this,
  };

  /// Truncates string with ellipsis, collapses multiple spaces to one.
  ///
  /// Example:
  /// ```dart
  /// final text = 'hello there, how are you?';
  /// final compact = text.truncate(10);
  /// // returns: 'Hello there...'
  /// ```
  String truncate([int maxLength = 90]) {
    final text = trim().replaceAll(RegExp(r'\s+'), ' ');
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Currency formatter.
  ///
  /// Example:
  /// ```dart
  /// final text = '2500.56';
  /// final currency = text.toCurrency('USD');
  /// // returns: '$2,500.56'
  /// ```
  String toCurrency([String symbol = '\$']) {
    if (isEmpty) return this;

    final normalizedSymbol = symbol.normalizeCurrency;

    // remove letters and symbols except dot
    final value = replaceAll(RegExp(r'[^0-9.]'), '');
    final doubleValue = double.tryParse(value) ?? 0.0;
    final fixedValue = doubleValue.toStringAsFixed(2);
    final parts = fixedValue.split('.');

    String mathFunc(Match match) => '${match[1]},';

    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final result = parts[0].replaceAllMapped(reg, mathFunc);

    return parts[1] == '00'
        ? '$normalizedSymbol$result'
        : '$normalizedSymbol$result.${parts[1]}';
  }

  /// Removes `data:*/*;base64,` from a Data URL.
  ///
  /// Example:
  /// ```dart
  /// final text = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFC';
  /// final base64 = text.base64Only;
  /// // returns: 'iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFC'
  /// ```
  String get base64Only => startsWith('data:') ? split(',').last : this;

  /// Extracts URL from this string.
  ///
  /// Example:
  /// ```dart
  /// final text = 'Please visit https://example.com';
  /// final url = text.extractLink;
  /// // returns: 'https://example.com'
  /// ```
  String? get extractLink =>
      RegExp(r'(https?://[^\s]+)').firstMatch(this)?.group(0);

  /// Returns true if this is a valid url.
  ///
  /// Example:
  /// ```dart
  /// final text = 'https://example.com';
  /// final isUrl = text.isUrl;
  /// // returns: true
  /// ```
  bool get isUrl => RegExp(
    r'^(?:(?:https?|ftp):\/\/)?' // optional scheme
    r'(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z]{2,63}' // domain
    r'(?::\d{1,5})?' // optional port
    r'(?:[/?#][^\s]*)?$', // optional path, query, or fragment
    caseSensitive: false,
  ).hasMatch(trim());

  /// Returns true if this is a valid email address.
  ///
  /// Example:
  /// ```dart
  /// final text = 'example@example.com';
  /// final isEmail = text.isEmail;
  /// // returns: true
  /// ```
  bool get isEmail => RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    caseSensitive: false,
  ).hasMatch(trim());

  /// Returns the first two letters.
  ///
  /// Example:
  /// ```dart
  /// final text = 'John Doe';
  /// final initials = text.initials;
  /// // returns: 'JD'
  /// ```
  String get initials {
    // check if the string is empty or just whitespace
    if (trim().isEmpty) return '-';

    try {
      return split(' ')
          .map((part) => part.withoutSymbols)
          .where((part) => part.isNotEmpty)
          .map((part) => part[0])
          .take(2)
          .join()
          .toUpperCase();
    } catch (_) {
      return '-';
    }
  }

  /// Returns this string without numbers and white spaces.
  ///
  /// Example:
  /// ```dart
  /// final text = 'Hello World 123';
  /// final withoutNumbersAndSpaces = text.withoutNumbersAndSpaces;
  /// // returns: 'HelloWorld'
  /// ```
  String get withoutNumbersAndSpaces => replaceAll(RegExp(r'[^a-zA-Z]'), '');

  /// Returns this string without special characters and symbols.
  ///
  /// Example:
  /// ```dart
  /// final text = 'Hello World! 123';
  /// final withoutSpecialCharactersAndSymbols = text.withoutSymbols;
  /// // returns: 'HelloWorld123'
  /// ```
  String get withoutSymbols => replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
}

/// Extension on nullable [String] for null and empty checks.
extension NullishStringExtension on String? {
  /// Returns true if this string is null or empty.
  ///
  /// Example:
  /// ```dart
  /// final text = '  ';
  /// final isNullOrEmpty = text.isNullOrEmpty;
  /// // returns: true
  /// ```
  bool get isNullOrEmpty {
    final trim = this?.trim();
    return trim == null || trim.isEmpty;
  }

  /// Returns true if this string is not null and not empty.
  ///
  /// Example:
  /// ```dart
  /// final text = 'Hello World';
  /// final isNotNullAndEmpty = text.isNotNullAndEmpty;
  /// // returns: true
  /// ```
  bool get isNotNullAndEmpty => !isNullOrEmpty;
}
