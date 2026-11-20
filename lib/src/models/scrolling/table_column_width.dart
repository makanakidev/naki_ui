part of 'index.dart';

/// Base class for specifying column width behavior in a TableView component.
abstract class TableColumnWidth {
  /// Base const constructor.
  const TableColumnWidth();

  /// Returns the CSS width string corresponding to this column width rule.
  String get cssWidth;
}

/// Column width that expands based on flex factor.
class FlexColumnWidth extends TableColumnWidth {
  /// Creates a column width that expands based on flex factor.
  const FlexColumnWidth();

  @override
  String get cssWidth => 'auto';
}

/// Column width fixed to a specific size.
class FixedColumnWidth extends TableColumnWidth {
  /// The fixed width.
  final Dim width;

  /// Creates a column width fixed to a specific size.
  const FixedColumnWidth(this.width);

  @override
  String get cssWidth => width.cssText;
}

/// Column width based on the intrinsic content width.
class IntrinsicColumnWidth extends TableColumnWidth {
  /// Creates a column width based on the intrinsic content width.
  const IntrinsicColumnWidth();

  @override
  String get cssWidth => 'max-content';
}

/// Column width calculated as a fraction of the total table width.
class FractionColumnWidth extends TableColumnWidth {
  /// Fraction value between 0.0 and 1.0.
  final double value;

  /// Creates a column width calculated as a fraction of the total table width.
  const FractionColumnWidth(this.value);

  @override
  String get cssWidth => '${(value.clamp(0, 1.0)) * 100}%';
}
