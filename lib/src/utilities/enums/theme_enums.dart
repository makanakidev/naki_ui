part of 'index.dart';

/// Theme mode options.
enum ThemeMode {
  /// Dark theme mode.
  dark,

  /// Light theme mode.
  light,

  /// Browser/device theme mode.
  system
  ;

  /// Converts a string to a ThemeMode.
  ///
  /// If [value] is not a valid theme mode,
  /// it defaults to [ThemeMode.system].
  ///
  /// Example:
  /// ```dart
  /// final mode = ThemeMode.from('dark');
  /// ```
  factory ThemeMode.from(String? value) {
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }
}

/// Represents CSS backdrop filter functions.
enum BackdropFilterType {
  /// Blurs the background.
  /// Requires a unit like 'Dim.px(10)'.
  blur._('blur'),

  /// Makes the background brighter (under 100%) or darker (over 100%).
  /// Requires a value like 'Dim.percent(50)'.
  brightness._('brightness'),

  /// Adjusts the contrast of the background.
  /// Requires a value like 'Dim.percent(50)'.
  contrast._('contrast'),

  /// Converts the background to black and white.
  /// Requires a value like 'Dim.percent(50)'.
  grayscale._('grayscale'),

  /// Rotates the hue of the background.
  /// Requires a value like 'Dim.deg(90)'.
  hueRotate._('hue-rotate'),

  /// Inverts the background colors.
  /// Requires a value like 'Dim.percent(50)', 'Dim(1.5)', or 'Dim(0.4)'.
  invert._('invert'),

  /// Adjusts the opacity of the background.
  /// Requires a value like 'Dim.percent(50)', 'Dim(1.5)', or 'Dim(0.4)'.
  opacity._('opacity'),

  /// Adjusts the saturation of the background.
  /// Requires a value like 'Dim.percent(50)', 'Dim(1.5)', or 'Dim(0.4)'.
  saturate._('saturate'),

  /// Converts the background to a warm, vintage brown tint.
  /// Requires a value like 'Dim.percent(50)', 'Dim(1.5)', or 'Dim(0.4)'.
  sepia._('sepia')
  ;

  /// The standard CSS value representing the backdrop filter type.
  final String css;
  const BackdropFilterType._(this.css);

  /// Converts the filter type and value to a CSS string
  /// (e.g., "blur(10px)").
  String cssText(Dim value) => '$css($value)';
}
