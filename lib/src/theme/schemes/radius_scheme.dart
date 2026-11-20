part of '../theme.dart';

/// Represents customizable global border radius variables.
class RadiusScheme {
  /// Small border radius.
  final Dim? radiusSm;

  /// Medium border radius.
  final Dim? radiusMd;

  /// Large border radius.
  final Dim? radiusLg;

  /// Container shape radius.
  final Dim? shapeRadius;

  const RadiusScheme({
    this.radiusSm,
    this.radiusMd,
    this.radiusLg,
    this.shapeRadius,
  });

  RadiusScheme copyWith({
    Dim? radiusSm,
    Dim? radiusMd,
    Dim? radiusLg,
    Dim? shapeRadius,
  }) {
    return RadiusScheme(
      radiusSm: radiusSm ?? this.radiusSm,
      radiusMd: radiusMd ?? this.radiusMd,
      radiusLg: radiusLg ?? this.radiusLg,
      shapeRadius: shapeRadius ?? this.shapeRadius,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RadiusScheme &&
        other.radiusSm == radiusSm &&
        other.radiusMd == radiusMd &&
        other.shapeRadius == shapeRadius &&
        other.radiusLg == radiusLg;
  }

  @override
  int get hashCode => Object.hash(radiusSm, radiusMd, radiusLg, shapeRadius);
}
