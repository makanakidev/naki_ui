part of 'index.dart';

/// {@template Filter}
/// A builder for creating CSS backdrop filter values applied
/// to the backdrop of a component.
///
/// Filters can be built using cascading `apply*` methods on
/// [Filter], or by composing standalone filter subclasses
/// (such as [BlurFilter], [BrightnessFilter], etc.)
/// using the [and] method.
///
/// ### Example 1: Using `apply*` methods
/// ```dart
/// final filters = Filter()
///   ..applyBlur(10)
///   ..applyBrightness(50)
///   ..applyContrast(50)
///   ..applyGrayscale(50)
///   ..applyHueRotate(50)
///   ..applyInvert(const Dim(1.5))
///   ..applyOpacity(const Dim(0.5))
///   ..applySaturation(const Dim.percent(50))
///   ..applySepia(const Dim(0.5));
/// ```
///
/// ### Example 2: Using `and` method
/// ```dart
/// final filters = const BlurFilter(10)
///   .and(const BrightnessFilter(50))
///   .and(const OpacityFilter(50));
/// ```
/// {@endtemplate}
class Filter implements NakiStylable {
  final List<String> _filters;

  /// {@macro Filter}
  Filter() : _filters = [];

  const Filter._() : _filters = const [];

  Filter._mutable(this._filters);

  bool get _isStandalone => false;

  List<String> get _entries => _filters;

  Filter _append(Filter filter) => _addAll(filter._entries);

  Filter _addCss(String css) => _addAll([css]);

  Filter _addAll(Iterable<String> entries) {
    if (_isStandalone) {
      throw UnsupportedError(
        'Cannot mutate a standalone $runtimeType. '
        'Use .and() to combine filters.',
      );
    }
    _filters.addAll(entries);
    return this;
  }

  /// Combines this filter with [other] and returns
  /// a new [Filter].
  ///
  /// Neither this filter nor [other] is mutated.
  Filter and(Filter other) => Filter._mutable([..._entries, ...other._entries]);

  /// Adds a blur filter effect.
  ///
  /// `value` must be between 0 and 100.
  Filter applyBlur(double value) => _append(BlurFilter(value));

  /// Adds a brightness filter effect.
  ///
  /// `value` must be between 0 and 100.
  Filter applyBrightness(double value) => _append(BrightnessFilter(value));

  /// Adds a contrast filter effect.
  ///
  /// `value` must be between 0 and 100.
  Filter applyContrast(double value) => _append(ContrastFilter(value));

  /// Adds a grayscale filter effect.
  ///
  /// `value` must be between 0 and 100.
  Filter applyGrayscale(double value) => _append(GrayscaleFilter(value));

  /// Adds a hue-rotate filter effect.
  ///
  /// `value` must be between 0 and 360.
  Filter applyHueRotate(double value) => _append(HueRotateFilter(value));

  /// Adds an invert filter effect.
  ///
  /// `Dim.percent()` is the accepted [value] type.
  Filter applyInvert(Dim value) =>
      _addCss(BackdropFilterType.invert.cssText(value));

  /// Adds an opacity filter effect.
  ///
  /// `Dim.percent()` is the accepted [value] type.
  Filter applyOpacity(Dim value) =>
      _addCss(BackdropFilterType.opacity.cssText(value));

  /// Adds a saturation filter effect.
  ///
  /// `Dim.percent()` is the accepted [value] type.
  Filter applySaturation(Dim value) =>
      _addCss(BackdropFilterType.saturate.cssText(value));

  /// Adds a sepia filter effect.
  ///
  /// `Dim.percent()` is the accepted [value] type.
  Filter applySepia(Dim value) =>
      _addCss(BackdropFilterType.sepia.cssText(value));

  /// Adds a raw CSS backdrop filter string.
  Filter applyRaw(String filter) => _append(RawFilter(filter));

  /// Removes all filters.
  Filter clear() {
    if (_isStandalone) {
      throw UnsupportedError('Cannot clear a standalone $runtimeType.');
    }
    _filters.clear();
    return this;
  }

  /// Frosted glass effect.
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
  static final dramaticOverlay = Filter()
    ..applyContrast(250)
    ..applyGrayscale(100);

  /// Dim blur effect.
  static final dimBlur = Filter()
    ..applyBlur(10)
    ..applyOpacity(const Dim(0.5));

  /// Generates a CSS string by concatenating all the filters.
  @override
  String get cssText => _filters.join(' ');

  /// Generates a CSS map entry for the filter.
  @override
  Map<String, String> get props => {
    '-webkit-backdrop-filter': cssText,
    'backdrop-filter': cssText,
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

abstract class _SingleFilter<T> extends Filter {
  /// The filter value.
  final T value;

  const _SingleFilter(this.value) : super._();

  @override
  bool get _isStandalone => true;

  @override
  List<String> get _entries => [cssText];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _SingleFilter<T> &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => Object.hash(runtimeType, value);
}

/// Standalone blur backdrop filter effect.
class BlurFilter extends _SingleFilter<double> {
  /// Creates a blur backdrop filter with [value]
  /// in pixels (0–100).
  const BlurFilter([double value = 0])
    : super(value < 0 ? 0.0 : (value > 100 ? 100.0 : value));

  @override
  String get cssText => BackdropFilterType.blur.cssText(.px(value));
}

/// Standalone brightness backdrop filter effect.
class BrightnessFilter extends _SingleFilter<double> {
  /// Creates a brightness backdrop filter with
  /// [value] in percent (0–100).
  const BrightnessFilter([double value = 100])
    : super(value < 0 ? 0.0 : (value > 100 ? 100.0 : value));

  @override
  String get cssText => BackdropFilterType.brightness.cssText(.percent(value));
}

/// Standalone contrast backdrop filter effect.
class ContrastFilter extends _SingleFilter<double> {
  /// Creates a contrast backdrop filter with
  /// [value] in percent (0–100).
  const ContrastFilter([double value = 100])
    : super(value < 0 ? 0.0 : (value > 100 ? 100.0 : value));

  @override
  String get cssText => BackdropFilterType.contrast.cssText(.percent(value));
}

/// Standalone grayscale backdrop filter effect.
class GrayscaleFilter extends _SingleFilter<double> {
  /// Creates a grayscale backdrop filter with
  /// [value] in percent (0–100).
  const GrayscaleFilter([double value = 0])
    : super(value < 0 ? 0.0 : (value > 100 ? 100.0 : value));

  @override
  String get cssText => BackdropFilterType.grayscale.cssText(.percent(value));
}

/// Standalone hue-rotate backdrop filter effect.
class HueRotateFilter extends _SingleFilter<double> {
  /// Creates a hue-rotate backdrop filter with
  /// [value] in degrees (0–360).
  const HueRotateFilter([double value = 0])
    : super(value < 0 ? 0.0 : (value > 360 ? 360.0 : value));

  @override
  String get cssText => BackdropFilterType.hueRotate.cssText(.deg(value));
}

/// Standalone invert backdrop filter effect.
class InvertFilter extends _SingleFilter<double> {
  /// Creates an invert backdrop filter with
  /// [value] in percent (0–100).
  const InvertFilter([double value = 0])
    : super(value < 0 ? 0.0 : (value > 100 ? 100.0 : value));

  @override
  String get cssText => BackdropFilterType.invert.cssText(.percent(value));
}

/// Standalone opacity backdrop filter effect.
class OpacityFilter extends _SingleFilter<double> {
  /// Creates an opacity backdrop filter with
  /// [value] in percent (0–100).
  const OpacityFilter([double value = 100])
    : super(value < 0 ? 0.0 : (value > 100 ? 100.0 : value));

  @override
  String get cssText => BackdropFilterType.opacity.cssText(.percent(value));
}

/// Standalone saturation backdrop filter effect.
class SaturationFilter extends _SingleFilter<double> {
  /// Creates a saturation backdrop filter with
  /// [value] in percent (`>= 0`).
  const SaturationFilter([double value = 100]) : super(value < 0 ? 0.0 : value);

  @override
  String get cssText => BackdropFilterType.saturate.cssText(.percent(value));
}

/// Standalone sepia backdrop filter effect.
class SepiaFilter extends _SingleFilter<double> {
  /// Creates a sepia backdrop filter with
  /// [value] in percent (0–100).
  const SepiaFilter([double value = 0])
    : super(value < 0 ? 0.0 : (value > 100 ? 100.0 : value));

  @override
  String get cssText => BackdropFilterType.sepia.cssText(.percent(value));
}

/// Standalone raw CSS backdrop filter effect.
class RawFilter extends _SingleFilter<String> {
  /// Creates a raw CSS backdrop filter from [value]
  /// (e.g., `'drop-shadow(0 4px 8px rgba(0, 0, 0, 0.25))'`).
  const RawFilter(super.value);

  @override
  String get cssText => value;
}
