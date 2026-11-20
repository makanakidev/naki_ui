part of 'index.dart';

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
         width: Dim.zero,
         isOnly: true,
       );

  /// A border with all properties set to zero/none.
  static BorderData get none => const BorderData._(
    color: Color.unset,
    style: BorderStyle.none,
    width: Dim.zero,
    radius: BorderRadiusData.none,
    isNone: true,
  );

  /// Convert border attributes to CSS styles.
  @override
  Map<String, String> get props => {
    if (_isNone) ...{
      'border': 'none',
    } else if (top != null ||
        right != null ||
        bottom != null ||
        left != null) ...{
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
  int get hashCode =>
      Object.hash(color, radius, style, width, top, right, bottom, left);
}
