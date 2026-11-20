part of 'index.dart';

/// Defines side attributes for a border (width, color, style).
class BorderSideData {
  /// Color of the border side.
  final Color? color;

  /// Width of the border side.
  final Dim width;

  /// Style of the border side (solid, dashed, dotted, none, etc.).
  final BorderStyle style;

  /// Creates a [BorderSideData] definition.
  const BorderSideData({
    this.color,
    this.width = const Dim.px(1),
    this.style = BorderStyle.solid,
  });

  /// A border side with no width/border.
  static const BorderSideData none = BorderSideData(
    width: Dim.zero,
    style: BorderStyle.none,
  );

  /// Get the border side CSS value.
  String get value =>
      style == BorderStyle.none && width.value == 0 && color == null
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
