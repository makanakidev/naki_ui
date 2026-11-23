part of 'core_extensions.dart';

/// Extension on [num] providing currency formatting,
/// rounding, and type check utilities.
extension NumExtension on num {
  /// Currency formatter (e.g '2500.56' -> '$2,500.56').
  ///
  /// Example:
  /// ```dart
  /// final number = 2500.56;
  /// final currency = number.toCurrency();
  /// // returns: '$2,500.56'
  /// ```
  String toCurrency([String? symbol]) => toString().toCurrency(symbol ?? '\$');

  /// Rounds up to nearest integer (e.g 4.123456789.roundUp -> 5).
  ///
  /// Example:
  /// ```dart
  /// final number = 4.123456789;
  /// final roundUp = number.roundUp;
  /// // returns: 5
  /// ```
  int get roundUp => ceil();

  /// Rounds down to nearest integer (e.g 4.123456789.roundDown -> 4)
  ///
  /// Example:
  /// ```dart
  /// final number = 4.123456789;
  /// final roundDown = number.roundDown;
  /// // returns: 4
  /// ```
  int get roundDown => floor();

  /// Rounds to [places] decimal places (e.g 4.123456789.roundTo(4) -> 4.1235)
  ///
  /// Example:
  /// ```dart
  /// final number = 4.123456789;
  /// final roundTo = number.roundTo(4);
  /// // returns: 4.1235
  /// ```
  double roundTo(int places) => double.tryParse(toStringAsFixed(places)) ?? 0.0;

  /// Returns true if this number is an integer.
  ///
  /// Example:
  /// ```dart
  /// final number1 = 4;
  /// final number2 = 4.0;
  /// final number3 = 4.1;
  ///
  /// final isInteger1 = number1.isInteger;
  /// // returns: true
  ///
  /// final isInteger2 = number2.isInteger;
  /// // returns: true
  ///
  /// final isInteger3 = number3.isInteger;
  /// // returns: false
  /// ```
  bool get isInteger => this % 1 == 0;

  /// Returns true if this number is a double.
  ///
  /// Example:
  /// ```dart
  /// final number1 = 4.0;
  /// final number2 = 4.1;
  ///
  /// final isDouble1 = number1.isDouble;
  /// // returns: false
  ///
  /// final isDouble2 = number2.isDouble;
  /// // returns: true
  /// ```
  bool get isDouble => !isInteger;

  /// Returns a string representation of this number without
  /// unnecessary trailing decimal places.
  ///
  /// Example:
  /// ```dart
  /// final number1 = 4.0;
  /// final number2 = 4.123;
  ///
  /// final string1 = number1.toCleanString;
  /// // returns: '4'
  ///
  /// final string2 = number2.toCleanString;
  /// // returns: '4.123'
  /// ```
  String get toCleanString => isDouble ? toString() : toStringAsFixed(0);

  /// Returns a CSS-formatted dimension string with 'px' unit.
  ///
  /// Example:
  /// ```dart
  /// final number = 12.34;
  /// final pxString = number.toPx;
  /// // returns: '12.34px'
  /// ```
  String get toPx => '${toCleanString}px';

  /// Returns a CSS-formatted dimension string with '%' unit.
  ///
  /// Example:
  /// ```dart
  /// final number = 12.0;
  /// final pctString = number.toPct;
  /// // returns: '12%'
  /// ```
  String get toPct => '${clamp(0, 100).toCleanString}%';
}
