part of 'index.dart';

/// A builder for creating CSS backdrop filter values.
///
/// It is used to create a backdrop filter that is applied to
/// the backdrop of a component.
///
/// ### Example
/// ```dart
/// const filters = Filter()
///   ..applyBlur(10)
///   ..applyBrightness(50)
///   ..applyContrast(50)
///   ..applyGrayscale(50)
///   ..applyHueRotate(50)
///   ..applyInvert(Dim(1.5))
///   ..applyOpacity(Dim(0.5))
///   ..applySaturation(Dim.percent(50))
///   ..applySepia(Dim(0.5));
/// ```
class Filter implements NakiStylable {
  final List<String> _filters = [];

  /// Adds a blur filter effect.
  ///
  /// `value` must be between 0 and 100px.
  Filter applyBlur(double value) {
    value = value.clamp(0, 100);
    _filters.add(BackdropFilterType.blur.cssText(.px(value)));
    return this;
  }

  /// Adds a brightness filter effect.
  ///
  /// `value` must be between 0 and 100%.
  Filter applyBrightness(double value) {
    value = value.clamp(0, 100);
    _filters.add(BackdropFilterType.brightness.cssText(.percent(value)));
    return this;
  }

  /// Adds a contrast filter effect.
  ///
  /// `value` must be between 0 and 100%.
  Filter applyContrast(double value) {
    value = value.clamp(0, 100);
    _filters.add(BackdropFilterType.contrast.cssText(.percent(value)));
    return this;
  }

  /// Adds a grayscale filter effect.
  ///
  /// `value` must be between 0 and 100%.
  Filter applyGrayscale(double value) {
    value = value.clamp(0, 100);
    _filters.add(BackdropFilterType.grayscale.cssText(.percent(value)));
    return this;
  }

  /// Adds a hue-rotate filter effect.
  ///
  /// `value` must be between 0 and 360 degrees.
  Filter applyHueRotate(double value) {
    value = value.clamp(0, 360);
    _filters.add(BackdropFilterType.hueRotate.cssText(.deg(value)));
    return this;
  }

  /// Adds a invert filter effect.
  ///
  /// `value` can be 'Dim.percent(50)' or 'Dim(0.5)'.
  Filter applyInvert(Dim value) {
    _filters.add(BackdropFilterType.invert.cssText(value));
    return this;
  }

  /// Adds a opacity filter effect.
  ///
  /// `value` can be 'Dim.percent(50)' or 'Dim(0.5)'.
  Filter applyOpacity(Dim value) {
    _filters.add(BackdropFilterType.opacity.cssText(value));
    return this;
  }

  /// Adds a saturation filter effect.
  ///
  /// `value` can be 'Dim.percent(50)' or 'Dim(0.5)'.
  Filter applySaturation(Dim value) {
    _filters.add(BackdropFilterType.saturate.cssText(value));
    return this;
  }

  /// Adds a sepia filter effect.
  ///
  /// `value` can be 'Dim.percent(50)' or 'Dim(0.5)'.
  Filter applySepia(Dim value) {
    _filters.add(BackdropFilterType.sepia.cssText(value));
    return this;
  }

  /// Removes all filters.
  Filter clear() {
    _filters.clear();
    return this;
  }

  /// Frosted glass effect.
  ///
  /// Applied `blur` (3px), `brightness` (50%), `contrast` (50%),
  /// `grayscale` (50%), `hue-rotate` (50%), `invert` (1.5),
  /// `opacity` (0.5), `saturation` (50%), `sepia` (50%)
  static final frostedGlass = Filter()
    ..applyBlur(3)
    ..applyBrightness(50)
    ..applyContrast(50)
    ..applyGrayscale(50)
    ..applyHueRotate(50)
    ..applyInvert(const Dim(1.5))
    ..applyOpacity(const Dim(0.5))
    ..applySaturation(const Dim.percent(50))
    ..applySepia(const Dim(0.5));

  /// Dramatic overlay effect.
  ///
  /// Applied contrast (250%), grayscale (100%)
  static final dramaticOverlay = Filter()
    ..applyContrast(250)
    ..applyGrayscale(100);

  /// Dim blur effect.
  ///
  /// Applied blur (10px), opacity (0.5)
  static final dimBlur = Filter()
    ..applyBlur(10)
    ..applyOpacity(const Dim(0.5));

  /// Generates a CSS string by concatenating all the filters.
  @override
  String get cssText => _filters.join(' ');

  /// Generates a CSS map entry for the filter.
  @override
  Map<String, String> get props => {
    'backdrop-filter': cssText,
    '-webkit-backdrop-filter': cssText,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Filter &&
          runtimeType == other.runtimeType &&
          listEquals(_filters, other._filters);

  @override
  int get hashCode => Object.hashAll(_filters);
}
