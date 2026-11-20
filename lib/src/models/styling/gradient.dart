part of 'index.dart';

/// A builder for creating CSS background gradients.
///
/// Supports linear, radial, conic, and repeating gradient types.
///
/// ### Color Stop Specifications:
/// - **Linear & Radial gradients**: Color stops accept only length and percentage units
///   (e.g., `Dim.percent(50)`, `Dim.px(20)`, `Dim.rem(1.5)`). Unitless numbers
///   are not valid in CSS.
/// - **Conic gradients**: Color stops accept only angle and percentage units
///   (e.g., `Dim.deg(90)`, `Dim.percent(50)`). Length units (`px`, `rem`) are not
///   valid for conic gradients.
///
/// ### Example
/// ```dart
/// final gradient = Gradient()
///   ..applyLinear(
///     colors: [Colors.blue, Colors.purple],
///     direction: LinearGradientDirection.toRight,
///   );
/// ```
class Gradient implements NakiStylable {
  final List<String> _gradients = [];

  /// Adds a linear gradient.
  ///
  /// If both [angle] and [direction] are provided, [angle] takes precedence.
  ///
  /// ### Properties:
  /// - [colors]: List of stop colors (minimum of 2 recommended).
  /// - [angle]: Angle of the gradient. It will be normalized to be within
  ///   the 1-360 range (e.g., 400° becomes 40°, -10° becomes 350°).
  /// - [direction]: Linear gradient direction.
  /// - [stops]: Optional stops corresponding to [colors]. Accepts length or percentage
  ///   units (e.g., `Dim.percent(50)`, `Dim.px(20)`, `Dim.rem(1.5)`). Unitless numbers
  ///   are not valid CSS.
  ///
  /// ### Example
  /// ```dart
  /// final gradient = Gradient()
  ///   ..applyLinear(
  ///     colors: const [Color('#3b82f6'), Colors.purple],
  ///     direction: LinearGradientDirection.toRight,
  ///     stops: const [Dim.px(20), Dim.percent(80)],
  ///     angle: 90,
  ///   );
  /// ```
  ///
  Gradient applyLinear({
    required List<Color> colors,
    double? angle,
    LinearGradientDirection? direction,
    List<Dim>? stops,
  }) {
    final List<String> parts = [];

    if (angle != null) {
      angle = angle % 360;
      parts.add('${angle}deg');
    } else if (direction != null) {
      parts.add(direction.css);
    }

    for (int i = 0; i < colors.length; i++) {
      final colorStr = colors[i].value;

      if (stops != null && i < stops.length) {
        parts.add('$colorStr ${stops[i]}');
      } else {
        parts.add(colorStr);
      }
    }

    _gradients.add(GradientType.linear.cssText(parts));

    return this;
  }

  /// Adds a radial gradient.
  ///
  /// ### Properties:
  /// - [colors]: List of stop colors.
  /// - [shape]: Shape of the gradient.
  /// - [position]: Position of the gradient center.
  /// - [stops]: Optional stops corresponding to [colors]. Accepts length or percentage
  ///   units (e.g., `Dim.percent(50)`, `Dim.px(20)`, `Dim.rem(1.5)`). Unitless numbers
  ///   are not valid CSS.
  ///
  /// ### Example
  /// ```dart
  /// final gradient = Gradient()
  ///   ..applyRadial(
  ///     colors: const [Colors.red, Color('#feb47b')],
  ///     shape: Shape.circle,
  ///     position: RadialGradientPosition.center,
  ///     stops: const [Dim.px(20), Dim.percent(80)],
  ///   );
  /// ```
  Gradient applyRadial({
    required List<Color> colors,
    Shape? shape,
    RadialGradientPosition? position,
    List<Dim>? stops,
  }) {
    final List<String> parts = [];

    if (shape != null && position != null) {
      parts.add('${shape.css} at ${position.css}');
    } else if (shape != null) {
      parts.add(shape.css);
    } else if (position != null) {
      parts.add('at ${position.css}');
    }

    for (int i = 0; i < colors.length; i++) {
      final colorStr = colors[i].value;

      if (stops != null && i < stops.length) {
        parts.add('$colorStr ${stops[i]}');
      } else {
        parts.add(colorStr);
      }
    }

    _gradients.add(GradientType.radial.cssText(parts));

    return this;
  }

  /// Adds a conic gradient.
  ///
  /// ### Properties:
  /// - [colors]: List of stop colors.
  /// - [angle]: Starting angle of rotation between 0 and 360.
  /// - [position]: Position of the gradient center (e.g., `ConicGradientPosition.center`).
  /// - [stops]: Optional stops corresponding to [colors]. Accepts angle or percentage
  ///   units (e.g., `Dim.deg(0)`, `Dim.percent(50)`). Length units (`px`, `rem`) are not
  ///   valid for conic gradients.
  ///
  /// ### Example
  /// ```dart
  /// final gradient = Gradient()
  ///   ..applyConic(
  ///     colors: const [Color('#ff0000'), Color('#00ff00'), Color('#0000ff')],
  ///     angle: 45,
  ///     position: ConicGradientPosition.center,
  ///     stops: const [Dim.deg(0), Dim.deg(180), Dim.deg(360)],
  ///   );
  /// ```
  Gradient applyConic({
    required List<Color> colors,
    double? angle,
    ConicGradientPosition? position,
    List<Dim>? stops,
  }) {
    final List<String> parts = [];

    if (angle != null && position != null) {
      angle = angle % 360;
      parts.add('from ${angle}deg at ${position.css}');
    } else if (angle != null) {
      angle = angle % 360;
      parts.add('from ${angle}deg');
    } else if (position != null) {
      parts.add('at ${position.css}');
    }

    for (int i = 0; i < colors.length; i++) {
      final colorStr = colors[i].value;

      if (stops != null && i < stops.length) {
        parts.add('$colorStr ${stops[i]}');
      } else {
        parts.add(colorStr);
      }
    }

    _gradients.add(GradientType.conic.cssText(parts));

    return this;
  }

  /// Adds a repeating linear gradient.
  ///
  /// ### Properties:
  /// - [colors]: List of stop colors.
  /// - [angle]: Angle of the gradient. It will be normalized to be within the 0-360 range.
  /// - [direction]: Linear gradient direction (e.g., `LinearGradientDirection.toRight`).
  /// - [stops]: Optional stops corresponding to [colors]. Accepts length or percentage
  ///   units (e.g., `Dim.percent(50)`, `Dim.px(20)`, `Dim.rem(1.5)`). Unitless numbers
  ///   are not valid CSS.
  ///
  /// ### Example
  /// ```dart
  /// final stripes = Gradient()
  ///   ..applyRepeatingLinear(
  ///     colors: const [Color('#000000'), Color('#ffffff')],
  ///     angle: 45,
  ///     stops: const [Dim.px(0), Dim.px(20)],
  ///   );
  /// ```
  Gradient applyRepeatingLinear({
    required List<Color> colors,
    double? angle,
    LinearGradientDirection? direction,
    List<Dim>? stops,
  }) {
    final List<String> parts = [];

    if (angle != null) {
      angle = angle % 360;
      parts.add('${angle}deg');
    } else if (direction != null) {
      parts.add(direction.css);
    }

    for (int i = 0; i < colors.length; i++) {
      final colorStr = colors[i].value;

      if (stops != null && i < stops.length) {
        parts.add('$colorStr ${stops[i]}');
      } else {
        parts.add(colorStr);
      }
    }

    _gradients.add(GradientType.repeatingLinear.cssText(parts));

    return this;
  }

  /// Adds a repeating radial gradient.
  ///
  /// ### Properties:
  /// - [colors]: List of stop colors.
  /// - [shape]: Shape of the gradient (e.g., `Shape.circle`, `Shape.ellipse`).
  /// - [position]: Position of the gradient center (e.g., `RadialGradientPosition.center`).
  /// - [stops]: Optional stops corresponding to [colors]. Accepts length or percentage
  ///   units (e.g., `Dim.percent(50)`, `Dim.px(20)`, `Dim.rem(1.5)`). Unitless numbers
  ///   are not valid CSS.
  ///
  /// ### Example
  /// ```dart
  /// final ripple = Gradient()
  ///   ..applyRepeatingRadial(
  ///     colors: const [Color('#ff0000'), Color('#0000ff')],
  ///     shape: Shape.circle,
  ///     position: RadialGradientPosition.center,
  ///     stops: const [Dim.px(0), Dim.px(15)],
  ///   );
  /// ```
  Gradient applyRepeatingRadial({
    required List<Color> colors,
    Shape? shape,
    RadialGradientPosition? position,
    List<Dim>? stops,
  }) {
    final List<String> parts = [];

    if (shape != null && position != null) {
      parts.add('${shape.css} at ${position.css}');
    } else if (shape != null) {
      parts.add(shape.css);
    } else if (position != null) {
      parts.add('at ${position.css}');
    }

    for (int i = 0; i < colors.length; i++) {
      final colorStr = colors[i].value;

      if (stops != null && i < stops.length) {
        parts.add('$colorStr ${stops[i]}');
      } else {
        parts.add(colorStr);
      }
    }

    _gradients.add(GradientType.repeatingRadial.cssText(parts));

    return this;
  }

  /// Adds a repeating conic gradient.
  ///
  /// ### Properties:
  /// - [colors]: List of stop colors.
  /// - [angle]: Starting angle of rotation between 0 and 360.
  /// - [position]: Position of the gradient center (e.g., `ConicGradientPosition.center`).
  /// - [stops]: Optional stops corresponding to [colors]. Accepts angle or percentage
  ///   units (e.g., `Dim.deg(0)`, `Dim.percent(50)`). Length units (`px`, `rem`) are not
  ///   valid for conic gradients.
  ///
  /// ### Example
  /// ```dart
  /// final pinwheel = Gradient()
  ///   ..applyRepeatingConic(
  ///     colors: const [Color('#ff0000'), Color('#00ff00'), Color('#0000ff')],
  ///     angle: 0,
  ///     position: ConicGradientPosition.center,
  ///     stops: const [Dim.deg(0), Dim.deg(20), Dim.deg(40)],
  ///   );
  /// ```
  Gradient applyRepeatingConic({
    required List<Color> colors,
    double? angle,
    ConicGradientPosition? position,
    List<Dim>? stops,
  }) {
    final List<String> parts = [];

    if (angle != null && position != null) {
      angle = angle % 360;
      parts.add('from ${angle}deg at ${position.css}');
    } else if (angle != null) {
      angle = angle % 360;
      parts.add('from ${angle}deg');
    } else if (position != null) {
      parts.add('at ${position.css}');
    }

    for (int i = 0; i < colors.length; i++) {
      final colorStr = colors[i].value;

      if (stops != null && i < stops.length) {
        parts.add('$colorStr ${stops[i]}');
      } else {
        parts.add(colorStr);
      }
    }

    _gradients.add(GradientType.repeatingConic.cssText(parts));

    return this;
  }

  /// Adds a raw CSS gradient string.
  Gradient applyRaw(String gradient) {
    _gradients.add(gradient);
    return this;
  }

  /// Removes all gradients.
  Gradient clear() {
    _gradients.clear();
    return this;
  }

  /// Sunset gradient preset.
  static final sunset = Gradient()
    ..applyLinear(
      colors: const [Color('#ff7e5f'), Color('#feb47b')],
      angle: 135,
    );

  /// Ocean breeze gradient preset.
  static final oceanBreeze = Gradient()
    ..applyLinear(
      colors: const [Color('#2b5876'), Color('#4e4376')],
      direction: LinearGradientDirection.toRight,
    );

  /// Lush gradient preset.
  static final lush = Gradient()
    ..applyLinear(
      colors: const [Color('#56ab2f'), Color('#a8e063')],
      direction: LinearGradientDirection.toRight,
    );

  /// Purple haze gradient preset.
  static final purpleHaze = Gradient()
    ..applyLinear(
      colors: const [Color('#7303c0'), Color('#ec38bc'), Color('#fdeff9')],
      direction: LinearGradientDirection.toRight,
    );

  /// Generates a CSS string by concatenating all gradients.
  @override
  String get cssText => _gradients.join(', ');

  /// Generates a CSS map entry for the gradient.
  @override
  Map<String, String> get props => {'background-image': cssText};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Gradient &&
          runtimeType == other.runtimeType &&
          listEquals(_gradients, other._gradients);

  @override
  int get hashCode => Object.hashAll(_gradients);
}
