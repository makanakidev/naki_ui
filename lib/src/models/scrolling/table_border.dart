part of 'index.dart';

/// Defines horizontal and vertical borders of a [Table] component.
class TableBorder {
  /// Top border of the table's outer boundary.
  final BorderSideData top;

  /// Right border of the table's outer boundary.
  final BorderSideData right;

  /// Bottom border of the table's outer boundary.
  final BorderSideData bottom;

  /// Left border of the table's outer boundary.
  final BorderSideData left;

  /// Border applied horizontally between rows (rendered as
  /// the bottom border of each cell, excluding the final row).
  final BorderSideData horizontalInside;

  /// Border applied vertically between columns (rendered as
  /// the right border of each cell, excluding the final column).
  final BorderSideData verticalInside;

  /// Border radius of the table.
  final BorderRadiusData? borderRadius;

  /// Creates a [TableBorder] with distinct side borders.
  const TableBorder({
    this.top = BorderSideData.none,
    this.right = BorderSideData.none,
    this.bottom = BorderSideData.none,
    this.left = BorderSideData.none,
    this.horizontalInside = BorderSideData.none,
    this.verticalInside = BorderSideData.none,
    this.borderRadius,
  });

  /// Creates a [TableBorder] where all sides share
  /// the same border properties.
  factory TableBorder.all({
    Dim width = const Dim.px(1),
    BorderStyle style = BorderStyle.solid,
    Color? color,
    BorderRadiusData? borderRadius,
  }) {
    final side = BorderSideData(color: color, width: width, style: style);
    return TableBorder(
      top: side,
      right: side,
      bottom: side,
      left: side,
      horizontalInside: side,
      verticalInside: side,
      borderRadius: borderRadius,
    );
  }

  /// Creates a [TableBorder] with symmetric outer/inner borders.
  factory TableBorder.symmetric({
    BorderSideData inside = BorderSideData.none,
    BorderSideData outside = BorderSideData.none,
  }) {
    return TableBorder(
      top: outside,
      right: outside,
      bottom: outside,
      left: outside,
      horizontalInside: inside,
      verticalInside: inside,
    );
  }

  /// Returns the CSS border style map for this TableBorder instance.
  Map<String, String> get props {
    return {
      'border-top': top.value,
      'border-right': right.value,
      'border-bottom': bottom.value,
      'border-left': left.value,
      ...?borderRadius?.props,
    };
  }
}
