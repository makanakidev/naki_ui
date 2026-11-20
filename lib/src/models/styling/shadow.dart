part of 'index.dart';

/// Shadow attributes of a component.
class Shadow implements NakiStylable {
  /// The x-offset of the shadow (in pixels).
  final double? offsetX;

  /// The y-offset of the shadow (in pixels).
  final double? offsetY;

  /// The blur radius of the shadow (in pixels).
  final double? blurRadius;

  /// The spread radius of the shadow (in pixels).
  final double? spreadRadius;

  /// The color of the shadow.
  final Color? color;

  /// Create a new shadow.
  const Shadow({
    this.offsetX,
    this.offsetY,
    this.blurRadius,
    this.spreadRadius,
    this.color,
  });

  /// Small shadow
  static const small = Shadow(
    offsetX: 0,
    offsetY: 2,
    blurRadius: 8.0,
    color: Colors.black,
  );

  /// Medium shadow
  static const medium = Shadow(
    offsetX: 0,
    offsetY: 4,
    blurRadius: 16.0,
    color: Colors.black,
  );

  /// Large shadow
  static const large = Shadow(
    offsetX: 0,
    offsetY: 8,
    blurRadius: 32.0,
    spreadRadius: 2.0,
    color: Colors.black,
  );

  /// Extra large shadow
  static const extraLarge = Shadow(
    offsetX: 0,
    offsetY: 16,
    blurRadius: 64.0,
    spreadRadius: 4.0,
    color: Colors.black,
  );

  /// Creates a copy of the current shadow with optional new values.
  Shadow copyWith({
    double? offsetX,
    double? offsetY,
    double? blurRadius,
    double? spreadRadius,
    Color? color,
  }) {
    return Shadow(
      offsetX: offsetX ?? this.offsetX,
      offsetY: offsetY ?? this.offsetY,
      blurRadius: blurRadius ?? this.blurRadius,
      spreadRadius: spreadRadius ?? this.spreadRadius,
      color: color ?? this.color,
    );
  }

  /// Converts shadow attributes to a CSS style map.
  @override
  Map<String, String> get props {
    final x = (offsetX ?? 0).toPx;
    final y = (offsetY ?? 0).toPx;
    final blur = blurRadius?.toPx ?? (spreadRadius != null ? '0px' : null);
    final spread = spreadRadius?.toPx;
    final c = color?.value;

    return {
      'box-shadow': [x, y, ?blur, ?spread, ?c].join(' '),
    };
  }

  @override
  String get cssText => props.cssText;

  /// Gets the CSS value of the `box-shadow` property.
  ///
  /// Returns `null` if the properties are not set.
  ///
  /// Example:
  /// ```dart
  /// const Shadow(
  ///   offsetX: 2,
  ///   offsetY: 4,
  ///   blurRadius: 8,
  ///   color: Colors.black,
  /// ).value;
  /// // Returns '2px 4px 8px 0px #000000'
  /// ```
  String get value => props['box-shadow']!;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Shadow &&
          runtimeType == other.runtimeType &&
          offsetX == other.offsetX &&
          offsetY == other.offsetY &&
          blurRadius == other.blurRadius &&
          spreadRadius == other.spreadRadius &&
          color == other.color;

  @override
  int get hashCode =>
      Object.hash(offsetX, offsetY, blurRadius, spreadRadius, color);
}
