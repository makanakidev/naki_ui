part of 'core_extensions.dart';

/// Extension on [Map] providing CSS property manipulation utilities.
extension CssPropsExtension on Map<String, String> {
  /// Converts raw CSS style properties to inline CSS string.
  ///
  /// Example:
  /// ```dart
  /// final css = {'display': 'block', 'color': 'red'};
  /// final cssText = css.cssText;
  /// // returns: 'display: block; color: red;'
  /// ```
  String get cssText => entries.map((e) => '${e.key}: ${e.value};').join(' ');

  /// Combines this map with [other].
  ///
  /// If the same key exists, the value from [other] is used.
  ///
  /// Example:
  /// ```dart
  /// final style1 = {'color': 'red', 'font-size': '10px'};
  /// final style2 = {'font-weight': 'bold', 'font-size': '12px'};
  /// final combined = style1.combine(style2);
  /// // returns: {'color': 'red', 'font-weight': 'bold', 'font-size': '12px'}
  /// ```
  Map<String, String> combine(Map<String, String> other) => {...this, ...other};

  /// Deletes [key] and its value from this map and
  /// returns a new map without it.
  ///
  /// Example:
  /// ```dart
  /// final style = {'color': 'red', 'font-size': '10px'};
  /// final withoutColor = style.delete('color');
  /// // returns: {'font-size': '10px'}
  /// ```
  Map<String, String> delete(String key) {
    final map = {...this};
    map.remove(key);
    return map;
  }

  @Deprecated('This will be removed in v2.0.0. Use .without() instead.')
  Map<String, String> except(Iterable<String> keys) => without(keys);

  /// Returns a new map containing all entries except those with keys in [keys].
  ///
  /// Example:
  /// ```dart
  /// final style = {'color': 'red', 'font-size': '10px', 'font-weight': 'bold'};
  /// final withoutColorAndSize = style.without(['color', 'font-size']);
  /// // returns: {'font-weight': 'bold'}
  /// ```
  Map<String, String> without(Iterable<String> keys) =>
      Map.fromEntries(entries.where((e) => !keys.contains(e.key)));

  /// Returns a new map containing only the entries in [keys].
  ///
  /// Example:
  /// ```dart
  /// final style = {'color': 'red', 'font-size': '10px', 'font-weight': 'bold'};
  /// final onlyColorAndSize = style.only(['color', 'font-size']);
  /// // returns: {'color': 'red', 'font-size': '10px'}
  /// ```
  Map<String, String> only(Iterable<String> keys) =>
      Map.fromEntries(entries.where((e) => keys.contains(e.key)));
}
