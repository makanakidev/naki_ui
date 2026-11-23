part of 'index.dart';

void _appendColorStops(
  List<String> parts,
  List<Color> colors,
  List<Dim>? stops,
) {
  for (int i = 0; i < colors.length; i++) {
    final colorStr = colors[i].value;
    if (stops != null && i < stops.length) {
      parts.add('$colorStr ${stops[i]}');
    } else {
      parts.add(colorStr);
    }
  }
}

String _linearCssText(
  GradientType type, {
  required List<Color> colors,
  double? angle,
  LinearGradientDirection? direction,
  List<Dim>? stops,
}) {
  final List<String> parts = [];

  if (angle != null) {
    parts.add('${angle % 360}deg');
  } else if (direction != null) {
    parts.add(direction.css);
  }

  _appendColorStops(parts, colors, stops);
  return type.cssText(parts);
}

String _radialCssText(
  GradientType type, {
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

  _appendColorStops(parts, colors, stops);
  return type.cssText(parts);
}

String _conicCssText(
  GradientType type, {
  required List<Color> colors,
  double? angle,
  ConicGradientPosition? position,
  List<Dim>? stops,
}) {
  final List<String> parts = [];

  if (angle != null && position != null) {
    parts.add('from ${angle % 360}deg at ${position.css}');
  } else if (angle != null) {
    parts.add('from ${angle % 360}deg');
  } else if (position != null) {
    parts.add('at ${position.css}');
  }

  _appendColorStops(parts, colors, stops);
  return type.cssText(parts);
}

/// {@template Gradient}
/// A builder for creating CSS background gradients.
///
/// Supports linear, radial, conic, and repeating gradient types.
///
/// Gradients can be built using cascading `apply*` methods
/// on [Gradient], or by composing standalone gradient
/// subclasses (such as [LinearGradient], [RadialGradient],
/// [ConicGradient], etc.) using the [and] method.
///
/// ### Color Stop Specifications:
/// - **Linear & Radial gradients**: Color stops accept only
///   length and percentage units (e.g., `Dim.percent(50)`,
///   `Dim.px(20)`, `Dim.rem(1.5)`). Unitless numbers are not
///   valid in CSS.
/// - **Conic gradients**: Color stops accept only angle
///   and percentage units (e.g., `Dim.deg(90)`,
///   `Dim.percent(50)`). Length units (`px`, `rem`) are
///   not valid for conic gradients.
///
/// ### Example 1: Using `apply*` methods
/// ```dart
/// final gradient = Gradient()
///   ..applyLinear(
///     colors: const [Colors.blue, Colors.purple],
///     direction: LinearGradientDirection.toRight,
///   );
/// ```
///
/// ### Example 2: Using `and` method
/// ```dart
/// final gradient1 = const LinearGradient(
///   colors: [Color('#3b82f6'), Color('#8b5cf6')],
///   direction: LinearGradientDirection.toRight,
/// );
///
/// final gradient2 = const RadialGradient(
///   colors: [Color('rgba(255,255,255,0.2)'), Colors.transparent],
///   shape: Shape.circle,
///   position: RadialGradientPosition.topLeft,
/// );
///
/// final layeredGradient = gradient1.and(gradient2);
/// ```
/// {@endtemplate}
class Gradient implements NakiStylable {
  final List<String> _gradients;

  /// {@macro Gradient}
  Gradient() : _gradients = [];

  const Gradient._() : _gradients = const [];

  Gradient._mutable(this._gradients);

  bool get _isStandalone => false;

  List<String> get _entries => _gradients;

  Gradient _append(Gradient gradient) {
    if (_isStandalone) {
      throw UnsupportedError(
        'Cannot mutate a standalone $runtimeType. '
        'Use .and() to combine gradients.',
      );
    }
    _gradients.addAll(gradient._entries);
    return this;
  }

  /// Combines this gradient with [other] and returns
  /// a new [Gradient].
  ///
  /// Neither this gradient nor [other] is mutated.
  Gradient and(Gradient other) =>
      Gradient._mutable([..._entries, ...other._entries]);

  /// Adds a linear gradient.
  ///
  /// If both [angle] and [direction] are provided,
  /// [angle] takes precedence.
  ///
  /// ### Properties:
  /// - [colors]: List of stop colors (minimum of 2 recommended).
  /// - [angle]: Angle of the gradient. It will be normalized
  ///   to be within the 1-360 range (e.g., 400° becomes 40°,
  ///   -10° becomes 350°).
  /// - [direction]: Linear gradient direction.
  /// - [stops]: Optional stops corresponding to [colors].
  ///   Accepts length or percentage units (e.g., `Dim.percent(50)`,
  ///   `Dim.px(20)`, `Dim.rem(1.5)`). Unitless numbers are not
  ///   valid CSS.
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
  Gradient applyLinear({
    required List<Color> colors,
    double? angle,
    LinearGradientDirection? direction,
    List<Dim>? stops,
  }) => _append(
    LinearGradient(
      colors: colors,
      angle: angle,
      direction: direction,
      stops: stops,
    ),
  );

  /// Adds a radial gradient.
  ///
  /// ### Properties:
  /// - [colors]: List of stop colors.
  /// - [shape]: Shape of the gradient.
  /// - [position]: Position of the gradient center.
  /// - [stops]: Optional stops corresponding to [colors].
  ///   Accepts length or percentage units (e.g., `Dim.percent(50)`,
  ///   `Dim.px(20)`, `Dim.rem(1.5)`). Unitless numbers are not
  ///   valid CSS.
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
  }) => _append(
    RadialGradient(
      colors: colors,
      shape: shape,
      position: position,
      stops: stops,
    ),
  );

  /// Adds a conic gradient.
  ///
  /// ### Properties:
  /// - [colors]: List of stop colors.
  /// - [angle]: Starting angle of rotation between 0 and 360.
  /// - [position]: Position of the gradient center (e.g.,
  ///   `ConicGradientPosition.center`).
  /// - [stops]: Optional stops corresponding to [colors].
  ///   Accepts angle or percentage units (e.g., `Dim.deg(0)`,
  ///   `Dim.percent(50)`). Length units (`px`, `rem`) are not
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
  }) => _append(
    ConicGradient(
      colors: colors,
      angle: angle,
      position: position,
      stops: stops,
    ),
  );

  /// Adds a repeating linear gradient.
  ///
  /// ### Properties:
  /// - [colors]: List of stop colors.
  /// - [angle]: Angle of the gradient. It will be normalized
  ///   to be within the 0-360 range.
  /// - [direction]: Linear gradient direction (e.g.,
  ///   `LinearGradientDirection.toRight`).
  /// - [stops]: Optional stops corresponding to [colors].
  ///   Accepts length or percentage units (e.g., `Dim.percent(50)`,
  ///   `Dim.px(20)`, `Dim.rem(1.5)`). Unitless numbers are not
  ///   valid CSS.
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
  }) => _append(
    RepeatingLinearGradient(
      colors: colors,
      angle: angle,
      direction: direction,
      stops: stops,
    ),
  );

  /// Adds a repeating radial gradient.
  ///
  /// ### Properties:
  /// - [colors]: List of stop colors.
  /// - [shape]: Shape of the gradient (e.g., `Shape.circle`,
  ///   `Shape.ellipse`).
  /// - [position]: Position of the gradient center (e.g.,
  ///   `RadialGradientPosition.center`).
  /// - [stops]: Optional stops corresponding to [colors].
  ///   Accepts length or percentage units (e.g., `Dim.percent(50)`,
  ///   `Dim.px(20)`, `Dim.rem(1.5)`). Unitless numbers are not
  ///   valid CSS.
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
  }) => _append(
    RepeatingRadialGradient(
      colors: colors,
      shape: shape,
      position: position,
      stops: stops,
    ),
  );

  /// Adds a repeating conic gradient.
  ///
  /// ### Properties:
  /// - [colors]: List of stop colors.
  /// - [angle]: Starting angle of rotation between 0 and 360.
  /// - [position]: Position of the gradient center (e.g.,
  ///   `ConicGradientPosition.center`).
  /// - [stops]: Optional stops corresponding to [colors].
  ///   Accepts angle or percentage units (e.g., `Dim.deg(0)`,
  ///   `Dim.percent(50)`). Length units (`px`, `rem`) are not
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
  }) => _append(
    RepeatingConicGradient(
      colors: colors,
      angle: angle,
      position: position,
      stops: stops,
    ),
  );

  /// Adds a raw CSS gradient string.
  Gradient applyRaw(String gradient) => _append(RawGradient(gradient));

  /// Removes all gradients.
  Gradient clear() {
    if (_isStandalone) {
      throw UnsupportedError('Cannot clear a standalone $runtimeType.');
    }
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

abstract class _SingleGradient extends Gradient {
  const _SingleGradient() : super._();

  @override
  bool get _isStandalone => true;

  @override
  List<String> get _entries => [cssText];
}

abstract class _LinearGradientBase extends _SingleGradient {
  /// Stop colors of the gradient.
  final List<Color> colors;

  /// Angle of the gradient in degrees (normalized to 0-360).
  final double? angle;

  /// Linear direction of the gradient.
  final LinearGradientDirection? direction;

  /// Optional stop offsets corresponding to [colors].
  ///
  /// **Supported [Dim] values**: only length and percentage units
  /// (e.g., `Dim.percent(50)`, `Dim.px(20)`, `Dim.rem(1.5)`).
  /// Unitless numbers and angle units are not valid CSS.
  final List<Dim>? stops;

  const _LinearGradientBase({
    required this.colors,
    this.angle,
    this.direction,
    this.stops,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _LinearGradientBase &&
          runtimeType == other.runtimeType &&
          listEquals(colors, other.colors) &&
          angle == other.angle &&
          direction == other.direction &&
          listEquals(stops, other.stops);

  @override
  int get hashCode => Object.hash(
    runtimeType,
    Object.hashAll(colors),
    angle,
    direction,
    stops == null ? null : Object.hashAll(stops!),
  );
}

/// Standalone linear gradient fill.
class LinearGradient extends _LinearGradientBase {
  /// Creates a linear gradient.
  ///
  /// If both [angle] and [direction] are provided,
  /// [angle] takes precedence.
  const LinearGradient({
    required super.colors,
    super.angle,
    super.direction,
    super.stops,
  });

  @override
  String get cssText => _linearCssText(
    GradientType.linear,
    colors: colors,
    angle: angle,
    direction: direction,
    stops: stops,
  );
}

/// Standalone repeating linear gradient fill.
class RepeatingLinearGradient extends _LinearGradientBase {
  /// Creates a repeating linear gradient.
  ///
  /// If both [angle] and [direction] are provided,
  /// [angle] takes precedence.
  const RepeatingLinearGradient({
    required super.colors,
    super.angle,
    super.direction,
    super.stops,
  });

  @override
  String get cssText => _linearCssText(
    GradientType.repeatingLinear,
    colors: colors,
    angle: angle,
    direction: direction,
    stops: stops,
  );
}

abstract class _RadialGradientBase extends _SingleGradient {
  /// Stop colors of the gradient.
  final List<Color> colors;

  /// Shape of the gradient.
  final Shape? shape;

  /// Center position of the gradient.
  final RadialGradientPosition? position;

  /// Optional stop offsets corresponding to [colors].
  ///
  /// {@template _radialGradStops}
  /// **Supported [Dim] values**: only length and percentage units
  /// (e.g., `Dim.percent(50)`, `Dim.px(20)`, `Dim.rem(1.5)`).
  /// Unitless numbers and angle units are not valid CSS.
  /// {@endtemplate}
  final List<Dim>? stops;

  const _RadialGradientBase({
    required this.colors,
    this.shape,
    this.position,
    this.stops,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _RadialGradientBase &&
          runtimeType == other.runtimeType &&
          listEquals(colors, other.colors) &&
          shape == other.shape &&
          position == other.position &&
          listEquals(stops, other.stops);

  @override
  int get hashCode => Object.hash(
    runtimeType,
    Object.hashAll(colors),
    shape,
    position,
    stops == null ? null : Object.hashAll(stops!),
  );
}

/// Standalone radial gradient fill.
class RadialGradient extends _RadialGradientBase {
  /// Creates a radial gradient.
  ///
  /// {@macro _radialGradStops}
  const RadialGradient({
    required super.colors,
    super.shape,
    super.position,
    super.stops,
  });

  @override
  String get cssText => _radialCssText(
    GradientType.radial,
    colors: colors,
    shape: shape,
    position: position,
    stops: stops,
  );
}

/// Standalone repeating radial gradient fill.
class RepeatingRadialGradient extends _RadialGradientBase {
  /// Creates a repeating radial gradient.
  ///
  /// {@macro _radialGradStops}
  const RepeatingRadialGradient({
    required super.colors,
    super.shape,
    super.position,
    super.stops,
  });

  @override
  String get cssText => _radialCssText(
    GradientType.repeatingRadial,
    colors: colors,
    shape: shape,
    position: position,
    stops: stops,
  );
}

abstract class _ConicGradientBase extends _SingleGradient {
  /// Stop colors of the gradient.
  final List<Color> colors;

  /// Starting angle of rotation in degrees.
  final double? angle;

  /// Center position of the gradient.
  final ConicGradientPosition? position;

  /// Optional stop offsets corresponding to [colors].
  ///
  /// {@template _conicGradStops}
  /// **Supported [Dim] values**: only angle and percentage units
  /// (e.g., `Dim.deg(0)`, `Dim.rad(1.5)`, `Dim.grad(100)`,
  /// `Dim.percent(50)`). Length units (`Dim.px`, `Dim.rem`, etc.)
  /// and unitless numbers are not valid CSS for conic gradients.
  /// {@endtemplate}
  final List<Dim>? stops;

  const _ConicGradientBase({
    required this.colors,
    this.angle,
    this.position,
    this.stops,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ConicGradientBase &&
          runtimeType == other.runtimeType &&
          listEquals(colors, other.colors) &&
          angle == other.angle &&
          position == other.position &&
          listEquals(stops, other.stops);

  @override
  int get hashCode => Object.hash(
    runtimeType,
    Object.hashAll(colors),
    angle,
    position,
    stops == null ? null : Object.hashAll(stops!),
  );
}

/// Standalone conic gradient fill.
class ConicGradient extends _ConicGradientBase {
  /// Creates a conic gradient.
  ///
  /// {@macro _conicGradStops}
  const ConicGradient({
    required super.colors,
    super.angle,
    super.position,
    super.stops,
  });

  @override
  String get cssText => _conicCssText(
    GradientType.conic,
    colors: colors,
    angle: angle,
    position: position,
    stops: stops,
  );
}

/// Standalone repeating conic gradient fill.
class RepeatingConicGradient extends _ConicGradientBase {
  /// Creates a repeating conic gradient.
  ///
  /// {@macro _conicGradStops}
  const RepeatingConicGradient({
    required super.colors,
    super.angle,
    super.position,
    super.stops,
  });

  @override
  String get cssText => _conicCssText(
    GradientType.repeatingConic,
    colors: colors,
    angle: angle,
    position: position,
    stops: stops,
  );
}

/// Standalone raw CSS gradient fill.
class RawGradient extends _SingleGradient {
  /// The raw CSS gradient expression.
  final String value;

  /// Creates a raw CSS gradient
  /// (e.g., 'linear-gradient(to right, red, blue)').
  const RawGradient(this.value);

  @override
  String get cssText => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RawGradient &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => Object.hash(runtimeType, value);
}
