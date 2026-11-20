part of 'index.dart';

/// A row of cells within a TableView component.
class TableRow {
  /// Unique identifier for the row.
  final String? id;

  /// Child cell components in the row (e.g. NakiText).
  final List<Component> children;

  /// Alignment of cells in the row.
  final TableRowCellAlignment? alignment;

  /// Additional CSS classes applied to the row.
  final String? classes;

  /// Callback function that is invoked when the row is clicked.
  final VoidCallback? onClick;

  /// Creates a [TableRow].
  const TableRow({
    this.id,
    required this.children,
    this.alignment,
    this.classes,
    this.onClick,
  });
}
