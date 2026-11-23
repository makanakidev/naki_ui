part of 'index.dart';

/// {@template PageView}
/// A component that displays a scrollable list that works page by page.
///
/// Supports page snapping, page navigation controller, customizable
/// scroll physics via [physics], and custom scrollbar styling via
/// [scrollBarConfiguration].
///
/// ### Example
/// ```dart
/// final controller = PageController();
///
/// PageView(
///   controller: controller,
///   physics: const BouncingScrollPhysics(),
///   scrollBarConfiguration: const ScrollBarConfiguration(
///     thumbColor: Color('#888888'),
///     trackColor: Color('#f0f0f0'),
///     height: 4,
///     radius: 2,
///   ),
///   onPageChanged: (page) => print('Page: $page'),
///   children: [
///     Page1(),
///     Page2(),
///   ],
/// )
/// ```
///
/// See also:
/// - [PageView.builder] for dynamic page building.
/// - [GridView] for grid layout.
/// - [ListView] for list layout.
/// - [SingleChildScrollView] for basic scrollable layout.
/// - [Table] for tabular data layout.
/// {@endtemplate}
class PageView extends StatefulComponent {
  /// Components to display.
  final List<Component> children;

  /// Direction of scrolling.
  final ScrollDirection direction;

  /// Reverse scroll direction.
  final bool reverse;

  /// Page controller for page navigation.
  final PageController? controller;

  /// Scroll physics for controlling scroll behavior (e.g. [BouncingScrollPhysics],
  /// [ClampingScrollPhysics], [NeverScrollableScrollPhysics]).
  final ScrollPhysics? physics;

  /// Scroll bar configuration. When provided, renders styled scrollbars.
  final ScrollBarConfiguration? scrollBarConfiguration;

  /// Whether page snapping is enabled (default: `true`).
  ///
  /// When `true`, the page view will snap to the nearest
  /// page after scrolling stops.
  final bool pageSnapping;

  /// Callback executed when the page changes after scrolling.
  final ValueChanged<int>? onPageChanged;

  /// Additional CSS classes applied to the page view component.
  final String? classes;

  /// {@macro PageView}
  const PageView({
    super.key,
    required this.children,
    this.direction = ScrollDirection.horizontal,
    this.reverse = false,
    this.pageSnapping = true,
    this.controller,
    this.physics,
    this.scrollBarConfiguration,
    this.onPageChanged,
    this.classes,
  });

  /// Builds a [PageView] dynamically with an item builder.
  ///
  /// Supports customizable scroll physics via [physics] and scrollbar
  /// styling via [scrollBarConfig].
  ///
  /// ### Example
  /// ```dart
  /// PageView.builder(
  ///   itemCount: 10,
  ///   physics: const BouncingScrollPhysics(),
  ///   scrollBarConfig: const ScrollBarConfiguration(
  ///     thumbColor: Color('#888888'),
  ///     trackColor: Color('#f0f0f0'),
  ///     height: 4,
  ///   ),
  ///   itemBuilder: (context, index) => PageCard(index: index),
  /// )
  /// ```
  ///
  /// ### Parameters
  /// * [itemCount]: Total number of pages.
  /// * [itemBuilder]: Builder function returning the page component for
  ///   a given index.
  /// * [direction]: Direction in which pages scroll.
  /// * [reverse]: Whether pages are rendered in reverse order.
  /// * [controller]: Controller for page navigation and
  ///   viewport tracking.
  /// * [physics]: Scroll physics governing swipe behavior.
  /// * [scrollBarConfig]: Scroll bar configuration.
  /// * [pageSnapping]: Whether pages snap to page boundaries.
  /// * [onPageChanged]: Callback invoked when the active
  ///   page index changes.
  /// * [classes]: Additional CSS class names applied to the page view.
  factory PageView.builder({
    Key? key,
    required int itemCount,
    required Component Function(BuildContext context, int index) itemBuilder,
    ScrollDirection direction = ScrollDirection.horizontal,
    bool reverse = false,
    bool pageSnapping = true,
    PageController? controller,
    ScrollPhysics? physics,
    ScrollBarConfiguration? scrollBarConfig,
    ValueChanged<int>? onPageChanged,
    String? classes,
  }) {
    return _PageViewBuilder(
      key: key,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      direction: direction,
      reverse: reverse,
      controller: controller,
      physics: physics,
      scrollBarConfiguration: scrollBarConfig,
      pageSnapping: pageSnapping,
      onPageChanged: onPageChanged,
      classes: classes,
    );
  }

  @override
  State<PageView> createState() => _PageViewState();

  static List<StyleRule> get styles => ScrollingStyles.pageView;
}

class _PageViewState extends State<PageView> with NakiStatefulMixin {
  late final String _id = nakiDomId(context, 'pageview');

  int _currentPage = 0;
  PageController? _internalController;

  /// The page controller used by this component
  PageController get _effectiveController =>
      component.controller ??
      (_internalController ??= PageController(direction: component.direction));

  /// Returns the component's global key
  GlobalNodeKey<HTMLElement>? get _key =>
      component.key is GlobalNodeKey<HTMLElement>
      ? component.key as GlobalNodeKey<HTMLElement>
      : null;

  @override
  void didUpdateComponent(PageView oldComponent) {
    super.didUpdateComponent(oldComponent);

    if (oldComponent.controller != component.controller ||
        oldComponent.direction != component.direction) {
      if (oldComponent.controller == null) {
        _internalController?.dispose();
        _internalController = null;
      }

      refreshAfterRender();
    }
  }

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  @override
  FutureOr<VoidCallback?> afterRender(BuildContext context) {
    final element =
        _key?.currentNode ?? document.getElementById(_id) as HTMLElement?;

    if (element == null) return null;

    final controller = _effectiveController;
    controller.attach(element);

    void controllerListener() {
      final index = controller.page.round();
      if (index != _currentPage) {
        _currentPage = index;
        component.onPageChanged?.call(index);
      }
    }

    controller.addListener(controllerListener);

    return () {
      controller.removeListener(controllerListener);
      controller.detach();
    };
  }

  @override
  Component build(BuildContext context) {
    final isHoriz = component.direction == ScrollDirection.horizontal;

    final effectiveStyles = {
      'overflow-x': isHoriz ? 'auto' : 'hidden',
      'overflow-y': !isHoriz ? 'auto' : 'hidden',
      if (component.pageSnapping)
        'scroll-snap-type': '${isHoriz ? 'x' : 'y'} mandatory',
      'flex-direction': isHoriz
          ? (component.reverse ? 'row-reverse' : 'row')
          : (component.reverse ? 'column-reverse' : 'column'),
      ...?component.physics?.props(component.direction),
    };

    const baseClass = 'naki-pageview';
    final effectiveClasses = joinClasses([
      ?component.classes,
      kInsetOwnerClass,
      baseClass,
    ]);

    final Component child = .element(
      tag: 'naki-pageview',
      id: _id,
      key: component.key,
      classes: effectiveClasses,
      styles: Styles(raw: effectiveStyles),
      attributes: {
        if (component.pageSnapping ||
            component.physics?.type == ScrollPhysicsType.snapping)
          'snap': '',
      },
      children: component.children,
    );

    return ScrollBarWrapper(
      selector: '#$_id',
      configuration: component.scrollBarConfiguration,
      child: child,
    );
  }
}

class _PageViewBuilder extends PageView {
  /// Number of items to display.
  final int itemCount;

  /// Item builder function.
  final Component Function(BuildContext context, int index) itemBuilder;

  const _PageViewBuilder({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    super.direction,
    super.reverse,
    super.controller,
    super.physics,
    super.scrollBarConfiguration,
    super.pageSnapping,
    super.onPageChanged,
    super.classes,
    super.children = const [],
  });

  @override
  State<PageView> createState() => _PageViewBuilderState();
}

class _PageViewBuilderState extends State<_PageViewBuilder>
    with NakiStatefulMixin {
  late final String _id = nakiDomId(context, 'pageview-builder');

  int _currentPage = 0;
  PageController? _internalController;

  /// The page controller used by this component
  PageController get _effectiveController =>
      component.controller ??
      (_internalController ??= PageController(direction: component.direction));

  /// Returns the component's global key
  GlobalNodeKey<HTMLElement>? get _key =>
      component.key is GlobalNodeKey<HTMLElement>
      ? component.key as GlobalNodeKey<HTMLElement>
      : null;

  @override
  void didUpdateComponent(_PageViewBuilder oldComponent) {
    super.didUpdateComponent(oldComponent);

    if (oldComponent.controller != component.controller ||
        oldComponent.direction != component.direction) {
      if (oldComponent.controller == null) {
        _internalController?.dispose();
        _internalController = null;
      }

      refreshAfterRender();
    }
  }

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  @override
  FutureOr<VoidCallback?> afterRender(BuildContext context) {
    final element =
        _key?.currentNode ?? document.getElementById(_id) as HTMLElement?;

    if (element == null) return null;

    final controller = _effectiveController;
    controller.attach(element);

    void controllerListener() {
      final index = controller.page.round();
      if (index != _currentPage) {
        _currentPage = index;
        component.onPageChanged?.call(index);
      }
    }

    controller.addListener(controllerListener);

    return () {
      controller.removeListener(controllerListener);
      controller.detach();
    };
  }

  @override
  Component build(BuildContext context) {
    final isHoriz = component.direction == ScrollDirection.horizontal;

    final effectiveStyles = {
      'overflow-x': isHoriz ? 'auto' : 'hidden',
      'overflow-y': !isHoriz ? 'auto' : 'hidden',
      if (component.pageSnapping)
        'scroll-snap-type': '${isHoriz ? 'x' : 'y'} mandatory',
      'flex-direction': isHoriz
          ? (component.reverse ? 'row-reverse' : 'row')
          : (component.reverse ? 'column-reverse' : 'column'),
      ...?component.physics?.props(component.direction),
    };

    final List<Component> pages = [];
    for (int i = 0; i < component.itemCount; i++) {
      pages.add(component.itemBuilder(context, i));
    }

    const baseClass = 'naki-pageview';
    final effectiveClasses = joinClasses([
      ?component.classes,
      kInsetOwnerClass,
      baseClass,
    ]);

    final Component child = .element(
      tag: 'naki-pageview',
      id: _id,
      key: component.key,
      classes: effectiveClasses,
      styles: Styles(raw: effectiveStyles),
      attributes: {
        if (component.pageSnapping ||
            component.physics?.type == ScrollPhysicsType.snapping)
          'snap': '',
      },
      children: pages,
    );

    return ScrollBarWrapper(
      selector: '#$_id',
      configuration: component.scrollBarConfiguration,
      child: child,
    );
  }
}
