part of '../theme_data.dart';

/// Represents customizable global border radius variables.
class RadiusScheme {
  /// Extra small border radius.
  final Dim? radiusXs;

  /// Small border radius.
  final Dim? radiusSm;

  /// Medium border radius.
  final Dim? radiusMd;

  /// Large border radius.
  final Dim? radiusLg;

  /// Pill / circular border radius.
  final Dim? radiusFull;

  /// Container shape radius.
  final Dim? shapeRadius;

  const RadiusScheme({
    this.radiusXs,
    this.radiusSm,
    this.radiusMd,
    this.radiusLg,
    this.radiusFull,
    this.shapeRadius,
  });

  RadiusScheme copyWith({
    Dim? radiusXs,
    Dim? radiusSm,
    Dim? radiusMd,
    Dim? radiusLg,
    Dim? radiusFull,
    Dim? shapeRadius,
  }) {
    return RadiusScheme(
      radiusXs: radiusXs ?? this.radiusXs,
      radiusSm: radiusSm ?? this.radiusSm,
      radiusMd: radiusMd ?? this.radiusMd,
      radiusLg: radiusLg ?? this.radiusLg,
      radiusFull: radiusFull ?? this.radiusFull,
      shapeRadius: shapeRadius ?? this.shapeRadius,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RadiusScheme &&
        other.radiusXs == radiusXs &&
        other.radiusSm == radiusSm &&
        other.radiusMd == radiusMd &&
        other.radiusLg == radiusLg &&
        other.radiusFull == radiusFull &&
        other.shapeRadius == shapeRadius;
  }

  @override
  int get hashCode => Object.hash(
    radiusXs,
    radiusSm,
    radiusMd,
    radiusLg,
    radiusFull,
    shapeRadius,
  );
}
