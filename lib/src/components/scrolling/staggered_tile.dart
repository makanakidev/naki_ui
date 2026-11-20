part of 'index.dart';

/// {@template StaggeredTile}
/// A component that specifies column spanning properties
/// for an item in a [StaggeredView].
///
/// ### Example
/// ```dart
/// StaggeredTile(
///   fullWidth: true,
///   child: Banner(primary: NakiText('Full width banner')),
/// )
/// ```
/// {@endtemplate}
class StaggeredTile extends StatelessComponent {
  /// The inner component inside the tile.
  final Component child;

  /// Whether this tile spans all columns in the staggered view.
  final bool fullWidth;

  /// {@macro StaggeredTile}
  const StaggeredTile({super.key, required this.child, this.fullWidth = false});

  @override
  Component build(BuildContext context) => child;
}
