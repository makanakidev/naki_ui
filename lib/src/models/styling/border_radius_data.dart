part of 'index.dart';

/// Border radius attributes of a component.
class BorderRadiusData implements NakiStylable {
  /// Top-left radius.
  final Dim? topLeft;

  /// Top-right radius.
  final Dim? topRight;

  /// Bottom-left radius.
  final Dim? bottomLeft;

  /// Bottom-right radius.
  final Dim? bottomRight;

  /// Create a new radius.
  const BorderRadiusData({
    this.topLeft,
    this.topRight,
    this.bottomLeft,
    this.bottomRight,
  });

  /// Create a symmetric border radius.
  factory BorderRadiusData.all(Dim value) => BorderRadiusData(
    topLeft: value,
    topRight: value,
    bottomLeft: value,
    bottomRight: value,
  );

  /// Circular border radius.
  static const circular = BorderRadiusData(
    topLeft: Dim.px(999),
    topRight: Dim.px(999),
    bottomLeft: Dim.px(999),
    bottomRight: Dim.px(999),
  );

  /// iOS-style squircle border radius.
  static BorderRadiusData get squircle =>
      BorderRadiusData.all(const Dim.percent(22.5));

  /// A radius with all corners set to zero.
  static const zero = BorderRadiusData(
    topLeft: Dim.zero,
    topRight: Dim.zero,
    bottomLeft: Dim.zero,
    bottomRight: Dim.zero,
  );

  /// Alias for [zero].
  static const none = zero;

  /// Create a new radius with optional changes to corner values.
  BorderRadiusData copyWith({
    Dim? topLeft,
    Dim? topRight,
    Dim? bottomLeft,
    Dim? bottomRight,
  }) {
    return BorderRadiusData(
      topLeft: topLeft ?? this.topLeft,
      topRight: topRight ?? this.topRight,
      bottomLeft: bottomLeft ?? this.bottomLeft,
      bottomRight: bottomRight ?? this.bottomRight,
    );
  }

  /// Returns the CSS value of the border radius.
  ///
  /// If no corner is set, it returns null. Otherwise, it returns
  /// a space-separated string of the corner values in the order:
  /// top-left, top-right, bottom-right, bottom-left.
  ///
  /// Example:
  /// ```dart
  /// final borderRadius = BorderRadiusData(
  ///   topLeft: Dim.px(10),
  ///   topRight: Dim.px(20),
  ///   bottomLeft: Dim.px(30),
  ///   bottomRight: Dim.px(40),
  /// );
  /// print(borderRadius.value);
  /// // Output: '10px 20px 40px 30px'
  /// ```
  String? get value {
    if (props.isEmpty) return null;
    if (props['border-radius'] != null) return props['border-radius'];

    String value = '';
    final topLeft = props['border-top-left-radius'];
    final topRight = props['border-top-right-radius'];
    final bottomRight = props['border-bottom-right-radius'];
    final bottomLeft = props['border-bottom-left-radius'];

    if (topLeft != null) value += '$topLeft ';
    if (topRight != null) value += '$topRight ';
    if (bottomRight != null) value += '$bottomRight ';
    if (bottomLeft != null) value += '$bottomLeft ';

    return value.trim();
  }

  /// Convert radius attributes to CSS styles.
  @override
  Map<String, String> get props => {
    if (topLeft == topRight &&
        bottomLeft == bottomRight &&
        topLeft == bottomLeft &&
        topRight == bottomRight) ...{
      'border-radius': ?topLeft?.cssText,
    } else if (topLeft != null &&
        topRight != null &&
        bottomLeft != null &&
        bottomRight != null) ...{
      'border-radius':
          '${topLeft!.cssText} ${topRight!.cssText} ${bottomRight!.cssText} ${bottomLeft!.cssText}',
    } else ...{
      'border-top-left-radius': ?topLeft?.cssText,
      'border-top-right-radius': ?topRight?.cssText,
      'border-bottom-right-radius': ?bottomRight?.cssText,
      'border-bottom-left-radius': ?bottomLeft?.cssText,
    },
  };

  @override
  String get cssText => props.cssText;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BorderRadiusData &&
          runtimeType == other.runtimeType &&
          topLeft == other.topLeft &&
          topRight == other.topRight &&
          bottomLeft == other.bottomLeft &&
          bottomRight == other.bottomRight;

  @override
  int get hashCode => Object.hash(topLeft, topRight, bottomLeft, bottomRight);
}
