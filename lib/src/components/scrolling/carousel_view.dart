part of 'index.dart';

/// {@template CarouselView}
/// A component that presents items horizontally or vertically in a
/// scrollable carousel.
///
/// Supports item snapping, customizable scroll physics via [physics],
/// and custom scrollbar styling via [scrollBarConfiguration].
///
/// ### Example
/// ```dart
/// CarouselView(
///   itemExtent: const Dim.px(280),
///   physics: const BouncingScrollPhysics(),
///   scrollBarConfiguration: const ScrollBarConfiguration(
///     thumbColor: Color('#888888'),
///     trackColor: Color('#f0f0f0'),
///     height: 4,
///     radius: 2,
///   ),
///   children: [
///     Container(child: NakiText('Card 1')),
///     Container(child: NakiText('Card 2')),
///   ],
/// )
/// ```
///
/// See also:
/// - [CarouselView.weighted] for a carousel with flex weights.
/// - [PageView] for a page-based scrolling layout.
/// - [GridView] for a grid-based scrolling layout.
/// - [ListView] for a list-based scrolling layout.
/// - [SingleChildScrollView] for basic scrollable layout.
/// - [Table] for tabular data layout.
/// {@endtemplate}
class CarouselView extends StatefulComponent {
  /// Components in the carousel.
  final List<Component> children;

  /// The size of each component along the scroll direction
  /// (default: `Dim.px(280)`).
  final Dim itemExtent;

  /// Relative flex weights assigned to components in the carousel.
  ///
  /// When provided, [children] will be sized based on their
  /// relative weight.
  ///
  /// ### Example
  /// ```dart
  /// CarouselView(
  ///   flexWeights: [1, 0.5, 3],
  ///   itemExtent: Dim.px(100),
  ///   ...
  /// )
  /// ```
  ///
  /// When `null`, [children] will be sized based on [itemExtent].
  final List<double>? flexWeights;

  /// Scroll direction.
  final ScrollDirection direction;

  /// Reverse scroll direction.
  final bool reverse;

  /// Enable scroll snap snapping (default: `true`).
  ///
  /// When `true`, [children] will snap to the nearest position.
  final bool itemSnapping;

  /// Scroll controller for observing and controlling scrolling.
  final ScrollController? controller;

  /// Spacing between [children] along the scroll [direction].
  final Dim? mainAxisSpacing;

  /// Callback invoked when a component in [children] is tapped/clicked.
  final ValueChanged<int>? onTap;

  /// Scroll physics for customizing scrolling behavior (e.g. [BouncingScrollPhysics],
  /// [ClampingScrollPhysics], [NeverScrollableScrollPhysics]).
  final ScrollPhysics? physics;

  /// Scroll bar configuration. When provided, renders styled scrollbars.
  final ScrollBarConfiguration? scrollBarConfiguration;

  /// Additional CSS classes applied to the carousel component.
  final String? classes;

  /// {@macro CarouselView}
  const CarouselView({
    super.key,
    required this.children,
    this.itemExtent = const Dim.px(280),
    this.direction = ScrollDirection.horizontal,
    this.reverse = false,
    this.itemSnapping = true,
    this.controller,
    this.mainAxisSpacing,
    this.onTap,
    this.physics,
    this.flexWeights,
    this.scrollBarConfiguration,
    this.classes,
  });

  /// Creates a carousel with flex weights assigned to items.
  ///
  /// Supports customizable scroll physics via [physics] and scrollbar
  /// configuration via [scrollBarConfig].
  ///
  /// ### Example
  /// ```dart
  /// CarouselView.weighted(
  ///   flexWeights: const [1, 2, 1],
  ///   itemExtent: const Dim.px(160),
  ///   physics: const BouncingScrollPhysics(),
  ///   scrollBarConfig: const ScrollBarConfiguration(
  ///     thumbColor: Color('#888888'),
  ///     trackColor: Color('#f0f0f0'),
  ///     height: 4,
  ///   ),
  ///   children: [
  ///     Card(child: NakiText('Small')),
  ///     Card(child: NakiText('Featured')),
  ///     Card(child: NakiText('Small')),
  ///   ],
  /// )
  /// ```
  ///
  /// ### Parameters
  /// * [flexWeights]: Relative flex weights determining item
  ///   sizing ratios.
  /// * [itemExtent]: Base extent (width/height) of each component in
  ///   the carousel based on [direction].
  /// * [children]: Components to display in the carousel.
  /// * [direction]: Scroll axis direction.
  /// * [reverse]: Whether components are rendered in reverse order.
  /// * [itemSnapping]: Whether components snap into alignment on
  ///   scroll end.
  /// * [mainAxisSpacing]: Spacing between components along the
  ///   scroll direction
  /// * [controller]: Controller for programmatic scrolling.
  /// * [physics]: Scroll physics governing inertia and snap behavior.
  /// * [scrollBarConfig]: Scroll bar configuration.
  /// * [onTap]: Callback invoked with the index of the tapped component.
  /// * [classes]: Additional CSS class names applied to the carousel.
  factory CarouselView.weighted({
    Key? key,
    required List<double> flexWeights,
    required Dim itemExtent,
    required List<Component> children,
    ScrollDirection direction = ScrollDirection.horizontal,
    bool reverse = false,
    bool itemSnapping = true,
    Dim? mainAxisSpacing,
    ScrollController? controller,
    ScrollPhysics? physics,
    ValueChanged<int>? onTap,
    ScrollBarConfiguration? scrollBarConfig,
    String? classes,
  }) {
    return CarouselView(
      key: key,
      children: children,
      itemExtent: itemExtent,
      flexWeights: flexWeights,
      direction: direction,
      reverse: reverse,
      itemSnapping: itemSnapping,
      mainAxisSpacing: mainAxisSpacing,
      controller: controller,
      physics: physics,
      onTap: onTap,
      scrollBarConfiguration: scrollBarConfig,
      classes: classes,
    );
  }

  @override
  State<CarouselView> createState() => _CarouselViewState();

  static List<StyleRule> get styles => ScrollingStyles.carouselView;
}

class _CarouselViewState extends State<CarouselView> with NakiStatefulMixin {
  late final String _id = nakiDomId(context, 'carousel-view');

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
  void didUpdateComponent(CarouselView oldComponent) {
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
      Tokens.current.carouselGap.name: ?component.mainAxisSpacing?.cssText,
      'overflow-x': isHoriz ? 'auto' : 'hidden',
      'overflow-y': !isHoriz ? 'auto' : 'hidden',
      if (component.itemSnapping)
        'scroll-snap-type': '${isHoriz ? 'x' : 'y'} mandatory',
      'flex-direction': isHoriz
          ? (component.reverse ? 'row-reverse' : 'row')
          : (component.reverse ? 'column-reverse' : 'column'),
      ...?component.physics?.props(component.direction),
    };

    final List<Component> items = [];
    final weights = component.flexWeights ?? [];
    final hasWeights = weights.isNotEmpty;

    for (int i = 0; i < component.children.length; i++) {
      final child = component.children[i];
      final weight = (hasWeights && i < weights.length) ? weights[i] : null;

      final itemExtentCss = weight != null
          ? 'calc(${component.itemExtent.cssText} * ${weight.toCleanString})'
          : component.itemExtent.cssText;

      items.add(
        div(
          classes: 'naki-carousel-item',
          styles: Styles(
            raw: {
              isHoriz ? 'width' : 'height': itemExtentCss,
              'flex-grow': ?weight?.toString(),
              'cursor': component.onTap != null ? 'pointer' : 'default',
            },
          ),
          attributes: component.onTap != null
              ? {'role': 'button', 'tabindex': '0'}
              : null,
          events: component.onTap == null
              ? null
              : {
                  'click': (_) => component.onTap!.call(i),
                  'keydown': (event) {
                    final key = (event as KeyboardEvent).key;
                    if (key == 'Enter' || key == ' ') {
                      event.preventDefault();
                      component.onTap!.call(i);
                    }
                  },
                },
          [child],
        ),
      );
    }

    const baseClass = 'naki-carouselview';
    final effectiveClasses = joinClasses([?component.classes, baseClass]);

    final Component child = .element(
      tag: 'naki-carouselview',
      id: _id,
      key: component.key,
      classes: effectiveClasses,
      styles: Styles(raw: effectiveStyles),
      attributes: {
        if (component.itemSnapping ||
            component.physics?.type == ScrollPhysicsType.snapping)
          'snap': '',
      },
      children: items,
    );

    return ScrollBarWrapper(
      selector: '#$_id',
      configuration: component.scrollBarConfiguration,
      child: child,
    );
  }
}
