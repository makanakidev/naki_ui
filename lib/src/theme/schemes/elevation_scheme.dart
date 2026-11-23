part of '../theme_data.dart';

/// Represents customizable global shadow and elevation variables.
class ElevationScheme {
  /// Default shadow color.
  final Color? shadowColor;

  /// Small shadow color.
  final Color? smallShadowColor;

  /// Medium shadow color.
  final Color? mediumShadowColor;

  /// Large shadow color.
  final Color? largeShadowColor;

  /// Elevated card box-shadow value.
  final String? cardShadow;

  /// AppBar box-shadow value.
  final String? appbarShadow;

  /// Bottom navigation bar box-shadow value.
  final String? bottomNavbarShadow;

  /// Floating bottom navigation bar box-shadow value.
  final String? bottomNavbarFloatingShadow;

  /// Glassmorphism surface box-shadow value.
  final String? glassShadow;

  /// Hover box-shadow value for glass cards.
  final String? cardGlassHoverShadow;

  const ElevationScheme({
    this.shadowColor,
    this.smallShadowColor,
    this.mediumShadowColor,
    this.largeShadowColor,
    this.cardShadow,
    this.appbarShadow,
    this.bottomNavbarShadow,
    this.bottomNavbarFloatingShadow,
    this.glassShadow,
    this.cardGlassHoverShadow,
  });

  ElevationScheme copyWith({
    Color? shadowColor,
    Color? smallShadowColor,
    Color? mediumShadowColor,
    Color? largeShadowColor,
    String? cardShadow,
    String? appbarShadow,
    String? bottomNavbarShadow,
    String? bottomNavbarFloatingShadow,
    String? glassShadow,
    String? cardGlassHoverShadow,
  }) {
    return ElevationScheme(
      shadowColor: shadowColor ?? this.shadowColor,
      smallShadowColor: smallShadowColor ?? this.smallShadowColor,
      mediumShadowColor: mediumShadowColor ?? this.mediumShadowColor,
      largeShadowColor: largeShadowColor ?? this.largeShadowColor,
      cardShadow: cardShadow ?? this.cardShadow,
      appbarShadow: appbarShadow ?? this.appbarShadow,
      bottomNavbarShadow: bottomNavbarShadow ?? this.bottomNavbarShadow,
      bottomNavbarFloatingShadow:
          bottomNavbarFloatingShadow ?? this.bottomNavbarFloatingShadow,
      glassShadow: glassShadow ?? this.glassShadow,
      cardGlassHoverShadow: cardGlassHoverShadow ?? this.cardGlassHoverShadow,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ElevationScheme &&
        other.shadowColor == shadowColor &&
        other.smallShadowColor == smallShadowColor &&
        other.mediumShadowColor == mediumShadowColor &&
        other.largeShadowColor == largeShadowColor &&
        other.cardShadow == cardShadow &&
        other.appbarShadow == appbarShadow &&
        other.bottomNavbarShadow == bottomNavbarShadow &&
        other.bottomNavbarFloatingShadow == bottomNavbarFloatingShadow &&
        other.glassShadow == glassShadow &&
        other.cardGlassHoverShadow == cardGlassHoverShadow;
  }

  @override
  int get hashCode => Object.hash(
    shadowColor,
    smallShadowColor,
    mediumShadowColor,
    largeShadowColor,
    cardShadow,
    appbarShadow,
    bottomNavbarShadow,
    bottomNavbarFloatingShadow,
    glassShadow,
    cardGlassHoverShadow,
  );
}
