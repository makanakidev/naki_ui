part of 'index.dart';

/// {@template GridTile}
/// A component that specifies column/row spanning properties
/// for an item in a [GridView].
///
/// ### Example
/// ```dart
/// GridTile(
///   columnSpan: 2,
///   child: NakiText('Spans 2 columns'),
/// )
/// ```
/// {@endtemplate}
class GridTile extends StatelessComponent {
  /// The inner component inside the tile.
  final Component child;

  /// Number of columns this tile spans.
  final int? columnSpan;

  /// Number of rows this tile spans.
  final int? rowSpan;

  /// Whether this tile spans the full width of the grid.
  final bool fullWidth;

  /// {@macro GridTile}
  const GridTile({
    super.key,
    required this.child,
    this.fullWidth = false,
    this.columnSpan,
    this.rowSpan,
  });

  @override
  Component build(BuildContext context) => child;
}
