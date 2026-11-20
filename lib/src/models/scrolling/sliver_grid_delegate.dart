part of 'index.dart';

/// Controls the layout of tiles in a `GridView`.
abstract class SliverGridDelegate {
  /// Abstract const constructor.
  const SliverGridDelegate();
}

/// Creates grid layouts with a fixed number of tiles in the cross ScrollDirection.
class SliverGridDelegateWithFixedCrossAxisCount extends SliverGridDelegate {
  /// Number of columns/rows in the cross ScrollDirection.
  final int crossAxisCount;

  /// Logical spacing between items along the main ScrollDirection.
  final Dim mainAxisSpacing;

  /// Logical spacing between items along the cross ScrollDirection.
  final Dim crossAxisSpacing;

  /// Ratio of the cross-axis to the main-axis extent of each child.
  final AspectRatioType? childAspectRatio;

  /// Main axis size of child (overrides [childAspectRatio] if specified).
  ///
  /// - If scroll direction is `vertical`, this is the `height` of each item.
  /// - If scroll direction is `horizontal`, this is the `width` of each item.
  final Dim? mainAxisExtent;

  /// Creates a [SliverGridDelegateWithFixedCrossAxisCount].
  const SliverGridDelegateWithFixedCrossAxisCount({
    required this.crossAxisCount,
    this.mainAxisSpacing = const Dim.px(16),
    this.crossAxisSpacing = const Dim.px(16),
    this.childAspectRatio,
    this.mainAxisExtent,
  }) : assert(crossAxisCount > 0, 'crossAxisCount must be greater than 0');
}

/// Creates grid layouts with tiles that each have a maximum cross-axis extent.
class SliverGridDelegateWithMaxCrossAxisExtent extends SliverGridDelegate {
  /// Maximum extent of tiles in the cross ScrollDirection.
  ///
  /// - If scroll direction is `vertical`, this is the `max-width` of each item.
  /// - If scroll direction is `horizontal`, this is the `max-height` of each item.
  final Dim maxCrossAxisExtent;

  /// Logical spacing between items along the main ScrollDirection.
  final Dim mainAxisSpacing;

  /// Logical spacing between items along the cross ScrollDirection.
  final Dim crossAxisSpacing;

  /// Ratio of the cross-axis to the main-axis extent of each child.
  final AspectRatioType? childAspectRatio;

  /// Main axis size of child (overrides [childAspectRatio] if specified).
  ///
  /// - If scroll direction is `vertical`, this is the `height` of each item.
  /// - If scroll direction is `horizontal`, this is the `width` of each item.
  final Dim? mainAxisExtent;

  /// Creates a [SliverGridDelegateWithMaxCrossAxisExtent] that creates grid
  /// layouts with tiles each having a maximum cross-axis extent.
  const SliverGridDelegateWithMaxCrossAxisExtent({
    required this.maxCrossAxisExtent,
    this.mainAxisSpacing = const Dim.px(16),
    this.crossAxisSpacing = const Dim.px(16),
    this.childAspectRatio,
    this.mainAxisExtent,
  });
}
