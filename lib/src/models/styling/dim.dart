part of 'index.dart';

/// Represents CSS dimensions with optional `!important` suffix.
class Dim {
  /// Numeric value of the dimension.
  final double? value;

  /// CSS unit of the dimension.
  final String unit;

  /// Whether the dimension has the `!important` declaration.
  final bool isImportant;

  /// Creates a new dimension with optional [unit] and [important] flag.
  ///
  /// Prefer the [important] getter unless a constant is required.
  const Dim(this.value, {this.unit = '', bool important = false})
    : isImportant = important;

  /// Default font size (14px).
  static const Dim defaultFontSize = Dim(14, unit: 'px');

  /// Max content.
  static const maxContent = Dim(null, unit: 'max-content');

  /// Min content.
  static const minContent = Dim(null, unit: 'min-content');

  /// Fit content.
  static const fitContent = Dim(null, unit: 'fit-content');

  /// Zero.
  static const zero = Dim(0);

  /// Inherit.
  static const inherit = Dim(null, unit: 'inherit');

  /// Auto.
  static const auto = Dim(null, unit: 'auto');

  /// Normal size.
  static const normal = Dim(null, unit: 'normal');

  /// Variable (e.g. variable name: `--naki-primary-color`).
  const Dim.variable(String variableName, {String? defaultValue})
    : this(
        null,
        unit: defaultValue != null && defaultValue != ''
            ? 'var($variableName, $defaultValue)'
            : 'var($variableName)',
      );

  /// Raw CSS dimension (e.g. `calc(100% - 48px)`).
  const Dim.raw(String raw) : this(null, unit: raw);

  /// Dimension in Pixels.
  const Dim.px(double value) : this(value, unit: 'px');

  /// Dimension in Points.
  const Dim.pt(double value) : this(value, unit: 'pt');

  /// Dimension in Percentage.
  const Dim.percent(double value) : this(value, unit: '%');

  /// Dimension relative to the font size of the parent element.
  const Dim.em(double value) : this(value, unit: 'em');

  /// Dimension relative to the font size of the root element.
  const Dim.rem(double value) : this(value, unit: 'rem');

  /// Dimension relative to the width of the viewport.
  const Dim.vw(double value) : this(value, unit: 'vw');

  /// Dimension relative to the height of the viewport.
  const Dim.vh(double value) : this(value, unit: 'vh');

  /// Dimension relative to the smallest viewport dimension.
  const Dim.vmin(double value) : this(value, unit: 'vmin');

  /// Dimension relative to the dynamic viewport height.
  const Dim.dvh(double value) : this(value, unit: 'dvh');

  /// Dimension relative to the dynamic viewport width.
  const Dim.dvw(double value) : this(value, unit: 'dvw');

  /// Dimension relative to the small viewport height.
  const Dim.svh(double value) : this(value, unit: 'svh');

  /// Dimension relative to the small viewport width.
  const Dim.svw(double value) : this(value, unit: 'svw');

  /// Dimension relative to the large viewport height.
  const Dim.lvh(double value) : this(value, unit: 'lvh');

  /// Dimension relative to the large viewport width.
  const Dim.lvw(double value) : this(value, unit: 'lvw');

  /// Dimension relative to the maximum viewport width or height.
  const Dim.vmax(double value) : this(value, unit: 'vmax');

  /// Dimension in Degrees.
  const Dim.deg(double value) : this(value, unit: 'deg');

  /// Dimension in Radians.
  const Dim.rad(double value) : this(value, unit: 'rad');

  /// Dimension in Gradians.
  const Dim.grad(double value) : this(value, unit: 'grad');

  /// Creates a copy of this dimension with optional changes.
  Dim copyWith({double? value, String? unit, bool? important}) {
    return Dim(
      value ?? this.value,
      unit: unit ?? this.unit,
      important: important ?? isImportant,
    );
  }

  /// This dimension with the `!important` declaration.
  ///
  /// Example usage:
  /// ```
  /// final dim = Dim.px(12).important;
  /// print(dim.cssText); // Output: '12px !important'
  /// ```
  Dim get important => isImportant ? this : copyWith(important: true);

  /// Adds another dimension with same unit to this dimension.
  Dim operator +(Dim other) {
    if (value == null || other.value == null || other.unit != unit) return this;
    return Dim(value! + other.value!, unit: unit, important: isImportant);
  }

  /// Subtracts another dimension with same unit from this dimension.
  Dim operator -(Dim other) {
    if (value == null || other.value == null || other.unit != unit) return this;
    return Dim(value! - other.value!, unit: unit, important: isImportant);
  }

  /// Multiplies this dimension by a factor.
  Dim operator *(num factor) {
    if (value == null) return this;
    return Dim(value! * factor, unit: unit, important: isImportant);
  }

  /// Divides this dimension by a factor.
  Dim operator /(num factor) {
    if (value == null) return this;
    return Dim(value! / factor, unit: unit, important: isImportant);
  }

  /// Returns a CSS-formatted dimension string.
  ///
  /// The returned string includes the unit and an optional `!important`
  /// suffix. Values are formatted without unnecessary decimal places
  /// (e.g., `12px` instead of `12.0px`).
  ///
  /// Example usage:
  /// ```
  /// final dim = Dim.px(12.0).important;
  /// print(dim.cssText); // Output: '12px !important'
  /// ```
  String get cssText {
    final formattedValue = value == null ? '' : value!.toCleanString;
    final suffix = isImportant ? ' !important' : '';
    return '$formattedValue${unit.trim()}$suffix';
  }

  /// String representation of this dimension.
  ///
  /// Example usage:
  /// ```
  /// final dim = Dim.px(12.0).important;
  /// print('$dim'); // Output: '12px !important'
  /// ```
  @override
  String toString() => cssText;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Dim &&
          runtimeType == other.runtimeType &&
          value == other.value &&
          unit == other.unit &&
          isImportant == other.isImportant;

  @override
  int get hashCode => Object.hashAll([value, unit, isImportant]);
}
