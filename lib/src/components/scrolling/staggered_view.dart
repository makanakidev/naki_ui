part of 'index.dart';

/// {@template StaggeredView}
/// A component that arranges its children in a staggered
/// grid / masonry layout.
///
/// Supports custom [crossAxisCount], [mainAxisSpacing],
/// [crossAxisSpacing], customizable scroll physics via [physics],
/// and custom scrollbar styling via [scrollBarConfiguration].
///
/// ### Example
/// ```dart
/// StaggeredView(
///   crossAxisCount: 2,
///   mainAxisSpacing: const Dim.px(16),
///   crossAxisSpacing: const Dim.px(16),
///   physics: const BouncingScrollPhysics(),
///   scrollBarConfiguration: const ScrollBarConfiguration(
///     thumbColor: Color('#888888'),
///     trackColor: Color('#f0f0f0'),
///     width: 6,
///     radius: 3,
///   ),
///   children: [
///     Container(child: NakiText('Item 1')),
///     Container(child: NakiText('Item 2')),
///   ],
/// )
/// ```
///
/// See also:
/// - [StaggeredView.count] for staggered grid with a fixed
///   number of columns.
/// - [GridView] for a non-staggered grid layout.
/// - [ListView] for a vertical list layout.
/// - [SingleChildScrollView] for a simple scrollable component.
/// {@endtemplate}
class StaggeredView extends StatefulComponent {
  /// Components in the staggered grid.
  final List<Component> children;

  /// Number of columns in the cross axis (default: 2).
  final int crossAxisCount;

  /// Spacing between components in the main axis (default: Dim.px(16)).
  final Dim mainAxisSpacing;

  /// Spacing between columns in the cross axis (default: Dim.px(16)).
  final Dim crossAxisSpacing;

  /// Main scroll axis direction (default: [ScrollDirection.vertical]).
  final ScrollDirection direction;

  /// Padding around the staggered grid content area.
  final EdgeInsets? padding;

  /// Scroll controller for programmatic scrolling.
  final ScrollController? controller;

  /// Scroll physics for customizing scrolling behavior
  /// (e.g. [BouncingScrollPhysics], [ClampingScrollPhysics],
  /// [NeverScrollableScrollPhysics]).
  final ScrollPhysics? physics;

  /// Scroll bar configuration. When provided, renders styled scrollbars.
  final ScrollBarConfiguration? scrollBarConfiguration;

  /// Additional CSS classes applied to the staggered view component.
  final String? classes;

  /// Whether to automatically span the last item across
  /// unfilled columns.
  final bool expandLastItem;

  /// {@macro StaggeredView}
  const StaggeredView({
    super.key,
    required this.children,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = const Dim.px(16),
    this.crossAxisSpacing = const Dim.px(16),
    this.direction = ScrollDirection.vertical,
    this.expandLastItem = false,
    this.padding,
    this.controller,
    this.physics,
    this.scrollBarConfiguration,
    this.classes,
  }) : assert(crossAxisCount > 0, 'crossAxisCount must be greater than 0');

  /// Creates a staggered grid view with a fixed number of columns.
  ///
  /// Supports customizable scroll physics via [physics] and scrollbar
  /// styling via [scrollBarConfig].
  ///
  /// ### Example
  /// ```dart
  /// StaggeredView.count(
  ///   2,
  ///   physics: const BouncingScrollPhysics(),
  ///   scrollBarConfig: const ScrollBarConfiguration(
  ///     thumbColor: Color('#888888'),
  ///     trackColor: Color('#f0f0f0'),
  ///     width: 6,
  ///     radius: 3,
  ///   ),
  ///   children: [
  ///     Container(child: NakiText('Item 1')),
  ///     Container(child: NakiText('Item 2')),
  ///   ],
  /// )
  /// ### Parameters
  /// * [crossAxisCount]: Fixed number of columns in the cross
  ///   ScrollDirection.
  /// * [children]: List of child components inside the staggered view.
  /// * [mainAxisSpacing]: Spacing between components along the
  ///   main ScrollDirection.
  /// * [crossAxisSpacing]: Spacing between columns along the
  ///   cross ScrollDirection.
  /// * [direction]: Main scroll axis direction.
  /// * [expandLastItem]: Whether to expand the last item across
  ///   unfilled columns.
  /// * [padding]: Insets around the staggered grid content.
  /// * [controller]: Controller for programmatic scroll operations.
  /// * [physics]: Scroll physics governing scroll behavior.
  /// * [scrollBarConfig]: Scroll bar configuration.
  /// * [classes]: Additional CSS class names applied to the staggered
  ///   view component.
  factory StaggeredView.count(
    int crossAxisCount, {
    Key? key,
    required List<Component> children,
    Dim mainAxisSpacing = const Dim.px(16),
    Dim crossAxisSpacing = const Dim.px(16),
    ScrollDirection direction = ScrollDirection.vertical,
    bool expandLastItem = false,
    EdgeInsets? padding,
    ScrollController? controller,
    ScrollPhysics? physics,
    ScrollBarConfiguration? scrollBarConfig,
    String? classes,
  }) {
    return StaggeredView(
      key: key,
      children: children,
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      direction: direction,
      expandLastItem: expandLastItem,
      padding: padding,
      controller: controller,
      physics: physics,
      scrollBarConfiguration: scrollBarConfig,
      classes: classes,
    );
  }

  @override
  State<StaggeredView> createState() => _StaggeredViewState();

  static List<StyleRule> get styles => ScrollingStyles.staggeredView;
}

class _StaggeredViewState extends State<StaggeredView> with NakiStatefulMixin {
  late final String _id = nakiDomId(context, 'staggered-view');

  /// Returns the component's global key
  GlobalNodeKey<HTMLElement>? get _key =>
      component.key is GlobalNodeKey<HTMLElement>
      ? component.key as GlobalNodeKey<HTMLElement>
      : null;

  @override
  FutureOr<VoidCallback?> afterRender(BuildContext context) {
    final element =
        _key?.currentNode ?? document.getElementById(_id) as HTMLElement?;

    if (element != null && component.controller != null) {
      final controller = component.controller!;
      controller.attach(element);
      return controller.detach;
    }

    return null;
  }

  @override
  void didUpdateComponent(StaggeredView oldComponent) {
    super.didUpdateComponent(oldComponent);

    if (oldComponent.controller != component.controller ||
        oldComponent.direction != component.direction) {
      refreshAfterRender();
    }
  }

  @override
  Component build(BuildContext context) {
    final isHoriz = component.direction == ScrollDirection.horizontal;

    final effectiveStyles = {
      if (!isHoriz) ...{
        'display': 'block',
        'height': '100%',
      } else ...{
        'display': 'grid',
        'grid-auto-flow': 'column',
        'grid-template-rows':
            'repeat(${component.crossAxisCount}, max-content)',
        'column-gap': component.mainAxisSpacing.cssText,
        'row-gap': component.crossAxisSpacing.cssText,
        'width': 'max-content',
      },
      'overflow-x': isHoriz ? 'auto' : 'hidden',
      'overflow-y': !isHoriz ? 'auto' : 'hidden',
      ...Css.scrollPadding(component.padding, vertical: !isHoriz),
      ...?component.physics?.props(component.direction),
    };

    final crossAxisCount = component.crossAxisCount;
    final totalChildren = component.children.length;
    final isRowPartiallyFilled = (totalChildren % crossAxisCount) != 0;
    final List<Component> items = [];

    for (int i = 0; i < totalChildren; i++) {
      final c = component.children[i];
      final isLast = i == totalChildren - 1;

      final tile = c is StaggeredTile ? c : null;
      final child = tile != null ? tile.child : c;

      final isSpanLast =
          isLast && component.expandLastItem && isRowPartiallyFilled;
      final isFullWidth = isSpanLast || (tile?.fullWidth ?? false);

      items.add(
        .element(
          tag: 'naki-staggered-item',
          classes: 'naki-staggered-item',
          styles: Styles(
            raw: {
              if (isFullWidth) 'column-span': 'all',
              if (!isHoriz) 'margin-bottom': component.mainAxisSpacing.cssText,
              if (isHoriz) 'margin-right': component.mainAxisSpacing.cssText,
            },
          ),
          children: [child],
        ),
      );
    }

    const baseClass = 'naki-staggeredview';
    final effectiveClasses = joinClasses([
      ?component.classes,
      if (!isHoriz) ...[kInsetOwnerClass, kFillScrollClass],
      baseClass,
    ]);

    final Component child = .element(
      tag: 'naki-staggered-view',
      id: _id,
      key: component.key,
      classes: effectiveClasses,
      styles: Styles(raw: effectiveStyles),
      children: isHoriz
          ? items
          : [
              .element(
                tag: 'naki-staggered-columns',
                classes: 'naki-staggered-columns',
                styles: Styles(
                  raw: {
                    'display': 'block',
                    'column-count': '${component.crossAxisCount}',
                    'column-gap': component.crossAxisSpacing.cssText,
                  },
                ),
                children: items,
              ),
            ],
    );

    return ScrollBarWrapper(
      selector: '#$_id',
      configuration: component.scrollBarConfiguration,
      child: child,
    );
  }
}
