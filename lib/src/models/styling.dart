import 'package:jaspr/dom.dart';

import '../styles/text_style.dart';
import '../theme/tokens.dart';
import '../utilities/enums.dart';
import '../utilities/extensions.dart';

import '../utilities/helpers.dart';
import 'naki.dart';

bool _listEquals<T>(List<T>? a, List<T>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null || a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

bool _mapEquals<K, V>(Map<K, V>? a, Map<K, V>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null || a.length != b.length) return false;
  for (final key in a.keys) {
    if (!b.containsKey(key) || b[key] != a[key]) return false;
  }
  return true;
}

/// Represents CSS dimensions with optional `!important` suffix.
class Dim {
  /// The numeric value of the unit.
  final double? value;

  /// The unit type.
  final String unit;

  /// Whether the unit has the `!important` declaration.
  final bool important;

  /// Creates a new dimension with optional [unit] and [important] flag.
  const Dim(this.value, {this.unit = '', this.important = false});

  /// Default font size (14px).
  static const Dim defaultFontSize = Dim(14, unit: 'px');

  /// Max content.
  const Dim.maxContent([this.important = false]) : value = null, unit = 'max-content';

  /// Min content.
  const Dim.minContent([this.important = false]) : value = null, unit = 'min-content';

  /// Fit content.
  const Dim.fitContent([this.important = false]) : value = null, unit = 'fit-content';

  /// Zero.
  const Dim.zero([this.important = false]) : value = 0, unit = '';

  /// Inherit.
  const Dim.inherit([this.important = false]) : value = null, unit = 'inherit';

  /// Auto.
  const Dim.auto([this.important = false]) : value = null, unit = 'auto';

  /// Normal size.
  const Dim.normal([this.important = false]) : value = null, unit = 'normal';

  /// Variable (e.g. variable name: `--naki-primary-color`).
  const Dim.variable(String variableName, {this.important = false, String? defaultValue})
    : value = null,
      unit = defaultValue != null && defaultValue != ''
          ? 'var($variableName, $defaultValue)'
          : 'var($variableName)';

  /// Raw expression (e.g. `calc(100% - 48px)`).
  const Dim.raw(String expression, [this.important = false]) : value = null, unit = expression;

  /// Pixels unit.
  const Dim.px(this.value, [this.important = false]) : unit = 'px';

  /// Percentage unit.
  const Dim.percent(this.value, [this.important = false]) : unit = '%';

  /// Element-relative size unit.
  const Dim.em(this.value, [this.important = false]) : unit = 'em';

  /// Root element-relative size unit.
  const Dim.rem(this.value, [this.important = false]) : unit = 'rem';

  /// Viewport width unit.
  const Dim.vw(this.value, [this.important = false]) : unit = 'vw';

  /// Viewport height unit.
  const Dim.vh(this.value, [this.important = false]) : unit = 'vh';

  /// Smallest viewport unit.
  const Dim.vmin(this.value, [this.important = false]) : unit = 'vmin';

  /// Dynamic viewport height unit.
  const Dim.dvh(this.value, [this.important = false]) : unit = 'dvh';

  /// Dynamic viewport width unit.
  const Dim.dvw(this.value, [this.important = false]) : unit = 'dvw';

  /// Small viewport height unit.
  const Dim.svh(this.value, [this.important = false]) : unit = 'svh';

  /// Small viewport width unit.
  const Dim.svw(this.value, [this.important = false]) : unit = 'svw';

  /// Large viewport height unit.
  const Dim.lvh(this.value, [this.important = false]) : unit = 'lvh';

  /// Large viewport width unit.
  const Dim.lvw(this.value, [this.important = false]) : unit = 'lvw';

  /// Maximum viewport unit.
  const Dim.vmax(this.value, [this.important = false]) : unit = 'vmax';

  /// Degree unit
  const Dim.deg(this.value, [this.important = false]) : unit = 'deg';

  /// Radian unit
  const Dim.rad(this.value, [this.important = false]) : unit = 'rad';

  /// Gradian unit
  const Dim.grad(this.value, [this.important = false]) : unit = 'grad';

  /// Creates a copy of this dimension with optional changes.
  Dim copyWith({double? value, String? unit, bool? important}) {
    return Dim(
      value ?? this.value,
      unit: unit ?? this.unit,
      important: important ?? this.important,
    );
  }

  /// Adds another dimension with same unit to this dimension.
  Dim operator +(Dim other) {
    if (value == null || other.value == null || other.unit != unit) return this;
    return Dim(value! + other.value!, unit: unit, important: important);
  }

  /// Subtracts another dimension with same unit from this dimension.
  Dim operator -(Dim other) {
    if (value == null || other.value == null || other.unit != unit) return this;
    return Dim(value! - other.value!, unit: unit, important: important);
  }

  /// Multiplies this dimension by a factor.
  Dim operator *(num factor) {
    if (value == null) return this;
    return Dim(value! * factor, unit: unit, important: important);
  }

  /// Divides this dimension by a factor.
  Dim operator /(num factor) {
    if (value == null) return this;
    return Dim(value! / factor, unit: unit, important: important);
  }

  /// Returns a CSS-formatted dimension string.
  ///
  /// The returned string includes the unit and an optional `!important`
  /// suffix. Values are formatted without unnecessary decimal places
  /// (e.g., `12px` instead of `12.0px`).
  ///
  /// Example usage:
  /// ```
  /// final dim = Dim.px(12.0, true);
  /// print(dim.cssText); // Output: '12px !important'
  /// ```
  String get cssText {
    final formattedValue = value == null ? '' : value!.toCleanString;
    final suffix = important ? ' !important' : '';
    return '$formattedValue${unit.trim()}$suffix';
  }

  /// String representation of this dimension.
  ///
  /// Example usage:
  /// ```
  /// final dim = Dim.px(12.0, true);
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
          important == other.important;

  @override
  int get hashCode => Object.hashAll([value, unit, important]);
}

/// Border radius attributes of a component.
class BorderRadiusData implements NakiStylable {
  /// Top-left radius.
  final Dim? topLeft;

  /// Top-right radius.
  final Dim? topRight;

  /// Bottom-left radius.
  final Dim? bottomLeft;

  /// Bottom-right radius.
  final Dim? bottomRight;

  /// Create a new radius.
  const BorderRadiusData({this.topLeft, this.topRight, this.bottomLeft, this.bottomRight});

  /// Create a symmetric border radius.
  factory BorderRadiusData.all(Dim value) =>
      BorderRadiusData(topLeft: value, topRight: value, bottomLeft: value, bottomRight: value);

  /// Circular border radius.
  static const circular = BorderRadiusData(
    topLeft: Dim.percent(50),
    topRight: Dim.percent(50),
    bottomLeft: Dim.percent(50),
    bottomRight: Dim.percent(50),
  );

  /// iOS-style squircle border radius.
  static BorderRadiusData get squircle => BorderRadiusData.all(const Dim.percent(22.5));

  /// A radius with all corners set to zero.
  static const zero = BorderRadiusData(
    topLeft: Dim.zero(),
    topRight: Dim.zero(),
    bottomLeft: Dim.zero(),
    bottomRight: Dim.zero(),
  );

  /// Alias for [zero].
  static const none = zero;

  /// Create a new radius with optional changes to corner values.
  BorderRadiusData copyWith({Dim? topLeft, Dim? topRight, Dim? bottomLeft, Dim? bottomRight}) {
    return BorderRadiusData(
      topLeft: topLeft ?? this.topLeft,
      topRight: topRight ?? this.topRight,
      bottomLeft: bottomLeft ?? this.bottomLeft,
      bottomRight: bottomRight ?? this.bottomRight,
    );
  }

  /// Returns the CSS value of the border radius.
  ///
  /// If no corner is set, it returns null. Otherwise, it returns
  /// a space-separated string of the corner values in the order:
  /// top-left, top-right, bottom-right, bottom-left.
  ///
  /// Example:
  /// ```dart
  /// final borderRadius = BorderRadiusData(
  ///   topLeft: Dim.px(10),
  ///   topRight: Dim.px(20),
  ///   bottomLeft: Dim.px(30),
  ///   bottomRight: Dim.px(40),
  /// );
  /// print(borderRadius.value);
  /// // Output: '10px 20px 40px 30px'
  /// ```
  String? get value {
    if (props.isEmpty) return null;
    if (props['border-radius'] != null) return props['border-radius'];

    String value = '';
    final topLeft = props['border-top-left-radius'];
    final topRight = props['border-top-right-radius'];
    final bottomRight = props['border-bottom-right-radius'];
    final bottomLeft = props['border-bottom-left-radius'];

    if (topLeft != null) value += '$topLeft ';
    if (topRight != null) value += '$topRight ';
    if (bottomRight != null) value += '$bottomRight ';
    if (bottomLeft != null) value += '$bottomLeft ';

    return value.trim();
  }

  /// Convert radius attributes to CSS styles.
  @override
  Map<String, String> get props => {
    if (topLeft == topRight &&
        bottomLeft == bottomRight &&
        topLeft == bottomLeft &&
        topRight == bottomRight) ...{
      'border-radius': ?topLeft?.cssText,
    } else if (topLeft != null &&
        topRight != null &&
        bottomLeft != null &&
        bottomRight != null) ...{
      'border-radius':
          '${topLeft!.cssText} ${topRight!.cssText} ${bottomRight!.cssText} ${bottomLeft!.cssText}',
    } else ...{
      'border-top-left-radius': ?topLeft?.cssText,
      'border-top-right-radius': ?topRight?.cssText,
      'border-bottom-right-radius': ?bottomRight?.cssText,
      'border-bottom-left-radius': ?bottomLeft?.cssText,
    },
  };

  @override
  String get cssText => props.cssText;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BorderRadiusData &&
          runtimeType == other.runtimeType &&
          topLeft == other.topLeft &&
          topRight == other.topRight &&
          bottomLeft == other.bottomLeft &&
          bottomRight == other.bottomRight;

  @override
  int get hashCode => Object.hash(topLeft, topRight, bottomLeft, bottomRight);
}

/// Border attributes of a component.
class BorderData implements NakiStylable {
  /// Border color.
  final Color color;

  /// Border radius.
  final BorderRadiusData? radius;

  /// Border style (e.g. solid, dashed, dotted, double, groove, ridge).
  final BorderStyle style;

  /// Border width.
  final Dim width;

  /// Top Border.
  final BorderSideData? top;

  /// Right Border.
  final BorderSideData? right;

  /// Bottom Border.
  final BorderSideData? bottom;

  /// Left Border.
  final BorderSideData? left;

  final bool _isNone, _isOnly;

  const BorderData._({
    this.color = Colors.transparent,
    this.style = BorderStyle.solid,
    this.width = const Dim.px(1),
    this.radius,
    this.top,
    this.right,
    this.bottom,
    this.left,
    bool isNone = false,
    bool isOnly = false,
  }) : _isNone = isNone,
       _isOnly = isOnly;

  /// Create a new uniform or directional border.
  const BorderData({
    Color color = Colors.transparent,
    BorderStyle style = BorderStyle.solid,
    Dim width = const Dim.px(1),
    BorderRadiusData? radius,
    BorderSideData? top,
    BorderSideData? right,
    BorderSideData? bottom,
    BorderSideData? left,
  }) : this._(
         color: color,
         style: style,
         width: width,
         radius: radius,
         top: top,
         right: right,
         bottom: bottom,
         left: left,
       );

  /// Creates a border with only the specified borders and radius.
  const BorderData.only({
    BorderSideData? top,
    BorderSideData? right,
    BorderSideData? bottom,
    BorderSideData? left,
    BorderRadiusData? radius,
  }) : this._(
         top: top,
         right: right,
         bottom: bottom,
         left: left,
         radius: radius,
         color: Color.unset,
         style: BorderStyle.none,
         width: const Dim.zero(),
         isOnly: true,
       );

  /// A border with all properties set to zero/none.
  static BorderData get none => const BorderData._(
    color: Color.unset,
    style: BorderStyle.none,
    width: Dim.zero(),
    radius: BorderRadiusData.none,
    isNone: true,
  );

  /// Convert border attributes to CSS styles.
  @override
  Map<String, String> get props => {
    if (_isNone) ...{
      'border': 'none',
    } else if (top != null || right != null || bottom != null || left != null) ...{
      'border-top': ?top?.value,
      'border-right': ?right?.value,
      'border-bottom': ?bottom?.value,
      'border-left': ?left?.value,
    } else if (!_isOnly) ...{
      'border': '${width.cssText} ${style.value} ${color.value}',
    },
    ...?radius?.props,
  };

  @override
  String get cssText => props.cssText;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BorderData &&
          runtimeType == other.runtimeType &&
          color == other.color &&
          top == other.top &&
          right == other.right &&
          bottom == other.bottom &&
          left == other.left &&
          radius == other.radius &&
          style == other.style &&
          width == other.width;

  @override
  int get hashCode => Object.hash(color, radius, style, width, top, right, bottom, left);
}

/// Size attributes of a component.
class SizeConstraints implements NakiStylable {
  /// Width.
  final Dim? width;

  /// Height.
  final Dim? height;

  /// Minimum width.
  final Dim? minWidth;

  /// Minimum height.
  final Dim? minHeight;

  /// Maximum width.
  final Dim? maxWidth;

  /// Maximum height.
  final Dim? maxHeight;

  /// Create a new size.
  const SizeConstraints({
    this.width,
    this.height,
    this.minWidth,
    this.minHeight,
    this.maxWidth,
    this.maxHeight,
  });

  /// Copy size constrains.
  SizeConstraints copyWith({
    Dim? width,
    Dim? height,
    Dim? minWidth,
    Dim? minHeight,
    Dim? maxWidth,
    Dim? maxHeight,
  }) => SizeConstraints(
    width: width ?? this.width,
    height: height ?? this.height,
    minWidth: minWidth ?? this.minWidth,
    minHeight: minHeight ?? this.minHeight,
    maxWidth: maxWidth ?? this.maxWidth,
    maxHeight: maxHeight ?? this.maxHeight,
  );

  /// Combines this size constraint with another size constraint.
  /// [other] is the constraint that takes precedence.
  SizeConstraints combineWith(SizeConstraints? other) {
    other ??= this;
    return SizeConstraints(
      width: other.width ?? width,
      height: other.height ?? height,
      minWidth: other.minWidth ?? minWidth,
      minHeight: other.minHeight ?? minHeight,
      maxWidth: other.maxWidth ?? maxWidth,
      maxHeight: other.maxHeight ?? maxHeight,
    );
  }

  /// Convert size attributes to CSS styles.
  @override
  Map<String, String> get props => {
    'width': ?width?.cssText,
    'height': ?height?.cssText,
    'min-width': ?minWidth?.cssText,
    'min-height': ?minHeight?.cssText,
    'max-width': ?maxWidth?.cssText,
    'max-height': ?maxHeight?.cssText,
  };

  @override
  String get cssText => props.cssText;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SizeConstraints &&
          runtimeType == other.runtimeType &&
          width == other.width &&
          height == other.height &&
          minWidth == other.minWidth &&
          minHeight == other.minHeight &&
          maxWidth == other.maxWidth &&
          maxHeight == other.maxHeight;

  @override
  int get hashCode => Object.hash(width, height, minWidth, minHeight, maxWidth, maxHeight);
}

/// The border, label, hint, and helper text styles used to
/// decorate a Naki input component.
class InputDecoration {
  /// Style of the input value.
  final TextStyle? inputStyle;

  /// Label text displayed above the component.
  final String? labelText;

  /// The typography style to use for [labelText].
  final TextStyle? labelStyle;

  /// Hint text displayed below the component.
  final String? helperText;

  /// Typography style to use for [helperText].
  final TextStyle? helperStyle;

  /// The placeholder text displayed in the component,
  /// when input value is empty.
  final String? placeholderText;

  /// Color of the placeholder text.
  final Color? placeholderColor;

  /// Border decoration of the component.
  final BorderData? border;

  /// Color of the border when hovered.
  final Color? hoverBorderColor;

  /// Color of the border when focused.
  final Color? focusBorderColor;

  /// Style of the error message
  /// (only font size and color applicable).
  final TextStyle? errorStyle;

  /// Padding of the input component.
  final EdgeInsets? padding;

  /// Margin of the input component.
  final EdgeInsets? margin;

  /// Creates an [InputDecoration] instance.
  const InputDecoration({
    this.labelText,
    this.labelStyle,
    this.helperText,
    this.helperStyle,
    this.placeholderText,
    this.placeholderColor,
    this.border,
    this.hoverBorderColor,
    this.focusBorderColor,
    this.errorStyle,
    this.inputStyle,
    this.padding,
    this.margin,
  });

  InputDecoration copyWith({
    String? labelText,
    TextStyle? labelStyle,
    String? helperText,
    TextStyle? helperStyle,
    String? placeholderText,
    Color? placeholderColor,
    BorderData? border,
    Color? hoverBorderColor,
    Color? focusBorderColor,
    TextStyle? errorStyle,
    TextStyle? inputStyle,
    EdgeInsets? padding,
    EdgeInsets? margin,
  }) {
    return InputDecoration(
      labelText: labelText ?? this.labelText,
      labelStyle: labelStyle ?? this.labelStyle,
      helperText: helperText ?? this.helperText,
      helperStyle: helperStyle ?? this.helperStyle,
      placeholderText: placeholderText ?? this.placeholderText,
      placeholderColor: placeholderColor ?? this.placeholderColor,
      border: border ?? this.border,
      hoverBorderColor: hoverBorderColor ?? this.hoverBorderColor,
      focusBorderColor: focusBorderColor ?? this.focusBorderColor,
      errorStyle: errorStyle ?? this.errorStyle,
      inputStyle: inputStyle ?? this.inputStyle,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InputDecoration &&
          runtimeType == other.runtimeType &&
          inputStyle == other.inputStyle &&
          labelText == other.labelText &&
          labelStyle == other.labelStyle &&
          helperText == other.helperText &&
          helperStyle == other.helperStyle &&
          placeholderText == other.placeholderText &&
          placeholderColor == other.placeholderColor &&
          border == other.border &&
          hoverBorderColor == other.hoverBorderColor &&
          focusBorderColor == other.focusBorderColor &&
          errorStyle == other.errorStyle &&
          padding == other.padding &&
          margin == other.margin;

  @override
  int get hashCode => Object.hashAll([
    inputStyle,
    labelText,
    labelStyle,
    helperText,
    helperStyle,
    placeholderText,
    placeholderColor,
    border,
    hoverBorderColor,
    focusBorderColor,
    errorStyle,
    padding,
    margin,
  ]);
}

/// Represents spacing attributes (margins or paddings) around a component.
class EdgeInsets {
  /// Spacing on the top side.
  final Dim? top;

  /// Spacing on the right side.
  final Dim? right;

  /// Spacing on the bottom side.
  final Dim? bottom;

  /// Spacing on the left side.
  final Dim? left;

  /// Creates spacing where all four sides have the same `value`.
  const EdgeInsets.all(Dim value) : top = value, right = value, bottom = value, left = value;

  /// Creates spacing with symmetrical vertical and horizontal offsets.
  const EdgeInsets.symmetric({Dim? vertical, Dim? horizontal})
    : top = vertical,
      bottom = vertical,
      left = horizontal,
      right = horizontal;

  /// Creates spacing with only the specified sides set.
  const EdgeInsets.only({this.top, this.right, this.bottom, this.left});

  /// The default zero spacing.
  static const zero = EdgeInsets.all(Dim.zero());

  /// Converts padding attributes to a CSS style map.
  Map<String, String> get pProps => {
    if (top != null && top == right && bottom == left && top == bottom && right == left) ...{
      'padding': top!.cssText,
    } else if (top != null && right != null && top == bottom && right == left) ...{
      'padding': '${top!.cssText} ${right!.cssText}',
    } else ...{
      'padding-top': ?top?.cssText,
      'padding-right': ?right?.cssText,
      'padding-bottom': ?bottom?.cssText,
      'padding-left': ?left?.cssText,
    },
  };

  /// Converts margin attributes to a CSS style map.
  Map<String, String> get mProps => {
    if (top != null && top == right && bottom == left && top == bottom && right == left) ...{
      'margin': top!.cssText,
    } else if (top != null && right != null && top == bottom && right == left) ...{
      'margin': '${top!.cssText} ${right!.cssText}',
    } else ...{
      'margin-top': ?top?.cssText,
      'margin-right': ?right?.cssText,
      'margin-bottom': ?bottom?.cssText,
      'margin-left': ?left?.cssText,
    },
  };

  /// Gets the CSS value of the EdgeInsets.
  ///
  /// If padding properties are set, it returns the padding value.
  /// Otherwise, it returns the margin value.
  ///
  /// Returns `null` if both padding and margin properties are not set.
  ///
  /// Example:
  /// ```dart
  /// const EdgeInsets.only(top: 10, right: 20, bottom: 30, left: 40).value;
  /// // Returns '10px 20px 30px 40px'
  /// ```
  String? get value {
    final map = pProps.isEmpty ? mProps : pProps;
    if (map.isEmpty) return null;

    if (map['padding'] != null) return map['padding'];
    if (map['margin'] != null) return map['margin'];

    String value = '';

    final pTop = map['padding-top'];
    final pRight = map['padding-right'];
    final pBottom = map['padding-bottom'];
    final pLeft = map['padding-left'];

    final mTop = map['margin-top'];
    final mRight = map['margin-right'];
    final mBottom = map['margin-bottom'];
    final mLeft = map['margin-left'];

    if (pTop != null) value += '$pTop ';
    if (pRight != null) value += '$pRight ';
    if (pBottom != null) value += '$pBottom ';
    if (pLeft != null) value += '$pLeft ';

    if (mTop != null) value += '$mTop ';
    if (mRight != null) value += '$mRight ';
    if (mBottom != null) value += '$mBottom ';
    if (mLeft != null) value += '$mLeft ';

    return value.trim();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EdgeInsets &&
          runtimeType == other.runtimeType &&
          top == other.top &&
          right == other.right &&
          bottom == other.bottom &&
          left == other.left;

  @override
  int get hashCode => Object.hash(top, right, bottom, left);
}

/// Box decoration attributes of a component.
class BoxDecoration implements NakiStylable {
  /// The background color of the box.
  final Color? backgroundColor;

  /// The background image of the box.
  final String? backgroundImage;

  /// How the background image should be sized to fit the box.
  final ObjectFit? imageFit;

  /// How the background image should be positioned within the box.
  final ObjectPosition? imagePosition;

  /// The background gradient of the box.
  final Gradient? gradient;

  /// The color of the box content.
  final Color? color;

  /// The display mode of the box.
  final Display? display;

  /// The border of the box.
  final BorderData? border;

  /// The border radius of the box.
  final BorderRadiusData? borderRadius;

  /// The padding of the box child.
  final EdgeInsets? padding;

  /// The margin of the box exterior.
  final EdgeInsets? margin;

  /// The alignment of the box child.
  final Alignment? alignment;

  /// The position of the box.
  final PositionData? position;

  /// The shadow of the box.
  final Shadow? shadow;

  /// The opacity of the box.
  final double? opacity;

  /// Create a new box decoration.
  const BoxDecoration({
    this.backgroundColor,
    this.backgroundImage,
    this.imageFit,
    this.imagePosition,
    this.gradient,
    this.display,
    this.color,
    this.border,
    this.borderRadius,
    this.padding,
    this.margin,
    this.alignment,
    this.position,
    this.shadow,
    this.opacity,
  });

  /// Converts the ObjectFit enum to a CSS background-size value.
  String? get _backgroundImageSize => switch (imageFit) {
    ObjectFit.cover => 'cover',
    ObjectFit.contain => 'contain',
    ObjectFit.fill => '100% 100%',
    ObjectFit.none => 'auto',
    ObjectFit.scaleDown => 'auto',
    _ => null,
  };

  /// Normalizes the background image to a CSS-valid format.
  String? get _normalizedBackgroundImage => switch (backgroundImage) {
    final bg? when bg.contains('gradient') => null,
    final bg? when bg.startsWith('url(') => bg,
    final bg? => 'url("${normaliseLink(bg)}")',
    null => null,
  };

  /// Converts box decoration attributes to a CSS style map.
  @override
  Map<String, String> get props => {
    'display': ?display?.value,
    'background-color': ?backgroundColor?.value,
    'background-image': ?_normalizedBackgroundImage,
    'background-size': ?_backgroundImageSize,
    'background-position': ?imagePosition?.css,
    'color': ?color?.value,
    'opacity': ?opacity?.toCleanString,
    ...?borderRadius?.props,
    ...?border?.props,
    ...?padding?.pProps,
    ...?margin?.mProps,
    ...?position?.props,
    ...?shadow?.props,
    ...?gradient?.props,
    if (alignment != null) ...{
      ...NakiAlignProps.mapAlignment(alignment!),
      'display': 'inline-flex',
    },
  };

  @override
  String get cssText => props.cssText;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoxDecoration &&
          runtimeType == other.runtimeType &&
          backgroundColor == other.backgroundColor &&
          backgroundImage == other.backgroundImage &&
          imageFit == other.imageFit &&
          imagePosition == other.imagePosition &&
          gradient == other.gradient &&
          color == other.color &&
          display == other.display &&
          border == other.border &&
          borderRadius == other.borderRadius &&
          padding == other.padding &&
          margin == other.margin &&
          alignment == other.alignment &&
          position == other.position &&
          shadow == other.shadow &&
          opacity == other.opacity;

  @override
  int get hashCode => Object.hashAll([
    backgroundColor,
    backgroundImage,
    imageFit,
    imagePosition,
    gradient,
    color,
    display,
    border,
    borderRadius,
    padding,
    margin,
    alignment,
    position,
    shadow,
    opacity,
  ]);
}

/// Shadow attributes of a component.
class Shadow implements NakiStylable {
  /// The x-offset of the shadow (in pixels).
  final double? offsetX;

  /// The y-offset of the shadow (in pixels).
  final double? offsetY;

  /// The blur radius of the shadow (in pixels).
  final double? blurRadius;

  /// The spread radius of the shadow (in pixels).
  final double? spreadRadius;

  /// The color of the shadow.
  final Color? color;

  /// Create a new shadow.
  const Shadow({this.offsetX, this.offsetY, this.blurRadius, this.spreadRadius, this.color});

  /// Small shadow
  static const small = Shadow(offsetX: 0, offsetY: 2, blurRadius: 8.0, color: Colors.black);

  /// Medium shadow
  static const medium = Shadow(offsetX: 0, offsetY: 4, blurRadius: 16.0, color: Colors.black);

  /// Large shadow
  static const large = Shadow(
    offsetX: 0,
    offsetY: 8,
    blurRadius: 32.0,
    spreadRadius: 2.0,
    color: Colors.black,
  );

  /// Extra large shadow
  static const extraLarge = Shadow(
    offsetX: 0,
    offsetY: 16,
    blurRadius: 64.0,
    spreadRadius: 4.0,
    color: Colors.black,
  );

  /// Creates a copy of the current shadow with optional new values.
  Shadow copyWith({
    double? offsetX,
    double? offsetY,
    double? blurRadius,
    double? spreadRadius,
    Color? color,
  }) {
    return Shadow(
      offsetX: offsetX ?? this.offsetX,
      offsetY: offsetY ?? this.offsetY,
      blurRadius: blurRadius ?? this.blurRadius,
      spreadRadius: spreadRadius ?? this.spreadRadius,
      color: color ?? this.color,
    );
  }

  /// Converts shadow attributes to a CSS style map.
  @override
  Map<String, String> get props {
    final x = (offsetX ?? 0).toPx;
    final y = (offsetY ?? 0).toPx;
    final blur = blurRadius?.toPx ?? (spreadRadius != null ? '0px' : null);
    final spread = spreadRadius?.toPx;
    final c = color?.value;

    return {
      'box-shadow': [x, y, ?blur, ?spread, ?c].join(' '),
    };
  }

  @override
  String get cssText => props.cssText;

  /// Gets the CSS value of the `box-shadow` property.
  ///
  /// Returns `null` if the properties are not set.
  ///
  /// Example:
  /// ```dart
  /// const Shadow(
  ///   offsetX: 2,
  ///   offsetY: 4,
  ///   blurRadius: 8,
  ///   color: Colors.black,
  /// ).value;
  /// // Returns '2px 4px 8px 0px #000000'
  /// ```
  String get value => props['box-shadow']!;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Shadow &&
          runtimeType == other.runtimeType &&
          offsetX == other.offsetX &&
          offsetY == other.offsetY &&
          blurRadius == other.blurRadius &&
          spreadRadius == other.spreadRadius &&
          color == other.color;

  @override
  int get hashCode => Object.hash(offsetX, offsetY, blurRadius, spreadRadius, color);
}

/// Position properties of a component.
class PositionData implements NakiStylable {
  /// The top position of the component.
  final Dim? top;

  /// The right position of the component.
  final Dim? right;

  /// The bottom position of the component.
  final Dim? bottom;

  /// The left position of the component.
  final Dim? left;

  /// The z-index of the component.
  final int? zIndex;

  /// The visibility of the component.
  final Visibility? visibility;

  /// The overflow of the component.
  final Overflow? overflow;

  /// Additional CSS properties (e.g. transform, scale).
  final Map<String, String>? extra;

  /// Create a new position.
  const PositionData({
    this.top,
    this.right,
    this.bottom,
    this.left,
    this.zIndex,
    this.visibility,
    this.overflow,
    this.extra,
  });

  /// Center position.
  static const center = PositionData(
    top: Dim.percent(50),
    left: Dim.percent(50),
    extra: {'transform': 'translate(-50%, -50%)'},
  );

  /// Top center position.
  static const topCenter = PositionData(
    top: Dim.zero(),
    left: Dim.percent(50),
    extra: {'transform': 'translate(-50%, 0%)'},
  );

  /// Top left position.
  static const topLeft = PositionData(top: Dim.zero(), left: Dim.zero());

  /// Top right position.
  static const topRight = PositionData(
    top: Dim.zero(),
    right: Dim.zero(),
    extra: {'transform': 'translate(0%, 0%)'},
  );

  /// Bottom center position.
  static const bottomCenter = PositionData(
    bottom: Dim.zero(),
    left: Dim.percent(50),
    extra: {'transform': 'translate(-50%, 0%)'},
  );

  /// Bottom left position.
  static const bottomLeft = PositionData(bottom: Dim.zero(), left: Dim.zero());

  /// Bottom right position.
  static const bottomRight = PositionData(
    bottom: Dim.zero(),
    right: Dim.zero(),
    extra: {'transform': 'translate(0%, 0%)'},
  );

  /// Copy position attributes.
  PositionData copyWith({
    Dim? top,
    Dim? right,
    Dim? bottom,
    Dim? left,
    int? zIndex,
    Visibility? visibility,
    Overflow? overflow,
    Map<String, String>? extra,
  }) => PositionData(
    top: top ?? this.top,
    right: right ?? this.right,
    bottom: bottom ?? this.bottom,
    left: left ?? this.left,
    zIndex: zIndex ?? this.zIndex,
    visibility: visibility ?? this.visibility,
    overflow: overflow ?? this.overflow,
    extra: (this.extra ?? {}).combine(extra ?? {}),
  );

  /// Converts position attributes to a CSS style map.
  @override
  Map<String, String> get props => {
    'top': ?top?.cssText,
    'right': ?right?.cssText,
    'bottom': ?bottom?.cssText,
    'left': ?left?.cssText,
    'z-index': ?zIndex?.toCleanString,
    'visibility': ?visibility?.value,
    ...?overflow?.styles,
    ...?extra,
  };

  @override
  String get cssText => props.cssText;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PositionData &&
          runtimeType == other.runtimeType &&
          top == other.top &&
          right == other.right &&
          bottom == other.bottom &&
          left == other.left &&
          zIndex == other.zIndex &&
          visibility == other.visibility &&
          overflow == other.overflow &&
          _mapEquals(extra, other.extra);

  @override
  int get hashCode => Object.hashAll([
    top,
    right,
    bottom,
    left,
    zIndex,
    visibility,
    overflow,
    extra == null ? null : Object.hashAll(extra!.entries),
  ]);
}

/// Color attributes for different states of a component.
class ComponentStatesColor implements NakiStylable {
  /// Color applied to the border of a component when focused.
  final Color? focusBorderColor;

  /// Color applied to the foreground of a component when hovered.
  final Color? hoverColor;

  /// Color applied to the background of a component when hovered.
  final Color? hoverBackgroundColor;

  /// Color applied to a validation text or error message.
  final Color? errorTextColor;

  /// Color applied to the background of a component when disabled.
  final Color? disabledBackgroundColor;

  /// Color applied to the foreground of a component when disabled.
  final Color? disabledColor;

  /// Create a new state color.
  const ComponentStatesColor({
    this.focusBorderColor,
    this.hoverColor,
    this.hoverBackgroundColor,
    this.errorTextColor,
    this.disabledBackgroundColor,
    this.disabledColor,
  });

  /// Create a copy of the state color.
  ComponentStatesColor copyWith({
    Color? focusBorderColor,
    Color? hoverColor,
    Color? hoverBackgroundColor,
    Color? errorTextColor,
    Color? disabledBackgroundColor,
    Color? disabledColor,
  }) => ComponentStatesColor(
    focusBorderColor: focusBorderColor ?? this.focusBorderColor,
    hoverColor: hoverColor ?? this.hoverColor,
    hoverBackgroundColor: hoverBackgroundColor ?? this.hoverBackgroundColor,
    errorTextColor: errorTextColor ?? this.errorTextColor,
    disabledBackgroundColor: disabledBackgroundColor ?? this.disabledBackgroundColor,
    disabledColor: disabledColor ?? this.disabledColor,
  );

  /// Converts state colors to a CSS style map of global variables.
  @override
  Map<String, String> get props => {
    Tokens.current.focusBorderColor.name: ?focusBorderColor?.value,
    Tokens.current.fieldHoverColor.name: ?hoverColor?.value,
    Tokens.current.hoverColor.name: ?hoverColor?.value,
    Tokens.current.buttonHoverBgColor.name: ?hoverBackgroundColor?.value,
    Tokens.current.errorColor.name: ?errorTextColor?.value,
    Tokens.current.disabledBgColor.name: ?disabledBackgroundColor?.value,
    Tokens.current.disabledColor.name: ?disabledColor?.value,
  };

  @override
  String get cssText => props.cssText;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComponentStatesColor &&
          runtimeType == other.runtimeType &&
          focusBorderColor == other.focusBorderColor &&
          hoverColor == other.hoverColor &&
          hoverBackgroundColor == other.hoverBackgroundColor &&
          errorTextColor == other.errorTextColor &&
          disabledBackgroundColor == other.disabledBackgroundColor &&
          disabledColor == other.disabledColor;

  @override
  int get hashCode => Object.hash(
    focusBorderColor,
    hoverColor,
    hoverBackgroundColor,
    errorTextColor,
    disabledBackgroundColor,
    disabledColor,
  );
}

/// Defines side attributes for a border (width, color, style).
class BorderSideData {
  /// Color of the border side.
  final Color? color;

  /// Width of the border side.
  final Dim width;

  /// Style of the border side (solid, dashed, dotted, none, etc.).
  final BorderStyle style;

  /// Creates a [BorderSideData] definition.
  const BorderSideData({this.color, this.width = const Dim.px(1), this.style = BorderStyle.solid});

  /// A border side with no width/border.
  static const BorderSideData none = BorderSideData(width: Dim.zero(), style: BorderStyle.none);

  /// Get the border side CSS value.
  String get value => style == BorderStyle.none && width.value == 0 && color == null
      ? 'none'
      : '${width.cssText} ${style.value} ${color?.value ?? 'currentcolor'}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BorderSideData &&
          runtimeType == other.runtimeType &&
          color == other.color &&
          width == other.width &&
          style == other.style;

  @override
  int get hashCode => Object.hash(color, width, style);
}

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
  Map<String, String> get props => {'backdrop-filter': cssText, '-webkit-backdrop-filter': cssText};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Filter && runtimeType == other.runtimeType && _listEquals(_filters, other._filters);

  @override
  int get hashCode => Object.hashAll(_filters);
}

/// Styling configuration for SegmentedInput component.
class SegmentedInputStyle {
  /// Width of each individual segment box.
  final Dim? segmentWidth;

  /// Height of each individual segment box.
  final Dim? segmentHeight;

  /// Gap/spacing between segment boxes.
  final Dim? gap;

  /// Border decoration of each segment.
  final BorderData? border;

  /// Radius of segment corners.
  final BorderRadiusData? borderRadius;

  /// Border color of segment when hovered.
  final Color? hoverBorderColor;

  /// Border color of segment when focused.
  final Color? focusBorderColor;

  /// Border color of segment when validation fails.
  final Color? errorBorderColor;

  /// Background color of empty segments.
  final Color? backgroundColor;

  /// Background color of filled segments.
  final Color? filledBackgroundColor;

  /// Typography style for the text/digits inside segments.
  final TextStyle? textStyle;

  /// Shape variant of the segments (box, underline, circle).
  final SegmentedInputShape shape;

  /// Margin around the segmented input wrapper.
  final EdgeInsets? margin;

  /// Padding around each segment box.
  final EdgeInsets? padding;

  /// Creates a [SegmentedInputStyle] instance.
  const SegmentedInputStyle({
    this.segmentWidth,
    this.segmentHeight,
    this.gap,
    this.border,
    this.borderRadius,
    this.hoverBorderColor,
    this.focusBorderColor,
    this.errorBorderColor,
    this.backgroundColor,
    this.filledBackgroundColor,
    this.textStyle,
    this.shape = SegmentedInputShape.box,
    this.margin,
    this.padding,
  });

  /// Creates a copy of this [SegmentedInputStyle]
  /// with the given fields replaced.
  SegmentedInputStyle copyWith({
    Dim? segmentWidth,
    Dim? segmentHeight,
    Dim? gap,
    BorderData? border,
    BorderRadiusData? borderRadius,
    Color? hoverBorderColor,
    Color? focusBorderColor,
    Color? errorBorderColor,
    Color? backgroundColor,
    Color? filledBackgroundColor,
    TextStyle? textStyle,
    SegmentedInputShape? shape,
    EdgeInsets? margin,
    EdgeInsets? padding,
  }) {
    return SegmentedInputStyle(
      segmentWidth: segmentWidth ?? this.segmentWidth,
      segmentHeight: segmentHeight ?? this.segmentHeight,
      gap: gap ?? this.gap,
      border: border ?? this.border,
      borderRadius: borderRadius ?? this.borderRadius,
      hoverBorderColor: hoverBorderColor ?? this.hoverBorderColor,
      focusBorderColor: focusBorderColor ?? this.focusBorderColor,
      errorBorderColor: errorBorderColor ?? this.errorBorderColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      filledBackgroundColor: filledBackgroundColor ?? this.filledBackgroundColor,
      textStyle: textStyle ?? this.textStyle,
      shape: shape ?? this.shape,
      margin: margin ?? this.margin,
      padding: padding ?? this.padding,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SegmentedInputStyle &&
          runtimeType == other.runtimeType &&
          segmentWidth == other.segmentWidth &&
          segmentHeight == other.segmentHeight &&
          gap == other.gap &&
          border == other.border &&
          borderRadius == other.borderRadius &&
          hoverBorderColor == other.hoverBorderColor &&
          focusBorderColor == other.focusBorderColor &&
          errorBorderColor == other.errorBorderColor &&
          backgroundColor == other.backgroundColor &&
          filledBackgroundColor == other.filledBackgroundColor &&
          textStyle == other.textStyle &&
          shape == other.shape &&
          margin == other.margin &&
          padding == other.padding;

  @override
  int get hashCode => Object.hashAll([
    segmentWidth,
    segmentHeight,
    gap,
    border,
    borderRadius,
    hoverBorderColor,
    focusBorderColor,
    errorBorderColor,
    backgroundColor,
    filledBackgroundColor,
    textStyle,
    shape,
    margin,
    padding,
  ]);
}

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
    ..applyLinear(colors: const [Color('#ff7e5f'), Color('#feb47b')], angle: 135);

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
          _listEquals(_gradients, other._gradients);

  @override
  int get hashCode => Object.hashAll(_gradients);
}
