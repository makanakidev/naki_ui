part of 'index.dart';

/// {@template ListView}
/// A component that displays a scrollable, linear list of components.
///
/// Supports customizable scroll physics (e.g. [BouncingScrollPhysics],
/// [ClampingScrollPhysics], [NeverScrollableScrollPhysics]) and scrollbar
/// styling via [ScrollBarConfiguration].
///
/// ### Example
/// ```dart
/// ListView(
///   physics: const BouncingScrollPhysics(),
///   scrollBarConfiguration: const ScrollBarConfiguration(
///     thumbColor: Color('#888888'),
///     trackColor: Color('#f0f0f0'),
///     width: 6,
///     radius: 3,
///   ),
///   children: [
///     NakiText('Item 1'),
///     NakiText('Item 2'),
///   ],
/// )
/// ```
///
/// See also:
/// - [ListView.builder] for lazy loading of list items.
/// - [ListView.separated] for list view with separators.
/// - [GridView] for grid layout.
/// - [SingleChildScrollView] for basic scrollable component.
/// {@endtemplate}
class ListView extends StatefulComponent {
  /// Scroll direction (horizontal or vertical).
  final ScrollDirection direction;

  /// Reverse scroll direction.
  final bool reverse;

  /// Components to display in the list view.
  final List<Component> children;

  /// Scroll controller to observe or control scroll activity.
  final ScrollController? controller;

  /// Scroll physics to control scroll behavior (e.g. [BouncingScrollPhysics],
  /// [ClampingScrollPhysics], [NeverScrollableScrollPhysics]).
  final ScrollPhysics? physics;

  /// Scroll bar configuration. When provided, renders styled scrollbars.
  final ScrollBarConfiguration? scrollBarConfiguration;

  /// By default, the list view will try to fill the entire available
  /// space and might not scroll if the content is smaller than the viewport.
  ///
  /// When [shrinkWrap] is `true`, the list view will only take the space
  /// required to display its content.
  ///
  /// This can be useful for performance optimization in some cases.
  final bool shrinkWrap;

  /// Insets around [children].
  final EdgeInsets? padding;

  /// The fixed width or height of each component in [children].
  ///
  /// If [direction] is `vertical`, [itemExtent] is the fixed height of
  /// each component. If [direction] is `horizontal`, [itemExtent] is
  /// the fixed width of each component.
  ///
  /// When provided, the list view will calculate the scroll position more
  /// efficiently and, in some cases, improve rendering performance.
  final Dim? itemExtent;

  /// Additional CSS classes applied to the list view component.
  final String? classes;

  /// {@macro ListView}
  const ListView({
    super.key,
    required this.children,
    this.direction = ScrollDirection.vertical,
    this.reverse = false,
    this.shrinkWrap = false,
    this.controller,
    this.physics,
    this.scrollBarConfiguration,
    this.padding,
    this.itemExtent,
    this.classes,
  });

  /// Creates a list view whose items are generated on demand.
  ///
  /// Supports scroll physics (e.g. [BouncingScrollPhysics]) and scrollbar
  /// styling via [scrollBarConfig].
  ///
  /// ### Example
  /// ```dart
  /// ListView.builder(
  ///   itemCount: 100,
  ///   physics: const ClampingScrollPhysics(),
  ///   scrollBarConfig: const ScrollBarConfiguration(
  ///     thumbColor: Color('#6750a4'),
  ///     trackColor: Color('#e7e0ec'),
  ///     width: 6,
  ///     radius: 3,
  ///   ),
  ///   itemBuilder: (context, index) => NakiText('Item $index'),
  /// )
  /// ```
  ///
  /// ### Parameters
  /// * [itemCount]: Total number of components in the list.
  /// * [itemBuilder]: Builder function returning the component for a
  ///   given index.
  /// * [direction]: Main scroll axis direction.
  /// * [reverse]: Whether items are rendered in reverse order.
  /// * [shrinkWrap]: Whether the list sizes itself to its contents.
  /// * [itemExtent]: Optional fixed extent (height/width) for all items.
  /// * [padding]: Insets around the scroll view content.
  /// * [controller]: Controller for programmatic scroll operations.
  /// * [physics]: Scroll physics governing bounce and deceleration.
  /// * [scrollBarConfig]: Scroll bar configuration.
  /// * [classes]: Additional CSS class names applied to the list view
  ///   component.
  /// * [initialItemCount]: Initial batch size rendered for lazy loading.
  /// * [loadMoreItemCount]: Number of components appended per lazy batch.
  /// * [loadMoreThreshold]: Scroll distance in pixels from the edge
  ///   triggering the next batch.
  factory ListView.builder({
    Key? key,
    required int itemCount,
    required Component Function(BuildContext context, int index) itemBuilder,
    ScrollDirection direction = ScrollDirection.vertical,
    bool reverse = false,
    bool shrinkWrap = false,
    Dim? itemExtent,
    EdgeInsets? padding,
    ScrollController? controller,
    ScrollPhysics? physics,
    ScrollBarConfiguration? scrollBarConfig,
    String? classes,
    int? initialItemCount,
    int loadMoreItemCount = _defaultLoadMoreItemCount,
    double loadMoreThreshold = _defaultLoadMoreThreshold,
  }) {
    return _ListViewBuilder(
      key: key,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      direction: direction,
      reverse: reverse,
      controller: controller,
      physics: physics,
      shrinkWrap: shrinkWrap,
      padding: padding,
      itemExtent: itemExtent,
      classes: classes,
      initialItemCount: initialItemCount,
      loadMoreItemCount: loadMoreItemCount,
      loadMoreThreshold: loadMoreThreshold,
      scrollBarConfiguration: scrollBarConfig,
    );
  }

  /// Creates a list view whose items are separated by custom components.
  ///
  /// Supports scroll physics (e.g. [BouncingScrollPhysics]) and scrollbar
  /// styling via [scrollBarConfig].
  ///
  /// ### Example
  /// ```dart
  /// ListView.separated(
  ///   itemCount: 50,
  ///   physics: const BouncingScrollPhysics(),
  ///   scrollBarConfig: const ScrollBarConfiguration(
  ///     thumbColor: Color('#888888'),
  ///     trackColor: Color('#f0f0f0'),
  ///     width: 6,
  ///     radius: 3,
  ///   ),
  ///   separatorBuilder: (context, index) => const Divider(),
  ///   itemBuilder: (context, index) => NakiText('Item $index'),
  /// )
  /// ```
  ///
  /// ### Parameters
  /// * [itemCount]: Total number of components in the list.
  /// * [itemBuilder]: Builder function returning the component for a
  ///   given index.
  /// * [separatorBuilder]: Builder function returning the separator after
  ///   each component except the last.
  /// * [direction]: Main scroll axis direction.
  /// * [reverse]: Whether items are rendered in reverse order.
  /// * [shrinkWrap]: Whether the list sizes itself to its contents.
  /// * [padding]: Insets around the scroll view content.
  /// * [controller]: Controller for programmatic scroll operations.
  /// * [physics]: Scroll physics governing bounce and deceleration.
  /// * [scrollBarConfig]: Scroll bar configuration.
  /// * [classes]: Additional CSS class names applied to the list view
  ///   component.
  /// * [initialItemCount]: Initial batch size rendered for lazy loading.
  /// * [loadMoreItemCount]: Number of components appended per lazy batch.
  /// * [loadMoreThreshold]: Scroll distance in pixels from the edge
  ///   triggering the next batch.
  factory ListView.separated({
    Key? key,
    required int itemCount,
    required Component Function(BuildContext context, int index) itemBuilder,
    required Component Function(BuildContext context, int index)
    separatorBuilder,
    ScrollDirection direction = ScrollDirection.vertical,
    bool reverse = false,
    bool shrinkWrap = false,
    EdgeInsets? padding,
    ScrollController? controller,
    ScrollPhysics? physics,
    ScrollBarConfiguration? scrollBarConfig,
    String? classes,
    int? initialItemCount,
    int loadMoreItemCount = _defaultLoadMoreItemCount,
    double loadMoreThreshold = _defaultLoadMoreThreshold,
  }) {
    return _ListViewSeparated(
      key: key,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      separatorBuilder: separatorBuilder,
      direction: direction,
      reverse: reverse,
      controller: controller,
      physics: physics,
      shrinkWrap: shrinkWrap,
      padding: padding,
      classes: classes,
      initialItemCount: initialItemCount,
      loadMoreItemCount: loadMoreItemCount,
      loadMoreThreshold: loadMoreThreshold,
      scrollBarConfiguration: scrollBarConfig,
    );
  }

  @override
  State<ListView> createState() => _ListViewState();

  @css
  static List<StyleRule> get styles =>
      NakiStyleRegistry.once('ListView', [Rules.nakiListViewRules]);
}

class _ListViewState extends State<ListView> with NakiStatefulMixin {
  late final String _id = nakiDomId(context, 'listview');

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
  void didUpdateComponent(ListView oldComponent) {
    super.didUpdateComponent(oldComponent);

    if (oldComponent.controller != component.controller ||
        oldComponent.direction != component.direction) {
      refreshAfterRender();
    }
  }

  @override
  Component build(BuildContext context) {
    final isHoriz = component.direction == ScrollDirection.horizontal;
    final overflowX = isHoriz ? 'auto' : 'hidden';
    final overflowY = !isHoriz ? 'auto' : 'hidden';
    final extent = component.itemExtent;

    final effectiveStyles = {
      'overflow-x': overflowX,
      'overflow-y': overflowY,
      'flex-direction': isHoriz
          ? (component.reverse ? 'row-reverse' : 'row')
          : (component.reverse ? 'column-reverse' : 'column'),
      if (component.shrinkWrap)
        (isHoriz ? 'width' : 'height'): 'fit-content'
      else
        (isHoriz ? 'width' : 'height'): '100%',
      ...Css.scrollPadding(component.padding, vertical: !isHoriz),
      ...?component.physics?.props(component.direction),
      Tokens.current.listViewItemExtentHeight.name: !isHoriz && extent != null
          ? extent.cssText
          : Tokens.current.listViewItemExtentHeight.value,
      Tokens.current.listViewItemExtentWidth.name: isHoriz && extent != null
          ? extent.cssText
          : Tokens.current.listViewItemExtentWidth.value,
    };

    const baseClass = 'naki-listview';
    final effectiveClasses = joinClasses([
      ?component.classes,
      if (!isHoriz) ...[
        kInsetOwnerClass,
        if (!component.shrinkWrap) kFillScrollClass,
      ],
      baseClass,
    ]);

    final Component child = .element(
      tag: 'naki-listview',
      key: _key,
      id: _id,
      classes: effectiveClasses,
      styles: Styles(raw: effectiveStyles),
      children: component.children,
    );

    return ScrollBarWrapper(
      selector: '#$_id',
      configuration: component.scrollBarConfiguration,
      child: child,
    );
  }
}

class _ListViewBuilder extends ListView {
  /// Number of items to render.
  final int itemCount;

  /// Function that builds an item for the given index.
  final Component Function(BuildContext context, int index) itemBuilder;

  /// Initial number of items built during SSR and hydration. When null, all
  /// items are built eagerly for backward compatibility.
  final int? initialItemCount;

  /// Number of additional items appended near the scroll boundary.
  final int loadMoreItemCount;

  /// Scroll distance or offset (in pixels) from the end of the scroll container
  /// that triggers loading the next batch of [loadMoreItemCount] items.
  ///
  /// For example, a threshold of `200` means that when the user scrolls to
  /// within `200` pixels of the scroll container's edge, additional items will
  /// be built and rendered automatically.
  final double loadMoreThreshold;

  const _ListViewBuilder({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.loadMoreItemCount,
    required this.loadMoreThreshold,
    this.initialItemCount,
    super.direction,
    super.reverse,
    super.controller,
    super.physics,
    super.shrinkWrap,
    super.padding,
    super.itemExtent,
    super.classes,
    super.scrollBarConfiguration,
    super.children = const [],
  }) : assert(itemCount > 0, 'itemCount must be greater than 0'),
       assert(
         initialItemCount == null || initialItemCount > 0,
         'initialItemCount must be greater than 0',
       ),
       assert(
         loadMoreItemCount > 0,
         'loadMoreItemCount must be greater than 0',
       ),
       assert(
         loadMoreThreshold > 0,
         'loadMoreThreshold must be greater than 0',
       );

  @override
  State<ListView> createState() => _ListViewBuilderState();
}

class _ListViewBuilderState extends State<_ListViewBuilder>
    with NakiStatefulMixin {
  late String _id;
  late int _renderedItemCount;

  bool _isLazy = false;
  bool _isLoadingMore = false;

  /// Returns the component's global key
  GlobalNodeKey<HTMLElement>? get _key =>
      component.key is GlobalNodeKey<HTMLElement>
      ? component.key as GlobalNodeKey<HTMLElement>
      : null;

  @override
  void setState(VoidCallback fn) {
    if (mounted && kIsWeb) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _id = nakiDomId(context, 'listview-builder');
    _isLazy = component.initialItemCount != null;
    _renderedItemCount = _initialRenderedCount();
  }

  @override
  FutureOr<VoidCallback?> afterRender(BuildContext context) {
    final element =
        _key?.currentNode ?? document.getElementById(_id) as HTMLElement?;

    if (element == null) return null;

    final controller = component.controller;
    controller?.attach(element);

    final subscription = _isLazy
        ? EventStreamProviders.scrollEvent
              .forTarget(element)
              .listen((_) => _loadMoreIfNeeded(element))
        : null;

    if (_isLazy) onComponentRendered(() => _loadMoreIfNeeded(element));

    return () {
      subscription?.cancel();
      controller?.detach();
    };
  }

  @override
  void didUpdateComponent(_ListViewBuilder oldComponent) {
    super.didUpdateComponent(oldComponent);

    if (oldComponent.controller != component.controller ||
        oldComponent.direction != component.direction ||
        oldComponent.initialItemCount != component.initialItemCount) {
      refreshAfterRender();
    }

    if (oldComponent.itemCount != component.itemCount ||
        oldComponent.initialItemCount != component.initialItemCount) {
      _renderedItemCount = math.min(
        component.itemCount,
        oldComponent.initialItemCount == component.initialItemCount
            ? _renderedItemCount
            : _initialRenderedCount(),
      );
    }

    _isLazy = component.initialItemCount != null;
  }

  /// Returns the initial number of items to render
  int _initialRenderedCount() => component.initialItemCount == null
      ? component.itemCount
      : math.min(component.itemCount, component.initialItemCount!);

  /// Loads more items if needed
  void _loadMoreIfNeeded(HTMLElement element) {
    if (!mounted ||
        !_isLazy ||
        _isLoadingMore ||
        _renderedItemCount >= component.itemCount) {
      return;
    }

    final isVert = component.direction == ScrollDirection.vertical;
    final double remaining;

    if (component.reverse) {
      remaining = (isVert ? element.scrollTop : element.scrollLeft).toDouble();
    } else {
      remaining =
          (isVert
                  ? element.scrollHeight -
                        element.scrollTop -
                        element.clientHeight
                  : element.scrollWidth -
                        element.scrollLeft -
                        element.clientWidth)
              .toDouble();
    }

    if (remaining > component.loadMoreThreshold) return;

    _isLoadingMore = true;

    final oldScrollExtent = isVert ? element.scrollHeight : element.scrollWidth;
    final oldScrollOffset = isVert ? element.scrollTop : element.scrollLeft;

    Future.delayed(const Duration(milliseconds: _defaultLoadMoreDelay), () {
      if (!mounted) return;

      setState(() {
        _renderedItemCount = math.min(
          component.itemCount,
          _renderedItemCount + component.loadMoreItemCount,
        );

        _isLoadingMore = false;
      });

      onComponentRendered(() {
        if (component.reverse && mounted) {
          final newScrollExtent = isVert
              ? element.scrollHeight
              : element.scrollWidth;

          final delta = newScrollExtent - oldScrollExtent;

          if (delta > 0) {
            if (isVert) {
              element.scrollTop = oldScrollOffset + delta;
            } else {
              element.scrollLeft = oldScrollOffset + delta;
            }
          }
        }
        _loadMoreIfNeeded(element);
      });
    });
  }

  @override
  Component build(BuildContext context) {
    final isHoriz = component.direction == ScrollDirection.horizontal;
    final overflowX = isHoriz ? 'auto' : 'hidden';
    final overflowY = !isHoriz ? 'auto' : 'hidden';

    final effectiveStyles = {
      'overflow-x': overflowX,
      'overflow-y': overflowY,
      'flex-direction': isHoriz
          ? (component.reverse ? 'row-reverse' : 'row')
          : (component.reverse ? 'column-reverse' : 'column'),
      if (component.shrinkWrap)
        (isHoriz ? 'width' : 'height'): 'fit-content'
      else
        (isHoriz ? 'width' : 'height'): '100%',
      ...Css.scrollPadding(component.padding, vertical: !isHoriz),
      ...?component.physics?.props(component.direction),
    };

    final List<Component> items = [];
    for (int i = 0; i < _renderedItemCount; i++) {
      items.add(component.itemBuilder(context, i));
    }

    const baseClass = 'naki-listview';
    final effectiveClasses = joinClasses([
      ?component.classes,
      if (!isHoriz) ...[
        kInsetOwnerClass,
        if (!component.shrinkWrap) kFillScrollClass,
      ],
      baseClass,
    ]);

    final Component child = .element(
      tag: 'naki-listview',
      id: _id,
      key: component.key,
      classes: effectiveClasses,
      styles: Styles(raw: effectiveStyles),
      children: items,
    );

    return ScrollBarWrapper(
      selector: '#$_id',
      configuration: component.scrollBarConfiguration,
      child: child,
    );
  }
}

class _ListViewSeparated extends ListView {
  /// Number of items to render.
  final int itemCount;

  /// Function that builds an item for the given index.
  final Component Function(BuildContext context, int index) itemBuilder;

  /// Function that builds a separator for the given index. This could
  /// be used to add spaces, dividers, or any component between items
  /// at certain intervals or indices.
  ///
  /// The separator is not built for the last item.
  final Component Function(BuildContext context, int index) separatorBuilder;

  /// Initial number of items to render.
  final int? initialItemCount;

  /// Number of additional items appended near the scroll boundary.
  final int loadMoreItemCount;

  /// Scroll distance or offset (in pixels) from the end of the scroll container
  /// that triggers loading the next batch of [loadMoreItemCount] items.
  ///
  /// For example, a threshold of `200` means that when the user scrolls to
  /// within `200` pixels of the scroll container's edge, additional items will
  /// be built and rendered automatically.
  final double loadMoreThreshold;

  const _ListViewSeparated({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.separatorBuilder,
    required this.loadMoreItemCount,
    required this.loadMoreThreshold,
    this.initialItemCount,
    super.direction,
    super.reverse,
    super.controller,
    super.physics,
    super.shrinkWrap,
    super.padding,
    super.scrollBarConfiguration,
    super.classes,
    super.children = const [],
  }) : assert(itemCount > 0, 'itemCount must be greater than 0'),
       assert(
         initialItemCount == null || initialItemCount > 0,
         'initialItemCount must be greater than 0',
       ),
       assert(
         loadMoreItemCount > 0,
         'loadMoreItemCount must be greater than 0',
       ),
       assert(
         loadMoreThreshold > 0,
         'loadMoreThreshold must be greater than 0',
       );

  @override
  State<ListView> createState() => _ListViewSeparatedState();
}

class _ListViewSeparatedState extends State<_ListViewSeparated>
    with NakiStatefulMixin {
  late String _id;
  late int _renderedItemCount;

  bool _isLazy = false;
  bool _isLoadingMore = false;

  /// Returns the component's global key
  GlobalNodeKey<HTMLElement>? get _key =>
      component.key is GlobalNodeKey<HTMLElement>
      ? component.key as GlobalNodeKey<HTMLElement>
      : null;

  @override
  void setState(VoidCallback fn) {
    if (mounted && kIsWeb) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _id = nakiDomId(context, 'listview-separated');
    _isLazy = component.initialItemCount != null;
    _renderedItemCount = _initialRenderedCount();
  }

  @override
  FutureOr<VoidCallback?> afterRender(BuildContext context) {
    final element =
        _key?.currentNode ?? document.getElementById(_id) as HTMLElement?;

    if (element == null) return null;

    final controller = component.controller;
    controller?.attach(element);

    final subscription = _isLazy
        ? EventStreamProviders.scrollEvent
              .forTarget(element)
              .listen((_) => _loadMoreIfNeeded(element))
        : null;

    if (_isLazy) onComponentRendered(() => _loadMoreIfNeeded(element));

    return () {
      subscription?.cancel();
      controller?.detach();
    };
  }

  @override
  void didUpdateComponent(_ListViewSeparated oldComponent) {
    super.didUpdateComponent(oldComponent);

    if (oldComponent.controller != component.controller ||
        oldComponent.direction != component.direction ||
        oldComponent.initialItemCount != component.initialItemCount) {
      refreshAfterRender();
    }

    if (oldComponent.itemCount != component.itemCount ||
        oldComponent.initialItemCount != component.initialItemCount) {
      _renderedItemCount = math.min(
        component.itemCount,
        oldComponent.initialItemCount == component.initialItemCount
            ? _renderedItemCount
            : _initialRenderedCount(),
      );
    }

    _isLazy = component.initialItemCount != null;
  }

  /// Returns the initial number of items to render
  int _initialRenderedCount() => component.initialItemCount == null
      ? component.itemCount
      : math.min(component.itemCount, component.initialItemCount!);

  /// Loads more items if needed
  void _loadMoreIfNeeded(HTMLElement element) {
    if (!mounted ||
        !_isLazy ||
        _isLoadingMore ||
        _renderedItemCount >= component.itemCount) {
      return;
    }

    final isVert = component.direction == ScrollDirection.vertical;
    final double remaining;

    if (component.reverse) {
      remaining = (isVert ? element.scrollTop : element.scrollLeft).toDouble();
    } else {
      remaining =
          (isVert
                  ? element.scrollHeight -
                        element.scrollTop -
                        element.clientHeight
                  : element.scrollWidth -
                        element.scrollLeft -
                        element.clientWidth)
              .toDouble();
    }

    if (remaining > component.loadMoreThreshold) return;

    _isLoadingMore = true;

    final oldScrollExtent = isVert ? element.scrollHeight : element.scrollWidth;
    final oldScrollOffset = isVert ? element.scrollTop : element.scrollLeft;

    Future.delayed(const Duration(milliseconds: _defaultLoadMoreDelay), () {
      if (!mounted) return;

      setState(() {
        _renderedItemCount = math.min(
          component.itemCount,
          _renderedItemCount + component.loadMoreItemCount,
        );

        _isLoadingMore = false;
      });

      onComponentRendered(() {
        if (component.reverse && mounted) {
          final newScrollExtent = isVert
              ? element.scrollHeight
              : element.scrollWidth;

          final delta = newScrollExtent - oldScrollExtent;

          if (delta > 0) {
            if (isVert) {
              element.scrollTop = oldScrollOffset + delta;
            } else {
              element.scrollLeft = oldScrollOffset + delta;
            }
          }
        }

        _loadMoreIfNeeded(element);
      });
    });
  }

  @override
  Component build(BuildContext context) {
    final isHoriz = component.direction == ScrollDirection.horizontal;
    final overflowX = isHoriz ? 'auto' : 'hidden';
    final overflowY = !isHoriz ? 'auto' : 'hidden';
    final List<Component> items = [];

    final effectiveStyles = {
      'overflow-x': overflowX,
      'overflow-y': overflowY,
      'flex-direction': isHoriz
          ? (component.reverse ? 'row-reverse' : 'row')
          : (component.reverse ? 'column-reverse' : 'column'),
      if (component.shrinkWrap)
        (isHoriz ? 'width' : 'height'): 'fit-content'
      else
        (isHoriz ? 'width' : 'height'): '100%',
      ...Css.scrollPadding(component.padding, vertical: !isHoriz),
      ...?component.physics?.props(component.direction),
    };

    const baseClass = 'naki-listview';
    final effectiveClasses = joinClasses([
      ?component.classes,
      if (!isHoriz) ...[
        kInsetOwnerClass,
        if (!component.shrinkWrap) kFillScrollClass,
      ],
      baseClass,
    ]);

    for (int i = 0; i < _renderedItemCount; i++) {
      items.add(component.itemBuilder(context, i));
      if (i < component.itemCount - 1) {
        items.add(component.separatorBuilder(context, i));
      }
    }

    final Component child = .element(
      tag: 'naki-listview',
      id: _id,
      key: component.key,
      classes: effectiveClasses,
      styles: Styles(raw: effectiveStyles),
      children: items,
    );

    return ScrollBarWrapper(
      selector: '#$_id',
      configuration: component.scrollBarConfiguration,
      child: child,
    );
  }
}
