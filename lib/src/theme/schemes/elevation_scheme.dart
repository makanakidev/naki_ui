part of '../theme.dart';

/// Represents customizable global shadow and elevation color variables.
class ElevationScheme {
  /// Default shadow color.
  final Color? shadowColor;

  /// Small shadow color.
  final Color? smallShadowColor;

  /// Medium shadow color.
  final Color? mediumShadowColor;

  /// Large shadow color.
  final Color? largeShadowColor;

  const ElevationScheme({
    this.shadowColor,
    this.smallShadowColor,
    this.mediumShadowColor,
    this.largeShadowColor,
  });

  ElevationScheme copyWith({
    Color? shadowColor,
    Color? smallShadowColor,
    Color? mediumShadowColor,
    Color? largeShadowColor,
  }) {
    return ElevationScheme(
      shadowColor: shadowColor ?? this.shadowColor,
      smallShadowColor: smallShadowColor ?? this.smallShadowColor,
      mediumShadowColor: mediumShadowColor ?? this.mediumShadowColor,
      largeShadowColor: largeShadowColor ?? this.largeShadowColor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ElevationScheme &&
        other.shadowColor == shadowColor &&
        other.smallShadowColor == smallShadowColor &&
        other.mediumShadowColor == mediumShadowColor &&
        other.largeShadowColor == largeShadowColor;
  }

  @override
  int get hashCode => Object.hash(
    shadowColor,
    smallShadowColor,
    mediumShadowColor,
    largeShadowColor,
  );
}
