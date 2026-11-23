part of 'index.dart';

/// {@template GridView}
/// A component that displays a scrollable, 2D array of components
/// in a grid layout.
///
/// Supports customizable scroll physics (e.g. [BouncingScrollPhysics],
/// [ClampingScrollPhysics]) and custom scrollbar styling via
/// [ScrollBarConfiguration].
///
/// ### Example
/// ```dart
/// GridView(
///   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
///   physics: const BouncingScrollPhysics(),
///   scrollBarConfiguration: const ScrollBarConfiguration(
///     thumbColor: Color('#888888'),
///     trackColor: Color('#f0f0f0'),
///     width: 6,
///     radius: 3,
///   ),
///   children: [
///     Container(child: NakiText('Card 1')),
///     Container(child: NakiText('Card 2')),
///   ],
/// )
/// ```
///
/// See also:
/// - [GridView.count] for grid with fixed number of columns.
/// - [GridView.extent] for grid with fixed max column size.
/// - [GridView.builder] for grid with lazy loading.
/// {@endtemplate}
class GridView extends StatefulComponent {
  /// Components to display in the grid.
  final List<Component> children;

  /// Grid delegate for determining column/row sizing.
  final SliverGridDelegate? gridDelegate;

  /// Scroll direction.
  final ScrollDirection direction;

  /// Reverse scroll direction.
  final bool reverse;

  /// Scroll controller to observe and control scrolling.
  final ScrollController? controller;

  /// Scroll physics for determining how the grid scrolls (e.g. [BouncingScrollPhysics],
  /// [ClampingScrollPhysics], [NeverScrollableScrollPhysics]).
  final ScrollPhysics? physics;

  /// Scroll bar configuration. When provided, renders styled scrollbars.
  final ScrollBarConfiguration? scrollBarConfiguration;

  /// When `true`, the grid will only take up as much space
  /// as its contents require. Otherwise, it will take
  /// up all available space in its parent.
  final bool shrinkWrap;

  /// Insets around [children].
  final EdgeInsets? padding;

  /// Additional CSS classes applied to the grid component.
  final String? classes;

  /// Whether to automatically expand the last component across
  /// unfilled columns (noticable when the number of [children]
  /// is not a multiple of the cross axis count defined in
  /// [gridDelegate]).
  ///
  /// For example:
  /// - 2 columns and 1 component: the component will expand across
  ///   the unfilled column to fill the row.
  /// - 3 columns and 2 components: the last component will expand across
  ///   the unfilled column to fill the row.
  /// - 3 columns and 3 components: the last component will not expand.
  final bool expandLastItem;

  /// {@macro GridView}
  const GridView({
    super.key,
    required this.children,
    this.gridDelegate,
    this.direction = ScrollDirection.vertical,
    this.reverse = false,
    this.shrinkWrap = false,
    this.expandLastItem = false,
    this.controller,
    this.physics,
    this.scrollBarConfiguration,
    this.padding,
    this.classes,
  });

  /// Creates a grid layout with a fixed column count.
  ///
  /// Supports scroll physics via [physics] and scrollbar
  /// configuration via [scrollBarConfig].
  ///
  /// ### Example
  /// ```dart
  /// GridView.count(
  ///   2,
  ///   physics: const BouncingScrollPhysics(),
  ///   scrollBarConfig: const ScrollBarConfiguration(
  ///     thumbColor: Color('#888888'),
  ///     trackColor: Color('#f0f0f0'),
  ///     width: 6,
  ///     radius: 3,
  ///   ),
  ///   children: [
  ///     Container(child: NakiText('Card 1')),
  ///     Container(child: NakiText('Card 2')),
  ///   ],
  /// )
  /// ```
  ///
  /// ### Parameters
  /// * [crossAxisCount]: Fixed number of columns in the cross
  ///   ScrollDirection.
  /// * [mainAxisSpacing]: Spacing between components along
  ///   the scroll ScrollDirection.
  /// * [crossAxisSpacing]: Spacing between components along
  ///   the cross ScrollDirection.
  /// * [childAspectRatio]: Aspect ratio of each of the
  ///   grid's [children].
  /// * [mainAxisExtent]: Optional fixed main-axis height/width,
  ///   based on [direction], overriding [childAspectRatio].
  /// * [children]: List of components in the grid.
  /// * [direction]: Main scroll axis direction.
  /// * [reverse]: Whether components are rendered in reverse order.
  /// * [shrinkWrap]: Whether the grid sizes itself to its contents.
  /// * [expandLastItem]: Whether to expand the last component across
  ///   unfilled columns.
  /// * [controller]: Controller for programmatic scroll operations.
  /// * [physics]: Scroll physics governing bounce and deceleration.
  /// * [scrollBarConfig]: Scroll bar configuration.
  /// * [padding]: Insets around the grid content.
  /// * [classes]: Additional CSS class names applied to the grid.
  factory GridView.count(
    int crossAxisCount, {
    Key? key,
    Dim mainAxisSpacing = const Dim.px(16),
    Dim crossAxisSpacing = const Dim.px(16),
    AspectRatioType? childAspectRatio,
    Dim? mainAxisExtent,
    List<Component> children = const [],
    ScrollDirection direction = ScrollDirection.vertical,
    bool reverse = false,
    bool shrinkWrap = false,
    bool expandLastItem = false,
    ScrollController? controller,
    ScrollPhysics? physics,
    ScrollBarConfiguration? scrollBarConfig,
    EdgeInsets? padding,
    String? classes,
  }) {
    return GridView(
      key: key,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: childAspectRatio,
        mainAxisExtent: mainAxisExtent,
      ),
      direction: direction,
      reverse: reverse,
      controller: controller,
      physics: physics,
      shrinkWrap: shrinkWrap,
      expandLastItem: expandLastItem,
      scrollBarConfiguration: scrollBarConfig,
      padding: padding,
      classes: classes,
      children: children,
    );
  }

  /// Creates a grid layout with maximum cross-axis extent.
  ///
  /// Supports scroll physics via [physics] and scrollbar
  /// configuration via [scrollBarConfig].
  ///
  /// ### Example
  /// ```dart
  /// GridView.extent(
  ///   Dim.px(200),
  ///   physics: const ClampingScrollPhysics(),
  ///   scrollBarConfig: const ScrollBarConfiguration(
  ///     thumbColor: Color('#888888'),
  ///     trackColor: Color('#f0f0f0'),
  ///     width: 6,
  ///     radius: 3,
  ///   ),
  ///   children: [ ... ],
  /// )
  /// ```
  ///
  /// ### Parameters
  /// * [maxCrossAxisExtent]: Maximum height/width of each
  ///   component in the
  ///   cross axis relative to [direction].
  /// * [mainAxisSpacing]: Spacing between components along
  ///   the scroll ScrollDirection.
  /// * [crossAxisSpacing]: Spacing between components along
  ///   the cross ScrollDirection.
  /// * [childAspectRatio]: Aspect ratio of each of the
  ///   grid's [children].
  /// * [mainAxisExtent]: Optional fixed main-axis height/width,
  ///   based on [direction], overriding [childAspectRatio].
  /// * [children]: List of components in the grid.
  /// * [direction]: Main scroll axis direction.
  /// * [reverse]: Whether components are rendered in reverse order.
  /// * [shrinkWrap]: Whether the grid sizes itself to its contents.
  /// * [expandLastItem]: Whether to expand the last component across
  ///   unfilled columns.
  /// * [controller]: Controller for programmatic scroll operations.
  /// * [physics]: Scroll physics governing bounce and deceleration.
  /// * [scrollBarConfig]: Scroll bar configuration.
  /// * [padding]: Insets around the grid content.
  /// * [classes]: Additional CSS class names applied to the grid.
  factory GridView.extent(
    Dim maxCrossAxisExtent, {
    Key? key,
    Dim mainAxisSpacing = const Dim.px(16),
    Dim crossAxisSpacing = const Dim.px(16),
    AspectRatioType? childAspectRatio,
    Dim? mainAxisExtent,
    List<Component> children = const [],
    ScrollDirection direction = ScrollDirection.vertical,
    bool reverse = false,
    bool shrinkWrap = false,
    bool expandLastItem = false,
    ScrollController? controller,
    ScrollPhysics? physics,
    ScrollBarConfiguration? scrollBarConfig,
    EdgeInsets? padding,
    String? classes,
  }) {
    return GridView(
      key: key,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: maxCrossAxisExtent,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: childAspectRatio,
        mainAxisExtent: mainAxisExtent,
      ),
      direction: direction,
      reverse: reverse,
      controller: controller,
      physics: physics,
      shrinkWrap: shrinkWrap,
      expandLastItem: expandLastItem,
      scrollBarConfiguration: scrollBarConfig,
      padding: padding,
      classes: classes,
      children: children,
    );
  }

  /// Creates a grid layout dynamically built with a builder.
  ///
  /// Supports scroll physics via [physics] and scrollbar
  /// configuration via [scrollBarConfig].
  ///
  /// ### Example
  /// ```dart
  /// GridView.builder(
  ///   itemCount: 40,
  ///   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
  ///   physics: const BouncingScrollPhysics(),
  ///   scrollBarConfig: const ScrollBarConfiguration(
  ///     thumbColor: Color('#888888'),
  ///     trackColor: Color('#f0f0f0'),
  ///     width: 6,
  ///     radius: 3,
  ///   ),
  ///   itemBuilder: (context, index) => Container(child: NakiText('Item $index')),
  /// )
  /// ```
  ///
  /// ### Parameters
  /// * [itemCount]: Total number of components in the grid.
  /// * [itemBuilder]: Builder function returning the component for a
  ///   given index.
  /// * [gridDelegate]: Delegate controlling grid layout and geometry.
  /// * [direction]: Main scroll axis direction.
  /// * [reverse]: Whether components are rendered in reverse order.
  /// * [shrinkWrap]: Whether the grid sizes itself to its contents.
  /// * [expandLastItem]: Whether to expand the last component across
  ///   unfilled columns.
  /// * [controller]: Controller for programmatic scroll operations.
  /// * [physics]: Scroll physics governing bounce and deceleration.
  /// * [scrollBarConfig]: Scroll bar configuration.
  /// * [padding]: Insets around the grid content.
  /// * [classes]: Additional CSS class names applied to the grid.
  /// * [initialItemCount]: Initial batch size rendered for lazy loading.
  /// * [loadMoreItemCount]: Number of items appended per lazy batch.
  /// * [loadMoreThreshold]: Scroll distance in pixels from the edge
  ///   triggering the next batch.
  factory GridView.builder({
    Key? key,
    required int itemCount,
    required Component Function(BuildContext context, int index) itemBuilder,
    required SliverGridDelegate gridDelegate,
    ScrollDirection direction = ScrollDirection.vertical,
    bool reverse = false,
    bool shrinkWrap = false,
    bool expandLastItem = false,
    ScrollController? controller,
    ScrollPhysics? physics,
    ScrollBarConfiguration? scrollBarConfig,
    EdgeInsets? padding,
    String? classes,
    int? initialItemCount,
    int loadMoreItemCount = _defaultLoadMoreItemCount,
    double loadMoreThreshold = _defaultLoadMoreThreshold,
  }) {
    return _GridViewBuilder(
      key: key,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      gridDelegate: gridDelegate,
      direction: direction,
      reverse: reverse,
      controller: controller,
      physics: physics,
      scrollBarConfiguration: scrollBarConfig,
      shrinkWrap: shrinkWrap,
      expandLastItem: expandLastItem,
      padding: padding,
      classes: classes,
      initialItemCount: initialItemCount,
      loadMoreItemCount: loadMoreItemCount,
      loadMoreThreshold: loadMoreThreshold,
    );
  }

  @override
  State<GridView> createState() => _GridViewState();

  static List<StyleRule> get styles => ScrollingStyles.gridView;
}

class _GridViewState extends State<GridView> with NakiStatefulMixin {
  late final String _id = nakiDomId(context, 'gridview');

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
  void didUpdateComponent(GridView oldComponent) {
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

    String? crossAxisTemplate;
    String? gapStyle;
    Dim? mainAxisExtent;
    int? crossAxisCount;

    AspectRatioType? childAspect;
    final delegate = component.gridDelegate;

    if (delegate is SliverGridDelegateWithFixedCrossAxisCount) {
      crossAxisCount = delegate.crossAxisCount;
      crossAxisTemplate = 'repeat($crossAxisCount, 1fr)';
      gapStyle =
          '${delegate.mainAxisSpacing.cssText} ${delegate.crossAxisSpacing.cssText}';

      childAspect = delegate.childAspectRatio;
      mainAxisExtent = delegate.mainAxisExtent;
      if (childAspect == null) mainAxisExtent ??= Dim.auto;
    } else if (delegate is SliverGridDelegateWithMaxCrossAxisExtent) {
      crossAxisTemplate =
          'repeat(auto-fill, minmax(${delegate.maxCrossAxisExtent.cssText}, 1fr))';
      gapStyle =
          '${delegate.mainAxisSpacing.cssText} ${delegate.crossAxisSpacing.cssText}';

      childAspect = delegate.childAspectRatio;
      mainAxisExtent = delegate.mainAxisExtent;
      if (childAspect == null) mainAxisExtent ??= Dim.auto;
    }

    final effectiveStyles = <String, String>{
      Tokens.current.gridGap.name: ?gapStyle,
      'overflow-x': overflowX,
      'overflow-y': overflowY,
      if (isHoriz) ...{
        'grid-auto-flow': 'column',
        'grid-template-rows': ?crossAxisTemplate,
      } else
        'grid-template-columns': ?crossAxisTemplate,
      if (mainAxisExtent != null)
        (isHoriz ? 'grid-auto-columns' : 'grid-auto-rows'):
            mainAxisExtent.cssText,
      if (component.shrinkWrap)
        (isHoriz ? 'width' : 'height'): 'fit-content'
      else
        (isHoriz ? 'width' : 'height'): '100%',
      ...Css.scrollPadding(component.padding, vertical: !isHoriz),
      ...?component.physics?.props(component.direction),
    };

    bool isRowPartiallyFilled = false;
    List<Component> children = [];
    final totalCount = component.children.length;

    if (crossAxisCount != null && crossAxisCount > 0) {
      isRowPartiallyFilled = (totalCount % crossAxisCount) != 0;
    }

    for (int i = 0; i < totalCount; i++) {
      final c = component.children[i];
      final isLast = i == totalCount - 1;

      final tile = c is GridTile ? c : null;
      final child = tile != null ? tile.child : c;
      final colSpan = tile?.columnSpan;
      final rowSpan = tile?.rowSpan;

      final spanLast =
          isLast && component.expandLastItem && isRowPartiallyFilled;
      final isFullWidth = spanLast || (tile?.fullWidth ?? false);

      final hasGridSpan = isFullWidth || colSpan != null || rowSpan != null;

      final tileStyles = hasGridSpan
          ? {
              if (isFullWidth)
                'grid-column': '1 / -1'
              else if (colSpan != null)
                'grid-column': 'span $colSpan',
              if (rowSpan != null) 'grid-row': 'span $rowSpan',
            }
          : null;

      final effectiveChild = mainAxisExtent == null && childAspect != null
          ? AspectRatio(child: child, aspectRatio: childAspect)
          : child;

      children.add(
        .wrapElement(
          styles: Styles(raw: tileStyles),
          child: effectiveChild,
        ),
      );
    }

    if (component.reverse) children = children.reversed.toList();

    const baseClass = 'naki-gridview';
    final effectiveClasses = joinClasses([
      ?component.classes,
      if (!isHoriz) ...[
        kInsetOwnerClass,
        if (!component.shrinkWrap) kFillScrollClass,
      ],
      baseClass,
    ]);

    final Component child = .element(
      tag: 'naki-gridview',
      id: _id,
      key: component.key,
      classes: effectiveClasses,
      styles: Styles(raw: effectiveStyles),
      children: children,
    );

    return ScrollBarWrapper(
      selector: '#$_id',
      configuration: component.scrollBarConfiguration,
      child: child,
    );
  }
}

class _GridViewBuilder extends GridView {
  /// The total number of items in the grid.
  final int itemCount;

  /// Builder function to create components for each index.
  final Component Function(BuildContext context, int index) itemBuilder;

  /// Initial number of items to render.
  final int? initialItemCount;

  /// Number of items to load at a time when loading more.
  final int loadMoreItemCount;

  /// Scroll distance or offset (in pixels) from the end of the
  /// grid container  that triggers loading the next batch of
  /// [loadMoreItemCount] items.
  ///
  /// For example, a threshold of `200` means that when the user
  /// scrolls to within `200` pixels of the grid container's edge,
  /// additional items will be built and rendered automatically.
  final double loadMoreThreshold;

  const _GridViewBuilder({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.initialItemCount,
    required this.loadMoreItemCount,
    required this.loadMoreThreshold,
    required super.gridDelegate,
    super.direction,
    super.reverse,
    super.controller,
    super.physics,
    super.scrollBarConfiguration,
    super.shrinkWrap,
    super.expandLastItem,
    super.padding,
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
  State<GridView> createState() => _GridViewBuilderState();
}

class _GridViewBuilderState extends State<_GridViewBuilder>
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
    _isLazy = component.initialItemCount != null;
    _id = nakiDomId(context, 'gridview_builder');
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
  void didUpdateComponent(_GridViewBuilder oldComponent) {
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

    String? crossAxisTemplate;
    String? gapStyle;
    Dim? mainAxisExtent;
    int? crossAxisCount;

    AspectRatioType? childAspect;
    final delegate = component.gridDelegate;

    if (delegate is SliverGridDelegateWithFixedCrossAxisCount) {
      crossAxisCount = delegate.crossAxisCount;
      crossAxisTemplate = 'repeat($crossAxisCount, 1fr)';
      gapStyle =
          '${delegate.mainAxisSpacing.cssText} ${delegate.crossAxisSpacing.cssText}';

      childAspect = delegate.childAspectRatio;
      mainAxisExtent = delegate.mainAxisExtent;
      if (childAspect == null) mainAxisExtent ??= Dim.auto;
    } else if (delegate is SliverGridDelegateWithMaxCrossAxisExtent) {
      crossAxisTemplate =
          'repeat(auto-fill, minmax(${delegate.maxCrossAxisExtent.cssText}, 1fr))';
      gapStyle =
          '${delegate.mainAxisSpacing.cssText} ${delegate.crossAxisSpacing.cssText}';

      childAspect = delegate.childAspectRatio;
      mainAxisExtent = delegate.mainAxisExtent;
      if (childAspect == null) mainAxisExtent ??= Dim.auto;
    }

    final effectiveStyles = <String, String>{
      Tokens.current.gridGap.name: ?gapStyle,
      'overflow-x': overflowX,
      'overflow-y': overflowY,
      if (isHoriz) ...{
        'grid-auto-flow': 'column',
        'grid-template-rows': ?crossAxisTemplate,
      } else
        'grid-template-columns': ?crossAxisTemplate,
      if (mainAxisExtent != null)
        (isHoriz ? 'grid-auto-columns' : 'grid-auto-rows'):
            mainAxisExtent.cssText,
      if (component.shrinkWrap)
        (isHoriz ? 'width' : 'height'): 'fit-content'
      else
        (isHoriz ? 'width' : 'height'): '100%',
      ...Css.scrollPadding(component.padding, vertical: !isHoriz),
      ...?component.physics?.props(component.direction),
    };

    bool isRowPartiallyFilled = false;
    List<Component> items = [];

    if (crossAxisCount != null && crossAxisCount > 0) {
      isRowPartiallyFilled = (component.itemCount % crossAxisCount) != 0;
    }

    for (int i = 0; i < _renderedItemCount; i++) {
      final c = component.itemBuilder(context, i);
      final isLastOfTotal = i == component.itemCount - 1;

      final tile = c is GridTile ? c : null;
      final child = tile != null ? tile.child : c;
      final colSpan = tile?.columnSpan;
      final rowSpan = tile?.rowSpan;

      final isSpanLast =
          isLastOfTotal && component.expandLastItem && isRowPartiallyFilled;
      final isFullWidth = isSpanLast || (tile?.fullWidth ?? false);
      final hasGridSpan = isFullWidth || colSpan != null || rowSpan != null;

      final tileStyles = hasGridSpan
          ? {
              if (isFullWidth)
                'grid-column': '1 / -1'
              else if (colSpan != null)
                'grid-column': 'span $colSpan',
              if (rowSpan != null) 'grid-row': 'span $rowSpan',
            }
          : null;

      final effectiveChild = mainAxisExtent == null && childAspect != null
          ? AspectRatio(child: child, aspectRatio: childAspect)
          : child;

      items.add(
        .wrapElement(
          styles: Styles(raw: tileStyles),
          child: effectiveChild,
        ),
      );
    }

    if (component.reverse) items = items.reversed.toList();

    const baseClass = 'naki-gridview';
    final effectiveClasses = joinClasses([
      ?component.classes,
      if (!isHoriz) ...[
        kInsetOwnerClass,
        if (!component.shrinkWrap) kFillScrollClass,
      ],
      baseClass,
    ]);

    final Component child = .element(
      tag: 'naki-gridview',
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
