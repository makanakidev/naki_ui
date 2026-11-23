part of 'index.dart';

/// {@template ScrollBarWrapper}
/// A component that adds scrollbar styling to its child.
///
/// This is used by components like [SingleChildScrollView], [ListView],
/// [GridView], [PageView], [CarouselView], [Table], [StaggeredView],
/// and other scrollable components to add scrollbar styling to
/// their children.
///
/// ### Example
/// ```dart
/// ScrollBarWrapper(
///   selector: '.my-list',
///   configuration: const ScrollBarConfiguration(
///     thumbColor: Color('#888888'),
///     trackColor: Color('#f0f0f0'),
///     width: 8,
///     radius: 4,
///   ),
///   child: ListView(
///     classes: 'my-list',
///     physics: const BouncingScrollPhysics(),
///     children: [
///       NakiText('Item 1'),
///       NakiText('Item 2'),
///     ],
///   ),
/// )
/// ```
/// {@endtemplate}
class ScrollBarWrapper extends StatelessComponent {
  /// The selector for the scrollbar. This can be an id, class,
  /// or any valid CSS selector.
  final String selector;

  /// The scrollbar configuration.
  /// If `null`, no scrollbar will be added.
  final ScrollBarConfiguration? configuration;

  /// The child component.
  final Component child;

  /// {@macro ScrollBarWrapper}
  const ScrollBarWrapper({
    super.key,
    required this.selector,
    this.configuration,
    required this.child,
  });

  @override
  Component build(BuildContext context) {
    return configuration == null
        ? child
        : NakiFragment([
            child,
            Document.head(
              children: [
                StyleRules(
                  Rules.buildScrollbarRules(selector, configuration!),
                  id: '${selector.hashCode}',
                ),
              ],
            ),
          ]);
  }
}
